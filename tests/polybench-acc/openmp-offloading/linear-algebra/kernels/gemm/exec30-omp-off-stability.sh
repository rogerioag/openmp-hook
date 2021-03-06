#!/bin/bash

# recupera o nome do diretorio, que é o nome do benchmark.

benchmark=`basename $PWD`

experiment_date=`date +'%d-%m-%Y-%H-%M-%S'`
OUTPUT=output/${experiment_date}

echo "Executing test for $benchmark, start at `date +'%d/%m/%Y-%T'`"

mkdir -p ${OUTPUT}

for size_of_data in SMALL_DATASET MEDIUM_DATASET STANDARD_DATASET LARGE_DATASET; do
	for num_threads in 1; do
		echo "Compiling ${benchmark} with dataset: ${size_of_data}, schedule: ${omp_schedule}, chunk: ${chunk_size}, threads: ${num_threads}."
		for omp_schedule in DYNAMIC; do
			for chunk_size in 64; do
				make POLYBENCH_OPTIONS="-DPOLYBENCH_TIME -D${size_of_data}" OMP_CONFIG="-DOPENMP_SCHEDULE_${omp_schedule} -DOPENMP_CHUNK_SIZE=${chunk_size} -DOPENMP_NUM_THREADS=${num_threads}"
				mv ${benchmark}-offloading-gpu.exe ${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${chunk_size}-threads-${num_threads}-offloading-gpu.exe
          			for ((  i = 1 ;  i <= 100;  i++  ))
				do
            		echo "Execution ${i} of ${benchmark} with dataset: ${size_of_data}, schedule: ${omp_schedule}, chunk: ${chunk_size}, threads: ${num_threads} start at `date +'%d/%m/%Y-%T'`"
					echo "Execution = ${i}, benchmark = ${benchmark}, size_of_data = ${size_of_data}, schedule = ${omp_schedule}, chunk_size = ${chunk_size}, num_threads = ${num_threads}," >> ${OUTPUT}/data-${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${chunk_size}-threads-${num_threads}-offloading-gpu.csv
					./${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${chunk_size}-threads-${num_threads}-offloading-gpu.exe >> ${OUTPUT}/data-${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${chunk_size}-threads-${num_threads}-offloading-gpu.csv 2>> ${OUTPUT}/data-${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${chunk_size}-threads-${num_threads}-offloading-gpu-stderr.csv
				done
			done
		done
	done
done
echo "End of tests at `date +'%d/%m/%Y-%T'`"

NOHUP_FILE="nohup.out"

if [ -f "$NOHUP_FILE" ]
then
	echo "Copy nohup.out to ${OUTPUT}."
	cp $NOHUP_FILE ${OUTPUT}
fi
