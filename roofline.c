#include "roofline.h"

static pthread_key_t papi_thread_info_key;
static bool papi_library_initialized = false;

static bool papi_eventset_was_created = false;
static bool papi_in_multiplexing_mode = false;

static bool thread_was_registred_in_papi = false;

static bool started_measuring = false;

/* ------------------------------------------------------------ */
/* Info and Test function.										*/
void info(void) {
	puts("Hello, I'm a shared library.\n");
}

/* ------------------------------------------------------------ */
/* Init library. 												*/
bool RM_library_init(void){
	PRINT_FUNC_NAME;
	bool result = true;
	int i;

	/*Create the structures to get measures. */
	ptr_measure = (struct _papi_thread_record *) malloc(sizeof(struct _papi_thread_record));
	ptr_measure->values = (long long *) malloc(sizeof(long long) * NUM_EVENTS);
	ptr_measure->events = (int *) malloc(sizeof(int) * NUM_EVENTS);

	TRACE("Size of values: %d %d %lld %lld %lld %lld %lld.\n", sizeof(long long), sizeof(ptr_measure->values), ptr_measure->values[0], ptr_measure->values[1], ptr_measure->values[2], ptr_measure->values[3], ptr_measure->values[4]);

	TRACE("Setting the defined code events to RM registry.\n");	
	memcpy(ptr_measure->events, FPO_event_codes, NUM_FPO_EVENTS * sizeof(int));
	memcpy(ptr_measure->events + NUM_FPO_EVENTS, MEM_event_codes, NUM_MEM_EVENTS * sizeof(int));
	memcpy(ptr_measure->events + NUM_FPO_EVENTS + NUM_MEM_EVENTS, TIME_event_codes, NUM_TIME_EVENTS * sizeof(int));
	
	ptr_measure->initial_time = (struct timeval){0};
	ptr_measure->final_time = (struct timeval){0};
	ptr_measure->EventSet = PAPI_NULL;

	papi_eventset_was_created = false;
	papi_in_multiplexing_mode = false;
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
		TRACE("PAPI_thread_id error.\n");
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

	TRACE("Setting debugging.\n");
	if (PAPI_set_debug(PAPI_VERB_ESTOP) != PAPI_OK ){
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

  	papi_eventset_was_created = (retval == PAPI_OK);

  	/* Assign it to the CPU component */
	TRACE("Assign it to the CPU component.\n");
	if ((PAPI_assign_eventset_component(ptr_measure->EventSet, 0)) != PAPI_OK){
  		RM_papi_handle_error(__FUNCTION__, retval, __LINE__);
  	}

	/* Convert the ''EventSet'' to a multiplexed event set */
	TRACE("Convert the EventSet to a multiplexed event set.\n");
	if ((retval = PAPI_set_multiplex(ptr_measure->EventSet)) != PAPI_OK){
		if ( retval == PAPI_ENOSUPP) {
			TRACE("Multiplex not supported.\n");
		}
  		RM_papi_handle_error(__FUNCTION__, retval, __LINE__);
  	}

  	retval = PAPI_get_multiplex(ptr_measure->EventSet);
	if (retval > 0)
		TRACE("This event set is ready for multiplexing.\n");
	if (retval == 0) 
		TRACE("This event set is not enabled for multiplexing.\n");
	if (retval < 0) 
		RM_papi_handle_error(__FUNCTION__, retval, __LINE__);
	
	papi_in_multiplexing_mode = (retval > 0);

	/* Add events to EventSet */
  	char event_str[PAPI_MAX_STR_LEN];
  	char event_str_test[PAPI_MAX_STR_LEN];
  	char error_str[PAPI_MAX_STR_LEN];

	for (i = 0; i < NUM_EVENTS; i++) {
		PAPI_event_code_to_name(ptr_measure->events[i], event_str);
		TRACE("Trying to add event: %x - %s.\n", ptr_measure->events[i], event_str);
		
		if(RM_check_event_is_available(ptr_measure->events[i], true)){
			if ((retval = PAPI_add_event(ptr_measure->EventSet, ptr_measure->events[i])) != PAPI_OK){
				TRACE("Error in PAPI_add_event().\n");
				RM_papi_handle_error(__FUNCTION__, retval, __LINE__);
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

	RM_check_papi_status();

	TRACE("Leaving the RM_create_event_set: papi_eventset_was_created %d && papi_in_multiplexing_mode %d.\n", papi_eventset_was_created, papi_in_multiplexing_mode);

	return papi_eventset_was_created && papi_in_multiplexing_mode;
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
	TRACE("Resetting the counters.\n");
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
	TRACE("Start counting.\n");
  	if ((retval = PAPI_start(ptr_measure->EventSet)) != PAPI_OK) {
		TRACE("PAPI_start() Starting counting error.\n");
		RM_papi_handle_error(__FUNCTION__, retval, __LINE__);

		/*if (retval == PAPI_ECNFLCT) {
	      TRACE("[RM_start_counters] PAPI error %d (%s): It is likely that you selected too many counters to monitor.\n",
		      retval, PAPI_strerror(retval));
	    }*/
  	}

  	/* First measure. */
  	TRACE("Stop counting to first measures.\n");
  	if ((retval = PAPI_stop(ptr_measure->EventSet, ptr_measure->values)) != PAPI_OK) {
  		RM_papi_handle_error(__FUNCTION__, retval, __LINE__);
	    TRACE("[RM_start_counters] PAPI_stop() counting first measure error.\n");
	}

	/* Gets the starting time in clock cycles */
	ptr_measure->start_cycles = PAPI_get_real_cyc();

	/* Gets the starting time in microseconds */
	ptr_measure->start_usec = PAPI_get_real_usec();

	/* Final measure. */
	TRACE("Start counting for measures.\n");
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
	int retval = 0;

	TRACE("Before PAPI accum counters: %d\n", NUM_EVENTS);

	if ((retval = PAPI_accum_counters(ptr_measure->values, NUM_EVENTS)) != PAPI_OK){
		TRACE("PAPI_accum_counters(...) error.\n");
		RM_papi_handle_error(__FUNCTION__, retval, __LINE__);

		switch (retval){
			case PAPI_EINVAL:
				TRACE("One or more of the arguments is invalid.\n");
				break;
			case PAPI_ESYS :
				TRACE("A system or C library call failed inside PAPI, see the errno variable.\n");
				break;
			defaul:
				TRACE("Unknown Error.\n");
		}
	}

	return (retval == PAPI_OK);
}

/* ------------------------------------------------------------ */
/* Record measures in intervals between start and stop.			*/
bool RM_registry_measures (void){
	PRINT_FUNC_NAME;
	bool retval = false;

	/* Stop and accumulate for >= second chunks. */
	TRACE("[HOOKOMP]: Verifying if started the measuring.\n");
	if(started_measuring){
		if(RM_stop_and_accumulate()){
			TRACE("[RM]: Stop and Accumulate.\n");
			retval = true;
		}
		else{
			TRACE("Error calling RM_stop_and_accumulate.\n");
			retval = false;
		}
	}

	/* Start for the next chunk. */
	if(RM_start_counters()){
		TRACE("[RM]: PAPI Counters Started.\n");
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
bool RM_library_shutdown(void){
	PRINT_FUNC_NAME;
	int retval = 0;
	
	TRACE("Trying to unregister thread calling PAPI_unregister_thread().\n");
	if ((retval = PAPI_unregister_thread()) != PAPI_OK){
		TRACE("PAPI_unregister_thread error.\n");
		RM_papi_handle_error(__FUNCTION__, retval, __LINE__);
	}
	else{
		TRACE("PAPI_unregister_thread OK.\n");
	}

	/*TRACE("Trying to clean up the event set.\n");
	if ((retval = PAPI_cleanup_eventset(ptr_measure->EventSet)) != PAPI_OK){
		TRACE("PAPI_cleanup_eventset error.\n");
		RM_papi_handle_error(__FUNCTION__, retval, __LINE__);
	}
	else{
		TRACE("PAPI_cleanup_eventset OK.\n");
	}*/

	/*TRACE("Trying to destroy event set.\n");
	if ((retval = PAPI_destroy_eventset(&ptr_measure->EventSet)) != PAPI_OK){
		TRACE("PAPI_destroy_eventset error.\n");
		RM_papi_handle_error(__FUNCTION__, retval, __LINE__);
	}*/

	TRACE("Trying to free allocated structures.\n");
	free(ptr_measure->events);
	free(ptr_measure->values);
	free(ptr_measure);

	PAPI_shutdown();

	return (retval == PAPI_OK);
}
