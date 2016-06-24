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

#define POLYBENCH_TIME 1

#include "gemm.cuh"
#include <polybench.h>
#include <polybenchUtilFuncts.h>

// Time measures implementation.
#include <timing.h>

#define GPU_DEVICE 0

// define the error threshold for the results "not matching"
#define PERCENT_DIFF_ERROR_THRESHOLD 0.05

#define RUN_ON_CPU

/* ------------------------------------------------------------- */
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
/* ------------------------------------------------------------- */
void copy_array(int ni, int nj, DATA_TYPE POLYBENCH_2D(C_source, NI, NJ, ni, nj), DATA_TYPE POLYBENCH_2D(C_dest, NI, NJ, ni, nj)) {
  int i, j;

  for (i = 0; i < ni; i++) {
    for (j = 0; j < nj; j++) {
      C_dest[i][j] = C_source[i][j];
      // printf("%4.2f - %4.2f\n", C_dest[i][j], C_source[i][j]);
    }
  }
}
/* ------------------------------------------------------------- */
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

/* ------------------------------------------------------------- */
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

/* ------------------------------------------------------------- */
void gemm_original(int ni, int nj, int nk, DATA_TYPE alpha, DATA_TYPE beta,
                   DATA_TYPE POLYBENCH_2D(A, NI, NK, ni, nk),
                   DATA_TYPE POLYBENCH_2D(B, NK, NJ, nk, nj),
                   DATA_TYPE POLYBENCH_2D(C, NI, NJ, ni, nj)) {

  /* Start timer. */
  // polybench_start_instruments;
  HOOKOMP_TIMING_SEQ_START;

  gemm(ni, nj, nk, alpha, beta, A, B, C);

  /* Stop and print timer. */
  // polybench_stop_instruments;
  // // printf("Original CPU Time in seconds:\n");
  // polybench_print_instruments;
  HOOKOMP_TIMING_SEQ_STOP;
  // HOOKOMP_TIMING_SEQ_PRINT;
}

/* ------------------------------------------------------------- */
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
  fprintf(stderr,
         "Non-Matching CPU-GPU Outputs Beyond Error Threshold of %4.2f "
         "Percent: %d\n",
         PERCENT_DIFF_ERROR_THRESHOLD, fail);
}

/* ------------------------------------------------------------- */
void GPU_argv_init() {
  cudaDeviceProp deviceProp;
  cudaGetDeviceProperties(&deviceProp, GPU_DEVICE);
  fprintf(stderr,"setting device %d with name %s\n", GPU_DEVICE, deviceProp.name);
  cudaSetDevice(GPU_DEVICE);
}

/* ------------------------------------------------------------- */
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

