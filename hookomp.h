#ifndef hookomp_h__
#define hookomp_h__
 
#include <papi.h>



#ifdef __cplusplus 
extern "C" {
#endif
		void foo(void);
		// GOMP_loop_runtime_start@@GOMP_1.0
		
		void GOMP_parallel_start (void (*fn)(void *), void *data, unsigned num_threads);

    void GOMP_parallel_end (void);
		
		
		
#ifdef __cplusplus
}
#endif

#endif // hookomp_h__




