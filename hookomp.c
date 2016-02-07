#include "hookomp.h"

/* ------------------------------------------------------------- */
/* Test function.                                                */
void foo(void) {
	puts("Hello, I'm a shared library.\n");
}

/* ------------------------------------------------------------- */
/* Function to execute up semaphore num_threads -1 to wake up the threads of team.*/
void release_all_team_threads(void){
	PRINT_FUNC_NAME;

	TRACE("[HOOKOMP]: Waking up the %d blocked threads.\n", number_of_blocked_threads);
	for (int i = 0; i < number_of_blocked_threads; ++i) {
		sem_post(&sem_blocks_other_team_threads);
	}
	number_of_blocked_threads = 0;
}

/* ------------------------------------------------------------- */
void HOOKOMP_initialization(long int start, long int end, long int num_threads){
	PRINT_FUNC_NAME;

	TRACE("Number of threads: %d.\n", num_threads);

	sem_wait(&mutex_hookomp_init);

	if(!is_hookomp_initialized){
		/* Initialization of semaphores of control. */
		sem_init(&mutex_registry_thread_in_func_next, 0, 1);

		/* Semaphore to registred thread wait for block the others. 
		 * The idea is block all and the last blocked wake up the registred thread.
		 * Must be initialized with (1 - (num_threads - 1)).
		 * Ex. num_threads = 4
		 * 1 thread will execute.
		 * 3 threads will blocked and up the sem_block_registred_thread.
		 * (1 - (num_threads - 1)) = (1 - (4 - 1)) = -2.
		 * 3 threads up -> -2 ... 1 (thread execute).
		*/
		// sem_init(&sem_block_registred_thread, 0, (1 - (num_threads - 1)));

		 sem_init(&sem_block_registred_thread, 0, 0);

		TRACE("sem_block_registred_thread: %d.\n", sem_block_registred_thread);

		/* Initialization of block to other team threads. 1 thread will be executing. 
		The initialization with 0 is proposital to block other threads.
		*/
		sem_init(&sem_blocks_other_team_threads, 0, 0);

		/* Initialization of control iterations variables. */
		loop_iterations_start = start;
		loop_iterations_end = end;
		total_of_iterations = (loop_iterations_end - loop_iterations_start);
		percentual_of_code = PERC_OF_CODE_TO_EXECUTE;

		/* Initialization of control iterations. */
		executed_loop_iterations = 0;

		/* Control of threads in parallel region. */
		number_of_threads_in_team = num_threads;
		number_of_blocked_threads = 0;

		/* Initialization of thread and measures section. */
		registred_thread_executing_function_next = -1;
		is_executing_measures_section = true;
		
		/* Control of decision about offloding. */		
		decided_by_offloading = false;
		made_the_offloading = false;

		/* Initialize RM library. */
		if(!RM_library_init()){
			TRACE("Error calling RM_library_init in %s.\n", __FUNCTION__);
		}

		is_hookomp_initialized = true;
	}
	/* up semaphore. */
	sem_post(&mutex_hookomp_init);
}

/* ------------------------------------------------------------- */
/* Registry the first thread that entry in function next. */
void HOOKOMP_registry_the_first_thread(void){
	PRINT_FUNC_NAME;

	long int thread_id = (long int) pthread_self();

	/* Thread registry. */
	sem_wait(&mutex_registry_thread_in_func_next);
	if(registred_thread_executing_function_next == -1){
		registred_thread_executing_function_next = thread_id;
		TRACE("[HOOKOMP]: Thread [%lu] was registred.\n", (long int) registred_thread_executing_function_next);
	}
	sem_post(&mutex_registry_thread_in_func_next);
	
	/* Single thread execution, don't wait. */
	if (number_of_threads_in_team > 1){
		if(registred_thread_executing_function_next == (long int) pthread_self()){
			TRACE("[HOOKOMP]: Thread [%lu] was registred and now is waiting for the block of other threads.\n", (long int) registred_thread_executing_function_next);
		
			sem_wait(&sem_block_registred_thread);

			TRACE("[HOOKOMP]: Thread [%lu] is entering in controled execution.\n", (long int) registred_thread_executing_function_next);
		}
		else {  /* Block other threads. */
			/* If it is executing in a section to measurements, the threads will be blocked. */		
			/* Other team threads will be blocked. */
			number_of_blocked_threads++;
			TRACE("[HOOKOMP]: Number of blocked threads: %d.\n", number_of_blocked_threads);
			TRACE("[HOOKOMP]: Before Up the sem_block_registred_thread: %d.\n", sem_block_registred_thread);

			TRACE("[HOOKOMP]: Number of threads in team: %d.\n", number_of_threads_in_team);

			TRACE("[HOOKOMP]: Number of threads omp_get_num_threads: %d.\n", omp_get_num_threads());


			/* The last thread Wake up the registred thread. */
			if(number_of_blocked_threads == number_of_threads_in_team - 1) {
				sem_post(&sem_block_registred_thread);
				TRACE("[HOOKOMP]: After Up the sem_block_registred_thread: %d.\n", sem_block_registred_thread);
			}
			
			TRACE("[HOOKOMP]: Thread [%lu] will be blocked.\n", thread_id );
			sem_wait(&sem_blocks_other_team_threads);
		}
	}

	/* The registry was made. */
	thread_was_registred_to_execute_alone = true;
		
}

/* ------------------------------------------------------------- */
/* Proxy function to *_start */
bool HOOKOMP_proxy_function_start_next (long* istart, long* iend, void* extra) {
	PRINT_FUNC_NAME;
	Params *params = (Params*) extra;
	
	TRACE("[HOOKOMP]: function type -> %d.\n", params->func_type);
	// GOMP_loop_dynamic_start(params->_0, params->_1, params->_2, params->_3, istart, iend);
	TRACE("[HOOKOMP]: calling the GOMP_loop_*_start in %s.\n", __FUNCTION__);
	bool result = params->func_start_next(params->_0, params->_1, params->_2, params->_3, istart, iend);
	TRACE("[HOOKOMP]: Leaving the %s.\n", __FUNCTION__);
	return result;
}

/* ------------------------------------------------------------- */
/* Proxy function to runtime_start. Is specific function. 
bool (*func_start_next_runtime) (long start, long end, long incr, long *istart, long *iend); */
bool HOOKOMP_proxy_function_start_next_runtime (long* istart, long* iend, void* extra) {
	PRINT_FUNC_NAME;
	Params *params = (Params*) extra;

	TRACE("[HOOKOMP]: function type -> %d.\n", params->func_type);

	TRACE("[HOOKOMP]: calling the lib_GOMP_loop_runtime_start in %s.\n", __FUNCTION__);
	bool result = params->func_start_next_runtime (params->_0, params->_1, params->_2, istart, iend);
	TRACE("[HOOKOMP]: Leaving the %s.\n", __FUNCTION__);
	return result;
}


