/**
 * syr2k.cu: This file is part of the PolyBench/GPU 1.0 test suite.
 *
 *
 * Contact: Scott Grauer-Gray <sgrauerg@gmail.com>
 * Will Killian <killian@udel.edu>
 * Louis-Noel Pouchet <pouchet@cse.ohio-state.edu>
 * Web address: http://www.cse.ohio-state.edu/~pouchet/software/polybench/GPU
 */

#include <assert.h>
#include <cuda.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <unistd.h>

 #include <pthread.h>

#define POLYBENCH_TIME 1

#include "syr2k.cuh"
#include <polybench.h>
#include <polybenchUtilFuncts.h>

// Macros to generate openmp schedule.
#include <macros.h>

// Offloading support functions.
#include <offload.h>

// define the error threshold for the results "not matching"
#define PERCENT_DIFF_ERROR_THRESHOLD 0.05

#define GPU_DEVICE 0

#define RUN_ON_CPU

/* GPU pointers now as global to be shared between kernels. */
DATA_TYPE *A_gpu;
DATA_TYPE *B_gpu;
DATA_TYPE *C_gpu;

/* ------------------------------------------------------------- */
void init_arrays(int ni, int nj, DATA_TYPE *alpha, DATA_TYPE *beta,
                 DATA_TYPE POLYBENCH_2D(A, NI, NJ, ni, nj),
                 DATA_TYPE POLYBENCH_2D(B, NI, NJ, ni, nj),
                 DATA_TYPE POLYBENCH_2D(C, NI, NI, ni, ni)) {
  int i, j;

  *alpha = 32412;
  *beta = 2123;

  for (i = 0; i < ni; i++) {
    for (j = 0; j < nj; j++) {
      A[i][j] = ((DATA_TYPE)i * j) / ni;
      B[i][j] = ((DATA_TYPE)i * j) / ni;
    }
  }

  for (i = 0; i < ni; i++) {
    for (j = 0; j < ni; j++) {
      C[i][j] = ((DATA_TYPE)i * j) / ni;
    }
  }
}

/* ------------------------------------------------------------- */
void copy_array(int ni, DATA_TYPE POLYBENCH_2D(C_source, NI, NI, ni, ni), DATA_TYPE POLYBENCH_2D(C_dest, NI, NI, ni, ni)) {
  int i, j;

  for (i = 0; i < ni; i++) {
    for (j = 0; j < ni; j++) {
      C_dest[i][j] = C_source[i][j];
      // printf("%4.2f - %4.2f\n", C_dest[i][j], C_source[i][j]);
    }
  }
}

/* ------------------------------------------------------------- */
/* DCE code. Must scan the entire live-out data.
   Can be used also to check the correctness of the output. */
static void print_array(int ni, DATA_TYPE POLYBENCH_2D(C, NI, NI, ni, ni)) {
  int i, j;

  for (i = 0; i < ni; i++)
    for (j = 0; j < ni; j++) {
      fprintf(stderr, DATA_PRINTF_MODIFIER, C[i][j]);
      if ((i * ni + j) % 20 == 0)
        fprintf(stderr, "\n");
    }
  fprintf(stderr, "\n");
}

/* ------------------------------------------------------------- */
void syr2kCpu(int ni, int nj, DATA_TYPE alpha, DATA_TYPE beta,
              DATA_TYPE POLYBENCH_2D(A, NI, NJ, ni, nj),
              DATA_TYPE POLYBENCH_2D(B, NI, NJ, ni, nj),
              DATA_TYPE POLYBENCH_2D(C, NI, NI, ni, ni)) {
  int i, j, k;

  /*    C := alpha*A*B' + alpha*B*A' + beta*C */
  for (i = 0; i < _PB_NI; i++) {
    for (j = 0; j < _PB_NI; j++) {
      C[i][j] *= beta;
    }
  }

  for (i = 0; i < _PB_NI; i++) {
    for (j = 0; j < _PB_NI; j++) {
      for (k = 0; k < _PB_NJ; k++) {
        C[i][j] += alpha * A[i][k] * B[j][k];
        C[i][j] += alpha * B[i][k] * A[j][k];
      }
    }
  }
}

