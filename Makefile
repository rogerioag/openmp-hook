CC=gcc-4.8
CXX=g++-4.8
LIB_HOOKOMP_PATH=$(PWD)

all: clean info libroofline libhookomp main

# Step 1: Compiling with Position Independent Code
roofline.o: roofline.c
	${CXX} $(OPTIONS) -c -Wno-write-strings -fpic roofline.c

# Step 2: Creating a shared library from an object file
libroofline: roofline.o
	${CXX} -shared -o libroofline.so roofline.o -ldl -lpapi -pthread -fopenmp


# Step 1: Compiling with Position Independent Code
hookomp.o: hookomp.c
	${CXX} $(OPTIONS) -c -Wno-write-strings -fpic hookomp.c

# Step 2: Creating a shared library from an object file
libhookomp: hookomp.o
	LD_LIBRARY_PATH=$(PWD):$(LD_LIBRARY_PATH) export LD_LIBRARY_PATH
	${CXX} -L ${LIB_HOOKOMP_PATH} -shared -o libhookomp.so hookomp.o -ldl -lroofline

# Step 3: Linking with a shared library
# As you can see, that was actually pretty easy. We have a shared library. 
# Let’s compile our main.c and link it with libfoo. We’ll call our final program “test.” 
# Note that the -lfoo option is not looking for foo.o, but libfoo.so. GCC assumes that all 
# libraries start with ‘lib’ and end with .so or .a (.so is for shared object or shared 
# libraries, and .a is for archive, or statically linked libraries).

