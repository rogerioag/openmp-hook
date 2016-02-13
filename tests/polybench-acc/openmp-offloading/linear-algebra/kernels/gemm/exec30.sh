#!/bin/bash -xe

# recupera o nome do diretorio, que é o nome do benchmark.
benchmark=basename `pwd`

# recupera o nome do diretorio, que é o nome do benchmark.
echo "Executing $benchmark."

for ((  i = 1 ;  i <= 30;  i++  ))
do
    for num_threads in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24; do
        echo "Execution ${i} of $benchmark."
        make POLYBENCH_OPTIONS="-DPOLYBENCH_TIME -DLARGE_DATASET" OMP_CONFIG="-DOPENMP_SCHEDULE_DYNAMIC -DOPENMP_CHUNK_SIZE=1 -DOPENMP_NUM_THREADS=${num_threads}"
        ./${benchmark}-offloading-gpu.exe >> data.csv
    done
done

echo "End of process."
