/**
 * jacobi2D.cu: This file is part of the PolyBench/GPU 1.0 test suite.
 *
 *
 * Contact: Scott Grauer-Gray <sgrauerg@gmail.com>
 * Will Killian <killian@udel.edu>
 * Louis-Noel Pouchet <pouchet@cse.ohio-state.edu>
 * Web address: http://www.cse.ohio-state.edu/~pouchet/software/polybench/GPU
 */

#include <stdio.h>
#include <unistd.h>
#include <time.h>
#include <sys/time.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>
#include <math.h>

#include <cuda.h>

#define POLYBENCH_TIME 1

#include "jacobi2D.cuh"
#include <polybench.h>
#include <polybenchUtilFuncts.h>

// Macros to generate openmp schedule.
#include <macros.h>

// Offloading support functions.
#include <offload.h>

// define the error threshold for the results "not matching"
#define PERCENT_DIFF_ERROR_THRESHOLD 0.05

#define RUN_ON_CPU

DATA_TYPE *Agpu;
DATA_TYPE *Bgpu;

bool data_alloc_and_copy = false;

/* ------------------------------------------------------------- */
/* Arrays initialization. */
void init_array(int n, DATA_TYPE POLYBENCH_2D(A, N, N, n, n),
                DATA_TYPE POLYBENCH_2D(B, N, N, n, n)) {
  int i, j;

  for (i = 0; i < n; i++) {
    for (j = 0; j < n; j++) {
      A[i][j] = ((DATA_TYPE)i * (j + 2) + 10) / N;
      B[i][j] = ((DATA_TYPE)(i - 4) * (j - 1) + 11) / N;
    }
  }
}

