#include "roofline.h"

/* ------------------------------------------------------------ */
/* Info and Test function.										*/
void info(void) {
	puts("Hello, I'm a roofline library.\n");
}

/* ------------------------------------------------------------ */
/* Init library. 												*/
bool RM_library_init(void){
	PRINT_FUNC_NAME;
	bool result = true;
	int i, j;

	/*Create the structures to get measures. */
	ptr_measure = (struct _papi_thread_record *) malloc(sizeof(struct _papi_thread_record));
	ptr_measure->values = (long long *) malloc(sizeof(long long) * NUM_EVENT_SETS * NUM_MAX_EVENTS);

	ptr_measure->quant_intervals = (long long *) malloc(sizeof(long long) * NUM_EVENT_SETS);

	memset(ptr_measure->quant_intervals, 0, NUM_EVENT_SETS * sizeof(*ptr_measure->quant_intervals));

	memset(ptr_measure->values, 0, NUM_EVENT_SETS * NUM_MAX_EVENTS * sizeof(*ptr_measure->values));

   	TRACE("ptr_measure->values initialization.\n");
   	for ( i = 0; i < NUM_EVENT_SETS; i++ ) {
   		TRACE("# intervals [%d]: %ld\n", i, ptr_measure->quant_intervals[i]);
 		for ( j = 0; j < NUM_MAX_EVENTS; j++ ) {
	 		ptr_measure->values[i * NUM_MAX_EVENTS + j] = 0;
	 		TRACE("ptr_measure->values[%d][%d]: %ld.\n", i, j, ptr_measure->values[i * NUM_MAX_EVENTS + j]);	
	 	}
	}

	ptr_measure->current_eventset = 0;
	ptr_measure->initial_time = (struct timeval){0};
	ptr_measure->final_time = (struct timeval){0};

	ptr_measure->EventSets = (int *) malloc(sizeof(int) * NUM_PAPI_EVENT_SETS);
	ptr_measure->EventSets[COMP_CORE] = PAPI_NULL;
	ptr_measure->EventSets[COMP_UNCORE] = PAPI_NULL;

	/* Aditional parameters. */
	ptr_measure->total_of_iterations = 0;
  	ptr_measure->executed_loop_iterations = 0;
  	ptr_measure->chunk_size = 0;

  	RM_print_counters_values();

	TRACE("PAPI Library was initialized: %d\n", papi_library_initialized);
	if(!papi_library_initialized){
  		TRACE("[Before] Value of papi_library_initialized: %d\n",papi_library_initialized);
  		result = RM_initialization_of_papi_libray_mode();
  		TRACE("[After] Value of result: %d, papi_library_initialized: %d\n", result, papi_library_initialized);
  	}

  	/* Thread was registered. */
  	/*TRACE("Verifying if the thread was registered in PAPI: %d.\n", thread_was_registred_in_papi);
  	if(!thread_was_registred_in_papi){
  		TRACE("Trying to registry the thread in papi.\n");
  		result = RM_register_papi_thread();
  	}*/

  	/* Event set was created. */
   	TRACE("Verifying if eventset was created: %d.\n", papi_eventsets_were_created);
	if(!papi_eventsets_were_created){
	 	TRACE("Trying to create event set.\n");
	 	result = RM_create_event_sets();
	}

	sem_init(&mutex_measure_session_init, 0, 1);

	is_measure_session_initialized = false;

	return result;
}

/* ------------------------------------------------------------ */
/* Session of measures to reinitialize for each loop            */
bool RM_measure_session_init(void){
	PRINT_FUNC_NAME;
	bool result = true;
	int i, j;

	sem_wait(&mutex_measure_session_init);

	TRACE("Session Initilized, is_measure_session_initialize:%d\n", is_measure_session_initialized);

	if (!is_measure_session_initialized){

		ptr_measure->current_eventset = 0;
		ptr_measure->initial_time = (struct timeval){0};
		ptr_measure->final_time = (struct timeval){0};

		ptr_measure->quant_intervals = (long long *) malloc(sizeof(long long) * NUM_EVENT_SETS);

		/* Reset the values. */
		// memset(ptr_measure->quant_intervals, 0, NUM_EVENT_SETS * sizeof(*ptr_measure->quant_intervals));
		// memset(ptr_measure->values, 0, NUM_EVENT_SETS * NUM_MAX_EVENTS * sizeof(*ptr_measure->values));

		TRACE("ptr_measure->values initialization.\n");
  		for ( i = 0; i < NUM_EVENT_SETS; i++ ) {
  			ptr_measure->quant_intervals[i] = 0;
  			TRACE("# intervals [%d]: %ld\n", i, ptr_measure->quant_intervals[i]);
			for ( j = 0; j < NUM_MAX_EVENTS; j++ ) {
				ptr_measure->values[i * NUM_MAX_EVENTS + j] = 0;
				TRACE("ptr_measure->values[%d][%d]: %ld.\n", i, j, ptr_measure->values[i * NUM_MAX_EVENTS + j]);	
			}
		}

		/* Aditional parameters. */
		ptr_measure->total_of_iterations = 0;
  		ptr_measure->executed_loop_iterations = 0;
 		ptr_measure->chunk_size = 0;

 		started_measuring = false;

 		RM_print_counters_values();

 		is_measure_session_initialized = true;
	}

	sem_post(&mutex_measure_session_init);

	return result;
}

