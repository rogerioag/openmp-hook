OPENMP_HOOK_PATH=/home/${USER}/prova-de-conceito/testes-prova-conceito/openmp-hook
CUDA_HOME=/home/${USER}/cuda

INCLUDE_DIR := -I${OPENMP_HOOK_PATH} -I${CUDA_HOME}/include -I/usr/include/c++/4.8 -I/usr/include/c++/4.8/x86_64-linux-gnu/ -I/usr/include/c++/4.8/ -I${CUDA_HOME}/samples/common/inc

LIBS_DIR := -L${OPENMP_HOOK_PATH} -L${CUDA_HOME}/lib64 -L${CUDA_HOME}/samples/common/lib -L${CUDA_HOME}/lib64/stubs -L . -L ../../../../../../
LIBRARIES:= -lhookomp -lroofline -fopenmp -lgomp -lffi -ldl -lcuda -lcudart

all:
	${NVCC} ${OPT_LEVEL} -c ${CUFILES} -I${PATH_TO_UTILS} ${INCLUDE_DIR} ${POLYBENCH_OPTIONS} ${OMP_CONFIG} -ccbin=${CXX} -Xcompiler -lhookomp -Xcompiler -lroofline -Xcompiler -fopenmp -Xcompiler -lgomp -Xcompiler -fpermissive -Xcompiler -lffi -Xcompiler -ldl -o ${OBJFILE} 

	${CXX} -g ${OBJFILE} ${OPT_LEVEL} ${LIBS_DIR} ${LIBRARIES} -o ${EXECUTABLE}

clean:
	rm -f *~ *.o *.exe

info:
	@echo "Use:"
	@echo "make POLYBENCH_OPTIONS=\"-DPOLYBENCH_TIME -DEXTRALARGE_DATASET\" OMP_CONFIG=\"-DOPENMP_SCHEDULE_RUNTIME -DOPENMP_CHUNK_SIZE=64 -DOPENMP_NUM_THREADS=24 -D[IVY_BRIDGE | SANDY_BRIDGE | NEHALEM]\""
	@echo "make POLYBENCH_OPTIONS=\"-DPOLYBENCH_TIME -DEXTRALARGE_DATASET\" OMP_CONFIG=\"-DOPENMP_SCHEDULE_DYNAMIC -DOPENMP_CHUNK_SIZE=64 -DOPENMP_NUM_THREADS=24 -D[IVY_BRIDGE | SANDY_BRIDGE | NEHALEM]\""
	@echo "make POLYBENCH_OPTIONS=\"-DPOLYBENCH_TIME -DEXTRALARGE_DATASET\" OMP_CONFIG=\"-DOPENMP_SCHEDULE_GUIDED -DOPENMP_CHUNK_SIZE=64 -DOPENMP_NUM_THREADS=24 -D[IVY_BRIDGE | SANDY_BRIDGE | NEHALEM]\""
	@echo "Use the option -DRUN_ORIG_VERSION to run the sequential version."
	@echo "Choose the data size:"
	@echo "-DTOY_DATASET: 32, -DMINI_DATASET: 64, -DTINY_DATASET: 128, -DSMALL_DATASET: 256, -DMEDIUM_DATASET: 512, -DSTANDARD_DATASET: 1024, -DLARGE_DATASET: 2048, -DEXTRALARGE_DATASET: 4096, -DHUGE_DATASET: 8192"
