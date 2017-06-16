.macro	do label
	.quad	\label
.endm

.macro	forthword
	do	enter
.endm

.macro	endword
	do	exit
.endm

.macro	const val
	do	docon
	.quad	\val
.endm

.macro	string data
	do	dostr
	.quad	2f - 1f
1:	.ascii	"\data\()"
2:
.endm

.macro	if label
	do	dobranch
	.quad	\label
.endm

.macro	test compare:req value:req target:req
	do	dup
	const	\value
	do	\compare
	if	\target
.endm

.macro	unless label
	do	not
	if	\label
.endm

	.data

cold:		forthword
_cold:	do	abort

abort:		forthword
	do	quit

quit:		forthword
	const	10
	const	4
	do	flag
	const	greet
	do	execute
	do	dottest
	do	halt

dottest:	forthword
	const	-1234090
	do	dot
	do	cr
	endword

greet:		forthword
	string	"Hello, World!"
	do	print
	do	cr
	endword

flag:		forthword
	1:	do	over
		do	line
		do	dec
		do	dup
		if	1b
	do	drop
	do	drop
	endword

line:		forthword
	1:	do	star
		do	dec
		do	dup
		if	1b
	do	drop
	do	cr
	endword

star:		forthword
	const	'*'
	do	emit
	endword

cr:		forthword
	string	"\n\r"
	do	print
	endword

dot:		forthword
	test	gequal	0	1f
	const	'-'
	do	emit
	do	negate
1:	do	_dot
	endword

_dot:		forthword
	test	less	10	1f
		const	10
		do	divide
		do	swap
		do	_dot
1:
		const	'0'
		do	plus
		do	emit
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

dojump:		codeword
	mov	(IP),	IP
	jmp	next

dobranch:	codeword
	cmp	$0,	TOS
	je	__brk
	mov	(IP),	IP
	jmp	_drop
__brk:	advanceIP
	jmp	_drop

dountil:	codeword
	cmp	$0,	TOS
	jne	__brk
	sub	(IP),	IP
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

top:		codeword
	_dup
	mov	SP,	TOS
	jmp	next

pushret:	codeword
	push	TOS
	jmp	drop

popret:		codeword
	_dup
	pop	TOS
	jmp	next

#	Logic

true:		codeword
	_dup
	movq	$-1,	TOS
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

negate:		codeword
	neg	TOS
	jmp	next

multiply:	codeword
divide:		codeword
	xor	%rdx,	%rdx
	mov	(SP),	%rax
	div	TOS
	mov	%rax,	(SP)
	mov	%rdx,	TOS
	jmp	next

#	Comparison

.macro	compare	op
		codeword
	cmp	TOS,	(SP)
	\op	truecmp
	movq	$0,	(SP)
	jmp	_drop
.endm

truecmp:
	movq	$-1,	(SP)
	jmp	_drop

equal:		compare je
nequal:		compare	jne
greater:	compare	jg
less:		compare jl
gequal:		compare	jge
lequal:		compare	jle
above:		compare	ja
below:		compare jb
aequal:		compare	jae
bequal:		compare	jbe

#	Kernel

exit:		codeword
	pop	IP
	jmp	next

execute:	codeword
	mov	TOS,	WP
	mov	(SP),	TOS
	sub	$8,	SP
	jmp	next2

	.text

_start:	mov	$stack,	SP
	mov	$_cold,	IP
next:
	mov	(IP),	WP
next2:	advanceIP
	jmp	*(WP)

enter:
	push	IP
	mov	WP,	IP
	advanceIP
	jmp	next
