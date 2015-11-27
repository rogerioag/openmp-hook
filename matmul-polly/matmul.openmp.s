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
# BB#0:                                 # %polly.split_new_and_old
	pushq	%rbx
.Ltmp0:
	.cfi_def_cfa_offset 16
	subq	$16, %rsp
.Ltmp1:
	.cfi_def_cfa_offset 32
.Ltmp2:
	.cfi_offset %rbx, -16
	xorl	%eax, %eax
	movl	$B, %ecx
	movl	$A+9437184, %edx
	cmpq	%rcx, %rdx
	setbe	%cl
	movl	$A, %edx
	movl	$B+9437184, %esi
	cmpq	%rdx, %rsi
	setbe	%dl
	orb	%cl, %dl
	je	.LBB0_1
# BB#6:                                 # %polly.start
	leaq	8(%rsp), %rbx
	movl	$init_array.polly.subfn, %edi
	xorl	%edx, %edx
	xorl	%ecx, %ecx
	movl	$1536, %r8d             # imm = 0x600
	movl	$1, %r9d
	movq	%rbx, %rsi
	callq	GOMP_parallel_loop_runtime_start
	movq	%rbx, %rdi
	callq	init_array.polly.subfn
	callq	GOMP_parallel_end
	jmp	.LBB0_5
.LBB0_1:
	movsd	.LCPI0_0(%rip), %xmm0   # xmm0 = mem[0],zero
	.align	16, 0x90
.LBB0_2:                                # %.preheader
                                        # =>This Loop Header: Depth=1
                                        #     Child Loop BB0_3 Depth 2
	xorl	%ecx, %ecx
	.align	16, 0x90
.LBB0_3:                                #   Parent Loop BB0_2 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movl	%ecx, %edx
	imull	%eax, %edx
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
	movq	%rax, %rdx
	shlq	$11, %rdx
	leaq	(%rdx,%rdx,2), %rdx
	movss	%xmm1, A(%rdx,%rcx,4)
	movss	%xmm1, B(%rdx,%rcx,4)
	movq	%rcx, %rbx
	orq	$1, %rbx
	movl	%ebx, %esi
	imull	%eax, %esi
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
	movss	%xmm1, A(%rdx,%rbx,4)
	movss	%xmm1, B(%rdx,%rbx,4)
	addq	$2, %rcx
	cmpq	$1536, %rcx             # imm = 0x600
	jne	.LBB0_3
# BB#4:                                 #   in Loop: Header=BB0_2 Depth=1
	incq	%rax
	cmpq	$1536, %rax             # imm = 0x600
	jne	.LBB0_2
.LBB0_5:                                # %polly.merge_new_and_old
	addq	$16, %rsp
	popq	%rbx
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
.Ltmp3:
	.cfi_def_cfa_offset 16
	pushq	%r14
.Ltmp4:
	.cfi_def_cfa_offset 24
	pushq	%r12
.Ltmp5:
	.cfi_def_cfa_offset 32
	pushq	%rbx
.Ltmp6:
	.cfi_def_cfa_offset 40
	pushq	%rax
.Ltmp7:
	.cfi_def_cfa_offset 48
.Ltmp8:
	.cfi_offset %rbx, -40
.Ltmp9:
	.cfi_offset %r12, -32
.Ltmp10:
	.cfi_offset %r14, -24
.Ltmp11:
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
# BB#0:                                 # %polly.split_new_and_old
	pushq	%r15
.Ltmp12:
	.cfi_def_cfa_offset 16
	pushq	%r14
.Ltmp13:
	.cfi_def_cfa_offset 24
	pushq	%rbx
.Ltmp14:
	.cfi_def_cfa_offset 32
	subq	$16, %rsp
.Ltmp15:
	.cfi_def_cfa_offset 48
.Ltmp16:
	.cfi_offset %rbx, -32
.Ltmp17:
	.cfi_offset %r14, -24
.Ltmp18:
	.cfi_offset %r15, -16
	xorl	%edx, %edx
	movl	$C, %r8d
	movl	$B+9437184, %ecx
	cmpq	%r8, %rcx
	setbe	%bl
	movl	$B-12288, %esi
	movl	$C+9437184, %r9d
	cmpq	%rsi, %r9
	setbe	%al
	orb	%bl, %al
	movl	$A, %r10d
	cmpq	%r10, %rcx
	setbe	%cl
	movl	$A+9437184, %edi
	cmpq	%rsi, %rdi
	setbe	%bl
	orb	%cl, %bl
	andb	%al, %bl
	cmpq	%r8, %rdi
	setbe	%al
	cmpq	%r10, %r9
	setbe	%cl
	orb	%al, %cl
	testb	%cl, %bl
	je	.LBB2_1
