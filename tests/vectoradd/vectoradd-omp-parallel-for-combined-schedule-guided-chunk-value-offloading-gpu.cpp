#include <stdio.h>
#include <stdlib.h>

#include <iostream>
#include <fstream>
#include <cassert>

#include <dlfcn.h>
#include <ffi.h>
#include <string.h>
#include <fcntl.h>
#include <stdint.h>
#include <inttypes.h>
#include <assert.h>

#ifdef _OPENMP
#include <omp.h>
#else
#define omp_get_thread_num() 0
#define omp_get_num_threads() 1
#define omp_get_num_procs() (system("cat /proc/cpuinfo | grep 'processor' | wc -l"))
#endif

// CUDA driver & runtime
#include <cuda.h>
#include <cuda_runtime.h>

// Size of vectors.
#ifndef N
#define N 4096
#endif

float h_a[N];
float h_b[N];
float h_c[N];

/* Support to table of functions. */
typedef struct Func {
  void *f;
  int nargs;
  ffi_type** arg_types;
  void** arg_values;
  ffi_type* ret_type;
  void* ret_value;
} Func;

/* Alternative Functions table pointer. */
Func ***table;

extern Func ***TablePointerFunctions;

/* current loop index. */
extern long int current_loop_index;

/* ------------------------------------------------------------- */
bool create_target_functions_table(Func ****table_, int nrows, int ncolumns) {

  Func ***table;

  bool result = true;
  int i, j;

  fprintf(stderr, "Allocating the rows.\n");
  table = (Func ***) malloc(nrows * sizeof(Func **));

  if (table != NULL) {
    fprintf(stderr, "Allocating the columns.\n");

    for (i = 0; i < nrows; i++) {
      table[i] = (Func **) malloc(ncolumns * sizeof(Func *));
      if (table[i] != NULL) {
        for (j = 0; j < ncolumns; j++) {
          table[i][j] = (Func *) malloc(sizeof(Func));
        }
      } else {
        fprintf(stderr,
            "Error in table of target functions allocation (columns).\n");
        result = false;
      }
    }
  } else {
    fprintf(stderr,
        "Error in table of target functions allocation (rows).\n");
    result = false;
  }
  fprintf(stderr, "Allocating the columns is OK.\n");

  /*fprintf(stderr, "Printing.\n");
  for (i = 0; i < nrows; i++) {
    for (j = 0; j < ncolumns; j++) {
      fprintf(stderr, "table[%d][%d]= %p\n", i, j, (table[i][j])->f);
    }
  }
  fprintf(stderr, "Printing OK.\n");*/

  *table_ = table;

  return result;
}

/* ------------------------------------------------------------- */
/* Call the target function. */
void call_function_ffi_call(Func* ff) {
  fprintf(stderr," In call_function_ffi_call.\n");
  ffi_cif cif;

  if (ffi_prep_cif(&cif, FFI_DEFAULT_ABI, ff->nargs, ff->ret_type,
      ff->arg_types) != FFI_OK) {
    fprintf(stderr,"Error ffi_prep_cif.\n");
    exit(1);
  }

  ffi_call(&cif, FFI_FN(ff->f), ff->ret_value, ff->arg_values);
}

/* ------------------------------------------------------------- */
void init_array() {
  int i;
  // Initialize vectors on host.
    for (i = 0; i < N; i++) {
      h_a[i] = 0.5;
      h_b[i] = 0.5;
    }
}

/* ------------------------------------------------------------- */
void print_array() {
  int i;
  fprintf(stdout, "Thread [%02d]: Imprimindo o array de resultados:\n", omp_get_thread_num());
  for (i = 0; i < N; i++) {
    fprintf(stdout, "Thread [%02d]: h_c[%07d]: %f\n", omp_get_thread_num(), i, h_c[i]);
  }
}

/* ------------------------------------------------------------- */
void check_result(){
  // Soma dos elementos do array C e divide por N, o valor deve ser igual a 1.
  int i;
  float sum = 0;
  fprintf(stdout, "Thread [%02d]: Verificando o resultado.\n", omp_get_thread_num());
  
  for (i = 0; i < N; i++) {
    sum += h_c[i];
  }
  fprintf(stdout, "Thread [%02d]: Resultado Final: (%f, %f)\n", omp_get_thread_num(), sum, (float)(sum / (float)N));
}

/* ------------------------------------------------------------- */
void checkCudaErrors(CUresult err) {
  assert(err == CUDA_SUCCESS);
}

