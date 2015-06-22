	.file	"vectoradd-omp-parallel-for.c"
	.comm	h_a,4194304,32
	.comm	h_b,4194304,32
	.comm	h_c,4194304,32
	.section	.rodata
.LC0:
	.string	"Inicializando os arrays.\n"
	.text
	.globl	init_array
	.type	init_array, @function
init_array:
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
	movl	$25, %edx
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
	cmpl	$1048575, -4(%rbp)
	jle	.L3
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE2:
	.size	init_array, .-init_array
	.section	.rodata
.LC2:
	.string	"h_c[%07d]: %f\n"
	.text
	.globl	print_array
	.type	print_array, @function
print_array:
.LFB3:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
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
	movl	$.LC2, %esi
	movq	%rax, %rdi
	movl	$1, %eax
	call	fprintf
	addl	$1, -4(%rbp)
.L5:
	cmpl	$1048575, -4(%rbp)
	jle	.L6
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE3:
	.size	print_array, .-print_array
	.section	.rodata
.LC4:
	.string	"Verificando o resultado.\n"
.LC6:
	.string	"Resultado Final: (%f, %f)\n"
	.text
	.globl	check_result
	.type	check_result, @function
check_result:
.LFB4:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movl	.LC3(%rip), %eax
	movl	%eax, -8(%rbp)
	movq	stdout(%rip), %rax
	movq	%rax, %rcx
	movl	$25, %edx
	movl	$1, %esi
	movl	$.LC4, %edi
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
	cmpl	$1048575, -4(%rbp)
	jle	.L9
	movss	-8(%rbp), %xmm0
	movss	.LC5(%rip), %xmm1
	divss	%xmm1, %xmm0
	unpcklps	%xmm0, %xmm0
	cvtps2pd	%xmm0, %xmm1
	movss	-8(%rbp), %xmm0
	cvtps2pd	%xmm0, %xmm0
	movq	stdout(%rip), %rax
	movl	$.LC6, %esi
	movq	%rax, %rdi
	movl	$2, %eax
	call	fprintf
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE4:
	.size	check_result, .-check_result
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
	movl	$0, %eax
	call	init_array
	movl	$0, %edx
	movl	$0, %esi
	movl	$main._omp_fn.0, %edi
	call	GOMP_parallel_start
	movl	$0, %edi
	call	main._omp_fn.0
	call	GOMP_parallel_end
	movl	$0, %eax
	call	print_array
	movl	$0, %eax
	call	check_result
	movl	$0, %eax
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE5:
	.size	main, .-main
	.type	main._omp_fn.0, @function
main._omp_fn.0:
.LFB6:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	pushq	%rbx
	subq	$40, %rsp
	.cfi_offset 3, -24
	movq	%rdi, -40(%rbp)
	call	omp_get_num_threads
	movl	%eax, %ebx
	call	omp_get_thread_num
	movl	%eax, %esi
	movl	$1048576, %eax
	movl	%eax, %edx
	sarl	$31, %edx
	idivl	%ebx
	movl	%eax, %ecx
	movl	$1048576, %eax
	movl	%eax, %edx
	sarl	$31, %edx
	idivl	%ebx
	movl	%edx, %eax
	cmpl	%eax, %esi
	jl	.L13
.L16:
	movl	%ecx, %edx
	imull	%esi, %edx
	addl	%edx, %eax
	leal	(%rax,%rcx), %edx
	cmpl	%edx, %eax
	jge	.L12
	movl	%eax, -20(%rbp)
.L15:
	movl	-20(%rbp), %eax
	cltq
	movss	h_a(,%rax,4), %xmm1
	movl	-20(%rbp), %eax
	cltq
	movss	h_b(,%rax,4), %xmm0
	addss	%xmm1, %xmm0
	movl	-20(%rbp), %eax
	cltq
	movss	%xmm0, h_c(,%rax,4)
	addl	$1, -20(%rbp)
	cmpl	%edx, -20(%rbp)
	jl	.L15
	jmp	.L12
.L13:
	movl	$0, %eax
	addl	$1, %ecx
	jmp	.L16
.L12:
	addq	$40, %rsp
	popq	%rbx
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE6:
	.size	main._omp_fn.0, .-main._omp_fn.0
	.section	.rodata
	.align 4
.LC1:
	.long	1056964608
	.align 4
.LC3:
	.long	0
	.align 4
.LC5:
	.long	1233125376
	.ident	"GCC: (Debian 4.7.4-3) 4.7.4"
	.section	.note.GNU-stack,"",@progbits
