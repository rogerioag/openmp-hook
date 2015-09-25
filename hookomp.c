#include "hookomp.h"

static long int executing_a_single_region = -1;

static long int thread_executing_function_next = -1;

/* ------------------------------------------------------------- */
/* Test function.                                                */
void foo(void) {
	puts("Hello, I'm a shared library.\n");
}

/* ------------------------------------------------------------- */
/* Function to intercept GOMP_parallel_start                     */
void GOMP_parallel_start (void (*fn)(void *), void *data, unsigned num_threads){
	HOOKOMP_FUNC_NAME;

  	// fprintf(stderr, "[hookomp]   Call by TablePointerFunctions.\n");
	// TablePointerFunctions[0](data);
	// TablePointerFunctions[1](data);
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_parallel_start, "GOMP_parallel_start");

	fprintf(stderr, "[GOMP_1.0] GOMP_parallel_start@GOMP_1.0.[%p]\n", (void* )fn);
	
	// fprintf(stderr, "[GOMP_1.0] lib_GOMP_parallel_start[%p]\n", (void* )lib_GOMP_parallel_start);

	lib_GOMP_parallel_start(fn, data, num_threads);

  	/* Initialize RM library. */
  	if(!RM_library_init()){
  		fprintf(stderr, "GOMP_parallel_start: error RM_library_init.\n");
  	}
}

/* ------------------------------------------------------------- */
/* Function to intercept GOMP_parallel_end                       */
void GOMP_parallel_end (void){
	HOOKOMP_FUNC_NAME;
	
	// Get Counters.
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_parallel_end, "GOMP_parallel_end");

	fprintf(stderr, "[GOMP_1.0] GOMP_parallel_end@GOMP_1.0 [%p]\n", (void* )lib_GOMP_parallel_end);

	sem_destroy(&mutex_func_next); 	/* destroy semaphore */
	
    lib_GOMP_parallel_end();
}

/*----------------------------------------------------------------*/
bool GOMP_single_start (void){
	HOOKOMP_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_single_start, "GOMP_single_start");
	
	/* This routine is called when first encountering a SINGLE construct that
   doesn't have a COPYPRIVATE clause.  Returns true if this is the thread
   that should execute the clause.
   bool GOMP_single_start (void){...} */

   fprintf(stderr, "[hookomp]: Testing single start[%lu].\n", (unsigned long int) pthread_self());

   fprintf(stderr, "[GOMP_1.0] GOMP_single_start@GOMP_1.0.\n");
   bool result = lib_GOMP_single_start();

   // Start the counters on PAPI if is the thread that should execute.
   if (result){
   		// Registry the thread id that entered in single region to match with OMP_barrier().
   		// executing_a_single_region = omp_get_thread_num();
   		executing_a_single_region = pthread_self();

   		fprintf(stderr, "[hookomp]: Thread [%lu] executing the single region.\n", (unsigned long int) executing_a_single_region);

   		// PAPI Start the counters.
   		if(RM_start_counters()){
   			fprintf(stderr, "[hookomp] GOMP_single_start: PAPI Counters Started.\n");
   		}
   		else 
   			fprintf(stderr, "Error calling RM_start_counters from GOMP_single_start.\n");
   	}	

   return result;
}

