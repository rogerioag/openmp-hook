	.file	"vectoradd-omp.c"
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
	.align 8
.LC2:
	.string	"Thread [%02d]: Imprimindo o array de resultados:\n"
.LC3:
	.string	"Thread [%02d]: h_c[%07d]: %f\n"
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
	subq	$32, %rsp
	call	omp_get_thread_num
	movl	%eax, %edx
	movq	stdout(%rip), %rax
	movl	$.LC2, %esi
	movq	%rax, %rdi
	movl	$0, %eax
	call	fprintf
	movl	$0, -4(%rbp)
	jmp	.L5
.L6:
	movl	-4(%rbp), %eax
	cltq
	movss	h_c(,%rax,4), %xmm0
	unpcklps	%xmm0, %xmm0
	cvtps2pd	%xmm0, %xmm0
	movsd	%xmm0, -24(%rbp)
	call	omp_get_thread_num
	movl	%eax, %edx
	movq	stdout(%rip), %rax
	movl	-4(%rbp), %ecx
	movsd	-24(%rbp), %xmm0
	movl	$.LC3, %esi
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
	.align 8
.LC5:
	.string	"Thread [%02d]: Verificando o resultado.\n"
	.align 8
.LC7:
	.string	"Thread [%02d]: Resultado Final: (%f, %f)\n"
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
	subq	$32, %rsp
	movl	.LC4(%rip), %eax
	movl	%eax, -8(%rbp)
	call	omp_get_thread_num
	movl	%eax, %edx
	movq	stdout(%rip), %rax
	movl	$.LC5, %esi
	movq	%rax, %rdi
	movl	$0, %eax
	call	fprintf
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
	movss	.LC6(%rip), %xmm1
	divss	%xmm1, %xmm0
	unpcklps	%xmm0, %xmm0
	cvtps2pd	%xmm0, %xmm0
	movsd	%xmm0, -24(%rbp)
	movss	-8(%rbp), %xmm0
	cvtps2pd	%xmm0, %xmm0
	movsd	%xmm0, -32(%rbp)
	call	omp_get_thread_num
	movl	%eax, %edx
	movq	stdout(%rip), %rax
	movsd	-24(%rbp), %xmm1
	movsd	-32(%rbp), %xmm0
	movl	$.LC7, %esi
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
	subq	$16, %rsp
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
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE5:
	.size	main, .-main
	.section	.rodata
	.align 8
.LC8:
	.string	"Thread [%02d]: Inicio de uma poss\355vel regiao paralela, numero de threads = %d, processadores = %d\n"
	.text
	.type	main._omp_fn.0, @function
main._omp_fn.0:
.LFB6:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	pushq	%r12
	pushq	%rbx
	subq	$48, %rsp
	.cfi_offset 12, -24
	.cfi_offset 3, -32
	movq	%rdi, -56(%rbp)
	call	GOMP_single_start
	cmpb	$1, %al
	je	.L13
.L17:
	call	GOMP_barrier
	leaq	-32(%rbp), %rdx
	leaq	-40(%rbp), %rax
	movq	%rdx, %r8
	movq	%rax, %rcx
	movl	$1, %edx
	movl	$1048576, %esi
	movl	$0, %edi
	call	GOMP_loop_runtime_start
	testb	%al, %al
	je	.L14
.L16:
	movq	-40(%rbp), %rax
	movl	%eax, -20(%rbp)
	movq	-32(%rbp), %rax
.L15:
	movl	-20(%rbp), %edx
	movslq	%edx, %rdx
	movss	h_a(,%rdx,4), %xmm1
	movl	-20(%rbp), %edx
	movslq	%edx, %rdx
	movss	h_b(,%rdx,4), %xmm0
	addss	%xmm1, %xmm0
	movl	-20(%rbp), %edx
	movslq	%edx, %rdx
	movss	%xmm0, h_c(,%rdx,4)
	addl	$1, -20(%rbp)
	cmpl	%eax, -20(%rbp)
	jl	.L15
	leaq	-32(%rbp), %rdx
	leaq	-40(%rbp), %rax
	movq	%rdx, %rsi
	movq	%rax, %rdi
	call	GOMP_loop_runtime_next
	testb	%al, %al
	jne	.L16
.L14:
	call	GOMP_loop_end_nowait
	jmp	.L18
.L13:
	call	omp_get_num_procs
	movl	%eax, %r12d
	call	omp_get_num_threads
	movl	%eax, %ebx
	call	omp_get_thread_num
	movl	%r12d, %ecx
	movl	%ebx, %edx
	movl	%eax, %esi
	movl	$.LC8, %edi
	movl	$0, %eax
	call	printf
	jmp	.L17
.L18:
	addq	$48, %rsp
	popq	%rbx
	popq	%r12
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
.LC4:
	.long	0
	.align 4
.LC6:
	.long	1233125376
	.ident	"GCC: (Debian 4.7.4-3) 4.7.4"
	.section	.note.GNU-stack,"",@progbits
