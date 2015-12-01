#include <stdio.h>
#include <stdlib.h>

#include <iostream>
#include <fstream>
#include <cassert>
#include <string.h>
#include <sstream>

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
#define N 1048576
#endif

#define NUMBER_OF_THREADS 4;

/* Tipo para o ponteiro de função. */
typedef void (*op_func) (void);

/* Tabela de funções para chamada parametrizada. */
// op_func getTargetFunc[2] = { func_CPU, func_GPU };
op_func **getTargetFunc;
/* Initialization of TablePointerFunctions to libhook. */
extern op_func **TablePointerFunctions;

typedef struct grid_block_dim{
  unsigned blockSizeX;
  unsigned blockSizeY;
  unsigned blockSizeZ;
  unsigned gridSizeX;
  unsigned gridSizeY;
  unsigned gridSizeZ;
} grid_block_dim_t;


CUdevice    device;
CUmodule    cudaModule;
CUcontext   context;
CUfunction  function;
CUlinkState linker;
int         devCount;

float h_a[N];
float h_b[N];
float h_c[N];

/* Memory Allocation. */
CUdeviceptr devBufferA;
CUdeviceptr devBufferB;
CUdeviceptr devBufferC;

/*------------------------------------------------------------------------------*/
void init_array() {
  int i;
  int number_of_threads = NUMBER_OF_THREADS;
 
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
bool init_runtime_gpu(){

  bool result = true;

  // Inicialização CUDA.
  result = checkCudaErrors(cuInit(0));
  result = checkCudaErrors(cuDeviceGetCount(&devCount));
  result = checkCudaErrors(cuDeviceGet(&device, 0));

  char name[128];
  result = checkCudaErrors(cuDeviceGetName(name, 128, device));
  std::cout << "Using CUDA Device [0]: " << name << "\n";

  int devMajor, devMinor;
  result = checkCudaErrors(cuDeviceComputeCapability(&devMajor, &devMinor, device));
  std::cout << "Device Compute Capability: " << devMajor << "." << devMinor << "\n";
  if (devMajor < 2) {
    std::cerr << "ERROR: Device 0 is not SM 2.0 or greater\n";
    result = false;
  }

  return result;
}

/*------------------------------------------------------------------------------*/
bool data_allocation(){

  bool result = true;

  result = checkCudaErrors(cuMemAlloc(&devBufferA, sizeof(float)*N));
  result = checkCudaErrors(cuMemAlloc(&devBufferB, sizeof(float)*N));
  result = checkCudaErrors(cuMemAlloc(&devBufferC, sizeof(float)*N));

  return result;
}

/*------------------------------------------------------------------------------*/
bool data_transfer_and_sync(){
  bool result = true;
  // Transferindo os dados para a memória do dispositivo.

  result = checkCudaErrors(cuMemcpyHtoD(devBufferA, &h_a[0], sizeof(float)*N));
  result = checkCudaErrors(cuMemcpyHtoD(devBufferB, &h_b[0], sizeof(float)*N));

  return result;
}

/*------------------------------------------------------------------------------*/
bool kernel_loading(std::string kernel_name, CUfunction function){
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
}

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
bool kernel_launching(CUfunction func_kernel, grid_block_dim_t *gbd, void *KernelParams[]){
  bool result = true;

  std::cout << "Launching kernel\n";
  // Lançando a execução do kernel.
  result = checkCudaErrors(cuLaunchKernel(func_kernel, gbd->gridSizeX, gbd->gridSizeY, gbd->gridSizeZ, gbd->blockSizeX, gbd->blockSizeY, gbd->blockSizeZ, 0, NULL, KernelParams, NULL));

  return result;
}

/*------------------------------------------------------------------------------*/
bool data_transfer_retrieve_results(){
  bool result = true;

  // Recuperando os dados do resultado.
  result = checkCudaErrors(cuMemcpyDtoH(&h_c[0], devBufferC, sizeof(float)*N));

  return result;
}

/*------------------------------------------------------------------------------*/
bool release_data_device(){
  bool result = true;

  // Liberando Memória do dispositivo.
  result = checkCudaErrors(cuMemFree(devBufferA));
  result = checkCudaErrors(cuMemFree(devBufferB));
  result = checkCudaErrors(cuMemFree(devBufferC));
  result = checkCudaErrors(cuModuleUnload(cudaModule));
  result = checkCudaErrors(cuCtxDestroy(context));

  cudaDeviceReset();

  return result;
}

/*------------------------------------------------------------------------------*/
void handler_function_init_array_GPU(void){
  init_array();
}

/*------------------------------------------------------------------------------*/
void handler_function_main_GPU(void){

  CUfunction func_kernel;

  grid_block_dim_t *gbd;

  gbd = (grid_block_dim_t*) malloc(sizeof(grid_block_dim_t));
  
  if(!init_runtime_gpu()){
    fprintf(stderr, "Error initializing runtime GPU.\n");
  }

  if(!data_allocation()){
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
}

/*------------------------------------------------------------------------------*/
bool create_target_functions_table(op_func **table, int nrows, int ncolumns){

  bool result = true;
  /*int i;

  fprintf(stderr, "Allocating the rows.\n");
  table = (op_func **) malloc(nrows * sizeof(op_func *));

  if(table == NULL){
    fprintf(stderr, "Error in table of target functions allocation (rows).\n");
    result= false;
  }
  else{
    fprintf(stderr, "Allocating the columns.\n");
    for(i = 0; i < nrows; i++){
      table[i] = (op_func *) malloc(ncolumns * sizeof(op_func *));
      if(table [i] == NULL){
        fprintf(stderr, "Error in table of target functions allocation (columns).\n");
        result = false;
      }
    }
  }*/

  table = new op_func[nrows][ncolumns];

  return result;
}

/* ------------------------------------------------------------------------- */
int main() {
  int i;

  /*          device 0
   * loop 1   init_array alternative
   * loop 2   main alternative.
   * matrix 2 x 1.
  */
  fprintf(stderr, "Creating table of target functions.\n");
  if(create_target_functions_table(getTargetFunc, 2, 1)){
    /* Set up the library Functions table. */
    getTargetFunc[0][1] = handler_function_init_array_GPU;
    getTargetFunc[1][1] = handler_function_main_GPU;

    TablePointerFunctions = getTargetFunc;
  }

  // init_array();
  fprintf(stderr, "Calling the init_array by pointer.\n");
  TablePointerFunctions[0][1]();
  fprintf(stderr, "Calling the vectoradd by pointer.\n");
  TablePointerFunctions[1][1]();


//  int number_of_threads = NUMBER_OF_THREADS;
//  // int chunk_size = N / number_of_threads;

//  #pragma omp parallel for num_threads (number_of_threads) schedule (dynamic, 32)
//  for (i = 0; i < N; i++) {
//    h_c[i] = h_a[i] + h_b[i];
//  }
  fprintf(stderr, "Checking results.\n");
  // print_array();
  check_result();

  return 0;
}
