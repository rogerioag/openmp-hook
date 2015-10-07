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

static bool decided_by_offloading = false;

// extern struct gomp_team gomp_team;
// extern struct gomp_work_share gomp_work_share;

// extern struct gomp_thread* gomp_thread();

/* ------------------------------------------------------------- */
/* Test function.                                                */
void foo(void) {
	puts("Hello, I'm a shared library.\n");
}

/* ------------------------------------------------------------- */
/* Function to execute up semaphore num_threads -1 to wake up the threads of team.*/
void release_all_team_threads(void){
	PRINT_FUNC_NAME;

	TRACE("[hookomp]: release_all_team_threads num_threads: %ld.\n", number_of_threads_in_team);
	for (int i = 0; i < number_of_threads_in_team; ++i) {
		sem_post(&sem_blocks_other_team_threads);
	}
}

/* ------------------------------------------------------------- */
void HOOKOMP_initialization(long int start, long int end, long int num_threads){
	PRINT_FUNC_NAME;

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

	decided_by_offloading = false;

	/* Initialize RM library. */
  	if(!RM_library_init()){
  		TRACE("Error calling RM_library_init in %s.\n", __FUNCTION__);
  	}
}

/* ------------------------------------------------------------- */
/* Generic function to get next chunk. */
bool HOOKOMP_generic_next (long *istart, long *iend, bool (*fn_next_chunk) (long *, long *)){
	PRINT_FUNC_NAME;
	bool result = false;
	TRACE("[hookomp]: Thread [%lu] is calling %s.\n", (long int) pthread_self(), __FUNCTION__);

	/* Registry the thread which will be execute alone. down semaphore. */
	sem_wait(&mutex_registry_thread_in_func_next);

	if(thread_executing_function_next == -1){
		thread_executing_function_next = pthread_self();
		TRACE("[hookomp]: Thread [%lu] is entering in controled execution.\n", (long int) thread_executing_function_next);
	}
	/* up semaphore. */
  	sem_post(&mutex_registry_thread_in_func_next);

	int total_of_iterations = 0;

	/* Verify if the thread is the thread executing. */
	if(thread_executing_function_next == (long int) pthread_self()){
		total_of_iterations = (loop_iterations_end - loop_iterations_start);

		if(executed_loop_iterations < (total_of_iterations / percentual_of_code)){
			TRACE("[hookomp]: [Before]-> GOMP_loop_runtime_next -- Tid[%lu] istart: %ld iend: %ld.\n", thread_executing_function_next, *istart, *iend);
			result = fn_next_chunk(istart, iend);
			TRACE("[hookomp]: [After]-> GOMP_loop_runtime_next -- Tid[%lu] istart: %ld iend: %ld.\n", thread_executing_function_next, *istart, *iend);
			/* Update the number of iterations executed by this thread. */
			TRACE("[hookomp]: [Before]-> GOMP_loop_runtime_next -- Tid[%lu] executed iterations: %ld.\n", thread_executing_function_next, executed_loop_iterations);
			executed_loop_iterations += (*iend - *istart);
			TRACE("[hookomp]: [After]-> GOMP_loop_runtime_next -- Tid[%lu] executed iterations: %ld.\n", thread_executing_function_next, executed_loop_iterations);

			/* PAPI Start the counters. */
			if(!started_measuring){
				if(RM_start_counters()){
   					TRACE("[hookomp] GOMP_single_start: PAPI Counters Started.\n");
   				}
   				else {
   					TRACE("Error calling RM_start_counters from GOMP_single_start.\n");
   				}
   				started_measuring = true;
   			}
		}
		else{
			TRACE("[hookomp]: GOMP_loop_runtime_next -- Tid[%lu] executed %ld iterations of %ld.\n", thread_executing_function_next, executed_loop_iterations, (loop_iterations_end - loop_iterations_start));
		}
	}
	else{
		/* If it is executing in a section to measurements, the threads will be blocked. */		
		if (is_executed_measures_section){
			/* Other team threads will be blocked. */
			TRACE("[hookomp]: Thread [%lu] will be blocked.\n", (long int) pthread_self());
			sem_wait(&sem_blocks_other_team_threads);	
		}
		
		// result = lib_GOMP_loop_runtime_next(istart, iend);
		/* if decided by offloading, no more work to do, so return false. */
		if(!decided_by_offloading){
			result = fn_next_chunk(istart, iend);	
		}
		else{
			result = false;
		}
	}
	return result;
}

/* ------------------------------------------------------------- */
void HOOKOMP_loop_end_nowait(void){
	if(thread_executing_function_next == (long int) pthread_self()){
		TRACE("[hookomp]: Thread [%lu] is finishing the execution.\n", (long int) thread_executing_function_next);

		// Get counters and decide about the migration.
		TRACE("[hookomp]: Thread [%lu] is getting the performance counters to decide.\n", (long int) pthread_self());

		if(!RM_stop_counters()){
			TRACE("Error GOMP_barrier: RM_stop_counters.\n");
		}
		else{
    
    		// A decisão de migrar é aqui.
			double oi = RM_get_operational_intensity();
			TRACE("Operational intensity: %10.2f\n", oi);

			int better_device = RM_get_better_device_to_execution();
			TRACE("Execution is better on device [%d].\n", better_device);

			if((decided_by_offloading = RM_decision_about_offloading()) != 0){
				/* Launch apropriated function. */
				TRACE("Launching apropriated function on device: %d.\n", better_device);

				TablePointerFunctions[better_device]();

				/* Set work share to final. No more iterations to execute. */
			}
		}

		/* Release all blocked team threads. */
		release_all_team_threads();

		executed_loop_iterations = 0;

		/* Mark that is no more in section of measurements. */
		is_executed_measures_section = false;
	}
}

