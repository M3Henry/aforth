#	Compiler

verb	forth	HERE
	variable
	endword

verb	forth	modeI	"["	immediate
	set	MODE	0
	endword

verb	forth	modeC	"]"
	set	MODE	-1
	endword

verb	forth	ALLOT
	get	HERE
	do	plus
	set	HERE
	endword

verb	forth	COMPILE	"COMPILE"	immediate
	get	HERE
	do	store
	const	8
	do	ALLOT
	endword

verb	forth	compnew	"\x3A"				# :
	do	modeC
	get	HERE
	get	LAST
	do	COMPILE
	do	WORD
	do	fetch
	const	8
	do	plus
	do	ALLOT
	do	TRUE
	do	COMPILE
	const	enter
	do	COMPILE
	endword

verb	forth	compend	"\x3B"	immediate		# ;
	const	EXIT
	do	COMPILE
	do	modeI
	set	LAST
	endword
