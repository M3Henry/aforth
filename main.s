.macro	const val
	.quad	docon
	.quad	\val
.endm
	.data

cold:	.quad	enter
_cold:	.quad	abort

abort:	.quad	enter
	.quad	quit

quit:	.quad	enter
	const 4
linelp:		const	10
	starlp:		.quad	star
			.quad	dec
			.quad	dup
		.quad	dowhile
		.quad	. - starlp
		.quad	drop
		.quad	cr
		.quad	dec
		.quad	dup
	.quad	dowhile
	.quad	. - linelp
	.quad	halt

dict:	.quad	star
	.quad	star
	.quad	cr
	.quad	star
	.quad	star
	.quad	halt

star:	.quad	enter
	const	42
	.quad	emit
	.quad	exit

buff:	.quad

stack:	.skip	64	#1048576

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

one:		.quad	. + 8
	mov	TOS,	(SP)
	add	$8,	SP
	mov	$1,	TOS
	jmp	next


double:		.quad	. + 8
	shl	TOS
	jmp	next

.macro	_dup
	add	$8,	SP
	mov	TOS,	(SP)
.endm
dup:		.quad	. + 8
	_dup
	jmp	next

drop2:		.quad	. + 8
_drop2:	sub	$8,	SP
	mov	(SP),	TOS
	sub	$8,	SP
	jmp	next

drop:		.quad	. + 8
_drop:	mov	(SP),	TOS
	sub	$8,	SP
	jmp	next

emit:		.quad	. + 8
	movq	TOS,	buff
	mov     $1,	%rax	# system call 1 is write
        mov     $1,	%rdi	# file handle 1 is stdout
        mov     $buff,	%rsi	# address of string to output
        mov     $1,	%rdx	# number of bytes
        syscall
	jmp	_drop

cr:		.quad	. + 8
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

halt:		.quad . + 8
	call	_cr
	xor     %rdi,	%rdi	# default return code 0
	sub	$stack, SP
	jz	_halt
		mov	TOS,	%rdi
_halt:	mov     $60,	%rax	# system call 60 is exit
	syscall

exit:		.quad	. + 8
	pop	IP
	jmp	next

docon:		.quad	. + 8
	_dup
	mov	(IP),	TOS
	advanceIP
	jmp	next

doagain:	.quad	. + 8
	sub	(IP),	IP
	jmp	next

dowhile:	.quad	. + 8
	cmp	$0,	TOS
	je	__whe
	sub	(IP),	IP
	jmp	_drop
__whe:	advanceIP
	jmp	_drop

execute:	.quad . + 8
	mov	TOS,	IP
	add	$8,	IP
	jmp	_drop

at:		.quad . + 8
	mov	(TOS),	TOS
	jmp	next


bang:		.quad . + 8
	mov	(SP),	ACC
	mov	ACC,	(TOS)
	jmp	_drop2

plus:		.quad . + 8
	add	TOS,	(SP)
	jmp	_drop

minus:		.quad . + 8
	sub	TOS,	(SP)
	jmp	_drop

inc:		.quad . + 8
	inc	TOS
	jmp	next

dec:		.quad . + 8
	sub	$1,	TOS
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
