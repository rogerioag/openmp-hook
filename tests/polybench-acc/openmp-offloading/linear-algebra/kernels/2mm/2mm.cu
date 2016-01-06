/**
 * 2mm.cu: This file is part of the PolyBench/GPU 1.0 test suite.
 *
 *
 * Contact: Scott Grauer-Gray <sgrauerg@gmail.com>
 * Will Killian <killian@udel.edu>
 * Louis-Noel Pouchet <pouchet@cse.ohio-state.edu>
 * Web address: http://www.cse.ohio-state.edu/~pouchet/software/polybench/GPU
 */

#include <assert.h>
#include <cuda.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <unistd.h>

#define POLYBENCH_TIME 1

#include "2mm.cuh"
#include <polybench.h>
#include <polybenchUtilFuncts.h>

// Offloading support functions.
#include <offload.h>

// define the error threshold for the results "not matching"
#define PERCENT_DIFF_ERROR_THRESHOLD 0.05

#define GPU_DEVICE 0

#define RUN_ON_CPU

/* GPU pointers now as global to be shared between kernels. */
DATA_TYPE *tmp_gpu;
DATA_TYPE *A_gpu;
DATA_TYPE *B_gpu;
DATA_TYPE *C_gpu;
DATA_TYPE *D_gpu;

// If data pointer was allocated in GPU Memory.
bool gpu_data_allocated = false;
bool gpu_data_copied = false;

/* ------------------------------------------------------------- */
/* Arrays initialization. */
void init_array(int ni, int nj, int nk, int nl, DATA_TYPE *alpha,
                DATA_TYPE *beta, DATA_TYPE POLYBENCH_2D(A, NI, NK, ni, nk),
                DATA_TYPE POLYBENCH_2D(B, NK, NJ, nk, nj),
                DATA_TYPE POLYBENCH_2D(C, NL, NJ, nl, nj),
                DATA_TYPE POLYBENCH_2D(D, NI, NL, ni, nl)) {
  int i, j;

  *alpha = 32412;
  *beta = 2123;

  for (i = 0; i < ni; i++) {
    for (j = 0; j < nk; j++) {
      A[i][j] = ((DATA_TYPE)i * j) / NI;
    }
  }

  for (i = 0; i < nk; i++) {
    for (j = 0; j < nj; j++) {
      B[i][j] = ((DATA_TYPE)i * (j + 1)) / NJ;
    }
  }

  for (i = 0; i < nl; i++) {
    for (j = 0; j < nj; j++) {
      C[i][j] = ((DATA_TYPE)i * (j + 3)) / NL;
    }
  }

  for (i = 0; i < ni; i++) {
    for (j = 0; j < nl; j++) {
      D[i][j] = ((DATA_TYPE)i * (j + 2)) / NK;
    }
  }
}

/* ------------------------------------------------------------- */
void compareResults(int ni, int nl, DATA_TYPE POLYBENCH_2D(D, NI, NL, ni, nl),
                    DATA_TYPE POLYBENCH_2D(D_outputFromGpu, NI, NL, ni, nl)) {
  int i, j, fail;
  fail = 0;

  for (i = 0; i < ni; i++) {
    for (j = 0; j < nl; j++) {
      if (percentDiff(D[i][j], D_outputFromGpu[i][j]) >
          PERCENT_DIFF_ERROR_THRESHOLD) {
        fail++;
      }
    }
  }

  // print results
  printf("Non-Matching CPU-GPU Outputs Beyond Error Threshold of %4.2f "
         "Percent: %d\n",
         PERCENT_DIFF_ERROR_THRESHOLD, fail);
}

/* ------------------------------------------------------------- */
/* DCE code. Must scan the entire live-out data.
   Can be used also to check the correctness of the output. */
static void print_array(int ni, int nl,
                        DATA_TYPE POLYBENCH_2D(D, NI, NL, ni, nl)) {
  int i, j;

  for (i = 0; i < ni; i++)
    for (j = 0; j < nl; j++) {
      fprintf(stderr, DATA_PRINTF_MODIFIER, D[i][j]);
      if ((i * ni + j) % 20 == 0)
        fprintf(stderr, "\n");
    }
  fprintf(stderr, "\n");
}

