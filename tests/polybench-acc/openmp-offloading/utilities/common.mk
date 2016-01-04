INCLUDE_DIR := "-I/home/goncalv/cuda/include -I/usr/include/c++/4.8 -I/usr/include/c++/4.8/x86_64-linux-gnu/ -I/home/goncalv/cuda/samples/common/inc"

LIBS_DIR := "-L/home/goncalv/cuda/lib64 -L/home/goncalv/cuda/samples/common/lib -L."
LIBRARIES:= "-lhookomp -lroofline -fopenmp -lgomp -lffi -ldl -lcuda -lcudart"

all:
	nvcc -O3 -c ${CUFILES} -I${PATH_TO_UTILS} -o ${OBJTFILE} ${INCLUDE_DIR} -DPOLYBENCH_TIME -ccbin=${CXX} -Xcompiler -fpermissive
	${CXX} -g ${OBJTFILE} -o ${EXECUTABLE} -O3 ${LIBS_DIR} ${LIBRARIES}

clean:
	rm -f *~ *.exe

