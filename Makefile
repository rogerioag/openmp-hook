CC=gcc-4.8
CXX=g++-4.8
LIB_HOOKOMP_PATH=$(PWD)

all: clean info libroofline libhookomp deploy-lib

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
	${CXX} -L ${LIB_HOOKOMP_PATH} -shared -o libhookomp.so hookomp.o -ldl -fpermissive -lffi -lroofline

# Step 3: Linking with a shared library
# As you can see, that was actually pretty easy. We have a shared library. 
# Let’s compile our main.c and link it with libfoo. We’ll call our final program “test.” 
# Note that the -lfoo option is not looking for foo.o, but libfoo.so. GCC assumes that all 
# libraries start with ‘lib’ and end with .so or .a (.so is for shared object or shared 
# libraries, and .a is for archive, or statically linked libraries).

deploy-lib:
	@echo "Deploying shared libraries..."
	cp libhookomp.so ../function-pointers/
	cp libroofline.so ../function-pointers/

	cp libhookomp.so ../polly-openmp/vectoradd/
	cp libroofline.so ../polly-openmp/vectoradd/
	
clean:
	@echo "Cleaning..."
	rm -rf *.o *.so

info:
	@echo "Use make OPTIONS=\"-DVERBOSE -DDEBUG\" to compile with messages."