/* ------------------------------------------------------------- */
/* Original kernel. */
void mm2_cpu(int ni, int nj, int nk, int nl, DATA_TYPE alpha, DATA_TYPE beta,
             DATA_TYPE POLYBENCH_2D(tmp, NI, NJ, ni, nj),
             DATA_TYPE POLYBENCH_2D(A, NI, NK, ni, nk),
             DATA_TYPE POLYBENCH_2D(B, NK, NJ, nk, nj),
             DATA_TYPE POLYBENCH_2D(C, NL, NJ, nl, nj),
             DATA_TYPE POLYBENCH_2D(D, NI, NL, ni, nl)) {
  int i, j, k;

  /* D := alpha*A*B*C + beta*D */
  for (i = 0; i < _PB_NI; i++) {
    for (j = 0; j < _PB_NJ; j++) {
      tmp[i][j] = 0;
      for (k = 0; k < _PB_NK; ++k) {
        tmp[i][j] += alpha * A[i][k] * B[k][j];
      }
    }
  }

  for (i = 0; i < _PB_NI; i++) {
    for (j = 0; j < _PB_NL; j++) {
      D[i][j] *= beta;
      for (k = 0; k < _PB_NJ; ++k) {
        D[i][j] += tmp[i][k] * C[k][j];
      }
    }
  }
}

/* ------------------------------------------------------------- */
/* Original Version. */
void mm_original(int ni, int nj, int nk, int nl, DATA_TYPE alpha, DATA_TYPE beta,
             DATA_TYPE POLYBENCH_2D(tmp, NI, NJ, ni, nj),
             DATA_TYPE POLYBENCH_2D(A, NI, NK, ni, nk),
             DATA_TYPE POLYBENCH_2D(B, NK, NJ, nk, nj),
             DATA_TYPE POLYBENCH_2D(C, NL, NJ, nl, nj),
             DATA_TYPE POLYBENCH_2D(D, NI, NL, ni, nl)) {
  
  /* Start timer. */
  polybench_start_instruments;

  mm2_cpu(ni, nj, nk, nl,
	      alpha, beta,
	      tmp,
	      A,
	      B,
	      C,
	      D);

  /* Stop and print timer. */
  printf("Original CPU Time in seconds:\n");
  polybench_stop_instruments;
  polybench_print_instruments;
}

/* ------------------------------------------------------------- */
/* OMP Version. */
/* Main computational kernel. The whole function will be timed,
   including the call and return. */
static
void kernel_2mm(int ni, int nj, int nk, int nl,
		DATA_TYPE alpha,
		DATA_TYPE beta,
		DATA_TYPE POLYBENCH_2D(tmp,NI,NJ,ni,nj),
		DATA_TYPE POLYBENCH_2D(A,NI,NK,ni,nk),
		DATA_TYPE POLYBENCH_2D(B,NK,NJ,nk,nj),
		DATA_TYPE POLYBENCH_2D(C,NL,NJ,nl,nj),
		DATA_TYPE POLYBENCH_2D(D,NI,NL,ni,nl))
{
  int i, j, k;
  #pragma scop
  /* D := alpha*A*B*C + beta*D */
  #pragma omp parallel
  {
  	current_loop_index = 0;
    #pragma omp for private(j, k) schedule(runtime)
    for (i = 0; i < _PB_NI; i++){
      for (j = 0; j < _PB_NJ; j++){
    	tmp[i][j] = 0;
  	  	for (k = 0; k < _PB_NK; ++k){
	    	tmp[i][j] += alpha * A[i][k] * B[k][j];
        }
      }
    }
    current_loop_index = 1;
    #pragma omp for private(j, k) schedule(runtime)
    for (i = 0; i < _PB_NI; i++){
      for (j = 0; j < _PB_NL; j++){
	  	D[i][j] *= beta;
	  	for (k = 0; k < _PB_NJ; ++k){
	    	D[i][j] += tmp[i][k] * C[k][j];
	    }
	  }
	}
  }
  #pragma endscop
}

/* ------------------------------------------------------------- */
/* OMP Version. */
void mm_omp(int ni, int nj, int nk, int nl, DATA_TYPE alpha, DATA_TYPE beta,
             DATA_TYPE POLYBENCH_2D(tmp, NI, NJ, ni, nj),
             DATA_TYPE POLYBENCH_2D(A, NI, NK, ni, nk),
             DATA_TYPE POLYBENCH_2D(B, NK, NJ, nk, nj),
             DATA_TYPE POLYBENCH_2D(C, NL, NJ, nl, nj),
             DATA_TYPE POLYBENCH_2D(D, NI, NL, ni, nl)) {
  
  /* Start timer. */
  polybench_start_instruments;

  /* Run kernel. */
  kernel_2mm (ni, nj, nk, nl,
	      alpha, beta,
	      tmp,
	      A,
	      B,
	      C,
	      D);

  /* Stop and print timer. */
  printf("CPU OMP Time in seconds:\n");
  polybench_stop_instruments;
  polybench_print_instruments;
}

