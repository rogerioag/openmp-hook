// #define _GNU_SOURCE
// #include <libgomp_g.h>

#include <dlfcn.h>
#include <stdio.h>
#include <stdint.h>

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


 
void foo(void) {
    puts("Hello, I'm a shared library");
} 

/* Function to intercept GOMP_parallel_start */
void GOMP_parallel_start (void (*fn)(void *), void *data, unsigned num_threads){
	 printf("[hookomp] GOMP_parallel_start.\n");
	 	 
	 typedef void (*func_t)(void (*fn)(void *), void *, unsigned);
	 
	 func_t lib_GOMP_parallel_start = (func_t) dlsym(RTLD_NEXT, "GOMP_parallel_start");
   printf("[GOMP_1.0] GOMP_parallel_start@@GOMP_1.0.\n");
   
	 return lib_GOMP_parallel_start(fn, data, num_threads);
	 
}

/* Function to intercept GOMP_parallel_end */
void GOMP_parallel_end (void){
	printf("[hookomp] GOMP_parallel_end.\n");
	 
	typedef void (*func_t)(void);
	 
	func_t lib_GOMP_parallel_end = (func_t) dlsym(RTLD_NEXT, "GOMP_parallel_end");
  printf("[GOMP_1.0] GOMP_parallel_end@@GOMP_1.0.\n");
  return lib_GOMP_parallel_end();	 
}



	
	
	