# BB#13:                                # %polly.start
	xorl	%r15d, %r15d
	leaq	(%rsp), %r14
	movl	$main.polly.subfn, %edi
	xorl	%edx, %edx
	xorl	%ecx, %ecx
	movl	$1536, %r8d             # imm = 0x600
	movl	$1, %r9d
	movq	%r14, %rsi
	callq	GOMP_parallel_loop_runtime_start
	movq	%r14, %rdi
	callq	main.polly.subfn
	callq	GOMP_parallel_end
	movl	$A+8, %r8d
	.align	16, 0x90
.LBB2_14:                               # %polly.loop_preheader3
                                        # =>This Loop Header: Depth=1
                                        #     Child Loop BB2_15 Depth 2
                                        #       Child Loop BB2_16 Depth 3
	leaq	(%r15,%r15,2), %rax
	shlq	$11, %rax
	leaq	C(%rax), %rcx
	xorl	%edx, %edx
	.align	16, 0x90
.LBB2_15:                               # %polly.stmt.
                                        #   Parent Loop BB2_14 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB2_16 Depth 3
	movl	$0, (%rcx,%rdx,4)
	movl	$0, 8(%rsp)
	movq	$-1, %rsi
	movq	$-9418752, %rdi         # imm = 0xFFFFFFFFFF704800
	movq	%r8, %rax
	xorl	%ebx, %ebx
	.align	16, 0x90
.LBB2_16:                               # %polly.stmt.15
                                        #   Parent Loop BB2_14 Depth=1
                                        #     Parent Loop BB2_15 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	movss	-8(%rax), %xmm0         # xmm0 = mem[0],zero,zero,zero
	movss	-4(%rax), %xmm1         # xmm1 = mem[0],zero,zero,zero
	mulss	B+9418752(%rdi,%rdx,4), %xmm0
	addss	8(%rsp), %xmm0
	mulss	B+9424896(%rdi,%rdx,4), %xmm1
	addss	%xmm0, %xmm1
	movss	(%rax), %xmm0           # xmm0 = mem[0],zero,zero,zero
	mulss	B+9431040(%rdi,%rdx,4), %xmm0
	addss	%xmm1, %xmm0
	movss	%xmm0, 8(%rsp)
	movss	%xmm0, 12(%rsp)
	incq	%rbx
	incq	%rsi
	addq	$18432, %rdi            # imm = 0x4800
	addq	$12, %rax
	cmpq	$511, %rsi              # imm = 0x1FF
	jl	.LBB2_16
# BB#11:                                # %polly.stmt.38
                                        #   in Loop: Header=BB2_15 Depth=2
	movss	12(%rsp), %xmm0         # xmm0 = mem[0],zero,zero,zero
	movss	%xmm0, (%rcx,%rdx,4)
	cmpq	$1535, %rdx             # imm = 0x5FF
	leaq	1(%rdx), %rdx
	jl	.LBB2_15
# BB#12:                                # %polly.loop_exit4
                                        #   in Loop: Header=BB2_14 Depth=1
	addq	$6144, %r8              # imm = 0x1800
	cmpq	$1535, %r15             # imm = 0x5FF
	leaq	1(%r15), %r15
	jl	.LBB2_14
	jmp	.LBB2_10
.LBB2_1:
	xorl	%r9d, %r9d
	movsd	.LCPI2_0(%rip), %xmm0   # xmm0 = mem[0],zero
	movl	$A+8, %r8d
	.align	16, 0x90
.LBB2_2:                                # %.preheader.i
                                        # =>This Loop Header: Depth=1
                                        #     Child Loop BB2_3 Depth 2
	xorl	%esi, %esi
	.align	16, 0x90
