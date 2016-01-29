# CODE GENERATION OPTIONS
########################################

# Default OpenMP Target is OpenCL
TARGET_LANG = OPENMP

# Uncomment if you want CUDA
# TARGET_LANG = CUDA

# COMPILER OPTIONS -- ACCELERATOR
########################################

# Accelerator Compiler
# ACC = hmpp

# Accelerator Compiler flags
# ACCFLAGS = --codelet-required --openacc-target=$(TARGET_LANG)

# COMPILER OPTIONS -- HOST
########################################

# Compiler
CC = gcc-4.8

# Compiler flags
CFLAGS = -O2 -fopenmp