/* ------------------------------------------------------------- */
void HOOKOMP_end(){

	sem_destroy(&mutex_registry_thread_in_func_next); 	/* destroy semaphore */

	sem_destroy(&sem_blocks_other_team_threads);
}
/* ------------------------------------------------------------- */
/* barrier.c                                                     */
/* ------------------------------------------------------------- */
void GOMP_barrier (void) {
	PRINT_FUNC_NAME;
	
	GET_RUNTIME_FUNCTION(lib_GOMP_barrier, "GOMP_barrier");

	TRACE("[hookomp]: Thread [%lu] is executing barrier, single region was executed by [%lu].\n", (unsigned long int) pthread_self(), (unsigned long int) executing_a_single_region);

	/* Matching the thread executing barrier with thread that entered in single region. */
	// if(executing_a_single_region == (long int) pthread_self()){
	// 	TRACE("[hookomp]: Thread [%lu] is exiting of single region.\n", (long int) executing_a_single_region);

	// 	if(!RM_stop_counters()){
	// 		TRACE("Error GOMP_barrier: RM_stop_counters.\n");
	// 	}
	// 	else{
	// 		// Verificar o que a GOMP_barrier faz para ver onde a chamada aos 
	// 		// contadores tem que ser feita.
    
 	//    	// A decisão de migrar é aqui.
	// 		// double oi = RM_get_operational_intensity();
	// 		// TRACE("Operational intensity: %10.2f\n", oi);

	// 		// int better_device = RM_get_better_device_to_execution();
	// 		// TRACE("Execution is better on device [%d].\n", better_device);
	// 	}
		
	// 	executing_a_single_region = -1;
	// }

	TRACE("[GOMP_1.0] GOMP_barrier@GOMP_1.0.\n");
	lib_GOMP_barrier();
}

/* ------------------------------------------------------------- */
bool GOMP_barrier_cancel (void){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_barrier_cancel, "GOMP_barrier_cancel");
	TRACE("[GOMP_1.0] GOMP_barrier_cancel@GOMP_1.0.\n");
	
	bool result = lib_GOMP_barrier_cancel();
	
	return result;
}

/* ------------------------------------------------------------- */
/* critical.c 													 */
/* ------------------------------------------------------------- */
void GOMP_critical_start (void){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_critical_start, "GOMP_critical_start");
	TRACE("[GOMP_1.0] GOMP_critical_start@GOMP_1.0.\n");
	
	lib_GOMP_critical_start();
}

/* ------------------------------------------------------------- */
void GOMP_critical_end (void){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_critical_end, "GOMP_critical_end");
	TRACE("[GOMP_1.0] GOMP_critical_end@GOMP_1.0.\n");
	
	lib_GOMP_critical_end();
}

/* ------------------------------------------------------------- */
void GOMP_critical_name_start (void **pptr){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_critical_name_start, "GOMP_critical_name_start");
	TRACE("[GOMP_1.0] GOMP_critical_name_start@GOMP_1.0.\n");
	
	lib_GOMP_critical_name_start(pptr);
}

/* ------------------------------------------------------------- */
void GOMP_critical_name_end (void **pptr){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_critical_name_end, "GOMP_critical_name_end");
	TRACE("[GOMP_1.0] GOMP_critical_name_end@GOMP_1.0.\n");
	
	lib_GOMP_critical_name_end(pptr);
}

/* ------------------------------------------------------------- */
void GOMP_atomic_start (void){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_atomic_start, "GOMP_atomic_start");
	TRACE("[GOMP_1.0] GOMP_atomic_start@GOMP_1.0.\n");
	
	lib_GOMP_atomic_start();
}

/* ------------------------------------------------------------- */
void GOMP_atomic_end (void){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_atomic_end, "GOMP_atomic_end");
	TRACE("[GOMP_1.0] GOMP_atomic_end@GOMP_1.0.\n");
	
	lib_GOMP_atomic_end();
}

/* ------------------------------------------------------------- */
/* loop.c                                                        */
/* ------------------------------------------------------------- */

bool GOMP_loop_static_start (long start, long end, long incr, long chunk_size,
			long *istart, long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_static_start, "GOMP_loop_static_start");
	TRACE("[GOMP_1.0] GOMP_loop_static_start@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_static_start(start, end, incr, chunk_size, istart, iend);
	
	return result;
}

/* ------------------------------------------------------------- */
bool GOMP_loop_dynamic_start (long start, long end, long incr, long chunk_size,
			 long *istart, long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_dynamic_start, "GOMP_loop_dynamic_start");
	TRACE("[GOMP_1.0] GOMP_loop_dynamic_start@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_dynamic_start(start, end, incr, chunk_size, istart, iend);
	
	return result;
}

/* ------------------------------------------------------------- */
bool GOMP_loop_guided_start (long start, long end, long incr, long chunk_size,
			long *istart, long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_guided_start, "GOMP_loop_guided_start");
	TRACE("[GOMP_1.0] GOMP_loop_guided_start@GOMP_1.0.\n");

	bool result = lib_GOMP_loop_guided_start(start, end, incr, chunk_size, istart, iend);

	// Initializations.
	HOOKOMP_initialization(start, end, omp_get_num_threads());
	
	return result;
}
/* ------------------------------------------------------------- */
bool GOMP_loop_runtime_start (long start, long end, long incr,
			 long *istart, long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_runtime_start, "GOMP_loop_runtime_start");
	TRACE("[GOMP_1.0] GOMP_loop_runtime_start@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_runtime_start(start, end, incr, istart, iend);
	
	return result;
}

/* ------------------------------------------------------------- */
bool GOMP_loop_ordered_static_start (long start, long end, long incr,
				long chunk_size, long *istart, long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ordered_static_start, "GOMP_loop_ordered_static_start");
	TRACE("[GOMP_1.0] GOMP_loop_ordered_static_start@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_ordered_static_start(start, end, incr, chunk_size, istart, iend);
	
	return result;
}

/* ------------------------------------------------------------- */
bool GOMP_loop_ordered_dynamic_start (long start, long end, long incr,
				 long chunk_size, long *istart, long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ordered_dynamic_start, "GOMP_loop_ordered_dynamic_start");
	TRACE("[GOMP_1.0] GOMP_loop_ordered_dynamic_start@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_ordered_dynamic_start(start, end, incr, chunk_size, istart, iend);
	
	return result;
}

