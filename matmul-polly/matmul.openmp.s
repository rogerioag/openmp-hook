	.text
	.file	"matmul.openmp.ll"
	.section	.rodata.cst8,"aM",@progbits,8
	.align	8
.LCPI0_0:
	.quad	4602678819172646912     # double 0.5
	.text
	.globl	init_array
	.align	16, 0x90
	.type	init_array,@function
init_array:                             # @init_array
	.cfi_startproc
# BB#0:
	xorl	%r8d, %r8d
	movsd	.LCPI0_0(%rip), %xmm0   # xmm0 = mem[0],zero
	.align	16, 0x90
.LBB0_1:                                # %.preheader
                                        # =>This Loop Header: Depth=1
                                        #     Child Loop BB0_2 Depth 2
	xorl	%ecx, %ecx
	.align	16, 0x90
.LBB0_2:                                #   Parent Loop BB0_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movl	%ecx, %edx
	imull	%r8d, %edx
	movl	%edx, %esi
	sarl	$31, %esi
	shrl	$22, %esi
	leal	(%rsi,%rdx), %esi
	andl	$-1024, %esi            # imm = 0xFFFFFFFFFFFFFC00
	subl	%esi, %edx
	orl	$1, %edx
	xorps	%xmm1, %xmm1
	cvtsi2sdl	%edx, %xmm1
	mulsd	%xmm0, %xmm1
	cvtsd2ss	%xmm1, %xmm1
	movq	%r8, %rdx
	shlq	$11, %rdx
	leaq	(%rdx,%rdx,2), %rdx
	movss	%xmm1, A(%rdx,%rcx,4)
	movss	%xmm1, B(%rdx,%rcx,4)
	movq	%rcx, %rax
	orq	$1, %rax
	movl	%eax, %esi
	imull	%r8d, %esi
	movl	%esi, %edi
	sarl	$31, %edi
	shrl	$22, %edi
	leal	(%rdi,%rsi), %edi
	andl	$-1024, %edi            # imm = 0xFFFFFFFFFFFFFC00
	negl	%edi
	leal	1(%rsi,%rdi), %esi
	cvtsi2sdl	%esi, %xmm1
	mulsd	%xmm0, %xmm1
	cvtsd2ss	%xmm1, %xmm1
	movss	%xmm1, A(%rdx,%rax,4)
	movss	%xmm1, B(%rdx,%rax,4)
	addq	$2, %rcx
	cmpq	$1536, %rcx             # imm = 0x600
	jne	.LBB0_2
# BB#3:                                 #   in Loop: Header=BB0_1 Depth=1
	incq	%r8
	cmpq	$1536, %r8              # imm = 0x600
	jne	.LBB0_1
# BB#4:
	retq
.Lfunc_end0:
	.size	init_array, .Lfunc_end0-init_array
	.cfi_endproc

	.globl	print_array
	.align	16, 0x90
	.type	print_array,@function
print_array:                            # @print_array
	.cfi_startproc
# BB#0:
	pushq	%r15
.Ltmp0:
	.cfi_def_cfa_offset 16
	pushq	%r14
.Ltmp1:
	.cfi_def_cfa_offset 24
	pushq	%r12
.Ltmp2:
	.cfi_def_cfa_offset 32
	pushq	%rbx
.Ltmp3:
	.cfi_def_cfa_offset 40
	pushq	%rax
.Ltmp4:
	.cfi_def_cfa_offset 48
.Ltmp5:
	.cfi_offset %rbx, -40
.Ltmp6:
	.cfi_offset %r12, -32
.Ltmp7:
	.cfi_offset %r14, -24
.Ltmp8:
	.cfi_offset %r15, -16
	movl	$C, %r14d
	xorl	%r15d, %r15d
	.align	16, 0x90
.LBB1_1:                                # %.preheader
                                        # =>This Loop Header: Depth=1
                                        #     Child Loop BB1_2 Depth 2
	movq	stdout(%rip), %rcx
	movq	%r14, %r12
	xorl	%ebx, %ebx
	.align	16, 0x90
.LBB1_2:                                #   Parent Loop BB1_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movss	(%r12), %xmm0           # xmm0 = mem[0],zero,zero,zero
	cvtss2sd	%xmm0, %xmm0
	movl	$.L.str, %esi
	movb	$1, %al
	movq	%rcx, %rdi
	callq	fprintf
	movslq	%ebx, %rax
	imulq	$1717986919, %rax, %rcx # imm = 0x66666667
	movq	%rcx, %rdx
	shrq	$63, %rdx
	sarq	$37, %rcx
	addl	%edx, %ecx
	shll	$4, %ecx
	leal	(%rcx,%rcx,4), %ecx
	subl	%ecx, %eax
	cmpl	$79, %eax
	jne	.LBB1_4
