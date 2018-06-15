	.data
INT:
	.string "%d"
INTN:
	.string "%d\n"
	.text
	.globl main
	.type main, @function

main:
	pushq %rbp
	movq %rsp, %rbp
	subq $24, %rsp
	movl $0, -4(%rbp)
	xorl %eax, %eax
	movl $1, %eax
	movl %eax, -4(%rbp)
	
	xorl %eax, %eax
	movl $2, %eax
	movl %eax, -8(%rbp)
	
	
	leaq -12(%rbp), %rax
	movq %rax, %rsi
	movl $INT, %edi
	movl $0, %eax
	call __isoc99_scanf
	
	
	xorl %edx, %edx
	movl %edx, -12(%rbp)
	cmpl %edx, -4(%rbp)
	jns .L001
	xorl %edx, %edx
	xorl %eax, %eax
	movl -12(%rbp), %eax
	addl -4(%rbp), %eax
	movl %eax, -16(%rbp)
	
	.L001:
	xorl %edx, %edx
	movl %edx, -12(%rbp)
	cmpl %edx, -4(%rbp)
	js .L002
	xorl %edx, %edx
	xorl %eax, %eax
	movl -12(%rbp), %eax
	subl -4(%rbp), %eax
	movl %eax, -16(%rbp)
	
	.L002:
	
	
	movl $INTN, %edi
	xorq %rsi, %rsi
	movl -4(%rbp), %eax
	movl %eax, %esi
	movl $0, %eax
	call printf
	
	
	movl $INTN, %edi
	xorq %rsi, %rsi
	movl -8(%rbp), %eax
	movl %eax, %esi
	movl $0, %eax
	call printf
	
	
	movl $INTN, %edi
	xorq %rsi, %rsi
	movl -12(%rbp), %eax
	movl %eax, %esi
	movl $0, %eax
	call printf
	
	
	addq $24, %rsp
	movl $1, %eax
	movl $0, %ebx
	popq %rbp
	int $0x80
	
	
	
