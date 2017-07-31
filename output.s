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

verb	forth	CR
	const	'\n'
	do	EMIT
	endword

verb	forth	SPACE
	const	' '
	do	EMIT
	endword

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
