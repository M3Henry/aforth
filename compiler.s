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

.macro compile value
.ifnb \value
	const	\value
.endif
	do	COMPILE
.endm

verb	forth	compnew	"\x3A"				# :
	do	modeC
	get	HERE
	get	LAST
	compile
	do	WORD
	do	fetch
	const	8
	do	plus
	do	ALLOT
	compile	-1
	compile	enter
	endword

verb	forth	compend	"\x3B"	immediate		# ;
	compile	EXIT
	do	modeI
	set	LAST
	endword

verb	forth	BEGIN	"BEGIN"	immediate
	get	HERE
	endword

verb	forth	AGAIN	"AGAIN"	immediate
	compile	dogoto
	compile
	endword

verb	forth	UNTIL	"UNTIL"	immediate
	compile	iszero
	compile	dobranch
	compile
	endword

verb	forth	WHILE	"WHILE"	immediate
	compile	iszero
	compile	dobranch
	get	HERE
	do	SWAP
	compile
	endword

verb	forth	REPEAT	"REPEAT"	immediate
	compile	dogoto
	do	DUP
	do	fetch
	compile
	get	HERE
	do	SWAP
	do	store
	endword
