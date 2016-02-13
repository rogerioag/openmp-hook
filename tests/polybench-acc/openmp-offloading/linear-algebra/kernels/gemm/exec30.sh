#!/bin/bash

# recupera o nome do diretorio, que é o nome do benchmark.

benchmark=`basename $PWD`

# recupera o nome do diretorio, que é o nome do benchmark.
echo "Executing $benchmark."

for size_of_data in LARGE_DATASET; do
    for num_threads in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24; do
        echo "Compiling ${benchmark} for ${num_threads} threads."

        make POLYBENCH_OPTIONS="-DPOLYBENCH_TIME -D${size_of_data}" OMP_CONFIG="-DOPENMP_SCHEDULE_DYNAMIC -DOPENMP_CHUNK_SIZE=1 -DOPENMP_NUM_THREADS=${num_threads}"

        for ((  i = 1 ;  i <= 30;  i++  ))
        do
            echo "Execution ${i} of ${benchmark} with ${num_threads} threads."
            ./${benchmark}-offloading-gpu.exe >> data.csv
        done
    done
done
echo "End of process."