# main: main-test.c
main:
	# ${CXX} -L${PWD} -Wall -o main-test main-test.c -ldl -lhookomp 
	${CXX} vectoradd-omp.c -o vectoradd-omp -fopenmp
	${CXX} -L ${LIB_HOOKOMP_PATH} vectoradd-omp-parallel-for-single.c -o vectoradd-omp-parallel-for-single -lhookomp -fopenmp
	${CXX} -L ${LIB_HOOKOMP_PATH} vectoradd-omp-parallel-for-peeling-for-to-1-thread.c -o vectoradd-omp-parallel-for-peeling-for-to-1-thread -lhookomp -fopenmp

	${CXX} -L ${LIB_HOOKOMP_PATH} vectoradd-omp-parallel-single-for-schedule-default-1-region.c -o vectoradd-omp-parallel-single-for-schedule-default-1-region -lhookomp -fopenmp -lgomp
	${CXX} -L ${LIB_HOOKOMP_PATH} vectoradd-omp-parallel-single-for-schedule-default-2-regions.c -o vectoradd-omp-parallel-single-for-schedule-default-2-regions -lhookomp -fopenmp -lgomp

	${CXX} -L ${LIB_HOOKOMP_PATH} vectoradd-omp-parallel-single-for-schedule-runtime-1-region.c -o vectoradd-omp-parallel-single-for-schedule-runtime-1-region -lhookomp -fopenmp -lgomp
	${CXX} -L ${LIB_HOOKOMP_PATH} vectoradd-omp-parallel-single-for-schedule-runtime-2-regions.c -o vectoradd-omp-parallel-single-for-schedule-runtime-2-regions -lhookomp -fopenmp -lgomp

	${CXX} -L ${LIB_HOOKOMP_PATH} -S vectoradd-omp-parallel-single-for-schedule-default-1-region.c -o vectoradd-omp-parallel-single-for-schedule-default-1-region.s -fopenmp -lgomp
	${CXX} -L ${LIB_HOOKOMP_PATH} -S vectoradd-omp-parallel-single-for-schedule-default-2-regions.c -o vectoradd-omp-parallel-single-for-schedule-default-2-regions.s -fopenmp -lgomp

	${CXX} -L ${LIB_HOOKOMP_PATH} -S vectoradd-omp-parallel-single-for-schedule-runtime-1-region.c -o vectoradd-omp-parallel-single-for-schedule-runtime-1-region.s -fopenmp -lgomp
	${CXX} -L ${LIB_HOOKOMP_PATH} -S vectoradd-omp-parallel-single-for-schedule-runtime-2-regions.c -o vectoradd-omp-parallel-single-for-schedule-runtime-2-regions.s -fopenmp -lgomp

	# ${CXX} -L ${LIB_HOOKOMP_PATH} vectoradd-omp-parallel-single-for-1-region-migration.c -o vectoradd-omp-parallel-single-for-1-region-migration -lhookomp -fopenmp -lgomp
	
	${CXX} vectoradd-omp-loops.c -o vectoradd-omp-loops -lpapi -fopenmp -lpthread

	# Teste de usar o código do PoLLy sem modificações.
	# Usar a função de next para testar os contadores de performance.
	${CXX} -L ${LIB_HOOKOMP_PATH} vectoradd-omp-parallel-for-combined-schedule-dynamic-chunk-variable.c -o vectoradd-omp-parallel-for-combined-schedule-dynamic-chunk-variable.exe -lhookomp -fopenmp -lgomp
	${CXX} -L ${LIB_HOOKOMP_PATH} vectoradd-omp-parallel-for-combined-schedule-dynamic-chunk-value.c -o vectoradd-omp-parallel-for-combined-schedule-dynamic-chunk-value.exe -lhookomp -fopenmp -lgomp

	${CXX} -L ${LIB_HOOKOMP_PATH} vectoradd-omp-parallel-for-combined-schedule-guided-chunk-variable.c -o vectoradd-omp-parallel-for-combined-schedule-guided-chunk-variable.exe -lhookomp -fopenmp -lgomp
	${CXX} -L ${LIB_HOOKOMP_PATH} vectoradd-omp-parallel-for-combined-schedule-guided-chunk-value.c -o vectoradd-omp-parallel-for-combined-schedule-guided-chunk-value.exe -lhookomp -fopenmp -lgomp

	${CXX} -L ${LIB_HOOKOMP_PATH} vectoradd-omp-parallel-for-combined-schedule-static-chunk-variable.c -o vectoradd-omp-parallel-for-combined-schedule-static-chunk-variable.exe -lhookomp -fopenmp -lgomp
	${CXX} -L ${LIB_HOOKOMP_PATH} vectoradd-omp-parallel-for-combined-schedule-static-chunk-value.c -o vectoradd-omp-parallel-for-combined-schedule-static-chunk-value.exe -lhookomp -fopenmp -lgomp

	# schedule(auto): error: schedule ‘auto’ does not take a ‘chunk_size’ parameter. 
	# ${CXX} -L ${LIB_HOOKOMP_PATH} vectoradd-omp-parallel-for-combined-schedule-auto-chunk-variable.c -o vectoradd-omp-parallel-for-combined-schedule-auto-chunk-variable.exe -lhookomp -fopenmp -lgomp
	# ${CXX} -L ${LIB_HOOKOMP_PATH} vectoradd-omp-parallel-for-combined-schedule-auto-chunk-value.c -o vectoradd-omp-parallel-for-combined-schedule-auto-chunk-value.exe -lhookomp -fopenmp -lgomp

	${CXX} -L ${LIB_HOOKOMP_PATH} vectoradd-omp-parallel-for-combined-schedule-auto.c -o vectoradd-omp-parallel-for-combined-schedule-auto.exe -lhookomp -fopenmp -lgomp

	# schedule(runtime): error: schedule ‘runtime’ does not take a ‘chunk_size’ parameter.
	# ${CXX} -L ${LIB_HOOKOMP_PATH} vectoradd-omp-parallel-for-combined-schedule-runtime-chunk-variable.c -o vectoradd-omp-parallel-for-combined-schedule-runtime-chunk-variable.exe -lhookomp -fopenmp -lgomp
	# ${CXX} -L ${LIB_HOOKOMP_PATH} vectoradd-omp-parallel-for-combined-schedule-runtime-chunk-value.c -o vectoradd-omp-parallel-for-combined-schedule-runtime-chunk-value.exe -lhookomp -fopenmp -lgomp

	${CXX} -L ${LIB_HOOKOMP_PATH} vectoradd-omp-parallel-for-combined-schedule-runtime.c -o vectoradd-omp-parallel-for-combined-schedule-runtime.exe -lhookomp -fopenmp -lgomp

	${CXX} -L ${LIB_HOOKOMP_PATH} vectoradd-omp-parallel-for-combined-schedule-unspecified.c -o vectoradd-omp-parallel-for-combined-schedule-unspecified.exe -lhookomp -fopenmp -lgomp
	
	# ${CXX} -L ${LIB_HOOKOMP_PATH} vectoradd-omp-for-runtime.c -o vectoradd-omp-for-runtime -lhookomp -fopenmp -lgomp
	# ${CXX} -L ${LIB_HOOKOMP_PATH} vectoradd-omp-for-static.c -o vectoradd-omp-for-static -lhookomp -fopenmp -lgomp
	# ${CXX} -L ${LIB_HOOKOMP_PATH} vectoradd-omp-for-dynamic.c -o vectoradd-omp-for-dynamic -lhookomp -fopenmp -lgomp
	# ${CXX} -L ${LIB_HOOKOMP_PATH} vectoradd-omp-for-guided.c -o vectoradd-omp-for-guided -lhookomp -fopenmp -lgomp

	# Tests for multiple parallel regions.
	${CXX} -L ${LIB_HOOKOMP_PATH} vectoradd-multiple-omp-parallel-for-combined-schedule-runtime.c -o vectoradd-multiple-omp-parallel-for-combined-schedule-runtime.exe -lhookomp -fopenmp -lgomp

	${CXX} -L ${LIB_HOOKOMP_PATH} vectoradd-multiple-omp-parallel-for-combined-schedule-dynamic-chunk-value.c -o vectoradd-multiple-omp-parallel-for-combined-schedule-dynamic-chunk-value.exe -lhookomp -fopenmp -lgomp

		# Test of offloading function schedule runtime.
	/home/goncalv/prototipo-370-gpu/llvm_build/bin/llc -march=nvptx64 vectoradd-kernel.ll -o vectoradd-kernel.ptx
	
	${CXX} -L ${LIB_HOOKOMP_PATH} vectoradd-omp-parallel-for-combined-schedule-runtime-offloading-gpu.cpp -o vectoradd-omp-parallel-for-combined-schedule-runtime-offloading-gpu.exe -g -I/home/goncalv/cuda/include -lcuda -lcudart -I/usr/include/c++/4.8 -I/usr/include/c++/4.8/x86_64-linux-gnu/ -L/home/goncalv/cuda/lib64 -I/home/goncalv/cuda/samples/common/inc/ -L/home/goncalv/cuda/samples/common/lib -lhookomp -fopenmp -lgomp
	
	# Offloading test without hook. The program will be executed normaly.
	${CXX} vectoradd-omp-parallel-for-combined-schedule-runtime-offloading-gpu.cpp -o vectoradd-omp-parallel-for-combined-schedule-runtime-offloading-gpu-without-hook.exe -g -I/home/goncalv/cuda/include -lcuda -lcudart -I/usr/include/c++/4.8 -I/usr/include/c++/4.8/x86_64-linux-gnu/ -L/home/goncalv/cuda/lib64 -I/home/goncalv/cuda/samples/common/inc/ -L/home/goncalv/cuda/samples/common/lib -fopenmp -lgomp
	@echo "*****Use: LD_PRELOAD=./libhookomp.so ./vectoradd-omp-parallel-for-combined-schedule-runtime-offloading-gpu-without-hook.exe"

	# Test of offloading function schedule guided.
	${CXX} -L ${LIB_HOOKOMP_PATH} vectoradd-omp-parallel-for-combined-schedule-guided-chunk-variable-offloading-gpu.cpp -o vectoradd-omp-parallel-for-combined-schedule-guided-chunk-variable-offloading-gpu.exe -g -I/home/goncalv/cuda/include -lcuda -lcudart -I/usr/include/c++/4.8 -I/usr/include/c++/4.8/x86_64-linux-gnu/ -L/home/goncalv/cuda/lib64 -I/home/goncalv/cuda/samples/common/inc/ -L/home/goncalv/cuda/samples/common/lib -lhookomp -fopenmp -lgomp
	
	# Offloading test without hook. The program will be executed normaly.
	${CXX} vectoradd-omp-parallel-for-combined-schedule-guided-chunk-variable-offloading-gpu.cpp -o vectoradd-omp-parallel-for-combined-schedule-guided-chunk-variable-offloading-gpu-without-hook.exe -g -I/home/goncalv/cuda/include -lcuda -lcudart -I/usr/include/c++/4.8 -I/usr/include/c++/4.8/x86_64-linux-gnu/ -L/home/goncalv/cuda/lib64 -I/home/goncalv/cuda/samples/common/inc/ -L/home/goncalv/cuda/samples/common/lib -fopenmp -lgomp
	@echo "*****Use: LD_PRELOAD=./libhookomp.so ./vectoradd-omp-parallel-for-combined-schedule-guided-chunk-variable-offloading-gpu-without-hook.exe"

	${CXX} -L ${LIB_HOOKOMP_PATH} vectoradd-omp-parallel-for-combined-schedule-guided-chunk-value-offloading-gpu.cpp -o vectoradd-omp-parallel-for-combined-schedule-guided-chunk-value-offloading-gpu.exe -g -I/home/goncalv/cuda/include -lcuda -lcudart -I/usr/include/c++/4.8 -I/usr/include/c++/4.8/x86_64-linux-gnu/ -L/home/goncalv/cuda/lib64 -I/home/goncalv/cuda/samples/common/inc/ -L/home/goncalv/cuda/samples/common/lib -lhookomp -fopenmp -lgomp
	
	# Offloading test without hook. The program will be executed normaly.
	${CXX} vectoradd-omp-parallel-for-combined-schedule-guided-chunk-value-offloading-gpu.cpp -o vectoradd-omp-parallel-for-combined-schedule-guided-chunk-value-offloading-gpu-without-hook.exe -g -I/home/goncalv/cuda/include -lcuda -lcudart -I/usr/include/c++/4.8 -I/usr/include/c++/4.8/x86_64-linux-gnu/ -L/home/goncalv/cuda/lib64 -I/home/goncalv/cuda/samples/common/inc/ -L/home/goncalv/cuda/samples/common/lib -fopenmp -lgomp
	@echo "*****Use: LD_PRELOAD=./libhookomp.so ./vectoradd-omp-parallel-for-combined-schedule-guided-chunk-value-offloading-gpu-without-hook.exe"

	# Test of offloading function schedule dynamic.
	${CXX} -L ${LIB_HOOKOMP_PATH} vectoradd-omp-parallel-for-combined-schedule-dynamic-chunk-variable-offloading-gpu.cpp -o vectoradd-omp-parallel-for-combined-schedule-dynamic-chunk-variable-offloading-gpu.exe -g -I/home/goncalv/cuda/include -lcuda -lcudart -I/usr/include/c++/4.8 -I/usr/include/c++/4.8/x86_64-linux-gnu/ -L/home/goncalv/cuda/lib64 -I/home/goncalv/cuda/samples/common/inc/ -L/home/goncalv/cuda/samples/common/lib -lhookomp -fopenmp -lgomp
	
	# Offloading test without hook. The program will be executed normaly.
	${CXX} vectoradd-omp-parallel-for-combined-schedule-dynamic-chunk-variable-offloading-gpu.cpp -o vectoradd-omp-parallel-for-combined-schedule-dynamic-chunk-variable-offloading-gpu-without-hook.exe -g -I/home/goncalv/cuda/include -lcuda -lcudart -I/usr/include/c++/4.8 -I/usr/include/c++/4.8/x86_64-linux-gnu/ -L/home/goncalv/cuda/lib64 -I/home/goncalv/cuda/samples/common/inc/ -L/home/goncalv/cuda/samples/common/lib -fopenmp -lgomp
	@echo "*****Use: LD_PRELOAD=./libhookomp.so ./vectoradd-omp-parallel-for-combined-schedule-dynamic-chunk-variable-offloading-gpu-without-hook.exe"

	${CXX} -L ${LIB_HOOKOMP_PATH} vectoradd-omp-parallel-for-combined-schedule-dynamic-chunk-value-offloading-gpu.cpp -o vectoradd-omp-parallel-for-combined-schedule-dynamic-chunk-value-offloading-gpu.exe -g -I/home/goncalv/cuda/include -lcuda -lcudart -I/usr/include/c++/4.8 -I/usr/include/c++/4.8/x86_64-linux-gnu/ -L/home/goncalv/cuda/lib64 -I/home/goncalv/cuda/samples/common/inc/ -L/home/goncalv/cuda/samples/common/lib -lhookomp -fopenmp -lgomp
	
	# Offloading test without hook. The program will be executed normaly.
	${CXX} vectoradd-omp-parallel-for-combined-schedule-dynamic-chunk-value-offloading-gpu.cpp -o vectoradd-omp-parallel-for-combined-schedule-dynamic-chunk-value-offloading-gpu-without-hook.exe -g -I/home/goncalv/cuda/include -lcuda -lcudart -I/usr/include/c++/4.8 -I/usr/include/c++/4.8/x86_64-linux-gnu/ -L/home/goncalv/cuda/lib64 -I/home/goncalv/cuda/samples/common/inc/ -L/home/goncalv/cuda/samples/common/lib -fopenmp -lgomp
	@echo "*****Use: LD_PRELOAD=./libhookomp.so ./vectoradd-omp-parallel-for-combined-schedule-dynamic-chunk-value-offloading-gpu-without-hook.exe"


	cp libhookomp.so ../function-pointers/
	cp libroofline.so ../function-pointers/

	cp libhookomp.so ../polly-openmp/vectoradd/
	cp libroofline.so ../polly-openmp/vectoradd/
	
clean:
	rm -rf *.o main-test *.so vectoradd-omp-parallel-for-peeling vectoradd-omp-parallel-for-peeling-for-to-1-thread vectoradd-omp-parallel-for-single vectoradd-omp vectoradd-omp-loops vectoradd-omp-parallel-single-for-schedule-default-1-region vectoradd-omp-parallel-single-for-schedule-default-2-regions vectoradd-omp-parallel-single-for-schedule-runtime-1-region vectoradd-omp-parallel-single-for-schedule-runtime-2-regions vectoradd-omp-for-runtime vectoradd-omp-for-guided vectoradd-omp-for-static vectoradd-omp-for-dynamic vectoradd-omp*.exe

info:
	@echo "Use make OPTIONS=\"-DVERBOSE -DDEBUG\" to compile with messages."
