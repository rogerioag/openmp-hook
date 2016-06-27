#!/bin/bash

benchmark=gemm
INPUT=output
OUTPUT=csv

echo "Executing join for $benchmark, start at `date +'%d/%m/%Y-%T'`"

for experiment_date in `ls ${INPUT}`; do
    echo "Experiment: ${experiment_date}"
    if [ -d "${INPUT}/${experiment_date}" ]
    then
        mkdir -p ${OUTPUT}
        echo "" > ${OUTPUT}/${experiment_date}-joined.csv
        # for size_of_data in TOY_DATASET MINI_DATASET TINY_DATASET SMALL_DATASET MEDIUM_DATASET STANDARD_DATASET LARGE_DATASET EXTRALARGE_DATASET; do
        for size_of_data in TOY_DATASET MINI_DATASET TINY_DATASET SMALL_DATASET MEDIUM_DATASET STANDARD_DATASET LARGE_DATASET; do
            for num_threads in 1 2 4 8 10 12 16 18 20 22 24; do
                for omp_schedule in DYNAMIC; do
                    for chunk_size in 16 32 64; do
                        echo "Processing ${i} of ${benchmark} with dataset: ${size_of_data}, schedule: ${omp_schedule}, chunk: ${chunk_size}, threads: ${num_threads}."
                        echo "File: ${experiment_date}/data-${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${chunk_size}-threads-${num_threads}-omp.csv"
                        cat ${INPUT}/${experiment_date}/data-${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${chunk_size}-threads-${num_threads}-omp.csv >> ${OUTPUT}/${experiment_date}-joined.csv
                    done
                done
            done
        done
    fi
done
echo "End of tests at `date +'%d/%m/%Y-%T'`"
