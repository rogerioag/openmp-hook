BENCHMARK  := $(shell basename `pwd`)
# position of directory (openmp, openmp-offloading, cuda...)
NUM_FIELD := 9
# retrieve openmp, openmp-offloading, cuda...
BENCHMARK_TYPE := $(shell pwd | cut -d'/' -f${NUM_FIELD} | tr '[:upper:]' '[:lower:]')
OBJFILE := ${BENCHMARK}-${BENCHMARK_TYPE}.o
EXECUTABLE := ${BENCHMARK}-${BENCHMARK_TYPE}.exe
CUFILES := ${BENCHMARK}.cu
PATH_TO_UTILS := ../../../utilities
CXX := g++-4.8
NVCC := nvcc -D_FORCE_INLINES
OPT_LEVEL := -O3
# MAKE_OPTIONS := -DPOLYBENCH_TIME -DEXTRALARGE_DATASET
include ${PATH_TO_UTILS}/common.mk

