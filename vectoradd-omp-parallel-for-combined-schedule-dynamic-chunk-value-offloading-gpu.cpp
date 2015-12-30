#include <stdio.h>
#include <stdlib.h>

#include <iostream>
#include <fstream>
#include <cassert>
#include <string.h>
#include <sstream>

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

#include <cuda.h>
#include <cuda_runtime.h>

// #include "runtimegpu.h"

// Size of vectors.
#ifndef N
// #define N 1048576
#define N 4096
#endif

#define NUMBER_OF_THREADS 4;

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

typedef struct grid_block_dim{
  unsigned blockSizeX;
  unsigned blockSizeY;
  unsigned blockSizeZ;
  unsigned gridSizeX;
  unsigned gridSizeY;
  unsigned gridSizeZ;
} grid_block_dim_t;

float h_a[N];
float h_b[N];
float h_c[N];

// Alocação de Memória no disposito.
CUdeviceptr devBufferA;
CUdeviceptr devBufferB;
CUdeviceptr devBufferC;

/*------------------------------------------------------------------------------*/
void init_array() {
  int i;
  int number_of_threads = NUMBER_OF_THREADS;
 
  // extern long int current_loop_index;
  current_loop_index = 0;
  fprintf(stderr, "[APP] Current loop index: %d\n", current_loop_index);
  #pragma omp parallel for num_threads (number_of_threads) schedule (dynamic, 32)
  for (i = 0; i < N; i++) {
    h_a[i] = 0.5;
    h_b[i] = 0.5;
  }
}

/*------------------------------------------------------------------------------*/
void print_array() {
  int i;
  fprintf(stdout, "Thread [%02d]: Imprimindo o array de resultados:\n", omp_get_thread_num());
  for (i = 0; i < N; i++) {
    fprintf(stdout, "Thread [%02d]: h_c[%07d]: %f\n", omp_get_thread_num(), i, h_c[i]);
  }
}

/*------------------------------------------------------------------------------*/
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

/*------------------------------------------------------------------------------*/
bool checkCudaErrors(CUresult err) {
  return (err == CUDA_SUCCESS);
}

/*------------------------------------------------------------------------------*/
bool init_runtime_gpu(CUdevice *device){

  bool result = true;
  int  devCount;

  // Inicialização CUDA.
  result = checkCudaErrors(cuInit(0));
  result = checkCudaErrors(cuDeviceGetCount(&devCount));
  result = checkCudaErrors(cuDeviceGet(device, 0));

  char name[128];
  result = checkCudaErrors(cuDeviceGetName(name, 128, (int) *device));
  std::cout << "Using CUDA Device [0]: " << name << "\n";

  int devMajor, devMinor;
  result = checkCudaErrors(cuDeviceComputeCapability(&devMajor, &devMinor, (int) *device));
  std::cout << "Device Compute Capability: " << devMajor << "." << devMinor << "\n";
  if (devMajor < 2) {
    std::cerr << "ERROR: Device 0 is not SM 2.0 or greater\n";
    result = false;
  }

  return result;
}

/*------------------------------------------------------------------------------*/
/*bool data_allocation(){

  bool result = true;

  result = checkCudaErrors(cuMemAlloc(&devBufferA, sizeof(float)*N));
  result = checkCudaErrors(cuMemAlloc(&devBufferB, sizeof(float)*N));
  result = checkCudaErrors(cuMemAlloc(&devBufferC, sizeof(float)*N));

  return result;
}*/

/*------------------------------------------------------------------------------*/
/*bool data_transfer_and_sync(){
  bool result = true;
  // Transferindo os dados para a memória do dispositivo.

  result = checkCudaErrors(cuMemcpyHtoD(devBufferA, &h_a[0], sizeof(float)*N));
  result = checkCudaErrors(cuMemcpyHtoD(devBufferB, &h_b[0], sizeof(float)*N));

  return result;
}*/

