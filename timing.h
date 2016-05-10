
#ifndef TIMING_H
#define TIMING_H
#include <stdint.h>
#include <time.h>

/* stackoverflow clock_gettime tem precisão de nano 
   e gettimeofday de microsegundos.
*/
uint64_t seq_start, seq_end, omp_start, omp_end, dev_start, dev_end;

uint64_t get_time(){
 struct timespec spec;
 clock_gettime(CLOCK_MONOTONIC, &spec);
 return ((uint64_t)1e9) * spec.tv_sec + spec.tv_nsec;
}

#define HOOKOMP_TIMING_SEQ_START hookomp_timing_start(&seq_start)
#define HOOKOMP_TIMING_SEQ_END hookomp_timing_start(&seq_end)
#define HOOKOMP_TIMING_SEQ_PRINT hookomp_timing_start(seq_start,seq_end)

void hookomp_timing_start(uint64_t *_start){
	*_start = get_time();
}

void hookomp_timing_stop(uint64_t *_end){
	*_end = get_time();
}

void hookomp_timing_print(uint64_t tstart, uint64_t tend){
	printf ("%Ld\n", tend - tstart);
}

#endif /* TIMING_H */
