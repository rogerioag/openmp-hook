#ifndef roofline_h__
#define roofline_h__
 
#include <dlfcn.h>
#include <stdio.h>
#include <stdint.h>
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

static pthread_key_t papi_thread_info_key;



#define NUM_EVENTS 2

long long values[NUM_EVENTS];
long long int Events[NUM_EVENTS]={PAPI_TOT_INS, PAPI_TOT_CYC};

int EventSet = PAPI_NULL;

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
