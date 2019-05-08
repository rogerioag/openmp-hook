CC=gcc-4.8
CXX=g++-4.8
LIB_HOOKOMP_PATH=$(PWD)
PAPI_DIR = /home/${USER}/papi/usr/local
INCLUDE += -I$(PAPI_DIR)/include -I$(PAPI_DIR)/src/testlib
LIBS += -L$(PAPI_DIR)/lib -L ${LIB_HOOKOMP_PATH} -Wl,-rpath,$(PAPI_DIR)/src/libpfm4/lib

all: clean info setenv libroofline libhookomp deploy-lib

setenv:
	LD_LIBRARY_PATH="$(LIB_HOOKOMP_PATH):$(LD_LIBRARY_PATH)"
        export LD_LIBRARY_PATH

# Step 1: Compiling with Position Independent Code
roofline.o: roofline.c
	${CXX} $(OPTIONS) $(INCLUDE) -c -Wno-write-strings -fpic roofline.c

# Step 2: Creating a shared library from an object file
libroofline: roofline.o
	${CXX} $(INCLUDE) $(LIBS) -shared -o libroofline.so roofline.o -ldl -lpapi -pthread -fopenmp


# Step 1: Compiling with Position Independent Code
hookomp.o: hookomp.c
	${CXX} $(OPTIONS) $(INCLUDE) -c -Wno-write-strings -fpic hookomp.c

# Step 2: Creating a shared library from an object file
libhookomp: hookomp.o
	${CXX} $(INCLUDE) $(LIBS) -shared -o libhookomp.so hookomp.o -ldl -fpermissive -lffi -lroofline -lm

# Step 3: Linking with a shared library
# As you can see, that was actually pretty easy. We have a shared library. 
# Let’s compile our main.c and link it with libfoo. We’ll call our final program “test.” 
# Note that the -lfoo option is not looking for foo.o, but libfoo.so. GCC assumes that all 
# libraries start with ‘lib’ and end with .so or .a (.so is for shared object or shared 
# libraries, and .a is for archive, or statically linked libraries).

deploy-lib:
	@echo "Deploying shared libraries..."

clean:
	@echo "Cleaning..."
	rm -rf *.o *.so

info:
	@echo "make OPTIONS=\"-D[COFFEE_LAKE | HASWELL | IVY_BRIDGE | SANDY_BRIDGE | NEHALEM]\""
	@echo "For compiling with DEBUG messages, use:"
	@echo "make OPTIONS=\"-DVERBOSE -DDEBUG -D[COFFEE_LAKE | HASWELL | IVY_BRIDGE | SANDY_BRIDGE | NEHALEM]\""
	@echo "For compiling with FORCENOOFFLOAD, use:"
	@echo "make OPTIONS=\"-DFORCENOOFFLOAD -D[COFFEE_LAKE | HASWELL | IVY_BRIDGE | SANDY_BRIDGE | NEHALEM]\""
	@echo "For compiling with DEBUG messages and force no offloading, use:"
	@echo "make OPTIONS=\"-DVERBOSE -DDEBUG -DFORCENOOFFLOAD -D[COFFEE_LAKE | HASWELL | IVY_BRIDGE | SANDY_BRIDGE | NEHALEM] \""
	@echo "make OPTIONS=\"-DVERBOSE -DDEBUG -DFORCENOOFFLOAD\""

document:
	@echo "Generating documentation using doxygen..."
	doxygen ./doc/doxygen.config
