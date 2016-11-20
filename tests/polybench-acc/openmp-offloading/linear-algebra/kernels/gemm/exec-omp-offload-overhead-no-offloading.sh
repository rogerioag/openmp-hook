#!/bin/bash

ARCH_CODE_NAME=`cat ../../../../../../arch-codename.in`

# Compile the libraries with no offloading:
# make OPTIONS="-DFORCENOOFFLOAD -D[IVY_BRIDGE | SANDY_BRIDGE | NEHALEM]"
cd /home/$USER/prova-de-conceito/testes-prova-conceito/openmp-hook
make OPTIONS="-DFORCENOOFFLOAD -D${ARCH_CODE_NAME}"
cd -

# retrieve the dir name, that is the benchmark name.
benchmark=`basename $PWD`

EXPERIMENT=overhead-no-offloading

experiment_date=`date +'%d-%m-%Y-%H-%M-%S'`

# position of directory (openmp, openmp-offloading, cuda...)
NUM_FIELD=9
# retrieve openmp, openmp-offloading, cuda...
BENCHMARK_TYPE=`pwd | cut -d'/' -f${NUM_FIELD} | tr '[:upper:]' '[:lower:]'`

PREFIX_BENCHMARK=${BENCHMARK_TYPE}

# For resume an experiment.
if [ "$#" -ne 1 ]; then
	echo "Executing a new experiment: "${experiment_date}
	OUTPUT=output/${HOSTNAME}-${BENCHMARK_TYPE}-${EXPERIMENT}-${experiment_date}
else
	echo "Resuming the experiment: "$1
	OUTPUT=output/$1
fi

echo "Executing test for $benchmark, start at `date +'%d/%m/%Y-%T'`"

mkdir -p ${OUTPUT}

for ((  i = 1 ;  i <= 10;  i++  ))
do
	# TOY_DATASET: 32, MINI_DATASET: 64, TINY_DATASET: 128, SMALL_DATASET: 256, MEDIUM_DATASET: 512, STANDARD_DATASET: 1024, LARGE_DATASET: 2048, EXTRALARGE_DATASET: 4096, HUGE_DATASET: 8192
	for size_of_data in STANDARD_DATASET LARGE_DATASET EXTRALARGE_DATASET HUGE_DATASET; do
		for num_threads in 1 2 4 6 8 10 12 14 16 18 20 22 24; do # 24 22 20 18 16 14 12 10 8 6 4 2 1
			for omp_schedule in DYNAMIC; do
				for chunk_size in 32 64 128 256; do
					echo "Compiling ${benchmark} with dataset: ${size_of_data}, schedule: ${omp_schedule}, chunk: ${chunk_size}, threads: ${num_threads}."
					# First exection with sequential code execution.
					# Retirei o -DRUN_ORIG_VERSION.****
					#if [ $i -eq 1 ] 
					#then
					#	# With sequential code execution.
					#	echo "Execution ${i}, compiling with sequential code execution option."
					##	make POLYBENCH_OPTIONS="-DPOLYBENCH_TIME -D${size_of_data}" OMP_CONFIG="-DOPENMP_SCHEDULE_${omp_schedule} -DOPENMP_CHUNK_SIZE=${chunk_size} -DOPENMP_NUM_THREADS=${num_threads} -D${ARCH_CODE_NAME}"
					#	mv ${benchmark}-${PREFIX_BENCHMARK}.exe ${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${chunk_size}-threads-${num_threads}-${PREFIX_BENCHMARK}.exe
					#fi
					# Second execution, compile without sequential execution option.
					if [ $i -ge 1 ]
					then
						# Without -DRUN_ORIG_VERSION.
						echo "Execution ${i}, compiling without sequential code execution option."
						make POLYBENCH_OPTIONS="-DPOLYBENCH_TIME -D${size_of_data}" OMP_CONFIG="-DOPENMP_SCHEDULE_${omp_schedule} -DOPENMP_CHUNK_SIZE=${chunk_size} -DOPENMP_NUM_THREADS=${num_threads} -D${ARCH_CODE_NAME}"
						mv ${benchmark}-${PREFIX_BENCHMARK}.exe ${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${chunk_size}-threads-${num_threads}-${PREFIX_BENCHMARK}.exe
					fi

					echo "Executing..."
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
