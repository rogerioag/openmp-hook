	.text
	.file	"matmul.polly.interchanged+tiled+vector+openmp.ll"
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
# BB#0:                                 # %entry
	pushq	%rbp
.Ltmp0:
	.cfi_def_cfa_offset 16
.Ltmp1:
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
.Ltmp2:
	.cfi_def_cfa_register %rbp
	pushq	%r15
	pushq	%r14
	pushq	%rbx
	subq	$40, %rsp
.Ltmp3:
	.cfi_offset %rbx, -40
.Ltmp4:
	.cfi_offset %r14, -32
.Ltmp5:
	.cfi_offset %r15, -24
	leaq	-32(%rbp), %rsi
	movl	$init_array.omp_subfn, %edi
	xorl	%edx, %edx
	xorl	%ecx, %ecx
	movl	$1536, %r8d             # imm = 0x600
	movl	$1, %r9d
	callq	GOMP_parallel_loop_runtime_start
	leaq	-40(%rbp), %rdi
	leaq	-48(%rbp), %rsi
	callq	GOMP_loop_runtime_next
	testb	%al, %al
	je	.LBB0_4
# BB#1:
	leaq	-40(%rbp), %r14
	leaq	-48(%rbp), %r15
	.align	16, 0x90
.LBB0_2:                                # %omp.loadIVBounds.i
                                        # =>This Loop Header: Depth=1
                                        #     Child Loop BB0_8 Depth 2
                                        #       Child Loop BB0_5 Depth 3
	movq	-40(%rbp), %rax
	movq	-48(%rbp), %rcx
	leaq	-1(%rcx), %rdx
	cmpq	%rdx, %rax
	jg	.LBB0_3
# BB#7:                                 # %polly.loop_preheader4.preheader.i
                                        #   in Loop: Header=BB0_2 Depth=1
	addq	$-2, %rcx
	.align	16, 0x90
.LBB0_8:                                # %polly.loop_preheader4.i
                                        #   Parent Loop BB0_2 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB0_5 Depth 3
	xorl	%edx, %edx
	movsd	.LCPI0_0(%rip), %xmm1   # xmm1 = mem[0],zero
	.align	16, 0x90
.LBB0_5:                                # %polly.loop_header3.i
                                        #   Parent Loop BB0_2 Depth=1
                                        #     Parent Loop BB0_8 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	movl	%edx, %ebx
	imull	%eax, %ebx
	movq	%rax, %rdi
	shlq	$11, %rdi
	leaq	(%rdi,%rdi,2), %rdi
	movl	%ebx, %esi
	sarl	$31, %esi
	shrl	$22, %esi
	leal	(%rsi,%rbx), %esi
	andl	$-1024, %esi            # imm = 0xFFFFFFFFFFFFFC00
	negl	%esi
	leal	1(%rbx,%rsi), %esi
	cvtsi2sdl	%esi, %xmm0
	mulsd	%xmm1, %xmm0
	cvtsd2ss	%xmm0, %xmm0
	movss	%xmm0, A(%rdi,%rdx,4)
	movss	%xmm0, B(%rdi,%rdx,4)
	incq	%rdx
	cmpq	$1536, %rdx             # imm = 0x600
	jne	.LBB0_5
# BB#6:                                 # %polly.loop_exit5.i
                                        #   in Loop: Header=BB0_8 Depth=2
	cmpq	%rcx, %rax
	leaq	1(%rax), %rax
	jle	.LBB0_8
.LBB0_3:                                # %omp.checkNext.backedge.i
                                        #   in Loop: Header=BB0_2 Depth=1
	movq	%r14, %rdi
	movq	%r15, %rsi
	callq	GOMP_loop_runtime_next
	testb	%al, %al
	jne	.LBB0_2
