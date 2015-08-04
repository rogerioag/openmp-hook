	.text
	.file	"vectoradd.openmp.ll"
	.section	.rodata.cst16,"aM",@progbits,16
	.align	16
.LCPI0_0:
	.long	1056964608              # float 5.000000e-01
	.long	1056964608              # float 5.000000e-01
	.long	1056964608              # float 5.000000e-01
	.long	1056964608              # float 5.000000e-01
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
	movq	stdout(%rip), %rcx
	movl	$.L.str, %edi
	movl	$28, %esi
	movl	$1, %edx
	callq	fwrite
	movl	$h_b, %eax
	movl	$h_a+4096, %ecx
	cmpq	%rax, %rcx
	setbe	%al
	movl	$h_a, %ecx
	movl	$h_b+4096, %edx
	cmpq	%rcx, %rdx
	setbe	%cl
	orb	%al, %cl
	je	.LBB0_1
# BB#4:                                 # %polly.start
	leaq	8(%rsp), %rbx
	movl	$init_array.polly.subfn, %edi
	xorl	%edx, %edx
	xorl	%ecx, %ecx
	movl	$64, %r8d
	movl	$1, %r9d
	movq	%rbx, %rsi
	callq	GOMP_parallel_loop_runtime_start
	movq	%rbx, %rdi
	callq	init_array.polly.subfn
	callq	GOMP_parallel_end
	jmp	.LBB0_3
.LBB0_1:
	movq	$-4096, %rax            # imm = 0xFFFFFFFFFFFFF000
	movaps	.LCPI0_0(%rip), %xmm0   # xmm0 = [5.000000e-01,5.000000e-01,5.000000e-01,5.000000e-01]
	.align	16, 0x90
.LBB0_2:                                # %vector.body
                                        # =>This Inner Loop Header: Depth=1
	movaps	%xmm0, h_a+4096(%rax)
	movaps	%xmm0, h_a+4112(%rax)
	movaps	%xmm0, h_b+4096(%rax)
	movaps	%xmm0, h_b+4112(%rax)
	movaps	%xmm0, h_a+4128(%rax)
	movaps	%xmm0, h_a+4144(%rax)
	movaps	%xmm0, h_b+4128(%rax)
	movaps	%xmm0, h_b+4144(%rax)
	addq	$64, %rax
	jne	.LBB0_2
.LBB0_3:                                # %polly.merge_new_and_old
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
	pushq	%rbx
.Ltmp4:
	.cfi_def_cfa_offset 16
.Ltmp5:
	.cfi_offset %rbx, -16
	movq	stdout(%rip), %rcx
	movl	$.L.str1, %edi
	movl	$28, %esi
	movl	$1, %edx
	callq	fwrite
	xorl	%ebx, %ebx
	.align	16, 0x90
.LBB1_1:                                # =>This Inner Loop Header: Depth=1
	movq	stdout(%rip), %rdi
	movss	h_c(,%rbx,4), %xmm0
	cvtss2sd	%xmm0, %xmm0
	movl	$.L.str2, %esi
	movb	$1, %al
	movl	%ebx, %edx
	callq	fprintf
	incq	%rbx
	cmpq	$1024, %rbx             # imm = 0x400
	jne	.LBB1_1
# BB#2:
	popq	%rbx
	retq
.Ltmp6:
	.size	print_array, .Ltmp6-print_array
	.cfi_endproc

	.section	.rodata.cst4,"aM",@progbits,4
	.align	4
.LCPI2_0:
	.long	981467136               # float 9.765625E-4
	.text
	.globl	check_result
	.align	16, 0x90
	.type	check_result,@function
check_result:                           # @check_result
	.cfi_startproc
# BB#0:
	xorps	%xmm1, %xmm1
	movq	$-4096, %rax            # imm = 0xFFFFFFFFFFFFF000
	.align	16, 0x90
