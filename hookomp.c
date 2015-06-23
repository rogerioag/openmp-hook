// #define _GNU_SOURCE
// #include <libgomp_g.h>

#include <dlfcn.h>
#include <stdio.h>
#include <stdint.h>
#include <papi.h>

#define NUM_EVENTS 2
long long values[NUM_EVENTS];
long long int Events[NUM_EVENTS]={PAPI_TOT_INS, PAPI_TOT_CYC};

int EventSet = PAPI_NULL;

#ifdef __cplusplus
extern "C" {
#endif
	void foo(void);
	// GOMP_loop_runtime_start@@GOMP_1.0
	void GOMP_parallel_start (void (*fn)(void *), void *data, unsigned num_threads);
	void GOMP_parallel_end (void);
#ifdef __cplusplus
}
#endif

/* Test function. */
void foo(void) {
	puts("Hello, I'm a shared library.\n");
}

/* Function to intercept GOMP_parallel_start */
void GOMP_parallel_start (void (*fn)(void *), void *data, unsigned num_threads){
	printf("[hookomp] GOMP_parallel_start.\n");
	
	EventSet = PAPI_NULL;

	typedef void (*func_t)(void (*fn)(void *), void *, unsigned);
	func_t lib_GOMP_parallel_start = (func_t) dlsym(RTLD_NEXT, "GOMP_parallel_start");
	printf("[GOMP_1.0] GOMP_parallel_start@@GOMP_1.0.\n");
	
	// int omp_get_thread_num(void);
	
	typedef int (*func_omp_get_thread_num_t)(void);
	func_omp_get_thread_num_t lib_GOMP_get_thread_num = (func_omp_get_thread_num_t) dlsym(RTLD_NEXT, "omp_get_thread_num");
	
	int retval = PAPI_thread_init((unsigned long (*)(void)) (lib_GOMP_get_thread_num));
	
	if (retval != PAPI_OK) {
		if (retval == PAPI_ESBSTR)
			printf("PAPI_thread_init: %d\n", retval);
	}
	
	/* Create an EventSet */
  if (PAPI_create_eventset(&EventSet) != PAPI_OK)
    printf("PAPI_create_eventset error.\n");

	/* Add Total Instructions Executed to our EventSet */
  if (PAPI_add_event(EventSet, PAPI_TOT_INS) != PAPI_OK)
		printf("PAPI_add_event error PAPI_TOT_INS.\n");
	
	if (PAPI_add_event(EventSet, PAPI_TOT_CYC) != PAPI_OK)
		printf("PAPI_add_event error PAPI_TOT_CYC.\n");

  /* Start counting */
  if (PAPI_start(EventSet) != PAPI_OK)
		printf("PAPI_start counting error.\n");

	/* Start the counters */
	// PAPI_start_counters((int*)Events, NUM_EVENTS);

	return lib_GOMP_parallel_start(fn, data, num_threads); 
}

/* Function to intercept GOMP_parallel_end */
void GOMP_parallel_end (void){
	printf("[hookomp] GOMP_parallel_end.\n");
	
	long long elapsed_us, elapsed_cyc;

	/* Stop counters and store results in values */
	int retval = PAPI_stop_counters(values, NUM_EVENTS);

	if(retval != PAPI_OK ){
		printf("Error on PAPI execution.\n");
		
		switch (retval){
				case PAPI_EINVAL :
					printf("One or more of the arguments is invalid.\n");
					break;
				case PAPI_ENOTRUN : 
					printf("The EventSet is not started yet.\n");
					break;
				case PAPI_ENOEVST : 
					printf("The EventSet has not been added yet.\n");
					break;
			default:
				printf("Unknown Error.\n");
		}
	}

	printf("Total insts: %lld Total Cycles: %lld\n", (long long int) values[0], (long long int) values[1]);	
	
	elapsed_us = PAPI_get_real_usec();
	elapsed_cyc = PAPI_get_real_cyc();
	
	printf( "Master real usec   : \t%lld\n", elapsed_us );
	printf( "Master real cycles : \t%lld\n", elapsed_cyc );
	
	/* Read the counters */
   if (PAPI_read(EventSet, values) != PAPI_OK)
     printf("PAPI_read error reading counters.\n");

	 printf("After reading counters: Total insts: %lld Total Cycles: %lld\n", (long long int) values[0], (long long int) values[1]);

   /* Start the counters */
   if (PAPI_stop(EventSet, values) != PAPI_OK)
     printf("PAPI_read error stopping counters.\n");
	 
	 printf("After stopping counters: Total insts: %lld Total Cycles: %lld\n", (long long int) values[0], (long long int) values[1]);
	
	
	typedef void (*func_t)(void);

	func_t lib_GOMP_parallel_end = (func_t) dlsym(RTLD_NEXT, "GOMP_parallel_end");
	printf("[GOMP_1.0] GOMP_parallel_end@@GOMP_1.0.\n");
	return lib_GOMP_parallel_end();
}
