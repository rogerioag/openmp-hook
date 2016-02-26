/* POLYBENCH/GPU-OPENMP
 *
 * This file is a part of the Polybench/GPU-OpenMP suite
 *
 * Contact:
 * William Killian <killian@udel.edu>
 *
 * Copyright 2013, The University of Delaware
 */
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <math.h>

/* Include polybench common header. */
#include <polybench.h>
#include <polybenchUtilFuncts.h>

// Macros to generate openmp schedule.
#include <macros.h>

/* Include benchmark-specific header. */
/* Default data type is double, default size is 4096x4096. */
#include "convolution-3d.h"

/* ------------------------------------------------------------- */
/* Array initialization. */
static void init_array(int ni, int nj, int nk,
                       DATA_TYPE POLYBENCH_3D(A, NI, NJ, NK, ni, nj, nk)) {
  int i, j, k;

  for (i = 0; i < ni; i++)
    for (j = 0; j < nj; j++)
      for (k = 0; j < nk; k++) {
        A[i][j][k] = i % 12 + 2 * (j % 7) + 3 * (k % 13);
      }
}

/* ------------------------------------------------------------- */
/* DCE code. Must scan the entire live-out data.
         Can be used also to check the correctness of the output. */
static void print_array(int ni, int nj, int nk,
                        DATA_TYPE POLYBENCH_3D(B, NI, NJ, NK, ni, nj, nk))

{
  int i, j, k;

  for (i = 0; i < ni; i++)
    for (j = 0; j < nj; j++)
      for (k = 0; j < nk; k++) {
        fprintf(stderr, DATA_PRINTF_MODIFIER, B[i][j][k]);
        if (((i * NJ + j) * NK + k) % 20 == 0)
          fprintf(stderr, "\n");
      }
  fprintf(stderr, "\n");
}

/* ------------------------------------------------------------- */
void compareResults(int ni, int nj, int nk,
                    DATA_TYPE POLYBENCH_3D(B_ori, NI, NJ, NK, ni, nj, nk),
                    DATA_TYPE POLYBENCH_3D(B_omp, NI, NJ, NK, ni, nj, nk)) {
  int i, j, k, fail;
  fail = 0;

  for (i = 0; i < ni; i++)
    for (j = 0; j < nj; j++)
      for (k = 0; j < nk; k++) {
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
static void kernel_conv2d(int ni, int nj, int nk,
                          DATA_TYPE POLYBENCH_3D(A, NI, NJ, NK, ni, nj, nk),
                          DATA_TYPE POLYBENCH_3D(B, NI, NJ, NK, ni, nj, nk)) {
  int i, j, k;
  for (i = 1; i < _PB_NI - 1; ++i)
    for (j = 1; j < _PB_NJ - 1; ++j)
      for (k = 1; k < _PB_NK - 1; ++k) {
        B[i][j][k] = 2 * A[i - 1][j - 1][k - 1] + 4 * A[i + 1][j - 1][k - 1] +
                     5 * A[i - 1][j - 1][k - 1] + 7 * A[i + 1][j - 1][k - 1] +
                     -8 * A[i - 1][j - 1][k - 1] + 10 * A[i + 1][j - 1][k - 1] +
                     -3 * A[i][j - 1][k] + 6 * A[i][j][k] +
                     -9 * A[i][j + 1][k] + 2 * A[i - 1][j - 1][k + 1] +
                     4 * A[i + 1][j - 1][k + 1] + 5 * A[i - 1][j][k + 1] +
                     7 * A[i + 1][j][k + 1] + -8 * A[i - 1][j + 1][k + 1] +
                     10 * A[i + 1][j + 1][k + 1];
      }
}

/* ------------------------------------------------------------- */
void conv2d_original(int ni, int nj, int nk,
                     DATA_TYPE POLYBENCH_3D(A, NI, NJ, NK, ni, nj, nk),
                     DATA_TYPE POLYBENCH_3D(B, NI, NJ, NK, ni, nj, nk)) {

  /* Start timer. */
  polybench_start_instruments;

  kernel_conv2d(ni, nj, nk, A, B);

  /* Stop and print timer. */
  polybench_stop_instruments;
  printf("CPU Time in seconds:\n");
  polybench_print_instruments;
}

/* ------------------------------------------------------------- */
/* Main computational kernel. The whole function will be timed,
         including the call and return. */
static void conv2d_omp_kernel(int ni, int nj, int nk,
                              DATA_TYPE POLYBENCH_3D(A, NI, NJ, NK, ni, nj, nk),
                              DATA_TYPE POLYBENCH_3D(B, NI, NJ, NK, ni, nj,
                                                     nk)) {
  int i, j, k;
#pragma scop
#pragma omp parallel
  {
#pragma omp for private(j, k) collapse(2)
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
void conv2d_omp(int ni, int nj, int nk,
                DATA_TYPE POLYBENCH_3D(A, NI, NJ, NK, ni, nj, nk),
                DATA_TYPE POLYBENCH_3D(B, NI, NJ, NK, ni, nj, nk)) {

  /* Start timer. */
  polybench_start_instruments;

  conv2d_omp_kernel(ni, nj, nk, A, B);

  /* Stop and print timer. */
  polybench_stop_instruments;
  printf("CPU-OMP Time in seconds:\n");
  polybench_print_instruments;
}

/* ------------------------------------------------------------- */
int main(int argc, char **argv) {
  /* Retrieve problem size. */
  int ni = NI;
  int nj = NJ;
  int nk = NK;

  /* Variable declaration/allocation. */
  POLYBENCH_3D_ARRAY_DECL(A, DATA_TYPE, NI, NJ, NK, ni, nj, nk);
  POLYBENCH_3D_ARRAY_DECL(B, DATA_TYPE, NI, NJ, NK, ni, nj, nk);

  POLYBENCH_3D_ARRAY_DECL(B_OMP, DATA_TYPE, NI, NJ, NK, ni, nj, nk);

  /* Initialize array(s). */
  init_array(ni, nj, nk, POLYBENCH_ARRAY(A));

  fprintf(stderr, "Calling conv2d_original.\n");

  conv2d_original(ni, nj, nk, POLYBENCH_ARRAY(A), POLYBENCH_ARRAY(B));

  fprintf(stderr, "Calling conv2d_omp.\n");
  conv2d_omp(ni, nj, nk, POLYBENCH_ARRAY(A), POLYBENCH_ARRAY(B_OMP));

  fprintf(stderr, "Calling compareResults(original, omp).\n");
  compareResults(ni, nj, nk, POLYBENCH_ARRAY(B), POLYBENCH_ARRAY(B_OMP));

  /* Prevent dead-code elimination. All live-out data must be printed
           by the function call in argument. */
  polybench_prevent_dce(print_array(ni, nj, nk, POLYBENCH_ARRAY(B)));

  /* Be clean. */
  POLYBENCH_FREE_ARRAY(A);
  POLYBENCH_FREE_ARRAY(B);
  POLYBENCH_FREE_ARRAY(B_OMP);

  return 0;
}
