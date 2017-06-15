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

.macro	string length data
	.quad	dostr
	.quad	\length
	.ascii	"\data\()"
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
	const	10
	const	4
	.quad	flag
	.quad	cr
	string	13	"Hello, World!"
	.quad	print
	.quad	cr
	.quad	halt

flag:	forthword
	flaglp:	.quad	over
		.quad	line
		.quad	dec
		.quad	dup
	while	flaglp
	.quad	drop
	.quad	drop
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

cr:	forthword
	string	2	"\n\r"
	.quad	print
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
	.set	TOSB,	%r15b
	.set	SP,	%r14
	.set	IP,	%r13
	.set	WP,	%r12
	.set	ACC,	%r11
	.set	ACCB,	%r11b

#	Stack manipulation

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

swap:		codeword
	push	TOS
	mov	(SP),	TOS
	pop	(SP)
	jmp	next

over:		codeword
	push	(SP)
	_dup
	pop	TOS
	jmp	next

#	Output

emit:		codeword
	movq	TOS,	buff
	mov	$1,	%rax	# system call 1 is write
        mov	$1,	%rdi	# file handle 1 is stdout
        mov	$buff,	%rsi	# address of string to output
        mov	$1,	%rdx	# number of bytes
        syscall
	jmp	_drop

print:		codeword
	mov	$1,	%rax
        mov	$1,	%rdi
        mov	(TOS),	%rdx
	add	$8,	TOS
        mov	TOS,	%rsi
	syscall
	jmp	_drop

halt:		codeword
	xor     %rdi,	%rdi	# default return code 0
	sub	$stack, SP
	jz	_halt
		mov	TOS,	%rdi
_halt:	mov     $60,	%rax	# system call 60 is exit
	syscall

#	Do Stuff

docon:		codeword
	_dup
	mov	(IP),	TOS
	advanceIP
	jmp	next

dostr:		codeword
	_dup
	mov	IP,	TOS
	add	(IP),	IP
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
	advanceIP
	jmp	_drop

#	Memory management

at:		codeword
	mov	(TOS),	TOS
	jmp	next

atb:		codeword
	movb	(TOS),	TOSB
	jmp	next

bang:		codeword
	mov	(SP),	ACC
	mov	ACC,	(TOS)
	jmp	_drop2

bangb:		codeword
	mov	(SP),	ACC
	movb	ACCB,	(TOS)
	jmp	_drop2

#	Logic

true:		codeword
	_dup
	mov	$-1,	TOS
	jmp	next

false:		codeword
	_dup
	xor	TOS,	TOS
	jmp	next

lshift:		codeword
	shl	TOS
	jmp	next

rshift:		codeword
	shr	TOS
	jmp	next

not:		codeword
	not	TOS
	jmp	next

and:		codeword
	and	TOS,	(SP)
	jmp	_drop

or:		codeword
	or	TOS,	(SP)
	jmp	_drop

xor:		codeword
	xor	TOS,	(SP)
	jmp	_drop

#	Maths

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

#	Kernel

exit:		codeword
	pop	IP
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
