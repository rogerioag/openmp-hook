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
/* Default data type is double, default size is 4000. */
#include "syr2k.h"

 // define the error threshold for the results "not matching"
#define PERCENT_DIFF_ERROR_THRESHOLD 0.05

/* ------------------------------------------------------------- */
/* Array initialization. */
static
void init_array(int ni, int nj,
		DATA_TYPE *alpha,
		DATA_TYPE *beta,
		DATA_TYPE POLYBENCH_2D(C,NI,NI,ni,ni),
		DATA_TYPE POLYBENCH_2D(A,NI,NJ,ni,nj),
		DATA_TYPE POLYBENCH_2D(B,NI,NJ,ni,nj))
{
  int i, j;

  *alpha = 32412;
  *beta = 2123;
  for (i = 0; i < ni; i++)
    for (j = 0; j < nj; j++) {
      A[i][j] = ((DATA_TYPE) i*j) / ni;
      B[i][j] = ((DATA_TYPE) i*j) / ni;
    }
  for (i = 0; i < ni; i++)
    for (j = 0; j < ni; j++)
      C[i][j] = ((DATA_TYPE) i*j) / ni;
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
static
void print_array(int ni,
		 DATA_TYPE POLYBENCH_2D(C,NI,NI,ni,ni))
{
  int i, j;

  for (i = 0; i < ni; i++)
    for (j = 0; j < ni; j++) {
	fprintf (stderr, DATA_PRINTF_MODIFIER, C[i][j]);
	if ((i * ni + j) % 20 == 0) fprintf (stderr, "\n");
    }
  fprintf (stderr, "\n");
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
                         DATA_TYPE POLYBENCH_2D(C, NI, NI, ni, ni)) {
  int i, j, k;

  #pragma scop
  // #pragma omp parallel
  #pragma omp parallel num_threads(OPENMP_NUM_THREADS)
  {
    /*    C := alpha*A*B' + alpha*B*A' + beta*C */
    // #pragma omp for private(j) schedule(runtime)
    #pragma omp for private(j) schedule(OPENMP_SCHEDULE_WITH_CHUNK)
    for (i = 0; i < _PB_NI; i++)
      for (j = 0; j < _PB_NI; j++)
        C[i][j] *= beta;
    //#pragma omp for private(j, k) schedule(runtime)
      #pragma omp for private(j, k) schedule(OPENMP_SCHEDULE_WITH_CHUNK)
    for (i = 0; i < _PB_NI; i++)
      for (j = 0; j < _PB_NI; j++)
        for (k = 0; k < _PB_NJ; k++) {
          C[i][j] += alpha * A[i][k] * B[j][k];
          C[i][j] += alpha * B[i][k] * A[j][k];
        }
  }
  #pragma endscop
}

/* ------------------------------------------------------------- */
void syr2k_omp(int ni, int nj, DATA_TYPE alpha, DATA_TYPE beta,
                         DATA_TYPE POLYBENCH_2D(A, NI, NJ, ni, nj),
                         DATA_TYPE POLYBENCH_2D(B, NI, NJ, ni, nj),
                         DATA_TYPE POLYBENCH_2D(C_outputFromOMP, NI, NI, ni, ni)) {

  /* Start timer. */
  polybench_start_instruments;

  syr2k_omp_kernel(ni, nj, alpha, beta, A, B, C_outputFromOMP);

  /* Stop and print timer. */
  polybench_stop_instruments;
  // printf("OpenMP Time in seconds:\n");
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
int main(int argc, char** argv) {
  /* Retrieve problem size. */
  int ni = NI;
  int nj = NJ;

  /* Variable declaration/allocation. */
  DATA_TYPE alpha;
  DATA_TYPE beta;
  POLYBENCH_2D_ARRAY_DECL(A, DATA_TYPE, NI, NJ, ni, nj);
  POLYBENCH_2D_ARRAY_DECL(B, DATA_TYPE, NI, NJ, ni, nj);
  POLYBENCH_2D_ARRAY_DECL(C, DATA_TYPE, NI, NI, ni, ni);
  POLYBENCH_2D_ARRAY_DECL(C_outputFromOMP, DATA_TYPE, NI, NJ, ni, nj);


  /* Initialize array(s). */
  fprintf(stderr, "Calling init_array.\n");
  init_array (ni, nj, &alpha, &beta,
        POLYBENCH_ARRAY(C),
        POLYBENCH_ARRAY(A),
        POLYBENCH_ARRAY(B));

  /*Copy the original C to C of OMP.*/
  fprintf(stderr, "Copying C to C_outputFromOMP.\n");
  copy_array(ni, POLYBENCH_ARRAY(C), POLYBENCH_ARRAY(C_outputFromOMP));

  fprintf(stderr, "Calling Original.\n");
  syr2k_original(ni, nj, alpha, beta, POLYBENCH_ARRAY(A), POLYBENCH_ARRAY(B), POLYBENCH_ARRAY(C));

  fprintf(stderr, "Calling OMP.\n");
  syr2k_omp(ni, nj, alpha, beta, POLYBENCH_ARRAY(A), POLYBENCH_ARRAY(B), POLYBENCH_ARRAY(C_outputFromOMP));

  fprintf(stderr, "Calling compareResults(original, omp).\n");
  compareResults(ni, POLYBENCH_ARRAY(C), POLYBENCH_ARRAY(C_outputFromOMP));

  /* Prevent dead-code elimination. All live-out data must be printed
     by the function call in argument. */
  polybench_prevent_dce(print_array(ni, POLYBENCH_ARRAY(C_outputFromOMP)));

  /* Be clean. */
  POLYBENCH_FREE_ARRAY(A);
  POLYBENCH_FREE_ARRAY(B);
  POLYBENCH_FREE_ARRAY(C);
  POLYBENCH_FREE_ARRAY(C_outputFromOMP);

  return 0;
}