/* ------------------------------------------------------------- */
void compareResults(int n, DATA_TYPE POLYBENCH_2D(a, N, N, n, n),
                    DATA_TYPE POLYBENCH_2D(a_outputFromGpu, N, N, n, n),
                    DATA_TYPE POLYBENCH_2D(b, N, N, n, n),
                    DATA_TYPE POLYBENCH_2D(b_outputFromGpu, N, N, n, n)) {
  int i, j, fail;
  fail = 0;

  // Compare output from CPU and GPU
  for (i = 0; i < n; i++) {
    for (j = 0; j < n; j++) {
      if (percentDiff(a[i][j], a_outputFromGpu[i][j]) >
          PERCENT_DIFF_ERROR_THRESHOLD) {
        fail++;
      }
    }
  }

  for (i = 0; i < n; i++) {
    for (j = 0; j < n; j++) {
      if (percentDiff(b[i][j], b_outputFromGpu[i][j]) >
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

/* ------------------------------------------------------------- */
/* DCE code. Must scan the entire live-out data.
         Can be used also to check the correctness of the output. */
static void print_array(int n, DATA_TYPE POLYBENCH_2D(A, N, N, n, n)) {
  int i, j;

  for (i = 0; i < n; i++) {
    for (j = 0; j < n; j++) {
      fprintf(stderr, DATA_PRINTF_MODIFIER, A[i][j]);
      if ((i * n + j) % 20 == 0)
        fprintf(stderr, "\n");
    }
  }
  fprintf(stderr, "\n");
}

/* ------------------------------------------------------------- */
void runJacobi2DCpu(int tsteps, int n, DATA_TYPE POLYBENCH_2D(A, N, N, n, n),
                    DATA_TYPE POLYBENCH_2D(B, N, N, n, n)) {
  for (int t = 0; t < _PB_TSTEPS; t++) {
    for (int i = 1; i < _PB_N - 1; i++) {
      for (int j = 1; j < _PB_N - 1; j++) {
        B[i][j] = 0.2f * (A[i][j] + A[i][(j - 1)] + A[i][(1 + j)] +
                          A[(1 + i)][j] + A[(i - 1)][j]);
      }
    }

    for (int i = 1; i < _PB_N - 1; i++) {
      for (int j = 1; j < _PB_N - 1; j++) {
        A[i][j] = B[i][j];
      }
    }
  }
}

/* ------------------------------------------------------------- */
void jacobi2d_original(int tsteps, int n, DATA_TYPE POLYBENCH_2D(A, N, N, n, n),
                       DATA_TYPE POLYBENCH_2D(B, N, N, n, n)) {
  /* Start timer. */
  polybench_start_instruments;

  runJacobi2DCpu(tsteps, n, A, B);

  /* Stop and print timer. */
  polybench_stop_instruments;
  // printf("CPU Time in seconds:\n");
  polybench_print_instruments;
}

/* ------------------------------------------------------------- */
/* Main computational kernel. The whole function will be timed,
         including the call and return. */
static void jacobi_2d_imper_omp_kernel(int tsteps, int n,
                                       DATA_TYPE POLYBENCH_2D(A, N, N, n, n),
                                       DATA_TYPE POLYBENCH_2D(B, N, N, n, n)) {
  int t, i, j;

	#pragma scop

	#pragma omp parallel private(i, j, t) num_threads(OPENMP_NUM_THREADS)
  {
		#pragma omp master
    {
      for (t = 0; t < _PB_TSTEPS; t++) {
				#pragma omp parallel for schedule(OPENMP_SCHEDULE_WITH_CHUNK)
        for (i = 1; i < _PB_N - 1; i++)
          for (j = 1; j < _PB_N - 1; j++)
            B[i][j] = 0.2 * (A[i][j] + A[i][j - 1] + A[i][1 + j] + A[1 + i][j] +
                             A[i - 1][j]);

				#pragma omp parallel for schedule(OPENMP_SCHEDULE_WITH_CHUNK)
        for (i = 1; i < _PB_N - 1; i++)
          for (j = 1; j < _PB_N - 1; j++)
            A[i][j] = B[i][j];
      }
    }
  }

/* 
  I put the parallel in omp parallel for directive, to fix this error:
  Errors with the old format:
         jacobi-2d-imper.c:145:17: error: work-sharing region may not be closely
   nested inside of work-sharing, critical, ordered, master or explicit task
   region
         #pragma omp for schedule(OPENMP_SCHEDULE_WITH_CHUNK)
                                                         ^
         jacobi-2d-imper.c:150:17: error: work-sharing region may not be closely
   nested inside of work-sharing, critical, ordered, master or explicit task
   region
         #pragma omp for schedule(OPENMP_SCHEDULE_WITH_CHUNK)
*/
#pragma endscop
}

/* ------------------------------------------------------------- */
void jacobi_2d_imper_omp(int tsteps, int n,
                         DATA_TYPE POLYBENCH_2D(A, N, N, n, n),
                         DATA_TYPE POLYBENCH_2D(B, N, N, n, n)) {
  /* Start timer. */
  polybench_start_instruments;

  /* Run kernel. */
  jacobi_2d_imper_omp_kernel(tsteps, n, A, B);

  /* Stop and print timer. */
  polybench_stop_instruments;
  printf("OMP Time in seconds:\n");
  polybench_print_instruments;
}

/* ------------------------------------------------------------- */
__global__ void jacobi_cuda_kernel_1(int n, DATA_TYPE *A, DATA_TYPE *B) {
  int i = blockIdx.y * blockDim.y + threadIdx.y;
  int j = blockIdx.x * blockDim.x + threadIdx.x;

  if ((i >= 1) && (i < (_PB_N - 1)) && (j >= 1) && (j < (_PB_N - 1))) {
    B[i * N + j] =
        0.2f * (A[i * N + j] + A[i * N + (j - 1)] + A[i * N + (1 + j)] +
                A[(1 + i) * N + j] + A[(i - 1) * N + j]);
  }
}

/* ------------------------------------------------------------- */
__global__ void jacobi_cuda_kernel_2(int n, DATA_TYPE *A, DATA_TYPE *B) {
  int i = blockIdx.y * blockDim.y + threadIdx.y;
  int j = blockIdx.x * blockDim.x + threadIdx.x;

  if ((i >= 1) && (i < (_PB_N - 1)) && (j >= 1) && (j < (_PB_N - 1))) {
    A[i * N + j] = B[i * N + j];
  }
}

/* ------------------------------------------------------------- */
void jacobi2d_cuda_1(int tsteps, int n, DATA_TYPE POLYBENCH_2D(A, N, N, n, n),
                     DATA_TYPE POLYBENCH_2D(B, N, N, n, n)) {

  if (!data_alloc_and_copy) {
    cudaMalloc(&Agpu, N * N * sizeof(DATA_TYPE));
    cudaMalloc(&Bgpu, N * N * sizeof(DATA_TYPE));
    cudaMemcpy(Agpu, A, N * N * sizeof(DATA_TYPE), cudaMemcpyHostToDevice);
    cudaMemcpy(Bgpu, B, N * N * sizeof(DATA_TYPE), cudaMemcpyHostToDevice);
    data_alloc_and_copy = true;
  }

  dim3 block(DIM_THREAD_BLOCK_X, DIM_THREAD_BLOCK_Y);
  dim3 grid((unsigned int)ceil(((float)N) / ((float)block.x)),
            (unsigned int)ceil(((float)N) / ((float)block.y)));

  jacobi_cuda_kernel_1<<<grid, block>>>(n, Agpu, Bgpu);
  cudaThreadSynchronize();

  cudaMemcpy(A, Agpu, sizeof(DATA_TYPE) * N * N, cudaMemcpyDeviceToHost);
  cudaMemcpy(B, Bgpu, sizeof(DATA_TYPE) * N * N, cudaMemcpyDeviceToHost);
}

/* ------------------------------------------------------------- */
void jacobi2d_cuda_2(int tsteps, int n, DATA_TYPE POLYBENCH_2D(A, N, N, n, n),
                     DATA_TYPE POLYBENCH_2D(B, N, N, n, n)) {

  if (!data_alloc_and_copy) {
    cudaMalloc(&Agpu, N * N * sizeof(DATA_TYPE));
    cudaMalloc(&Bgpu, N * N * sizeof(DATA_TYPE));
    cudaMemcpy(Agpu, A, N * N * sizeof(DATA_TYPE), cudaMemcpyHostToDevice);
    cudaMemcpy(Bgpu, B, N * N * sizeof(DATA_TYPE), cudaMemcpyHostToDevice);
    data_alloc_and_copy = true;
  }

  dim3 block(DIM_THREAD_BLOCK_X, DIM_THREAD_BLOCK_Y);
  dim3 grid((unsigned int)ceil(((float)N) / ((float)block.x)),
            (unsigned int)ceil(((float)N) / ((float)block.y)));

  jacobi_cuda_kernel_2<<<grid, block>>>(n, Agpu, Bgpu);
  cudaThreadSynchronize();

  cudaMemcpy(A, Agpu, sizeof(DATA_TYPE) * N * N, cudaMemcpyDeviceToHost);
  cudaMemcpy(B, Bgpu, sizeof(DATA_TYPE) * N * N, cudaMemcpyDeviceToHost);
}

/* ------------------------------------------------------------- */
void copy_array(int n, DATA_TYPE POLYBENCH_2D(source, N, N, n, n),
                DATA_TYPE POLYBENCH_2D(dest, N, N, n, n)) {
  int i, j;

  for (i = 0; i < n; i++) {
    for (j = 0; j < n; j++) {
      dest[i][j] = source[i][j];
    }
  }
}

/* ------------------------------------------------------------- */
int main(int argc, char **argv) {
  /* Retrieve problem size. */
  int n = N;
  int tsteps = TSTEPS;

  POLYBENCH_2D_ARRAY_DECL(A, DATA_TYPE, N, N, n, n);
  POLYBENCH_2D_ARRAY_DECL(B, DATA_TYPE, N, N, n, n);

  POLYBENCH_2D_ARRAY_DECL(A_OMP, DATA_TYPE, N, N, n, n);
  POLYBENCH_2D_ARRAY_DECL(B_OMP, DATA_TYPE, N, N, n, n);

  POLYBENCH_2D_ARRAY_DECL(A_GPU, DATA_TYPE, N, N, n, n);
  POLYBENCH_2D_ARRAY_DECL(B_GPU, DATA_TYPE, N, N, n, n);

  // void jacobi2d_cuda_1(int tsteps, int n, DATA_TYPE POLYBENCH_2D(A,N,N,n,n),
  //                      DATA_TYPE POLYBENCH_2D(B,N,N,n,n))

  // Number of parameters to function.
  int n_params = 4;

  // loop 0.
  Func *ff_0 = (Func *)malloc(sizeof(Func));

  // Number of arguments + 1, the lists need to have last element NULL.
  ff_0->arg_types = (ffi_type **)malloc((n_params + 1) * sizeof(ffi_type *));
  ff_0->arg_values = (void **)malloc((n_params + 1) * sizeof(void *));

  ff_0->f = &jacobi2d_cuda_1;
  memset(&ff_0->ret_value, 0, sizeof(ff_0->ret_value));

  // return type.
  ff_0->ret_type = &ffi_type_void;

  ff_0->nargs = n_params;

  ff_0->arg_values[0] = &tsteps;
  ff_0->arg_values[1] = &n;
  ff_0->arg_values[2] = &A_GPU;
  ff_0->arg_values[3] = &A_GPU;
  ff_0->arg_values[4] = NULL;

  ff_0->arg_types[0] = &ffi_type_sint32;
  ff_0->arg_types[1] = &ffi_type_sint32;
  ff_0->arg_types[2] = &ffi_type_pointer;
  ff_0->arg_types[3] = &ffi_type_pointer;
  ff_0->arg_types[4] = NULL;

  // loop 1.
  Func *ff_1 = (Func *)malloc(sizeof(Func));

  // Number of arguments + 1, the lists need to have last element NULL.
  ff_1->arg_types = (ffi_type **)malloc((n_params + 1) * sizeof(ffi_type *));
  ff_1->arg_values = (void **)malloc((n_params + 1) * sizeof(void *));

  ff_1->f = &jacobi2d_cuda_2;
  memset(&ff_1->ret_value, 0, sizeof(ff_1->ret_value));

  // return type.
  ff_1->ret_type = &ffi_type_void;

  ff_1->nargs = n_params;

  ff_1->arg_values[0] = &tsteps;
  ff_1->arg_values[1] = &n;
  ff_1->arg_values[2] = &A_GPU;
  ff_1->arg_values[3] = &B_GPU;
  ff_1->arg_values[4] = NULL;

  ff_1->arg_types[0] = &ffi_type_sint32;
  ff_1->arg_types[1] = &ffi_type_sint32;
  ff_1->arg_types[2] = &ffi_type_pointer;
  ff_1->arg_types[3] = &ffi_type_pointer;
  ff_1->arg_types[4] = NULL;

  /*          device 0  device 1
   * loop 0   OMP       &jacobi2d_cuda_1
   * loop 1   OMP       &jacobi2d_cuda_2
   * matrix 2 x 2.
  */
  fprintf(stderr, "Creating table of target functions.\n");
  int nloops = 2;
  int ndevices = 2;

  if (create_target_functions_table(&table, nloops, ndevices)) {
    // Set up the library Functions table.
    assert(table != NULL);

    fprintf(stderr, "Declaring function in 0,1.\n");
    table[0][1][0] = *ff_0;
    fprintf(stderr, "Declaring function in 1,1.\n");
    table[1][1][0] = *ff_1;

    TablePointerFunctions = table;
    assert(TablePointerFunctions != NULL);
  }

  fprintf(stderr, "Calling init_array.\n");
  init_array(n, POLYBENCH_ARRAY(A), POLYBENCH_ARRAY(B));

  /*Copy the original OMP.*/
  fprintf(stderr, "Copying A to A_OMP.\n");
  copy_array(n, POLYBENCH_ARRAY(A), POLYBENCH_ARRAY(A_OMP));
  fprintf(stderr, "Copying B to B_OMP.\n");
  copy_array(n, POLYBENCH_ARRAY(B), POLYBENCH_ARRAY(B_OMP));

  fprintf(stderr, "Copying A to A_GPU.\n");
  copy_array(n, POLYBENCH_ARRAY(A), POLYBENCH_ARRAY(A_GPU));
  fprintf(stderr, "Copying B to B_GPU.\n");
  copy_array(n, POLYBENCH_ARRAY(B), POLYBENCH_ARRAY(B_GPU));

  fprintf(stdout, "exp, num_threads, N, ORIG, OMP\n");

  fprintf(stdout, "OMP+OFF, %d, %d, ", OPENMP_NUM_THREADS, N);

  fprintf(stderr, "Calling Original.\n");
  jacobi2d_original(tsteps, n, POLYBENCH_ARRAY(A), POLYBENCH_ARRAY(B));
  fprintf(stdout, ", ");

  fprintf(stderr, "Calling OMP.\n");
  jacobi_2d_imper_omp(tsteps, n, POLYBENCH_ARRAY(A_OMP),
                      POLYBENCH_ARRAY(B_OMP));
  fprintf(stdout, "\n");

  fprintf(stderr, "Calling compareResults(original, omp).\n");
  compareResults(n, POLYBENCH_ARRAY(A), POLYBENCH_ARRAY(A_OMP),
                 POLYBENCH_ARRAY(B), POLYBENCH_ARRAY(B_OMP));

  fprintf(stderr, "Calling compareResults(original, cuda).\n");
  compareResults(n, POLYBENCH_ARRAY(A), POLYBENCH_ARRAY(A_GPU),
                 POLYBENCH_ARRAY(B), POLYBENCH_ARRAY(B_GPU));

  polybench_prevent_dce(print_array(n, POLYBENCH_ARRAY(A)));

  POLYBENCH_FREE_ARRAY(A);
  POLYBENCH_FREE_ARRAY(A_OMP);
  POLYBENCH_FREE_ARRAY(A_GPU);
  POLYBENCH_FREE_ARRAY(B);
  POLYBENCH_FREE_ARRAY(B_OMP);
  POLYBENCH_FREE_ARRAY(B_GPU);

  cudaFree(Agpu);
  cudaFree(Bgpu);

  return 0;
}

// polybench.c uses the OpenMP to parallelize somethings. This call were
// intercepted by hookomp.
#undef _OPENMP

#include <polybench.c>