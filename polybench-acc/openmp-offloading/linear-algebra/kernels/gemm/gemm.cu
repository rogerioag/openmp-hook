/**
 * gemm.cu: This file is part of the PolyBench/GPU 1.0 test suite.
 *
 *
 * Contact: Scott Grauer-Gray <sgrauerg@gmail.com>
 * Will Killian <killian@udel.edu>
 * Louis-Noel Pouchet <pouchet@cse.ohio-state.edu>
 * Web address: http://www.cse.ohio-state.edu/~pouchet/software/polybench/GPU
 */

#include <cuda.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>
#include <time.h>
#include <unistd.h>

#include <dlfcn.h>
#include <ffi.h>
// #include <stdio.h>
// #include <stdlib.h>
// #include <string.h>
#include <fcntl.h>
#include <stdint.h>
#include <inttypes.h>
#include <assert.h>

#define POLYBENCH_TIME 1

#include "gemm.h"
#include <polybench.h>
#include <polybenchUtilFuncts.h>

#define GPU_DEVICE 0

// define the error threshold for the results "not matching"
#define PERCENT_DIFF_ERROR_THRESHOLD 0.05

#define RUN_ON_CPU

typedef struct Func {
  void *f;
  int nargs;
  ffi_type* arg_types[4];
  void* arg_values[4];
  ffi_type* ret_type;
  void* ret_value;
} Func;

/* Alternative Functions table pointer. */
Func ***table;

extern Func ***TablePointerFunctions;

/* current loop index. */
// extern long int current_loop_index;
long int current_loop_index;

bool create_target_functions_table(Func ****table_, int nrows, int ncolumns) {

  Func ***table;

  bool result = true;
  int i, j;

  fprintf(stderr, "Allocating the rows.\n");
  table = (Func ***) malloc(nrows * sizeof(Func **));

  if (table != NULL) {
    fprintf(stderr, "Allocating the columns.\n");

    for (i = 0; i < nrows; i++) {
      table[i] = (Func **) malloc(ncolumns * sizeof(Func *));
      if (table[i] != NULL) {
        for (j = 0; j < ncolumns; j++) {
          table[i][j] = (Func *) malloc(sizeof(Func));
        }
      } else {
        fprintf(stderr,
            "Error in table of target functions allocation (columns).\n");
        result = false;
      }
    }
  } else {
    fprintf(stderr,
        "Error in table of target functions allocation (rows).\n");
    result = false;
  }
  fprintf(stderr, "Allocating the columns is OK.\n");

  /*fprintf(stderr, "Initializing.\n");

  for (i = 0; i < nrows; i++) {
    for (j = 0; j < ncolumns; j++) {
      table[i][j][0] = 0;
    }
  }

  fprintf(stderr, "Initializing OK.\n");*/

  *table_ = table;

  return result;
}

/* Call the target function. */
void call_function_ffi_call(Func* ff) {
  fprintf(stderr," In call_function_ffi_call.\n");
  ffi_cif cif;

  if (ffi_prep_cif(&cif, FFI_DEFAULT_ABI, ff->nargs, ff->ret_type,
      ff->arg_types) != FFI_OK) {
    fprintf(stderr,"Error ffi_prep_cif.\n");
    exit(1);
  }

  ffi_call(&cif, FFI_FN(ff->f), ff->ret_value, ff->arg_values);
}

/* Arrays initialization. */
void init_array(int ni, int nj, int nk, DATA_TYPE *alpha, DATA_TYPE *beta,
                DATA_TYPE POLYBENCH_2D(A, NI, NK, ni, nk),
                DATA_TYPE POLYBENCH_2D(B, NK, NJ, nk, nj),
                DATA_TYPE POLYBENCH_2D(C, NI, NJ, ni, nj)) {
  int i, j;

  *alpha = 32412;
  *beta = 2123;

  for (i = 0; i < ni; i++) {
    for (j = 0; j < nk; j++) {
      A[i][j] = ((DATA_TYPE)i * j) / NI;
    }
  }

  for (i = 0; i < nk; i++) {
    for (j = 0; j < nj; j++) {
      B[i][j] = ((DATA_TYPE)i * j) / NI;
    }
  }

  for (i = 0; i < ni; i++) {
    for (j = 0; j < nj; j++) {
      C[i][j] = ((DATA_TYPE)i * j) / NI;
    }
  }
}

