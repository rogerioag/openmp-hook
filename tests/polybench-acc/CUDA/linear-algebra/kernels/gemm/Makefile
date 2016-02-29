BENCHMARK  := $(shell basename `pwd`)
OBJFILE := ${BENCHMARK}-gpu.o
EXECUTABLE := ${BENCHMARK}-gpu.exe
CUFILES := ${BENCHMARK}.cu
PATH_TO_UTILS := ../../../utilities
CXX := g++-4.8
NVCC := nvcc
OPT_LEVEL := -O2
include ${PATH_TO_UTILS}/common.mk