# BB#3:                                 #   in Loop: Header=BB1_2 Depth=2
	movq	stdout(%rip), %rsi
	movl	$10, %edi
	callq	fputc
.LBB1_4:                                #   in Loop: Header=BB1_2 Depth=2
	incq	%rbx
	movq	stdout(%rip), %rcx
	addq	$4, %r12
	cmpq	$1536, %rbx             # imm = 0x600
	jne	.LBB1_2
# BB#5:                                 #   in Loop: Header=BB1_1 Depth=1
	movl	$10, %edi
	movq	%rcx, %rsi
	callq	fputc
	incq	%r15
	addq	$6144, %r14             # imm = 0x1800
	cmpq	$1536, %r15             # imm = 0x600
	jne	.LBB1_1
# BB#6:
	addq	$8, %rsp
	popq	%rbx
	popq	%r12
	popq	%r14
	popq	%r15
	retq
.Lfunc_end1:
	.size	print_array, .Lfunc_end1-print_array
	.cfi_endproc

	.section	.rodata.cst8,"aM",@progbits,8
	.align	8
.LCPI2_0:
	.quad	4602678819172646912     # double 0.5
	.text
	.globl	main
	.align	16, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# BB#0:
	xorl	%r8d, %r8d
	movsd	.LCPI2_0(%rip), %xmm0   # xmm0 = mem[0],zero
	.align	16, 0x90
.LBB2_1:                                # %.preheader.i
                                        # =>This Loop Header: Depth=1
                                        #     Child Loop BB2_2 Depth 2
	xorl	%ecx, %ecx
	.align	16, 0x90
.LBB2_2:                                #   Parent Loop BB2_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movl	%ecx, %edx
	imull	%r8d, %edx
	movl	%edx, %esi
	sarl	$31, %esi
	shrl	$22, %esi
	leal	(%rsi,%rdx), %esi
	andl	$-1024, %esi            # imm = 0xFFFFFFFFFFFFFC00
	subl	%esi, %edx
	orl	$1, %edx
	xorps	%xmm1, %xmm1
	cvtsi2sdl	%edx, %xmm1
	mulsd	%xmm0, %xmm1
	cvtsd2ss	%xmm1, %xmm1
	movq	%r8, %rdx
	shlq	$11, %rdx
	leaq	(%rdx,%rdx,2), %rdx
	movss	%xmm1, A(%rdx,%rcx,4)
	movss	%xmm1, B(%rdx,%rcx,4)
	movq	%rcx, %rax
	orq	$1, %rax
	movl	%eax, %esi
	imull	%r8d, %esi
	movl	%esi, %edi
	sarl	$31, %edi
	shrl	$22, %edi
	leal	(%rdi,%rsi), %edi
	andl	$-1024, %edi            # imm = 0xFFFFFFFFFFFFFC00
	negl	%edi
	leal	1(%rsi,%rdi), %esi
	cvtsi2sdl	%esi, %xmm1
	mulsd	%xmm0, %xmm1
	cvtsd2ss	%xmm1, %xmm1
	movss	%xmm1, A(%rdx,%rax,4)
	movss	%xmm1, B(%rdx,%rax,4)
	addq	$2, %rcx
	cmpq	$1536, %rcx             # imm = 0x600
	jne	.LBB2_2
# BB#3:                                 #   in Loop: Header=BB2_1 Depth=1
	incq	%r8
	cmpq	$1536, %r8              # imm = 0x600
	jne	.LBB2_1
# BB#4:                                 # %polly.split_new_and_old
	movl	$A, %r10d
	xorl	%r8d, %r8d
	movl	$A+8, %r9d
	movl	$C, %ecx
	movl	$B+9437184, %edx
	cmpq	%rcx, %rdx
	setbe	%dl
	movl	$B-12288, %esi
	movl	$C+9437184, %edi
	cmpq	%rsi, %rdi
	setbe	%al
	orb	%dl, %al
	movl	$A+9437184, %edx
	cmpq	%rcx, %rdx
	setbe	%cl
	cmpq	%r10, %rdi
	setbe	%dl
	orb	%cl, %dl
	testb	%al, %dl
	je	.LBB2_5
	.align	16, 0x90
.LBB2_13:                               # %polly.loop_preheader2
                                        # =>This Loop Header: Depth=1
                                        #     Child Loop BB2_14 Depth 2
                                        #       Child Loop BB2_15 Depth 3
	leaq	(%r8,%r8,2), %rax
	shlq	$11, %rax
	leaq	C(%rax), %r10
	xorl	%esi, %esi
	.align	16, 0x90
.LBB2_14:                               # %polly.stmt.
                                        #   Parent Loop BB2_13 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB2_15 Depth 3
	movl	$0, (%r10,%rsi,4)
	movl	$0, -8(%rsp)
	movq	$-1, %rdi
	movq	$-9418752, %rax         # imm = 0xFFFFFFFFFF704800
	movq	%r9, %rcx
	xorl	%edx, %edx
	.align	16, 0x90
