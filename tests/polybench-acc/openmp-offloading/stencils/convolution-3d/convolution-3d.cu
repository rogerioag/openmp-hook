/**
 * 3DConvolution.cu: This file is part of the PolyBench/GPU 1.0 test suite.
 *
 *
 * Contact: Scott Grauer-Gray <sgrauerg@gmail.com>
 * Will Killian <killian@udel.edu>
 * Louis-Noel Pouchet <pouchet@cse.ohio-state.edu>
 * Web address: http://www.cse.ohio-state.edu/~pouchet/software/polybench/GPU
 */

#include <unistd.h>
#include <stdio.h>
#include <time.h>
#include <sys/time.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <cuda.h>

#define POLYBENCH_TIME 1

#include "convolution-3d.cuh"
#include <polybench.h>
#include <polybenchUtilFuncts.h>

// Macros to generate openmp schedule.
#include <macros.h>

// define the error threshold for the results "not matching"
#define PERCENT_DIFF_ERROR_THRESHOLD 0.5

#define GPU_DEVICE 0

#define RUN_ON_CPU

/* ------------------------------------------------------------- */
/* Array initialization. */
static void init_array(int ni, int nj, int nk,
                       DATA_TYPE POLYBENCH_3D(A, NI, NJ, NK, ni, nj, nk)) {
  int i, j, k;

  for (i = 0; i < ni; i++){
    for (j = 0; j < nj; j++){
      for (k = 0; k < nk; k++) {
        A[i][j][k] = i % 12 + 2 * (j % 7) + 3 * (k % 13);
      }
    }
  }
}

/* ------------------------------------------------------------- */
/* DCE code. Must scan the entire live-out data.
   Can be used also to check the correctness of the output. */
static void print_array(int ni, int nj, int nk,
                        DATA_TYPE POLYBENCH_3D(B, NI, NJ, NK, ni, nj, nk)) {
  int i, j, k;

  for (i = 0; i < ni; i++)
    for (j = 0; j < nj; j++)
      for (k = 0; k < nk; k++) {
        fprintf(stderr, DATA_PRINTF_MODIFIER, B[i][j][k]);
        if ((i * (nj * nk) + j * nk + k) % 20 == 0)
          fprintf(stderr, "\n");
      }
  fprintf(stderr, "\n");
}

/* ------------------------------------------------------------- */
void compareResults(int ni, int nj, int nk,
                    DATA_TYPE POLYBENCH_3D(B_ori, NI, NJ, NK, ni, nj, nk),
                    DATA_TYPE POLYBENCH_3D(B_out, NI, NJ, NK, ni, nj, nk)) {
  int i, j, k, fail;
  fail = 0;

  for (i = 0; i < ni; i++)
    for (j = 0; j < nj; j++)
      for (k = 0; k < nk; k++) {
        if (percentDiff(B_ori[i][j][k], B_omp[i][j][k]) >
            PERCENT_DIFF_ERROR_THRESHOLD) {
          fail++;
        }
      }

  // Print results
  printf("Non-Matching CPU-GPU Outputs Beyond Error Threshold of %4.2f "
         "Percent: %d\n",
         PERCENT_DIFF_ERROR_THRESHOLD, fail);
}

/* ------------------------------------------------------------- */
void kernel_conv3d(int ni, int nj, int nk,
                          DATA_TYPE POLYBENCH_3D(A, NI, NJ, NK, ni, nj, nk),
                          DATA_TYPE POLYBENCH_3D(B, NI, NJ, NK, ni, nj, nk)) {
  int i, j, k;
  DATA_TYPE c11, c12, c13, c21, c22, c23, c31, c32, c33;

  c11 = +2;
  c21 = +5;
  c31 = -8;
  c12 = -3;
  c22 = +6;
  c32 = -9;
  c13 = +4;
  c23 = +7;
  c33 = +10;

  for (i = 1; i < _PB_NI - 1; ++i) // 0
  {
    for (j = 1; j < _PB_NJ - 1; ++j) // 1
    {
      for (k = 1; k < _PB_NK - 1; ++k) // 2
      {
        B[i][j][k] = c11 * A[(i - 1)][(j - 1)][(k - 1)] +
                     c13 * A[(i + 1)][(j - 1)][(k - 1)] +
                     c21 * A[(i - 1)][(j - 1)][(k - 1)] +
                     c23 * A[(i + 1)][(j - 1)][(k - 1)] +
                     c31 * A[(i - 1)][(j - 1)][(k - 1)] +
                     c33 * A[(i + 1)][(j - 1)][(k - 1)] +
                     c12 * A[(i + 0)][(j - 1)][(k + 0)] +
                     c22 * A[(i + 0)][(j + 0)][(k + 0)] +
                     c32 * A[(i + 0)][(j + 1)][(k + 0)] +
                     c11 * A[(i - 1)][(j - 1)][(k + 1)] +
                     c13 * A[(i + 1)][(j - 1)][(k + 1)] +
                     c21 * A[(i - 1)][(j + 0)][(k + 1)] +
                     c23 * A[(i + 1)][(j + 0)][(k + 1)] +
                     c31 * A[(i - 1)][(j + 1)][(k + 1)] +
                     c33 * A[(i + 1)][(j + 1)][(k + 1)];
      }
    }
  }
}

