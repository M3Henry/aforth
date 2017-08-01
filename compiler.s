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

verb	forth	comma	","	immediate
	get	HERE
	do	store
	const	8
	do	ALLOT
	endword

.macro compile value
.ifnb \value
	const	\value
.endif
	do	comma
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

#	Indefinite Loops

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

#	Finite Loops

verb	forth	DO	"DO"	immediate
	get	HERE
	compile	pushret			# Loop Counter
	compile	pushret			# # Loop End
	endword				# #

verb	forth	LOOP	"LOOP"	immediate
	compile	popret			# #
	compile	popret			#
	compile	inc
	compile	dup2
	compile	nequal
	compile	dobranch
		compile
	compile	drop2
	endword

verb	forth	plusloop	"+LOOP"	immediate
	compile	popret			# #
	compile	SWAP			#
	compile	popret			#
	compile	SWAP
	compile	pushret			# Increment
	compile	dup2			#
	compile lequal			#
	compile	popret			#
	compile	SWAP
	compile	pushret			# Less Before?
	compile	plus			#
	compile	dup2			#
	compile	greater			#
	compile	popret			#
	compile XOR
	compile	dobranch
		compile
	compile	drop2
	endword

#	Conditionals

verb	forth	IF	"IF"	immediate
	compile iszero
	compile	dobranch
	get	HERE
	compile	0
	endword

verb	forth	ELSE	"ELSE"	immediate
	compile dogoto
	get	HERE
	compile 0
	do	SWAP
	get	HERE
	do	SWAP
	do	store
	endword

verb	forth	THEN	"THEN"	immediate
	get	HERE
	do	SWAP
	do	store
	endword
