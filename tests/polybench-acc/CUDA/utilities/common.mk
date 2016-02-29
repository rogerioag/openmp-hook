all:
	${NVCC} ${OPT_LEVEL} ${CUFILES} -I${PATH_TO_UTILS} ${INCLUDE_DIR} ${POLYBENCH_OPTIONS} -ccbin=${CXX} -o ${EXECUTABLE}
clean:
	rm -f *~ *.exe

 

