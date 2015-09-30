#include "roofline.h"

static pthread_key_t papi_thread_info_key;
static int papi_library_initialized = 0;

/* ------------------------------------------------------------ */
/* Info and Test function.										*/
void info(void) {
	puts("Hello, I'm a shared library.\n");
}

/* ------------------------------------------------------------ */
/* Init library.												*/
bool RM_library_init(void){
	PRINT_FUNC_NAME;
	bool result = true;

	// sem_init(&mutex, 0, 1);      /* initialize mutex to 1 - binary semaphore */
                                 /* second param = 0 - semaphore is local */

	ptr_measure = (struct _papi_thread_record *) malloc(sizeof(struct _papi_thread_record));
	ptr_measure->values = (long_long *) malloc(sizeof(long_long) * NUM_EVENTS);
	ptr_measure->events = (int *) malloc(sizeof(int) * NUM_EVENTS);

	ptr_measure->events[0] = PAPI_TOT_INS;
	ptr_measure->events[1] = PAPI_TOT_CYC;

	// ptr_measure->initial_time = 0;
	// ptr_measure->final_time = 0;
	ptr_measure->EventSet = PAPI_NULL;

	return result;
}

/* ------------------------------------------------------------- */
/* Function to initialization of PAPI Library.                   */
bool RM_initialization_of_papi_libray_mode(){
	PRINT_FUNC_NAME;
	
	int retval;
	pthread_key_create(&papi_thread_info_key, NULL );

	TRACE("[After]: pthread_key_create.\n");

	TRACE("[Before]: PAPI_library_init.\n");
	retval = PAPI_library_init(PAPI_VER_CURRENT);
	if (retval != PAPI_VER_CURRENT && retval > 0){
		TRACE("PAPI_library_init error: %d\n", retval);
		TRACE("PAPI library version mismatch!\n");
		RM_papi_handle_error(__FUNCTION__, retval, __LINE__);
	}

	retval = PAPI_is_initialized();
	switch (retval){
		case PAPI_NOT_INITED :
			TRACE("Library has not been initialized.\n");
			break;
		case PAPI_LOW_LEVEL_INITED : 
			TRACE("Low level has called library init.\n");
			break;
		case PAPI_HIGH_LEVEL_INITED	: 
			TRACE("High level has called library init.\n");
			break;
		case PAPI_THREAD_LEVEL_INITED :
			TRACE("Threads have been inited.\n");
			break;
		default:
			TRACE("Unknown Error.\n");
	}

	while ((retval = PAPI_is_initialized()) != PAPI_LOW_LEVEL_INITED){
		TRACE("Waiting PAPI initialization.\n");
	}

	TRACE("[After]: PAPI_library_init.\n");
	
	//if ((retval = PAPI_thread_init((unsigned long (*)(void)) (pthread_self()))) != PAPI_OK){
	// if ((retval = PAPI_thread_init(&id)) != PAPI_OK){
	// if((retval = PAPI_thread_init((unsigned long (*)(void))(pthread_self())) ) != PAPI_OK){


	TRACE("[Before]: PAPI_thread_init.\n");

	// if((retval = PAPI_thread_init((unsigned long (*)(void))(omp_get_thread_num))) != PAPI_OK){
	if((retval = PAPI_thread_init((unsigned long (*)(void))(pthread_self))) != PAPI_OK){

        RM_papi_handle_error(__FUNCTION__, retval, __LINE__);
        if (retval == PAPI_ESBSTR)
			TRACE("PAPI_thread_init error: %d\n", retval);
	}

	unsigned long int tid = PAPI_thread_id();

	TRACE("[After]: PAPI_thread_init: %lu\n", tid);

	// __papi_init_counter_ids();
    // __papi_select_counters();

	papi_library_initialized = 1;

	TRACE("RM_initialization_of_papi_libray_mode: %d\n", papi_library_initialized);

	return (retval == PAPI_OK);
}

/* ------------------------------------------------------------ */
/* Error handle to papi.								*/
/*void RM_papi_handle_error(char* function_name, int n_error, int n_line){
	PRINT_FUNC_NAME;

	TRACE("%s [%d]: PAPI error %d: %s\n", function_name, n_line, n_error, PAPI_strerror(n_error));
}*/

/* ------------------------------------------------------------ */
/* Print the counters and values.								*/
void RM_print_counters_values(void) {
	PRINT_FUNC_NAME;
	int i;
	char event_str[PAPI_MAX_STR_LEN];

	for (i = 0; i < NUM_EVENTS; i++) {
		PAPI_event_code_to_name(ptr_measure->events[i], event_str);
		TRACE("Event: %x- %s : %lld\n", ptr_measure->events[i], event_str, ptr_measure->values[i]);
	}
}