/*------------------------------------------------------------------------------*/
/*bool kernel_loading(std::string kernel_name, CUfunction function){
  bool result = true;

  std::cout << "Carregando" << kernel_name << ".ptx." << "\n";
  // Carregando o arquivo PTX.
  std::stringstream ss;
  ss << kernel_name << ".ptx";
  std::string file_name = ss.str();

  std::ifstream ifs(file_name.c_str());
  if (!ifs.is_open()) {
    std::cerr << kernel_name << ".ptx not found.\n";
  }
  std::string str((std::istreambuf_iterator<char>(ifs)), std::istreambuf_iterator<char>());

  // Criando o Driver Context.
  result = checkCudaErrors(cuCtxCreate(&context, 0, device));

  // Criando um módulo.
  result = checkCudaErrors(cuModuleLoadDataEx(&cudaModule, str.c_str(), 0, 0, 0));

  // Get kernel function.
  result = checkCudaErrors(cuModuleGetFunction(&function, cudaModule, kernel_name.c_str()));

  return result;
}*/

/*------------------------------------------------------------------------------*/
bool calculate_kernel_dimensions(grid_block_dim_t *gbd){
  bool result = true;

  gbd->blockSizeX = 32;
  gbd->blockSizeY = 32;
  gbd->blockSizeZ = 1;
  gbd->gridSizeX  = 32;
  gbd->gridSizeY  = 32;
  gbd->gridSizeZ  = 1;

  return result;
}

/*------------------------------------------------------------------------------*/
/*bool kernel_launching(CUfunction func_kernel, grid_block_dim_t *gbd, void *KernelParams[]){
  bool result = true;

  std::cout << "Launching kernel\n";
  // Lançando a execução do kernel.
  result = checkCudaErrors(cuLaunchKernel(func_kernel, gbd->gridSizeX, gbd->gridSizeY, gbd->gridSizeZ, gbd->blockSizeX, gbd->blockSizeY, gbd->blockSizeZ, 0, NULL, KernelParams, NULL));

  return result;
}*/

/*------------------------------------------------------------------------------*/
/*bool data_transfer_retrieve_results(){
  bool result = true;

  // Recuperando os dados do resultado.
  result = checkCudaErrors(cuMemcpyDtoH(&h_c[0], devBufferC, sizeof(float)*N));

  return result;
}*/

/*------------------------------------------------------------------------------*/
/*bool release_data_device(){
  bool result = true;

  // Liberando Memória do dispositivo.
  result = checkCudaErrors(cuMemFree(devBufferA));
  result = checkCudaErrors(cuMemFree(devBufferB));
  result = checkCudaErrors(cuMemFree(devBufferC));
  result = checkCudaErrors(cuModuleUnload(cudaModule));
  result = checkCudaErrors(cuCtxDestroy(context));

  cudaDeviceReset();

  return result;
}*/

/*------------------------------------------------------------------------------*/
void handler_function_init_array_GPU(void){
  CUdevice    device;
  CUmodule    cudaModule;
  CUcontext   context;
  CUfunction  function;
  CUlinkState linker;

  grid_block_dim_t *gbd;
  gbd = (grid_block_dim_t*) malloc(sizeof(grid_block_dim_t));
  
  if(!init_runtime_gpu(&device)){
    fprintf(stderr, "Error initializing runtime GPU.\n");
  }

  // Criando o Driver Context.
  checkCudaErrors(cuCtxCreate(&context, 0, device));

  if(devBufferA == NULL){
    checkCudaErrors(cuMemAlloc(&devBufferA, sizeof(float)*N));
  }

  if(devBufferB == NULL){
    checkCudaErrors(cuMemAlloc(&devBufferB, sizeof(float)*N));
  }
  
  if(devBufferC == NULL){
    checkCudaErrors(cuMemAlloc(&devBufferC, sizeof(float)*N));
  }

  std::cout << "Carregando init_array-kernel.ptx. " << "\n";
  // Carregando o arquivo PTX.
  std::ifstream t("init_array-kernel.ptx");
  if (!t.is_open()) {
    std::cerr << "init_array-kernel.ptx not found\n";
  }
  std::string str((std::istreambuf_iterator<char>(t)),std::istreambuf_iterator<char>());

  // Criando um módulo.
  checkCudaErrors(cuModuleLoadDataEx(&cudaModule, str.c_str(), 0, 0, 0));

  // Get kernel function.
  checkCudaErrors(cuModuleGetFunction(&function, cudaModule, "init_array_kernel"));

  if(!calculate_kernel_dimensions(gbd)){
    fprintf(stderr, "Error calculating the kernel dimensions.\n"); 
  }

  fprintf(stderr, "Dimensions: %d, %d, %d, %d, %d, %d.\n", gbd->gridSizeX, gbd->gridSizeY, gbd->gridSizeZ, gbd->blockSizeX, gbd->blockSizeY, gbd->blockSizeZ); 

  // Parâmetros do kernel.
  void *KernelParams[] = { &devBufferA, &devBufferB };

  std::cout << "Launching kernel\n";

  // Lançando a execução do kernel.
  checkCudaErrors(cuLaunchKernel(function, gbd->gridSizeX, gbd->gridSizeY, gbd->gridSizeZ, gbd->blockSizeX, gbd->blockSizeY, gbd->blockSizeZ, 0, NULL, KernelParams, NULL));

  // No copy back. Data resident in GPU.
}

