#include "hookomp.h"

/* ------------------------------------------------------------- */
/* Test function.                                                */
void foo(void) {
	puts("Hello, I'm a shared library.\n");
}

/* ------------------------------------------------------------- */
/* Function to intercept GOMP_parallel_start                     */
void GOMP_parallel_start (void (*fn)(void *), void *data, unsigned num_threads){
	HOOKOMP_FUNC_NAME;

  	// printf("[hookomp]   Call by TablePointerFunctions.\n");
	// TablePointerFunctions[0](data);
	// TablePointerFunctions[1](data);
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_parallel_start, "GOMP_parallel_start");

	printf("[GOMP_1.0] GOMP_parallel_start@GOMP_1.0.[%p]\n", (void* )fn);
	
	printf("[GOMP_1.0] lib_GOMP_parallel_start[%p]\n", (void* )lib_GOMP_parallel_start);

	lib_GOMP_parallel_start(fn, data, num_threads); 
}

/* ------------------------------------------------------------- */
/* Function to intercept GOMP_parallel_end                       */
void GOMP_parallel_end (void){
	HOOKOMP_FUNC_NAME;
	
	// Get Counters.
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_parallel_end, "GOMP_parallel_end");

	printf("[GOMP_1.0] GOMP_parallel_end@GOMP_1.0 [%p]\n", (void* )lib_GOMP_parallel_end);
	
    lib_GOMP_parallel_end();
}

/*----------------------------------------------------------------*/
bool GOMP_single_start (void){
	HOOKOMP_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_single_start, "GOMP_single_start");
	printf("[GOMP_1.0] GOMP_single_start@GOMP_1.0.\n");
	
	/* This routine is called when first encountering a SINGLE construct that
   doesn't have a COPYPRIVATE clause.  Returns true if this is the thread
   that should execute the clause.
   bool GOMP_single_start (void){...} */

   bool result = lib_GOMP_single_start();

   // Start the counters on PAPI if is the thread that should execute.
   if (result){
   		// PAPI Start the counters.
   		if(RM_start_counters()){
   			fprintf(stderr, "[hookomp] GOMP_single_start: calling PAPI START THE COUNTERS.\n");
   		}
   		else 
   			fprintf(stderr, "Error calling RM_start_counters from GOMP_single_start.");
   	}	

   return result;
}

/*----------------------------------------------------------------*/
void GOMP_barrier (void) {
	HOOKOMP_FUNC_NAME;
	
	GET_RUNTIME_FUNCTION(lib_GOMP_barrier, "GOMP_barrier");

	bool result = RM_stop_counters();

	if(!result){
		fprintf(stderr, "Error GOMP_barrier: RM_stop_counters.");
	}

	printf("[GOMP_1.0] GOMP_barrier@GOMP_1.0.\n");
	
	lib_GOMP_barrier();

	// Verificar o que a GOMP_barrier faz para ver onde a chamada aos contadores tem que ser feita.

	// A decisão de migrar é aqui.
	double oi = RM_get_operational_intensity();
	fprintf(stderr, "Operational intensity: %g", oi);	

}

/*----------------------------------------------------------------*/
bool GOMP_loop_runtime_next (long *istart, long *iend){
	HOOKOMP_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_runtime_next, "GOMP_loop_runtime_next");
	printf("[GOMP_1.0] GOMP_loop_runtime_next@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_runtime_next(istart, iend);
	
	return result;
}

/*----------------------------------------------------------------*/
bool GOMP_loop_ordered_runtime_next (long *istart, long *iend){
	HOOKOMP_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ordered_runtime_next, "GOMP_loop_ordered_runtime_next");
	printf("[GOMP_1.0] GOMP_loop_ordered_runtime_next@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_ordered_runtime_next(istart, iend);
	
	return result;
}

/*----------------------------------------------------------------*/
bool GOMP_loop_ordered_runtime_start (long start, long end, long incr, long *istart, long *iend){
	HOOKOMP_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ordered_runtime_start, "GOMP_loop_ordered_runtime_start");
	printf("[GOMP_1.0] GOMP_loop_ordered_runtime_start@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_ordered_runtime_start(start, end, incr, istart, iend);
	
	return result;
}

