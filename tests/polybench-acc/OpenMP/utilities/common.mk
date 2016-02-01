INCPATHS = -I$(UTIL_DIR)

BENCHMARK = $(shell basename `pwd`)
EXE = $(BENCHMARK)_omp
SRC = $(BENCHMARK).c
HEADERS = $(BENCHMARK).h

SRC += $(UTIL_DIR)/polybench.c

DEPS        := Makefile.dep
DEP_FLAG    := -MM

.PHONY: all exe clean veryclean

all : exe

exe : $(EXE)

$(EXE) : $(SRC)
	# $(ACC) $(ACCFLAGS) $(CC) $(CFLAGS) $(INCPATHS) $^ -o $@
	$(CC) $(POLYBENCH_OPTIONS) $(CFLAGS) $(OMP_CONFIG) $(INCPATHS) $^ -o $@

clean :
	-rm -vf __hmpp* -vf $(EXE) *~ rm *.exe Makefile.dep

veryclean : clean
	-rm -vf $(DEPS)

info:
	@echo "Use:"
	@echo "make POLYBENCH_OPTIONS=\"-DPOLYBENCH_TIME -DEXTRALARGE_DATASET\" OMP_CONFIG=\" -DOPENMP_SCHEDULE_RUNTIME -DOPENMP_CHUNK_SIZE=64 -DOPENMP_NUM_THREADS=24\""
	@echo "make POLYBENCH_OPTIONS=\"-DPOLYBENCH_TIME -DEXTRALARGE_DATASET\" OMP_CONFIG=\" -DOPENMP_SCHEDULE_DYNAMIC -DOPENMP_CHUNK_SIZE=64 -DOPENMP_NUM_THREADS=24\""
	@echo "make POLYBENCH_OPTIONS=\"-DPOLYBENCH_TIME -DEXTRALARGE_DATASET\" OMP_CONFIG=\" -DOPENMP_SCHEDULE_GUIDED -DOPENMP_CHUNK_SIZE=64 -DOPENMP_NUM_THREADS=24\""


$(DEPS): $(SRC) $(HEADERS)
	$(CC) $(INCPATHS) $(DEP_FLAG) $(SRC) > $(DEPS)

-include $(DEPS)

