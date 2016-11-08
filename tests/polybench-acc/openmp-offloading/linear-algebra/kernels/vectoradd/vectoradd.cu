#include <cuda.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>
#include <time.h>
#include <unistd.h>

#define POLYBENCH_TIME 1

#include "vectoradd.h"
#include <polybench.h>
#include <polybenchUtilFuncts.h>

// Macros to generate openmp schedule.
#include <macros.h>

// Time measures implementation.
#include <timing.h>

// Offloading support functions.
#include <offload.h>

// define the error threshold for the results "not matching"
#define PERCENT_DIFF_ERROR_THRESHOLD 0.05

#define GPU_DEVICE 0

#define RUN_ON_CPU

/* ------------------------------------------------------------- */
/* Arrays initialization. */
void init_array(int ni, DATA_TYPE POLYBENCH_1D(A, NI, ni),
                DATA_TYPE POLYBENCH_1D(B, NI, ni),
                DATA_TYPE POLYBENCH_1D(C, NI, ni)) {
  int i;

  for (i = 0; i < ni; i++) {
      A[i] = ((DATA_TYPE) i ) / NI;
  }

  for (i = 0; i < ni; i++) {
      B[i] = ((DATA_TYPE) i ) / NI;
  }

  for (i = 0; i < ni; i++) {
      C[i] = 0.0;
  }
}

/* ------------------------------------------------------------- */
void copy_array(int ni, DATA_TYPE POLYBENCH_1D(C_source, NI, ni), DATA_TYPE POLYBENCH_1D(C_dest, NI, ni)) {
  int i;

  for (i = 0; i < ni; i++) {
      C_dest[i] = C_source[i];
      // printf("%4.2f - %4.2f\n", C_dest[i][j], C_source[i][j]);
  }
}

/* ------------------------------------------------------------- */
void compareResults(int ni, DATA_TYPE POLYBENCH_1D(C, NI, ni),
                    DATA_TYPE POLYBENCH_1D(C_output, NI, ni)) {
  int i, fail;
  fail = 0;

  // Compare CPU and GPU outputs
  for (i = 0; i < ni; i++) {
      if (percentDiff(C[i], C_output[i]) > PERCENT_DIFF_ERROR_THRESHOLD) {
        fail++;
      }
  }

  // Print results
  fprintf(stderr,
          "Non-Matching CPU-GPU Outputs Beyond Error Threshold of %4.2f "
          "Percent: %d\n",
          PERCENT_DIFF_ERROR_THRESHOLD, fail);
}

/* ------------------------------------------------------------- */
/* DCE code. Must scan the entire live-out data.
   Can be used also to check the correctness of the output. */
static void print_array(int ni,
                        DATA_TYPE POLYBENCH_1D(C, NI, ni)) {
  int i;

  for (i = 0; i < ni; i++){
    fprintf(stderr, DATA_PRINTF_MODIFIER, C[i]);
  }
  fprintf(stderr, "\n");
}

/* ------------------------------------------------------------- */
/* Original Version. */
void vectoradd(int ni, DATA_TYPE POLYBENCH_1D(A, NI, ni),
          DATA_TYPE POLYBENCH_1D(B, NI, ni),
          DATA_TYPE POLYBENCH_1D(C, NI, ni)) {
  int i;

  for (i = 0; i < _PB_NI; i++) {
        C[i] = A[i] + B[i];
  }
}

/* ------------------------------------------------------------- */
void vectoradd_original(int ni, DATA_TYPE POLYBENCH_1D(A, NI, ni),
                   DATA_TYPE POLYBENCH_1D(B, NI, ni),
                   DATA_TYPE POLYBENCH_1D(C, NI, ni)) {

  /* Start timer. */
  HOOKOMP_TIMING_SEQ_START;

  vectoradd(ni, A, B, C);

  /* Stop and print timer. */
  HOOKOMP_TIMING_SEQ_STOP;
}

/* ------------------------------------------------------------- */
/* Main computational kernel. The whole function will be timed,
   including the call and return. */
void vectoradd_omp_kernel(int ni, DATA_TYPE POLYBENCH_1D(A, NI, ni),
                     DATA_TYPE POLYBENCH_1D(B, NI, ni),
                     DATA_TYPE POLYBENCH_1D(C, NI, ni)) {

  int i;

  #pragma scop
  #pragma omp parallel num_threads(OPENMP_NUM_THREADS)
  {
    /* C := alpha*A*B + beta*C */
    current_loop_index = 0;
    num_threads_defined = OPENMP_NUM_THREADS;
    // Copy to device A, B, C.
    q_data_transfer_write = (sizeof(DATA_TYPE) * NI) +
                            (sizeof(DATA_TYPE) * NI);
    // Copy back C.
    q_data_transfer_read = (sizeof(DATA_TYPE) * NI);

    // 0: MEMORY_ALLOC_DEFAULT, 1: MEMORY_ALLOC_PAGEABLE, 2: MEMORY_ALLOC_PINNED
    type_of_data_allocation = MEMORY_ALLOC_PAGEABLE;
    #pragma omp for private(i) schedule(OPENMP_SCHEDULE_WITH_CHUNK)
    for (i = 0; i < _PB_NI; i++) {
      C[i] = A[i] + B[i];
    }
  }
  #pragma endscop
}
/* ------------------------------------------------------------- */
void vectoradd_omp(int ni, DATA_TYPE POLYBENCH_1D(A, NI, ni),
              DATA_TYPE POLYBENCH_1D(B, NI, ni),
              DATA_TYPE POLYBENCH_1D(C_outputFromOMP, NI, ni)) {

  /* Start timer. */
  HOOKOMP_TIMING_OMP_START;

  vectoradd_omp_kernel(ni, A, B, C_outputFromOMP);

  /* Stop and print timer. */
  HOOKOMP_TIMING_OMP_STOP;
}