/*----------------------------------------------------------------*/
bool GOMP_loop_static_start (long start, long end, long incr, long chunk_size, long *istart, long *iend){
	HOOKOMP_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_static_start, "GOMP_loop_static_start");
	printf("[GOMP_1.0] GOMP_loop_static_start@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_static_start(start, end, incr, chunk_size, istart, iend);
	
	return result;
}

/*----------------------------------------------------------------*/
bool GOMP_loop_runtime_start (long start, long end, long incr,
			 long *istart, long *iend){
	HOOKOMP_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_runtime_start, "GOMP_loop_runtime_start");
	printf("[GOMP_1.0] GOMP_loop_runtime_start@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_runtime_start(start, end, incr, istart, iend);
	
	return result;
}

/*----------------------------------------------------------------*/
bool GOMP_loop_dynamic_start (long start, long end, long incr, long chunk_size, long *istart, long *iend){
	HOOKOMP_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_dynamic_start, "GOMP_loop_dynamic_start");
	printf("[GOMP_1.0] GOMP_loop_dynamic_start@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_dynamic_start(start, end, incr, chunk_size, istart, iend);
	
	return result;
}

/*----------------------------------------------------------------*/
bool GOMP_loop_guided_start (long start, long end, long incr, long chunk_size, long *istart, long *iend){
	HOOKOMP_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_guided_start, "GOMP_loop_guided_start");
	printf("[GOMP_1.0] GOMP_loop_guided_start@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_guided_start(start, end, incr, chunk_size, istart, iend);
	
	return result;
}

/*----------------------------------------------------------------*/
bool GOMP_loop_ordered_static_start (long start, long end, long incr, long chunk_size, long *istart, long *iend){
	HOOKOMP_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ordered_static_start, "GOMP_loop_ordered_static_start");
	printf("[GOMP_1.0] GOMP_loop_ordered_static_start@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_ordered_static_start(start, end, incr, chunk_size, istart, iend);
	
	return result;
}

/*----------------------------------------------------------------*/
bool GOMP_loop_ordered_dynamic_start (long start, long end, long incr, long chunk_size, long *istart, long *iend){
	HOOKOMP_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ordered_dynamic_start, "GOMP_loop_ordered_dynamic_start");
	printf("[GOMP_1.0] GOMP_loop_ordered_dynamic_start@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_ordered_dynamic_start(start, end, incr, chunk_size, istart, iend);
	
	return result;
}

/*----------------------------------------------------------------*/
bool GOMP_loop_ordered_guided_start (long start, long end, long incr, long chunk_size, long *istart, long *iend){
	HOOKOMP_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ordered_guided_start, "GOMP_loop_ordered_guided_start");
	printf("[GOMP_1.0] GOMP_loop_ordered_guided_start@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_ordered_guided_start(start, end, incr, chunk_size, istart, iend);
	
	return result;
}

/*----------------------------------------------------------------*/
bool GOMP_loop_static_next (long *istart, long *iend){
	HOOKOMP_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_static_next, "GOMP_loop_static_next");
	printf("[GOMP_1.0] GOMP_loop_static_next@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_static_next(istart, iend);
	
	return result;
}

/*----------------------------------------------------------------*/
bool GOMP_loop_dynamic_next (long *istart, long *iend){
	HOOKOMP_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_dynamic_next, "GOMP_loop_dynamic_next");
	printf("[GOMP_1.0] GOMP_loop_dynamic_next@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_dynamic_next(istart, iend);
	
	return result;
}

/*----------------------------------------------------------------*/
bool GOMP_loop_guided_next (long *istart, long *iend){
	HOOKOMP_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_guided_next, "GOMP_loop_guided_next");
	printf("[GOMP_1.0] GOMP_loop_guided_next@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_guided_next(istart, iend);
	
	return result;
}

/*----------------------------------------------------------------*/
bool GOMP_loop_ordered_static_next (long *istart, long *iend){
	HOOKOMP_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ordered_static_next, "GOMP_loop_ordered_static_next");
	printf("[GOMP_1.0] GOMP_loop_ordered_static_next@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_ordered_static_next(istart, iend);
	
	return result;
}

/*----------------------------------------------------------------*/
bool GOMP_loop_ordered_dynamic_next (long *istart, long *iend){
	HOOKOMP_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ordered_dynamic_next, "GOMP_loop_ordered_dynamic_next");
	printf("[GOMP_1.0] GOMP_loop_ordered_dynamic_next@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_ordered_dynamic_next(istart, iend);
	
	return result;
}

