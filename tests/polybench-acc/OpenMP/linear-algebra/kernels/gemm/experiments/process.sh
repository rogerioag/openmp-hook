#!/bin/bash

cp ../output/ . -R
cd ./output/29-03-2016-00-56-12
sed -i -- 's/, NK =/, NK =/g' *
sed -i -- ':a;N;$!ba;s/\nexp/,\nexp/g' *
cd ../..
./join.sh
./csvize-omp-experiments-results.py -i csv/29-03-2016-00-56-12-joined.csv -o csv/29-03-2016-00-56-12-traited.csv