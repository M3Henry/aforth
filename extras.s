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
