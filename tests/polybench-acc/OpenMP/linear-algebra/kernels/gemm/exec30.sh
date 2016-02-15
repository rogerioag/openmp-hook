#!/bin/bash

# recupera o nome do diretorio, que é o nome do benchmark.

benchmark=`basename $PWD`

# recupera o nome do diretorio, que é o nome do benchmark.
echo "Executing $benchmark."

for size_of_data in LARGE_DATASET; do
    for num_threads in 64 32 24 22 20 18 16 12 8 4 2 1; do
        echo "Compiling ${benchmark} with dataset: ${size_of_data}, schedule: ${omp_schedule}, chunk: ${chunk_size}, threads: ${num_threads}."
        for omp_schedule in DYNAMIC; do
            for chunk_size in 32 64 128; do
                make POLYBENCH_OPTIONS="-DPOLYBENCH_TIME -D${size_of_data}" OMP_CONFIG="-DOPENMP_SCHEDULE_${omp_schedule} -DOPENMP_CHUNK_SIZE=${chunk_size} -DOPENMP_NUM_THREADS=${num_threads}"
       		mv ${benchmark}_omp.exe ${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${chunk_size}-threads-${num_threads}-omp.exe

       		for ((  i = 1 ;  i <= 10;  i++  ))
       		do
			echo "Execution ${i} of ${benchmark} with dataset: ${size_of_data}, schedule: ${omp_schedule}, chunk: ${chunk_size}, threads: ${num_threads}."
           		./${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${chunk_size}-threads-${num_threads}-omp.exe >> data-${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${chunk_size}-threads-${num_threads}-omp.csv
     		done
    	     done
        done
    done
done
echo "End of process."