/* ------------------------------------------------------------- */
void syr2k_original(int ni, int nj, DATA_TYPE alpha, DATA_TYPE beta,
              DATA_TYPE POLYBENCH_2D(A, NI, NJ, ni, nj),
              DATA_TYPE POLYBENCH_2D(B, NI, NJ, ni, nj),
              DATA_TYPE POLYBENCH_2D(C, NI, NI, ni, ni)) {
  
  /* Start timer. */
  /* Start timer. */
  polybench_start_instruments;

  /* Run kernel. */
  syr2kCpu(ni, nj, alpha, beta, A, B, C);

  /* Stop and print timer. */
  polybench_stop_instruments;
  printf("Original CPU Time in seconds:\n");
  polybench_print_instruments;
}

/* ------------------------------------------------------------- */
/* Main computational kernel. The whole function will be timed,
   including the call and return. */
static void syr2k_omp_kernel(int ni, int nj, DATA_TYPE alpha, DATA_TYPE beta,
                         DATA_TYPE POLYBENCH_2D(A, NI, NJ, ni, nj),
                         DATA_TYPE POLYBENCH_2D(B, NI, NJ, ni, nj),
                         DATA_TYPE POLYBENCH_2D(C, NI, NI, ni, ni), 
                         long int POLYBENCH_2D(Control_Loop_0, NI, NI, ni, ni), 
                         long int POLYBENCH_2D(Control_Loop_1, NI, NI, ni, ni)) {
  int i, j, k;

  #pragma scop
  // #pragma omp parallel
  #pragma omp parallel num_threads(OPENMP_NUM_THREADS)
  {
    /*    C := alpha*A*B' + alpha*B*A' + beta*C */
    current_loop_index = 0;
    // Copy to device A, B, C.
    q_data_transfer_write = (sizeof(DATA_TYPE) * NI * NJ) + (sizeof(DATA_TYPE) * NI * NJ) + (sizeof(DATA_TYPE) * NI * NI);
    // Copy back C.
    q_data_transfer_read = (sizeof(DATA_TYPE) * NI * NI);
    // #pragma omp for private(j) schedule(runtime)
    #pragma omp for private(j) schedule(OPENMP_SCHEDULE_WITH_CHUNK)
    for (i = 0; i < _PB_NI; i++)
      for (j = 0; j < _PB_NI; j++){
        C[i][j] *= beta;
        Control_Loop_0[i][j] = pthread_self();
      }
  // }
    
    current_loop_index = 1;
    // Copy to device A, B, C.
    q_data_transfer_write = (sizeof(DATA_TYPE) * NI * NJ) + (sizeof(DATA_TYPE) * NI * NJ) + (sizeof(DATA_TYPE) * NI * NI);
    // Copy back C.
    q_data_transfer_read = (sizeof(DATA_TYPE) * NI * NI);
  // #pragma omp parallel num_threads(OPENMP_NUM_THREADS)
  // {
    // #pragma omp for private(j, k) schedule(runtime)
    #pragma omp for private(j, k) schedule(OPENMP_SCHEDULE_WITH_CHUNK)
    for (i = 0; i < _PB_NI; i++)
      for (j = 0; j < _PB_NI; j++)
        for (k = 0; k < _PB_NJ; k++) {
          C[i][j] += alpha * A[i][k] * B[j][k];
          C[i][j] += alpha * B[i][k] * A[j][k];
          Control_Loop_1[i][j] = pthread_self();
        }
  }
  #pragma endscop
}

/* ------------------------------------------------------------- */
void syr2k_omp(int ni, int nj, DATA_TYPE alpha, DATA_TYPE beta,
                         DATA_TYPE POLYBENCH_2D(A, NI, NJ, ni, nj),
                         DATA_TYPE POLYBENCH_2D(B, NI, NJ, ni, nj),
                         DATA_TYPE POLYBENCH_2D(C_outputFromOMP, NI, NI, ni, ni),
                         long int POLYBENCH_2D(Control_Loop_0, NI, NI, ni, ni),
                         long int POLYBENCH_2D(Control_Loop_1, NI, NI, ni, ni)) {

  /* Start timer. */
  polybench_start_instruments;

  syr2k_omp_kernel(ni, nj, alpha, beta, A, B, C_outputFromOMP, Control_Loop_0, Control_Loop_1);

  /* Stop and print timer. */
  polybench_stop_instruments;
  printf("OpenMP Time in seconds:\n");
  polybench_print_instruments;
}

