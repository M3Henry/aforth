#	Input

verb	forth	TIB
	scratch	256	#80
	endword

verb	forth	numtib	"\#TIB"
	variable
	endword

verb	forth	numin	"\#IN"
	variable
	endword

verb	code	ACCEPT
	minstk	2
	mov	$0,	CMD
	mov	$0,	ARGA
	mov	(SP),	ARGB
	mov	TOS,	ARGC
	syscall
	mov	CMD,	(SP)
	jmp	_drop

verb	forth	WORD
	do	pushret
	do	HERE
	const	0
	do	OVER
	do	store
	const	8
	do	plus
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
		do	less
		do	OVER
		do	peekret
		do	equal
		do	OR
		if	2f
			do	HERE
			do	incaddr
			do	OVER
			do	storeb
			do	inc
			goto	1b
	2:	do	DROP
3:	do	popret
	do	drop2
	do	HERE
	endword
