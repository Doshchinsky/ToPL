	.data
INT:
	.string "%d"
INTN:
	.string "%d\n"
CHAR:
	.string "%c"
CHARN:
	.string "%c\n"
	.text
	.globl main
	.type main, @function

main:
	pushq %rbp
	movq %rsp, %rbp
	subq $28, %rsp
	movl $0, -4(%rbp)
	xorl %eax, %eax
	movl $1, %eax
	andl $65535, %eax
	movl %eax, -4(%rbp)
	
	xorl %eax, %eax
	movl $2, %eax
	andl $65535, %eax
	movl %eax, -8(%rbp)
	
	
	movl $INT, %edi
	leaq -20(%rbp), %rax
	movq %rax, %rsi
	movl $0, %eax
	call __isoc99_scanf
	
	
	movl $INT, %edi
	leaq -12(%rbp), %rax
	movq %rax, %rsi
	movl $0, %eax
	call __isoc99_scanf
	
	
	jmp .L002
.L001:
	xorl %edx, %edx
	movl %edx, -12(%rbp)
	cmpl %edx, -4(%rbp)
	jns .L002
	xorl %edx, %edx
	xorl %eax, %eax
	movl -12(%rbp), %eax
	addl -4(%rbp), %eax
	andl $65535, %eax
	movl %eax, -16(%rbp)
	
	.L002:
	xorl %edx, %edx
	movl %edx, -12(%rbp)
	cmpl %edx, -4(%rbp)
	js .L003
	xorl %edx, %edx
	xorl %eax, %eax
	movl -12(%rbp), %eax
	subl -4(%rbp), %eax
	andl $65535, %eax
	movl %eax, -16(%rbp)
	
	.L003:
	
	xorl %eax, %eax
	movl $1, %eax
	addl -20(%rbp), %eax
	andl $65535, %eax
	movl %eax, -20(%rbp)
	
	
	.L004:
	cmpl $10, -20(%rbp)
	js .L003
	xorl %edx, %edx
	
	
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
	
	
	addq $28, %rsp
	movl $1, %eax
	movl $0, %ebx
	popq %rbp
	int $0x80
	
	
	
