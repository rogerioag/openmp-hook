#include <stdio.h>
#include <stdlib.h>

// #include "hookomp.h"

#ifdef _OPENMP
#include <omp.h>
// #include <libgomp_g.h>
// #include "hookomp.h"
#else
#define omp_get_thread_num() 0
#define omp_get_num_threads() 1
#define omp_get_num_procs() (system("cat /proc/cpuinfo | grep 'processor' | wc -l"))
#endif

extern void GOMP_barrier(void);
extern bool GOMP_single_start(void);
extern void GOMP_loop_end(void);
extern bool GOMP_loop_runtime_next (long *, long *);
extern bool GOMP_loop_runtime_start (long, long, long, long *, long *);

// Size of vectors.
#ifndef N
// #define N 1048576
#define N 4096
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


void func_OpenMP(){
    printf("func_OpenMP.\n");
    long i, _s0, _e0;
    if (GOMP_loop_runtime_start (N/2, N, 1, &_s0, &_e0))
      do {
           long _e1 = _e0;
           for (i = _s0; i < _e0; i++){
             fprintf(stdout, "Thread: %d of %d.\n", omp_get_thread_num(), omp_get_num_threads());
             h_c[i] = h_a[i] + h_b[i];
           }
         } while (GOMP_loop_runtime_next (&_s0, &_e0));
    
    GOMP_loop_end ();
}

void func_GPU(){
    printf("func_GPU.\n");
    long i, _s0, _e0;
    if (GOMP_loop_runtime_start (N/2, N, 1, &_s0, &_e0))
      do {
           long _e1 = _e0;
           for (i = _s0; i < _e0; i++){
             fprintf(stdout, "Thread: %d of %d.\n", omp_get_thread_num(), omp_get_num_threads());
             h_c[i] = h_a[i] + h_b[i];
           }
         } while (GOMP_loop_runtime_next (&_s0, &_e0));
    
    GOMP_loop_end ();
}


/* Tipo para o ponteiro de função. */
typedef void (*op_func) (void);

/* Tabela de funções para chamada parametrizada. */
op_func getTargetFunc[2] = { func_OpenMP, func_GPU };

/* Initialization of TablePointerFunctions to libhook. */
op_func *TablePointerFunctions = getTargetFunc;


int main() {
	fprintf(stdout, "main().\n");
  int i;
  /* Inicialização  dos vetores. */
  init_array();
	
	// initialization_of_papi_libray_mode();
	
  fprintf(stdout, "before parallel region.\n");
  #pragma omp parallel num_threads(2)
  {
    // Test single start. Source: https://gcc.gnu.org/onlinedocs/libgomp/Implementing-SINGLE-construct.html#Implementing-SINGLE-construct
    //#pragma omp single
    //{
    //  body;
    //}

    // becomes:

    //if (GOMP_single_start ())
    //  body;
    //GOMP_barrier ();

    // #pragma omp single
    // for (i = 0; i < N/2; i++) {
    //  fprintf(stdout, "Thread: %d of %d.\n", omp_get_thread_num(), omp_get_num_threads()); 
    //  h_c[i] = h_a[i] + h_b[i];
    // }
    
    if (GOMP_single_start()){
      for (i = 0; i < N/2; i++) {
        fprintf(stdout, "Thread: %d of %d.\n", omp_get_thread_num(), omp_get_num_threads()); 
        h_c[i] = h_a[i] + h_b[i];
      }  
    }
    GOMP_barrier ();

    // #pragma omp for schedule(runtime)
    // for (i = 0; i < n; i++)
    //   body;

    // becomes:
    //{
    //  long i, _s0, _e0;
    //  if (GOMP_loop_runtime_start (0, n, 1, &_s0, &_e0))
    //    do {
    //         long _e1 = _e0;
    //         for (i = _s0, i < _e0; i++)
    //           body;
    //       } while (GOMP_loop_runtime_next (&_s0, _&e0));
    //
    //  GOMP_loop_end ();
    //}

    // #pragma omp for schedule(runtime)
    // for (i = N/2; i < N; i++) {
    //  fprintf(stdout, "Thread: %d of %d.\n", omp_get_thread_num(), omp_get_num_threads());
    //  h_c[i] = h_a[i] + h_b[i];
    // }

    /*{
      long i, _s0, _e0;
      if (GOMP_loop_runtime_start (N/2, N, 1, &_s0, &_e0))
        do {
             long _e1 = _e0;
             for (i = _s0; i < _e0; i++){
               fprintf(stdout, "Thread: %d of %d.\n", omp_get_thread_num(), omp_get_num_threads());
               h_c[i] = h_a[i] + h_b[i];
             }
           } while (GOMP_loop_runtime_next (&_s0, &_e0));
    
      GOMP_loop_end ();
    }*/

    func_OpenMP();

  }

  
  // GOMP_parallel_start(getTargetFunc[0], &data, 2);
  // getTargetFunc[0](&data);
  // GOMP_parallel_end();

  /* Resultados. */
  // print_array();
  check_result();
  
  return 0;
}

