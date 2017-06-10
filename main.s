	.data

dict:
	.8byte	star
	.8byte	star
	.8byte	cr
	.8byte	star
	.8byte	star
	.8byte	halt

star:	.8byte	enter
	.8byte	docon
	.8byte	42
	.8byte	emit
	.8byte	exit

buff:	.8byte

stack:	.skip	1048576

	.global _start

	.text

	.set	TOS,	%r15
	.set	SP,	%r14
	.set	IP,	%r13
	.set	WP,	%r12

one:	.8byte	. + 8
	mov	TOS,	(SP)
	add	$8,	SP
	mov	$1,	TOS
	jmp	next


double:	.8byte	. + 8
	shl	TOS
	jmp	next

dup:	.8byte	. + 8
	mov	TOS,	(SP)
	add	$8,	SP
	jmp	next

drop:	.8byte	. + 8
_drop:	mov	(SP),	TOS
	sub	$8,	SP
	jmp	next

emit:	.8byte	. + 8
	movq	TOS,	buff
	mov     $1,	%rax	# system call 1 is write
        mov     $1,	%rdi	# file handle 1 is stdout
        mov     $buff,	%rsi	# address of string to output
        mov     $1,	%rdx	# number of bytes
        syscall
	jmp	_drop

cr:	.8byte	. + 8
	call	_cr
	jmp	next
newl:	.ascii	"\n\r"
_cr:
	mov     $1,	%rax	# system call 1 is write
        mov     $1,	%rdi	# file handle 1 is stdout
        mov     $newl,	%rsi	# address of string to output
        mov     $2,	%rdx	# number of bytes
        syscall
	ret

halt:	.8byte . + 8
	call	_cr
	xor     %rdi,	%rdi	# default return code 0
	sub	$stack, SP
	jz	_halt
		mov	TOS,	%rdi
_halt:	mov     $60,	%rax	# system call 60 is exit
	syscall

exit:	.8byte	. + 8
	pop	IP
	jmp	next



_start:
	mov	$stack,	SP
	mov	$dict,	IP
next:
	mov	(IP),	WP
	add	$8,	IP
	jmp	*(WP)

enter:
	push	IP
	mov	WP,	IP
	add	$8,	IP
	jmp	next

execute:	# not done!
	mov	TOS,	WP
	jmp	_drop

docon:	.8byte	. + 8
	mov	TOS,	(SP)
	add	$8,	SP
	mov	(IP),	TOS
	add	$8,	IP
	jmp	next
