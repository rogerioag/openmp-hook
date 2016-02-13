#ifndef hookomp_h__
#define hookomp_h__
 
#include <dlfcn.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdint.h>
#include <semaphore.h>
#include <pthread.h>

#include <ffi.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <inttypes.h>
#include <assert.h>
#include <math.h>

#include "debug.h"
#include "roofline.h"

#ifdef _OPENMP
#include <omp.h>
#else
#define omp_get_thread_num() 0
#define omp_get_num_threads() 1
#endif

#define MIN(a,b) (((a)<(b))?(a):(b))
#define MAX(a,b) (((a)>(b))?(a):(b))

/* Percentual of code to execute and get performance counters to decision about offloading. */
#define PERC_OF_CODE_TO_EXECUTE 10

#define  PRINT_ERROR()					\
  do {									\
    char * error;						\
    if ((error = dlerror()) != NULL)  {	\
      fputs(error, stderr);				\
    }									\
  }while(0)

#define GET_RUNTIME_FUNCTION(hook_func_pointer, func_name)									\
  do {																						\
    if (hook_func_pointer) break;															\
    void *__handle = RTLD_NEXT;																\
    hook_func_pointer = (typeof(hook_func_pointer)) (uintptr_t) dlsym(__handle, func_name);	\
    PRINT_ERROR();																			\
  } while(0)

/* Semaphore to registry the thread which can execute the function to get next block of iterations. */
sem_t mutex_registry_thread_in_func_next;

/* Semaphore to block the first thread to wait others threads. */
sem_t sem_block_registred_thread;

/* Semaphore to block other team threads.*/
sem_t sem_blocks_other_team_threads;

/* Control access to HOOKOMP_initialization. */
sem_t mutex_hookomp_init;

/* Control access to loop initialization. */
sem_t mutex_hookomp_loop_init;

/* Control loop end. */
sem_t mutex_loop_end;

/* Control the threads in final of loop. For parallel regions with 2 or more loops. */
sem_t sem_blocks_threads_in_loop_end;

/* Tipo para o ponteiro de função. */
// typedef void (*op_func) (void);

/* Ponteiro para a função proxy que irá chamar ou *_next ou *_start. */
typedef bool (*chunk_next_fn)(long*, long*, void*);

/* Have too diferents kinds of functions. */
enum FUN_TYPES {
    FUN_START_NEXT,
    FUN_START_NEXT_RUNTIME, // Thank you for more one parameter. :-(
    FUN_NEXT
};

/* Struct for extra parameters in generic next function. */
typedef struct Params_ {
    long _0, _1, _2, _3;
    unsigned int func_type;
    union {
    	bool (*func_start_next) (long start, long end, long incr, long chunk_size, long *istart, long *iend);
    	bool (*func_start_next_runtime) (long start, long end, long incr, long *istart, long *iend);
    	bool (*func_next) (long *istart, long *iend);    	
  	};
} Params;

/* Struct to store pointer and arguments to alternative functions calls. */
typedef struct Func {
	void *f;
	int nargs;
	ffi_type** arg_types;
	void** arg_values;
	ffi_type* ret_type;
	void* ret_value;
	} Func;

