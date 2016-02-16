#!/bin/bash

# recupera o nome do diretorio, que é o nome do benchmark.

benchmark=`basename $PWD`

# recupera o nome do diretorio, que é o nome do benchmark.
echo "Executing $benchmark."

for size_of_data in LARGE_DATASET; do
	for num_threads in 1 2 4 8 10 12; do
		echo "Compiling ${benchmark} with dataset: ${size_of_data}, schedule: ${omp_schedule}, chunk: ${chunk_size}, threads: ${num_threads}."
		for omp_schedule in DYNAMIC; do
			for chunk_size in 16 32 64; do
				make POLYBENCH_OPTIONS="-DPOLYBENCH_TIME -D${size_of_data}" OMP_CONFIG="-DOPENMP_SCHEDULE_${omp_schedule} -DOPENMP_CHUNK_SIZE=${chunk_size} -DOPENMP_NUM_THREADS=${num_threads}"
				mv ${benchmark}-offloading-gpu.exe ${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${chunk_size}-threads-${num_threads}-offloading-gpu.exe
          		for ((  i = 1 ;  i <= 10;  i++  ))
				do
            		echo "Execution ${i} of ${benchmark} with dataset: ${size_of_data}, schedule: ${omp_schedule}, chunk: ${chunk_size}, threads: ${num_threads}."
					./${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${chunk_size}-threads-${num_threads}-offloading-gpu.exe >> data-${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${chunk_size}-threads-${num_threads}-offloading-gpu.csv 2>> data-${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${chunk_size}-threads-${num_threads}-offloading-gpu-stderr.csv
				done
			done
		done
	done
done
echo "End of process."
