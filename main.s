.macro	do label
	.quad	\label
.endm

.macro	forthword name
	do	enter
.endm

.macro	endword
	do	EXIT
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

.macro	set var:req value
.ifnb	\value
	const	\value
.endif
	do	\var
	do	store
.endm

.macro	strlit msg
	.quad	9f - 8f
8:	.ascii	"\msg\()"
9:
.endm

.macro	string msg
	do	dostr
	strlit	"\msg\()"
.endm

.macro	say msg
	string	"\msg\()"
	do	PRINT
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
	do	DUP
	const	\value
	do	\compare
	if	\target
.endm

.macro	unless label
	do	NOT
	if	\label
.endm

.macro	debug
	do	DUP
	do	dot
	do	CR
.endm

.macro	offset var distance
	do	\var
	const	\distance
	do	plus
.endm

.macro	verb type:req name:req altname end
.ifnb	\end
	.quad	0
.else
	.quad	7b - 8
.endif
.ifnb	\altname
7:	strlit	"\altname\()"
.else
7:	strlit	"\name\()"
.endif
\name\():	\type\()word
.endm

	.data

verb	forth	COLD	"COLD"	end
_cold:	saycr	"aFORTH alpha \xe2\x9c\x93"
	set	numtib	0
	do	ABORT

verb	forth	ABORT
	do	QUIT

verb	forth	QUIT
	const	10
	const	4
2:	do	TIB
	const	80
	say	"? "
	do	ACCEPT
	test	equal	0	1f
		set	numtib
		do	INTERPRET
		do	dotdot
		goto	2b
1:	saycr	"Done."
	do	HALT

verb	forth	INTERPRET
	set	numin	0
	1:	do	WORD
		do	FIND
		get	numin
		get	numtib
		do	less
		if	1b
	saycr	" ok"
	endword

verb	forth	WORD
	set	PAD	0
	offset	PAD	8

1:	get	numin
	get	numtib
	do	gequal
	if	3f
		do	TIB
		get	numin
		do	plus
		do	fetchb
		do	numin
		do	incaddr
		do	DUP
		const	' '
		do	lequal
		if	2f
			do	PAD
			do	incaddr
			do	OVER
			do	storeb
			do	inc
			goto	1b
	2:	do	DROP
3:	do	DROP
	do	PAD
	endword

verb	forth	FIND
	const	dictionaryhead
2:	do	dup2
	const	8
	do	plus
	do	STRCMP
	unless	1f
		const	16
		do	plus
		do	SWAP
		do	fetch
		do	plus
		do	EXECUTE
		endword
1:	do	fetch
	do	DUP
	if	2b
	do	drop2
	endword

verb	forth	greet	GREET
	say	"Hello, World!"
	do	CR
	endword

verb	forth	FLAG
	1:	do	OVER
		do	line
		do	dec
		do	DUP
		if	1b
	do	DROP
	do	DROP
	endword

line:		forthword
	1:	do	STAR
		do	dec
		do	DUP
		if	1b
	do	DROP
	do	CR
	endword

verb	forth	STAR
	const	'*'
	do	EMIT
	endword

verb	forth	SPACE
	const	' '
	do	EMIT
	endword

verb	forth	PAD
	scratch	90
	endword

verb	forth	TIB
	scratch	80
	endword

verb	forth	numtib	"#TIB"
	variable
	endword

verb	forth	numin	"#IN"
	variable
	endword

verb	forth	CR
	const	'\n'
	do	EMIT
	endword

verb	forth	dot	"."
	test	gequal	0	1f
	const	'-'
	do	EMIT
	do	NEGATE
1:	do	_dot
	endword

_dot:		forthword
	test	less	10	1f
		const	10
		do	divide
		do	SWAP
		do	_dot
1:
		const	'0'
		do	plus
		do	EMIT
	endword

verb	forth	dotdot	"..."
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
		do	pushret			# Top of stack
		do	_dotdot			#
		do	popret			#
		const	'\t'
		do	EMIT
		do	DUP
		do	dot
1:	endword

verb	forth	dup2	"2DUP"
	do	OVER
	do	OVER
	endword

verb	forth	MIN
	do	dup2
	do	less
	if	1f
		do	SWAP
1:	do	DROP
	endword

verb	forth	MAX
	do	dup2
	do	greater
	if	1f
		do	SWAP
1:	do	DROP
	endword

verb	forth	STRCMP
	do	dup2
	do	fetch
	do	SWAP
	do	fetch
	do	equal
	unless	0f
		do	OVER
		do	fetch
		const	8
		do	divide
		do	SWAP
		do	pushret			# Quotient
		do	DUP			#
		do	pushret			# # Remainder
		do	plus			# #
		do	SWAP			# #
		do	popret			# #
		do	plus			#
		do	popret			#
		do	inc
		do	QUADCMP
		endword
