#	Interpreter

verb	forth	MODE
	variable
	endword

verb	forth	INTERPRET
	set	numin	0
	3:	const	' '
		do	WORD
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
			test	greater	0	5f
				do	HERE
				escape	91
				say	"Unknown token: "
				do	PRINT
				do	CR
				do	ABORT
		5:	get MODE
			unless	2f
				const	docon
				do	comma
				do	comma
				goto	2f
		1:	do	DUP
			do	fetch
			const	0x8000000000000000
			do	AND
			do	iszero
			get	MODE
			do	AND
			if	1f
				do	EXECUTE
				goto	2f
		1:	do	comma
	2:	get	numin
		get	numtib
		do	less
		if	3b
	escape	92
	do	DEPTH
	test	equal	0	4f
	say	" ok "
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
	saycr	" ok."
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
