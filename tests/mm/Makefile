
all: mmc mmf

mmc: omp_mm.c
	gcc omp_mm.c -fopenmp -o mmc.exe

mmf: omp_mm.f
	gfortran omp_mm.f -fopenmp -o mmf.exe

clean:
	rm *.exe

