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