0:	do	drop2
	do	FALSE
	endword

verb	forth	QUADCMP
2:	do	DUP
	if	1f
		do	drop2
		do	DROP
		do	TRUE
		endword
1:	do	pushret				# Count
	do	dup2				#
	do	indneq				#
	if	0f				#
		do	inc			#
		do	SWAP			#
		do	inc			#
		do	SWAP			#
		do	popret			#
		do	dec
		goto	2b

0:	do	drop2				# (Count)
	do	popret				#
	do	DROP
	do	FALSE
	endword

buff:	.quad	0

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
verb	code	DUP
	_dup
	jmp	next

verb	code	drop2	"2DROP"
_drop2:	retreat	SP
	mov	(SP),	TOS
	retreat	SP
	jmp	next

verb	code	DROP
_drop:	mov	(SP),	TOS
	retreat	SP
	jmp	next

verb	code	SWAP
	push	TOS
	mov	(SP),	TOS
	pop	(SP)
	jmp	next

verb	code	OVER
	push	(SP)
	_dup
	pop	TOS
	jmp	next

#	Output

verb	code	EMIT
	movq	TOS,	buff
	mov	$1,	CMD	# system call 1 is write
        mov	$1,	ARGA	# file handle 1 is stdout
        mov	$buff,	ARGB	# address of string to output
        mov	$1,	ARGC	# number of bytes
        syscall
	jmp	_drop

verb	code	PRINT
	mov	$1,	CMD
        mov	$1,	ARGA
        mov	(TOS),	ARGC
	advance	TOS
        mov	TOS,	ARGB
	syscall
	jmp	_drop

verb	code	TYPE
	mov	$1,	CMD
	mov	$1,	ARGA
	mov	(SP),	ARGB
	mov	TOS,	ARGC
	syscall
	jmp	_drop2

verb	code	HALT
	xor     ARGA,	ARGA	# default return code 0
	sub	$stack, SP
	jz	1f
		mov	TOS,	ARGA
1:	mov     $60,	CMD	# system call 60 is exit
	syscall

#	Input

verb	code	ACCEPT
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

verb	code	fetch	"@"
	mov	(TOS),	TOS
	jmp	next

fetchb:		codeword
	movb	(TOS),	TOSB
	and	$0xFF,	TOS
	jmp	next

verb	code	store	"!"
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

verb	code	pushret	">R"
	push	TOS
	jmp	_drop

verb	code	popret	"R>"
	_dup
	pop	TOS
	jmp	next

#	Logic

verb	code	TRUE
	_dup
	movq	$-1,	TOS
	jmp	next

verb	code	FALSE
	_dup
	xor	TOS,	TOS
	jmp	next

verb	code	lshift	"<<"
	shl	TOS
	jmp	next

verb	code	rshift	">>"
	shr	TOS
	jmp	next

verb	code	NOT
	not	TOS
	jmp	next

verb	code	AND
	and	TOS,	(SP)
	jmp	_drop

verb	code	OR
	or	TOS,	(SP)
	jmp	_drop

verb	code	XOR
	xor	TOS,	(SP)
	jmp	_drop

#	Maths

verb	code	plus	"+"
	add	TOS,	(SP)
	jmp	_drop

verb	code	minus	"-"
	sub	TOS,	(SP)
	jmp	_drop

verb	code	inc	"1+"
	inc	TOS
	jmp	next

verb	code	dec	"1-"
	dec	TOS
	jmp	next

verb	code	incaddr	"*1+"
	incq	(TOS)
	jmp	_drop

verb	code	decaddr	"*1-"
	decq	(TOS)
	jmp	_drop

verb	code	NEGATE
	neg	TOS
	jmp	next

#multiply:	codeword

verb	code	divide	"/%"
	xor	%rdx,	%rdx
	mov	(SP),	%rax
	div	TOS
	mov	%rax,	(SP)
	mov	%rdx,	TOS
	jmp	next

#	Comparison

.macro	compare	op	name	altname
verb	code	\name	"\altname\()"
	cmp	TOS,	(SP)
	\op	truecmp
	movq	$0,	(SP)
	jmp	_drop
.endm

.macro	cmpaddr	op	name	altname
verb	code	\name	"\altname\()"
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

compare	je	equal	"\="
compare	jne	nequal	"<>"
compare	jg	greater	">"
compare	jl	less	"<"
compare	jge	gequal	">="
compare	jle	lequal	"<="
compare	ja	above	"S>"
compare	jb	below	"S<"
compare	jae	aequal	"S>="
compare	jbe	bequal	"S<="

cmpaddr	je	indeq	"@@="
cmpaddr	jne	indneq	"@@<>"

#	Kernel

verb	code	EXIT
	pop	IP
	jmp	next

dictionaryhead:
verb	code	EXECUTE
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