.LBB0_4:                                # %init_array.omp_subfn.exit
	callq	GOMP_loop_end_nowait
	callq	GOMP_parallel_end
	addq	$40, %rsp
	popq	%rbx
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
.Lfunc_end0:
	.size	init_array, .Lfunc_end0-init_array
	.cfi_endproc

	.globl	print_array
	.align	16, 0x90
	.type	print_array,@function
print_array:                            # @print_array
	.cfi_startproc
# BB#0:                                 # %entry
	pushq	%rbp
.Ltmp6:
	.cfi_def_cfa_offset 16
.Ltmp7:
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
.Ltmp8:
	.cfi_def_cfa_register %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r12
	pushq	%rbx
.Ltmp9:
	.cfi_offset %rbx, -48
.Ltmp10:
	.cfi_offset %r12, -40
.Ltmp11:
	.cfi_offset %r14, -32
.Ltmp12:
	.cfi_offset %r15, -24
	movl	$C, %r14d
	xorl	%r15d, %r15d
	.align	16, 0x90
.LBB1_1:                                # %for.cond1.preheader
                                        # =>This Loop Header: Depth=1
                                        #     Child Loop BB1_2 Depth 2
	movq	stdout(%rip), %rcx
	movq	%r14, %r12
	xorl	%ebx, %ebx
	.align	16, 0x90
.LBB1_2:                                # %for.body3
                                        #   Parent Loop BB1_1 Depth=1
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
# BB#3:                                 # %if.then
                                        #   in Loop: Header=BB1_2 Depth=2
	movq	stdout(%rip), %rsi
	movl	$10, %edi
	callq	fputc
.LBB1_4:                                # %for.inc
                                        #   in Loop: Header=BB1_2 Depth=2
	incq	%rbx
	movq	stdout(%rip), %rcx
	addq	$4, %r12
	cmpq	$1536, %rbx             # imm = 0x600
	jne	.LBB1_2
# BB#5:                                 # %for.end
                                        #   in Loop: Header=BB1_1 Depth=1
	movl	$10, %edi
	movq	%rcx, %rsi
	callq	fputc
	incq	%r15
	addq	$6144, %r14             # imm = 0x1800
	cmpq	$1536, %r15             # imm = 0x600
	jne	.LBB1_1
# BB#6:                                 # %for.end12
	popq	%rbx
	popq	%r12
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
.Lfunc_end1:
	.size	print_array, .Lfunc_end1-print_array
	.cfi_endproc

	.globl	main
	.align	16, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# BB#0:                                 # %entry
	pushq	%rbp
.Ltmp13:
	.cfi_def_cfa_offset 16
.Ltmp14:
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
.Ltmp15:
	.cfi_def_cfa_register %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$24, %rsp
.Ltmp16:
	.cfi_offset %rbx, -56
.Ltmp17:
	.cfi_offset %r12, -48
.Ltmp18:
	.cfi_offset %r13, -40
.Ltmp19:
	.cfi_offset %r14, -32
.Ltmp20:
	.cfi_offset %r15, -24
	callq	init_array
	leaq	-48(%rbp), %rsi
	movl	$main.omp_subfn, %edi
	xorl	%edx, %edx
	xorl	%ecx, %ecx
	movl	$1536, %r8d             # imm = 0x600
	movl	$1, %r9d
	callq	GOMP_parallel_loop_runtime_start
	leaq	-56(%rbp), %rdi
	leaq	-64(%rbp), %rsi
	callq	GOMP_loop_runtime_next
	testb	%al, %al
	je	.LBB2_4
# BB#1:
	leaq	-56(%rbp), %r14
	leaq	-64(%rbp), %r15
	.align	16, 0x90
.LBB2_2:                                # %omp.loadIVBounds.i
                                        # =>This Loop Header: Depth=1
                                        #     Child Loop BB2_6 Depth 2
	movq	-56(%rbp), %r12
	movq	-64(%rbp), %r13
	leaq	-1(%r13), %rax
	cmpq	%rax, %r12
	jg	.LBB2_3