.LBB2_1:                                # =>This Inner Loop Header: Depth=1
	addss	h_c+4096(%rax), %xmm1
	addss	h_c+4100(%rax), %xmm1
	addss	h_c+4104(%rax), %xmm1
	addss	h_c+4108(%rax), %xmm1
	addq	$16, %rax
	jne	.LBB2_1
# BB#2:
	movq	stdout(%rip), %rdi
	cvtss2sd	%xmm1, %xmm0
	mulss	.LCPI2_0(%rip), %xmm1
	cvtss2sd	%xmm1, %xmm1
	movl	$.L.str3, %esi
	movb	$2, %al
	jmp	fprintf                 # TAILCALL
.Ltmp7:
	.size	check_result, .Ltmp7-check_result
	.cfi_endproc

	.section	.rodata.cst16,"aM",@progbits,16
	.align	16
.LCPI3_0:
	.long	1056964608              # float 5.000000e-01
	.long	1056964608              # float 5.000000e-01
	.long	1056964608              # float 5.000000e-01
	.long	1056964608              # float 5.000000e-01
	.section	.rodata.cst4,"aM",@progbits,4
	.align	4
.LCPI3_1:
	.long	981467136               # float 9.765625E-4
	.text
	.globl	main
	.align	16, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# BB#0:                                 # %polly.split_new_and_old
	pushq	%rbx
.Ltmp8:
	.cfi_def_cfa_offset 16
	subq	$16, %rsp
.Ltmp9:
	.cfi_def_cfa_offset 32
.Ltmp10:
	.cfi_offset %rbx, -16
	movq	stdout(%rip), %rcx
	movl	$.L.str, %edi
	movl	$28, %esi
	movl	$1, %edx
	callq	fwrite
	movl	$h_b, %r8d
	movl	$h_c+4096, %ecx
	cmpq	%r8, %rcx
	setbe	%dl
	movl	$h_c, %esi
	movl	$h_b+4096, %r9d
	cmpq	%rsi, %r9
	setbe	%bl
	orb	%dl, %bl
	movl	$h_a, %edi
	cmpq	%rdi, %rcx
	setbe	%cl
	movl	$h_a+4096, %eax
	cmpq	%rsi, %rax
	setbe	%dl
	orb	%cl, %dl
	andb	%bl, %dl
	cmpq	%r8, %rax
	setbe	%al
	cmpq	%rdi, %r9
	setbe	%cl
	orb	%al, %cl
	testb	%cl, %dl
	je	.LBB3_1
# BB#10:                                # %polly.start
	leaq	(%rsp), %rbx
	movl	$main.polly.subfn, %edi
	xorl	%edx, %edx
	xorl	%ecx, %ecx
	movl	$64, %r8d
	movl	$1, %r9d
	movq	%rbx, %rsi
	callq	GOMP_parallel_loop_runtime_start
	movq	%rbx, %rdi
	callq	main.polly.subfn
	callq	GOMP_parallel_end
	leaq	8(%rsp), %rbx
	movl	$main.polly.subfn1, %edi
	xorl	%edx, %edx
	xorl	%ecx, %ecx
	movl	$128, %r8d
	movl	$1, %r9d
	movq	%rbx, %rsi
	callq	GOMP_parallel_loop_runtime_start
	movq	%rbx, %rdi
	callq	main.polly.subfn1
	callq	GOMP_parallel_end
	jmp	.LBB3_5
.LBB3_1:
	movq	$-4096, %rax            # imm = 0xFFFFFFFFFFFFF000
	movaps	.LCPI3_0(%rip), %xmm0   # xmm0 = [5.000000e-01,5.000000e-01,5.000000e-01,5.000000e-01]
	.align	16, 0x90
.LBB3_2:                                # %vector.body
                                        # =>This Inner Loop Header: Depth=1
	movaps	%xmm0, h_a+4096(%rax)
	movaps	%xmm0, h_a+4112(%rax)
	movaps	%xmm0, h_b+4096(%rax)
	movaps	%xmm0, h_b+4112(%rax)
	movaps	%xmm0, h_a+4128(%rax)
	movaps	%xmm0, h_a+4144(%rax)
	movaps	%xmm0, h_b+4128(%rax)
	movaps	%xmm0, h_b+4144(%rax)
	addq	$64, %rax
	jne	.LBB3_2