/* ------------------------------------------------------------- */
/* Proxy function to *_next */
bool HOOKOMP_proxy_function_next (long* istart, long* iend, void* extra) {
	PRINT_FUNC_NAME;
	// GOMP_loop_dynamic_next (istart, iend);
	Params *params = (Params*) extra;

	TRACE("[HOOKOMP]: function type -> %d.\n", params->func_type);

	TRACE("[HOOKOMP]: calling the GOMP_loop_*_next in %s.\n", __FUNCTION__);
	bool result = params->func_next(istart, iend);

	TRACE("[HOOKOMP]: Leaving the %s.\n", __FUNCTION__);
	return result;
}

/* ------------------------------------------------------------- */
/* Call the target function. */
bool HOOKOMP_call_function_ffi(Func* ff) {
  PRINT_FUNC_NAME;
  ffi_cif cif;
  int retval = 0;

  TRACE("Preparing calling.\n");
  if ((retval = ffi_prep_cif(&cif, FFI_DEFAULT_ABI, ff->nargs, ff->ret_type, ff->arg_types)) != FFI_OK){
	TRACE("Error ffi_prep_cif.\n");
  }
  else{
  	TRACE("Calling the target function.\n");
  	ffi_call(&cif, FFI_FN(ff->f), ff->ret_value, ff->arg_values);	
  }  

  return (retval == FFI_OK);
}

/* ------------------------------------------------------------- */
/* Call the appropriated function. */
bool HOOKOMP_call_offloading_function(long int loop_index, long int device_index){
	PRINT_FUNC_NAME;
	bool retval = false;

	TRACE("Verifying if function for loop index: %d, device index: %d is defined. \n", loop_index, device_index);
	if(TablePointerFunctions == NULL){
      TRACE("TablePointerFunctions is not defined. (TablePointerFunctions is NULL).\n");
      return retval;
    }

	TRACE("TablePointerFunctions: %p.\n", TablePointerFunctions);
	TRACE("TablePointerFunctions[%d][%d]: %p.\n", loop_index, device_index, (Func *) TablePointerFunctions[loop_index][device_index]);
	TRACE("(TablePointerFunctions[%d][%d])->f: %p.\n", loop_index, device_index, (TablePointerFunctions[loop_index][device_index])->f);
	
	if((TablePointerFunctions != NULL) && (TablePointerFunctions[loop_index][device_index] != NULL) && ((TablePointerFunctions[loop_index][device_index])->f != NULL)){
		TRACE("Offloading function for loop index: %d, device index: %d.\n", loop_index, device_index);
		retval = HOOKOMP_call_function_ffi(TablePointerFunctions[loop_index][device_index]);
	}
	else{
		TRACE("Offloading function not defined in TablePointerFunctions.\n");
	}
	return retval;
}

/* ------------------------------------------------------------- */
/* Generic function to get next chunk. */
bool HOOKOMP_generic_next(long* istart, long* iend, chunk_next_fn fn_proxy, void* extra) {	
	PRINT_FUNC_NAME;
	bool result = false;
	TRACE("[HOOKOMP]: Thread [%lu] is calling %s.\n", (long int) pthread_self(), __FUNCTION__);

	TRACE("[HOOKOMP]: Number of treads in team **: %d, omp_get_num_threads: %d.\n", number_of_threads_in_team, omp_get_num_threads());

	/* Registry the thread which will be execute alone. down semaphore. */
	if(!thread_was_registred_to_execute_alone){
		HOOKOMP_registry_the_first_thread();	
	}

	/* Is not getting measures execute directly. */
	if(!is_executing_measures_section){
		TRACE("[HOOKOMP]: [OUTSIDE] Calling next function out of measures section.\n");
		TRACE("[HOOKOMP]: [Before Call]-> Target GOMP_loop_*_next -- istart: %ld iend: %ld.\n", *istart, *iend);
		result = fn_proxy(istart, iend, extra);
		TRACE("[HOOKOMP]: [After Call]-> Target GOMP_loop_*_next -- istart: %ld iend: %ld.\n", *istart, *iend);
	}
	else{
		/* Verify if the thread is the thread registred to execute and get measures. */
		TRACE("[HOOKOMP]: Testing the registred thread id: %ld.\n", registred_thread_executing_function_next);
		if(registred_thread_executing_function_next == (long int) pthread_self()){
			/* Execute only percentual of code. */
			TRACE("[HOOKOMP]: Testing the number of executed iterations: %ld.\n", executed_loop_iterations);
			if(executed_loop_iterations < (total_of_iterations / percentual_of_code)){
				TRACE("[HOOKOMP]: [INSIDE] Calling next function inside of measures section.\n");
				TRACE("[HOOKOMP]: [Before Call]-> Target GOMP_loop_*_next -- istart: %ld iend: %ld.\n", *istart, *iend);
				result = fn_proxy(istart, iend, extra);
				TRACE("[HOOKOMP]: [After Call]-> Target GOMP_loop_*_next -- istart: %ld iend: %ld.\n", *istart, *iend);
				/* Update the number of iterations executed by this thread. */
				TRACE("[HOOKOMP]: [Before]-> Update of executed iterations: %ld.\n", executed_loop_iterations);
				executed_loop_iterations += (*iend - *istart);
				TRACE("[HOOKOMP]: [After]-> Update of executed iterations: %ld.\n", executed_loop_iterations);

				/* Starting the registry on RM library. Is necessary partial measures each chunk. 
				Switching to do not get measures considering control code. */
				RM_registry_measures();	
			}
			else{ /* Decision about the offloading. */
				TRACE("[HOOKOMP]: They were executed %ld iterations of %ld.\n", executed_loop_iterations, (loop_iterations_end - loop_iterations_start));
				TRACE("[HOOKOMP]: Trying to make decision about offloading.\n");

				long better_device = 0;

				// Get counters and decide about the migration.
				TRACE("[HOOKOMP]: Thread [%lu] is getting the performance counters to decide.\n", (long int) pthread_self());

				TRACE("Calling RM_stop_and_accumulate.\n");
				if(!RM_stop_and_accumulate()){
					TRACE("[HOOKOMP]: Error calling RM_stop_and_accumulate.\n");
				}
				else{
					TRACE("Current loop index: %d.\n", current_loop_index);
					TRACE("Defining aditional parameters.\n");
					// N: total of iterations, Number of executed iterations (percentual), last chunk_size.
					RM_set_aditional_parameters(total_of_iterations, executed_loop_iterations, (*iend - *istart), q_data_transfer_write, q_data_transfer_read);
					// A decisão de migrar é aqui.
					TRACE("Getting decision about offloading.\n");
					if((decided_by_offloading = RM_decision_about_offloading(&better_device)) != 0){
						/* Launch apropriated function. */
						TRACE("RM decided by device [%d].\n", better_device);

						TRACE("Trying to launch apropriated function to loop %d on device: %d.\n", current_loop_index, better_device);

						made_the_offloading = HOOKOMP_call_offloading_function(current_loop_index, better_device);

						TRACE("After to try launching of apropriated function to loop %d on device: %d.\n", current_loop_index, better_device);

						if (!made_the_offloading){
							TRACE("The function offloading was not done.\n");
						}
						else{
							TRACE("The offloading was done.\n");
						}
					}
					TRACE("After decision about offloading.\n");
				}

				/* Continue execution. */
				if(!(decided_by_offloading && made_the_offloading)){
					TRACE("[HOOKOMP]: [CONTINUE] Calling next function after offloading decision about.\n");
					TRACE("[HOOKOMP]: [Before Call]-> Target GOMP_loop_*_next -- istart: %ld iend: %ld.\n", *istart, *iend);
					result = fn_proxy(istart, iend, extra);
					TRACE("[HOOKOMP]: [After Call]-> Target GOMP_loop_*_next -- istart: %ld iend: %ld.\n", *istart, *iend);
				}

				/* Release all blocked team threads. */
				TRACE("[HOOKOMP]: Number of Blocked Threds: %ld.\n", number_of_blocked_threads);
				if(number_of_blocked_threads > 0){
					release_all_team_threads();	
				}
				
				executed_loop_iterations = 0;

				/* Mark that is no more in section of measurements. */
				is_executing_measures_section = false;
			}
		}
		else{ /* Block other threads. */
			/* If it is executing in a section to measurements, the threads will be blocked. */		
			/* Other team threads will be blocked. */
			// TRACE("[HOOKOMP]: Thread [%lu] will be blocked.\n", (long int) pthread_self());
			// number_of_blocked_threads++;
			// sem_wait(&sem_blocks_other_team_threads);	
		
			TRACE("Verifying if was decided by offloading.\n");
		
			/* if decided by offloading, no more work to do, so return false. */
			if(!made_the_offloading){
				TRACE("[HOOKOMP]: [WAKE UP] Calling next function out of measures section after wake up.\n");
				TRACE("[HOOKOMP]: [Before Call]-> Target GOMP_loop_*_next -- istart: %ld iend: %ld.\n", *istart, *iend);
				result = fn_proxy(istart, iend, extra);
				TRACE("[HOOKOMP]: [After Call]-> Target GOMP_loop_*_next -- istart: %ld iend: %ld.\n", *istart, *iend);
			}
			else{ /* Indicates have no more work to do. */
				result = false;
			}
		}
	}

	TRACE("[HOOKOMP]: Leaving the %s.\n", __FUNCTION__);
	return result;
}

