// #define _GNU_SOURCE
// #include <libgomp_g.h>

#include <dlfcn.h>
#include <stdio.h>
#include <stdint.h>
#include <papi.h>
#include <pthread.h>
#include "hookomp.h"

#ifdef __cplusplus
extern "C" {
#endif
	/* Tabela de funções para chamada parametrizada. */
	// op_func *TablePointerFunctions;

	void foo(void);
	// GOMP_loop_runtime_start@@GOMP_1.0
	void GOMP_parallel_start (void (*fn)(void *), void *data, unsigned num_threads);
	void GOMP_parallel_end (void);
	
	bool GOMP_single_start (void);
	void GOMP_barrier (void);
	
	

	bool GOMP_loop_runtime_start (long start, long end, long incr,
			 long *istart, long *iend);

	bool GOMP_loop_runtime_next (long *istart, long *iend);

	bool GOMP_loop_ordered_runtime_next (long *istart, long *iend);

	bool GOMP_loop_ordered_runtime_start (long start, long end, long incr,
				 long *istart, long *iend);

	bool GOMP_loop_static_start (long start, long end, long incr, long chunk_size,
			long *istart, long *iend);

	bool GOMP_loop_dynamic_start (long start, long end, long incr, long chunk_size,
			 long *istart, long *iend);

	bool GOMP_loop_guided_start (long start, long end, long incr, long chunk_size,
			long *istart, long *iend);

	bool GOMP_loop_ordered_static_start (long start, long end, long incr,
				long chunk_size, long *istart, long *iend);

	bool GOMP_loop_ordered_dynamic_start (long start, long end, long incr,
				 long chunk_size, long *istart, long *iend);

	bool GOMP_loop_ordered_guided_start (long start, long end, long incr,
				long chunk_size, long *istart, long *iend);

	bool GOMP_loop_static_next (long *istart, long *iend);

	bool GOMP_loop_dynamic_next (long *istart, long *iend);

	bool GOMP_loop_guided_next (long *istart, long *iend);

	bool GOMP_loop_ordered_static_next (long *istart, long *iend);

	bool GOMP_loop_ordered_dynamic_next (long *istart, long *iend);

	bool GOMP_loop_ordered_guided_next (long *istart, long *iend);

	void GOMP_parallel_loop_static_start (void (*fn) (void *), void *data,
				 unsigned num_threads, long start, long end,
				 long incr, long chunk_size);

	void GOMP_parallel_loop_dynamic_start (void (*fn) (void *), void *data,
				  unsigned num_threads, long start, long end,
				  long incr, long chunk_size);

	void GOMP_parallel_loop_guided_start (void (*fn) (void *), void *data,
				 unsigned num_threads, long start, long end,
				 long incr, long chunk_size);

	void GOMP_parallel_loop_runtime_start (void (*fn) (void *), void *data,
				  unsigned num_threads, long start, long end,
				  long incr);

	void GOMP_loop_end (void);

	void GOMP_loop_end_nowait (void);


	
#ifdef __cplusplus
}
#endif

/* ------------------------------------------------------------- */
/* Test function.                                                */
void foo(void) {
	puts("Hello, I'm a shared library.\n");
}

/* ------------------------------------------------------------- */
/* Function to initialization of HOOKOMP Library.                   */
void initialization_of_hookomp_library(){
	printf("[hookomp] initialization_of_hookomp_library.\n");		
}

/* ------------------------------------------------------------- */
/* Function to intercept GOMP_parallel_start                     */
void GOMP_parallel_start (void (*fn)(void *), void *data, unsigned num_threads){
	printf("[hookomp] GOMP_parallel_start.\n");

  	// printf("[hookomp]   Call by TablePointerFunctions.\n");
	// TablePointerFunctions[0](data);
	// TablePointerFunctions[1](data);
	
	typedef void (*func_t)(void (*fn)(void *), void *, unsigned);
	func_t lib_GOMP_parallel_start = (func_t) dlsym(RTLD_NEXT, "GOMP_parallel_start");
	printf("[GOMP_1.0] GOMP_parallel_start@GOMP_1.0.[%p]\n", (void* )fn);
	
	printf("[GOMP_1.0] lib_GOMP_parallel_start[%p]\n", (void* )lib_GOMP_parallel_start);

	lib_GOMP_parallel_start(fn, data, num_threads); 
}