# BB#5:                                 # %polly.loop_preheader4.preheader.i
                                        #   in Loop: Header=BB2_2 Depth=1
	addq	$-2, %r13
	leaq	(%r12,%r12,2), %rax
	shlq	$11, %rax
	leaq	C(%rax), %rbx
	decq	%r12
	.align	16, 0x90
.LBB2_6:                                # %polly.loop_preheader4.i
                                        #   Parent Loop BB2_2 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	xorl	%esi, %esi
	movl	$6144, %edx             # imm = 0x1800
	movq	%rbx, %rdi
	callq	memset
	addq	$6144, %rbx             # imm = 0x1800
	incq	%r12
	cmpq	%r13, %r12
	jle	.LBB2_6
.LBB2_3:                                # %omp.checkNext.backedge.i
                                        #   in Loop: Header=BB2_2 Depth=1
	movq	%r14, %rdi
	movq	%r15, %rsi
	callq	GOMP_loop_runtime_next
	testb	%al, %al
	jne	.LBB2_2
.LBB2_4:                                # %main.omp_subfn.exit
	callq	GOMP_loop_end_nowait
	callq	GOMP_parallel_end
	leaq	-48(%rbp), %rbx
	movl	$main.omp_subfn1, %edi
	xorl	%edx, %edx
	xorl	%ecx, %ecx
	movl	$1536, %r8d             # imm = 0x600
	movl	$64, %r9d
	movq	%rbx, %rsi
	callq	GOMP_parallel_loop_runtime_start
	movq	%rbx, %rdi
	callq	main.omp_subfn1
	callq	GOMP_parallel_end
	xorl	%eax, %eax
	addq	$24, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
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
	.type	init_array.omp_subfn,@function
init_array.omp_subfn:                   # @init_array.omp_subfn
	.cfi_startproc
# BB#0:                                 # %omp.setup
	pushq	%r15
.Ltmp21:
	.cfi_def_cfa_offset 16
	pushq	%r14
.Ltmp22:
	.cfi_def_cfa_offset 24
	pushq	%rbx
.Ltmp23:
	.cfi_def_cfa_offset 32
	subq	$32, %rsp
.Ltmp24:
	.cfi_def_cfa_offset 64
.Ltmp25:
	.cfi_offset %rbx, -32
.Ltmp26:
	.cfi_offset %r14, -24
.Ltmp27:
	.cfi_offset %r15, -16
	leaq	24(%rsp), %rdi
	leaq	16(%rsp), %rsi
	callq	GOMP_loop_runtime_next
	testb	%al, %al
	je	.LBB3_4
# BB#1:
	leaq	24(%rsp), %r14
	leaq	16(%rsp), %r15
	.align	16, 0x90
.LBB3_2:                                # %omp.loadIVBounds
                                        # =>This Loop Header: Depth=1
                                        #     Child Loop BB3_8 Depth 2
                                        #       Child Loop BB3_5 Depth 3
	movq	24(%rsp), %rax
	movq	16(%rsp), %rcx
	leaq	-1(%rcx), %rdx
	cmpq	%rdx, %rax
	jg	.LBB3_3
# BB#7:                                 # %polly.loop_preheader4.preheader
                                        #   in Loop: Header=BB3_2 Depth=1
	addq	$-2, %rcx
	.align	16, 0x90
.LBB3_8:                                # %polly.loop_preheader4
                                        #   Parent Loop BB3_2 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB3_5 Depth 3
	xorl	%edx, %edx
	movsd	.LCPI3_0(%rip), %xmm1   # xmm1 = mem[0],zero
	.align	16, 0x90