/* ------------------------------------------------------------- */
/* Function to parallel_start. */
void HOOKOMP_parallel_start(void){
	PRINT_FUNC_NAME;

	sem_init(&mutex_hookomp_init, 0, 1);

	TRACE("[HOOKOMP]: Leaving the %s.\n", __FUNCTION__);
}

/* ------------------------------------------------------------- */
/* Function to parallel_end. */
void HOOKOMP_parallel_end(void){
	PRINT_FUNC_NAME;

	TRACE("[HOOKOMP] [Before] Destroying the semaphores. \n");
	sem_destroy(&mutex_registry_thread_in_func_next); 	/* destroy semaphore */

	sem_destroy(&sem_blocks_other_team_threads);

	sem_destroy(&mutex_hookomp_init);
	TRACE("[HOOKOMP] [After] Destroying the semaphores.\n");

	/* Shutdown RM library. */
	if(!RM_library_shutdown()){
		TRACE("Error calling RM_library_shutdown() in %s.\n", __FUNCTION__);
	}

	/* Set flag to control initialization of hook. */
	is_hookomp_initialized = false;

	TRACE("[HOOKOMP]: Leaving the %s.\n", __FUNCTION__);
}

/* ------------------------------------------------------------- */
void HOOKOMP_loop_end_nowait(void){
	PRINT_FUNC_NAME;
	TRACE("[HOOKOMP]: Thread [%lu] is calling %s in current loop index %d.\n", (long int) pthread_self(), __FUNCTION__, current_loop_index);
	
	// if(is_hookomp_initialized){
		/* Set flag to control initialization of hook. */
	// 	is_hookomp_initialized = false;	
	// }
}

/* ------------------------------------------------------------- */
void HOOKOMP_loop_end(void){
	PRINT_FUNC_NAME;
	TRACE("[HOOKOMP]: Thread [%lu] is calling %s in current loop index %d.\n", (long int) pthread_self(), __FUNCTION__, current_loop_index);
	
	// if(is_hookomp_initialized){
		/* Set flag to control initialization of hook. */
	// 	is_hookomp_initialized = false;	
	// }
}

/* ------------------------------------------------------------- */
/* barrier.c                                                     */
/* ------------------------------------------------------------- */
void GOMP_barrier (void) {
	PRINT_FUNC_NAME;
	
	GET_RUNTIME_FUNCTION(lib_GOMP_barrier, "GOMP_barrier");

	TRACE("[LIBGOMP] GOMP_barrier@GOMP_X.X.\n");
	lib_GOMP_barrier();
}

/* ------------------------------------------------------------- */
bool GOMP_barrier_cancel (void){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_barrier_cancel, "GOMP_barrier_cancel");
	TRACE("[LIBGOMP] GOMP_barrier_cancel@GOMP_X.X.\n");
	
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
	TRACE("[LIBGOMP] GOMP_critical_start@GOMP_X.X.\n");
	
	lib_GOMP_critical_start();
}

/* ------------------------------------------------------------- */
void GOMP_critical_end (void){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_critical_end, "GOMP_critical_end");
	TRACE("[LIBGOMP] GOMP_critical_end@GOMP_X.X.\n");
	
	lib_GOMP_critical_end();
}

/* ------------------------------------------------------------- */
void GOMP_critical_name_start (void **pptr){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_critical_name_start, "GOMP_critical_name_start");
	TRACE("[LIBGOMP] GOMP_critical_name_start@GOMP_X.X.\n");
	
	lib_GOMP_critical_name_start(pptr);
}

