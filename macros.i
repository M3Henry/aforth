.macro	do label
	.quad	\label
.endm

.macro	forthword immediate
.ifnb	\immediate
	.quad	0x8000000000000000 + enter
.else
	.quad	enter
.endif
.endm

.macro	endword
	do	EXIT
.endm

.macro	const val
	do	docon
	.quad	\val
.endm

.macro	variable init
	do	dovar
.ifnb	\init
	.quad	\init
.else
	.quad	0
.endif
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

.macro	escape val
	say	"\x1B[\val\()m"
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
	do	iszero
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

.macro	verb type:req name:req altname immediate
	.quad	7b - 8
.ifnb	\altname
7:	strlit	"\altname\()"
.else
7:	strlit	"\name\()"
.endif
.ifnb	\immediate
\name\():	\type\()word	\immediate
.else
\name\():	\type\()word
.endif
.endm

.macro	noverb type:req name:req immediate
.ifnb	\immediate
\name\():	\type\()word	\immediate
.else
\name\():	\type\()word
.endif
.endm

#	Codeword macros

.macro	codeword immediate
.ifnb	\immediate
	.quad	0x8000000000000008 + .
.else
	.quad	. + 8
.endif
.endm

.macro	advance	register
	add	$8,	\register
.endm

.macro	retreat	register
	sub	$8,	\register
.endm

#	Stack manipulation

.macro	_dup
	retreat	SP
	mov	TOS,	(SP)
.endm

#	Comparison

.macro	compare	op	name	altname
verb	code	\name	"\altname\()"
	minstk	2
	cmp	TOS,	(SP)
	\op	truecmp
	movq	$0,	(SP)
	jmp	_drop
.endm

.macro	cmpaddr	op	name	altname
verb	code	\name	"\altname\()"
	minstk	2
	mov	(SP),	ACC
	mov	(ACC),	ACC
	cmp	(TOS),	ACC
	\op	truecmp
	movq	$0,	(SP)
	jmp	_drop
.endm

.macro	minstk	depth:req
	cmp	$stack - ( \depth * 8 ), SP
	jle	1f
		mov	$_uflow,	IP
		jmp	next
1:
.endm
