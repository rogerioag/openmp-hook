INCLUDE_DIR := -I/home/goncalv/prova-de-conceito/testes-prova-conceito/openmp-hook -I/home/goncalv/cuda/include -I/usr/include/c++/4.8 -I/usr/include/c++/4.8/x86_64-linux-gnu/ -I/home/goncalv/cuda/samples/common/inc

LIBS_DIR := -L/home/goncalv/prova-de-conceito/testes-prova-conceito/openmp-hook -L/home/goncalv/cuda/lib64 -L/home/goncalv/cuda/samples/common/lib -L . -L ../../../../../../
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
	@echo "MINI_DATASET:32, SMALL_DATASET:128, STANDARD_DATASET:1024, LARGE_DATASET:2000, EXTRALARGE_DATASET:4000"