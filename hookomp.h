#ifndef hookomp_h__
#define hookomp_h__
 
#include <dlfcn.h>
#include <stdio.h>
#include <stdint.h>
#include "roofline.h"


#ifdef _OPENMP
#include <omp.h>
#else
#define omp_get_thread_num() 0
#define omp_get_num_threads() 1
#endif


// #define VERBOSE 1
// Use make OPTIONS=-DVERBOSE
#ifdef VERBOSE
#define HOOKOMP_FUNC_NAME fprintf(stderr, "[%s] Calling [%s]\n", __FILE__, __FUNCTION__)
#else
#define HOOKOMP_FUNC_NAME (void) 0
#endif


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

/* Tipo para o ponteiro de função. */
typedef void (*op_func) (void *);

/* Ponteiros para as funções que serão recuperadas pela macro get runtime function.*/
void (*lib_GOMP_parallel_start)(void (*fn)(void *), void *data, unsigned num_threads);
void (*lib_GOMP_parallel_end)(void);
bool (*lib_GOMP_single_start)(void);
bool (*lib_GOMP_barrier)(void);

void (*lib_GOMP_parallel_loop_static_start)(void (*)(void *), void *, unsigned, long, long, long, long);
void (*lib_GOMP_parallel_loop_dynamic_start)(void (*)(void *), void *, unsigned, long, long, long, long);
void (*lib_GOMP_parallel_loop_guided_start)(void (*)(void *), void *, unsigned, long, long, long, long);

bool (*lib_GOMP_loop_runtime_next)(long *istart, long *iend);
bool (*lib_GOMP_loop_ordered_runtime_next)(long *istart, long *iend);

bool (*lib_GOMP_loop_ordered_runtime_start)(long start, long end, long incr, long *istart, long *iend);
bool (*lib_GOMP_loop_static_start)(long start, long end, long incr, long chunk_size, long *istart, long *iend);
bool (*lib_GOMP_loop_runtime_start)(long start, long end, long incr, long *istart, long *iend);

bool (*lib_GOMP_loop_dynamic_start)(long start, long end, long incr, long chunk_size, long *istart, long *iend);
bool (*lib_GOMP_loop_guided_start)(long start, long end, long incr, long chunk_size, long *istart, long *iend);
bool (*lib_GOMP_loop_ordered_static_start)(long start, long end, long incr, long chunk_size, long *istart, long *iend);
bool (*lib_GOMP_loop_ordered_dynamic_start)(long start, long end, long incr, long chunk_size, long *istart, long *iend);
bool (*lib_GOMP_loop_ordered_guided_start)(long start, long end, long incr, long chunk_size, long *istart, long *iend);

bool (*lib_GOMP_loop_static_next)(long *istart, long *iend);
bool (*lib_GOMP_loop_dynamic_next)(long *istart, long *iend);
bool (*lib_GOMP_loop_guided_next)(long *istart, long *iend);
bool (*lib_GOMP_loop_ordered_static_next)(long *istart, long *iend);
bool (*lib_GOMP_loop_ordered_dynamic_next)(long *istart, long *iend);
bool (*lib_GOMP_loop_ordered_guided_next)(long *istart, long *iend);

void (*lib_GOMP_parallel_loop_runtime_start)(void (*) (void *), void *, unsigned, long, long, long);
void (*lib_GOMP_loop_end)(void);
void (*lib_GOMP_loop_end_nowait)(void);


#ifdef __cplusplus 
extern "C" {
#endif

	/* Tabela de funções para chamada parametrizada. */
	op_func *TablePointerFunctions;

	void foo(void);
	// GOMP_loop_runtime_start@@GOMP_1.0
	void GOMP_parallel_start (void (*fn)(void *), void *data, unsigned num_threads);
	void GOMP_parallel_end (void);
	
	bool GOMP_single_start (void);
	void GOMP_barrier (void);

	bool GOMP_loop_runtime_start (long start, long end, long incr,
			 long *istart, long *iend);

	bool GOMP_loop_runtime_next (long *istart, long *iend);

	bool GOMP_loop_ordered_runtime_next (long *istart, long *iend);

	bool GOMP_loop_ordered_runtime_start (long start, long end, long incr,
				 long *istart, long *iend);

	bool GOMP_loop_static_start (long start, long end, long incr, long chunk_size,
			long *istart, long *iend);

	bool GOMP_loop_dynamic_start (long start, long end, long incr, long chunk_size,
			 long *istart, long *iend);

	bool GOMP_loop_guided_start (long start, long end, long incr, long chunk_size,
			long *istart, long *iend);

	bool GOMP_loop_ordered_static_start (long start, long end, long incr,
				long chunk_size, long *istart, long *iend);

	bool GOMP_loop_ordered_dynamic_start (long start, long end, long incr,
				 long chunk_size, long *istart, long *iend);

	bool GOMP_loop_ordered_guided_start (long start, long end, long incr,
				long chunk_size, long *istart, long *iend);

	bool GOMP_loop_static_next (long *istart, long *iend);

	bool GOMP_loop_dynamic_next (long *istart, long *iend);

	bool GOMP_loop_guided_next (long *istart, long *iend);

	bool GOMP_loop_ordered_static_next (long *istart, long *iend);

	bool GOMP_loop_ordered_dynamic_next (long *istart, long *iend);

	bool GOMP_loop_ordered_guided_next (long *istart, long *iend);

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

	void GOMP_loop_end (void);

	void GOMP_loop_end_nowait (void);
	
#ifdef __cplusplus
}
#endif

#endif // hookomp_h__