/* ------------------------------------------------------------- */
void gemm_cuda(int ni, int nj, int nk, DATA_TYPE alpha, DATA_TYPE beta,
               DATA_TYPE POLYBENCH_2D(A, NI, NK, ni, nk),
               DATA_TYPE POLYBENCH_2D(B, NK, NJ, nk, nj),
               DATA_TYPE POLYBENCH_2D(C, NI, NJ, ni, nj),
               DATA_TYPE POLYBENCH_2D(C_inputToGpu, NI, NJ, ni, nj),
               DATA_TYPE POLYBENCH_2D(C_outputFromGpu, NI, NJ, ni, nj)) {

  fprintf(stderr, "Calling function gemm_cuda.\n");

  // GPU initialization.
  GPU_argv_init();

  DATA_TYPE *A_gpu;
  DATA_TYPE *B_gpu;
  DATA_TYPE *C_gpu;

  // polybench_start_instruments;

  cudaMalloc((void **)&A_gpu, sizeof(DATA_TYPE) * NI * NK);
  cudaMalloc((void **)&B_gpu, sizeof(DATA_TYPE) * NK * NJ);
  cudaMalloc((void **)&C_gpu, sizeof(DATA_TYPE) * NI * NJ);

  // polybench_stop_instruments;
  // printf("GPU cuda Malloc Time in seconds:\n");
  // polybench_print_instruments;

  // polybench_start_instruments;
  HOOKOMP_TIMING_DT_H2D_START;

  cudaMemcpy(A_gpu, A, sizeof(DATA_TYPE) * NI * NK, cudaMemcpyHostToDevice);
  cudaMemcpy(B_gpu, B, sizeof(DATA_TYPE) * NK * NJ, cudaMemcpyHostToDevice);
  cudaMemcpy(C_gpu, C_inputToGpu, sizeof(DATA_TYPE) * NI * NJ,
             cudaMemcpyHostToDevice);

  // polybench_stop_instruments;
  // printf("GPU Data Transfers Time in seconds:\n");
  // polybench_print_instruments;
  HOOKOMP_TIMING_DT_H2D_STOP;

  dim3 block(DIM_THREAD_BLOCK_X, DIM_THREAD_BLOCK_Y);
  dim3 grid((size_t)(ceil(((float)NI) / ((float)block.x))),
            (size_t)(ceil(((float)NJ) / ((float)block.y))));

  /* Start timer. */
  // polybench_start_instruments;
  HOOKOMP_TIMING_DEV_KERNEL1_START;

  gemm_cuda_kernel<<<grid, block>>>(ni, nj, nk, alpha, beta, A_gpu, B_gpu,
                                    C_gpu);
  cudaThreadSynchronize();

  /* Stop and print timer. */
  // printf("GPU kernel Time in seconds:\n");
  // olybench_stop_instruments;
  // polybench_print_instruments;
  HOOKOMP_TIMING_DEV_KERNEL1_STOP;

  // polybench_start_instruments;
  HOOKOMP_TIMING_DT_D2H_START;

  cudaMemcpy(C_outputFromGpu, C_gpu, sizeof(DATA_TYPE) * NI * NJ,
             cudaMemcpyDeviceToHost);

  // printf("GPU copy result Time in seconds:\n");
  // polybench_stop_instruments;
  // polybench_print_instruments;
  HOOKOMP_TIMING_DT_D2H_STOP;
  // HOOKOMP_TIMING_DEV_PRINT;

  cudaFree(A_gpu);
  cudaFree(B_gpu);
  cudaFree(C_gpu);
}

/* ------------------------------------------------------------- */
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
  POLYBENCH_2D_ARRAY_DECL(C_inputToGpu, DATA_TYPE, NI, NJ, ni, nj);
  POLYBENCH_2D_ARRAY_DECL(C_outputFromGpu, DATA_TYPE, NI, NJ, ni, nj);

  fprintf(stderr, "Calling init_array.\n");
  init_array(ni, nj, nk, &alpha, &beta, POLYBENCH_ARRAY(A), POLYBENCH_ARRAY(B),
       POLYBENCH_ARRAY(C));

  // memcpy(C_inputToGpu, C, sizeof(C_inputToGpu));
  copy_array(ni, nj, POLYBENCH_ARRAY(C), POLYBENCH_ARRAY(C_outputFromGpu));

  fprintf(stderr, "calling gemm_original:\n");
  gemm_original(ni, nj, nk, alpha, beta, POLYBENCH_ARRAY(A), POLYBENCH_ARRAY(B), POLYBENCH_ARRAY(C));

  fprintf(stderr, "calling gemm_cuda:\n");
  gemm_cuda(ni, nj, nk, alpha, beta, POLYBENCH_ARRAY(A), POLYBENCH_ARRAY(B), 
            POLYBENCH_ARRAY(C), POLYBENCH_ARRAY(C_inputToGpu),
            POLYBENCH_ARRAY(C_outputFromGpu));

  fprintf(stdout, "version = CUDA, num_threads = %d, NI = %d, NJ = %d, NK = %d, ", 1, NI, NJ, NK);
  HOOKOMP_PRINT_TIME_RESULTS;

  fprintf(stderr, "Calling compareResults(original, cuda).\n");
  compareResults(ni, nj, POLYBENCH_ARRAY(C), POLYBENCH_ARRAY(C_outputFromGpu));

  polybench_prevent_dce(print_array(ni, nj, POLYBENCH_ARRAY(C_outputFromGpu)));

  POLYBENCH_FREE_ARRAY(A);
  POLYBENCH_FREE_ARRAY(B);
  POLYBENCH_FREE_ARRAY(C);
  POLYBENCH_FREE_ARRAY(C_inputToGpu);
  POLYBENCH_FREE_ARRAY(C_outputFromGpu);

  return 0;
}

// polybench.c uses the OpenMP to parallelize somethings. This call were
// intercepted by hookomp.
#undef _OPENMP

#include <polybench.c>