.LBB3_5:                                # %polly.loop_header3
                                        #   Parent Loop BB3_2 Depth=1
                                        #     Parent Loop BB3_8 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	movl	%edx, %ebx
	imull	%eax, %ebx
	movq	%rax, %rdi
	shlq	$11, %rdi
	leaq	(%rdi,%rdi,2), %rdi
	movl	%ebx, %esi
	sarl	$31, %esi
	shrl	$22, %esi
	leal	(%rsi,%rbx), %esi
	andl	$-1024, %esi            # imm = 0xFFFFFFFFFFFFFC00
	negl	%esi
	leal	1(%rbx,%rsi), %esi
	cvtsi2sdl	%esi, %xmm0
	mulsd	%xmm1, %xmm0
	cvtsd2ss	%xmm0, %xmm0
	movss	%xmm0, A(%rdi,%rdx,4)
	movss	%xmm0, B(%rdi,%rdx,4)
	incq	%rdx
	cmpq	$1536, %rdx             # imm = 0x600
	jne	.LBB3_5
# BB#6:                                 # %polly.loop_exit5
                                        #   in Loop: Header=BB3_8 Depth=2
	cmpq	%rcx, %rax
	leaq	1(%rax), %rax
	jle	.LBB3_8
.LBB3_3:                                # %omp.checkNext.backedge
                                        #   in Loop: Header=BB3_2 Depth=1
	movq	%r14, %rdi
	movq	%r15, %rsi
	callq	GOMP_loop_runtime_next
	testb	%al, %al
	jne	.LBB3_2
.LBB3_4:                                # %omp.exit
	callq	GOMP_loop_end_nowait
	addq	$32, %rsp
	popq	%rbx
	popq	%r14
	popq	%r15
	retq
.Lfunc_end3:
	.size	init_array.omp_subfn, .Lfunc_end3-init_array.omp_subfn
	.cfi_endproc

	.align	16, 0x90
	.type	main.omp_subfn,@function
main.omp_subfn:                         # @main.omp_subfn
	.cfi_startproc
# BB#0:                                 # %omp.setup
	pushq	%r15
.Ltmp28:
	.cfi_def_cfa_offset 16
	pushq	%r14
.Ltmp29:
	.cfi_def_cfa_offset 24
	pushq	%r13
.Ltmp30:
	.cfi_def_cfa_offset 32
	pushq	%r12
.Ltmp31:
	.cfi_def_cfa_offset 40
	pushq	%rbx
.Ltmp32:
	.cfi_def_cfa_offset 48
	subq	$16, %rsp
.Ltmp33:
	.cfi_def_cfa_offset 64
.Ltmp34:
	.cfi_offset %rbx, -48
.Ltmp35:
	.cfi_offset %r12, -40
.Ltmp36:
	.cfi_offset %r13, -32
.Ltmp37:
	.cfi_offset %r14, -24
.Ltmp38:
	.cfi_offset %r15, -16
	leaq	8(%rsp), %rdi
	leaq	(%rsp), %rsi
	callq	GOMP_loop_runtime_next
	testb	%al, %al
	je	.LBB4_4
# BB#1:
	leaq	8(%rsp), %r14
	leaq	(%rsp), %r15
	.align	16, 0x90
.LBB4_2:                                # %omp.loadIVBounds
                                        # =>This Loop Header: Depth=1
                                        #     Child Loop BB4_6 Depth 2
	movq	8(%rsp), %r12
	movq	(%rsp), %r13
	leaq	-1(%r13), %rax
	cmpq	%rax, %r12
	jg	.LBB4_3
# BB#5:                                 # %polly.loop_preheader4.preheader
                                        #   in Loop: Header=BB4_2 Depth=1
	addq	$-2, %r13
	leaq	(%r12,%r12,2), %rax
	shlq	$11, %rax
	leaq	C(%rax), %rbx
	decq	%r12
	.align	16, 0x90
.LBB4_6:                                # %polly.loop_preheader4
                                        #   Parent Loop BB4_2 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	xorl	%esi, %esi
	movl	$6144, %edx             # imm = 0x1800
	movq	%rbx, %rdi
	callq	memset
	addq	$6144, %rbx             # imm = 0x1800
	incq	%r12
	cmpq	%r13, %r12
	jle	.LBB4_6
