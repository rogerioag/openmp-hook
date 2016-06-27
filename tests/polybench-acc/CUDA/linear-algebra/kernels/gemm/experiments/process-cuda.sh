#!/bin/bash

cp ../output/ . -R
./join-cuda.sh
./csvize-cuda-experiments-results.py -i csv/28-03-2016-19-39-23-joined.csv -o csv/28-03-2016-19-39-23-traited.csv