/* Original Version. */
void gemm(int ni, int nj, int nk, DATA_TYPE alpha, DATA_TYPE beta,
          DATA_TYPE POLYBENCH_2D(A, NI, NK, ni, nk),
          DATA_TYPE POLYBENCH_2D(B, NK, NJ, nk, nj),
          DATA_TYPE POLYBENCH_2D(C, NI, NJ, ni, nj)) {
  int i, j, k;

  for (i = 0; i < _PB_NI; i++) {
    for (j = 0; j < _PB_NJ; j++) {
      C[i][j] *= beta;

      for (k = 0; k < _PB_NK; ++k) {
        C[i][j] += alpha * A[i][k] * B[k][j];
      }
    }
  }
}

void gemm_original(int ni, int nj, int nk, DATA_TYPE alpha, DATA_TYPE beta,
          DATA_TYPE POLYBENCH_2D(A, NI, NK, ni, nk),
          DATA_TYPE POLYBENCH_2D(B, NK, NJ, nk, nj),
          DATA_TYPE POLYBENCH_2D(C, NI, NJ, ni, nj)) {
  
  /* Start timer. */
  polybench_start_instruments;

  gemm(ni, nj, nk, alpha, beta, 
        A, 
        B,
        C);

  /* Stop and print timer. */
  printf("Original CPU Time in seconds:\n");
  polybench_stop_instruments;
  polybench_print_instruments;
}

/* Main computational kernel. The whole function will be timed,
   including the call and return. */
void gemm_omp_kernel(int ni, int nj, int nk, DATA_TYPE alpha, DATA_TYPE beta,
          DATA_TYPE POLYBENCH_2D(A, NI, NK, ni, nk),
          DATA_TYPE POLYBENCH_2D(B, NK, NJ, nk, nj),
          DATA_TYPE POLYBENCH_2D(C, NI, NJ, ni, nj)) {

  int i, j, k;
  current_loop_index = 0;
  #pragma scop
  #pragma omp parallel
  {
  /* C := alpha*A*B + beta*C */
  #pragma omp for private(j, k) schedule(runtime)
    for (i = 0; i < _PB_NI; i++)
      for (j = 0; j < _PB_NJ; j++) {
        C[i][j] *= beta;
        for (k = 0; k < _PB_NK; ++k)
          C[i][j] += alpha * A[i][k] * B[k][j];
      }
  }
  #pragma endscop
}

void gemm_omp(int ni, int nj, int nk, DATA_TYPE alpha, DATA_TYPE beta,
              DATA_TYPE POLYBENCH_2D(A, NI, NK, ni, nk),
              DATA_TYPE POLYBENCH_2D(B, NK, NJ, nk, nj),
              DATA_TYPE POLYBENCH_2D(C_outputFromOMP, NI, NJ, ni, nj)) {

  /* Start timer. */
  polybench_start_instruments;

  gemm_omp_kernel(ni, nj, nk, alpha, beta, 
                  A, 
                  B,
                  C_outputFromOMP);

  /* Stop and print timer. */
  printf("OpenMP Time in seconds:\n");
  polybench_stop_instruments;
  polybench_print_instruments;
}

/*--------------------------------------------------------------*/
/* CUDA */
void GPU_argv_init() {
  cudaDeviceProp deviceProp;
  cudaGetDeviceProperties(&deviceProp, GPU_DEVICE);
  printf("setting device %d with name %s\n", GPU_DEVICE, deviceProp.name);
  cudaSetDevice(GPU_DEVICE);
}

__global__ void gemm_cuda_kernel(int ni, int nj, int nk, DATA_TYPE alpha,
                            DATA_TYPE beta, DATA_TYPE *a, DATA_TYPE *b,
                            DATA_TYPE *c) {
  int j = blockIdx.x * blockDim.x + threadIdx.x;
  int i = blockIdx.y * blockDim.y + threadIdx.y;

  if ((i < _PB_NI) && (j < _PB_NJ)) {
    c[i * NJ + j] *= beta;
    int k;
    for (k = 0; k < _PB_NK; k++) {
      c[i * NJ + j] += alpha * a[i * NK + k] * b[k * NJ + j];
    }
  }
}