/* ------------------------------------------------------------- */
/* Function to intercept GOMP_parallel_end                       */
void GOMP_parallel_end (void){
	printf("[hookomp] GOMP_parallel_end.\n");
	
	// Get Counters.
	
	typedef void (*func_t)(void);

	func_t lib_GOMP_parallel_end = (func_t) dlsym(RTLD_NEXT, "GOMP_parallel_end");
	printf("[GOMP_1.0] GOMP_parallel_end@GOMP_1.0.\n");
	
    lib_GOMP_parallel_end();
}

/*----------------------------------------------------------------*/
bool GOMP_single_start (void){
	printf("[hookomp] GOMP_single_start.\n");
	
	// Retrieve the OpenMP runtime function.
	typedef bool (*func_t)(void);

	func_t lib_GOMP_single_start = (func_t) dlsym(RTLD_NEXT, "GOMP_single_start");
	printf("[GOMP_1.0] GOMP_single_start@GOMP_1.0.\n");
	
	bool result = lib_GOMP_single_start();

	/* This routine is called when first encountering a SINGLE construct that
   doesn't have a COPYPRIVATE clause.  Returns true if this is the thread
   that should execute the clause.
   bool GOMP_single_start (void){...} */

   // Start the counters on PAPI if is the thread that should execute.
   if (result){
   		// PAPI Start the counters.
   		printf("[hookomp] GOMP_single_start: calling PAPI START THE COUNTERS.\n");
   }

   return result;
}

/*----------------------------------------------------------------*/
void GOMP_barrier (void){
	printf("[hookomp] GOMP_barrier.\n");
	
	typedef bool (*func_t)(void);

	func_t lib_GOMP_barrier = (func_t) dlsym(RTLD_NEXT, "GOMP_barrier");
	printf("[GOMP_1.0] GOMP_barrier@GOMP_1.0.\n");
	
	lib_GOMP_barrier();
}

bool GOMP_loop_runtime_start (long start, long end, long incr,
			 long *istart, long *iend){
	return false;
}

bool GOMP_loop_runtime_next (long *istart, long *iend){
	return false;
}

bool GOMP_loop_ordered_runtime_next (long *istart, long *iend){
	return false;
}

bool GOMP_loop_ordered_runtime_start (long start, long end, long incr, long *istart, long *iend){
	return false;
}

bool GOMP_loop_static_start (long start, long end, long incr, long chunk_size, long *istart, long *iend){
	return false;
}

bool GOMP_loop_dynamic_start (long start, long end, long incr, long chunk_size, long *istart, long *iend){
	return false;
}

bool GOMP_loop_guided_start (long start, long end, long incr, long chunk_size, long *istart, long *iend){
	return false;
}

bool GOMP_loop_ordered_static_start (long start, long end, long incr, long chunk_size, long *istart, long *iend){
	return false;
}

bool GOMP_loop_ordered_dynamic_start (long start, long end, long incr, long chunk_size, long *istart, long *iend){
	return false;
}

bool GOMP_loop_ordered_guided_start (long start, long end, long incr, long chunk_size, long *istart, long *iend){
	return false;
}

bool GOMP_loop_static_next (long *istart, long *iend){
	return false;
}

bool GOMP_loop_dynamic_next (long *istart, long *iend){
	return false;
}

bool GOMP_loop_guided_next (long *istart, long *iend){
	return false;
}

bool GOMP_loop_ordered_static_next (long *istart, long *iend){
	return false;
}

bool GOMP_loop_ordered_dynamic_next (long *istart, long *iend){
	return false;
}

bool GOMP_loop_ordered_guided_next (long *istart, long *iend){
	return false;
}

void GOMP_parallel_loop_static_start (void (*fn) (void *), void *data,
				 unsigned num_threads, long start, long end,
				 long incr, long chunk_size){

}

void GOMP_parallel_loop_dynamic_start (void (*fn) (void *), void *data,
				  unsigned num_threads, long start, long end,
				  long incr, long chunk_size){

}

void GOMP_parallel_loop_guided_start (void (*fn) (void *), void *data,
				 unsigned num_threads, long start, long end,
				 long incr, long chunk_size){

}

void GOMP_parallel_loop_runtime_start (void (*fn) (void *), void *data,
				  unsigned num_threads, long start, long end,
				  long incr){

}

void GOMP_loop_end (void){

}

void GOMP_loop_end_nowait (void){

}