/* ------------------------------------------------------------- */
void compareResults(int ni, DATA_TYPE POLYBENCH_2D(C, NI, NI, ni, ni),
                    DATA_TYPE POLYBENCH_2D(C_output, NI, NI, ni, ni)) {
  int i, j, fail;
  fail = 0;

  // Compare C with D
  for (i = 0; i < ni; i++) {
    for (j = 0; j < ni; j++) {
      // printf("%4.2f - %4.2f\n", C[i][j], C_output[i][j]);
      if (percentDiff(C[i][j], C_output[i][j]) >
          PERCENT_DIFF_ERROR_THRESHOLD) {
        fail++;
      }
    }
  }

  // print results
  printf("Non-Matching CPU-GPU Outputs Beyond Error Threshold of %4.2f "
         "Percent: %d\n",
         PERCENT_DIFF_ERROR_THRESHOLD, fail);
}

/* ------------------------------------------------------------- */
void GPU_argv_init() {
  cudaDeviceProp deviceProp;
  cudaGetDeviceProperties(&deviceProp, GPU_DEVICE);
  printf("setting device %d with name %s\n", GPU_DEVICE, deviceProp.name);
  cudaSetDevice(GPU_DEVICE);
}

/* ------------------------------------------------------------- */
/* Original of Benchmarks, join the loops. */
__global__ void syr2k_cuda_kernel(int ni, int nj, DATA_TYPE alpha, DATA_TYPE beta,
                             DATA_TYPE *a, DATA_TYPE *b, DATA_TYPE *c) {
  int j = blockIdx.x * blockDim.x + threadIdx.x;
  int i = blockIdx.y * blockDim.y + threadIdx.y;

  if ((i < NI) && (j < NI)) {
    c[i * NI + j] *= beta;

    int k;
    for (k = 0; k < NJ; k++) {
      c[i * NI + j] += alpha * a[i * NJ + k] * b[j * NJ + k] +
                       alpha * b[i * NJ + k] * a[j * NJ + k];
    }
  }
}

/* It was separated in two kernels, because the loop index. */
/* ------------------------------------------------------------- */
__global__ void syr2k_cuda_kernel_1(int ni, int nj, DATA_TYPE alpha, DATA_TYPE beta,
                             DATA_TYPE *a, DATA_TYPE *b, DATA_TYPE *c) {
  int j = blockIdx.x * blockDim.x + threadIdx.x;
  int i = blockIdx.y * blockDim.y + threadIdx.y;

  if ((i < NI) && (j < NI)) {
    c[i * NI + j] *= beta;
  }
}

/* ------------------------------------------------------------- */
__global__ void syr2k_cuda_kernel_2(int ni, int nj, DATA_TYPE alpha, DATA_TYPE beta,
                             DATA_TYPE *a, DATA_TYPE *b, DATA_TYPE *c) {
  int j = blockIdx.x * blockDim.x + threadIdx.x;
  int i = blockIdx.y * blockDim.y + threadIdx.y;

  if ((i < NI) && (j < NI)) {
    int k;
    for (k = 0; k < NJ; k++) {
      c[i * NI + j] += alpha * a[i * NJ + k] * b[j * NJ + k] +
                       alpha * b[i * NJ + k] * a[j * NJ + k];
    }
  }
}