/* ------------------------------------------------------------- */
bool GOMP_loop_ordered_guided_start (long start, long end, long incr,
				long chunk_size, long *istart, long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ordered_guided_start, "GOMP_loop_ordered_guided_start");
	TRACE("[GOMP_1.0] GOMP_loop_ordered_guided_start@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_ordered_guided_start(start, end, incr, chunk_size, istart, iend);
	
	return result;
}

/* ------------------------------------------------------------- */
bool GOMP_loop_ordered_runtime_start (long start, long end, long incr,
				 long *istart, long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ordered_runtime_start, "GOMP_loop_ordered_runtime_start");
	TRACE("[GOMP_1.0] GOMP_loop_ordered_runtime_start@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_ordered_runtime_start(start, end, incr, istart, iend);
	
	return result;
}

/* ------------------------------------------------------------- */
bool GOMP_loop_static_next (long *istart, long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_static_next, "GOMP_loop_static_next");
	TRACE("[GOMP_1.0] GOMP_loop_static_next@GOMP_1.0.\n");
	
	// bool result = lib_GOMP_loop_static_next(istart, iend);
	bool result = HOOKOMP_generic_next(istart, iend, lib_GOMP_loop_static_next);
	
	return result;
}

/* ------------------------------------------------------------- */
bool GOMP_loop_dynamic_next (long *istart, long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_dynamic_next, "GOMP_loop_dynamic_next");
	TRACE("[GOMP_1.0] GOMP_loop_dynamic_next@GOMP_1.0.\n");
	
	// bool result = lib_GOMP_loop_dynamic_next(istart, iend);
	bool result = HOOKOMP_generic_next(istart, iend, lib_GOMP_loop_dynamic_next);
	
	return result;
}

/* ------------------------------------------------------------- */
bool GOMP_loop_guided_next (long *istart, long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_guided_next, "GOMP_loop_guided_next");
	TRACE("[GOMP_1.0] GOMP_loop_guided_next@GOMP_1.0.\n");
	
	// bool result = lib_GOMP_loop_guided_next(istart, iend);
	bool result = HOOKOMP_generic_next(istart, iend, lib_GOMP_loop_guided_next);
	
	return result;
}

/* ------------------------------------------------------------- */
bool GOMP_loop_runtime_next (long *istart, long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_runtime_next, "GOMP_loop_runtime_next");
	TRACE("[GOMP_1.0] GOMP_loop_runtime_next@GOMP_1.0.\n");

	TRACE("[hookomp]: Thread [%lu] is calling %s.\n", (long int) pthread_self(), __FUNCTION__);

	bool result = HOOKOMP_generic_next(istart, iend, lib_GOMP_loop_runtime_next);

	return result;

	// // struct gomp_thread *thr = gomp_thread ();

	// // struct gomp_team *team = thr->ts.team;

	// // struct gomp_work_share *ws = thr->ts.work_share;

 //  	// TRACE("[hookomp]: Scheduling: %d.\n", ws->sched);

	// /* Registry the thread which will be execute alone. down semaphore. */
	// sem_wait(&mutex_registry_thread_in_func_next);

	// if(thread_executing_function_next == -1){
	// 	thread_executing_function_next = pthread_self();
	// 	TRACE("[hookomp]: Thread [%lu] is entering in controled execution.\n", (long int) thread_executing_function_next);
	// }
	// /* up semaphore. */
 //  	sem_post(&mutex_registry_thread_in_func_next);

	// bool result = false;
	// int total_of_iterations = 0;

	// /* Verify if the thread is the thread executing. */
	// if(thread_executing_function_next == (long int) pthread_self()){
	// 	total_of_iterations = (loop_iterations_end - loop_iterations_start);

	// 	if(executed_loop_iterations < (total_of_iterations / percentual_of_code)){
	// 		TRACE("[hookomp]: [Before]-> GOMP_loop_runtime_next -- Tid[%lu] istart: %ld iend: %ld.\n", thread_executing_function_next, *istart, *iend);
	// 		result = lib_GOMP_loop_runtime_next(istart, iend);
	// 		TRACE("[hookomp]: [After]-> GOMP_loop_runtime_next -- Tid[%lu] istart: %ld iend: %ld.\n", thread_executing_function_next, *istart, *iend);
	// 		/* Update the number of iterations executed by this thread. */
	// 		TRACE("[hookomp]: [Before]-> GOMP_loop_runtime_next -- Tid[%lu] executed iterations: %ld.\n", thread_executing_function_next, executed_loop_iterations);
	// 		executed_loop_iterations += (*iend - *istart);
	// 		TRACE("[hookomp]: [After]-> GOMP_loop_runtime_next -- Tid[%lu] executed iterations: %ld.\n", thread_executing_function_next, executed_loop_iterations);

	// 		/* PAPI Start the counters. */
	// 		if(!started_measuring){
	// 			if(RM_start_counters()){
 //   					TRACE("[hookomp] GOMP_single_start: PAPI Counters Started.\n");
 //   				}
 //   				else {
 //   					TRACE("Error calling RM_start_counters from GOMP_single_start.\n");
 //   				}
 //   				started_measuring = true;
 //   			}
	// 	}
	// 	else{
	// 		TRACE("[hookomp]: GOMP_loop_runtime_next -- Tid[%lu] executed %ld iterations of %ld.\n", thread_executing_function_next, executed_loop_iterations, (loop_iterations_end - loop_iterations_start));
	// 	}
	// }
	// else{
	// 	/* If it is executing in a section to measurements, the threads will be blocked. */		
	// 	if (is_executed_measures_section){
	// 		/* Other team threads will be blocked. */
	// 		TRACE("[hookomp]: Thread [%lu] will be blocked.\n", (long int) pthread_self());
	// 		sem_wait(&sem_blocks_other_team_threads);	
	// 	}
		
	// 	// result = lib_GOMP_loop_runtime_next(istart, iend);
	// 	/* if decided by offloading, no more work to do, so return false. */
	// 	if(!decided_by_offloading){
	// 		result = lib_GOMP_loop_runtime_next(istart, iend);	
	// 	}
	// 	else{
	// 		result = false;
	// 	}
	// }
	// return result;
}

