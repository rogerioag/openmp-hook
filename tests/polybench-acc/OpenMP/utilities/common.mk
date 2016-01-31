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
	$(CC) $(CFLAGS) $(INCPATHS) $^ -o $@

clean :
	-rm -vf __hmpp* -vf $(EXE) *~ 

veryclean : clean
	-rm -vf $(DEPS)

$(DEPS): $(SRC) $(HEADERS)
	$(CC) $(INCPATHS) $(DEP_FLAG) $(SRC) > $(DEPS)

-include $(DEPS)

gen-tests:
	for schedule in RUNTIME DYNAMIC GUIDED ; do \
		for number_of_threads in 1 2 4 8 16 24 ; do \
        	echo Compiling...: $$schedule-$$number_of_threads ; \
        	$(CC) $(CFLAGS) $(INCPATHS) $^ -DOPENMP_SCHEDULE_$$schedule -DOPENMP_CHUNK_SIZE=64 -DOPENMP_NUM_THREADS=$$number_of_threads -o teste-$$schedule-$$number_of_threads.exe ; \
    	done \
	done

exec-tests:
	mkdir output
	for schedule in RUNTIME DYNAMIC GUIDED ; do \
		for number_of_threads in 1 2 4 8 16 24 ; do \
        	echo Executing...: $$schedule-$$number_of_threads ; \
        	mkdir -p output/$$number_of_threads; \
        	for execution in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 ; do \
        		echo Execution...: $$execution ; \
        		./teste-$$schedule-$$number_of_threads.exe > output/$$number_of_threads/teste-$$schedule-$$number_of_threads-output-$$execution.txt; \
        	done \
    	done \
	done

clean:
	rm *.exe