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

verb	forth	dup2	"2DUP"
	do	OVER
	do	OVER
	endword

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

verb	code	ROT
	minstk	3
	mov	(SP),	ACC
	mov	TOS,	(SP)
	mov	-8(SP),	TOS
	mov	ACC,	-8(SP)
	jmp	next

verb	code	ROLL
	minstk	1
	cmp	TOS,	0
	je	1f
	shl	TOS
	shl	TOS
	shl	TOS
	add	SP,	TOS
	mov	(TOS),	TOS
1:	jmp	next

verb	code	DEPTH
	mov	$stack,	ACC
	sub	SP,	ACC
	shr	ACC
	shr	ACC
	shr	ACC
	_dup
	mov	ACC,	TOS
	jmp	next

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

verb	code	peekret	"R@"
	_dup
	mov	(%rsp),	TOS
	jmp	next
