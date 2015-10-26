#include "roofline.h"

static pthread_key_t papi_thread_info_key;
static bool papi_library_initialized = false;

static bool papi_eventset_was_created = false;

static bool thread_was_registred_in_papi = false;

static bool started_measuring = false;

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
	int i;

	/*Create the structures to get measures. */
	ptr_measure = (struct _papi_thread_record *) malloc(sizeof(struct _papi_thread_record));
	ptr_measure->values = (long_long *) malloc(sizeof(long_long) * NUM_EVENTS);
	ptr_measure->events = (int *) malloc(sizeof(int) * NUM_EVENTS);

	TRACE("Setting the defined code events to RM registry.\n");
	for (i = 0; i < NUM_EVENTS; i++) {
		ptr_measure->events[i] = FPO_event_codes[i];
	}

	ptr_measure->initial_time = (struct timeval){0};
	ptr_measure->final_time = (struct timeval){0};
	ptr_measure->EventSet = PAPI_NULL;

	papi_eventset_was_created = false;
	thread_was_registred_in_papi = false;

	TRACE("PAPI Library is initialized: %d\n", papi_library_initialized);
	if(!papi_library_initialized){
  		TRACE("[Before] Value of papi_library_initialized: %d\n",papi_library_initialized);
  		result = RM_initialization_of_papi_libray_mode();
  		TRACE("[After] Value of result: %d, papi_library_initialized: %d\n", result, papi_library_initialized);
  	}

  	/* Thread was registered. */
  	if(!thread_was_registred_in_papi){
  		TRACE("Trying to registry the thread in papi.\n");
  		result = RM_register_papi_thread();
  	}

  	/* Event set was created. */
	if(!papi_eventset_was_created){
		TRACE("Trying to create event set.\n");
		result = RM_create_event_set();
	}

	return result;
}
/* ------------------------------------------------------------ */
/* Register the thread in PAPI.												*/
bool RM_register_papi_thread(void){
	PRINT_FUNC_NAME;
	bool result = true;
	int retval;
	unsigned long int tid = 0;
	TRACE("[%s] [Before] PAPI_register_thread.\n", __FUNCTION__);

	TRACE("[Before]: PAPI_thread_init.\n");

	if((retval = PAPI_thread_init((unsigned long (*)(void))(pthread_self))) != PAPI_OK){
        RM_papi_handle_error(__FUNCTION__, retval, __LINE__);
        if (retval == PAPI_ESBSTR)
			TRACE("PAPI_thread_init error: %d\n", retval);
	}

	tid = PAPI_thread_id();
	TRACE("[After]: PAPI_thread_init: %lu\n", tid);

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
	else{
		thread_was_registred_in_papi = true;
	}

	TRACE("[%s] [After] PAPI_register_thread.\n", __FUNCTION__);

	if ((tid = PAPI_thread_id()) == (unsigned long int)-1){
		TRACE("[RM_start_counters] PAPI_thread_id error.\n");
		RM_papi_handle_error(__FUNCTION__, retval, __LINE__);
	}
	else {
		TRACE("Thread id is: %lu\n", tid);
	}

	return (retval == PAPI_OK);
}

/* ------------------------------------------------------------- */
/* Function to initialization of PAPI Library.                   */
bool RM_initialization_of_papi_libray_mode(){
	PRINT_FUNC_NAME;
	
	int retval;
	pthread_key_create(&papi_thread_info_key, NULL );

	TRACE("[After]: pthread_key_create.\n");

	TRACE("[Before]: Calling PAPI_library_init().\n");
	retval = PAPI_library_init(PAPI_VER_CURRENT);
	if (retval != PAPI_VER_CURRENT && retval > 0){
		TRACE("PAPI_library_init error: %d\n", retval);
		TRACE("PAPI library version mismatch!\n");
		RM_papi_handle_error(__FUNCTION__, retval, __LINE__);
	}

	while ((retval = PAPI_is_initialized()) != PAPI_LOW_LEVEL_INITED){
		TRACE("Waiting PAPI initialization.\n");
		RM_papi_handle_error(__FUNCTION__, retval, __LINE__);
	}
	/*switch (retval){
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
	}*/

	papi_library_initialized = (retval == PAPI_LOW_LEVEL_INITED);

	TRACE("[After]: PAPI_library_init. Value of papi_library_initialized: %d\n", papi_library_initialized);

	/* Enable and initialize multiplex support */
	TRACE("[Before]: Trying to start the multiplex mode. Calling PAPI_multiplex_init().\n");
  	if ((retval = PAPI_multiplex_init()) != PAPI_OK){
		TRACE("Error in initialization of multiplex mode.\n");
		RM_papi_handle_error(__FUNCTION__, retval, __LINE__);
	}

	return (retval == PAPI_OK);
}

