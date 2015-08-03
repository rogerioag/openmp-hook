	.file	"vectoradd-omp-parallel-for-single.c"
	.globl	h_a
	.bss
	.align 32
	.type	h_a, @object
	.size	h_a, 64
h_a:
	.zero	64
	.globl	h_b
	.align 32
	.type	h_b, @object
	.size	h_b, 64
h_b:
	.zero	64
	.globl	h_c
	.align 32
	.type	h_c, @object
	.size	h_c, 64
h_c:
	.zero	64
	.section	.rodata
.LC0:
	.string	"init_array().\n"
	.text
	.globl	_Z10init_arrayv
	.type	_Z10init_arrayv, @function
_Z10init_arrayv:
.LFB2:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movq	stdout(%rip), %rax
	movq	%rax, %rcx
	movl	$14, %edx
	movl	$1, %esi
	movl	$.LC0, %edi
	call	fwrite
	movl	$0, -4(%rbp)
	jmp	.L2
.L3:
	movl	-4(%rbp), %eax
	movslq	%eax, %rdx
	movl	.LC1(%rip), %eax
	movl	%eax, h_a(,%rdx,4)
	movl	-4(%rbp), %eax
	movslq	%eax, %rdx
	movl	.LC1(%rip), %eax
	movl	%eax, h_b(,%rdx,4)
	addl	$1, -4(%rbp)
.L2:
	cmpl	$15, -4(%rbp)
	setle	%al
	testb	%al, %al
	jne	.L3
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE2:
	.size	_Z10init_arrayv, .-_Z10init_arrayv
	.section	.rodata
.LC2:
	.string	"print_array().\n"
.LC3:
	.string	"h_c[%07d]: %f\n"
	.text
	.globl	_Z11print_arrayv
	.type	_Z11print_arrayv, @function
_Z11print_arrayv:
.LFB3:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movq	stdout(%rip), %rax
	movq	%rax, %rcx
	movl	$15, %edx
	movl	$1, %esi
	movl	$.LC2, %edi
	call	fwrite
	movl	$0, -4(%rbp)
	jmp	.L5
.L6:
	movl	-4(%rbp), %eax
	cltq
	movss	h_c(,%rax,4), %xmm0
	unpcklps	%xmm0, %xmm0
	cvtps2pd	%xmm0, %xmm0
	movq	stdout(%rip), %rax
	movl	-4(%rbp), %edx
	movl	$.LC3, %esi
	movq	%rax, %rdi
	movl	$1, %eax
	call	fprintf
	addl	$1, -4(%rbp)
.L5:
	cmpl	$15, -4(%rbp)
	setle	%al
	testb	%al, %al
	jne	.L6
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE3:
	.size	_Z11print_arrayv, .-_Z11print_arrayv
	.section	.rodata
.LC4:
	.string	"check_result().\n"
.LC6:
	.string	"Verificando o resultado.\n"
.LC8:
	.string	"Resultado Final: (%f, %f)\n"
	.text
	.globl	_Z12check_resultv
	.type	_Z12check_resultv, @function
_Z12check_resultv:
.LFB4:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movq	stdout(%rip), %rax
	movq	%rax, %rcx
	movl	$16, %edx
	movl	$1, %esi
	movl	$.LC4, %edi
	call	fwrite
	movl	.LC5(%rip), %eax
	movl	%eax, -8(%rbp)
	movq	stdout(%rip), %rax
	movq	%rax, %rcx
	movl	$25, %edx
	movl	$1, %esi
	movl	$.LC6, %edi
	call	fwrite
	movl	$0, -4(%rbp)
	jmp	.L8
.L9:
	movl	-4(%rbp), %eax
	cltq
	movss	h_c(,%rax,4), %xmm0
	movss	-8(%rbp), %xmm1
	addss	%xmm1, %xmm0
	movss	%xmm0, -8(%rbp)
	addl	$1, -4(%rbp)