/*----------------------------------------------------------------*/
void GOMP_barrier (void) {
	HOOKOMP_FUNC_NAME;
	
	GET_RUNTIME_FUNCTION(lib_GOMP_barrier, "GOMP_barrier");

	fprintf(stderr, "[hookomp]: Thread [%lu] is executing barrier, single region was executed by [%lu].\n", (unsigned long int) pthread_self(), (unsigned long int) executing_a_single_region);

	/* Matching the thread executing barrier with thread that entered in single region. */
	// if(executing_a_single_region == omp_get_thread_num()){
	if(executing_a_single_region == (long int) pthread_self()){
		fprintf(stderr, "[hookomp]: Thread [%lu] is exiting of single region.\n", (long int) executing_a_single_region);

		if(!RM_stop_counters()){
			fprintf(stderr, "Error GOMP_barrier: RM_stop_counters.\n");
		}
		else{
			// Verificar o que a GOMP_barrier faz para ver onde a chamada aos 
			// contadores tem que ser feita.
    
    		// A decisão de migrar é aqui.
			double oi = RM_get_operational_intensity();
			fprintf(stderr, "Operational intensity: %10.2f\n", oi);

			int better_device = RM_get_better_device_to_execution();
			fprintf(stderr, "Execution is better on device [%d].\n", better_device);
		}
		
		executing_a_single_region = -1;
	}

	fprintf(stderr, "[GOMP_1.0] GOMP_barrier@GOMP_1.0.\n");
	lib_GOMP_barrier();
}

/*----------------------------------------------------------------*/
bool GOMP_loop_runtime_next (long *istart, long *iend){
	HOOKOMP_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_runtime_next, "GOMP_loop_runtime_next");
	fprintf(stderr, "[GOMP_1.0] GOMP_loop_runtime_next@GOMP_1.0.\n");

	sem_wait(&mutex_func_next);       /* down semaphore */

	if(thread_executing_function_next == -1){
		thread_executing_function_next = pthread_self();
		fprintf(stderr, "[hookomp]: Thread [%lu] is in execution.\n", (long int) thread_executing_function_next);
	}

  	sem_post(&mutex_func_next);       /* up semaphore */

	bool result = false;

	if(thread_executing_function_next == (long int) pthread_self()){
		fprintf(stderr, "[hookomp]: Antes-> GOMP_loop_runtime_next -- Tid[%lu] istart: %ld iend: %ld.\n", thread_executing_function_next, *istart, *iend);
		result = lib_GOMP_loop_runtime_next(istart, iend);
		fprintf(stderr, "[hookomp]: Depois-> GOMP_loop_runtime_next -- Tid[%lu] istart: %ld iend: %ld.\n", thread_executing_function_next, *istart, *iend);
	}	
	
	return result;
}

/*----------------------------------------------------------------*/
bool GOMP_loop_ordered_runtime_next (long *istart, long *iend){
	HOOKOMP_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ordered_runtime_next, "GOMP_loop_ordered_runtime_next");
	fprintf(stderr, "[GOMP_1.0] GOMP_loop_ordered_runtime_next@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_ordered_runtime_next(istart, iend);
	
	return result;
}

/*----------------------------------------------------------------*/
bool GOMP_loop_ordered_runtime_start (long start, long end, long incr, long *istart, long *iend){
	HOOKOMP_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ordered_runtime_start, "GOMP_loop_ordered_runtime_start");
	fprintf(stderr, "[GOMP_1.0] GOMP_loop_ordered_runtime_start@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_ordered_runtime_start(start, end, incr, istart, iend);
	
	return result;
}

/*----------------------------------------------------------------*/
bool GOMP_loop_static_start (long start, long end, long incr, long chunk_size, long *istart, long *iend){
	HOOKOMP_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_static_start, "GOMP_loop_static_start");
	fprintf(stderr, "[GOMP_1.0] GOMP_loop_static_start@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_static_start(start, end, incr, chunk_size, istart, iend);
	
	return result;
}

/*----------------------------------------------------------------*/
bool GOMP_loop_runtime_start (long start, long end, long incr,
			 long *istart, long *iend){
	HOOKOMP_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_runtime_start, "GOMP_loop_runtime_start");
	fprintf(stderr, "[GOMP_1.0] GOMP_loop_runtime_start@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_runtime_start(start, end, incr, istart, iend);
	
	return result;
}

/*----------------------------------------------------------------*/
bool GOMP_loop_dynamic_start (long start, long end, long incr, long chunk_size, long *istart, long *iend){
	HOOKOMP_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_dynamic_start, "GOMP_loop_dynamic_start");
	fprintf(stderr, "[GOMP_1.0] GOMP_loop_dynamic_start@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_dynamic_start(start, end, incr, chunk_size, istart, iend);
	
	return result;
}

