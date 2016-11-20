# Como os gráficos foram gerados para a comparação da execução de OpenMP e CUDA.

# Para mostrar quando que o offloading deve ser feito.
# Se executar no CUDA é mais rápido, o runtime deve decidir por isso no openmp-offloading.

# Experimento: all-data-sizes-and-chunk-sizes-evaluation-openmp-vs-openmp-offloading

# Arquivos utilizados foram organizados nos diretórios.

pilipili2-omp-all-data-sizes-and-chunk-sizes-evaluation-11-08-2016-18-44-48

pilipili2-openmp-offloading-all-data-sizes-and-chunk-sizes-evaluation-17-11-2016-13-15-25


ragserver-omp-all-data-sizes-and-chunk-sizes-evaluation-09-11-2016-12-16-41

ragserver-openmp-offloading-all-data-sizes-and-chunk-sizes-evaluation-17-11-2016-02-32-35

# Acesso ao diretório.
cd /dados/rogerio/USP/doutorado/prova-de-conceito/testes-prova-conceito/openmp-hook/experiments/all-data-sizes-and-chunk-sizes-evaluation-openmp-vs-openmp-offloading

# Faz o join de todos os arquivos no diretório out.
./join-omp-omp-off-cuda.sh gemm

# Gerou os arquivos em csv.
ls csv
gemm-pilipili2-omp-all-data-sizes-and-chunk-sizes-evaluation-11-08-2016-18-44-48-joined.csv
gemm-pilipili2-openmp-offloading-all-data-sizes-and-chunk-sizes-evaluation-17-11-2016-13-15-25-joined.csv
gemm-ragserver-omp-all-data-sizes-and-chunk-sizes-evaluation-09-11-2016-12-16-41-joined.csv
gemm-ragserver-openmp-offloading-all-data-sizes-and-chunk-sizes-evaluation-17-11-2016-02-32-35-joined.csv

# Transforma em csv os resultados do pilipili2:

./csvize-omp-off-experiments-results.py -i csv/gemm-pilipili2-omp-all-data-sizes-and-chunk-sizes-evaluation-11-08-2016-18-44-48-joined.csv -o csv/gemm-pilipili2-omp-all-data-sizes-and-chunk-sizes-evaluation-11-08-2016-18-44-48-joined-processed.csv
 
./csvize-omp-off-experiments-results.py -i csv/gemm-pilipili2-openmp-offloading-all-data-sizes-and-chunk-sizes-evaluation-17-11-2016-13-15-25-joined.csv -o csv/gemm-pilipili2-openmp-offloading-all-data-sizes-and-chunk-sizes-evaluation-17-11-2016-13-15-25-joined-processed.csv

mkdir -p csv/pilipili2/
cp csv/gemm-pilipili2-*-joined*.csv csv/pilipili2/

# Merge dos dois arquivos:
# Arquivo CUDA: gemm-pilipili2-openmp-offloading-all-data-sizes-and-chunk-sizes-evaluation-17-11-2016-13-15-25-joined-processed.csv
# Arquivo OMP: gemm-pilipili2-omp-all-data-sizes-and-chunk-sizes-evaluation-11-08-2016-18-44-48-joined-processed.csv

cd csv/pilipili2
./merge.sh

# Arquivo final:
gemm-pilipili2-omp-all-data-sizes-and-chunk-sizes-evaluation-11-08-2016-18-44-48-and-gemm-pilipili2-openmp-offloading-all-data-sizes-and-chunk-sizes-evaluation-17-11-2016-13-15-25-joined-processed-final.csv


# Volta no diretorio do experimento.
cd /dados/rogerio/USP/doutorado/prova-de-conceito/testes-prova-conceito/openmp-hook/experiments/all-data-sizes-and-chunk-sizes-evaluation-openmp-vs-openmp-offloading


# Transforma em csv os resultados do ragserver: 

./csvize-omp-off-experiments-results.py -i csv/gemm-ragserver-omp-all-data-sizes-and-chunk-sizes-evaluation-09-11-2016-12-16-41-joined.csv -o csv/gemm-ragserver-omp-all-data-sizes-and-chunk-sizes-evaluation-09-11-2016-12-16-41-joined-processed.csv
 
./csvize-omp-off-experiments-results.py -i csv/gemm-ragserver-openmp-offloading-all-data-sizes-and-chunk-sizes-evaluation-17-11-2016-02-32-35-joined.csv -o csv/gemm-ragserver-openmp-offloading-all-data-sizes-and-chunk-sizes-evaluation-17-11-2016-02-32-35-joined-processed.csv

mkdir -p csv/ragserver/
cp csv/gemm-ragserver-*-joined*.csv csv/ragserver/

# Merge dos dois arquivos:
# Arquivo CUDA: gemm-ragserver-openmp-offloading-all-data-sizes-and-chunk-sizes-evaluation-17-11-2016-02-32-35-joined-processed.csv
# Arquivo OMP: gemm-ragserver-omp-all-data-sizes-and-chunk-sizes-evaluation-09-11-2016-12-16-41-joined-processed.csv

cd csv/ragserver
./merge.sh

# Arquivo final: gemm-ragserver-cuda-all-data-sizes-and-chunk-sizes-evaluation-11-11-2016-18-51-34-and-gemm-ragserver-omp-all-data-sizes-and-chunk-sizes-evaluation-09-11-2016-12-16-41-joined-processed-final.csv

# Executa o R com o script: 
# /dados/rogerio/USP/doutorado/prova-de-conceito/testes-prova-conceito/openmp-hook/experiments/all-data-sizes-and-chunk-sizes-evaluation/

Script: graph-omp-ompoff-all-data-sizes-and-chunk-sizes-evaluation.R


