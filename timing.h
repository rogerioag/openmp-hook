
#ifndef TIMING_H
#define TIMING_H
#include <stdint.h>
#include <time.h>

/* stackoverflow clock_gettime tem precisão de nano 
   e gettimeofday de microsegundos.
*/
// Monitoring SEQUENTIAL version.
uint64_t seq_start, seq_stop;
// Monitoring OMP version.
uint64_t omp_start, omp_stop;
// Monitoring Device, CUDA version.
uint64_t dev_kernel1_start, dev_kernel1_stop;
uint64_t dev_kernel2_start, dev_kernel2_stop;
uint64_t dev_kernel3_start, dev_kernel3_stop;
// Monitoring Data Transfers.
uint64_t data_transfer_h2d_start, data_transfer_h2d_stop;
uint64_t data_transfer_d2h_start, data_transfer_d2h_stop;

/* Flag to registry if the shared work finish before the offloading decision. 
  When the original next chunk function returns false (NO MORE WORK TO DO) before of the thread reach the decision point. */
static bool reach_offload_decision_point = false;

static bool decided_by_offloading = false;

static bool made_the_offloading = false;

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
#define HOOKOMP_TIMING_OMP_PRINT hookomp_timing_print_without_dev()

#define HOOKOMP_TIMING_DEV_KERNEL1_START hookomp_timing_start(&dev_kernel1_start)
#define HOOKOMP_TIMING_DEV_KERNEL1_STOP hookomp_timing_stop(&dev_kernel1_stop)
#define HOOKOMP_TIMING_DEV_KERNEL1_PRINT hookomp_timing_print(dev_kernel1_start,dev_kernel1_stop)

#define HOOKOMP_TIMING_DEV_KERNEL2_START hookomp_timing_start(&dev_kernel2_start)
#define HOOKOMP_TIMING_DEV_KERNEL2_STOP hookomp_timing_stop(&dev_kernel2_stop)
#define HOOKOMP_TIMING_DEV_KERNEL2_PRINT hookomp_timing_print(dev_kernel2_start,dev_kernel2_stop)

#define HOOKOMP_TIMING_DEV_KERNEL3_START hookomp_timing_start(&dev_kernel3_start)
#define HOOKOMP_TIMING_DEV_KERNEL3_STOP hookomp_timing_stop(&dev_kernel3_stop)
#define HOOKOMP_TIMING_DEV_KERNEL3_PRINT hookomp_timing_print(dev_kernel3_start,dev_kernel3_stop)

#define HOOKOMP_TIMING_DT_H2D_START hookomp_timing_start(&data_transfer_h2d_start)
#define HOOKOMP_TIMING_DT_H2D_STOP hookomp_timing_stop(&data_transfer_h2d_stop)
#define HOOKOMP_TIMING_DT_H2D_PRINT hookomp_timing_print(data_transfer_h2d_start,data_transfer_h2d_stop)

#define HOOKOMP_TIMING_DT_D2H_START hookomp_timing_start(&data_transfer_d2h_start)
#define HOOKOMP_TIMING_DT_D2H_STOP hookomp_timing_stop(&data_transfer_d2h_stop)
#define HOOKOMP_TIMING_DT_D2H_PRINT hookomp_timing_print(data_transfer_d2h_start,data_transfer_d2h_stop)

#define HOOKOMP_PRINT_TIME_RESULTS hookomp_print_time_results()

void hookomp_timing_start(uint64_t *_start){
	*_start = get_time();
}

void hookomp_timing_stop(uint64_t *_stop){
	*_stop = get_time();
}

void hookomp_timing_print(uint64_t tstart, uint64_t tstop){
	printf ("%Ld", tstop - tstart);
}

void hookomp_timing_print_without_dev() {
	uint64_t total_time = omp_stop - omp_start;
	uint64_t dev_time = (dev_kernel1_stop - dev_kernel1_start) + (dev_kernel2_stop - dev_kernel2_start) + (dev_kernel3_stop - dev_kernel3_start);
	uint64_t dt_time = (data_transfer_h2d_stop - data_transfer_h2d_start) + (data_transfer_d2h_stop - data_transfer_d2h_start);

	printf ("%Ld", (total_time - dev_time - dt_time));
}

void hookomp_print_time_results(){
	fprintf(stdout, "ORIG = ");
  	HOOKOMP_TIMING_SEQ_PRINT;
  	fprintf(stdout, ", ");
  	fprintf(stdout, "OMP_OFF = ");
  	HOOKOMP_TIMING_OMP_OFF_PRINT;
  	fprintf(stdout, ", ");
  	fprintf(stdout, "OMP = ");
  	HOOKOMP_TIMING_OMP_PRINT;
  	fprintf(stdout, ", ");
  	fprintf(stdout, "CUDA_KERNEL1 = ");
  	HOOKOMP_TIMING_DEV_KERNEL1_PRINT;
  	fprintf(stdout, ", ");
  	fprintf(stdout, "CUDA_KERNEL2 = ");
  	HOOKOMP_TIMING_DEV_KERNEL2_PRINT;
  	fprintf(stdout, ", ");
  	fprintf(stdout, "CUDA_KERNEL3 = ");
  	HOOKOMP_TIMING_DEV_KERNEL3_PRINT;
  	fprintf(stdout, ", ");
  	fprintf(stdout, "DT_H2D = ");
  	HOOKOMP_TIMING_DT_H2D_PRINT;
  	fprintf(stdout, ", ");
  	fprintf(stdout, "DT_D2H = ");
  	HOOKOMP_TIMING_DT_D2H_PRINT;
    fprintf(stdout, "WORK_FINISHED_BEFORE_OFFLOAD_DECISION = %d", ((!reach_offload_decision_point)?(1):(0)));
    fprintf(stdout, "REACH_OFFLOAD_DECISION_POINT = %d", reach_offload_decision_point);
    fprintf(stdout, "DECIDED_BY_OFFLOADING = %d", decided_by_offloading);
    fprintf(stdout, "MADE_THE_OFFLOADING = %d", made_the_offloading);
  	fprintf(stdout, "\n");
}

#endif /* TIMING_H */
