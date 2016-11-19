#!/bin/bash

# For resume an experiment.
if [ "$#" -ne 5 ]; then
	echo "Uso $0 <dir> <benchmark> <arch> <experiment> <benchmark_type>"
	exit
else
	echo "Verifying the Experiment: "$1
	OUTPUT=$1
fi

# retrieve the dir name, that is the benchmark name.
benchmark=$2

ARCH_CODE_NAME=$3

EXPERIMENT=$4

# retrieve openmp, openmp-offloading, cuda...
BENCHMARK_TYPE=`echo $5 | tr '[:upper:]' '[:lower:]'`

PREFIX_BENCHMARK=${BENCHMARK_TYPE}

echo "Verifying ${OUTPUT}, ${ARCH_CODE_NAME}, ${EXPERIMENT}, ${benchmark}, ${BENCHMARK_TYPE}."

echo "Executing test for $benchmark, start at `date +'%d/%m/%Y-%T'`"

count=0

# TOY_DATASET: 32, MINI_DATASET: 64, TINY_DATASET: 128, SMALL_DATASET: 256, MEDIUM_DATASET: 512, STANDARD_DATASET: 1024, LARGE_DATASET: 2048, EXTRALARGE_DATASET: 4096, HUGE_DATASET: 8192
for size_of_data in TOY_DATASET MINI_DATASET TINY_DATASET SMALL_DATASET MEDIUM_DATASET STANDARD_DATASET LARGE_DATASET EXTRALARGE_DATASET HUGE_DATASET; do
	for num_threads in 24 22 20 18 16 14 12 10 8 6 4 2 1; do
		for omp_schedule in DYNAMIC; do
			for chunk_size in 16 32 64 128 256; do
				echo "Verifying ${benchmark} with dataset: ${size_of_data}, schedule: ${omp_schedule}, chunk: ${chunk_size}, threads: ${num_threads}."
				# for ((  i = 1 ;  i <= 10;  i++  ))
				# do
					((count=count+1))
					# Verify if file exists.					
					if [ -f "${OUTPUT}/data-${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${chunk_size}-threads-${num_threads}-${PREFIX_BENCHMARK}.csv" ]
					then
						#echo " Result file exists. Checking to resume."
						# echo "" > /dev/null
						checksum=`awk '/^exp|version/{a++}END{print a}' ${OUTPUT}/data-${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${chunk_size}-threads-${num_threads}-${PREFIX_BENCHMARK}.csv`
						if [ $checksum -lt 20 ]
						then
							echo "  [$checksum]:data-${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${chunk_size}-threads-${num_threads}-${PREFIX_BENCHMARK}.csv"
						fi	
						# if grep -q "Erro | Morto" ${OUTPUT}/data-${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${chunk_size}-threads-${num_threads}-${PREFIX_BENCHMARK}-stderr.csv; 
						#	then
						#		echo "Re-executing..."
						#		rm ${OUTPUT}/data-${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${chunk_size}-threads-${num_threads}-${PREFIX_BENCHMARK}.csv
						#		rm ${OUTPUT}/data-${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${chunk_size}-threads-${num_threads}-${PREFIX_BENCHMARK}-stderr.csv
						#		echo "Experiment '${EXPERIMENT}', execution ${i} of ${benchmark} with dataset: ${size_of_data}, schedule: ${omp_schedule}, chunk_size: ${chunk_size}, threads: ${num_threads} start at `date +'%d/%m/%Y-%T'`"
						#		echo "Experiment '${EXPERIMENT}', execution ${i} of ${benchmark} with dataset: ${size_of_data}, schedule: ${omp_schedule}, chunk_size: ${chunk_size}, threads: ${num_threads} start at `date +'%d/%m/%Y-%T'`" >> ${OUTPUT}/data-${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${chunk_size}-threads-${num_threads}-${PREFIX_BENCHMARK}-stderr.csv
						#		echo "exp = ${EXPERIMENT}, execution = ${i}, benchmark = ${benchmark}, size_of_data = ${size_of_data}, schedule = ${omp_schedule}, chunk_size = ${chunk_size}, num_threads = ${num_threads}," >> ${OUTPUT}/data-${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${chunk_size}-threads-${num_threads}-${PREFIX_BENCHMARK}.csv
						#		./${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${chunk_size}-threads-${num_threads}-${PREFIX_BENCHMARK}.exe >> ${OUTPUT}/data-${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${chunk_size}-threads-${num_threads}-${PREFIX_BENCHMARK}.csv 2>> ${OUTPUT}/data-${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${chunk_size}-threads-${num_threads}-${PREFIX_BENCHMARK}-stderr.csv
						#	else
						#		echo "Result file OK."
						#	fi
					else
						echo "  [NOK]: data-${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${chunk_size}-threads-${num_threads}-${PREFIX_BENCHMARK}.csv"
					fi
				# done
			done
		done
	done
done
echo Total: ${count} files.
echo "End of tests at `date +'%d/%m/%Y-%T'`"
