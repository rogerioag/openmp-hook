#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <benchmark>" >&2
  exit 1
fi

benchmark=$1
INPUT=output
OUTPUT=csv

echo "Executing join for $benchmark, start at `date +'%d/%m/%Y-%T'`"

counter=0

for experiment_date in `ls ${INPUT}`; do
    echo "Experiment: ${experiment_date}"
    if [ -d "${INPUT}/${experiment_date}" ]
    then
        mkdir -p ${OUTPUT}
        echo "" > ${OUTPUT}/${benchmark}-${experiment_date}-joined.csv
        for size_of_data in EXTRALARGE_DATASET LARGE_DATASET STANDARD_DATASET MEDIUM_DATASET SMALL_DATASET TINY_DATASET MINI_DATASET TOY_DATASET; do
			# for num_threads in 24 22 20 18 16 14 12 10 8 6 4 2 1; do
                for num_threads in 1; do
                for omp_schedule in DYNAMIC; do
                    for chunk_size in 16 32 64 128 256 512; do
                        echo "Processing ${i} of ${benchmark} with dataset: ${size_of_data}, schedule: ${omp_schedule}, chunk: ${chunk_size}, threads: ${num_threads}."
                        for version in openmp-offloading; do
                            if [ -f "${INPUT}/${experiment_date}/data-${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${chunk_size}-threads-${num_threads}-${version}-stderr.csv" ]
                            then
                                echo "File: ${INPUT}/${experiment_date}/data-${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${chunk_size}-threads-${num_threads}-${version}-stderr.csv [OK]"
                                counter=$((counter+1))
                                cat ${INPUT}/${experiment_date}/data-${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${chunk_size}-threads-${num_threads}-${version}-stderr.csv | grep -v '^Preparing' | grep -v '^Creating' | grep -v '^Allocating' | grep -v '^Calling' | grep -v '^Declaring' | grep -v '^Printing' | grep -v '^Non-Matching' >> ${OUTPUT}/${benchmark}-${experiment_date}-joined.csv
                            else
                                echo "${INPUT}/${experiment_date}/data-${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${chunk_size}-threads-${num_threads}-${version}-stderr.csv [NOT FOUND]"
                            fi
                        done
                    done
                done
            done
        done
    fi
done
echo Result: $counter " files was processed."
echo "End of process at `date +'%d/%m/%Y-%T'`"
