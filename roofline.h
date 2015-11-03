#ifndef roofline_h__
#define roofline_h__
 
#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <sys/time.h>
#include <pthread.h>
#include <semaphore.h>
#include <papi.h>
#include <omp.h>

#include "debug.h"

/*#define RM_papi_handle_error(n) \
  fprintf(stderr, "%s: PAPI error %d: %s\n",__FUNCTION__, n,PAPI_strerror(n))
 */

#define RM_papi_handle_error(function_name, n_error, n_line) \
  fprintf(stderr, "[RM_papi_handle_error] %s -> %s [line %d]: PAPI error %d: %s\n", __FILE__, function_name, n_line, n_error, PAPI_strerror(n_error));

#define NUM_FPO_EVENTS 1
#define NUM_MEM_EVENTS 2
#define NUM_TIME_EVENTS 2

#define NUM_EVENTS (NUM_FPO_EVENTS + NUM_MEM_EVENTS + NUM_TIME_EVENTS)

/* Events need to Float Point Operations. */
// int FPO_event_codes[NUM_FPO_EVENTS] = {PAPI_FP_INS, PAPI_FP_OPS, PAPI_SP_OPS, PAPI_DP_OPS, PAPI_VEC_SP, PAPI_VEC_DP};
int FPO_event_codes[NUM_FPO_EVENTS] = {PAPI_DP_OPS};
/* Events for Memory. */
int MEM_event_codes[NUM_MEM_EVENTS] = {PAPI_L3_TCR, PAPI_L3_TCW};
/* Time Events. */
#define UNHALTED_CORE_CYCLES 0x40000000
#define UNHALTED_REFERENCE_CYCLES 0x40000001
int TIME_event_codes[NUM_TIME_EVENTS] = {UNHALTED_CORE_CYCLES, UNHALTED_REFERENCE_CYCLES};

// Events more PAPI_get_real_cyc() that work with time stamp counter (tsc), getting the value of rdtsc.

/* Struct to registry performance counters and time. */
struct _papi_thread_record {
  int *events;
  long_long *values;
  int EventSet = PAPI_NULL;
  struct timeval initial_time;
  struct timeval final_time;

  long_long start_cycles, end_cycles;
  long_long start_usec, end_usec;
};

struct _papi_thread_record *ptr_measure = NULL;

sem_t mutex;

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
	
#ifdef __cplusplus
}
#endif

#endif // roofline_h__