# BB#3:
	movq	$-4096, %rax            # imm = 0xFFFFFFFFFFFFF000
	.align	16, 0x90
.LBB3_4:                                # %vector.body12
                                        # =>This Inner Loop Header: Depth=1
	movaps	h_a+4096(%rax), %xmm0
	movaps	h_a+4112(%rax), %xmm1
	addps	h_b+4096(%rax), %xmm0
	addps	h_b+4112(%rax), %xmm1
	movaps	%xmm0, h_c+4096(%rax)
	movaps	%xmm1, h_c+4112(%rax)
	addq	$32, %rax
	jne	.LBB3_4
.LBB3_5:                                # %polly.merge_new_and_old
	movq	stdout(%rip), %rcx
	movl	$.L.str1, %edi
	movl	$28, %esi
	movl	$1, %edx
	callq	fwrite
	xorl	%ebx, %ebx
	.align	16, 0x90
.LBB3_6:                                # =>This Inner Loop Header: Depth=1
	movq	stdout(%rip), %rdi
	movss	h_c(,%rbx,4), %xmm0
	cvtss2sd	%xmm0, %xmm0
	movl	$.L.str2, %esi
	movb	$1, %al
	movl	%ebx, %edx
	callq	fprintf
	incq	%rbx
	cmpq	$1024, %rbx             # imm = 0x400
	jne	.LBB3_6
# BB#7:
	xorps	%xmm1, %xmm1
	movq	$-4096, %rax            # imm = 0xFFFFFFFFFFFFF000
	.align	16, 0x90
.LBB3_8:                                # %print_array.exit
                                        # =>This Inner Loop Header: Depth=1
	addss	h_c+4096(%rax), %xmm1
	addss	h_c+4100(%rax), %xmm1
	addss	h_c+4104(%rax), %xmm1
	addss	h_c+4108(%rax), %xmm1
	addq	$16, %rax
	jne	.LBB3_8
# BB#9:                                 # %check_result.exit
	movq	stdout(%rip), %rdi
	cvtss2sd	%xmm1, %xmm0
	mulss	.LCPI3_1(%rip), %xmm1
	cvtss2sd	%xmm1, %xmm1
	movl	$.L.str3, %esi
	movb	$2, %al
	callq	fprintf
	xorl	%eax, %eax
	addq	$16, %rsp
	popq	%rbx
	retq
.Ltmp11:
	.size	main, .Ltmp11-main
	.cfi_endproc

	.section	.rodata.cst16,"aM",@progbits,16
	.align	16
.LCPI4_0:
	.long	1056964608              # float 5.000000e-01
	.long	1056964608              # float 5.000000e-01
	.long	1056964608              # float 5.000000e-01
	.long	1056964608              # float 5.000000e-01
	.text
	.align	16, 0x90
	.type	init_array.polly.subfn,@function
init_array.polly.subfn:                 # @init_array.polly.subfn
	.cfi_startproc
# BB#0:                                 # %polly.par.setup
	pushq	%r14
.Ltmp12:
	.cfi_def_cfa_offset 16
	pushq	%rbx
.Ltmp13:
	.cfi_def_cfa_offset 24
	subq	$24, %rsp
.Ltmp14:
	.cfi_def_cfa_offset 48
.Ltmp15:
	.cfi_offset %rbx, -24
.Ltmp16:
	.cfi_offset %r14, -16
	leaq	16(%rsp), %r14
	leaq	8(%rsp), %rbx
	jmp	.LBB4_1
	.align	16, 0x90
.LBB4_2:                                # %polly.loop_preheader
                                        #   in Loop: Header=BB4_1 Depth=1
	movq	16(%rsp), %rax
	movq	8(%rsp), %rcx
	decq	%rcx
	leaq	-1(%rax), %rdx
	shlq	$4, %rax
	addq	$-1008, %rax            # imm = 0xFFFFFFFFFFFFFC10
	movaps	.LCPI4_0(%rip), %xmm0   # xmm0 = [5.000000e-01,5.000000e-01,5.000000e-01,5.000000e-01]
	.align	16, 0x90