/*--------------------------------------------------------------*/
/* CUDA */
void GPU_argv_init() {
  cudaDeviceProp deviceProp;
  fprintf(stderr, "GPU init.\n");

  cudaGetDeviceProperties(&deviceProp, GPU_DEVICE);
  fprintf(stderr, "setting device %d with name %s\n", GPU_DEVICE,
          deviceProp.name);
  cudaSetDevice(GPU_DEVICE);
}

/* ------------------------------------------------------------- */
__global__ void vectoradd_cuda_kernel(int ni, DATA_TYPE *a, DATA_TYPE *b, DATA_TYPE *c) {
  int i = blockDim.x * blockIdx.x + threadIdx.x;

  if (i < _PB_NI) {
    c[i] = a[i] + b[i];
  }
}

/* ------------------------------------------------------------- */
void vectoradd_cuda(int ni, DATA_TYPE POLYBENCH_1D(A, NI, ni),
               DATA_TYPE POLYBENCH_1D(B, NI, ni),
               DATA_TYPE POLYBENCH_1D(C, NI, ni),
               DATA_TYPE POLYBENCH_1D(C_inputToGpu, NI, ni),
               DATA_TYPE POLYBENCH_1D(C_outputFromGpu, NI, ni)) {

  fprintf(stderr, "Calling function vectoradd_cuda.\n");

  // GPU initialization.
  GPU_argv_init();

  DATA_TYPE *A_gpu;
  DATA_TYPE *B_gpu;
  DATA_TYPE *C_gpu;

  cudaMalloc((void **)&A_gpu, sizeof(DATA_TYPE) * NI);
  cudaMalloc((void **)&B_gpu, sizeof(DATA_TYPE) * NI);
  cudaMalloc((void **)&C_gpu, sizeof(DATA_TYPE) * NI);

  HOOKOMP_TIMING_DT_H2D_START;

  cudaMemcpy(A_gpu, A, sizeof(DATA_TYPE) * NI, cudaMemcpyHostToDevice);
  cudaMemcpy(B_gpu, B, sizeof(DATA_TYPE) * NI, cudaMemcpyHostToDevice);
  cudaMemcpy(C_gpu, C_inputToGpu, sizeof(DATA_TYPE) * NI, cudaMemcpyHostToDevice);

  HOOKOMP_TIMING_DT_H2D_STOP;

  dim3 block(DIM_THREAD_BLOCK_X, DIM_THREAD_BLOCK_Y);
  dim3 grid((unsigned int)ceil( ((float)N) / ((float)block.x) ), 1);

  /* Start timer. */
  HOOKOMP_TIMING_DEV_KERNEL1_START;

  vectoradd_cuda_kernel<<<grid, block>>>(ni, A_gpu, B_gpu, C_gpu);
  cudaThreadSynchronize();

  /* Stop and print timer. */
  HOOKOMP_TIMING_DEV_KERNEL1_STOP;

  HOOKOMP_TIMING_DT_D2H_START;

  cudaMemcpy(C_outputFromGpu, C_gpu, sizeof(DATA_TYPE) * NI, cudaMemcpyDeviceToHost);

  HOOKOMP_TIMING_DT_D2H_STOP;

  cudaFree(A_gpu);
  cudaFree(B_gpu);
  cudaFree(C_gpu);
}