/* ------------------------------------------------------------- */
/* CUDA Version. */
void GPU_argv_init() {
  fprintf(stderr, "GPU init.\n");
  cudaDeviceProp deviceProp;
  cudaGetDeviceProperties(&deviceProp, GPU_DEVICE);
  printf("setting device %d with name %s\n", GPU_DEVICE, deviceProp.name);
  cudaSetDevice(GPU_DEVICE);
}

/* ------------------------------------------------------------- */
__global__ void mm2_kernel1(int ni, int nj, int nk, int nl, DATA_TYPE alpha,
                            DATA_TYPE beta, DATA_TYPE *tmp, DATA_TYPE *A,
                            DATA_TYPE *B) {
  int j = blockIdx.x * blockDim.x + threadIdx.x;
  int i = blockIdx.y * blockDim.y + threadIdx.y;

  if ((i < _PB_NI) && (j < _PB_NJ)) {
    tmp[i * NJ + j] = 0;
    int k;
    for (k = 0; k < _PB_NK; k++) {
      tmp[i * NJ + j] += alpha * A[i * NK + k] * B[k * NJ + j];
    }
  }
}

/* ------------------------------------------------------------- */
__global__ void mm2_kernel2(int ni, int nj, int nk, int nl, DATA_TYPE alpha,
                            DATA_TYPE beta, DATA_TYPE *tmp, DATA_TYPE *C,
                            DATA_TYPE *D) {
  int j = blockIdx.x * blockDim.x + threadIdx.x;
  int i = blockIdx.y * blockDim.y + threadIdx.y;

  if ((i < _PB_NI) && (j < _PB_NL)) {
    D[i * NL + j] *= beta;
    int k;
    for (k = 0; k < _PB_NJ; k++) {
      D[i * NL + j] += tmp[i * NJ + k] * C[k * NL + j];
    }
  }
}

/* ------------------------------------------------------------- */
void GPU_data_allocation(void){
  fprintf(stderr, "GPU_data_allocation.\n");

  if(!gpu_data_allocated){
    cudaMalloc((void **)&tmp_gpu, sizeof(DATA_TYPE) * NI * NJ);
    cudaMalloc((void **)&A_gpu, sizeof(DATA_TYPE) * NI * NK);
    cudaMalloc((void **)&B_gpu, sizeof(DATA_TYPE) * NK * NJ);
    cudaMalloc((void **)&C_gpu, sizeof(DATA_TYPE) * NL * NJ);
    cudaMalloc((void **)&D_gpu, sizeof(DATA_TYPE) * NI * NL);
    gpu_data_allocated = true;
  }
}

/* ------------------------------------------------------------- */
void GPU_data_copy(DATA_TYPE POLYBENCH_2D(tmp, NI, NJ, ni, nj),
             DATA_TYPE POLYBENCH_2D(A, NI, NK, ni, nk),
             DATA_TYPE POLYBENCH_2D(B, NK, NJ, nk, nj),
             DATA_TYPE POLYBENCH_2D(C, NL, NJ, nl, nj),
             DATA_TYPE POLYBENCH_2D(D, NI, NL, ni, nl)){

  fprintf(stderr, "GPU_data_copy.\n");

  if(!gpu_data_copied){
    cudaMemcpy(tmp_gpu, tmp, sizeof(DATA_TYPE) * NI * NJ, cudaMemcpyHostToDevice);
    cudaMemcpy(A_gpu, A, sizeof(DATA_TYPE) * NI * NK, cudaMemcpyHostToDevice);
    cudaMemcpy(B_gpu, B, sizeof(DATA_TYPE) * NK * NJ, cudaMemcpyHostToDevice);
    cudaMemcpy(C_gpu, C, sizeof(DATA_TYPE) * NL * NJ, cudaMemcpyHostToDevice);
    cudaMemcpy(D_gpu, D, sizeof(DATA_TYPE) * NI * NL, cudaMemcpyHostToDevice);
    gpu_data_copied = true;
  }
}