/* ------------------------------------------------------------ */
/* Print event info.											*/
void RM_print_event_info(unsigned int event){
	PRINT_FUNC_NAME;

	PAPI_event_info_t info;
	/* Get details about event. */
	if (PAPI_get_event_info(event, &info) != PAPI_OK) {
		TRACE("No info about the event.\n");
	}
	else{
		if (info.count > 0){
			TRACE("This event is available on this hardware.\n");
		}
		// More infos.
	}
}
/* ------------------------------------------------------------ */
/* Check if available event.									*/
bool RM_check_event_is_available(unsigned int event, bool print_it){
	PRINT_FUNC_NAME;
	int retval;
	char event_str[PAPI_MAX_STR_LEN];
	
	/* Check to see if the event exists */
	if((retval = PAPI_query_event (event)) == PAPI_OK){
		PAPI_event_code_to_name(event, event_str);
		TRACE("Event: %x - %s is available.\n", event, event_str);

		if(print_it){
			RM_print_event_info(event);
		}
	}
	else{
		TRACE("Event %x is not available.\n");
	}	

	return (retval == PAPI_OK);
}

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
/* PAPI Status.													*/
void RM_check_papi_status(){
	PRINT_FUNC_NAME;
	int retval;

	int status = 0;
	if((retval = PAPI_state(ptr_measure->EventSet, &status)) != PAPI_OK){
		switch (retval){
			case PAPI_STOPPED :
				TRACE("EventSet is stopped.\n");
				break;
			case PAPI_RUNNING :
				TRACE("EventSet is running.\n");
				break;
			case PAPI_PAUSED :
				TRACE("EventSet temporarily disabled by the library.\n"); 
				break;
			case PAPI_NOT_INIT :
				TRACE("EventSet defined, but not initialized.\n");
				break;
    		case PAPI_OVERFLOWING :
				TRACE("EventSet has overflowing enabled.\n");
    			break;
		    case PAPI_PROFILING :
				TRACE("EventSet has profiling enabled.\n");
		    	break;
		    case PAPI_MULTIPLEXING :
				TRACE("EventSet has multiplexing enabled.\n");
		    	break;
		//    case PAPI_ACCUMULATING :
		//		TRACE("reserved for future use.\n");
		//    	break;
		//    case PAPI_HWPROFILING :
		//		TRACE("reserved for future use.\n");
		//    	break;
		    defaul: TRACE("Undefined retval.\n");
		} 
	}    
}