.LBB4_3:                                # %polly.stmt.vector.body
                                        #   Parent Loop BB4_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movaps	%xmm0, h_a+4032(,%rax,4)
	movaps	%xmm0, h_a+4048(,%rax,4)
	movaps	%xmm0, h_b+4032(,%rax,4)
	movaps	%xmm0, h_b+4048(,%rax,4)
	movaps	%xmm0, h_a+4064(,%rax,4)
	movaps	%xmm0, h_a+4080(,%rax,4)
	movaps	%xmm0, h_b+4064(,%rax,4)
	movaps	%xmm0, h_b+4080(,%rax,4)
	leaq	-1(%rcx), %rsi
	incq	%rdx
	addq	$16, %rax
	cmpq	%rsi, %rdx
	jle	.LBB4_3
.LBB4_1:                                # %polly.par.checkNext
                                        # =>This Loop Header: Depth=1
                                        #     Child Loop BB4_3 Depth 2
	movq	%r14, %rdi
	movq	%rbx, %rsi
	callq	GOMP_loop_runtime_next
	testb	%al, %al
	jne	.LBB4_2
# BB#4:                                 # %polly.par.exit
	callq	GOMP_loop_end_nowait
	addq	$24, %rsp
	popq	%rbx
	popq	%r14
	retq
.Ltmp17:
	.size	init_array.polly.subfn, .Ltmp17-init_array.polly.subfn
	.cfi_endproc

	.section	.rodata.cst16,"aM",@progbits,16
	.align	16
.LCPI5_0:
	.long	1056964608              # float 5.000000e-01
	.long	1056964608              # float 5.000000e-01
	.long	1056964608              # float 5.000000e-01
	.long	1056964608              # float 5.000000e-01
	.text
	.align	16, 0x90
	.type	main.polly.subfn,@function
main.polly.subfn:                       # @main.polly.subfn
	.cfi_startproc
# BB#0:                                 # %polly.par.setup
	pushq	%r14
.Ltmp18:
	.cfi_def_cfa_offset 16
	pushq	%rbx
.Ltmp19:
	.cfi_def_cfa_offset 24
	subq	$24, %rsp
.Ltmp20:
	.cfi_def_cfa_offset 48
.Ltmp21:
	.cfi_offset %rbx, -24
.Ltmp22:
	.cfi_offset %r14, -16
	leaq	16(%rsp), %r14
	leaq	8(%rsp), %rbx
	jmp	.LBB5_1
	.align	16, 0x90
.LBB5_2:                                # %polly.loop_preheader
                                        #   in Loop: Header=BB5_1 Depth=1
	movq	16(%rsp), %rax
	movq	8(%rsp), %rcx
	decq	%rcx
	leaq	-1(%rax), %rdx
	shlq	$4, %rax
	addq	$-1008, %rax            # imm = 0xFFFFFFFFFFFFFC10
	movaps	.LCPI5_0(%rip), %xmm0   # xmm0 = [5.000000e-01,5.000000e-01,5.000000e-01,5.000000e-01]
	.align	16, 0x90
.LBB5_3:                                # %polly.stmt.vector.body
                                        #   Parent Loop BB5_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movaps	%xmm0, h_a+4032(,%rax,4)
	movaps	%xmm0, h_a+4048(,%rax,4)
	movaps	%xmm0, h_b+4032(,%rax,4)
	movaps	%xmm0, h_b+4048(,%rax,4)
	movaps	%xmm0, h_a+4064(,%rax,4)
	movaps	%xmm0, h_a+4080(,%rax,4)
	movaps	%xmm0, h_b+4064(,%rax,4)
	movaps	%xmm0, h_b+4080(,%rax,4)
	leaq	-1(%rcx), %rsi
	incq	%rdx
	addq	$16, %rax
	cmpq	%rsi, %rdx
	jle	.LBB5_3
