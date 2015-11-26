
CC=gcc-4.7
CXX=g++-4.7

# LLVM_BUILD=/dados/rogerio/USP/doutorado/prototipo-370-gpu/llvm_build
LLVM_BUILD=/home/goncalv/prototipo-370-gpu/llvm_build

# LIB_HOOKOMP_PATH=/dados/rogerio/USP/doutorado/prova-de-conceito/testes-prova-conceito/openmp-hook/
LIB_HOOKOMP_PATH=/home/goncalv/prova-de-conceito/testes-prova-conceito/openmp-hook

all: main create-png

main: vectoradd.c
	${LLVM_BUILD}/bin/clang -O3 -S -emit-llvm vectoradd.c -o vectoradd.ll
	${LLVM_BUILD}/bin/opt -load ${LLVM_BUILD}/lib/LLVMPolly.so -polly-parallel -polly-parallel-force -polly-codegen -S vectoradd.ll
	${LLVM_BUILD}/bin/opt -load ${LLVM_BUILD}/lib/LLVMPolly.so -polly-detect-unprofitable -polly-ast -polly-parallel -polly-parallel-force -polly-codegen -S vectoradd.ll -o vectoradd.openmp.ll

	# /dados/rogerio/USP/doutorado/prototipo-370-gpu/llvm_build/bin/opt -load /dados/rogerio/USP/doutorado/prototipo-370-gpu/llvm_build/lib/LLVMPolly.so -polly-ast -polly-parallel -polly-parallel-force -S vectoradd.ll -o vectoradd.openmp.ll

	# /dados/rogerio/USP/doutorado/prototipo-370-gpu/llvm_build/bin/opt -load /dados/rogerio/USP/doutorado/prototipo-370-gpu/llvm_build/lib/LLVMPolly.so -polly-parallel -polly-parallel-force -polly-ast -analyze vectoradd.ll
	@echo "Analising the code..."
	${LLVM_BUILD}/bin/opt -load ${LLVM_BUILD}/lib/LLVMPolly.so -polly-parallel -polly-parallel-force -polly-ast -analyze vectoradd.ll

	${LLVM_BUILD}/bin/llc vectoradd.openmp.ll -o vectoradd.openmp.s
	
	${CC} -lgomp vectoradd.openmp.s -o vectoradd.omp.lgomp.exe
	${CC} -fopenmp vectoradd.openmp.s -o vectoradd.omp.fopenmp.exe 
	
	${CC} -L ${LIB_HOOKOMP_PATH} -lhookomp -lgomp vectoradd.openmp.s -o vectoradd.omp.lgomp.hook.exe
	${CC} -L ${LIB_HOOKOMP_PATH} -lhookomp -lgomp vectoradd.openmp.s -o vectoradd.omp.fopenmp.hook.exe
	${CC} -L ${LIB_HOOKOMP_PATH} -lhookomp -fopenmp -lgomp vectoradd.openmp.s -o vectoradd.omp.fopenmp.lgomp.hook.exe
	# gcc -L /home/goncalv/prova-de-conceito/testes-prova-conceito/openmp-hook/ -lhookomp -fopenmp -lgomp vectoradd.openmp.s -o vectoradd.omp.fopenmp.lgomp.hook.exe

create-dot:
	@echo "Analising the code..."
	${LLVM_BUILD}/bin/opt -load ${LLVM_BUILD}/lib/LLVMPolly.so -analyze -dot-scops -polly-detect-unprofitable vectoradd.openmp.ll

create-png: create-dot
	$(foreach var,$(shell ls *.dot), dot -Tpng $(var) > $(var).png;)		

clean:
	rm -rf *.o *.exe
