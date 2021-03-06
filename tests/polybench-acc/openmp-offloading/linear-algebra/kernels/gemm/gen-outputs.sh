#!/bin/bash -xe

benchmark=`basename $PWD`

for num_threads in 1 2 4 8 12 16 24; do
	echo "Executing test with ${num_threads} threads."
	make POLYBENCH_OPTIONS="-DPOLYBENCH_TIME -DLARGE_DATASET" OMP_CONFIG="-DOPENMP_SCHEDULE_DYNAMIC -DOPENMP_CHUNK_SIZE=32 -DOPENMP_NUM_THREADS=${num_threads}"
	./${benchmark}-offloading-gpu.exe 2> output-${benchmark}-${num_threads}-threads.txt > output-${benchmark}-${num_threads}-threads.txt
done

echo "End of process."