.LBB2_15:                               # %polly.stmt.14
                                        #   Parent Loop BB2_13 Depth=1
                                        #     Parent Loop BB2_14 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	movss	-8(%rcx), %xmm0         # xmm0 = mem[0],zero,zero,zero
	movss	-4(%rcx), %xmm1         # xmm1 = mem[0],zero,zero,zero
	mulss	B+9418752(%rax,%rsi,4), %xmm0
	addss	-8(%rsp), %xmm0
	mulss	B+9424896(%rax,%rsi,4), %xmm1
	addss	%xmm0, %xmm1
	movss	(%rcx), %xmm0           # xmm0 = mem[0],zero,zero,zero
	mulss	B+9431040(%rax,%rsi,4), %xmm0
	addss	%xmm1, %xmm0
	movss	%xmm0, -8(%rsp)
	movss	%xmm0, -4(%rsp)
	incq	%rdx
	incq	%rdi
	addq	$18432, %rax            # imm = 0x4800
	addq	$12, %rcx
	cmpq	$511, %rdi              # imm = 0x1FF
	jl	.LBB2_15
# BB#11:                                # %polly.stmt.37
                                        #   in Loop: Header=BB2_14 Depth=2
	movss	-4(%rsp), %xmm0         # xmm0 = mem[0],zero,zero,zero
	movss	%xmm0, (%r10,%rsi,4)
	cmpq	$1535, %rsi             # imm = 0x5FF
	leaq	1(%rsi), %rsi
	jl	.LBB2_14
# BB#12:                                # %polly.loop_exit3
                                        #   in Loop: Header=BB2_13 Depth=1
	addq	$6144, %r9              # imm = 0x1800
	cmpq	$1535, %r8              # imm = 0x5FF
	leaq	1(%r8), %r8
	jl	.LBB2_13
	jmp	.LBB2_10
	.align	16, 0x90
.LBB2_5:                                # %.preheader
                                        # =>This Loop Header: Depth=1
                                        #     Child Loop BB2_6 Depth 2
                                        #       Child Loop BB2_7 Depth 3
	xorl	%edx, %edx
	.align	16, 0x90
.LBB2_6:                                #   Parent Loop BB2_5 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB2_7 Depth 3
	leaq	(%r8,%r8,2), %rcx
	shlq	$11, %rcx
	leaq	C(%rcx,%rdx,4), %rax
	movl	$0, C(%rcx,%rdx,4)
	xorpd	%xmm0, %xmm0
	movq	$-9437184, %rcx         # imm = 0xFFFFFFFFFF700000
	movq	%r9, %rsi
	.align	16, 0x90
.LBB2_7:                                #   Parent Loop BB2_5 Depth=1
                                        #     Parent Loop BB2_6 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	movss	-8(%rsi), %xmm1         # xmm1 = mem[0],zero,zero,zero
	movss	-4(%rsi), %xmm2         # xmm2 = mem[0],zero,zero,zero
	mulss	B+9437184(%rcx,%rdx,4), %xmm1
	addss	%xmm0, %xmm1
	mulss	B+9443328(%rcx,%rdx,4), %xmm2
	addss	%xmm1, %xmm2
	movss	(%rsi), %xmm0           # xmm0 = mem[0],zero,zero,zero
	mulss	B+9449472(%rcx,%rdx,4), %xmm0
	addss	%xmm2, %xmm0
	addq	$12, %rsi
	addq	$18432, %rcx            # imm = 0x4800
	jne	.LBB2_7
# BB#8:                                 #   in Loop: Header=BB2_6 Depth=2
	movss	%xmm0, (%rax)
	incq	%rdx
	cmpq	$1536, %rdx             # imm = 0x600
	jne	.LBB2_6
# BB#9:                                 # %init_array.exit
                                        #   in Loop: Header=BB2_5 Depth=1
	incq	%r8
	addq	$6144, %r9              # imm = 0x1800
	cmpq	$1536, %r8              # imm = 0x600
	jne	.LBB2_5
.LBB2_10:                               # %polly.merge_new_and_old
	xorl	%eax, %eax
	retq
.Lfunc_end2:
	.size	main, .Lfunc_end2-main
	.cfi_endproc

	.type	A,@object               # @A
	.comm	A,9437184,16
	.type	B,@object               # @B
	.comm	B,9437184,16
	.type	.L.str,@object          # @.str
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str:
	.asciz	"%lf "
	.size	.L.str, 5

	.type	C,@object               # @C
	.comm	C,9437184,16

	.ident	"clang version 3.7.0 (tags/RELEASE_370/final 254107)"
	.section	".note.GNU-stack","",@progbits
