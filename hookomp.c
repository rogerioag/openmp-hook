// #define _GNU_SOURCE
// #include <libgomp_g.h>

#include <dlfcn.h>
#include <stdio.h>
#include <stdint.h>
#include <papi.h>

#define NUM_EVENTS 2
long long values[NUM_EVENTS];
long long int Events[NUM_EVENTS]={PAPI_TOT_INS, PAPI_TOT_CYC};

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
	puts("Hello, I'm a shared library");
}

/* Function to intercept GOMP_parallel_start */
void GOMP_parallel_start (void (*fn)(void *), void *data, unsigned num_threads){
	printf("[hookomp] GOMP_parallel_start.\n");

	typedef void (*func_t)(void (*fn)(void *), void *, unsigned);

	func_t lib_GOMP_parallel_start = (func_t) dlsym(RTLD_NEXT, "GOMP_parallel_start");
	printf("[GOMP_1.0] GOMP_parallel_start@@GOMP_1.0.\n");

	/* Start the counters */
	PAPI_start_counters((int*)Events, NUM_EVENTS);

	return lib_GOMP_parallel_start(fn, data, num_threads); 
}

/* Function to intercept GOMP_parallel_end */
void GOMP_parallel_end (void){
	printf("[hookomp] GOMP_parallel_end.\n");

	/* Stop counters and store results in values */
	int retval = PAPI_stop_counters(values, NUM_EVENTS);

	if(retval != PAPI_OK )
		printf("Error on PAPI execution.\n");

	printf("Total insts: %lld Total Cycles: %lld\n", (long long int) values[0], (long long int) values[1]);	 

	typedef void (*func_t)(void);

	func_t lib_GOMP_parallel_end = (func_t) dlsym(RTLD_NEXT, "GOMP_parallel_end");
	printf("[GOMP_1.0] GOMP_parallel_end@@GOMP_1.0.\n");
	return lib_GOMP_parallel_end();	 
}