/* ------------------------------------------------------------- */
bool GOMP_loop_ordered_static_next (long *istart, long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ordered_static_next, "GOMP_loop_ordered_static_next");
	TRACE("[GOMP_1.0] GOMP_loop_ordered_static_next@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_ordered_static_next(istart, iend);
	
	return result;
}

/* ------------------------------------------------------------- */
bool GOMP_loop_ordered_dynamic_next (long *istart, long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ordered_dynamic_next, "GOMP_loop_ordered_dynamic_next");
	TRACE("[GOMP_1.0] GOMP_loop_ordered_dynamic_next@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_ordered_dynamic_next(istart, iend);
	
	return result;
}

/* ------------------------------------------------------------- */
bool GOMP_loop_ordered_guided_next (long *istart, long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ordered_guided_next, "GOMP_loop_ordered_guided_next");
	TRACE("[GOMP_1.0] GOMP_loop_ordered_guided_next@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_ordered_guided_next(istart, iend);
	
	return result;
}

/* ------------------------------------------------------------- */
bool GOMP_loop_ordered_runtime_next (long *istart, long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ordered_runtime_next, "GOMP_loop_ordered_runtime_next");
	TRACE("[GOMP_1.0] GOMP_loop_ordered_runtime_next@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_ordered_runtime_next(istart, iend);
	
	return result;
}

/* ------------------------------------------------------------- */
void GOMP_parallel_loop_static_start (void (*fn) (void *), void *data,
				 unsigned num_threads, long start, long end,
				 long incr, long chunk_size){
	PRINT_FUNC_NAME;

  	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_parallel_loop_static_start, "GOMP_parallel_loop_static_start");

	TRACE("[GOMP_1.0] GOMP_parallel_loop_static_start@GOMP_1.0.[%p]\n", (void* )fn);
	
	TRACE("[GOMP_1.0] lib_GOMP_parallel_loop_static_start[%p]\n", (void* )lib_GOMP_parallel_loop_static_start);

	lib_GOMP_parallel_loop_static_start(fn, data, num_threads, start, end, incr, chunk_size);
}

/* ------------------------------------------------------------- */
void GOMP_parallel_loop_dynamic_start (void (*fn) (void *), void *data,
				  unsigned num_threads, long start, long end,
				  long incr, long chunk_size){
	PRINT_FUNC_NAME;

  	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_parallel_loop_dynamic_start, "GOMP_parallel_loop_dynamic_start");

	TRACE("[GOMP_1.0] GOMP_parallel_loop_dynamic_start@GOMP_1.0.[%p]\n", (void* )fn);
	
	TRACE("[GOMP_1.0] lib_GOMP_parallel_loop_dynamic_start[%p]\n", (void* )lib_GOMP_parallel_loop_dynamic_start);

	lib_GOMP_parallel_loop_dynamic_start(fn, data, num_threads, start, end, incr, chunk_size);
}

/* ------------------------------------------------------------- */
void GOMP_parallel_loop_guided_start (void (*fn) (void *), void *data,
				 unsigned num_threads, long start, long end,
				 long incr, long chunk_size){
	PRINT_FUNC_NAME;

  	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_parallel_loop_guided_start, "GOMP_parallel_loop_guided_start");

	TRACE("[GOMP_1.0] GOMP_parallel_loop_guided_start@GOMP_1.0.[%p]\n", (void* )fn);
	
	TRACE("[GOMP_1.0] lib_GOMP_parallel_loop_guided_start[%p]\n", (void* )lib_GOMP_parallel_loop_guided_start);

	lib_GOMP_parallel_loop_guided_start(fn, data, num_threads, start, end, incr, chunk_size);
}

/* ------------------------------------------------------------- */
void GOMP_parallel_loop_runtime_start (void (*fn) (void *), void *data,
				  unsigned num_threads, long start, long end,
				  long incr){
	PRINT_FUNC_NAME;

  	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_parallel_loop_runtime_start, "GOMP_parallel_loop_runtime_start");

	TRACE("[GOMP_1.0] GOMP_parallel_loop_runtime_start@GOMP_1.0.[%p]\n", (void* )fn);
	
	TRACE("[GOMP_1.0] lib_GOMP_parallel_loop_runtime_start[%p]\n", (void* )lib_GOMP_parallel_loop_runtime_start);

	// Initializations.
	HOOKOMP_initialization(start, end, num_threads);
	
	lib_GOMP_parallel_loop_runtime_start(fn, data, num_threads, start, end, incr);
}

/* ------------------------------------------------------------- */
void GOMP_parallel_loop_static (void (*fn) (void *), void *data,
			   unsigned num_threads, long start, long end,
			   long incr, long chunk_size, unsigned flags){
	PRINT_FUNC_NAME;

  	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_parallel_loop_static, "GOMP_parallel_loop_static");

	TRACE("[GOMP_1.0] lib_GOMP_parallel_loop_static[%p]\n", (void* )lib_GOMP_parallel_loop_static);

	lib_GOMP_parallel_loop_static(fn, data, num_threads, start, end, incr, chunk_size, flags);
}

/* ------------------------------------------------------------- */
void GOMP_parallel_loop_dynamic (void (*fn) (void *), void *data,
			    unsigned num_threads, long start, long end,
			    long incr, long chunk_size, unsigned flags){
	PRINT_FUNC_NAME;

  	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_parallel_loop_dynamic, "GOMP_parallel_loop_dynamic");

	TRACE("[GOMP_1.0] lib_GOMP_parallel_loop_dynamic[%p]\n", (void* )lib_GOMP_parallel_loop_dynamic);

	lib_GOMP_parallel_loop_dynamic(fn, data, num_threads, start, end, incr, chunk_size, flags);
}

/* ------------------------------------------------------------- */
void GOMP_parallel_loop_guided (void (*fn) (void *), void *data,
			  unsigned num_threads, long start, long end,
			  long incr, long chunk_size, unsigned flags){
	PRINT_FUNC_NAME;

  	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_parallel_loop_guided, "GOMP_parallel_loop_guided");

	TRACE("[GOMP_1.0] lib_GOMP_parallel_loop_guided[%p]\n", (void* )lib_GOMP_parallel_loop_guided);

	lib_GOMP_parallel_loop_guided(fn, data, num_threads, start, end, incr, chunk_size, flags);
}