/* ------------------------------------------------------------- */
void conv3d_original(int ni, int nj, int nk,
                     DATA_TYPE POLYBENCH_3D(A, NI, NJ, NK, ni, nj, nk),
                     DATA_TYPE POLYBENCH_3D(B, NI, NJ, NK, ni, nj, nk)) {

  /* Start timer. */
  polybench_start_instruments;

  kernel_conv3d(ni, nj, nk, A, B);

  /* Stop and print timer. */
  polybench_stop_instruments;
  printf("CPU Time in seconds:\n");
  polybench_print_instruments;
}

/* ------------------------------------------------------------- */
/* Main computational kernel. The whole function will be timed,
         including the call and return. */
static void conv3d_omp_kernel(int ni, int nj, int nk,
                              DATA_TYPE POLYBENCH_3D(A, NI, NJ, NK, ni, nj, nk),
                              DATA_TYPE POLYBENCH_3D(B, NI, NJ, NK, ni, nj,
                                                     nk)) {
  int i, j, k;
  #pragma scop
  #pragma omp parallel num_threads(OPENMP_NUM_THREADS)
  {
    #pragma omp for private(j, k) collapse(2) schedule(OPENMP_SCHEDULE_WITH_CHUNK)
    for (i = 1; i < _PB_NI - 1; ++i)
      for (j = 1; j < _PB_NJ - 1; ++j)
        for (k = 1; k < _PB_NK - 1; ++k) {
          B[i][j][k] =
              2 * A[i - 1][j - 1][k - 1] + 4 * A[i + 1][j - 1][k - 1] +
              5 * A[i - 1][j - 1][k - 1] + 7 * A[i + 1][j - 1][k - 1] +
              -8 * A[i - 1][j - 1][k - 1] + 10 * A[i + 1][j - 1][k - 1] +
              -3 * A[i][j - 1][k] + 6 * A[i][j][k] + -9 * A[i][j + 1][k] +
              2 * A[i - 1][j - 1][k + 1] + 4 * A[i + 1][j - 1][k + 1] +
              5 * A[i - 1][j][k + 1] + 7 * A[i + 1][j][k + 1] +
              -8 * A[i - 1][j + 1][k + 1] + 10 * A[i + 1][j + 1][k + 1];
        }
  }
  #pragma endscop
}

/* ------------------------------------------------------------- */
void conv3d_omp(int ni, int nj, int nk,
                DATA_TYPE POLYBENCH_3D(A, NI, NJ, NK, ni, nj, nk),
                DATA_TYPE POLYBENCH_3D(B, NI, NJ, NK, ni, nj, nk)) {

  /* Start timer. */
  polybench_start_instruments;

  conv3d_omp_kernel(ni, nj, nk, A, B);

  /* Stop and print timer. */
  polybench_stop_instruments;
  printf("CPU-OMP Time in seconds:\n");
  polybench_print_instruments;
}

/* ------------------------------------------------------------- */
void GPU_argv_init() {
  cudaDeviceProp deviceProp;
  cudaGetDeviceProperties(&deviceProp, GPU_DEVICE);
  printf("setting device %d with name %s\n", GPU_DEVICE, deviceProp.name);
  cudaSetDevice(GPU_DEVICE);
}