/*------------------------------------------------------------------------------*/
/*void handler_function_main_GPU(void){

  CUfunction func_kernel;

  grid_block_dim_t *gbd;

  gbd = (grid_block_dim_t*) malloc(sizeof(grid_block_dim_t));
  
  if(!init_runtime_gpu()){
    fprintf(stderr, "Error initializing runtime GPU.\n");
  }

  /*if(!data_allocation()){
    fprintf(stderr, "Error data allocation in GPU.\n");
  }*/

  /*bool result = true;

  result = checkCudaErrors(cuMemAlloc(&devBufferA, sizeof(float)*N));
  result = checkCudaErrors(cuMemAlloc(&devBufferB, sizeof(float)*N));
  result = checkCudaErrors(cuMemAlloc(&devBufferC, sizeof(float)*N));

  if(!result){
    fprintf(stderr, "Error data allocation in GPU.\n");
  }

  if(!data_transfer_and_sync()){
    fprintf(stderr, "Error data transfer or synchronization with GPU.\n");
  }

  if(!kernel_loading("vectoradd-kernel", func_kernel)){
    fprintf(stderr, "Error loading kernel from file.\n"); 
  }

  if(!calculate_kernel_dimensions(gbd)){
    fprintf(stderr, "Error loading kernel from file.\n"); 
  }

  // Parâmetros do kernel.
  void *KernelParams[] = { &devBufferA, &devBufferB, &devBufferC };

  if(!kernel_launching(func_kernel, gbd, KernelParams)){
    fprintf(stderr, "Error launching the kernel.\n");
  }

  if(!data_transfer_retrieve_results()){
    fprintf(stderr, "Error retrieving the results form GPU.\n");
  }

  if(!release_data_device()){
    fprintf(stderr, "Error retrieving the results form GPU.\n");
  }
}*/
void handler_function_main_GPU(void){
  CUdevice    device;
  CUmodule    cudaModule;
  CUcontext   context;
  CUfunction  function;
  CUlinkState linker;

  grid_block_dim_t *gbd;
  gbd = (grid_block_dim_t*) malloc(sizeof(grid_block_dim_t));
  
  if(!init_runtime_gpu(&device)){
    fprintf(stderr, "Error initializing runtime GPU.\n");
  }

  // Criando o Driver Context.
  checkCudaErrors(cuCtxCreate(&context, 0, device));

  if(devBufferA == NULL){
    checkCudaErrors(cuMemAlloc(&devBufferA, sizeof(float)*N));
    checkCudaErrors(cuMemcpyHtoD(devBufferA, &h_a[0], sizeof(float)*N));
  }

  if(devBufferB == NULL){
    checkCudaErrors(cuMemAlloc(&devBufferB, sizeof(float)*N));
    checkCudaErrors(cuMemcpyHtoD(devBufferB, &h_b[0], sizeof(float)*N));
  }
  
  if(devBufferC == NULL){
    checkCudaErrors(cuMemAlloc(&devBufferC, sizeof(float)*N));
  }

  // Sincronização??

  std::cout << "Carregando vectoradd-kernel.ptx. " << "\n";
  // Carregando o arquivo PTX.
  std::ifstream t("vectoradd-kernel.ptx");
  if (!t.is_open()) {
    std::cerr << "vectoradd-kernel.ptx not found\n";
  }
  std::string str((std::istreambuf_iterator<char>(t)),std::istreambuf_iterator<char>());

  // Criando um módulo.
  checkCudaErrors(cuModuleLoadDataEx(&cudaModule, str.c_str(), 0, 0, 0));

  // Get kernel function.
  checkCudaErrors(cuModuleGetFunction(&function, cudaModule, "vectoradd_kernel"));

  // Calculate kernel dimensions.
  if(!calculate_kernel_dimensions(gbd)){
    fprintf(stderr, "Error loading kernel from file.\n"); 
  }

  fprintf(stderr, "Dimensions: %d, %d, %d, %d, %d, %d.\n", gbd->gridSizeX, gbd->gridSizeY, gbd->gridSizeZ, gbd->blockSizeX, gbd->blockSizeY, gbd->blockSizeZ); 

  // Parâmetros do kernel.
  void *KernelParams[] = { &devBufferA, &devBufferB, &devBufferC };

  std::cout << "Launching kernel\n";

  // Lançando a execução do kernel.
  checkCudaErrors(cuLaunchKernel(function, gbd->gridSizeX, gbd->gridSizeY, gbd->gridSizeZ, gbd->blockSizeX, gbd->blockSizeY, gbd->blockSizeZ, 0, NULL, KernelParams, NULL));

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
void prepare_alternatives_functions(){
  fprintf(stdout, "In prepare_alternatives_functions.\n");  
  // Number of parameters to function.
  // void func_GPU(void). void parameters are considered.
  int n_params = 1;

  // void handler_function_init_array_GPU(void)
  Func *ff_1 = (Func *) malloc(sizeof(Func));

  // Número de parametros + 1, tem que ter um NULL finalizando as listas.
  ff_1->arg_types = (ffi_type**) malloc ((n_params + 1) * sizeof(ffi_type*));
  ff_1->arg_values = (void**) malloc ((n_params + 1) * sizeof(void*));

  ff_1->f = &handler_function_init_array_GPU;
  memset(&ff_1->ret_value, 0, sizeof(ff_1->ret_value));

  // return type.
  ff_1->ret_type = &ffi_type_void;

  ff_1->nargs = n_params;

  ff_1->arg_values[0] = &ffi_type_void;
  ff_1->arg_values[1] = NULL;

  ff_1->arg_types[0] = &ffi_type_void;
  ff_1->arg_types[1] = NULL;

  // void handler_function_main_GPU(void).
  Func *ff_2 = (Func *) malloc(sizeof(Func));

  // Número de parametros + 1, tem que ter um NULL finalizando as listas.
  ff_2->arg_types = (ffi_type**) malloc ((n_params + 1) * sizeof(ffi_type*));
  ff_2->arg_values = (void**) malloc ((n_params + 1) * sizeof(void*));

  ff_2->f = &handler_function_main_GPU;
  memset(&ff_2->ret_value, 0, sizeof(ff_2->ret_value));

  // return type.
  ff_2->ret_type = &ffi_type_void;

  ff_2->nargs = n_params;

  ff_2->arg_values[0] = &ffi_type_void;
  ff_2->arg_values[1] = NULL;

  ff_2->arg_types[0] = &ffi_type_void;
  ff_2->arg_types[1] = NULL;

  /*          device 0
   * loop 0   init_array alternative
   * loop 1   main alternative.
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

    fprintf(stderr, "Declaring function in 1,0.\n");
    table[1][0][0] = *ff_2;

    TablePointerFunctions = table;
    assert(TablePointerFunctions != NULL);
  }
}

/* ------------------------------------------------------------------------- */
int main() {
  int i;

  prepare_alternatives_functions();  

  // init_array();
  handler_function_init_array_GPU();

  int number_of_threads = NUMBER_OF_THREADS;
  // int chunk_size = N / number_of_threads;
  
  current_loop_index = 1;
  fprintf(stderr, "[APP] Current loop index: %d\n", current_loop_index);
  #pragma omp parallel for num_threads (number_of_threads) schedule (dynamic, 1024)
  for (i = 0; i < N; i++) {
     h_c[i] = h_a[i] + h_b[i];
  }

  // fprintf(stderr, "Calling gemm_cuda using Table of Pointers.\n");
  // call_function_ffi_call(table[0][0]);

  // print_array();
  check_result();

  return 0;
}
