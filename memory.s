#	Memory management

verb	code	fetch	"@>"
	minstk	1
	mov	$0x0000FFFFFFFFFFFF, ACC
	and	ACC,	TOS
	mov	(TOS),	TOS
	jmp	next

fetchb:		codeword
	minstk	1
	movb	(TOS),	TOSB
	and	$0xFF,	TOS
	jmp	next

verb	code	store	">@"
	minstk	2
	mov	$0x0000FFFFFFFFFFFF, ACC
	and	ACC,	TOS
	mov	(SP),	ACC
	mov	ACC,	(TOS)
	jmp	_drop2

.macro	storei value:req variable
.ifnb	\variable
	const	value
	const	variable
.else
	const	value
	do	SWAP
.endif
	do	store
.endm

storeb:		codeword
	minstk	2
	mov	(SP),	ACC
	movb	ACCB,	(TOS)
	jmp	_drop2

verb	forth	QUADCMP
2:	do	DUP
	if	1f
		do	drop2
		do	DROP
		do	TRUE
		endword
1:	do	pushret				# Count
	do	dup2				#
	do	indneq				#
	if	0f				#
		do	inc			#
		do	SWAP			#
		do	inc			#
		do	SWAP			#
		do	popret			#
		do	dec
		goto	2b

0:	do	drop2				# (Count)
	do	popret				#
	do	DROP
	do	FALSE
	endword

verb	forth	STRCMP
	do	dup2
	do	fetch
	do	SWAP
	do	fetch
	do	equal
	unless	0f
		do	OVER
		do	fetch
		const	8
		do	divmod
		do	SWAP
		do	pushret			# Quotient
		do	DUP			#
		do	pushret			# # Remainder
		do	plus			# #
		do	SWAP			# #
		do	popret			# #
		do	plus			#
		do	popret			#
		do	inc
		do	QUADCMP
		endword
0:	do	drop2
	do	FALSE
	endword

verb	forth	CMOVE
2:	test	equal	0	1f
		do	dec
		do	pushret					# Count
		do	OVER					#
		do	fetchb					#
		do	OVER					#
		do	storeb					#
		const	8					#
		do	plus					#
		do	SWAP					#
		const	8					#
		do	plus					#
		do	SWAP					#
		do	popret					#
		goto	2
1:	do	DROP
	do	drop2
	endword

verb	forth	STRMOVE
	do	OVER
	do	fetch
	const	8
	do	plus
	do	CMOVE
	endword
