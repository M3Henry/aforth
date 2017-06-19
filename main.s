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

.macro	variable
	do	dovar
	.quad	0
.endm

.macro	get var
	do	\var
	do	fetch
.endm

.macro	set var value
	const	\value
	do	\var
	do	store
.endm

.macro	string msg
	do	dostr
	.quad	9f - 8f
8:	.ascii	"\msg\()"
9:
.endm

.macro	say msg
	string	"\msg\()"
	do	print
.endm

.macro	saycr msg
	say	"\msg\()\n"
.endm

.macro	scratch length
	const	8f
	goto	9f
8:	.skip	\length
9:
.endm

.macro	goto label
	do	dogoto
	.quad	\label
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

.macro	debug
	do	dup
	do	dot
	do	cr
.endm

.macro	offset var distance
	do	\var
	const	\distance
	do	plus
.endm

	.data

cold:		forthword
_cold:	saycr	"aFORTH alpha \xe2\x9c\x93"
	set	numtib	0
	do	abort

abort:		forthword
	do	quit

quit:		forthword
	const	10
	const	4
	do	flag
	const	greet
	do	execute
	do	dottest
	do	inputtest
	set	numin	0
	1:	do	getword
		do	dup
		do	print
		string	"VERYLONGWORDIE"
		do	strcmp
		unless	2f
			say	" *"
	2:	do	cr
		get	numin
		get	numtib
		do	less
		if	1b
	do	dotdot
	saycr	"Done."
	do	halt

dottest:	forthword
	const	-1234090
	do	dot
	do	cr
	endword

inputtest:	forthword
	do	tib
	do	dup
	const	80
	say	"Enter something: >"
	do	accept
	do	dup
	do	numtib
	do	store
	do	cr
	say	"Read "
	do	dup
	do	dot
	saycr	" characters."

	say	"["
	do	type
	saycr	"]"
	endword

getword:	forthword
	set	pad	0
	offset	pad	8

1:	get	numin
	get	numtib
	do	gequal
	if	3f
	do	tib
	get	numin
	do	plus
	do	fetchb
	do	numin
	do	incaddr
	do	dup
	const	' '
	do	equal
	if	2f
		do	pad
		do	incaddr
		do	over
		do	storeb
		do	inc
		goto	1b
2:	do	drop
3:	do	drop
	do	pad
	endword

greet:		forthword
	say	"Hello, World!"
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

pad:		forthword
	scratch	90
	endword

tib:		forthword
	scratch	80
	endword

numtib:		forthword
	variable
	endword

numin:		forthword
	variable
	endword

cr:		forthword
	const	'\n'
	do	emit
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

dotdot:		forthword
	say	"..."
	do	top
	const	stack
	do	nequal
	if	1f
		say	"Stack Empty"
1:	do	_dotdot
	saycr	"..."
	endword

_dotdot:	forthword
	do	top
	const	stack
	do	equal
	if	1f
		do	pushret
		do	_dotdot
		do	popret
		const	'\t'
		do	emit
		do	dup
		do	dot
1:	endword

dup2:		forthword
	do	over
	do	over
	endword

min:		forthword
	do	dup2
	do	less
	if	1f
		do	swap
1:	do	drop
	endword

max:		forthword
	do	dup2
	do	greater
	if	1f
		do	swap
1:	do	drop
	endword

strcmp:		forthword
	do	dup2
	do	fetch
	do	swap
	do	fetch
	do	equal
	unless	0f
		do	over
		do	fetch
		const	8
		do	divide
		do	swap
		do	pushret			# Quotient
		do	dup			#
		do	pushret			# # Remainder
		do	plus			# #
		do	swap			# #
		do	popret			# #
		do	plus			#
		do	popret			#
		do	inc
		do	quadcmp
		endword
0:	do	drop2
	do	false
	endword

quadcmp:	forthword
2:	do	dup
	if	1f
		do	drop2
		do	drop
		do	true
		endword
1:	do	pushret
	do	dup2
	do	indneq
	if	0f
		do	inc
		do	swap
		do	inc
		do	swap
		do	popret
		do	dec
		goto	2b

