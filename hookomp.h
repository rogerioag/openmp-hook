#ifndef hookomp_h__
#define hookomp_h__
 
#include <papi.h>

/* Tipo para o ponteiro de função. */
typedef void (*op_func) (void *);

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