/* ------------------------------------------------------------- */
void GOMP_critical_name_end (void **pptr){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_critical_name_end, "GOMP_critical_name_end");
	TRACE("[LIBGOMP] GOMP_critical_name_end@GOMP_X.X.\n");
	
	lib_GOMP_critical_name_end(pptr);
}

/* ------------------------------------------------------------- */
void GOMP_atomic_start (void){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_atomic_start, "GOMP_atomic_start");
	TRACE("[LIBGOMP] GOMP_atomic_start@GOMP_X.X.\n");
	
	lib_GOMP_atomic_start();
}

/* ------------------------------------------------------------- */
void GOMP_atomic_end (void){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_atomic_end, "GOMP_atomic_end");
	TRACE("[LIBGOMP] GOMP_atomic_end@GOMP_X.X.\n");
	
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
	TRACE("[LIBGOMP] GOMP_loop_static_start@GOMP_X.X.\n");
	
	bool result = lib_GOMP_loop_static_start(start, end, incr, chunk_size, istart, iend);
	
	return result;
}

/* ------------------------------------------------------------- */
bool GOMP_loop_dynamic_start (long start, long end, long incr, long chunk_size,
			 long *istart, long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_dynamic_start, "GOMP_loop_dynamic_start");
	TRACE("[LIBGOMP] GOMP_loop_dynamic_start@GOMP_X.X.\n");

	TRACE("Starting with %d threads.\n", omp_get_num_threads());

	// Initializations.
	HOOKOMP_initialization(start, end, omp_get_num_threads());
	
	// bool result = lib_GOMP_loop_dynamic_start(start, end, incr, chunk_size, istart, iend);
	chunk_next_fn func_proxy;
	Params p;	

	p._0 = start;
	p._1 = end;
	p._2 = incr;
	p._3 = chunk_size;

	p.func_start_next = lib_GOMP_loop_dynamic_start;
	p.func_type = FUN_START_NEXT;

	func_proxy = &HOOKOMP_proxy_function_start_next;

	bool result = HOOKOMP_generic_next(istart, iend, func_proxy, &p);

	TRACE("Leaving %s with %d threads.\n", __FUNCTION__, omp_get_num_threads());
	
	return result;
}

/* ------------------------------------------------------------- */
bool GOMP_loop_guided_start (long start, long end, long incr, long chunk_size,
			long *istart, long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_guided_start, "GOMP_loop_guided_start");
	TRACE("[LIBGOMP] GOMP_loop_guided_start@GOMP_X.X.\n");

	// Initializations.
	HOOKOMP_initialization(start, end, omp_get_num_threads());
	
	// bool result = lib_GOMP_loop_guided_start(start, end, incr, chunk_size, istart, iend);
	chunk_next_fn func_proxy;
	Params p;	

	p._0 = start;
	p._1 = end;
	p._2 = incr;
	p._3 = chunk_size;

	p.func_start_next = lib_GOMP_loop_guided_start;
	p.func_type = FUN_START_NEXT;

	func_proxy = &HOOKOMP_proxy_function_start_next;

	bool result = HOOKOMP_generic_next(istart, iend, func_proxy, &p);
	
	return result;
}
/* ------------------------------------------------------------- */
bool GOMP_loop_runtime_start (long start, long end, long incr,
			 long *istart, long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_runtime_start, "GOMP_loop_runtime_start");
	TRACE("[LIBGOMP] GOMP_loop_runtime_start@GOMP_X.X.\n");
	
	// Initializations.
	HOOKOMP_initialization(start, end, omp_get_num_threads());
	
	// bool result = lib_GOMP_loop_runtime_start(start, end, incr, istart, iend);
	chunk_next_fn func_proxy;
	Params p;	

	p._0 = start;
	p._1 = end;
	p._2 = incr;
	p._3 = 0;

	p.func_start_next_runtime = lib_GOMP_loop_runtime_start;
	p.func_type = FUN_START_NEXT_RUNTIME;

	func_proxy = &HOOKOMP_proxy_function_start_next_runtime;

	bool result = HOOKOMP_generic_next(istart, iend, func_proxy, &p);
	
	return result;
}

/* ------------------------------------------------------------- */
bool GOMP_loop_ordered_static_start (long start, long end, long incr,
				long chunk_size, long *istart, long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ordered_static_start, "GOMP_loop_ordered_static_start");
	TRACE("[LIBGOMP] GOMP_loop_ordered_static_start@GOMP_X.X.\n");
	
	bool result = lib_GOMP_loop_ordered_static_start(start, end, incr, chunk_size, istart, iend);
	
	return result;
}

/* ------------------------------------------------------------- */
bool GOMP_loop_ordered_dynamic_start (long start, long end, long incr,
				 long chunk_size, long *istart, long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ordered_dynamic_start, "GOMP_loop_ordered_dynamic_start");
	TRACE("[LIBGOMP] GOMP_loop_ordered_dynamic_start@GOMP_X.X.\n");
	
	bool result = lib_GOMP_loop_ordered_dynamic_start(start, end, incr, chunk_size, istart, iend);
	
	return result;
}

/* ------------------------------------------------------------- */
bool GOMP_loop_ordered_guided_start (long start, long end, long incr,
				long chunk_size, long *istart, long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ordered_guided_start, "GOMP_loop_ordered_guided_start");
	TRACE("[LIBGOMP] GOMP_loop_ordered_guided_start@GOMP_X.X.\n");
	
	bool result = lib_GOMP_loop_ordered_guided_start(start, end, incr, chunk_size, istart, iend);
	
	return result;
}

/* ------------------------------------------------------------- */
bool GOMP_loop_ordered_runtime_start (long start, long end, long incr,
				 long *istart, long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ordered_runtime_start, "GOMP_loop_ordered_runtime_start");
	TRACE("[LIBGOMP] GOMP_loop_ordered_runtime_start@GOMP_X.X.\n");
	
	bool result = lib_GOMP_loop_ordered_runtime_start(start, end, incr, istart, iend);
	
	return result;
}

/* ------------------------------------------------------------- */
bool GOMP_loop_static_next (long *istart, long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_static_next, "GOMP_loop_static_next");
	TRACE("[LIBGOMP] GOMP_loop_static_next@GOMP_X.X.\n");
	
	// bool result = lib_GOMP_loop_static_next(istart, iend);
	// bool result = HOOKOMP_generic_next(istart, iend, lib_GOMP_loop_static_next);
	chunk_next_fn func_proxy;
	Params p;	

	p._0 = 0;
	p._1 = 0;
	p._2 = 0;
	p._3 = 0;

	p.func_next = lib_GOMP_loop_static_next;
	p.func_type = FUN_NEXT;

	func_proxy = &HOOKOMP_proxy_function_next;

	bool result = HOOKOMP_generic_next(istart, iend, func_proxy, &p);
	
	return result;
}

