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

verb	forth	LEAVE "LEAVE" immediate
	compile popret			# #
	compile	popret			#
	compile dogoto
	get	HERE
	do	SIFTDO
	do	store
	compile	0
	endword

verb	forth	loopI	"I"	immediate	# ( -- uint )
	compile	popret			# #
	compile	popret			#
	compile	DUP
	compile	pushret			# Loop Counter
	compile	SWAP			#
	compile	pushret			# # Loop End
	endword

verb	forth	LOOP	"LOOP"	immediate
	compile	popret			# #
	compile	popret			#
	compile	inc
	compile	dup2
	compile	nequal
0:	compile	dobranch
	do	DUP
		compile
	do	DUP
	do	fetch
	test	equal	pushret	1f
		const	thing
		do	linksapply
		const	pushret
		do	SWAP
		do	store
		goto	2f
1:	do	drop2
2:	compile	drop2
	endword

noverb	forth linksapply			# ( ptr func -- )
	do	OVER
	if	1f
		do	drop2
		endword
1:	do	OVER
	do	fetch
	do	OVER
	do	linksapply
	do	EXECUTE
	endword

noverb	forth thing
	get	HERE
	do	SWAP
	do	store
	endword

noverb	forth resolveleaves
	do	DUP
	do	fetch
	do	DUP
	if	1f
		do	DROP
		endword
1:	do	resolveleaves
	get	HERE
	do	SWAP
	do	store
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
	goto	0b	# Can use LOOP logic

verb	forth	SIFTDO				# ( {sys} -- {sys} sys )
	do	DUP
	do	fetch
	const	pushret
	do	equal
	if	1f
		do	pushret		# Unrelated stack item
		do	SIFTDO		#
		do	popret		#
		do	SWAP
		endword
1:	do	DUP
	endword

#	Conditionals

verb	forth	IF	"IF"	immediate
	compile iszero
	compile	dobranch
	compile	0
	endword

verb	forth	ELSE	"ELSE"	immediate
	compile dogoto
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

verb	forth	STRIPFLAGS
	const	0x0000FFFFFFFFFFFF
	do	AND
	endword

verb	forth	GETFLAGS
	const	0x0001000000000000
	do	divide
	endword

verb	forth	SETFLAGS
	const	0x0001000000000000
	do	mult
	do	OR
	endword

verb	forth	SIFTFLAGS
	do	OVER
	do	GETFLAGS
	do	OVER
	do	equal
	if	1f
		do	SWAP
		do	pushret			# Unrelated stack item
		do	SIFTFLAGS		#
		do	popret			#
		do	SWAP
		endword
1:	do	DROP
	do	DUP
	do	STRIPFLAGS
	endword
