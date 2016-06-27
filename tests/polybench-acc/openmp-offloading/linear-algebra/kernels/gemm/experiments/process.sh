#!/bin/bash

cp ../output/ . -R
cd ./output/29-03-2016-15-09-51
sed -i -- 's/ , NK =/, NK =/g' *
sed -i -- ':a;N;$!ba;s/\nexp/,\nexp/g' *
cd ../..
./join-omp-off.sh
./csvize-omp-off-experiments-results.py -i csv/29-03-2016-15-09-51-joined.csv -o csv/29-03-2016-15-09-51-traited.csv