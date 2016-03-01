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
/* Default data type is double, default size is 20x1000. */
#include "jacobi-2d-imper.h"

// define the error threshold for the results "not matching"
#define PERCENT_DIFF_ERROR_THRESHOLD 0.05

/* ------------------------------------------------------------- */
/* Array initialization. */
static
void init_array (int n,
		 DATA_TYPE POLYBENCH_2D(A,N,N,n,n),
		 DATA_TYPE POLYBENCH_2D(B,N,N,n,n))
{
  int i, j;

  for (i = 0; i < n; i++)
    for (j = 0; j < n; j++) {
	     A[i][j] = ((DATA_TYPE) i*(j+2) + 2) / n;
	     B[i][j] = ((DATA_TYPE) i*(j+3) + 3) / n;
    }
}

/* ------------------------------------------------------------- */
/* DCE code. Must scan the entire live-out data.
   Can be used also to check the correctness of the output. */
static
void print_array(int n,
		 DATA_TYPE POLYBENCH_2D(A,N,N,n,n))

{
  int i, j;

  for (i = 0; i < n; i++)
    for (j = 0; j < n; j++) {
      fprintf(stderr, DATA_PRINTF_MODIFIER, A[i][j]);
      if ((i * n + j) % 20 == 0) fprintf(stderr, "\n");
    }
  fprintf(stderr, "\n");
}

/* ------------------------------------------------------------- */
void copy_array(int n, DATA_TYPE POLYBENCH_2D(source, N, N, n, n), DATA_TYPE POLYBENCH_2D(dest, N, N, n, n)) {
  int i, j;

  for (i = 0; i < n; i++) {
    for (j = 0; j < n; j++) {
      dest[i][j] = source[i][j];
    }
  }
}

/* ------------------------------------------------------------- */
void compareResults(int n, DATA_TYPE POLYBENCH_2D(A,N,N,n,n), DATA_TYPE POLYBENCH_2D(A_output,N,N,n,n), 
                            DATA_TYPE POLYBENCH_2D(B,N,N,n,n), DATA_TYPE POLYBENCH_2D(B_output,N,N,n,n))
{
  int i, j, fail;
  fail = 0;   

  // Compare output from CPU and GPU
  for (i=0; i<n; i++) {
    for (j=0; j<n; j++) {
      if (percentDiff(A[i][j], A_output[i][j]) > PERCENT_DIFF_ERROR_THRESHOLD) {
        fail++;
      }
    }
  }
  
  for (i=0; i<n; i++) {
    for (j=0; j<n; j++) {
      if (percentDiff(B[i][j], B_output[i][j]) > PERCENT_DIFF_ERROR_THRESHOLD) {
        fail++;
      }
    }
  }

  // Print results
  printf("Non-Matching CPU-GPU Outputs Beyond Error Threshold of %4.2f Percent: %d\n", PERCENT_DIFF_ERROR_THRESHOLD, fail);
}

/* Main computational kernel. The whole function will be timed,
   including the call and return. */

/* ------------------------------------------------------------- */
void runJacobi2DCpu(int tsteps, int n, DATA_TYPE POLYBENCH_2D(A,N,N,n,n), DATA_TYPE POLYBENCH_2D(B,N,N,n,n)) {

  int t, i, j;
  
  for (t = 0; t < _PB_TSTEPS; t++) {
    for (i = 1; i < _PB_N - 1; i++) {
      for (j = 1; j < _PB_N - 1; j++) {
          B[i][j] = 0.2f * (A[i][j] + A[i][(j-1)] + A[i][(1+j)] + A[(1+i)][j] + A[(i-1)][j]);
      }
    }
    
    for (i = 1; i < _PB_N-1; i++) {
      for (j = 1; j < _PB_N-1; j++) {
          A[i][j] = B[i][j];
      }
    }
  }
}

/* ------------------------------------------------------------- */
void jacobi2d_original(int tsteps, int n, DATA_TYPE POLYBENCH_2D(A,N,N,n,n), DATA_TYPE POLYBENCH_2D(B,N,N,n,n)){

  /* Start timer. */
  polybench_start_instruments;

  runJacobi2DCpu(tsteps, n, A, B);
  
  /* Stop and print timer. */
  polybench_stop_instruments;
  printf("CPU Time in seconds:\n");
  polybench_print_instruments;
}