/* ------------------------------------------------------------- */
void GOMP_parallel_loop_runtime (void (*fn) (void *), void *data,
			    unsigned num_threads, long start, long end,
			    long incr, unsigned flags){
	PRINT_FUNC_NAME;

  	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_parallel_loop_runtime, "GOMP_parallel_loop_runtime");

	TRACE("[GOMP_1.0] lib_GOMP_parallel_loop_runtime[%p]\n", (void* )lib_GOMP_parallel_loop_runtime);

	lib_GOMP_parallel_loop_runtime(fn, data, num_threads, start, end, incr, flags);
}

/* ------------------------------------------------------------- */
void GOMP_loop_end (void){
	PRINT_FUNC_NAME;

  	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_end, "GOMP_loop_end");

	TRACE("[GOMP_1.0] lib_GOMP_loop_end[%p]\n", (void* )lib_GOMP_loop_end);

	lib_GOMP_loop_end();
}
/* ------------------------------------------------------------- */
void GOMP_loop_end_nowait (void){
	PRINT_FUNC_NAME;

  	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_end_nowait, "GOMP_loop_end_nowait");

	TRACE("[GOMP_1.0] lib_GOMP_loop_end_nowait[%p]\n", (void* )GOMP_loop_end_nowait);

	TRACE("[hookomp]: Thread [%lu] is calling %s.\n", (long int) pthread_self(), __FUNCTION__);

	HOOKOMP_loop_end_nowait();

	lib_GOMP_loop_end_nowait();
}

/* ------------------------------------------------------------- */
bool GOMP_loop_end_cancel (void){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_end_cancel, "GOMP_loop_end_cancel");
	TRACE("[GOMP_1.0] GOMP_loop_end_cancel@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_end_cancel();
	
	return result;
}

/* ------------------------------------------------------------- */
/* loop_ull.c                                                    */
/* ------------------------------------------------------------- */
bool GOMP_loop_ull_static_start (bool up, unsigned long long start, unsigned long long end,
			    unsigned long long incr, unsigned long long chunk_size,
			    unsigned long long *istart, unsigned long long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ull_static_start, "GOMP_loop_ull_static_start");
	TRACE("[GOMP_1.0] GOMP_loop_ull_static_start@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_ull_static_start(up, start, end, incr, chunk_size, istart, iend);
	
	return result;
}

/* ------------------------------------------------------------- */
bool GOMP_loop_ull_dynamic_start (bool up, unsigned long long start, unsigned long long end,
			     unsigned long long incr, unsigned long long chunk_size,
			     unsigned long long *istart, unsigned long long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ull_dynamic_start, "GOMP_loop_ull_dynamic_start");
	TRACE("[GOMP_1.0] GOMP_loop_ull_dynamic_start@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_ull_dynamic_start(up, start, end, incr, chunk_size, istart, iend);
	
	return result;
}

/* ------------------------------------------------------------- */
bool GOMP_loop_ull_guided_start (bool up, unsigned long long start, unsigned long long end,
			    unsigned long long incr, unsigned long long chunk_size,
			    unsigned long long *istart, unsigned long long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ull_guided_start, "GOMP_loop_ull_guided_start");
	TRACE("[GOMP_1.0] GOMP_loop_ull_guided_start@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_ull_guided_start(up, start, end, incr, chunk_size, istart, iend);
	
	return result;
}

/* ------------------------------------------------------------- */
bool GOMP_loop_ull_runtime_start (bool up, unsigned long long start, unsigned long long end,
			     unsigned long long incr, unsigned long long *istart, unsigned long long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ull_runtime_start, "GOMP_loop_ull_runtime_start");
	TRACE("[GOMP_1.0] GOMP_loop_ull_runtime_start@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_ull_runtime_start(up, start, end, incr, istart, iend);
	
	return result;
}

/* ------------------------------------------------------------- */
bool GOMP_loop_ull_ordered_static_start (bool up, unsigned long long start, unsigned long long end,
				    unsigned long long incr, unsigned long long chunk_size,
				    unsigned long long *istart, unsigned long long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ull_ordered_static_start, "GOMP_loop_ull_ordered_static_start");
	TRACE("[GOMP_1.0] GOMP_loop_ull_ordered_static_start@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_ull_ordered_static_start(up, start, end, incr, chunk_size, istart, iend);
	
	return result;
}

/* ------------------------------------------------------------- */
bool GOMP_loop_ull_ordered_dynamic_start (bool up, unsigned long long start, unsigned long long end,
				     unsigned long long incr, unsigned long long chunk_size,
				     unsigned long long *istart, unsigned long long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ull_ordered_dynamic_start, "GOMP_loop_ull_ordered_dynamic_start");
	TRACE("[GOMP_1.0] GOMP_loop_ull_ordered_dynamic_start@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_ull_ordered_dynamic_start(up, start, end, incr, chunk_size, istart, iend);
	
	return result;
}

/* ------------------------------------------------------------- */
bool GOMP_loop_ull_ordered_guided_start (bool up, unsigned long long start, unsigned long long end,
				    unsigned long long incr, unsigned long long chunk_size,
				    unsigned long long *istart, unsigned long long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ull_ordered_guided_start, "GOMP_loop_ull_ordered_guided_start");
	TRACE("[GOMP_1.0] GOMP_loop_ull_ordered_guided_start@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_ull_ordered_guided_start(up, start, end, incr, chunk_size, istart, iend);
	
	return result;
}

/* ------------------------------------------------------------- */
bool GOMP_loop_ull_ordered_runtime_start (bool up, unsigned long long start, unsigned long long end,
				     unsigned long long incr, unsigned long long *istart,
				     unsigned long long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ull_ordered_runtime_start, "GOMP_loop_ull_ordered_runtime_start");
	TRACE("[GOMP_1.0] GOMP_loop_ull_ordered_runtime_start@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_ull_ordered_runtime_start(up, start, end, incr, istart, iend);
	
	return result;
}

