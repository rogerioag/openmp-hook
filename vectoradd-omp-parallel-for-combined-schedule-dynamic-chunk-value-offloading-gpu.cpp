#include <stdio.h>
#include <stdlib.h>

#include <iostream>
#include <fstream>
#include <cassert>

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
#define N 1048576
#endif

float h_a[N];
float h_b[N];
float h_c[N];

void init_array() {
  int i;
  // Initialize vectors on host.
    for (i = 0; i < N; i++) {
      h_a[i] = 0.5;
      h_b[i] = 0.5;
    }
}

void print_array() {
  int i;
  fprintf(stdout, "Thread [%02d]: Imprimindo o array de resultados:\n", omp_get_thread_num());
  for (i = 0; i < N; i++) {
    fprintf(stdout, "Thread [%02d]: h_c[%07d]: %f\n", omp_get_thread_num(), i, h_c[i]);
  }
}

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

void func_CPU(void) {
    printf( "func_CPU.\n");
}


void checkCudaErrors(CUresult err) {
  assert(err == CUDA_SUCCESS);
}

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

  unsigned blockSizeX = 32;
  unsigned blockSizeY = 32;
  unsigned blockSizeZ = 1;
  unsigned gridSizeX  = 32;
  unsigned gridSizeY  = 32;
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

/* Tipo para o ponteiro de função. */
typedef void (*op_func) (void);

/* Tabela de funções para chamada parametrizada. */
op_func getTargetFunc[2] = { func_CPU, func_GPU };

/* Initialization of TablePointerFunctions to libhook. */
extern op_func *TablePointerFunctions = getTargetFunc;

int main() {
  int i;

  init_array();

  int number_of_threads = 4;
  // int chunk_size = N / number_of_threads;

  #pragma omp parallel for num_threads (number_of_threads) schedule (dynamic, 32)
  for (i = 0; i < N; i++) {
    h_c[i] = h_a[i] + h_b[i];
  }

  // TablePointerFunctions[1]();

  // print_array();
  check_result();

  return 0;
}
