# OpenCL_SDK=/global/homes/s/sgrauerg/NVIDIA_GPU_Computing_SDK
OpenCL_SDK=/home/goncalv/cuda

# INCLUDE=-I${OpenCL_SDK}/OpenCL/common/inc -I${PATH_TO_UTILS}
INCLUDE=-I${OpenCL_SDK}/include -I${PATH_TO_UTILS}

#LIBPATH=-L${OpenCL_SDK}/OpenCL/common/lib -L${OpenCL_SDK}/shared/lib
LIBPATH=-L${OpenCL_SDK}/lib64 -L${OpenCL_SDK}/lib

LIB=-lOpenCL -lm
all:
	gcc -O3 ${INCLUDE} ${LIBPATH} ${LIB} ${CFILES} -o ${EXECUTABLE}

clean:
	rm -f *~ *.exe *.txt
