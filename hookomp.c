#include "hookomp.h"

static long int executing_a_single_region = -1;

/* Registry the thread which can execute the next function. */
static long int thread_executing_function_next = -1;

/* Interval control for calculate the portion of code to execute. 10% */
static long int loop_iterations_start = 0;
static long int loop_iterations_end = 0;
/* To acumulate the iterations executed by thread to calculate the percentual of executed code. */
static long int executed_loop_iterations = 0;

/* 10% of code. */
static long int percentual_of_code = 10;

static long int number_of_threads_in_team = 0;

static bool is_executed_measures_section = false;

static bool started_measuring = false;

struct gomp_thread;
struct gomp_team;
struct gomp_work_share;

extern struct gomp_thread* gomp_thread();
extern struct gomp_team;
extern struct gomp_work_share;

/* ------------------------------------------------------------- */
/* Test function.                                                */
void foo(void) {
	puts("Hello, I'm a shared library.\n");
}

/* ------------------------------------------------------------- */
/* Function to execute up num_threads -1 of team.*/
void release_all_team_threads(void){
	HOOKOMP_FUNC_NAME;

	fprintf(stderr, "[hookomp]: release_all_team_threads num_threads: %ld.\n", number_of_threads_in_team);
	for (int i = 0; i < number_of_threads_in_team; ++i) {
		sem_post(&sem_blocks_other_team_threads);
	}
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

	sem_destroy(&mutex_registry_thread_in_func_next); 	/* destroy semaphore */

	sem_destroy(&sem_blocks_other_team_threads);
	
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

	fprintf(stderr, "[hookomp]: Thread [%lu] is calling %s.\n", (long int) pthread_self(), __FUNCTION__);

	struct gomp_thread *thr = gomp_thread ();
  	fprintf(stderr, "[hookomp]: Scheduling: %d  %s.\n", thr->ts.work_share->sched);

	/* Registry the thread which will be execute alone. down semaphore. */
	sem_wait(&mutex_registry_thread_in_func_next);

	if(thread_executing_function_next == -1){
		thread_executing_function_next = pthread_self();
		fprintf(stderr, "[hookomp]: Thread [%lu] is entering in controled execution.\n", (long int) thread_executing_function_next);
	}
	/* up semaphore. */
  	sem_post(&mutex_registry_thread_in_func_next);

	bool result = false;
	int total_of_iterations = 0;

	/* Verify if the thread is the thread executing. */
	if(thread_executing_function_next == (long int) pthread_self()){
		total_of_iterations = (loop_iterations_end - loop_iterations_start);

		if(executed_loop_iterations < (total_of_iterations / percentual_of_code)){
			fprintf(stderr, "[hookomp]: Antes-> GOMP_loop_runtime_next -- Tid[%lu] istart: %ld iend: %ld.\n", thread_executing_function_next, *istart, *iend);
			result = lib_GOMP_loop_runtime_next(istart, iend);
			fprintf(stderr, "[hookomp]: Depois-> GOMP_loop_runtime_next -- Tid[%lu] istart: %ld iend: %ld.\n", thread_executing_function_next, *istart, *iend);
			/* Update the number of iterations executed by this thread. */
			fprintf(stderr, "[hookomp]: Antes-> GOMP_loop_runtime_next -- Tid[%lu] executed iterations: %ld.\n", thread_executing_function_next, executed_loop_iterations);
			executed_loop_iterations += (*iend - *istart);
			fprintf(stderr, "[hookomp]: Depois-> GOMP_loop_runtime_next -- Tid[%lu] executed iterations: %ld.\n", thread_executing_function_next, executed_loop_iterations);

			/* PAPI Start the counters. */
			if(!started_measuring){
				if(RM_start_counters()){
   					fprintf(stderr, "[hookomp] GOMP_single_start: PAPI Counters Started.\n");
   				}
   				else {
   					fprintf(stderr, "Error calling RM_start_counters from GOMP_single_start.\n");
   				}
   				started_measuring = true;
   			}
		}
		else{
			fprintf(stderr, "[hookomp]: GOMP_loop_runtime_next -- Tid[%lu] executed %ld iterations of %ld.\n", thread_executing_function_next, executed_loop_iterations, (loop_iterations_end - loop_iterations_start));
		}
	}
	else{
		/* If it is executing in a section to measurements, the threads will be blocked. */		
		if (is_executed_measures_section){
			/* Other team threads will be blocked. */
			fprintf(stderr, "[hookomp]: Thread [%lu] will be blocked.\n", (long int) pthread_self());
			sem_wait(&sem_blocks_other_team_threads);	
		}
		result = lib_GOMP_loop_runtime_next(istart, iend);
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

	/* Initialization of semaphores of control. */
	sem_init(&mutex_registry_thread_in_func_next, 0, 1);

	/* Initialization of block to other team threads. 1 thread will be executing. 
	   The initialization with 0 is proposital to block other threads.
	*/
	sem_init(&sem_blocks_other_team_threads, 0, 0);

	/* Initialization of control iterations variables. */
	loop_iterations_start = start;
	loop_iterations_end = end;
	executed_loop_iterations = 0;
	number_of_threads_in_team = num_threads;

	/* Initialization of thread and measures section. */
	thread_executing_function_next = -1;
	is_executed_measures_section = true;
	started_measuring = false;

	lib_GOMP_parallel_loop_runtime_start(fn, data, num_threads, start, end, incr);
	
	/* Initialize RM library. */
  	if(!RM_library_init()){
  		fprintf(stderr, "GOMP_parallel_start: error RM_library_init.\n");
  	}
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

	fprintf(stderr, "[hookomp]: Thread [%lu] is calling %s.\n", (long int) pthread_self(), __FUNCTION__);

	if(thread_executing_function_next == (long int) pthread_self()){
		fprintf(stderr, "[hookomp]: Thread [%lu] is finishing the execution.\n", (long int) thread_executing_function_next);

		// Get counters and decide about the migration.
		fprintf(stderr, "[hookomp]: Thread [%lu] is getting the performance counters to decide.\n", (long int) pthread_self());

		if(!RM_stop_counters()){
			fprintf(stderr, "Error GOMP_barrier: RM_stop_counters.\n");
		}
		else{
    
    		// A decisão de migrar é aqui.
			double oi = RM_get_operational_intensity();
			fprintf(stderr, "Operational intensity: %10.2f\n", oi);

			int better_device = RM_get_better_device_to_execution();
			fprintf(stderr, "Execution is better on device [%d].\n", better_device);

			bool decide_migration = true;

			if(decide_migration){
				/* Launch apropriated function. */
				fprintf(stderr, "Launching apropriated function on device: %d.\n", better_device);

				/* Set work share to final. No more iterations to execute. */
			}
		}

		/* Release all blocked team threads. */
		release_all_team_threads();

		executed_loop_iterations = 0;

		/* Mark that is no more in section of measurements. */
		is_executed_measures_section = false;
	}

	lib_GOMP_loop_end_nowait();
}

/*----------------------------------------------------------------*/