/* ------------------------------------------------------------ */
/* Create event set. 											*/
bool RM_create_event_set(void){
	PRINT_FUNC_NAME;
	int i, retval;

	int native = 0x0;

	TRACE("Trying to create PAPI event set.\n");

	/* Create an EventSet */
  	if ((retval = PAPI_create_eventset(&ptr_measure->EventSet)) != PAPI_OK){
    	TRACE("PAPI_create_eventset error.\n");
    	RM_papi_handle_error(__FUNCTION__, retval, __LINE__);
  	}

	/* Add events to EventSet */
  	char event_str[PAPI_MAX_STR_LEN];
  	char error_str[PAPI_MAX_STR_LEN];

	for (i = 0; i < NUM_EVENTS; i++) {
		PAPI_event_code_to_name(ptr_measure->events[i], event_str);
		TRACE("Trying to add event: %x - %s.\n", ptr_measure->events[i], event_str);
		
		if(RM_check_event_is_available(ptr_measure->events[i], true)){
			if ((retval = PAPI_add_event(ptr_measure->EventSet, ptr_measure->events[i])) != PAPI_OK){
				TRACE("Error in PAPI_add_event().\n");
				RM_papi_handle_error(__FUNCTION__, retval, __LINE__);


				retval = PAPI_event_name_to_code("PAPI_DP_OPS", &native);
				TRACE("Event with problem: %x.\n", native);

				// PAPI_perror(retval, error_str, PAPI_MAX_STR_LEN);
  				// TRACE("PAPI_error %d: %s.\n", retval, error_str);

			}
			else{
				PAPI_event_code_to_name(ptr_measure->events[i], event_str);
				TRACE("Event %x - %s was added.\n", ptr_measure->events[i], event_str);
			}			
	    }
	    else{
	    	TRACE("Event: %x - %s is not available in this hardware.\n", ptr_measure->events[i], event_str);
	    }
	}

	/* Convert the ''EventSet'' to a multiplexed event set */
	TRACE("Convert the EventSet to a multiplexed event set.\n");
	if ((retval = PAPI_set_multiplex(ptr_measure->EventSet)) != PAPI_OK){
  		RM_papi_handle_error(__FUNCTION__, retval, __LINE__);
  	}

	papi_eventset_was_created = (retval == PAPI_OK);

	RM_check_papi_status();

	return papi_eventset_was_created;
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
	if(!papi_library_initialized){
  		TRACE("[Before] RM_start_counters: papi_library_initialized: %d\n",papi_library_initialized);
  		result = RM_initialization_of_papi_libray_mode();
  		TRACE("[After] RM_start_counters: %d, papi_library_initialized: %d\n", result, papi_library_initialized);
  	}

  	/* Thread was registered. */
  	if(!thread_was_registred_in_papi){
  		TRACE("Trying to registry the thread in papi.\n");
  		result = RM_register_papi_thread();
  	}

  	/* Event set was created. */
	if(!papi_eventset_was_created){
		TRACE("Trying to create event set.\n");
		result = RM_create_event_set();
	}

	/* Restart the counters. */
	if ((retval = PAPI_reset(ptr_measure->EventSet)) != PAPI_OK) {
		TRACE("PAPI_reset() counters error.\n");
		RM_papi_handle_error(__FUNCTION__, retval, __LINE__);

		// PAPI_ESYS A system or C library call failed inside PAPI, see the errno variable.
		// PAPI_ENOEVST The EventSet specified does not exist. 
		// if (retval == PAPI_ECNFLCT) {
	    //  TRACE("[RM_start_counters] PAPI error %d (%s): It is likely that you selected too many counters to monitor.\n",
		//      retval, PAPI_strerror(retval));
	    // }
  	}

	/* Start counting */
  	if ((retval = PAPI_start(ptr_measure->EventSet)) != PAPI_OK) {
		TRACE("PAPI_start() Starting counting error.\n");
		RM_papi_handle_error(__FUNCTION__, retval, __LINE__);

		/*if (retval == PAPI_ECNFLCT) {
	      TRACE("[RM_start_counters] PAPI error %d (%s): It is likely that you selected too many counters to monitor.\n",
		      retval, PAPI_strerror(retval));
	    }*/
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

	started_measuring = (retval == PAPI_OK);

	return started_measuring;
}

/* ------------------------------------------------------------ */
/* Stop counters.												*/
bool RM_stop_measures(void){
	PRINT_FUNC_NAME;	
	int retval_stop, retval_read = PAPI_OK;

	/* Stop counters and store results in values */
	if ((retval_stop = PAPI_stop(ptr_measure->EventSet, ptr_measure->values)) != PAPI_OK){
		TRACE("Error calling PAPI_stop.\n");
		RM_papi_handle_error(__FUNCTION__, retval_stop, __LINE__);
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
		 
		TRACE("After stopping counters:\n");
	    RM_print_counters_values();	
    }    	

	return ((retval_stop == PAPI_OK) && (retval_read == PAPI_OK));
}

/* ------------------------------------------------------------ */
/* Stop and accumulate.											*/
bool RM_stop_and_accumulate(void){
	PRINT_FUNC_NAME;
	bool retval = false;

	if ((retval = PAPI_accum_counters(ptr_measure->values, NUM_EVENTS)) != PAPI_OK){
		TRACE("PAPI_accum_counters(...) error.\n");
		RM_papi_handle_error(__FUNCTION__, retval, __LINE__);
	}

	return (retval == PAPI_OK);
}

/* ------------------------------------------------------------ */
/* Record measures in intervals between start and stop.			*/
bool RM_registry_measures (void){
	PRINT_FUNC_NAME;
	bool retval = false;

	/* Stop and accumulate for >= second chunks. */
	if(started_measuring){
		if(RM_stop_and_accumulate()){
			TRACE("[HOOKOMP]: Stop and Accumulate.\n");
			retval = true;
		}
		else{
			TRACE("Error calling RM_stop_and_accumulate.\n");
			retval = false;
		}
	}

	/* Start for the next chunk. */
	if(RM_start_counters()){
		TRACE("[HOOKOMP]: PAPI Counters Started.\n");
		retval = true;
	}
	else {
		TRACE("Error calling RM_start_counters.\n");
		retval = false;
	}

	return retval;
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
bool RM_decision_about_offloading(long *better_device_index){
	PRINT_FUNC_NAME;

	bool offload_decision = true;

	double oi = RM_get_operational_intensity();
	TRACE("Operational intensity: %10.2f\n", oi);

	*better_device_index = RM_get_better_device_to_execution();
	TRACE("Execution is better on device [%d].\n", better_device_index);
	
	return offload_decision;
}
/* ------------------------------------------------------------ */
