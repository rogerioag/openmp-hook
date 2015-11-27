#include "roofline.h"

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
	int i, j;

	/*Create the structures to get measures. */
	ptr_measure = (struct _papi_thread_record *) malloc(sizeof(struct _papi_thread_record));
	ptr_measure->values = (long long *) malloc(sizeof(long long) * NUM_EVENT_SETS * NUM_MAX_EVENTS);

	ptr_measure->quant_intervals = (long long *) malloc(sizeof(long long) * NUM_EVENT_SETS);

	memset(ptr_measure->quant_intervals, 0, NUM_EVENT_SETS * sizeof(*ptr_measure->quant_intervals));

	memset(ptr_measure->values, 0, NUM_EVENT_SETS * NUM_MAX_EVENTS * sizeof(*ptr_measure->values));

  	ptr_measure->current_eventset = 0;

  	TRACE("values initialization.\n");
  	for ( i = 0; i < NUM_EVENT_SETS; i++ ) {
  		TRACE("# intervals [%d]: %ld\n", i, ptr_measure->quant_intervals[i]);
		for ( j = 0; event_names[i][j] != NULL; j++ ) {
			ptr_measure->values[i * NUM_MAX_EVENTS + j] = 0;
			TRACE("ptr_measure->values[%d][%d]: %ld.\n", i, j, ptr_measure->values[i * NUM_MAX_EVENTS + j]);
		}
	}

	RM_print_counters_values();

	ptr_measure->initial_time = (struct timeval){0};
	ptr_measure->final_time = (struct timeval){0};
	ptr_measure->EventSet = PAPI_NULL;

	/* Aditional parameters. */
	ptr_measure->total_of_iterations = 0;
  	ptr_measure->executed_loop_iterations = 0;
 	ptr_measure->chunk_size = 0;

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

	TRACE("Final Values:\n");
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
    	TRACE("PAPI_create_eventset error: %d %s\n", retval, PAPI_strerror(retval));
    	RM_papi_handle_error(__FUNCTION__, retval, __LINE__);
  	}

  	papi_eventset_was_created = (retval == PAPI_OK);

  	/* Assign it to the CPU component */
	TRACE("Assign it to the CPU component.\n");
	if ((retval = PAPI_assign_eventset_component(ptr_measure->EventSet, 0)) != PAPI_OK){
  		TRACE("PAPI_assign_eventset_component: %d %s\n", retval, PAPI_strerror(retval));
  		RM_papi_handle_error(__FUNCTION__, retval, __LINE__);
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

	RM_check_papi_status();

	TRACE("Leaving the RM_create_event_set: papi_eventset_was_created %d.\n", papi_eventset_was_created);

	return papi_eventset_was_created;
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
	if(!papi_eventset_was_created){
		TRACE("Trying to create event set.\n");
		result = RM_create_event_set();
	}

	TRACE("EventSet: %d\n", ptr_measure->current_eventset);
	for ( j = 0; event_names[ptr_measure->current_eventset][j] != NULL; j++ ) {
		TRACE("Adding[%s].\n", event_names[ptr_measure->current_eventset][j] );
  		if ((retval = PAPI_add_named_event( ptr_measure->EventSet, event_names[ptr_measure->current_eventset][j] )) != PAPI_OK){+
			fprintf(stderr,"PAPI_add_named_event[%s] error: %s\n", event_names[ptr_measure->current_eventset][j], PAPI_strerror(retval));
		}
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

	/* Gets the starting time in clock cycles */
	ptr_measure->start_cycles = PAPI_get_real_cyc();

	/* Gets the starting time in microseconds */
	ptr_measure->start_usec = PAPI_get_real_usec();

	/* Start counting */
	TRACE("Starting counting...\n");
  	if ((retval = PAPI_start(ptr_measure->EventSet)) != PAPI_OK) {
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
	if ((retval = PAPI_accum(ptr_measure->EventSet, &ptr_measure->values[ptr_measure->current_eventset * NUM_MAX_EVENTS + 0])) != PAPI_OK){
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
	if ((retval = PAPI_stop(ptr_measure->EventSet, &discarded_values)) != PAPI_OK){
		TRACE("PAPI_stop error: %d %s\n", retval, PAPI_strerror(retval));
		RM_papi_handle_error(__FUNCTION__, retval, __LINE__);
	}

	TRACE("Removing events of EventSet: %d\n", ptr_measure->current_eventset);
	for ( j = 0; event_names[ptr_measure->current_eventset][j] != NULL; j++ ) {
		TRACE("Removing[%s].\n", event_names[ptr_measure->current_eventset][j] );
  		if ((retval = PAPI_remove_named_event(ptr_measure->EventSet, event_names[ptr_measure->current_eventset][j] )) != PAPI_OK){
			TRACE("PAPI_remove_named_event[%s] error: %s\n", event_names[ptr_measure->current_eventset][j], PAPI_strerror(retval));
		}
	}

	ptr_measure->quant_intervals[ptr_measure->current_eventset] = ptr_measure->quant_intervals[ptr_measure->current_eventset] + 1;

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
	TRACE("[HOOKOMP]: Verifying if started the measuring.\n");
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
 */
 void RM_set_aditional_parameters(long long total_of_iterations, long long executed_loop_iterations, long long chunk_size) {
 	PRINT_FUNC_NAME;

 	ptr_measure->total_of_iterations = total_of_iterations;
  	ptr_measure->executed_loop_iterations = executed_loop_iterations;
  	ptr_measure->chunk_size = chunk_size;

  	TRACE("Total of iterations: %ld, executed_iterations: %lld, chunk_size: %lld.\n", ptr_measure->total_of_iterations, ptr_measure->executed_loop_iterations, ptr_measure->chunk_size);
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
	TRACE("total of chunks: %ld.\n", total_chunks);
	return total_chunks;
}

/* ------------------------------------------------------------ */
// #define MEASURED_CHUNKS (ptr_measure->quant_intervals[0] + ptr_measure->quant_intervals[1] + ptr_measure->quant_intervals[2] + ptr_measure->quant_intervals[3])
long long measured_chunks(){
	PRINT_FUNC_NAME;
	long long measured_chunks = (ptr_measure->quant_intervals[0] + 
			ptr_measure->quant_intervals[1] + 
			ptr_measure->quant_intervals[2] + 
			ptr_measure->quant_intervals[3]);
	TRACE("measured chunks: %ld.\n", measured_chunks);
	return measured_chunks;
}

/* ------------------------------------------------------------ */
double measured(int i, int j){
	PRINT_FUNC_NAME;

	TRACE("value: %ld.\n", ptr_measure->values[i * NUM_MAX_EVENTS + j]);
	TRACE("# intervals: %ld.\n", ptr_measure->quant_intervals[i]);

	double measure = (double) (((double) ptr_measure->values[i * NUM_MAX_EVENTS + j]) / ((double) ptr_measure->quant_intervals[i]));
	TRACE("measured: %f.\n", measure);
	return measure;
}

/* ------------------------------------------------------------ */
double measured_percentual(int i, int j){
	PRINT_FUNC_NAME;
	double measure = (measured(i,j) * measured_chunks());
	TRACE("measured percentual: %f.\n", measure);
	return measure;
}

/* ------------------------------------------------------------ */
double estimated(int i, int j){
	PRINT_FUNC_NAME;
	double estimative = (measured(i,j) * total_of_chunks());
	TRACE("estimative: %f.\n", estimative);
	return estimative;
}

/* ------------------------------------------------------------ */
double work(){
	PRINT_FUNC_NAME;
	double w = estimated(IDX_FPO, 2);
	TRACE("work: %f.\n", w);
	return w;
}

/* ------------------------------------------------------------ */
double Qr(int i){
	PRINT_FUNC_NAME;
	double qr = estimated(i, 2) * CACHE_LINE_SIZE;
	TRACE("Qr: %f.\n", qr);
	return qr;
}

/* ------------------------------------------------------------ */
double Qw(int i){
	PRINT_FUNC_NAME;
	double qw = estimated(i, 3) * CACHE_LINE_SIZE;
	TRACE("Qw: %f.\n", qw);
	return qw;
}

/* ------------------------------------------------------------ */
double Q_level(int i){
	PRINT_FUNC_NAME;
	double qlevel = (Qr(i) + Qw(i));
	TRACE("Q_level: %f.\n", qlevel);
	return qlevel;
}

/* ------------------------------------------------------------ */
double Q_total(){
	PRINT_FUNC_NAME;
	double qtotal = (Q_level(IDX_LLC) + Q_level(IDX_L2) + Q_level(IDX_L1));
	TRACE("Q_total: %f.\n", qtotal);
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
	double Q = 0.0;

	// W.
	W = work();
	TRACE("W: %f\n", W);

	// Q = Q_LLC + Q_L2 + Q_L1.
	Q = Q_total();
	TRACE("Q: %f\n", Q);

	I =  (double) W / Q;

	TRACE("I: %f\n", I);	

	return I;
}

/* ------------------------------------------------------------ */
/* Better Device to execution.									*/
int RM_get_better_device_to_execution(double oi){
	PRINT_FUNC_NAME;
	TRACE("Operational intensity: %10.6f\n", oi);


	
	return 1;
}

/* ------------------------------------------------------------ */
/* Better Device to execution.									*/
bool RM_decision_about_offloading(long *better_device_index){
	PRINT_FUNC_NAME;

	bool offload_decision = true;

	double oi = RM_get_operational_intensity();
	TRACE("Operational intensity: %10.6f\n", oi);

	*better_device_index = RM_get_better_device_to_execution(oi);
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
	// free(ptr_measure->values);
	free(ptr_measure);

	/* PAPI shutdown. */
	TRACE("Calling the PAPI shutdown.\n");
	PAPI_shutdown()
		
	return (retval == PAPI_OK);
}
