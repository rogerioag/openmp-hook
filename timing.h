
#ifndef TIMING_H
#define TIMING_H
#include <stdint.h>
#include <time.h>

/* stackoverflow clock_gettime tem precisão de nano 
   e gettimeofday de microsegundos.
*/
uint64_t seq_start, seq_stop, omp_start, omp_stop, dev_start, dev_stop;
uint64_t data_transfer_h2d_start, data_transfer_h2d_stop;
uint64_t data_transfer_d2h_start, data_transfer_d2h_stop;

uint64_t get_time(){
 struct timespec spec;
 clock_gettime(CLOCK_MONOTONIC, &spec);
 return ((uint64_t)1e9) * spec.tv_sec + spec.tv_nsec;
}

#define HOOKOMP_TIMING_SEQ_START hookomp_timing_start(&seq_start)
#define HOOKOMP_TIMING_SEQ_STOP hookomp_timing_stop(&seq_stop)
#define HOOKOMP_TIMING_SEQ_PRINT hookomp_timing_print(seq_start,seq_stop)

// Global time omp code, with the possibility of device offloading.
#define HOOKOMP_TIMING_OMP_START hookomp_timing_start(&omp_start)
#define HOOKOMP_TIMING_OMP_STOP hookomp_timing_stop(&omp_stop)
#define HOOKOMP_TIMING_OMP_OFF_PRINT hookomp_timing_print(omp_start,omp_stop)

// OMP code time execution without device times.
#define HOOKOMP_TIMING_OMP_PRINT hookomp_timing_print_without_dev(omp_start,omp_stop,dev_start,dev_stop,data_transfer_h2d_start,data_transfer_h2d_stop,data_transfer_d2h_start,data_transfer_d2h_stop)

#define HOOKOMP_TIMING_DEV_START hookomp_timing_start(&dev_start)
#define HOOKOMP_TIMING_DEV_STOP hookomp_timing_stop(&dev_stop)
#define HOOKOMP_TIMING_DEV_PRINT hookomp_timing_print(dev_start,dev_stop)

#define HOOKOMP_TIMING_DT_H2D_START hookomp_timing_start(&data_transfer_h2d_start)
#define HOOKOMP_TIMING_DT_H2D_STOP hookomp_timing_stop(&data_transfer_h2d_stop)
#define HOOKOMP_TIMING_DT_H2D_PRINT hookomp_timing_print(data_transfer_h2d_start,data_transfer_h2d_stop)

#define HOOKOMP_TIMING_DT_D2H_START hookomp_timing_start(&data_transfer_d2h_start)
#define HOOKOMP_TIMING_DT_D2H_STOP hookomp_timing_stop(&data_transfer_d2h_stop)
#define HOOKOMP_TIMING_DT_D2H_PRINT hookomp_timing_print(data_transfer_d2h_start,data_transfer_d2h_stop)

void hookomp_timing_start(uint64_t *_start){
	*_start = get_time();
}

void hookomp_timing_stop(uint64_t *_stop){
	*_stop = get_time();
}

void hookomp_timing_print(uint64_t tstart, uint64_t tstop){
	printf ("%Ld", tstop - tstart);
}

void hookomp_timing_print_without_dev(uint64_t omp_start, uint64_t omp_stop,
	                                  uint64_t dev_start, uint64_t dev_stop,
	                                  uint64_t data_transfer_h2d_start,
	                                  uint64_t data_transfer_h2d_stop,
	                                  uint64_t data_transfer_d2h_start,
	                                  uint64_t data_transfer_d2h_stop) {
	uint64_t total_time = omp_stop - omp_start;
	uint64_t dev_time = dev_stop - dev_start;
	uint64_t dt_time = (data_transfer_h2d_stop - data_transfer_h2d_start) + (data_transfer_d2h_stop - data_transfer_d2h_start);

	printf ("%Ld", (total_time - dev_time - dt_time));
}

#endif /* TIMING_H */
