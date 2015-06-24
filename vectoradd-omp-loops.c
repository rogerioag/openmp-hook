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
	int Events[NUM_EVENTS] = { PAPI_TOT_INS, PAPI_TOT_CYC };
		
	/* Inicialização  dos vetores. */
	init_array();
	
	retval = PAPI_library_init( PAPI_VER_CURRENT );
	if ( retval != PAPI_VER_CURRENT ){
		printf("PAPI_VERSION: %d, PAPI_VER_CURRENT: %d", PAPI_VERSION, PAPI_VER_CURRENT);
		printf("PAPI_library_init: %d.\n", retval);
		
		switch (retval) {
			case PAPI_EINVAL: 
				printf("papi.h is different from the version used to compile the PAPI library.\n"); 
				break;

			case PAPI_ENOMEM:
				printf("Insufficient memory to complete the operation.\n");
				break;
			case PAPI_ESBSTR:
				printf("This substrate does not support the underlying hardware.\n");
				break;
			case PAPI_ESYS:
				printf("A system or C library call failed inside PAPI, see the errno variable.\n");
				break;
			default:
					printf("Unknown error.");
		}
		
	}
	
	if (retval != PAPI_VER_CURRENT && retval > 0) {
		fprintf(stderr,"PAPI library version mismatch!\n");
		exit(1);
	}
	
	retval = PAPI_is_initialized();
	if (retval != PAPI_LOW_LEVEL_INITED){
		printf("PAPI_is_initialized: %d.\n", retval);
	}
	
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
			int retval_private = PAPI_thread_init((unsigned long (*)(void)) (omp_get_thread_num));
	
			if ( retval_private != PAPI_OK ) {
				if ( retval_private == PAPI_ECMP )
					printf("PAPI_thread_init OK: %d.\n", retval_private);
				else
				printf("PAPI_thread_init fail: %d.\n", retval_private);
			}
	
			// retval_private = PAPI_start(EventsSet);
			
			retval_private = PAPI_start_counters(Events, 2);
						
			if ( retval_private != PAPI_OK ){
				printf("PAPI_start_counters error: %d.\n", retval_private);
				
				switch (retval_private) {
					case PAPI_EINVAL :
						printf("One or more of the arguments is invalid.\n");
						break;
					case PAPI_EISRUN :
						printf("Counters have already been started, you must call PAPI_stop_counters() before you call this function again.\n");
						break;
					case PAPI_ESYS :
						printf("A system or C library call failed inside PAPI, see the errno variable.\n");
						break;
					case PAPI_ENOMEM :
						printf("Insufficient memory to complete the operation.\n");
						break;
					case PAPI_ECNFLCT :
						printf("The underlying counter hardware cannot count this event and other events in the EventSet simultaneously.\n");
						break;
					case PAPI_ENOEVNT :
						printf("The PAPI preset is not available on the underlying hardware.\n");
						break;
					default:
						printf("Unknown error.\n");
				}				
			}
			
			for (i = 0; i < N; i++) {
				fprintf(stdout, "Thread: %d of %d.\n", omp_get_thread_num(), omp_get_num_threads()); 
				h_c[i] = h_a[i] + h_b[i];
			}
			
			// retval_private = PAPI_stop(EventsSet, values);
			retval_private = PAPI_stop_counters(values, NUM_EVENTS);
			if ( retval_private != PAPI_OK ){
				printf("PAPI_stop_counters error: %d.\n", retval_private);
				
				switch (retval_private){
					case PAPI_EINVAL : 
						printf("One or more of the arguments is invalid.\n");
						break;
					case PAPI_ENOTRUN : 
						printf("The EventSet is not started yet.\n");
						break;
					case PAPI_ENOEVST:
						printf("The EventSet has not been added yet.\n");
						break;
					default:
						printf("Unknown error.\n");
				}
			}
			
	
			printf("Total insts: %lld Total Cycles: %lld\n", values[0], values[1]);
			PAPI_unregister_thread();
			printf( "Thread %#x finished\n", omp_get_thread_num());
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