/* ------------------------------------------------------------- */
__global__ void conv3d_cuda_kernel(int ni, int nj, int nk, DATA_TYPE *A,
                                     DATA_TYPE *B, int i) {
  int k = blockIdx.x * blockDim.x + threadIdx.x;
  int j = blockIdx.y * blockDim.y + threadIdx.y;

  DATA_TYPE c11, c12, c13, c21, c22, c23, c31, c32, c33;

  c11 = +2;
  c21 = +5;
  c31 = -8;
  c12 = -3;
  c22 = +6;
  c32 = -9;
  c13 = +4;
  c23 = +7;
  c33 = +10;

  if ((i < (_PB_NI - 1)) && (j < (_PB_NJ - 1)) && (k < (_PB_NK - 1)) &&
      (i > 0) && (j > 0) && (k > 0)) {
    B[i * (NK * NJ) + j * NK + k] =
        c11 * A[(i - 1) * (NK * NJ) + (j - 1) * NK + (k - 1)] +
        c13 * A[(i + 1) * (NK * NJ) + (j - 1) * NK + (k - 1)] +
        c21 * A[(i - 1) * (NK * NJ) + (j - 1) * NK + (k - 1)] +
        c23 * A[(i + 1) * (NK * NJ) + (j - 1) * NK + (k - 1)] +
        c31 * A[(i - 1) * (NK * NJ) + (j - 1) * NK + (k - 1)] +
        c33 * A[(i + 1) * (NK * NJ) + (j - 1) * NK + (k - 1)] +
        c12 * A[(i + 0) * (NK * NJ) + (j - 1) * NK + (k + 0)] +
        c22 * A[(i + 0) * (NK * NJ) + (j + 0) * NK + (k + 0)] +
        c32 * A[(i + 0) * (NK * NJ) + (j + 1) * NK + (k + 0)] +
        c11 * A[(i - 1) * (NK * NJ) + (j - 1) * NK + (k + 1)] +
        c13 * A[(i + 1) * (NK * NJ) + (j - 1) * NK + (k + 1)] +
        c21 * A[(i - 1) * (NK * NJ) + (j + 0) * NK + (k + 1)] +
        c23 * A[(i + 1) * (NK * NJ) + (j + 0) * NK + (k + 1)] +
        c31 * A[(i - 1) * (NK * NJ) + (j + 1) * NK + (k + 1)] +
        c33 * A[(i + 1) * (NK * NJ) + (j + 1) * NK + (k + 1)];
  }
}

/* ------------------------------------------------------------- */
void conv3d_cuda(int ni, int nj, int nk,
                       DATA_TYPE POLYBENCH_3D(A, NI, NJ, NK, ni, nj, nk),
                       DATA_TYPE POLYBENCH_3D(B, NI, NJ, NK, ni, nj, nk),
                       DATA_TYPE POLYBENCH_3D(B_outputFromGpu, NI, NJ, NK, ni,
                                              nj, nk)) {
  fprintf(stderr, "Calling function conv3d_cuda.\n");

  // GPU initialization.
  GPU_argv_init();

  DATA_TYPE *A_gpu;
  DATA_TYPE *B_gpu;

  cudaMalloc((void **)&A_gpu, sizeof(DATA_TYPE) * NI * NJ * NK);
  cudaMalloc((void **)&B_gpu, sizeof(DATA_TYPE) * NI * NJ * NK);
  cudaMemcpy(A_gpu, A, sizeof(DATA_TYPE) * NI * NJ * NK,
             cudaMemcpyHostToDevice);
  cudaMemcpy(B_gpu, B, sizeof(DATA_TYPE) * NI * NJ * NK,
             cudaMemcpyHostToDevice);

  dim3 block(DIM_THREAD_BLOCK_X, DIM_THREAD_BLOCK_Y);
  dim3 grid((size_t)(ceil(((float)NK) / ((float)block.x))),
            (size_t)(ceil(((float)NJ) / ((float)block.y))));

  /* Start timer. */
  // polybench_start_instruments;

  int i;
  for (i = 1; i < _PB_NI - 1; ++i) // 0
  {
    convolution3D_kernel<<<grid, block>>>(ni, nj, nk, A_gpu, B_gpu, i);
  }

  cudaThreadSynchronize();
  // printf("GPU Time in seconds:\n");
  // polybench_stop_instruments;
  // polybench_print_instruments;

  cudaMemcpy(B_outputFromGpu, B_gpu, sizeof(DATA_TYPE) * NI * NJ * NK,
             cudaMemcpyDeviceToHost);

  cudaFree(A_gpu);
  cudaFree(B_gpu);
}