.L8:
	cmpl	$15, -4(%rbp)
	setle	%al
	testb	%al, %al
	jne	.L9
	movss	-8(%rbp), %xmm0
	movss	.LC7(%rip), %xmm1
	divss	%xmm1, %xmm0
	unpcklps	%xmm0, %xmm0
	cvtps2pd	%xmm0, %xmm1
	movss	-8(%rbp), %xmm0
	cvtps2pd	%xmm0, %xmm0
	movq	stdout(%rip), %rax
	movl	$.LC8, %esi
	movq	%rax, %rdi
	movl	$2, %eax
	call	fprintf
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE4:
	.size	_Z12check_resultv, .-_Z12check_resultv
	.section	.rodata
.LC9:
	.string	"main().\n"
.LC10:
	.string	"before parallel region 1.\n"
	.text
	.globl	main
	.type	main, @function
main:
.LFB5:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movq	stdout(%rip), %rax
	movq	%rax, %rcx
	movl	$8, %edx
	movl	$1, %esi
	movl	$.LC9, %edi
	call	fwrite
	call	_Z10init_arrayv
	movq	stdout(%rip), %rax
	movq	%rax, %rcx
	movl	$26, %edx
	movl	$1, %esi
	movl	$.LC10, %edi
	call	fwrite
	movl	-4(%rbp), %eax
	movl	%eax, -16(%rbp)
	leaq	-16(%rbp), %rax
	movl	$0, %edx
	movq	%rax, %rsi
	movl	$main._omp_fn.0, %edi
	call	GOMP_parallel_start
	leaq	-16(%rbp), %rax
	movq	%rax, %rdi
	call	main._omp_fn.0
	call	GOMP_parallel_end
	movl	-16(%rbp), %eax
	movl	%eax, -4(%rbp)
	call	_Z12check_resultv
	movl	$0, %eax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE5:
	.size	main, .-main
	.section	.rodata
.LC11:
	.string	"Thread: %d of %d.\n"
	.text
	.type	main._omp_fn.0, @function
main._omp_fn.0:
.LFB6:
	.cfi_startproc
	.cfi_personality 0x3,__gxx_personality_v0
	.cfi_lsda 0x3,.LLSDA6
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	pushq	%rbx
	subq	$24, %rsp
	.cfi_offset 3, -24
	movq	%rdi, -24(%rbp)
	call	GOMP_single_start
	cmpb	$1, %al
	jne	.L12
.L13:
	movq	-24(%rbp), %rax
	movl	$0, (%rax)
.L15:
	movq	-24(%rbp), %rax
	movl	(%rax), %eax
	cmpl	$15, %eax
	setle	%al
	testb	%al, %al
	je	.L12
	call	omp_get_num_threads
	movl	%eax, %ebx
	call	omp_get_thread_num
	movl	%eax, %edx
	movq	stdout(%rip), %rax
	movl	%ebx, %ecx
	movl	$.LC11, %esi
	movq	%rax, %rdi
	movl	$0, %eax
	call	fprintf
	movq	-24(%rbp), %rax
	movl	(%rax), %eax
	cltq
	movss	h_a(,%rax,4), %xmm1
	movq	-24(%rbp), %rax
	movl	(%rax), %eax
	cltq
	movss	h_b(,%rax,4), %xmm0
	addss	%xmm1, %xmm0
	movq	-24(%rbp), %rax
	movl	(%rax), %eax
	cltq
	movss	%xmm0, h_c(,%rax,4)
	movq	-24(%rbp), %rax
	movl	(%rax), %eax
	leal	1(%rax), %edx
	movq	-24(%rbp), %rax
	movl	%edx, (%rax)
	jmp	.L15
.L12:
	addq	$24, %rsp
	popq	%rbx
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE6:
	.globl	__gxx_personality_v0
	.section	.gcc_except_table,"a",@progbits
.LLSDA6:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSE6-.LLSDACSB6
.LLSDACSB6:
.LLSDACSE6:
	.text
	.size	main._omp_fn.0, .-main._omp_fn.0
	.section	.rodata
	.align 4
.LC1:
	.long	1056964608
	.align 4
.LC5:
	.long	0
	.align 4
.LC7:
	.long	1098907648
	.ident	"GCC: (Debian 4.7.4-3) 4.7.4"
	.section	.note.GNU-stack,"",@progbits