/*----------------------------------------------------------------*/
bool GOMP_loop_guided_start (long start, long end, long incr, long chunk_size, long *istart, long *iend){
	HOOKOMP_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_guided_start, "GOMP_loop_guided_start");
	fprintf(stderr, "[GOMP_1.0] GOMP_loop_guided_start@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_guided_start(start, end, incr, chunk_size, istart, iend);
	
	return result;
}

/*----------------------------------------------------------------*/
bool GOMP_loop_ordered_static_start (long start, long end, long incr, long chunk_size, long *istart, long *iend){
	HOOKOMP_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ordered_static_start, "GOMP_loop_ordered_static_start");
	fprintf(stderr, "[GOMP_1.0] GOMP_loop_ordered_static_start@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_ordered_static_start(start, end, incr, chunk_size, istart, iend);
	
	return result;
}

/*----------------------------------------------------------------*/
bool GOMP_loop_ordered_dynamic_start (long start, long end, long incr, long chunk_size, long *istart, long *iend){
	HOOKOMP_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ordered_dynamic_start, "GOMP_loop_ordered_dynamic_start");
	fprintf(stderr, "[GOMP_1.0] GOMP_loop_ordered_dynamic_start@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_ordered_dynamic_start(start, end, incr, chunk_size, istart, iend);
	
	return result;
}

/*----------------------------------------------------------------*/
bool GOMP_loop_ordered_guided_start (long start, long end, long incr, long chunk_size, long *istart, long *iend){
	HOOKOMP_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ordered_guided_start, "GOMP_loop_ordered_guided_start");
	fprintf(stderr, "[GOMP_1.0] GOMP_loop_ordered_guided_start@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_ordered_guided_start(start, end, incr, chunk_size, istart, iend);
	
	return result;
}

/*----------------------------------------------------------------*/
bool GOMP_loop_static_next (long *istart, long *iend){
	HOOKOMP_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_static_next, "GOMP_loop_static_next");
	fprintf(stderr, "[GOMP_1.0] GOMP_loop_static_next@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_static_next(istart, iend);
	
	return result;
}

/*----------------------------------------------------------------*/
bool GOMP_loop_dynamic_next (long *istart, long *iend){
	HOOKOMP_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_dynamic_next, "GOMP_loop_dynamic_next");
	fprintf(stderr, "[GOMP_1.0] GOMP_loop_dynamic_next@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_dynamic_next(istart, iend);
	
	return result;
}

/*----------------------------------------------------------------*/
bool GOMP_loop_guided_next (long *istart, long *iend){
	HOOKOMP_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_guided_next, "GOMP_loop_guided_next");
	fprintf(stderr, "[GOMP_1.0] GOMP_loop_guided_next@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_guided_next(istart, iend);
	
	return result;
}

/*----------------------------------------------------------------*/
bool GOMP_loop_ordered_static_next (long *istart, long *iend){
	HOOKOMP_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ordered_static_next, "GOMP_loop_ordered_static_next");
	fprintf(stderr, "[GOMP_1.0] GOMP_loop_ordered_static_next@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_ordered_static_next(istart, iend);
	
	return result;
}

/*----------------------------------------------------------------*/
bool GOMP_loop_ordered_dynamic_next (long *istart, long *iend){
	HOOKOMP_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ordered_dynamic_next, "GOMP_loop_ordered_dynamic_next");
	fprintf(stderr, "[GOMP_1.0] GOMP_loop_ordered_dynamic_next@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_ordered_dynamic_next(istart, iend);
	
	return result;
}

