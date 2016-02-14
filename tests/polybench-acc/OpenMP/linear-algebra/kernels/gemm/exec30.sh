#!/bin/bash

# recupera o nome do diretorio, que é o nome do benchmark.

benchmark=`basename $PWD`

# recupera o nome do diretorio, que é o nome do benchmark.
echo "Executing $benchmark."

for size_of_data in LARGE_DATASET; do
    for num_threads in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24; do
        echo "Compiling ${benchmark} for ${num_threads} threads."
        for omp_schedule in DYNAMIC; do
        	for chunk_size in 1; do
        		make POLYBENCH_OPTIONS="-DPOLYBENCH_TIME -D${size_of_data}" OMP_CONFIG="-DOPENMP_SCHEDULE_${omp_schedule} -DOPENMP_CHUNK_SIZE=${chunk_size} -DOPENMP_NUM_THREADS=${num_threads}"
        		mv ${benchmark}_omp.exe ${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${chunk_size}-threads-${num_threads}-omp.exe

        		for ((  i = 1 ;  i <= 30;  i++  ))
        		do
            		echo "Execution ${i} of ${benchmark} with dataset: ${size_of_data}, schedule: ${omp_schedule}, chunk: ${chunk_size}, threads: ${num_threads}."
            		${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${chunk_size}-threads-${num_threads}-omp.exe >> data-${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${chunk_size}-threads-${num_threads}-omp.csv
        		done
        	done
        done
    done
done
echo "End of process."

