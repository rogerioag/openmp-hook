OPENMP_HOOK_PATH=/home/${USER}/prova-de-conceito/testes-prova-conceito/openmp-hook
CUDA_HOME=/home/${USER}/cuda

INCLUDE_DIR := -I${OPENMP_HOOK_PATH} -I${CUDA_HOME}/include -I/usr/include/c++/4.8 -I/usr/include/c++/4.8/x86_64-linux-gnu/ -I/usr/include/c++/4.8/ -I${CUDA_HOME}/samples/common/inc

LIBS_DIR := -L${OPENMP_HOOK_PATH} -L${CUDA_HOME}/lib64 -L${CUDA_HOME}/samples/common/lib -L . -L ../../../../../../
LIBRARIES:= -lhookomp -lroofline -fopenmp -lgomp -lffi -ldl -lcuda -lcudart

all:
	${NVCC} ${OPT_LEVEL} -c ${CUFILES} -I${PATH_TO_UTILS} ${INCLUDE_DIR} ${POLYBENCH_OPTIONS} ${OMP_CONFIG} -ccbin=${CXX} -Xcompiler -lhookomp -Xcompiler -lroofline -Xcompiler -fopenmp -Xcompiler -lgomp -Xcompiler -fpermissive -Xcompiler -lffi -Xcompiler -ldl -o ${OBJFILE} 

	${CXX} -g ${OBJFILE} ${OPT_LEVEL} ${LIBS_DIR} ${LIBRARIES} -o ${EXECUTABLE}

clean:
	rm -f *~ *.o *.exe

info:
	@echo "Use:"
	@echo "make POLYBENCH_OPTIONS=\"-DPOLYBENCH_TIME -DEXTRALARGE_DATASET\" OMP_CONFIG=\"-DOPENMP_SCHEDULE_RUNTIME -DOPENMP_CHUNK_SIZE=64 -DOPENMP_NUM_THREADS=24\""
	@echo "make POLYBENCH_OPTIONS=\"-DPOLYBENCH_TIME -DEXTRALARGE_DATASET\" OMP_CONFIG=\"-DOPENMP_SCHEDULE_DYNAMIC -DOPENMP_CHUNK_SIZE=64 -DOPENMP_NUM_THREADS=24\""
	@echo "make POLYBENCH_OPTIONS=\"-DPOLYBENCH_TIME -DEXTRALARGE_DATASET\" OMP_CONFIG=\"-DOPENMP_SCHEDULE_GUIDED -DOPENMP_CHUNK_SIZE=64 -DOPENMP_NUM_THREADS=24\""
	@echo "TOY_DATASET: 32, MINI_DATASET: 64, TINY_DATASET: 128, SMALL_DATASET: 256, MEDIUM_DATASET: 512, STANDARD_DATASET: 1024, LARGE_DATASET: 2048, EXTRALARGE_DATASET: 4096, HUGE_DATASET: 8192"
