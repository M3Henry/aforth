.macro	forthword
	.quad	enter
.endm

.macro	endword
	.quad	exit
.endm

.macro	const val
	.quad	docon
	.quad	\val
.endm

.macro	vari label
	.quad	dovar
	.quad	\label
.endm

.macro	while label
	.quad	dowhile
	.quad	. - \label
.endm

	.data

cold:	forthword
_cold:	.quad	abort

abort:	forthword
	.quad	quit

quit:	forthword
	const	4
	.quad	flag
	.quad	halt
linelp:		const	10
	starlp2:		.quad	star
			.quad	dec
			.quad	dup
		.quad	dowhile
		.quad	. - starlp2
		.quad	drop
		.quad	cr
		.quad	dec
		.quad	dup
	.quad	dowhile
	.quad	. - linelp
	.quad	halt

flag:	forthword
	flaglp:	const 10
		.quad	line
		.quad	dec
		.quad	dup
	while	flaglp
	endword

line:	forthword
	starlp:	.quad	star
		.quad	dec
		.quad	dup
	while	starlp
	.quad	drop
	.quad	cr
	endword

star:	forthword
	const	42
	.quad	emit
	endword

buff:	.quad

stack:	.skip	1024	#1048576

.macro	codeword
	.quad	. + 8
.endm

.macro	advanceIP
	add	$8,	IP
.endm

	.global _start

	.text

	.set	TOS,	%r15
	.set	SP,	%r14
	.set	IP,	%r13
	.set	WP,	%r12
	.set	ACC,	%r11

.macro	_dup
	add	$8,	SP
	mov	TOS,	(SP)
.endm
dup:		codeword
	_dup
	jmp	next

drop2:		codeword
_drop2:	sub	$8,	SP
	mov	(SP),	TOS
	sub	$8,	SP
	jmp	next

drop:		codeword
_drop:	mov	(SP),	TOS
	sub	$8,	SP
	jmp	next

emit:		codeword
	movq	TOS,	buff
	mov	$1,	%rax	# system call 1 is write
        mov	$1,	%rdi	# file handle 1 is stdout
        mov	$buff,	%rsi	# address of string to output
        mov	$1,	%rdx	# number of bytes
        syscall
	jmp	_drop

cr:		codeword
	call	_cr
	jmp	next
newl:	.ascii	"\n\r"
_cr:
	mov	$1,	%rax
        mov	$1,	%rdi
        mov	$newl,	%rsi
        mov	$2,	%rdx
        syscall
	ret

halt:		codeword
	call	_cr
	xor     %rdi,	%rdi	# default return code 0
	sub	$stack, SP
	jz	_halt
		mov	TOS,	%rdi
_halt:	mov     $60,	%rax	# system call 60 is exit
	syscall

exit:		codeword
	pop	IP
	jmp	next

docon:		codeword
	_dup
	mov	(IP),	TOS
	advanceIP
	jmp	next

dovar:		codeword
	_dup
	mov	(IP),	TOS
	mov	(TOS),	TOS
	advanceIP
	jmp	next

doagain:	codeword
	sub	(IP),	IP
	jmp	next

dowhile:	codeword
	cmp	$0,	TOS
	je	__brk
	sub	(IP),	IP
	jmp	_drop
__brk:	advanceIP
	jmp	_drop

dountil:	codeword
	cmp	$0,	TOS
	jne	__brk
	sub	(IP),	IP
	jmp	_drop

execute:	codeword
	mov	TOS,	IP
	add	$8,	IP
	jmp	_drop

at:		codeword
	mov	(TOS),	TOS
	jmp	next

bang:		codeword
	mov	(SP),	ACC
	mov	ACC,	(TOS)
	jmp	_drop2

one:		codeword
	_dup
	mov	$1,	TOS
	jmp	next


double:		codeword
	shl	TOS
	jmp	next

plus:		codeword
	add	TOS,	(SP)
	jmp	_drop

minus:		codeword
	sub	TOS,	(SP)
	jmp	_drop

inc:		codeword
	inc	TOS
	jmp	next

dec:		codeword
	dec	TOS
	jmp	next




	.text

_start:	mov	$stack,	SP
	mov	$_cold,	IP
next:
	mov	(IP),	WP
	advanceIP
	jmp	*(WP)

enter:
	push	IP
	mov	WP,	IP
	advanceIP
	jmp	next