/* ------------------------------------------------------------- */
bool GOMP_loop_ull_static_next (unsigned long long *istart, unsigned long long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ull_static_next, "GOMP_loop_ull_static_next");
	TRACE("[GOMP_1.0] GOMP_loop_ull_static_next@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_ull_static_next(istart, iend);
	
	return result;
}

/* ------------------------------------------------------------- */
bool GOMP_loop_ull_dynamic_next (unsigned long long *istart, unsigned long long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ull_dynamic_next, "GOMP_loop_ull_dynamic_next");
	TRACE("[GOMP_1.0] GOMP_loop_ull_dynamic_next@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_ull_dynamic_next(istart, iend);
	
	return result;
}

/* ------------------------------------------------------------- */
bool GOMP_loop_ull_guided_next (unsigned long long *istart, unsigned long long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ull_guided_next, "GOMP_loop_ull_guided_next");
	TRACE("[GOMP_1.0] GOMP_loop_ull_guided_next@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_ull_guided_next(istart, iend);
	
	return result;
}

/* ------------------------------------------------------------- */
bool GOMP_loop_ull_runtime_next (unsigned long long *istart, unsigned long long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ull_runtime_next, "GOMP_loop_ull_runtime_next");
	TRACE("[GOMP_1.0] GOMP_loop_ull_runtime_next@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_ull_runtime_next(istart, iend);
	
	return result;
}

/* ------------------------------------------------------------- */
bool GOMP_loop_ull_ordered_static_next (unsigned long long *istart, unsigned long long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ull_ordered_static_next, "GOMP_loop_ull_ordered_static_next");
	TRACE("[GOMP_1.0] GOMP_loop_ull_ordered_static_next@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_ull_ordered_static_next(istart, iend);
	
	return result;
}

/* ------------------------------------------------------------- */
bool GOMP_loop_ull_ordered_dynamic_next (unsigned long long *istart, unsigned long long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ull_ordered_dynamic_next, "GOMP_loop_ull_ordered_dynamic_next");
	TRACE("[GOMP_1.0] GOMP_loop_ull_ordered_dynamic_next@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_ull_ordered_dynamic_next(istart, iend);
	
	return result;
}

/* ------------------------------------------------------------- */
bool GOMP_loop_ull_ordered_guided_next (unsigned long long *istart, unsigned long long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ull_ordered_guided_next, "GOMP_loop_ull_ordered_guided_next");
	TRACE("[GOMP_1.0] GOMP_loop_ull_ordered_guided_next@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_ull_ordered_guided_next(istart, iend);
	
	return result;
}

/* ------------------------------------------------------------- */
bool GOMP_loop_ull_ordered_runtime_next (unsigned long long *istart, unsigned long long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ull_ordered_runtime_next, "GOMP_loop_ull_ordered_runtime_next");
	TRACE("[GOMP_1.0] GOMP_loop_ull_ordered_runtime_next@GOMP_1.0.\n");
	
	bool result = lib_GOMP_loop_ull_ordered_runtime_next(istart, iend);
	
	return result;
}

/* ------------------------------------------------------------- */
/* ordered.c                                                     */
/* ------------------------------------------------------------- */
void GOMP_ordered_start (void){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_ordered_start, "GOMP_ordered_start");
	TRACE("[GOMP_1.0] GOMP_ordered_start@GOMP_1.0.\n");
	
	lib_GOMP_ordered_start();
}

/* ------------------------------------------------------------- */
void GOMP_ordered_end (void){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_ordered_end, "GOMP_ordered_end");
	TRACE("[GOMP_1.0] GOMP_ordered_end@GOMP_1.0.\n");
	
	lib_GOMP_ordered_end();
}

/* ------------------------------------------------------------- */
/* parallel.c                                                    */
/* ------------------------------------------------------------- */
/* Function to intercept GOMP_parallel_start                     */
void GOMP_parallel_start (void (*fn) (void *), void *data, unsigned num_threads){
	PRINT_FUNC_NAME;

	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_parallel_start, "GOMP_parallel_start");

	TRACE("[GOMP_1.0] GOMP_parallel_start@GOMP_1.0.[%p]\n", (void* )fn);
	
	TRACE("[GOMP_1.0] lib_GOMP_parallel_start[%p]\n", (void* ) lib_GOMP_parallel_start);

	lib_GOMP_parallel_start(fn, data, num_threads);
}

/* ------------------------------------------------------------- */
/* Function to intercept GOMP_parallel_end                       */
void GOMP_parallel_end (void){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_parallel_end, "GOMP_parallel_end");

	TRACE("[GOMP_1.0] GOMP_parallel_end@GOMP_1.0 [%p]\n", (void* ) lib_GOMP_parallel_end);

	HOOKOMP_end();
	
    lib_GOMP_parallel_end();
}

/* ------------------------------------------------------------- */
void GOMP_parallel (void (*fn) (void *), void *data, unsigned num_threads, unsigned int flags){
	PRINT_FUNC_NAME;

  	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_parallel, "GOMP_parallel");

	TRACE("[GOMP_1.0] GOMP_parallel@GOMP_1.0.[%p]\n", (void* )fn);
	
	TRACE("[GOMP_1.0] lib_GOMP_parallel[%p]\n", (void* )lib_GOMP_parallel);

	lib_GOMP_parallel(fn, data, num_threads, flags);
}

/* ------------------------------------------------------------- */
bool GOMP_cancel (int which, bool do_cancel){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_cancel, "GOMP_cancel");
	TRACE("[GOMP_1.0] GOMP_cancel@GOMP_1.0.\n");
	
	bool result = lib_GOMP_cancel(which, do_cancel);
	
	return result;
}

/* ------------------------------------------------------------- */
bool GOMP_cancellation_point (int which){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_cancellation_point, "GOMP_cancellation_point");
	TRACE("[GOMP_1.0] GOMP_cancellation_point@GOMP_1.0.\n");
	
	bool result = lib_GOMP_cancellation_point(which);
	
	return result;
}

