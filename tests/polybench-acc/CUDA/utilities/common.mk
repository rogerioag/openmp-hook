all:
	nvcc ${OPT_LEVEL} ${CUFILES} -I${PATH_TO_UTILS} -o ${EXECUTABLE} -DPOLYBENCH_TIME -ccbin=${CXX}
clean:
	rm -f *~ *.exe


