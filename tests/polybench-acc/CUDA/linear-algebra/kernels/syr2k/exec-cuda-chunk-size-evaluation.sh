#!/bin/bash

# recupera o nome do diretorio, que é o nome do benchmark.

benchmark=`basename $PWD`

experiment_date=`date +'%d-%m-%Y-%H-%M-%S'`
OUTPUT=output/${experiment_date}

# position of directory (openmp, openmp-offloading, cuda...)
NUM_FIELD=9
# retrieve openmp, openmp-offloading, cuda...
BENCHMARK_TYPE=`pwd | cut -d'/' -f${NUM_FIELD} | tr '[:upper:]' '[:lower:]'`

PREFIX_BENCHMARK=${BENCHMARK_TYPE}

EXPERIMENT=chunk_size_evaluation

echo "Executing test for $benchmark, start at `date +'%d/%m/%Y-%T'`"

mkdir -p ${OUTPUT}

# for size_of_data in TOY_DATASET MINI_DATASET TINY_DATASET SMALL_DATASET MEDIUM_DATASET STANDARD_DATASET LARGE_DATASET EXTRALARGE_DATASET; do
for size_of_data in LARGE_DATASET; do
	for num_threads in 1; do		
		for omp_schedule in NONE; do
			for chunk_size in 0; do
				echo "Compiling ${benchmark} with dataset: ${size_of_data}, schedule: ${omp_schedule}, chunk: ${chunk_size}, threads: ${num_threads}."
				make POLYBENCH_OPTIONS="-DPOLYBENCH_TIME -D${size_of_data}" OMP_CONFIG="-DOPENMP_SCHEDULE_${omp_schedule} -DOPENMP_CHUNK_SIZE=${chunk_size} -DOPENMP_NUM_THREADS=${num_threads}"
				mv ${benchmark}-${PREFIX_BENCHMARK}.exe ${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${chunk_size}-threads-${num_threads}-${PREFIX_BENCHMARK}.exe
				for ((  i = 1 ;  i <= 10;  i++  ))
				do
					echo "Experiment '${EXPERIMENT}', execution ${i} of ${benchmark} with dataset: ${size_of_data}, schedule: ${omp_schedule}, chunk_size: ${chunk_size}, threads: ${num_threads} start at `date +'%d/%m/%Y-%T'`"
					echo "Experiment '${EXPERIMENT}', execution ${i} of ${benchmark} with dataset: ${size_of_data}, schedule: ${omp_schedule}, chunk_size: ${chunk_size}, threads: ${num_threads} start at `date +'%d/%m/%Y-%T'`" >> ${OUTPUT}/data-${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${chunk_size}-threads-${num_threads}-${PREFIX_BENCHMARK}-stderr.csv
					echo "exp = ${EXPERIMENT}, execution = ${i}, benchmark = ${benchmark}, size_of_data = ${size_of_data}, schedule = ${omp_schedule}, chunk_size = ${chunk_size}, num_threads = ${num_threads}," >> ${OUTPUT}/data-${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${chunk_size}-threads-${num_threads}-${PREFIX_BENCHMARK}.csv
					./${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${chunk_size}-threads-${num_threads}-${PREFIX_BENCHMARK}.exe >> ${OUTPUT}/data-${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${chunk_size}-threads-${num_threads}-${PREFIX_BENCHMARK}.csv 2>> ${OUTPUT}/data-${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${chunk_size}-threads-${num_threads}-${PREFIX_BENCHMARK}-stderr.csv
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
