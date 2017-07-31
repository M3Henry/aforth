#	Dictionary

verb	forth	LAST
	variable
	endword

verb	forth	DICTIONARY
	get	LAST
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
	get	LAST
2:	do	dup2
	const	8
	do	plus
	do	STRCMP
	unless	1f
		const	24
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
