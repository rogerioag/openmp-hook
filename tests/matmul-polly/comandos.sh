/home/goncalv/prototipo-370-gpu/llvm_build/bin/clang -S -emit-llvm matmul.c -o matmul.s

/home/goncalv/prototipo-370-gpu/llvm_build/lib

/home/goncalv/prototipo-370-gpu/llvm_build/bin/opt -load /home/goncalv/prototipo-370-gpu/llvm_build/lib/LLVMPolly.so -S -polly-canonicalize matmul.s > matmul.preopt.ll

/home/goncalv/prototipo-370-gpu/llvm_build/bin/opt -load /home/goncalv/prototipo-370-gpu/llvm_build/lib/LLVMPolly.so -basicaa -polly-ast -analyze -q matmul.preopt.ll

/home/goncalv/prototipo-370-gpu/llvm_build/bin/opt -load /home/goncalv/prototipo-370-gpu/llvm_build/lib/LLVMPolly.so -polly-parallel -polly-parallel-force -polly-ast -analyze -q matmul.preopt.ll

goncalv@pilipili2:~/prova-de-conceito/testes-prova-conceito/openmp-hook/matmul-polly$ /home/goncalv/prototipo-370-gpu/llvm_build/bin/opt -load /home/goncalv/prototipo-370-gpu/llvm_build/lib/LLVMPolly.so -polly-parallel -polly-parallel-force -polly-ast -analyze -q matmul.preopt.ll
:: isl ast :: main :: .preheader => %15

if (1 && (&MemRef_C[2359296] <= &MemRef_A[0] || &MemRef_A[2359296] <= &MemRef_C[0]) && (&MemRef_C[2359296] <= &MemRef_B[0] || &MemRef_B[2359296] <= &MemRef_C[0]))

    #pragma omp parallel for
    for (int c0 = 0; c0 <= 1535; c0 += 1)
      for (int c1 = 0; c1 <= 1535; c1 += 1) {
        Stmt_1(c0, c1);
        #pragma minimal dependence distance: 1
        for (int c2 = 0; c2 <= 1535; c2 += 1)
          Stmt_3(c0, c1, c2);
      }

else
    {  /* original code */ }

/home/goncalv/prototipo-370-gpu/llvm_build/bin/opt -load /home/goncalv/prototipo-370-gpu/llvm_build/lib/LLVMPolly.so -basicaa -dot-scops -disable-output matmul.preopt.ll

/home/goncalv/prototipo-370-gpu/llvm_build/bin/opt -load /home/goncalv/prototipo-370-gpu/llvm_build/lib/LLVMPolly.so -basicaa -dot-scops-only -disable-output matmul.preopt.ll

for i in `ls *.dot`; do dot -Tpng $i > $i.png; done

/home/goncalv/prototipo-370-gpu/llvm_build/bin/opt -load /home/goncalv/prototipo-370-gpu/llvm_build/lib/LLVMPolly.so -basicaa -polly-scops -analyze matmul.preopt.ll