/* ------------------------------------------------------------ */
/* Start counters.												*/
bool RM_start_counters (void){
	PRINT_FUNC_NAME;
	
	int i, retval, result;
  	unsigned long int tid;

	// retval = PAPI_thread_init((unsigned long (*)(void)) (lib_GOMP_get_thread_num));
	/* The OpenMP call omp_get_thread_num() violates this rule, as the underlying LWPs may 
	 * have been killed off by the run-time system or by a call to omp_set_num_threads() . 
	 * In that case, it may still possible to use omp_get_thread_num() in conjunction with 
	 * PAPI_unregister_thread() when the OpenMP thread has finished. However it is much 
	 * better to use the underlying thread subsystem's call, which is pthread_self() 
	 * on Linux platforms. */

	/* Initialize RM library. */
	// sem_wait(&mutex);       /* down semaphore */

	if(!papi_library_initialized){
  		TRACE("[Before] RM_start_counters: papi_library_initialized: %d\n",papi_library_initialized);
  		result = RM_initialization_of_papi_libray_mode();
  		TRACE("[After] RM_start_counters: %d, papi_library_initialized: %d\n", result, papi_library_initialized);
  	}

  	// sem_post(&mutex);       /* up semaphore */

  	// sem_destroy(&mutex); 	/* destroy semaphore */

  	TRACE("[%s] [Before] PAPI_register_thread.\n", __FUNCTION__);

  	if((retval = PAPI_register_thread()) != PAPI_OK){
        RM_papi_handle_error(__FUNCTION__, retval, __LINE__);
        switch (retval){
        	case PAPI_ENOMEM :
        		TRACE("Space could not be allocated to store the new thread information.\n");
        		break;
			case PAPI_ESYS :
				TRACE("A system or C library call failed inside PAPI, see the errno variable.\n");
				break;
			case PAPI_ECMP :
				TRACE("Hardware counters for this thread could not be initialized.\n");
				break;
			default :
				TRACE("PAPI_register_thread: Unknown error.\n");
        }
	}

	TRACE("[%s] [After] PAPI_register_thread.\n", __FUNCTION__);

	//while ((retval = PAPI_is_initialized()) != PAPI_LOW_LEVEL_INITED){
	//	TRACE("Waiting PAPI initialization.\n");
	//	// RM_papi_handle_error(__FUNCTION__, retval, __LINE__);
	//	exit(1);
	//}

	if ((tid = PAPI_thread_id()) == (unsigned long int)-1){
		TRACE("[RM_start_counters] PAPI_thread_id error.\n");
		RM_papi_handle_error(__FUNCTION__, retval, __LINE__);
	}
	else 
		TRACE("[RM_start_counters] Thread id is: %lu\n", tid);

	/* Create an EventSet */
  	if ((retval = PAPI_create_eventset(&ptr_measure->EventSet)) != PAPI_OK){
    	TRACE("[RM_start_counters] PAPI_create_eventset error.\n");
    	RM_papi_handle_error(__FUNCTION__, retval, __LINE__);
  	}

	/* Add Total Instructions Executed to our EventSet */
  	//if (PAPI_add_event(EventSet, PAPI_TOT_INS) != PAPI_OK)
	//	TRACE("PAPI_add_event error PAPI_TOT_INS.\n");
	
	//if (PAPI_add_event(EventSet, PAPI_TOT_CYC) != PAPI_OK)
	//	TRACE("PAPI_add_event error PAPI_TOT_CYC.\n");

	/* Add events to EventSet */
  	char event_str[PAPI_MAX_STR_LEN];

	for (i = 0; i < NUM_EVENTS; i++) {
		retval = PAPI_add_event(ptr_measure->EventSet, ptr_measure->events[i]);
		PAPI_event_code_to_name(ptr_measure->events[i], event_str);
		TRACE("[RM_start_counters] PAPI_add_event: %x - %s.\n", ptr_measure->events[i], event_str);
	    if(retval != PAPI_OK) {
	      RM_papi_handle_error(__FUNCTION__, retval, __LINE__);
	    }
	}

	/* Start counting */
  	if ((retval = PAPI_start(ptr_measure->EventSet)) != PAPI_OK) {
		TRACE("[RM_start_counters] PAPI_start() Starting counting error.\n");
		RM_papi_handle_error(__FUNCTION__, retval, __LINE__);

		if (retval == PAPI_ECNFLCT) {
	      TRACE("[RM_start_counters] PAPI error %d (%s): It is likely that you selected too many counters to monitor.\n",
		      retval, PAPI_strerror(retval));
	    }
  	}

  	/* First measure. */
  	if ((retval = PAPI_stop(ptr_measure->EventSet, ptr_measure->values)) != PAPI_OK) {
  		RM_papi_handle_error(__FUNCTION__, retval, __LINE__);
	    TRACE("[RM_start_counters] PAPI_stop() counting first measure error.\n");
	}

	/* Gets the starting time in clock cycles */
	ptr_measure->start_cycles = PAPI_get_real_cyc();

	/* Gets the starting time in microseconds */
	ptr_measure->start_usec = PAPI_get_real_usec();

	/* Final measure. */
	if ((retval = PAPI_start(ptr_measure->EventSet)) != PAPI_OK) {
		RM_papi_handle_error(__FUNCTION__, retval, __LINE__);
		TRACE("[RM_start_counters] PAPI_start() counting in final measure error.\n");
	}

	return (retval == PAPI_OK);
}

