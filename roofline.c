#include "roofline.h"

/* ------------------------------------------------------------ */
/* Info and Test function.										*/
void info(void) {
	puts("Hello, I'm a shared library.\n");
}

/* ------------------------------------------------------------ */
/* Init library.												*/
bool RM_library_init(void){
	boot result = true;

	result = RM_initialization_of_papi_libray_mode();

	return result;
}

/* ------------------------------------------------------------- */
/* Function to initialization of PAPI Library.                   */
bool RM_initialization_of_papi_libray_mode(){
	RM_FUNC_NAME;
	
	int retval;
	unsigned long int tid;

	retval = PAPI_library_init(PAPI_VER_CURRENT);
	if (retval != PAPI_VER_CURRENT && retval > 0){
		fprintf(stderr, "PAPI_library_init error: %d\n", retval);
		fprintf(stderr, "PAPI library version mismatch!\n");
		RM_papi_handle_error(retval);
	}

	return (retval == PAPI_OK);
}

/* ------------------------------------------------------------ */
/* Start counters.												*/
bool RM_start_counters(void){
	RM_FUNC_NAME;
	
	int retval;
  	unsigned long int tid;
 
	// retval = PAPI_thread_init((unsigned long (*)(void)) (lib_GOMP_get_thread_num));
	/* The OpenMP call omp_get_thread_num() violates this rule, as the underlying LWPs may 
	 * have been killed off by the run-time system or by a call to omp_set_num_threads() . 
	 * In that case, it may still possible to use omp_get_thread_num() in conjunction with 
	 * PAPI_unregister_thread() when the OpenMP thread has finished. However it is much 
	 * better to use the underlying thread subsystem's call, which is pthread_self() 
	 * on Linux platforms. */

	pthread_key_create(&papi_thread_info_key, NULL );
	
	if ((retval = PAPI_thread_init((unsigned long (*)(void)) (pthread_self()))) != PAPI_OK){
        RM_papi_handle_error(retval);
        if (retval == PAPI_ESBSTR)
			fprintf(stderr, "PAPI_thread_init error: %d\n", retval);
	}

	if ((tid = PAPI_thread_id()) == (unsigned long int)-1)
		fprintf(stderr, "PAPI_thread_id error.\n");
	else fprintf(stderr, "Thread id is: %lu\n",tid);	
	
	/* Create an EventSet */
  	if (PAPI_create_eventset(&EventSet) != PAPI_OK)
    	fprintf(stderr, "PAPI_create_eventset error.\n");

	/* Add Total Instructions Executed to our EventSet */
  	if (PAPI_add_event(EventSet, PAPI_TOT_INS) != PAPI_OK)
		fprintf(stderr, "PAPI_add_event error PAPI_TOT_INS.\n");
	
	if (PAPI_add_event(EventSet, PAPI_TOT_CYC) != PAPI_OK)
		fprintf(stderr, "PAPI_add_event error PAPI_TOT_CYC.\n");

  	/* Start counting */
  	if ((retval = PAPI_start(EventSet)) != PAPI_OK)
		fprintf(stderr, "PAPI_start counting error.\n");

	return (retval == PAPI_OK);
}

/* ------------------------------------------------------------ */
/* Stop counters.												*/
bool RM_stop_counters(void){
	RM_FUNC_NAME;
	
	long long elapsed_us, elapsed_cyc;

	/* Stop counters and store results in values */
	int retval = PAPI_stop_counters(values, NUM_EVENTS);

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

	fprintf(stderr, "Total insts: %lld Total Cycles: %lld\n", (long long int) values[0], (long long int) values[1]);	
	
	elapsed_us = PAPI_get_real_usec();
	elapsed_cyc = PAPI_get_real_cyc();
	
	fprintf(stderr, "Master real usec   : \t%lld\n", elapsed_us );
	fprintf(stderr, "Master real cycles : \t%lld\n", elapsed_cyc );
	
	/* Read the counters */
   if (PAPI_read(EventSet, values) != PAPI_OK)
     fprintf(stderr, "PAPI_read error reading counters.\n");

	 fprintf(stderr, "After reading counters: Total insts: %lld Total Cycles: %lld\n", (long long int) values[0], (long long int) values[1]);

   /* Start the counters */
   if (PAPI_stop(EventSet, values) != PAPI_OK)
     fprintf(stderr, "PAPI_read error stopping counters.\n");
	 
	 printf("After stopping counters: Total insts: %lld Total Cycles: %lld\n", (long long int) values[0], (long long int) values[1]);

	return (retval == PAPI_OK);
}

/* ------------------------------------------------------------ */
/* Calculate the Operational Intensity.							*/
double RM_get_operational_intensity(void){

	double oi = 0.0

	return oi;
}