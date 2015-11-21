#ifndef roofline_h__
#define roofline_h__
 
#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <sys/time.h>
#include <string.h>
#include <pthread.h>
#include <semaphore.h>
#include <papi.h>
#include <omp.h>

#include "debug.h"

#define RM_papi_handle_error(function_name, n_error, n_line) \
  fprintf(stderr, "[RM_papi_handle_error] %s -> %s [line %d]: PAPI error %d: %s\n", __FILE__, function_name, n_line, n_error, PAPI_strerror(n_error));

#define NUM_EVENT_SETS 4
#define NUM_MAX_EVENTS 5

// Events more PAPI_get_real_cyc() that work with time stamp counter (tsc), getting the value of rdtsc.

/* Names of Events. */
static char *event_names[NUM_EVENT_SETS][NUM_MAX_EVENTS] = { 
/* L3_event_names */ { "PAPI_TOT_CYC", "PAPI_REF_CYC", "PAPI_L3_TCR", "PAPI_L3_TCW", NULL },
/* L2_event_names */ { "PAPI_TOT_CYC", "PAPI_REF_CYC", "PAPI_L2_TCR", "PAPI_L2_TCW", NULL },
/* L1_event_names */ { "PAPI_TOT_CYC", "PAPI_REF_CYC", "PAPI_L1_TCR", "PAPI_L1_TCW", NULL },
/* FPO_event_names */{ "PAPI_TOT_CYC", "PAPI_REF_CYC", "PAPI_DP_OPS", 		 NULL, NULL }
};

/* Struct to registry performance counters and time. */
struct _papi_thread_record {
  /* Shared EventSet. Each set of events is copied to this to get measures. */
  int EventSet = PAPI_NULL;

  struct timeval initial_time;
  struct timeval final_time;
  long long start_cycles, end_cycles;
  long long start_usec, end_usec;

  /* Values. */
  // long long *values;
  long long values[NUM_EVENT_SETS][NUM_MAX_EVENTS] = {  
   	{0, 0, 0, 0, 0},
   	{0, 0, 0, 0, 0},
   	{0, 0, 0, 0, 0},
   	{0, 0, 0, 0, 0}
  };
  
  /* Current EventSet in measuring. */
  static int current_eventset = 0;

  static int quant_intervals[NUM_EVENT_SETS] = {  
  /* FPO_event_names */0,
  /* L1_event_names */ 0,
  /* L2_event_names */ 0,
  /* L3_event_names */ 0
  };
};

/* Registry for thread. */
struct _papi_thread_record *ptr_measure = NULL;

/* For read values that are discarded*/
long long discarded_values = 0;

static pthread_key_t papi_thread_info_key;

static bool papi_library_initialized = false;

static bool papi_eventset_was_created = false;
// static bool papi_in_multiplexing_mode = false;

static bool thread_was_registred_in_papi = false;

/* Control of measuring. */
static bool started_measuring = false;

#ifdef __cplusplus 
extern "C" {
#endif
	/* PAPI */
	bool RM_library_init(void);

	bool RM_library_shutdown(void);

	bool RM_initialization_of_papi_libray_mode(void);

	// void RM_papi_handle_error(int n);

	bool RM_check_event_is_available(unsigned int event, bool print_it);

	bool RM_start_counters(void);

	bool RM_registry_measures (void);

	bool RM_stop_measures(void);	

	void RM_print_event_info(unsigned int event);

	double RM_get_operational_intensity(void);

	int RM_get_better_device_to_execution(void);

	bool RM_decision_about_offloading(long *);

	bool RM_register_papi_thread(void);

	bool RM_create_event_set(void);

	void RM_print_counters_values(void);
	
#ifdef __cplusplus
}
#endif

#endif // roofline_h__
