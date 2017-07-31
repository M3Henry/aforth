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

verb	forth	divide	"/"
	do	divmod
	do	DROP
	endword

verb	forth	mod	"%"
	do	divmod
	do	SWAP
	do	DROP
	endword

verb	code	muldivmod	"*/%"
	minstk	3
	mov	(SP),	%rax
	mul	TOS
	divq	-8(SP)
	mov	%rax,	-8(SP)
	mov	%rdx,	(SP)
	jmp	_drop

verb	forth	muldiv	"*/"
	do	muldivmod
	do	DROP
	endword

#	Functions

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

#	Comparison

verb	forth	iszero	"0="
	do	FALSE
	do	equal
	endword

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
