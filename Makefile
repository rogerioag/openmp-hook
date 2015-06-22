CC=gcc-4.7
CXX=g++-4.7

all: libhookomp main

# Step 1: Compiling with Position Independent Code
hookomp.o: hookomp.c
	${CXX} -c -Wall -Werror -fpic hookomp.c

# Step 2: Creating a shared library from an object file
libhookomp: hookomp.o
	${CXX} -shared -o libhookomp.so hookomp.o -ldl -lpapi

# Step 3: Linking with a shared library
# As you can see, that was actually pretty easy. We have a shared library. 
# Let’s compile our main.c and link it with libfoo. We’ll call our final program “test.” 
# Note that the -lfoo option is not looking for foo.o, but libfoo.so. GCC assumes that all 
# libraries start with ‘lib’ and end with .so or .a (.so is for shared object or shared 
# libraries, and .a is for archive, or statically linked libraries).

main: main-test.c
	${CXX} -L${PWD} -Wall -o main-test main-test.c -ldl -lhookomp 
	${CC} vectoradd-omp.c -o vectoradd-omp -fopenmp
	

clean:
	rm -rf *.o main-test *.so