/* ------------------------------------------------------------- */
bool GOMP_loop_dynamic_next (long *istart, long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_dynamic_next, "GOMP_loop_dynamic_next");
	TRACE("[LIBGOMP] GOMP_loop_dynamic_next@GOMP_X.X.\n");
	
	// bool result = lib_GOMP_loop_dynamic_next(istart, iend);
	// HOOKOMP_generic_next(&istart, &iend, func, &p);
	chunk_next_fn func_proxy;
	Params p;	

	p._0 = 0;
	p._1 = 0;
	p._2 = 0;
	p._3 = 0;

	p.func_next = lib_GOMP_loop_dynamic_next;
	p.func_type = FUN_NEXT;

	func_proxy = &HOOKOMP_proxy_function_next;

	bool result = HOOKOMP_generic_next(istart, iend, func_proxy, &p);	
	
	return result;
}

/* ------------------------------------------------------------- */
bool GOMP_loop_guided_next (long *istart, long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_guided_next, "GOMP_loop_guided_next");
	TRACE("[LIBGOMP] GOMP_loop_guided_next@GOMP_X.X.\n");
	
	// bool result = lib_GOMP_loop_guided_next(istart, iend);
	// bool result = HOOKOMP_generic_next(istart, iend, lib_GOMP_loop_guided_next);

	chunk_next_fn func_proxy;
	Params p;	

	p._0 = 0;
	p._1 = 0;
	p._2 = 0;
	p._3 = 0;

	p.func_next = lib_GOMP_loop_guided_next;
	p.func_type = FUN_NEXT;

	func_proxy = &HOOKOMP_proxy_function_next;

	bool result = HOOKOMP_generic_next(istart, iend, func_proxy, &p);

	return result;
}

/* ------------------------------------------------------------- */
bool GOMP_loop_runtime_next (long *istart, long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_runtime_next, "GOMP_loop_runtime_next");
	TRACE("[LIBGOMP] GOMP_loop_runtime_next@GOMP_X.X.\n");

	TRACE("[HOOKOMP]: Thread [%lu] is calling %s.\n", (long int) pthread_self(), __FUNCTION__);

	//bool result = HOOKOMP_generic_next(istart, iend, lib_GOMP_loop_runtime_next);

	chunk_next_fn func_proxy;
	Params p;	

	p._0 = 0;
	p._1 = 0;
	p._2 = 0;
	p._3 = 0;

	p.func_next = lib_GOMP_loop_runtime_next;
	p.func_type = FUN_NEXT;

	func_proxy = &HOOKOMP_proxy_function_next;

	bool result = HOOKOMP_generic_next(istart, iend, func_proxy, &p);

	return result;
}

/* ------------------------------------------------------------- */
bool GOMP_loop_ordered_static_next (long *istart, long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ordered_static_next, "GOMP_loop_ordered_static_next");
	TRACE("[LIBGOMP] GOMP_loop_ordered_static_next@GOMP_X.X.\n");
	
	bool result = lib_GOMP_loop_ordered_static_next(istart, iend);
	
	return result;
}

/* ------------------------------------------------------------- */
bool GOMP_loop_ordered_dynamic_next (long *istart, long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ordered_dynamic_next, "GOMP_loop_ordered_dynamic_next");
	TRACE("[LIBGOMP] GOMP_loop_ordered_dynamic_next@GOMP_X.X.\n");
	
	bool result = lib_GOMP_loop_ordered_dynamic_next(istart, iend);
	
	return result;
}

/* ------------------------------------------------------------- */
bool GOMP_loop_ordered_guided_next (long *istart, long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ordered_guided_next, "GOMP_loop_ordered_guided_next");
	TRACE("[LIBGOMP] GOMP_loop_ordered_guided_next@GOMP_X.X.\n");
	
	bool result = lib_GOMP_loop_ordered_guided_next(istart, iend);
	
	return result;
}

/* ------------------------------------------------------------- */
bool GOMP_loop_ordered_runtime_next (long *istart, long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ordered_runtime_next, "GOMP_loop_ordered_runtime_next");
	TRACE("[LIBGOMP] GOMP_loop_ordered_runtime_next@GOMP_X.X.\n");
	
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

	TRACE("[LIBGOMP] GOMP_parallel_loop_static_start@GOMP_X.X.[%p]\n", (void* )fn);
	
	TRACE("[LIBGOMP] lib_GOMP_parallel_loop_static_start[%p]\n", (void* )lib_GOMP_parallel_loop_static_start);

	lib_GOMP_parallel_loop_static_start(fn, data, num_threads, start, end, incr, chunk_size);
}

/* ------------------------------------------------------------- */
void GOMP_parallel_loop_dynamic_start (void (*fn) (void *), void *data,
				  unsigned num_threads, long start, long end,
				  long incr, long chunk_size){
	PRINT_FUNC_NAME;

	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_parallel_loop_dynamic_start, "GOMP_parallel_loop_dynamic_start");

	TRACE("[LIBGOMP] GOMP_parallel_loop_dynamic_start@GOMP_X.X.[%p]\n", (void* )fn);
	
	TRACE("[LIBGOMP] lib_GOMP_parallel_loop_dynamic_start[%p]\n", (void* )lib_GOMP_parallel_loop_dynamic_start);

	// sem_init(&mutex_hookomp_init, 0, 1);
	HOOKOMP_parallel_start();

	// Initializations.
	HOOKOMP_initialization(start, end, num_threads);

	lib_GOMP_parallel_loop_dynamic_start(fn, data, num_threads, start, end, incr, chunk_size);
}

/* ------------------------------------------------------------- */
void GOMP_parallel_loop_guided_start (void (*fn) (void *), void *data,
				 unsigned num_threads, long start, long end,
				 long incr, long chunk_size){
	PRINT_FUNC_NAME;

	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_parallel_loop_guided_start, "GOMP_parallel_loop_guided_start");

	TRACE("[LIBGOMP] GOMP_parallel_loop_guided_start@GOMP_X.X.[%p]\n", (void* )fn);
	
	TRACE("[LIBGOMP] lib_GOMP_parallel_loop_guided_start[%p]\n", (void* )lib_GOMP_parallel_loop_guided_start);

	// sem_init(&mutex_hookomp_init, 0, 1);
	HOOKOMP_parallel_start();

	// Initializations.
	HOOKOMP_initialization(start, end, num_threads);

	lib_GOMP_parallel_loop_guided_start(fn, data, num_threads, start, end, incr, chunk_size);
}