.LBB2_3:                                #   Parent Loop BB2_2 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movl	%esi, %ecx
	imull	%edx, %ecx
	movl	%ecx, %edi
	sarl	$31, %edi
	shrl	$22, %edi
	leal	(%rdi,%rcx), %edi
	andl	$-1024, %edi            # imm = 0xFFFFFFFFFFFFFC00
	subl	%edi, %ecx
	orl	$1, %ecx
	xorps	%xmm1, %xmm1
	cvtsi2sdl	%ecx, %xmm1
	mulsd	%xmm0, %xmm1
	cvtsd2ss	%xmm1, %xmm1
	movq	%rdx, %rcx
	shlq	$11, %rcx
	leaq	(%rcx,%rcx,2), %rcx
	movss	%xmm1, A(%rcx,%rsi,4)
	movss	%xmm1, B(%rcx,%rsi,4)
	movq	%rsi, %rax
	orq	$1, %rax
	movl	%eax, %ebx
	imull	%edx, %ebx
	movl	%ebx, %edi
	sarl	$31, %edi
	shrl	$22, %edi
	leal	(%rdi,%rbx), %edi
	andl	$-1024, %edi            # imm = 0xFFFFFFFFFFFFFC00
	negl	%edi
	leal	1(%rbx,%rdi), %edi
	cvtsi2sdl	%edi, %xmm1
	mulsd	%xmm0, %xmm1
	cvtsd2ss	%xmm1, %xmm1
	movss	%xmm1, A(%rcx,%rax,4)
	movss	%xmm1, B(%rcx,%rax,4)
	addq	$2, %rsi
	cmpq	$1536, %rsi             # imm = 0x600
	jne	.LBB2_3
# BB#4:                                 #   in Loop: Header=BB2_2 Depth=1
	incq	%rdx
	cmpq	$1536, %rdx             # imm = 0x600
	jne	.LBB2_2
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
	leaq	(%r9,%r9,2), %rax
	shlq	$11, %rax
	leaq	C(%rax,%rdx,4), %rsi
	movl	$0, C(%rax,%rdx,4)
	xorpd	%xmm0, %xmm0
	movq	$-9437184, %rdi         # imm = 0xFFFFFFFFFF700000
	movq	%r8, %rcx
	.align	16, 0x90
.LBB2_7:                                #   Parent Loop BB2_5 Depth=1
                                        #     Parent Loop BB2_6 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	movss	-8(%rcx), %xmm1         # xmm1 = mem[0],zero,zero,zero
	movss	-4(%rcx), %xmm2         # xmm2 = mem[0],zero,zero,zero
	mulss	B+9437184(%rdi,%rdx,4), %xmm1
	addss	%xmm0, %xmm1
	mulss	B+9443328(%rdi,%rdx,4), %xmm2
	addss	%xmm1, %xmm2
	movss	(%rcx), %xmm0           # xmm0 = mem[0],zero,zero,zero
	mulss	B+9449472(%rdi,%rdx,4), %xmm0
	addss	%xmm2, %xmm0
	addq	$12, %rcx
	addq	$18432, %rdi            # imm = 0x4800
	jne	.LBB2_7
# BB#8:                                 #   in Loop: Header=BB2_6 Depth=2
	movss	%xmm0, (%rsi)
	incq	%rdx
	cmpq	$1536, %rdx             # imm = 0x600
	jne	.LBB2_6
# BB#9:                                 # %init_array.exit
                                        #   in Loop: Header=BB2_5 Depth=1
	incq	%r9
	addq	$6144, %r8              # imm = 0x1800
	cmpq	$1536, %r9              # imm = 0x600
	jne	.LBB2_5
.LBB2_10:                               # %polly.merge_new_and_old
	xorl	%eax, %eax
	addq	$16, %rsp
	popq	%rbx
	popq	%r14
	popq	%r15
	retq
.Lfunc_end2:
	.size	main, .Lfunc_end2-main
	.cfi_endproc

	.section	.rodata.cst8,"aM",@progbits,8
	.align	8
.LCPI3_0:
	.quad	4602678819172646912     # double 0.5
	.text
	.align	16, 0x90
	.type	init_array.polly.subfn,@function
init_array.polly.subfn:                 # @init_array.polly.subfn
	.cfi_startproc
# BB#0:                                 # %polly.par.setup
	pushq	%r15
.Ltmp19:
	.cfi_def_cfa_offset 16
	pushq	%r14
.Ltmp20:
	.cfi_def_cfa_offset 24
	pushq	%rbx
.Ltmp21:
	.cfi_def_cfa_offset 32
	subq	$16, %rsp