void gemm_cuda(int ni, int nj, int nk, DATA_TYPE alpha, DATA_TYPE beta,
              DATA_TYPE POLYBENCH_2D(A, NI, NK, ni, nk),
              DATA_TYPE POLYBENCH_2D(B, NK, NJ, nk, nj),
              DATA_TYPE POLYBENCH_2D(C, NI, NJ, ni, nj),
              DATA_TYPE POLYBENCH_2D(C_inputToGpu, NI, NJ, ni, nj),
              DATA_TYPE POLYBENCH_2D(C_outputFromGpu, NI, NJ, ni, nj)) {
  DATA_TYPE *A_gpu;
  DATA_TYPE *B_gpu;
  DATA_TYPE *C_gpu;

  fprintf(stderr, "Calling function gemm_cuda.\n");

  cudaMalloc((void **)&A_gpu, sizeof(DATA_TYPE) * NI * NK);
  cudaMalloc((void **)&B_gpu, sizeof(DATA_TYPE) * NK * NJ);
  cudaMalloc((void **)&C_gpu, sizeof(DATA_TYPE) * NI * NJ);

  cudaMemcpy(A_gpu, A, sizeof(DATA_TYPE) * NI * NK, cudaMemcpyHostToDevice);
  cudaMemcpy(B_gpu, B, sizeof(DATA_TYPE) * NK * NJ, cudaMemcpyHostToDevice);
  cudaMemcpy(C_gpu, C_inputToGpu, sizeof(DATA_TYPE) * NI * NJ, cudaMemcpyHostToDevice);

  dim3 block(DIM_THREAD_BLOCK_X, DIM_THREAD_BLOCK_Y);
  dim3 grid((size_t)(ceil(((float)NI) / ((float)block.x))),
            (size_t)(ceil(((float)NJ) / ((float)block.y))));

  /* Start timer. */
  polybench_start_instruments;

  gemm_cuda_kernel<<<grid, block>>>(ni, nj, nk, alpha, beta, A_gpu, B_gpu, C_gpu);
  cudaThreadSynchronize();

  /* Stop and print timer. */
  printf("GPU Time in seconds:\n");
  polybench_stop_instruments;
  polybench_print_instruments;

  cudaMemcpy(C_outputFromGpu, C_gpu, sizeof(DATA_TYPE) * NI * NJ,
             cudaMemcpyDeviceToHost);

  cudaFree(A_gpu);
  cudaFree(B_gpu);
  cudaFree(C_gpu);
}

void compareResults(int ni, int nj, DATA_TYPE POLYBENCH_2D(C, NI, NJ, ni, nj),
                    DATA_TYPE POLYBENCH_2D(C_outputFromGpu, NI, NJ, ni, nj)) {
  int i, j, fail;
  fail = 0;

  // Compare CPU and GPU outputs
  for (i = 0; i < ni; i++) {
    for (j = 0; j < nj; j++) {
      if (percentDiff(C[i][j], C_outputFromGpu[i][j]) >
          PERCENT_DIFF_ERROR_THRESHOLD) {
        fail++;
      }
    }
  }

  // Print results
  printf("Non-Matching CPU-GPU Outputs Beyond Error Threshold of %4.2f "
         "Percent: %d\n",
         PERCENT_DIFF_ERROR_THRESHOLD, fail);
}

/* DCE code. Must scan the entire live-out data.
   Can be used also to check the correctness of the output. */
static void print_array(int ni, int nj,
                        DATA_TYPE POLYBENCH_2D(C, NI, NJ, ni, nj)) {
  int i, j;

  for (i = 0; i < ni; i++)
    for (j = 0; j < nj; j++) {
      fprintf(stderr, DATA_PRINTF_MODIFIER, C[i][j]);
      if ((i * ni + j) % 20 == 0)
        fprintf(stderr, "\n");
    }
  fprintf(stderr, "\n");
}