.LBB4_3:                                # %omp.checkNext.backedge
                                        #   in Loop: Header=BB4_2 Depth=1
	movq	%r14, %rdi
	movq	%r15, %rsi
	callq	GOMP_loop_runtime_next
	testb	%al, %al
	jne	.LBB4_2
.LBB4_4:                                # %omp.exit
	callq	GOMP_loop_end_nowait
	addq	$16, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	retq
.Lfunc_end4:
	.size	main.omp_subfn, .Lfunc_end4-main.omp_subfn
	.cfi_endproc

	.align	16, 0x90
	.type	main.omp_subfn1,@function
main.omp_subfn1:                        # @main.omp_subfn1
	.cfi_startproc
# BB#0:                                 # %omp.setup
	pushq	%rbp
.Ltmp39:
	.cfi_def_cfa_offset 16
	pushq	%r15
.Ltmp40:
	.cfi_def_cfa_offset 24
	pushq	%r14
.Ltmp41:
	.cfi_def_cfa_offset 32
	pushq	%r13
.Ltmp42:
	.cfi_def_cfa_offset 40
	pushq	%r12
.Ltmp43:
	.cfi_def_cfa_offset 48
	pushq	%rbx
.Ltmp44:
	.cfi_def_cfa_offset 56
	subq	$72, %rsp
.Ltmp45:
	.cfi_def_cfa_offset 128
.Ltmp46:
	.cfi_offset %rbx, -56
.Ltmp47:
	.cfi_offset %r12, -48
.Ltmp48:
	.cfi_offset %r13, -40
.Ltmp49:
	.cfi_offset %r14, -32
.Ltmp50:
	.cfi_offset %r15, -24
.Ltmp51:
	.cfi_offset %rbp, -16
	jmp	.LBB5_1
	.align	16, 0x90
.LBB5_2:                                # %omp.loadIVBounds
                                        #   in Loop: Header=BB5_1 Depth=1
	movq	64(%rsp), %r8
	movq	56(%rsp), %rax
	movq	%rax, 8(%rsp)           # 8-byte Spill
	leaq	-1(%rax), %rax
	cmpq	%rax, %r8
	jg	.LBB5_1
# BB#3:                                 # %polly.loop_preheader4.preheader
                                        #   in Loop: Header=BB5_1 Depth=1
	addq	$-65, 8(%rsp)           # 8-byte Folded Spill
	movq	%r8, %rax
	shlq	$9, %rax
	leaq	(%rax,%rax,2), %rax
	leaq	C+16(,%rax,4), %rax
	movq	%rax, 16(%rsp)          # 8-byte Spill
	leaq	-1(%r8), %rax
	movq	%rax, 40(%rsp)          # 8-byte Spill
	.align	16, 0x90
.LBB5_7:                                # %polly.loop_preheader4
                                        #   Parent Loop BB5_1 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB5_8 Depth 3
                                        #         Child Loop BB5_9 Depth 4
                                        #           Child Loop BB5_12 Depth 5
                                        #             Child Loop BB5_17 Depth 6
                                        #               Child Loop BB5_18 Depth 7
                                        #           Child Loop BB5_14 Depth 5
	movq	%r8, 48(%rsp)           # 8-byte Spill
	leaq	62(%r8), %rdi
	xorl	%esi, %esi
	.align	16, 0x90