.Ltmp22:
	.cfi_def_cfa_offset 48
.Ltmp23:
	.cfi_offset %rbx, -32
.Ltmp24:
	.cfi_offset %r14, -24
.Ltmp25:
	.cfi_offset %r15, -16
	leaq	8(%rsp), %r14
	leaq	(%rsp), %r15
	jmp	.LBB3_1
	.align	16, 0x90
.LBB3_2:                                # %polly.par.loadIVBounds
                                        #   in Loop: Header=BB3_1 Depth=1
	movq	8(%rsp), %rax
	movq	(%rsp), %r8
	decq	%r8
	movsd	.LCPI3_0(%rip), %xmm1   # xmm1 = mem[0],zero
	.align	16, 0x90
.LBB3_5:                                # %polly.loop_preheader3
                                        #   Parent Loop BB3_1 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB3_3 Depth 3
	leal	(%rax,%rax), %r9d
	movq	%rax, %rcx
	shlq	$11, %rcx
	leaq	A(%rcx,%rcx,2), %r10
	leaq	B(%rcx,%rcx,2), %r11
	movq	%rax, %rcx
	shlq	$9, %rcx
	leaq	(%rcx,%rcx,2), %rcx
	leaq	A+4(,%rcx,4), %rbx
	leaq	B+4(,%rcx,4), %rcx
	xorl	%edx, %edx
	.align	16, 0x90
.LBB3_3:                                # %polly.stmt.
                                        #   Parent Loop BB3_1 Depth=1
                                        #     Parent Loop BB3_5 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	movl	%r9d, %edi
	imull	%edx, %edi
	movl	%edi, %esi
	sarl	$31, %esi
	shrl	$22, %esi
	leal	(%rsi,%rdi), %esi
	andl	$-1024, %esi            # imm = 0xFFFFFFFFFFFFFC00
	subl	%esi, %edi
	orl	$1, %edi
	xorps	%xmm0, %xmm0
	cvtsi2sdl	%edi, %xmm0
	mulsd	%xmm1, %xmm0
	cvtsd2ss	%xmm0, %xmm0
	movss	%xmm0, (%r10,%rdx,8)
	movss	%xmm0, (%r11,%rdx,8)
	leal	1(%rdx,%rdx), %esi
	imull	%eax, %esi
	movl	%esi, %edi
	sarl	$31, %edi
	shrl	$22, %edi
	leal	(%rdi,%rsi), %edi
	andl	$-1024, %edi            # imm = 0xFFFFFFFFFFFFFC00
	negl	%edi
	leal	1(%rsi,%rdi), %esi
	xorps	%xmm0, %xmm0
	cvtsi2sdl	%esi, %xmm0
	mulsd	%xmm1, %xmm0
	cvtsd2ss	%xmm0, %xmm0
	movss	%xmm0, (%rbx,%rdx,8)
	movss	%xmm0, (%rcx,%rdx,8)
	cmpq	$767, %rdx              # imm = 0x2FF
	leaq	1(%rdx), %rdx
	jl	.LBB3_3
# BB#4:                                 # %polly.loop_exit4
                                        #   in Loop: Header=BB3_5 Depth=2
	leaq	-1(%r8), %rcx
	cmpq	%rcx, %rax
	leaq	1(%rax), %rax
	jle	.LBB3_5
.LBB3_1:                                # %polly.par.checkNext
                                        # =>This Loop Header: Depth=1
                                        #     Child Loop BB3_5 Depth 2
                                        #       Child Loop BB3_3 Depth 3
	movq	%r14, %rdi
	movq	%r15, %rsi
	callq	GOMP_loop_runtime_next
	testb	%al, %al
	jne	.LBB3_2
# BB#6:                                 # %polly.par.exit
	callq	GOMP_loop_end_nowait
	addq	$16, %rsp
	popq	%rbx
	popq	%r14
	popq	%r15
	retq
.Lfunc_end3:
	.size	init_array.polly.subfn, .Lfunc_end3-init_array.polly.subfn
	.cfi_endproc

	.section	.rodata.cst8,"aM",@progbits,8
	.align	8
.LCPI4_0:
	.quad	4602678819172646912     # double 0.5
	.text
	.align	16, 0x90
	.type	main.polly.subfn,@function
main.polly.subfn:                       # @main.polly.subfn
	.cfi_startproc