/* ------------------------------------------------------------- */
/* Main computational kernel. The whole function will be timed,
   including the call and return. */
static
void jacobi_2d_imper_omp_kernel(int tsteps,
          int n,
          DATA_TYPE POLYBENCH_2D(A,N,N,n,n),
          DATA_TYPE POLYBENCH_2D(B,N,N,n,n))
{
  int t, i, j;

  int tid;

  #pragma scop
  #pragma omp parallel private(i,j,t) num_threads(OPENMP_NUM_THREADS)
  {
    #pragma omp master
    {
      for (t = 0; t < _PB_TSTEPS; t++)
      {
        #pragma omp parallel for schedule(OPENMP_SCHEDULE_WITH_CHUNK) 
        for (i = 1; i < _PB_N - 1; i++)
          for (j = 1; j < _PB_N - 1; j++)
            B[i][j] = 0.2 * (A[i][j] + A[i][j-1] + A[i][1+j] + A[1+i][j] + A[i-1][j]);
        
        #pragma omp parallel for schedule(OPENMP_SCHEDULE_WITH_CHUNK) 
        for (i = 1; i < _PB_N-1; i++)
          for (j = 1; j < _PB_N-1; j++)
            A[i][j] = B[i][j];
      }
    }
  }
  #pragma endscop  

}

/* ------------------------------------------------------------- */
void jacobi_2d_imper_omp(int tsteps,
          int n,
          DATA_TYPE POLYBENCH_2D(A,N,N,n,n),
          DATA_TYPE POLYBENCH_2D(B,N,N,n,n)){
  /* Start timer. */
  polybench_start_instruments;

  /* Run kernel. */
  jacobi_2d_imper_omp_kernel (tsteps, n, A, B);

  /* Stop and print timer. */
  polybench_stop_instruments;
  polybench_print_instruments;

}

/* ------------------------------------------------------------- */
int main(int argc, char** argv)
{
  /* Retrieve problem size. */
  int n = N;
  int tsteps = TSTEPS;

  /* Variable declaration/allocation. */
  POLYBENCH_2D_ARRAY_DECL(A, DATA_TYPE, N, N, n, n);
  POLYBENCH_2D_ARRAY_DECL(B, DATA_TYPE, N, N, n, n);

  POLYBENCH_2D_ARRAY_DECL(A_OMP,DATA_TYPE,N,N,n,n);
  POLYBENCH_2D_ARRAY_DECL(B_OMP,DATA_TYPE,N,N,n,n);

  /* Initialize array(s). */
  init_array (n, POLYBENCH_ARRAY(A), POLYBENCH_ARRAY(B));

  copy_array(n, POLYBENCH_ARRAY(A), POLYBENCH_ARRAY(A_OMP));
  copy_array(n, POLYBENCH_ARRAY(B), POLYBENCH_ARRAY(B_OMP));

  fprintf(stderr, "Calling jacobi2d_original.\n");
  jacobi2d_original(tsteps, n, POLYBENCH_ARRAY(A), POLYBENCH_ARRAY(B));
  
  fprintf(stderr, "Calling jacobi_2d_imper_omp.\n");
  jacobi_2d_imper_omp(tsteps, n, POLYBENCH_ARRAY(A_OMP), POLYBENCH_ARRAY(B_OMP));

  fprintf(stderr, "Calling compareResults(original, omp).\n");
  compareResults(n, POLYBENCH_ARRAY(A), POLYBENCH_ARRAY(A_OMP), 
                    POLYBENCH_ARRAY(B), POLYBENCH_ARRAY(B_OMP));

  /* Prevent dead-code elimination. All live-out data must be printed
     by the function call in argument. */
  polybench_prevent_dce(print_array(n, POLYBENCH_ARRAY(A)));

  /* Be clean. */
  POLYBENCH_FREE_ARRAY(A);
  POLYBENCH_FREE_ARRAY(B);

  return 0;
}
