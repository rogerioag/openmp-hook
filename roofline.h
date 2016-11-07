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
#include <float.h>

#include "debug.h"
#include "platform.h"

#define RM_check_perf_event_paranoid() (system("cat /proc/sys/kernel/perf_event_paranoid"))

#define RM_papi_handle_error(function_name, n_error, n_line) \
  fprintf(stderr, "[RM_papi_handle_error] %s -> %s [line %d]: PAPI error %d: %s\n", __FILE__, function_name, n_line, n_error, PAPI_strerror(n_error));

#define MIN(a,b) (((a)<(b))?(a):(b))
#define MAX(a,b) (((a)>(b))?(a):(b))

/* Macro definition to control the force NO Offloadig. To overhead verification. */
#if defined(FORCENOOFFLOAD)
 #define DEV_OFFLOAD 0
#else
 #define DEV_OFFLOAD best_dev
#endif

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

  /*Type of allocation memory (pageable (malloc), pinned (CudaMallocHost))*/
  unsigned int type_of_data_allocation;
};

/* Control the measure session init. */
sem_t mutex_measure_session_init;

static bool is_roofline_initialized = false;

static bool is_measure_session_initialized = false;

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

  bool RM_measure_session_init(void);

  bool RM_measure_session_finish(void);

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

  bool RM_unregister_papi_thread(void);

	bool RM_create_event_sets(void);

  bool RM_destroy_event_sets(void);

	void RM_print_counters_values(void);
  
  void RM_print_counters_values_csv(void);

	void RM_set_aditional_parameters(long long, long long, long long, long long, long long, unsigned int);

  int RM_get_num_events_sets();
	
#ifdef __cplusplus
}
#endif

#endif // roofline_h__