.LBB5_8:                                # %polly.loop_preheader11
                                        #   Parent Loop BB5_1 Depth=1
                                        #     Parent Loop BB5_7 Depth=2
                                        # =>    This Loop Header: Depth=3
                                        #         Child Loop BB5_9 Depth 4
                                        #           Child Loop BB5_12 Depth 5
                                        #             Child Loop BB5_17 Depth 6
                                        #               Child Loop BB5_18 Depth 7
                                        #           Child Loop BB5_14 Depth 5
	movq	%rsi, 24(%rsp)          # 8-byte Spill
	leaq	-1(%rsi), %rax
	leaq	-4(%rsi), %rcx
	testq	%rax, %rax
	cmovnsq	%rax, %rcx
	movq	%rcx, %r9
	sarq	$63, %r9
	shrq	$62, %r9
	addq	%rcx, %r9
	movq	%r9, %rdx
	sarq	$2, %rdx
	andq	$-4, %r9
	leaq	4(%r9), %rcx
	movq	%rsi, %rbx
	orq	$63, %rbx
	leaq	-4(%rbx), %rsi
	shlq	$4, %rdx
	leaq	B+16(%rdx), %rax
	movq	16(%rsp), %rbp          # 8-byte Reload
	leaq	(%rdx,%rbp), %rdx
	movq	%rdx, 32(%rsp)          # 8-byte Spill
	xorl	%ebp, %ebp
	.align	16, 0x90
.LBB5_9:                                # %polly.loop_header10
                                        #   Parent Loop BB5_1 Depth=1
                                        #     Parent Loop BB5_7 Depth=2
                                        #       Parent Loop BB5_8 Depth=3
                                        # =>      This Loop Header: Depth=4
                                        #           Child Loop BB5_12 Depth 5
                                        #             Child Loop BB5_17 Depth 6
                                        #               Child Loop BB5_18 Depth 7
                                        #           Child Loop BB5_14 Depth 5
	movabsq	$9223372036854775744, %rdx # imm = 0x7FFFFFFFFFFFFFC0
	cmpq	%rdx, %r8
	jg	.LBB5_15
# BB#10:                                # %polly.loop_header17.preheader
                                        #   in Loop: Header=BB5_9 Depth=4
	movq	%rbp, %r14
	orq	$63, %r14
	cmpq	%r14, %rbp
	movq	40(%rsp), %rdx          # 8-byte Reload
	jle	.LBB5_11
	.align	16, 0x90
.LBB5_14:                               # %polly.loop_exit28.us
                                        #   Parent Loop BB5_1 Depth=1
                                        #     Parent Loop BB5_7 Depth=2
                                        #       Parent Loop BB5_8 Depth=3
                                        #         Parent Loop BB5_9 Depth=4
                                        # =>        This Inner Loop Header: Depth=5
	incq	%rdx
	cmpq	%rdi, %rdx
	jle	.LBB5_14
	jmp	.LBB5_15
	.align	16, 0x90
.LBB5_11:                               #   in Loop: Header=BB5_9 Depth=4
	decq	%r14
	movq	32(%rsp), %r12          # 8-byte Reload
	movq	48(%rsp), %r13          # 8-byte Reload
	.align	16, 0x90
.LBB5_12:                               # %polly.loop_header26.preheader
                                        #   Parent Loop BB5_1 Depth=1
                                        #     Parent Loop BB5_7 Depth=2
                                        #       Parent Loop BB5_8 Depth=3
                                        #         Parent Loop BB5_9 Depth=4
                                        # =>        This Loop Header: Depth=5
                                        #             Child Loop BB5_17 Depth 6
                                        #               Child Loop BB5_18 Depth 7
	cmpq	%rbx, %rcx
	movq	%rax, %r11
	movq	%rbp, %r15
	jg	.LBB5_13
	.align	16, 0x90
