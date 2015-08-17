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
	bool result = true;

	ptr_measure = (struct _papi_thread_record *) malloc(sizeof(struct _papi_thread_record));
	ptr_measure->values = (long_long *) malloc(sizeof(long_long) * NUM_EVENTS);

	// ptr_measure->initial_time = 0;
	// ptr_measure->final_time = 0;
	ptr_measure->EventSet = PAPI_NULL;

	result = RM_initialization_of_papi_libray_mode();

	return result;
}

/* ------------------------------------------------------------- */
/* Function to initialization of PAPI Library.                   */
bool RM_initialization_of_papi_libray_mode(){
	RM_FUNC_NAME;
	
	int retval;
	pthread_key_create(&papi_thread_info_key, NULL );

	retval = PAPI_library_init(PAPI_VER_CURRENT);
	if (retval != PAPI_VER_CURRENT && retval > 0){
		fprintf(stderr, "PAPI_library_init error: %d\n", retval);
		fprintf(stderr, "PAPI library version mismatch!\n");
		RM_papi_handle_error(retval);
	}
	
	if ((retval = PAPI_thread_init((unsigned long (*)(void)) (pthread_self()))) != PAPI_OK){
        RM_papi_handle_error(retval);
        if (retval == PAPI_ESBSTR)
			fprintf(stderr, "PAPI_thread_init error: %d\n", retval);
	}

	// __papi_init_counter_ids();
    // __papi_select_counters();

	papi_library_initialized = 1;

	return (retval == PAPI_OK);
}

/* ------------------------------------------------------------ */
/* Print the counters and values.								*/
void RM_print_counters_values(void){
	int i;
	char event_str[PAPI_MAX_STR_LEN];

	for (i = 0; i < NUM_EVENTS; i++) {
		PAPI_event_code_to_name(ptr_measure->events[i], event_str);
		fprintf(stderr, "Event: %d - %s : %lld\n", ptr_measure->events[i], event_str, ptr_measure->values[i]);
	}
}

/* ------------------------------------------------------------ */
/* Start counters.												*/
bool RM_start_counters (void){
	RM_FUNC_NAME;
	
	int i, retval;
  	unsigned long int tid;

  	if(!papi_library_initialized){
  		RM_initialization_of_papi_libray_mode();
  	}
 
	// retval = PAPI_thread_init((unsigned long (*)(void)) (lib_GOMP_get_thread_num));
	/* The OpenMP call omp_get_thread_num() violates this rule, as the underlying LWPs may 
	 * have been killed off by the run-time system or by a call to omp_set_num_threads() . 
	 * In that case, it may still possible to use omp_get_thread_num() in conjunction with 
	 * PAPI_unregister_thread() when the OpenMP thread has finished. However it is much 
	 * better to use the underlying thread subsystem's call, which is pthread_self() 
	 * on Linux platforms. */

	PAPI_register_thread();

	if ((tid = PAPI_thread_id()) == (unsigned long int)-1)
		fprintf(stderr, "PAPI_thread_id error.\n");
	else fprintf(stderr, "Thread id is: %lu\n",tid);

	/* Create an EventSet */
  	if (PAPI_create_eventset(&ptr_measure->EventSet) != PAPI_OK)
    	fprintf(stderr, "PAPI_create_eventset error.\n");

	/* Add Total Instructions Executed to our EventSet */
  	//if (PAPI_add_event(EventSet, PAPI_TOT_INS) != PAPI_OK)
	//	fprintf(stderr, "PAPI_add_event error PAPI_TOT_INS.\n");
	
	//if (PAPI_add_event(EventSet, PAPI_TOT_CYC) != PAPI_OK)
	//	fprintf(stderr, "PAPI_add_event error PAPI_TOT_CYC.\n");

	/* Add events to EventSet */
	for (i = 0; i < NUM_EVENTS; i++) {
		retval = PAPI_add_event(ptr_measure->EventSet, ptr_measure->events[i]);
	    if(retval != PAPI_OK) {
	      RM_papi_handle_error(retval);
	    }
	}

	/* Start counting */
  	if ((retval = PAPI_start(ptr_measure->EventSet)) != PAPI_OK) {
		fprintf(stderr, "PAPI_start() counting error.\n");
		if (retval == PAPI_ECNFLCT) {
	      fprintf(stderr, "PAPI error %d (%s): It is likely that you selected too many counters to monitor\n",
		      retval, PAPI_strerror(retval));
	    }
  	}

  	/* First measure. */
  	if ((retval = PAPI_stop(ptr_measure->EventSet, ptr_measure->values)) != PAPI_OK) {
	    fprintf(stderr, "PAPI_stop() counting error.\n");
	}

	/* Gets the starting time in clock cycles */
	ptr_measure->start_cycles = PAPI_get_real_cyc();

	/* Gets the starting time in microseconds */
	ptr_measure->start_usec = PAPI_get_real_usec();

	/* Final measure. */
	if ((retval = PAPI_start(ptr_measure->EventSet)) != PAPI_OK) {
		fprintf(stderr, "PAPI_start() counting error.\n");
	}

	return (retval == PAPI_OK);
}

/* ------------------------------------------------------------ */
/* Stop counters.												*/
bool RM_stop_counters(void){
	RM_FUNC_NAME;
	
	/* Stop counters and store results in values */
	int retval = PAPI_stop_counters(ptr_measure->values, NUM_EVENTS);

	if(retval != PAPI_OK ){
		fprintf(stderr, "Error on PAPI execution.\n");
		
		switch (retval){
				case PAPI_EINVAL :
					fprintf(stderr, "One or more of the arguments is invalid.\n");
					break;
				case PAPI_ENOTRUN : 
					fprintf(stderr, "The EventSet is not started yet.\n");
					break;
				case PAPI_ENOEVST : 
					fprintf(stderr, "The EventSet has not been added yet.\n");
					break;
			default:
				fprintf(stderr, "Unknown Error.\n");
		}
	}

	/* Gets the ending time in clock cycles */
	ptr_measure->end_cycles = PAPI_get_real_cyc();

	/* Gets the ending time in microseconds */
	ptr_measure->end_usec = PAPI_get_real_usec();
	
	fprintf(stderr, "Wall clock cycles   : \t%lld\n", ptr_measure->end_cycles - ptr_measure->start_cycles );
	fprintf(stderr, "Wall clock time in microseconds: \t%lld\n", ptr_measure->end_usec - ptr_measure->start_usec );
	
	/* Read the counters */
    if (PAPI_read(ptr_measure->EventSet, ptr_measure->values) != PAPI_OK)
    	fprintf(stderr, "PAPI_read error reading counters.\n");

	fprintf(stderr, "After reading counters:\n");
	RM_print_counters_values();

    /* Start the counters */
    if (PAPI_stop(ptr_measure->EventSet, ptr_measure->values) != PAPI_OK)
    	fprintf(stderr, "PAPI_read error stopping counters.\n");
	 
	fprintf(stderr, "After stopping counters:\n");
    RM_print_counters_values();

	return (retval == PAPI_OK);
}

/* ------------------------------------------------------------ */
/* Calculate the Operational Intensity.							*/
double RM_get_operational_intensity(void){

	double oi = 0.0;

	return oi;
}