goncalv@pilipili2:~/prova-de-conceito/testes-prova-conceito/openmp-hook/matmul-polly$ /home/goncalv/prototipo-370-gpu/llvm_build/bin/opt -load /home/goncalv/prototipo-370-gpu/llvm_build/lib/LLVMPolly.so -basicaa -polly-scops -analyze matmul.preopt.ll
Printing analysis 'Basic Alias Analysis (stateless AA impl)':
Pass::print not implemented for pass: 'Basic Alias Analysis (stateless AA impl)'!
Printing analysis 'Polly - Create polyhedral description of Scops' for region: '%1 => %18' in function 'init_array':
Invalid Scop!
Printing analysis 'Polly - Create polyhedral description of Scops' for region: '.preheader => %19' in function 'init_array':
Invalid Scop!
Printing analysis 'Polly - Create polyhedral description of Scops' for region: '%0 => <Function Return>' in function 'init_array':
Invalid Scop!
Printing analysis 'Polly - Create polyhedral description of Scops' for region: '%2 => %13' in function 'print_array':
Invalid Scop!
Printing analysis 'Polly - Create polyhedral description of Scops' for region: '%2 => %15' in function 'print_array':
Invalid Scop!
Printing analysis 'Polly - Create polyhedral description of Scops' for region: '.preheader => %16' in function 'print_array':
Invalid Scop!
Printing analysis 'Polly - Create polyhedral description of Scops' for region: '%0 => <Function Return>' in function 'print_array':
Invalid Scop!
Printing analysis 'Polly - Create polyhedral description of Scops' for region: '%3 => %13' in function 'main':
Invalid Scop!
Printing analysis 'Polly - Create polyhedral description of Scops' for region: '%1 => %14' in function 'main':
Invalid Scop!
Printing analysis 'Polly - Create polyhedral description of Scops' for region: '.preheader => %15' in function 'main':
    Function: main
    Region: %.preheader---%15
    Max Loop Depth:  3
    Context:
    {  :  }
    Assumed Context:
    {  :  }
    Arrays {
        float MemRef_C[*][4] // Element size 4
        float MemRef_A[*][4] // Element size 4
        float MemRef_B[*][4] // Element size 4
    }
    Alias Groups (0):
        n/a
    Statements {
    	Stmt_1
            Domain :=
                { Stmt_1[i0, i1] : i0 >= 0 and i0 <= 1535 and i1 >= 0 and i1 <= 1535 };
            Schedule :=
                { Stmt_1[i0, i1] -> [i0, i1, 0, 0] };
            MustWriteAccess :=	[Reduction Type: NONE] [Scalar: 0]
                { Stmt_1[i0, i1] -> MemRef_C[1536i0 + i1] };
    	Stmt_3
            Domain :=
                { Stmt_3[i0, i1, i2] : i0 >= 0 and i0 <= 1535 and i1 >= 0 and i1 <= 1535 and i2 >= 0 and i2 <= 1535 };
            Schedule :=
                { Stmt_3[i0, i1, i2] -> [i0, i1, 1, i2] };
            ReadAccess :=	[Reduction Type: NONE] [Scalar: 0]
                { Stmt_3[i0, i1, i2] -> MemRef_C[1536i0 + i1] };
            ReadAccess :=	[Reduction Type: NONE] [Scalar: 0]
                { Stmt_3[i0, i1, i2] -> MemRef_A[1536i0 + i2] };
            ReadAccess :=	[Reduction Type: NONE] [Scalar: 0]
                { Stmt_3[i0, i1, i2] -> MemRef_B[i1 + 1536i2] };
            MustWriteAccess :=	[Reduction Type: NONE] [Scalar: 0]
                { Stmt_3[i0, i1, i2] -> MemRef_C[1536i0 + i1] };
    }
Printing analysis 'Polly - Create polyhedral description of Scops' for region: '%0 => <Function Return>' in function 'main':
Invalid Scop!

goncalv@pilipili2:~/prova-de-conceito/testes-prova-conceito/openmp-hook/matmul-polly$ /home/goncalv/prototipo-370-gpu/llvm_build/bin/opt -load /home/goncalv/prototipo-370-gpu/llvm_build/lib/LLVMPolly.so -basicaa -polly-dependences -analyze matmul.preopt.ll
Printing analysis 'Basic Alias Analysis (stateless AA impl)':
Pass::print not implemented for pass: 'Basic Alias Analysis (stateless AA impl)'!
Printing analysis 'Polly - Calculate dependences' for region: '%1 => %18' in function 'init_array':
Printing analysis 'Polly - Calculate dependences' for region: '.preheader => %19' in function 'init_array':
Printing analysis 'Polly - Calculate dependences' for region: '%0 => <Function Return>' in function 'init_array':
Printing analysis 'Polly - Calculate dependences' for region: '%2 => %13' in function 'print_array':
Printing analysis 'Polly - Calculate dependences' for region: '%2 => %15' in function 'print_array':
Printing analysis 'Polly - Calculate dependences' for region: '.preheader => %16' in function 'print_array':
Printing analysis 'Polly - Calculate dependences' for region: '%0 => <Function Return>' in function 'print_array':
Printing analysis 'Polly - Calculate dependences' for region: '%3 => %13' in function 'main':
Printing analysis 'Polly - Calculate dependences' for region: '%1 => %14' in function 'main':
Printing analysis 'Polly - Calculate dependences' for region: '.preheader => %15' in function 'main':
	RAW dependences:
		{ Stmt_1[i0, i1] -> Stmt_3[i0, i1, 0] : i0 >= 0 and i0 <= 1535 and i1 >= 0 and i1 <= 1535; Stmt_3[i0, i1, i2] -> Stmt_3[i0, i1, 1 + i2] : i0 >= 0 and i0 <= 1535 and i1 >= 0 and i1 <= 1535 and i2 >= 0 and i2 <= 1534 }
	WAR dependences:
		{  }
	WAW dependences:
		{ Stmt_1[i0, i1] -> Stmt_3[i0, i1, 0] : i0 <= 1535 and i0 >= 0 and i1 <= 1535 and i1 >= 0; Stmt_3[i0, i1, i2] -> Stmt_3[i0, i1, 1 + i2] : i0 <= 1535 and i0 >= 0 and i1 <= 1535 and i1 >= 0 and i2 <= 1534 and i2 >= 0 }
	Reduction dependences:
		{  }
	Transitive closure of reduction dependences:
		n/a