/* ------------------------------------------------------------- */
/* task.c */
/* ------------------------------------------------------------- */
void GOMP_task (void (*fn) (void *), void *data, void (*cpyfn) (void *, void *),
	   long arg_size, long arg_align, bool if_clause, unsigned flags,
	   void **depend){
	PRINT_FUNC_NAME;

  	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_task, "GOMP_task");

	TRACE("[GOMP_1.0] GOMP_task@GOMP_1.0.[%p]\n", (void* )fn);
	
	TRACE("[GOMP_1.0] lib_GOMP_task[%p]\n", (void* )lib_GOMP_task);

	lib_GOMP_task(fn, data, cpyfn, arg_size, arg_align, if_clause, flags, depend);
}

/* ------------------------------------------------------------- */
void GOMP_taskwait (void){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_taskwait, "GOMP_taskwait");
	TRACE("[GOMP_1.0] GOMP_taskwait@GOMP_1.0.\n");
	
	lib_GOMP_taskwait();
}

/* ------------------------------------------------------------- */
void GOMP_taskyield (void){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_taskyield, "GOMP_taskyield");
	TRACE("[GOMP_1.0] GOMP_taskyield@GOMP_1.0.\n");
	
	lib_GOMP_taskyield();
}

/* ------------------------------------------------------------- */
void GOMP_taskgroup_start (void){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_taskgroup_start, "GOMP_taskgroup_start");
	TRACE("[GOMP_1.0] GOMP_taskgroup_start@GOMP_1.0.\n");
	
	lib_GOMP_taskgroup_start();
}

/* ------------------------------------------------------------- */
void GOMP_taskgroup_end (void){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_taskgroup_end, "GOMP_taskgroup_end");
	TRACE("[GOMP_1.0] GOMP_taskgroup_end@GOMP_1.0.\n");
	
	lib_GOMP_taskgroup_end();
}

/* ------------------------------------------------------------- */
/* sections.c */
/* ------------------------------------------------------------- */
unsigned GOMP_sections_start (unsigned count){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_sections_start, "GOMP_sections_start");
	TRACE("[GOMP_1.0] GOMP_sections_start@GOMP_1.0.\n");
	
	unsigned result = lib_GOMP_sections_start(count);
	
	return result;
}

/* ------------------------------------------------------------- */
unsigned GOMP_sections_next (void){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_sections_next, "GOMP_sections_next");
	TRACE("[GOMP_1.0] GOMP_sections_next@GOMP_1.0.\n");
	
	unsigned result = lib_GOMP_sections_next();
	
	return result;
}

/* ------------------------------------------------------------- */
void GOMP_parallel_sections_start (void (*fn) (void *), void *data,
			      unsigned num_threads, unsigned count){
	PRINT_FUNC_NAME;

  	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_parallel_sections_start, "GOMP_parallel_sections_start");

	TRACE("[GOMP_1.0] GOMP_parallel_sections_start@GOMP_1.0.[%p]\n", (void* )fn);
	
	TRACE("[GOMP_1.0] lib_GOMP_parallel_sections_start[%p]\n", (void* )lib_GOMP_parallel_sections_start);

	lib_GOMP_parallel_sections_start(fn, data, num_threads, count);
}

/* ------------------------------------------------------------- */
void GOMP_parallel_sections (void (*fn) (void *), void *data,
			unsigned num_threads, unsigned count, unsigned flags){
	PRINT_FUNC_NAME;

  	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_parallel_sections, "GOMP_parallel_sections");

	TRACE("[GOMP_1.0] GOMP_parallel_sections@GOMP_1.0.[%p]\n", (void* )fn);
	
	TRACE("[GOMP_1.0] lib_GGOMP_parallel_sections[%p]\n", (void* )lib_GOMP_parallel_sections);

	lib_GOMP_parallel_sections(fn, data, num_threads, count, flags);
}

/* ------------------------------------------------------------- */
void GOMP_sections_end (void){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_sections_end, "GOMP_sections_end");
	TRACE("[GOMP_1.0] GOMP_sections_end@GOMP_1.0.\n");
	
	lib_GOMP_sections_end();
}
	
/* ------------------------------------------------------------- */
void GOMP_sections_end_nowait (void){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_sections_end_nowait, "GOMP_sections_end_nowait");
	TRACE("[GOMP_1.0] GOMP_sections_end_nowait@GOMP_1.0.\n");
	
	lib_GOMP_sections_end_nowait();
}
	
/* ------------------------------------------------------------- */
bool GOMP_sections_end_cancel (void){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_sections_end_cancel, "GOMP_sections_end_cancel");
	TRACE("[GOMP_1.0] GOMP_sections_end_cancel@GOMP_1.0.\n");
	
	bool result = lib_GOMP_sections_end_cancel();
	
	return result;
}

/* ------------------------------------------------------------- */
/* single.c */
/* ------------------------------------------------------------- */
bool GOMP_single_start (void){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_single_start, "GOMP_single_start");
	
	/* This routine is called when first encountering a SINGLE construct that
   doesn't have a COPYPRIVATE clause.  Returns true if this is the thread
   that should execute the clause.
   bool GOMP_single_start (void){...} */

   TRACE("[hookomp]: Testing single start[%lu].\n", (unsigned long int) pthread_self());

   TRACE("[GOMP_1.0] GOMP_single_start@GOMP_1.0.\n");
   bool result = lib_GOMP_single_start();

   // // Start the counters on PAPI if is the thread that should execute.
   // if (result){
   // 		// Registry the thread id that entered in single region to match with OMP_barrier().
   // 		// executing_a_single_region = omp_get_thread_num();
   // 		executing_a_single_region = pthread_self();

   // 		TRACE("[hookomp]: Thread [%lu] executing the single region.\n", (unsigned long int) executing_a_single_region);

   // 		// PAPI Start the counters.
   // 		if(RM_start_counters()){
   // 			TRACE("[hookomp] GOMP_single_start: PAPI Counters Started.\n");
   // 		}
   // 		else 
   // 			TRACE("Error calling RM_start_counters from GOMP_single_start.\n");
   // 	}	

   return result;
}

