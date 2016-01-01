#include <stdio.h>
#include <stdlib.h>

#include "hookomp.h"

#ifdef _OPENMP
#include <omp.h>
#else
#define omp_get_thread_num() 0
#define omp_get_num_threads() 1
#define omp_get_num_procs() (system("cat /proc/cpuinfo | grep 'processor' | wc -l"))
#endif

// Size of vectors.
#ifndef N
// #define N 1048576
#define N 16
#endif
// Entrada e saída.
float h_a[N];
float h_b[N];
float h_c[N];

void init_array() {
  fprintf(stdout, "init_array().\n");
  int i;
  // Initialize vectors on host.
    for (i = 0; i < N; i++) {
      h_a[i] = 0.5;
      h_b[i] = 0.5;
    }
}

void print_array() {
	fprintf(stdout, "print_array().\n");
  int i;
  for (i = 0; i < N; i++) {
    fprintf(stdout, "h_c[%07d]: %f\n", i, h_c[i]);
  }
}

void check_result(){
	fprintf(stdout, "check_result().\n");
  // Soma dos elementos do array C e divide por N, o valor deve ser igual a 1.
  int i;
  float sum = 0;
  fprintf(stdout, "Verificando o resultado.\n");  
  
  for (i = 0; i < N; i++) {
    sum += h_c[i];
  }
  fprintf(stdout, "Resultado Final: (%f, %f)\n", sum, (float)(sum / (float)N));
}

int main() {
	fprintf(stdout, "main().\n");
  int i;
  /* Inicialização  dos vetores. */
  init_array();
	
	fprintf(stdout, "before parallel region 1.\n");
#pragma omp parallel
{
  #pragma omp single
  /* Cálculo. */
  for (i = 0; i < N/2; i++) {
	fprintf(stdout, "Thread: %d of %d.\n", omp_get_thread_num(), omp_get_num_threads()); 
	h_c[i] = h_a[i] + h_b[i];
  }
}

fprintf(stdout, "before parallel region 2.\n");
#pragma omp parallel
{
  #pragma omp for
  /* Cálculo. */
  for (i = N/2; i < N; i++) {
		fprintf(stdout, "Thread: %d of %d.\n", omp_get_thread_num(), omp_get_num_threads());
    h_c[i] = h_a[i] + h_b[i];
  }
}

  /* Resultados. */
  // print_array();
  check_result();
  
  return 0;
}
