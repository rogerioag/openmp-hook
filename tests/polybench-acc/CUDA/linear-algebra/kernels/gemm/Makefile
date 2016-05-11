BENCHMARK  := $(shell basename `pwd`)
OBJFILE := ${BENCHMARK}-gpu.o
EXECUTABLE := ${BENCHMARK}-gpu.exe
CUFILES := ${BENCHMARK}.cu
PATH_TO_UTILS := ../../../utilities
INCLUDE_DIR := -I/home/goncalv/prova-de-conceito/testes-prova-conceito/openmp-hook
CXX := g++-4.8
NVCC := nvcc
OPT_LEVEL := -O3
include ${PATH_TO_UTILS}/common.mk