Printing analysis 'Polly - Calculate dependences' for region: '%0 => <Function Return>' in function 'main':



/home/goncalv/prototipo-370-gpu/llvm_build/bin/opt -load /home/goncalv/prototipo-370-gpu/llvm_build/lib/LLVMPolly.so -basicaa -polly-import-jscop -polly-import-jscop-postfix=interchanged -polly-codegen matmul.preopt.ll | /home/goncalv/prototipo-370-gpu/llvm_build/bin/opt -O3 > matmul.polly.interchanged.ll

goncalv@pilipili2:~/prova-de-conceito/testes-prova-conceito/openmp-hook/matmul-polly$ /home/goncalv/prototipo-370-gpu/llvm_build/bin/opt -load /home/goncalv/prototipo-370-gpu/llvm_build/lib/LLVMPolly.so -basicaa -polly-import-jscop -polly-import-jscop-postfix=interchanged -polly-codegen matmul.preopt.ll | /home/goncalv/prototipo-370-gpu/llvm_build/bin/opt -O3 > matmul.polly.interchanged.ll
Reading JScop '.preheader => %15' in function 'main' from './main___%.preheader---%15.jscop.interchanged'.
JScop file contains a schedule that changes the dependences. Use -disable-polly-legality to continue anyways
goncalv@pilipili2:~/prova-de-conceito/testes-prova-conceito/openmp-hook/matmul-polly$ /home/goncalv/prototipo-370-gpu/llvm_build/bin/opt -load /home/goncalv/prototipo-370-gpu/llvm_build/lib/LLVMPolly.so -basicaa -polly-import-jscop -polly-import-jscop-postfix=interchanged -polly-codegen -disable-polly-legality matmul.preopt.ll | /home/goncalv/prototipo-370-gpu/llvm_build/bin/opt -O3 > matmul.polly.interchanged.ll
Reading JScop '.preheader => %15' in function 'main' from './main___%.preheader---%15.jscop.interchanged'.
goncalv@pilipili2:~/prova-de-conceito/testes-prova-conceito/openmp-hook/matmul-polly$ /home/goncalv/prototipo-370-gpu/llvm_build/bin/opt -load /home/goncalv/prototipo-370-gpu/llvm_build/lib/LLVMPolly.so -basicaa -polly-import-jscop -polly-import-jscop-postfix=interchanged -polly-codegen -disable-polly-legality matmul.preopt.ll | /home/goncalv/prototipo-370-gpu/llvm_build/bin/opt -O3 > matmul.polly.interchanged.ll


/home/goncalv/prototipo-370-gpu/llvm_build/bin/opt -load /home/goncalv/prototipo-370-gpu/llvm_build/lib/LLVMPolly.so -basicaa -polly-import-jscop -polly-ast -analyze matmul.preopt.ll -polly-import-jscop-postfix=interchanged+tiled

/home/goncalv/prototipo-370-gpu/llvm_build/bin/opt -load /home/goncalv/prototipo-370-gpu/llvm_build/lib/LLVMPolly.so -basicaa -polly-import-jscop -polly-ast -analyze matmul.preopt.ll -polly-import-jscop-postfix=interchanged+tiled+vector

/home/goncalv/prototipo-370-gpu/llvm_build/bin/opt -load /home/goncalv/prototipo-370-gpu/llvm_build/lib/LLVMPolly.so -basicaa -polly-import-jscop -polly-parallel -polly-parallel-force -polly-ast -analyze matmul.preopt.ll -polly-import-jscop-postfix=interchanged+tiled+vector