.LBB5_1:                                # %polly.par.checkNext
                                        # =>This Loop Header: Depth=1
                                        #     Child Loop BB5_3 Depth 2
	movq	%r14, %rdi
	movq	%rbx, %rsi
	callq	GOMP_loop_runtime_next
	testb	%al, %al
	jne	.LBB5_2
# BB#4:                                 # %polly.par.exit
	callq	GOMP_loop_end_nowait
	addq	$24, %rsp
	popq	%rbx
	popq	%r14
	retq
.Ltmp23:
	.size	main.polly.subfn, .Ltmp23-main.polly.subfn
	.cfi_endproc

	.align	16, 0x90
	.type	main.polly.subfn1,@function
main.polly.subfn1:                      # @main.polly.subfn1
	.cfi_startproc
# BB#0:                                 # %polly.par.setup
	pushq	%r14
.Ltmp24:
	.cfi_def_cfa_offset 16
	pushq	%rbx
.Ltmp25:
	.cfi_def_cfa_offset 24
	subq	$24, %rsp
.Ltmp26:
	.cfi_def_cfa_offset 48
.Ltmp27:
	.cfi_offset %rbx, -24
.Ltmp28:
	.cfi_offset %r14, -16
	leaq	16(%rsp), %r14
	leaq	8(%rsp), %rbx
	jmp	.LBB6_1
	.align	16, 0x90
.LBB6_2:                                # %polly.loop_preheader
                                        #   in Loop: Header=BB6_1 Depth=1
	movq	16(%rsp), %rax
	movq	8(%rsp), %rcx
	decq	%rcx
	leaq	-1016(,%rax,8), %rdx
	decq	%rax
	.align	16, 0x90
.LBB6_3:                                # %polly.stmt.vector.body12
                                        #   Parent Loop BB6_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movaps	h_a+4064(,%rdx,4), %xmm0
	movaps	h_a+4080(,%rdx,4), %xmm1
	addps	h_b+4064(,%rdx,4), %xmm0
	addps	h_b+4080(,%rdx,4), %xmm1
	movaps	%xmm0, h_c+4064(,%rdx,4)
	movaps	%xmm1, h_c+4080(,%rdx,4)
	leaq	-1(%rcx), %rsi
	incq	%rax
	addq	$8, %rdx
	cmpq	%rsi, %rax
	jle	.LBB6_3
.LBB6_1:                                # %polly.par.checkNext
                                        # =>This Loop Header: Depth=1
                                        #     Child Loop BB6_3 Depth 2
	movq	%r14, %rdi
	movq	%rbx, %rsi
	callq	GOMP_loop_runtime_next
	testb	%al, %al
	jne	.LBB6_2
# BB#4:                                 # %polly.par.exit
	callq	GOMP_loop_end_nowait
	addq	$24, %rsp
	popq	%rbx
	popq	%r14
	retq
.Ltmp29:
	.size	main.polly.subfn1, .Ltmp29-main.polly.subfn1
	.cfi_endproc

	.type	.L.str,@object          # @.str
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str:
	.asciz	"Initialize vectors on host:\n"
	.size	.L.str, 29

	.type	h_a,@object             # @h_a
	.comm	h_a,4096,16
	.type	h_b,@object             # @h_b
	.comm	h_b,4096,16
	.type	.L.str1,@object         # @.str1
.L.str1:
	.asciz	"Printing the vector result:\n"
	.size	.L.str1, 29

	.type	.L.str2,@object         # @.str2
.L.str2:
	.asciz	"h_c[%d]: %f\n"
	.size	.L.str2, 13

	.type	h_c,@object             # @h_c
	.comm	h_c,4096,16
	.type	.L.str3,@object         # @.str3
.L.str3:
	.asciz	"Final Result: (%f, %f)\n"
	.size	.L.str3, 24


	.ident	"clang version 3.6.0 (tags/RELEASE_360/final)"
	.section	".note.GNU-stack","",@progbits