/* ------------------------------------------------------------- */
void GOMP_parallel_loop_runtime_start (void (*fn) (void *), void *data,
				  unsigned num_threads, long start, long end,
				  long incr){
	PRINT_FUNC_NAME;

	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_parallel_loop_runtime_start, "GOMP_parallel_loop_runtime_start");

	TRACE("[LIBGOMP] GOMP_parallel_loop_runtime_start@GOMP_X.X.[%p]\n", (void* )fn);
	
	TRACE("[LIBGOMP] lib_GOMP_parallel_loop_runtime_start[%p]\n", (void* )lib_GOMP_parallel_loop_runtime_start);

	// sem_init(&mutex_hookomp_init, 0, 1);
	HOOKOMP_parallel_start();

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

	TRACE("[LIBGOMP] lib_GOMP_parallel_loop_static[%p]\n", (void* )lib_GOMP_parallel_loop_static);

	lib_GOMP_parallel_loop_static(fn, data, num_threads, start, end, incr, chunk_size, flags);
}

/* ------------------------------------------------------------- */
void GOMP_parallel_loop_dynamic (void (*fn) (void *), void *data,
				unsigned num_threads, long start, long end,
				long incr, long chunk_size, unsigned flags){
	PRINT_FUNC_NAME;

	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_parallel_loop_dynamic, "GOMP_parallel_loop_dynamic");

	TRACE("[LIBGOMP] lib_GOMP_parallel_loop_dynamic[%p]\n", (void* )lib_GOMP_parallel_loop_dynamic);

	lib_GOMP_parallel_loop_dynamic(fn, data, num_threads, start, end, incr, chunk_size, flags);
}

/* ------------------------------------------------------------- */
void GOMP_parallel_loop_guided (void (*fn) (void *), void *data,
			  unsigned num_threads, long start, long end,
			  long incr, long chunk_size, unsigned flags){
	PRINT_FUNC_NAME;

	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_parallel_loop_guided, "GOMP_parallel_loop_guided");

	TRACE("[LIBGOMP] lib_GOMP_parallel_loop_guided[%p]\n", (void* )lib_GOMP_parallel_loop_guided);

	lib_GOMP_parallel_loop_guided(fn, data, num_threads, start, end, incr, chunk_size, flags);
}

/* ------------------------------------------------------------- */
void GOMP_parallel_loop_runtime (void (*fn) (void *), void *data,
				unsigned num_threads, long start, long end,
				long incr, unsigned flags){
	PRINT_FUNC_NAME;

	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_parallel_loop_runtime, "GOMP_parallel_loop_runtime");

	TRACE("[LIBGOMP] lib_GOMP_parallel_loop_runtime[%p]\n", (void* )lib_GOMP_parallel_loop_runtime);

	lib_GOMP_parallel_loop_runtime(fn, data, num_threads, start, end, incr, flags);
}

/* ------------------------------------------------------------- */
void GOMP_loop_end (void){
	PRINT_FUNC_NAME;

	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_end, "GOMP_loop_end");

	TRACE("[LIBGOMP] lib_GOMP_loop_end[%p]\n", (void* )lib_GOMP_loop_end);

	HOOKOMP_loop_end();

	lib_GOMP_loop_end();


}
/* ------------------------------------------------------------- */
void GOMP_loop_end_nowait (void){
	PRINT_FUNC_NAME;

	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_end_nowait, "GOMP_loop_end_nowait");

	TRACE("[LIBGOMP] lib_GOMP_loop_end_nowait[%p]\n", (void* )GOMP_loop_end_nowait);

	TRACE("[HOOKOMP]: Thread [%lu] is calling %s.\n", (long int) pthread_self(), __FUNCTION__);

	HOOKOMP_loop_end_nowait();

	lib_GOMP_loop_end_nowait();
}

/* ------------------------------------------------------------- */
bool GOMP_loop_end_cancel (void){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_end_cancel, "GOMP_loop_end_cancel");
	TRACE("[LIBGOMP] GOMP_loop_end_cancel@GOMP_X.X.\n");
	
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
	TRACE("[LIBGOMP] GOMP_loop_ull_static_start@GOMP_X.X.\n");
	
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
	TRACE("[LIBGOMP] GOMP_loop_ull_dynamic_start@GOMP_X.X.\n");
	
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
	TRACE("[LIBGOMP] GOMP_loop_ull_guided_start@GOMP_X.X.\n");
	
	bool result = lib_GOMP_loop_ull_guided_start(up, start, end, incr, chunk_size, istart, iend);
	
	return result;
}

/* ------------------------------------------------------------- */
bool GOMP_loop_ull_runtime_start (bool up, unsigned long long start, unsigned long long end,
				 unsigned long long incr, unsigned long long *istart, unsigned long long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ull_runtime_start, "GOMP_loop_ull_runtime_start");
	TRACE("[LIBGOMP] GOMP_loop_ull_runtime_start@GOMP_X.X.\n");
	
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
	TRACE("[LIBGOMP] GOMP_loop_ull_ordered_static_start@GOMP_X.X.\n");
	
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
	TRACE("[LIBGOMP] GOMP_loop_ull_ordered_dynamic_start@GOMP_X.X.\n");
	
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
	TRACE("[LIBGOMP] GOMP_loop_ull_ordered_guided_start@GOMP_X.X.\n");
	
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
	TRACE("[LIBGOMP] GOMP_loop_ull_ordered_runtime_start@GOMP_X.X.\n");
	
	bool result = lib_GOMP_loop_ull_ordered_runtime_start(up, start, end, incr, istart, iend);
	
	return result;
}

/* ------------------------------------------------------------- */
bool GOMP_loop_ull_static_next (unsigned long long *istart, unsigned long long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ull_static_next, "GOMP_loop_ull_static_next");
	TRACE("[LIBGOMP] GOMP_loop_ull_static_next@GOMP_X.X.\n");
	
	bool result = lib_GOMP_loop_ull_static_next(istart, iend);
	
	return result;
}

/* ------------------------------------------------------------- */
bool GOMP_loop_ull_dynamic_next (unsigned long long *istart, unsigned long long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ull_dynamic_next, "GOMP_loop_ull_dynamic_next");
	TRACE("[LIBGOMP] GOMP_loop_ull_dynamic_next@GOMP_X.X.\n");
	
	bool result = lib_GOMP_loop_ull_dynamic_next(istart, iend);
	
	return result;
}

/* ------------------------------------------------------------- */
bool GOMP_loop_ull_guided_next (unsigned long long *istart, unsigned long long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ull_guided_next, "GOMP_loop_ull_guided_next");
	TRACE("[LIBGOMP] GOMP_loop_ull_guided_next@GOMP_X.X.\n");
	
	bool result = lib_GOMP_loop_ull_guided_next(istart, iend);
	
	return result;
}