/* ------------------------------------------------------------- */
void func_GPU(void){
  CUdevice    device;
  CUmodule    cudaModule;
  CUcontext   context;
  CUfunction  function;
  CUlinkState linker;
  int         devCount;

   // Inicialização CUDA.
  checkCudaErrors(cuInit(0));
  checkCudaErrors(cuDeviceGetCount(&devCount));
  checkCudaErrors(cuDeviceGet(&device, 0));

  char name[128];
  checkCudaErrors(cuDeviceGetName(name, 128, device));
  std::cout << "Using CUDA Device [0]: " << name << "\n";

  int devMajor, devMinor;
  checkCudaErrors(cuDeviceComputeCapability(&devMajor, &devMinor, device));
  std::cout << "Device Compute Capability: " << devMajor << "." << devMinor << "\n";
  if (devMajor < 2) {
    std::cerr << "ERROR: Device 0 is not SM 2.0 or greater\n";
  }

  std::cout << "Carregando vectoradd-kernel.ptx. " << "\n";
  // Carregando o arquivo PTX.
  std::ifstream t("vectoradd-kernel.ptx");
  if (!t.is_open()) {
    std::cerr << "vectoradd-kernel.ptx not found\n";
  }
  std::string str((std::istreambuf_iterator<char>(t)),std::istreambuf_iterator<char>());

  // Criando o Driver Context.
  checkCudaErrors(cuCtxCreate(&context, 0, device));

  // Criando um módulo.
  checkCudaErrors(cuModuleLoadDataEx(&cudaModule, str.c_str(), 0, 0, 0));

  // Get kernel function.
  checkCudaErrors(cuModuleGetFunction(&function, cudaModule, "vectoradd_kernel"));

  // Alocação de Memória no disposito.
  CUdeviceptr devBufferA;
  CUdeviceptr devBufferB;
  CUdeviceptr devBufferC;

  checkCudaErrors(cuMemAlloc(&devBufferA, sizeof(float)*N));
  checkCudaErrors(cuMemAlloc(&devBufferB, sizeof(float)*N));
  checkCudaErrors(cuMemAlloc(&devBufferC, sizeof(float)*N));

  // Transferindo os dados para a memória do dispositivo.
  checkCudaErrors(cuMemcpyHtoD(devBufferA, &h_a[0], sizeof(float)*N));
  checkCudaErrors(cuMemcpyHtoD(devBufferB, &h_b[0], sizeof(float)*N));

  unsigned blockSizeX = 1024;
  unsigned blockSizeY = 1;
  unsigned blockSizeZ = 1;
  unsigned gridSizeX  = 4;
  unsigned gridSizeY  = 1;
  unsigned gridSizeZ  = 1;

  // Parâmetros do kernel.
  void *KernelParams[] = { &devBufferA, &devBufferB, &devBufferC };

  std::cout << "Launching kernel\n";

  // Lançando a execução do kernel.
  checkCudaErrors(cuLaunchKernel(function, gridSizeX, gridSizeY, gridSizeZ, blockSizeX, blockSizeY, blockSizeZ, 0, NULL, KernelParams, NULL));

  // Recuperando os dados do resultado.
  checkCudaErrors(cuMemcpyDtoH(&h_c[0], devBufferC, sizeof(float)*N));

  // Liberando Memória do dispositivo.
  checkCudaErrors(cuMemFree(devBufferA));
  checkCudaErrors(cuMemFree(devBufferB));
  checkCudaErrors(cuMemFree(devBufferC));
  checkCudaErrors(cuModuleUnload(cudaModule));
  checkCudaErrors(cuCtxDestroy(context));

  cudaDeviceReset();
}

/* ------------------------------------------------------------- */
void prepare_alternatives_functions(){
  fprintf(stdout, "In prepare_alternatives_functions.\n");  
  // Number of parameters to function.
  // void func_GPU(void). void parameters are considered.
  int n_params = 1;

  Func *ff = (Func *) malloc(sizeof(Func));

  // Número de parametros + 1, tem que ter um NULL finalizando as listas.
  ff->arg_types = (ffi_type**) malloc ((n_params + 1) * sizeof(ffi_type*));
  ff->arg_values = (void**) malloc ((n_params + 1) * sizeof(void*));

  ff->f = &func_GPU;
  memset(&ff->ret_value, 0, sizeof(ff->ret_value));

  // return type.
  ff->ret_type = &ffi_type_void;

  ff->nargs = n_params;

  ff->arg_values[0] = &ffi_type_void;
  ff->arg_values[1] = NULL;

  ff->arg_types[0] = &ffi_type_void;
  ff->arg_types[1] = NULL;

  int nloops = 2;
  int ndevices = 2;

  if (create_target_functions_table(&table, nloops, ndevices)) {
    // Set up the library Functions table.
    assert(table != NULL);

    fprintf(stderr, "Declaring function in 0,0.\n");
    table[0][0][0] = *ff;

    TablePointerFunctions = table;
    assert(TablePointerFunctions != NULL);
  }
}

/* ------------------------------------------------------------- */
int main() {
  int i;

  prepare_alternatives_functions();  

  init_array();

  int number_of_threads = 4;
  int chunk_size = N / number_of_threads;
  
  current_loop_index = 0;
  #pragma omp parallel for num_threads (number_of_threads) schedule (guided, 1024)
  for (i = 0; i < N; i++) {
     h_c[i] = h_a[i] + h_b[i];
  }

  // fprintf(stderr, "Calling gemm_cuda using Table of Pointers.\n");
  // call_function_ffi_call(table[0][0]);

  // print_array();
  check_result();

  return 0;
}
