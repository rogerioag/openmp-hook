#!/bin/bash

# recupera o nome do diretorio, que é o nome do benchmark.

benchmark=`basename $PWD`

# recupera o nome do diretorio, que é o nome do benchmark.
echo "Executing testing $benchmark."

for size_of_data in EXTRALARGE_DATASET; do
	for num_threads in 1 2 4 8 12 16 24; do
		echo "Compiling ${benchmark} with dataset: ${size_of_data}, schedule: ${omp_schedule}, chunk: ${chunk_size}, threads: ${num_threads}."
		ft_num_threads=`echo $num_threads | awk '{printf ("%03i", $1)}'`
		echo "teste: $ft_num_threads"
		for omp_schedule in DYNAMIC; do
			for chunk_size in 16 32 64 128; do
				make POLYBENCH_OPTIONS="-DPOLYBENCH_TIME -D${size_of_data}" OMP_CONFIG="-DOPENMP_SCHEDULE_${omp_schedule} -DOPENMP_CHUNK_SIZE=${chunk_size} -DOPENMP_NUM_THREADS=${num_threads}"
				ft_chunk_size=`echo $chunk_size | awk '{printf ("%03i", $1)}'`
				mv ${benchmark}-offloading-gpu.exe ${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${ft_chunk_size}-threads-${ft_num_threads}-offloading-gpu.exe
            			echo "Execution ${i} of ${benchmark} with dataset: ${size_of_data}, schedule: ${omp_schedule}, chunk: ${chunk_size}, threads: ${num_threads}."
				./${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${ft_chunk_size}-threads-${ft_num_threads}-offloading-gpu.exe 2> output-${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${ft_chunk_size}-threads-${ft_num_threads}-offloading-gpu.txt
			done
		done
	done
done
echo "End of process."
