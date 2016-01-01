#include <stdio.h>
#include <stdlib.h>

#ifdef _OPENMP
#include <omp.h>
#else
#define omp_get_thread_num() 0
#define omp_get_num_threads() 1
#define omp_get_num_procs() (system("cat /proc/cpuinfo | grep 'processor' | wc -l"))
#endif

// Size of vectors.
#ifndef N
#define N 4096
#endif
// Entrada e saida.
#define DATA_TYPE double

DATA_TYPE h_a[N];
DATA_TYPE h_b[N];
DATA_TYPE h_c[N];

void init_array() {
  fprintf(stdout, "Inicializando os arrays.\n");
  int i;
  // Initialize vectors on host.
    for (i = 0; i < N; i++) {
      h_a[i] = 0.5;
      h_b[i] = 0.5;
    }
}

void print_array() {
  int i;
  fprintf(stdout, "Thread [%02d]: Imprimindo o array de resultados:\n", omp_get_thread_num());
  for (i = 0; i < N; i++) {
    fprintf(stdout, "Thread [%02d]: h_c[%07d]: %f\n", omp_get_thread_num(), i, h_c[i]);
  }
}

void check_result(){
  // Soma dos elementos do array C e divide por N, o valor deve ser igual a 1.
  int i;
  DATA_TYPE sum = 0;
  fprintf(stdout, "Thread [%02d]: Verificando o resultado.\n", omp_get_thread_num());  
  
  for (i = 0; i < N; i++) {
    sum += h_c[i];
  }
  fprintf(stdout, "Thread [%02d]: Resultado Final: (%f, %f)\n", omp_get_thread_num(), sum, (DATA_TYPE)(sum / (DATA_TYPE)N));
}

int main() {
  int i;
  init_array();

  int number_of_threads = 4;

  #pragma omp parallel for num_threads (number_of_threads) schedule (runtime)
  for (i = 0; i < N; i++) {
    h_c[i] = h_a[i] + h_b[i];
  }

  // print_array();
  check_result();

  return 0;
}
