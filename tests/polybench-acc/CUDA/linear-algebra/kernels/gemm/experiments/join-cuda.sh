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
            echo "Processing benchmark = ${benchmark}, size_of_data = ${size_of_data}"
            cat ${INPUT}/${experiment_date}/data-${benchmark}-dataset-${size_of_data}-gpu.csv >> ${OUTPUT}/${experiment_date}-joined.csv
        done
    fi
done
echo "End of tests at `date +'%d/%m/%Y-%T'`"