/* ------------------------------------------------------------- */
void syr2k_cuda_0(int ni, int nj, DATA_TYPE alpha, DATA_TYPE beta,
               DATA_TYPE POLYBENCH_2D(A, NI, NJ, ni, nj),
               DATA_TYPE POLYBENCH_2D(B, NI, NJ, ni, nj),
               DATA_TYPE POLYBENCH_2D(C_inputToGpu, NI, NI, ni, ni),
               DATA_TYPE POLYBENCH_2D(C_outputFromGpu, NI, NI, ni, ni)) {

  fprintf(stderr, "Calling function syr2k_cuda_0.\n");

  // GPU initialization.
  GPU_argv_init();

  // Moved to Global.
  // DATA_TYPE *A_gpu;
  // DATA_TYPE *B_gpu;
  // DATA_TYPE *C_gpu;

  cudaMalloc((void **)&A_gpu, sizeof(DATA_TYPE) * NI * NJ);
  cudaMalloc((void **)&B_gpu, sizeof(DATA_TYPE) * NI * NJ);
  cudaMalloc((void **)&C_gpu, sizeof(DATA_TYPE) * NI * NI);
  cudaMemcpy(A_gpu, A, sizeof(DATA_TYPE) * NI * NJ, cudaMemcpyHostToDevice);
  cudaMemcpy(B_gpu, B, sizeof(DATA_TYPE) * NI * NJ, cudaMemcpyHostToDevice);
  cudaMemcpy(C_gpu, C_inputToGpu, sizeof(DATA_TYPE) * NI * NI, cudaMemcpyHostToDevice);

  dim3 block(DIM_THREAD_BLOCK_X, DIM_THREAD_BLOCK_Y);
  dim3 grid((size_t)ceil(((float)NI) / ((float)DIM_THREAD_BLOCK_X)),
            (size_t)(ceil(((float)NI) / ((float)DIM_THREAD_BLOCK_Y))));

  /* Start timer. */
  polybench_start_instruments;

  syr2k_cuda_kernel_1<<<grid, block>>>(ni, nj, alpha, beta, A_gpu, B_gpu, C_gpu);
  cudaThreadSynchronize();

  // syr2k_cuda_kernel_2<<<grid, block>>>(ni, nj, alpha, beta, A_gpu, B_gpu, C_gpu); 
  // cudaThreadSynchronize();

  /* Stop and print timer. */
  polybench_stop_instruments;
  printf("GPU Time in seconds:\n");
  polybench_print_instruments;

  // cudaMemcpy(C_outputFromGpu, C_gpu, sizeof(DATA_TYPE) * NI * NI, cudaMemcpyDeviceToHost);

  // cudaFree(A_gpu);
  // cudaFree(B_gpu);
  // cudaFree(C_gpu);
}

/* ------------------------------------------------------------- */
void syr2k_cuda_1(int ni, int nj, DATA_TYPE alpha, DATA_TYPE beta,
               DATA_TYPE POLYBENCH_2D(A, NI, NJ, ni, nj),
               DATA_TYPE POLYBENCH_2D(B, NI, NJ, ni, nj),
               DATA_TYPE POLYBENCH_2D(C_inputToGpu, NI, NI, ni, ni),
               DATA_TYPE POLYBENCH_2D(C_outputFromGpu, NI, NI, ni, ni)) {

  fprintf(stderr, "Calling function syr2k_cuda_1.\n");

  dim3 block(DIM_THREAD_BLOCK_X, DIM_THREAD_BLOCK_Y);
  dim3 grid((size_t)ceil(((float)NI) / ((float)DIM_THREAD_BLOCK_X)),
            (size_t)(ceil(((float)NI) / ((float)DIM_THREAD_BLOCK_Y))));

  /* Start timer. */
  polybench_start_instruments;

  syr2k_cuda_kernel_2<<<grid, block>>>(ni, nj, alpha, beta, A_gpu, B_gpu, C_gpu);
  cudaThreadSynchronize();

  /* Stop and print timer. */
  polybench_stop_instruments;
  printf("GPU Time in seconds:\n");
  polybench_print_instruments;

  cudaMemcpy(C_outputFromGpu, C_gpu, sizeof(DATA_TYPE) * NI * NI,
             cudaMemcpyDeviceToHost);

  cudaFree(A_gpu);
  cudaFree(B_gpu);
  cudaFree(C_gpu);
}

