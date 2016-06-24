INCPATHS = -I$(UTIL_DIR) -I/home/goncalv/prova-de-conceito/testes-prova-conceito/openmp-hook

BENCHMARK = $(shell basename `pwd`)
# position of diretory (openmp, openmp-offloading, cuda...)
NUM_FIELD = 9
# retrieve openmp, openmp-offloading, cuda...
BENCHMARK_TYPE = $(shell pwd | cut -d'/' -f${NUM_FIELD} | tr '[:upper:]' '[:lower:]')
EXE = ${BENCHMARK}-${BENCHMARK_TYPE}.exe

SRC = $(BENCHMARK).c
HEADERS = $(BENCHMARK).h

SRC += $(UTIL_DIR)/polybench.c

DEPS        := Makefile.dep
DEP_FLAG    := -MM

.PHONY: all exe clean veryclean

all : exe

exe : clean $(EXE)

$(EXE) : $(SRC)
	# $(ACC) $(ACCFLAGS) $(CC) $(CFLAGS) $(INCPATHS) $^ -o $@
	$(CC) $(POLYBENCH_OPTIONS) $(CFLAGS) $(OMP_CONFIG) $(INCPATHS) $^ -o $@

clean :
	-rm -vf __hmpp* -vf $(EXE) *~ rm *.exe Makefile.dep

veryclean : clean
	-rm -vf $(DEPS)

info:
	@echo "Use:"
	@echo "make POLYBENCH_OPTIONS=\"-DPOLYBENCH_TIME -DEXTRALARGE_DATASET\" OMP_CONFIG=\"-DOPENMP_SCHEDULE_RUNTIME -DOPENMP_CHUNK_SIZE=64 -DOPENMP_NUM_THREADS=24\""
	@echo "make POLYBENCH_OPTIONS=\"-DPOLYBENCH_TIME -DEXTRALARGE_DATASET\" OMP_CONFIG=\"-DOPENMP_SCHEDULE_DYNAMIC -DOPENMP_CHUNK_SIZE=64 -DOPENMP_NUM_THREADS=24\""
	@echo "make POLYBENCH_OPTIONS=\"-DPOLYBENCH_TIME -DEXTRALARGE_DATASET\" OMP_CONFIG=\"-DOPENMP_SCHEDULE_GUIDED -DOPENMP_CHUNK_SIZE=64 -DOPENMP_NUM_THREADS=24\""
	@echo "TOY_DATASET: 32, MINI_DATASET: 64, TINY_DATASET: 128, SMALL_DATASET: 256, MEDIUM_DATASET: 512, STANDARD_DATASET: 1024, LARGE_DATASET: 2048, EXTRALARGE_DATASET: 4096, HUGE_DATASET: 8192"


$(DEPS): $(SRC) $(HEADERS)
	$(CC) $(INCPATHS) $(DEP_FLAG) $(SRC) > $(DEPS)

-include $(DEPS)