/* ------------------------------------------------------------- */
void GPU_data_copy_back(DATA_TYPE POLYBENCH_2D(D_outputFromGpu, NI, NL, ni, nl))

cudaMemcpy(D_outputFromGpu, D_gpu, sizeof(DATA_TYPE) * NI * NL,
             cudaMemcpyDeviceToHost);

}



/* ------------------------------------------------------------- */
/* A caller for each kernel, because OMP generate two for loops structures. 
 * Put the gpu pointer as global, to verify allocations and copies.
*/
void mm2Cuda_1(int ni, int nj, int nk, int nl, DATA_TYPE alpha, DATA_TYPE beta,
             DATA_TYPE POLYBENCH_2D(tmp, NI, NJ, ni, nj),
             DATA_TYPE POLYBENCH_2D(A, NI, NK, ni, nk),
             DATA_TYPE POLYBENCH_2D(B, NK, NJ, nk, nj),
             DATA_TYPE POLYBENCH_2D(C, NL, NJ, nl, nj),
             DATA_TYPE POLYBENCH_2D(D, NI, NL, ni, nl),
             DATA_TYPE POLYBENCH_2D(D_outputFromGpu, NI, NL, ni, nl)) {
  fprintf(stderr, "mm2Cuda_1.\n");
  
  GPU_argv_init();

  GPU_data_allocation();

  GPU_data_copy();

  dim3 block(DIM_THREAD_BLOCK_X, DIM_THREAD_BLOCK_Y);
  dim3 grid1((size_t)ceil(((float)NJ) / ((float)block.x)),
             (size_t)ceil(((float)NI) / ((float)block.y)));
  
  /* Start timer. */
  polybench_start_instruments;

  mm2_kernel1<<<grid1, block>>>(ni, nj, nk, nl, alpha, beta, tmp_gpu, A_gpu,
                                B_gpu);
  cudaThreadSynchronize();
  
  printf("GPU Time in seconds:\n");
  polybench_stop_instruments;
  polybench_print_instruments;
}

/* ------------------------------------------------------------- */
void mm2Cuda_2(int ni, int nj, int nk, int nl, DATA_TYPE alpha, DATA_TYPE beta,
             DATA_TYPE POLYBENCH_2D(tmp, NI, NJ, ni, nj),
             DATA_TYPE POLYBENCH_2D(A, NI, NK, ni, nk),
             DATA_TYPE POLYBENCH_2D(B, NK, NJ, nk, nj),
             DATA_TYPE POLYBENCH_2D(C, NL, NJ, nl, nj),
             DATA_TYPE POLYBENCH_2D(D, NI, NL, ni, nl),
             DATA_TYPE POLYBENCH_2D(D_outputFromGpu, NI, NL, ni, nl)) {
  
  GPU_argv_init();

  GPU_data_allocation();

  GPU_data_copy();

  dim3 block(DIM_THREAD_BLOCK_X, DIM_THREAD_BLOCK_Y);
  
  dim3 grid2((size_t)ceil(((float)NL) / ((float)block.x)),
             (size_t)ceil(((float)NI) / ((float)block.y)));

  /* Start timer. */
  polybench_start_instruments;

  mm2_kernel2<<<grid2, block>>>(ni, nj, nk, nl, alpha, beta, tmp_gpu, C_gpu,
                                D_gpu);
  cudaThreadSynchronize();

  printf("GPU Time in seconds:\n");
  polybench_stop_instruments;
  polybench_print_instruments;

  GPU_data_copy_back(D_outputFromGpu);
}