0:	do	drop2
	do	popret
	do	drop
	do	false
	endword

buff:	.quad

stack:	.skip	1024	#1048576

#	Codeword macros

.macro	codeword
	.quad	. + 8
.endm

.macro	advance	register
	add	$8,	\register
.endm

.macro	retreat	register
	sub	$8,	\register
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

	.set	CMD,	%rax
	.set	ARGA,	%rdi
	.set	ARGB,	%rsi
	.set	ARGC,	%rdx
	.set	ARGD,	%r10
	.set	ARGE,	%r8
	.set	ARGF,	%r9


#	Stack manipulation

.macro	_dup
	advance	SP
	mov	TOS,	(SP)
.endm
dup:		codeword
	_dup
	jmp	next

drop2:		codeword
_drop2:	retreat	SP
	mov	(SP),	TOS
	retreat	SP
	jmp	next

drop:		codeword
_drop:	mov	(SP),	TOS
	retreat	SP
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
	mov	$1,	CMD	# system call 1 is write
        mov	$1,	ARGA	# file handle 1 is stdout
        mov	$buff,	ARGB	# address of string to output
        mov	$1,	ARGC	# number of bytes
        syscall
	jmp	_drop

print:		codeword
	mov	$1,	CMD
        mov	$1,	ARGA
        mov	(TOS),	ARGC
	advance	TOS
        mov	TOS,	ARGB
	syscall
	jmp	_drop
type:		codeword
	mov	$1,	CMD
	mov	$1,	ARGA
	mov	(SP),	ARGB
	mov	TOS,	ARGC
	syscall
	jmp	_drop2

halt:		codeword
	xor     ARGA,	ARGA	# default return code 0
	sub	$stack, SP
	jz	_halt
		mov	TOS,	ARGA
_halt:	mov     $60,	CMD	# system call 60 is exit
	syscall

#	Input

accept:		codeword
	mov	$0,	CMD
	mov	$0,	ARGA
	mov	(SP),	ARGB
	mov	TOS,	ARGC
	syscall
	mov	CMD,	(SP)
	jmp	_drop

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
	cmp	$0,	TOS
	je	__brk
	mov	(IP),	IP
	jmp	_drop
__brk:	advance	IP
	jmp	_drop

dountil:	codeword
	cmp	$0,	TOS
	jne	__brk
	sub	(IP),	IP
	jmp	_drop

#	Memory management

fetch:		codeword
	mov	(TOS),	TOS
	jmp	next

fetchb:		codeword
	movb	(TOS),	TOSB
	and	$0xFF,	TOS
	jmp	next

store:		codeword
	mov	(SP),	ACC
	mov	ACC,	(TOS)
	jmp	_drop2

storeb:		codeword
	mov	(SP),	ACC
	movb	ACCB,	(TOS)
	jmp	_drop2

top:		codeword
	push	SP
	_dup
	pop	TOS
	jmp	next

pushret:	codeword
	push	TOS
	jmp	_drop

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

incaddr:	codeword
	incq	(TOS)
	jmp	_drop

decaddr:	codeword
	decq	(TOS)
	jmp	_drop

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

.macro	cmpaddr	op
		codeword
	mov	(SP),	ACC
	mov	(ACC),	ACC
	cmp	(TOS),	ACC
	\op	truecmp
	movq	$0,	(SP)
	jmp	_drop
.endm

truecmp:
	movq	$-1,	(SP)
	jmp	_drop

equal:		compare	je
nequal:		compare	jne
greater:	compare	jg
less:		compare	jl
gequal:		compare	jge
lequal:		compare	jle
above:		compare	ja
below:		compare	jb
aequal:		compare	jae
bequal:		compare	jbe

indeq:		cmpaddr	je
indneq:		cmpaddr	jne

#	Kernel

exit:		codeword
	pop	IP
	jmp	next

execute:	codeword
	mov	TOS,	WP
	mov	(SP),	TOS
	retreat	SP
	jmp	*(WP)

	.text

_start:	mov	$stack,	SP
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