/* ------------------------------------------------------------- */
int main(int argc, char *argv[]) {
  /* Retrieve problem size. */
  int ni = NI;
  int nj = NJ;

  /* Variable declaration/allocation. */
  DATA_TYPE alpha;
  DATA_TYPE beta;
  POLYBENCH_2D_ARRAY_DECL(A, DATA_TYPE, NI, NJ, ni, nj);
  POLYBENCH_2D_ARRAY_DECL(B, DATA_TYPE, NI, NJ, ni, nj);
  POLYBENCH_2D_ARRAY_DECL(C, DATA_TYPE, NI, NI, ni, ni);
  POLYBENCH_2D_ARRAY_DECL(C_outputFromOMP, DATA_TYPE, NI, NI, ni, ni);
  POLYBENCH_2D_ARRAY_DECL(C_inputToGpu, DATA_TYPE, NI, NI, ni, ni);
  POLYBENCH_2D_ARRAY_DECL(C_outputFromGpu, DATA_TYPE, NI, NI, ni, ni);
  
  POLYBENCH_2D_ARRAY_DECL(Control_Loop_0, long int, NI, NI, ni, nj);
  POLYBENCH_2D_ARRAY_DECL(Control_Loop_1, long int, NI, NI, ni, nj);

  fprintf(stderr, "Preparing alternatives functions.\n");
  /* Preparing the call to target function.
  void syr2k_cuda(int ni, int nj, DATA_TYPE alpha, DATA_TYPE beta,
               DATA_TYPE POLYBENCH_2D(A, NI, NJ, ni, nj),
               DATA_TYPE POLYBENCH_2D(B, NI, NJ, ni, nj),
               DATA_TYPE POLYBENCH_2D(C_inputToGpu, NI, NI, ni, ni),
               DATA_TYPE POLYBENCH_2D(C_outputFromGpu, NI, NI, ni, ni))
  */
  // Number of parameters to function.
  int n_params = 8;

  // loop 0.
  Func *ff_0 = (Func *) malloc(sizeof(Func));

  // Number of arguments + 1, the lists need to have last element NULL.
  ff_0->arg_types = (ffi_type**) malloc ((n_params + 1) * sizeof(ffi_type*));
  ff_0->arg_values = (void**) malloc ((n_params + 1) * sizeof(void*));

  ff_0->f = &syr2k_cuda_0;
  memset(&ff_0->ret_value, 0, sizeof(ff_0->ret_value));

  // return type.
  ff_0->ret_type = &ffi_type_void;

  ff_0->nargs = n_params;

  ff_0->arg_values[0] = &ni;
  ff_0->arg_values[1] = &nj;
  ff_0->arg_values[2] = &alpha;
  ff_0->arg_values[3] = &beta;
  ff_0->arg_values[4] = &A;
  ff_0->arg_values[5] = &B;
  ff_0->arg_values[6] = &C_inputToGpu;
  ff_0->arg_values[7] = &C_outputFromGpu;
  ff_0->arg_values[8] = NULL;

  ff_0->arg_types[0] = &ffi_type_sint32;
  ff_0->arg_types[1] = &ffi_type_sint32;
  ff_0->arg_types[2] = &ffi_type_double;
  ff_0->arg_types[3] = &ffi_type_double;
  ff_0->arg_types[4] = &ffi_type_pointer;
  ff_0->arg_types[5] = &ffi_type_pointer;
  ff_0->arg_types[6] = &ffi_type_pointer;
  ff_0->arg_types[7] = &ffi_type_pointer;
  ff_0->arg_types[8] = NULL;

  // loop 1.
  Func *ff_1 = (Func *) malloc(sizeof(Func));

  // Number of arguments + 1, the lists need to have last element NULL.
  ff_1->arg_types = (ffi_type**) malloc ((n_params + 1) * sizeof(ffi_type*));
  ff_1->arg_values = (void**) malloc ((n_params + 1) * sizeof(void*));

  ff_1->f = &syr2k_cuda_1;
  memset(&ff_1->ret_value, 0, sizeof(ff_1->ret_value));

  // return type.
  ff_1->ret_type = &ffi_type_void;

  ff_1->nargs = n_params;

  ff_1->arg_values[0] = &ni;
  ff_1->arg_values[1] = &nj;
  ff_1->arg_values[2] = &alpha;
  ff_1->arg_values[3] = &beta;
  ff_1->arg_values[4] = &A;
  ff_1->arg_values[5] = &B;
  ff_1->arg_values[6] = &C_inputToGpu;
  ff_1->arg_values[7] = &C_outputFromGpu;
  ff_1->arg_values[8] = NULL;

  ff_1->arg_types[0] = &ffi_type_sint32;
  ff_1->arg_types[1] = &ffi_type_sint32;
  ff_1->arg_types[2] = &ffi_type_double;
  ff_1->arg_types[3] = &ffi_type_double;
  ff_1->arg_types[4] = &ffi_type_pointer;
  ff_1->arg_types[5] = &ffi_type_pointer;
  ff_1->arg_types[6] = &ffi_type_pointer;
  ff_1->arg_types[7] = &ffi_type_pointer;
  ff_1->arg_types[8] = NULL;

  /*          device 0
   * loop 0   gemm_cuda
   * matrix 1 x 1.
  */
  fprintf(stderr, "Creating table of target functions.\n");
  int nloops = 2;
  int ndevices = 2;

  if (create_target_functions_table(&table, nloops, ndevices)) {
    // Set up the library Functions table.
    assert(table != NULL);

    fprintf(stderr, "Declaring function in 0,0.\n");
    table[0][1][0] = *ff_0;
    table[1][1][0] = *ff_1;

    TablePointerFunctions = table;
    assert(TablePointerFunctions != NULL);
  }

  fprintf(stderr, "Calling init_array.\n");
  init_arrays(ni, nj, &alpha, &beta, POLYBENCH_ARRAY(A), POLYBENCH_ARRAY(B),
              POLYBENCH_ARRAY(C));

  /*Copy the original C to C of OMP.*/
  fprintf(stderr, "Copying C to C_outputFromOMP.\n");
  // memcpy(C_outputFromOMP, C, sizeof(C_outputFromOMP));
  copy_array(ni, POLYBENCH_ARRAY(C), POLYBENCH_ARRAY(C_outputFromOMP));
  
  // printf("%4.2f - %4.2f\n", *(C[0][0]), *(C_outputFromOMP[0][0]));
  // compareResults(ni, POLYBENCH_ARRAY(C), POLYBENCH_ARRAY(C_outputFromOMP));

  fprintf(stderr, "Copying C to C_outputFromOMP.\n");
  // memcpy(C_inputToGpu, C, sizeof(C_inputToGpu));
  copy_array(ni, POLYBENCH_ARRAY(C), POLYBENCH_ARRAY(C_outputFromGpu));
  // compareResults(ni, POLYBENCH_ARRAY(C), POLYBENCH_ARRAY(C_outputFromGpu));

  fprintf(stderr, "Calling Original.\n");
  syr2k_original(ni, nj, alpha, beta, POLYBENCH_ARRAY(A), POLYBENCH_ARRAY(B), POLYBENCH_ARRAY(C));

  fprintf(stderr, "Calling OMP.\n");
  syr2k_omp(ni, nj, alpha, beta, POLYBENCH_ARRAY(A), POLYBENCH_ARRAY(B), POLYBENCH_ARRAY(C_outputFromOMP), POLYBENCH_ARRAY(Control_Loop_0), POLYBENCH_ARRAY(Control_Loop_1));

  fprintf(stderr, "Calling compareResults(original, omp).\n");
  compareResults(ni, POLYBENCH_ARRAY(C), POLYBENCH_ARRAY(C_outputFromOMP));

  // fprintf(stderr, "Calling CUDA.\n");
  // syr2k_cuda(ni, nj, alpha, beta, POLYBENCH_ARRAY(A), POLYBENCH_ARRAY(B), POLYBENCH_ARRAY(C_inputToGpu), POLYBENCH_ARRAY(C_outputFromGpu));

  // fprintf(stderr, "Calling gemm_cuda using Table of Pointers.\n");
  // call_function_ffi_call(table[0][0]);

  fprintf(stderr, "Calling compareResults(original, cuda).\n");
  compareResults(ni, POLYBENCH_ARRAY(C), POLYBENCH_ARRAY(C_outputFromGpu));

  fprintf(stderr, "Comparing threads accesses:\n");
  // compareResults(ni, POLYBENCH_ARRAY(Control_Loop_0), POLYBENCH_ARRAY(Control_Loop_1));
  // Compare C with D
  int i;
  int j;
  int count_dff = 0;
  for (i = 0; i < ni; i++) {
    for (j = 0; j < ni; j++) {
      printf("CL[%lu][%lu] = %d.\n", Control_Loop_0[i][j], Control_Loop_1[i][j], (Control_Loop_0[i][j] == Control_Loop_1[i][j]));
      if (Control_Loop_0[i][j] != Control_Loop_1[i][j]){
        count_dff++;
      }
    }
  }
  printf("Diferentes: %d\n", count_dff);
  
  polybench_prevent_dce(print_array(ni, POLYBENCH_ARRAY(C_outputFromGpu)));

  POLYBENCH_FREE_ARRAY(A);
  POLYBENCH_FREE_ARRAY(B);
  POLYBENCH_FREE_ARRAY(C);
  POLYBENCH_FREE_ARRAY(C_outputFromOMP);
  POLYBENCH_FREE_ARRAY(C_outputFromGpu);

  return 0;
}

// polybench.c uses the OpenMP to parallelize somethings. This call were intercepted by hookomp.
#undef _OPENMP

#include <polybench.c>