int main(int argc, char *argv[]) {
  /* Retrieve problem size. */
  int ni = NI;
  int nj = NJ;
  int nk = NK;

  /* Variable declaration/allocation. */
  DATA_TYPE alpha;
  DATA_TYPE beta;
  POLYBENCH_2D_ARRAY_DECL(A, DATA_TYPE, NI, NK, ni, nk);
  POLYBENCH_2D_ARRAY_DECL(B, DATA_TYPE, NK, NJ, nk, nj);
  POLYBENCH_2D_ARRAY_DECL(C, DATA_TYPE, NI, NJ, ni, nj);
  POLYBENCH_2D_ARRAY_DECL(C_outputFromOMP, DATA_TYPE, NI, NJ, ni, nj);
  POLYBENCH_2D_ARRAY_DECL(C_inputToGpu, DATA_TYPE, NI, NJ, ni, nj);
  POLYBENCH_2D_ARRAY_DECL(C_outputFromGpu, DATA_TYPE, NI, NJ, ni, nj);


  init_array(ni, nj, nk, &alpha, &beta, POLYBENCH_ARRAY(A), POLYBENCH_ARRAY(B),
       POLYBENCH_ARRAY(C));

  /*Copy the original C to C of OMP.*/
  memcpy(C_outputFromOMP, C, sizeof(C_outputFromOMP));

  memcpy(C_inputToGpu, C, sizeof(C_inputToGpu));

  /* Preparing the call to target function.
  void gemm_cuda(int ni, int nj, int nk, DATA_TYPE alpha, DATA_TYPE beta,
              DATA_TYPE POLYBENCH_2D(A, NI, NK, ni, nk),
              DATA_TYPE POLYBENCH_2D(B, NK, NJ, nk, nj),
              DATA_TYPE POLYBENCH_2D(C, NI, NJ, ni, nj),
              DATA_TYPE POLYBENCH_2D(C_inputToGpu, NI, NJ, ni, nj),
              DATA_TYPE POLYBENCH_2D(C_outputFromGpu, NI, NJ, ni, nj))
  */
  Func *ff = (Func *) malloc(sizeof(Func));

  ff->f = &gemm_cuda;
  memset(&ff->ret_value, 0, sizeof(ff->ret_value));

  // return type.
  ff->ret_type = &ffi_type_void;

  ff->nargs = 10;

  ff->arg_values[0] = &ni;
  ff->arg_values[1] = &nj;
  ff->arg_values[2] = &nk;
  ff->arg_values[3] = &alpha;
  ff->arg_values[4] = &beta;
  ff->arg_values[5] = &A;
  ff->arg_values[6] = &B;
  ff->arg_values[7] = &C;
  ff->arg_values[8] = &C_inputToGpu;
  ff->arg_values[9] = &C_outputFromGpu;
  ff->arg_values[10] = NULL;

  ff->arg_types[0] = &ffi_type_sint32;
  ff->arg_types[1] = &ffi_type_sint32;
  ff->arg_types[2] = &ffi_type_sint32;
  ff->arg_types[3] = &ffi_type_double;
  ff->arg_types[4] = &ffi_type_double;
  ff->arg_types[5] = &ffi_type_pointer;
  ff->arg_types[6] = &ffi_type_pointer;
  ff->arg_types[7] = &ffi_type_pointer;
  ff->arg_types[8] = &ffi_type_pointer;
  ff->arg_types[9] = &ffi_type_pointer;
  ff->arg_types[10] = NULL;

  int nloops = 1;
  int ndevices = 1;

  if (create_target_functions_table(&table, nloops, ndevices)) {
    // Set up the library Functions table.
    assert(table != NULL);

    fprintf(stderr, "Declaring function in 0,0.\n");
    table[0][0][0] = *ff;

    // TablePointerFunctions = table;
    // assert(TablePointerFunctions != NULL);
  }

  fprintf(stderr, "Calling gemm_original.\n");
  gemm_original(ni, nj, nk, alpha, beta, POLYBENCH_ARRAY(A), POLYBENCH_ARRAY(B), POLYBENCH_ARRAY(C));

  fprintf(stderr, "Calling gemm_omp.\n");
  gemm_omp(ni, nj, nk, alpha, beta, POLYBENCH_ARRAY(A), POLYBENCH_ARRAY(B), POLYBENCH_ARRAY(C_outputFromOMP));

  fprintf(stderr, "Calling compareResults(original, omp).\n");
  compareResults(ni, nj, POLYBENCH_ARRAY(C), POLYBENCH_ARRAY(C_outputFromOMP));

  fprintf(stderr, "GPU init.\n");
  GPU_argv_init();

  fprintf(stderr, "Calling gemm_cuda.\n");
  gemm_cuda(ni, nj, nk, alpha, beta, POLYBENCH_ARRAY(A), POLYBENCH_ARRAY(B), POLYBENCH_ARRAY(C), POLYBENCH_ARRAY(C_inputToGpu), POLYBENCH_ARRAY(C_outputFromGpu));

  // fprintf(stderr, "Calling using Table of Pointers 1.\n");
  // call_function_ffi_call(table[0][0]);

  fprintf(stderr, "Calling compareResults(original, cuda).\n");
  compareResults(ni, nj, POLYBENCH_ARRAY(C), POLYBENCH_ARRAY(C_outputFromGpu));

  polybench_prevent_dce(print_array(ni, nj, POLYBENCH_ARRAY(C_outputFromGpu)));

  POLYBENCH_FREE_ARRAY(A);
  POLYBENCH_FREE_ARRAY(B);
  POLYBENCH_FREE_ARRAY(C);
  POLYBENCH_FREE_ARRAY(C_outputFromOMP);
  POLYBENCH_FREE_ARRAY(C_outputFromGpu);

  return 0;
}

#include <polybench.c>