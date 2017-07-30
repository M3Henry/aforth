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

#	Interpreter

verb	forth	PAD
	scratch	90
	endword

verb	forth	TIB
	scratch	80
	endword

verb	forth	numtib	"\#TIB"
	variable
	endword

verb	forth	numin	"\#IN"
	variable
	endword

verb	forth	MODE
	variable
	endword

verb	forth	INTERPRET
	set	numin	0
	3:	do	WORD
		do	DUP
		do	fetch
		if	0f
			do	DROP
			goto	2f
	0:	do	FIND
		if	1f
			const	0
			do	SWAP
			do	DUP
			const	8
			do	plus
			do	SWAP
			do	fetch
			do	CONVERT
			do	drop2
			test	greater	0	2f
				do	DROP
				do	PAD
				escape	91
				say	"Unknown token: "
				do	PRINT
				do	CR
				do	ABORT
			goto	2f
		1:	const	8
			do	plus
			do	EXECUTE
	2:	get	numin
		get	numtib
		do	less
		if	3b
	escape	92
	do	DEPTH
	test	equal	0	4f
	say	" ⏎ "
	test	equal	1	5f
	do	DUP
	do	dot
5:	do	DROP
	say	"["
	do	DUP
	do	dot
	saycr	"]"
	endword
4:	do	DROP
	saycr	" 🗸"
	endword

verb	forth	CONVERT
2:	test	equal	0	1f
	do	pushret
	do	DUP
	do	pushret
	do	fetchb
	const	'0'
	do	minus
	test	greater	9	0f
		do	SWAP
		const	10
		do	mult
		do	plus
		do	popret
		do	inc
		do	popret
		do	dec
		goto	2b
0:	do	DROP
	do	popret
	do	popret
1:	endword

verb	forth	WORD
	set	PAD	0
	offset	PAD	8
1:		get	numin
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

verb	forth	DICTIONARY
	const	dictionaryhead
2:	do	DUP
	do	fetch
	const	0
	do	equal
	if	1f
		do	DUP
		const	8
		do	plus
		do	PRINT
		do	fetch
		do	SPACE
		goto	2b
1:	do	DROP
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
		do	TRUE
		endword
1:	do	fetch
	do	DUP
	if	2b
	do	DROP
	do	FALSE
	endword

#	User Words

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
	1:	const	'*'
		do	EMIT
		do	dec
		do	DUP
		if	1b
	do	DROP
	do	CR
	endword

verb	forth	SPACE
	const	' '
	do	EMIT
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
		do	divmod
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
		do	divmod
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

verb	forth	divide	"/"
	do	divmod
	do	DROP
	endword

verb	forth	mod	"%"
	do	divmod
	do	SWAP
	do	DROP
	endword

verb	forth	muldiv	"*/"
	do	muldivmod
	do	DROP
	endword

verb	forth	iszero	"0="
	do	FALSE
	do	equal
	endword

# "CODEWORDS"


#	Stack manipulation

verb	code	RESETDATA
	mov	$stack,	SP
	jmp	next

verb	code	RESETRETURN
	mov	rspbk,	%rsp
	jmp	next

verb	code	DUP
	minstk	1
	_dup
	jmp	next

verb	code	drop2	"2DROP"
	minstk	2
_drop2:	advance	SP
	mov	(SP),	TOS
	advance	SP
	jmp	next

verb	code	DROP
	minstk	1
_drop:	mov	(SP),	TOS
	advance	SP
	jmp	next

_uflow:	do	RESETDATA
	saycr	"\x1B[91m Stack underflow!"
	do	QUIT

verb	code	SWAP
	minstk	2
	push	TOS
	mov	(SP),	TOS
	pop	(SP)
	jmp	next

verb	code	OVER
	minstk	2
	push	(SP)
	_dup
	pop	TOS
	jmp	next

#	Output

verb	code	EMIT
	minstk	1
	movq	TOS,	buff
	mov	$1,	CMD	# system call 1 is write
        mov	$1,	ARGA	# file handle 1 is stdout
        mov	$buff,	ARGB	# address of string to output
        mov	$1,	ARGC	# number of bytes
        syscall
	jmp	_drop

