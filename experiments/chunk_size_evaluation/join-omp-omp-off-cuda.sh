#!/bin/bash -xe

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <benchmark>" >&2
  exit 1
fi

benchmark=$1
INPUT=output
OUTPUT=csv

echo "Executing join for $benchmark, start at `date +'%d/%m/%Y-%T'`"

for experiment_date in `ls ${INPUT}`; do
    echo "Experiment: ${experiment_date}"
    if [ -d "${INPUT}/${experiment_date}" ]
    then
        mkdir -p ${OUTPUT}
        echo "" >> ${OUTPUT}/${experiment_date}-joined.csv
        for size_of_data in LARGE_DATASET; do
            for num_threads in 24 22 20 18 16 14 12 10 8 6 4 2 1; do
                for omp_schedule in DYNAMIC; do
                    for chunk_size in 16 32 64 128 256; do
                        echo "Processing ${i} of ${benchmark} with dataset: ${size_of_data}, schedule: ${omp_schedule}, chunk: ${chunk_size}, threads: ${num_threads}."
                        for version in omp offloading-gpu; do
                            # ${INPUT}/${experiment_date}/data-${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${chunk_size}-threads-${num_threads}-${version}.csv
                            if [ -f "${INPUT}/${experiment_date}/data-${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${chunk_size}-threads-${num_threads}-${version}.csv" ]
                            then
                                echo "File: ${experiment_date}/data-${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${chunk_size}-threads-${num_threads}-${version}.csv"
                                cat ${INPUT}/${experiment_date}/data-${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${chunk_size}-threads-${num_threads}-${version}.csv >> ${OUTPUT}/${experiment_date}-joined.csv
                            else
                                echo "${INPUT}/${experiment_date}/data-${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${chunk_size}-threads-${num_threads}-${version}.csv not found."
                            fi
                        done
                    done
                done
            done
        done
    fi
done
echo "End of tests at `date +'%d/%m/%Y-%T'`"