# BB#0:                                 # %polly.par.setup
	pushq	%r15
.Ltmp26:
	.cfi_def_cfa_offset 16
	pushq	%r14
.Ltmp27:
	.cfi_def_cfa_offset 24
	pushq	%rbx
.Ltmp28:
	.cfi_def_cfa_offset 32
	subq	$16, %rsp
.Ltmp29:
	.cfi_def_cfa_offset 48
.Ltmp30:
	.cfi_offset %rbx, -32
.Ltmp31:
	.cfi_offset %r14, -24
.Ltmp32:
	.cfi_offset %r15, -16
	leaq	8(%rsp), %r14
	leaq	(%rsp), %r15
	jmp	.LBB4_1
	.align	16, 0x90
.LBB4_2:                                # %polly.par.loadIVBounds
                                        #   in Loop: Header=BB4_1 Depth=1
	movq	8(%rsp), %rax
	movq	(%rsp), %r8
	decq	%r8
	movsd	.LCPI4_0(%rip), %xmm1   # xmm1 = mem[0],zero
	.align	16, 0x90
.LBB4_5:                                # %polly.loop_preheader3
                                        #   Parent Loop BB4_1 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB4_3 Depth 3
	leal	(%rax,%rax), %r9d
	movq	%rax, %rcx
	shlq	$11, %rcx
	leaq	A(%rcx,%rcx,2), %r10
	leaq	B(%rcx,%rcx,2), %r11
	movq	%rax, %rcx
	shlq	$9, %rcx
	leaq	(%rcx,%rcx,2), %rcx
	leaq	A+4(,%rcx,4), %rbx
	leaq	B+4(,%rcx,4), %rcx
	xorl	%edx, %edx
	.align	16, 0x90
.LBB4_3:                                # %polly.stmt.
                                        #   Parent Loop BB4_1 Depth=1
                                        #     Parent Loop BB4_5 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	movl	%r9d, %edi
	imull	%edx, %edi
	movl	%edi, %esi
	sarl	$31, %esi
	shrl	$22, %esi
	leal	(%rsi,%rdi), %esi
	andl	$-1024, %esi            # imm = 0xFFFFFFFFFFFFFC00
	subl	%esi, %edi
	orl	$1, %edi
	xorps	%xmm0, %xmm0
	cvtsi2sdl	%edi, %xmm0
	mulsd	%xmm1, %xmm0
	cvtsd2ss	%xmm0, %xmm0
	movss	%xmm0, (%r10,%rdx,8)
	movss	%xmm0, (%r11,%rdx,8)
	leal	1(%rdx,%rdx), %esi
	imull	%eax, %esi
	movl	%esi, %edi
	sarl	$31, %edi
	shrl	$22, %edi
	leal	(%rdi,%rsi), %edi
	andl	$-1024, %edi            # imm = 0xFFFFFFFFFFFFFC00
	negl	%edi
	leal	1(%rsi,%rdi), %esi
	xorps	%xmm0, %xmm0
	cvtsi2sdl	%esi, %xmm0
	mulsd	%xmm1, %xmm0
	cvtsd2ss	%xmm0, %xmm0
	movss	%xmm0, (%rbx,%rdx,8)
	movss	%xmm0, (%rcx,%rdx,8)
	cmpq	$767, %rdx              # imm = 0x2FF
	leaq	1(%rdx), %rdx
	jl	.LBB4_3
# BB#4:                                 # %polly.loop_exit4
                                        #   in Loop: Header=BB4_5 Depth=2
	leaq	-1(%r8), %rcx
	cmpq	%rcx, %rax
	leaq	1(%rax), %rax
	jle	.LBB4_5
.LBB4_1:                                # %polly.par.checkNext
                                        # =>This Loop Header: Depth=1
                                        #     Child Loop BB4_5 Depth 2
                                        #       Child Loop BB4_3 Depth 3
	movq	%r14, %rdi
	movq	%r15, %rsi
	callq	GOMP_loop_runtime_next
	testb	%al, %al
	jne	.LBB4_2
# BB#6:                                 # %polly.par.exit
	callq	GOMP_loop_end_nowait
	addq	$16, %rsp
	popq	%rbx
	popq	%r14
	popq	%r15
	retq
.Lfunc_end4:
	.size	main.polly.subfn, .Lfunc_end4-main.polly.subfn
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
