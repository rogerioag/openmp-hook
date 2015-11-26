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
	movsd	.LCPI0_0(%rip), %xmm0
	.align	16, 0x90
.LBB0_2:                                # %vector.ph
                                        # =>This Loop Header: Depth=1
                                        #     Child Loop BB0_3 Depth 2
	xorl	%ecx, %ecx
	.align	16, 0x90
.LBB0_3:                                # %vector.body
                                        #   Parent Loop BB0_2 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movq	%rcx, %rdx
	orq	$1, %rdx
	movl	%ecx, %ebx
	imull	%eax, %ebx
	movl	%edx, %edi
	imull	%eax, %edi
	movl	%ebx, %esi
	sarl	$31, %esi
	shrl	$22, %esi
	addl	%ebx, %esi
	andl	$-1024, %esi            # imm = 0xFFFFFFFFFFFFFC00
	subl	%esi, %ebx
	movl	%edi, %esi
	sarl	$31, %esi
	shrl	$22, %esi
	addl	%edi, %esi
	andl	$-1024, %esi            # imm = 0xFFFFFFFFFFFFFC00
	negl	%esi
	orl	$1, %ebx
	leal	1(%rdi,%rsi), %esi
	cvtsi2sdl	%ebx, %xmm1
	cvtsi2sdl	%esi, %xmm2
	mulsd	%xmm0, %xmm1
	mulsd	%xmm0, %xmm2
	cvtsd2ss	%xmm1, %xmm1
	cvtsd2ss	%xmm2, %xmm2
	movq	%rax, %rsi
	shlq	$11, %rsi
	leaq	(%rsi,%rsi,2), %rsi
	movss	%xmm1, A(%rsi,%rcx,4)
	movss	%xmm2, A(%rsi,%rdx,4)
	movss	%xmm1, B(%rsi,%rcx,4)
	movss	%xmm2, B(%rsi,%rdx,4)
	addq	$2, %rcx
	cmpq	$1536, %rcx             # imm = 0x600
	jne	.LBB0_3
# BB#4:                                 # %middle.block
                                        #   in Loop: Header=BB0_2 Depth=1
	incq	%rax
	cmpq	$1536, %rax             # imm = 0x600
	jne	.LBB0_2
.LBB0_5:                                # %polly.merge_new_and_old
	addq	$16, %rsp
	popq	%rbx
	retq
.Ltmp3:
	.size	init_array, .Ltmp3-init_array
	.cfi_endproc

	.globl	print_array
	.align	16, 0x90
	.type	print_array,@function
print_array:                            # @print_array
	.cfi_startproc
# BB#0:
	pushq	%r15
.Ltmp4:
	.cfi_def_cfa_offset 16
	pushq	%r14
.Ltmp5:
	.cfi_def_cfa_offset 24
	pushq	%r12
.Ltmp6:
	.cfi_def_cfa_offset 32
	pushq	%rbx
.Ltmp7:
	.cfi_def_cfa_offset 40
	pushq	%rax
.Ltmp8:
	.cfi_def_cfa_offset 48
.Ltmp9:
	.cfi_offset %rbx, -40
.Ltmp10:
	.cfi_offset %r12, -32
.Ltmp11:
	.cfi_offset %r14, -24
.Ltmp12:
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
	movss	(%r12), %xmm0
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
	imull	$80, %ecx, %ecx
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
.Ltmp13:
	.size	print_array, .Ltmp13-print_array
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
.Ltmp14:
	.cfi_def_cfa_offset 16
	pushq	%r14
.Ltmp15:
	.cfi_def_cfa_offset 24
	pushq	%rbx
.Ltmp16:
	.cfi_def_cfa_offset 32
	subq	$16, %rsp
.Ltmp17:
	.cfi_def_cfa_offset 48
.Ltmp18:
	.cfi_offset %rbx, -32
.Ltmp19:
	.cfi_offset %r14, -24
.Ltmp20:
	.cfi_offset %r15, -16
	xorl	%ecx, %ecx
	movl	$B, %eax
	movl	$A+9437184, %edx
	cmpq	%rax, %rdx
	setbe	%al
	movl	$A, %edx
	movl	$B+9437184, %esi
	cmpq	%rdx, %rsi
	setbe	%dl
	xorl	%r15d, %r15d
	orb	%al, %dl
	je	.LBB2_1