/* ------------------------------------------------------------- */
int main(int argc, char *argv[]) {
  /* Retrieve problem size. */
  int ni = NI;
  
  /* Variable declaration/allocation. */
  POLYBENCH_1D_ARRAY_DECL(A, DATA_TYPE, NI, ni);
  POLYBENCH_1D_ARRAY_DECL(B, DATA_TYPE, NI, ni);
  POLYBENCH_1D_ARRAY_DECL(C, DATA_TYPE, NI, ni);
  POLYBENCH_1D_ARRAY_DECL(C_outputFromOMP, DATA_TYPE, NI, ni);
  POLYBENCH_1D_ARRAY_DECL(C_inputToGpu, DATA_TYPE, NI, ni);
  POLYBENCH_1D_ARRAY_DECL(C_outputFromGpu, DATA_TYPE, NI, ni);

  fprintf(stderr, "Preparing alternatives functions.\n");
  /* Preparing the call to target function.
  void vectoradd_cuda(int ni, DATA_TYPE POLYBENCH_1D(A, NI, ni),
               DATA_TYPE POLYBENCH_1D(B, NI, ni),
               DATA_TYPE POLYBENCH_1D(C, NI, ni),
               DATA_TYPE POLYBENCH_1D(C_inputToGpu, NI, ni),
               DATA_TYPE POLYBENCH_1D(C_outputFromGpu, NI, ni))
  */
  // Number of parameters to function.
  int n_params = 6;

  // void handler_function_init_array_GPU(void)
  Func *ff_0 = (Func *)malloc(sizeof(Func));

  // Number of arguments + 1, the lists need to have last element NULL.
  ff_0->arg_types = (ffi_type **)malloc((n_params + 1) * sizeof(ffi_type *));
  ff_0->arg_values = (void **)malloc((n_params + 1) * sizeof(void *));

  ff_0->f = &vectoradd_cuda;
  memset(&ff_0->ret_value, 0, sizeof(ff_0->ret_value));

  // return type.
  ff_0->ret_type = &ffi_type_void;

  ff_0->nargs = n_params;

  ff_0->arg_values[0] = &ni;
  ff_0->arg_values[1] = &A;
  ff_0->arg_values[2] = &B;
  ff_0->arg_values[3] = &C;
  ff_0->arg_values[4] = &C_inputToGpu;
  ff_0->arg_values[5] = &C_outputFromGpu;
  ff_0->arg_values[6] = NULL;

  ff_0->arg_types[0] = &ffi_type_sint32;
  ff_0->arg_types[1] = &ffi_type_pointer;
  ff_0->arg_types[2] = &ffi_type_pointer;
  ff_0->arg_types[3] = &ffi_type_pointer;
  ff_0->arg_types[4] = &ffi_type_pointer;
  ff_0->arg_types[5] = &ffi_type_pointer;
  ff_0->arg_types[6] = NULL;

  /*          device 0
   * loop 0   vectoradd_cuda
   * matrix 1 x 1.
  */
  fprintf(stderr, "Creating table of target functions.\n");
  int nloops = 1;
  int ndevices = 2;

  if (create_target_functions_table(&table, nloops, ndevices)) {
    // Set up the library Functions table.
    assert(table != NULL);
    // 0,0 is CPU = NULL, because is openmp code.
    fprintf(stderr, "Declaring function in 0,1.\n");
    table[0][1][0] = *ff_0;

    TablePointerFunctions = table;
    assert(TablePointerFunctions != NULL);
  }

  fprintf(stderr, "Calling init_array.\n");
  init_array(ni, POLYBENCH_ARRAY(A), POLYBENCH_ARRAY(B), POLYBENCH_ARRAY(C));

  /*Copy the original C to C of OMP.*/
  copy_array(ni, POLYBENCH_ARRAY(C), POLYBENCH_ARRAY(C_outputFromOMP));

  copy_array(ni, POLYBENCH_ARRAY(C), POLYBENCH_ARRAY(C_outputFromGpu));

#ifdef RUN_ORIG_VERSION
  fprintf(stderr, "Calling vectoradd_original:\n");
  vectoradd_original(ni, POLYBENCH_ARRAY(A), POLYBENCH_ARRAY(B), POLYBENCH_ARRAY(C));
#endif

  fprintf(stderr, "Calling vectoradd_omp:\n");
  vectoradd_omp(ni, POLYBENCH_ARRAY(A), POLYBENCH_ARRAY(B), POLYBENCH_ARRAY(C_outputFromOMP));

  fprintf(stdout, "version = OMP+OFF, num_threads = %d, NI = %d, ", OPENMP_NUM_THREADS, NI);
  HOOKOMP_PRINT_TIME_RESULTS;

  fprintf(stderr, "Calling compareResults(original, omp).\n");
  compareResults(ni, POLYBENCH_ARRAY(C), POLYBENCH_ARRAY(C_outputFromOMP));

  fprintf(stderr, "Calling compareResults(original, cuda).\n");
  compareResults(ni, POLYBENCH_ARRAY(C), POLYBENCH_ARRAY(C_outputFromGpu));

  polybench_prevent_dce(print_array(ni, POLYBENCH_ARRAY(C_outputFromGpu)));

  POLYBENCH_FREE_ARRAY(A);
  POLYBENCH_FREE_ARRAY(B);
  POLYBENCH_FREE_ARRAY(C);
  POLYBENCH_FREE_ARRAY(C_outputFromOMP);
  POLYBENCH_FREE_ARRAY(C_outputFromGpu);

  return 0;
}

// polybench.c uses the OpenMP to parallelize somethings. This call were
// intercepted by hookomp.
#undef _OPENMP

#include <polybench.c>
