#!/bin/bash

# cp -R /dados/rogerio/USP/doutorado/prova-de-conceito/testes-prova-conceito/openmp-hook/tests/polybench-acc/openmp-offloading/linear-algebra/kernels/syr2k/output/14-05-2016-23-42-12 output/
# cp -R /dados/rogerio/USP/doutorado/prova-de-conceito/testes-prova-conceito/openmp-hook/tests/polybench-acc/openmp-offloading/linear-algebra/kernels/gemm/output/12-05-2016-05-28-24 output/

# cp -R /dados/rogerio/USP/doutorado/prova-de-conceito/testes-prova-conceito/openmp-hook/tests/polybench-acc/OpenMP/linear-algebra/kernels/gemm/output/12-05-2016-12-26-36 output/
# cp -R /dados/rogerio/USP/doutorado/prova-de-conceito/testes-prova-conceito/openmp-hook/tests/polybench-acc/OpenMP/linear-algebra/kernels/syr2k/output/14-05-2016-22-30-41 output/

./join-omp-omp-off-cuda.sh gemm
# ./join-omp-omp-off-cuda.sh syr2k

for result_file in `ls csv`; do
	echo "csvizing ${result_file}"
	result_file_name=${result_file%.csv}

	./csvize-omp-off-experiments-results.py -i csv/${result_file} -o csv/${result_file_name}-processed.csv
done