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
#include <unistd.h>
#include <stdbool.h>

#include "debug.h"
#include "platform.h"

#define RM_papi_handle_error(function_name, n_error, n_line) \
  fprintf(stderr, "[RM_papi_handle_error] %s -> %s [line %d]: PAPI error %d: %s\n", __FILE__, function_name, n_line, n_error, PAPI_strerror(n_error));

#define MIN(a,b) (((a)<(b))?(a):(b))
#define MAX(a,b) (((a)>(b))?(a):(b))

/* Cache line size: 64 bytes. http://www.cpu-world.com/CPUs/Xeon/Intel-Xeon%20E5-2630.html */
#define CACHE_LINE_SIZE 64

/* One to preset, cpu and other to native and uncore. */
#define NUM_PAPI_EVENT_SETS 2

#define NUM_EVENT_SETS 5
#define NUM_MAX_EVENTS 5

/* Events more PAPI_get_real_cyc() that work with time stamp counter (tsc), getting the value of rdtsc. */

/* Indexes to define the position of values. */
#define IDX_MEM 0
#define IDX_LLC 1
#define IDX_L2 2
#define IDX_L1 3
#define IDX_FPO 4

#define COMP_CORE 0
#define COMP_UNCORE 1

/* Names of Events. */
/* Attention: Position is important to read the table values after. */
static char *event_names[NUM_EVENT_SETS][NUM_MAX_EVENTS] = { 
/* MEM_event_names */ //{ "ivbep_unc_ha0::UNC_H_IMC_READS:cpu=0", "ivbep_unc_ha0::UNC_H_IMC_WRITES:cpu=0", NULL, NULL, NULL },
/* MEM_event_names */{ "UNC_H_IMC_READS", "UNC_H_IMC_WRITES", NULL, NULL, NULL },
// /* L3_event_names */ { "PAPI_TOT_CYC", "PAPI_REF_CYC", "PAPI_L3_TCR", "PAPI_L3_TCW", NULL },
/* L3_event_names */ { "PAPI_TOT_CYC", "PAPI_REF_CYC", "PAPI_L3_DCR", "PAPI_L3_DCW", NULL },  
/* L2_event_names */ { "PAPI_TOT_CYC", "PAPI_REF_CYC", "PAPI_L2_DCR", "PAPI_L2_DCW", NULL },
///* L1_event_names */ { "PAPI_TOT_CYC", "PAPI_REF_CYC", "PAPI_L1_TCR", "PAPI_L1_TCW", NULL },
/* L1_event_names */ { "UNHALTED_CORE_CYCLES", "UNHALTED_REFERENCE_CYCLES", "perf::PERF_COUNT_HW_CACHE_L1D:READ", "perf::PERF_COUNT_HW_CACHE_L1D:WRITE", NULL },
/* FPO_event_names */{ "PAPI_TOT_CYC", "PAPI_REF_CYC", "PAPI_DP_OPS", 		 NULL, NULL }
};

/* Position, column in te values table according with events names. */
static int event_position[NUM_EVENT_SETS] = { 
/* MEM_events */  0 ,
/* L3_events  */  2,
/* L2_events  */  2 ,
/* L1_events  */  2 ,
/* FPO_events */  2 
};

/* The kind of component the eventset was associated. Is need different event sets to measures preset events and native events. 
   Components cpu (0) and perf_event_uncore to uncore events are associated with EventSet. 
   This kind is used to switch between EventSets. */
static int kind_of_event_set[NUM_EVENT_SETS] = { 
/* MEM_event_names */ COMP_UNCORE ,
/* L3_event_names */  COMP_CORE ,
/* L2_event_names */  COMP_CORE ,
/* L1_event_names */  COMP_CORE ,
/* FPO_event_names */ COMP_CORE 
};

/* Struct to registry performance counters and time. */
struct _papi_thread_record {
  /* Shared EventSet. Each set of events is copied to this to get measures. */
  /* EventSets[0] for core and preset events. EventSet[1] for uncore and native events. */
  int *EventSets;  

  struct timeval initial_time;
  struct timeval final_time;
  long long start_cycles, end_cycles;
  long long start_usec, end_usec;

  /* Values. */
  long long *values;
  // long long values[NUM_EVENT_SETS][NUM_MAX_EVENTS];
  
  /* Current EventSet in measuring. */
  int current_eventset;

  /* Quantity of measured intervals to EventSet. */
  // int quant_intervals[NUM_EVENT_SETS];
  long long *quant_intervals;

  /* Aditional parameters. */
  long long total_of_iterations;
  long long executed_loop_iterations;
  long long chunk_size;

  /* Data IN to device. */
  long long q_data_transfer_write;
  /* Data OUT from device. */
  long long q_data_transfer_read;
};

/* Registry for thread. */
struct _papi_thread_record *ptr_measure = NULL;

/* For read values that are discarded*/
long long discarded_values = 0;

static pthread_key_t papi_thread_info_key;

static bool papi_library_initialized = false;

static bool papi_eventsets_were_created = false;
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

	bool RM_stop_and_accumulate(void);	

	void RM_print_event_info(unsigned int event);

	double RM_get_operational_intensity(double);

	int RM_get_better_device_to_execution(void);

	bool RM_decision_about_offloading(long *);

	bool RM_register_papi_thread(void);

	bool RM_create_event_sets(void);

  bool RM_destroy_event_sets(void);

	void RM_print_counters_values(void);

	void RM_set_aditional_parameters(long long, long long, long long, long long, long long);
	
#ifdef __cplusplus
}
#endif

#endif // roofline_h__