/* ------------------------------------------------------------- */
int main(int argc, char **argv) {
  /* Retrieve problem size. */
  int ni = NI;
  int nj = NJ;
  int nk = NK;
  int nl = NL;

  /* Variable declaration/allocation. */
  DATA_TYPE alpha;
  DATA_TYPE beta;
  POLYBENCH_2D_ARRAY_DECL(tmp, DATA_TYPE, NI, NJ, ni, nj);
  POLYBENCH_2D_ARRAY_DECL(A, DATA_TYPE, NI, NK, ni, nk);
  POLYBENCH_2D_ARRAY_DECL(B, DATA_TYPE, NK, NJ, nk, nj);
  POLYBENCH_2D_ARRAY_DECL(C, DATA_TYPE, NL, NJ, nl, nj);
  POLYBENCH_2D_ARRAY_DECL(D, DATA_TYPE, NI, NL, ni, nl);
  POLYBENCH_2D_ARRAY_DECL(D_outputFromOMP, DATA_TYPE, NI, NL, ni, nl);
  POLYBENCH_2D_ARRAY_DECL(D_outputFromGpu, DATA_TYPE, NI, NL, ni, nl);


  fprintf(stderr, "Preparing alternatives functions.\n");
  /* Preparing the call to target function.
  void mm2Cuda(int ni, int nj, int nk, int nl, DATA_TYPE alpha, DATA_TYPE beta,
             DATA_TYPE POLYBENCH_2D(tmp, NI, NJ, ni, nj),
             DATA_TYPE POLYBENCH_2D(A, NI, NK, ni, nk),
             DATA_TYPE POLYBENCH_2D(B, NK, NJ, nk, nj),
             DATA_TYPE POLYBENCH_2D(C, NL, NJ, nl, nj),
             DATA_TYPE POLYBENCH_2D(D, NI, NL, ni, nl),
             DATA_TYPE POLYBENCH_2D(D_outputFromGpu, NI, NL, ni, nl))
  */
  // Number of parameters to function.
  int n_params = 12;

  // void handler_function_init_array_GPU(void)
  Func *ff_1 = (Func *) malloc(sizeof(Func));
  Func *ff_2 = (Func *) malloc(sizeof(Func));

  // Number of arguments + 1, the lists need to have last element NULL.
  ff_1->arg_types = (ffi_type**) malloc ((n_params + 1) * sizeof(ffi_type*));
  ff_1->arg_values = (void**) malloc ((n_params + 1) * sizeof(void*));

  ff_2->arg_types = (ffi_type**) malloc ((n_params + 1) * sizeof(ffi_type*));
  ff_2->arg_values = (void**) malloc ((n_params + 1) * sizeof(void*));

  ff_1->f = &mm2Cuda_1;

  memset(&ff_1->ret_value, 0, sizeof(ff_1->ret_value));

  ff_2->f = &mm2Cuda_2;
  memset(&ff_2->ret_value, 0, sizeof(ff_2->ret_value));

  // return type.
  ff_1->ret_type = &ffi_type_void;

  // return type.
  ff_2->ret_type = &ffi_type_void;

  ff_1->nargs = n_params;

  ff_1->arg_values[0] = &ni;
  ff_1->arg_values[1] = &nj;
  ff_1->arg_values[2] = &nk;
  ff_1->arg_values[3] = &nl;
  ff_1->arg_values[4] = &alpha;
  ff_1->arg_values[5] = &beta;
  ff_1->arg_values[6] = &tmp;
  ff_1->arg_values[7] = &A;
  ff_1->arg_values[8] = &B;
  ff_1->arg_values[9] = &C;
  ff_1->arg_values[10] = &D;
  ff_1->arg_values[11] = &D_outputFromGpu;
  ff_1->arg_values[12] = NULL;

  ff_1->arg_types[0] = &ffi_type_sint32;
  ff_1->arg_types[1] = &ffi_type_sint32;
  ff_1->arg_types[2] = &ffi_type_sint32;
  ff_1->arg_types[3] = &ffi_type_sint32;
  ff_1->arg_types[4] = &ffi_type_double;
  ff_1->arg_types[5] = &ffi_type_double;
  ff_1->arg_types[6] = &ffi_type_pointer;
  ff_1->arg_types[7] = &ffi_type_pointer;
  ff_1->arg_types[8] = &ffi_type_pointer;
  ff_1->arg_types[9] = &ffi_type_pointer;
  ff_1->arg_types[10] = &ffi_type_pointer;
  ff_1->arg_types[11] = &ffi_type_pointer;
  ff_1->arg_types[12] = NULL;

  ff_2->nargs = n_params;

  ff_2->arg_values[0] = &ni;
  ff_2->arg_values[1] = &nj;
  ff_2->arg_values[2] = &nk;
  ff_2->arg_values[3] = &nl;
  ff_2->arg_values[4] = &alpha;
  ff_2->arg_values[5] = &beta;
  ff_2->arg_values[6] = &tmp;
  ff_2->arg_values[7] = &A;
  ff_2->arg_values[8] = &B;
  ff_2->arg_values[9] = &C;
  ff_2->arg_values[10] = &D;
  ff_2->arg_values[11] = &D_outputFromGpu;
  ff_2->arg_values[12] = NULL;

  ff_2->arg_types[0] = &ffi_type_sint32;
  ff_2->arg_types[1] = &ffi_type_sint32;
  ff_2->arg_types[2] = &ffi_type_sint32;
  ff_2->arg_types[3] = &ffi_type_sint32;
  ff_2->arg_types[4] = &ffi_type_double;
  ff_2->arg_types[5] = &ffi_type_double;
  ff_2->arg_types[6] = &ffi_type_pointer;
  ff_2->arg_types[7] = &ffi_type_pointer;
  ff_2->arg_types[8] = &ffi_type_pointer;
  ff_2->arg_types[9] = &ffi_type_pointer;
  ff_2->arg_types[10] = &ffi_type_pointer;
  ff_2->arg_types[11] = &ffi_type_pointer;
  ff_2->arg_types[12] = NULL;

  /*          device 0
   * loop 0   mm2Cuda_1
   * loop 1   mm2Cuda_2
   * matrix 2 x 1.
  */
  fprintf(stderr, "Creating table of target functions.\n");
  int nloops = 2;
  int ndevices = 1;

  if (create_target_functions_table(&table, nloops, ndevices)) {
    // Set up the library Functions table.
    assert(table != NULL);

    fprintf(stderr, "Declaring function in 0,0.\n");
    table[0][0][0] = *ff_1;
    table[1][0][0] = *ff_2;

    TablePointerFunctions = table;
    assert(TablePointerFunctions != NULL);
  }

  fprintf(stderr, "Calling init_array.\n");
  /* Initialize array(s). */
  init_array(ni, nj, nk, nl, &alpha, &beta, POLYBENCH_ARRAY(A),
             POLYBENCH_ARRAY(B), POLYBENCH_ARRAY(C), POLYBENCH_ARRAY(D));
  
  fprintf(stderr, "Calling gemm_original.\n");
  mm_original(ni, nj, nk, nl, alpha, beta, POLYBENCH_ARRAY(tmp), POLYBENCH_ARRAY(A),
          POLYBENCH_ARRAY(B), POLYBENCH_ARRAY(C), POLYBENCH_ARRAY(D));

  fprintf(stderr, "Calling gemm_omp.\n");
  mm_omp(ni, nj, nk, nl,
	      alpha, beta,
	      POLYBENCH_ARRAY(tmp),
	      POLYBENCH_ARRAY(A),
	      POLYBENCH_ARRAY(B),
	      POLYBENCH_ARRAY(C),
	      POLYBENCH_ARRAY(D_outputFromOMP));

  fprintf(stderr, "Calling compareResults(original, omp).\n");
  compareResults(ni, nl, POLYBENCH_ARRAY(D), POLYBENCH_ARRAY(D_outputFromOMP));

  fprintf(stderr, "Calling gemm_cuda.\n");  
  mm2Cuda_1(ni, nj, nk, nl, alpha, beta, POLYBENCH_ARRAY(tmp), POLYBENCH_ARRAY(A),
          POLYBENCH_ARRAY(B), POLYBENCH_ARRAY(C), POLYBENCH_ARRAY(D),
          POLYBENCH_ARRAY(D_outputFromGpu));

  // fprintf(stderr, "Calling gemm_cuda using Table of Pointers.\n");
  // call_function_ffi_call(table[0][0]);

  fprintf(stderr, "Calling compareResults(original, cuda).\n");
  compareResults(ni, nl, POLYBENCH_ARRAY(D), POLYBENCH_ARRAY(D_outputFromGpu));


  polybench_prevent_dce(print_array(ni, nl, POLYBENCH_ARRAY(D_outputFromGpu)));

  POLYBENCH_FREE_ARRAY(tmp);
  POLYBENCH_FREE_ARRAY(A);
  POLYBENCH_FREE_ARRAY(B);
  POLYBENCH_FREE_ARRAY(C);
  POLYBENCH_FREE_ARRAY(D);
  POLYBENCH_FREE_ARRAY(D_outputFromOMP);
  POLYBENCH_FREE_ARRAY(D_outputFromGpu);


  if(gpu_data_allocated){
  	cudaFree(tmp_gpu);
  	cudaFree(A_gpu);
  	cudaFree(B_gpu);
  	cudaFree(C_gpu);
  	cudaFree(D_gpu);	
  }

  return 0;
}

#include <polybench.c>