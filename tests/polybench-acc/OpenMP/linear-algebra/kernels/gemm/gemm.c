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

#include <macros.h>

/* Include benchmark-specific header. */
/* Default data type is double, default size is 4000. */
#include "gemm.h"

// define the error threshold for the results "not matching"
#define PERCENT_DIFF_ERROR_THRESHOLD 0.05

/* Array initialization. */
static
void init_array(int ni, int nj, int nk,
		DATA_TYPE *alpha,
		DATA_TYPE *beta,
		DATA_TYPE POLYBENCH_2D(C,NI,NJ,ni,nj),
		DATA_TYPE POLYBENCH_2D(A,NI,NK,ni,nk),
		DATA_TYPE POLYBENCH_2D(B,NK,NJ,nk,nj))
{
  int i, j;

  *alpha = 32412;
  *beta = 2123;
  for (i = 0; i < ni; i++)
    for (j = 0; j < nj; j++)
      C[i][j] = ((DATA_TYPE) i*j) / ni;
  for (i = 0; i < ni; i++)
    for (j = 0; j < nk; j++)
      A[i][j] = ((DATA_TYPE) i*j) / ni;
  for (i = 0; i < nk; i++)
    for (j = 0; j < nj; j++)
      B[i][j] = ((DATA_TYPE) i*j) / ni;
}


/* DCE code. Must scan the entire live-out data.
   Can be used also to check the correctness of the output. */
static
void print_array(int ni, int nj,
		 DATA_TYPE POLYBENCH_2D(C,NI,NJ,ni,nj))
{
  int i, j;

  for (i = 0; i < ni; i++)
    for (j = 0; j < nj; j++) {
	fprintf (stderr, DATA_PRINTF_MODIFIER, C[i][j]);
	if ((i * ni + j) % 20 == 0) fprintf (stderr, "\n");
    }
  fprintf (stderr, "\n");
}

/* ------------------------------------------------------------- */
void compareResults(int ni, int nj, DATA_TYPE POLYBENCH_2D(C, NI, NJ, ni, nj),
                    DATA_TYPE POLYBENCH_2D(C_output, NI, NJ, ni, nj)) {
  int i, j, fail;
  fail = 0;

  // Compare CPU and GPU outputs
  for (i = 0; i < ni; i++) {
    for (j = 0; j < nj; j++) {
      if (percentDiff(C[i][j], C_output[i][j]) >
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

/* ------------------------------------------------------------- */
/* Main computational kernel. The whole function will be timed,
   including the call and return. */
void gemm_omp_kernel(int ni, int nj, int nk, DATA_TYPE alpha, DATA_TYPE beta,
          DATA_TYPE POLYBENCH_2D(A, NI, NK, ni, nk),
          DATA_TYPE POLYBENCH_2D(B, NK, NJ, nk, nj),
          DATA_TYPE POLYBENCH_2D(C, NI, NJ, ni, nj)) {

  int i, j, k;
  #pragma scop
  // #pragma omp parallel
  #pragma omp parallel num_threads(OPENMP_NUM_THREADS)
  {
  /* C := alpha*A*B + beta*C */
  // #pragma omp for private(j, k) schedule(runtime)
    #pragma omp parallel for schedule(OPENMP_SCHEDULE_WITH_CHUNK)
    for (i = 0; i < _PB_NI; i++)
      for (j = 0; j < _PB_NJ; j++) {
        C[i][j] *= beta;
        for (k = 0; k < _PB_NK; ++k)
          C[i][j] += alpha * A[i][k] * B[k][j];
      }
  }
  #pragma endscop
}
/* ------------------------------------------------------------- */
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
  POLYBENCH_2D_ARRAY_DECL(C_outputFromOMP, DATA_TYPE, NI, NJ, ni, nj);
  
  fprintf(stderr, "Calling init_array.\n");
  init_array(ni, nj, nk, &alpha, &beta, POLYBENCH_ARRAY(A), POLYBENCH_ARRAY(B),
       POLYBENCH_ARRAY(C));

  /*Copy the original C to C of OMP.*/
  memcpy(C_outputFromOMP, C, sizeof(C_outputFromOMP));

  fprintf(stderr, "Calling gemm_original.\n");
  gemm_original(ni, nj, nk, alpha, beta, POLYBENCH_ARRAY(A), POLYBENCH_ARRAY(B), POLYBENCH_ARRAY(C));
  
  fprintf(stderr, "Calling gemm_omp.\n");
  gemm_omp(ni, nj, nk, alpha, beta, POLYBENCH_ARRAY(A), POLYBENCH_ARRAY(B), POLYBENCH_ARRAY(C_outputFromOMP));

  fprintf(stderr, "Calling compareResults(original, omp).\n");
  compareResults(ni, nj, POLYBENCH_ARRAY(C), POLYBENCH_ARRAY(C_outputFromOMP));

  polybench_prevent_dce(print_array(ni, nj, POLYBENCH_ARRAY(C_outputFromOMP)));

  POLYBENCH_FREE_ARRAY(A);
  POLYBENCH_FREE_ARRAY(B);
  POLYBENCH_FREE_ARRAY(C);
  POLYBENCH_FREE_ARRAY(C_outputFromOMP);

  return 0;
}