/* ------------------------------------------------------------- */
int main(int argc, char *argv[]) {
  int ni = NI;
  int nj = NJ;
  int nk = NK;

  POLYBENCH_3D_ARRAY_DECL(A, DATA_TYPE, NI, NJ, NK, ni, nj, nk);
  POLYBENCH_3D_ARRAY_DECL(B, DATA_TYPE, NI, NJ, NK, ni, nj, nk);
  POLYBENCH_3D_ARRAY_DECL(B_outputFromOMP, DATA_TYPE, NI, NJ, NK, ni, nj, nk);
  POLYBENCH_3D_ARRAY_DECL(B_outputFromGpu, DATA_TYPE, NI, NJ, NK, ni, nj, nk);

  fprintf(stderr, "Preparing alternatives functions.\n");
  /* Preparing the call to target function.
  void conv3d_cuda(int ni, int nj, int nk,
                       DATA_TYPE POLYBENCH_3D(A, NI, NJ, NK, ni, nj, nk),
                       DATA_TYPE POLYBENCH_3D(B, NI, NJ, NK, ni, nj, nk),
                       DATA_TYPE POLYBENCH_3D(B_outputFromGpu, NI, NJ, NK, ni, nj, nk))
  */
  // Number of parameters to function.
  int n_params = 6;

  // void handler_function_init_array_GPU(void)
  Func *ff_0 = (Func *)malloc(sizeof(Func));

  // Number of arguments + 1, the lists need to have last element NULL.
  ff_0->arg_types = (ffi_type **)malloc((n_params + 1) * sizeof(ffi_type *));
  ff_0->arg_values = (void **)malloc((n_params + 1) * sizeof(void *));

  ff_0->f = &conv3d_cuda;
  memset(&ff_0->ret_value, 0, sizeof(ff_0->ret_value));

  // return type.
  ff_0->ret_type = &ffi_type_void;

  ff_0->nargs = n_params;

  ff_0->arg_values[0] = &ni;
  ff_0->arg_values[1] = &nj;
  ff_0->arg_values[2] = &nk;
  ff_0->arg_values[3] = &A;
  ff_0->arg_values[4] = &B;
  ff_0->arg_values[5] = &B_outputFromGpu;
  ff_0->arg_values[6] = NULL;

  ff_0->arg_types[0] = &ffi_type_sint32;
  ff_0->arg_types[1] = &ffi_type_sint32;
  ff_0->arg_types[2] = &ffi_type_sint32;
  ff_0->arg_types[3] = &ffi_type_pointer;
  ff_0->arg_types[4] = &ffi_type_pointer;
  ff_0->arg_types[5] = &ffi_type_pointer;
  ff_0->arg_types[6] = NULL;

  /*          device 0
   * loop 0   conv3d_cuda
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
  init_array(ni, nj, nk, POLYBENCH_ARRAY(A));

  // convolution3DCuda(ni, nj, nk, POLYBENCH_ARRAY(A), POLYBENCH_ARRAY(B), POLYBENCH_ARRAY(B_outputFromGpu));

  fprintf(stdout, "exp, num_threads, NI, NJ, NK, ORIG, OMP\n");

  fprintf(stdout, "OMP+OFF, %d, %d, %d, %d, ", OPENMP_NUM_THREADS, NI, NJ, NK);

  fprintf(stderr, "Calling conv3d_original.\n");
  conv3d_original(ni, nj, nk, POLYBENCH_ARRAY(A), POLYBENCH_ARRAY(B));
  fprintf(stdout, ", ");

  fprintf(stderr, "Calling conv3d_omp.\n");
  conv3d_omp(ni, nj, nk, POLYBENCH_ARRAY(A), POLYBENCH_ARRAY(B_OMP));
  fprintf(stdout, "\n");

  fprintf(stderr, "Calling compareResults(original, omp).\n");
  compareResults(ni, nj, nk, POLYBENCH_ARRAY(B), POLYBENCH_ARRAY(B_outputFromOMP));

  fprintf(stderr, "Calling compareResults(original, cuda).\n");
  compareResults(ni, nj, nk, POLYBENCH_ARRAY(B), POLYBENCH_ARRAY(B_outputFromGpu));

  polybench_prevent_dce(print_array(NI, NJ, NK, POLYBENCH_ARRAY(B_outputFromGpu)));

  POLYBENCH_FREE_ARRAY(A);
  POLYBENCH_FREE_ARRAY(B);
  POLYBENCH_FREE_ARRAY(B_outputFromOMP);
  POLYBENCH_FREE_ARRAY(B_outputFromGpu);

  return 0;
}

// polybench.c uses the OpenMP to parallelize somethings. This call were
// intercepted by hookomp.
#undef _OPENMP

#include <polybench.c>