/* ------------------------------------------------------------- */
bool GOMP_loop_ull_runtime_next (unsigned long long *istart, unsigned long long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ull_runtime_next, "GOMP_loop_ull_runtime_next");
	TRACE("[LIBGOMP] GOMP_loop_ull_runtime_next@GOMP_X.X.\n");
	
	bool result = lib_GOMP_loop_ull_runtime_next(istart, iend);
	
	return result;
}

/* ------------------------------------------------------------- */
bool GOMP_loop_ull_ordered_static_next (unsigned long long *istart, unsigned long long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ull_ordered_static_next, "GOMP_loop_ull_ordered_static_next");
	TRACE("[LIBGOMP] GOMP_loop_ull_ordered_static_next@GOMP_X.X.\n");
	
	bool result = lib_GOMP_loop_ull_ordered_static_next(istart, iend);
	
	return result;
}

/* ------------------------------------------------------------- */
bool GOMP_loop_ull_ordered_dynamic_next (unsigned long long *istart, unsigned long long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ull_ordered_dynamic_next, "GOMP_loop_ull_ordered_dynamic_next");
	TRACE("[LIBGOMP] GOMP_loop_ull_ordered_dynamic_next@GOMP_X.X.\n");
	
	bool result = lib_GOMP_loop_ull_ordered_dynamic_next(istart, iend);
	
	return result;
}

/* ------------------------------------------------------------- */
bool GOMP_loop_ull_ordered_guided_next (unsigned long long *istart, unsigned long long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ull_ordered_guided_next, "GOMP_loop_ull_ordered_guided_next");
	TRACE("[LIBGOMP] GOMP_loop_ull_ordered_guided_next@GOMP_X.X.\n");
	
	bool result = lib_GOMP_loop_ull_ordered_guided_next(istart, iend);
	
	return result;
}

/* ------------------------------------------------------------- */
bool GOMP_loop_ull_ordered_runtime_next (unsigned long long *istart, unsigned long long *iend){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_loop_ull_ordered_runtime_next, "GOMP_loop_ull_ordered_runtime_next");
	TRACE("[LIBGOMP] GOMP_loop_ull_ordered_runtime_next@GOMP_X.X.\n");
	
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
	TRACE("[LIBGOMP] GOMP_ordered_start@GOMP_X.X.\n");
	
	lib_GOMP_ordered_start();
}

/* ------------------------------------------------------------- */
void GOMP_ordered_end (void){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_ordered_end, "GOMP_ordered_end");
	TRACE("[LIBGOMP] GOMP_ordered_end@GOMP_X.X.\n");
	
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

	TRACE("[LIBGOMP] GOMP_parallel_start@GOMP_X.X.[%p]\n", (void* )fn);
	
	TRACE("[LIBGOMP] lib_GOMP_parallel_start[%p]\n", (void* ) lib_GOMP_parallel_start);

	lib_GOMP_parallel_start(fn, data, num_threads);

	// sem_init(&mutex_hookomp_init, 0, 1);
	HOOKOMP_parallel_start();
}

/* ------------------------------------------------------------- */
/* Function to intercept GOMP_parallel_end                       */
void GOMP_parallel_end (void){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_parallel_end, "GOMP_parallel_end");

	TRACE("[LIBGOMP] GOMP_parallel_end@GOMP_X.X [%p]\n", (void* ) lib_GOMP_parallel_end);

	/* In cases of benchmark have two loops inside the same parallel region. The second was ignored, because the control had no reinitilized. */
	if(is_hookomp_initialized){
		HOOKOMP_parallel_end();	
	}
	
	lib_GOMP_parallel_end();
}

/* ------------------------------------------------------------- */
void GOMP_parallel (void (*fn) (void *), void *data, unsigned num_threads, unsigned int flags){
	PRINT_FUNC_NAME;

	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_parallel, "GOMP_parallel");

	TRACE("[LIBGOMP] GOMP_parallel@GOMP_X.X.[%p]\n", (void* )fn);
	
	TRACE("[LIBGOMP] lib_GOMP_parallel[%p]\n", (void* )lib_GOMP_parallel);

	lib_GOMP_parallel(fn, data, num_threads, flags);
}

/* ------------------------------------------------------------- */
bool GOMP_cancel (int which, bool do_cancel){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_cancel, "GOMP_cancel");
	TRACE("[LIBGOMP] GOMP_cancel@GOMP_X.X.\n");
	
	bool result = lib_GOMP_cancel(which, do_cancel);
	
	return result;
}

/* ------------------------------------------------------------- */
bool GOMP_cancellation_point (int which){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_cancellation_point, "GOMP_cancellation_point");
	TRACE("[LIBGOMP] GOMP_cancellation_point@GOMP_X.X.\n");
	
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

	TRACE("[LIBGOMP] GOMP_task@GOMP_X.X.[%p]\n", (void* )fn);
	
	TRACE("[LIBGOMP] lib_GOMP_task[%p]\n", (void* )lib_GOMP_task);

	lib_GOMP_task(fn, data, cpyfn, arg_size, arg_align, if_clause, flags, depend);
}

/* ------------------------------------------------------------- */
void GOMP_taskwait (void){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_taskwait, "GOMP_taskwait");
	TRACE("[LIBGOMP] GOMP_taskwait@GOMP_X.X.\n");
	
	lib_GOMP_taskwait();
}

/* ------------------------------------------------------------- */
void GOMP_taskyield (void){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_taskyield, "GOMP_taskyield");
	TRACE("[LIBGOMP] GOMP_taskyield@GOMP_X.X.\n");
	
	lib_GOMP_taskyield();
}

/* ------------------------------------------------------------- */
void GOMP_taskgroup_start (void){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_taskgroup_start, "GOMP_taskgroup_start");
	TRACE("[LIBGOMP] GOMP_taskgroup_start@GOMP_X.X.\n");
	
	lib_GOMP_taskgroup_start();
}

/* ------------------------------------------------------------- */
void GOMP_taskgroup_end (void){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_taskgroup_end, "GOMP_taskgroup_end");
	TRACE("[LIBGOMP] GOMP_taskgroup_end@GOMP_X.X.\n");
	
	lib_GOMP_taskgroup_end();
}

/* ------------------------------------------------------------- */
/* sections.c */
/* ------------------------------------------------------------- */
unsigned GOMP_sections_start (unsigned count){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_sections_start, "GOMP_sections_start");
	TRACE("[LIBGOMP] GOMP_sections_start@GOMP_X.X.\n");
	
	unsigned result = lib_GOMP_sections_start(count);
	
	return result;
}

