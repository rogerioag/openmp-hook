CC=gcc-4.8
CXX=g++-4.8
LIB_HOOKOMP_PATH=$(PWD)

all: clean info libroofline libhookomp main

# Step 1: Compiling with Position Independent Code
roofline.o: roofline.c
	${CXX} $(OPTIONS) -c -Wall -Werror -fpic roofline.c

# Step 2: Creating a shared library from an object file
libroofline: roofline.o
	${CXX} -shared -o libroofline.so roofline.o -ldl -lpapi -pthread -fopenmp


# Step 1: Compiling with Position Independent Code
hookomp.o: hookomp.c
	${CXX} $(OPTIONS) -c -Wall -Werror -fpic hookomp.c

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

main: main-test.c
	${CXX} -L${PWD} -Wall -o main-test main-test.c -ldl -lhookomp 
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
	${CXX} -L ${LIB_HOOKOMP_PATH} vectoradd-omp-for-runtime.c -o vectoradd-omp-for-runtime -lhookomp -fopenmp -lgomp


	cp libhookomp.so ../function-pointers/
	cp libroofline.so ../function-pointers/

	cp libhookomp.so ../polly-openmp/vectoradd/
	cp libroofline.so ../polly-openmp/vectoradd/
	
clean:
	rm -rf *.o main-test *.so vectoradd-omp-parallel-for-peeling vectoradd-omp-parallel-for-peeling-for-to-1-thread vectoradd-omp-parallel-for-single vectoradd-omp vectoradd-omp-loops vectoradd-omp-parallel-single-for-schedule-default-1-region vectoradd-omp-parallel-single-for-schedule-default-2-regions vectoradd-omp-parallel-single-for-schedule-runtime-1-region vectoradd-omp-parallel-single-for-schedule-runtime-2-regions 

info:
	@echo "Use make OPTIONS=-DVERBOSE to compile with messages."
