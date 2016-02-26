BENCHMARK  := $(shell basename `pwd`)
OBJFILE := ${BENCHMARK}-offloading-gpu.o
EXECUTABLE := ${BENCHMARK}-offloading-gpu.exe
CUFILES := ${BENCHMARK}.cu
PATH_TO_UTILS := ../../../utilities
CXX := g++-4.8
NVCC := nvcc
OPT_LEVEL := -O2
# MAKE_OPTIONS := -DPOLYBENCH_TIME -DEXTRALARGE_DATASET
include ${PATH_TO_UTILS}/common.mk
