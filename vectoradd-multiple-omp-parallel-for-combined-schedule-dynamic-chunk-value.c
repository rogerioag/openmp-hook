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
double h_a[N];
double h_b[N];
double h_c[N];

void init_array() {
  fprintf(stdout, "Inicializando os arrays.\n");
  int i;
  
  #pragma omp parallel for num_threads (4) schedule (dynamic, 32)
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
  double sum = 0;
  fprintf(stdout, "Thread [%02d]: Verificando o resultado.\n", omp_get_thread_num());  
  
  for (i = 0; i < N; i++) {
    sum += h_c[i];
  }
  fprintf(stdout, "Thread [%02d]: Resultado Final: (%f, %f)\n", omp_get_thread_num(), sum, (double)(sum / (double)N));
}

int main() {
  int i;
  init_array();

  // int chunk_size = N / omp_get_num_procs();

  #pragma omp parallel for num_threads (4) schedule (dynamic, 32)
  for (i = 0; i < N; i++) {
    h_c[i] = h_a[i] + h_b[i];
  }

  // print_array();
  check_result();

  return 0;
}