/* ------------------------------------------------------------ */
/* Stop counters.												*/
bool RM_stop_counters(void){
	PRINT_FUNC_NAME;
	
	int retval_stop, retval_read = PAPI_OK;

	/* Stop counters and store results in values */
	// int retval = PAPI_stop_counters(ptr_measure->values, NUM_EVENTS);
	if ((retval_stop = PAPI_stop(ptr_measure->EventSet, ptr_measure->values)) != PAPI_OK){
	//if ((retval_stop = PAPI_stop_counters(ptr_measure->values, NUM_EVENTS)) != PAPI_OK){
		TRACE("Error on PAPI execution.\n");
		RM_papi_handle_error(__FUNCTION__, retval_stop, __LINE__);
		// exit(1);
		switch (retval_stop){
				case PAPI_EINVAL :
					TRACE("One or more of the arguments is invalid.\n");
					break;
				case PAPI_ENOTRUN : 
					TRACE("The EventSet is not started yet.\n");
					break;
				case PAPI_ENOEVST : 
					TRACE("The EventSet has not been added yet.\n");
					break;
			default:
				TRACE("Unknown Error.\n");
		}
	}

	/* Read the counters */
	if ((retval_read = PAPI_read(ptr_measure->EventSet, ptr_measure->values)) != PAPI_OK){
        TRACE("PAPI_read error reading counters.\n");
        RM_papi_handle_error(__FUNCTION__, retval_read, __LINE__);
    }

    if((retval_stop == PAPI_OK) && (retval_read == PAPI_OK) ){
    	/* Gets the ending time in clock cycles */
		ptr_measure->end_cycles = PAPI_get_real_cyc();

		/* Gets the ending time in microseconds */
		ptr_measure->end_usec = PAPI_get_real_usec();
		
		TRACE("Wall clock cycles: \t\t\t%lld\n", ptr_measure->end_cycles - ptr_measure->start_cycles );
		TRACE("Wall clock time in microseconds: \t%lld\n", ptr_measure->end_usec - ptr_measure->start_usec );
		
		/* Read the counters */
	    //if (PAPI_read(ptr_measure->EventSet, ptr_measure->values) != PAPI_OK)
	    //	TRACE("PAPI_read error reading counters.\n");

		//TRACE("After reading counters:\n");
		//RM_print_counters_values();

	    /* Stop the counters */
	    //if (PAPI_stop(ptr_measure->EventSet, ptr_measure->values) != PAPI_OK)
	    //	TRACE("PAPI_read error stopping counters.\n");
		 
		TRACE("After stopping counters:\n");
	    RM_print_counters_values();	
    }    	

	return ((retval_stop == PAPI_OK) && (retval_read == PAPI_OK));
}

/* ------------------------------------------------------------ */
/* Calculate the Operational Intensity.							*/
double RM_get_operational_intensity(void){
	PRINT_FUNC_NAME;

	double oi = 0.0;

	oi = ptr_measure->values[0] / 1000;

	return oi;
}

/* ------------------------------------------------------------ */
/* Better Device to execution.									*/
int RM_get_better_device_to_execution(void){
	PRINT_FUNC_NAME;
	
	return 1;
}

/* ------------------------------------------------------------ */
/* Better Device to execution.									*/
bool RM_decision_about_offloading(void){
	PRINT_FUNC_NAME;
	
	return false;
}
/* ------------------------------------------------------------ */