.LBB5_17:                               # %polly.loop_header35.preheader
                                        #   Parent Loop BB5_1 Depth=1
                                        #     Parent Loop BB5_7 Depth=2
                                        #       Parent Loop BB5_8 Depth=3
                                        #         Parent Loop BB5_9 Depth=4
                                        #           Parent Loop BB5_12 Depth=5
                                        # =>          This Loop Header: Depth=6
                                        #               Child Loop BB5_18 Depth 7
	leaq	(%r13,%r13,2), %rdx
	shlq	$11, %rdx
	movss	A(%rdx,%r15,4), %xmm0   # xmm0 = mem[0],zero,zero,zero
	shufps	$0, %xmm0, %xmm0        # xmm0 = xmm0[0,0,0,0]
	movq	%r12, %r8
	movq	%r11, %r10
	movq	%r9, %rdx
	.align	16, 0x90
.LBB5_18:                               # %polly.loop_header35
                                        #   Parent Loop BB5_1 Depth=1
                                        #     Parent Loop BB5_7 Depth=2
                                        #       Parent Loop BB5_8 Depth=3
                                        #         Parent Loop BB5_9 Depth=4
                                        #           Parent Loop BB5_12 Depth=5
                                        #             Parent Loop BB5_17 Depth=6
                                        # =>            This Inner Loop Header: Depth=7
	movaps	(%r10), %xmm1
	mulps	%xmm0, %xmm1
	addps	(%r8), %xmm1
	movaps	%xmm1, (%r8)
	addq	$4, %rdx
	addq	$16, %r10
	addq	$16, %r8
	cmpq	%rsi, %rdx
	jle	.LBB5_18
# BB#16:                                # %polly.loop_exit37
                                        #   in Loop: Header=BB5_17 Depth=6
	addq	$6144, %r11             # imm = 0x1800
	cmpq	%r14, %r15
	leaq	1(%r15), %r15
	jle	.LBB5_17
.LBB5_13:                               # %polly.loop_exit28
                                        #   in Loop: Header=BB5_12 Depth=5
	addq	$6144, %r12             # imm = 0x1800
	cmpq	%rdi, %r13
	leaq	1(%r13), %r13
	jle	.LBB5_12
.LBB5_15:                               # %polly.loop_exit19
                                        #   in Loop: Header=BB5_9 Depth=4
	addq	$393216, %rax           # imm = 0x60000
	cmpq	$1472, %rbp             # imm = 0x5C0
	leaq	64(%rbp), %rbp
	movq	48(%rsp), %r8           # 8-byte Reload
	jl	.LBB5_9
# BB#5:                                 # %polly.loop_exit12
                                        #   in Loop: Header=BB5_8 Depth=3
	movq	24(%rsp), %rsi          # 8-byte Reload
	cmpq	$1472, %rsi             # imm = 0x5C0
	leaq	64(%rsi), %rsi
	jl	.LBB5_8
# BB#6:                                 # %polly.loop_exit5
                                        #   in Loop: Header=BB5_7 Depth=2
	addq	$393216, 16(%rsp)       # 8-byte Folded Spill
                                        # imm = 0x60000
	addq	$64, 40(%rsp)           # 8-byte Folded Spill
	cmpq	8(%rsp), %r8            # 8-byte Folded Reload
	leaq	64(%r8), %r8
	jle	.LBB5_7
.LBB5_1:                                # %omp.setup
                                        # =>This Loop Header: Depth=1
                                        #     Child Loop BB5_7 Depth 2
                                        #       Child Loop BB5_8 Depth 3
                                        #         Child Loop BB5_9 Depth 4
                                        #           Child Loop BB5_12 Depth 5
                                        #             Child Loop BB5_17 Depth 6
                                        #               Child Loop BB5_18 Depth 7
                                        #           Child Loop BB5_14 Depth 5
	leaq	64(%rsp), %rdi
	leaq	56(%rsp), %rsi
	callq	GOMP_loop_runtime_next
	testb	%al, %al
	jne	.LBB5_2
# BB#4:                                 # %omp.exit
	callq	GOMP_loop_end_nowait
	addq	$72, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
.Lfunc_end5:
	.size	main.omp_subfn1, .Lfunc_end5-main.omp_subfn1
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

	.section	".note.GNU-stack","",@progbits