/* Ponteiros para as funções que serão recuperadas pela macro get runtime function.*/

	/* barrier.c */

	void (*lib_GOMP_barrier)(void);
	bool (*lib_GOMP_barrier_cancel)(void);

	/* critical.c */

	void (*lib_GOMP_critical_start) (void);
	void (*lib_GOMP_critical_end) (void);
	void (*lib_GOMP_critical_name_start) (void **pptr);
	void (*lib_GOMP_critical_name_end) (void **pptr);
	void (*lib_GOMP_atomic_start) (void);
	void (*lib_GOMP_atomic_end) (void);

	/* loop.c */

	bool (*lib_GOMP_loop_static_start) (long start, long end, long incr, long chunk_size, 
			 long *istart, long *iend);

	bool (*lib_GOMP_loop_dynamic_start) (long start, long end, long incr, long chunk_size, 
			 long *istart, long *iend);

	bool (*lib_GOMP_loop_guided_start) (long start, long end, long incr, long chunk_size,
			long *istart, long *iend);

	bool (*lib_GOMP_loop_runtime_start) (long start, long end, long incr,
			 long *istart, long *iend);

	bool (*lib_GOMP_loop_ordered_static_start) (long start, long end, long incr,
				long chunk_size, long *istart, long *iend);

	bool (*lib_GOMP_loop_ordered_dynamic_start) (long start, long end, long incr,
				 long chunk_size, long *istart, long *iend);

	bool (*lib_GOMP_loop_ordered_guided_start) (long start, long end, long incr,
				long chunk_size, long *istart, long *iend);

	bool (*lib_GOMP_loop_ordered_runtime_start) (long start, long end, long incr,
				 long *istart, long *iend);

	bool (*lib_GOMP_loop_static_next) (long *istart, long *iend);

	bool (*lib_GOMP_loop_dynamic_next) (long *istart, long *iend);

	bool (*lib_GOMP_loop_guided_next) (long *istart, long *iend);

	bool (*lib_GOMP_loop_runtime_next) (long *istart, long *iend);

	bool (*lib_GOMP_loop_ordered_static_next) (long *istart, long *iend);

	bool (*lib_GOMP_loop_ordered_dynamic_next) (long *istart, long *iend);

	bool (*lib_GOMP_loop_ordered_guided_next) (long *istart, long *iend);

	bool (*lib_GOMP_loop_ordered_runtime_next) (long *istart, long *iend);

	void (*lib_GOMP_parallel_loop_static_start) (void (*fn) (void *), void *data,
				 unsigned num_threads, long start, long end,
				 long incr, long chunk_size);

	void (*lib_GOMP_parallel_loop_dynamic_start) (void (*fn) (void *), void *data,
				  unsigned num_threads, long start, long end,
				  long incr, long chunk_size);

	void (*lib_GOMP_parallel_loop_guided_start) (void (*fn) (void *), void *data,
				 unsigned num_threads, long start, long end,
				 long incr, long chunk_size);

	void (*lib_GOMP_parallel_loop_runtime_start) (void (*fn) (void *), void *data,
				  unsigned num_threads, long start, long end,
				  long incr);

	void (*lib_GOMP_parallel_loop_static) (void (*fn) (void *), void *data,
			   unsigned num_threads, long start, long end,
			   long incr, long chunk_size, unsigned flags);

	void (*lib_GOMP_parallel_loop_dynamic) (void (*fn) (void *), void *data,
			    unsigned num_threads, long start, long end,
			    long incr, long chunk_size, unsigned flags);

	void (*lib_GOMP_parallel_loop_guided) (void (*fn) (void *), void *data,
			  unsigned num_threads, long start, long end,
			  long incr, long chunk_size, unsigned flags);
	
	void (*lib_GOMP_parallel_loop_runtime) (void (*fn) (void *), void *data,
			    unsigned num_threads, long start, long end,
			    long incr, unsigned flags);
	
	void (*lib_GOMP_loop_end) (void);
	void (*lib_GOMP_loop_end_nowait) (void);
	bool (*lib_GOMP_loop_end_cancel) (void);

	/* loop_ull.c */

	bool (*lib_GOMP_loop_ull_static_start) (bool up, unsigned long long start, unsigned long long end,
			    unsigned long long incr, unsigned long long chunk_size,
			    unsigned long long *istart, unsigned long long *iend);

	bool (*lib_GOMP_loop_ull_dynamic_start) (bool up, unsigned long long start, unsigned long long end,
			     unsigned long long incr, unsigned long long chunk_size,
			     unsigned long long *istart, unsigned long long *iend);


	bool (*lib_GOMP_loop_ull_guided_start) (bool up, unsigned long long start, unsigned long long end,
			    unsigned long long incr, unsigned long long chunk_size,
			    unsigned long long *istart, unsigned long long *iend);

	bool (*lib_GOMP_loop_ull_runtime_start) (bool up, unsigned long long start, unsigned long long end,
			     unsigned long long incr, unsigned long long *istart, unsigned long long *iend);

	bool (*lib_GOMP_loop_ull_ordered_static_start) (bool up, unsigned long long start, unsigned long long end,
				    unsigned long long incr, unsigned long long chunk_size,
				    unsigned long long *istart, unsigned long long *iend);

	bool (*lib_GOMP_loop_ull_ordered_dynamic_start) (bool up, unsigned long long start, unsigned long long end,
				     unsigned long long incr, unsigned long long chunk_size,
				     unsigned long long *istart, unsigned long long *iend);

	bool (*lib_GOMP_loop_ull_ordered_guided_start) (bool up, unsigned long long start, unsigned long long end,
				    unsigned long long incr, unsigned long long chunk_size,
				    unsigned long long *istart, unsigned long long *iend);

	bool (*lib_GOMP_loop_ull_ordered_runtime_start) (bool up, unsigned long long start, unsigned long long end,
				     unsigned long long incr, unsigned long long *istart,
				     unsigned long long *iend);

	bool (*lib_GOMP_loop_ull_static_next) (unsigned long long *istart, unsigned long long *iend);

	bool (*lib_GOMP_loop_ull_dynamic_next) (unsigned long long *istart, unsigned long long *iend);

	bool (*lib_GOMP_loop_ull_guided_next) (unsigned long long *istart, unsigned long long *iend);

	bool (*lib_GOMP_loop_ull_runtime_next) (unsigned long long *istart, unsigned long long *iend);

	bool (*lib_GOMP_loop_ull_ordered_static_next) (unsigned long long *istart, unsigned long long *iend);

	bool (*lib_GOMP_loop_ull_ordered_dynamic_next) (unsigned long long *istart, unsigned long long *iend);

	bool (*lib_GOMP_loop_ull_ordered_guided_next) (unsigned long long *istart, unsigned long long *iend);

	bool (*lib_GOMP_loop_ull_ordered_runtime_next) (unsigned long long *istart, unsigned long long *iend);

	/* ordered.c */

	void (*lib_GOMP_ordered_start) (void);
	void (*lib_GOMP_ordered_end) (void);

	/* parallel.c */

	void (*lib_GOMP_parallel_start) (void (*fn) (void *), void *data, unsigned num_threads);
	void (*lib_GOMP_parallel_end) (void);

	void (*lib_GOMP_parallel) (void (*fn) (void *), void *data, unsigned num_threads, unsigned int flags);
	bool (*lib_GOMP_cancel) (int which, bool do_cancel);
	bool (*lib_GOMP_cancellation_point) (int which);

	/* task.c */

	void (*lib_GOMP_task) (void (*fn) (void *), void *data, void (*cpyfn) (void *, void *),
	   long arg_size, long arg_align, bool if_clause, unsigned flags,
	   void **depend);

	void (*lib_GOMP_taskwait) (void);
	void (*lib_GOMP_taskyield) (void);
	void (*lib_GOMP_taskgroup_start) (void);
	void (*lib_GOMP_taskgroup_end) (void);

	/* sections.c */

	unsigned (*lib_GOMP_sections_start) (unsigned count);

	unsigned (*lib_GOMP_sections_next) (void);

	void (*lib_GOMP_parallel_sections_start) (void (*fn) (void *), void *data,
			      unsigned num_threads, unsigned count);

	void (*lib_GOMP_parallel_sections) (void (*fn) (void *), void *data,
			unsigned num_threads, unsigned count, unsigned flags);

	void (*lib_GOMP_sections_end) (void);
	
	void (*lib_GOMP_sections_end_nowait) (void);
	
	bool (*lib_GOMP_sections_end_cancel) (void);

	/* single.c */

	bool (*lib_GOMP_single_start) (void);

	void *(*lib_GOMP_single_copy_start) (void);

	void (*lib_GOMP_single_copy_end) (void *data);

	/* target.c */

	void (*lib_GOMP_target) (int device, void (*fn) (void *), const void *unused,
	     size_t mapnum, void **hostaddrs, size_t *sizes,
	     unsigned char *kinds);

	void (*lib_GOMP_target_data) (int device, const void *unused, size_t mapnum,
		  void **hostaddrs, size_t *sizes, unsigned char *kinds);

	void (*lib_GOMP_target_end_data) (void);

	void (*lib_GOMP_target_update) (int device, const void *unused, size_t mapnum,
		    void **hostaddrs, size_t *sizes, unsigned char *kinds);

	void (*lib_GOMP_teams) (unsigned int num_teams, unsigned int thread_limit);

	/* oacc-parallel.c */

	/*void (*lib_GOACC_data_start) (int device, size_t mapnum,
		  void **hostaddrs, size_t *sizes, unsigned short *kinds);

	void (*lib_GOACC_data_end) (void);

	void (*lib_GOACC_enter_exit_data) (int device, size_t mapnum,
		       void **hostaddrs, size_t *sizes, unsigned short *kinds,
		       int async, int num_waits, ...);

	void (*lib_GOACC_parallel) (int device, void (*fn) (void *),
		size_t mapnum, void **hostaddrs, size_t *sizes,
		unsigned short *kinds,
		int num_gangs, int num_workers, int vector_length,
		int async, int num_waits, ...);

	void (*lib_GOACC_update) (int device, size_t mapnum,
	      void **hostaddrs, size_t *sizes, unsigned short *kinds,
	      int async, int num_waits, ...);

	void (*lib_GOACC_wait) (int async, int num_waits, ...);
	
	int (*lib_GOACC_get_num_threads) (void);
	
	int (*lib_GOACC_get_thread_num) (void);*/

