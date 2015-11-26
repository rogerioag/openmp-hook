
CC=gcc-4.8
CXX=g++-4.8

# LLVM_BUILD=/dados/rogerio/USP/doutorado/prototipo-370-gpu/llvm_build
LLVM_BUILD=/home/goncalv/prototipo-370-gpu/llvm_build

# LIB_HOOKOMP_PATH=/dados/rogerio/USP/doutorado/prova-de-conceito/testes-prova-conceito/openmp-hook/
LIB_HOOKOMP_PATH=/home/goncalv/prova-de-conceito/testes-prova-conceito/openmp-hook

all: main create-png

main: matmul.c
	${LLVM_BUILD}/bin/clang -O3 -S -emit-llvm matmul.c -o matmul.ll
	${LLVM_BUILD}/bin/opt -load ${LLVM_BUILD}/lib/LLVMPolly.so -polly-parallel -polly-parallel-force -polly-codegen -S matmul.ll
	${LLVM_BUILD}/bin/opt -load ${LLVM_BUILD}/lib/LLVMPolly.so -polly-parallel -polly-parallel-force -polly-codegen -S matmul.ll -o matmul.openmp.ll

	# /dados/rogerio/USP/doutorado/prototipo-370-gpu/llvm_build/bin/opt -load /dados/rogerio/USP/doutorado/prototipo-370-gpu/llvm_build/lib/LLVMPolly.so -polly-ast -polly-parallel -polly-parallel-force -S matmul.ll -o matmul.openmp.ll

	# /dados/rogerio/USP/doutorado/prototipo-370-gpu/llvm_build/bin/opt -load /dados/rogerio/USP/doutorado/prototipo-370-gpu/llvm_build/lib/LLVMPolly.so -polly-parallel -polly-parallel-force -polly-ast -analyze matmul.ll
	@echo "Analizing the code..."
	${LLVM_BUILD}/bin/opt -load ${LLVM_BUILD}/lib/LLVMPolly.so -polly-parallel -polly-parallel-force -polly-ast -analyze matmul.ll
	
	${LLVM_BUILD}/bin/llc matmul.openmp.ll -o matmul.openmp.s
	
	${CC} -lgomp matmul.openmp.s -o matmul.omp.lgomp.exe
	${CC} -fopenmp matmul.openmp.s -o matmul.omp.fopenmp.exe 
	
	${CC} -L ${LIB_HOOKOMP_PATH} -lhookomp -lgomp matmul.openmp.s -o matmul.omp.lgomp.hook.exe
	${CC} -L ${LIB_HOOKOMP_PATH} -lhookomp -lgomp matmul.openmp.s -o matmul.omp.fopenmp.hook.exe
	${CC} -L ${LIB_HOOKOMP_PATH} -lhookomp -fopenmp -lgomp matmul.openmp.s -o matmul.omp.fopenmp.lgomp.hook.exe
	# gcc -L /home/goncalv/prova-de-conceito/testes-prova-conceito/openmp-hook/ -lhookomp -fopenmp -lgomp matmul.openmp.s -o matmul.omp.fopenmp.lgomp.hook.exe

create-dot:
	@echo "Analising the code..."
	${LLVM_BUILD}/bin/opt -load ${LLVM_BUILD}/lib/LLVMPolly.so -analyze -dot-scops matmul.openmp.ll

create-png: create-dot
	$(foreach var,$(shell ls *.dot), dot -Tpng $(var) > $(var).png;)

clean:
	rm -rf *.o *.exe
