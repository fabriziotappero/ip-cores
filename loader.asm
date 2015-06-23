IN_RX_DATA	= 0x00			;
IN_STATUS	= 0x01			;

MEMTOP		= 0x2000

OUT_TX_DATA	= 0x00			;
;---------------------------------------;
RELOC_SRC	= start+Cend_text-stack	;
;---------------------------------------;
					;
	MOVE	#reloc_rr, RR		;
	MOVE	RR, SP			;
	MOVE	#MEMTOP, LL		; destination
reloc:					;
	MOVE	(SP)+, RR		; restore source
	MOVE	-(RR), -(LL)		;
	MOVE	RR, -(SP)		; save source
	SHI	RR, #start		;
	JMP	RRNZ, reloc		;
	MOVE	#stack, RR		;
	MOVE	RR, SP			;
	CALL	Cmain			;
halt:					;
	HALT				;
reloc_rr:				; source
	.WORD	RELOC_SRC		;
;---------------------------------------;
start:					;
	.OFFSET	MEMTOP			;
stack:					;
;---------------------------------------;
;;; { 0 FunctionDefinition
;;;   { 1 TypeName
;;;     { 2 TypeSpecifier (all)
;;;       spec = int (80000)
;;;     } 2 TypeSpecifier (all)
;;;     { 2 List<DeclItem>
;;;       { 3 DeclItem
;;;         what = DECL_NAME
;;;         name = getchr
;;;       } 3 DeclItem
;;;     } 2 List<DeclItem>
;;;   } 1 TypeName
;;;   { 1 List<DeclItem>
;;;     { 2 DeclItem
;;;       what = DECL_NAME
;;;       name = getchr
;;;     } 2 DeclItem
;;;     { 2 DeclItem
;;;       what = DECL_FUN
;;;     } 2 DeclItem
;;;   } 1 List<DeclItem>
Cgetchr:
;;;   { 1 CompoundStatement
;;;     { 2 List<while Statement>
;;;       { 3 while Statement
L2_loop_1:
;;;         { 4 ExpressionStatement
;;;         } 4 ExpressionStatement
L2_cont_1:
;;;         { 4 Expr ! r
;;;           { 5 Expr l & r
;;;             { 6 TypeName (internal)
;;;               { 7 TypeSpecifier (all)
;;;                 spec = int (80000)
;;;               } 7 TypeSpecifier (all)
;;;             } 6 TypeName (internal)
	IN   (IN_STATUS), RU
;--	l & r
	AND	RR, #0x0001
;;;           } 5 Expr l & r
;--	16 bit ! r
	LNOT	RR
;;;         } 4 Expr ! r
;--	branch_true
	JMP	RRNZ, L2_loop_1
L2_brk_2:
;;;       } 3 while Statement
;;;       { 3 ExpressionStatement
IN   (IN_RX_DATA), RU
;;;       } 3 ExpressionStatement
;;;     } 2 List<while Statement>
;--	pop 0 bytes
;;;   } 1 CompoundStatement
;--	ret
	RET
;;; ------------------------------------;
;;;   { 1 FunctionDefinition
;;;     { 2 TypeName
;;;       { 3 TypeSpecifier (all)
;;;         spec = void (10000)
;;;       } 3 TypeSpecifier (all)
;;;       { 3 List<DeclItem>
;;;         { 4 DeclItem
;;;           what = DECL_NAME
;;;           name = putchr
;;;         } 4 DeclItem
;;;       } 3 List<DeclItem>
;;;     } 2 TypeName
;;;     { 2 List<DeclItem>
;;;       { 3 DeclItem
;;;         what = DECL_NAME
;;;         name = putchr
;;;       } 3 DeclItem
;;;       { 3 DeclItem
;;;         what = DECL_FUN
;;;         { 4 List<ParameterDeclaration>
;;;           { 5 ParameterDeclaration
;;;             isEllipsis = false
;;;             { 6 TypeName
;;;               { 7 TypeSpecifier (all)
;;;                 spec = char (20000)
;;;               } 7 TypeSpecifier (all)
;;;               { 7 List<DeclItem>
;;;                 { 8 DeclItem
;;;                   what = DECL_NAME
;;;                   name = c
;;;                 } 8 DeclItem
;;;               } 7 List<DeclItem>
;;;             } 6 TypeName
;;;           } 5 ParameterDeclaration
;;;         } 4 List<ParameterDeclaration>
;;;       } 3 DeclItem
;;;     } 2 List<DeclItem>
Cputchr:
;;;     { 2 CompoundStatement
;;;       { 3 List<while Statement>
;;;         { 4 while Statement
L3_loop_3:
;;;           { 5 ExpressionStatement
;;;           } 5 ExpressionStatement
L3_cont_3:
;;;           { 5 Expr l & r
;;;             { 6 TypeName (internal)
;;;               { 7 TypeSpecifier (all)
;;;                 spec = int (80000)
;;;               } 7 TypeSpecifier (all)
;;;             } 6 TypeName (internal)
	IN (IN_STATUS), RU
;--	l & r
	AND	RR, #0x0002
;;;           } 5 Expr l & r
;--	branch_true
	JMP	RRNZ, L3_loop_3
L3_brk_4:
;;;         } 4 while Statement
;;;         { 4 ExpressionStatement
	MOVE 2(SP), RU
;;;         } 4 ExpressionStatement
;;;         { 4 ExpressionStatement
	OUT  R, (OUT_TX_DATA)
;;;         } 4 ExpressionStatement
;;;       } 3 List<while Statement>
;--	pop 0 bytes
;;;     } 2 CompoundStatement
;--	ret
	RET
;;; ------------------------------------;
;;;     { 2 FunctionDefinition
;;;       { 3 TypeName
;;;         { 4 TypeSpecifier (all)
;;;           spec = void (10000)
;;;         } 4 TypeSpecifier (all)
;;;         { 4 List<DeclItem>
;;;           { 5 DeclItem
;;;             what = DECL_NAME
;;;             name = print_string
;;;           } 5 DeclItem
;;;         } 4 List<DeclItem>
;;;       } 3 TypeName
;;;       { 3 List<DeclItem>
;;;         { 4 DeclItem
;;;           what = DECL_NAME
;;;           name = print_string
;;;         } 4 DeclItem
;;;         { 4 DeclItem
;;;           what = DECL_FUN
;;;           { 5 List<ParameterDeclaration>
;;;             { 6 ParameterDeclaration
;;;               isEllipsis = false
;;;               { 7 TypeName
;;;                 { 8 TypeSpecifier (all)
;;;                   spec = const char (20100)
;;;                 } 8 TypeSpecifier (all)
;;;                 { 8 List<DeclItem>
;;;                   { 9 DeclItem
;;;                     what = DECL_POINTER
;;;                     { 10 List<Ptr>
;;;                       { 11 Ptr
;;;                       } 11 Ptr
;;;                     } 10 List<Ptr>
;;;                   } 9 DeclItem
;;;                   { 9 DeclItem
;;;                     what = DECL_NAME
;;;                     name = buffer
;;;                   } 9 DeclItem
;;;                 } 8 List<DeclItem>
;;;               } 7 TypeName
;;;             } 6 ParameterDeclaration
;;;           } 5 List<ParameterDeclaration>
;;;         } 4 DeclItem
;;;       } 3 List<DeclItem>
Cprint_string:
;;;       { 3 CompoundStatement
;;;         { 4 List<while Statement>
;;;           { 5 while Statement
;--	branch
	JMP	L4_cont_5
L4_loop_5:
;;;             { 6 ExpressionStatement
;;;               { 7 Expr l(r)
;;;                 { 8 TypeName
;;;                   { 9 TypeSpecifier (all)
;;;                     spec = void (10000)
;;;                   } 9 TypeSpecifier (all)
;;;                   { 9 List<DeclItem>
;;;                     { 10 DeclItem
;;;                       what = DECL_NAME
;;;                       name = putchr
;;;                     } 10 DeclItem
;;;                   } 9 List<DeclItem>
;;;                 } 8 TypeName
;;;                 { 8 ParameterDeclaration
;;;                   isEllipsis = false
;;;                   { 9 TypeName
;;;                     { 10 TypeSpecifier (all)
;;;                       spec = char (20000)
;;;                     } 10 TypeSpecifier (all)
;;;                     { 10 List<DeclItem>
;;;                       { 11 DeclItem
;;;                         what = DECL_NAME
;;;                         name = c
;;;                       } 11 DeclItem
;;;                     } 10 List<DeclItem>
;;;                   } 9 TypeName
;;;                 } 8 ParameterDeclaration
;;;                 { 8 Expr * r
;;;                   { 9 Expr l - r
;;;                     { 10 Expr ++r
;;;                       { 11 Expression (variable name)
;;;                         expr_type = "identifier" (buffer)
;--	load_rr_var buffer = 2(FP), SP at 0 (16 bit)
	MOVE	2(SP), RR
;;;                       } 11 Expression (variable name)
;--	++
	ADD	RR, #0x0001
;--	store_rr_var buffer = 2(FP), SP at 0
	MOVE	RR, 2(SP)
;;;                     } 10 Expr ++r
;--	l - r
	SUB	RR, #0x0001
;;;                   } 9 Expr l - r
;--	content
	MOVE	(RR), RS
;;;                 } 8 Expr * r
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;--	push 0 bytes
;--	call
	CALL	Cputchr
;--	pop 1 bytes
	ADD	SP, #1
;;;               } 7 Expr l(r)
;;;             } 6 ExpressionStatement
L4_cont_5:
;;;             { 6 Expr * r
;;;               { 7 Expression (variable name)
;;;                 expr_type = "identifier" (buffer)
;--	load_rr_var buffer = 2(FP), SP at 0 (16 bit)
	MOVE	2(SP), RR
;;;               } 7 Expression (variable name)
;--	content
	MOVE	(RR), RS
;;;             } 6 Expr * r
;--	branch_true
	JMP	RRNZ, L4_loop_5
L4_brk_6:
;;;           } 5 while Statement
;;;         } 4 List<while Statement>
;--	pop 0 bytes
;;;       } 3 CompoundStatement
;--	ret
	RET
;;; ------------------------------------;
;;;       { 3 FunctionDefinition
;;;         { 4 TypeName
;;;           { 5 TypeSpecifier (all)
;;;             spec = unsigned char (22000)
;;;           } 5 TypeSpecifier (all)
;;;           { 5 List<DeclItem>
;;;             { 6 DeclItem
;;;               what = DECL_NAME
;;;               name = get_nibble
;;;             } 6 DeclItem
;;;           } 5 List<DeclItem>
;;;         } 4 TypeName
;;;         { 4 List<DeclItem>
;;;           { 5 DeclItem
;;;             what = DECL_NAME
;;;             name = get_nibble
;;;           } 5 DeclItem
;;;           { 5 DeclItem
;;;             what = DECL_FUN
;;;           } 5 DeclItem
;;;         } 4 List<DeclItem>
Cget_nibble:
;;;         { 4 CompoundStatement
;;;           { 5 InitDeclarator
;;;             { 6 List<DeclItem>
;;;               { 7 DeclItem
;;;                 what = DECL_NAME
;;;                 name = c
;;;               } 7 DeclItem
;;;             } 6 List<DeclItem>
;;;             { 6 Initializer (skalar)
;;;               { 7 Expr l(r)
;;;                 { 8 TypeName
;;;                   { 9 TypeSpecifier (all)
;;;                     spec = int (80000)
;;;                   } 9 TypeSpecifier (all)
;;;                   { 9 List<DeclItem>
;;;                     { 10 DeclItem
;;;                       what = DECL_NAME
;;;                       name = getchr
;;;                     } 10 DeclItem
;;;                   } 9 List<DeclItem>
;;;                 } 8 TypeName
;--	push 2 bytes
;--	call
	CALL	Cgetchr
;--	pop 0 bytes
;;;               } 7 Expr l(r)
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;;;             } 6 Initializer (skalar)
;;;           } 5 InitDeclarator
;;;           { 5 List<IfElseStatement>
;;;             { 6 IfElseStatement
;;;               { 7 Expr l < r
;;;                 { 8 TypeName (internal)
;;;                   { 9 TypeSpecifier (all)
;;;                     spec = unsigned int (82000)
;;;                   } 9 TypeSpecifier (all)
;;;                 } 8 TypeName (internal)
;;;                 { 8 Expression (variable name)
;;;                   expr_type = "identifier" (c)
;--	load_rr_var c = -1(FP), SP at -1 (8 bit)
	MOVE	0(SP), RU
;;;                 } 8 Expression (variable name)
;--	l < r
	SLO	RR, #0x0030
;;;               } 7 Expr l < r
;--	branch_false
	JMP	RRZ, L5_endif_7
;;;               { 7 return Statement
;;;                 { 8 NumericExpression (constant 255 = 0xFF)
;--	load_rr_constant
	MOVE	#0x00FF, RR
;;;                 } 8 NumericExpression (constant 255 = 0xFF)
;--	ret
	ADD	SP, #1
	RET
;;;               } 7 return Statement
L5_endif_7:
;;;             } 6 IfElseStatement
;;;             { 6 IfElseStatement
;;;               { 7 Expr l <= r
;;;                 { 8 TypeName (internal)
;;;                   { 9 TypeSpecifier (all)
;;;                     spec = unsigned int (82000)
;;;                   } 9 TypeSpecifier (all)
;;;                 } 8 TypeName (internal)
;;;                 { 8 Expression (variable name)
;;;                   expr_type = "identifier" (c)
;--	load_rr_var c = -1(FP), SP at -1 (8 bit)
	MOVE	0(SP), RU
;;;                 } 8 Expression (variable name)
;--	l <= r
	SLS	RR, #0x0039
;;;               } 7 Expr l <= r
;--	branch_false
	JMP	RRZ, L5_endif_8
;;;               { 7 return Statement
;;;                 { 8 Expr l - r
;;;                   { 9 Expression (variable name)
;;;                     expr_type = "identifier" (c)
;--	load_rr_var c = -1(FP), SP at -1 (8 bit)
	MOVE	0(SP), RU
;;;                   } 9 Expression (variable name)
;--	l - r
	SUB	RR, #0x0030
;;;                 } 8 Expr l - r
;--	ret
	ADD	SP, #1
	RET
;;;               } 7 return Statement
L5_endif_8:
;;;             } 6 IfElseStatement
;;;             { 6 IfElseStatement
;;;               { 7 Expr l < r
;;;                 { 8 TypeName (internal)
;;;                   { 9 TypeSpecifier (all)
;;;                     spec = unsigned int (82000)
;;;                   } 9 TypeSpecifier (all)
;;;                 } 8 TypeName (internal)
;;;                 { 8 Expression (variable name)
;;;                   expr_type = "identifier" (c)
;--	load_rr_var c = -1(FP), SP at -1 (8 bit)
	MOVE	0(SP), RU
;;;                 } 8 Expression (variable name)
;--	l < r
	SLO	RR, #0x0041
;;;               } 7 Expr l < r
;--	branch_false
	JMP	RRZ, L5_endif_9
;;;               { 7 return Statement
;;;                 { 8 NumericExpression (constant 255 = 0xFF)
;--	load_rr_constant
	MOVE	#0x00FF, RR
;;;                 } 8 NumericExpression (constant 255 = 0xFF)
;--	ret
	ADD	SP, #1
	RET
;;;               } 7 return Statement
L5_endif_9:
;;;             } 6 IfElseStatement
;;;             { 6 IfElseStatement
;;;               { 7 Expr l <= r
;;;                 { 8 TypeName (internal)
;;;                   { 9 TypeSpecifier (all)
;;;                     spec = unsigned int (82000)
;;;                   } 9 TypeSpecifier (all)
;;;                 } 8 TypeName (internal)
;;;                 { 8 Expression (variable name)
;;;                   expr_type = "identifier" (c)
;--	load_rr_var c = -1(FP), SP at -1 (8 bit)
	MOVE	0(SP), RU
;;;                 } 8 Expression (variable name)
;--	l <= r
	SLS	RR, #0x0046
;;;               } 7 Expr l <= r
;--	branch_false
	JMP	RRZ, L5_endif_10
;;;               { 7 return Statement
;;;                 { 8 Expr l - r
;;;                   { 9 Expression (variable name)
;;;                     expr_type = "identifier" (c)
;--	load_rr_var c = -1(FP), SP at -1 (8 bit)
	MOVE	0(SP), RU
;;;                   } 9 Expression (variable name)
;--	l - r
	SUB	RR, #0x0037
;;;                 } 8 Expr l - r
;--	ret
	ADD	SP, #1
	RET
;;;               } 7 return Statement
L5_endif_10:
;;;             } 6 IfElseStatement
;;;             { 6 IfElseStatement
;;;               { 7 Expr l < r
;;;                 { 8 TypeName (internal)
;;;                   { 9 TypeSpecifier (all)
;;;                     spec = unsigned int (82000)
;;;                   } 9 TypeSpecifier (all)
;;;                 } 8 TypeName (internal)
;;;                 { 8 Expression (variable name)
;;;                   expr_type = "identifier" (c)
;--	load_rr_var c = -1(FP), SP at -1 (8 bit)
	MOVE	0(SP), RU
;;;                 } 8 Expression (variable name)
;--	l < r
	SLO	RR, #0x0061
;;;               } 7 Expr l < r
;--	branch_false
	JMP	RRZ, L5_endif_11
;;;               { 7 return Statement
;;;                 { 8 NumericExpression (constant 255 = 0xFF)
;--	load_rr_constant
	MOVE	#0x00FF, RR
;;;                 } 8 NumericExpression (constant 255 = 0xFF)
;--	ret
	ADD	SP, #1
	RET
;;;               } 7 return Statement
L5_endif_11:
;;;             } 6 IfElseStatement
;;;             { 6 IfElseStatement
;;;               { 7 Expr l <= r
;;;                 { 8 TypeName (internal)
;;;                   { 9 TypeSpecifier (all)
;;;                     spec = unsigned int (82000)
;;;                   } 9 TypeSpecifier (all)
;;;                 } 8 TypeName (internal)
;;;                 { 8 Expression (variable name)
;;;                   expr_type = "identifier" (c)
;--	load_rr_var c = -1(FP), SP at -1 (8 bit)
	MOVE	0(SP), RU
;;;                 } 8 Expression (variable name)
;--	l <= r
	SLS	RR, #0x0066
;;;               } 7 Expr l <= r
;--	branch_false
	JMP	RRZ, L5_endif_12
;;;               { 7 return Statement
;;;                 { 8 Expr l - r
;;;                   { 9 Expression (variable name)
;;;                     expr_type = "identifier" (c)
;--	load_rr_var c = -1(FP), SP at -1 (8 bit)
	MOVE	0(SP), RU
;;;                   } 9 Expression (variable name)
;--	l - r
	SUB	RR, #0x0057
;;;                 } 8 Expr l - r
;--	ret
	ADD	SP, #1
	RET
;;;               } 7 return Statement
L5_endif_12:
;;;             } 6 IfElseStatement
;;;             { 6 return Statement
;;;               { 7 NumericExpression (constant 255 = 0xFF)
;--	load_rr_constant
	MOVE	#0x00FF, RR
;;;               } 7 NumericExpression (constant 255 = 0xFF)
;--	ret
	ADD	SP, #1
	RET
;;;             } 6 return Statement
;;;           } 5 List<IfElseStatement>
;--	pop 1 bytes
	ADD	SP, #1
;;;         } 4 CompoundStatement
;--	ret
	RET
;;; ------------------------------------;
;;;         { 4 FunctionDefinition
;;;           { 5 TypeName
;;;             { 6 TypeSpecifier (all)
;;;               spec = int (80000)
;;;             } 6 TypeSpecifier (all)
;;;             { 6 List<DeclItem>
;;;               { 7 DeclItem
;;;                 what = DECL_NAME
;;;                 name = get_byte
;;;               } 7 DeclItem
;;;             } 6 List<DeclItem>
;;;           } 5 TypeName
;;;           { 5 List<DeclItem>
;;;             { 6 DeclItem
;;;               what = DECL_NAME
;;;               name = get_byte
;;;             } 6 DeclItem
;;;             { 6 DeclItem
;;;               what = DECL_FUN
;;;             } 6 DeclItem
;;;           } 5 List<DeclItem>
Cget_byte:
;;;           { 5 CompoundStatement
;;;             { 6 InitDeclarator
;;;               { 7 List<DeclItem>
;;;                 { 8 DeclItem
;;;                   what = DECL_NAME
;;;                   name = hi
;;;                 } 8 DeclItem
;;;               } 7 List<DeclItem>
;;;               { 7 Initializer (skalar)
;;;                 { 8 Expr l(r)
;;;                   { 9 TypeName
;;;                     { 10 TypeSpecifier (all)
;;;                       spec = unsigned char (22000)
;;;                     } 10 TypeSpecifier (all)
;;;                     { 10 List<DeclItem>
;;;                       { 11 DeclItem
;;;                         what = DECL_NAME
;;;                         name = get_nibble
;;;                       } 11 DeclItem
;;;                     } 10 List<DeclItem>
;;;                   } 9 TypeName
;--	push 1 bytes
;--	call
	CALL	Cget_nibble
;--	pop 0 bytes
;;;                 } 8 Expr l(r)
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;;;               } 7 Initializer (skalar)
;;;             } 6 InitDeclarator
;;;             { 6 InitDeclarator
;;;               { 7 List<DeclItem>
;;;                 { 8 DeclItem
;;;                   what = DECL_NAME
;;;                   name = lo
;;;                 } 8 DeclItem
;;;               } 7 List<DeclItem>
;--	push_zero 1 bytes
	CLRB	-(SP)
;;;             } 6 InitDeclarator
;;;             { 6 List<IfElseStatement>
;;;               { 7 IfElseStatement
;;;                 { 8 Expr l != r
;;;                   { 9 TypeName (internal)
;;;                     { 10 TypeSpecifier (all)
;;;                       spec = unsigned int (82000)
;;;                     } 10 TypeSpecifier (all)
;;;                   } 9 TypeName (internal)
;;;                   { 9 Expression (variable name)
;;;                     expr_type = "identifier" (hi)
;--	load_rr_var hi = -1(FP), SP at -2 (8 bit)
	MOVE	1(SP), RU
;;;                   } 9 Expression (variable name)
;--	l != r
	SNE	RR, #0x00FF
;;;                 } 8 Expr l != r
;--	branch_false
	JMP	RRZ, L6_endif_13
;;;                 { 8 CompoundStatement
;;;                   { 9 List<ExpressionStatement>
;;;                     { 10 ExpressionStatement
;;;                       { 11 Expr l = r
;;;                         { 12 TypeName
;;;                           { 13 TypeSpecifier (all)
;;;                             spec = unsigned char (22000)
;;;                           } 13 TypeSpecifier (all)
;;;                           { 13 List<DeclItem>
;;;                             { 14 DeclItem
;;;                               what = DECL_NAME
;;;                               name = lo
;;;                             } 14 DeclItem
;;;                           } 13 List<DeclItem>
;;;                         } 12 TypeName
;;;                         { 12 Expr l(r)
;;;                           { 13 TypeName
;;;                             { 14 TypeSpecifier (all)
;;;                               spec = unsigned char (22000)
;;;                             } 14 TypeSpecifier (all)
;;;                             { 14 List<DeclItem>
;;;                               { 15 DeclItem
;;;                                 what = DECL_NAME
;;;                                 name = get_nibble
;;;                               } 15 DeclItem
;;;                             } 14 List<DeclItem>
;;;                           } 13 TypeName
;--	push 1 bytes
;--	call
	CALL	Cget_nibble
;--	pop 0 bytes
;;;                         } 12 Expr l(r)
;--	store_rr_var lo = -2(FP), SP at -2
	MOVE	R, 0(SP)
;;;                       } 11 Expr l = r
;;;                     } 10 ExpressionStatement
;;;                     { 10 IfElseStatement
;;;                       { 11 Expr l != r
;;;                         { 12 TypeName (internal)
;;;                           { 13 TypeSpecifier (all)
;;;                             spec = unsigned int (82000)
;;;                           } 13 TypeSpecifier (all)
;;;                         } 12 TypeName (internal)
;;;                         { 12 Expression (variable name)
;;;                           expr_type = "identifier" (lo)
;--	load_rr_var lo = -2(FP), SP at -2 (8 bit)
	MOVE	0(SP), RU
;;;                         } 12 Expression (variable name)
;--	l != r
	SNE	RR, #0x00FF
;;;                       } 11 Expr l != r
;--	branch_false
	JMP	RRZ, L6_endif_14
;;;                       { 11 return Statement
;;;                         { 12 Expr l | r
;;;                           { 13 TypeName (internal)
;;;                             { 14 TypeSpecifier (all)
;;;                               spec = unsigned int (82000)
;;;                             } 14 TypeSpecifier (all)
;;;                           } 13 TypeName (internal)
;;;                           { 13 Expr l << r
;;;                             { 14 TypeName (internal)
;;;                               { 15 TypeSpecifier (all)
;;;                                 spec = int (80000)
;;;                               } 15 TypeSpecifier (all)
;;;                             } 14 TypeName (internal)
;;;                             { 14 Expression (variable name)
;;;                               expr_type = "identifier" (hi)
;--	load_rr_var hi = -1(FP), SP at -2 (8 bit)
	MOVE	1(SP), RU
;;;                             } 14 Expression (variable name)
;--	l << r
	LSL	RR, #0x0004
;;;                           } 13 Expr l << r
;--	move_rr_to_ll
	MOVE	RR, LL
;;;                           { 13 Expression (variable name)
;;;                             expr_type = "identifier" (lo)
;--	load_rr_var lo = -2(FP), SP at -2 (8 bit)
	MOVE	0(SP), RU
;;;                           } 13 Expression (variable name)
;--	l | r
	OR	LL, RR
;;;                         } 12 Expr l | r
;--	ret
	ADD	SP, #2
	RET
;;;                       } 11 return Statement
L6_endif_14:
;;;                     } 10 IfElseStatement
;;;                   } 9 List<ExpressionStatement>
;--	pop 0 bytes
;;;                 } 8 CompoundStatement
L6_endif_13:
;;;               } 7 IfElseStatement
;;;               { 7 ExpressionStatement
;;;                 { 8 Expr l(r)
;;;                   { 9 TypeName
;;;                     { 10 TypeSpecifier (all)
;;;                       spec = void (10000)
;;;                     } 10 TypeSpecifier (all)
;;;                     { 10 List<DeclItem>
;;;                       { 11 DeclItem
;;;                         what = DECL_NAME
;;;                         name = print_string
;;;                       } 11 DeclItem
;;;                     } 10 List<DeclItem>
;;;                   } 9 TypeName
;;;                   { 9 ParameterDeclaration
;;;                     isEllipsis = false
;;;                     { 10 TypeName
;;;                       { 11 TypeSpecifier (all)
;;;                         spec = const char (20100)
;;;                       } 11 TypeSpecifier (all)
;;;                       { 11 List<DeclItem>
;;;                         { 12 DeclItem
;;;                           what = DECL_POINTER
;;;                           { 13 List<Ptr>
;;;                             { 14 Ptr
;;;                             } 14 Ptr
;;;                           } 13 List<Ptr>
;;;                         } 12 DeclItem
;;;                         { 12 DeclItem
;;;                           what = DECL_NAME
;;;                           name = buffer
;;;                         } 12 DeclItem
;;;                       } 11 List<DeclItem>
;;;                     } 10 TypeName
;;;                   } 9 ParameterDeclaration
;;;                   { 9 StringExpression
;--	load_rr_string
	MOVE	#Cstr_5, RR
;;;                   } 9 StringExpression
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;--	push 0 bytes
;--	call
	CALL	Cprint_string
;--	pop 2 bytes
	ADD	SP, #2
;;;                 } 8 Expr l(r)
;;;               } 7 ExpressionStatement
;;;               { 7 ExpressionStatement
	HALT
;;;               } 7 ExpressionStatement
;;;             } 6 List<IfElseStatement>
;--	pop 2 bytes
	ADD	SP, #2
;;;           } 5 CompoundStatement
;--	ret
	RET
;;; ------------------------------------;
;;;           { 5 FunctionDefinition
;;;             { 6 TypeName
;;;               { 7 TypeSpecifier (all)
;;;                 spec = int (80000)
;;;               } 7 TypeSpecifier (all)
;;;               { 7 List<DeclItem>
;;;                 { 8 DeclItem
;;;                   what = DECL_NAME
;;;                   name = main
;;;                 } 8 DeclItem
;;;               } 7 List<DeclItem>
;;;             } 6 TypeName
;;;             { 6 List<DeclItem>
;;;               { 7 DeclItem
;;;                 what = DECL_NAME
;;;                 name = main
;;;               } 7 DeclItem
;;;               { 7 DeclItem
;;;                 what = DECL_FUN
;;;                 { 8 List<ParameterDeclaration>
;;;                   { 9 ParameterDeclaration
;;;                     isEllipsis = false
;;;                     { 10 TypeName
;;;                       { 11 TypeSpecifier (all)
;;;                         spec = int (80000)
;;;                       } 11 TypeSpecifier (all)
;;;                       { 11 List<DeclItem>
;;;                         { 12 DeclItem
;;;                           what = DECL_NAME
;;;                           name = argc
;;;                         } 12 DeclItem
;;;                       } 11 List<DeclItem>
;;;                     } 10 TypeName
;;;                   } 9 ParameterDeclaration
;;;                   { 9 ParameterDeclaration
;;;                     isEllipsis = false
;;;                     { 10 TypeName
;;;                       { 11 TypeSpecifier (all)
;;;                         spec = char (20000)
;;;                       } 11 TypeSpecifier (all)
;;;                       { 11 List<DeclItem>
;;;                         { 12 DeclItem
;;;                           what = DECL_POINTER
;;;                           { 13 List<Ptr>
;;;                             { 14 Ptr
;;;                             } 14 Ptr
;;;                           } 13 List<Ptr>
;;;                         } 12 DeclItem
;;;                         { 12 DeclItem
;;;                           what = DECL_NAME
;;;                           name = argv
;;;                         } 12 DeclItem
;;;                         { 12 DeclItem
;;;                           what = DECL_ARRAY
;;;                         } 12 DeclItem
;;;                       } 11 List<DeclItem>
;;;                     } 10 TypeName
;;;                   } 9 ParameterDeclaration
;;;                 } 8 List<ParameterDeclaration>
;;;               } 7 DeclItem
;;;             } 6 List<DeclItem>
Cmain:
;;;             { 6 CompoundStatement
;;;               { 7 InitDeclarator
;;;                 { 8 List<DeclItem>
;;;                   { 9 DeclItem
;;;                     what = DECL_NAME
;;;                     name = record_length
;;;                   } 9 DeclItem
;;;                 } 8 List<DeclItem>
;--	push_zero 1 bytes
	CLRB	-(SP)
;;;               } 7 InitDeclarator
;;;               { 7 InitDeclarator
;;;                 { 8 List<DeclItem>
;;;                   { 9 DeclItem
;;;                     what = DECL_NAME
;;;                     name = address
;;;                   } 9 DeclItem
;;;                 } 8 List<DeclItem>
;--	push_zero 2 bytes
	CLRW	-(SP)
;;;               } 7 InitDeclarator
;;;               { 7 InitDeclarator
;;;                 { 8 List<DeclItem>
;;;                   { 9 DeclItem
;;;                     what = DECL_NAME
;;;                     name = record_type
;;;                   } 9 DeclItem
;;;                 } 8 List<DeclItem>
;--	push_zero 1 bytes
	CLRB	-(SP)
;;;               } 7 InitDeclarator
;;;               { 7 InitDeclarator
;;;                 { 8 List<DeclItem>
;;;                   { 9 DeclItem
;;;                     what = DECL_NAME
;;;                     name = check_sum
;;;                   } 9 DeclItem
;;;                 } 8 List<DeclItem>
;--	push_zero 1 bytes
	CLRB	-(SP)
;;;               } 7 InitDeclarator
;;;               { 7 InitDeclarator
;;;                 { 8 List<DeclItem>
;;;                   { 9 DeclItem
;;;                     what = DECL_NAME
;;;                     name = i
;;;                   } 9 DeclItem
;;;                 } 8 List<DeclItem>
;--	push_zero 1 bytes
	CLRB	-(SP)
;;;               } 7 InitDeclarator
;;;               { 7 InitDeclarator
;;;                 { 8 List<DeclItem>
;;;                   { 9 DeclItem
;;;                     what = DECL_NAME
;;;                     name = c
;;;                   } 9 DeclItem
;;;                 } 8 List<DeclItem>
;--	push_zero 1 bytes
	CLRB	-(SP)
;;;               } 7 InitDeclarator
;;;               { 7 List<for Statement>
;;;                 { 8 for Statement
;;;                   { 9 ExpressionStatement
;;;                   } 9 ExpressionStatement
L7_loop_15:
;;;                   { 9 CompoundStatement
;;;                     { 10 List<ExpressionStatement>
;;;                       { 11 ExpressionStatement
;;;                         { 12 Expr l(r)
;;;                           { 13 TypeName
;;;                             { 14 TypeSpecifier (all)
;;;                               spec = void (10000)
;;;                             } 14 TypeSpecifier (all)
;;;                             { 14 List<DeclItem>
;;;                               { 15 DeclItem
;;;                                 what = DECL_NAME
;;;                                 name = print_string
;;;                               } 15 DeclItem
;;;                             } 14 List<DeclItem>
;;;                           } 13 TypeName
;;;                           { 13 ParameterDeclaration
;;;                             isEllipsis = false
;;;                             { 14 TypeName
;;;                               { 15 TypeSpecifier (all)
;;;                                 spec = const char (20100)
;;;                               } 15 TypeSpecifier (all)
;;;                               { 15 List<DeclItem>
;;;                                 { 16 DeclItem
;;;                                   what = DECL_POINTER
;;;                                   { 17 List<Ptr>
;;;                                     { 18 Ptr
;;;                                     } 18 Ptr
;;;                                   } 17 List<Ptr>
;;;                                 } 16 DeclItem
;;;                                 { 16 DeclItem
;;;                                   what = DECL_NAME
;;;                                   name = buffer
;;;                                 } 16 DeclItem
;;;                               } 15 List<DeclItem>
;;;                             } 14 TypeName
;;;                           } 13 ParameterDeclaration
;;;                           { 13 StringExpression
;--	load_rr_string
	MOVE	#Cstr_7, RR
;;;                           } 13 StringExpression
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;--	push 0 bytes
;--	call
	CALL	Cprint_string
;--	pop 2 bytes
	ADD	SP, #2
;;;                         } 12 Expr l(r)
;;;                       } 11 ExpressionStatement
;;;                       { 11 for Statement
;;;                         { 12 ExpressionStatement
;;;                         } 12 ExpressionStatement
L7_loop_17:
;;;                         { 12 CompoundStatement
;;;                           { 13 List<while Statement>
;;;                             { 14 while Statement
L7_loop_19:
;;;                               { 15 ExpressionStatement
;;;                               } 15 ExpressionStatement
L7_cont_19:
;;;                               { 15 Expr l != r
;;;                                 { 16 TypeName (internal)
;;;                                   { 17 TypeSpecifier (all)
;;;                                     spec = unsigned int (82000)
;;;                                   } 17 TypeSpecifier (all)
;;;                                 } 16 TypeName (internal)
;;;                                 { 16 Expr l = r
;;;                                   { 17 TypeName
;;;                                     { 18 TypeSpecifier (all)
;;;                                       spec = unsigned char (22000)
;;;                                     } 18 TypeSpecifier (all)
;;;                                     { 18 List<DeclItem>
;;;                                       { 19 DeclItem
;;;                                         what = DECL_NAME
;;;                                         name = c
;;;                                       } 19 DeclItem
;;;                                     } 18 List<DeclItem>
;;;                                   } 17 TypeName
;;;                                   { 17 Expr l(r)
;;;                                     { 18 TypeName
;;;                                       { 19 TypeSpecifier (all)
;;;                                         spec = int (80000)
;;;                                       } 19 TypeSpecifier (all)
;;;                                       { 19 List<DeclItem>
;;;                                         { 20 DeclItem
;;;                                           what = DECL_NAME
;;;                                           name = getchr
;;;                                         } 20 DeclItem
;;;                                       } 19 List<DeclItem>
;;;                                     } 18 TypeName
;--	push 2 bytes
;--	call
	CALL	Cgetchr
;--	pop 0 bytes
;;;                                   } 17 Expr l(r)
;--	store_rr_var c = -7(FP), SP at -7
	MOVE	R, 0(SP)
;;;                                 } 16 Expr l = r
;--	l != r
	SNE	RR, #0x003A
;;;                               } 15 Expr l != r
;--	branch_true
	JMP	RRNZ, L7_loop_19
L7_brk_20:
;;;                             } 14 while Statement
;;;                             { 14 ExpressionStatement
;;;                               { 15 Expr l = r
;;;                                 { 16 TypeName
;;;                                   { 17 TypeSpecifier (all)
;;;                                     spec = unsigned char (22000)
;;;                                   } 17 TypeSpecifier (all)
;;;                                   { 17 List<DeclItem>
;;;                                     { 18 DeclItem
;;;                                       what = DECL_NAME
;;;                                       name = check_sum
;;;                                     } 18 DeclItem
;;;                                   } 17 List<DeclItem>
;;;                                 } 16 TypeName
;;;                                 { 16 NumericExpression (constant 0 = 0x0)
;--	load_rr_constant
	MOVE	#0x0000, RR
;;;                                 } 16 NumericExpression (constant 0 = 0x0)
;--	store_rr_var check_sum = -5(FP), SP at -7
	MOVE	R, 2(SP)
;;;                               } 15 Expr l = r
;;;                             } 14 ExpressionStatement
;;;                             { 14 ExpressionStatement
;;;                               { 15 Expr l = r
;;;                                 { 16 TypeName
;;;                                   { 17 TypeSpecifier (all)
;;;                                     spec = unsigned char (22000)
;;;                                   } 17 TypeSpecifier (all)
;;;                                   { 17 List<DeclItem>
;;;                                     { 18 DeclItem
;;;                                       what = DECL_NAME
;;;                                       name = c
;;;                                     } 18 DeclItem
;;;                                   } 17 List<DeclItem>
;;;                                 } 16 TypeName
;;;                                 { 16 Expr l(r)
;;;                                   { 17 TypeName
;;;                                     { 18 TypeSpecifier (all)
;;;                                       spec = int (80000)
;;;                                     } 18 TypeSpecifier (all)
;;;                                     { 18 List<DeclItem>
;;;                                       { 19 DeclItem
;;;                                         what = DECL_NAME
;;;                                         name = get_byte
;;;                                       } 19 DeclItem
;;;                                     } 18 List<DeclItem>
;;;                                   } 17 TypeName
;--	push 2 bytes
;--	call
	CALL	Cget_byte
;--	pop 0 bytes
;;;                                 } 16 Expr l(r)
;--	store_rr_var c = -7(FP), SP at -7
	MOVE	R, 0(SP)
;;;                               } 15 Expr l = r
;;;                             } 14 ExpressionStatement
;;;                             { 14 ExpressionStatement
;;;                               { 15 Expr l += r
;;;                                 { 16 TypeName
;;;                                   { 17 TypeSpecifier (all)
;;;                                     spec = unsigned char (22000)
;;;                                   } 17 TypeSpecifier (all)
;;;                                   { 17 List<DeclItem>
;;;                                     { 18 DeclItem
;;;                                       what = DECL_NAME
;;;                                       name = check_sum
;;;                                     } 18 DeclItem
;;;                                   } 17 List<DeclItem>
;;;                                 } 16 TypeName
;;;                                 { 16 Expr l + r
;;;                                   { 17 Expression (variable name)
;;;                                     expr_type = "identifier" (check_sum)
;--	load_rr_var check_sum = -5(FP), SP at -7 (8 bit)
	MOVE	2(SP), RU
;;;                                   } 17 Expression (variable name)
;--	move_rr_to_ll
	MOVE	RR, LL
;;;                                   { 17 Expression (variable name)
;;;                                     expr_type = "identifier" (c)
;--	load_rr_var c = -7(FP), SP at -7 (8 bit)
	MOVE	0(SP), RU
;;;                                   } 17 Expression (variable name)
;--	scale_rr *1
;--	l + r
	ADD	LL, RR
;;;                                 } 16 Expr l + r
;--	store_rr_var check_sum = -5(FP), SP at -7
	MOVE	R, 2(SP)
;;;                               } 15 Expr l += r
;;;                             } 14 ExpressionStatement
;;;                             { 14 ExpressionStatement
;;;                               { 15 Expr l = r
;;;                                 { 16 TypeName
;;;                                   { 17 TypeSpecifier (all)
;;;                                     spec = unsigned char (22000)
;;;                                   } 17 TypeSpecifier (all)
;;;                                   { 17 List<DeclItem>
;;;                                     { 18 DeclItem
;;;                                       what = DECL_NAME
;;;                                       name = record_length
;;;                                     } 18 DeclItem
;;;                                   } 17 List<DeclItem>
;;;                                 } 16 TypeName
;;;                                 { 16 Expression (variable name)
;;;                                   expr_type = "identifier" (c)
;--	load_rr_var c = -7(FP), SP at -7 (8 bit)
	MOVE	0(SP), RU
;;;                                 } 16 Expression (variable name)
;--	store_rr_var record_length = -1(FP), SP at -7
	MOVE	R, 6(SP)
;;;                               } 15 Expr l = r
;;;                             } 14 ExpressionStatement
;;;                             { 14 ExpressionStatement
;;;                               { 15 Expr l = r
;;;                                 { 16 TypeName
;;;                                   { 17 TypeSpecifier (all)
;;;                                     spec = unsigned char (22000)
;;;                                   } 17 TypeSpecifier (all)
;;;                                   { 17 List<DeclItem>
;;;                                     { 18 DeclItem
;;;                                       what = DECL_NAME
;;;                                       name = c
;;;                                     } 18 DeclItem
;;;                                   } 17 List<DeclItem>
;;;                                 } 16 TypeName
;;;                                 { 16 Expr l(r)
;;;                                   { 17 TypeName
;;;                                     { 18 TypeSpecifier (all)
;;;                                       spec = int (80000)
;;;                                     } 18 TypeSpecifier (all)
;;;                                     { 18 List<DeclItem>
;;;                                       { 19 DeclItem
;;;                                         what = DECL_NAME
;;;                                         name = get_byte
;;;                                       } 19 DeclItem
;;;                                     } 18 List<DeclItem>
;;;                                   } 17 TypeName
;--	push 2 bytes
;--	call
	CALL	Cget_byte
;--	pop 0 bytes
;;;                                 } 16 Expr l(r)
;--	store_rr_var c = -7(FP), SP at -7
	MOVE	R, 0(SP)
;;;                               } 15 Expr l = r
;;;                             } 14 ExpressionStatement
;;;                             { 14 ExpressionStatement
;;;                               { 15 Expr l += r
;;;                                 { 16 TypeName
;;;                                   { 17 TypeSpecifier (all)
;;;                                     spec = unsigned char (22000)
;;;                                   } 17 TypeSpecifier (all)
;;;                                   { 17 List<DeclItem>
;;;                                     { 18 DeclItem
;;;                                       what = DECL_NAME
;;;                                       name = check_sum
;;;                                     } 18 DeclItem
;;;                                   } 17 List<DeclItem>
;;;                                 } 16 TypeName
;;;                                 { 16 Expr l + r
;;;                                   { 17 Expression (variable name)
;;;                                     expr_type = "identifier" (check_sum)
;--	load_rr_var check_sum = -5(FP), SP at -7 (8 bit)
	MOVE	2(SP), RU
;;;                                   } 17 Expression (variable name)
;--	move_rr_to_ll
	MOVE	RR, LL
;;;                                   { 17 Expression (variable name)
;;;                                     expr_type = "identifier" (c)
;--	load_rr_var c = -7(FP), SP at -7 (8 bit)
	MOVE	0(SP), RU
;;;                                   } 17 Expression (variable name)
;--	scale_rr *1
;--	l + r
	ADD	LL, RR
;;;                                 } 16 Expr l + r
;--	store_rr_var check_sum = -5(FP), SP at -7
	MOVE	R, 2(SP)
;;;                               } 15 Expr l += r
;;;                             } 14 ExpressionStatement
;;;                             { 14 ExpressionStatement
;;;                               { 15 Expr l = r
;;;                                 { 16 TypeName
;;;                                   { 17 TypeSpecifier (all)
;;;                                     spec = unsigned int (82000)
;;;                                   } 17 TypeSpecifier (all)
;;;                                   { 17 List<DeclItem>
;;;                                     { 18 DeclItem
;;;                                       what = DECL_NAME
;;;                                       name = address
;;;                                     } 18 DeclItem
;;;                                   } 17 List<DeclItem>
;;;                                 } 16 TypeName
;;;                                 { 16 Expr l << r
;;;                                   { 17 TypeName (internal)
;;;                                     { 18 TypeSpecifier (all)
;;;                                       spec = int (80000)
;;;                                     } 18 TypeSpecifier (all)
;;;                                   } 17 TypeName (internal)
;;;                                   { 17 Expression (variable name)
;;;                                     expr_type = "identifier" (c)
;--	load_rr_var c = -7(FP), SP at -7 (8 bit)
	MOVE	0(SP), RU
;;;                                   } 17 Expression (variable name)
;--	l << r
	LSL	RR, #0x0008
;;;                                 } 16 Expr l << r
;--	store_rr_var address = -3(FP), SP at -7
	MOVE	RR, 4(SP)
;;;                               } 15 Expr l = r
;;;                             } 14 ExpressionStatement
;;;                             { 14 ExpressionStatement
;;;                               { 15 Expr l = r
;;;                                 { 16 TypeName
;;;                                   { 17 TypeSpecifier (all)
;;;                                     spec = unsigned char (22000)
;;;                                   } 17 TypeSpecifier (all)
;;;                                   { 17 List<DeclItem>
;;;                                     { 18 DeclItem
;;;                                       what = DECL_NAME
;;;                                       name = c
;;;                                     } 18 DeclItem
;;;                                   } 17 List<DeclItem>
;;;                                 } 16 TypeName
;;;                                 { 16 Expr l(r)
;;;                                   { 17 TypeName
;;;                                     { 18 TypeSpecifier (all)
;;;                                       spec = int (80000)
;;;                                     } 18 TypeSpecifier (all)
;;;                                     { 18 List<DeclItem>
;;;                                       { 19 DeclItem
;;;                                         what = DECL_NAME
;;;                                         name = get_byte
;;;                                       } 19 DeclItem
;;;                                     } 18 List<DeclItem>
;;;                                   } 17 TypeName
;--	push 2 bytes
;--	call
	CALL	Cget_byte
;--	pop 0 bytes
;;;                                 } 16 Expr l(r)
;--	store_rr_var c = -7(FP), SP at -7
	MOVE	R, 0(SP)
;;;                               } 15 Expr l = r
;;;                             } 14 ExpressionStatement
;;;                             { 14 ExpressionStatement
;;;                               { 15 Expr l += r
;;;                                 { 16 TypeName
;;;                                   { 17 TypeSpecifier (all)
;;;                                     spec = unsigned char (22000)
;;;                                   } 17 TypeSpecifier (all)
;;;                                   { 17 List<DeclItem>
;;;                                     { 18 DeclItem
;;;                                       what = DECL_NAME
;;;                                       name = check_sum
;;;                                     } 18 DeclItem
;;;                                   } 17 List<DeclItem>
;;;                                 } 16 TypeName
;;;                                 { 16 Expr l + r
;;;                                   { 17 Expression (variable name)
;;;                                     expr_type = "identifier" (check_sum)
;--	load_rr_var check_sum = -5(FP), SP at -7 (8 bit)
	MOVE	2(SP), RU
;;;                                   } 17 Expression (variable name)
;--	move_rr_to_ll
	MOVE	RR, LL
;;;                                   { 17 Expression (variable name)
;;;                                     expr_type = "identifier" (c)
;--	load_rr_var c = -7(FP), SP at -7 (8 bit)
	MOVE	0(SP), RU
;;;                                   } 17 Expression (variable name)
;--	scale_rr *1
;--	l + r
	ADD	LL, RR
;;;                                 } 16 Expr l + r
;--	store_rr_var check_sum = -5(FP), SP at -7
	MOVE	R, 2(SP)
;;;                               } 15 Expr l += r
;;;                             } 14 ExpressionStatement
;;;                             { 14 ExpressionStatement
;;;                               { 15 Expr l | r
;;;                                 { 16 TypeName
;;;                                   { 17 TypeSpecifier (all)
;;;                                     spec = unsigned int (82000)
;;;                                   } 17 TypeSpecifier (all)
;;;                                   { 17 List<DeclItem>
;;;                                     { 18 DeclItem
;;;                                       what = DECL_NAME
;;;                                       name = address
;;;                                     } 18 DeclItem
;;;                                   } 17 List<DeclItem>
;;;                                 } 16 TypeName
;;;                                 { 16 Expr l | r
;;;                                   { 17 TypeName (internal)
;;;                                     { 18 TypeSpecifier (all)
;;;                                       spec = unsigned int (82000)
;;;                                     } 18 TypeSpecifier (all)
;;;                                   } 17 TypeName (internal)
;;;                                   { 17 Expression (variable name)
;;;                                     expr_type = "identifier" (address)
;--	load_rr_var address = -3(FP), SP at -7 (16 bit)
	MOVE	4(SP), RR
;;;                                   } 17 Expression (variable name)
;--	move_rr_to_ll
	MOVE	RR, LL
;;;                                   { 17 Expression (variable name)
;;;                                     expr_type = "identifier" (c)
;--	load_rr_var c = -7(FP), SP at -7 (8 bit)
	MOVE	0(SP), RU
;;;                                   } 17 Expression (variable name)
;--	l | r
	OR	LL, RR
;;;                                 } 16 Expr l | r
;--	store_rr_var address = -3(FP), SP at -7
	MOVE	RR, 4(SP)
;;;                               } 15 Expr l | r
;;;                             } 14 ExpressionStatement
;;;                             { 14 ExpressionStatement
;;;                               { 15 Expr l = r
;;;                                 { 16 TypeName
;;;                                   { 17 TypeSpecifier (all)
;;;                                     spec = unsigned char (22000)
;;;                                   } 17 TypeSpecifier (all)
;;;                                   { 17 List<DeclItem>
;;;                                     { 18 DeclItem
;;;                                       what = DECL_NAME
;;;                                       name = c
;;;                                     } 18 DeclItem
;;;                                   } 17 List<DeclItem>
;;;                                 } 16 TypeName
;;;                                 { 16 Expr l(r)
;;;                                   { 17 TypeName
;;;                                     { 18 TypeSpecifier (all)
;;;                                       spec = int (80000)
;;;                                     } 18 TypeSpecifier (all)
;;;                                     { 18 List<DeclItem>
;;;                                       { 19 DeclItem
;;;                                         what = DECL_NAME
;;;                                         name = get_byte
;;;                                       } 19 DeclItem
;;;                                     } 18 List<DeclItem>
;;;                                   } 17 TypeName
;--	push 2 bytes
;--	call
	CALL	Cget_byte
;--	pop 0 bytes
;;;                                 } 16 Expr l(r)
;--	store_rr_var c = -7(FP), SP at -7
	MOVE	R, 0(SP)
;;;                               } 15 Expr l = r
;;;                             } 14 ExpressionStatement
;;;                             { 14 ExpressionStatement
;;;                               { 15 Expr l += r
;;;                                 { 16 TypeName
;;;                                   { 17 TypeSpecifier (all)
;;;                                     spec = unsigned char (22000)
;;;                                   } 17 TypeSpecifier (all)
;;;                                   { 17 List<DeclItem>
;;;                                     { 18 DeclItem
;;;                                       what = DECL_NAME
;;;                                       name = check_sum
;;;                                     } 18 DeclItem
;;;                                   } 17 List<DeclItem>
;;;                                 } 16 TypeName
;;;                                 { 16 Expr l + r
;;;                                   { 17 Expression (variable name)
;;;                                     expr_type = "identifier" (check_sum)
;--	load_rr_var check_sum = -5(FP), SP at -7 (8 bit)
	MOVE	2(SP), RU
;;;                                   } 17 Expression (variable name)
;--	move_rr_to_ll
	MOVE	RR, LL
;;;                                   { 17 Expression (variable name)
;;;                                     expr_type = "identifier" (c)
;--	load_rr_var c = -7(FP), SP at -7 (8 bit)
	MOVE	0(SP), RU
;;;                                   } 17 Expression (variable name)
;--	scale_rr *1
;--	l + r
	ADD	LL, RR
;;;                                 } 16 Expr l + r
;--	store_rr_var check_sum = -5(FP), SP at -7
	MOVE	R, 2(SP)
;;;                               } 15 Expr l += r
;;;                             } 14 ExpressionStatement
;;;                             { 14 ExpressionStatement
;;;                               { 15 Expr l = r
;;;                                 { 16 TypeName
;;;                                   { 17 TypeSpecifier (all)
;;;                                     spec = unsigned char (22000)
;;;                                   } 17 TypeSpecifier (all)
;;;                                   { 17 List<DeclItem>
;;;                                     { 18 DeclItem
;;;                                       what = DECL_NAME
;;;                                       name = record_type
;;;                                     } 18 DeclItem
;;;                                   } 17 List<DeclItem>
;;;                                 } 16 TypeName
;;;                                 { 16 Expression (variable name)
;;;                                   expr_type = "identifier" (c)
;--	load_rr_var c = -7(FP), SP at -7 (8 bit)
	MOVE	0(SP), RU
;;;                                 } 16 Expression (variable name)
;--	store_rr_var record_type = -4(FP), SP at -7
	MOVE	R, 3(SP)
;;;                               } 15 Expr l = r
;;;                             } 14 ExpressionStatement
;;;                             { 14 for Statement
;;;                               { 15 ExpressionStatement
;;;                                 { 16 Expr l = r
;;;                                   { 17 TypeName
;;;                                     { 18 TypeSpecifier (all)
;;;                                       spec = unsigned char (22000)
;;;                                     } 18 TypeSpecifier (all)
;;;                                     { 18 List<DeclItem>
;;;                                       { 19 DeclItem
;;;                                         what = DECL_NAME
;;;                                         name = i
;;;                                       } 19 DeclItem
;;;                                     } 18 List<DeclItem>
;;;                                   } 17 TypeName
;;;                                   { 17 NumericExpression (constant 0 = 0x0)
;--	load_rr_constant
	MOVE	#0x0000, RR
;;;                                   } 17 NumericExpression (constant 0 = 0x0)
;--	store_rr_var i = -6(FP), SP at -7
	MOVE	R, 1(SP)
;;;                                 } 16 Expr l = r
;;;                               } 15 ExpressionStatement
;--	branch
	JMP	L7_tst_21
L7_loop_21:
;;;                               { 15 CompoundStatement
;;;                                 { 16 List<ExpressionStatement>
;;;                                   { 17 ExpressionStatement
;;;                                     { 18 Expr l = r
;;;                                       { 19 TypeName
;;;                                         { 20 TypeSpecifier (all)
;;;                                           spec = unsigned char (22000)
;;;                                         } 20 TypeSpecifier (all)
;;;                                         { 20 List<DeclItem>
;;;                                           { 21 DeclItem
;;;                                             what = DECL_NAME
;;;                                             name = c
;;;                                           } 21 DeclItem
;;;                                         } 20 List<DeclItem>
;;;                                       } 19 TypeName
;;;                                       { 19 Expr l(r)
;;;                                         { 20 TypeName
;;;                                           { 21 TypeSpecifier (all)
;;;                                             spec = int (80000)
;;;                                           } 21 TypeSpecifier (all)
;;;                                           { 21 List<DeclItem>
;;;                                             { 22 DeclItem
;;;                                               what = DECL_NAME
;;;                                               name = get_byte
;;;                                             } 22 DeclItem
;;;                                           } 21 List<DeclItem>
;;;                                         } 20 TypeName
;--	push 2 bytes
;--	call
	CALL	Cget_byte
;--	pop 0 bytes
;;;                                       } 19 Expr l(r)
;--	store_rr_var c = -7(FP), SP at -7
	MOVE	R, 0(SP)
;;;                                     } 18 Expr l = r
;;;                                   } 17 ExpressionStatement
;;;                                   { 17 ExpressionStatement
;;;                                     { 18 Expr l = r
;;;                                       { 19 TypeName
;;;                                         { 20 TypeSpecifier (all)
;;;                                           spec = char (20000)
;;;                                         } 20 TypeSpecifier (all)
;;;                                       } 19 TypeName
;;;                                       { 19 Expression (variable name)
;;;                                         expr_type = "identifier" (c)
;--	load_rr_var c = -7(FP), SP at -7 (8 bit)
	MOVE	0(SP), RU
;;;                                       } 19 Expression (variable name)
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;;;                                       { 19 Expr l[r]
;;;                                         { 20 Expression (variable name)
;;;                                           expr_type = "identifier" (i)
;--	load_rr_var i = -6(FP), SP at -8 (8 bit)
	MOVE	2(SP), RU
;;;                                         } 20 Expression (variable name)
;--	scale_rr *1
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                         { 20 Expression (cast)r
;;;                                           { 21 Expression (variable name)
;;;                                             expr_type = "identifier" (address)
;--	load_rr_var address = -3(FP), SP at -10 (16 bit)
	MOVE	7(SP), RR
;;;                                           } 21 Expression (variable name)
;;;                                         } 20 Expression (cast)r
;--	pop_ll (16 bit)
	MOVE	(SP)+, LL
;--	+ (element)
	ADD	LL, RR
;;;                                       } 19 Expr l[r]
;--	move_rr_to_ll
	MOVE	RR, LL
;--	pop_rr (8 bit)
	MOVE	(SP)+, RS
;--	assign (8 bit)
	MOVE	R, (LL)
;;;                                     } 18 Expr l = r
;;;                                   } 17 ExpressionStatement
;;;                                   { 17 ExpressionStatement
;;;                                     { 18 Expr l += r
;;;                                       { 19 TypeName
;;;                                         { 20 TypeSpecifier (all)
;;;                                           spec = unsigned char (22000)
;;;                                         } 20 TypeSpecifier (all)
;;;                                         { 20 List<DeclItem>
;;;                                           { 21 DeclItem
;;;                                             what = DECL_NAME
;;;                                             name = check_sum
;;;                                           } 21 DeclItem
;;;                                         } 20 List<DeclItem>
;;;                                       } 19 TypeName
;;;                                       { 19 Expr l + r
;;;                                         { 20 Expression (variable name)
;;;                                           expr_type = "identifier" (check_sum)
;--	load_rr_var check_sum = -5(FP), SP at -7 (8 bit)
	MOVE	2(SP), RU
;;;                                         } 20 Expression (variable name)
;--	move_rr_to_ll
	MOVE	RR, LL
;;;                                         { 20 Expression (variable name)
;;;                                           expr_type = "identifier" (c)
;--	load_rr_var c = -7(FP), SP at -7 (8 bit)
	MOVE	0(SP), RU
;;;                                         } 20 Expression (variable name)
;--	scale_rr *1
;--	l + r
	ADD	LL, RR
;;;                                       } 19 Expr l + r
;--	store_rr_var check_sum = -5(FP), SP at -7
	MOVE	R, 2(SP)
;;;                                     } 18 Expr l += r
;;;                                   } 17 ExpressionStatement
;;;                                 } 16 List<ExpressionStatement>
;--	pop 0 bytes
;;;                               } 15 CompoundStatement
L7_cont_21:
;;;                               { 15 Expr l - r
;;;                                 { 16 Expr ++r
;;;                                   { 17 Expression (variable name)
;;;                                     expr_type = "identifier" (i)
;--	load_rr_var i = -6(FP), SP at -7 (8 bit)
	MOVE	1(SP), RU
;;;                                   } 17 Expression (variable name)
;--	++
	ADD	RR, #0x0001
;--	store_rr_var i = -6(FP), SP at -7
	MOVE	R, 1(SP)
;;;                                 } 16 Expr ++r
;--	l - r
	SUB	RR, #0x0001
;;;                               } 15 Expr l - r
L7_tst_21:
;;;                               { 15 Expr l < r
;;;                                 { 16 TypeName (internal)
;;;                                   { 17 TypeSpecifier (all)
;;;                                     spec = unsigned int (82000)
;;;                                   } 17 TypeSpecifier (all)
;;;                                 } 16 TypeName (internal)
;;;                                 { 16 Expression (variable name)
;;;                                   expr_type = "identifier" (i)
;--	load_rr_var i = -6(FP), SP at -7 (8 bit)
	MOVE	1(SP), RU
;;;                                 } 16 Expression (variable name)
;--	move_rr_to_ll
	MOVE	RR, LL
;;;                                 { 16 Expression (variable name)
;;;                                   expr_type = "identifier" (record_length)
;--	load_rr_var record_length = -1(FP), SP at -7 (8 bit)
	MOVE	6(SP), RU
;;;                                 } 16 Expression (variable name)
;--	l < r
	SLO	LL, RR
;;;                               } 15 Expr l < r
;--	branch_true
	JMP	RRNZ, L7_loop_21
L7_brk_22:
;;;                             } 14 for Statement
;;;                             { 14 ExpressionStatement
;;;                               { 15 Expr l = r
;;;                                 { 16 TypeName
;;;                                   { 17 TypeSpecifier (all)
;;;                                     spec = unsigned char (22000)
;;;                                   } 17 TypeSpecifier (all)
;;;                                   { 17 List<DeclItem>
;;;                                     { 18 DeclItem
;;;                                       what = DECL_NAME
;;;                                       name = c
;;;                                     } 18 DeclItem
;;;                                   } 17 List<DeclItem>
;;;                                 } 16 TypeName
;;;                                 { 16 Expr l(r)
;;;                                   { 17 TypeName
;;;                                     { 18 TypeSpecifier (all)
;;;                                       spec = int (80000)
;;;                                     } 18 TypeSpecifier (all)
;;;                                     { 18 List<DeclItem>
;;;                                       { 19 DeclItem
;;;                                         what = DECL_NAME
;;;                                         name = get_byte
;;;                                       } 19 DeclItem
;;;                                     } 18 List<DeclItem>
;;;                                   } 17 TypeName
;--	push 2 bytes
;--	call
	CALL	Cget_byte
;--	pop 0 bytes
;;;                                 } 16 Expr l(r)
;--	store_rr_var c = -7(FP), SP at -7
	MOVE	R, 0(SP)
;;;                               } 15 Expr l = r
;;;                             } 14 ExpressionStatement
;;;                             { 14 ExpressionStatement
;;;                               { 15 Expr l += r
;;;                                 { 16 TypeName
;;;                                   { 17 TypeSpecifier (all)
;;;                                     spec = unsigned char (22000)
;;;                                   } 17 TypeSpecifier (all)
;;;                                   { 17 List<DeclItem>
;;;                                     { 18 DeclItem
;;;                                       what = DECL_NAME
;;;                                       name = check_sum
;;;                                     } 18 DeclItem
;;;                                   } 17 List<DeclItem>
;;;                                 } 16 TypeName
;;;                                 { 16 Expr l + r
;;;                                   { 17 Expression (variable name)
;;;                                     expr_type = "identifier" (check_sum)
;--	load_rr_var check_sum = -5(FP), SP at -7 (8 bit)
	MOVE	2(SP), RU
;;;                                   } 17 Expression (variable name)
;--	move_rr_to_ll
	MOVE	RR, LL
;;;                                   { 17 Expression (variable name)
;;;                                     expr_type = "identifier" (c)
;--	load_rr_var c = -7(FP), SP at -7 (8 bit)
	MOVE	0(SP), RU
;;;                                   } 17 Expression (variable name)
;--	scale_rr *1
;--	l + r
	ADD	LL, RR
;;;                                 } 16 Expr l + r
;--	store_rr_var check_sum = -5(FP), SP at -7
	MOVE	R, 2(SP)
;;;                               } 15 Expr l += r
;;;                             } 14 ExpressionStatement
;;;                             { 14 IfElseStatement
;;;                               { 15 Expression (variable name)
;;;                                 expr_type = "identifier" (check_sum)
;--	load_rr_var check_sum = -5(FP), SP at -7 (8 bit)
	MOVE	2(SP), RU
;;;                               } 15 Expression (variable name)
;--	branch_false
	JMP	RRZ, L7_endif_23
;;;                               { 15 break/continue Statement
;--	branch
	JMP	L7_brk_18
;;;                               } 15 break/continue Statement
L7_endif_23:
;;;                             } 14 IfElseStatement
;;;                             { 14 ExpressionStatement
;;;                               { 15 Expr l(r)
;;;                                 { 16 TypeName
;;;                                   { 17 TypeSpecifier (all)
;;;                                     spec = void (10000)
;;;                                   } 17 TypeSpecifier (all)
;;;                                   { 17 List<DeclItem>
;;;                                     { 18 DeclItem
;;;                                       what = DECL_NAME
;;;                                       name = putchr
;;;                                     } 18 DeclItem
;;;                                   } 17 List<DeclItem>
;;;                                 } 16 TypeName
;;;                                 { 16 ParameterDeclaration
;;;                                   isEllipsis = false
;;;                                   { 17 TypeName
;;;                                     { 18 TypeSpecifier (all)
;;;                                       spec = char (20000)
;;;                                     } 18 TypeSpecifier (all)
;;;                                     { 18 List<DeclItem>
;;;                                       { 19 DeclItem
;;;                                         what = DECL_NAME
;;;                                         name = c
;;;                                       } 19 DeclItem
;;;                                     } 18 List<DeclItem>
;;;                                   } 17 TypeName
;;;                                 } 16 ParameterDeclaration
;;;                                 { 16 NumericExpression (constant 46 = 0x2E)
;--	load_rr_constant
	MOVE	#0x002E, RR
;;;                                 } 16 NumericExpression (constant 46 = 0x2E)
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;--	push 0 bytes
;--	call
	CALL	Cputchr
;--	pop 1 bytes
	ADD	SP, #1
;;;                               } 15 Expr l(r)
;;;                             } 14 ExpressionStatement
;;;                             { 14 IfElseStatement
;;;                               { 15 Expr l == r
;;;                                 { 16 TypeName (internal)
;;;                                   { 17 TypeSpecifier (all)
;;;                                     spec = unsigned int (82000)
;;;                                   } 17 TypeSpecifier (all)
;;;                                 } 16 TypeName (internal)
;;;                                 { 16 Expression (variable name)
;;;                                   expr_type = "identifier" (record_type)
;--	load_rr_var record_type = -4(FP), SP at -7 (8 bit)
	MOVE	3(SP), RU
;;;                                 } 16 Expression (variable name)
;--	l == r
	SEQ	RR, #0x0001
;;;                               } 15 Expr l == r
;--	branch_false
	JMP	RRZ, L7_endif_24
;;;                               { 15 CompoundStatement
;;;                                 { 16 List<ExpressionStatement>
;;;                                   { 17 ExpressionStatement
;;;                                     { 18 Expr l(r)
;;;                                       { 19 TypeName
;;;                                         { 20 TypeSpecifier (all)
;;;                                           spec = void (10000)
;;;                                         } 20 TypeSpecifier (all)
;;;                                         { 20 List<DeclItem>
;;;                                           { 21 DeclItem
;;;                                             what = DECL_NAME
;;;                                             name = print_string
;;;                                           } 21 DeclItem
;;;                                         } 20 List<DeclItem>
;;;                                       } 19 TypeName
;;;                                       { 19 ParameterDeclaration
;;;                                         isEllipsis = false
;;;                                         { 20 TypeName
;;;                                           { 21 TypeSpecifier (all)
;;;                                             spec = const char (20100)
;;;                                           } 21 TypeSpecifier (all)
;;;                                           { 21 List<DeclItem>
;;;                                             { 22 DeclItem
;;;                                               what = DECL_POINTER
;;;                                               { 23 List<Ptr>
;;;                                                 { 24 Ptr
;;;                                                 } 24 Ptr
;;;                                               } 23 List<Ptr>
;;;                                             } 22 DeclItem
;;;                                             { 22 DeclItem
;;;                                               what = DECL_NAME
;;;                                               name = buffer
;;;                                             } 22 DeclItem
;;;                                           } 21 List<DeclItem>
;;;                                         } 20 TypeName
;;;                                       } 19 ParameterDeclaration
;;;                                       { 19 StringExpression
;--	load_rr_string
	MOVE	#Cstr_8, RR
;;;                                       } 19 StringExpression
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;--	push 0 bytes
;--	call
	CALL	Cprint_string
;--	pop 2 bytes
	ADD	SP, #2
;;;                                     } 18 Expr l(r)
;;;                                   } 17 ExpressionStatement
;;;                                   { 17 ExpressionStatement
;;;                                     { 18 Expr l(r)
;;;                                       { 19 TypeName
;;;                                         { 20 TypeSpecifier (all)
;;;                                           spec = void (10000)
;;;                                         } 20 TypeSpecifier (all)
;;;                                       } 19 TypeName
;--	push 2 bytes
;;;                                       { 19 Expression (cast)r
;;;                                         { 20 Expression (variable name)
;;;                                           expr_type = "identifier" (address)
;--	load_rr_var address = -3(FP), SP at -7 (16 bit)
	MOVE	4(SP), RR
;;;                                         } 20 Expression (variable name)
;;;                                       } 19 Expression (cast)r
;--	call_ptr
	CALL	(RR)
;--	pop 0 bytes
;;;                                     } 18 Expr l(r)
;;;                                   } 17 ExpressionStatement
;;;                                 } 16 List<ExpressionStatement>
;--	pop 0 bytes
;;;                               } 15 CompoundStatement
L7_endif_24:
;;;                             } 14 IfElseStatement
;;;                           } 13 List<while Statement>
;--	pop 0 bytes
;;;                         } 12 CompoundStatement
L7_cont_17:
;--	branch
	JMP	L7_loop_17
L7_brk_18:
;;;                       } 11 for Statement
;;;                       { 11 ExpressionStatement
;;;                         { 12 Expr l(r)
;;;                           { 13 TypeName
;;;                             { 14 TypeSpecifier (all)
;;;                               spec = void (10000)
;;;                             } 14 TypeSpecifier (all)
;;;                             { 14 List<DeclItem>
;;;                               { 15 DeclItem
;;;                                 what = DECL_NAME
;;;                                 name = print_string
;;;                               } 15 DeclItem
;;;                             } 14 List<DeclItem>
;;;                           } 13 TypeName
;;;                           { 13 ParameterDeclaration
;;;                             isEllipsis = false
;;;                             { 14 TypeName
;;;                               { 15 TypeSpecifier (all)
;;;                                 spec = const char (20100)
;;;                               } 15 TypeSpecifier (all)
;;;                               { 15 List<DeclItem>
;;;                                 { 16 DeclItem
;;;                                   what = DECL_POINTER
;;;                                   { 17 List<Ptr>
;;;                                     { 18 Ptr
;;;                                     } 18 Ptr
;;;                                   } 17 List<Ptr>
;;;                                 } 16 DeclItem
;;;                                 { 16 DeclItem
;;;                                   what = DECL_NAME
;;;                                   name = buffer
;;;                                 } 16 DeclItem
;;;                               } 15 List<DeclItem>
;;;                             } 14 TypeName
;;;                           } 13 ParameterDeclaration
;;;                           { 13 StringExpression
;--	load_rr_string
	MOVE	#Cstr_9, RR
;;;                           } 13 StringExpression
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;--	push 0 bytes
;--	call
	CALL	Cprint_string
;--	pop 2 bytes
	ADD	SP, #2
;;;                         } 12 Expr l(r)
;;;                       } 11 ExpressionStatement
;;;                     } 10 List<ExpressionStatement>
;--	pop 0 bytes
;;;                   } 9 CompoundStatement
L7_cont_15:
;--	branch
	JMP	L7_loop_15
L7_brk_16:
;;;                 } 8 for Statement
;;;               } 7 List<for Statement>
;--	pop 7 bytes
	ADD	SP, #7
;;;             } 6 CompoundStatement
;--	ret
	RET
;;; ------------------------------------;
Cstr_5:				;
	.BYTE	0x0D			;
	.BYTE	0x0A			;
	.BYTE	0x45			;
	.BYTE	0x52			;
	.BYTE	0x52			;
	.BYTE	0x4F			;
	.BYTE	0x52			;
	.BYTE	0x3A			;
	.BYTE	0x20			;
	.BYTE	0x6E			;
	.BYTE	0x6F			;
	.BYTE	0x74			;
	.BYTE	0x20			;
	.BYTE	0x68			;
	.BYTE	0x65			;
	.BYTE	0x78			;
	.BYTE	0x0D			;
	.BYTE	0x0A			;
	.BYTE	0			;
Cstr_7:				;
	.BYTE	0x0D			;
	.BYTE	0x0A			;
	.BYTE	0x4C			;
	.BYTE	0x4F			;
	.BYTE	0x41			;
	.BYTE	0x44			;
	.BYTE	0x20			;
	.BYTE	0x3E			;
	.BYTE	0x20			;
	.BYTE	0			;
Cstr_8:				;
	.BYTE	0x0D			;
	.BYTE	0x0A			;
	.BYTE	0x44			;
	.BYTE	0x4F			;
	.BYTE	0x4E			;
	.BYTE	0x45			;
	.BYTE	0x2E			;
	.BYTE	0x0D			;
	.BYTE	0x0A			;
	.BYTE	0			;
Cstr_9:				;
	.BYTE	0x0D			;
	.BYTE	0x0A			;
	.BYTE	0x43			;
	.BYTE	0x48			;
	.BYTE	0x45			;
	.BYTE	0x43			;
	.BYTE	0x4B			;
	.BYTE	0x53			;
	.BYTE	0x55			;
	.BYTE	0x4D			;
	.BYTE	0x20			;
	.BYTE	0x45			;
	.BYTE	0x52			;
	.BYTE	0x52			;
	.BYTE	0x4F			;
	.BYTE	0x52			;
	.BYTE	0x2E			;
	.BYTE	0			;
Cend_text:				;
