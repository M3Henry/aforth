.include	"macros.i"

# "REGISTERS"

	.text

	.set	TOS,	%r15
	.set	TOSB,	%r15b
	.set	SP,	%r14
	.set	IP,	%r13
	.set	WP,	%r12
	.set	ACC,	%r11
	.set	ACCB,	%r11b

	.set	CMD,	%rax
	.set	ARGA,	%rdi
	.set	ARGB,	%rsi
	.set	ARGC,	%rdx
	.set	ARGD,	%r10
	.set	ARGE,	%r8
	.set	ARGF,	%r9

# Kernel

	.global _start

_start:	movq	%rsp,	rspbk
	mov	$_cold,	IP
next:
	mov	(IP),	WP
	advance	IP
	jmp	*(WP)

enter:
	push	IP
	mov	WP,	IP
	advance	IP
	jmp	next

# "DICTIONARY"

	.data

	.quad	0
7:	strlit	"COLD"
	.quad	0
COLD:	forthword
_cold:	do	RESETDATA
	set	LAST	dictionaryhead
	set	HERE	dictionaryend
	escape	0
	escape	96
	saycr	"aFORTH alpha"
	set	numtib	0
	do	QUIT

verb	forth	ABORT
	do	RESETDATA
	do	QUIT

verb	forth	QUIT
	do	RESETRETURN	# was commented out?
	do	modeI
2:	do	TIB
	const	80
	escape	93
	say	"➤ "
	do	ACCEPT
	escape	0
	test	equal	0	1f
		set	numtib
		do	INTERPRET
		goto	2b
1:	escape	96
	saycr	"Done."
	escape	0
	do	HALT

.include "stack.s"
.include "memory.s"
.include "boolean.s"
.include "maths.s"
.include "input.s"
.include "dictionary.s"
.include "interpreter.s"
.include "compiler.s"
.include "output.s"
.include "extras.s"


# "CODEWORDS"

verb	code	HALT
_halt:	xor     ARGA,	ARGA	# default return code 0
	sub	$stack, SP
	jz	1f
		mov	TOS,	ARGA
1:	mov     $60,	CMD	# system call 60 is exit
	syscall

#	Do Stuff

docon:		codeword
	_dup
	mov	(IP),	TOS
	advance	IP
	jmp	next

dovar:		codeword
	_dup
	mov	IP,	TOS
	advance	IP
	jmp	next

dostr:		codeword
	_dup
	mov	IP,	TOS
	add	(IP),	IP
	advance	IP
	jmp	next

dogoto:		codeword
	mov	(IP),	IP
	jmp	next

dobranch:	codeword
	minstk	1
	cmp	$0,	TOS
	je	__brk
	mov	(IP),	IP
	jmp	_drop
__brk:	advance	IP
	jmp	_drop

dountil:	codeword
	minstk	1
	cmp	$0,	TOS
	jne	__brk
	sub	(IP),	IP
	jmp	_drop

#	Kernel

verb	code	EXIT
	pop	IP
	jmp	next

dictionaryhead:
verb	code	EXECUTE
	minstk	1
	mov	TOS,	WP
	mov	(SP),	TOS
	advance	SP
	jmp	*(WP)
dictionaryend:

# "STACK"

	.skip	1048576
stack:	.quad	0

# "CORE VARIABLES"

rspbk:	.quad	0

buff:	.quad	0