verb	code	PRINT
	minstk	1
	mov	$1,	CMD
        mov	$1,	ARGA
        mov	(TOS),	ARGC
	advance	TOS
        mov	TOS,	ARGB
	syscall
	jmp	_drop

verb	code	TYPE
	minstk	2
	mov	$1,	CMD
	mov	$1,	ARGA
	mov	(SP),	ARGB
	mov	TOS,	ARGC
	syscall
	jmp	_drop2

verb	code	HALT
_halt:	xor     ARGA,	ARGA	# default return code 0
	sub	$stack, SP
	jz	1f
		mov	TOS,	ARGA
1:	mov     $60,	CMD	# system call 60 is exit
	syscall

#	Input

verb	code	ACCEPT
	minstk	2
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

#	Memory management

verb	code	DEPTH
	mov	$stack,	ACC
	sub	SP,	ACC
	shr	ACC
	shr	ACC
	shr	ACC
	_dup
	mov	ACC,	TOS
	jmp	next

verb	code	fetch	"@>"
	minstk	1
	mov	(TOS),	TOS
	jmp	next

fetchb:		codeword
	minstk	1
	movb	(TOS),	TOSB
	and	$0xFF,	TOS
	jmp	next

verb	code	store	">@"
	minstk	2
	mov	(SP),	ACC
	mov	ACC,	(TOS)
	jmp	_drop2

storeb:		codeword
	minstk	2
	mov	(SP),	ACC
	movb	ACCB,	(TOS)
	jmp	_drop2

top:		codeword
	push	SP
	_dup
	pop	TOS
	jmp	next

verb	code	pushret	">R"
	minstk	1
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

verb	code	FALSE	"0"
	_dup
	xor	TOS,	TOS
	jmp	next

verb	code	lshift	"<<"
	minstk	1
	shl	TOS
	jmp	next

verb	code	rshift	">>"
	minstk	1
	shr	TOS
	jmp	next

verb	code	halve	"2/"
	minstk	1
	sar	TOS
	jmp	next

verb	code	NOT
	minstk	1
	not	TOS
	jmp	next

verb	code	AND
	minstk	2
	and	TOS,	(SP)
	jmp	_drop

verb	code	OR
	minstk	2
	or	TOS,	(SP)
	jmp	_drop

verb	code	XOR
	minstk	2
	xor	TOS,	(SP)
	jmp	_drop

#	Maths

verb	code	plus	"+"
	minstk	2
	add	TOS,	(SP)
	jmp	_drop

verb	code	minus	"-"
	minstk	2
	sub	TOS,	(SP)
	jmp	_drop

verb	code	inc	"1+"
	minstk	1
	inc	TOS
	jmp	next

verb	code	dec	"1-"
	minstk	1
	dec	TOS
	jmp	next

verb	code	incaddr	"@1+"
	minstk	1
	incq	(TOS)
	jmp	_drop

verb	code	decaddr	"@1-"
	minstk	1
	decq	(TOS)
	jmp	_drop

verb	code	NEGATE
	minstk	1
	neg	TOS
	jmp	next

verb	code	mult	"*"
	minstk	2
	mov	(SP),	%rax
	mul	TOS
	mov	%rax,	(SP)
	jmp	_drop

verb	code	divmod	"/%"
	minstk	2
	xor	%rdx,	%rdx
	mov	(SP),	%rax
	div	TOS
	mov	%rax,	(SP)
	mov	%rdx,	TOS
	jmp	next

verb	code	muldivmod	"*/%"
	minstk	3
	mov	(SP),	%rax
	mul	TOS
	divq	-8(SP)
	mov	%rax,	-8(SP)
	mov	%rdx,	(SP)
	jmp	_drop

#	Comparison

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

cmpaddr	je	indeq	"@="
cmpaddr	jne	indneq	"@<>"

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


# "STACK"

	.skip	1048576
stack:	.quad	0

# "CORE VARIABLES"

rspbk:	.quad	0

buff:	.quad	0