# BB#11:                                # %polly.start
	leaq	8(%rsp), %r14
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
	jmp	.LBB2_5
.LBB2_1:
	movsd	.LCPI2_0(%rip), %xmm0
	movl	$A+8, %r8d
	.align	16, 0x90
.LBB2_2:                                # %vector.ph
                                        # =>This Loop Header: Depth=1
                                        #     Child Loop BB2_3 Depth 2
	xorl	%edx, %edx
	.align	16, 0x90
.LBB2_3:                                # %vector.body
                                        #   Parent Loop BB2_2 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movq	%rdx, %rsi
	orq	$1, %rsi
	movl	%edx, %ebx
	imull	%ecx, %ebx
	movl	%esi, %edi
	imull	%ecx, %edi
	movl	%ebx, %eax
	sarl	$31, %eax
	shrl	$22, %eax
	addl	%ebx, %eax
	andl	$-1024, %eax            # imm = 0xFFFFFFFFFFFFFC00
	subl	%eax, %ebx
	movl	%edi, %eax
	sarl	$31, %eax
	shrl	$22, %eax
	addl	%edi, %eax
	andl	$-1024, %eax            # imm = 0xFFFFFFFFFFFFFC00
	negl	%eax
	orl	$1, %ebx
	leal	1(%rdi,%rax), %eax
	cvtsi2sdl	%ebx, %xmm1
	cvtsi2sdl	%eax, %xmm2
	mulsd	%xmm0, %xmm1
	mulsd	%xmm0, %xmm2
	cvtsd2ss	%xmm1, %xmm1
	cvtsd2ss	%xmm2, %xmm2
	movq	%rcx, %rax
	shlq	$11, %rax
	leaq	(%rax,%rax,2), %rax
	movss	%xmm1, A(%rax,%rdx,4)
	movss	%xmm2, A(%rax,%rsi,4)
	movss	%xmm1, B(%rax,%rdx,4)
	movss	%xmm2, B(%rax,%rsi,4)
	addq	$2, %rdx
	cmpq	$1536, %rdx             # imm = 0x600
	jne	.LBB2_3
# BB#4:                                 # %middle.block
                                        #   in Loop: Header=BB2_2 Depth=1
	incq	%rcx
	cmpq	$1536, %rcx             # imm = 0x600
	jne	.LBB2_2
	.align	16, 0x90
.LBB2_5:                                # %.preheader
                                        # =>This Loop Header: Depth=1
                                        #     Child Loop BB2_6 Depth 2
                                        #       Child Loop BB2_7 Depth 3
	xorl	%ecx, %ecx
	leaq	(%r15,%r15,2), %rdx
	shlq	$11, %rdx
	.align	16, 0x90
.LBB2_6:                                #   Parent Loop BB2_5 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB2_7 Depth 3
	leaq	C(%rdx,%rcx,4), %rsi
	movl	$0, C(%rdx,%rcx,4)
	xorps	%xmm0, %xmm0
	movq	$-9437184, %rdi         # imm = 0xFFFFFFFFFF700000
	movq	%r8, %rax
	.align	16, 0x90
.LBB2_7:                                #   Parent Loop BB2_5 Depth=1
                                        #     Parent Loop BB2_6 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	movss	-8(%rax), %xmm1
	movss	-4(%rax), %xmm2
	mulss	B+9437184(%rdi,%rcx,4), %xmm1
	addss	%xmm0, %xmm1
	mulss	B+9443328(%rdi,%rcx,4), %xmm2
	addss	%xmm1, %xmm2
	movss	(%rax), %xmm0
	mulss	B+9449472(%rdi,%rcx,4), %xmm0
	addss	%xmm2, %xmm0
	addq	$12, %rax
	addq	$18432, %rdi            # imm = 0x4800
	jne	.LBB2_7
# BB#8:                                 #   in Loop: Header=BB2_6 Depth=2
	movss	%xmm0, (%rsi)
	incq	%rcx
	cmpq	$1536, %rcx             # imm = 0x600
	jne	.LBB2_6
