#	Compiler

noverb	forth	here
	variable
	endword

verb	forth	HERE
	get	here
	endword

verb	forth	modeI	"["	immediate
	set	MODE	0
	endword

verb	forth	modeC	"]"
	set	MODE	-1
	endword

verb	forth	ALLOT
	do	HERE
	do	plus
	set	here
	endword

verb	forth	comma	","	immediate
	do	HERE
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

#	Compiler Compiling

verb	forth	backwardmark	"MARK<"	immediate		# ( -- addr )
	do	HERE
	endword

verb	forth	backwardresolve	"<RESOLVE"	immediate	# ( addr -- )
	compile
	endword

verb	forth	forwardmark	"MARK>"	immdiate		# ( -- addr )
	do	HERE
	do	FALSE
	compile
	endword

verb	forth	forwardresolve	">RESOLVE"	immediate	# ( addr -- )
	do	HERE
	do	SWAP
	do	store
	endword

verb	forth	markstore ">@MARK"	immediate	# ( quad -- addr )
	do	HERE
	do	SWAP
	compile
	endword

#

verb	forth	compnew	"\x3A"	#":"
	do	modeC
	get	LAST
	do	markstore
	do	WORD
	do	fetch
	const	8
	do	plus
	do	ALLOT
	compile	enter
	endword

verb	forth	compend	"\x3B"	immediate	#";"
	compile	EXIT
	do	modeI
	set	LAST
	endword

verb	forth	IMMEDIATE
	get	LAST
	do	DUP
	const	0x8000000000000000
	do	OR
	do	store
	endword

#	Indefinite Loops

verb	forth	BEGIN	"BEGIN"	immediate
	do	backwardmark
	endword

verb	forth	AGAIN	"AGAIN"	immediate
	compile	dogoto
	do	backwardresolve
	endword

verb	forth	UNTIL	"UNTIL"	immediate
	compile	iszero
	compile	dobranch
	do	backwardresolve
	endword

verb	forth	WHILE	"WHILE"	immediate
	compile	iszero
	compile	dobranch
	do	forwardmark
	endword

verb	forth	REPEAT	"REPEAT"	immediate
	compile	dogoto
	do	SWAP
	do	backwardresolve
	do	forwardresolve
	endword

#	Finite Loops

verb	forth	DO	"DO"	immediate	# ( -- sys )
	const	pushret
	const	DO
	do	markstore		# Loop Counter	# (pushret)
	compile	pushret			# # Loop End
	endword				# #

verb	forth	LEAVE	"LEAVE" immediate	# ( {sys} -- {sys sys} )
	compile popret			# #
	compile	popret			#
#	compile	drop2
	compile dogoto
	do	SIFTDO
	endword

verb	forth	loopI	"I>"	immediate	# ( -- uint )
	compile	popret			# #
	compile	popret			#
	compile	DUP
	compile	pushret			# Loop Counter
	compile	SWAP			#
	compile	pushret			# # Loop End
	endword

verb	forth	LOOP	"LOOP"	immediate	# ( sys [sys...sys] -- )
	compile	popret			# #
	compile	popret			#
	compile	inc
	compile	dup2
	compile	nequal
0:	compile	dobranch
2:	do	DUP
	do	fetch
	const	DO
	do	equal
	if	1f				# Do an 8+ forwardresolve
		do	HERE
		const	8
		do	plus
		do	SWAP
		do	store
		goto	2b
1:	do	DUP
	do	backwardresolve
	do	store
	compile	drop2
	endword

noverb	forth	linksapply			# ( ptr func -- )
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

noverb	forth	SIFTDO				# ( {sys} -- {sys sys} )
	do	DUP
	do	fetch
	do	DUP
	const	DO
	do	equal
	do	SWAP
	const	LEAVE
	do	equal
	do	OR
	if	1f
		do	pushret		# Unrelated stack item
		do	SIFTDO		#
		do	popret		#
		endword
1:	const	LEAVE
	do	markstore
	endword

#	Conditionals

verb	forth	IF	"IF"	immediate
	compile iszero
	compile	dobranch
	do	forwardmark
	endword

verb	forth	ELSE	"ELSE"	immediate
	compile dogoto
	do	forwardmark
	do	SWAP
	do	forwardresolve
	endword

verb	forth	THEN	"THEN"	immediate
	do	forwardresolve
	endword

#	Flags

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