/* ------------------------------------------------------------- */
unsigned GOMP_sections_next (void){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_sections_next, "GOMP_sections_next");
	TRACE("[LIBGOMP] GOMP_sections_next@GOMP_X.X.\n");
	
	unsigned result = lib_GOMP_sections_next();
	
	return result;
}

/* ------------------------------------------------------------- */
void GOMP_parallel_sections_start (void (*fn) (void *), void *data,
				  unsigned num_threads, unsigned count){
	PRINT_FUNC_NAME;

	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_parallel_sections_start, "GOMP_parallel_sections_start");

	TRACE("[LIBGOMP] GOMP_parallel_sections_start@GOMP_X.X.[%p]\n", (void* )fn);
	
	TRACE("[LIBGOMP] lib_GOMP_parallel_sections_start[%p]\n", (void* )lib_GOMP_parallel_sections_start);

	lib_GOMP_parallel_sections_start(fn, data, num_threads, count);
}

/* ------------------------------------------------------------- */
void GOMP_parallel_sections (void (*fn) (void *), void *data,
			unsigned num_threads, unsigned count, unsigned flags){
	PRINT_FUNC_NAME;

	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_parallel_sections, "GOMP_parallel_sections");

	TRACE("[LIBGOMP] GOMP_parallel_sections@GOMP_X.X.[%p]\n", (void* )fn);
	
	TRACE("[LIBGOMP] lib_GGOMP_parallel_sections[%p]\n", (void* )lib_GOMP_parallel_sections);

	lib_GOMP_parallel_sections(fn, data, num_threads, count, flags);
}

/* ------------------------------------------------------------- */
void GOMP_sections_end (void){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_sections_end, "GOMP_sections_end");
	TRACE("[LIBGOMP] GOMP_sections_end@GOMP_X.X.\n");
	
	lib_GOMP_sections_end();
}
	
/* ------------------------------------------------------------- */
void GOMP_sections_end_nowait (void){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_sections_end_nowait, "GOMP_sections_end_nowait");
	TRACE("[LIBGOMP] GOMP_sections_end_nowait@GOMP_X.X.\n");
	
	lib_GOMP_sections_end_nowait();
}
	
/* ------------------------------------------------------------- */
bool GOMP_sections_end_cancel (void){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_sections_end_cancel, "GOMP_sections_end_cancel");
	TRACE("[LIBGOMP] GOMP_sections_end_cancel@GOMP_X.X.\n");
	
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

   TRACE("[LIBGOMP] GOMP_single_start@GOMP_X.X.\n");
   bool result = lib_GOMP_single_start();

   return result;
}

/* ------------------------------------------------------------- */
void *GOMP_single_copy_start (void){
	PRINT_FUNC_NAME;

	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_single_copy_start, "GOMP_single_copy_start");
	TRACE("[LIBGOMP] GOMP_single_copy_start@GOMP_X.X.\n");
	
	void *result;

	result = lib_GOMP_single_copy_start();

	return result;
}

/* ------------------------------------------------------------- */
void GOMP_single_copy_end (void *data){

	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_single_copy_end, "GOMP_single_copy_end");
	TRACE("[LIBGOMP] GOMP_single_copy_end@GOMP_X.X.\n");
	
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
	TRACE("[LIBGOMP] GOMP_target@GOMP_X.X.\n");
	
	lib_GOMP_target(device, fn, unused, mapnum, hostaddrs, sizes, kinds);
}

/* ------------------------------------------------------------- */
void GOMP_target_data (int device, const void *unused, size_t mapnum,
		  void **hostaddrs, size_t *sizes, unsigned char *kinds){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_target_data, "GOMP_target_data");
	TRACE("[LIBGOMP] GOMP_target_data@GOMP_X.X.\n");
	
	lib_GOMP_target_data(device, unused, mapnum, hostaddrs, sizes, kinds);
}

/* ------------------------------------------------------------- */
void GOMP_target_end_data (void){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_target_end_data, "GOMP_target_end_data");
	TRACE("[LIBGOMP] GOMP_target_end_data@GOMP_X.X.\n");
	
	lib_GOMP_target_end_data();
}

/* ------------------------------------------------------------- */
void GOMP_target_update (int device, const void *unused, size_t mapnum,
			void **hostaddrs, size_t *sizes, unsigned char *kinds){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_target_update, "GOMP_target_update");
	TRACE("[LIBGOMP] GOMP_target_update@GOMP_X.X.\n");
	
	lib_GOMP_target_update(device, unused, mapnum, hostaddrs, sizes, kinds);
}

/* ------------------------------------------------------------- */
void GOMP_teams (unsigned int num_teams, unsigned int thread_limit){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOMP_teams, "GOMP_teams");
	TRACE("[LIBGOMP] GOMP_teams@GOMP_X.X.\n");
	
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
	TRACE("[LIBGOMP] GOACC_data_start@GOMP_X.X.\n");
	
	lib_GOACC_data_start(device, mapnum, hostaddrs, sizes, kinds);
}
*/
/* ------------------------------------------------------------- */
/*
void GOACC_data_end (void){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOACC_data_end, "GOACC_data_end");
	TRACE("[LIBGOMP] GOACC_data_end@GOMP_X.X.\n");
	
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
	TRACE("[LIBGOMP] GOACC_enter_exit_data@GOMP_X.X.\n");
	
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
	TRACE("[LIBGOMP] GOACC_parallel@GOMP_X.X.\n");
	
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
	TRACE("[LIBGOMP] GOACC_update@GOMP_X.X.\n");
	
	lib_GOACC_update(device, mapnum, hostaddrs, sizes, kinds, async, num_waits, ...);
}
*/
/* ------------------------------------------------------------- */
/*
void GOACC_wait (int async, int num_waits, ...){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOACC_wait, "GOACC_wait");
	TRACE("[LIBGOMP] GOACC_wait@GOMP_X.X.\n");
	
	lib_GOACC_wait(async, num_waits, ...);
}
*/	
/* ------------------------------------------------------------- */
/*
int GOACC_get_num_threads (void){
	PRINT_FUNC_NAME;
	
	// Retrieve the OpenMP runtime function.
	GET_RUNTIME_FUNCTION(lib_GOACC_get_num_threads, "GOACC_get_num_threads");
	TRACE("[LIBGOMP] GOACC_get_num_threads@GOMP_X.X.\n");
	
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
	TRACE("[LIBGOMP] GOACC_get_thread_num@GOMP_X.X.\n");
	
	int result = lib_GOACC_get_thread_num();
	
	return result;
}
*/
/* ------------------------------------------------------------- */