/*----------------------------------------------------------------*/
bool GOMP_loop_ordered_guided_next (long *istart, long *iend){
	HOOKOMP_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ordered_guided_next, "GOMP_loop_ordered_guided_next");
	fprintf(stderr, "[GOMP_1.0] GOMP_loop_ordered_guided_next@GOMP_1.0.\n");
	
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

	fprintf(stderr, "[GOMP_1.0] GOMP_parallel_loop_static_start@GOMP_1.0.[%p]\n", (void* )fn);
	
	fprintf(stderr, "[GOMP_1.0] lib_GOMP_parallel_loop_static_start[%p]\n", (void* )lib_GOMP_parallel_loop_static_start);

	lib_GOMP_parallel_loop_static_start(fn, data, num_threads, start, end, incr, chunk_size);
}

/*----------------------------------------------------------------*/
void GOMP_parallel_loop_dynamic_start (void (*fn) (void *), void *data,
				  unsigned num_threads, long start, long end,
				  long incr, long chunk_size){
	HOOKOMP_FUNC_NAME;

  	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_parallel_loop_dynamic_start, "GOMP_parallel_loop_dynamic_start");

	fprintf(stderr, "[GOMP_1.0] GOMP_parallel_loop_dynamic_start@GOMP_1.0.[%p]\n", (void* )fn);
	
	fprintf(stderr, "[GOMP_1.0] lib_GOMP_parallel_loop_dynamic_start[%p]\n", (void* )lib_GOMP_parallel_loop_dynamic_start);

	lib_GOMP_parallel_loop_dynamic_start(fn, data, num_threads, start, end, incr, chunk_size);
}

/*----------------------------------------------------------------*/
void GOMP_parallel_loop_guided_start (void (*fn) (void *), void *data,
				 unsigned num_threads, long start, long end,
				 long incr, long chunk_size){
	HOOKOMP_FUNC_NAME;

  	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_parallel_loop_guided_start, "GOMP_parallel_loop_guided_start");

	fprintf(stderr, "[GOMP_1.0] GOMP_parallel_loop_guided_start@GOMP_1.0.[%p]\n", (void* )fn);
	
	fprintf(stderr, "[GOMP_1.0] lib_GOMP_parallel_loop_guided_start[%p]\n", (void* )lib_GOMP_parallel_loop_guided_start);

	lib_GOMP_parallel_loop_guided_start(fn, data, num_threads, start, end, incr, chunk_size);
}

/*----------------------------------------------------------------*/
void GOMP_parallel_loop_runtime_start (void (*fn) (void *), void *data,
				  unsigned num_threads, long start, long end,
				  long incr){
	HOOKOMP_FUNC_NAME;

  	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_parallel_loop_runtime_start, "GOMP_parallel_loop_runtime_start");

	fprintf(stderr, "[GOMP_1.0] GOMP_parallel_loop_runtime_start@GOMP_1.0.[%p]\n", (void* )fn);
	
	fprintf(stderr, "[GOMP_1.0] lib_GOMP_parallel_loop_runtime_start[%p]\n", (void* )lib_GOMP_parallel_loop_runtime_start);

	sem_init(&mutex_func_next, 0, 1);

	lib_GOMP_parallel_loop_runtime_start(fn, data, num_threads, start, end, incr);	
}

/*----------------------------------------------------------------*/
void GOMP_loop_end (void){
	HOOKOMP_FUNC_NAME;

  	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_end, "GOMP_loop_end");

	fprintf(stderr, "[GOMP_1.0] lib_GOMP_loop_end[%p]\n", (void* )lib_GOMP_loop_end);

	lib_GOMP_loop_end();
}

/*----------------------------------------------------------------*/
void GOMP_loop_end_nowait (void){
	HOOKOMP_FUNC_NAME;

  	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_end_nowait, "GOMP_loop_end_nowait");

	fprintf(stderr, "[GOMP_1.0] lib_GOMP_loop_end_nowait[%p]\n", (void* )GOMP_loop_end_nowait);

	if(thread_executing_function_next == (long int) pthread_self()){
		fprintf(stderr, "[hookomp]: Thread [%lu] is in execution.\n", (long int) thread_executing_function_next);
		thread_executing_function_next = -1;
	}

	lib_GOMP_loop_end_nowait();
}

/*----------------------------------------------------------------*/
