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
#define N 1048576
#endif
// Entrada e saída.
float h_a[N];
float h_b[N];
float h_c[N];

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
  float sum = 0;
  fprintf(stdout, "Thread [%02d]: Verificando o resultado.\n", omp_get_thread_num());  
  
  for (i = 0; i < N; i++) {
    sum += h_c[i];
  }
  fprintf(stdout, "Thread [%02d]: Resultado Final: (%f, %f)\n", omp_get_thread_num(), sum, (float)(sum / (float)N));
}

int main() {
  int i;
  /* Inicialização  dos vetores. */
  init_array();
  
  #pragma omp parallel
  {
    #pragma omp single
    printf("Thread [%02d]: Inicio de uma possivel regiao paralela, numero de threads = %d, processadores = %d\n", omp_get_thread_num(), omp_get_num_threads(), omp_get_num_procs());
    
    #pragma omp for schedule(runtime)
    /* Calculo. */
    for (i = 0; i < N; i++) {
      // printf("Thread [%02d] executa a iteracao %07d do loop.\n", omp_get_thread_num(), i);
      h_c[i] = h_a[i] + h_b[i];
    }
  }
  /* Resultados. */
  // print_array();
  check_result();
  
  return 0;
}