/* Registry the thread which can execute the next function. */
static long int registred_thread_executing_function_next = -1;

/* Flag to control the thread registry. */
static bool thread_was_registred_to_execute_alone = false;

/* Interval control for calculate the portion of code to execute. 10% */
static long int loop_iterations_start = 0;
static long int loop_iterations_end = 0;
static long int total_of_iterations = 0;

static long int max_loops_iterations_for_measures;

/* To acumulate the iterations executed by thread to calculate the percentual of executed code. */
static long int executed_loop_iterations = 0;

/* 10% of code. */
static long int percentual_of_code = PERC_OF_CODE_TO_EXECUTE;

static long int number_of_threads_in_team = 0;
static long int number_of_blocked_threads = 0;

static long int chunk_size_execution = 0;

static long int chunk_size_measures = 0;

static long int number_of_blocked_threads_in_loop_end = 0;

static bool is_executing_measures_section = true;

// static bool started_measuring = false;

static bool decided_by_offloading = false;

static bool made_the_offloading = false;

static bool is_hookomp_initialized = false;

static bool is_loop_initialized = false;

// extern struct gomp_team gomp_team;
// extern struct gomp_work_share gomp_work_share;

// extern struct gomp_thread* gomp_thread();

#ifdef __cplusplus 
extern "C" {
#endif

	/* Alternative Functions table pointer and args structures. */
	Func ***TablePointerFunctions;
	
	/* Current loop index. To identify the loop in execution. */
	long int current_loop_index;

	long int num_threads_defined;

	/* Amount of bytes that will be moved to device, if offloading. */
	/* Write: sent to device. Inputs to kernel. */
	long long q_data_transfer_write;
	/* Read: get from device. Results, data that was modified. */
	long long q_data_transfer_read;

	void foo(void);
	// GOMP_loop_runtime_start@@GOMP_1.0

	/* barrier.c */

	void GOMP_barrier (void);
	bool GOMP_barrier_cancel (void);

	/* critical.c */

	void GOMP_critical_start (void);
	void GOMP_critical_end (void);
	void GOMP_critical_name_start (void **pptr);
	void GOMP_critical_name_end (void **pptr);
	void GOMP_atomic_start (void);
	void GOMP_atomic_end (void);

	/* loop.c */

	bool GOMP_loop_static_start (long start, long end, long incr, long chunk_size,
			long *istart, long *iend);

	bool GOMP_loop_dynamic_start (long start, long end, long incr, long chunk_size,
			 long *istart, long *iend);

	bool GOMP_loop_guided_start (long start, long end, long incr, long chunk_size,
			long *istart, long *iend);

	bool GOMP_loop_runtime_start (long start, long end, long incr,
			 long *istart, long *iend);

	bool GOMP_loop_ordered_static_start (long start, long end, long incr,
				long chunk_size, long *istart, long *iend);

	bool GOMP_loop_ordered_dynamic_start (long start, long end, long incr,
				 long chunk_size, long *istart, long *iend);

	bool GOMP_loop_ordered_guided_start (long start, long end, long incr,
				long chunk_size, long *istart, long *iend);

	bool GOMP_loop_ordered_runtime_start (long start, long end, long incr,
				 long *istart, long *iend);

	bool GOMP_loop_static_next (long *istart, long *iend);

	bool GOMP_loop_dynamic_next (long *istart, long *iend);

	bool GOMP_loop_guided_next (long *istart, long *iend);

	bool GOMP_loop_runtime_next (long *istart, long *iend);

	bool GOMP_loop_ordered_static_next (long *istart, long *iend);

	bool GOMP_loop_ordered_dynamic_next (long *istart, long *iend);

	bool GOMP_loop_ordered_guided_next (long *istart, long *iend);

	bool GOMP_loop_ordered_runtime_next (long *istart, long *iend);


	void GOMP_parallel_loop_static_start (void (*fn) (void *), void *data,
				 unsigned num_threads, long start, long end,
				 long incr, long chunk_size);

	void GOMP_parallel_loop_dynamic_start (void (*fn) (void *), void *data,
				  unsigned num_threads, long start, long end,
				  long incr, long chunk_size);

	void GOMP_parallel_loop_guided_start (void (*fn) (void *), void *data,
				 unsigned num_threads, long start, long end,
				 long incr, long chunk_size);

	void GOMP_parallel_loop_runtime_start (void (*fn) (void *), void *data,
				  unsigned num_threads, long start, long end,
				  long incr);

	void GOMP_parallel_loop_static (void (*fn) (void *), void *data,
			   unsigned num_threads, long start, long end,
			   long incr, long chunk_size, unsigned flags);

	void GOMP_parallel_loop_dynamic (void (*fn) (void *), void *data,
			    unsigned num_threads, long start, long end,
			    long incr, long chunk_size, unsigned flags);


	void GOMP_parallel_loop_guided (void (*fn) (void *), void *data,
			  unsigned num_threads, long start, long end,
			  long incr, long chunk_size, unsigned flags);
	
	void GOMP_parallel_loop_runtime (void (*fn) (void *), void *data,
			    unsigned num_threads, long start, long end,
			    long incr, unsigned flags);
	
	void GOMP_loop_end (void);
	void GOMP_loop_end_nowait (void);
	bool GOMP_loop_end_cancel (void);

	/* loop_ull.c */

	bool GOMP_loop_ull_static_start (bool up, unsigned long long start, unsigned long long end,
			    unsigned long long incr, unsigned long long chunk_size,
			    unsigned long long *istart, unsigned long long *iend);

	bool GOMP_loop_ull_dynamic_start (bool up, unsigned long long start, unsigned long long end,
			     unsigned long long incr, unsigned long long chunk_size,
			     unsigned long long *istart, unsigned long long *iend);


	bool GOMP_loop_ull_guided_start (bool up, unsigned long long start, unsigned long long end,
			    unsigned long long incr, unsigned long long chunk_size,
			    unsigned long long *istart, unsigned long long *iend);

	bool GOMP_loop_ull_runtime_start (bool up, unsigned long long start, unsigned long long end,
			     unsigned long long incr, unsigned long long *istart, unsigned long long *iend);


	bool GOMP_loop_ull_ordered_static_start (bool up, unsigned long long start, unsigned long long end,
				    unsigned long long incr, unsigned long long chunk_size,
				    unsigned long long *istart, unsigned long long *iend);

	bool GOMP_loop_ull_ordered_dynamic_start (bool up, unsigned long long start, unsigned long long end,
				     unsigned long long incr, unsigned long long chunk_size,
				     unsigned long long *istart, unsigned long long *iend);

	bool GOMP_loop_ull_ordered_guided_start (bool up, unsigned long long start, unsigned long long end,
				    unsigned long long incr, unsigned long long chunk_size,
				    unsigned long long *istart, unsigned long long *iend);

	bool GOMP_loop_ull_ordered_runtime_start (bool up, unsigned long long start, unsigned long long end,
				     unsigned long long incr, unsigned long long *istart,
				     unsigned long long *iend);

	bool GOMP_loop_ull_static_next (unsigned long long *istart, unsigned long long *iend);

	bool GOMP_loop_ull_dynamic_next (unsigned long long *istart, unsigned long long *iend);

	bool GOMP_loop_ull_guided_next (unsigned long long *istart, unsigned long long *iend);

	bool GOMP_loop_ull_runtime_next (unsigned long long *istart, unsigned long long *iend);

	bool GOMP_loop_ull_ordered_static_next (unsigned long long *istart, unsigned long long *iend);

	bool GOMP_loop_ull_ordered_dynamic_next (unsigned long long *istart, unsigned long long *iend);

	bool GOMP_loop_ull_ordered_guided_next (unsigned long long *istart, unsigned long long *iend);

	bool GOMP_loop_ull_ordered_runtime_next (unsigned long long *istart, unsigned long long *iend);

	/* ordered.c */

	void GOMP_ordered_start (void);
	void GOMP_ordered_end (void);

	/* parallel.c */

	void GOMP_parallel_start (void (*fn) (void *), void *data, unsigned num_threads);
	void GOMP_parallel_end (void);

	void GOMP_parallel (void (*fn) (void *), void *data, unsigned num_threads, unsigned int flags);
	bool GOMP_cancel (int which, bool do_cancel);
	bool GOMP_cancellation_point (int which);

	/* task.c */

	void GOMP_task (void (*fn) (void *), void *data, void (*cpyfn) (void *, void *),
	   long arg_size, long arg_align, bool if_clause, unsigned flags,
	   void **depend);

	void GOMP_taskwait (void);
	void GOMP_taskyield (void);
	void GOMP_taskgroup_start (void);
	void GOMP_taskgroup_end (void);

	/* sections.c */

	unsigned GOMP_sections_start (unsigned count);

	unsigned GOMP_sections_next (void);

	void GOMP_parallel_sections_start (void (*fn) (void *), void *data,
			      unsigned num_threads, unsigned count);

	void GOMP_parallel_sections (void (*fn) (void *), void *data,
			unsigned num_threads, unsigned count, unsigned flags);

	void GOMP_sections_end (void);
	
	void GOMP_sections_end_nowait (void);
	
	bool GOMP_sections_end_cancel (void);

	/* single.c */

	bool GOMP_single_start (void);

	void *GOMP_single_copy_start (void);

	void GOMP_single_copy_end (void *data);

	/* target.c */

	void GOMP_target (int device, void (*fn) (void *), const void *unused,
	     size_t mapnum, void **hostaddrs, size_t *sizes,
	     unsigned char *kinds);

	void GOMP_target_data (int device, const void *unused, size_t mapnum,
		  void **hostaddrs, size_t *sizes, unsigned char *kinds);

	void GOMP_target_end_data (void);

	void GOMP_target_update (int device, const void *unused, size_t mapnum,
		    void **hostaddrs, size_t *sizes, unsigned char *kinds);

	void GOMP_teams (unsigned int num_teams, unsigned int thread_limit);

	/* oacc-parallel.c */

	/*void GOACC_data_start (int device, size_t mapnum,
		  void **hostaddrs, size_t *sizes, unsigned short *kinds);

	void GOACC_data_end (void);

	void GOACC_enter_exit_data (int device, size_t mapnum,
		       void **hostaddrs, size_t *sizes, unsigned short *kinds,
		       int async, int num_waits, ...);

	void GOACC_parallel (int device, void (*fn) (void *),
		size_t mapnum, void **hostaddrs, size_t *sizes,
		unsigned short *kinds,
		int num_gangs, int num_workers, int vector_length,
		int async, int num_waits, ...);

	void GOACC_update (int device, size_t mapnum,
	      void **hostaddrs, size_t *sizes, unsigned short *kinds,
	      int async, int num_waits, ...);

	void GOACC_wait (int async, int num_waits, ...);
	
	int GOACC_get_num_threads (void);
	
	int GOACC_get_thread_num (void);*/
	
#ifdef __cplusplus
}
#endif

#endif // hookomp_h__