/* ------------------------------------------------------------ */
bool RM_measure_session_finish(void){
	PRINT_FUNC_NAME;
	bool result = true;

	if (is_measure_session_initialized){
 		is_measure_session_initialized = false;
 		
 		/*TRACE("Verifying the registered thread in PAPI: %d.\n", thread_was_registred_in_papi);
  		if(thread_was_registred_in_papi){
  			TRACE("Trying to unregister the thread in PAPI.\n");
  			if((result = RM_unregister_papi_thread()) != true){
  				TRACE("Thread [%lu] was not unregistered in PAPI.\n", thread_was_registred_in_papi);
  			}
  			else{
  				TRACE("Thread [%lu] was unregistered in PAPI.\n");
  			}
  		}*/
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
        TRACE("PAPI_thread_init error: %d %s\n", retval, PAPI_strerror(retval));
        RM_papi_handle_error(__FUNCTION__, retval, __LINE__);
        if (retval == PAPI_ESBSTR)
			TRACE("PAPI_thread_init error: %d\n", retval);
	}

	tid = PAPI_thread_id();
	TRACE("[After]: PAPI_thread_init: %lu\n", tid);

  	if((retval = PAPI_register_thread()) != PAPI_OK){
        TRACE("PAPI_register_thread error: %d %s\n", retval, PAPI_strerror(retval));
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

/* ------------------------------------------------------------ */
/* Register the thread in PAPI.												*/
/*bool RM_unregister_papi_thread(void){
	PRINT_FUNC_NAME;
	int retval;
	
	TRACE("[%s] [Before] PAPI_unregister_thread.\n", __FUNCTION__);

	if((retval = PAPI_unregister_thread()) != PAPI_OK){
        TRACE("PAPI_unregister_thread error: %d %s\n", retval, PAPI_strerror(retval));
        RM_papi_handle_error(__FUNCTION__, retval, __LINE__);
	}
	else {
		thread_was_registred_in_papi = false;
	}

	return (retval == PAPI_OK);
}*/

/* ------------------------------------------------------------- */
/* Function to initialization of PAPI Library.                   */
bool RM_initialization_of_papi_libray_mode(){
	PRINT_FUNC_NAME;
	
	int retval;
	pthread_key_create(&papi_thread_info_key, NULL );

	// TRACE("pthread_key_create: %lld.\n", papi_thread_info_key);

	TRACE("[Before]: Calling PAPI_library_init().\n");
	if ((retval = PAPI_library_init(PAPI_VER_CURRENT)) != PAPI_VER_CURRENT){
		TRACE("PAPI_library_init error: %d %s\n", retval, PAPI_strerror(retval));
		TRACE("PAPI library version mismatch.\n");
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

	/* Set the control initialization of PAPI library. */
	papi_library_initialized = (retval == PAPI_LOW_LEVEL_INITED);

	TRACE("[After]: PAPI_library_init. Value of papi_library_initialized: %d\n", papi_library_initialized);

	/* Enable and initialize multiplex support */
	/*TRACE("[Before]: Trying to start the multiplex mode. Calling PAPI_multiplex_init().\n");
  	if ((retval = PAPI_multiplex_init()) != PAPI_OK){
		TRACE("Error in initialization of multiplex mode.\n");
		RM_papi_handle_error(__FUNCTION__, retval, __LINE__);
	}*/

	TRACE("Setting debugging.\n");
	if((retval = PAPI_set_debug(PAPI_VERB_ECONT)) != PAPI_OK){
		TRACE("PAPI_set_debug error: %d %s\n", retval, PAPI_strerror(retval));
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

	TRACE("Printing Values:\n");
	for ( i = 0; i < NUM_EVENT_SETS; i++ ) {
		TRACE("%s;%s;%s;%s;%s;%s;\n", "measures", 
				((event_names[i][0] != NULL) ? event_names[i][0] : "") , 
				((event_names[i][1] != NULL) ? event_names[i][1] : ""), 
				((event_names[i][2] != NULL) ? event_names[i][2] : ""), 
				((event_names[i][3] != NULL) ? event_names[i][3] : ""), 
				((event_names[i][4] != NULL) ? event_names[i][4] : ""));
		
		TRACE("%lld;%lld;%lld;%lld;%lld;%lld;\n", 
			ptr_measure->quant_intervals[i], 
			((event_names[i][0] != NULL) ? ptr_measure->values[i * NUM_MAX_EVENTS + 0] : NULL), 
			((event_names[i][1] != NULL) ? ptr_measure->values[i * NUM_MAX_EVENTS + 1] : NULL),
			((event_names[i][2] != NULL) ? ptr_measure->values[i * NUM_MAX_EVENTS + 2] : NULL),
			((event_names[i][3] != NULL) ? ptr_measure->values[i * NUM_MAX_EVENTS + 3] : NULL),
			((event_names[i][4] != NULL) ? ptr_measure->values[i * NUM_MAX_EVENTS + 4] : NULL));
	}
}

/* ------------------------------------------------------------ */
/* PAPI Status.													*/
void RM_check_papi_status(int idx){
	PRINT_FUNC_NAME;
	int retval;

	int status = 0;
	TRACE("Checking the Status of EventSet[%d].\n", idx);
	if((retval = PAPI_state(ptr_measure->EventSets[idx], &status)) != PAPI_OK){
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
	// TRACE("Checking the Status of EventSetUnCore.\n");
	// if((retval = PAPI_state(ptr_measure->EventSetUnCore, &status)) != PAPI_OK){
	// 	switch (retval){
	// 		case PAPI_STOPPED :
	// 			TRACE("EventSet is stopped.\n");
	// 			break;
	// 		case PAPI_RUNNING :
	// 			TRACE("EventSet is running.\n");
	// 			break;
	// 		case PAPI_PAUSED :
	// 			TRACE("EventSet temporarily disabled by the library.\n"); 
	// 			break;
	// 		case PAPI_NOT_INIT :
	// 			TRACE("EventSet defined, but not initialized.\n");
	// 			break;
 //    		case PAPI_OVERFLOWING :
	// 			TRACE("EventSet has overflowing enabled.\n");
 //    			break;
	// 	    case PAPI_PROFILING :
	// 			TRACE("EventSet has profiling enabled.\n");
	// 	    	break;
	// 	    case PAPI_MULTIPLEXING :
	// 			TRACE("EventSet has multiplexing enabled.\n");
	// 	    	break;
	// 	//    case PAPI_ACCUMULATING :
	// 	//		TRACE("reserved for future use.\n");
	// 	//    	break;
	// 	//    case PAPI_HWPROFILING :
	// 	//		TRACE("reserved for future use.\n");
	// 	//    	break;
	// 	    defaul: TRACE("Undefined retval.\n");
	// 	} 
	// }
}

/* ------------------------------------------------------------ */
/* Create event set. 											*/
bool RM_create_event_sets(void){
	PRINT_FUNC_NAME;
	int i, retval_1, retval_2;

	int uncore_cidx = -1;
   	const PAPI_component_info_t *cmp_info;

	int native = 0x0;

	TRACE("Trying to create PAPI Event Sets.\n");

	TRACE("Trying to create ptr_measure->EventSets[COMP_CORE].\n");
	/* Create an EventSet */
  	if ((retval_1 = PAPI_create_eventset(&ptr_measure->EventSets[COMP_CORE])) != PAPI_OK){
    	TRACE("PAPI_create_eventset error: %d %s\n", retval_1, PAPI_strerror(retval_1));
    	RM_papi_handle_error(__FUNCTION__, retval_1, __LINE__);
  	}

  	/* Assign it to the CPU component */
	TRACE("Assign it to the CPU component.\n");
	if ((retval_1 = PAPI_assign_eventset_component(ptr_measure->EventSets[COMP_CORE], 0)) != PAPI_OK){
  		TRACE("PAPI_assign_eventset_component: %d %s\n", retval_1, PAPI_strerror(retval_1));
  		RM_papi_handle_error(__FUNCTION__, retval_1, __LINE__);
  	}

   // 	/* we need to set to a certain cpu for uncore to work */

   // 	PAPI_cpu_option_t cpu_opt_is_core;

   // 	cpu_opt_is_core.eventset = ptr_measure->EventSetCore;
   // 	cpu_opt_is_core.cpu_num = 0;

   // retval = PAPI_set_opt(PAPI_CPU_ATTACH,(PAPI_option_t*)&cpu_opt_is_core);
   // if (retval != PAPI_OK) {
   //    test_skip( __FILE__, __LINE__,
   //          "this test; trying to PAPI_CPU_ATTACH; need to run as root",
   //          retval);
   // }

   // /* we need to set the granularity to system-wide for uncore to work */

   // PAPI_granularity_option_t gran_opt_is_core;

   //  PAPI_GRN_THR   Count each individual thread
   //    PAPI_GRN_PROC  Count each individual process
   //    PAPI_GRN_PROCG    Count each individual process group
   //    PAPI_GRN_SYS   Count the current CPU
   //    PAPI_GRN_SYS_CPU  Count all CPU's individually
   //    PAPI_GRN_MIN   The finest available granularity
   //    PAPI_GRN_MAX   The coarsest available granularity 
   
   // gran_opt_is_core.def_cidx = 0;
   // gran_opt_is_core.eventset = ptr_measure->EventSetCore;
   // gran_opt_is_core.granularity = PAPI_GRN_SYS;

   // retval = PAPI_set_opt(PAPI_GRANUL, (PAPI_option_t*) &gran_opt_is_core);
   // if (retval != PAPI_OK) {
   //    test_skip( __FILE__, __LINE__,
   //          "this test; trying to set PAPI_GRN_SYS",
   //          retval);
   // }

   // /* we need to set domain to be as inclusive as possible */

   // PAPI_domain_option_t domain_opt_is_core;

   // domain_opt_is_core.def_cidx = 0;
   // domain_opt_is_core.eventset = ptr_measure->EventSetCore;
   // domain_opt_is_core.domain = PAPI_DOM_ALL;

   // retval = PAPI_set_opt(PAPI_DOMAIN,(PAPI_option_t*) &domain_opt_is_core);
   // if (retval != PAPI_OK) {
   //    test_skip( __FILE__, __LINE__,
   //          "this test; trying to set PAPI_DOM_ALL; need to run as root",
   //          retval);
   // }

  	TRACE("Trying to create ptr_measure->EventSets[COMP_UNCORE].\n");

  	/* Find the uncore PMU */
  	if ((uncore_cidx = PAPI_get_component_index("perf_event_uncore")) < 0){
  		TRACE("perf_event_uncore component not found: %d %s\n", uncore_cidx, PAPI_strerror(uncore_cidx));
   	}

   	/* Check if component disabled */
   	if ((cmp_info = PAPI_get_component_info(uncore_cidx)) == NULL){
   		TRACE("Uncore component %d not found.\n", uncore_cidx);	
   	}
   	else{
   		if (cmp_info->disabled) {
    	  TRACE("Uncore component disabled.\n");
   		}	
   	}

   	/* Create an eventset */
   	if ((retval_2 = PAPI_create_eventset(&ptr_measure->EventSets[COMP_UNCORE])) != PAPI_OK){
    	TRACE("PAPI_create_eventset error: %d %s\n", retval_2, PAPI_strerror(retval_2));
    	RM_papi_handle_error(__FUNCTION__, retval_2, __LINE__);
  	}

  	/* Assign it to the perf_uncore component */
	TRACE("Assign it to perf_uncore component.\n");
	if ((retval_2 = PAPI_assign_eventset_component(ptr_measure->EventSets[COMP_UNCORE], uncore_cidx)) != PAPI_OK){
  		TRACE("PAPI_assign_eventset_component: %d %s\n", retval_2, PAPI_strerror(retval_2));
  		RM_papi_handle_error(__FUNCTION__, retval_2, __LINE__);
  	}

   	/* we need to set to a certain cpu for uncore to work */
  	TRACE("Defining CPU to uncore component.\n");
   	PAPI_cpu_option_t cpu_opt_uncore;

   	cpu_opt_uncore.eventset = ptr_measure->EventSets[COMP_UNCORE];
   	cpu_opt_uncore.cpu_num = 0;

   	if ((retval_2 = PAPI_set_opt(PAPI_CPU_ATTACH, (PAPI_option_t*) &cpu_opt_uncore)) != PAPI_OK){
   		TRACE("Trying to PAPI_CPU_ATTACH; need to run as root: %d %s\n", retval_2, PAPI_strerror(retval_2));
   	}

   	/* we need to set the granularity to system-wide for uncore to work */
   	TRACE("Defining granularity to uncore component.\n");
   	PAPI_granularity_option_t gran_opt_uncore;

   	/* PAPI_GRN_THR   Count each individual thread
      PAPI_GRN_PROC  Count each individual process
      PAPI_GRN_PROCG    Count each individual process group
      PAPI_GRN_SYS   Count the current CPU
      PAPI_GRN_SYS_CPU  Count all CPU's individually
      PAPI_GRN_MIN   The finest available granularity
      PAPI_GRN_MAX   The coarsest available granularity 
   	*/
   	gran_opt_uncore.def_cidx = 0;
   	gran_opt_uncore.eventset = ptr_measure->EventSets[COMP_UNCORE];
   	gran_opt_uncore.granularity = PAPI_GRN_SYS;

   	if ((retval_2 = PAPI_set_opt(PAPI_GRANUL, (PAPI_option_t*) &gran_opt_uncore)) != PAPI_OK){
   		TRACE("Trying to PAPI_GRN_SYS: %d %s\n", retval_2, PAPI_strerror(retval_2));
   	}

   	/* we need to set domain to be as inclusive as possible */
   	TRACE("Defining domain to uncore component.\n");
   	PAPI_domain_option_t domain_opt_uncore;

   	domain_opt_uncore.def_cidx = 0;
   	domain_opt_uncore.eventset = ptr_measure->EventSets[COMP_UNCORE];
   	domain_opt_uncore.domain = PAPI_DOM_ALL;

   	if ((retval_2 = PAPI_set_opt(PAPI_DOMAIN,(PAPI_option_t*) &domain_opt_uncore)) != PAPI_OK){
   		TRACE("Trying to PAPI_DOM_ALL; need to run as root %d %s\n", retval_2, PAPI_strerror(retval_2));
   	}
   
   	/* Convert the ''EventSet'' to a multiplexed event set */
	/*TRACE("Convert the EventSet to a multiplexed event set.\n");
	if ((retval = PAPI_set_multiplex(ptr_measure->EventSet)) != PAPI_OK){
		if ( retval == PAPI_ENOSUPP) {
			TRACE("Multiplex not supported.\n");
		}
  		RM_papi_handle_error(__FUNCTION__, retval, __LINE__);
  	}*/

  	/*retval = PAPI_get_multiplex(ptr_measure->EventSet);
	if (retval > 0)
		TRACE("This event set is ready for multiplexing.\n");
	if (retval == 0) 
		TRACE("This event set is not enabled for multiplexing.\n");
	if (retval < 0) 
		RM_papi_handle_error(__FUNCTION__, retval, __LINE__);
	
	papi_in_multiplexing_mode = (retval > 0);*/

	/* Add events to EventSet */
  	/*char event_str[PAPI_MAX_STR_LEN];
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
	}*/

	/* Set eventsets were created. */
  	papi_eventsets_were_created = ((retval_1 == PAPI_OK) && (retval_2 == PAPI_OK));

	RM_check_papi_status(COMP_CORE);
	RM_check_papi_status(COMP_UNCORE);

	TRACE("Leaving the RM_create_event_sets: papi_eventsets_were_created %d.\n", papi_eventsets_were_created);

	return papi_eventsets_were_created;
}

/* ------------------------------------------------------------ */
/* Start counters.												*/
bool RM_start_counters (void){
	PRINT_FUNC_NAME;
	
	int i, j, retval, result;
  	unsigned long int tid;

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
	if(!papi_eventsets_were_created){
		TRACE("Trying to create event set.\n");
		result = RM_create_event_sets();
	}

	int EventCode = 0x0;

	TRACE("EventSet: %d\n", ptr_measure->current_eventset);
	for ( j = 0; j < NUM_MAX_EVENTS; j++ ) {
		if(event_names[ptr_measure->current_eventset][j] != NULL){
			TRACE("Adding[%s].\n", event_names[ptr_measure->current_eventset][j] );
  			/*if ((retval = PAPI_add_named_event( ptr_measure->EventSet, event_names[ptr_measure->current_eventset][j] )) != PAPI_OK){
				// fprintf(stderr,"PAPI_add_named_event[%s] error: %s\n", event_names[ptr_measure->current_eventset][j], PAPI_strerror(retval));
				// TRACE("PAPI_add_named_event[%s] error.\n");// , event_names[ptr_measure->current_eventset][j]);
				RM_papi_handle_error(__FUNCTION__, retval, __LINE__);
			}*/
			EventCode = 0x0;
			if ((retval = PAPI_event_name_to_code(event_names[ptr_measure->current_eventset][j], &EventCode )) != PAPI_OK){
				RM_papi_handle_error(__FUNCTION__, retval, __LINE__);
			}

			TRACE("DEBUG: ptr_measure->current_eventset: %d\n", ptr_measure->current_eventset);
			TRACE("DEBUG: kind_of_event_set[ptr_measure->current_eventset]: %d\n", kind_of_event_set[ptr_measure->current_eventset]);

			TRACE("DEBUG: ptr_measure->EventSets[kind_of_event_set[ptr_measure->current_eventset]]: %d\n", ptr_measure->EventSets[kind_of_event_set[ptr_measure->current_eventset]]);
			

			TRACE("Adding[%X].\n", EventCode);
			if ((retval = PAPI_add_event(ptr_measure->EventSets[kind_of_event_set[ptr_measure->current_eventset]], EventCode )) != PAPI_OK){
				RM_papi_handle_error(__FUNCTION__, retval, __LINE__);
			}	
		}
	}

	/* Restart the counters. */
	TRACE("Resetting the counters.\n");
	if ((retval = PAPI_reset(ptr_measure->EventSets[kind_of_event_set[ptr_measure->current_eventset]])) != PAPI_OK) {
		TRACE("PAPI_reset() counters error.\n");
		RM_papi_handle_error(__FUNCTION__, retval, __LINE__);

		// PAPI_ESYS A system or C library call failed inside PAPI, see the errno variable.
		// PAPI_ENOEVST The EventSet specified does not exist. 
		// if (retval == PAPI_ECNFLCT) {
	    //  TRACE("[RM_start_counters] PAPI error %d (%s): It is likely that you selected too many counters to monitor.\n",
		//      retval, PAPI_strerror(retval));
	    // }
  	}

	/* Gets the starting time in clock cycles */
	ptr_measure->start_cycles = PAPI_get_real_cyc();

	/* Gets the starting time in microseconds */
	ptr_measure->start_usec = PAPI_get_real_usec();

	/* Start counting */
	TRACE("Starting counting...\n");
  	if ((retval = PAPI_start(ptr_measure->EventSets[kind_of_event_set[ptr_measure->current_eventset]])) != PAPI_OK) {
		TRACE("PAPI_start() Starting counting error.\n");
		RM_papi_handle_error(__FUNCTION__, retval, __LINE__);

		/*if (retval == PAPI_ECNFLCT) {
	      TRACE("[RM_start_counters] PAPI error %d (%s): It is likely that you selected too many counters to monitor.\n",
		      retval, PAPI_strerror(retval));
	    }*/
  	}

	started_measuring = (retval == PAPI_OK);

	return started_measuring;
}

/* ------------------------------------------------------------ */
/* Stop and accumulate.											*/
bool RM_stop_and_accumulate(void){
	PRINT_FUNC_NAME;
	int retval = 0;
	int j;

  	TRACE("Trying accumulate counters.\n");
	if ((retval = PAPI_accum(ptr_measure->EventSets[kind_of_event_set[ptr_measure->current_eventset]], &ptr_measure->values[ptr_measure->current_eventset * NUM_MAX_EVENTS + 0])) != PAPI_OK){
		TRACE("PAPI_accum error: %d %s\n", retval, PAPI_strerror(retval));
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

	/* Gets the ending time in clock cycles */
	ptr_measure->end_cycles = PAPI_get_real_cyc();

	/* Gets the ending time in microseconds */
	ptr_measure->end_usec = PAPI_get_real_usec();
		
	TRACE("Wall clock cycles: \t\t\t%lld\n", ptr_measure->end_cycles - ptr_measure->start_cycles );
	TRACE("Wall clock time in microseconds: \t%lld\n", ptr_measure->end_usec - ptr_measure->start_usec );
		 
	/* Stop de measures. */
	TRACE("Stopping the counters.\n");
	if ((retval = PAPI_stop(ptr_measure->EventSets[kind_of_event_set[ptr_measure->current_eventset]], &discarded_values)) != PAPI_OK){
		TRACE("PAPI_stop error: %d %s\n", retval, PAPI_strerror(retval));
		RM_papi_handle_error(__FUNCTION__, retval, __LINE__);
	}

	TRACE("Removing events of EventSet: %d\n", ptr_measure->current_eventset);
	for ( j = 0; j < NUM_MAX_EVENTS; j++ ) {
		if(event_names[ptr_measure->current_eventset][j] != NULL){
			TRACE("Removing[%s].\n", event_names[ptr_measure->current_eventset][j] );
  			if ((retval = PAPI_remove_named_event(ptr_measure->EventSets[kind_of_event_set[ptr_measure->current_eventset]], event_names[ptr_measure->current_eventset][j] )) != PAPI_OK){
				TRACE("PAPI_remove_named_event[%s] error: %s\n", event_names[ptr_measure->current_eventset][j], PAPI_strerror(retval));
				// The retval when the platform don't have support the counter was returned and supressing the offloading.
				// PAPI can continue after errors. So defining retval to PAPI_OK.
			}
			retval = PAPI_OK;
		}
	}

	TRACE("Before Intervals Count -> EventSet: %d quant_intervals: %d\n", ptr_measure->current_eventset, ptr_measure->quant_intervals[ptr_measure->current_eventset]);
	
	ptr_measure->quant_intervals[ptr_measure->current_eventset] = ptr_measure->quant_intervals[ptr_measure->current_eventset] + 1;

	TRACE("After Intervals Count -> EventSet: %d quant_intervals: %d\n", ptr_measure->current_eventset, ptr_measure->quant_intervals[ptr_measure->current_eventset]);

	TRACE("Calling the printing of counter values.\n");
	RM_print_counters_values();

	ptr_measure->current_eventset = ((ptr_measure->current_eventset + 1) % NUM_EVENT_SETS);

	return (retval == PAPI_OK);
}

/* ------------------------------------------------------------ */
/* Record measures in intervals between start and stop.			*/
bool RM_registry_measures (void){
	PRINT_FUNC_NAME;
	bool retval = false;

	/* Stop and accumulate for >= second chunks. */
	TRACE("[RM]: Verifying if started the measuring: %d.\n", started_measuring);
	if(started_measuring){
		TRACE("call RM_stop_and_accumulate().\n");
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
	TRACE("call RM_start_counters().\n");
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
/* Aditional parameters definition.							
 * N: total of iterations, 
 * executed_iterations: Number of executed iterations (percentual)
 * chunk_size: last chunk_size.
 * q_data_transfer: number of bytes that will be transfered to device.
 */
 void RM_set_aditional_parameters(long long total_of_iterations, long long executed_loop_iterations, long long chunk_size, long long q_data_transfer_write, long long q_data_transfer_read, unsigned int type_of_data_allocation) {
 	PRINT_FUNC_NAME;

 	ptr_measure->total_of_iterations = total_of_iterations;
  	ptr_measure->executed_loop_iterations = executed_loop_iterations;
  	ptr_measure->chunk_size = chunk_size;
  	ptr_measure->q_data_transfer_write = q_data_transfer_write;
  	ptr_measure->q_data_transfer_read = q_data_transfer_read;
  	ptr_measure->type_of_data_allocation = type_of_data_allocation;

  	TRACE("Total of iterations: %ld, executed_iterations: %lld, chunk_size: %lld, q_data_transfer_write: %lld, q_data_transfer_read: %lld.\n", ptr_measure->total_of_iterations, ptr_measure->executed_loop_iterations, ptr_measure->chunk_size, ptr_measure->q_data_transfer_write, ptr_measure->q_data_transfer_read);
 }

/* ------------------------------------------------------------ */
/* Calculate the Operational Intensity.							*/
/* Indices to storage structures.
 * IDX_LLC 0
 * IDX_L2  1
 * IDX_L1  2
 * IDX_FPO 3
 *
 * long long values[NUM_EVENT_SETS][NUM_MAX_EVENTS] 
 * {0, 0, 0, 0, 0}
 * {0, 0, 0, 0, 0}
 * {0, 0, 0, 0, 0}
 * {0, 0, 0, 0, 0}
 *
 * quant_intervals[NUM_EVENT_SETS]
 * FPO_event_names 0,
 * L1_event_names  0,
 * L2_event_names  0,
 * L3_event_names  0
 */

/* ------------------------------------------------------------ */
// #define TOTAL_OF_CHUNKS (ptr_measure->total_of_iterations / ptr_measure->chunk_size)
long long total_of_chunks() {
	PRINT_FUNC_NAME;
	long long total_chunks = (ptr_measure->total_of_iterations / ptr_measure->chunk_size);
	TRACE("total of iterations: %ld, chunk size: %d , total of chunks: %ld.\n", ptr_measure->total_of_iterations, ptr_measure->chunk_size, total_chunks);
	return total_chunks;
}

/* ------------------------------------------------------------ */
// #define MEASURED_CHUNKS (ptr_measure->quant_intervals[0] + ptr_measure->quant_intervals[1] + ptr_measure->quant_intervals[2] + ptr_measure->quant_intervals[3])
long long measured_chunks(){
	PRINT_FUNC_NAME;
	int i = 0;
	long long measured_chunks = 0;

	for ( i = 0; i < NUM_EVENT_SETS; i++ ){
		measured_chunks += ptr_measure->quant_intervals[i];
	}
	TRACE("measured chunks: %ld.\n", measured_chunks);
	return measured_chunks;
}

/* ------------------------------------------------------------ */
double measured(int i, int j){
	PRINT_FUNC_NAME;

	TRACE("value: %ld.\n", ptr_measure->values[i * NUM_MAX_EVENTS + j]);
	TRACE("# intervals: %ld.\n", ptr_measure->quant_intervals[i]);

	double measure = (double) (((double) ptr_measure->values[i * NUM_MAX_EVENTS + j]) / ((double) ptr_measure->quant_intervals[i]));
	TRACE("measured: %10.6f.\n", measure);
	return measure;
}

/* ------------------------------------------------------------ */
double measured_percentual(int i, int j){
	PRINT_FUNC_NAME;
	double measure = (measured(i,j) * measured_chunks());
	TRACE("measured percentual: %10.6f.\n", measure);
	return measure;
}

/* ------------------------------------------------------------ */
double estimated(int i, int j){
	PRINT_FUNC_NAME;
	double estimative = (measured(i,j) * total_of_chunks());
	TRACE("estimative: %10.6f\n", estimative);
	return estimative;
}

/* ------------------------------------------------------------ */
double work(){
	PRINT_FUNC_NAME;
	double w = estimated(IDX_FPO, 2);
	TRACE("work: %10.6f\n", w);
	return w;
}

/* ------------------------------------------------------------ */
double Qr(int i, int j){
	PRINT_FUNC_NAME;
	TRACE("Getting Qr(%d,%d).\n", i, j);
	double qr = estimated(i, j) * CACHE_LINE_SIZE;
	TRACE("Qr(%d,%d): %10.6f\n", i, j, qr);
	return qr;
}

/* ------------------------------------------------------------ */
double Qw(int i, int j){
	PRINT_FUNC_NAME;
	TRACE("Getting Qw(%d,%d).\n", i, j);
	double qw = estimated(i, j) * CACHE_LINE_SIZE;
	TRACE("Qw(%d,%d): %10.6f\n", i, j, qw);
	return qw;
}

/* ------------------------------------------------------------ */
double Q_level(int i){
	PRINT_FUNC_NAME;
	double qlevel = (Qr(i, event_position[i]) + Qw(i, event_position[i]));
	TRACE("Q_level(%d): %10.6f\n", i, qlevel);
	return qlevel;
}

/* ------------------------------------------------------------ */
double Q_total(){
	PRINT_FUNC_NAME;
	double qtotal = ( Q_level(IDX_MEM) + Q_level(IDX_LLC) + Q_level(IDX_L2) + Q_level(IDX_L1) );
	TRACE("Q_total: %10.6f\n", qtotal);
	return qtotal;
}

/* ------------------------------------------------------------ */
/* Operational Intensity.										*/
double RM_get_operational_intensity(void){
	PRINT_FUNC_NAME;

	// Operational intensity.
	double I = 0.0;
	// Work.
	double W = 0.0;
	// Memory traffic.
	double Q, Q_MEM, Q_LLC, Q_L2, Q_L1 = 0.0;

	// W.
	W = work();
	TRACE("W: %10.6f\n", W);

	// Q = Q_MEM + Q_LLC + Q_L2 + Q_L1.
	Q = Q_total();
	TRACE("Q: %10.6f\n", Q);

	I =  (double) W / Q;

	TRACE("I: %10.6f\n", I);

	Q_L1 = Q_level(IDX_L1);
	Q_L2 = Q_level(IDX_L1) + Q_level(IDX_L2);
	Q_LLC = Q_level(IDX_L1) + Q_level(IDX_L2) + Q_level(IDX_LLC);
	Q_MEM = Q;
	
	TRACE("I_L1: %10.6f\n", (double) W / Q_L1);	
	TRACE("I_L2: %10.6f\n", (double) W / Q_L2);	
	TRACE("I_LLC: %10.6f\n", (double) W / Q_LLC);	
	TRACE("I_MEM: %10.6f\n", (double) W / Q_MEM);

	return I;
}

/* ------------------------------------------------------------ */
/* Operational Intensity.										*/
double RM_get_operational_intensity_in_GPU(void){
	PRINT_FUNC_NAME;

	// Operational intensity.
	double I = 0.0;
	// Work.
	double W = 0.0;
	// Memory traffic.
	double Q_data_transfer, Q = 0.0;

	// W.
	W = work();
	TRACE("W: %f\n", W);

	// Q = Q_MEM + Q_LLC + Q_L2 + Q_L1.
	Q = Q_total();
	TRACE("Q: %10.6f\n", Q);

	Q_data_transfer = ptr_measure->q_data_transfer_read + ptr_measure->q_data_transfer_write;
	TRACE("Q_data_transfer: %f\n", Q_data_transfer);

	I =  (double) W / (Q + Q_data_transfer);

	TRACE("I_GPU: %10.6f\n", I);

	return I;
}

/* ------------------------------------------------------------*/
/* Calc time computation.                                      */
double RM_time_computation(double w, double p){
	PRINT_FUNC_NAME;
	TRACE("Calculating time computation with W %10.6f and performance P %10.6f\n", w, p);
	double tcomp = 0.0;
	// P = W / T -> T = W / P
	tcomp = w / p;

	TRACE("T_comp: %10.6f\n", tcomp);

	return tcomp;
}

/* ------------------------------------------------------------ */
/* Calc time data transfer.                                     */
double RM_time_data_transfer(int id_device){
	PRINT_FUNC_NAME;
	TRACE("Calculating time of data transfer.\n");

	double t_data_transfer = 0.0;
	
	if(id_device > 0){
		// t_data_transfer = (ptr_measure->q_data_transfer_write * T_WRITE_BYTE) + (ptr_measure->q_data_transfer_read * T_READ_BYTE);
		t_data_transfer = devices[id_device].latency + 
						(ptr_measure->q_data_transfer_write / devices[id_device].efect_bandwidth[MEMORY_WRITE][ptr_measure->type_of_data_allocation]) + 
						(ptr_measure->q_data_transfer_read / devices[id_device].efect_bandwidth[MEMORY_READ][ptr_measure->type_of_data_allocation]);
	}

	TRACE("T_data_transfer: %10.6f\n", t_data_transfer);

	return t_data_transfer;
}

/* ------------------------------------------------------------ */
/* Calc time of execution.                                      */
double RM_execution_time(int id_device, double w, double p){
	PRINT_FUNC_NAME;
	double texec = 0.0;

	TRACE("Calculating time execution of %d with W %10.6f and performance P %10.6f\n", id_device, w, p);
	
	texec = RM_time_computation(w, p) + RM_time_data_transfer(id_device);
	
	TRACE("T_exec: %10.6f\n", texec);

	return texec;
}

/* ------------------------------------------------------------ */
/* Calc Attainable performance in device                        */
double RM_attainable_performance(int id_device, double op_intensity){
	PRINT_FUNC_NAME;
	double ap = 0.0;

	TRACE("Calculating Attainable Performance to device %d with Operational intensity %10.6f\n", id_device, op_intensity);
	// Attainable performance = Min( F_flops, B_mem * I).
	ap = MIN(devices[id_device].theor_flops, (devices[id_device].theor_bandwidth * op_intensity));
	
	TRACE("AP in device %d: %10.6f\n", id_device, ap);

	return ap;
}

/* ------------------------------------------------------------ */
/* Better Device to execution.									*/
int RM_get_better_device_to_execution(double oi){
	PRINT_FUNC_NAME;
	int i = 0;
	double oi_dev = 0.0;

	double texec = 0.0;

	TRACE("Operational intensity in CPU: %10.10f\n", oi);

	double oi_gpu = RM_get_operational_intensity_in_GPU();
	TRACE("Operational intensity in CPU: %10.10f\n", oi);
	TRACE("Operational intensity in GPU: %10.10f\n", oi_gpu);

	int best_dev = 0;
	double best_texec = DBL_MAX;
	double best_ap = 0.0;
	double calc_ap = 0.0;
	for(i = 0; i < NUM_DEVICES; i++){
		if(i == 0){
			oi_dev = oi;
		}
		else{
			oi_dev = oi_gpu;
		}

		calc_ap = RM_attainable_performance(i, oi_dev);

		texec = RM_execution_time(i, work(), calc_ap);

		TRACE("Texec: %10.6f on device %d.\n", texec, i);

		if (texec < best_texec){
			best_texec = texec;
			best_ap = calc_ap;
			best_dev = i;
			TRACE("High Attainable Performance: %10.6f on device %d.\n", best_ap, best_dev);
		}
	}
	TRACE("Chosen device: %d.\n", best_dev);

	fprintf(stderr, "oi_cpu, oi_gpu, ap_cpu, ap_gpu, best_ap, best_dev \n");
	fprintf(stderr, "%10.10f, %10.10f, %10.10f, %10.10f, %d\n", oi, oi_gpu, RM_attainable_performance(0, oi), RM_attainable_performance(1, oi), best_ap, best_dev);
	
	// return 0;
	
	return best_dev;
}

/* ------------------------------------------------------------ */
bool RM_check_all_eventsets_was_collected(void){
	PRINT_FUNC_NAME;
	int i = 0;
	int were_collected = 0;

	for ( i = 0; i < NUM_EVENT_SETS; i++ ){
		if(ptr_measure->quant_intervals[i] > 0){
			were_collected++; 
		}
	}
	TRACE("Number of collected events sets: %d of %d.\n", were_collected, NUM_EVENT_SETS);
	return (were_collected == NUM_EVENT_SETS);
}

/* ------------------------------------------------------------ */
/* Better Device to execution.									*/
bool RM_decision_about_offloading(long *better_device_index){
	PRINT_FUNC_NAME;

	bool offload_decision = true;
	double oi = 0.0;

	/* Verify if have measures enough to calculate decision. */
	if ((offload_decision = RM_check_all_eventsets_was_collected()) == true){
		oi = RM_get_operational_intensity();
		TRACE("Operational intensity: %10.6f\n", oi);
		*better_device_index = RM_get_better_device_to_execution(oi);
	}
	else {
		TRACE("Decision is not possible.\n");
		*better_device_index = 0;
	}

	TRACE("Execution is better on device [%d].\n", *better_device_index);
	
	return offload_decision;
}
/* ------------------------------------------------------------ */
bool RM_destroy_event_sets(void){
	int i, retval = 0;
	/*TRACE("Trying to clean up the event set.\n");
		if ((retval = PAPI_cleanup_eventset(ptr_measure->EventSet)) != PAPI_OK){
			TRACE("PAPI_cleanup_eventset error.\n");
			RM_papi_handle_error(__FUNCTION__, retval, __LINE__);
		}
		else{
			TRACE("PAPI_cleanup_eventset OK.\n");
		}*/
	for(i = 0; i < NUM_PAPI_EVENT_SETS; i++){
		TRACE("Trying to destroy EventSet, ptr_measure->EventSets[%d].\n", i);
		if ((retval = PAPI_destroy_eventset(&ptr_measure->EventSets[i])) != PAPI_OK){
			TRACE("PAPI_destroy_eventset error.\n");
			RM_papi_handle_error(__FUNCTION__, retval, __LINE__);
			return false;
		}
		else{
			TRACE("PAPI_destroy_eventset OK.\n");
		}
	}
	return true;		
}
/* ------------------------------------------------------------ */
bool RM_library_shutdown(void){
	PRINT_FUNC_NAME;
	int retval = 0;

  	/* Event set was created. */
  	TRACE("Trying to destroy event sets.\n");
	if(papi_eventsets_were_created){
		if(RM_destroy_event_sets()){
			TRACE("EventSets were destroied.\n");
			papi_eventsets_were_created = false;
		}
	}

	/* Thread was registered. */
  	TRACE("Trying to unregister thread calling PAPI_unregister_thread().\n");
  	if(thread_was_registred_in_papi){
  		if ((retval = PAPI_unregister_thread()) != PAPI_OK){
  			TRACE("PAPI_unregister_thread error.\n");
  			RM_papi_handle_error(__FUNCTION__, retval, __LINE__);
		}
		else{
			TRACE("PAPI_unregister_thread OK.\n");
			thread_was_registred_in_papi = false;
		}
  	}

  	TRACE("Calling the PAPI shutdown: %d\n", papi_library_initialized);
	if(papi_library_initialized){
  		/* PAPI shutdown. */
		PAPI_shutdown();
		papi_library_initialized = false;
  	}

	TRACE("Trying to free allocated structures.\n");
	free(ptr_measure->values);
	free(ptr_measure->quant_intervals);
	free(ptr_measure);

	started_measuring = false;
		
	return (retval == PAPI_OK);
}

/* ------------------------------------------------------------ */
int RM_get_num_events_sets(){
	PRINT_FUNC_NAME;
	
	return NUM_EVENT_SETS;
}

/* ------------------------------------------------------------ */