# BB#9:                                 # %init_array.exit
                                        #   in Loop: Header=BB2_5 Depth=1
	incq	%r15
	addq	$6144, %r8              # imm = 0x1800
	cmpq	$1536, %r15             # imm = 0x600
	jne	.LBB2_5
# BB#10:
	xorl	%eax, %eax
	addq	$16, %rsp
	popq	%rbx
	popq	%r14
	popq	%r15
	retq
.Ltmp21:
	.size	main, .Ltmp21-main
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
.Ltmp22:
	.cfi_def_cfa_offset 16
	pushq	%r14
.Ltmp23:
	.cfi_def_cfa_offset 24
	pushq	%r12
.Ltmp24:
	.cfi_def_cfa_offset 32
	pushq	%rbx
.Ltmp25:
	.cfi_def_cfa_offset 40
	subq	$24, %rsp
.Ltmp26:
	.cfi_def_cfa_offset 64
.Ltmp27:
	.cfi_offset %rbx, -40
.Ltmp28:
	.cfi_offset %r12, -32
.Ltmp29:
	.cfi_offset %r14, -24
.Ltmp30:
	.cfi_offset %r15, -16
	leaq	16(%rsp), %r14
	leaq	8(%rsp), %r15
	jmp	.LBB3_1
	.align	16, 0x90
.LBB3_2:                                # %polly.par.loadIVBounds
                                        #   in Loop: Header=BB3_1 Depth=1
	movq	16(%rsp), %r11
	movq	8(%rsp), %r8
	decq	%r8
	movsd	.LCPI3_0(%rip), %xmm2
	.align	16, 0x90
.LBB3_5:                                # %polly.loop_preheader3
                                        #   Parent Loop BB3_1 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB3_3 Depth 3
	leal	(%r11,%r11), %r9d
	movq	%r11, %rax
	shlq	$11, %rax
	leaq	A(%rax,%rax,2), %r10
	movq	%r11, %rcx
	shlq	$9, %rcx
	leaq	(%rcx,%rcx,2), %rcx
	leaq	A+4(,%rcx,4), %r12
	leaq	B(%rax,%rax,2), %rbx
	leaq	B+4(,%rcx,4), %rcx
	xorl	%edx, %edx
	.align	16, 0x90
.LBB3_3:                                # %polly.stmt.vector.body
                                        #   Parent Loop BB3_1 Depth=1
                                        #     Parent Loop BB3_5 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	movl	%r9d, %eax
	imull	%edx, %eax
	movl	%eax, %esi
	sarl	$31, %esi
	shrl	$22, %esi
	addl	%eax, %esi
	andl	$-1024, %esi            # imm = 0xFFFFFFFFFFFFFC00
	subl	%esi, %eax
	leal	1(%rdx,%rdx), %edi
	imull	%r11d, %edi
	movl	%edi, %esi
	sarl	$31, %esi
	shrl	$22, %esi
	addl	%edi, %esi
	andl	$-1024, %esi            # imm = 0xFFFFFFFFFFFFFC00
	negl	%esi
	orl	$1, %eax
	leal	1(%rdi,%rsi), %esi
	cvtsi2sdl	%eax, %xmm0
	cvtsi2sdl	%esi, %xmm1
	mulsd	%xmm2, %xmm0
	mulsd	%xmm2, %xmm1
	cvtsd2ss	%xmm0, %xmm0
	cvtsd2ss	%xmm1, %xmm1
	movss	%xmm0, (%r10,%rdx,8)
	movss	%xmm1, (%r12,%rdx,8)
	movss	%xmm0, (%rbx,%rdx,8)
	movss	%xmm1, (%rcx,%rdx,8)
	cmpq	$767, %rdx              # imm = 0x2FF
	leaq	1(%rdx), %rdx
	jl	.LBB3_3
# BB#4:                                 # %polly.loop_exit4
                                        #   in Loop: Header=BB3_5 Depth=2
	leaq	-1(%r8), %rcx
	cmpq	%rcx, %r11
	leaq	1(%r11), %r11
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
	addq	$24, %rsp
	popq	%rbx
	popq	%r12
	popq	%r14
	popq	%r15
	retq
