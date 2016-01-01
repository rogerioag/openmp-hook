#!/bin/bash
echo "Removendo executáveis antigos..."
rm lloops
rm lloops-O2
rm lloops-O3

echo "Compilando..."
gcc lloops.c cpuidc.o cpuida.o -m32 -lrt -lc -lm -o lloops
echo "Compilando... -O2"
gcc lloops-O2.c cpuidc.o cpuida.o -m32 -lrt -lc -lm -O2 -o lloops-O2
echo "Compilando... -O3"
gcc lloops-O3.c cpuidc.o cpuida.o -m32 -lrt -lc -lm -O3 -o lloops-O3
