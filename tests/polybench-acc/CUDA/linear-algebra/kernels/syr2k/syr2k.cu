/**
 * syr2k.cu: This file is part of the PolyBench/GPU 1.0 test suite.
 *
 *
 * Contact: Scott Grauer-Gray <sgrauerg@gmail.com>
 * Will Killian <killian@udel.edu>
 * Louis-Noel Pouchet <pouchet@cse.ohio-state.edu>
 * Web address: http://www.cse.ohio-state.edu/~pouchet/software/polybench/GPU
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <assert.h>
#include <unistd.h>
#include <sys/time.h>
#include <cuda.h>

#define POLYBENCH_TIME 1

#include "syr2k.cuh"
#include <polybench.h>
#include <polybenchUtilFuncts.h>

// Time measures implementation.
#include <timing.h>

// define the error threshold for the results "not matching"
#define PERCENT_DIFF_ERROR_THRESHOLD 0.05

#define GPU_DEVICE 0

#define RUN_ON_CPU

/* ------------------------------------------------------------- */
/* Arrays initialization. */
void init_arrays(int ni, int nj,
		DATA_TYPE *alpha,
		DATA_TYPE *beta,
		DATA_TYPE POLYBENCH_2D(A,NI,NJ,ni,nj),
		DATA_TYPE POLYBENCH_2D(B,NI,NJ,ni,nj),
		DATA_TYPE POLYBENCH_2D(C,NI,NI,ni,ni))
{
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
static
void print_array(int ni, DATA_TYPE POLYBENCH_2D(C,NI,NI,ni,ni)) {
  int i, j;

  for (i = 0; i < ni; i++)
    for (j = 0; j < ni; j++) {
      fprintf(stderr, DATA_PRINTF_MODIFIER, C[i][j]);
      if ((i * ni + j) % 20 == 0) fprintf(stderr, "\n");
    }
  fprintf(stderr, "\n");
}

/* ------------------------------------------------------------- */
/* Original Version. */
void syr2kCpu(int ni, int nj,
		DATA_TYPE alpha,
		DATA_TYPE beta,
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
void syr2k_original(int ni, int nj,
			DATA_TYPE alpha,
			DATA_TYPE beta,
			DATA_TYPE POLYBENCH_2D(A, NI, NJ, ni, nj),
			DATA_TYPE POLYBENCH_2D(B, NI, NJ, ni, nj),
			DATA_TYPE POLYBENCH_2D(C, NI, NI, ni, ni)) {

  /* Start timer. */
  // polybench_start_instruments;
  HOOKOMP_TIMING_SEQ_START;

  /* Run kernel. */
  syr2kCpu(ni, nj, alpha, beta, A, B, C);

  /* Stop and print timer. */
  // polybench_stop_instruments;
  // // printf("Original CPU Time in seconds:\n");
  // polybench_print_instruments;
  HOOKOMP_TIMING_SEQ_STOP;
  // HOOKOMP_TIMING_SEQ_PRINT;
}

/* ------------------------------------------------------------- */
void GPU_argv_init() {
	cudaDeviceProp deviceProp;
	cudaGetDeviceProperties(&deviceProp, GPU_DEVICE);
	printf("setting device %d with name %s\n", GPU_DEVICE, deviceProp.name);
	cudaSetDevice(GPU_DEVICE);
}

/* ------------------------------------------------------------- */
void compareResults(int ni,
			DATA_TYPE POLYBENCH_2D(C, NI, NI, ni, ni),
			DATA_TYPE POLYBENCH_2D(C_outputFromGpu,
			NI, NI, ni, ni)) {
  int i, j, fail;
  fail = 0;

  // Compare C with D
  for (i = 0; i < ni; i++) {
    for (j = 0; j < ni; j++) {
      if (percentDiff(C[i][j], C_outputFromGpu[i][j]) > 
        PERCENT_DIFF_ERROR_THRESHOLD) {
        fail++;
      }
    }
  }

  // print results
  fprintf(stderr,
          "Non-Matching CPU-GPU Outputs Beyond Error Threshold of %4.2f Percent: %d\n", PERCENT_DIFF_ERROR_THRESHOLD, fail);
}
/* ------------------------------------------------------------- */
__global__ void syr2k_cuda_kernel(int ni, int nj,
				  DATA_TYPE alpha,
				  DATA_TYPE beta,
				  DATA_TYPE *a,
				  DATA_TYPE *b,
				  DATA_TYPE *c) {
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
/* ------------------------------------------------------------- */
__global__ void syr2k_cuda_kernel_0(int ni, int nj, DATA_TYPE alpha, DATA_TYPE beta,
                             DATA_TYPE *a, DATA_TYPE *b, DATA_TYPE *c) {
  int j = blockIdx.x * blockDim.x + threadIdx.x;
  int i = blockIdx.y * blockDim.y + threadIdx.y;

  if ((i < NI) && (j < NI)) {
    c[i * NI + j] *= beta;
  }
}

/* ------------------------------------------------------------- */
void syr2k_cuda(int ni, int nj, DATA_TYPE alpha, DATA_TYPE beta, 
				DATA_TYPE POLYBENCH_2D(A, NI, NJ, ni, nj), 
				DATA_TYPE POLYBENCH_2D(B, NI, NJ, ni, nj),
				DATA_TYPE POLYBENCH_2D(C_inputToGpu, NI, NI, ni, ni), 
				DATA_TYPE POLYBENCH_2D(C_outputFromGpu, NI, NI, ni, ni)) 
{
	DATA_TYPE *A_gpu;
	DATA_TYPE *B_gpu;
	DATA_TYPE *C_gpu;

	cudaMalloc((void **)&A_gpu, sizeof(DATA_TYPE) * NI * NJ);
	cudaMalloc((void **)&B_gpu, sizeof(DATA_TYPE) * NI * NJ);
	cudaMalloc((void **)&C_gpu, sizeof(DATA_TYPE) * NI * NI);

	HOOKOMP_TIMING_DT_H2D_START;

	cudaMemcpy(A_gpu, A, sizeof(DATA_TYPE) * NI * NJ, cudaMemcpyHostToDevice);
	cudaMemcpy(B_gpu, B, sizeof(DATA_TYPE) * NI * NJ, cudaMemcpyHostToDevice);
	cudaMemcpy(C_gpu, C_inputToGpu, sizeof(DATA_TYPE) * NI * NI, cudaMemcpyHostToDevice);

	HOOKOMP_TIMING_DT_H2D_STOP;
	
	dim3 block(DIM_THREAD_BLOCK_X, DIM_THREAD_BLOCK_Y);
	dim3 grid((size_t)ceil( ((float)NI) / ((float)DIM_THREAD_BLOCK_X) ), (size_t)(ceil( ((float)NI) / ((float)DIM_THREAD_BLOCK_Y) )));
	
	/* Start timer. */
  	// polybench_start_instruments;
  	HOOKOMP_TIMING_DEV_START;

	syr2k_cuda_kernel<<<grid,block>>>(ni, nj, alpha, beta, A_gpu, B_gpu, C_gpu);
	cudaThreadSynchronize();

	/* Stop and print timer. */
	// printf("GPU Time in seconds:\n");
  	// polybench_stop_instruments;
 	// polybench_print_instruments;

 	HOOKOMP_TIMING_DEV_STOP;

 	HOOKOMP_TIMING_DT_D2H_START;
		
	cudaMemcpy(C_outputFromGpu, C_gpu, sizeof(DATA_TYPE) * NI * NI, cudaMemcpyDeviceToHost);

	HOOKOMP_TIMING_DT_D2H_STOP;

	cudaFree(A_gpu);
	cudaFree(B_gpu);
	cudaFree(C_gpu);
}

/* ------------------------------------------------------------- */
int main(int argc, char *argv[])
{
	/* Retrieve problem size. */
	int ni = NI;
	int nj = NJ;

	/* Variable declaration/allocation. */
	DATA_TYPE alpha;
	DATA_TYPE beta;
	POLYBENCH_2D_ARRAY_DECL(A,DATA_TYPE,NI,NJ,ni,nj);
	POLYBENCH_2D_ARRAY_DECL(B,DATA_TYPE,NI,NJ,ni,nj);
	POLYBENCH_2D_ARRAY_DECL(C,DATA_TYPE,NI,NI,ni,ni);
	POLYBENCH_2D_ARRAY_DECL(C_inputToGpu, DATA_TYPE, NI, NI, ni, ni);
  	POLYBENCH_2D_ARRAY_DECL(C_outputFromGpu, DATA_TYPE, NI, NI, ni, ni);

  	fprintf(stderr, "Calling init_array.\n");
	init_arrays(ni, nj, &alpha, &beta, POLYBENCH_ARRAY(A), POLYBENCH_ARRAY(B), POLYBENCH_ARRAY(C));

	fprintf(stderr, "Copying C to C_outputFromGpu.\n");
  	copy_array(ni, POLYBENCH_ARRAY(C), POLYBENCH_ARRAY(C_outputFromGpu));

  	fprintf(stderr, "Calling syr2k_original:\n");
  	syr2k_original(ni, nj, alpha, beta, POLYBENCH_ARRAY(A), POLYBENCH_ARRAY(B), POLYBENCH_ARRAY(C));

  	fprintf(stderr, "Calling syr2k_cuda:\n");
	GPU_argv_init();
	syr2k_cuda(ni, nj, alpha, beta, POLYBENCH_ARRAY(A), POLYBENCH_ARRAY(B), POLYBENCH_ARRAY(C_inputToGpu), POLYBENCH_ARRAY(C_outputFromGpu));

	fprintf(stdout, "version = CUDA, num_threads = %d, NI = %d, NJ = %d, NK = %d, ", 1, NI, NJ, 0);
	HOOKOMP_PRINT_TIME_RESULTS;

	fprintf(stderr, "Calling compareResults(original, cuda).\n");
  	compareResults(ni, POLYBENCH_ARRAY(C), POLYBENCH_ARRAY(C_outputFromGpu));

  	polybench_prevent_dce(print_array(ni, POLYBENCH_ARRAY(C_outputFromGpu)));

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