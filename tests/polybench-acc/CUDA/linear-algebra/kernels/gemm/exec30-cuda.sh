#!/bin/bash

# recupera o nome do diretorio, que é o nome do benchmark.

benchmark=`basename $PWD`

experiment_date=`date +'%d-%m-%Y-%H-%M-%S'`
OUTPUT=output/${experiment_date}

echo "Executing test for $benchmark, start at `date +'%d/%m/%Y-%T'`"

mkdir -p ${OUTPUT}

for size_of_data in TOY_DATASET MINI_DATASET TINY_DATASET SMALL_DATASET MEDIUM_DATASET STANDARD_DATASET LARGE_DATASET EXTRALARGE_DATASET HUGE_DATASET; do
	echo "Compiling ${benchmark} with dataset: ${size_of_data}"
	make POLYBENCH_OPTIONS="-DPOLYBENCH_TIME -D${size_of_data}"
	mv ${benchmark}-gpu.exe ${benchmark}-dataset-${size_of_data}-gpu.exe
    for ((  i = 1 ;  i <= 10;  i++  ))
	do
       	echo "Execution ${i} of ${benchmark} with dataset: ${size_of_data} start at `date +'%d/%m/%Y-%T'`"
       	echo "Execution = ${i}, benchmark = ${benchmark}, size_of_data = ${size_of_data}," >> ${OUTPUT}/data-${benchmark}-dataset-${size_of_data}-gpu.csv
		./${benchmark}-dataset-${size_of_data}-gpu.exe >> ${OUTPUT}/data-${benchmark}-dataset-${size_of_data}-gpu.csv 2>> ${OUTPUT}/data-${benchmark}-dataset-${size_of_data}-gpu-stderr.csv
	done
done
echo "End of tests at `date +'%d/%m/%Y-%T'`"

NOHUP_FILE="nohup.out"

if [ -f "$NOHUP_FILE" ]
then
	echo "Copy nohup.out to ${OUTPUT}."
	cp $NOHUP_FILE ${OUTPUT}
fi
