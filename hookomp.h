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
		
		bool GOMP_single_start (void);
		
		// long_long values[NUM_EVENTS];
		// unsigned int Events[NUM_EVENTS]={PAPI_TOT_INS, PAPI_TOT_CYC};
		
#ifdef __cplusplus
}
#endif

#endif // hookomp_h__




