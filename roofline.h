#ifndef roofline_h__
#define roofline_h__
 
#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <sys/time.h>
#include <pthread.h>
#include <papi.h>

#define VERBOSE 1
// Use make OPTIONS=-DVERBOSE
#ifdef VERBOSE
#define RM_FUNC_NAME fprintf(stderr, "[%s] Calling [%s]\n", __FILE__, __FUNCTION__)
#else
#define RM_FUNC_NAME (void) 0
#endif


#define RM_papi_handle_error(n) \
  fprintf(stderr, "%s: PAPI error %d: %s\n",__FUNCTION__, n,PAPI_strerror(n))



#define NUM_EVENTS 2

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

#ifdef __cplusplus 
extern "C" {
#endif
	/* PAPI */
	bool RM_library_init(void);

	bool RM_initialization_of_papi_libray_mode(void);

	bool RM_start_counters(void);

	bool RM_stop_counters(void);

	double RM_get_operational_intensity(void);
	
#ifdef __cplusplus
}
#endif

#endif // roofline_h__