/* ------------------------------------------------------------- */
void *GOMP_single_copy_start (void){
	PRINT_FUNC_NAME;

	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_single_copy_start, "GOMP_single_copy_start");
	TRACE("[GOMP_1.0] GOMP_single_copy_start@GOMP_1.0.\n");
	
	void *result;

	result = lib_GOMP_single_copy_start();

	return result;
}

/* ------------------------------------------------------------- */
void GOMP_single_copy_end (void *data){

	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_single_copy_end, "GOMP_single_copy_end");
	TRACE("[GOMP_1.0] GOMP_single_copy_end@GOMP_1.0.\n");
	
	lib_GOMP_single_copy_end(data);
}

/* ------------------------------------------------------------- */
/* target.c */
/* ------------------------------------------------------------- */

void GOMP_target (int device, void (*fn) (void *), const void *unused,
	     size_t mapnum, void **hostaddrs, size_t *sizes,
	     unsigned char *kinds){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_target, "GOMP_target");
	TRACE("[GOMP_1.0] GOMP_target@GOMP_1.0.\n");
	
	lib_GOMP_target(device, fn, unused, mapnum, hostaddrs, sizes, kinds);
}

/* ------------------------------------------------------------- */
void GOMP_target_data (int device, const void *unused, size_t mapnum,
		  void **hostaddrs, size_t *sizes, unsigned char *kinds){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_target_data, "GOMP_target_data");
	TRACE("[GOMP_1.0] GOMP_target_data@GOMP_1.0.\n");
	
	lib_GOMP_target_data(device, unused, mapnum, hostaddrs, sizes, kinds);
}

/* ------------------------------------------------------------- */
void GOMP_target_end_data (void){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_target_end_data, "GOMP_target_end_data");
	TRACE("[GOMP_1.0] GOMP_target_end_data@GOMP_1.0.\n");
	
	lib_GOMP_target_end_data();
}

/* ------------------------------------------------------------- */
void GOMP_target_update (int device, const void *unused, size_t mapnum,
		    void **hostaddrs, size_t *sizes, unsigned char *kinds){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_target_update, "GOMP_target_update");
	TRACE("[GOMP_1.0] GOMP_target_update@GOMP_1.0.\n");
	
	lib_GOMP_target_update(device, unused, mapnum, hostaddrs, sizes, kinds);
}

/* ------------------------------------------------------------- */
void GOMP_teams (unsigned int num_teams, unsigned int thread_limit){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_teams, "GOMP_teams");
	TRACE("[GOMP_1.0] GOMP_teams@GOMP_1.0.\n");
	
	lib_GOMP_teams(num_teams, thread_limit);
}

/* ------------------------------------------------------------- */
/* oacc-parallel.c */
/* ------------------------------------------------------------- */
/*
void GOACC_data_start (int device, size_t mapnum,
		  void **hostaddrs, size_t *sizes, unsigned short *kinds){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOACC_data_start, "GOACC_data_start");
	TRACE("[GOMP_1.0] GOACC_data_start@GOMP_1.0.\n");
	
	lib_GOACC_data_start(device, mapnum, hostaddrs, sizes, kinds);
}
*/
/* ------------------------------------------------------------- */
/*
void GOACC_data_end (void){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOACC_data_end, "GOACC_data_end");
	TRACE("[GOMP_1.0] GOACC_data_end@GOMP_1.0.\n");
	
	lib_GOACC_data_end();
}
*/
/* ------------------------------------------------------------- */
/*
void GOACC_enter_exit_data (int device, size_t mapnum,
		       void **hostaddrs, size_t *sizes, unsigned short *kinds,
		       int async, int num_waits, ...){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOACC_enter_exit_data, "GOACC_enter_exit_data");
	TRACE("[GOMP_1.0] GOACC_enter_exit_data@GOMP_1.0.\n");
	
	lib_GOACC_enter_exit_data(device, mapnum, hostaddrs, sizes, kinds, async, num_waits, ...);
}
*/
/* ------------------------------------------------------------- */
/*
void GOACC_parallel (int device, void (*fn) (void *),
		size_t mapnum, void **hostaddrs, size_t *sizes,
		unsigned short *kinds,
		int num_gangs, int num_workers, int vector_length,
		int async, int num_waits, ...){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOACC_parallel, "GOACC_parallel");
	TRACE("[GOMP_1.0] GOACC_parallel@GOMP_1.0.\n");
	
	lib_GOACC_parallel(device, fn, mapnum, hostaddrs, sizes, kinds, num_gangs, num_workers, vector_length, async, num_waits, ...);
}
*/
/* ------------------------------------------------------------- */
/*
void GOACC_update (int device, size_t mapnum,
	      void **hostaddrs, size_t *sizes, unsigned short *kinds,
	      int async, int num_waits, ...){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOACC_update, "GOACC_update");
	TRACE("[GOMP_1.0] GOACC_update@GOMP_1.0.\n");
	
	lib_GOACC_update(device, mapnum, hostaddrs, sizes, kinds, async, num_waits, ...);
}
*/
/* ------------------------------------------------------------- */
/*
void GOACC_wait (int async, int num_waits, ...){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOACC_wait, "GOACC_wait");
	TRACE("[GOMP_1.0] GOACC_wait@GOMP_1.0.\n");
	
	lib_GOACC_wait(async, num_waits, ...);
}
*/	
/* ------------------------------------------------------------- */
/*
int GOACC_get_num_threads (void){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOACC_get_num_threads, "GOACC_get_num_threads");
	TRACE("[GOMP_1.0] GOACC_get_num_threads@GOMP_1.0.\n");
	
	int result = lib_GOACC_get_num_threads();
	
	return result;
}
*/	
/* ------------------------------------------------------------- */
/*
int GOACC_get_thread_num (void){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOACC_get_thread_num, "GOACC_get_thread_num");
	TRACE("[GOMP_1.0] GOACC_get_thread_num@GOMP_1.0.\n");
	
	int result = lib_GOACC_get_thread_num();
	
	return result;
}
*/
/* ------------------------------------------------------------- */
