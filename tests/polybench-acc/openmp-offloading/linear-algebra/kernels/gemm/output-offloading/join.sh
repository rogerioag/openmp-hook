#!/bin/bash

# recupera o nome do diretorio, que é o nome do benchmark.

benchmark=gemm

# recupera o nome do diretorio, que é o nome do benchmark.
echo "Joining outputs from $benchmark."

# Delete files generated.
rm data-large_dataset-num_threads-1-a-12-dynamic-chunk_size-16-a-64.csv
rm data-large_dataset-num_threads-1-a-12-dynamic-chunk_size-16-a-64-lib.csv
rm data-large_dataset-num_threads-1-a-12-dynamic-chunk_size-16-a-64-final.csv
rm data-large_dataset-num_threads-1-a-12-dynamic-chunk_size-16-a-64-lib-final.csv

for size_of_data in LARGE_DATASET; do
	for num_threads in 1 2 4 8 10 12; do
		# echo "Processing ${benchmark} with dataset: ${size_of_data}, schedule: ${omp_schedule}, chunk: ${chunk_size}, threads: ${num_threads}."
		for omp_schedule in DYNAMIC; do
			for chunk_size in 16 32 64; do
          		
            		echo "Processing ${i} of ${benchmark} with dataset: ${size_of_data}, schedule: ${omp_schedule}, chunk: ${chunk_size}, threads: ${num_threads}."
            		echo "File: data-${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${chunk_size}-threads-${num_threads}-offloading-gpu.csv"
            		prefix_header='dataset, schedule, chunk_size, threads, '
            		prefix_line_data="${size_of_data}, ${omp_schedule}, ${chunk_size}, ${num_threads}, "

            		# cat data-${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${chunk_size}-threads-${num_threads}-offloading-gpu.csv >> data-large_dataset-num_threads-1-a-12-dynamic-chunk_size-16-a-64.csv
            		sed '/^$/d' data-${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${chunk_size}-threads-${num_threads}-offloading-gpu.csv | sort | grep '^OMP' | sed "s/^/${prefix_line_data}/" > data.csv
            		sed '/^$/d' data-${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${chunk_size}-threads-${num_threads}-offloading-gpu.csv | sort | grep '^exp' | uniq | sed "s/^/${prefix_header}/" > header.csv
					
					cat header.csv >> data-large_dataset-num_threads-1-a-12-dynamic-chunk_size-16-a-64-header.csv
					cat data.csv >> data-large_dataset-num_threads-1-a-12-dynamic-chunk_size-16-a-64-data.csv

					rm header.csv
					rm data.csv


					# cat data-${benchmark}-dataset-${size_of_data}-schedule-${omp_schedule}-chunk-${chunk_size}-threads-${num_threads}-offloading-gpu-stderr.csv >> data-large_dataset-num_threads-1-a-12-dynamic-chunk_size-16-a-64-lib.csv
					
			done
		done
	done

	cat data-large_dataset-num_threads-1-a-12-dynamic-chunk_size-16-a-64-header.csv | uniq > data-large_dataset-num_threads-1-a-12-dynamic-chunk_size-16-a-64-final.csv
	cat data-large_dataset-num_threads-1-a-12-dynamic-chunk_size-16-a-64-data.csv >> data-large_dataset-num_threads-1-a-12-dynamic-chunk_size-16-a-64-final.csv

	# dados da execucao.
	# sed '/^$/d' data-large_dataset-num_threads-1-a-12-dynamic-chunk_size-16-a-64.csv | sort | grep '^OMP' > data.csv
	# sed '/^$/d' data-large_dataset-num_threads-1-a-12-dynamic-chunk_size-16-a-64.csv | sort | grep '^exp' | uniq > header.csv

	# cat header.csv > data-large_dataset-num_threads-1-a-12-dynamic-chunk_size-16-a-64-final.csv
	# cat data.csv >> data-large_dataset-num_threads-1-a-12-dynamic-chunk_size-16-a-64-final.csv

	# rm header.csv
	# rm data.csv

	# saida da biblioteca.
	# cat data-large_dataset-num_threads-1-a-12-dynamic-chunk_size-16-a-64-lib.csv | grep -E '^([1-9][0-9]?[0-9]?[0-9]|[0-9])\b' > data.csv
	# sed '/^$/d' data-large_dataset-num_threads-1-a-12-dynamic-chunk_size-16-a-64-lib.csv | sort | grep '^oi_cpu' | uniq > header.csv

	# cat header.csv > data-large_dataset-num_threads-1-a-12-dynamic-chunk_size-16-a-64-lib-final.csv
	# cat data.csv >> data-large_dataset-num_threads-1-a-12-dynamic-chunk_size-16-a-64-lib-final.csv

	# rm header.csv
	# rm data.csv

done
echo "End of process."
