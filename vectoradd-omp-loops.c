#include <stdio.h>
#include <stdlib.h>

#ifdef _OPENMP
#include <omp.h>
#else
#define omp_get_thread_num() 0
#define omp_get_num_threads() 1
#define omp_get_num_procs() (system("cat /proc/cpuinfo | grep 'processor' | wc -l"))
#endif

#include <papi.h>

#define NUM_EVENTS 2

// Size of vectors.
#ifndef N
// #define N 1048576
#define N 16
#endif
// Entrada e saída.
float h_a[N];
float h_b[N];
float h_c[N];

const PAPI_hw_info_t *hw_info = NULL;

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
	int i, retval;
	long long elapsed_us, elapsed_cyc;
	
	long_long values[NUM_EVENTS];
	unsigned int EventsSet[NUM_EVENTS]={PAPI_TOT_INS, PAPI_TOT_CYC};
	
	/* Inicialização  dos vetores. */
	init_array();
	
	retval = PAPI_library_init( PAPI_VER_CURRENT );
	if ( retval != PAPI_VER_CURRENT )
		printf("PAPI_library_init: %d.\n", retval);
	
	hw_info = PAPI_get_hardware_info();
	if (hw_info == NULL)
		printf("PAPI_get_hardware_info: %d.\n", 2);
	
	elapsed_us = PAPI_get_real_usec();
	
	elapsed_cyc = PAPI_get_real_cyc();
	
	
	
	
	fprintf(stdout, "before parallel region 1.\n");
	#pragma omp parallel
	{
		#pragma omp single
		/* Cálculo. */
		{
			retval = PAPI_thread_init((unsigned long (*)(void)) (omp_get_thread_num));
	
			if ( retval != PAPI_OK ) {
				if ( retval == PAPI_ECMP )
					printf("PAPI_thread_init OK: %d.\n", retval);
				else
				printf("PAPI_thread_init fail: %d.\n", retval);
			}
	
			retval = PAPI_start(EventsSet);
			if ( retval != PAPI_OK )
				printf("PAPI_start error: %d.\n", retval);
			
			for (i = 0; i < N; i++) {
				fprintf(stdout, "Thread: %d of %d.\n", omp_get_thread_num(), omp_get_num_threads()); 
				h_c[i] = h_a[i] + h_b[i];
			}
			
			// int retval = PAPI_stop_counters(values,NUM_EVENTS);
	
			retval = PAPI_stop(EventsSet, values);
			if ( retval != PAPI_OK )
				printf("PAPI_stop error: %d.\n", retval);
	
			printf("Total insts: %lld Total Cycles: %lld\n", values[0], values[1]);
		}
	}
	
	
	
	
/*	fprintf(stdout, "before parallel region 2.\n");
	#pragma omp parallel
	{
		#pragma omp for
		for (i = N/2; i < N; i++) {
			fprintf(stdout, "Thread: %d of %d.\n", omp_get_thread_num(), omp_get_num_threads());
			h_c[i] = h_a[i] + h_b[i];
		}
	}
*/	
	/* Resultados. */
	// print_array();
	check_result();
	
	elapsed_cyc = PAPI_get_real_cyc() - elapsed_cyc;

	elapsed_us = PAPI_get_real_usec() - elapsed_us;

	printf( "Master real usec   : \t%lld\n", elapsed_us );
	printf( "Master real cycles : \t%lld\n", elapsed_cyc );
	
	return 0;
}