.Ltmp31:
	.size	init_array.polly.subfn, .Ltmp31-init_array.polly.subfn
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
.Ltmp32:
	.cfi_def_cfa_offset 16
	pushq	%r14
.Ltmp33:
	.cfi_def_cfa_offset 24
	pushq	%r12
.Ltmp34:
	.cfi_def_cfa_offset 32
	pushq	%rbx
.Ltmp35:
	.cfi_def_cfa_offset 40
	subq	$24, %rsp
.Ltmp36:
	.cfi_def_cfa_offset 64
.Ltmp37:
	.cfi_offset %rbx, -40
.Ltmp38:
	.cfi_offset %r12, -32
.Ltmp39:
	.cfi_offset %r14, -24
.Ltmp40:
	.cfi_offset %r15, -16
	leaq	16(%rsp), %r14
	leaq	8(%rsp), %r15
	jmp	.LBB4_1
	.align	16, 0x90
.LBB4_2:                                # %polly.par.loadIVBounds
                                        #   in Loop: Header=BB4_1 Depth=1
	movq	16(%rsp), %r11
	movq	8(%rsp), %r8
	decq	%r8
	movsd	.LCPI4_0(%rip), %xmm2
	.align	16, 0x90
.LBB4_5:                                # %polly.loop_preheader3
                                        #   Parent Loop BB4_1 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB4_3 Depth 3
	leal	(%r11,%r11), %r9d
	movq	%r11, %rax
	shlq	$11, %rax
	leaq	A(%rax,%rax,2), %r10
	movq	%r11, %rcx
	shlq	$9, %rcx
	leaq	(%rcx,%rcx,2), %rcx
	leaq	A+4(,%rcx,4), %r12
	leaq	B(%rax,%rax,2), %rbx
	leaq	B+4(,%rcx,4), %rcx
	xorl	%edx, %edx
	.align	16, 0x90
.LBB4_3:                                # %polly.stmt.vector.body
                                        #   Parent Loop BB4_1 Depth=1
                                        #     Parent Loop BB4_5 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	movl	%r9d, %eax
	imull	%edx, %eax
	movl	%eax, %esi
	sarl	$31, %esi
	shrl	$22, %esi
	addl	%eax, %esi
	andl	$-1024, %esi            # imm = 0xFFFFFFFFFFFFFC00
	subl	%esi, %eax
	leal	1(%rdx,%rdx), %edi
	imull	%r11d, %edi
	movl	%edi, %esi
	sarl	$31, %esi
	shrl	$22, %esi
	addl	%edi, %esi
	andl	$-1024, %esi            # imm = 0xFFFFFFFFFFFFFC00
	negl	%esi
	orl	$1, %eax
	leal	1(%rdi,%rsi), %esi
	cvtsi2sdl	%eax, %xmm0
	cvtsi2sdl	%esi, %xmm1
	mulsd	%xmm2, %xmm0
	mulsd	%xmm2, %xmm1
	cvtsd2ss	%xmm0, %xmm0
	cvtsd2ss	%xmm1, %xmm1
	movss	%xmm0, (%r10,%rdx,8)
	movss	%xmm1, (%r12,%rdx,8)
	movss	%xmm0, (%rbx,%rdx,8)
	movss	%xmm1, (%rcx,%rdx,8)
	cmpq	$767, %rdx              # imm = 0x2FF
	leaq	1(%rdx), %rdx
	jl	.LBB4_3
# BB#4:                                 # %polly.loop_exit4
                                        #   in Loop: Header=BB4_5 Depth=2
	leaq	-1(%r8), %rcx
	cmpq	%rcx, %r11
	leaq	1(%r11), %r11
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
	addq	$24, %rsp
	popq	%rbx
	popq	%r12
	popq	%r14
	popq	%r15
	retq
.Ltmp41:
	.size	main.polly.subfn, .Ltmp41-main.polly.subfn
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

	.ident	"clang version 3.6.2 (tags/RELEASE_362/final 244750)"
	.section	".note.GNU-stack","",@progbits
