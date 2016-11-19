#!/bin/bash -xe

# /dados/rogerio/USP/doutorado/prova-de-conceito/testes-prova-conceito/openmp-hook/experiments/all-data-sizes-and-chunk-sizes-evaluation/csv/pilipili2/gemm-pilipili2-cuda-all-data-sizes-and-chunk-sizes-evaluation-12-11-2016-17-49-49-joined-processed.csv
# /dados/rogerio/USP/doutorado/prova-de-conceito/testes-prova-conceito/openmp-hook/experiments/all-data-sizes-and-chunk-sizes-evaluation/csv/pilipili2/gemm-pilipili2-omp-all-data-sizes-and-chunk-sizes-evaluation-11-08-2016-18-44-48-joined-processed.csv

# gemm-pilipili2-cuda-all-data-sizes-and-chunk-sizes-evaluation-12-11-2016-17-49-49-joined-processed-and-gemm-pilipili2-omp-all-data-sizes-and-chunk-sizes-evaluation-11-08-2016-18-44-48-joined-processed.csv

concat_names=""
for result_file in `ls *-joined-processed.csv | cut -d'/' -f2`; do
	echo "processing ${result_file}"
	result_file_name=${result_file%-joined-processed.csv}
	concat_names+=${result_file_name}
	concat_names+="#"
	header=`head -n 1 ${result_file}`
	num_lines=`cat ${result_file} | wc -l`
	((num_lines=num_lines-1))

	tail -n ${num_lines} ${result_file} >> temp.csv
done
final_name=`echo ${concat_names} | cut -d'#' -f1-2 | sed 's/#/-and-/g'`
echo ${header} > ${final_name}-joined-processed-final.csv
cat temp.csv >> ${final_name}-joined-processed-final.csv
rm temp.csv