/*----------------------------------------------------------------*/
bool GOMP_loop_ordered_guided_next (long *istart, long *iend){
	HOOKOMP_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ordered_guided_next, "GOMP_loop_ordered_guided_next");
	printf("[GOMP_1.0] GOMP_loop_ordered_guided_next@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_ordered_guided_next(istart, iend);
	
	return result;
}

/*----------------------------------------------------------------*/
void GOMP_parallel_loop_static_start (void (*fn) (void *), void *data,
				 unsigned num_threads, long start, long end,
				 long incr, long chunk_size){
	HOOKOMP_FUNC_NAME;

  	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_parallel_loop_static_start, "GOMP_parallel_loop_static_start");

	printf("[GOMP_1.0] GOMP_parallel_loop_static_start@GOMP_1.0.[%p]\n", (void* )fn);
	
	printf("[GOMP_1.0] lib_GOMP_parallel_loop_static_start[%p]\n", (void* )lib_GOMP_parallel_loop_static_start);

	lib_GOMP_parallel_loop_static_start(fn, data, num_threads, start, end, incr, chunk_size);
}

/*----------------------------------------------------------------*/
void GOMP_parallel_loop_dynamic_start (void (*fn) (void *), void *data,
				  unsigned num_threads, long start, long end,
				  long incr, long chunk_size){
	HOOKOMP_FUNC_NAME;

  	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_parallel_loop_dynamic_start, "GOMP_parallel_loop_dynamic_start");

	printf("[GOMP_1.0] GOMP_parallel_loop_dynamic_start@GOMP_1.0.[%p]\n", (void* )fn);
	
	printf("[GOMP_1.0] lib_GOMP_parallel_loop_dynamic_start[%p]\n", (void* )lib_GOMP_parallel_loop_dynamic_start);

	lib_GOMP_parallel_loop_dynamic_start(fn, data, num_threads, start, end, incr, chunk_size);
}

/*----------------------------------------------------------------*/
void GOMP_parallel_loop_guided_start (void (*fn) (void *), void *data,
				 unsigned num_threads, long start, long end,
				 long incr, long chunk_size){
	HOOKOMP_FUNC_NAME;

  	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_parallel_loop_guided_start, "GOMP_parallel_loop_guided_start");

	printf("[GOMP_1.0] GOMP_parallel_loop_guided_start@GOMP_1.0.[%p]\n", (void* )fn);
	
	printf("[GOMP_1.0] lib_GOMP_parallel_loop_guided_start[%p]\n", (void* )lib_GOMP_parallel_loop_guided_start);

	lib_GOMP_parallel_loop_guided_start(fn, data, num_threads, start, end, incr, chunk_size);
}

/*----------------------------------------------------------------*/
void GOMP_parallel_loop_runtime_start (void (*fn) (void *), void *data,
				  unsigned num_threads, long start, long end,
				  long incr){
	HOOKOMP_FUNC_NAME;

  	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_parallel_loop_runtime_start, "GOMP_parallel_loop_runtime_start");

	printf("[GOMP_1.0] GOMP_parallel_loop_runtime_start@GOMP_1.0.[%p]\n", (void* )fn);
	
	printf("[GOMP_1.0] lib_GOMP_parallel_loop_runtime_start[%p]\n", (void* )lib_GOMP_parallel_loop_runtime_start);

	lib_GOMP_parallel_loop_runtime_start(fn, data, num_threads, start, end, incr);	
}

/*----------------------------------------------------------------*/
void GOMP_loop_end (void){
	HOOKOMP_FUNC_NAME;

  	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_end, "GOMP_loop_end");

	printf("[GOMP_1.0] lib_GOMP_loop_end[%p]\n", (void* )lib_GOMP_loop_end);

	lib_GOMP_loop_end();
}

/*----------------------------------------------------------------*/
void GOMP_loop_end_nowait (void){
	HOOKOMP_FUNC_NAME;

  	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_end_nowait, "GOMP_loop_end_nowait");

	printf("[GOMP_1.0] lib_GOMP_loop_end_nowait[%p]\n", (void* )GOMP_loop_end_nowait);

	lib_GOMP_loop_end_nowait();
}

/*----------------------------------------------------------------*/
