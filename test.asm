IN_RX_DATA		= 0x00		;
IN_STATUS		= 0x01		;
IN_TEMPERAT		= 0x02		;
IN_DIP_SWITCH		= 0x03		;
IN_CLK_CTR_LOW		= 0x05		;
IN_CLK_CTR_HIGH		= 0x06		;

MEMTOP	=0x2000

OUT_TX_DATA		= 0x00		;
OUT_LEDS		= 0x02		;
OUT_INT_MASK		= 0x03		;
OUT_RESET_TIMER		= 0x04		;
OUT_START_CLK_CTR	= 0x05		;
OUT_STOP_CLK_CTR	= 0x06		;
;---------------------------------------;
	MOVE	#MEMTOP, RR		;
	MOVE	RR, SP			;
	EI				;
	JMP	Cmain			;
	JMP	Cinterrupt		;
;---------------------------------------;
mult_div:				;
	MD_STP				; 1
	MD_STP				; 2
	MD_STP				; 3
	MD_STP				; 4
	MD_STP				; 5
	MD_STP				; 6
	MD_STP				; 7
	MD_STP				; 8
	MD_STP				; 9
	MD_STP				; 10
	MD_STP				; 11
	MD_STP				; 12
	MD_STP				; 13
	MD_STP				; 14
	MD_STP				; 15
	MD_STP				; 16
	RET				;
;---------------------------------------;
;;; { 0 Declaration
;;;   { 1 TypeSpecifier (all)
;;;     spec = unsigned char (22000)
;;;   } 1 TypeSpecifier (all)
Cserial_in_buffer:			; 
	.BYTE	0			; VOID [0]
	.BYTE	0			; VOID [1]
	.BYTE	0			; VOID [2]
	.BYTE	0			; VOID [3]
	.BYTE	0			; VOID [4]
	.BYTE	0			; VOID [5]
	.BYTE	0			; VOID [6]
	.BYTE	0			; VOID [7]
	.BYTE	0			; VOID [8]
	.BYTE	0			; VOID [9]
	.BYTE	0			; VOID [10]
	.BYTE	0			; VOID [11]
	.BYTE	0			; VOID [12]
	.BYTE	0			; VOID [13]
	.BYTE	0			; VOID [14]
	.BYTE	0			; VOID [15]
;;; } 0 Declaration
;;; ------------------------------------;
;;; { 0 Declaration
;;;   { 1 TypeSpecifier (all)
;;;     spec = unsigned char (22000)
;;;   } 1 TypeSpecifier (all)
Cserial_in_get:			; 
	.BYTE	0
;;; } 0 Declaration
;;; ------------------------------------;
;;; { 0 Declaration
;;;   { 1 TypeSpecifier (all)
;;;     spec = unsigned char (22000)
;;;   } 1 TypeSpecifier (all)
Cserial_in_put:			; 
	.BYTE	0
;;; } 0 Declaration
;;; ------------------------------------;
;;; { 0 Declaration
;;;   { 1 TypeSpecifier (all)
;;;     spec = unsigned char (22000)
;;;   } 1 TypeSpecifier (all)
Cserial_in_length:			; 
	.BYTE	0
;;; } 0 Declaration
;;; ------------------------------------;
;;; { 0 Declaration
;;;   { 1 TypeSpecifier (all)
;;;     spec = unsigned char (22000)
;;;   } 1 TypeSpecifier (all)
Cserial_in_overflow:			; 
	.BYTE	0
;;; } 0 Declaration
;;; ------------------------------------;
;;; { 0 FunctionDefinition
;;;   { 1 TypeName
;;;     { 2 TypeSpecifier (all)
;;;       spec = void (10000)
;;;     } 2 TypeSpecifier (all)
;;;     { 2 List<DeclItem>
;;;       { 3 DeclItem
;;;         what = DECL_NAME
;;;         name = rx_interrupt
;;;       } 3 DeclItem
;;;     } 2 List<DeclItem>
;;;   } 1 TypeName
;;;   { 1 List<DeclItem>
;;;     { 2 DeclItem
;;;       what = DECL_NAME
;;;       name = rx_interrupt
;;;     } 2 DeclItem
;;;     { 2 DeclItem
;;;       what = DECL_FUN
;;;     } 2 DeclItem
;;;   } 1 List<DeclItem>
Crx_interrupt:
;;;   { 1 CompoundStatement
;;;     { 2 InitDeclarator
;;;       { 3 List<DeclItem>
;;;         { 4 DeclItem
;;;           what = DECL_NAME
;;;           name = c
;;;         } 4 DeclItem
;;;       } 3 List<DeclItem>
;;;       { 3 Initializer (skalar)
	IN   (IN_RX_DATA), RU
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;;;       } 3 Initializer (skalar)
;;;     } 2 InitDeclarator
;;;     { 2 List<IfElseStatement>
;;;       { 3 IfElseStatement
;;;         { 4 Expr l < r
;;;           { 5 TypeName (internal)
;;;             { 6 TypeSpecifier (all)
;;;               spec = unsigned int (82000)
;;;             } 6 TypeSpecifier (all)
;;;           } 5 TypeName (internal)
;;;           { 5 Expression (variable name)
;;;             expr_type = "identifier" (serial_in_length)
;--	load_rr_var serial_in_length, (8 bit)
	MOVE	(Cserial_in_length), RU
;;;           } 5 Expression (variable name)
;--	l < r
	SLO	RR, #0x0010
;;;         } 4 Expr l < r
;--	branch_false
	JMP	RRZ, L2_else_1
;;;         { 4 CompoundStatement
;;;           { 5 List<ExpressionStatement>
;;;             { 6 ExpressionStatement
;;;               { 7 Expr l = r
;;;                 { 8 TypeName
;;;                   { 9 TypeSpecifier (all)
;;;                     spec = unsigned char (22000)
;;;                   } 9 TypeSpecifier (all)
;;;                   { 9 List<DeclItem>
;;;                     { 10 DeclItem
;;;                       what = DECL_NAME
;;;                       name = serial_in_buffer
;;;                     } 10 DeclItem
;;;                   } 9 List<DeclItem>
;;;                 } 8 TypeName
;;;                 { 8 Expression (variable name)
;;;                   expr_type = "identifier" (c)
;--	load_rr_var c = -1(FP), SP at -1 (8 bit)
	MOVE	0(SP), RS
;;;                 } 8 Expression (variable name)
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;;;                 { 8 Expr l[r]
;;;                   { 9 Expression (variable name)
;;;                     expr_type = "identifier" (serial_in_put)
;--	load_rr_var serial_in_put, (8 bit)
	MOVE	(Cserial_in_put), RU
;;;                   } 9 Expression (variable name)
;--	scale_rr *1
;--	add_address serial_in_buffer
	ADD	RR, #Cserial_in_buffer
;;;                 } 8 Expr l[r]
;--	move_rr_to_ll
	MOVE	RR, LL
;--	pop_rr (8 bit)
	MOVE	(SP)+, RU
;--	assign (8 bit)
	MOVE	R, (LL)
;;;               } 7 Expr l = r
;;;             } 6 ExpressionStatement
;;;             { 6 ExpressionStatement
;;;               { 7 Expr l = r
;;;                 { 8 TypeName
;;;                   { 9 TypeSpecifier (all)
;;;                     spec = unsigned char (22000)
;;;                   } 9 TypeSpecifier (all)
;;;                   { 9 List<DeclItem>
;;;                     { 10 DeclItem
;;;                       what = DECL_NAME
;;;                       name = serial_in_put
;;;                     } 10 DeclItem
;;;                   } 9 List<DeclItem>
;;;                 } 8 TypeName
;;;                 { 8 Expr l & r
;;;                   { 9 TypeName (internal)
;;;                     { 10 TypeSpecifier (all)
;;;                       spec = unsigned int (82000)
;;;                     } 10 TypeSpecifier (all)
;;;                   } 9 TypeName (internal)
;;;                   { 9 Expr ++r
;;;                     { 10 Expression (variable name)
;;;                       expr_type = "identifier" (serial_in_put)
;--	load_rr_var serial_in_put, (8 bit)
	MOVE	(Cserial_in_put), RU
;;;                     } 10 Expression (variable name)
;--	++
	ADD	RR, #0x0001
;--	store_rr_var serial_in_put
	MOVE	R, (Cserial_in_put)
;;;                   } 9 Expr ++r
;--	l & r
	AND	RR, #0x000F
;;;                 } 8 Expr l & r
;--	store_rr_var serial_in_put
	MOVE	R, (Cserial_in_put)
;;;               } 7 Expr l = r
;;;             } 6 ExpressionStatement
;;;             { 6 ExpressionStatement
;;;               { 7 Expr ++r
;;;                 { 8 Expression (variable name)
;;;                   expr_type = "identifier" (serial_in_length)
;--	load_rr_var serial_in_length, (8 bit)
	MOVE	(Cserial_in_length), RU
;;;                 } 8 Expression (variable name)
;--	++
	ADD	RR, #0x0001
;--	store_rr_var serial_in_length
	MOVE	R, (Cserial_in_length)
;;;               } 7 Expr ++r
;;;             } 6 ExpressionStatement
;;;           } 5 List<ExpressionStatement>
;--	pop 0 bytes
;;;         } 4 CompoundStatement
;--	branch
	JMP	L2_endif_1
L2_else_1:
;;;         { 4 CompoundStatement
;;;           { 5 List<ExpressionStatement>
;;;             { 6 ExpressionStatement
;;;               { 7 Expr l = r
;;;                 { 8 TypeName
;;;                   { 9 TypeSpecifier (all)
;;;                     spec = unsigned char (22000)
;;;                   } 9 TypeSpecifier (all)
;;;                   { 9 List<DeclItem>
;;;                     { 10 DeclItem
;;;                       what = DECL_NAME
;;;                       name = serial_in_overflow
;;;                     } 10 DeclItem
;;;                   } 9 List<DeclItem>
;;;                 } 8 TypeName
;;;                 { 8 NumericExpression (constant 255 = 0xFF)
;--	load_rr_constant
	MOVE	#0x00FF, RR
;;;                 } 8 NumericExpression (constant 255 = 0xFF)
;--	store_rr_var serial_in_overflow
	MOVE	R, (Cserial_in_overflow)
;;;               } 7 Expr l = r
;;;             } 6 ExpressionStatement
;;;           } 5 List<ExpressionStatement>
;--	pop 0 bytes
;;;         } 4 CompoundStatement
L2_endif_1:
;;;       } 3 IfElseStatement
;;;     } 2 List<IfElseStatement>
;--	pop 1 bytes
	ADD	SP, #1
;;;   } 1 CompoundStatement
;--	ret
	RET
;;; ------------------------------------;
;;;   { 1 Declaration
;;;     { 2 TypeSpecifier (all)
;;;       spec = unsigned char (22000)
;;;     } 2 TypeSpecifier (all)
Cserial_out_buffer:			; 
	.BYTE	0			; VOID [0]
	.BYTE	0			; VOID [1]
	.BYTE	0			; VOID [2]
	.BYTE	0			; VOID [3]
	.BYTE	0			; VOID [4]
	.BYTE	0			; VOID [5]
	.BYTE	0			; VOID [6]
	.BYTE	0			; VOID [7]
	.BYTE	0			; VOID [8]
	.BYTE	0			; VOID [9]
	.BYTE	0			; VOID [10]
	.BYTE	0			; VOID [11]
	.BYTE	0			; VOID [12]
	.BYTE	0			; VOID [13]
	.BYTE	0			; VOID [14]
	.BYTE	0			; VOID [15]
;;;   } 1 Declaration
;;; ------------------------------------;
;;;   { 1 Declaration
;;;     { 2 TypeSpecifier (all)
;;;       spec = unsigned char (22000)
;;;     } 2 TypeSpecifier (all)
Cserial_out_get:			; 
	.BYTE	0
;;;   } 1 Declaration
;;; ------------------------------------;
;;;   { 1 Declaration
;;;     { 2 TypeSpecifier (all)
;;;       spec = unsigned char (22000)
;;;     } 2 TypeSpecifier (all)
Cserial_out_put:			; 
	.BYTE	0
;;;   } 1 Declaration
;;; ------------------------------------;
;;;   { 1 Declaration
;;;     { 2 TypeSpecifier (all)
;;;       spec = unsigned char (22000)
;;;     } 2 TypeSpecifier (all)
Cserial_out_length:			; 
	.BYTE	0
;;;   } 1 Declaration
;;; ------------------------------------;
;;;   { 1 FunctionDefinition
;;;     { 2 TypeName
;;;       { 3 TypeSpecifier (all)
;;;         spec = void (10000)
;;;       } 3 TypeSpecifier (all)
;;;       { 3 List<DeclItem>
;;;         { 4 DeclItem
;;;           what = DECL_NAME
;;;           name = tx_interrupt
;;;         } 4 DeclItem
;;;       } 3 List<DeclItem>
;;;     } 2 TypeName
;;;     { 2 List<DeclItem>
;;;       { 3 DeclItem
;;;         what = DECL_NAME
;;;         name = tx_interrupt
;;;       } 3 DeclItem
;;;       { 3 DeclItem
;;;         what = DECL_FUN
;;;       } 3 DeclItem
;;;     } 2 List<DeclItem>
Ctx_interrupt:
;;;     { 2 CompoundStatement
;;;       { 3 List<IfElseStatement>
;;;         { 4 IfElseStatement
;;;           { 5 Expression (variable name)
;;;             expr_type = "identifier" (serial_out_length)
;--	load_rr_var serial_out_length, (8 bit)
	MOVE	(Cserial_out_length), RU
;;;           } 5 Expression (variable name)
;--	branch_false
	JMP	RRZ, L3_else_2
;;;           { 5 CompoundStatement
;;;             { 6 List<ExpressionStatement>
;;;               { 7 ExpressionStatement
;;;                 { 8 Expr l[r]
;;;                   { 9 TypeName
;;;                     { 10 TypeSpecifier (all)
;;;                       spec = unsigned char (22000)
;;;                     } 10 TypeSpecifier (all)
;;;                     { 10 List<DeclItem>
;;;                       { 11 DeclItem
;;;                         what = DECL_NAME
;;;                         name = serial_out_buffer
;;;                       } 11 DeclItem
;;;                     } 10 List<DeclItem>
;;;                   } 9 TypeName
;;;                   { 9 Expr l[r]
;;;                     { 10 Expression (variable name)
;;;                       expr_type = "identifier" (serial_out_get)
;--	load_rr_var serial_out_get, (8 bit)
	MOVE	(Cserial_out_get), RU
;;;                     } 10 Expression (variable name)
;--	scale_rr *1
;--	add_address serial_out_buffer
	ADD	RR, #Cserial_out_buffer
;;;                   } 9 Expr l[r]
;--	content
	MOVE	(RR), RU
;;;                 } 8 Expr l[r]
;;;               } 7 ExpressionStatement
;;;               { 7 ExpressionStatement
	OUT  R, (OUT_TX_DATA)
;;;               } 7 ExpressionStatement
;;;               { 7 ExpressionStatement
;;;                 { 8 Expr l = r
;;;                   { 9 TypeName
;;;                     { 10 TypeSpecifier (all)
;;;                       spec = unsigned char (22000)
;;;                     } 10 TypeSpecifier (all)
;;;                     { 10 List<DeclItem>
;;;                       { 11 DeclItem
;;;                         what = DECL_NAME
;;;                         name = serial_out_get
;;;                       } 11 DeclItem
;;;                     } 10 List<DeclItem>
;;;                   } 9 TypeName
;;;                   { 9 Expr l & r
;;;                     { 10 TypeName (internal)
;;;                       { 11 TypeSpecifier (all)
;;;                         spec = unsigned int (82000)
;;;                       } 11 TypeSpecifier (all)
;;;                     } 10 TypeName (internal)
;;;                     { 10 Expr ++r
;;;                       { 11 Expression (variable name)
;;;                         expr_type = "identifier" (serial_out_get)
;--	load_rr_var serial_out_get, (8 bit)
	MOVE	(Cserial_out_get), RU
;;;                       } 11 Expression (variable name)
;--	++
	ADD	RR, #0x0001
;--	store_rr_var serial_out_get
	MOVE	R, (Cserial_out_get)
;;;                     } 10 Expr ++r
;--	l & r
	AND	RR, #0x000F
;;;                   } 9 Expr l & r
;--	store_rr_var serial_out_get
	MOVE	R, (Cserial_out_get)
;;;                 } 8 Expr l = r
;;;               } 7 ExpressionStatement
;;;               { 7 ExpressionStatement
;;;                 { 8 Expr --r
;;;                   { 9 Expression (variable name)
;;;                     expr_type = "identifier" (serial_out_length)
;--	load_rr_var serial_out_length, (8 bit)
	MOVE	(Cserial_out_length), RU
;;;                   } 9 Expression (variable name)
;--	--
	SUB	RR, #0x0001
;--	store_rr_var serial_out_length
	MOVE	R, (Cserial_out_length)
;;;                 } 8 Expr --r
;;;               } 7 ExpressionStatement
;;;             } 6 List<ExpressionStatement>
;--	pop 0 bytes
;;;           } 5 CompoundStatement
;--	branch
	JMP	L3_endif_2
L3_else_2:
;;;           { 5 CompoundStatement
;;;             { 6 List<ExpressionStatement>
;;;               { 7 ExpressionStatement
	MOVE #0x05, RR
;;;               } 7 ExpressionStatement
;;;               { 7 ExpressionStatement
	OUT  R, (OUT_INT_MASK)
;;;               } 7 ExpressionStatement
;;;             } 6 List<ExpressionStatement>
;--	pop 0 bytes
;;;           } 5 CompoundStatement
L3_endif_2:
;;;         } 4 IfElseStatement
;;;       } 3 List<IfElseStatement>
;--	pop 0 bytes
;;;     } 2 CompoundStatement
;--	ret
	RET
;;; ------------------------------------;
;;;     { 2 Declaration
;;;       { 3 TypeSpecifier (all)
;;;         spec = unsigned int (82000)
;;;       } 3 TypeSpecifier (all)
Cmilliseconds:			; 
	.WORD	0
;;;     } 2 Declaration
;;; ------------------------------------;
;;;     { 2 Declaration
;;;       { 3 TypeSpecifier (all)
;;;         spec = unsigned int (82000)
;;;       } 3 TypeSpecifier (all)
Cseconds_low:			; 
	.WORD	0
;;;     } 2 Declaration
;;; ------------------------------------;
;;;     { 2 Declaration
;;;       { 3 TypeSpecifier (all)
;;;         spec = unsigned int (82000)
;;;       } 3 TypeSpecifier (all)
Cseconds_mid:			; 
	.WORD	0
;;;     } 2 Declaration
;;; ------------------------------------;
;;;     { 2 Declaration
;;;       { 3 TypeSpecifier (all)
;;;         spec = unsigned int (82000)
;;;       } 3 TypeSpecifier (all)
Cseconds_high:			; 
	.WORD	0
;;;     } 2 Declaration
;;; ------------------------------------;
;;;     { 2 Declaration
;;;       { 3 TypeSpecifier (all)
;;;         spec = unsigned char (22000)
;;;       } 3 TypeSpecifier (all)
Cseconds_changed:			; 
	.BYTE	0
;;;     } 2 Declaration
;;; ------------------------------------;
;;;     { 2 FunctionDefinition
;;;       { 3 TypeName
;;;         { 4 TypeSpecifier (all)
;;;           spec = void (10000)
;;;         } 4 TypeSpecifier (all)
;;;         { 4 List<DeclItem>
;;;           { 5 DeclItem
;;;             what = DECL_NAME
;;;             name = timer_interrupt
;;;           } 5 DeclItem
;;;         } 4 List<DeclItem>
;;;       } 3 TypeName
;;;       { 3 List<DeclItem>
;;;         { 4 DeclItem
;;;           what = DECL_NAME
;;;           name = timer_interrupt
;;;         } 4 DeclItem
;;;         { 4 DeclItem
;;;           what = DECL_FUN
;;;         } 4 DeclItem
;;;       } 3 List<DeclItem>
Ctimer_interrupt:
;;;       { 3 CompoundStatement
;;;         { 4 List<ExpressionStatement>
;;;           { 5 ExpressionStatement
	OUT  R, (OUT_RESET_TIMER)
;;;           } 5 ExpressionStatement
;;;           { 5 IfElseStatement
;;;             { 6 Expr l == r
;;;               { 7 TypeName (internal)
;;;                 { 8 TypeSpecifier (all)
;;;                   spec = unsigned int (82000)
;;;                 } 8 TypeSpecifier (all)
;;;               } 7 TypeName (internal)
;;;               { 7 Expr ++r
;;;                 { 8 Expression (variable name)
;;;                   expr_type = "identifier" (milliseconds)
;--	load_rr_var milliseconds, (16 bit)
	MOVE	(Cmilliseconds), RR
;;;                 } 8 Expression (variable name)
;--	++
	ADD	RR, #0x0001
;--	store_rr_var milliseconds
	MOVE	RR, (Cmilliseconds)
;;;               } 7 Expr ++r
;--	l == r
	SEQ	RR, #0x03E8
;;;             } 6 Expr l == r
;--	branch_false
	JMP	RRZ, L4_endif_3
;;;             { 6 CompoundStatement
;;;               { 7 List<ExpressionStatement>
;;;                 { 8 ExpressionStatement
;;;                   { 9 Expr l = r
;;;                     { 10 TypeName
;;;                       { 11 TypeSpecifier (all)
;;;                         spec = unsigned int (82000)
;;;                       } 11 TypeSpecifier (all)
;;;                       { 11 List<DeclItem>
;;;                         { 12 DeclItem
;;;                           what = DECL_NAME
;;;                           name = milliseconds
;;;                         } 12 DeclItem
;;;                       } 11 List<DeclItem>
;;;                     } 10 TypeName
;;;                     { 10 NumericExpression (constant 0 = 0x0)
;--	load_rr_constant
	MOVE	#0x0000, RR
;;;                     } 10 NumericExpression (constant 0 = 0x0)
;--	store_rr_var milliseconds
	MOVE	RR, (Cmilliseconds)
;;;                   } 9 Expr l = r
;;;                 } 8 ExpressionStatement
;;;                 { 8 ExpressionStatement
;;;                   { 9 Expr l = r
;;;                     { 10 TypeName
;;;                       { 11 TypeSpecifier (all)
;;;                         spec = unsigned char (22000)
;;;                       } 11 TypeSpecifier (all)
;;;                       { 11 List<DeclItem>
;;;                         { 12 DeclItem
;;;                           what = DECL_NAME
;;;                           name = seconds_changed
;;;                         } 12 DeclItem
;;;                       } 11 List<DeclItem>
;;;                     } 10 TypeName
;;;                     { 10 NumericExpression (constant 255 = 0xFF)
;--	load_rr_constant
	MOVE	#0x00FF, RR
;;;                     } 10 NumericExpression (constant 255 = 0xFF)
;--	store_rr_var seconds_changed
	MOVE	R, (Cseconds_changed)
;;;                   } 9 Expr l = r
;;;                 } 8 ExpressionStatement
;;;                 { 8 IfElseStatement
;;;                   { 9 Expr l == r
;;;                     { 10 TypeName (internal)
;;;                       { 11 TypeSpecifier (all)
;;;                         spec = unsigned int (82000)
;;;                       } 11 TypeSpecifier (all)
;;;                     } 10 TypeName (internal)
;;;                     { 10 Expr ++r
;;;                       { 11 Expression (variable name)
;;;                         expr_type = "identifier" (seconds_low)
;--	load_rr_var seconds_low, (16 bit)
	MOVE	(Cseconds_low), RR
;;;                       } 11 Expression (variable name)
;--	++
	ADD	RR, #0x0001
;--	store_rr_var seconds_low
	MOVE	RR, (Cseconds_low)
;;;                     } 10 Expr ++r
;--	l == r
	SEQ	RR, #0x0000
;;;                   } 9 Expr l == r
;--	branch_false
	JMP	RRZ, L4_endif_4
;;;                   { 9 CompoundStatement
;;;                     { 10 List<IfElseStatement>
;;;                       { 11 IfElseStatement
;;;                         { 12 Expr l == r
;;;                           { 13 TypeName (internal)
;;;                             { 14 TypeSpecifier (all)
;;;                               spec = unsigned int (82000)
;;;                             } 14 TypeSpecifier (all)
;;;                           } 13 TypeName (internal)
;;;                           { 13 Expr ++r
;;;                             { 14 Expression (variable name)
;;;                               expr_type = "identifier" (seconds_mid)
;--	load_rr_var seconds_mid, (16 bit)
	MOVE	(Cseconds_mid), RR
;;;                             } 14 Expression (variable name)
;--	++
	ADD	RR, #0x0001
;--	store_rr_var seconds_mid
	MOVE	RR, (Cseconds_mid)
;;;                           } 13 Expr ++r
;--	l == r
	SEQ	RR, #0x0000
;;;                         } 12 Expr l == r
;--	branch_false
	JMP	RRZ, L4_endif_5
;;;                         { 12 ExpressionStatement
;;;                           { 13 Expr ++r
;;;                             { 14 Expression (variable name)
;;;                               expr_type = "identifier" (seconds_high)
;--	load_rr_var seconds_high, (16 bit)
	MOVE	(Cseconds_high), RR
;;;                             } 14 Expression (variable name)
;--	++
	ADD	RR, #0x0001
;--	store_rr_var seconds_high
	MOVE	RR, (Cseconds_high)
;;;                           } 13 Expr ++r
;;;                         } 12 ExpressionStatement
L4_endif_5:
;;;                       } 11 IfElseStatement
;;;                     } 10 List<IfElseStatement>
;--	pop 0 bytes
;;;                   } 9 CompoundStatement
L4_endif_4:
;;;                 } 8 IfElseStatement
;;;               } 7 List<ExpressionStatement>
;--	pop 0 bytes
;;;             } 6 CompoundStatement
L4_endif_3:
;;;           } 5 IfElseStatement
;;;         } 4 List<ExpressionStatement>
;--	pop 0 bytes
;;;       } 3 CompoundStatement
;--	ret
	RET
;;; ------------------------------------;
;;;       { 3 FunctionDefinition
;;;         { 4 TypeName
;;;           { 5 TypeSpecifier (all)
;;;             spec = void (10000)
;;;           } 5 TypeSpecifier (all)
;;;           { 5 List<DeclItem>
;;;             { 6 DeclItem
;;;               what = DECL_NAME
;;;               name = interrupt
;;;             } 6 DeclItem
;;;           } 5 List<DeclItem>
;;;         } 4 TypeName
;;;         { 4 List<DeclItem>
;;;           { 5 DeclItem
;;;             what = DECL_NAME
;;;             name = interrupt
;;;           } 5 DeclItem
;;;           { 5 DeclItem
;;;             what = DECL_FUN
;;;           } 5 DeclItem
;;;         } 4 List<DeclItem>
Cinterrupt:
;;;         { 4 CompoundStatement
;;;           { 5 List<ExpressionStatement>
;;;             { 6 ExpressionStatement
	MOVE RR, -(SP)
;;;             } 6 ExpressionStatement
;;;             { 6 ExpressionStatement
	MOVE LL, RR
;;;             } 6 ExpressionStatement
;;;             { 6 ExpressionStatement
	MOVE RR, -(SP)
;;;             } 6 ExpressionStatement
;;;             { 6 IfElseStatement
;;;               { 7 Expr l & r
;;;                 { 8 TypeName (internal)
;;;                   { 9 TypeSpecifier (all)
;;;                     spec = int (80000)
;;;                   } 9 TypeSpecifier (all)
;;;                 } 8 TypeName (internal)
	IN   (IN_STATUS), RU
;--	l & r
	AND	RR, #0x0010
;;;               } 7 Expr l & r
;--	branch_false
	JMP	RRZ, L5_endif_6
;;;               { 7 ExpressionStatement
;;;                 { 8 Expr l(r)
;;;                   { 9 TypeName
;;;                     { 10 TypeSpecifier (all)
;;;                       spec = void (10000)
;;;                     } 10 TypeSpecifier (all)
;;;                     { 10 List<DeclItem>
;;;                       { 11 DeclItem
;;;                         what = DECL_NAME
;;;                         name = rx_interrupt
;;;                       } 11 DeclItem
;;;                     } 10 List<DeclItem>
;;;                   } 9 TypeName
;--	push 0 bytes
;--	call
	CALL	Crx_interrupt
;--	pop 0 bytes
;;;                 } 8 Expr l(r)
;;;               } 7 ExpressionStatement
L5_endif_6:
;;;             } 6 IfElseStatement
;;;             { 6 IfElseStatement
;;;               { 7 Expr l & r
;;;                 { 8 TypeName (internal)
;;;                   { 9 TypeSpecifier (all)
;;;                     spec = int (80000)
;;;                   } 9 TypeSpecifier (all)
;;;                 } 8 TypeName (internal)
	IN   (IN_STATUS), RU
;--	l & r
	AND	RR, #0x0020
;;;               } 7 Expr l & r
;--	branch_false
	JMP	RRZ, L5_endif_7
;;;               { 7 ExpressionStatement
;;;                 { 8 Expr l(r)
;;;                   { 9 TypeName
;;;                     { 10 TypeSpecifier (all)
;;;                       spec = void (10000)
;;;                     } 10 TypeSpecifier (all)
;;;                     { 10 List<DeclItem>
;;;                       { 11 DeclItem
;;;                         what = DECL_NAME
;;;                         name = tx_interrupt
;;;                       } 11 DeclItem
;;;                     } 10 List<DeclItem>
;;;                   } 9 TypeName
;--	push 0 bytes
;--	call
	CALL	Ctx_interrupt
;--	pop 0 bytes
;;;                 } 8 Expr l(r)
;;;               } 7 ExpressionStatement
L5_endif_7:
;;;             } 6 IfElseStatement
;;;             { 6 IfElseStatement
;;;               { 7 Expr l & r
;;;                 { 8 TypeName (internal)
;;;                   { 9 TypeSpecifier (all)
;;;                     spec = int (80000)
;;;                   } 9 TypeSpecifier (all)
;;;                 } 8 TypeName (internal)
	IN   (IN_STATUS), RU
;--	l & r
	AND	RR, #0x0040
;;;               } 7 Expr l & r
;--	branch_false
	JMP	RRZ, L5_endif_8
;;;               { 7 ExpressionStatement
;;;                 { 8 Expr l(r)
;;;                   { 9 TypeName
;;;                     { 10 TypeSpecifier (all)
;;;                       spec = void (10000)
;;;                     } 10 TypeSpecifier (all)
;;;                     { 10 List<DeclItem>
;;;                       { 11 DeclItem
;;;                         what = DECL_NAME
;;;                         name = timer_interrupt
;;;                       } 11 DeclItem
;;;                     } 10 List<DeclItem>
;;;                   } 9 TypeName
;--	push 0 bytes
;--	call
	CALL	Ctimer_interrupt
;--	pop 0 bytes
;;;                 } 8 Expr l(r)
;;;               } 7 ExpressionStatement
L5_endif_8:
;;;             } 6 IfElseStatement
;;;             { 6 ExpressionStatement
	MOVE (SP)+, RR
;;;             } 6 ExpressionStatement
;;;             { 6 ExpressionStatement
	MOVE RR, LL
;;;             } 6 ExpressionStatement
;;;             { 6 ExpressionStatement
	MOVE (SP)+, RR
;;;             } 6 ExpressionStatement
;;;             { 6 ExpressionStatement
	RETI
;;;             } 6 ExpressionStatement
;;;           } 5 List<ExpressionStatement>
;--	pop 0 bytes
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
;;;                 name = strlen
;;;               } 7 DeclItem
;;;             } 6 List<DeclItem>
;;;           } 5 TypeName
;;;           { 5 List<DeclItem>
;;;             { 6 DeclItem
;;;               what = DECL_NAME
;;;               name = strlen
;;;             } 6 DeclItem
;;;             { 6 DeclItem
;;;               what = DECL_FUN
;;;               { 7 List<ParameterDeclaration>
;;;                 { 8 ParameterDeclaration
;;;                   isEllipsis = false
;;;                   { 9 TypeName
;;;                     { 10 TypeSpecifier (all)
;;;                       spec = const char (20100)
;;;                     } 10 TypeSpecifier (all)
;;;                     { 10 List<DeclItem>
;;;                       { 11 DeclItem
;;;                         what = DECL_POINTER
;;;                         { 12 List<Ptr>
;;;                           { 13 Ptr
;;;                           } 13 Ptr
;;;                         } 12 List<Ptr>
;;;                       } 11 DeclItem
;;;                       { 11 DeclItem
;;;                         what = DECL_NAME
;;;                         name = buffer
;;;                       } 11 DeclItem
;;;                     } 10 List<DeclItem>
;;;                   } 9 TypeName
;;;                 } 8 ParameterDeclaration
;;;               } 7 List<ParameterDeclaration>
;;;             } 6 DeclItem
;;;           } 5 List<DeclItem>
Cstrlen:
;;;           { 5 CompoundStatement
;;;             { 6 InitDeclarator
;;;               { 7 List<DeclItem>
;;;                 { 8 DeclItem
;;;                   what = DECL_POINTER
;;;                   { 9 List<Ptr>
;;;                     { 10 Ptr
;;;                     } 10 Ptr
;;;                   } 9 List<Ptr>
;;;                 } 8 DeclItem
;;;                 { 8 DeclItem
;;;                   what = DECL_NAME
;;;                   name = from
;;;                 } 8 DeclItem
;;;               } 7 List<DeclItem>
;;;               { 7 Initializer (skalar)
;;;                 { 8 Expression (variable name)
;;;                   expr_type = "identifier" (buffer)
;--	load_rr_var buffer = 2(FP), SP at 0 (16 bit)
	MOVE	2(SP), RR
;;;                 } 8 Expression (variable name)
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;               } 7 Initializer (skalar)
;;;             } 6 InitDeclarator
;;;             { 6 List<while Statement>
;;;               { 7 while Statement
;--	branch
	JMP	L6_cont_9
L6_loop_9:
;;;                 { 8 ExpressionStatement
;;;                   { 9 Expr l - r
;;;                     { 10 Expr ++r
;;;                       { 11 Expression (variable name)
;;;                         expr_type = "identifier" (buffer)
;--	load_rr_var buffer = 2(FP), SP at -2 (16 bit)
	MOVE	4(SP), RR
;;;                       } 11 Expression (variable name)
;--	++
	ADD	RR, #0x0001
;--	store_rr_var buffer = 2(FP), SP at -2
	MOVE	RR, 4(SP)
;;;                     } 10 Expr ++r
;--	l - r
	SUB	RR, #0x0001
;;;                   } 9 Expr l - r
;;;                 } 8 ExpressionStatement
L6_cont_9:
;;;                 { 8 Expr * r
;;;                   { 9 Expression (variable name)
;;;                     expr_type = "identifier" (buffer)
;--	load_rr_var buffer = 2(FP), SP at -2 (16 bit)
	MOVE	4(SP), RR
;;;                   } 9 Expression (variable name)
;--	content
	MOVE	(RR), RS
;;;                 } 8 Expr * r
;--	branch_true
	JMP	RRNZ, L6_loop_9
L6_brk_10:
;;;               } 7 while Statement
;;;               { 7 return Statement
;;;                 { 8 Expr l - r
;;;                   { 9 Expression (variable name)
;;;                     expr_type = "identifier" (buffer)
;--	load_rr_var buffer = 2(FP), SP at -2 (16 bit)
	MOVE	4(SP), RR
;;;                   } 9 Expression (variable name)
;--	move_rr_to_ll
	MOVE	RR, LL
;;;                   { 9 Expression (variable name)
;;;                     expr_type = "identifier" (from)
;--	load_rr_var from = -2(FP), SP at -2 (16 bit)
	MOVE	0(SP), RR
;;;                   } 9 Expression (variable name)
;--	scale_rr *1
;--	l - r
	SUB	LL, RR
;--	scale *1
;;;                 } 8 Expr l - r
;--	ret
	ADD	SP, #2
	RET
;;;               } 7 return Statement
;;;             } 6 List<while Statement>
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
;;;                   name = putchr
;;;                 } 8 DeclItem
;;;               } 7 List<DeclItem>
;;;             } 6 TypeName
;;;             { 6 List<DeclItem>
;;;               { 7 DeclItem
;;;                 what = DECL_NAME
;;;                 name = putchr
;;;               } 7 DeclItem
;;;               { 7 DeclItem
;;;                 what = DECL_FUN
;;;                 { 8 List<ParameterDeclaration>
;;;                   { 9 ParameterDeclaration
;;;                     isEllipsis = false
;;;                     { 10 TypeName
;;;                       { 11 TypeSpecifier (all)
;;;                         spec = char (20000)
;;;                       } 11 TypeSpecifier (all)
;;;                       { 11 List<DeclItem>
;;;                         { 12 DeclItem
;;;                           what = DECL_NAME
;;;                           name = c
;;;                         } 12 DeclItem
;;;                       } 11 List<DeclItem>
;;;                     } 10 TypeName
;;;                   } 9 ParameterDeclaration
;;;                 } 8 List<ParameterDeclaration>
;;;               } 7 DeclItem
;;;             } 6 List<DeclItem>
Cputchr:
;;;             { 6 CompoundStatement
;;;               { 7 List<while Statement>
;;;                 { 8 while Statement
L7_loop_11:
;;;                   { 9 ExpressionStatement
;;;                   } 9 ExpressionStatement
L7_cont_11:
;;;                   { 9 Expr l == r
;;;                     { 10 TypeName (internal)
;;;                       { 11 TypeSpecifier (all)
;;;                         spec = unsigned int (82000)
;;;                       } 11 TypeSpecifier (all)
;;;                     } 10 TypeName (internal)
;;;                     { 10 Expression (variable name)
;;;                       expr_type = "identifier" (serial_out_length)
;--	load_rr_var serial_out_length, (8 bit)
	MOVE	(Cserial_out_length), RU
;;;                     } 10 Expression (variable name)
;--	l == r
	SEQ	RR, #0x0010
;;;                   } 9 Expr l == r
;--	branch_true
	JMP	RRNZ, L7_loop_11
L7_brk_12:
;;;                 } 8 while Statement
;;;                 { 8 ExpressionStatement
;;;                   { 9 Expr l = r
;;;                     { 10 TypeName
;;;                       { 11 TypeSpecifier (all)
;;;                         spec = unsigned char (22000)
;;;                       } 11 TypeSpecifier (all)
;;;                       { 11 List<DeclItem>
;;;                         { 12 DeclItem
;;;                           what = DECL_NAME
;;;                           name = serial_out_buffer
;;;                         } 12 DeclItem
;;;                       } 11 List<DeclItem>
;;;                     } 10 TypeName
;;;                     { 10 Expression (variable name)
;;;                       expr_type = "identifier" (c)
;--	load_rr_var c = 2(FP), SP at 0 (8 bit)
	MOVE	2(SP), RS
;;;                     } 10 Expression (variable name)
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;;;                     { 10 Expr l[r]
;;;                       { 11 Expression (variable name)
;;;                         expr_type = "identifier" (serial_out_put)
;--	load_rr_var serial_out_put, (8 bit)
	MOVE	(Cserial_out_put), RU
;;;                       } 11 Expression (variable name)
;--	scale_rr *1
;--	add_address serial_out_buffer
	ADD	RR, #Cserial_out_buffer
;;;                     } 10 Expr l[r]
;--	move_rr_to_ll
	MOVE	RR, LL
;--	pop_rr (8 bit)
	MOVE	(SP)+, RU
;--	assign (8 bit)
	MOVE	R, (LL)
;;;                   } 9 Expr l = r
;;;                 } 8 ExpressionStatement
;;;                 { 8 ExpressionStatement
;;;                   { 9 Expr l = r
;;;                     { 10 TypeName
;;;                       { 11 TypeSpecifier (all)
;;;                         spec = unsigned char (22000)
;;;                       } 11 TypeSpecifier (all)
;;;                       { 11 List<DeclItem>
;;;                         { 12 DeclItem
;;;                           what = DECL_NAME
;;;                           name = serial_out_put
;;;                         } 12 DeclItem
;;;                       } 11 List<DeclItem>
;;;                     } 10 TypeName
;;;                     { 10 Expr l & r
;;;                       { 11 TypeName (internal)
;;;                         { 12 TypeSpecifier (all)
;;;                           spec = unsigned int (82000)
;;;                         } 12 TypeSpecifier (all)
;;;                       } 11 TypeName (internal)
;;;                       { 11 Expr ++r
;;;                         { 12 Expression (variable name)
;;;                           expr_type = "identifier" (serial_out_put)
;--	load_rr_var serial_out_put, (8 bit)
	MOVE	(Cserial_out_put), RU
;;;                         } 12 Expression (variable name)
;--	++
	ADD	RR, #0x0001
;--	store_rr_var serial_out_put
	MOVE	R, (Cserial_out_put)
;;;                       } 11 Expr ++r
;--	l & r
	AND	RR, #0x000F
;;;                     } 10 Expr l & r
;--	store_rr_var serial_out_put
	MOVE	R, (Cserial_out_put)
;;;                   } 9 Expr l = r
;;;                 } 8 ExpressionStatement
;;;                 { 8 ExpressionStatement
	DI
;;;                 } 8 ExpressionStatement
;;;                 { 8 ExpressionStatement
;;;                   { 9 Expr ++r
;;;                     { 10 Expression (variable name)
;;;                       expr_type = "identifier" (serial_out_length)
;--	load_rr_var serial_out_length, (8 bit)
	MOVE	(Cserial_out_length), RU
;;;                     } 10 Expression (variable name)
;--	++
	ADD	RR, #0x0001
;--	store_rr_var serial_out_length
	MOVE	R, (Cserial_out_length)
;;;                   } 9 Expr ++r
;;;                 } 8 ExpressionStatement
;;;                 { 8 ExpressionStatement
	EI
;;;                 } 8 ExpressionStatement
;;;                 { 8 ExpressionStatement
	MOVE #0x07, RR
;;;                 } 8 ExpressionStatement
;;;                 { 8 ExpressionStatement
	OUT  R, (OUT_INT_MASK)
;;;                 } 8 ExpressionStatement
;;;                 { 8 ExpressionStatement
;;;                   { 9 NumericExpression (constant 1 = 0x1)
;--	load_rr_constant
	MOVE	#0x0001, RR
;;;                   } 9 NumericExpression (constant 1 = 0x1)
;;;                 } 8 ExpressionStatement
;;;               } 7 List<while Statement>
;--	pop 0 bytes
;;;             } 6 CompoundStatement
;--	ret
	RET
;;; ------------------------------------;
;;;             { 6 FunctionDefinition
;;;               { 7 TypeName
;;;                 { 8 TypeSpecifier (all)
;;;                   spec = void (10000)
;;;                 } 8 TypeSpecifier (all)
;;;                 { 8 List<DeclItem>
;;;                   { 9 DeclItem
;;;                     what = DECL_NAME
;;;                     name = print_string
;;;                   } 9 DeclItem
;;;                 } 8 List<DeclItem>
;;;               } 7 TypeName
;;;               { 7 List<DeclItem>
;;;                 { 8 DeclItem
;;;                   what = DECL_NAME
;;;                   name = print_string
;;;                 } 8 DeclItem
;;;                 { 8 DeclItem
;;;                   what = DECL_FUN
;;;                   { 9 List<ParameterDeclaration>
;;;                     { 10 ParameterDeclaration
;;;                       isEllipsis = false
;;;                       { 11 TypeName
;;;                         { 12 TypeSpecifier (all)
;;;                           spec = const char (20100)
;;;                         } 12 TypeSpecifier (all)
;;;                         { 12 List<DeclItem>
;;;                           { 13 DeclItem
;;;                             what = DECL_POINTER
;;;                             { 14 List<Ptr>
;;;                               { 15 Ptr
;;;                               } 15 Ptr
;;;                             } 14 List<Ptr>
;;;                           } 13 DeclItem
;;;                           { 13 DeclItem
;;;                             what = DECL_NAME
;;;                             name = buffer
;;;                           } 13 DeclItem
;;;                         } 12 List<DeclItem>
;;;                       } 11 TypeName
;;;                     } 10 ParameterDeclaration
;;;                   } 9 List<ParameterDeclaration>
;;;                 } 8 DeclItem
;;;               } 7 List<DeclItem>
Cprint_string:
;;;               { 7 CompoundStatement
;;;                 { 8 List<while Statement>
;;;                   { 9 while Statement
;--	branch
	JMP	L8_cont_13
L8_loop_13:
;;;                     { 10 ExpressionStatement
;;;                       { 11 Expr l(r)
;;;                         { 12 TypeName
;;;                           { 13 TypeSpecifier (all)
;;;                             spec = int (80000)
;;;                           } 13 TypeSpecifier (all)
;;;                           { 13 List<DeclItem>
;;;                             { 14 DeclItem
;;;                               what = DECL_NAME
;;;                               name = putchr
;;;                             } 14 DeclItem
;;;                           } 13 List<DeclItem>
;;;                         } 12 TypeName
;;;                         { 12 ParameterDeclaration
;;;                           isEllipsis = false
;;;                           { 13 TypeName
;;;                             { 14 TypeSpecifier (all)
;;;                               spec = char (20000)
;;;                             } 14 TypeSpecifier (all)
;;;                             { 14 List<DeclItem>
;;;                               { 15 DeclItem
;;;                                 what = DECL_NAME
;;;                                 name = c
;;;                               } 15 DeclItem
;;;                             } 14 List<DeclItem>
;;;                           } 13 TypeName
;;;                         } 12 ParameterDeclaration
;;;                         { 12 Expr * r
;;;                           { 13 Expr l - r
;;;                             { 14 Expr ++r
;;;                               { 15 Expression (variable name)
;;;                                 expr_type = "identifier" (buffer)
;--	load_rr_var buffer = 2(FP), SP at 0 (16 bit)
	MOVE	2(SP), RR
;;;                               } 15 Expression (variable name)
;--	++
	ADD	RR, #0x0001
;--	store_rr_var buffer = 2(FP), SP at 0
	MOVE	RR, 2(SP)
;;;                             } 14 Expr ++r
;--	l - r
	SUB	RR, #0x0001
;;;                           } 13 Expr l - r
;--	content
	MOVE	(RR), RS
;;;                         } 12 Expr * r
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;--	push 2 bytes
;--	call
	CALL	Cputchr
;--	pop 1 bytes
	ADD	SP, #1
;;;                       } 11 Expr l(r)
;;;                     } 10 ExpressionStatement
L8_cont_13:
;;;                     { 10 Expr * r
;;;                       { 11 Expression (variable name)
;;;                         expr_type = "identifier" (buffer)
;--	load_rr_var buffer = 2(FP), SP at 0 (16 bit)
	MOVE	2(SP), RR
;;;                       } 11 Expression (variable name)
;--	content
	MOVE	(RR), RS
;;;                     } 10 Expr * r
;--	branch_true
	JMP	RRNZ, L8_loop_13
L8_brk_14:
;;;                   } 9 while Statement
;;;                 } 8 List<while Statement>
;--	pop 0 bytes
;;;               } 7 CompoundStatement
;--	ret
	RET
;;; ------------------------------------;
;;;               { 7 FunctionDefinition
;;;                 { 8 TypeName
;;;                   { 9 TypeSpecifier (all)
;;;                     spec = void (10000)
;;;                   } 9 TypeSpecifier (all)
;;;                   { 9 List<DeclItem>
;;;                     { 10 DeclItem
;;;                       what = DECL_NAME
;;;                       name = print_hex
;;;                     } 10 DeclItem
;;;                   } 9 List<DeclItem>
;;;                 } 8 TypeName
;;;                 { 8 List<DeclItem>
;;;                   { 9 DeclItem
;;;                     what = DECL_NAME
;;;                     name = print_hex
;;;                   } 9 DeclItem
;;;                   { 9 DeclItem
;;;                     what = DECL_FUN
;;;                     { 10 List<ParameterDeclaration>
;;;                       { 11 ParameterDeclaration
;;;                         isEllipsis = false
;;;                         { 12 TypeName
;;;                           { 13 TypeSpecifier (all)
;;;                             spec = char (20000)
;;;                           } 13 TypeSpecifier (all)
;;;                           { 13 List<DeclItem>
;;;                             { 14 DeclItem
;;;                               what = DECL_POINTER
;;;                               { 15 List<Ptr>
;;;                                 { 16 Ptr
;;;                                 } 16 Ptr
;;;                               } 15 List<Ptr>
;;;                             } 14 DeclItem
;;;                             { 14 DeclItem
;;;                               what = DECL_NAME
;;;                               name = dest
;;;                             } 14 DeclItem
;;;                           } 13 List<DeclItem>
;;;                         } 12 TypeName
;;;                       } 11 ParameterDeclaration
;;;                       { 11 ParameterDeclaration
;;;                         isEllipsis = false
;;;                         { 12 TypeName
;;;                           { 13 TypeSpecifier (all)
;;;                             spec = unsigned int (82000)
;;;                           } 13 TypeSpecifier (all)
;;;                           { 13 List<DeclItem>
;;;                             { 14 DeclItem
;;;                               what = DECL_NAME
;;;                               name = value
;;;                             } 14 DeclItem
;;;                           } 13 List<DeclItem>
;;;                         } 12 TypeName
;;;                       } 11 ParameterDeclaration
;;;                       { 11 ParameterDeclaration
;;;                         isEllipsis = false
;;;                         { 12 TypeName
;;;                           { 13 TypeSpecifier (all)
;;;                             spec = const char (20100)
;;;                           } 13 TypeSpecifier (all)
;;;                           { 13 List<DeclItem>
;;;                             { 14 DeclItem
;;;                               what = DECL_POINTER
;;;                               { 15 List<Ptr>
;;;                                 { 16 Ptr
;;;                                 } 16 Ptr
;;;                               } 15 List<Ptr>
;;;                             } 14 DeclItem
;;;                             { 14 DeclItem
;;;                               what = DECL_NAME
;;;                               name = hex
;;;                             } 14 DeclItem
;;;                           } 13 List<DeclItem>
;;;                         } 12 TypeName
;;;                       } 11 ParameterDeclaration
;;;                     } 10 List<ParameterDeclaration>
;;;                   } 9 DeclItem
;;;                 } 8 List<DeclItem>
Cprint_hex:
;;;                 { 8 CompoundStatement
;;;                   { 9 List<IfElseStatement>
;;;                     { 10 IfElseStatement
;;;                       { 11 Expr l >= r
;;;                         { 12 TypeName (internal)
;;;                           { 13 TypeSpecifier (all)
;;;                             spec = unsigned int (82000)
;;;                           } 13 TypeSpecifier (all)
;;;                         } 12 TypeName (internal)
;;;                         { 12 Expression (variable name)
;;;                           expr_type = "identifier" (value)
;--	load_rr_var value = 4(FP), SP at 0 (16 bit)
	MOVE	4(SP), RR
;;;                         } 12 Expression (variable name)
;--	l >= r
	SHS	RR, #0x1000
;;;                       } 11 Expr l >= r
;--	branch_false
	JMP	RRZ, L9_endif_15
;;;                       { 11 ExpressionStatement
;;;                         { 12 Expr l = r
;;;                           { 13 TypeName
;;;                             { 14 TypeSpecifier (all)
;;;                               spec = char (20000)
;;;                             } 14 TypeSpecifier (all)
;;;                             { 14 List<DeclItem>
;;;                               { 15 DeclItem
;;;                                 what = DECL_NAME
;;;                                 name = dest
;;;                               } 15 DeclItem
;;;                             } 14 List<DeclItem>
;;;                           } 13 TypeName
;;;                           { 13 Expr l[r]
;;;                             { 14 TypeName
;;;                               { 15 TypeSpecifier (all)
;;;                                 spec = const char (20100)
;;;                               } 15 TypeSpecifier (all)
;;;                               { 15 List<DeclItem>
;;;                                 { 16 DeclItem
;;;                                   what = DECL_NAME
;;;                                   name = hex
;;;                                 } 16 DeclItem
;;;                               } 15 List<DeclItem>
;;;                             } 14 TypeName
;;;                             { 14 Expr l[r]
;;;                               { 15 Expr l & r
;;;                                 { 16 TypeName (internal)
;;;                                   { 17 TypeSpecifier (all)
;;;                                     spec = int (80000)
;;;                                   } 17 TypeSpecifier (all)
;;;                                 } 16 TypeName (internal)
;;;                                 { 16 Expr l >> r
;;;                                   { 17 TypeName (internal)
;;;                                     { 18 TypeSpecifier (all)
;;;                                       spec = int (80000)
;;;                                     } 18 TypeSpecifier (all)
;;;                                   } 17 TypeName (internal)
;;;                                   { 17 Expression (variable name)
;;;                                     expr_type = "identifier" (value)
;--	load_rr_var value = 4(FP), SP at 0 (16 bit)
	MOVE	4(SP), RR
;;;                                   } 17 Expression (variable name)
;--	l >> r
	ASR	RR, #0x000C
;;;                                 } 16 Expr l >> r
;--	l & r
	AND	RR, #0x000F
;;;                               } 15 Expr l & r
;--	scale_rr *1
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                               { 15 Expression (variable name)
;;;                                 expr_type = "identifier" (hex)
;--	load_rr_var hex = 6(FP), SP at -2 (16 bit)
	MOVE	8(SP), RR
;;;                               } 15 Expression (variable name)
;--	pop_ll (16 bit)
	MOVE	(SP)+, LL
;--	+ (element)
	ADD	LL, RR
;;;                             } 14 Expr l[r]
;--	content
	MOVE	(RR), RS
;;;                           } 13 Expr l[r]
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;;;                           { 13 Expr * r
;;;                             { 14 Expr l - r
;;;                               { 15 Expr ++r
;;;                                 { 16 Expression (variable name)
;;;                                   expr_type = "identifier" (dest)
;--	load_rr_var dest = 2(FP), SP at -1 (16 bit)
	MOVE	3(SP), RR
;;;                                 } 16 Expression (variable name)
;--	++
	ADD	RR, #0x0001
;--	store_rr_var dest = 2(FP), SP at -1
	MOVE	RR, 3(SP)
;;;                               } 15 Expr ++r
;--	l - r
	SUB	RR, #0x0001
;;;                             } 14 Expr l - r
;;;                           } 13 Expr * r
;--	move_rr_to_ll
	MOVE	RR, LL
;--	pop_rr (8 bit)
	MOVE	(SP)+, RS
;--	assign (8 bit)
	MOVE	R, (LL)
;;;                         } 12 Expr l = r
;;;                       } 11 ExpressionStatement
L9_endif_15:
;;;                     } 10 IfElseStatement
;;;                     { 10 IfElseStatement
;;;                       { 11 Expr l >= r
;;;                         { 12 TypeName (internal)
;;;                           { 13 TypeSpecifier (all)
;;;                             spec = unsigned int (82000)
;;;                           } 13 TypeSpecifier (all)
;;;                         } 12 TypeName (internal)
;;;                         { 12 Expression (variable name)
;;;                           expr_type = "identifier" (value)
;--	load_rr_var value = 4(FP), SP at 0 (16 bit)
	MOVE	4(SP), RR
;;;                         } 12 Expression (variable name)
;--	l >= r
	SHS	RR, #0x0100
;;;                       } 11 Expr l >= r
;--	branch_false
	JMP	RRZ, L9_endif_16
;;;                       { 11 ExpressionStatement
;;;                         { 12 Expr l = r
;;;                           { 13 TypeName
;;;                             { 14 TypeSpecifier (all)
;;;                               spec = char (20000)
;;;                             } 14 TypeSpecifier (all)
;;;                             { 14 List<DeclItem>
;;;                               { 15 DeclItem
;;;                                 what = DECL_NAME
;;;                                 name = dest
;;;                               } 15 DeclItem
;;;                             } 14 List<DeclItem>
;;;                           } 13 TypeName
;;;                           { 13 Expr l[r]
;;;                             { 14 TypeName
;;;                               { 15 TypeSpecifier (all)
;;;                                 spec = const char (20100)
;;;                               } 15 TypeSpecifier (all)
;;;                               { 15 List<DeclItem>
;;;                                 { 16 DeclItem
;;;                                   what = DECL_NAME
;;;                                   name = hex
;;;                                 } 16 DeclItem
;;;                               } 15 List<DeclItem>
;;;                             } 14 TypeName
;;;                             { 14 Expr l[r]
;;;                               { 15 Expr l & r
;;;                                 { 16 TypeName (internal)
;;;                                   { 17 TypeSpecifier (all)
;;;                                     spec = int (80000)
;;;                                   } 17 TypeSpecifier (all)
;;;                                 } 16 TypeName (internal)
;;;                                 { 16 Expr l >> r
;;;                                   { 17 TypeName (internal)
;;;                                     { 18 TypeSpecifier (all)
;;;                                       spec = int (80000)
;;;                                     } 18 TypeSpecifier (all)
;;;                                   } 17 TypeName (internal)
;;;                                   { 17 Expression (variable name)
;;;                                     expr_type = "identifier" (value)
;--	load_rr_var value = 4(FP), SP at 0 (16 bit)
	MOVE	4(SP), RR
;;;                                   } 17 Expression (variable name)
;--	l >> r
	ASR	RR, #0x0008
;;;                                 } 16 Expr l >> r
;--	l & r
	AND	RR, #0x000F
;;;                               } 15 Expr l & r
;--	scale_rr *1
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                               { 15 Expression (variable name)
;;;                                 expr_type = "identifier" (hex)
;--	load_rr_var hex = 6(FP), SP at -2 (16 bit)
	MOVE	8(SP), RR
;;;                               } 15 Expression (variable name)
;--	pop_ll (16 bit)
	MOVE	(SP)+, LL
;--	+ (element)
	ADD	LL, RR
;;;                             } 14 Expr l[r]
;--	content
	MOVE	(RR), RS
;;;                           } 13 Expr l[r]
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;;;                           { 13 Expr * r
;;;                             { 14 Expr l - r
;;;                               { 15 Expr ++r
;;;                                 { 16 Expression (variable name)
;;;                                   expr_type = "identifier" (dest)
;--	load_rr_var dest = 2(FP), SP at -1 (16 bit)
	MOVE	3(SP), RR
;;;                                 } 16 Expression (variable name)
;--	++
	ADD	RR, #0x0001
;--	store_rr_var dest = 2(FP), SP at -1
	MOVE	RR, 3(SP)
;;;                               } 15 Expr ++r
;--	l - r
	SUB	RR, #0x0001
;;;                             } 14 Expr l - r
;;;                           } 13 Expr * r
;--	move_rr_to_ll
	MOVE	RR, LL
;--	pop_rr (8 bit)
	MOVE	(SP)+, RS
;--	assign (8 bit)
	MOVE	R, (LL)
;;;                         } 12 Expr l = r
;;;                       } 11 ExpressionStatement
L9_endif_16:
;;;                     } 10 IfElseStatement
;;;                     { 10 IfElseStatement
;;;                       { 11 Expr l >= r
;;;                         { 12 TypeName (internal)
;;;                           { 13 TypeSpecifier (all)
;;;                             spec = unsigned int (82000)
;;;                           } 13 TypeSpecifier (all)
;;;                         } 12 TypeName (internal)
;;;                         { 12 Expression (variable name)
;;;                           expr_type = "identifier" (value)
;--	load_rr_var value = 4(FP), SP at 0 (16 bit)
	MOVE	4(SP), RR
;;;                         } 12 Expression (variable name)
;--	l >= r
	SHS	RR, #0x0010
;;;                       } 11 Expr l >= r
;--	branch_false
	JMP	RRZ, L9_endif_17
;;;                       { 11 ExpressionStatement
;;;                         { 12 Expr l = r
;;;                           { 13 TypeName
;;;                             { 14 TypeSpecifier (all)
;;;                               spec = char (20000)
;;;                             } 14 TypeSpecifier (all)
;;;                             { 14 List<DeclItem>
;;;                               { 15 DeclItem
;;;                                 what = DECL_NAME
;;;                                 name = dest
;;;                               } 15 DeclItem
;;;                             } 14 List<DeclItem>
;;;                           } 13 TypeName
;;;                           { 13 Expr l[r]
;;;                             { 14 TypeName
;;;                               { 15 TypeSpecifier (all)
;;;                                 spec = const char (20100)
;;;                               } 15 TypeSpecifier (all)
;;;                               { 15 List<DeclItem>
;;;                                 { 16 DeclItem
;;;                                   what = DECL_NAME
;;;                                   name = hex
;;;                                 } 16 DeclItem
;;;                               } 15 List<DeclItem>
;;;                             } 14 TypeName
;;;                             { 14 Expr l[r]
;;;                               { 15 Expr l & r
;;;                                 { 16 TypeName (internal)
;;;                                   { 17 TypeSpecifier (all)
;;;                                     spec = int (80000)
;;;                                   } 17 TypeSpecifier (all)
;;;                                 } 16 TypeName (internal)
;;;                                 { 16 Expr l >> r
;;;                                   { 17 TypeName (internal)
;;;                                     { 18 TypeSpecifier (all)
;;;                                       spec = int (80000)
;;;                                     } 18 TypeSpecifier (all)
;;;                                   } 17 TypeName (internal)
;;;                                   { 17 Expression (variable name)
;;;                                     expr_type = "identifier" (value)
;--	load_rr_var value = 4(FP), SP at 0 (16 bit)
	MOVE	4(SP), RR
;;;                                   } 17 Expression (variable name)
;--	l >> r
	ASR	RR, #0x0004
;;;                                 } 16 Expr l >> r
;--	l & r
	AND	RR, #0x000F
;;;                               } 15 Expr l & r
;--	scale_rr *1
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                               { 15 Expression (variable name)
;;;                                 expr_type = "identifier" (hex)
;--	load_rr_var hex = 6(FP), SP at -2 (16 bit)
	MOVE	8(SP), RR
;;;                               } 15 Expression (variable name)
;--	pop_ll (16 bit)
	MOVE	(SP)+, LL
;--	+ (element)
	ADD	LL, RR
;;;                             } 14 Expr l[r]
;--	content
	MOVE	(RR), RS
;;;                           } 13 Expr l[r]
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;;;                           { 13 Expr * r
;;;                             { 14 Expr l - r
;;;                               { 15 Expr ++r
;;;                                 { 16 Expression (variable name)
;;;                                   expr_type = "identifier" (dest)
;--	load_rr_var dest = 2(FP), SP at -1 (16 bit)
	MOVE	3(SP), RR
;;;                                 } 16 Expression (variable name)
;--	++
	ADD	RR, #0x0001
;--	store_rr_var dest = 2(FP), SP at -1
	MOVE	RR, 3(SP)
;;;                               } 15 Expr ++r
;--	l - r
	SUB	RR, #0x0001
;;;                             } 14 Expr l - r
;;;                           } 13 Expr * r
;--	move_rr_to_ll
	MOVE	RR, LL
;--	pop_rr (8 bit)
	MOVE	(SP)+, RS
;--	assign (8 bit)
	MOVE	R, (LL)
;;;                         } 12 Expr l = r
;;;                       } 11 ExpressionStatement
L9_endif_17:
;;;                     } 10 IfElseStatement
;;;                     { 10 ExpressionStatement
;;;                       { 11 Expr l = r
;;;                         { 12 TypeName
;;;                           { 13 TypeSpecifier (all)
;;;                             spec = char (20000)
;;;                           } 13 TypeSpecifier (all)
;;;                           { 13 List<DeclItem>
;;;                             { 14 DeclItem
;;;                               what = DECL_NAME
;;;                               name = dest
;;;                             } 14 DeclItem
;;;                           } 13 List<DeclItem>
;;;                         } 12 TypeName
;;;                         { 12 Expr l[r]
;;;                           { 13 TypeName
;;;                             { 14 TypeSpecifier (all)
;;;                               spec = const char (20100)
;;;                             } 14 TypeSpecifier (all)
;;;                             { 14 List<DeclItem>
;;;                               { 15 DeclItem
;;;                                 what = DECL_NAME
;;;                                 name = hex
;;;                               } 15 DeclItem
;;;                             } 14 List<DeclItem>
;;;                           } 13 TypeName
;;;                           { 13 Expr l[r]
;;;                             { 14 Expr l & r
;;;                               { 15 TypeName (internal)
;;;                                 { 16 TypeSpecifier (all)
;;;                                   spec = unsigned int (82000)
;;;                                 } 16 TypeSpecifier (all)
;;;                               } 15 TypeName (internal)
;;;                               { 15 Expression (variable name)
;;;                                 expr_type = "identifier" (value)
;--	load_rr_var value = 4(FP), SP at 0 (16 bit)
	MOVE	4(SP), RR
;;;                               } 15 Expression (variable name)
;--	l & r
	AND	RR, #0x000F
;;;                             } 14 Expr l & r
;--	scale_rr *1
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                             { 14 Expression (variable name)
;;;                               expr_type = "identifier" (hex)
;--	load_rr_var hex = 6(FP), SP at -2 (16 bit)
	MOVE	8(SP), RR
;;;                             } 14 Expression (variable name)
;--	pop_ll (16 bit)
	MOVE	(SP)+, LL
;--	+ (element)
	ADD	LL, RR
;;;                           } 13 Expr l[r]
;--	content
	MOVE	(RR), RS
;;;                         } 12 Expr l[r]
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;;;                         { 12 Expr * r
;;;                           { 13 Expr l - r
;;;                             { 14 Expr ++r
;;;                               { 15 Expression (variable name)
;;;                                 expr_type = "identifier" (dest)
;--	load_rr_var dest = 2(FP), SP at -1 (16 bit)
	MOVE	3(SP), RR
;;;                               } 15 Expression (variable name)
;--	++
	ADD	RR, #0x0001
;--	store_rr_var dest = 2(FP), SP at -1
	MOVE	RR, 3(SP)
;;;                             } 14 Expr ++r
;--	l - r
	SUB	RR, #0x0001
;;;                           } 13 Expr l - r
;;;                         } 12 Expr * r
;--	move_rr_to_ll
	MOVE	RR, LL
;--	pop_rr (8 bit)
	MOVE	(SP)+, RS
;--	assign (8 bit)
	MOVE	R, (LL)
;;;                       } 11 Expr l = r
;;;                     } 10 ExpressionStatement
;;;                     { 10 ExpressionStatement
;;;                       { 11 Expr l = r
;;;                         { 12 TypeName
;;;                           { 13 TypeSpecifier (all)
;;;                             spec = char (20000)
;;;                           } 13 TypeSpecifier (all)
;;;                           { 13 List<DeclItem>
;;;                             { 14 DeclItem
;;;                               what = DECL_NAME
;;;                               name = dest
;;;                             } 14 DeclItem
;;;                           } 13 List<DeclItem>
;;;                         } 12 TypeName
;;;                         { 12 NumericExpression (constant 0 = 0x0)
;--	load_rr_constant
	MOVE	#0x0000, RR
;;;                         } 12 NumericExpression (constant 0 = 0x0)
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;;;                         { 12 Expr * r
;;;                           { 13 Expression (variable name)
;;;                             expr_type = "identifier" (dest)
;--	load_rr_var dest = 2(FP), SP at -1 (16 bit)
	MOVE	3(SP), RR
;;;                           } 13 Expression (variable name)
;;;                         } 12 Expr * r
;--	move_rr_to_ll
	MOVE	RR, LL
;--	pop_rr (8 bit)
	MOVE	(SP)+, RS
;--	assign (8 bit)
	MOVE	R, (LL)
;;;                       } 11 Expr l = r
;;;                     } 10 ExpressionStatement
;;;                   } 9 List<IfElseStatement>
;--	pop 0 bytes
;;;                 } 8 CompoundStatement
;--	ret
	RET
;;; ------------------------------------;
;;;                 { 8 FunctionDefinition
;;;                   { 9 TypeName
;;;                     { 10 TypeSpecifier (all)
;;;                       spec = void (10000)
;;;                     } 10 TypeSpecifier (all)
;;;                     { 10 List<DeclItem>
;;;                       { 11 DeclItem
;;;                         what = DECL_NAME
;;;                         name = print_unsigned
;;;                       } 11 DeclItem
;;;                     } 10 List<DeclItem>
;;;                   } 9 TypeName
;;;                   { 9 List<DeclItem>
;;;                     { 10 DeclItem
;;;                       what = DECL_NAME
;;;                       name = print_unsigned
;;;                     } 10 DeclItem
;;;                     { 10 DeclItem
;;;                       what = DECL_FUN
;;;                       { 11 List<ParameterDeclaration>
;;;                         { 12 ParameterDeclaration
;;;                           isEllipsis = false
;;;                           { 13 TypeName
;;;                             { 14 TypeSpecifier (all)
;;;                               spec = char (20000)
;;;                             } 14 TypeSpecifier (all)
;;;                             { 14 List<DeclItem>
;;;                               { 15 DeclItem
;;;                                 what = DECL_POINTER
;;;                                 { 16 List<Ptr>
;;;                                   { 17 Ptr
;;;                                   } 17 Ptr
;;;                                 } 16 List<Ptr>
;;;                               } 15 DeclItem
;;;                               { 15 DeclItem
;;;                                 what = DECL_NAME
;;;                                 name = dest
;;;                               } 15 DeclItem
;;;                             } 14 List<DeclItem>
;;;                           } 13 TypeName
;;;                         } 12 ParameterDeclaration
;;;                         { 12 ParameterDeclaration
;;;                           isEllipsis = false
;;;                           { 13 TypeName
;;;                             { 14 TypeSpecifier (all)
;;;                               spec = unsigned int (82000)
;;;                             } 14 TypeSpecifier (all)
;;;                             { 14 List<DeclItem>
;;;                               { 15 DeclItem
;;;                                 what = DECL_NAME
;;;                                 name = value
;;;                               } 15 DeclItem
;;;                             } 14 List<DeclItem>
;;;                           } 13 TypeName
;;;                         } 12 ParameterDeclaration
;;;                       } 11 List<ParameterDeclaration>
;;;                     } 10 DeclItem
;;;                   } 9 List<DeclItem>
Cprint_unsigned:
;;;                   { 9 CompoundStatement
;;;                     { 10 List<IfElseStatement>
;;;                       { 11 IfElseStatement
;;;                         { 12 Expr l >= r
;;;                           { 13 TypeName (internal)
;;;                             { 14 TypeSpecifier (all)
;;;                               spec = unsigned int (82000)
;;;                             } 14 TypeSpecifier (all)
;;;                           } 13 TypeName (internal)
;;;                           { 13 Expression (variable name)
;;;                             expr_type = "identifier" (value)
;--	load_rr_var value = 4(FP), SP at 0 (16 bit)
	MOVE	4(SP), RR
;;;                           } 13 Expression (variable name)
;--	l >= r
	SHS	RR, #0x2710
;;;                         } 12 Expr l >= r
;--	branch_false
	JMP	RRZ, L10_endif_18
;;;                         { 12 CompoundStatement
;;;                           { 13 List<ExpressionStatement>
;;;                             { 14 ExpressionStatement
;;;                               { 15 Expr l = r
;;;                                 { 16 TypeName
;;;                                   { 17 TypeSpecifier (all)
;;;                                     spec = char (20000)
;;;                                   } 17 TypeSpecifier (all)
;;;                                   { 17 List<DeclItem>
;;;                                     { 18 DeclItem
;;;                                       what = DECL_NAME
;;;                                       name = dest
;;;                                     } 18 DeclItem
;;;                                   } 17 List<DeclItem>
;;;                                 } 16 TypeName
;;;                                 { 16 Expr l + r
;;;                                   { 17 Expr l / r
;;;                                     { 18 TypeName (internal)
;;;                                       { 19 TypeSpecifier (all)
;;;                                         spec = unsigned int (82000)
;;;                                       } 19 TypeSpecifier (all)
;;;                                     } 18 TypeName (internal)
;;;                                     { 18 Expression (variable name)
;;;                                       expr_type = "identifier" (value)
;--	load_rr_var value = 4(FP), SP at 0 (16 bit)
	MOVE	4(SP), RR
;;;                                     } 18 Expression (variable name)
;--	l / r
	MOVE	RR, LL
	MOVE	#0x2710, RR
;--	l / r
	DI
	DIV_IU
	CALL	mult_div
	MD_FIN
	EI
;;;                                   } 17 Expr l / r
;--	l + r
	ADD	RR, #0x0030
;;;                                 } 16 Expr l + r
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;;;                                 { 16 Expr * r
;;;                                   { 17 Expr l - r
;;;                                     { 18 Expr ++r
;;;                                       { 19 Expression (variable name)
;;;                                         expr_type = "identifier" (dest)
;--	load_rr_var dest = 2(FP), SP at -1 (16 bit)
	MOVE	3(SP), RR
;;;                                       } 19 Expression (variable name)
;--	++
	ADD	RR, #0x0001
;--	store_rr_var dest = 2(FP), SP at -1
	MOVE	RR, 3(SP)
;;;                                     } 18 Expr ++r
;--	l - r
	SUB	RR, #0x0001
;;;                                   } 17 Expr l - r
;;;                                 } 16 Expr * r
;--	move_rr_to_ll
	MOVE	RR, LL
;--	pop_rr (8 bit)
	MOVE	(SP)+, RS
;--	assign (8 bit)
	MOVE	R, (LL)
;;;                               } 15 Expr l = r
;;;                             } 14 ExpressionStatement
;;;                             { 14 ExpressionStatement
;;;                               { 15 Expr l %= r
;;;                                 { 16 TypeName
;;;                                   { 17 TypeSpecifier (all)
;;;                                     spec = unsigned int (82000)
;;;                                   } 17 TypeSpecifier (all)
;;;                                   { 17 List<DeclItem>
;;;                                     { 18 DeclItem
;;;                                       what = DECL_NAME
;;;                                       name = value
;;;                                     } 18 DeclItem
;;;                                   } 17 List<DeclItem>
;;;                                 } 16 TypeName
;;;                                 { 16 Expr l % r
;;;                                   { 17 TypeName (internal)
;;;                                     { 18 TypeSpecifier (all)
;;;                                       spec = unsigned int (82000)
;;;                                     } 18 TypeSpecifier (all)
;;;                                   } 17 TypeName (internal)
;;;                                   { 17 Expression (variable name)
;;;                                     expr_type = "identifier" (value)
;--	load_rr_var value = 4(FP), SP at 0 (16 bit)
	MOVE	4(SP), RR
;;;                                   } 17 Expression (variable name)
;--	l % r
	MOVE	RR, LL
	MOVE	#0x2710, RR
;--	l % r
	DI
	DIV_IU
	CALL	mult_div
	MOD_FIN
	EI
;;;                                 } 16 Expr l % r
;--	store_rr_var value = 4(FP), SP at 0
	MOVE	RR, 4(SP)
;;;                               } 15 Expr l %= r
;;;                             } 14 ExpressionStatement
;;;                           } 13 List<ExpressionStatement>
;--	pop 0 bytes
;;;                         } 12 CompoundStatement
L10_endif_18:
;;;                       } 11 IfElseStatement
;;;                       { 11 IfElseStatement
;;;                         { 12 Expr l >= r
;;;                           { 13 TypeName (internal)
;;;                             { 14 TypeSpecifier (all)
;;;                               spec = unsigned int (82000)
;;;                             } 14 TypeSpecifier (all)
;;;                           } 13 TypeName (internal)
;;;                           { 13 Expression (variable name)
;;;                             expr_type = "identifier" (value)
;--	load_rr_var value = 4(FP), SP at 0 (16 bit)
	MOVE	4(SP), RR
;;;                           } 13 Expression (variable name)
;--	l >= r
	SHS	RR, #0x03E8
;;;                         } 12 Expr l >= r
;--	branch_false
	JMP	RRZ, L10_endif_19
;;;                         { 12 CompoundStatement
;;;                           { 13 List<ExpressionStatement>
;;;                             { 14 ExpressionStatement
;;;                               { 15 Expr l = r
;;;                                 { 16 TypeName
;;;                                   { 17 TypeSpecifier (all)
;;;                                     spec = char (20000)
;;;                                   } 17 TypeSpecifier (all)
;;;                                   { 17 List<DeclItem>
;;;                                     { 18 DeclItem
;;;                                       what = DECL_NAME
;;;                                       name = dest
;;;                                     } 18 DeclItem
;;;                                   } 17 List<DeclItem>
;;;                                 } 16 TypeName
;;;                                 { 16 Expr l + r
;;;                                   { 17 Expr l / r
;;;                                     { 18 TypeName (internal)
;;;                                       { 19 TypeSpecifier (all)
;;;                                         spec = unsigned int (82000)
;;;                                       } 19 TypeSpecifier (all)
;;;                                     } 18 TypeName (internal)
;;;                                     { 18 Expression (variable name)
;;;                                       expr_type = "identifier" (value)
;--	load_rr_var value = 4(FP), SP at 0 (16 bit)
	MOVE	4(SP), RR
;;;                                     } 18 Expression (variable name)
;--	l / r
	MOVE	RR, LL
	MOVE	#0x03E8, RR
;--	l / r
	DI
	DIV_IU
	CALL	mult_div
	MD_FIN
	EI
;;;                                   } 17 Expr l / r
;--	l + r
	ADD	RR, #0x0030
;;;                                 } 16 Expr l + r
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;;;                                 { 16 Expr * r
;;;                                   { 17 Expr l - r
;;;                                     { 18 Expr ++r
;;;                                       { 19 Expression (variable name)
;;;                                         expr_type = "identifier" (dest)
;--	load_rr_var dest = 2(FP), SP at -1 (16 bit)
	MOVE	3(SP), RR
;;;                                       } 19 Expression (variable name)
;--	++
	ADD	RR, #0x0001
;--	store_rr_var dest = 2(FP), SP at -1
	MOVE	RR, 3(SP)
;;;                                     } 18 Expr ++r
;--	l - r
	SUB	RR, #0x0001
;;;                                   } 17 Expr l - r
;;;                                 } 16 Expr * r
;--	move_rr_to_ll
	MOVE	RR, LL
;--	pop_rr (8 bit)
	MOVE	(SP)+, RS
;--	assign (8 bit)
	MOVE	R, (LL)
;;;                               } 15 Expr l = r
;;;                             } 14 ExpressionStatement
;;;                             { 14 ExpressionStatement
;;;                               { 15 Expr l %= r
;;;                                 { 16 TypeName
;;;                                   { 17 TypeSpecifier (all)
;;;                                     spec = unsigned int (82000)
;;;                                   } 17 TypeSpecifier (all)
;;;                                   { 17 List<DeclItem>
;;;                                     { 18 DeclItem
;;;                                       what = DECL_NAME
;;;                                       name = value
;;;                                     } 18 DeclItem
;;;                                   } 17 List<DeclItem>
;;;                                 } 16 TypeName
;;;                                 { 16 Expr l % r
;;;                                   { 17 TypeName (internal)
;;;                                     { 18 TypeSpecifier (all)
;;;                                       spec = unsigned int (82000)
;;;                                     } 18 TypeSpecifier (all)
;;;                                   } 17 TypeName (internal)
;;;                                   { 17 Expression (variable name)
;;;                                     expr_type = "identifier" (value)
;--	load_rr_var value = 4(FP), SP at 0 (16 bit)
	MOVE	4(SP), RR
;;;                                   } 17 Expression (variable name)
;--	l % r
	MOVE	RR, LL
	MOVE	#0x03E8, RR
;--	l % r
	DI
	DIV_IU
	CALL	mult_div
	MOD_FIN
	EI
;;;                                 } 16 Expr l % r
;--	store_rr_var value = 4(FP), SP at 0
	MOVE	RR, 4(SP)
;;;                               } 15 Expr l %= r
;;;                             } 14 ExpressionStatement
;;;                           } 13 List<ExpressionStatement>
;--	pop 0 bytes
;;;                         } 12 CompoundStatement
L10_endif_19:
;;;                       } 11 IfElseStatement
;;;                       { 11 IfElseStatement
;;;                         { 12 Expr l >= r
;;;                           { 13 TypeName (internal)
;;;                             { 14 TypeSpecifier (all)
;;;                               spec = unsigned int (82000)
;;;                             } 14 TypeSpecifier (all)
;;;                           } 13 TypeName (internal)
;;;                           { 13 Expression (variable name)
;;;                             expr_type = "identifier" (value)
;--	load_rr_var value = 4(FP), SP at 0 (16 bit)
	MOVE	4(SP), RR
;;;                           } 13 Expression (variable name)
;--	l >= r
	SHS	RR, #0x0064
;;;                         } 12 Expr l >= r
;--	branch_false
	JMP	RRZ, L10_endif_20
;;;                         { 12 CompoundStatement
;;;                           { 13 List<ExpressionStatement>
;;;                             { 14 ExpressionStatement
;;;                               { 15 Expr l = r
;;;                                 { 16 TypeName
;;;                                   { 17 TypeSpecifier (all)
;;;                                     spec = char (20000)
;;;                                   } 17 TypeSpecifier (all)
;;;                                   { 17 List<DeclItem>
;;;                                     { 18 DeclItem
;;;                                       what = DECL_NAME
;;;                                       name = dest
;;;                                     } 18 DeclItem
;;;                                   } 17 List<DeclItem>
;;;                                 } 16 TypeName
;;;                                 { 16 Expr l + r
;;;                                   { 17 Expr l / r
;;;                                     { 18 TypeName (internal)
;;;                                       { 19 TypeSpecifier (all)
;;;                                         spec = unsigned int (82000)
;;;                                       } 19 TypeSpecifier (all)
;;;                                     } 18 TypeName (internal)
;;;                                     { 18 Expression (variable name)
;;;                                       expr_type = "identifier" (value)
;--	load_rr_var value = 4(FP), SP at 0 (16 bit)
	MOVE	4(SP), RR
;;;                                     } 18 Expression (variable name)
;--	l / r
	MOVE	RR, LL
	MOVE	#0x0064, RR
;--	l / r
	DI
	DIV_IU
	CALL	mult_div
	MD_FIN
	EI
;;;                                   } 17 Expr l / r
;--	l + r
	ADD	RR, #0x0030
;;;                                 } 16 Expr l + r
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;;;                                 { 16 Expr * r
;;;                                   { 17 Expr l - r
;;;                                     { 18 Expr ++r
;;;                                       { 19 Expression (variable name)
;;;                                         expr_type = "identifier" (dest)
;--	load_rr_var dest = 2(FP), SP at -1 (16 bit)
	MOVE	3(SP), RR
;;;                                       } 19 Expression (variable name)
;--	++
	ADD	RR, #0x0001
;--	store_rr_var dest = 2(FP), SP at -1
	MOVE	RR, 3(SP)
;;;                                     } 18 Expr ++r
;--	l - r
	SUB	RR, #0x0001
;;;                                   } 17 Expr l - r
;;;                                 } 16 Expr * r
;--	move_rr_to_ll
	MOVE	RR, LL
;--	pop_rr (8 bit)
	MOVE	(SP)+, RS
;--	assign (8 bit)
	MOVE	R, (LL)
;;;                               } 15 Expr l = r
;;;                             } 14 ExpressionStatement
;;;                             { 14 ExpressionStatement
;;;                               { 15 Expr l %= r
;;;                                 { 16 TypeName
;;;                                   { 17 TypeSpecifier (all)
;;;                                     spec = unsigned int (82000)
;;;                                   } 17 TypeSpecifier (all)
;;;                                   { 17 List<DeclItem>
;;;                                     { 18 DeclItem
;;;                                       what = DECL_NAME
;;;                                       name = value
;;;                                     } 18 DeclItem
;;;                                   } 17 List<DeclItem>
;;;                                 } 16 TypeName
;;;                                 { 16 Expr l % r
;;;                                   { 17 TypeName (internal)
;;;                                     { 18 TypeSpecifier (all)
;;;                                       spec = unsigned int (82000)
;;;                                     } 18 TypeSpecifier (all)
;;;                                   } 17 TypeName (internal)
;;;                                   { 17 Expression (variable name)
;;;                                     expr_type = "identifier" (value)
;--	load_rr_var value = 4(FP), SP at 0 (16 bit)
	MOVE	4(SP), RR
;;;                                   } 17 Expression (variable name)
;--	l % r
	MOVE	RR, LL
	MOVE	#0x0064, RR
;--	l % r
	DI
	DIV_IU
	CALL	mult_div
	MOD_FIN
	EI
;;;                                 } 16 Expr l % r
;--	store_rr_var value = 4(FP), SP at 0
	MOVE	RR, 4(SP)
;;;                               } 15 Expr l %= r
;;;                             } 14 ExpressionStatement
;;;                           } 13 List<ExpressionStatement>
;--	pop 0 bytes
;;;                         } 12 CompoundStatement
L10_endif_20:
;;;                       } 11 IfElseStatement
;;;                       { 11 IfElseStatement
;;;                         { 12 Expr l >= r
;;;                           { 13 TypeName (internal)
;;;                             { 14 TypeSpecifier (all)
;;;                               spec = unsigned int (82000)
;;;                             } 14 TypeSpecifier (all)
;;;                           } 13 TypeName (internal)
;;;                           { 13 Expression (variable name)
;;;                             expr_type = "identifier" (value)
;--	load_rr_var value = 4(FP), SP at 0 (16 bit)
	MOVE	4(SP), RR
;;;                           } 13 Expression (variable name)
;--	l >= r
	SHS	RR, #0x000A
;;;                         } 12 Expr l >= r
;--	branch_false
	JMP	RRZ, L10_endif_21
;;;                         { 12 CompoundStatement
;;;                           { 13 List<ExpressionStatement>
;;;                             { 14 ExpressionStatement
;;;                               { 15 Expr l = r
;;;                                 { 16 TypeName
;;;                                   { 17 TypeSpecifier (all)
;;;                                     spec = char (20000)
;;;                                   } 17 TypeSpecifier (all)
;;;                                   { 17 List<DeclItem>
;;;                                     { 18 DeclItem
;;;                                       what = DECL_NAME
;;;                                       name = dest
;;;                                     } 18 DeclItem
;;;                                   } 17 List<DeclItem>
;;;                                 } 16 TypeName
;;;                                 { 16 Expr l + r
;;;                                   { 17 Expr l / r
;;;                                     { 18 TypeName (internal)
;;;                                       { 19 TypeSpecifier (all)
;;;                                         spec = unsigned int (82000)
;;;                                       } 19 TypeSpecifier (all)
;;;                                     } 18 TypeName (internal)
;;;                                     { 18 Expression (variable name)
;;;                                       expr_type = "identifier" (value)
;--	load_rr_var value = 4(FP), SP at 0 (16 bit)
	MOVE	4(SP), RR
;;;                                     } 18 Expression (variable name)
;--	l / r
	MOVE	RR, LL
	MOVE	#0x000A, RR
;--	l / r
	DI
	DIV_IU
	CALL	mult_div
	MD_FIN
	EI
;;;                                   } 17 Expr l / r
;--	l + r
	ADD	RR, #0x0030
;;;                                 } 16 Expr l + r
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;;;                                 { 16 Expr * r
;;;                                   { 17 Expr l - r
;;;                                     { 18 Expr ++r
;;;                                       { 19 Expression (variable name)
;;;                                         expr_type = "identifier" (dest)
;--	load_rr_var dest = 2(FP), SP at -1 (16 bit)
	MOVE	3(SP), RR
;;;                                       } 19 Expression (variable name)
;--	++
	ADD	RR, #0x0001
;--	store_rr_var dest = 2(FP), SP at -1
	MOVE	RR, 3(SP)
;;;                                     } 18 Expr ++r
;--	l - r
	SUB	RR, #0x0001
;;;                                   } 17 Expr l - r
;;;                                 } 16 Expr * r
;--	move_rr_to_ll
	MOVE	RR, LL
;--	pop_rr (8 bit)
	MOVE	(SP)+, RS
;--	assign (8 bit)
	MOVE	R, (LL)
;;;                               } 15 Expr l = r
;;;                             } 14 ExpressionStatement
;;;                             { 14 ExpressionStatement
;;;                               { 15 Expr l %= r
;;;                                 { 16 TypeName
;;;                                   { 17 TypeSpecifier (all)
;;;                                     spec = unsigned int (82000)
;;;                                   } 17 TypeSpecifier (all)
;;;                                   { 17 List<DeclItem>
;;;                                     { 18 DeclItem
;;;                                       what = DECL_NAME
;;;                                       name = value
;;;                                     } 18 DeclItem
;;;                                   } 17 List<DeclItem>
;;;                                 } 16 TypeName
;;;                                 { 16 Expr l % r
;;;                                   { 17 TypeName (internal)
;;;                                     { 18 TypeSpecifier (all)
;;;                                       spec = unsigned int (82000)
;;;                                     } 18 TypeSpecifier (all)
;;;                                   } 17 TypeName (internal)
;;;                                   { 17 Expression (variable name)
;;;                                     expr_type = "identifier" (value)
;--	load_rr_var value = 4(FP), SP at 0 (16 bit)
	MOVE	4(SP), RR
;;;                                   } 17 Expression (variable name)
;--	l % r
	MOVE	RR, LL
	MOVE	#0x000A, RR
;--	l % r
	DI
	DIV_IU
	CALL	mult_div
	MOD_FIN
	EI
;;;                                 } 16 Expr l % r
;--	store_rr_var value = 4(FP), SP at 0
	MOVE	RR, 4(SP)
;;;                               } 15 Expr l %= r
;;;                             } 14 ExpressionStatement
;;;                           } 13 List<ExpressionStatement>
;--	pop 0 bytes
;;;                         } 12 CompoundStatement
L10_endif_21:
;;;                       } 11 IfElseStatement
;;;                       { 11 ExpressionStatement
;;;                         { 12 Expr l = r
;;;                           { 13 TypeName
;;;                             { 14 TypeSpecifier (all)
;;;                               spec = char (20000)
;;;                             } 14 TypeSpecifier (all)
;;;                             { 14 List<DeclItem>
;;;                               { 15 DeclItem
;;;                                 what = DECL_NAME
;;;                                 name = dest
;;;                               } 15 DeclItem
;;;                             } 14 List<DeclItem>
;;;                           } 13 TypeName
;;;                           { 13 Expr l + r
;;;                             { 14 Expression (variable name)
;;;                               expr_type = "identifier" (value)
;--	load_rr_var value = 4(FP), SP at 0 (16 bit)
	MOVE	4(SP), RR
;;;                             } 14 Expression (variable name)
;--	l + r
	ADD	RR, #0x0030
;;;                           } 13 Expr l + r
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;;;                           { 13 Expr * r
;;;                             { 14 Expr l - r
;;;                               { 15 Expr ++r
;;;                                 { 16 Expression (variable name)
;;;                                   expr_type = "identifier" (dest)
;--	load_rr_var dest = 2(FP), SP at -1 (16 bit)
	MOVE	3(SP), RR
;;;                                 } 16 Expression (variable name)
;--	++
	ADD	RR, #0x0001
;--	store_rr_var dest = 2(FP), SP at -1
	MOVE	RR, 3(SP)
;;;                               } 15 Expr ++r
;--	l - r
	SUB	RR, #0x0001
;;;                             } 14 Expr l - r
;;;                           } 13 Expr * r
;--	move_rr_to_ll
	MOVE	RR, LL
;--	pop_rr (8 bit)
	MOVE	(SP)+, RS
;--	assign (8 bit)
	MOVE	R, (LL)
;;;                         } 12 Expr l = r
;;;                       } 11 ExpressionStatement
;;;                       { 11 ExpressionStatement
;;;                         { 12 Expr l = r
;;;                           { 13 TypeName
;;;                             { 14 TypeSpecifier (all)
;;;                               spec = char (20000)
;;;                             } 14 TypeSpecifier (all)
;;;                             { 14 List<DeclItem>
;;;                               { 15 DeclItem
;;;                                 what = DECL_NAME
;;;                                 name = dest
;;;                               } 15 DeclItem
;;;                             } 14 List<DeclItem>
;;;                           } 13 TypeName
;;;                           { 13 NumericExpression (constant 0 = 0x0)
;--	load_rr_constant
	MOVE	#0x0000, RR
;;;                           } 13 NumericExpression (constant 0 = 0x0)
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;;;                           { 13 Expr * r
;;;                             { 14 Expression (variable name)
;;;                               expr_type = "identifier" (dest)
;--	load_rr_var dest = 2(FP), SP at -1 (16 bit)
	MOVE	3(SP), RR
;;;                             } 14 Expression (variable name)
;;;                           } 13 Expr * r
;--	move_rr_to_ll
	MOVE	RR, LL
;--	pop_rr (8 bit)
	MOVE	(SP)+, RS
;--	assign (8 bit)
	MOVE	R, (LL)
;;;                         } 12 Expr l = r
;;;                       } 11 ExpressionStatement
;;;                     } 10 List<IfElseStatement>
;--	pop 0 bytes
;;;                   } 9 CompoundStatement
;--	ret
	RET
;;; ------------------------------------;
;;;                   { 9 FunctionDefinition
;;;                     { 10 TypeName
;;;                       { 11 TypeSpecifier (all)
;;;                         spec = int (80000)
;;;                       } 11 TypeSpecifier (all)
;;;                       { 11 List<DeclItem>
;;;                         { 12 DeclItem
;;;                           what = DECL_NAME
;;;                           name = print_item
;;;                         } 12 DeclItem
;;;                       } 11 List<DeclItem>
;;;                     } 10 TypeName
;;;                     { 10 List<DeclItem>
;;;                       { 11 DeclItem
;;;                         what = DECL_NAME
;;;                         name = print_item
;;;                       } 11 DeclItem
;;;                       { 11 DeclItem
;;;                         what = DECL_FUN
;;;                         { 12 List<ParameterDeclaration>
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
;;;                           { 13 ParameterDeclaration
;;;                             isEllipsis = false
;;;                             { 14 TypeName
;;;                               { 15 TypeSpecifier (all)
;;;                                 spec = char (20000)
;;;                               } 15 TypeSpecifier (all)
;;;                               { 15 List<DeclItem>
;;;                                 { 16 DeclItem
;;;                                   what = DECL_NAME
;;;                                   name = flags
;;;                                 } 16 DeclItem
;;;                               } 15 List<DeclItem>
;;;                             } 14 TypeName
;;;                           } 13 ParameterDeclaration
;;;                           { 13 ParameterDeclaration
;;;                             isEllipsis = false
;;;                             { 14 TypeName
;;;                               { 15 TypeSpecifier (all)
;;;                                 spec = char (20000)
;;;                               } 15 TypeSpecifier (all)
;;;                               { 15 List<DeclItem>
;;;                                 { 16 DeclItem
;;;                                   what = DECL_NAME
;;;                                   name = sign
;;;                                 } 16 DeclItem
;;;                               } 15 List<DeclItem>
;;;                             } 14 TypeName
;;;                           } 13 ParameterDeclaration
;;;                           { 13 ParameterDeclaration
;;;                             isEllipsis = false
;;;                             { 14 TypeName
;;;                               { 15 TypeSpecifier (all)
;;;                                 spec = char (20000)
;;;                               } 15 TypeSpecifier (all)
;;;                               { 15 List<DeclItem>
;;;                                 { 16 DeclItem
;;;                                   what = DECL_NAME
;;;                                   name = pad
;;;                                 } 16 DeclItem
;;;                               } 15 List<DeclItem>
;;;                             } 14 TypeName
;;;                           } 13 ParameterDeclaration
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
;;;                                   name = alt
;;;                                 } 16 DeclItem
;;;                               } 15 List<DeclItem>
;;;                             } 14 TypeName
;;;                           } 13 ParameterDeclaration
;;;                           { 13 ParameterDeclaration
;;;                             isEllipsis = false
;;;                             { 14 TypeName
;;;                               { 15 TypeSpecifier (all)
;;;                                 spec = int (80000)
;;;                               } 15 TypeSpecifier (all)
;;;                               { 15 List<DeclItem>
;;;                                 { 16 DeclItem
;;;                                   what = DECL_NAME
;;;                                   name = field_w
;;;                                 } 16 DeclItem
;;;                               } 15 List<DeclItem>
;;;                             } 14 TypeName
;;;                           } 13 ParameterDeclaration
;;;                           { 13 ParameterDeclaration
;;;                             isEllipsis = false
;;;                             { 14 TypeName
;;;                               { 15 TypeSpecifier (all)
;;;                                 spec = int (80000)
;;;                               } 15 TypeSpecifier (all)
;;;                               { 15 List<DeclItem>
;;;                                 { 16 DeclItem
;;;                                   what = DECL_NAME
;;;                                   name = min_w
;;;                                 } 16 DeclItem
;;;                               } 15 List<DeclItem>
;;;                             } 14 TypeName
;;;                           } 13 ParameterDeclaration
;;;                           { 13 ParameterDeclaration
;;;                             isEllipsis = false
;;;                             { 14 TypeName
;;;                               { 15 TypeSpecifier (all)
;;;                                 spec = char (20000)
;;;                               } 15 TypeSpecifier (all)
;;;                               { 15 List<DeclItem>
;;;                                 { 16 DeclItem
;;;                                   what = DECL_NAME
;;;                                   name = min_p
;;;                                 } 16 DeclItem
;;;                               } 15 List<DeclItem>
;;;                             } 14 TypeName
;;;                           } 13 ParameterDeclaration
;;;                         } 12 List<ParameterDeclaration>
;;;                       } 11 DeclItem
;;;                     } 10 List<DeclItem>
Cprint_item:
;;;                     { 10 CompoundStatement
;;;                       { 11 InitDeclarator
;;;                         { 12 List<DeclItem>
;;;                           { 13 DeclItem
;;;                             what = DECL_NAME
;;;                             name = filllen
;;;                           } 13 DeclItem
;;;                         } 12 List<DeclItem>
;;;                         { 12 Initializer (skalar)
;--	push_zero 2 bytes
	CLRW	-(SP)
;;;                         } 12 Initializer (skalar)
;;;                       } 11 InitDeclarator
;;;                       { 11 InitDeclarator
;;;                         { 12 List<DeclItem>
;;;                           { 13 DeclItem
;;;                             what = DECL_NAME
;;;                             name = signlen
;;;                           } 13 DeclItem
;;;                         } 12 List<DeclItem>
;;;                         { 12 Initializer (skalar)
;--	push_zero 2 bytes
	CLRW	-(SP)
;;;                         } 12 Initializer (skalar)
;;;                       } 11 InitDeclarator
;;;                       { 11 InitDeclarator
;;;                         { 12 List<DeclItem>
;;;                           { 13 DeclItem
;;;                             what = DECL_NAME
;;;                             name = altlen
;;;                           } 13 DeclItem
;;;                         } 12 List<DeclItem>
;;;                         { 12 Initializer (skalar)
;--	push_zero 2 bytes
	CLRW	-(SP)
;;;                         } 12 Initializer (skalar)
;;;                       } 11 InitDeclarator
;;;                       { 11 InitDeclarator
;;;                         { 12 List<DeclItem>
;;;                           { 13 DeclItem
;;;                             what = DECL_NAME
;;;                             name = padlen
;;;                           } 13 DeclItem
;;;                         } 12 List<DeclItem>
;;;                         { 12 Initializer (skalar)
;--	push_zero 2 bytes
	CLRW	-(SP)
;;;                         } 12 Initializer (skalar)
;;;                       } 11 InitDeclarator
;;;                       { 11 InitDeclarator
;;;                         { 12 List<DeclItem>
;;;                           { 13 DeclItem
;;;                             what = DECL_NAME
;;;                             name = buflen
;;;                           } 13 DeclItem
;;;                         } 12 List<DeclItem>
;;;                         { 12 Initializer (skalar)
;;;                           { 13 Expr l(r)
;;;                             { 14 TypeName
;;;                               { 15 TypeSpecifier (all)
;;;                                 spec = int (80000)
;;;                               } 15 TypeSpecifier (all)
;;;                               { 15 List<DeclItem>
;;;                                 { 16 DeclItem
;;;                                   what = DECL_NAME
;;;                                   name = strlen
;;;                                 } 16 DeclItem
;;;                               } 15 List<DeclItem>
;;;                             } 14 TypeName
;;;                             { 14 ParameterDeclaration
;;;                               isEllipsis = false
;;;                               { 15 TypeName
;;;                                 { 16 TypeSpecifier (all)
;;;                                   spec = const char (20100)
;;;                                 } 16 TypeSpecifier (all)
;;;                                 { 16 List<DeclItem>
;;;                                   { 17 DeclItem
;;;                                     what = DECL_POINTER
;;;                                     { 18 List<Ptr>
;;;                                       { 19 Ptr
;;;                                       } 19 Ptr
;;;                                     } 18 List<Ptr>
;;;                                   } 17 DeclItem
;;;                                   { 17 DeclItem
;;;                                     what = DECL_NAME
;;;                                     name = buffer
;;;                                   } 17 DeclItem
;;;                                 } 16 List<DeclItem>
;;;                               } 15 TypeName
;;;                             } 14 ParameterDeclaration
;;;                             { 14 Expression (variable name)
;;;                               expr_type = "identifier" (buffer)
;--	load_rr_var buffer = 2(FP), SP at -8 (16 bit)
	MOVE	10(SP), RR
;;;                             } 14 Expression (variable name)
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;--	push 2 bytes
;--	call
	CALL	Cstrlen
;--	pop 2 bytes
	ADD	SP, #2
;;;                           } 13 Expr l(r)
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                         } 12 Initializer (skalar)
;;;                       } 11 InitDeclarator
;;;                       { 11 InitDeclarator
;;;                         { 12 List<DeclItem>
;;;                           { 13 DeclItem
;;;                             what = DECL_NAME
;;;                             name = len
;;;                           } 13 DeclItem
;;;                         } 12 List<DeclItem>
;--	push_zero 2 bytes
	CLRW	-(SP)
;;;                       } 11 InitDeclarator
;;;                       { 11 InitDeclarator
;;;                         { 12 List<DeclItem>
;;;                           { 13 DeclItem
;;;                             what = DECL_NAME
;;;                             name = i
;;;                           } 13 DeclItem
;;;                         } 12 List<DeclItem>
;--	push_zero 2 bytes
	CLRW	-(SP)
;;;                       } 11 InitDeclarator
;;;                       { 11 List<IfElseStatement>
;;;                         { 12 IfElseStatement
;;;                           { 13 Expr l > r
;;;                             { 14 TypeName (internal)
;;;                               { 15 TypeSpecifier (all)
;;;                                 spec = int (80000)
;;;                               } 15 TypeSpecifier (all)
;;;                             } 14 TypeName (internal)
;;;                             { 14 Expression (variable name)
;;;                               expr_type = "identifier" (min_w)
;--	load_rr_var min_w = 11(FP), SP at -14 (16 bit)
	MOVE	25(SP), RR
;;;                             } 14 Expression (variable name)
;--	move_rr_to_ll
	MOVE	RR, LL
;;;                             { 14 Expression (variable name)
;;;                               expr_type = "identifier" (buflen)
;--	load_rr_var buflen = -10(FP), SP at -14 (16 bit)
	MOVE	4(SP), RR
;;;                             } 14 Expression (variable name)
;--	l > r
	SGT	LL, RR
;;;                           } 13 Expr l > r
;--	branch_false
	JMP	RRZ, L11_endif_22
;;;                           { 13 ExpressionStatement
;;;                             { 14 Expr l = r
;;;                               { 15 TypeName
;;;                                 { 16 TypeSpecifier (all)
;;;                                   spec = int (80000)
;;;                                 } 16 TypeSpecifier (all)
;;;                                 { 16 List<DeclItem>
;;;                                   { 17 DeclItem
;;;                                     what = DECL_NAME
;;;                                     name = padlen
;;;                                   } 17 DeclItem
;;;                                 } 16 List<DeclItem>
;;;                               } 15 TypeName
;;;                               { 15 Expr l - r
;;;                                 { 16 Expression (variable name)
;;;                                   expr_type = "identifier" (min_w)
;--	load_rr_var min_w = 11(FP), SP at -14 (16 bit)
	MOVE	25(SP), RR
;;;                                 } 16 Expression (variable name)
;--	move_rr_to_ll
	MOVE	RR, LL
;;;                                 { 16 Expression (variable name)
;;;                                   expr_type = "identifier" (buflen)
;--	load_rr_var buflen = -10(FP), SP at -14 (16 bit)
	MOVE	4(SP), RR
;;;                                 } 16 Expression (variable name)
;--	scale_rr *1
;--	l - r
	SUB	LL, RR
;--	scale *1
;;;                               } 15 Expr l - r
;--	store_rr_var padlen = -8(FP), SP at -14
	MOVE	RR, 6(SP)
;;;                             } 14 Expr l = r
;;;                           } 13 ExpressionStatement
L11_endif_22:
;;;                         } 12 IfElseStatement
;;;                         { 12 IfElseStatement
;;;                           { 13 Expression (variable name)
;;;                             expr_type = "identifier" (sign)
;--	load_rr_var sign = 5(FP), SP at -14 (8 bit)
	MOVE	19(SP), RS
;;;                           } 13 Expression (variable name)
;--	branch_false
	JMP	RRZ, L11_endif_23
;;;                           { 13 ExpressionStatement
;;;                             { 14 Expr l = r
;;;                               { 15 TypeName
;;;                                 { 16 TypeSpecifier (all)
;;;                                   spec = int (80000)
;;;                                 } 16 TypeSpecifier (all)
;;;                                 { 16 List<DeclItem>
;;;                                   { 17 DeclItem
;;;                                     what = DECL_NAME
;;;                                     name = signlen
;;;                                   } 17 DeclItem
;;;                                 } 16 List<DeclItem>
;;;                               } 15 TypeName
;;;                               { 15 NumericExpression (constant 1 = 0x1)
;--	load_rr_constant
	MOVE	#0x0001, RR
;;;                               } 15 NumericExpression (constant 1 = 0x1)
;--	store_rr_var signlen = -4(FP), SP at -14
	MOVE	RR, 10(SP)
;;;                             } 14 Expr l = r
;;;                           } 13 ExpressionStatement
L11_endif_23:
;;;                         } 12 IfElseStatement
;;;                         { 12 IfElseStatement
;;;                           { 13 Expr l && r
;;;                             { 14 TypeName (internal)
;;;                               { 15 TypeSpecifier (all)
;;;                                 spec = int (80000)
;;;                               } 15 TypeSpecifier (all)
;;;                             } 14 TypeName (internal)
;;;                             { 14 IfElseStatement
;;;                               { 15 Expression (variable name)
;;;                                 expr_type = "identifier" (alt)
;--	load_rr_var alt = 7(FP), SP at -14 (16 bit)
	MOVE	21(SP), RR
;;;                               } 15 Expression (variable name)
;--	branch_false
	JMP	RRZ, L11_endif_25
;;;                               { 15 ExpressionStatement
;;;                                 { 16 Expr l & r
;;;                                   { 17 TypeName (internal)
;;;                                     { 18 TypeSpecifier (all)
;;;                                       spec = int (80000)
;;;                                     } 18 TypeSpecifier (all)
;;;                                   } 17 TypeName (internal)
;;;                                   { 17 Expression (variable name)
;;;                                     expr_type = "identifier" (flags)
;--	load_rr_var flags = 4(FP), SP at -14 (8 bit)
	MOVE	18(SP), RS
;;;                                   } 17 Expression (variable name)
;--	l & r
	AND	RR, #0x0001
;;;                                 } 16 Expr l & r
;;;                               } 15 ExpressionStatement
L11_endif_25:
;;;                             } 14 IfElseStatement
;;;                           } 13 Expr l && r
;--	branch_false
	JMP	RRZ, L11_endif_24
;;;                           { 13 ExpressionStatement
;;;                             { 14 Expr l = r
;;;                               { 15 TypeName
;;;                                 { 16 TypeSpecifier (all)
;;;                                   spec = int (80000)
;;;                                 } 16 TypeSpecifier (all)
;;;                                 { 16 List<DeclItem>
;;;                                   { 17 DeclItem
;;;                                     what = DECL_NAME
;;;                                     name = altlen
;;;                                   } 17 DeclItem
;;;                                 } 16 List<DeclItem>
;;;                               } 15 TypeName
;;;                               { 15 Expr l(r)
;;;                                 { 16 TypeName
;;;                                   { 17 TypeSpecifier (all)
;;;                                     spec = int (80000)
;;;                                   } 17 TypeSpecifier (all)
;;;                                   { 17 List<DeclItem>
;;;                                     { 18 DeclItem
;;;                                       what = DECL_NAME
;;;                                       name = strlen
;;;                                     } 18 DeclItem
;;;                                   } 17 List<DeclItem>
;;;                                 } 16 TypeName
;;;                                 { 16 ParameterDeclaration
;;;                                   isEllipsis = false
;;;                                   { 17 TypeName
;;;                                     { 18 TypeSpecifier (all)
;;;                                       spec = const char (20100)
;;;                                     } 18 TypeSpecifier (all)
;;;                                     { 18 List<DeclItem>
;;;                                       { 19 DeclItem
;;;                                         what = DECL_POINTER
;;;                                         { 20 List<Ptr>
;;;                                           { 21 Ptr
;;;                                           } 21 Ptr
;;;                                         } 20 List<Ptr>
;;;                                       } 19 DeclItem
;;;                                       { 19 DeclItem
;;;                                         what = DECL_NAME
;;;                                         name = buffer
;;;                                       } 19 DeclItem
;;;                                     } 18 List<DeclItem>
;;;                                   } 17 TypeName
;;;                                 } 16 ParameterDeclaration
;;;                                 { 16 Expression (variable name)
;;;                                   expr_type = "identifier" (alt)
;--	load_rr_var alt = 7(FP), SP at -14 (16 bit)
	MOVE	21(SP), RR
;;;                                 } 16 Expression (variable name)
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;--	push 2 bytes
;--	call
	CALL	Cstrlen
;--	pop 2 bytes
	ADD	SP, #2
;;;                               } 15 Expr l(r)
;--	store_rr_var altlen = -6(FP), SP at -14
	MOVE	RR, 8(SP)
;;;                             } 14 Expr l = r
;;;                           } 13 ExpressionStatement
L11_endif_24:
;;;                         } 12 IfElseStatement
;;;                         { 12 ExpressionStatement
;;;                           { 13 Expr l = r
;;;                             { 14 TypeName
;;;                               { 15 TypeSpecifier (all)
;;;                                 spec = int (80000)
;;;                               } 15 TypeSpecifier (all)
;;;                               { 15 List<DeclItem>
;;;                                 { 16 DeclItem
;;;                                   what = DECL_NAME
;;;                                   name = len
;;;                                 } 16 DeclItem
;;;                               } 15 List<DeclItem>
;;;                             } 14 TypeName
;;;                             { 14 Expr l + r
;;;                               { 15 Expr l + r
;;;                                 { 16 Expr l + r
;;;                                   { 17 Expression (variable name)
;;;                                     expr_type = "identifier" (signlen)
;--	load_rr_var signlen = -4(FP), SP at -14 (16 bit)
	MOVE	10(SP), RR
;;;                                   } 17 Expression (variable name)
;--	move_rr_to_ll
	MOVE	RR, LL
;;;                                   { 17 Expression (variable name)
;;;                                     expr_type = "identifier" (altlen)
;--	load_rr_var altlen = -6(FP), SP at -14 (16 bit)
	MOVE	8(SP), RR
;;;                                   } 17 Expression (variable name)
;--	scale_rr *1
;--	l + r
	ADD	LL, RR
;;;                                 } 16 Expr l + r
;--	move_rr_to_ll
	MOVE	RR, LL
;;;                                 { 16 Expression (variable name)
;;;                                   expr_type = "identifier" (padlen)
;--	load_rr_var padlen = -8(FP), SP at -14 (16 bit)
	MOVE	6(SP), RR
;;;                                 } 16 Expression (variable name)
;--	scale_rr *1
;--	l + r
	ADD	LL, RR
;;;                               } 15 Expr l + r
;--	move_rr_to_ll
	MOVE	RR, LL
;;;                               { 15 Expression (variable name)
;;;                                 expr_type = "identifier" (buflen)
;--	load_rr_var buflen = -10(FP), SP at -14 (16 bit)
	MOVE	4(SP), RR
;;;                               } 15 Expression (variable name)
;--	scale_rr *1
;--	l + r
	ADD	LL, RR
;;;                             } 14 Expr l + r
;--	store_rr_var len = -12(FP), SP at -14
	MOVE	RR, 2(SP)
;;;                           } 13 Expr l = r
;;;                         } 12 ExpressionStatement
;;;                         { 12 IfElseStatement
;;;                           { 13 Expr l & r
;;;                             { 14 TypeName (internal)
;;;                               { 15 TypeSpecifier (all)
;;;                                 spec = int (80000)
;;;                               } 15 TypeSpecifier (all)
;;;                             } 14 TypeName (internal)
;;;                             { 14 Expr ~ r
;;;                               { 15 Expression (variable name)
;;;                                 expr_type = "identifier" (flags)
;--	load_rr_var flags = 4(FP), SP at -14 (8 bit)
	MOVE	18(SP), RS
;;;                               } 15 Expression (variable name)
;--	16 bit ~ r
	NOT	RR
;;;                             } 14 Expr ~ r
;--	l & r
	AND	RR, #0x0002
;;;                           } 13 Expr l & r
;--	branch_false
	JMP	RRZ, L11_endif_26
;;;                           { 13 CompoundStatement
;;;                             { 14 List<for Statement>
;;;                               { 15 for Statement
;;;                                 { 16 ExpressionStatement
;;;                                   { 17 Expr l = r
;;;                                     { 18 TypeName
;;;                                       { 19 TypeSpecifier (all)
;;;                                         spec = int (80000)
;;;                                       } 19 TypeSpecifier (all)
;;;                                       { 19 List<DeclItem>
;;;                                         { 20 DeclItem
;;;                                           what = DECL_NAME
;;;                                           name = i
;;;                                         } 20 DeclItem
;;;                                       } 19 List<DeclItem>
;;;                                     } 18 TypeName
;;;                                     { 18 Expression (variable name)
;;;                                       expr_type = "identifier" (len)
;--	load_rr_var len = -12(FP), SP at -14 (16 bit)
	MOVE	2(SP), RR
;;;                                     } 18 Expression (variable name)
;--	store_rr_var i = -14(FP), SP at -14
	MOVE	RR, 0(SP)
;;;                                   } 17 Expr l = r
;;;                                 } 16 ExpressionStatement
;--	branch
	JMP	L11_tst_27
L11_loop_27:
;;;                                 { 16 ExpressionStatement
;;;                                   { 17 Expr l(r)
;;;                                     { 18 TypeName
;;;                                       { 19 TypeSpecifier (all)
;;;                                         spec = int (80000)
;;;                                       } 19 TypeSpecifier (all)
;;;                                       { 19 List<DeclItem>
;;;                                         { 20 DeclItem
;;;                                           what = DECL_NAME
;;;                                           name = putchr
;;;                                         } 20 DeclItem
;;;                                       } 19 List<DeclItem>
;;;                                     } 18 TypeName
;;;                                     { 18 ParameterDeclaration
;;;                                       isEllipsis = false
;;;                                       { 19 TypeName
;;;                                         { 20 TypeSpecifier (all)
;;;                                           spec = char (20000)
;;;                                         } 20 TypeSpecifier (all)
;;;                                         { 20 List<DeclItem>
;;;                                           { 21 DeclItem
;;;                                             what = DECL_NAME
;;;                                             name = c
;;;                                           } 21 DeclItem
;;;                                         } 20 List<DeclItem>
;;;                                       } 19 TypeName
;;;                                     } 18 ParameterDeclaration
;;;                                     { 18 Expression (variable name)
;;;                                       expr_type = "identifier" (pad)
;--	load_rr_var pad = 6(FP), SP at -14 (8 bit)
	MOVE	20(SP), RS
;;;                                     } 18 Expression (variable name)
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;--	push 2 bytes
;--	call
	CALL	Cputchr
;--	pop 1 bytes
	ADD	SP, #1
;;;                                   } 17 Expr l(r)
;;;                                 } 16 ExpressionStatement
L11_cont_27:
;;;                                 { 16 Expr l - r
;;;                                   { 17 Expr ++r
;;;                                     { 18 Expression (variable name)
;;;                                       expr_type = "identifier" (i)
;--	load_rr_var i = -14(FP), SP at -14 (16 bit)
	MOVE	0(SP), RR
;;;                                     } 18 Expression (variable name)
;--	++
	ADD	RR, #0x0001
;--	store_rr_var i = -14(FP), SP at -14
	MOVE	RR, 0(SP)
;;;                                   } 17 Expr ++r
;--	l - r
	SUB	RR, #0x0001
;;;                                 } 16 Expr l - r
L11_tst_27:
;;;                                 { 16 Expr l < r
;;;                                   { 17 TypeName (internal)
;;;                                     { 18 TypeSpecifier (all)
;;;                                       spec = int (80000)
;;;                                     } 18 TypeSpecifier (all)
;;;                                   } 17 TypeName (internal)
;;;                                   { 17 Expression (variable name)
;;;                                     expr_type = "identifier" (i)
;--	load_rr_var i = -14(FP), SP at -14 (16 bit)
	MOVE	0(SP), RR
;;;                                   } 17 Expression (variable name)
;--	move_rr_to_ll
	MOVE	RR, LL
;;;                                   { 17 Expression (variable name)
;;;                                     expr_type = "identifier" (field_w)
;--	load_rr_var field_w = 9(FP), SP at -14 (16 bit)
	MOVE	23(SP), RR
;;;                                   } 17 Expression (variable name)
;--	l < r
	SLT	LL, RR
;;;                                 } 16 Expr l < r
;--	branch_true
	JMP	RRNZ, L11_loop_27
L11_brk_28:
;;;                               } 15 for Statement
;;;                             } 14 List<for Statement>
;--	pop 0 bytes
;;;                           } 13 CompoundStatement
L11_endif_26:
;;;                         } 12 IfElseStatement
;;;                         { 12 IfElseStatement
;;;                           { 13 Expression (variable name)
;;;                             expr_type = "identifier" (sign)
;--	load_rr_var sign = 5(FP), SP at -14 (8 bit)
	MOVE	19(SP), RS
;;;                           } 13 Expression (variable name)
;--	branch_false
	JMP	RRZ, L11_endif_29
;;;                           { 13 ExpressionStatement
;;;                             { 14 Expr l(r)
;;;                               { 15 TypeName
;;;                                 { 16 TypeSpecifier (all)
;;;                                   spec = int (80000)
;;;                                 } 16 TypeSpecifier (all)
;;;                                 { 16 List<DeclItem>
;;;                                   { 17 DeclItem
;;;                                     what = DECL_NAME
;;;                                     name = putchr
;;;                                   } 17 DeclItem
;;;                                 } 16 List<DeclItem>
;;;                               } 15 TypeName
;;;                               { 15 ParameterDeclaration
;;;                                 isEllipsis = false
;;;                                 { 16 TypeName
;;;                                   { 17 TypeSpecifier (all)
;;;                                     spec = char (20000)
;;;                                   } 17 TypeSpecifier (all)
;;;                                   { 17 List<DeclItem>
;;;                                     { 18 DeclItem
;;;                                       what = DECL_NAME
;;;                                       name = c
;;;                                     } 18 DeclItem
;;;                                   } 17 List<DeclItem>
;;;                                 } 16 TypeName
;;;                               } 15 ParameterDeclaration
;;;                               { 15 Expression (variable name)
;;;                                 expr_type = "identifier" (sign)
;--	load_rr_var sign = 5(FP), SP at -14 (8 bit)
	MOVE	19(SP), RS
;;;                               } 15 Expression (variable name)
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;--	push 2 bytes
;--	call
	CALL	Cputchr
;--	pop 1 bytes
	ADD	SP, #1
;;;                             } 14 Expr l(r)
;;;                           } 13 ExpressionStatement
L11_endif_29:
;;;                         } 12 IfElseStatement
;;;                         { 12 IfElseStatement
;;;                           { 13 Expression (variable name)
;;;                             expr_type = "identifier" (alt)
;--	load_rr_var alt = 7(FP), SP at -14 (16 bit)
	MOVE	21(SP), RR
;;;                           } 13 Expression (variable name)
;--	branch_false
	JMP	RRZ, L11_endif_30
;;;                           { 13 CompoundStatement
;;;                             { 14 List<IfElseStatement>
;;;                               { 15 IfElseStatement
;;;                                 { 16 Expr l & r
;;;                                   { 17 TypeName (internal)
;;;                                     { 18 TypeSpecifier (all)
;;;                                       spec = int (80000)
;;;                                     } 18 TypeSpecifier (all)
;;;                                   } 17 TypeName (internal)
;;;                                   { 17 Expression (variable name)
;;;                                     expr_type = "identifier" (flags)
;--	load_rr_var flags = 4(FP), SP at -14 (8 bit)
	MOVE	18(SP), RS
;;;                                   } 17 Expression (variable name)
;--	l & r
	AND	RR, #0x0001
;;;                                 } 16 Expr l & r
;--	branch_false
	JMP	RRZ, L11_endif_31
;;;                                 { 16 ExpressionStatement
;;;                                   { 17 Expr l(r)
;;;                                     { 18 TypeName
;;;                                       { 19 TypeSpecifier (all)
;;;                                         spec = void (10000)
;;;                                       } 19 TypeSpecifier (all)
;;;                                       { 19 List<DeclItem>
;;;                                         { 20 DeclItem
;;;                                           what = DECL_NAME
;;;                                           name = print_string
;;;                                         } 20 DeclItem
;;;                                       } 19 List<DeclItem>
;;;                                     } 18 TypeName
;;;                                     { 18 ParameterDeclaration
;;;                                       isEllipsis = false
;;;                                       { 19 TypeName
;;;                                         { 20 TypeSpecifier (all)
;;;                                           spec = const char (20100)
;;;                                         } 20 TypeSpecifier (all)
;;;                                         { 20 List<DeclItem>
;;;                                           { 21 DeclItem
;;;                                             what = DECL_POINTER
;;;                                             { 22 List<Ptr>
;;;                                               { 23 Ptr
;;;                                               } 23 Ptr
;;;                                             } 22 List<Ptr>
;;;                                           } 21 DeclItem
;;;                                           { 21 DeclItem
;;;                                             what = DECL_NAME
;;;                                             name = buffer
;;;                                           } 21 DeclItem
;;;                                         } 20 List<DeclItem>
;;;                                       } 19 TypeName
;;;                                     } 18 ParameterDeclaration
;;;                                     { 18 Expression (variable name)
;;;                                       expr_type = "identifier" (alt)
;--	load_rr_var alt = 7(FP), SP at -14 (16 bit)
	MOVE	21(SP), RR
;;;                                     } 18 Expression (variable name)
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;--	push 0 bytes
;--	call
	CALL	Cprint_string
;--	pop 2 bytes
	ADD	SP, #2
;;;                                   } 17 Expr l(r)
;;;                                 } 16 ExpressionStatement
L11_endif_31:
;;;                               } 15 IfElseStatement
;;;                             } 14 List<IfElseStatement>
;--	pop 0 bytes
;;;                           } 13 CompoundStatement
L11_endif_30:
;;;                         } 12 IfElseStatement
;;;                         { 12 for Statement
;;;                           { 13 ExpressionStatement
;;;                             { 14 Expr l = r
;;;                               { 15 TypeName
;;;                                 { 16 TypeSpecifier (all)
;;;                                   spec = int (80000)
;;;                                 } 16 TypeSpecifier (all)
;;;                                 { 16 List<DeclItem>
;;;                                   { 17 DeclItem
;;;                                     what = DECL_NAME
;;;                                     name = i
;;;                                   } 17 DeclItem
;;;                                 } 16 List<DeclItem>
;;;                               } 15 TypeName
;;;                               { 15 NumericExpression (constant 0 = 0x0)
;--	load_rr_constant
	MOVE	#0x0000, RR
;;;                               } 15 NumericExpression (constant 0 = 0x0)
;--	store_rr_var i = -14(FP), SP at -14
	MOVE	RR, 0(SP)
;;;                             } 14 Expr l = r
;;;                           } 13 ExpressionStatement
;--	branch
	JMP	L11_tst_32
L11_loop_32:
;;;                           { 13 ExpressionStatement
;;;                             { 14 Expr l(r)
;;;                               { 15 TypeName
;;;                                 { 16 TypeSpecifier (all)
;;;                                   spec = int (80000)
;;;                                 } 16 TypeSpecifier (all)
;;;                                 { 16 List<DeclItem>
;;;                                   { 17 DeclItem
;;;                                     what = DECL_NAME
;;;                                     name = putchr
;;;                                   } 17 DeclItem
;;;                                 } 16 List<DeclItem>
;;;                               } 15 TypeName
;;;                               { 15 ParameterDeclaration
;;;                                 isEllipsis = false
;;;                                 { 16 TypeName
;;;                                   { 17 TypeSpecifier (all)
;;;                                     spec = char (20000)
;;;                                   } 17 TypeSpecifier (all)
;;;                                   { 17 List<DeclItem>
;;;                                     { 18 DeclItem
;;;                                       what = DECL_NAME
;;;                                       name = c
;;;                                     } 18 DeclItem
;;;                                   } 17 List<DeclItem>
;;;                                 } 16 TypeName
;;;                               } 15 ParameterDeclaration
;;;                               { 15 Expression (variable name)
;;;                                 expr_type = "identifier" (min_p)
;--	load_rr_var min_p = 13(FP), SP at -14 (8 bit)
	MOVE	27(SP), RS
;;;                               } 15 Expression (variable name)
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;--	push 2 bytes
;--	call
	CALL	Cputchr
;--	pop 1 bytes
	ADD	SP, #1
;;;                             } 14 Expr l(r)
;;;                           } 13 ExpressionStatement
L11_cont_32:
;;;                           { 13 Expr l - r
;;;                             { 14 Expr ++r
;;;                               { 15 Expression (variable name)
;;;                                 expr_type = "identifier" (i)
;--	load_rr_var i = -14(FP), SP at -14 (16 bit)
	MOVE	0(SP), RR
;;;                               } 15 Expression (variable name)
;--	++
	ADD	RR, #0x0001
;--	store_rr_var i = -14(FP), SP at -14
	MOVE	RR, 0(SP)
;;;                             } 14 Expr ++r
;--	l - r
	SUB	RR, #0x0001
;;;                           } 13 Expr l - r
L11_tst_32:
;;;                           { 13 Expr l < r
;;;                             { 14 TypeName (internal)
;;;                               { 15 TypeSpecifier (all)
;;;                                 spec = int (80000)
;;;                               } 15 TypeSpecifier (all)
;;;                             } 14 TypeName (internal)
;;;                             { 14 Expression (variable name)
;;;                               expr_type = "identifier" (i)
;--	load_rr_var i = -14(FP), SP at -14 (16 bit)
	MOVE	0(SP), RR
;;;                             } 14 Expression (variable name)
;--	move_rr_to_ll
	MOVE	RR, LL
;;;                             { 14 Expression (variable name)
;;;                               expr_type = "identifier" (padlen)
;--	load_rr_var padlen = -8(FP), SP at -14 (16 bit)
	MOVE	6(SP), RR
;;;                             } 14 Expression (variable name)
;--	l < r
	SLT	LL, RR
;;;                           } 13 Expr l < r
;--	branch_true
	JMP	RRNZ, L11_loop_32
L11_brk_33:
;;;                         } 12 for Statement
;;;                         { 12 ExpressionStatement
;;;                           { 13 Expr l(r)
;;;                             { 14 TypeName
;;;                               { 15 TypeSpecifier (all)
;;;                                 spec = void (10000)
;;;                               } 15 TypeSpecifier (all)
;;;                               { 15 List<DeclItem>
;;;                                 { 16 DeclItem
;;;                                   what = DECL_NAME
;;;                                   name = print_string
;;;                                 } 16 DeclItem
;;;                               } 15 List<DeclItem>
;;;                             } 14 TypeName
;;;                             { 14 ParameterDeclaration
;;;                               isEllipsis = false
;;;                               { 15 TypeName
;;;                                 { 16 TypeSpecifier (all)
;;;                                   spec = const char (20100)
;;;                                 } 16 TypeSpecifier (all)
;;;                                 { 16 List<DeclItem>
;;;                                   { 17 DeclItem
;;;                                     what = DECL_POINTER
;;;                                     { 18 List<Ptr>
;;;                                       { 19 Ptr
;;;                                       } 19 Ptr
;;;                                     } 18 List<Ptr>
;;;                                   } 17 DeclItem
;;;                                   { 17 DeclItem
;;;                                     what = DECL_NAME
;;;                                     name = buffer
;;;                                   } 17 DeclItem
;;;                                 } 16 List<DeclItem>
;;;                               } 15 TypeName
;;;                             } 14 ParameterDeclaration
;;;                             { 14 Expression (variable name)
;;;                               expr_type = "identifier" (buffer)
;--	load_rr_var buffer = 2(FP), SP at -14 (16 bit)
	MOVE	16(SP), RR
;;;                             } 14 Expression (variable name)
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;--	push 0 bytes
;--	call
	CALL	Cprint_string
;--	pop 2 bytes
	ADD	SP, #2
;;;                           } 13 Expr l(r)
;;;                         } 12 ExpressionStatement
;;;                         { 12 IfElseStatement
;;;                           { 13 Expr l & r
;;;                             { 14 TypeName (internal)
;;;                               { 15 TypeSpecifier (all)
;;;                                 spec = int (80000)
;;;                               } 15 TypeSpecifier (all)
;;;                             } 14 TypeName (internal)
;;;                             { 14 Expression (variable name)
;;;                               expr_type = "identifier" (flags)
;--	load_rr_var flags = 4(FP), SP at -14 (8 bit)
	MOVE	18(SP), RS
;;;                             } 14 Expression (variable name)
;--	l & r
	AND	RR, #0x0002
;;;                           } 13 Expr l & r
;--	branch_false
	JMP	RRZ, L11_endif_34
;;;                           { 13 CompoundStatement
;;;                             { 14 List<for Statement>
;;;                               { 15 for Statement
;;;                                 { 16 ExpressionStatement
;;;                                   { 17 Expr l = r
;;;                                     { 18 TypeName
;;;                                       { 19 TypeSpecifier (all)
;;;                                         spec = int (80000)
;;;                                       } 19 TypeSpecifier (all)
;;;                                       { 19 List<DeclItem>
;;;                                         { 20 DeclItem
;;;                                           what = DECL_NAME
;;;                                           name = i
;;;                                         } 20 DeclItem
;;;                                       } 19 List<DeclItem>
;;;                                     } 18 TypeName
;;;                                     { 18 Expression (variable name)
;;;                                       expr_type = "identifier" (len)
;--	load_rr_var len = -12(FP), SP at -14 (16 bit)
	MOVE	2(SP), RR
;;;                                     } 18 Expression (variable name)
;--	store_rr_var i = -14(FP), SP at -14
	MOVE	RR, 0(SP)
;;;                                   } 17 Expr l = r
;;;                                 } 16 ExpressionStatement
;--	branch
	JMP	L11_tst_35
L11_loop_35:
;;;                                 { 16 ExpressionStatement
;;;                                   { 17 Expr l(r)
;;;                                     { 18 TypeName
;;;                                       { 19 TypeSpecifier (all)
;;;                                         spec = int (80000)
;;;                                       } 19 TypeSpecifier (all)
;;;                                       { 19 List<DeclItem>
;;;                                         { 20 DeclItem
;;;                                           what = DECL_NAME
;;;                                           name = putchr
;;;                                         } 20 DeclItem
;;;                                       } 19 List<DeclItem>
;;;                                     } 18 TypeName
;;;                                     { 18 ParameterDeclaration
;;;                                       isEllipsis = false
;;;                                       { 19 TypeName
;;;                                         { 20 TypeSpecifier (all)
;;;                                           spec = char (20000)
;;;                                         } 20 TypeSpecifier (all)
;;;                                         { 20 List<DeclItem>
;;;                                           { 21 DeclItem
;;;                                             what = DECL_NAME
;;;                                             name = c
;;;                                           } 21 DeclItem
;;;                                         } 20 List<DeclItem>
;;;                                       } 19 TypeName
;;;                                     } 18 ParameterDeclaration
;;;                                     { 18 Expression (variable name)
;;;                                       expr_type = "identifier" (pad)
;--	load_rr_var pad = 6(FP), SP at -14 (8 bit)
	MOVE	20(SP), RS
;;;                                     } 18 Expression (variable name)
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;--	push 2 bytes
;--	call
	CALL	Cputchr
;--	pop 1 bytes
	ADD	SP, #1
;;;                                   } 17 Expr l(r)
;;;                                 } 16 ExpressionStatement
L11_cont_35:
;;;                                 { 16 Expr l - r
;;;                                   { 17 Expr ++r
;;;                                     { 18 Expression (variable name)
;;;                                       expr_type = "identifier" (i)
;--	load_rr_var i = -14(FP), SP at -14 (16 bit)
	MOVE	0(SP), RR
;;;                                     } 18 Expression (variable name)
;--	++
	ADD	RR, #0x0001
;--	store_rr_var i = -14(FP), SP at -14
	MOVE	RR, 0(SP)
;;;                                   } 17 Expr ++r
;--	l - r
	SUB	RR, #0x0001
;;;                                 } 16 Expr l - r
L11_tst_35:
;;;                                 { 16 Expr l < r
;;;                                   { 17 TypeName (internal)
;;;                                     { 18 TypeSpecifier (all)
;;;                                       spec = int (80000)
;;;                                     } 18 TypeSpecifier (all)
;;;                                   } 17 TypeName (internal)
;;;                                   { 17 Expression (variable name)
;;;                                     expr_type = "identifier" (i)
;--	load_rr_var i = -14(FP), SP at -14 (16 bit)
	MOVE	0(SP), RR
;;;                                   } 17 Expression (variable name)
;--	move_rr_to_ll
	MOVE	RR, LL
;;;                                   { 17 Expression (variable name)
;;;                                     expr_type = "identifier" (field_w)
;--	load_rr_var field_w = 9(FP), SP at -14 (16 bit)
	MOVE	23(SP), RR
;;;                                   } 17 Expression (variable name)
;--	l < r
	SLT	LL, RR
;;;                                 } 16 Expr l < r
;--	branch_true
	JMP	RRNZ, L11_loop_35
L11_brk_36:
;;;                               } 15 for Statement
;;;                             } 14 List<for Statement>
;--	pop 0 bytes
;;;                           } 13 CompoundStatement
L11_endif_34:
;;;                         } 12 IfElseStatement
;;;                         { 12 return Statement
;;;                           { 13 Expression (variable name)
;;;                             expr_type = "identifier" (len)
;--	load_rr_var len = -12(FP), SP at -14 (16 bit)
	MOVE	2(SP), RR
;;;                           } 13 Expression (variable name)
;--	ret
	ADD	SP, #14
	RET
;;;                         } 12 return Statement
;;;                       } 11 List<IfElseStatement>
;--	pop 14 bytes
	ADD	SP, #14
;;;                     } 10 CompoundStatement
;--	ret
	RET
;;; ------------------------------------;
;;;                     { 10 FunctionDefinition
;;;                       { 11 TypeName
;;;                         { 12 TypeSpecifier (all)
;;;                           spec = int (80000)
;;;                         } 12 TypeSpecifier (all)
;;;                         { 12 List<DeclItem>
;;;                           { 13 DeclItem
;;;                             what = DECL_NAME
;;;                             name = printf
;;;                           } 13 DeclItem
;;;                         } 12 List<DeclItem>
;;;                       } 11 TypeName
;;;                       { 11 List<DeclItem>
;;;                         { 12 DeclItem
;;;                           what = DECL_NAME
;;;                           name = printf
;;;                         } 12 DeclItem
;;;                         { 12 DeclItem
;;;                           what = DECL_FUN
;;;                           { 13 List
;;;                             { 14 ParameterDeclaration
;;;                               isEllipsis = true
;;;                               { 15 TypeName
;;;                                 { 16 TypeSpecifier (all)
;;;                                   spec = const char (20100)
;;;                                 } 16 TypeSpecifier (all)
;;;                                 { 16 List<DeclItem>
;;;                                   { 17 DeclItem
;;;                                     what = DECL_POINTER
;;;                                     { 18 List<Ptr>
;;;                                       { 19 Ptr
;;;                                       } 19 Ptr
;;;                                     } 18 List<Ptr>
;;;                                   } 17 DeclItem
;;;                                   { 17 DeclItem
;;;                                     what = DECL_NAME
;;;                                     name = format
;;;                                   } 17 DeclItem
;;;                                 } 16 List<DeclItem>
;;;                               } 15 TypeName
;;;                             } 14 ParameterDeclaration
;;;                           } 13 List
;;;                         } 12 DeclItem
;;;                       } 11 List<DeclItem>
Cprintf:
;;;                       { 11 CompoundStatement
;;;                         { 12 InitDeclarator
;;;                           { 13 List<DeclItem>
;;;                             { 14 DeclItem
;;;                               what = DECL_POINTER
;;;                               { 15 List<Ptr>
;;;                                 { 16 Ptr
;;;                                 } 16 Ptr
;;;                                 { 16 Ptr
;;;                                 } 16 Ptr
;;;                               } 15 List<Ptr>
;;;                             } 14 DeclItem
;;;                             { 14 DeclItem
;;;                               what = DECL_NAME
;;;                               name = args
;;;                             } 14 DeclItem
;;;                           } 13 List<DeclItem>
;;;                           { 13 Initializer (skalar)
;;;                             { 14 Expr l + r
;;;                               { 15 Expr & r
;--	load_address format = 2(FP), SP at 0
	LEA	2(SP), RR
;;;                               } 15 Expr & r
;--	l + r
	ADD	RR, #0x0002
;;;                             } 14 Expr l + r
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                           } 13 Initializer (skalar)
;;;                         } 12 InitDeclarator
;;;                         { 12 InitDeclarator
;;;                           { 13 List<DeclItem>
;;;                             { 14 DeclItem
;;;                               what = DECL_NAME
;;;                               name = len
;;;                             } 14 DeclItem
;;;                           } 13 List<DeclItem>
;;;                           { 13 Initializer (skalar)
;--	push_zero 2 bytes
	CLRW	-(SP)
;;;                           } 13 Initializer (skalar)
;;;                         } 12 InitDeclarator
;;;                         { 12 InitDeclarator
;;;                           { 13 List<DeclItem>
;;;                             { 14 DeclItem
;;;                               what = DECL_NAME
;;;                               name = c
;;;                             } 14 DeclItem
;;;                           } 13 List<DeclItem>
;--	push_zero 1 bytes
	CLRB	-(SP)
;;;                         } 12 InitDeclarator
;;;                         { 12 InitDeclarator
;;;                           { 13 List<DeclItem>
;;;                             { 14 DeclItem
;;;                               what = DECL_NAME
;;;                               name = flags
;;;                             } 14 DeclItem
;;;                           } 13 List<DeclItem>
;--	push_zero 1 bytes
	CLRB	-(SP)
;;;                         } 12 InitDeclarator
;;;                         { 12 InitDeclarator
;;;                           { 13 List<DeclItem>
;;;                             { 14 DeclItem
;;;                               what = DECL_NAME
;;;                               name = sign
;;;                             } 14 DeclItem
;;;                           } 13 List<DeclItem>
;--	push_zero 1 bytes
	CLRB	-(SP)
;;;                         } 12 InitDeclarator
;;;                         { 12 InitDeclarator
;;;                           { 13 List<DeclItem>
;;;                             { 14 DeclItem
;;;                               what = DECL_NAME
;;;                               name = pad
;;;                             } 14 DeclItem
;;;                           } 13 List<DeclItem>
;--	push_zero 1 bytes
	CLRB	-(SP)
;;;                         } 12 InitDeclarator
;;;                         { 12 InitDeclarator
;;;                           { 13 List<DeclItem>
;;;                             { 14 DeclItem
;;;                               what = DECL_POINTER
;;;                               { 15 List<Ptr>
;;;                                 { 16 Ptr
;;;                                 } 16 Ptr
;;;                               } 15 List<Ptr>
;;;                             } 14 DeclItem
;;;                             { 14 DeclItem
;;;                               what = DECL_NAME
;;;                               name = alt
;;;                             } 14 DeclItem
;;;                           } 13 List<DeclItem>
;--	push_zero 2 bytes
	CLRW	-(SP)
;;;                         } 12 InitDeclarator
;;;                         { 12 InitDeclarator
;;;                           { 13 List<DeclItem>
;;;                             { 14 DeclItem
;;;                               what = DECL_NAME
;;;                               name = field_w
;;;                             } 14 DeclItem
;;;                           } 13 List<DeclItem>
;--	push_zero 2 bytes
	CLRW	-(SP)
;;;                         } 12 InitDeclarator
;;;                         { 12 InitDeclarator
;;;                           { 13 List<DeclItem>
;;;                             { 14 DeclItem
;;;                               what = DECL_NAME
;;;                               name = min_w
;;;                             } 14 DeclItem
;;;                           } 13 List<DeclItem>
;--	push_zero 2 bytes
	CLRW	-(SP)
;;;                         } 12 InitDeclarator
;;;                         { 12 InitDeclarator
;;;                           { 13 List<DeclItem>
;;;                             { 14 DeclItem
;;;                               what = DECL_POINTER
;;;                               { 15 List<Ptr>
;;;                                 { 16 Ptr
;;;                                 } 16 Ptr
;;;                               } 15 List<Ptr>
;;;                             } 14 DeclItem
;;;                             { 14 DeclItem
;;;                               what = DECL_NAME
;;;                               name = which_w
;;;                             } 14 DeclItem
;;;                           } 13 List<DeclItem>
;--	push_zero 2 bytes
	CLRW	-(SP)
;;;                         } 12 InitDeclarator
;;;                         { 12 InitDeclarator
;;;                           { 13 List<DeclItem>
;;;                             { 14 DeclItem
;;;                               what = DECL_NAME
;;;                               name = buffer
;;;                             } 14 DeclItem
;;;                             { 14 DeclItem
;;;                               what = DECL_ARRAY
;;;                             } 14 DeclItem
;;;                           } 13 List<DeclItem>
;--	push_zero 12 bytes
	CLRW	-(SP)
	CLRW	-(SP)
	CLRW	-(SP)
	CLRW	-(SP)
	CLRW	-(SP)
	CLRW	-(SP)
;;;                         } 12 InitDeclarator
;;;                         { 12 List<while Statement>
;;;                           { 13 while Statement
;--	branch
	JMP	L12_cont_37
L12_loop_37:
;;;                             { 14 CompoundStatement
;;;                               { 15 List<IfElseStatement>
;;;                                 { 16 IfElseStatement
;;;                                   { 17 Expr l != r
;;;                                     { 18 TypeName (internal)
;;;                                       { 19 TypeSpecifier (all)
;;;                                         spec = int (80000)
;;;                                       } 19 TypeSpecifier (all)
;;;                                     } 18 TypeName (internal)
;;;                                     { 18 Expression (variable name)
;;;                                       expr_type = "identifier" (c)
;--	load_rr_var c = -5(FP), SP at -28 (8 bit)
	MOVE	23(SP), RS
;;;                                     } 18 Expression (variable name)
;--	l != r
	SNE	RR, #0x0025
;;;                                   } 17 Expr l != r
;--	branch_false
	JMP	RRZ, L12_endif_39
;;;                                   { 17 CompoundStatement
;;;                                     { 18 List<ExpressionStatement>
;;;                                       { 19 ExpressionStatement
;;;                                         { 20 Expr l += r
;;;                                           { 21 TypeName
;;;                                             { 22 TypeSpecifier (all)
;;;                                               spec = int (80000)
;;;                                             } 22 TypeSpecifier (all)
;;;                                             { 22 List<DeclItem>
;;;                                               { 23 DeclItem
;;;                                                 what = DECL_NAME
;;;                                                 name = len
;;;                                               } 23 DeclItem
;;;                                             } 22 List<DeclItem>
;;;                                           } 21 TypeName
;;;                                           { 21 Expr l + r
;;;                                             { 22 Expr l(r)
;;;                                               { 23 TypeName
;;;                                                 { 24 TypeSpecifier (all)
;;;                                                   spec = int (80000)
;;;                                                 } 24 TypeSpecifier (all)
;;;                                                 { 24 List<DeclItem>
;;;                                                   { 25 DeclItem
;;;                                                     what = DECL_NAME
;;;                                                     name = putchr
;;;                                                   } 25 DeclItem
;;;                                                 } 24 List<DeclItem>
;;;                                               } 23 TypeName
;;;                                               { 23 ParameterDeclaration
;;;                                                 isEllipsis = false
;;;                                                 { 24 TypeName
;;;                                                   { 25 TypeSpecifier (all)
;;;                                                     spec = char (20000)
;;;                                                   } 25 TypeSpecifier (all)
;;;                                                   { 25 List<DeclItem>
;;;                                                     { 26 DeclItem
;;;                                                       what = DECL_NAME
;;;                                                       name = c
;;;                                                     } 26 DeclItem
;;;                                                   } 25 List<DeclItem>
;;;                                                 } 24 TypeName
;;;                                               } 23 ParameterDeclaration
;;;                                               { 23 Expression (variable name)
;;;                                                 expr_type = "identifier" (c)
;--	load_rr_var c = -5(FP), SP at -28 (8 bit)
	MOVE	23(SP), RS
;;;                                               } 23 Expression (variable name)
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;--	push 2 bytes
;--	call
	CALL	Cputchr
;--	pop 1 bytes
	ADD	SP, #1
;;;                                             } 22 Expr l(r)
;;;                                             { 22 Expression (variable name)
;;;                                               expr_type = "identifier" (len)
;--	load_ll_var len = -4(FP), SP at -28 (16 bit)
	MOVE	24(SP), LL
;;;                                             } 22 Expression (variable name)
;--	scale_rr *1
;--	l + r
	ADD	LL, RR
;;;                                           } 21 Expr l + r
;--	store_rr_var len = -4(FP), SP at -28
	MOVE	RR, 24(SP)
;;;                                         } 20 Expr l += r
;;;                                       } 19 ExpressionStatement
;;;                                       { 19 break/continue Statement
;--	branch
	JMP	L12_cont_37
;;;                                       } 19 break/continue Statement
;;;                                     } 18 List<ExpressionStatement>
;--	pop 0 bytes
;;;                                   } 17 CompoundStatement
L12_endif_39:
;;;                                 } 16 IfElseStatement
;;;                                 { 16 ExpressionStatement
;;;                                   { 17 Expr l = r
;;;                                     { 18 TypeName
;;;                                       { 19 TypeSpecifier (all)
;;;                                         spec = char (20000)
;;;                                       } 19 TypeSpecifier (all)
;;;                                       { 19 List<DeclItem>
;;;                                         { 20 DeclItem
;;;                                           what = DECL_NAME
;;;                                           name = flags
;;;                                         } 20 DeclItem
;;;                                       } 19 List<DeclItem>
;;;                                     } 18 TypeName
;;;                                     { 18 NumericExpression (constant 0 = 0x0)
;--	load_rr_constant
	MOVE	#0x0000, RR
;;;                                     } 18 NumericExpression (constant 0 = 0x0)
;--	store_rr_var flags = -6(FP), SP at -28
	MOVE	R, 22(SP)
;;;                                   } 17 Expr l = r
;;;                                 } 16 ExpressionStatement
;;;                                 { 16 ExpressionStatement
;;;                                   { 17 Expr l = r
;;;                                     { 18 TypeName
;;;                                       { 19 TypeSpecifier (all)
;;;                                         spec = char (20000)
;;;                                       } 19 TypeSpecifier (all)
;;;                                       { 19 List<DeclItem>
;;;                                         { 20 DeclItem
;;;                                           what = DECL_NAME
;;;                                           name = sign
;;;                                         } 20 DeclItem
;;;                                       } 19 List<DeclItem>
;;;                                     } 18 TypeName
;;;                                     { 18 NumericExpression (constant 0 = 0x0)
;--	load_rr_constant
	MOVE	#0x0000, RR
;;;                                     } 18 NumericExpression (constant 0 = 0x0)
;--	store_rr_var sign = -7(FP), SP at -28
	MOVE	R, 21(SP)
;;;                                   } 17 Expr l = r
;;;                                 } 16 ExpressionStatement
;;;                                 { 16 ExpressionStatement
;;;                                   { 17 Expr l = r
;;;                                     { 18 TypeName
;;;                                       { 19 TypeSpecifier (all)
;;;                                         spec = char (20000)
;;;                                       } 19 TypeSpecifier (all)
;;;                                       { 19 List<DeclItem>
;;;                                         { 20 DeclItem
;;;                                           what = DECL_NAME
;;;                                           name = pad
;;;                                         } 20 DeclItem
;;;                                       } 19 List<DeclItem>
;;;                                     } 18 TypeName
;;;                                     { 18 NumericExpression (constant 32 = 0x20)
;--	load_rr_constant
	MOVE	#0x0020, RR
;;;                                     } 18 NumericExpression (constant 32 = 0x20)
;--	store_rr_var pad = -8(FP), SP at -28
	MOVE	R, 20(SP)
;;;                                   } 17 Expr l = r
;;;                                 } 16 ExpressionStatement
;;;                                 { 16 ExpressionStatement
;;;                                   { 17 Expr l = r
;;;                                     { 18 TypeName
;;;                                       { 19 TypeSpecifier (all)
;;;                                         spec = int (80000)
;;;                                       } 19 TypeSpecifier (all)
;;;                                       { 19 List<DeclItem>
;;;                                         { 20 DeclItem
;;;                                           what = DECL_NAME
;;;                                           name = field_w
;;;                                         } 20 DeclItem
;;;                                       } 19 List<DeclItem>
;;;                                     } 18 TypeName
;;;                                     { 18 NumericExpression (constant 0 = 0x0)
;--	load_rr_constant
	MOVE	#0x0000, RR
;;;                                     } 18 NumericExpression (constant 0 = 0x0)
;--	store_rr_var field_w = -12(FP), SP at -28
	MOVE	RR, 16(SP)
;;;                                   } 17 Expr l = r
;;;                                 } 16 ExpressionStatement
;;;                                 { 16 ExpressionStatement
;;;                                   { 17 Expr l = r
;;;                                     { 18 TypeName
;;;                                       { 19 TypeSpecifier (all)
;;;                                         spec = int (80000)
;;;                                       } 19 TypeSpecifier (all)
;;;                                       { 19 List<DeclItem>
;;;                                         { 20 DeclItem
;;;                                           what = DECL_NAME
;;;                                           name = min_w
;;;                                         } 20 DeclItem
;;;                                       } 19 List<DeclItem>
;;;                                     } 18 TypeName
;;;                                     { 18 NumericExpression (constant 0 = 0x0)
;--	load_rr_constant
	MOVE	#0x0000, RR
;;;                                     } 18 NumericExpression (constant 0 = 0x0)
;--	store_rr_var min_w = -14(FP), SP at -28
	MOVE	RR, 14(SP)
;;;                                   } 17 Expr l = r
;;;                                 } 16 ExpressionStatement
;;;                                 { 16 ExpressionStatement
;;;                                   { 17 Expr l = r
;;;                                     { 18 TypeName
;;;                                       { 19 TypeSpecifier (all)
;;;                                         spec = unsigned int (82000)
;;;                                       } 19 TypeSpecifier (all)
;;;                                       { 19 List<DeclItem>
;;;                                         { 20 DeclItem
;;;                                           what = DECL_POINTER
;;;                                           { 21 List<Ptr>
;;;                                             { 22 Ptr
;;;                                             } 22 Ptr
;;;                                           } 21 List<Ptr>
;;;                                         } 20 DeclItem
;;;                                         { 20 DeclItem
;;;                                           what = DECL_NAME
;;;                                           name = which_w
;;;                                         } 20 DeclItem
;;;                                       } 19 List<DeclItem>
;;;                                     } 18 TypeName
;;;                                     { 18 Expr & r
;--	load_address field_w = -12(FP), SP at -28
	LEA	16(SP), RR
;;;                                     } 18 Expr & r
;--	store_rr_var which_w = -16(FP), SP at -28
	MOVE	RR, 12(SP)
;;;                                   } 17 Expr l = r
;;;                                 } 16 ExpressionStatement
;;;                                 { 16 for Statement
;;;                                   { 17 ExpressionStatement
;;;                                   } 17 ExpressionStatement
L12_loop_40:
;;;                                   { 17 CompoundStatement
;;;                                     { 18 List<SwitchStatement>
;;;                                       { 19 SwitchStatement
;;;                                         { 20 Expr l = r
;;;                                           { 21 TypeName
;;;                                             { 22 TypeSpecifier (all)
;;;                                               spec = char (20000)
;;;                                             } 22 TypeSpecifier (all)
;;;                                             { 22 List<DeclItem>
;;;                                               { 23 DeclItem
;;;                                                 what = DECL_NAME
;;;                                                 name = c
;;;                                               } 23 DeclItem
;;;                                             } 22 List<DeclItem>
;;;                                           } 21 TypeName
;;;                                           { 21 Expr * r
;;;                                             { 22 Expr l - r
;;;                                               { 23 Expr ++r
;;;                                                 { 24 Expression (variable name)
;;;                                                   expr_type = "identifier" (format)
;--	load_rr_var format = 2(FP), SP at -28 (16 bit)
	MOVE	30(SP), RR
;;;                                                 } 24 Expression (variable name)
;--	++
	ADD	RR, #0x0001
;--	store_rr_var format = 2(FP), SP at -28
	MOVE	RR, 30(SP)
;;;                                               } 23 Expr ++r
;--	l - r
	SUB	RR, #0x0001
;;;                                             } 22 Expr l - r
;--	content
	MOVE	(RR), RS
;;;                                           } 21 Expr * r
;--	store_rr_var c = -5(FP), SP at -28
	MOVE	R, 23(SP)
;;;                                         } 20 Expr l = r
;--	move_rr_to_ll
	MOVE	RR, LL
;--	branch_case (8 bit)
	SEQ	LL, #0x0058
	JMP	RRNZ, L12_case_42_0058
;--	branch_case (8 bit)
	SEQ	LL, #0x0064
	JMP	RRNZ, L12_case_42_0064
;--	branch_case (8 bit)
	SEQ	LL, #0x0073
	JMP	RRNZ, L12_case_42_0073
;--	branch_case (8 bit)
	SEQ	LL, #0x0075
	JMP	RRNZ, L12_case_42_0075
;--	branch_case (8 bit)
	SEQ	LL, #0x0078
	JMP	RRNZ, L12_case_42_0078
;--	branch_case (8 bit)
	SEQ	LL, #0x0063
	JMP	RRNZ, L12_case_42_0063
;--	branch_case (8 bit)
	SEQ	LL, #0x0023
	JMP	RRNZ, L12_case_42_0023
;--	branch_case (8 bit)
	SEQ	LL, #0x002D
	JMP	RRNZ, L12_case_42_002D
;--	branch_case (8 bit)
	SEQ	LL, #0x0020
	JMP	RRNZ, L12_case_42_0020
;--	branch_case (8 bit)
	SEQ	LL, #0x002B
	JMP	RRNZ, L12_case_42_002B
;--	branch_case (8 bit)
	SEQ	LL, #0x002E
	JMP	RRNZ, L12_case_42_002E
;--	branch_case (8 bit)
	SEQ	LL, #0x0030
	JMP	RRNZ, L12_case_42_0030
;--	branch_case (8 bit)
	SEQ	LL, #0x0031
	JMP	RRNZ, L12_case_42_0031
;--	branch_case (8 bit)
	SEQ	LL, #0x0032
	JMP	RRNZ, L12_case_42_0032
;--	branch_case (8 bit)
	SEQ	LL, #0x0033
	JMP	RRNZ, L12_case_42_0033
;--	branch_case (8 bit)
	SEQ	LL, #0x0034
	JMP	RRNZ, L12_case_42_0034
;--	branch_case (8 bit)
	SEQ	LL, #0x0035
	JMP	RRNZ, L12_case_42_0035
;--	branch_case (8 bit)
	SEQ	LL, #0x0036
	JMP	RRNZ, L12_case_42_0036
;--	branch_case (8 bit)
	SEQ	LL, #0x0037
	JMP	RRNZ, L12_case_42_0037
;--	branch_case (8 bit)
	SEQ	LL, #0x0038
	JMP	RRNZ, L12_case_42_0038
;--	branch_case (8 bit)
	SEQ	LL, #0x0039
	JMP	RRNZ, L12_case_42_0039
;--	branch_case (8 bit)
	SEQ	LL, #0x002A
	JMP	RRNZ, L12_case_42_002A
;--	branch_case (8 bit)
	SEQ	LL, #0x0000
	JMP	RRNZ, L12_case_42_0000
;--	branch
	JMP	L12_deflt_42
;;;                                         { 20 CompoundStatement
;;;                                           { 21 List<case Statement>
;;;                                             { 22 case Statement
L12_case_42_0058:
;;;                                               { 23 ExpressionStatement
;;;                                                 { 24 Expr l(r)
;;;                                                   { 25 TypeName
;;;                                                     { 26 TypeSpecifier (all)
;;;                                                       spec = void (10000)
;;;                                                     } 26 TypeSpecifier (all)
;;;                                                     { 26 List<DeclItem>
;;;                                                       { 27 DeclItem
;;;                                                         what = DECL_NAME
;;;                                                         name = print_hex
;;;                                                       } 27 DeclItem
;;;                                                     } 26 List<DeclItem>
;;;                                                   } 25 TypeName
;;;                                                   { 25 Expr (l , r)
;;;                                                     { 26 ParameterDeclaration
;;;                                                       isEllipsis = false
;;;                                                       { 27 TypeName
;;;                                                         { 28 TypeSpecifier (all)
;;;                                                           spec = const char (20100)
;;;                                                         } 28 TypeSpecifier (all)
;;;                                                         { 28 List<DeclItem>
;;;                                                           { 29 DeclItem
;;;                                                             what = DECL_POINTER
;;;                                                             { 30 List<Ptr>
;;;                                                               { 31 Ptr
;;;                                                               } 31 Ptr
;;;                                                             } 30 List<Ptr>
;;;                                                           } 29 DeclItem
;;;                                                           { 29 DeclItem
;;;                                                             what = DECL_NAME
;;;                                                             name = hex
;;;                                                           } 29 DeclItem
;;;                                                         } 28 List<DeclItem>
;;;                                                       } 27 TypeName
;;;                                                     } 26 ParameterDeclaration
;;;                                                     { 26 StringExpression
;--	load_rr_string
	MOVE	#Cstr_19, RR
;;;                                                     } 26 StringExpression
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                                     { 26 Expr (l , r)
;;;                                                       { 27 ParameterDeclaration
;;;                                                         isEllipsis = false
;;;                                                         { 28 TypeName
;;;                                                           { 29 TypeSpecifier (all)
;;;                                                             spec = unsigned int (82000)
;;;                                                           } 29 TypeSpecifier (all)
;;;                                                           { 29 List<DeclItem>
;;;                                                             { 30 DeclItem
;;;                                                               what = DECL_NAME
;;;                                                               name = value
;;;                                                             } 30 DeclItem
;;;                                                           } 29 List<DeclItem>
;;;                                                         } 28 TypeName
;;;                                                       } 27 ParameterDeclaration
;;;                                                       { 27 Expression (cast)r
;;;                                                         { 28 Expr * r
;;;                                                           { 29 Expr l - r
;;;                                                             { 30 Expr ++r
;;;                                                               { 31 Expression (variable name)
;;;                                                                 expr_type = "identifier" (args)
;--	load_rr_var args = -2(FP), SP at -30 (16 bit)
	MOVE	28(SP), RR
;;;                                                               } 31 Expression (variable name)
;--	++
	ADD	RR, #0x0002
;--	store_rr_var args = -2(FP), SP at -30
	MOVE	RR, 28(SP)
;;;                                                             } 30 Expr ++r
;--	l - r
	SUB	RR, #0x0002
;;;                                                           } 29 Expr l - r
;--	content
	MOVE	(RR), RR
;;;                                                         } 28 Expr * r
;;;                                                       } 27 Expression (cast)r
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                                       { 27 ParameterDeclaration
;;;                                                         isEllipsis = false
;;;                                                         { 28 TypeName
;;;                                                           { 29 TypeSpecifier (all)
;;;                                                             spec = char (20000)
;;;                                                           } 29 TypeSpecifier (all)
;;;                                                           { 29 List<DeclItem>
;;;                                                             { 30 DeclItem
;;;                                                               what = DECL_POINTER
;;;                                                               { 31 List<Ptr>
;;;                                                                 { 32 Ptr
;;;                                                                 } 32 Ptr
;;;                                                               } 31 List<Ptr>
;;;                                                             } 30 DeclItem
;;;                                                             { 30 DeclItem
;;;                                                               what = DECL_NAME
;;;                                                               name = dest
;;;                                                             } 30 DeclItem
;;;                                                           } 29 List<DeclItem>
;;;                                                         } 28 TypeName
;;;                                                       } 27 ParameterDeclaration
;--	load_address buffer = -28(FP), SP at -32
	LEA	4(SP), RR
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                                     } 26 Expr (l , r)
;;;                                                   } 25 Expr (l , r)
;--	push 0 bytes
;--	call
	CALL	Cprint_hex
;--	pop 6 bytes
	ADD	SP, #6
;;;                                                 } 24 Expr l(r)
;;;                                               } 23 ExpressionStatement
;;;                                             } 22 case Statement
;;;                                             { 22 ExpressionStatement
;;;                                               { 23 Expr l += r
;;;                                                 { 24 TypeName
;;;                                                   { 25 TypeSpecifier (all)
;;;                                                     spec = int (80000)
;;;                                                   } 25 TypeSpecifier (all)
;;;                                                   { 25 List<DeclItem>
;;;                                                     { 26 DeclItem
;;;                                                       what = DECL_NAME
;;;                                                       name = len
;;;                                                     } 26 DeclItem
;;;                                                   } 25 List<DeclItem>
;;;                                                 } 24 TypeName
;;;                                                 { 24 Expr l + r
;;;                                                   { 25 Expr l(r)
;;;                                                     { 26 TypeName
;;;                                                       { 27 TypeSpecifier (all)
;;;                                                         spec = int (80000)
;;;                                                       } 27 TypeSpecifier (all)
;;;                                                       { 27 List<DeclItem>
;;;                                                         { 28 DeclItem
;;;                                                           what = DECL_NAME
;;;                                                           name = print_item
;;;                                                         } 28 DeclItem
;;;                                                       } 27 List<DeclItem>
;;;                                                     } 26 TypeName
;;;                                                     { 26 Expr (l , r)
;;;                                                       { 27 ParameterDeclaration
;;;                                                         isEllipsis = false
;;;                                                         { 28 TypeName
;;;                                                           { 29 TypeSpecifier (all)
;;;                                                             spec = char (20000)
;;;                                                           } 29 TypeSpecifier (all)
;;;                                                           { 29 List<DeclItem>
;;;                                                             { 30 DeclItem
;;;                                                               what = DECL_NAME
;;;                                                               name = min_p
;;;                                                             } 30 DeclItem
;;;                                                           } 29 List<DeclItem>
;;;                                                         } 28 TypeName
;;;                                                       } 27 ParameterDeclaration
;;;                                                       { 27 NumericExpression (constant 48 = 0x30)
;--	load_rr_constant
	MOVE	#0x0030, RR
;;;                                                       } 27 NumericExpression (constant 48 = 0x30)
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;;;                                                       { 27 Expr (l , r)
;;;                                                         { 28 ParameterDeclaration
;;;                                                           isEllipsis = false
;;;                                                           { 29 TypeName
;;;                                                             { 30 TypeSpecifier (all)
;;;                                                               spec = int (80000)
;;;                                                             } 30 TypeSpecifier (all)
;;;                                                             { 30 List<DeclItem>
;;;                                                               { 31 DeclItem
;;;                                                                 what = DECL_NAME
;;;                                                                 name = min_w
;;;                                                               } 31 DeclItem
;;;                                                             } 30 List<DeclItem>
;;;                                                           } 29 TypeName
;;;                                                         } 28 ParameterDeclaration
;;;                                                         { 28 Expression (variable name)
;;;                                                           expr_type = "identifier" (min_w)
;--	load_rr_var min_w = -14(FP), SP at -29 (16 bit)
	MOVE	15(SP), RR
;;;                                                         } 28 Expression (variable name)
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                                         { 28 Expr (l , r)
;;;                                                           { 29 ParameterDeclaration
;;;                                                             isEllipsis = false
;;;                                                             { 30 TypeName
;;;                                                               { 31 TypeSpecifier (all)
;;;                                                                 spec = int (80000)
;;;                                                               } 31 TypeSpecifier (all)
;;;                                                               { 31 List<DeclItem>
;;;                                                                 { 32 DeclItem
;;;                                                                   what = DECL_NAME
;;;                                                                   name = field_w
;;;                                                                 } 32 DeclItem
;;;                                                               } 31 List<DeclItem>
;;;                                                             } 30 TypeName
;;;                                                           } 29 ParameterDeclaration
;;;                                                           { 29 Expression (variable name)
;;;                                                             expr_type = "identifier" (field_w)
;--	load_rr_var field_w = -12(FP), SP at -31 (16 bit)
	MOVE	19(SP), RR
;;;                                                           } 29 Expression (variable name)
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                                           { 29 Expr (l , r)
;;;                                                             { 30 ParameterDeclaration
;;;                                                               isEllipsis = false
;;;                                                               { 31 TypeName
;;;                                                                 { 32 TypeSpecifier (all)
;;;                                                                   spec = const char (20100)
;;;                                                                 } 32 TypeSpecifier (all)
;;;                                                                 { 32 List<DeclItem>
;;;                                                                   { 33 DeclItem
;;;                                                                     what = DECL_POINTER
;;;                                                                     { 34 List<Ptr>
;;;                                                                       { 35 Ptr
;;;                                                                       } 35 Ptr
;;;                                                                     } 34 List<Ptr>
;;;                                                                   } 33 DeclItem
;;;                                                                   { 33 DeclItem
;;;                                                                     what = DECL_NAME
;;;                                                                     name = alt
;;;                                                                   } 33 DeclItem
;;;                                                                 } 32 List<DeclItem>
;;;                                                               } 31 TypeName
;;;                                                             } 30 ParameterDeclaration
;;;                                                             { 30 StringExpression
;--	load_rr_string
	MOVE	#Cstr_20, RR
;;;                                                             } 30 StringExpression
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                                             { 30 Expr (l , r)
;;;                                                               { 31 ParameterDeclaration
;;;                                                                 isEllipsis = false
;;;                                                                 { 32 TypeName
;;;                                                                   { 33 TypeSpecifier (all)
;;;                                                                     spec = char (20000)
;;;                                                                   } 33 TypeSpecifier (all)
;;;                                                                   { 33 List<DeclItem>
;;;                                                                     { 34 DeclItem
;;;                                                                       what = DECL_NAME
;;;                                                                       name = pad
;;;                                                                     } 34 DeclItem
;;;                                                                   } 33 List<DeclItem>
;;;                                                                 } 32 TypeName
;;;                                                               } 31 ParameterDeclaration
;;;                                                               { 31 Expression (variable name)
;;;                                                                 expr_type = "identifier" (pad)
;--	load_rr_var pad = -8(FP), SP at -35 (8 bit)
	MOVE	27(SP), RS
;;;                                                               } 31 Expression (variable name)
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;;;                                                               { 31 Expr (l , r)
;;;                                                                 { 32 ParameterDeclaration
;;;                                                                   isEllipsis = false
;;;                                                                   { 33 TypeName
;;;                                                                     { 34 TypeSpecifier (all)
;;;                                                                       spec = char (20000)
;;;                                                                     } 34 TypeSpecifier (all)
;;;                                                                     { 34 List<DeclItem>
;;;                                                                       { 35 DeclItem
;;;                                                                         what = DECL_NAME
;;;                                                                         name = sign
;;;                                                                       } 35 DeclItem
;;;                                                                     } 34 List<DeclItem>
;;;                                                                   } 33 TypeName
;;;                                                                 } 32 ParameterDeclaration
;;;                                                                 { 32 Expression (variable name)
;;;                                                                   expr_type = "identifier" (sign)
;--	load_rr_var sign = -7(FP), SP at -36 (8 bit)
	MOVE	29(SP), RS
;;;                                                                 } 32 Expression (variable name)
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;;;                                                                 { 32 Expr (l , r)
;;;                                                                   { 33 ParameterDeclaration
;;;                                                                     isEllipsis = false
;;;                                                                     { 34 TypeName
;;;                                                                       { 35 TypeSpecifier (all)
;;;                                                                         spec = char (20000)
;;;                                                                       } 35 TypeSpecifier (all)
;;;                                                                       { 35 List<DeclItem>
;;;                                                                         { 36 DeclItem
;;;                                                                           what = DECL_NAME
;;;                                                                           name = flags
;;;                                                                         } 36 DeclItem
;;;                                                                       } 35 List<DeclItem>
;;;                                                                     } 34 TypeName
;;;                                                                   } 33 ParameterDeclaration
;;;                                                                   { 33 Expression (variable name)
;;;                                                                     expr_type = "identifier" (flags)
;--	load_rr_var flags = -6(FP), SP at -37 (8 bit)
	MOVE	31(SP), RS
;;;                                                                   } 33 Expression (variable name)
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;;;                                                                   { 33 ParameterDeclaration
;;;                                                                     isEllipsis = false
;;;                                                                     { 34 TypeName
;;;                                                                       { 35 TypeSpecifier (all)
;;;                                                                         spec = const char (20100)
;;;                                                                       } 35 TypeSpecifier (all)
;;;                                                                       { 35 List<DeclItem>
;;;                                                                         { 36 DeclItem
;;;                                                                           what = DECL_POINTER
;;;                                                                           { 37 List<Ptr>
;;;                                                                             { 38 Ptr
;;;                                                                             } 38 Ptr
;;;                                                                           } 37 List<Ptr>
;;;                                                                         } 36 DeclItem
;;;                                                                         { 36 DeclItem
;;;                                                                           what = DECL_NAME
;;;                                                                           name = buffer
;;;                                                                         } 36 DeclItem
;;;                                                                       } 35 List<DeclItem>
;;;                                                                     } 34 TypeName
;;;                                                                   } 33 ParameterDeclaration
;--	load_address buffer = -28(FP), SP at -38
	LEA	10(SP), RR
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                                                 } 32 Expr (l , r)
;;;                                                               } 31 Expr (l , r)
;;;                                                             } 30 Expr (l , r)
;;;                                                           } 29 Expr (l , r)
;;;                                                         } 28 Expr (l , r)
;;;                                                       } 27 Expr (l , r)
;;;                                                     } 26 Expr (l , r)
;--	push 2 bytes
;--	call
	CALL	Cprint_item
;--	pop 12 bytes
	ADD	SP, #12
;;;                                                   } 25 Expr l(r)
;;;                                                   { 25 Expression (variable name)
;;;                                                     expr_type = "identifier" (len)
;--	load_ll_var len = -4(FP), SP at -28 (16 bit)
	MOVE	24(SP), LL
;;;                                                   } 25 Expression (variable name)
;--	scale_rr *1
;--	l + r
	ADD	LL, RR
;;;                                                 } 24 Expr l + r
;--	store_rr_var len = -4(FP), SP at -28
	MOVE	RR, 24(SP)
;;;                                               } 23 Expr l += r
;;;                                             } 22 ExpressionStatement
;;;                                             { 22 break/continue Statement
;--	branch
	JMP	L12_brk_42
;;;                                             } 22 break/continue Statement
;;;                                             { 22 case Statement
L12_case_42_0064:
;;;                                               { 23 IfElseStatement
;;;                                                 { 24 Expr l < r
;;;                                                   { 25 TypeName (internal)
;;;                                                     { 26 TypeSpecifier (all)
;;;                                                       spec = int (80000)
;;;                                                     } 26 TypeSpecifier (all)
;;;                                                   } 25 TypeName (internal)
;;;                                                   { 25 Expression (cast)r
;;;                                                     { 26 Expr * r
;;;                                                       { 27 Expression (variable name)
;;;                                                         expr_type = "identifier" (args)
;--	load_rr_var args = -2(FP), SP at -28 (16 bit)
	MOVE	26(SP), RR
;;;                                                       } 27 Expression (variable name)
;--	content
	MOVE	(RR), RR
;;;                                                     } 26 Expr * r
;;;                                                   } 25 Expression (cast)r
;--	l < r
	SLT	RR, #0x0000
;;;                                                 } 24 Expr l < r
;--	branch_false
	JMP	RRZ, L12_endif_43
;;;                                                 { 24 CompoundStatement
;;;                                                   { 25 List<ExpressionStatement>
;;;                                                     { 26 ExpressionStatement
;;;                                                       { 27 Expr l = r
;;;                                                         { 28 TypeName
;;;                                                           { 29 TypeSpecifier (all)
;;;                                                             spec = char (20000)
;;;                                                           } 29 TypeSpecifier (all)
;;;                                                           { 29 List<DeclItem>
;;;                                                             { 30 DeclItem
;;;                                                               what = DECL_NAME
;;;                                                               name = sign
;;;                                                             } 30 DeclItem
;;;                                                           } 29 List<DeclItem>
;;;                                                         } 28 TypeName
;;;                                                         { 28 NumericExpression (constant 45 = 0x2D)
;--	load_rr_constant
	MOVE	#0x002D, RR
;;;                                                         } 28 NumericExpression (constant 45 = 0x2D)
;--	store_rr_var sign = -7(FP), SP at -28
	MOVE	R, 21(SP)
;;;                                                       } 27 Expr l = r
;;;                                                     } 26 ExpressionStatement
;;;                                                     { 26 ExpressionStatement
;;;                                                       { 27 Expr l = r
;;;                                                         { 28 TypeName
;;;                                                           { 29 TypeSpecifier (all)
;;;                                                             spec = const char (20100)
;;;                                                           } 29 TypeSpecifier (all)
;;;                                                           { 29 List<DeclItem>
;;;                                                             { 30 DeclItem
;;;                                                               what = DECL_POINTER
;;;                                                               { 31 List<Ptr>
;;;                                                                 { 32 Ptr
;;;                                                                 } 32 Ptr
;;;                                                               } 31 List<Ptr>
;;;                                                             } 30 DeclItem
;;;                                                             { 30 DeclItem
;;;                                                               what = DECL_NAME
;;;                                                               name = args
;;;                                                             } 30 DeclItem
;;;                                                           } 29 List<DeclItem>
;;;                                                         } 28 TypeName
;;;                                                         { 28 Expression (cast)r
;;;                                                           { 29 Expr - r
;;;                                                             { 30 Expression (cast)r
;;;                                                               { 31 Expr * r
;;;                                                                 { 32 Expression (variable name)
;;;                                                                   expr_type = "identifier" (args)
;--	load_rr_var args = -2(FP), SP at -28 (16 bit)
	MOVE	26(SP), RR
;;;                                                                 } 32 Expression (variable name)
;--	content
	MOVE	(RR), RR
;;;                                                               } 31 Expr * r
;;;                                                             } 30 Expression (cast)r
;--	16 bit - r
	NEG	RR
;;;                                                           } 29 Expr - r
;;;                                                         } 28 Expression (cast)r
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                                         { 28 Expr * r
;;;                                                           { 29 Expression (variable name)
;;;                                                             expr_type = "identifier" (args)
;--	load_rr_var args = -2(FP), SP at -30 (16 bit)
	MOVE	28(SP), RR
;;;                                                           } 29 Expression (variable name)
;;;                                                         } 28 Expr * r
;--	move_rr_to_ll
	MOVE	RR, LL
;--	pop_rr (16 bit)
	MOVE	(SP)+, RR
;--	assign (16 bit)
	MOVE	RR, (LL)
;;;                                                       } 27 Expr l = r
;;;                                                     } 26 ExpressionStatement
;;;                                                   } 25 List<ExpressionStatement>
;--	pop 0 bytes
;;;                                                 } 24 CompoundStatement
L12_endif_43:
;;;                                               } 23 IfElseStatement
;;;                                             } 22 case Statement
;;;                                             { 22 ExpressionStatement
;;;                                               { 23 Expr l(r)
;;;                                                 { 24 TypeName
;;;                                                   { 25 TypeSpecifier (all)
;;;                                                     spec = void (10000)
;;;                                                   } 25 TypeSpecifier (all)
;;;                                                   { 25 List<DeclItem>
;;;                                                     { 26 DeclItem
;;;                                                       what = DECL_NAME
;;;                                                       name = print_unsigned
;;;                                                     } 26 DeclItem
;;;                                                   } 25 List<DeclItem>
;;;                                                 } 24 TypeName
;;;                                                 { 24 Expr (l , r)
;;;                                                   { 25 ParameterDeclaration
;;;                                                     isEllipsis = false
;;;                                                     { 26 TypeName
;;;                                                       { 27 TypeSpecifier (all)
;;;                                                         spec = unsigned int (82000)
;;;                                                       } 27 TypeSpecifier (all)
;;;                                                       { 27 List<DeclItem>
;;;                                                         { 28 DeclItem
;;;                                                           what = DECL_NAME
;;;                                                           name = value
;;;                                                         } 28 DeclItem
;;;                                                       } 27 List<DeclItem>
;;;                                                     } 26 TypeName
;;;                                                   } 25 ParameterDeclaration
;;;                                                   { 25 Expression (cast)r
;;;                                                     { 26 Expr * r
;;;                                                       { 27 Expr l - r
;;;                                                         { 28 Expr ++r
;;;                                                           { 29 Expression (variable name)
;;;                                                             expr_type = "identifier" (args)
;--	load_rr_var args = -2(FP), SP at -28 (16 bit)
	MOVE	26(SP), RR
;;;                                                           } 29 Expression (variable name)
;--	++
	ADD	RR, #0x0002
;--	store_rr_var args = -2(FP), SP at -28
	MOVE	RR, 26(SP)
;;;                                                         } 28 Expr ++r
;--	l - r
	SUB	RR, #0x0002
;;;                                                       } 27 Expr l - r
;--	content
	MOVE	(RR), RR
;;;                                                     } 26 Expr * r
;;;                                                   } 25 Expression (cast)r
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                                   { 25 ParameterDeclaration
;;;                                                     isEllipsis = false
;;;                                                     { 26 TypeName
;;;                                                       { 27 TypeSpecifier (all)
;;;                                                         spec = char (20000)
;;;                                                       } 27 TypeSpecifier (all)
;;;                                                       { 27 List<DeclItem>
;;;                                                         { 28 DeclItem
;;;                                                           what = DECL_POINTER
;;;                                                           { 29 List<Ptr>
;;;                                                             { 30 Ptr
;;;                                                             } 30 Ptr
;;;                                                           } 29 List<Ptr>
;;;                                                         } 28 DeclItem
;;;                                                         { 28 DeclItem
;;;                                                           what = DECL_NAME
;;;                                                           name = dest
;;;                                                         } 28 DeclItem
;;;                                                       } 27 List<DeclItem>
;;;                                                     } 26 TypeName
;;;                                                   } 25 ParameterDeclaration
;--	load_address buffer = -28(FP), SP at -30
	LEA	2(SP), RR
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                                 } 24 Expr (l , r)
;--	push 0 bytes
;--	call
	CALL	Cprint_unsigned
;--	pop 4 bytes
	ADD	SP, #4
;;;                                               } 23 Expr l(r)
;;;                                             } 22 ExpressionStatement
;;;                                             { 22 ExpressionStatement
;;;                                               { 23 Expr l += r
;;;                                                 { 24 TypeName
;;;                                                   { 25 TypeSpecifier (all)
;;;                                                     spec = int (80000)
;;;                                                   } 25 TypeSpecifier (all)
;;;                                                   { 25 List<DeclItem>
;;;                                                     { 26 DeclItem
;;;                                                       what = DECL_NAME
;;;                                                       name = len
;;;                                                     } 26 DeclItem
;;;                                                   } 25 List<DeclItem>
;;;                                                 } 24 TypeName
;;;                                                 { 24 Expr l + r
;;;                                                   { 25 Expr l(r)
;;;                                                     { 26 TypeName
;;;                                                       { 27 TypeSpecifier (all)
;;;                                                         spec = int (80000)
;;;                                                       } 27 TypeSpecifier (all)
;;;                                                       { 27 List<DeclItem>
;;;                                                         { 28 DeclItem
;;;                                                           what = DECL_NAME
;;;                                                           name = print_item
;;;                                                         } 28 DeclItem
;;;                                                       } 27 List<DeclItem>
;;;                                                     } 26 TypeName
;;;                                                     { 26 Expr (l , r)
;;;                                                       { 27 ParameterDeclaration
;;;                                                         isEllipsis = false
;;;                                                         { 28 TypeName
;;;                                                           { 29 TypeSpecifier (all)
;;;                                                             spec = char (20000)
;;;                                                           } 29 TypeSpecifier (all)
;;;                                                           { 29 List<DeclItem>
;;;                                                             { 30 DeclItem
;;;                                                               what = DECL_NAME
;;;                                                               name = min_p
;;;                                                             } 30 DeclItem
;;;                                                           } 29 List<DeclItem>
;;;                                                         } 28 TypeName
;;;                                                       } 27 ParameterDeclaration
;;;                                                       { 27 NumericExpression (constant 48 = 0x30)
;--	load_rr_constant
	MOVE	#0x0030, RR
;;;                                                       } 27 NumericExpression (constant 48 = 0x30)
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;;;                                                       { 27 Expr (l , r)
;;;                                                         { 28 ParameterDeclaration
;;;                                                           isEllipsis = false
;;;                                                           { 29 TypeName
;;;                                                             { 30 TypeSpecifier (all)
;;;                                                               spec = int (80000)
;;;                                                             } 30 TypeSpecifier (all)
;;;                                                             { 30 List<DeclItem>
;;;                                                               { 31 DeclItem
;;;                                                                 what = DECL_NAME
;;;                                                                 name = min_w
;;;                                                               } 31 DeclItem
;;;                                                             } 30 List<DeclItem>
;;;                                                           } 29 TypeName
;;;                                                         } 28 ParameterDeclaration
;;;                                                         { 28 Expression (variable name)
;;;                                                           expr_type = "identifier" (min_w)
;--	load_rr_var min_w = -14(FP), SP at -29 (16 bit)
	MOVE	15(SP), RR
;;;                                                         } 28 Expression (variable name)
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                                         { 28 Expr (l , r)
;;;                                                           { 29 ParameterDeclaration
;;;                                                             isEllipsis = false
;;;                                                             { 30 TypeName
;;;                                                               { 31 TypeSpecifier (all)
;;;                                                                 spec = int (80000)
;;;                                                               } 31 TypeSpecifier (all)
;;;                                                               { 31 List<DeclItem>
;;;                                                                 { 32 DeclItem
;;;                                                                   what = DECL_NAME
;;;                                                                   name = field_w
;;;                                                                 } 32 DeclItem
;;;                                                               } 31 List<DeclItem>
;;;                                                             } 30 TypeName
;;;                                                           } 29 ParameterDeclaration
;;;                                                           { 29 Expression (variable name)
;;;                                                             expr_type = "identifier" (field_w)
;--	load_rr_var field_w = -12(FP), SP at -31 (16 bit)
	MOVE	19(SP), RR
;;;                                                           } 29 Expression (variable name)
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                                           { 29 Expr (l , r)
;;;                                                             { 30 ParameterDeclaration
;;;                                                               isEllipsis = false
;;;                                                               { 31 TypeName
;;;                                                                 { 32 TypeSpecifier (all)
;;;                                                                   spec = const char (20100)
;;;                                                                 } 32 TypeSpecifier (all)
;;;                                                                 { 32 List<DeclItem>
;;;                                                                   { 33 DeclItem
;;;                                                                     what = DECL_POINTER
;;;                                                                     { 34 List<Ptr>
;;;                                                                       { 35 Ptr
;;;                                                                       } 35 Ptr
;;;                                                                     } 34 List<Ptr>
;;;                                                                   } 33 DeclItem
;;;                                                                   { 33 DeclItem
;;;                                                                     what = DECL_NAME
;;;                                                                     name = alt
;;;                                                                   } 33 DeclItem
;;;                                                                 } 32 List<DeclItem>
;;;                                                               } 31 TypeName
;;;                                                             } 30 ParameterDeclaration
;;;                                                             { 30 StringExpression
;--	load_rr_string
	MOVE	#Cstr_21, RR
;;;                                                             } 30 StringExpression
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                                             { 30 Expr (l , r)
;;;                                                               { 31 ParameterDeclaration
;;;                                                                 isEllipsis = false
;;;                                                                 { 32 TypeName
;;;                                                                   { 33 TypeSpecifier (all)
;;;                                                                     spec = char (20000)
;;;                                                                   } 33 TypeSpecifier (all)
;;;                                                                   { 33 List<DeclItem>
;;;                                                                     { 34 DeclItem
;;;                                                                       what = DECL_NAME
;;;                                                                       name = pad
;;;                                                                     } 34 DeclItem
;;;                                                                   } 33 List<DeclItem>
;;;                                                                 } 32 TypeName
;;;                                                               } 31 ParameterDeclaration
;;;                                                               { 31 Expression (variable name)
;;;                                                                 expr_type = "identifier" (pad)
;--	load_rr_var pad = -8(FP), SP at -35 (8 bit)
	MOVE	27(SP), RS
;;;                                                               } 31 Expression (variable name)
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;;;                                                               { 31 Expr (l , r)
;;;                                                                 { 32 ParameterDeclaration
;;;                                                                   isEllipsis = false
;;;                                                                   { 33 TypeName
;;;                                                                     { 34 TypeSpecifier (all)
;;;                                                                       spec = char (20000)
;;;                                                                     } 34 TypeSpecifier (all)
;;;                                                                     { 34 List<DeclItem>
;;;                                                                       { 35 DeclItem
;;;                                                                         what = DECL_NAME
;;;                                                                         name = sign
;;;                                                                       } 35 DeclItem
;;;                                                                     } 34 List<DeclItem>
;;;                                                                   } 33 TypeName
;;;                                                                 } 32 ParameterDeclaration
;;;                                                                 { 32 Expression (variable name)
;;;                                                                   expr_type = "identifier" (sign)
;--	load_rr_var sign = -7(FP), SP at -36 (8 bit)
	MOVE	29(SP), RS
;;;                                                                 } 32 Expression (variable name)
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;;;                                                                 { 32 Expr (l , r)
;;;                                                                   { 33 ParameterDeclaration
;;;                                                                     isEllipsis = false
;;;                                                                     { 34 TypeName
;;;                                                                       { 35 TypeSpecifier (all)
;;;                                                                         spec = char (20000)
;;;                                                                       } 35 TypeSpecifier (all)
;;;                                                                       { 35 List<DeclItem>
;;;                                                                         { 36 DeclItem
;;;                                                                           what = DECL_NAME
;;;                                                                           name = flags
;;;                                                                         } 36 DeclItem
;;;                                                                       } 35 List<DeclItem>
;;;                                                                     } 34 TypeName
;;;                                                                   } 33 ParameterDeclaration
;;;                                                                   { 33 Expression (variable name)
;;;                                                                     expr_type = "identifier" (flags)
;--	load_rr_var flags = -6(FP), SP at -37 (8 bit)
	MOVE	31(SP), RS
;;;                                                                   } 33 Expression (variable name)
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;;;                                                                   { 33 ParameterDeclaration
;;;                                                                     isEllipsis = false
;;;                                                                     { 34 TypeName
;;;                                                                       { 35 TypeSpecifier (all)
;;;                                                                         spec = const char (20100)
;;;                                                                       } 35 TypeSpecifier (all)
;;;                                                                       { 35 List<DeclItem>
;;;                                                                         { 36 DeclItem
;;;                                                                           what = DECL_POINTER
;;;                                                                           { 37 List<Ptr>
;;;                                                                             { 38 Ptr
;;;                                                                             } 38 Ptr
;;;                                                                           } 37 List<Ptr>
;;;                                                                         } 36 DeclItem
;;;                                                                         { 36 DeclItem
;;;                                                                           what = DECL_NAME
;;;                                                                           name = buffer
;;;                                                                         } 36 DeclItem
;;;                                                                       } 35 List<DeclItem>
;;;                                                                     } 34 TypeName
;;;                                                                   } 33 ParameterDeclaration
;--	load_address buffer = -28(FP), SP at -38
	LEA	10(SP), RR
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                                                 } 32 Expr (l , r)
;;;                                                               } 31 Expr (l , r)
;;;                                                             } 30 Expr (l , r)
;;;                                                           } 29 Expr (l , r)
;;;                                                         } 28 Expr (l , r)
;;;                                                       } 27 Expr (l , r)
;;;                                                     } 26 Expr (l , r)
;--	push 2 bytes
;--	call
	CALL	Cprint_item
;--	pop 12 bytes
	ADD	SP, #12
;;;                                                   } 25 Expr l(r)
;;;                                                   { 25 Expression (variable name)
;;;                                                     expr_type = "identifier" (len)
;--	load_ll_var len = -4(FP), SP at -28 (16 bit)
	MOVE	24(SP), LL
;;;                                                   } 25 Expression (variable name)
;--	scale_rr *1
;--	l + r
	ADD	LL, RR
;;;                                                 } 24 Expr l + r
;--	store_rr_var len = -4(FP), SP at -28
	MOVE	RR, 24(SP)
;;;                                               } 23 Expr l += r
;;;                                             } 22 ExpressionStatement
;;;                                             { 22 break/continue Statement
;--	branch
	JMP	L12_brk_42
;;;                                             } 22 break/continue Statement
;;;                                             { 22 case Statement
L12_case_42_0073:
;;;                                               { 23 ExpressionStatement
;;;                                                 { 24 Expr l += r
;;;                                                   { 25 TypeName
;;;                                                     { 26 TypeSpecifier (all)
;;;                                                       spec = int (80000)
;;;                                                     } 26 TypeSpecifier (all)
;;;                                                     { 26 List<DeclItem>
;;;                                                       { 27 DeclItem
;;;                                                         what = DECL_NAME
;;;                                                         name = len
;;;                                                       } 27 DeclItem
;;;                                                     } 26 List<DeclItem>
;;;                                                   } 25 TypeName
;;;                                                   { 25 Expr l + r
;;;                                                     { 26 Expr l(r)
;;;                                                       { 27 TypeName
;;;                                                         { 28 TypeSpecifier (all)
;;;                                                           spec = int (80000)
;;;                                                         } 28 TypeSpecifier (all)
;;;                                                         { 28 List<DeclItem>
;;;                                                           { 29 DeclItem
;;;                                                             what = DECL_NAME
;;;                                                             name = print_item
;;;                                                           } 29 DeclItem
;;;                                                         } 28 List<DeclItem>
;;;                                                       } 27 TypeName
;;;                                                       { 27 Expr (l , r)
;;;                                                         { 28 ParameterDeclaration
;;;                                                           isEllipsis = false
;;;                                                           { 29 TypeName
;;;                                                             { 30 TypeSpecifier (all)
;;;                                                               spec = char (20000)
;;;                                                             } 30 TypeSpecifier (all)
;;;                                                             { 30 List<DeclItem>
;;;                                                               { 31 DeclItem
;;;                                                                 what = DECL_NAME
;;;                                                                 name = min_p
;;;                                                               } 31 DeclItem
;;;                                                             } 30 List<DeclItem>
;;;                                                           } 29 TypeName
;;;                                                         } 28 ParameterDeclaration
;;;                                                         { 28 NumericExpression (constant 32 = 0x20)
;--	load_rr_constant
	MOVE	#0x0020, RR
;;;                                                         } 28 NumericExpression (constant 32 = 0x20)
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;;;                                                         { 28 Expr (l , r)
;;;                                                           { 29 ParameterDeclaration
;;;                                                             isEllipsis = false
;;;                                                             { 30 TypeName
;;;                                                               { 31 TypeSpecifier (all)
;;;                                                                 spec = int (80000)
;;;                                                               } 31 TypeSpecifier (all)
;;;                                                               { 31 List<DeclItem>
;;;                                                                 { 32 DeclItem
;;;                                                                   what = DECL_NAME
;;;                                                                   name = min_w
;;;                                                                 } 32 DeclItem
;;;                                                               } 31 List<DeclItem>
;;;                                                             } 30 TypeName
;;;                                                           } 29 ParameterDeclaration
;;;                                                           { 29 Expression (variable name)
;;;                                                             expr_type = "identifier" (min_w)
;--	load_rr_var min_w = -14(FP), SP at -29 (16 bit)
	MOVE	15(SP), RR
;;;                                                           } 29 Expression (variable name)
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                                           { 29 Expr (l , r)
;;;                                                             { 30 ParameterDeclaration
;;;                                                               isEllipsis = false
;;;                                                               { 31 TypeName
;;;                                                                 { 32 TypeSpecifier (all)
;;;                                                                   spec = int (80000)
;;;                                                                 } 32 TypeSpecifier (all)
;;;                                                                 { 32 List<DeclItem>
;;;                                                                   { 33 DeclItem
;;;                                                                     what = DECL_NAME
;;;                                                                     name = field_w
;;;                                                                   } 33 DeclItem
;;;                                                                 } 32 List<DeclItem>
;;;                                                               } 31 TypeName
;;;                                                             } 30 ParameterDeclaration
;;;                                                             { 30 Expression (variable name)
;;;                                                               expr_type = "identifier" (field_w)
;--	load_rr_var field_w = -12(FP), SP at -31 (16 bit)
	MOVE	19(SP), RR
;;;                                                             } 30 Expression (variable name)
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                                             { 30 Expr (l , r)
;;;                                                               { 31 ParameterDeclaration
;;;                                                                 isEllipsis = false
;;;                                                                 { 32 TypeName
;;;                                                                   { 33 TypeSpecifier (all)
;;;                                                                     spec = const char (20100)
;;;                                                                   } 33 TypeSpecifier (all)
;;;                                                                   { 33 List<DeclItem>
;;;                                                                     { 34 DeclItem
;;;                                                                       what = DECL_POINTER
;;;                                                                       { 35 List<Ptr>
;;;                                                                         { 36 Ptr
;;;                                                                         } 36 Ptr
;;;                                                                       } 35 List<Ptr>
;;;                                                                     } 34 DeclItem
;;;                                                                     { 34 DeclItem
;;;                                                                       what = DECL_NAME
;;;                                                                       name = alt
;;;                                                                     } 34 DeclItem
;;;                                                                   } 33 List<DeclItem>
;;;                                                                 } 32 TypeName
;;;                                                               } 31 ParameterDeclaration
;;;                                                               { 31 StringExpression
;--	load_rr_string
	MOVE	#Cstr_22, RR
;;;                                                               } 31 StringExpression
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                                               { 31 Expr (l , r)
;;;                                                                 { 32 ParameterDeclaration
;;;                                                                   isEllipsis = false
;;;                                                                   { 33 TypeName
;;;                                                                     { 34 TypeSpecifier (all)
;;;                                                                       spec = char (20000)
;;;                                                                     } 34 TypeSpecifier (all)
;;;                                                                     { 34 List<DeclItem>
;;;                                                                       { 35 DeclItem
;;;                                                                         what = DECL_NAME
;;;                                                                         name = pad
;;;                                                                       } 35 DeclItem
;;;                                                                     } 34 List<DeclItem>
;;;                                                                   } 33 TypeName
;;;                                                                 } 32 ParameterDeclaration
;;;                                                                 { 32 NumericExpression (constant 32 = 0x20)
;--	load_rr_constant
	MOVE	#0x0020, RR
;;;                                                                 } 32 NumericExpression (constant 32 = 0x20)
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;;;                                                                 { 32 Expr (l , r)
;;;                                                                   { 33 ParameterDeclaration
;;;                                                                     isEllipsis = false
;;;                                                                     { 34 TypeName
;;;                                                                       { 35 TypeSpecifier (all)
;;;                                                                         spec = char (20000)
;;;                                                                       } 35 TypeSpecifier (all)
;;;                                                                       { 35 List<DeclItem>
;;;                                                                         { 36 DeclItem
;;;                                                                           what = DECL_NAME
;;;                                                                           name = sign
;;;                                                                         } 36 DeclItem
;;;                                                                       } 35 List<DeclItem>
;;;                                                                     } 34 TypeName
;;;                                                                   } 33 ParameterDeclaration
;;;                                                                   { 33 NumericExpression (constant 0 = 0x0)
;--	load_rr_constant
	MOVE	#0x0000, RR
;;;                                                                   } 33 NumericExpression (constant 0 = 0x0)
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;;;                                                                   { 33 Expr (l , r)
;;;                                                                     { 34 ParameterDeclaration
;;;                                                                       isEllipsis = false
;;;                                                                       { 35 TypeName
;;;                                                                         { 36 TypeSpecifier (all)
;;;                                                                           spec = char (20000)
;;;                                                                         } 36 TypeSpecifier (all)
;;;                                                                         { 36 List<DeclItem>
;;;                                                                           { 37 DeclItem
;;;                                                                             what = DECL_NAME
;;;                                                                             name = flags
;;;                                                                           } 37 DeclItem
;;;                                                                         } 36 List<DeclItem>
;;;                                                                       } 35 TypeName
;;;                                                                     } 34 ParameterDeclaration
;;;                                                                     { 34 Expr l & r
;;;                                                                       { 35 TypeName (internal)
;;;                                                                         { 36 TypeSpecifier (all)
;;;                                                                           spec = int (80000)
;;;                                                                         } 36 TypeSpecifier (all)
;;;                                                                       } 35 TypeName (internal)
;;;                                                                       { 35 Expression (variable name)
;;;                                                                         expr_type = "identifier" (flags)
;--	load_rr_var flags = -6(FP), SP at -37 (8 bit)
	MOVE	31(SP), RS
;;;                                                                       } 35 Expression (variable name)
;--	l & r
	AND	RR, #0x0002
;;;                                                                     } 34 Expr l & r
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;;;                                                                     { 34 ParameterDeclaration
;;;                                                                       isEllipsis = false
;;;                                                                       { 35 TypeName
;;;                                                                         { 36 TypeSpecifier (all)
;;;                                                                           spec = const char (20100)
;;;                                                                         } 36 TypeSpecifier (all)
;;;                                                                         { 36 List<DeclItem>
;;;                                                                           { 37 DeclItem
;;;                                                                             what = DECL_POINTER
;;;                                                                             { 38 List<Ptr>
;;;                                                                               { 39 Ptr
;;;                                                                               } 39 Ptr
;;;                                                                             } 38 List<Ptr>
;;;                                                                           } 37 DeclItem
;;;                                                                           { 37 DeclItem
;;;                                                                             what = DECL_NAME
;;;                                                                             name = buffer
;;;                                                                           } 37 DeclItem
;;;                                                                         } 36 List<DeclItem>
;;;                                                                       } 35 TypeName
;;;                                                                     } 34 ParameterDeclaration
;;;                                                                     { 34 Expr * r
;;;                                                                       { 35 Expr l - r
;;;                                                                         { 36 Expr ++r
;;;                                                                           { 37 Expression (variable name)
;;;                                                                             expr_type = "identifier" (args)
;--	load_rr_var args = -2(FP), SP at -38 (16 bit)
	MOVE	36(SP), RR
;;;                                                                           } 37 Expression (variable name)
;--	++
	ADD	RR, #0x0002
;--	store_rr_var args = -2(FP), SP at -38
	MOVE	RR, 36(SP)
;;;                                                                         } 36 Expr ++r
;--	l - r
	SUB	RR, #0x0002
;;;                                                                       } 35 Expr l - r
;--	content
	MOVE	(RR), RR
;;;                                                                     } 34 Expr * r
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                                                   } 33 Expr (l , r)
;;;                                                                 } 32 Expr (l , r)
;;;                                                               } 31 Expr (l , r)
;;;                                                             } 30 Expr (l , r)
;;;                                                           } 29 Expr (l , r)
;;;                                                         } 28 Expr (l , r)
;;;                                                       } 27 Expr (l , r)
;--	push 2 bytes
;--	call
	CALL	Cprint_item
;--	pop 12 bytes
	ADD	SP, #12
;;;                                                     } 26 Expr l(r)
;;;                                                     { 26 Expression (variable name)
;;;                                                       expr_type = "identifier" (len)
;--	load_ll_var len = -4(FP), SP at -28 (16 bit)
	MOVE	24(SP), LL
;;;                                                     } 26 Expression (variable name)
;--	scale_rr *1
;--	l + r
	ADD	LL, RR
;;;                                                   } 25 Expr l + r
;--	store_rr_var len = -4(FP), SP at -28
	MOVE	RR, 24(SP)
;;;                                                 } 24 Expr l += r
;;;                                               } 23 ExpressionStatement
;;;                                             } 22 case Statement
;;;                                             { 22 break/continue Statement
;--	branch
	JMP	L12_brk_42
;;;                                             } 22 break/continue Statement
;;;                                             { 22 case Statement
L12_case_42_0075:
;;;                                               { 23 ExpressionStatement
;;;                                                 { 24 Expr l(r)
;;;                                                   { 25 TypeName
;;;                                                     { 26 TypeSpecifier (all)
;;;                                                       spec = void (10000)
;;;                                                     } 26 TypeSpecifier (all)
;;;                                                     { 26 List<DeclItem>
;;;                                                       { 27 DeclItem
;;;                                                         what = DECL_NAME
;;;                                                         name = print_unsigned
;;;                                                       } 27 DeclItem
;;;                                                     } 26 List<DeclItem>
;;;                                                   } 25 TypeName
;;;                                                   { 25 Expr (l , r)
;;;                                                     { 26 ParameterDeclaration
;;;                                                       isEllipsis = false
;;;                                                       { 27 TypeName
;;;                                                         { 28 TypeSpecifier (all)
;;;                                                           spec = unsigned int (82000)
;;;                                                         } 28 TypeSpecifier (all)
;;;                                                         { 28 List<DeclItem>
;;;                                                           { 29 DeclItem
;;;                                                             what = DECL_NAME
;;;                                                             name = value
;;;                                                           } 29 DeclItem
;;;                                                         } 28 List<DeclItem>
;;;                                                       } 27 TypeName
;;;                                                     } 26 ParameterDeclaration
;;;                                                     { 26 Expression (cast)r
;;;                                                       { 27 Expr * r
;;;                                                         { 28 Expr l - r
;;;                                                           { 29 Expr ++r
;;;                                                             { 30 Expression (variable name)
;;;                                                               expr_type = "identifier" (args)
;--	load_rr_var args = -2(FP), SP at -28 (16 bit)
	MOVE	26(SP), RR
;;;                                                             } 30 Expression (variable name)
;--	++
	ADD	RR, #0x0002
;--	store_rr_var args = -2(FP), SP at -28
	MOVE	RR, 26(SP)
;;;                                                           } 29 Expr ++r
;--	l - r
	SUB	RR, #0x0002
;;;                                                         } 28 Expr l - r
;--	content
	MOVE	(RR), RR
;;;                                                       } 27 Expr * r
;;;                                                     } 26 Expression (cast)r
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                                     { 26 ParameterDeclaration
;;;                                                       isEllipsis = false
;;;                                                       { 27 TypeName
;;;                                                         { 28 TypeSpecifier (all)
;;;                                                           spec = char (20000)
;;;                                                         } 28 TypeSpecifier (all)
;;;                                                         { 28 List<DeclItem>
;;;                                                           { 29 DeclItem
;;;                                                             what = DECL_POINTER
;;;                                                             { 30 List<Ptr>
;;;                                                               { 31 Ptr
;;;                                                               } 31 Ptr
;;;                                                             } 30 List<Ptr>
;;;                                                           } 29 DeclItem
;;;                                                           { 29 DeclItem
;;;                                                             what = DECL_NAME
;;;                                                             name = dest
;;;                                                           } 29 DeclItem
;;;                                                         } 28 List<DeclItem>
;;;                                                       } 27 TypeName
;;;                                                     } 26 ParameterDeclaration
;--	load_address buffer = -28(FP), SP at -30
	LEA	2(SP), RR
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                                   } 25 Expr (l , r)
;--	push 0 bytes
;--	call
	CALL	Cprint_unsigned
;--	pop 4 bytes
	ADD	SP, #4
;;;                                                 } 24 Expr l(r)
;;;                                               } 23 ExpressionStatement
;;;                                             } 22 case Statement
;;;                                             { 22 ExpressionStatement
;;;                                               { 23 Expr l += r
;;;                                                 { 24 TypeName
;;;                                                   { 25 TypeSpecifier (all)
;;;                                                     spec = int (80000)
;;;                                                   } 25 TypeSpecifier (all)
;;;                                                   { 25 List<DeclItem>
;;;                                                     { 26 DeclItem
;;;                                                       what = DECL_NAME
;;;                                                       name = len
;;;                                                     } 26 DeclItem
;;;                                                   } 25 List<DeclItem>
;;;                                                 } 24 TypeName
;;;                                                 { 24 Expr l + r
;;;                                                   { 25 Expr l(r)
;;;                                                     { 26 TypeName
;;;                                                       { 27 TypeSpecifier (all)
;;;                                                         spec = int (80000)
;;;                                                       } 27 TypeSpecifier (all)
;;;                                                       { 27 List<DeclItem>
;;;                                                         { 28 DeclItem
;;;                                                           what = DECL_NAME
;;;                                                           name = print_item
;;;                                                         } 28 DeclItem
;;;                                                       } 27 List<DeclItem>
;;;                                                     } 26 TypeName
;;;                                                     { 26 Expr (l , r)
;;;                                                       { 27 ParameterDeclaration
;;;                                                         isEllipsis = false
;;;                                                         { 28 TypeName
;;;                                                           { 29 TypeSpecifier (all)
;;;                                                             spec = char (20000)
;;;                                                           } 29 TypeSpecifier (all)
;;;                                                           { 29 List<DeclItem>
;;;                                                             { 30 DeclItem
;;;                                                               what = DECL_NAME
;;;                                                               name = min_p
;;;                                                             } 30 DeclItem
;;;                                                           } 29 List<DeclItem>
;;;                                                         } 28 TypeName
;;;                                                       } 27 ParameterDeclaration
;;;                                                       { 27 NumericExpression (constant 48 = 0x30)
;--	load_rr_constant
	MOVE	#0x0030, RR
;;;                                                       } 27 NumericExpression (constant 48 = 0x30)
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;;;                                                       { 27 Expr (l , r)
;;;                                                         { 28 ParameterDeclaration
;;;                                                           isEllipsis = false
;;;                                                           { 29 TypeName
;;;                                                             { 30 TypeSpecifier (all)
;;;                                                               spec = int (80000)
;;;                                                             } 30 TypeSpecifier (all)
;;;                                                             { 30 List<DeclItem>
;;;                                                               { 31 DeclItem
;;;                                                                 what = DECL_NAME
;;;                                                                 name = min_w
;;;                                                               } 31 DeclItem
;;;                                                             } 30 List<DeclItem>
;;;                                                           } 29 TypeName
;;;                                                         } 28 ParameterDeclaration
;;;                                                         { 28 Expression (variable name)
;;;                                                           expr_type = "identifier" (min_w)
;--	load_rr_var min_w = -14(FP), SP at -29 (16 bit)
	MOVE	15(SP), RR
;;;                                                         } 28 Expression (variable name)
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                                         { 28 Expr (l , r)
;;;                                                           { 29 ParameterDeclaration
;;;                                                             isEllipsis = false
;;;                                                             { 30 TypeName
;;;                                                               { 31 TypeSpecifier (all)
;;;                                                                 spec = int (80000)
;;;                                                               } 31 TypeSpecifier (all)
;;;                                                               { 31 List<DeclItem>
;;;                                                                 { 32 DeclItem
;;;                                                                   what = DECL_NAME
;;;                                                                   name = field_w
;;;                                                                 } 32 DeclItem
;;;                                                               } 31 List<DeclItem>
;;;                                                             } 30 TypeName
;;;                                                           } 29 ParameterDeclaration
;;;                                                           { 29 Expression (variable name)
;;;                                                             expr_type = "identifier" (field_w)
;--	load_rr_var field_w = -12(FP), SP at -31 (16 bit)
	MOVE	19(SP), RR
;;;                                                           } 29 Expression (variable name)
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                                           { 29 Expr (l , r)
;;;                                                             { 30 ParameterDeclaration
;;;                                                               isEllipsis = false
;;;                                                               { 31 TypeName
;;;                                                                 { 32 TypeSpecifier (all)
;;;                                                                   spec = const char (20100)
;;;                                                                 } 32 TypeSpecifier (all)
;;;                                                                 { 32 List<DeclItem>
;;;                                                                   { 33 DeclItem
;;;                                                                     what = DECL_POINTER
;;;                                                                     { 34 List<Ptr>
;;;                                                                       { 35 Ptr
;;;                                                                       } 35 Ptr
;;;                                                                     } 34 List<Ptr>
;;;                                                                   } 33 DeclItem
;;;                                                                   { 33 DeclItem
;;;                                                                     what = DECL_NAME
;;;                                                                     name = alt
;;;                                                                   } 33 DeclItem
;;;                                                                 } 32 List<DeclItem>
;;;                                                               } 31 TypeName
;;;                                                             } 30 ParameterDeclaration
;;;                                                             { 30 StringExpression
;--	load_rr_string
	MOVE	#Cstr_23, RR
;;;                                                             } 30 StringExpression
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                                             { 30 Expr (l , r)
;;;                                                               { 31 ParameterDeclaration
;;;                                                                 isEllipsis = false
;;;                                                                 { 32 TypeName
;;;                                                                   { 33 TypeSpecifier (all)
;;;                                                                     spec = char (20000)
;;;                                                                   } 33 TypeSpecifier (all)
;;;                                                                   { 33 List<DeclItem>
;;;                                                                     { 34 DeclItem
;;;                                                                       what = DECL_NAME
;;;                                                                       name = pad
;;;                                                                     } 34 DeclItem
;;;                                                                   } 33 List<DeclItem>
;;;                                                                 } 32 TypeName
;;;                                                               } 31 ParameterDeclaration
;;;                                                               { 31 Expression (variable name)
;;;                                                                 expr_type = "identifier" (pad)
;--	load_rr_var pad = -8(FP), SP at -35 (8 bit)
	MOVE	27(SP), RS
;;;                                                               } 31 Expression (variable name)
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;;;                                                               { 31 Expr (l , r)
;;;                                                                 { 32 ParameterDeclaration
;;;                                                                   isEllipsis = false
;;;                                                                   { 33 TypeName
;;;                                                                     { 34 TypeSpecifier (all)
;;;                                                                       spec = char (20000)
;;;                                                                     } 34 TypeSpecifier (all)
;;;                                                                     { 34 List<DeclItem>
;;;                                                                       { 35 DeclItem
;;;                                                                         what = DECL_NAME
;;;                                                                         name = sign
;;;                                                                       } 35 DeclItem
;;;                                                                     } 34 List<DeclItem>
;;;                                                                   } 33 TypeName
;;;                                                                 } 32 ParameterDeclaration
;;;                                                                 { 32 Expression (variable name)
;;;                                                                   expr_type = "identifier" (sign)
;--	load_rr_var sign = -7(FP), SP at -36 (8 bit)
	MOVE	29(SP), RS
;;;                                                                 } 32 Expression (variable name)
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;;;                                                                 { 32 Expr (l , r)
;;;                                                                   { 33 ParameterDeclaration
;;;                                                                     isEllipsis = false
;;;                                                                     { 34 TypeName
;;;                                                                       { 35 TypeSpecifier (all)
;;;                                                                         spec = char (20000)
;;;                                                                       } 35 TypeSpecifier (all)
;;;                                                                       { 35 List<DeclItem>
;;;                                                                         { 36 DeclItem
;;;                                                                           what = DECL_NAME
;;;                                                                           name = flags
;;;                                                                         } 36 DeclItem
;;;                                                                       } 35 List<DeclItem>
;;;                                                                     } 34 TypeName
;;;                                                                   } 33 ParameterDeclaration
;;;                                                                   { 33 Expression (variable name)
;;;                                                                     expr_type = "identifier" (flags)
;--	load_rr_var flags = -6(FP), SP at -37 (8 bit)
	MOVE	31(SP), RS
;;;                                                                   } 33 Expression (variable name)
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;;;                                                                   { 33 ParameterDeclaration
;;;                                                                     isEllipsis = false
;;;                                                                     { 34 TypeName
;;;                                                                       { 35 TypeSpecifier (all)
;;;                                                                         spec = const char (20100)
;;;                                                                       } 35 TypeSpecifier (all)
;;;                                                                       { 35 List<DeclItem>
;;;                                                                         { 36 DeclItem
;;;                                                                           what = DECL_POINTER
;;;                                                                           { 37 List<Ptr>
;;;                                                                             { 38 Ptr
;;;                                                                             } 38 Ptr
;;;                                                                           } 37 List<Ptr>
;;;                                                                         } 36 DeclItem
;;;                                                                         { 36 DeclItem
;;;                                                                           what = DECL_NAME
;;;                                                                           name = buffer
;;;                                                                         } 36 DeclItem
;;;                                                                       } 35 List<DeclItem>
;;;                                                                     } 34 TypeName
;;;                                                                   } 33 ParameterDeclaration
;--	load_address buffer = -28(FP), SP at -38
	LEA	10(SP), RR
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                                                 } 32 Expr (l , r)
;;;                                                               } 31 Expr (l , r)
;;;                                                             } 30 Expr (l , r)
;;;                                                           } 29 Expr (l , r)
;;;                                                         } 28 Expr (l , r)
;;;                                                       } 27 Expr (l , r)
;;;                                                     } 26 Expr (l , r)
;--	push 2 bytes
;--	call
	CALL	Cprint_item
;--	pop 12 bytes
	ADD	SP, #12
;;;                                                   } 25 Expr l(r)
;;;                                                   { 25 Expression (variable name)
;;;                                                     expr_type = "identifier" (len)
;--	load_ll_var len = -4(FP), SP at -28 (16 bit)
	MOVE	24(SP), LL
;;;                                                   } 25 Expression (variable name)
;--	scale_rr *1
;--	l + r
	ADD	LL, RR
;;;                                                 } 24 Expr l + r
;--	store_rr_var len = -4(FP), SP at -28
	MOVE	RR, 24(SP)
;;;                                               } 23 Expr l += r
;;;                                             } 22 ExpressionStatement
;;;                                             { 22 break/continue Statement
;--	branch
	JMP	L12_brk_42
;;;                                             } 22 break/continue Statement
;;;                                             { 22 case Statement
L12_case_42_0078:
;;;                                               { 23 ExpressionStatement
;;;                                                 { 24 Expr l(r)
;;;                                                   { 25 TypeName
;;;                                                     { 26 TypeSpecifier (all)
;;;                                                       spec = void (10000)
;;;                                                     } 26 TypeSpecifier (all)
;;;                                                     { 26 List<DeclItem>
;;;                                                       { 27 DeclItem
;;;                                                         what = DECL_NAME
;;;                                                         name = print_hex
;;;                                                       } 27 DeclItem
;;;                                                     } 26 List<DeclItem>
;;;                                                   } 25 TypeName
;;;                                                   { 25 Expr (l , r)
;;;                                                     { 26 ParameterDeclaration
;;;                                                       isEllipsis = false
;;;                                                       { 27 TypeName
;;;                                                         { 28 TypeSpecifier (all)
;;;                                                           spec = const char (20100)
;;;                                                         } 28 TypeSpecifier (all)
;;;                                                         { 28 List<DeclItem>
;;;                                                           { 29 DeclItem
;;;                                                             what = DECL_POINTER
;;;                                                             { 30 List<Ptr>
;;;                                                               { 31 Ptr
;;;                                                               } 31 Ptr
;;;                                                             } 30 List<Ptr>
;;;                                                           } 29 DeclItem
;;;                                                           { 29 DeclItem
;;;                                                             what = DECL_NAME
;;;                                                             name = hex
;;;                                                           } 29 DeclItem
;;;                                                         } 28 List<DeclItem>
;;;                                                       } 27 TypeName
;;;                                                     } 26 ParameterDeclaration
;;;                                                     { 26 StringExpression
;--	load_rr_string
	MOVE	#Cstr_24, RR
;;;                                                     } 26 StringExpression
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                                     { 26 Expr (l , r)
;;;                                                       { 27 ParameterDeclaration
;;;                                                         isEllipsis = false
;;;                                                         { 28 TypeName
;;;                                                           { 29 TypeSpecifier (all)
;;;                                                             spec = unsigned int (82000)
;;;                                                           } 29 TypeSpecifier (all)
;;;                                                           { 29 List<DeclItem>
;;;                                                             { 30 DeclItem
;;;                                                               what = DECL_NAME
;;;                                                               name = value
;;;                                                             } 30 DeclItem
;;;                                                           } 29 List<DeclItem>
;;;                                                         } 28 TypeName
;;;                                                       } 27 ParameterDeclaration
;;;                                                       { 27 Expression (cast)r
;;;                                                         { 28 Expr * r
;;;                                                           { 29 Expr l - r
;;;                                                             { 30 Expr ++r
;;;                                                               { 31 Expression (variable name)
;;;                                                                 expr_type = "identifier" (args)
;--	load_rr_var args = -2(FP), SP at -30 (16 bit)
	MOVE	28(SP), RR
;;;                                                               } 31 Expression (variable name)
;--	++
	ADD	RR, #0x0002
;--	store_rr_var args = -2(FP), SP at -30
	MOVE	RR, 28(SP)
;;;                                                             } 30 Expr ++r
;--	l - r
	SUB	RR, #0x0002
;;;                                                           } 29 Expr l - r
;--	content
	MOVE	(RR), RR
;;;                                                         } 28 Expr * r
;;;                                                       } 27 Expression (cast)r
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                                       { 27 ParameterDeclaration
;;;                                                         isEllipsis = false
;;;                                                         { 28 TypeName
;;;                                                           { 29 TypeSpecifier (all)
;;;                                                             spec = char (20000)
;;;                                                           } 29 TypeSpecifier (all)
;;;                                                           { 29 List<DeclItem>
;;;                                                             { 30 DeclItem
;;;                                                               what = DECL_POINTER
;;;                                                               { 31 List<Ptr>
;;;                                                                 { 32 Ptr
;;;                                                                 } 32 Ptr
;;;                                                               } 31 List<Ptr>
;;;                                                             } 30 DeclItem
;;;                                                             { 30 DeclItem
;;;                                                               what = DECL_NAME
;;;                                                               name = dest
;;;                                                             } 30 DeclItem
;;;                                                           } 29 List<DeclItem>
;;;                                                         } 28 TypeName
;;;                                                       } 27 ParameterDeclaration
;--	load_address buffer = -28(FP), SP at -32
	LEA	4(SP), RR
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                                     } 26 Expr (l , r)
;;;                                                   } 25 Expr (l , r)
;--	push 0 bytes
;--	call
	CALL	Cprint_hex
;--	pop 6 bytes
	ADD	SP, #6
;;;                                                 } 24 Expr l(r)
;;;                                               } 23 ExpressionStatement
;;;                                             } 22 case Statement
;;;                                             { 22 ExpressionStatement
;;;                                               { 23 Expr l += r
;;;                                                 { 24 TypeName
;;;                                                   { 25 TypeSpecifier (all)
;;;                                                     spec = int (80000)
;;;                                                   } 25 TypeSpecifier (all)
;;;                                                   { 25 List<DeclItem>
;;;                                                     { 26 DeclItem
;;;                                                       what = DECL_NAME
;;;                                                       name = len
;;;                                                     } 26 DeclItem
;;;                                                   } 25 List<DeclItem>
;;;                                                 } 24 TypeName
;;;                                                 { 24 Expr l + r
;;;                                                   { 25 Expr l(r)
;;;                                                     { 26 TypeName
;;;                                                       { 27 TypeSpecifier (all)
;;;                                                         spec = int (80000)
;;;                                                       } 27 TypeSpecifier (all)
;;;                                                       { 27 List<DeclItem>
;;;                                                         { 28 DeclItem
;;;                                                           what = DECL_NAME
;;;                                                           name = print_item
;;;                                                         } 28 DeclItem
;;;                                                       } 27 List<DeclItem>
;;;                                                     } 26 TypeName
;;;                                                     { 26 Expr (l , r)
;;;                                                       { 27 ParameterDeclaration
;;;                                                         isEllipsis = false
;;;                                                         { 28 TypeName
;;;                                                           { 29 TypeSpecifier (all)
;;;                                                             spec = char (20000)
;;;                                                           } 29 TypeSpecifier (all)
;;;                                                           { 29 List<DeclItem>
;;;                                                             { 30 DeclItem
;;;                                                               what = DECL_NAME
;;;                                                               name = min_p
;;;                                                             } 30 DeclItem
;;;                                                           } 29 List<DeclItem>
;;;                                                         } 28 TypeName
;;;                                                       } 27 ParameterDeclaration
;;;                                                       { 27 NumericExpression (constant 48 = 0x30)
;--	load_rr_constant
	MOVE	#0x0030, RR
;;;                                                       } 27 NumericExpression (constant 48 = 0x30)
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;;;                                                       { 27 Expr (l , r)
;;;                                                         { 28 ParameterDeclaration
;;;                                                           isEllipsis = false
;;;                                                           { 29 TypeName
;;;                                                             { 30 TypeSpecifier (all)
;;;                                                               spec = int (80000)
;;;                                                             } 30 TypeSpecifier (all)
;;;                                                             { 30 List<DeclItem>
;;;                                                               { 31 DeclItem
;;;                                                                 what = DECL_NAME
;;;                                                                 name = min_w
;;;                                                               } 31 DeclItem
;;;                                                             } 30 List<DeclItem>
;;;                                                           } 29 TypeName
;;;                                                         } 28 ParameterDeclaration
;;;                                                         { 28 Expression (variable name)
;;;                                                           expr_type = "identifier" (min_w)
;--	load_rr_var min_w = -14(FP), SP at -29 (16 bit)
	MOVE	15(SP), RR
;;;                                                         } 28 Expression (variable name)
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                                         { 28 Expr (l , r)
;;;                                                           { 29 ParameterDeclaration
;;;                                                             isEllipsis = false
;;;                                                             { 30 TypeName
;;;                                                               { 31 TypeSpecifier (all)
;;;                                                                 spec = int (80000)
;;;                                                               } 31 TypeSpecifier (all)
;;;                                                               { 31 List<DeclItem>
;;;                                                                 { 32 DeclItem
;;;                                                                   what = DECL_NAME
;;;                                                                   name = field_w
;;;                                                                 } 32 DeclItem
;;;                                                               } 31 List<DeclItem>
;;;                                                             } 30 TypeName
;;;                                                           } 29 ParameterDeclaration
;;;                                                           { 29 Expression (variable name)
;;;                                                             expr_type = "identifier" (field_w)
;--	load_rr_var field_w = -12(FP), SP at -31 (16 bit)
	MOVE	19(SP), RR
;;;                                                           } 29 Expression (variable name)
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                                           { 29 Expr (l , r)
;;;                                                             { 30 ParameterDeclaration
;;;                                                               isEllipsis = false
;;;                                                               { 31 TypeName
;;;                                                                 { 32 TypeSpecifier (all)
;;;                                                                   spec = const char (20100)
;;;                                                                 } 32 TypeSpecifier (all)
;;;                                                                 { 32 List<DeclItem>
;;;                                                                   { 33 DeclItem
;;;                                                                     what = DECL_POINTER
;;;                                                                     { 34 List<Ptr>
;;;                                                                       { 35 Ptr
;;;                                                                       } 35 Ptr
;;;                                                                     } 34 List<Ptr>
;;;                                                                   } 33 DeclItem
;;;                                                                   { 33 DeclItem
;;;                                                                     what = DECL_NAME
;;;                                                                     name = alt
;;;                                                                   } 33 DeclItem
;;;                                                                 } 32 List<DeclItem>
;;;                                                               } 31 TypeName
;;;                                                             } 30 ParameterDeclaration
;;;                                                             { 30 StringExpression
;--	load_rr_string
	MOVE	#Cstr_25, RR
;;;                                                             } 30 StringExpression
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                                             { 30 Expr (l , r)
;;;                                                               { 31 ParameterDeclaration
;;;                                                                 isEllipsis = false
;;;                                                                 { 32 TypeName
;;;                                                                   { 33 TypeSpecifier (all)
;;;                                                                     spec = char (20000)
;;;                                                                   } 33 TypeSpecifier (all)
;;;                                                                   { 33 List<DeclItem>
;;;                                                                     { 34 DeclItem
;;;                                                                       what = DECL_NAME
;;;                                                                       name = pad
;;;                                                                     } 34 DeclItem
;;;                                                                   } 33 List<DeclItem>
;;;                                                                 } 32 TypeName
;;;                                                               } 31 ParameterDeclaration
;;;                                                               { 31 Expression (variable name)
;;;                                                                 expr_type = "identifier" (pad)
;--	load_rr_var pad = -8(FP), SP at -35 (8 bit)
	MOVE	27(SP), RS
;;;                                                               } 31 Expression (variable name)
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;;;                                                               { 31 Expr (l , r)
;;;                                                                 { 32 ParameterDeclaration
;;;                                                                   isEllipsis = false
;;;                                                                   { 33 TypeName
;;;                                                                     { 34 TypeSpecifier (all)
;;;                                                                       spec = char (20000)
;;;                                                                     } 34 TypeSpecifier (all)
;;;                                                                     { 34 List<DeclItem>
;;;                                                                       { 35 DeclItem
;;;                                                                         what = DECL_NAME
;;;                                                                         name = sign
;;;                                                                       } 35 DeclItem
;;;                                                                     } 34 List<DeclItem>
;;;                                                                   } 33 TypeName
;;;                                                                 } 32 ParameterDeclaration
;;;                                                                 { 32 Expression (variable name)
;;;                                                                   expr_type = "identifier" (sign)
;--	load_rr_var sign = -7(FP), SP at -36 (8 bit)
	MOVE	29(SP), RS
;;;                                                                 } 32 Expression (variable name)
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;;;                                                                 { 32 Expr (l , r)
;;;                                                                   { 33 ParameterDeclaration
;;;                                                                     isEllipsis = false
;;;                                                                     { 34 TypeName
;;;                                                                       { 35 TypeSpecifier (all)
;;;                                                                         spec = char (20000)
;;;                                                                       } 35 TypeSpecifier (all)
;;;                                                                       { 35 List<DeclItem>
;;;                                                                         { 36 DeclItem
;;;                                                                           what = DECL_NAME
;;;                                                                           name = flags
;;;                                                                         } 36 DeclItem
;;;                                                                       } 35 List<DeclItem>
;;;                                                                     } 34 TypeName
;;;                                                                   } 33 ParameterDeclaration
;;;                                                                   { 33 Expression (variable name)
;;;                                                                     expr_type = "identifier" (flags)
;--	load_rr_var flags = -6(FP), SP at -37 (8 bit)
	MOVE	31(SP), RS
;;;                                                                   } 33 Expression (variable name)
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;;;                                                                   { 33 ParameterDeclaration
;;;                                                                     isEllipsis = false
;;;                                                                     { 34 TypeName
;;;                                                                       { 35 TypeSpecifier (all)
;;;                                                                         spec = const char (20100)
;;;                                                                       } 35 TypeSpecifier (all)
;;;                                                                       { 35 List<DeclItem>
;;;                                                                         { 36 DeclItem
;;;                                                                           what = DECL_POINTER
;;;                                                                           { 37 List<Ptr>
;;;                                                                             { 38 Ptr
;;;                                                                             } 38 Ptr
;;;                                                                           } 37 List<Ptr>
;;;                                                                         } 36 DeclItem
;;;                                                                         { 36 DeclItem
;;;                                                                           what = DECL_NAME
;;;                                                                           name = buffer
;;;                                                                         } 36 DeclItem
;;;                                                                       } 35 List<DeclItem>
;;;                                                                     } 34 TypeName
;;;                                                                   } 33 ParameterDeclaration
;--	load_address buffer = -28(FP), SP at -38
	LEA	10(SP), RR
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                                                 } 32 Expr (l , r)
;;;                                                               } 31 Expr (l , r)
;;;                                                             } 30 Expr (l , r)
;;;                                                           } 29 Expr (l , r)
;;;                                                         } 28 Expr (l , r)
;;;                                                       } 27 Expr (l , r)
;;;                                                     } 26 Expr (l , r)
;--	push 2 bytes
;--	call
	CALL	Cprint_item
;--	pop 12 bytes
	ADD	SP, #12
;;;                                                   } 25 Expr l(r)
;;;                                                   { 25 Expression (variable name)
;;;                                                     expr_type = "identifier" (len)
;--	load_ll_var len = -4(FP), SP at -28 (16 bit)
	MOVE	24(SP), LL
;;;                                                   } 25 Expression (variable name)
;--	scale_rr *1
;--	l + r
	ADD	LL, RR
;;;                                                 } 24 Expr l + r
;--	store_rr_var len = -4(FP), SP at -28
	MOVE	RR, 24(SP)
;;;                                               } 23 Expr l += r
;;;                                             } 22 ExpressionStatement
;;;                                             { 22 break/continue Statement
;--	branch
	JMP	L12_brk_42
;;;                                             } 22 break/continue Statement
;;;                                             { 22 case Statement
L12_case_42_0063:
;;;                                               { 23 ExpressionStatement
;;;                                                 { 24 Expr l += r
;;;                                                   { 25 TypeName
;;;                                                     { 26 TypeSpecifier (all)
;;;                                                       spec = int (80000)
;;;                                                     } 26 TypeSpecifier (all)
;;;                                                     { 26 List<DeclItem>
;;;                                                       { 27 DeclItem
;;;                                                         what = DECL_NAME
;;;                                                         name = len
;;;                                                       } 27 DeclItem
;;;                                                     } 26 List<DeclItem>
;;;                                                   } 25 TypeName
;;;                                                   { 25 Expr l + r
;;;                                                     { 26 Expr l(r)
;;;                                                       { 27 TypeName
;;;                                                         { 28 TypeSpecifier (all)
;;;                                                           spec = int (80000)
;;;                                                         } 28 TypeSpecifier (all)
;;;                                                         { 28 List<DeclItem>
;;;                                                           { 29 DeclItem
;;;                                                             what = DECL_NAME
;;;                                                             name = putchr
;;;                                                           } 29 DeclItem
;;;                                                         } 28 List<DeclItem>
;;;                                                       } 27 TypeName
;;;                                                       { 27 ParameterDeclaration
;;;                                                         isEllipsis = false
;;;                                                         { 28 TypeName
;;;                                                           { 29 TypeSpecifier (all)
;;;                                                             spec = char (20000)
;;;                                                           } 29 TypeSpecifier (all)
;;;                                                           { 29 List<DeclItem>
;;;                                                             { 30 DeclItem
;;;                                                               what = DECL_NAME
;;;                                                               name = c
;;;                                                             } 30 DeclItem
;;;                                                           } 29 List<DeclItem>
;;;                                                         } 28 TypeName
;;;                                                       } 27 ParameterDeclaration
;;;                                                       { 27 Expression (cast)r
;;;                                                         { 28 Expr * r
;;;                                                           { 29 Expr l - r
;;;                                                             { 30 Expr ++r
;;;                                                               { 31 Expression (variable name)
;;;                                                                 expr_type = "identifier" (args)
;--	load_rr_var args = -2(FP), SP at -28 (16 bit)
	MOVE	26(SP), RR
;;;                                                               } 31 Expression (variable name)
;--	++
	ADD	RR, #0x0002
;--	store_rr_var args = -2(FP), SP at -28
	MOVE	RR, 26(SP)
;;;                                                             } 30 Expr ++r
;--	l - r
	SUB	RR, #0x0002
;;;                                                           } 29 Expr l - r
;--	content
	MOVE	(RR), RR
;;;                                                         } 28 Expr * r
;;;                                                       } 27 Expression (cast)r
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;--	push 2 bytes
;--	call
	CALL	Cputchr
;--	pop 1 bytes
	ADD	SP, #1
;;;                                                     } 26 Expr l(r)
;;;                                                     { 26 Expression (variable name)
;;;                                                       expr_type = "identifier" (len)
;--	load_ll_var len = -4(FP), SP at -28 (16 bit)
	MOVE	24(SP), LL
;;;                                                     } 26 Expression (variable name)
;--	scale_rr *1
;--	l + r
	ADD	LL, RR
;;;                                                   } 25 Expr l + r
;--	store_rr_var len = -4(FP), SP at -28
	MOVE	RR, 24(SP)
;;;                                                 } 24 Expr l += r
;;;                                               } 23 ExpressionStatement
;;;                                             } 22 case Statement
;;;                                             { 22 break/continue Statement
;--	branch
	JMP	L12_brk_42
;;;                                             } 22 break/continue Statement
;;;                                             { 22 case Statement
L12_case_42_0023:
;;;                                               { 23 ExpressionStatement
;;;                                                 { 24 Expr l | r
;;;                                                   { 25 TypeName
;;;                                                     { 26 TypeSpecifier (all)
;;;                                                       spec = char (20000)
;;;                                                     } 26 TypeSpecifier (all)
;;;                                                     { 26 List<DeclItem>
;;;                                                       { 27 DeclItem
;;;                                                         what = DECL_NAME
;;;                                                         name = flags
;;;                                                       } 27 DeclItem
;;;                                                     } 26 List<DeclItem>
;;;                                                   } 25 TypeName
;;;                                                   { 25 Expr l | r
;;;                                                     { 26 TypeName (internal)
;;;                                                       { 27 TypeSpecifier (all)
;;;                                                         spec = int (80000)
;;;                                                       } 27 TypeSpecifier (all)
;;;                                                     } 26 TypeName (internal)
;;;                                                     { 26 Expression (variable name)
;;;                                                       expr_type = "identifier" (flags)
;--	load_rr_var flags = -6(FP), SP at -28 (8 bit)
	MOVE	22(SP), RS
;;;                                                     } 26 Expression (variable name)
;--	l | r
	OR	RR, #0x0001
;;;                                                   } 25 Expr l | r
;--	store_rr_var flags = -6(FP), SP at -28
	MOVE	R, 22(SP)
;;;                                                 } 24 Expr l | r
;;;                                               } 23 ExpressionStatement
;;;                                             } 22 case Statement
;;;                                             { 22 break/continue Statement
;--	branch
	JMP	L12_cont_40
;;;                                             } 22 break/continue Statement
;;;                                             { 22 case Statement
L12_case_42_002D:
;;;                                               { 23 ExpressionStatement
;;;                                                 { 24 Expr l | r
;;;                                                   { 25 TypeName
;;;                                                     { 26 TypeSpecifier (all)
;;;                                                       spec = char (20000)
;;;                                                     } 26 TypeSpecifier (all)
;;;                                                     { 26 List<DeclItem>
;;;                                                       { 27 DeclItem
;;;                                                         what = DECL_NAME
;;;                                                         name = flags
;;;                                                       } 27 DeclItem
;;;                                                     } 26 List<DeclItem>
;;;                                                   } 25 TypeName
;;;                                                   { 25 Expr l | r
;;;                                                     { 26 TypeName (internal)
;;;                                                       { 27 TypeSpecifier (all)
;;;                                                         spec = int (80000)
;;;                                                       } 27 TypeSpecifier (all)
;;;                                                     } 26 TypeName (internal)
;;;                                                     { 26 Expression (variable name)
;;;                                                       expr_type = "identifier" (flags)
;--	load_rr_var flags = -6(FP), SP at -28 (8 bit)
	MOVE	22(SP), RS
;;;                                                     } 26 Expression (variable name)
;--	l | r
	OR	RR, #0x0002
;;;                                                   } 25 Expr l | r
;--	store_rr_var flags = -6(FP), SP at -28
	MOVE	R, 22(SP)
;;;                                                 } 24 Expr l | r
;;;                                               } 23 ExpressionStatement
;;;                                             } 22 case Statement
;;;                                             { 22 break/continue Statement
;--	branch
	JMP	L12_cont_40
;;;                                             } 22 break/continue Statement
;;;                                             { 22 case Statement
L12_case_42_0020:
;;;                                               { 23 IfElseStatement
;;;                                                 { 24 Expr ! r
;;;                                                   { 25 Expression (variable name)
;;;                                                     expr_type = "identifier" (sign)
;--	load_rr_var sign = -7(FP), SP at -28 (8 bit)
	MOVE	21(SP), RS
;;;                                                   } 25 Expression (variable name)
;--	16 bit ! r
	LNOT	RR
;;;                                                 } 24 Expr ! r
;--	branch_false
	JMP	RRZ, L12_endif_44
;;;                                                 { 24 ExpressionStatement
;;;                                                   { 25 Expr l = r
;;;                                                     { 26 TypeName
;;;                                                       { 27 TypeSpecifier (all)
;;;                                                         spec = char (20000)
;;;                                                       } 27 TypeSpecifier (all)
;;;                                                       { 27 List<DeclItem>
;;;                                                         { 28 DeclItem
;;;                                                           what = DECL_NAME
;;;                                                           name = sign
;;;                                                         } 28 DeclItem
;;;                                                       } 27 List<DeclItem>
;;;                                                     } 26 TypeName
;;;                                                     { 26 NumericExpression (constant 32 = 0x20)
;--	load_rr_constant
	MOVE	#0x0020, RR
;;;                                                     } 26 NumericExpression (constant 32 = 0x20)
;--	store_rr_var sign = -7(FP), SP at -28
	MOVE	R, 21(SP)
;;;                                                   } 25 Expr l = r
;;;                                                 } 24 ExpressionStatement
L12_endif_44:
;;;                                               } 23 IfElseStatement
;;;                                             } 22 case Statement
;;;                                             { 22 break/continue Statement
;--	branch
	JMP	L12_cont_40
;;;                                             } 22 break/continue Statement
;;;                                             { 22 case Statement
L12_case_42_002B:
;;;                                               { 23 ExpressionStatement
;;;                                                 { 24 Expr l = r
;;;                                                   { 25 TypeName
;;;                                                     { 26 TypeSpecifier (all)
;;;                                                       spec = char (20000)
;;;                                                     } 26 TypeSpecifier (all)
;;;                                                     { 26 List<DeclItem>
;;;                                                       { 27 DeclItem
;;;                                                         what = DECL_NAME
;;;                                                         name = sign
;;;                                                       } 27 DeclItem
;;;                                                     } 26 List<DeclItem>
;;;                                                   } 25 TypeName
;;;                                                   { 25 NumericExpression (constant 43 = 0x2B)
;--	load_rr_constant
	MOVE	#0x002B, RR
;;;                                                   } 25 NumericExpression (constant 43 = 0x2B)
;--	store_rr_var sign = -7(FP), SP at -28
	MOVE	R, 21(SP)
;;;                                                 } 24 Expr l = r
;;;                                               } 23 ExpressionStatement
;;;                                             } 22 case Statement
;;;                                             { 22 break/continue Statement
;--	branch
	JMP	L12_cont_40
;;;                                             } 22 break/continue Statement
;;;                                             { 22 case Statement
L12_case_42_002E:
;;;                                               { 23 ExpressionStatement
;;;                                                 { 24 Expr l = r
;;;                                                   { 25 TypeName
;;;                                                     { 26 TypeSpecifier (all)
;;;                                                       spec = unsigned int (82000)
;;;                                                     } 26 TypeSpecifier (all)
;;;                                                     { 26 List<DeclItem>
;;;                                                       { 27 DeclItem
;;;                                                         what = DECL_POINTER
;;;                                                         { 28 List<Ptr>
;;;                                                           { 29 Ptr
;;;                                                           } 29 Ptr
;;;                                                         } 28 List<Ptr>
;;;                                                       } 27 DeclItem
;;;                                                       { 27 DeclItem
;;;                                                         what = DECL_NAME
;;;                                                         name = which_w
;;;                                                       } 27 DeclItem
;;;                                                     } 26 List<DeclItem>
;;;                                                   } 25 TypeName
;;;                                                   { 25 Expr & r
;--	load_address min_w = -14(FP), SP at -28
	LEA	14(SP), RR
;;;                                                   } 25 Expr & r
;--	store_rr_var which_w = -16(FP), SP at -28
	MOVE	RR, 12(SP)
;;;                                                 } 24 Expr l = r
;;;                                               } 23 ExpressionStatement
;;;                                             } 22 case Statement
;;;                                             { 22 break/continue Statement
;--	branch
	JMP	L12_cont_40
;;;                                             } 22 break/continue Statement
;;;                                             { 22 case Statement
L12_case_42_0030:
;;;                                               { 23 IfElseStatement
;;;                                                 { 24 Expr * r
;;;                                                   { 25 Expression (variable name)
;;;                                                     expr_type = "identifier" (which_w)
;--	load_rr_var which_w = -16(FP), SP at -28 (16 bit)
	MOVE	12(SP), RR
;;;                                                   } 25 Expression (variable name)
;--	content
	MOVE	(RR), RR
;;;                                                 } 24 Expr * r
;--	branch_false
	JMP	RRZ, L12_else_45
;;;                                                 { 24 ExpressionStatement
;;;                                                   { 25 Expr l *- r
;;;                                                     { 26 TypeName
;;;                                                       { 27 TypeSpecifier (all)
;;;                                                         spec = unsigned int (82000)
;;;                                                       } 27 TypeSpecifier (all)
;;;                                                       { 27 List<DeclItem>
;;;                                                         { 28 DeclItem
;;;                                                           what = DECL_NAME
;;;                                                           name = which_w
;;;                                                         } 28 DeclItem
;;;                                                       } 27 List<DeclItem>
;;;                                                     } 26 TypeName
;;;                                                     { 26 Expr l * r
;;;                                                       { 27 TypeName (internal)
;;;                                                         { 28 TypeSpecifier (all)
;;;                                                           spec = unsigned int (82000)
;;;                                                         } 28 TypeSpecifier (all)
;;;                                                       } 27 TypeName (internal)
;;;                                                       { 27 Expr * r
;;;                                                         { 28 Expression (variable name)
;;;                                                           expr_type = "identifier" (which_w)
;--	load_rr_var which_w = -16(FP), SP at -28 (16 bit)
	MOVE	12(SP), RR
;;;                                                         } 28 Expression (variable name)
;--	content
	MOVE	(RR), RR
;;;                                                       } 27 Expr * r
;--	l * r
	MOVE	RR, LL
	MOVE	#0x000A, RR
;--	l * r
	DI
	MUL_IU
	CALL	mult_div
	MD_FIN
	EI
;;;                                                     } 26 Expr l * r
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                                     { 26 Expr * r
;;;                                                       { 27 Expression (variable name)
;;;                                                         expr_type = "identifier" (which_w)
;--	load_rr_var which_w = -16(FP), SP at -30 (16 bit)
	MOVE	14(SP), RR
;;;                                                       } 27 Expression (variable name)
;;;                                                     } 26 Expr * r
;--	move_rr_to_ll
	MOVE	RR, LL
;--	pop_rr (16 bit)
	MOVE	(SP)+, RR
;--	assign (16 bit)
	MOVE	RR, (LL)
;;;                                                   } 25 Expr l *- r
;;;                                                 } 24 ExpressionStatement
;--	branch
	JMP	L12_endif_45
L12_else_45:
;;;                                                 { 24 ExpressionStatement
;;;                                                   { 25 Expr l = r
;;;                                                     { 26 TypeName
;;;                                                       { 27 TypeSpecifier (all)
;;;                                                         spec = char (20000)
;;;                                                       } 27 TypeSpecifier (all)
;;;                                                       { 27 List<DeclItem>
;;;                                                         { 28 DeclItem
;;;                                                           what = DECL_NAME
;;;                                                           name = pad
;;;                                                         } 28 DeclItem
;;;                                                       } 27 List<DeclItem>
;;;                                                     } 26 TypeName
;;;                                                     { 26 NumericExpression (constant 48 = 0x30)
;--	load_rr_constant
	MOVE	#0x0030, RR
;;;                                                     } 26 NumericExpression (constant 48 = 0x30)
;--	store_rr_var pad = -8(FP), SP at -28
	MOVE	R, 20(SP)
;;;                                                   } 25 Expr l = r
;;;                                                 } 24 ExpressionStatement
L12_endif_45:
;;;                                               } 23 IfElseStatement
;;;                                             } 22 case Statement
;;;                                             { 22 break/continue Statement
;--	branch
	JMP	L12_cont_40
;;;                                             } 22 break/continue Statement
;;;                                             { 22 case Statement
L12_case_42_0031:
;;;                                               { 23 ExpressionStatement
;;;                                                 { 24 Expr l = r
;;;                                                   { 25 TypeName
;;;                                                     { 26 TypeSpecifier (all)
;;;                                                       spec = unsigned int (82000)
;;;                                                     } 26 TypeSpecifier (all)
;;;                                                     { 26 List<DeclItem>
;;;                                                       { 27 DeclItem
;;;                                                         what = DECL_NAME
;;;                                                         name = which_w
;;;                                                       } 27 DeclItem
;;;                                                     } 26 List<DeclItem>
;;;                                                   } 25 TypeName
;;;                                                   { 25 Expr l + r
;;;                                                     { 26 Expr l * r
;;;                                                       { 27 TypeName (internal)
;;;                                                         { 28 TypeSpecifier (all)
;;;                                                           spec = unsigned int (82000)
;;;                                                         } 28 TypeSpecifier (all)
;;;                                                       } 27 TypeName (internal)
;;;                                                       { 27 Expr * r
;;;                                                         { 28 Expression (variable name)
;;;                                                           expr_type = "identifier" (which_w)
;--	load_rr_var which_w = -16(FP), SP at -28 (16 bit)
	MOVE	12(SP), RR
;;;                                                         } 28 Expression (variable name)
;--	content
	MOVE	(RR), RR
;;;                                                       } 27 Expr * r
;--	l * r
	MOVE	RR, LL
	MOVE	#0x000A, RR
;--	l * r
	DI
	MUL_IU
	CALL	mult_div
	MD_FIN
	EI
;;;                                                     } 26 Expr l * r
;--	l + r
	ADD	RR, #0x0001
;;;                                                   } 25 Expr l + r
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                                   { 25 Expr * r
;;;                                                     { 26 Expression (variable name)
;;;                                                       expr_type = "identifier" (which_w)
;--	load_rr_var which_w = -16(FP), SP at -30 (16 bit)
	MOVE	14(SP), RR
;;;                                                     } 26 Expression (variable name)
;;;                                                   } 25 Expr * r
;--	move_rr_to_ll
	MOVE	RR, LL
;--	pop_rr (16 bit)
	MOVE	(SP)+, RR
;--	assign (16 bit)
	MOVE	RR, (LL)
;;;                                                 } 24 Expr l = r
;;;                                               } 23 ExpressionStatement
;;;                                             } 22 case Statement
;;;                                             { 22 break/continue Statement
;--	branch
	JMP	L12_cont_40
;;;                                             } 22 break/continue Statement
;;;                                             { 22 case Statement
L12_case_42_0032:
;;;                                               { 23 ExpressionStatement
;;;                                                 { 24 Expr l = r
;;;                                                   { 25 TypeName
;;;                                                     { 26 TypeSpecifier (all)
;;;                                                       spec = unsigned int (82000)
;;;                                                     } 26 TypeSpecifier (all)
;;;                                                     { 26 List<DeclItem>
;;;                                                       { 27 DeclItem
;;;                                                         what = DECL_NAME
;;;                                                         name = which_w
;;;                                                       } 27 DeclItem
;;;                                                     } 26 List<DeclItem>
;;;                                                   } 25 TypeName
;;;                                                   { 25 Expr l + r
;;;                                                     { 26 Expr l * r
;;;                                                       { 27 TypeName (internal)
;;;                                                         { 28 TypeSpecifier (all)
;;;                                                           spec = unsigned int (82000)
;;;                                                         } 28 TypeSpecifier (all)
;;;                                                       } 27 TypeName (internal)
;;;                                                       { 27 Expr * r
;;;                                                         { 28 Expression (variable name)
;;;                                                           expr_type = "identifier" (which_w)
;--	load_rr_var which_w = -16(FP), SP at -28 (16 bit)
	MOVE	12(SP), RR
;;;                                                         } 28 Expression (variable name)
;--	content
	MOVE	(RR), RR
;;;                                                       } 27 Expr * r
;--	l * r
	MOVE	RR, LL
	MOVE	#0x000A, RR
;--	l * r
	DI
	MUL_IU
	CALL	mult_div
	MD_FIN
	EI
;;;                                                     } 26 Expr l * r
;--	l + r
	ADD	RR, #0x0002
;;;                                                   } 25 Expr l + r
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                                   { 25 Expr * r
;;;                                                     { 26 Expression (variable name)
;;;                                                       expr_type = "identifier" (which_w)
;--	load_rr_var which_w = -16(FP), SP at -30 (16 bit)
	MOVE	14(SP), RR
;;;                                                     } 26 Expression (variable name)
;;;                                                   } 25 Expr * r
;--	move_rr_to_ll
	MOVE	RR, LL
;--	pop_rr (16 bit)
	MOVE	(SP)+, RR
;--	assign (16 bit)
	MOVE	RR, (LL)
;;;                                                 } 24 Expr l = r
;;;                                               } 23 ExpressionStatement
;;;                                             } 22 case Statement
;;;                                             { 22 break/continue Statement
;--	branch
	JMP	L12_cont_40
;;;                                             } 22 break/continue Statement
;;;                                             { 22 case Statement
L12_case_42_0033:
;;;                                               { 23 ExpressionStatement
;;;                                                 { 24 Expr l = r
;;;                                                   { 25 TypeName
;;;                                                     { 26 TypeSpecifier (all)
;;;                                                       spec = unsigned int (82000)
;;;                                                     } 26 TypeSpecifier (all)
;;;                                                     { 26 List<DeclItem>
;;;                                                       { 27 DeclItem
;;;                                                         what = DECL_NAME
;;;                                                         name = which_w
;;;                                                       } 27 DeclItem
;;;                                                     } 26 List<DeclItem>
;;;                                                   } 25 TypeName
;;;                                                   { 25 Expr l + r
;;;                                                     { 26 Expr l * r
;;;                                                       { 27 TypeName (internal)
;;;                                                         { 28 TypeSpecifier (all)
;;;                                                           spec = unsigned int (82000)
;;;                                                         } 28 TypeSpecifier (all)
;;;                                                       } 27 TypeName (internal)
;;;                                                       { 27 Expr * r
;;;                                                         { 28 Expression (variable name)
;;;                                                           expr_type = "identifier" (which_w)
;--	load_rr_var which_w = -16(FP), SP at -28 (16 bit)
	MOVE	12(SP), RR
;;;                                                         } 28 Expression (variable name)
;--	content
	MOVE	(RR), RR
;;;                                                       } 27 Expr * r
;--	l * r
	MOVE	RR, LL
	MOVE	#0x000A, RR
;--	l * r
	DI
	MUL_IU
	CALL	mult_div
	MD_FIN
	EI
;;;                                                     } 26 Expr l * r
;--	l + r
	ADD	RR, #0x0003
;;;                                                   } 25 Expr l + r
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                                   { 25 Expr * r
;;;                                                     { 26 Expression (variable name)
;;;                                                       expr_type = "identifier" (which_w)
;--	load_rr_var which_w = -16(FP), SP at -30 (16 bit)
	MOVE	14(SP), RR
;;;                                                     } 26 Expression (variable name)
;;;                                                   } 25 Expr * r
;--	move_rr_to_ll
	MOVE	RR, LL
;--	pop_rr (16 bit)
	MOVE	(SP)+, RR
;--	assign (16 bit)
	MOVE	RR, (LL)
;;;                                                 } 24 Expr l = r
;;;                                               } 23 ExpressionStatement
;;;                                             } 22 case Statement
;;;                                             { 22 break/continue Statement
;--	branch
	JMP	L12_cont_40
;;;                                             } 22 break/continue Statement
;;;                                             { 22 case Statement
L12_case_42_0034:
;;;                                               { 23 ExpressionStatement
;;;                                                 { 24 Expr l = r
;;;                                                   { 25 TypeName
;;;                                                     { 26 TypeSpecifier (all)
;;;                                                       spec = unsigned int (82000)
;;;                                                     } 26 TypeSpecifier (all)
;;;                                                     { 26 List<DeclItem>
;;;                                                       { 27 DeclItem
;;;                                                         what = DECL_NAME
;;;                                                         name = which_w
;;;                                                       } 27 DeclItem
;;;                                                     } 26 List<DeclItem>
;;;                                                   } 25 TypeName
;;;                                                   { 25 Expr l + r
;;;                                                     { 26 Expr l * r
;;;                                                       { 27 TypeName (internal)
;;;                                                         { 28 TypeSpecifier (all)
;;;                                                           spec = unsigned int (82000)
;;;                                                         } 28 TypeSpecifier (all)
;;;                                                       } 27 TypeName (internal)
;;;                                                       { 27 Expr * r
;;;                                                         { 28 Expression (variable name)
;;;                                                           expr_type = "identifier" (which_w)
;--	load_rr_var which_w = -16(FP), SP at -28 (16 bit)
	MOVE	12(SP), RR
;;;                                                         } 28 Expression (variable name)
;--	content
	MOVE	(RR), RR
;;;                                                       } 27 Expr * r
;--	l * r
	MOVE	RR, LL
	MOVE	#0x000A, RR
;--	l * r
	DI
	MUL_IU
	CALL	mult_div
	MD_FIN
	EI
;;;                                                     } 26 Expr l * r
;--	l + r
	ADD	RR, #0x0004
;;;                                                   } 25 Expr l + r
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                                   { 25 Expr * r
;;;                                                     { 26 Expression (variable name)
;;;                                                       expr_type = "identifier" (which_w)
;--	load_rr_var which_w = -16(FP), SP at -30 (16 bit)
	MOVE	14(SP), RR
;;;                                                     } 26 Expression (variable name)
;;;                                                   } 25 Expr * r
;--	move_rr_to_ll
	MOVE	RR, LL
;--	pop_rr (16 bit)
	MOVE	(SP)+, RR
;--	assign (16 bit)
	MOVE	RR, (LL)
;;;                                                 } 24 Expr l = r
;;;                                               } 23 ExpressionStatement
;;;                                             } 22 case Statement
;;;                                             { 22 break/continue Statement
;--	branch
	JMP	L12_cont_40
;;;                                             } 22 break/continue Statement
;;;                                             { 22 case Statement
L12_case_42_0035:
;;;                                               { 23 ExpressionStatement
;;;                                                 { 24 Expr l = r
;;;                                                   { 25 TypeName
;;;                                                     { 26 TypeSpecifier (all)
;;;                                                       spec = unsigned int (82000)
;;;                                                     } 26 TypeSpecifier (all)
;;;                                                     { 26 List<DeclItem>
;;;                                                       { 27 DeclItem
;;;                                                         what = DECL_NAME
;;;                                                         name = which_w
;;;                                                       } 27 DeclItem
;;;                                                     } 26 List<DeclItem>
;;;                                                   } 25 TypeName
;;;                                                   { 25 Expr l + r
;;;                                                     { 26 Expr l * r
;;;                                                       { 27 TypeName (internal)
;;;                                                         { 28 TypeSpecifier (all)
;;;                                                           spec = unsigned int (82000)
;;;                                                         } 28 TypeSpecifier (all)
;;;                                                       } 27 TypeName (internal)
;;;                                                       { 27 Expr * r
;;;                                                         { 28 Expression (variable name)
;;;                                                           expr_type = "identifier" (which_w)
;--	load_rr_var which_w = -16(FP), SP at -28 (16 bit)
	MOVE	12(SP), RR
;;;                                                         } 28 Expression (variable name)
;--	content
	MOVE	(RR), RR
;;;                                                       } 27 Expr * r
;--	l * r
	MOVE	RR, LL
	MOVE	#0x000A, RR
;--	l * r
	DI
	MUL_IU
	CALL	mult_div
	MD_FIN
	EI
;;;                                                     } 26 Expr l * r
;--	l + r
	ADD	RR, #0x0005
;;;                                                   } 25 Expr l + r
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                                   { 25 Expr * r
;;;                                                     { 26 Expression (variable name)
;;;                                                       expr_type = "identifier" (which_w)
;--	load_rr_var which_w = -16(FP), SP at -30 (16 bit)
	MOVE	14(SP), RR
;;;                                                     } 26 Expression (variable name)
;;;                                                   } 25 Expr * r
;--	move_rr_to_ll
	MOVE	RR, LL
;--	pop_rr (16 bit)
	MOVE	(SP)+, RR
;--	assign (16 bit)
	MOVE	RR, (LL)
;;;                                                 } 24 Expr l = r
;;;                                               } 23 ExpressionStatement
;;;                                             } 22 case Statement
;;;                                             { 22 break/continue Statement
;--	branch
	JMP	L12_cont_40
;;;                                             } 22 break/continue Statement
;;;                                             { 22 case Statement
L12_case_42_0036:
;;;                                               { 23 ExpressionStatement
;;;                                                 { 24 Expr l = r
;;;                                                   { 25 TypeName
;;;                                                     { 26 TypeSpecifier (all)
;;;                                                       spec = unsigned int (82000)
;;;                                                     } 26 TypeSpecifier (all)
;;;                                                     { 26 List<DeclItem>
;;;                                                       { 27 DeclItem
;;;                                                         what = DECL_NAME
;;;                                                         name = which_w
;;;                                                       } 27 DeclItem
;;;                                                     } 26 List<DeclItem>
;;;                                                   } 25 TypeName
;;;                                                   { 25 Expr l + r
;;;                                                     { 26 Expr l * r
;;;                                                       { 27 TypeName (internal)
;;;                                                         { 28 TypeSpecifier (all)
;;;                                                           spec = unsigned int (82000)
;;;                                                         } 28 TypeSpecifier (all)
;;;                                                       } 27 TypeName (internal)
;;;                                                       { 27 Expr * r
;;;                                                         { 28 Expression (variable name)
;;;                                                           expr_type = "identifier" (which_w)
;--	load_rr_var which_w = -16(FP), SP at -28 (16 bit)
	MOVE	12(SP), RR
;;;                                                         } 28 Expression (variable name)
;--	content
	MOVE	(RR), RR
;;;                                                       } 27 Expr * r
;--	l * r
	MOVE	RR, LL
	MOVE	#0x000A, RR
;--	l * r
	DI
	MUL_IU
	CALL	mult_div
	MD_FIN
	EI
;;;                                                     } 26 Expr l * r
;--	l + r
	ADD	RR, #0x0006
;;;                                                   } 25 Expr l + r
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                                   { 25 Expr * r
;;;                                                     { 26 Expression (variable name)
;;;                                                       expr_type = "identifier" (which_w)
;--	load_rr_var which_w = -16(FP), SP at -30 (16 bit)
	MOVE	14(SP), RR
;;;                                                     } 26 Expression (variable name)
;;;                                                   } 25 Expr * r
;--	move_rr_to_ll
	MOVE	RR, LL
;--	pop_rr (16 bit)
	MOVE	(SP)+, RR
;--	assign (16 bit)
	MOVE	RR, (LL)
;;;                                                 } 24 Expr l = r
;;;                                               } 23 ExpressionStatement
;;;                                             } 22 case Statement
;;;                                             { 22 break/continue Statement
;--	branch
	JMP	L12_cont_40
;;;                                             } 22 break/continue Statement
;;;                                             { 22 case Statement
L12_case_42_0037:
;;;                                               { 23 ExpressionStatement
;;;                                                 { 24 Expr l = r
;;;                                                   { 25 TypeName
;;;                                                     { 26 TypeSpecifier (all)
;;;                                                       spec = unsigned int (82000)
;;;                                                     } 26 TypeSpecifier (all)
;;;                                                     { 26 List<DeclItem>
;;;                                                       { 27 DeclItem
;;;                                                         what = DECL_NAME
;;;                                                         name = which_w
;;;                                                       } 27 DeclItem
;;;                                                     } 26 List<DeclItem>
;;;                                                   } 25 TypeName
;;;                                                   { 25 Expr l + r
;;;                                                     { 26 Expr l * r
;;;                                                       { 27 TypeName (internal)
;;;                                                         { 28 TypeSpecifier (all)
;;;                                                           spec = unsigned int (82000)
;;;                                                         } 28 TypeSpecifier (all)
;;;                                                       } 27 TypeName (internal)
;;;                                                       { 27 Expr * r
;;;                                                         { 28 Expression (variable name)
;;;                                                           expr_type = "identifier" (which_w)
;--	load_rr_var which_w = -16(FP), SP at -28 (16 bit)
	MOVE	12(SP), RR
;;;                                                         } 28 Expression (variable name)
;--	content
	MOVE	(RR), RR
;;;                                                       } 27 Expr * r
;--	l * r
	MOVE	RR, LL
	MOVE	#0x000A, RR
;--	l * r
	DI
	MUL_IU
	CALL	mult_div
	MD_FIN
	EI
;;;                                                     } 26 Expr l * r
;--	l + r
	ADD	RR, #0x0007
;;;                                                   } 25 Expr l + r
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                                   { 25 Expr * r
;;;                                                     { 26 Expression (variable name)
;;;                                                       expr_type = "identifier" (which_w)
;--	load_rr_var which_w = -16(FP), SP at -30 (16 bit)
	MOVE	14(SP), RR
;;;                                                     } 26 Expression (variable name)
;;;                                                   } 25 Expr * r
;--	move_rr_to_ll
	MOVE	RR, LL
;--	pop_rr (16 bit)
	MOVE	(SP)+, RR
;--	assign (16 bit)
	MOVE	RR, (LL)
;;;                                                 } 24 Expr l = r
;;;                                               } 23 ExpressionStatement
;;;                                             } 22 case Statement
;;;                                             { 22 break/continue Statement
;--	branch
	JMP	L12_cont_40
;;;                                             } 22 break/continue Statement
;;;                                             { 22 case Statement
L12_case_42_0038:
;;;                                               { 23 ExpressionStatement
;;;                                                 { 24 Expr l = r
;;;                                                   { 25 TypeName
;;;                                                     { 26 TypeSpecifier (all)
;;;                                                       spec = unsigned int (82000)
;;;                                                     } 26 TypeSpecifier (all)
;;;                                                     { 26 List<DeclItem>
;;;                                                       { 27 DeclItem
;;;                                                         what = DECL_NAME
;;;                                                         name = which_w
;;;                                                       } 27 DeclItem
;;;                                                     } 26 List<DeclItem>
;;;                                                   } 25 TypeName
;;;                                                   { 25 Expr l + r
;;;                                                     { 26 Expr l * r
;;;                                                       { 27 TypeName (internal)
;;;                                                         { 28 TypeSpecifier (all)
;;;                                                           spec = unsigned int (82000)
;;;                                                         } 28 TypeSpecifier (all)
;;;                                                       } 27 TypeName (internal)
;;;                                                       { 27 Expr * r
;;;                                                         { 28 Expression (variable name)
;;;                                                           expr_type = "identifier" (which_w)
;--	load_rr_var which_w = -16(FP), SP at -28 (16 bit)
	MOVE	12(SP), RR
;;;                                                         } 28 Expression (variable name)
;--	content
	MOVE	(RR), RR
;;;                                                       } 27 Expr * r
;--	l * r
	MOVE	RR, LL
	MOVE	#0x000A, RR
;--	l * r
	DI
	MUL_IU
	CALL	mult_div
	MD_FIN
	EI
;;;                                                     } 26 Expr l * r
;--	l + r
	ADD	RR, #0x0008
;;;                                                   } 25 Expr l + r
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                                   { 25 Expr * r
;;;                                                     { 26 Expression (variable name)
;;;                                                       expr_type = "identifier" (which_w)
;--	load_rr_var which_w = -16(FP), SP at -30 (16 bit)
	MOVE	14(SP), RR
;;;                                                     } 26 Expression (variable name)
;;;                                                   } 25 Expr * r
;--	move_rr_to_ll
	MOVE	RR, LL
;--	pop_rr (16 bit)
	MOVE	(SP)+, RR
;--	assign (16 bit)
	MOVE	RR, (LL)
;;;                                                 } 24 Expr l = r
;;;                                               } 23 ExpressionStatement
;;;                                             } 22 case Statement
;;;                                             { 22 break/continue Statement
;--	branch
	JMP	L12_cont_40
;;;                                             } 22 break/continue Statement
;;;                                             { 22 case Statement
L12_case_42_0039:
;;;                                               { 23 ExpressionStatement
;;;                                                 { 24 Expr l = r
;;;                                                   { 25 TypeName
;;;                                                     { 26 TypeSpecifier (all)
;;;                                                       spec = unsigned int (82000)
;;;                                                     } 26 TypeSpecifier (all)
;;;                                                     { 26 List<DeclItem>
;;;                                                       { 27 DeclItem
;;;                                                         what = DECL_NAME
;;;                                                         name = which_w
;;;                                                       } 27 DeclItem
;;;                                                     } 26 List<DeclItem>
;;;                                                   } 25 TypeName
;;;                                                   { 25 Expr l + r
;;;                                                     { 26 Expr l * r
;;;                                                       { 27 TypeName (internal)
;;;                                                         { 28 TypeSpecifier (all)
;;;                                                           spec = unsigned int (82000)
;;;                                                         } 28 TypeSpecifier (all)
;;;                                                       } 27 TypeName (internal)
;;;                                                       { 27 Expr * r
;;;                                                         { 28 Expression (variable name)
;;;                                                           expr_type = "identifier" (which_w)
;--	load_rr_var which_w = -16(FP), SP at -28 (16 bit)
	MOVE	12(SP), RR
;;;                                                         } 28 Expression (variable name)
;--	content
	MOVE	(RR), RR
;;;                                                       } 27 Expr * r
;--	l * r
	MOVE	RR, LL
	MOVE	#0x000A, RR
;--	l * r
	DI
	MUL_IU
	CALL	mult_div
	MD_FIN
	EI
;;;                                                     } 26 Expr l * r
;--	l + r
	ADD	RR, #0x0009
;;;                                                   } 25 Expr l + r
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                                   { 25 Expr * r
;;;                                                     { 26 Expression (variable name)
;;;                                                       expr_type = "identifier" (which_w)
;--	load_rr_var which_w = -16(FP), SP at -30 (16 bit)
	MOVE	14(SP), RR
;;;                                                     } 26 Expression (variable name)
;;;                                                   } 25 Expr * r
;--	move_rr_to_ll
	MOVE	RR, LL
;--	pop_rr (16 bit)
	MOVE	(SP)+, RR
;--	assign (16 bit)
	MOVE	RR, (LL)
;;;                                                 } 24 Expr l = r
;;;                                               } 23 ExpressionStatement
;;;                                             } 22 case Statement
;;;                                             { 22 break/continue Statement
;--	branch
	JMP	L12_cont_40
;;;                                             } 22 break/continue Statement
;;;                                             { 22 case Statement
L12_case_42_002A:
;;;                                               { 23 ExpressionStatement
;;;                                                 { 24 Expr l = r
;;;                                                   { 25 TypeName
;;;                                                     { 26 TypeSpecifier (all)
;;;                                                       spec = unsigned int (82000)
;;;                                                     } 26 TypeSpecifier (all)
;;;                                                     { 26 List<DeclItem>
;;;                                                       { 27 DeclItem
;;;                                                         what = DECL_NAME
;;;                                                         name = which_w
;;;                                                       } 27 DeclItem
;;;                                                     } 26 List<DeclItem>
;;;                                                   } 25 TypeName
;;;                                                   { 25 Expression (cast)r
;;;                                                     { 26 Expr * r
;;;                                                       { 27 Expr l - r
;;;                                                         { 28 Expr ++r
;;;                                                           { 29 Expression (variable name)
;;;                                                             expr_type = "identifier" (args)
;--	load_rr_var args = -2(FP), SP at -28 (16 bit)
	MOVE	26(SP), RR
;;;                                                           } 29 Expression (variable name)
;--	++
	ADD	RR, #0x0002
;--	store_rr_var args = -2(FP), SP at -28
	MOVE	RR, 26(SP)
;;;                                                         } 28 Expr ++r
;--	l - r
	SUB	RR, #0x0002
;;;                                                       } 27 Expr l - r
;--	content
	MOVE	(RR), RR
;;;                                                     } 26 Expr * r
;;;                                                   } 25 Expression (cast)r
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                                   { 25 Expr * r
;;;                                                     { 26 Expression (variable name)
;;;                                                       expr_type = "identifier" (which_w)
;--	load_rr_var which_w = -16(FP), SP at -30 (16 bit)
	MOVE	14(SP), RR
;;;                                                     } 26 Expression (variable name)
;;;                                                   } 25 Expr * r
;--	move_rr_to_ll
	MOVE	RR, LL
;--	pop_rr (16 bit)
	MOVE	(SP)+, RR
;--	assign (16 bit)
	MOVE	RR, (LL)
;;;                                                 } 24 Expr l = r
;;;                                               } 23 ExpressionStatement
;;;                                             } 22 case Statement
;;;                                             { 22 break/continue Statement
;--	branch
	JMP	L12_cont_40
;;;                                             } 22 break/continue Statement
;;;                                             { 22 case Statement
L12_case_42_0000:
;;;                                               { 23 ExpressionStatement
;;;                                                 { 24 Expr l + r
;;;                                                   { 25 Expr --r
;;;                                                     { 26 Expression (variable name)
;;;                                                       expr_type = "identifier" (format)
;--	load_rr_var format = 2(FP), SP at -28 (16 bit)
	MOVE	30(SP), RR
;;;                                                     } 26 Expression (variable name)
;--	--
	SUB	RR, #0x0001
;--	store_rr_var format = 2(FP), SP at -28
	MOVE	RR, 30(SP)
;;;                                                   } 25 Expr --r
;--	l + r
	ADD	RR, #0x0001
;;;                                                 } 24 Expr l + r
;;;                                               } 23 ExpressionStatement
;;;                                             } 22 case Statement
;;;                                             { 22 break/continue Statement
;--	branch
	JMP	L12_brk_42
;;;                                             } 22 break/continue Statement
;;;                                             { 22 case Statement
L12_deflt_42:
;;;                                               { 23 ExpressionStatement
;;;                                                 { 24 Expr l += r
;;;                                                   { 25 TypeName
;;;                                                     { 26 TypeSpecifier (all)
;;;                                                       spec = int (80000)
;;;                                                     } 26 TypeSpecifier (all)
;;;                                                     { 26 List<DeclItem>
;;;                                                       { 27 DeclItem
;;;                                                         what = DECL_NAME
;;;                                                         name = len
;;;                                                       } 27 DeclItem
;;;                                                     } 26 List<DeclItem>
;;;                                                   } 25 TypeName
;;;                                                   { 25 Expr l + r
;;;                                                     { 26 Expr l(r)
;;;                                                       { 27 TypeName
;;;                                                         { 28 TypeSpecifier (all)
;;;                                                           spec = int (80000)
;;;                                                         } 28 TypeSpecifier (all)
;;;                                                         { 28 List<DeclItem>
;;;                                                           { 29 DeclItem
;;;                                                             what = DECL_NAME
;;;                                                             name = putchr
;;;                                                           } 29 DeclItem
;;;                                                         } 28 List<DeclItem>
;;;                                                       } 27 TypeName
;;;                                                       { 27 ParameterDeclaration
;;;                                                         isEllipsis = false
;;;                                                         { 28 TypeName
;;;                                                           { 29 TypeSpecifier (all)
;;;                                                             spec = char (20000)
;;;                                                           } 29 TypeSpecifier (all)
;;;                                                           { 29 List<DeclItem>
;;;                                                             { 30 DeclItem
;;;                                                               what = DECL_NAME
;;;                                                               name = c
;;;                                                             } 30 DeclItem
;;;                                                           } 29 List<DeclItem>
;;;                                                         } 28 TypeName
;;;                                                       } 27 ParameterDeclaration
;;;                                                       { 27 Expression (variable name)
;;;                                                         expr_type = "identifier" (c)
;--	load_rr_var c = -5(FP), SP at -28 (8 bit)
	MOVE	23(SP), RS
;;;                                                       } 27 Expression (variable name)
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;--	push 2 bytes
;--	call
	CALL	Cputchr
;--	pop 1 bytes
	ADD	SP, #1
;;;                                                     } 26 Expr l(r)
;;;                                                     { 26 Expression (variable name)
;;;                                                       expr_type = "identifier" (len)
;--	load_ll_var len = -4(FP), SP at -28 (16 bit)
	MOVE	24(SP), LL
;;;                                                     } 26 Expression (variable name)
;--	scale_rr *1
;--	l + r
	ADD	LL, RR
;;;                                                   } 25 Expr l + r
;--	store_rr_var len = -4(FP), SP at -28
	MOVE	RR, 24(SP)
;;;                                                 } 24 Expr l += r
;;;                                               } 23 ExpressionStatement
;;;                                             } 22 case Statement
;;;                                             { 22 break/continue Statement
;--	branch
	JMP	L12_brk_42
;;;                                             } 22 break/continue Statement
;;;                                           } 21 List<case Statement>
;--	pop 0 bytes
;;;                                         } 20 CompoundStatement
L12_brk_42:
;;;                                       } 19 SwitchStatement
;;;                                       { 19 break/continue Statement
;--	branch
	JMP	L12_brk_41
;;;                                       } 19 break/continue Statement
;;;                                     } 18 List<SwitchStatement>
;--	pop 0 bytes
;;;                                   } 17 CompoundStatement
L12_cont_40:
;--	branch
	JMP	L12_loop_40
L12_brk_41:
;;;                                 } 16 for Statement
;;;                               } 15 List<IfElseStatement>
;--	pop 0 bytes
;;;                             } 14 CompoundStatement
L12_cont_37:
;;;                             { 14 Expr l = r
;;;                               { 15 TypeName
;;;                                 { 16 TypeSpecifier (all)
;;;                                   spec = char (20000)
;;;                                 } 16 TypeSpecifier (all)
;;;                                 { 16 List<DeclItem>
;;;                                   { 17 DeclItem
;;;                                     what = DECL_NAME
;;;                                     name = c
;;;                                   } 17 DeclItem
;;;                                 } 16 List<DeclItem>
;;;                               } 15 TypeName
;;;                               { 15 Expr * r
;;;                                 { 16 Expr l - r
;;;                                   { 17 Expr ++r
;;;                                     { 18 Expression (variable name)
;;;                                       expr_type = "identifier" (format)
;--	load_rr_var format = 2(FP), SP at -28 (16 bit)
	MOVE	30(SP), RR
;;;                                     } 18 Expression (variable name)
;--	++
	ADD	RR, #0x0001
;--	store_rr_var format = 2(FP), SP at -28
	MOVE	RR, 30(SP)
;;;                                   } 17 Expr ++r
;--	l - r
	SUB	RR, #0x0001
;;;                                 } 16 Expr l - r
;--	content
	MOVE	(RR), RS
;;;                               } 15 Expr * r
;--	store_rr_var c = -5(FP), SP at -28
	MOVE	R, 23(SP)
;;;                             } 14 Expr l = r
;--	branch_true
	JMP	RRNZ, L12_loop_37
L12_brk_38:
;;;                           } 13 while Statement
;;;                           { 13 return Statement
;;;                             { 14 Expression (variable name)
;;;                               expr_type = "identifier" (len)
;--	load_rr_var len = -4(FP), SP at -28 (16 bit)
	MOVE	24(SP), RR
;;;                             } 14 Expression (variable name)
;--	ret
	ADD	SP, #28
	RET
;;;                           } 13 return Statement
;;;                         } 12 List<while Statement>
;--	pop 28 bytes
	ADD	SP, #28
;;;                       } 11 CompoundStatement
;--	ret
	RET
;;; ------------------------------------;
;;;                       { 11 FunctionDefinition
;;;                         { 12 TypeName
;;;                           { 13 TypeSpecifier (all)
;;;                             spec = int (80000)
;;;                           } 13 TypeSpecifier (all)
;;;                           { 13 List<DeclItem>
;;;                             { 14 DeclItem
;;;                               what = DECL_NAME
;;;                               name = getchr
;;;                             } 14 DeclItem
;;;                           } 13 List<DeclItem>
;;;                         } 12 TypeName
;;;                         { 12 List<DeclItem>
;;;                           { 13 DeclItem
;;;                             what = DECL_NAME
;;;                             name = getchr
;;;                           } 13 DeclItem
;;;                           { 13 DeclItem
;;;                             what = DECL_FUN
;;;                           } 13 DeclItem
;;;                         } 12 List<DeclItem>
Cgetchr:
;;;                         { 12 CompoundStatement
;;;                           { 13 InitDeclarator
;;;                             { 14 List<DeclItem>
;;;                               { 15 DeclItem
;;;                                 what = DECL_NAME
;;;                                 name = c
;;;                               } 15 DeclItem
;;;                             } 14 List<DeclItem>
;--	push_zero 1 bytes
	CLRB	-(SP)
;;;                           } 13 InitDeclarator
;;;                           { 13 List<while Statement>
;;;                             { 14 while Statement
L13_loop_46:
;;;                               { 15 ExpressionStatement
;;;                               } 15 ExpressionStatement
L13_cont_46:
;;;                               { 15 Expr ! r
;;;                                 { 16 Expression (variable name)
;;;                                   expr_type = "identifier" (serial_in_length)
;--	load_rr_var serial_in_length, (8 bit)
	MOVE	(Cserial_in_length), RU
;;;                                 } 16 Expression (variable name)
;--	16 bit ! r
	LNOT	RR
;;;                               } 15 Expr ! r
;--	branch_true
	JMP	RRNZ, L13_loop_46
L13_brk_47:
;;;                             } 14 while Statement
;;;                             { 14 ExpressionStatement
;;;                               { 15 Expr l = r
;;;                                 { 16 TypeName
;;;                                   { 17 TypeSpecifier (all)
;;;                                     spec = char (20000)
;;;                                   } 17 TypeSpecifier (all)
;;;                                   { 17 List<DeclItem>
;;;                                     { 18 DeclItem
;;;                                       what = DECL_NAME
;;;                                       name = c
;;;                                     } 18 DeclItem
;;;                                   } 17 List<DeclItem>
;;;                                 } 16 TypeName
;;;                                 { 16 Expr l[r]
;;;                                   { 17 TypeName
;;;                                     { 18 TypeSpecifier (all)
;;;                                       spec = unsigned char (22000)
;;;                                     } 18 TypeSpecifier (all)
;;;                                     { 18 List<DeclItem>
;;;                                       { 19 DeclItem
;;;                                         what = DECL_NAME
;;;                                         name = serial_in_buffer
;;;                                       } 19 DeclItem
;;;                                     } 18 List<DeclItem>
;;;                                   } 17 TypeName
;;;                                   { 17 Expr l[r]
;;;                                     { 18 Expression (variable name)
;;;                                       expr_type = "identifier" (serial_in_get)
;--	load_rr_var serial_in_get, (8 bit)
	MOVE	(Cserial_in_get), RU
;;;                                     } 18 Expression (variable name)
;--	scale_rr *1
;--	add_address serial_in_buffer
	ADD	RR, #Cserial_in_buffer
;;;                                   } 17 Expr l[r]
;--	content
	MOVE	(RR), RU
;;;                                 } 16 Expr l[r]
;--	store_rr_var c = -1(FP), SP at -1
	MOVE	R, 0(SP)
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
;;;                                       name = serial_in_get
;;;                                     } 18 DeclItem
;;;                                   } 17 List<DeclItem>
;;;                                 } 16 TypeName
;;;                                 { 16 Expr l & r
;;;                                   { 17 TypeName (internal)
;;;                                     { 18 TypeSpecifier (all)
;;;                                       spec = unsigned int (82000)
;;;                                     } 18 TypeSpecifier (all)
;;;                                   } 17 TypeName (internal)
;;;                                   { 17 Expr ++r
;;;                                     { 18 Expression (variable name)
;;;                                       expr_type = "identifier" (serial_in_get)
;--	load_rr_var serial_in_get, (8 bit)
	MOVE	(Cserial_in_get), RU
;;;                                     } 18 Expression (variable name)
;--	++
	ADD	RR, #0x0001
;--	store_rr_var serial_in_get
	MOVE	R, (Cserial_in_get)
;;;                                   } 17 Expr ++r
;--	l & r
	AND	RR, #0x000F
;;;                                 } 16 Expr l & r
;--	store_rr_var serial_in_get
	MOVE	R, (Cserial_in_get)
;;;                               } 15 Expr l = r
;;;                             } 14 ExpressionStatement
;;;                             { 14 ExpressionStatement
	DI
;;;                             } 14 ExpressionStatement
;;;                             { 14 ExpressionStatement
;;;                               { 15 Expr --r
;;;                                 { 16 Expression (variable name)
;;;                                   expr_type = "identifier" (serial_in_length)
;--	load_rr_var serial_in_length, (8 bit)
	MOVE	(Cserial_in_length), RU
;;;                                 } 16 Expression (variable name)
;--	--
	SUB	RR, #0x0001
;--	store_rr_var serial_in_length
	MOVE	R, (Cserial_in_length)
;;;                               } 15 Expr --r
;;;                             } 14 ExpressionStatement
;;;                             { 14 ExpressionStatement
	EI
;;;                             } 14 ExpressionStatement
;;;                             { 14 return Statement
;;;                               { 15 Expression (variable name)
;;;                                 expr_type = "identifier" (c)
;--	load_rr_var c = -1(FP), SP at -1 (8 bit)
	MOVE	0(SP), RS
;;;                               } 15 Expression (variable name)
;--	ret
	ADD	SP, #1
	RET
;;;                             } 14 return Statement
;;;                           } 13 List<while Statement>
;--	pop 1 bytes
	ADD	SP, #1
;;;                         } 12 CompoundStatement
;--	ret
	RET
;;; ------------------------------------;
;;;                         { 12 FunctionDefinition
;;;                           { 13 TypeName
;;;                             { 14 TypeSpecifier (all)
;;;                               spec = int (80000)
;;;                             } 14 TypeSpecifier (all)
;;;                             { 14 List<DeclItem>
;;;                               { 15 DeclItem
;;;                                 what = DECL_NAME
;;;                                 name = peekchr
;;;                               } 15 DeclItem
;;;                             } 14 List<DeclItem>
;;;                           } 13 TypeName
;;;                           { 13 List<DeclItem>
;;;                             { 14 DeclItem
;;;                               what = DECL_NAME
;;;                               name = peekchr
;;;                             } 14 DeclItem
;;;                             { 14 DeclItem
;;;                               what = DECL_FUN
;;;                             } 14 DeclItem
;;;                           } 13 List<DeclItem>
Cpeekchr:
;;;                           { 13 CompoundStatement
;;;                             { 14 List<while Statement>
;;;                               { 15 while Statement
L14_loop_48:
;;;                                 { 16 ExpressionStatement
;;;                                 } 16 ExpressionStatement
L14_cont_48:
;;;                                 { 16 Expr ! r
;;;                                   { 17 Expression (variable name)
;;;                                     expr_type = "identifier" (serial_in_length)
;--	load_rr_var serial_in_length, (8 bit)
	MOVE	(Cserial_in_length), RU
;;;                                   } 17 Expression (variable name)
;--	16 bit ! r
	LNOT	RR
;;;                                 } 16 Expr ! r
;--	branch_true
	JMP	RRNZ, L14_loop_48
L14_brk_49:
;;;                               } 15 while Statement
;;;                               { 15 return Statement
;;;                                 { 16 Expr l[r]
;;;                                   { 17 TypeName
;;;                                     { 18 TypeSpecifier (all)
;;;                                       spec = unsigned char (22000)
;;;                                     } 18 TypeSpecifier (all)
;;;                                     { 18 List<DeclItem>
;;;                                       { 19 DeclItem
;;;                                         what = DECL_NAME
;;;                                         name = serial_in_buffer
;;;                                       } 19 DeclItem
;;;                                     } 18 List<DeclItem>
;;;                                   } 17 TypeName
;;;                                   { 17 Expr l[r]
;;;                                     { 18 Expression (variable name)
;;;                                       expr_type = "identifier" (serial_in_get)
;--	load_rr_var serial_in_get, (8 bit)
	MOVE	(Cserial_in_get), RU
;;;                                     } 18 Expression (variable name)
;--	scale_rr *1
;--	add_address serial_in_buffer
	ADD	RR, #Cserial_in_buffer
;;;                                   } 17 Expr l[r]
;--	content
	MOVE	(RR), RU
;;;                                 } 16 Expr l[r]
;--	ret
	RET
;;;                               } 15 return Statement
;;;                             } 14 List<while Statement>
;--	pop 0 bytes
;;;                           } 13 CompoundStatement
;--	ret
	RET
;;; ------------------------------------;
;;;                           { 13 FunctionDefinition
;;;                             { 14 TypeName
;;;                               { 15 TypeSpecifier (all)
;;;                                 spec = char (20000)
;;;                               } 15 TypeSpecifier (all)
;;;                               { 15 List<DeclItem>
;;;                                 { 16 DeclItem
;;;                                   what = DECL_NAME
;;;                                   name = getnibble
;;;                                 } 16 DeclItem
;;;                               } 15 List<DeclItem>
;;;                             } 14 TypeName
;;;                             { 14 List<DeclItem>
;;;                               { 15 DeclItem
;;;                                 what = DECL_NAME
;;;                                 name = getnibble
;;;                               } 15 DeclItem
;;;                               { 15 DeclItem
;;;                                 what = DECL_FUN
;;;                                 { 16 List<ParameterDeclaration>
;;;                                   { 17 ParameterDeclaration
;;;                                     isEllipsis = false
;;;                                     { 18 TypeName
;;;                                       { 19 TypeSpecifier (all)
;;;                                         spec = char (20000)
;;;                                       } 19 TypeSpecifier (all)
;;;                                       { 19 List<DeclItem>
;;;                                         { 20 DeclItem
;;;                                           what = DECL_NAME
;;;                                           name = echo
;;;                                         } 20 DeclItem
;;;                                       } 19 List<DeclItem>
;;;                                     } 18 TypeName
;;;                                   } 17 ParameterDeclaration
;;;                                 } 16 List<ParameterDeclaration>
;;;                               } 15 DeclItem
;;;                             } 14 List<DeclItem>
Cgetnibble:
;;;                             { 14 CompoundStatement
;;;                               { 15 InitDeclarator
;;;                                 { 16 List<DeclItem>
;;;                                   { 17 DeclItem
;;;                                     what = DECL_NAME
;;;                                     name = c
;;;                                   } 17 DeclItem
;;;                                 } 16 List<DeclItem>
;;;                                 { 16 Initializer (skalar)
;;;                                   { 17 Expr l(r)
;;;                                     { 18 TypeName
;;;                                       { 19 TypeSpecifier (all)
;;;                                         spec = int (80000)
;;;                                       } 19 TypeSpecifier (all)
;;;                                       { 19 List<DeclItem>
;;;                                         { 20 DeclItem
;;;                                           what = DECL_NAME
;;;                                           name = peekchr
;;;                                         } 20 DeclItem
;;;                                       } 19 List<DeclItem>
;;;                                     } 18 TypeName
;--	push 2 bytes
;--	call
	CALL	Cpeekchr
;--	pop 0 bytes
;;;                                   } 17 Expr l(r)
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;;;                                 } 16 Initializer (skalar)
;;;                               } 15 InitDeclarator
;;;                               { 15 InitDeclarator
;;;                                 { 16 List<DeclItem>
;;;                                   { 17 DeclItem
;;;                                     what = DECL_NAME
;;;                                     name = ret
;;;                                   } 17 DeclItem
;;;                                 } 16 List<DeclItem>
;;;                                 { 16 Initializer (skalar)
;;;                                   { 17 NumericExpression (constant 1 = 0x1)
;--	load_rr_constant
	MOVE	#0xFFFF, RR
;;;                                   } 17 NumericExpression (constant 1 = 0x1)
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                 } 16 Initializer (skalar)
;;;                               } 15 InitDeclarator
;;;                               { 15 List<IfElseStatement>
;;;                                 { 16 IfElseStatement
;;;                                   { 17 Expr l && r
;;;                                     { 18 TypeName (internal)
;;;                                       { 19 TypeSpecifier (all)
;;;                                         spec = int (80000)
;;;                                       } 19 TypeSpecifier (all)
;;;                                     } 18 TypeName (internal)
;;;                                     { 18 IfElseStatement
;;;                                       { 19 Expr l >= r
;;;                                         { 20 TypeName (internal)
;;;                                           { 21 TypeSpecifier (all)
;;;                                             spec = int (80000)
;;;                                           } 21 TypeSpecifier (all)
;;;                                         } 20 TypeName (internal)
;;;                                         { 20 Expression (variable name)
;;;                                           expr_type = "identifier" (c)
;--	load_rr_var c = -1(FP), SP at -3 (8 bit)
	MOVE	2(SP), RS
;;;                                         } 20 Expression (variable name)
;--	l >= r
	SGE	RR, #0x0030
;;;                                       } 19 Expr l >= r
;--	branch_false
	JMP	RRZ, L15_endif_51
;;;                                       { 19 ExpressionStatement
;;;                                         { 20 Expr l <= r
;;;                                           { 21 TypeName (internal)
;;;                                             { 22 TypeSpecifier (all)
;;;                                               spec = int (80000)
;;;                                             } 22 TypeSpecifier (all)
;;;                                           } 21 TypeName (internal)
;;;                                           { 21 Expression (variable name)
;;;                                             expr_type = "identifier" (c)
;--	load_rr_var c = -1(FP), SP at -3 (8 bit)
	MOVE	2(SP), RS
;;;                                           } 21 Expression (variable name)
;--	l <= r
	SLE	RR, #0x0039
;;;                                         } 20 Expr l <= r
;;;                                       } 19 ExpressionStatement
L15_endif_51:
;;;                                     } 18 IfElseStatement
;;;                                   } 17 Expr l && r
;--	branch_false
	JMP	RRZ, L15_else_50
;;;                                   { 17 ExpressionStatement
;;;                                     { 18 Expr l = r
;;;                                       { 19 TypeName
;;;                                         { 20 TypeSpecifier (all)
;;;                                           spec = int (80000)
;;;                                         } 20 TypeSpecifier (all)
;;;                                         { 20 List<DeclItem>
;;;                                           { 21 DeclItem
;;;                                             what = DECL_NAME
;;;                                             name = ret
;;;                                           } 21 DeclItem
;;;                                         } 20 List<DeclItem>
;;;                                       } 19 TypeName
;;;                                       { 19 Expr l - r
;;;                                         { 20 Expression (variable name)
;;;                                           expr_type = "identifier" (c)
;--	load_rr_var c = -1(FP), SP at -3 (8 bit)
	MOVE	2(SP), RS
;;;                                         } 20 Expression (variable name)
;--	l - r
	SUB	RR, #0x0030
;;;                                       } 19 Expr l - r
;--	store_rr_var ret = -3(FP), SP at -3
	MOVE	RR, 0(SP)
;;;                                     } 18 Expr l = r
;;;                                   } 17 ExpressionStatement
;--	branch
	JMP	L15_endif_50
L15_else_50:
;;;                                   { 17 IfElseStatement
;;;                                     { 18 Expr l && r
;;;                                       { 19 TypeName (internal)
;;;                                         { 20 TypeSpecifier (all)
;;;                                           spec = int (80000)
;;;                                         } 20 TypeSpecifier (all)
;;;                                       } 19 TypeName (internal)
;;;                                       { 19 IfElseStatement
;;;                                         { 20 Expr l >= r
;;;                                           { 21 TypeName (internal)
;;;                                             { 22 TypeSpecifier (all)
;;;                                               spec = int (80000)
;;;                                             } 22 TypeSpecifier (all)
;;;                                           } 21 TypeName (internal)
;;;                                           { 21 Expression (variable name)
;;;                                             expr_type = "identifier" (c)
;--	load_rr_var c = -1(FP), SP at -3 (8 bit)
	MOVE	2(SP), RS
;;;                                           } 21 Expression (variable name)
;--	l >= r
	SGE	RR, #0x0041
;;;                                         } 20 Expr l >= r
;--	branch_false
	JMP	RRZ, L15_endif_53
;;;                                         { 20 ExpressionStatement
;;;                                           { 21 Expr l <= r
;;;                                             { 22 TypeName (internal)
;;;                                               { 23 TypeSpecifier (all)
;;;                                                 spec = int (80000)
;;;                                               } 23 TypeSpecifier (all)
;;;                                             } 22 TypeName (internal)
;;;                                             { 22 Expression (variable name)
;;;                                               expr_type = "identifier" (c)
;--	load_rr_var c = -1(FP), SP at -3 (8 bit)
	MOVE	2(SP), RS
;;;                                             } 22 Expression (variable name)
;--	l <= r
	SLE	RR, #0x0046
;;;                                           } 21 Expr l <= r
;;;                                         } 20 ExpressionStatement
L15_endif_53:
;;;                                       } 19 IfElseStatement
;;;                                     } 18 Expr l && r
;--	branch_false
	JMP	RRZ, L15_else_52
;;;                                     { 18 ExpressionStatement
;;;                                       { 19 Expr l = r
;;;                                         { 20 TypeName
;;;                                           { 21 TypeSpecifier (all)
;;;                                             spec = int (80000)
;;;                                           } 21 TypeSpecifier (all)
;;;                                           { 21 List<DeclItem>
;;;                                             { 22 DeclItem
;;;                                               what = DECL_NAME
;;;                                               name = ret
;;;                                             } 22 DeclItem
;;;                                           } 21 List<DeclItem>
;;;                                         } 20 TypeName
;;;                                         { 20 Expr l - r
;;;                                           { 21 Expression (variable name)
;;;                                             expr_type = "identifier" (c)
;--	load_rr_var c = -1(FP), SP at -3 (8 bit)
	MOVE	2(SP), RS
;;;                                           } 21 Expression (variable name)
;--	l - r
	SUB	RR, #0x0037
;;;                                         } 20 Expr l - r
;--	store_rr_var ret = -3(FP), SP at -3
	MOVE	RR, 0(SP)
;;;                                       } 19 Expr l = r
;;;                                     } 18 ExpressionStatement
;--	branch
	JMP	L15_endif_52
L15_else_52:
;;;                                     { 18 IfElseStatement
;;;                                       { 19 Expr l && r
;;;                                         { 20 TypeName (internal)
;;;                                           { 21 TypeSpecifier (all)
;;;                                             spec = int (80000)
;;;                                           } 21 TypeSpecifier (all)
;;;                                         } 20 TypeName (internal)
;;;                                         { 20 IfElseStatement
;;;                                           { 21 Expr l >= r
;;;                                             { 22 TypeName (internal)
;;;                                               { 23 TypeSpecifier (all)
;;;                                                 spec = int (80000)
;;;                                               } 23 TypeSpecifier (all)
;;;                                             } 22 TypeName (internal)
;;;                                             { 22 Expression (variable name)
;;;                                               expr_type = "identifier" (c)
;--	load_rr_var c = -1(FP), SP at -3 (8 bit)
	MOVE	2(SP), RS
;;;                                             } 22 Expression (variable name)
;--	l >= r
	SGE	RR, #0x0061
;;;                                           } 21 Expr l >= r
;--	branch_false
	JMP	RRZ, L15_endif_55
;;;                                           { 21 ExpressionStatement
;;;                                             { 22 Expr l <= r
;;;                                               { 23 TypeName (internal)
;;;                                                 { 24 TypeSpecifier (all)
;;;                                                   spec = int (80000)
;;;                                                 } 24 TypeSpecifier (all)
;;;                                               } 23 TypeName (internal)
;;;                                               { 23 Expression (variable name)
;;;                                                 expr_type = "identifier" (c)
;--	load_rr_var c = -1(FP), SP at -3 (8 bit)
	MOVE	2(SP), RS
;;;                                               } 23 Expression (variable name)
;--	l <= r
	SLE	RR, #0x0066
;;;                                             } 22 Expr l <= r
;;;                                           } 21 ExpressionStatement
L15_endif_55:
;;;                                         } 20 IfElseStatement
;;;                                       } 19 Expr l && r
;--	branch_false
	JMP	RRZ, L15_endif_54
;;;                                       { 19 ExpressionStatement
;;;                                         { 20 Expr l = r
;;;                                           { 21 TypeName
;;;                                             { 22 TypeSpecifier (all)
;;;                                               spec = int (80000)
;;;                                             } 22 TypeSpecifier (all)
;;;                                             { 22 List<DeclItem>
;;;                                               { 23 DeclItem
;;;                                                 what = DECL_NAME
;;;                                                 name = ret
;;;                                               } 23 DeclItem
;;;                                             } 22 List<DeclItem>
;;;                                           } 21 TypeName
;;;                                           { 21 Expr l - r
;;;                                             { 22 Expression (variable name)
;;;                                               expr_type = "identifier" (c)
;--	load_rr_var c = -1(FP), SP at -3 (8 bit)
	MOVE	2(SP), RS
;;;                                             } 22 Expression (variable name)
;--	l - r
	SUB	RR, #0x0057
;;;                                           } 21 Expr l - r
;--	store_rr_var ret = -3(FP), SP at -3
	MOVE	RR, 0(SP)
;;;                                         } 20 Expr l = r
;;;                                       } 19 ExpressionStatement
L15_endif_54:
;;;                                     } 18 IfElseStatement
L15_endif_52:
;;;                                   } 17 IfElseStatement
L15_endif_50:
;;;                                 } 16 IfElseStatement
;;;                                 { 16 IfElseStatement
;;;                                   { 17 Expr l != r
;;;                                     { 18 TypeName (internal)
;;;                                       { 19 TypeSpecifier (all)
;;;                                         spec = int (80000)
;;;                                       } 19 TypeSpecifier (all)
;;;                                     } 18 TypeName (internal)
;;;                                     { 18 Expression (variable name)
;;;                                       expr_type = "identifier" (ret)
;--	load_rr_var ret = -3(FP), SP at -3 (16 bit)
	MOVE	0(SP), RR
;;;                                     } 18 Expression (variable name)
;--	l != r
	SNE	RR, #0xFFFF
;;;                                   } 17 Expr l != r
;--	branch_false
	JMP	RRZ, L15_endif_56
;;;                                   { 17 CompoundStatement
;;;                                     { 18 List<ExpressionStatement>
;;;                                       { 19 ExpressionStatement
;;;                                         { 20 Expr l(r)
;;;                                           { 21 TypeName
;;;                                             { 22 TypeSpecifier (all)
;;;                                               spec = int (80000)
;;;                                             } 22 TypeSpecifier (all)
;;;                                             { 22 List<DeclItem>
;;;                                               { 23 DeclItem
;;;                                                 what = DECL_NAME
;;;                                                 name = getchr
;;;                                               } 23 DeclItem
;;;                                             } 22 List<DeclItem>
;;;                                           } 21 TypeName
;--	push 2 bytes
;--	call
	CALL	Cgetchr
;--	pop 0 bytes
;;;                                         } 20 Expr l(r)
;;;                                       } 19 ExpressionStatement
;;;                                       { 19 IfElseStatement
;;;                                         { 20 Expression (variable name)
;;;                                           expr_type = "identifier" (echo)
;--	load_rr_var echo = 2(FP), SP at -3 (8 bit)
	MOVE	5(SP), RS
;;;                                         } 20 Expression (variable name)
;--	branch_false
	JMP	RRZ, L15_endif_57
;;;                                         { 20 ExpressionStatement
;;;                                           { 21 Expr l(r)
;;;                                             { 22 TypeName
;;;                                               { 23 TypeSpecifier (all)
;;;                                                 spec = int (80000)
;;;                                               } 23 TypeSpecifier (all)
;;;                                               { 23 List<DeclItem>
;;;                                                 { 24 DeclItem
;;;                                                   what = DECL_NAME
;;;                                                   name = putchr
;;;                                                 } 24 DeclItem
;;;                                               } 23 List<DeclItem>
;;;                                             } 22 TypeName
;;;                                             { 22 ParameterDeclaration
;;;                                               isEllipsis = false
;;;                                               { 23 TypeName
;;;                                                 { 24 TypeSpecifier (all)
;;;                                                   spec = char (20000)
;;;                                                 } 24 TypeSpecifier (all)
;;;                                                 { 24 List<DeclItem>
;;;                                                   { 25 DeclItem
;;;                                                     what = DECL_NAME
;;;                                                     name = c
;;;                                                   } 25 DeclItem
;;;                                                 } 24 List<DeclItem>
;;;                                               } 23 TypeName
;;;                                             } 22 ParameterDeclaration
;;;                                             { 22 Expression (variable name)
;;;                                               expr_type = "identifier" (c)
;--	load_rr_var c = -1(FP), SP at -3 (8 bit)
	MOVE	2(SP), RS
;;;                                             } 22 Expression (variable name)
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;--	push 2 bytes
;--	call
	CALL	Cputchr
;--	pop 1 bytes
	ADD	SP, #1
;;;                                           } 21 Expr l(r)
;;;                                         } 20 ExpressionStatement
L15_endif_57:
;;;                                       } 19 IfElseStatement
;;;                                     } 18 List<ExpressionStatement>
;--	pop 0 bytes
;;;                                   } 17 CompoundStatement
L15_endif_56:
;;;                                 } 16 IfElseStatement
;;;                                 { 16 return Statement
;;;                                   { 17 Expression (variable name)
;;;                                     expr_type = "identifier" (ret)
;--	load_rr_var ret = -3(FP), SP at -3 (16 bit)
	MOVE	0(SP), RR
;;;                                   } 17 Expression (variable name)
;--	ret
	ADD	SP, #3
	RET
;;;                                 } 16 return Statement
;;;                               } 15 List<IfElseStatement>
;--	pop 3 bytes
	ADD	SP, #3
;;;                             } 14 CompoundStatement
;--	ret
	RET
;;; ------------------------------------;
;;;                             { 14 FunctionDefinition
;;;                               { 15 TypeName
;;;                                 { 16 TypeSpecifier (all)
;;;                                   spec = int (80000)
;;;                                 } 16 TypeSpecifier (all)
;;;                                 { 16 List<DeclItem>
;;;                                   { 17 DeclItem
;;;                                     what = DECL_NAME
;;;                                     name = gethex
;;;                                   } 17 DeclItem
;;;                                 } 16 List<DeclItem>
;;;                               } 15 TypeName
;;;                               { 15 List<DeclItem>
;;;                                 { 16 DeclItem
;;;                                   what = DECL_NAME
;;;                                   name = gethex
;;;                                 } 16 DeclItem
;;;                                 { 16 DeclItem
;;;                                   what = DECL_FUN
;;;                                   { 17 List<ParameterDeclaration>
;;;                                     { 18 ParameterDeclaration
;;;                                       isEllipsis = false
;;;                                       { 19 TypeName
;;;                                         { 20 TypeSpecifier (all)
;;;                                           spec = char (20000)
;;;                                         } 20 TypeSpecifier (all)
;;;                                         { 20 List<DeclItem>
;;;                                           { 21 DeclItem
;;;                                             what = DECL_NAME
;;;                                             name = echo
;;;                                           } 21 DeclItem
;;;                                         } 20 List<DeclItem>
;;;                                       } 19 TypeName
;;;                                     } 18 ParameterDeclaration
;;;                                   } 17 List<ParameterDeclaration>
;;;                                 } 16 DeclItem
;;;                               } 15 List<DeclItem>
Cgethex:
;;;                               { 15 CompoundStatement
;;;                                 { 16 InitDeclarator
;;;                                   { 17 List<DeclItem>
;;;                                     { 18 DeclItem
;;;                                       what = DECL_NAME
;;;                                       name = ret
;;;                                     } 18 DeclItem
;;;                                   } 17 List<DeclItem>
;;;                                   { 17 Initializer (skalar)
;--	push_zero 2 bytes
	CLRW	-(SP)
;;;                                   } 17 Initializer (skalar)
;;;                                 } 16 InitDeclarator
;;;                                 { 16 InitDeclarator
;;;                                   { 17 List<DeclItem>
;;;                                     { 18 DeclItem
;;;                                       what = DECL_NAME
;;;                                       name = c
;;;                                     } 18 DeclItem
;;;                                   } 17 List<DeclItem>
;--	push_zero 1 bytes
	CLRB	-(SP)
;;;                                 } 16 InitDeclarator
;;;                                 { 16 List<while Statement>
;;;                                   { 17 while Statement
;--	branch
	JMP	L16_cont_58
L16_loop_58:
;;;                                     { 18 ExpressionStatement
;;;                                       { 19 Expr l = r
;;;                                         { 20 TypeName
;;;                                           { 21 TypeSpecifier (all)
;;;                                             spec = int (80000)
;;;                                           } 21 TypeSpecifier (all)
;;;                                           { 21 List<DeclItem>
;;;                                             { 22 DeclItem
;;;                                               what = DECL_NAME
;;;                                               name = ret
;;;                                             } 22 DeclItem
;;;                                           } 21 List<DeclItem>
;;;                                         } 20 TypeName
;;;                                         { 20 Expr l | r
;;;                                           { 21 TypeName (internal)
;;;                                             { 22 TypeSpecifier (all)
;;;                                               spec = int (80000)
;;;                                             } 22 TypeSpecifier (all)
;;;                                           } 21 TypeName (internal)
;;;                                           { 21 Expr l << r
;;;                                             { 22 TypeName (internal)
;;;                                               { 23 TypeSpecifier (all)
;;;                                                 spec = int (80000)
;;;                                               } 23 TypeSpecifier (all)
;;;                                             } 22 TypeName (internal)
;;;                                             { 22 Expression (variable name)
;;;                                               expr_type = "identifier" (ret)
;--	load_rr_var ret = -2(FP), SP at -3 (16 bit)
	MOVE	1(SP), RR
;;;                                             } 22 Expression (variable name)
;--	l << r
	LSL	RR, #0x0004
;;;                                           } 21 Expr l << r
;--	move_rr_to_ll
	MOVE	RR, LL
;;;                                           { 21 Expression (variable name)
;;;                                             expr_type = "identifier" (c)
;--	load_rr_var c = -3(FP), SP at -3 (8 bit)
	MOVE	0(SP), RS
;;;                                           } 21 Expression (variable name)
;--	l | r
	OR	LL, RR
;;;                                         } 20 Expr l | r
;--	store_rr_var ret = -2(FP), SP at -3
	MOVE	RR, 1(SP)
;;;                                       } 19 Expr l = r
;;;                                     } 18 ExpressionStatement
L16_cont_58:
;;;                                     { 18 Expr l != r
;;;                                       { 19 TypeName (internal)
;;;                                         { 20 TypeSpecifier (all)
;;;                                           spec = int (80000)
;;;                                         } 20 TypeSpecifier (all)
;;;                                       } 19 TypeName (internal)
;;;                                       { 19 Expr l = r
;;;                                         { 20 TypeName
;;;                                           { 21 TypeSpecifier (all)
;;;                                             spec = char (20000)
;;;                                           } 21 TypeSpecifier (all)
;;;                                           { 21 List<DeclItem>
;;;                                             { 22 DeclItem
;;;                                               what = DECL_NAME
;;;                                               name = c
;;;                                             } 22 DeclItem
;;;                                           } 21 List<DeclItem>
;;;                                         } 20 TypeName
;;;                                         { 20 Expr l(r)
;;;                                           { 21 TypeName
;;;                                             { 22 TypeSpecifier (all)
;;;                                               spec = char (20000)
;;;                                             } 22 TypeSpecifier (all)
;;;                                             { 22 List<DeclItem>
;;;                                               { 23 DeclItem
;;;                                                 what = DECL_NAME
;;;                                                 name = getnibble
;;;                                               } 23 DeclItem
;;;                                             } 22 List<DeclItem>
;;;                                           } 21 TypeName
;;;                                           { 21 ParameterDeclaration
;;;                                             isEllipsis = false
;;;                                             { 22 TypeName
;;;                                               { 23 TypeSpecifier (all)
;;;                                                 spec = char (20000)
;;;                                               } 23 TypeSpecifier (all)
;;;                                               { 23 List<DeclItem>
;;;                                                 { 24 DeclItem
;;;                                                   what = DECL_NAME
;;;                                                   name = echo
;;;                                                 } 24 DeclItem
;;;                                               } 23 List<DeclItem>
;;;                                             } 22 TypeName
;;;                                           } 21 ParameterDeclaration
;;;                                           { 21 Expression (variable name)
;;;                                             expr_type = "identifier" (echo)
;--	load_rr_var echo = 2(FP), SP at -3 (8 bit)
	MOVE	5(SP), RS
;;;                                           } 21 Expression (variable name)
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;--	push 1 bytes
;--	call
	CALL	Cgetnibble
;--	pop 1 bytes
	ADD	SP, #1
;;;                                         } 20 Expr l(r)
;--	store_rr_var c = -3(FP), SP at -3
	MOVE	R, 0(SP)
;;;                                       } 19 Expr l = r
;--	l != r
	SNE	RR, #0xFFFF
;;;                                     } 18 Expr l != r
;--	branch_true
	JMP	RRNZ, L16_loop_58
L16_brk_59:
;;;                                   } 17 while Statement
;;;                                   { 17 return Statement
;;;                                     { 18 Expression (variable name)
;;;                                       expr_type = "identifier" (ret)
;--	load_rr_var ret = -2(FP), SP at -3 (16 bit)
	MOVE	1(SP), RR
;;;                                     } 18 Expression (variable name)
;--	ret
	ADD	SP, #3
	RET
;;;                                   } 17 return Statement
;;;                                 } 16 List<while Statement>
;--	pop 3 bytes
	ADD	SP, #3
;;;                               } 15 CompoundStatement
;--	ret
	RET
;;; ------------------------------------;
;;;                               { 15 FunctionDefinition
;;;                                 { 16 TypeName
;;;                                   { 17 TypeSpecifier (all)
;;;                                     spec = void (10000)
;;;                                   } 17 TypeSpecifier (all)
;;;                                   { 17 List<DeclItem>
;;;                                     { 18 DeclItem
;;;                                       what = DECL_NAME
;;;                                       name = show_time
;;;                                     } 18 DeclItem
;;;                                   } 17 List<DeclItem>
;;;                                 } 16 TypeName
;;;                                 { 16 List<DeclItem>
;;;                                   { 17 DeclItem
;;;                                     what = DECL_NAME
;;;                                     name = show_time
;;;                                   } 17 DeclItem
;;;                                   { 17 DeclItem
;;;                                     what = DECL_FUN
;;;                                   } 17 DeclItem
;;;                                 } 16 List<DeclItem>
Cshow_time:
;;;                                 { 16 CompoundStatement
;;;                                   { 17 InitDeclarator
;;;                                     { 18 List<DeclItem>
;;;                                       { 19 DeclItem
;;;                                         what = DECL_NAME
;;;                                         name = sl
;;;                                       } 19 DeclItem
;;;                                     } 18 List<DeclItem>
;--	push_zero 2 bytes
	CLRW	-(SP)
;;;                                   } 17 InitDeclarator
;;;                                   { 17 InitDeclarator
;;;                                     { 18 List<DeclItem>
;;;                                       { 19 DeclItem
;;;                                         what = DECL_NAME
;;;                                         name = sm
;;;                                       } 19 DeclItem
;;;                                     } 18 List<DeclItem>
;--	push_zero 2 bytes
	CLRW	-(SP)
;;;                                   } 17 InitDeclarator
;;;                                   { 17 InitDeclarator
;;;                                     { 18 List<DeclItem>
;;;                                       { 19 DeclItem
;;;                                         what = DECL_NAME
;;;                                         name = sh
;;;                                       } 19 DeclItem
;;;                                     } 18 List<DeclItem>
;--	push_zero 2 bytes
	CLRW	-(SP)
;;;                                   } 17 InitDeclarator
;;;                                   { 17 List<do while Statement>
;;;                                     { 18 do while Statement
L17_loop_60:
;;;                                       { 19 CompoundStatement
;;;                                         { 20 List<ExpressionStatement>
;;;                                           { 21 ExpressionStatement
;;;                                             { 22 Expr l = r
;;;                                               { 23 TypeName
;;;                                                 { 24 TypeSpecifier (all)
;;;                                                   spec = unsigned char (22000)
;;;                                                 } 24 TypeSpecifier (all)
;;;                                                 { 24 List<DeclItem>
;;;                                                   { 25 DeclItem
;;;                                                     what = DECL_NAME
;;;                                                     name = seconds_changed
;;;                                                   } 25 DeclItem
;;;                                                 } 24 List<DeclItem>
;;;                                               } 23 TypeName
;;;                                               { 23 NumericExpression (constant 0 = 0x0)
;--	load_rr_constant
	MOVE	#0x0000, RR
;;;                                               } 23 NumericExpression (constant 0 = 0x0)
;--	store_rr_var seconds_changed
	MOVE	R, (Cseconds_changed)
;;;                                             } 22 Expr l = r
;;;                                           } 21 ExpressionStatement
;;;                                           { 21 ExpressionStatement
;;;                                             { 22 Expr l = r
;;;                                               { 23 TypeName
;;;                                                 { 24 TypeSpecifier (all)
;;;                                                   spec = unsigned int (82000)
;;;                                                 } 24 TypeSpecifier (all)
;;;                                                 { 24 List<DeclItem>
;;;                                                   { 25 DeclItem
;;;                                                     what = DECL_NAME
;;;                                                     name = sl
;;;                                                   } 25 DeclItem
;;;                                                 } 24 List<DeclItem>
;;;                                               } 23 TypeName
;;;                                               { 23 Expression (variable name)
;;;                                                 expr_type = "identifier" (seconds_low)
;--	load_rr_var seconds_low, (16 bit)
	MOVE	(Cseconds_low), RR
;;;                                               } 23 Expression (variable name)
;--	store_rr_var sl = -2(FP), SP at -6
	MOVE	RR, 4(SP)
;;;                                             } 22 Expr l = r
;;;                                           } 21 ExpressionStatement
;;;                                           { 21 ExpressionStatement
;;;                                             { 22 Expr l = r
;;;                                               { 23 TypeName
;;;                                                 { 24 TypeSpecifier (all)
;;;                                                   spec = unsigned int (82000)
;;;                                                 } 24 TypeSpecifier (all)
;;;                                                 { 24 List<DeclItem>
;;;                                                   { 25 DeclItem
;;;                                                     what = DECL_NAME
;;;                                                     name = sm
;;;                                                   } 25 DeclItem
;;;                                                 } 24 List<DeclItem>
;;;                                               } 23 TypeName
;;;                                               { 23 Expression (variable name)
;;;                                                 expr_type = "identifier" (seconds_mid)
;--	load_rr_var seconds_mid, (16 bit)
	MOVE	(Cseconds_mid), RR
;;;                                               } 23 Expression (variable name)
;--	store_rr_var sm = -4(FP), SP at -6
	MOVE	RR, 2(SP)
;;;                                             } 22 Expr l = r
;;;                                           } 21 ExpressionStatement
;;;                                           { 21 ExpressionStatement
;;;                                             { 22 Expr l = r
;;;                                               { 23 TypeName
;;;                                                 { 24 TypeSpecifier (all)
;;;                                                   spec = unsigned int (82000)
;;;                                                 } 24 TypeSpecifier (all)
;;;                                                 { 24 List<DeclItem>
;;;                                                   { 25 DeclItem
;;;                                                     what = DECL_NAME
;;;                                                     name = sh
;;;                                                   } 25 DeclItem
;;;                                                 } 24 List<DeclItem>
;;;                                               } 23 TypeName
;;;                                               { 23 Expression (variable name)
;;;                                                 expr_type = "identifier" (seconds_high)
;--	load_rr_var seconds_high, (16 bit)
	MOVE	(Cseconds_high), RR
;;;                                               } 23 Expression (variable name)
;--	store_rr_var sh = -6(FP), SP at -6
	MOVE	RR, 0(SP)
;;;                                             } 22 Expr l = r
;;;                                           } 21 ExpressionStatement
;;;                                         } 20 List<ExpressionStatement>
;--	pop 0 bytes
;;;                                       } 19 CompoundStatement
L17_cont_60:
;;;                                       { 19 Expression (variable name)
;;;                                         expr_type = "identifier" (seconds_changed)
;--	load_rr_var seconds_changed, (8 bit)
	MOVE	(Cseconds_changed), RU
;;;                                       } 19 Expression (variable name)
;--	branch_true
	JMP	RRNZ, L17_loop_60
L17_brk_61:
;;;                                     } 18 do while Statement
;;;                                     { 18 ExpressionStatement
;;;                                       { 19 Expr l(r)
;;;                                         { 20 TypeName
;;;                                           { 21 TypeSpecifier (all)
;;;                                             spec = int (80000)
;;;                                           } 21 TypeSpecifier (all)
;;;                                           { 21 List<DeclItem>
;;;                                             { 22 DeclItem
;;;                                               what = DECL_NAME
;;;                                               name = printf
;;;                                             } 22 DeclItem
;;;                                           } 21 List<DeclItem>
;;;                                         } 20 TypeName
;;;                                         { 20 Expr (l , r)
;;;                                           { 21 ParameterDeclaration
;;;                                             isEllipsis = true
;;;                                             { 22 TypeName
;;;                                               { 23 TypeSpecifier (all)
;;;                                                 spec = const char (20100)
;;;                                               } 23 TypeSpecifier (all)
;;;                                               { 23 List<DeclItem>
;;;                                                 { 24 DeclItem
;;;                                                   what = DECL_POINTER
;;;                                                   { 25 List<Ptr>
;;;                                                     { 26 Ptr
;;;                                                     } 26 Ptr
;;;                                                   } 25 List<Ptr>
;;;                                                 } 24 DeclItem
;;;                                                 { 24 DeclItem
;;;                                                   what = DECL_NAME
;;;                                                   name = format
;;;                                                 } 24 DeclItem
;;;                                               } 23 List<DeclItem>
;;;                                             } 22 TypeName
;;;                                           } 21 ParameterDeclaration
;;;                                           { 21 Expression (variable name)
;;;                                             expr_type = "identifier" (sl)
;--	load_rr_var sl = -2(FP), SP at -6 (16 bit)
	MOVE	4(SP), RR
;;;                                           } 21 Expression (variable name)
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                           { 21 Expr (l , r)
;;;                                             { 22 ParameterDeclaration
;;;                                               isEllipsis = true
;;;                                               { 23 TypeName
;;;                                                 { 24 TypeSpecifier (all)
;;;                                                   spec = const char (20100)
;;;                                                 } 24 TypeSpecifier (all)
;;;                                                 { 24 List<DeclItem>
;;;                                                   { 25 DeclItem
;;;                                                     what = DECL_POINTER
;;;                                                     { 26 List<Ptr>
;;;                                                       { 27 Ptr
;;;                                                       } 27 Ptr
;;;                                                     } 26 List<Ptr>
;;;                                                   } 25 DeclItem
;;;                                                   { 25 DeclItem
;;;                                                     what = DECL_NAME
;;;                                                     name = format
;;;                                                   } 25 DeclItem
;;;                                                 } 24 List<DeclItem>
;;;                                               } 23 TypeName
;;;                                             } 22 ParameterDeclaration
;;;                                             { 22 Expression (variable name)
;;;                                               expr_type = "identifier" (sm)
;--	load_rr_var sm = -4(FP), SP at -8 (16 bit)
	MOVE	4(SP), RR
;;;                                             } 22 Expression (variable name)
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                             { 22 Expr (l , r)
;;;                                               { 23 ParameterDeclaration
;;;                                                 isEllipsis = true
;;;                                                 { 24 TypeName
;;;                                                   { 25 TypeSpecifier (all)
;;;                                                     spec = const char (20100)
;;;                                                   } 25 TypeSpecifier (all)
;;;                                                   { 25 List<DeclItem>
;;;                                                     { 26 DeclItem
;;;                                                       what = DECL_POINTER
;;;                                                       { 27 List<Ptr>
;;;                                                         { 28 Ptr
;;;                                                         } 28 Ptr
;;;                                                       } 27 List<Ptr>
;;;                                                     } 26 DeclItem
;;;                                                     { 26 DeclItem
;;;                                                       what = DECL_NAME
;;;                                                       name = format
;;;                                                     } 26 DeclItem
;;;                                                   } 25 List<DeclItem>
;;;                                                 } 24 TypeName
;;;                                               } 23 ParameterDeclaration
;;;                                               { 23 Expression (variable name)
;;;                                                 expr_type = "identifier" (sh)
;--	load_rr_var sh = -6(FP), SP at -10 (16 bit)
	MOVE	4(SP), RR
;;;                                               } 23 Expression (variable name)
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                               { 23 ParameterDeclaration
;;;                                                 isEllipsis = true
;;;                                                 { 24 TypeName
;;;                                                   { 25 TypeSpecifier (all)
;;;                                                     spec = const char (20100)
;;;                                                   } 25 TypeSpecifier (all)
;;;                                                   { 25 List<DeclItem>
;;;                                                     { 26 DeclItem
;;;                                                       what = DECL_POINTER
;;;                                                       { 27 List<Ptr>
;;;                                                         { 28 Ptr
;;;                                                         } 28 Ptr
;;;                                                       } 27 List<Ptr>
;;;                                                     } 26 DeclItem
;;;                                                     { 26 DeclItem
;;;                                                       what = DECL_NAME
;;;                                                       name = format
;;;                                                     } 26 DeclItem
;;;                                                   } 25 List<DeclItem>
;;;                                                 } 24 TypeName
;;;                                               } 23 ParameterDeclaration
;;;                                               { 23 StringExpression
;--	load_rr_string
	MOVE	#Cstr_28, RR
;;;                                               } 23 StringExpression
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                             } 22 Expr (l , r)
;;;                                           } 21 Expr (l , r)
;;;                                         } 20 Expr (l , r)
;--	push 2 bytes
;--	call
	CALL	Cprintf
;--	pop 8 bytes
	ADD	SP, #8
;;;                                       } 19 Expr l(r)
;;;                                     } 18 ExpressionStatement
;;;                                   } 17 List<do while Statement>
;--	pop 6 bytes
	ADD	SP, #6
;;;                                 } 16 CompoundStatement
;--	ret
	RET
;;; ------------------------------------;
;;;                                 { 16 FunctionDefinition
;;;                                   { 17 TypeName
;;;                                     { 18 TypeSpecifier (all)
;;;                                       spec = void (10000)
;;;                                     } 18 TypeSpecifier (all)
;;;                                     { 18 List<DeclItem>
;;;                                       { 19 DeclItem
;;;                                         what = DECL_NAME
;;;                                         name = display_memory
;;;                                       } 19 DeclItem
;;;                                     } 18 List<DeclItem>
;;;                                   } 17 TypeName
;;;                                   { 17 List<DeclItem>
;;;                                     { 18 DeclItem
;;;                                       what = DECL_NAME
;;;                                       name = display_memory
;;;                                     } 18 DeclItem
;;;                                     { 18 DeclItem
;;;                                       what = DECL_FUN
;;;                                       { 19 List<ParameterDeclaration>
;;;                                         { 20 ParameterDeclaration
;;;                                           isEllipsis = false
;;;                                           { 21 TypeName
;;;                                             { 22 TypeSpecifier (all)
;;;                                               spec = unsigned char (22000)
;;;                                             } 22 TypeSpecifier (all)
;;;                                             { 22 List<DeclItem>
;;;                                               { 23 DeclItem
;;;                                                 what = DECL_POINTER
;;;                                                 { 24 List<Ptr>
;;;                                                   { 25 Ptr
;;;                                                   } 25 Ptr
;;;                                                 } 24 List<Ptr>
;;;                                               } 23 DeclItem
;;;                                               { 23 DeclItem
;;;                                                 what = DECL_NAME
;;;                                                 name = address
;;;                                               } 23 DeclItem
;;;                                             } 22 List<DeclItem>
;;;                                           } 21 TypeName
;;;                                         } 20 ParameterDeclaration
;;;                                       } 19 List<ParameterDeclaration>
;;;                                     } 18 DeclItem
;;;                                   } 17 List<DeclItem>
Cdisplay_memory:
;;;                                   { 17 CompoundStatement
;;;                                     { 18 InitDeclarator
;;;                                       { 19 List<DeclItem>
;;;                                         { 20 DeclItem
;;;                                           what = DECL_NAME
;;;                                           name = c
;;;                                         } 20 DeclItem
;;;                                       } 19 List<DeclItem>
;--	push_zero 1 bytes
	CLRB	-(SP)
;;;                                     } 18 InitDeclarator
;;;                                     { 18 InitDeclarator
;;;                                       { 19 List<DeclItem>
;;;                                         { 20 DeclItem
;;;                                           what = DECL_NAME
;;;                                           name = row
;;;                                         } 20 DeclItem
;;;                                       } 19 List<DeclItem>
;--	push_zero 2 bytes
	CLRW	-(SP)
;;;                                     } 18 InitDeclarator
;;;                                     { 18 InitDeclarator
;;;                                       { 19 List<DeclItem>
;;;                                         { 20 DeclItem
;;;                                           what = DECL_NAME
;;;                                           name = col
;;;                                         } 20 DeclItem
;;;                                       } 19 List<DeclItem>
;--	push_zero 2 bytes
	CLRW	-(SP)
;;;                                     } 18 InitDeclarator
;;;                                     { 18 List<for Statement>
;;;                                       { 19 for Statement
;;;                                         { 20 ExpressionStatement
;;;                                           { 21 Expr l = r
;;;                                             { 22 TypeName
;;;                                               { 23 TypeSpecifier (all)
;;;                                                 spec = int (80000)
;;;                                               } 23 TypeSpecifier (all)
;;;                                               { 23 List<DeclItem>
;;;                                                 { 24 DeclItem
;;;                                                   what = DECL_NAME
;;;                                                   name = row
;;;                                                 } 24 DeclItem
;;;                                               } 23 List<DeclItem>
;;;                                             } 22 TypeName
;;;                                             { 22 NumericExpression (constant 0 = 0x0)
;--	load_rr_constant
	MOVE	#0x0000, RR
;;;                                             } 22 NumericExpression (constant 0 = 0x0)
;--	store_rr_var row = -3(FP), SP at -5
	MOVE	RR, 2(SP)
;;;                                           } 21 Expr l = r
;;;                                         } 20 ExpressionStatement
;--	branch
	JMP	L18_tst_62
L18_loop_62:
;;;                                         { 20 CompoundStatement
;;;                                           { 21 List<ExpressionStatement>
;;;                                             { 22 ExpressionStatement
;;;                                               { 23 Expr l(r)
;;;                                                 { 24 TypeName
;;;                                                   { 25 TypeSpecifier (all)
;;;                                                     spec = int (80000)
;;;                                                   } 25 TypeSpecifier (all)
;;;                                                   { 25 List<DeclItem>
;;;                                                     { 26 DeclItem
;;;                                                       what = DECL_NAME
;;;                                                       name = printf
;;;                                                     } 26 DeclItem
;;;                                                   } 25 List<DeclItem>
;;;                                                 } 24 TypeName
;;;                                                 { 24 Expr (l , r)
;;;                                                   { 25 ParameterDeclaration
;;;                                                     isEllipsis = true
;;;                                                     { 26 TypeName
;;;                                                       { 27 TypeSpecifier (all)
;;;                                                         spec = const char (20100)
;;;                                                       } 27 TypeSpecifier (all)
;;;                                                       { 27 List<DeclItem>
;;;                                                         { 28 DeclItem
;;;                                                           what = DECL_POINTER
;;;                                                           { 29 List<Ptr>
;;;                                                             { 30 Ptr
;;;                                                             } 30 Ptr
;;;                                                           } 29 List<Ptr>
;;;                                                         } 28 DeclItem
;;;                                                         { 28 DeclItem
;;;                                                           what = DECL_NAME
;;;                                                           name = format
;;;                                                         } 28 DeclItem
;;;                                                       } 27 List<DeclItem>
;;;                                                     } 26 TypeName
;;;                                                   } 25 ParameterDeclaration
;;;                                                   { 25 Expression (variable name)
;;;                                                     expr_type = "identifier" (address)
;--	load_rr_var address = 2(FP), SP at -5 (16 bit)
	MOVE	7(SP), RR
;;;                                                   } 25 Expression (variable name)
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                                   { 25 ParameterDeclaration
;;;                                                     isEllipsis = true
;;;                                                     { 26 TypeName
;;;                                                       { 27 TypeSpecifier (all)
;;;                                                         spec = const char (20100)
;;;                                                       } 27 TypeSpecifier (all)
;;;                                                       { 27 List<DeclItem>
;;;                                                         { 28 DeclItem
;;;                                                           what = DECL_POINTER
;;;                                                           { 29 List<Ptr>
;;;                                                             { 30 Ptr
;;;                                                             } 30 Ptr
;;;                                                           } 29 List<Ptr>
;;;                                                         } 28 DeclItem
;;;                                                         { 28 DeclItem
;;;                                                           what = DECL_NAME
;;;                                                           name = format
;;;                                                         } 28 DeclItem
;;;                                                       } 27 List<DeclItem>
;;;                                                     } 26 TypeName
;;;                                                   } 25 ParameterDeclaration
;;;                                                   { 25 StringExpression
;--	load_rr_string
	MOVE	#Cstr_29, RR
;;;                                                   } 25 StringExpression
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                                 } 24 Expr (l , r)
;--	push 2 bytes
;--	call
	CALL	Cprintf
;--	pop 4 bytes
	ADD	SP, #4
;;;                                               } 23 Expr l(r)
;;;                                             } 22 ExpressionStatement
;;;                                             { 22 for Statement
;;;                                               { 23 ExpressionStatement
;;;                                                 { 24 Expr l = r
;;;                                                   { 25 TypeName
;;;                                                     { 26 TypeSpecifier (all)
;;;                                                       spec = int (80000)
;;;                                                     } 26 TypeSpecifier (all)
;;;                                                     { 26 List<DeclItem>
;;;                                                       { 27 DeclItem
;;;                                                         what = DECL_NAME
;;;                                                         name = col
;;;                                                       } 27 DeclItem
;;;                                                     } 26 List<DeclItem>
;;;                                                   } 25 TypeName
;;;                                                   { 25 NumericExpression (constant 0 = 0x0)
;--	load_rr_constant
	MOVE	#0x0000, RR
;;;                                                   } 25 NumericExpression (constant 0 = 0x0)
;--	store_rr_var col = -5(FP), SP at -5
	MOVE	RR, 0(SP)
;;;                                                 } 24 Expr l = r
;;;                                               } 23 ExpressionStatement
;--	branch
	JMP	L18_tst_64
L18_loop_64:
;;;                                               { 23 ExpressionStatement
;;;                                                 { 24 Expr l(r)
;;;                                                   { 25 TypeName
;;;                                                     { 26 TypeSpecifier (all)
;;;                                                       spec = int (80000)
;;;                                                     } 26 TypeSpecifier (all)
;;;                                                     { 26 List<DeclItem>
;;;                                                       { 27 DeclItem
;;;                                                         what = DECL_NAME
;;;                                                         name = printf
;;;                                                       } 27 DeclItem
;;;                                                     } 26 List<DeclItem>
;;;                                                   } 25 TypeName
;;;                                                   { 25 Expr (l , r)
;;;                                                     { 26 ParameterDeclaration
;;;                                                       isEllipsis = true
;;;                                                       { 27 TypeName
;;;                                                         { 28 TypeSpecifier (all)
;;;                                                           spec = const char (20100)
;;;                                                         } 28 TypeSpecifier (all)
;;;                                                         { 28 List<DeclItem>
;;;                                                           { 29 DeclItem
;;;                                                             what = DECL_POINTER
;;;                                                             { 30 List<Ptr>
;;;                                                               { 31 Ptr
;;;                                                               } 31 Ptr
;;;                                                             } 30 List<Ptr>
;;;                                                           } 29 DeclItem
;;;                                                           { 29 DeclItem
;;;                                                             what = DECL_NAME
;;;                                                             name = format
;;;                                                           } 29 DeclItem
;;;                                                         } 28 List<DeclItem>
;;;                                                       } 27 TypeName
;;;                                                     } 26 ParameterDeclaration
;;;                                                     { 26 Expr * r
;;;                                                       { 27 Expr l - r
;;;                                                         { 28 Expr ++r
;;;                                                           { 29 Expression (variable name)
;;;                                                             expr_type = "identifier" (address)
;--	load_rr_var address = 2(FP), SP at -5 (16 bit)
	MOVE	7(SP), RR
;;;                                                           } 29 Expression (variable name)
;--	++
	ADD	RR, #0x0001
;--	store_rr_var address = 2(FP), SP at -5
	MOVE	RR, 7(SP)
;;;                                                         } 28 Expr ++r
;--	l - r
	SUB	RR, #0x0001
;;;                                                       } 27 Expr l - r
;--	content
	MOVE	(RR), RU
;;;                                                     } 26 Expr * r
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                                     { 26 ParameterDeclaration
;;;                                                       isEllipsis = true
;;;                                                       { 27 TypeName
;;;                                                         { 28 TypeSpecifier (all)
;;;                                                           spec = const char (20100)
;;;                                                         } 28 TypeSpecifier (all)
;;;                                                         { 28 List<DeclItem>
;;;                                                           { 29 DeclItem
;;;                                                             what = DECL_POINTER
;;;                                                             { 30 List<Ptr>
;;;                                                               { 31 Ptr
;;;                                                               } 31 Ptr
;;;                                                             } 30 List<Ptr>
;;;                                                           } 29 DeclItem
;;;                                                           { 29 DeclItem
;;;                                                             what = DECL_NAME
;;;                                                             name = format
;;;                                                           } 29 DeclItem
;;;                                                         } 28 List<DeclItem>
;;;                                                       } 27 TypeName
;;;                                                     } 26 ParameterDeclaration
;;;                                                     { 26 StringExpression
;--	load_rr_string
	MOVE	#Cstr_30, RR
;;;                                                     } 26 StringExpression
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                                   } 25 Expr (l , r)
;--	push 2 bytes
;--	call
	CALL	Cprintf
;--	pop 4 bytes
	ADD	SP, #4
;;;                                                 } 24 Expr l(r)
;;;                                               } 23 ExpressionStatement
L18_cont_64:
;;;                                               { 23 Expr l - r
;;;                                                 { 24 Expr ++r
;;;                                                   { 25 Expression (variable name)
;;;                                                     expr_type = "identifier" (col)
;--	load_rr_var col = -5(FP), SP at -5 (16 bit)
	MOVE	0(SP), RR
;;;                                                   } 25 Expression (variable name)
;--	++
	ADD	RR, #0x0001
;--	store_rr_var col = -5(FP), SP at -5
	MOVE	RR, 0(SP)
;;;                                                 } 24 Expr ++r
;--	l - r
	SUB	RR, #0x0001
;;;                                               } 23 Expr l - r
L18_tst_64:
;;;                                               { 23 Expr l < r
;;;                                                 { 24 TypeName (internal)
;;;                                                   { 25 TypeSpecifier (all)
;;;                                                     spec = int (80000)
;;;                                                   } 25 TypeSpecifier (all)
;;;                                                 } 24 TypeName (internal)
;;;                                                 { 24 Expression (variable name)
;;;                                                   expr_type = "identifier" (col)
;--	load_rr_var col = -5(FP), SP at -5 (16 bit)
	MOVE	0(SP), RR
;;;                                                 } 24 Expression (variable name)
;--	l < r
	SLT	RR, #0x0010
;;;                                               } 23 Expr l < r
;--	branch_true
	JMP	RRNZ, L18_loop_64
L18_brk_65:
;;;                                             } 22 for Statement
;;;                                             { 22 ExpressionStatement
;;;                                               { 23 Expr l -= r
;;;                                                 { 24 TypeName
;;;                                                   { 25 TypeSpecifier (all)
;;;                                                     spec = unsigned char (22000)
;;;                                                   } 25 TypeSpecifier (all)
;;;                                                   { 25 List<DeclItem>
;;;                                                     { 26 DeclItem
;;;                                                       what = DECL_POINTER
;;;                                                       { 27 List<Ptr>
;;;                                                         { 28 Ptr
;;;                                                         } 28 Ptr
;;;                                                       } 27 List<Ptr>
;;;                                                     } 26 DeclItem
;;;                                                     { 26 DeclItem
;;;                                                       what = DECL_NAME
;;;                                                       name = address
;;;                                                     } 26 DeclItem
;;;                                                   } 25 List<DeclItem>
;;;                                                 } 24 TypeName
;;;                                                 { 24 Expr l - r
;;;                                                   { 25 Expression (variable name)
;;;                                                     expr_type = "identifier" (address)
;--	load_rr_var address = 2(FP), SP at -5 (16 bit)
	MOVE	7(SP), RR
;;;                                                   } 25 Expression (variable name)
;--	l - r
	SUB	RR, #0x0010
;;;                                                 } 24 Expr l - r
;--	store_rr_var address = 2(FP), SP at -5
	MOVE	RR, 7(SP)
;;;                                               } 23 Expr l -= r
;;;                                             } 22 ExpressionStatement
;;;                                             { 22 ExpressionStatement
;;;                                               { 23 Expr l(r)
;;;                                                 { 24 TypeName
;;;                                                   { 25 TypeSpecifier (all)
;;;                                                     spec = int (80000)
;;;                                                   } 25 TypeSpecifier (all)
;;;                                                   { 25 List<DeclItem>
;;;                                                     { 26 DeclItem
;;;                                                       what = DECL_NAME
;;;                                                       name = printf
;;;                                                     } 26 DeclItem
;;;                                                   } 25 List<DeclItem>
;;;                                                 } 24 TypeName
;;;                                                 { 24 ParameterDeclaration
;;;                                                   isEllipsis = true
;;;                                                   { 25 TypeName
;;;                                                     { 26 TypeSpecifier (all)
;;;                                                       spec = const char (20100)
;;;                                                     } 26 TypeSpecifier (all)
;;;                                                     { 26 List<DeclItem>
;;;                                                       { 27 DeclItem
;;;                                                         what = DECL_POINTER
;;;                                                         { 28 List<Ptr>
;;;                                                           { 29 Ptr
;;;                                                           } 29 Ptr
;;;                                                         } 28 List<Ptr>
;;;                                                       } 27 DeclItem
;;;                                                       { 27 DeclItem
;;;                                                         what = DECL_NAME
;;;                                                         name = format
;;;                                                       } 27 DeclItem
;;;                                                     } 26 List<DeclItem>
;;;                                                   } 25 TypeName
;;;                                                 } 24 ParameterDeclaration
;;;                                                 { 24 StringExpression
;--	load_rr_string
	MOVE	#Cstr_31, RR
;;;                                                 } 24 StringExpression
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;--	push 2 bytes
;--	call
	CALL	Cprintf
;--	pop 2 bytes
	ADD	SP, #2
;;;                                               } 23 Expr l(r)
;;;                                             } 22 ExpressionStatement
;;;                                             { 22 for Statement
;;;                                               { 23 ExpressionStatement
;;;                                                 { 24 Expr l = r
;;;                                                   { 25 TypeName
;;;                                                     { 26 TypeSpecifier (all)
;;;                                                       spec = int (80000)
;;;                                                     } 26 TypeSpecifier (all)
;;;                                                     { 26 List<DeclItem>
;;;                                                       { 27 DeclItem
;;;                                                         what = DECL_NAME
;;;                                                         name = col
;;;                                                       } 27 DeclItem
;;;                                                     } 26 List<DeclItem>
;;;                                                   } 25 TypeName
;;;                                                   { 25 NumericExpression (constant 0 = 0x0)
;--	load_rr_constant
	MOVE	#0x0000, RR
;;;                                                   } 25 NumericExpression (constant 0 = 0x0)
;--	store_rr_var col = -5(FP), SP at -5
	MOVE	RR, 0(SP)
;;;                                                 } 24 Expr l = r
;;;                                               } 23 ExpressionStatement
;--	branch
	JMP	L18_tst_66
L18_loop_66:
;;;                                               { 23 CompoundStatement
;;;                                                 { 24 List<ExpressionStatement>
;;;                                                   { 25 ExpressionStatement
;;;                                                     { 26 Expr l = r
;;;                                                       { 27 TypeName
;;;                                                         { 28 TypeSpecifier (all)
;;;                                                           spec = char (20000)
;;;                                                         } 28 TypeSpecifier (all)
;;;                                                         { 28 List<DeclItem>
;;;                                                           { 29 DeclItem
;;;                                                             what = DECL_NAME
;;;                                                             name = c
;;;                                                           } 29 DeclItem
;;;                                                         } 28 List<DeclItem>
;;;                                                       } 27 TypeName
;;;                                                       { 27 Expr * r
;;;                                                         { 28 Expr l - r
;;;                                                           { 29 Expr ++r
;;;                                                             { 30 Expression (variable name)
;;;                                                               expr_type = "identifier" (address)
;--	load_rr_var address = 2(FP), SP at -5 (16 bit)
	MOVE	7(SP), RR
;;;                                                             } 30 Expression (variable name)
;--	++
	ADD	RR, #0x0001
;--	store_rr_var address = 2(FP), SP at -5
	MOVE	RR, 7(SP)
;;;                                                           } 29 Expr ++r
;--	l - r
	SUB	RR, #0x0001
;;;                                                         } 28 Expr l - r
;--	content
	MOVE	(RR), RU
;;;                                                       } 27 Expr * r
;--	store_rr_var c = -1(FP), SP at -5
	MOVE	R, 4(SP)
;;;                                                     } 26 Expr l = r
;;;                                                   } 25 ExpressionStatement
;;;                                                   { 25 IfElseStatement
;;;                                                     { 26 Expr l < r
;;;                                                       { 27 TypeName (internal)
;;;                                                         { 28 TypeSpecifier (all)
;;;                                                           spec = int (80000)
;;;                                                         } 28 TypeSpecifier (all)
;;;                                                       } 27 TypeName (internal)
;;;                                                       { 27 Expression (variable name)
;;;                                                         expr_type = "identifier" (c)
;--	load_rr_var c = -1(FP), SP at -5 (8 bit)
	MOVE	4(SP), RS
;;;                                                       } 27 Expression (variable name)
;--	l < r
	SLT	RR, #0x0020
;;;                                                     } 26 Expr l < r
;--	branch_false
	JMP	RRZ, L18_else_68
;;;                                                     { 26 ExpressionStatement
;;;                                                       { 27 Expr l(r)
;;;                                                         { 28 TypeName
;;;                                                           { 29 TypeSpecifier (all)
;;;                                                             spec = int (80000)
;;;                                                           } 29 TypeSpecifier (all)
;;;                                                           { 29 List<DeclItem>
;;;                                                             { 30 DeclItem
;;;                                                               what = DECL_NAME
;;;                                                               name = putchr
;;;                                                             } 30 DeclItem
;;;                                                           } 29 List<DeclItem>
;;;                                                         } 28 TypeName
;;;                                                         { 28 ParameterDeclaration
;;;                                                           isEllipsis = false
;;;                                                           { 29 TypeName
;;;                                                             { 30 TypeSpecifier (all)
;;;                                                               spec = char (20000)
;;;                                                             } 30 TypeSpecifier (all)
;;;                                                             { 30 List<DeclItem>
;;;                                                               { 31 DeclItem
;;;                                                                 what = DECL_NAME
;;;                                                                 name = c
;;;                                                               } 31 DeclItem
;;;                                                             } 30 List<DeclItem>
;;;                                                           } 29 TypeName
;;;                                                         } 28 ParameterDeclaration
;;;                                                         { 28 NumericExpression (constant 46 = 0x2E)
;--	load_rr_constant
	MOVE	#0x002E, RR
;;;                                                         } 28 NumericExpression (constant 46 = 0x2E)
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;--	push 2 bytes
;--	call
	CALL	Cputchr
;--	pop 1 bytes
	ADD	SP, #1
;;;                                                       } 27 Expr l(r)
;;;                                                     } 26 ExpressionStatement
;--	branch
	JMP	L18_endif_68
L18_else_68:
;;;                                                     { 26 IfElseStatement
;;;                                                       { 27 Expr l < r
;;;                                                         { 28 TypeName (internal)
;;;                                                           { 29 TypeSpecifier (all)
;;;                                                             spec = int (80000)
;;;                                                           } 29 TypeSpecifier (all)
;;;                                                         } 28 TypeName (internal)
;;;                                                         { 28 Expression (variable name)
;;;                                                           expr_type = "identifier" (c)
;--	load_rr_var c = -1(FP), SP at -5 (8 bit)
	MOVE	4(SP), RS
;;;                                                         } 28 Expression (variable name)
;--	l < r
	SLT	RR, #0x007F
;;;                                                       } 27 Expr l < r
;--	branch_false
	JMP	RRZ, L18_else_69
;;;                                                       { 27 ExpressionStatement
;;;                                                         { 28 Expr l(r)
;;;                                                           { 29 TypeName
;;;                                                             { 30 TypeSpecifier (all)
;;;                                                               spec = int (80000)
;;;                                                             } 30 TypeSpecifier (all)
;;;                                                             { 30 List<DeclItem>
;;;                                                               { 31 DeclItem
;;;                                                                 what = DECL_NAME
;;;                                                                 name = putchr
;;;                                                               } 31 DeclItem
;;;                                                             } 30 List<DeclItem>
;;;                                                           } 29 TypeName
;;;                                                           { 29 ParameterDeclaration
;;;                                                             isEllipsis = false
;;;                                                             { 30 TypeName
;;;                                                               { 31 TypeSpecifier (all)
;;;                                                                 spec = char (20000)
;;;                                                               } 31 TypeSpecifier (all)
;;;                                                               { 31 List<DeclItem>
;;;                                                                 { 32 DeclItem
;;;                                                                   what = DECL_NAME
;;;                                                                   name = c
;;;                                                                 } 32 DeclItem
;;;                                                               } 31 List<DeclItem>
;;;                                                             } 30 TypeName
;;;                                                           } 29 ParameterDeclaration
;;;                                                           { 29 Expression (variable name)
;;;                                                             expr_type = "identifier" (c)
;--	load_rr_var c = -1(FP), SP at -5 (8 bit)
	MOVE	4(SP), RS
;;;                                                           } 29 Expression (variable name)
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;--	push 2 bytes
;--	call
	CALL	Cputchr
;--	pop 1 bytes
	ADD	SP, #1
;;;                                                         } 28 Expr l(r)
;;;                                                       } 27 ExpressionStatement
;--	branch
	JMP	L18_endif_69
L18_else_69:
;;;                                                       { 27 ExpressionStatement
;;;                                                         { 28 Expr l(r)
;;;                                                           { 29 TypeName
;;;                                                             { 30 TypeSpecifier (all)
;;;                                                               spec = int (80000)
;;;                                                             } 30 TypeSpecifier (all)
;;;                                                             { 30 List<DeclItem>
;;;                                                               { 31 DeclItem
;;;                                                                 what = DECL_NAME
;;;                                                                 name = putchr
;;;                                                               } 31 DeclItem
;;;                                                             } 30 List<DeclItem>
;;;                                                           } 29 TypeName
;;;                                                           { 29 ParameterDeclaration
;;;                                                             isEllipsis = false
;;;                                                             { 30 TypeName
;;;                                                               { 31 TypeSpecifier (all)
;;;                                                                 spec = char (20000)
;;;                                                               } 31 TypeSpecifier (all)
;;;                                                               { 31 List<DeclItem>
;;;                                                                 { 32 DeclItem
;;;                                                                   what = DECL_NAME
;;;                                                                   name = c
;;;                                                                 } 32 DeclItem
;;;                                                               } 31 List<DeclItem>
;;;                                                             } 30 TypeName
;;;                                                           } 29 ParameterDeclaration
;;;                                                           { 29 NumericExpression (constant 46 = 0x2E)
;--	load_rr_constant
	MOVE	#0x002E, RR
;;;                                                           } 29 NumericExpression (constant 46 = 0x2E)
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;--	push 2 bytes
;--	call
	CALL	Cputchr
;--	pop 1 bytes
	ADD	SP, #1
;;;                                                         } 28 Expr l(r)
;;;                                                       } 27 ExpressionStatement
L18_endif_69:
;;;                                                     } 26 IfElseStatement
L18_endif_68:
;;;                                                   } 25 IfElseStatement
;;;                                                 } 24 List<ExpressionStatement>
;--	pop 0 bytes
;;;                                               } 23 CompoundStatement
L18_cont_66:
;;;                                               { 23 Expr l - r
;;;                                                 { 24 Expr ++r
;;;                                                   { 25 Expression (variable name)
;;;                                                     expr_type = "identifier" (col)
;--	load_rr_var col = -5(FP), SP at -5 (16 bit)
	MOVE	0(SP), RR
;;;                                                   } 25 Expression (variable name)
;--	++
	ADD	RR, #0x0001
;--	store_rr_var col = -5(FP), SP at -5
	MOVE	RR, 0(SP)
;;;                                                 } 24 Expr ++r
;--	l - r
	SUB	RR, #0x0001
;;;                                               } 23 Expr l - r
L18_tst_66:
;;;                                               { 23 Expr l < r
;;;                                                 { 24 TypeName (internal)
;;;                                                   { 25 TypeSpecifier (all)
;;;                                                     spec = int (80000)
;;;                                                   } 25 TypeSpecifier (all)
;;;                                                 } 24 TypeName (internal)
;;;                                                 { 24 Expression (variable name)
;;;                                                   expr_type = "identifier" (col)
;--	load_rr_var col = -5(FP), SP at -5 (16 bit)
	MOVE	0(SP), RR
;;;                                                 } 24 Expression (variable name)
;--	l < r
	SLT	RR, #0x0010
;;;                                               } 23 Expr l < r
;--	branch_true
	JMP	RRNZ, L18_loop_66
L18_brk_67:
;;;                                             } 22 for Statement
;;;                                             { 22 ExpressionStatement
;;;                                               { 23 Expr l(r)
;;;                                                 { 24 TypeName
;;;                                                   { 25 TypeSpecifier (all)
;;;                                                     spec = int (80000)
;;;                                                   } 25 TypeSpecifier (all)
;;;                                                   { 25 List<DeclItem>
;;;                                                     { 26 DeclItem
;;;                                                       what = DECL_NAME
;;;                                                       name = printf
;;;                                                     } 26 DeclItem
;;;                                                   } 25 List<DeclItem>
;;;                                                 } 24 TypeName
;;;                                                 { 24 ParameterDeclaration
;;;                                                   isEllipsis = true
;;;                                                   { 25 TypeName
;;;                                                     { 26 TypeSpecifier (all)
;;;                                                       spec = const char (20100)
;;;                                                     } 26 TypeSpecifier (all)
;;;                                                     { 26 List<DeclItem>
;;;                                                       { 27 DeclItem
;;;                                                         what = DECL_POINTER
;;;                                                         { 28 List<Ptr>
;;;                                                           { 29 Ptr
;;;                                                           } 29 Ptr
;;;                                                         } 28 List<Ptr>
;;;                                                       } 27 DeclItem
;;;                                                       { 27 DeclItem
;;;                                                         what = DECL_NAME
;;;                                                         name = format
;;;                                                       } 27 DeclItem
;;;                                                     } 26 List<DeclItem>
;;;                                                   } 25 TypeName
;;;                                                 } 24 ParameterDeclaration
;;;                                                 { 24 StringExpression
;--	load_rr_string
	MOVE	#Cstr_32, RR
;;;                                                 } 24 StringExpression
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;--	push 2 bytes
;--	call
	CALL	Cprintf
;--	pop 2 bytes
	ADD	SP, #2
;;;                                               } 23 Expr l(r)
;;;                                             } 22 ExpressionStatement
;;;                                           } 21 List<ExpressionStatement>
;--	pop 0 bytes
;;;                                         } 20 CompoundStatement
L18_cont_62:
;;;                                         { 20 Expr l - r
;;;                                           { 21 Expr ++r
;;;                                             { 22 Expression (variable name)
;;;                                               expr_type = "identifier" (row)
;--	load_rr_var row = -3(FP), SP at -5 (16 bit)
	MOVE	2(SP), RR
;;;                                             } 22 Expression (variable name)
;--	++
	ADD	RR, #0x0001
;--	store_rr_var row = -3(FP), SP at -5
	MOVE	RR, 2(SP)
;;;                                           } 21 Expr ++r
;--	l - r
	SUB	RR, #0x0001
;;;                                         } 20 Expr l - r
L18_tst_62:
;;;                                         { 20 Expr l < r
;;;                                           { 21 TypeName (internal)
;;;                                             { 22 TypeSpecifier (all)
;;;                                               spec = int (80000)
;;;                                             } 22 TypeSpecifier (all)
;;;                                           } 21 TypeName (internal)
;;;                                           { 21 Expression (variable name)
;;;                                             expr_type = "identifier" (row)
;--	load_rr_var row = -3(FP), SP at -5 (16 bit)
	MOVE	2(SP), RR
;;;                                           } 21 Expression (variable name)
;--	l < r
	SLT	RR, #0x0010
;;;                                         } 20 Expr l < r
;--	branch_true
	JMP	RRNZ, L18_loop_62
L18_brk_63:
;;;                                       } 19 for Statement
;;;                                     } 18 List<for Statement>
;--	pop 5 bytes
	ADD	SP, #5
;;;                                   } 17 CompoundStatement
;--	ret
	RET
;;; ------------------------------------;
;;;                                   { 17 FunctionDefinition
;;;                                     { 18 TypeName
;;;                                       { 19 TypeSpecifier (all)
;;;                                         spec = int (80000)
;;;                                       } 19 TypeSpecifier (all)
;;;                                       { 19 List<DeclItem>
;;;                                         { 20 DeclItem
;;;                                           what = DECL_NAME
;;;                                           name = main
;;;                                         } 20 DeclItem
;;;                                       } 19 List<DeclItem>
;;;                                     } 18 TypeName
;;;                                     { 18 List<DeclItem>
;;;                                       { 19 DeclItem
;;;                                         what = DECL_NAME
;;;                                         name = main
;;;                                       } 19 DeclItem
;;;                                       { 19 DeclItem
;;;                                         what = DECL_FUN
;;;                                         { 20 List<ParameterDeclaration>
;;;                                           { 21 ParameterDeclaration
;;;                                             isEllipsis = false
;;;                                             { 22 TypeName
;;;                                               { 23 TypeSpecifier (all)
;;;                                                 spec = int (80000)
;;;                                               } 23 TypeSpecifier (all)
;;;                                               { 23 List<DeclItem>
;;;                                                 { 24 DeclItem
;;;                                                   what = DECL_NAME
;;;                                                   name = argc
;;;                                                 } 24 DeclItem
;;;                                               } 23 List<DeclItem>
;;;                                             } 22 TypeName
;;;                                           } 21 ParameterDeclaration
;;;                                           { 21 ParameterDeclaration
;;;                                             isEllipsis = false
;;;                                             { 22 TypeName
;;;                                               { 23 TypeSpecifier (all)
;;;                                                 spec = char (20000)
;;;                                               } 23 TypeSpecifier (all)
;;;                                               { 23 List<DeclItem>
;;;                                                 { 24 DeclItem
;;;                                                   what = DECL_POINTER
;;;                                                   { 25 List<Ptr>
;;;                                                     { 26 Ptr
;;;                                                     } 26 Ptr
;;;                                                   } 25 List<Ptr>
;;;                                                 } 24 DeclItem
;;;                                                 { 24 DeclItem
;;;                                                   what = DECL_NAME
;;;                                                   name = argv
;;;                                                 } 24 DeclItem
;;;                                                 { 24 DeclItem
;;;                                                   what = DECL_ARRAY
;;;                                                 } 24 DeclItem
;;;                                               } 23 List<DeclItem>
;;;                                             } 22 TypeName
;;;                                           } 21 ParameterDeclaration
;;;                                         } 20 List<ParameterDeclaration>
;;;                                       } 19 DeclItem
;;;                                     } 18 List<DeclItem>
Cmain:
;;;                                     { 18 CompoundStatement
;;;                                       { 19 InitDeclarator
;;;                                         { 20 List<DeclItem>
;;;                                           { 21 DeclItem
;;;                                             what = DECL_NAME
;;;                                             name = c
;;;                                           } 21 DeclItem
;;;                                         } 20 List<DeclItem>
;--	push_zero 1 bytes
	CLRB	-(SP)
;;;                                       } 19 InitDeclarator
;;;                                       { 19 InitDeclarator
;;;                                         { 20 List<DeclItem>
;;;                                           { 21 DeclItem
;;;                                             what = DECL_NAME
;;;                                             name = noprompt
;;;                                           } 21 DeclItem
;;;                                         } 20 List<DeclItem>
;--	push_zero 1 bytes
	CLRB	-(SP)
;;;                                       } 19 InitDeclarator
;;;                                       { 19 InitDeclarator
;;;                                         { 20 List<DeclItem>
;;;                                           { 21 DeclItem
;;;                                             what = DECL_NAME
;;;                                             name = last_c
;;;                                           } 21 DeclItem
;;;                                         } 20 List<DeclItem>
;--	push_zero 1 bytes
	CLRB	-(SP)
;;;                                       } 19 InitDeclarator
;;;                                       { 19 InitDeclarator
;;;                                         { 20 List<DeclItem>
;;;                                           { 21 DeclItem
;;;                                             what = DECL_POINTER
;;;                                             { 22 List<Ptr>
;;;                                               { 23 Ptr
;;;                                               } 23 Ptr
;;;                                             } 22 List<Ptr>
;;;                                           } 21 DeclItem
;;;                                           { 21 DeclItem
;;;                                             what = DECL_NAME
;;;                                             name = address
;;;                                           } 21 DeclItem
;;;                                         } 20 List<DeclItem>
;--	push_zero 2 bytes
	CLRW	-(SP)
;;;                                       } 19 InitDeclarator
;;;                                       { 19 List<ExpressionStatement>
;;;                                         { 20 ExpressionStatement
	MOVE #0x05, RR
;;;                                         } 20 ExpressionStatement
;;;                                         { 20 ExpressionStatement
	OUT  R, (OUT_INT_MASK)
;;;                                         } 20 ExpressionStatement
;;;                                         { 20 for Statement
;;;                                           { 21 ExpressionStatement
;;;                                           } 21 ExpressionStatement
L19_loop_70:
;;;                                           { 21 CompoundStatement
;;;                                             { 22 List<ExpressionStatement>
;;;                                               { 23 ExpressionStatement
;;;                                                 { 24 Expr l = r
;;;                                                   { 25 TypeName
;;;                                                     { 26 TypeSpecifier (all)
;;;                                                       spec = char (20000)
;;;                                                     } 26 TypeSpecifier (all)
;;;                                                     { 26 List<DeclItem>
;;;                                                       { 27 DeclItem
;;;                                                         what = DECL_NAME
;;;                                                         name = last_c
;;;                                                       } 27 DeclItem
;;;                                                     } 26 List<DeclItem>
;;;                                                   } 25 TypeName
;;;                                                   { 25 Expression (variable name)
;;;                                                     expr_type = "identifier" (c)
;--	load_rr_var c = -1(FP), SP at -5 (8 bit)
	MOVE	4(SP), RS
;;;                                                   } 25 Expression (variable name)
;--	store_rr_var last_c = -3(FP), SP at -5
	MOVE	R, 2(SP)
;;;                                                 } 24 Expr l = r
;;;                                               } 23 ExpressionStatement
;;;                                               { 23 IfElseStatement
;;;                                                 { 24 Expr ! r
;;;                                                   { 25 Expression (variable name)
;;;                                                     expr_type = "identifier" (noprompt)
;--	load_rr_var noprompt = -2(FP), SP at -5 (8 bit)
	MOVE	3(SP), RS
;;;                                                   } 25 Expression (variable name)
;--	16 bit ! r
	LNOT	RR
;;;                                                 } 24 Expr ! r
;--	branch_false
	JMP	RRZ, L19_endif_72
;;;                                                 { 24 ExpressionStatement
;;;                                                   { 25 Expr l(r)
;;;                                                     { 26 TypeName
;;;                                                       { 27 TypeSpecifier (all)
;;;                                                         spec = int (80000)
;;;                                                       } 27 TypeSpecifier (all)
;;;                                                       { 27 List<DeclItem>
;;;                                                         { 28 DeclItem
;;;                                                           what = DECL_NAME
;;;                                                           name = printf
;;;                                                         } 28 DeclItem
;;;                                                       } 27 List<DeclItem>
;;;                                                     } 26 TypeName
;;;                                                     { 26 ParameterDeclaration
;;;                                                       isEllipsis = true
;;;                                                       { 27 TypeName
;;;                                                         { 28 TypeSpecifier (all)
;;;                                                           spec = const char (20100)
;;;                                                         } 28 TypeSpecifier (all)
;;;                                                         { 28 List<DeclItem>
;;;                                                           { 29 DeclItem
;;;                                                             what = DECL_POINTER
;;;                                                             { 30 List<Ptr>
;;;                                                               { 31 Ptr
;;;                                                               } 31 Ptr
;;;                                                             } 30 List<Ptr>
;;;                                                           } 29 DeclItem
;;;                                                           { 29 DeclItem
;;;                                                             what = DECL_NAME
;;;                                                             name = format
;;;                                                           } 29 DeclItem
;;;                                                         } 28 List<DeclItem>
;;;                                                       } 27 TypeName
;;;                                                     } 26 ParameterDeclaration
;;;                                                     { 26 StringExpression
;--	load_rr_string
	MOVE	#Cstr_35, RR
;;;                                                     } 26 StringExpression
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;--	push 2 bytes
;--	call
	CALL	Cprintf
;--	pop 2 bytes
	ADD	SP, #2
;;;                                                   } 25 Expr l(r)
;;;                                                 } 24 ExpressionStatement
L19_endif_72:
;;;                                               } 23 IfElseStatement
;;;                                               { 23 ExpressionStatement
;;;                                                 { 24 Expr l = r
;;;                                                   { 25 TypeName
;;;                                                     { 26 TypeSpecifier (all)
;;;                                                       spec = char (20000)
;;;                                                     } 26 TypeSpecifier (all)
;;;                                                     { 26 List<DeclItem>
;;;                                                       { 27 DeclItem
;;;                                                         what = DECL_NAME
;;;                                                         name = noprompt
;;;                                                       } 27 DeclItem
;;;                                                     } 26 List<DeclItem>
;;;                                                   } 25 TypeName
;;;                                                   { 25 NumericExpression (constant 0 = 0x0)
;--	load_rr_constant
	MOVE	#0x0000, RR
;;;                                                   } 25 NumericExpression (constant 0 = 0x0)
;--	store_rr_var noprompt = -2(FP), SP at -5
	MOVE	R, 3(SP)
;;;                                                 } 24 Expr l = r
;;;                                               } 23 ExpressionStatement
;;;                                               { 23 SwitchStatement
;;;                                                 { 24 Expr l = r
;;;                                                   { 25 TypeName
;;;                                                     { 26 TypeSpecifier (all)
;;;                                                       spec = char (20000)
;;;                                                     } 26 TypeSpecifier (all)
;;;                                                     { 26 List<DeclItem>
;;;                                                       { 27 DeclItem
;;;                                                         what = DECL_NAME
;;;                                                         name = c
;;;                                                       } 27 DeclItem
;;;                                                     } 26 List<DeclItem>
;;;                                                   } 25 TypeName
;;;                                                   { 25 Expr l(r)
;;;                                                     { 26 TypeName
;;;                                                       { 27 TypeSpecifier (all)
;;;                                                         spec = int (80000)
;;;                                                       } 27 TypeSpecifier (all)
;;;                                                       { 27 List<DeclItem>
;;;                                                         { 28 DeclItem
;;;                                                           what = DECL_NAME
;;;                                                           name = getchr
;;;                                                         } 28 DeclItem
;;;                                                       } 27 List<DeclItem>
;;;                                                     } 26 TypeName
;--	push 2 bytes
;--	call
	CALL	Cgetchr
;--	pop 0 bytes
;;;                                                   } 25 Expr l(r)
;--	store_rr_var c = -1(FP), SP at -5
	MOVE	R, 4(SP)
;;;                                                 } 24 Expr l = r
;--	move_rr_to_ll
	MOVE	RR, LL
;--	branch_case (8 bit)
	SEQ	LL, #0x000D
	JMP	RRNZ, L19_case_73_000D
;--	branch_case (8 bit)
	SEQ	LL, #0x000A
	JMP	RRNZ, L19_case_73_000A
;--	branch_case (8 bit)
	SEQ	LL, #0x0043
	JMP	RRNZ, L19_case_73_0043
;--	branch_case (8 bit)
	SEQ	LL, #0x0063
	JMP	RRNZ, L19_case_73_0063
;--	branch_case (8 bit)
	SEQ	LL, #0x0044
	JMP	RRNZ, L19_case_73_0044
;--	branch_case (8 bit)
	SEQ	LL, #0x0064
	JMP	RRNZ, L19_case_73_0064
;--	branch_case (8 bit)
	SEQ	LL, #0x0045
	JMP	RRNZ, L19_case_73_0045
;--	branch_case (8 bit)
	SEQ	LL, #0x0065
	JMP	RRNZ, L19_case_73_0065
;--	branch_case (8 bit)
	SEQ	LL, #0x004D
	JMP	RRNZ, L19_case_73_004D
;--	branch_case (8 bit)
	SEQ	LL, #0x006D
	JMP	RRNZ, L19_case_73_006D
;--	branch_case (8 bit)
	SEQ	LL, #0x0053
	JMP	RRNZ, L19_case_73_0053
;--	branch_case (8 bit)
	SEQ	LL, #0x0073
	JMP	RRNZ, L19_case_73_0073
;--	branch_case (8 bit)
	SEQ	LL, #0x0054
	JMP	RRNZ, L19_case_73_0054
;--	branch_case (8 bit)
	SEQ	LL, #0x0074
	JMP	RRNZ, L19_case_73_0074
;--	branch_case (8 bit)
	SEQ	LL, #0x0051
	JMP	RRNZ, L19_case_73_0051
;--	branch_case (8 bit)
	SEQ	LL, #0x0071
	JMP	RRNZ, L19_case_73_0071
;--	branch_case (8 bit)
	SEQ	LL, #0x0058
	JMP	RRNZ, L19_case_73_0058
;--	branch_case (8 bit)
	SEQ	LL, #0x0078
	JMP	RRNZ, L19_case_73_0078
;--	branch
	JMP	L19_deflt_73
;;;                                                 { 24 CompoundStatement
;;;                                                   { 25 List<case Statement>
;;;                                                     { 26 case Statement
L19_case_73_000D:
;;;                                                       { 27 case Statement
L19_case_73_000A:
;;;                                                         { 28 IfElseStatement
;;;                                                           { 29 Expr l == r
;;;                                                             { 30 TypeName (internal)
;;;                                                               { 31 TypeSpecifier (all)
;;;                                                                 spec = int (80000)
;;;                                                               } 31 TypeSpecifier (all)
;;;                                                             } 30 TypeName (internal)
;;;                                                             { 30 Expression (variable name)
;;;                                                               expr_type = "identifier" (last_c)
;--	load_rr_var last_c = -3(FP), SP at -5 (8 bit)
	MOVE	2(SP), RS
;;;                                                             } 30 Expression (variable name)
;--	l == r
	SEQ	RR, #0x0064
;;;                                                           } 29 Expr l == r
;--	branch_false
	JMP	RRZ, L19_endif_74
;;;                                                           { 29 CompoundStatement
;;;                                                             { 30 List<ExpressionStatement>
;;;                                                               { 31 ExpressionStatement
;;;                                                                 { 32 Expr l += r
;;;                                                                   { 33 TypeName
;;;                                                                     { 34 TypeSpecifier (all)
;;;                                                                       spec = unsigned char (22000)
;;;                                                                     } 34 TypeSpecifier (all)
;;;                                                                     { 34 List<DeclItem>
;;;                                                                       { 35 DeclItem
;;;                                                                         what = DECL_POINTER
;;;                                                                         { 36 List<Ptr>
;;;                                                                           { 37 Ptr
;;;                                                                           } 37 Ptr
;;;                                                                         } 36 List<Ptr>
;;;                                                                       } 35 DeclItem
;;;                                                                       { 35 DeclItem
;;;                                                                         what = DECL_NAME
;;;                                                                         name = address
;;;                                                                       } 35 DeclItem
;;;                                                                     } 34 List<DeclItem>
;;;                                                                   } 33 TypeName
;;;                                                                   { 33 Expr l + r
;;;                                                                     { 34 Expression (variable name)
;;;                                                                       expr_type = "identifier" (address)
;--	load_rr_var address = -5(FP), SP at -5 (16 bit)
	MOVE	0(SP), RR
;;;                                                                     } 34 Expression (variable name)
;--	l + r
	ADD	RR, #0x0100
;;;                                                                   } 33 Expr l + r
;--	store_rr_var address = -5(FP), SP at -5
	MOVE	RR, 0(SP)
;;;                                                                 } 32 Expr l += r
;;;                                                               } 31 ExpressionStatement
;;;                                                               { 31 ExpressionStatement
;;;                                                                 { 32 Expr l(r)
;;;                                                                   { 33 TypeName
;;;                                                                     { 34 TypeSpecifier (all)
;;;                                                                       spec = int (80000)
;;;                                                                     } 34 TypeSpecifier (all)
;;;                                                                     { 34 List<DeclItem>
;;;                                                                       { 35 DeclItem
;;;                                                                         what = DECL_NAME
;;;                                                                         name = printf
;;;                                                                       } 35 DeclItem
;;;                                                                     } 34 List<DeclItem>
;;;                                                                   } 33 TypeName
;;;                                                                   { 33 ParameterDeclaration
;;;                                                                     isEllipsis = true
;;;                                                                     { 34 TypeName
;;;                                                                       { 35 TypeSpecifier (all)
;;;                                                                         spec = const char (20100)
;;;                                                                       } 35 TypeSpecifier (all)
;;;                                                                       { 35 List<DeclItem>
;;;                                                                         { 36 DeclItem
;;;                                                                           what = DECL_POINTER
;;;                                                                           { 37 List<Ptr>
;;;                                                                             { 38 Ptr
;;;                                                                             } 38 Ptr
;;;                                                                           } 37 List<Ptr>
;;;                                                                         } 36 DeclItem
;;;                                                                         { 36 DeclItem
;;;                                                                           what = DECL_NAME
;;;                                                                           name = format
;;;                                                                         } 36 DeclItem
;;;                                                                       } 35 List<DeclItem>
;;;                                                                     } 34 TypeName
;;;                                                                   } 33 ParameterDeclaration
;;;                                                                   { 33 StringExpression
;--	load_rr_string
	MOVE	#Cstr_36, RR
;;;                                                                   } 33 StringExpression
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;--	push 2 bytes
;--	call
	CALL	Cprintf
;--	pop 2 bytes
	ADD	SP, #2
;;;                                                                 } 32 Expr l(r)
;;;                                                               } 31 ExpressionStatement
;;;                                                               { 31 ExpressionStatement
;;;                                                                 { 32 Expr l(r)
;;;                                                                   { 33 TypeName
;;;                                                                     { 34 TypeSpecifier (all)
;;;                                                                       spec = void (10000)
;;;                                                                     } 34 TypeSpecifier (all)
;;;                                                                     { 34 List<DeclItem>
;;;                                                                       { 35 DeclItem
;;;                                                                         what = DECL_NAME
;;;                                                                         name = display_memory
;;;                                                                       } 35 DeclItem
;;;                                                                     } 34 List<DeclItem>
;;;                                                                   } 33 TypeName
;;;                                                                   { 33 ParameterDeclaration
;;;                                                                     isEllipsis = false
;;;                                                                     { 34 TypeName
;;;                                                                       { 35 TypeSpecifier (all)
;;;                                                                         spec = unsigned char (22000)
;;;                                                                       } 35 TypeSpecifier (all)
;;;                                                                       { 35 List<DeclItem>
;;;                                                                         { 36 DeclItem
;;;                                                                           what = DECL_POINTER
;;;                                                                           { 37 List<Ptr>
;;;                                                                             { 38 Ptr
;;;                                                                             } 38 Ptr
;;;                                                                           } 37 List<Ptr>
;;;                                                                         } 36 DeclItem
;;;                                                                         { 36 DeclItem
;;;                                                                           what = DECL_NAME
;;;                                                                           name = address
;;;                                                                         } 36 DeclItem
;;;                                                                       } 35 List<DeclItem>
;;;                                                                     } 34 TypeName
;;;                                                                   } 33 ParameterDeclaration
;;;                                                                   { 33 Expression (variable name)
;;;                                                                     expr_type = "identifier" (address)
;--	load_rr_var address = -5(FP), SP at -5 (16 bit)
	MOVE	0(SP), RR
;;;                                                                   } 33 Expression (variable name)
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;--	push 0 bytes
;--	call
	CALL	Cdisplay_memory
;--	pop 2 bytes
	ADD	SP, #2
;;;                                                                 } 32 Expr l(r)
;;;                                                               } 31 ExpressionStatement
;;;                                                               { 31 ExpressionStatement
;;;                                                                 { 32 Expr l = r
;;;                                                                   { 33 TypeName
;;;                                                                     { 34 TypeSpecifier (all)
;;;                                                                       spec = char (20000)
;;;                                                                     } 34 TypeSpecifier (all)
;;;                                                                     { 34 List<DeclItem>
;;;                                                                       { 35 DeclItem
;;;                                                                         what = DECL_NAME
;;;                                                                         name = c
;;;                                                                       } 35 DeclItem
;;;                                                                     } 34 List<DeclItem>
;;;                                                                   } 33 TypeName
;;;                                                                   { 33 NumericExpression (constant 100 = 0x64)
;--	load_rr_constant
	MOVE	#0x0064, RR
;;;                                                                   } 33 NumericExpression (constant 100 = 0x64)
;--	store_rr_var c = -1(FP), SP at -5
	MOVE	R, 4(SP)
;;;                                                                 } 32 Expr l = r
;;;                                                               } 31 ExpressionStatement
;;;                                                             } 30 List<ExpressionStatement>
;--	pop 0 bytes
;;;                                                           } 29 CompoundStatement
L19_endif_74:
;;;                                                         } 28 IfElseStatement
;;;                                                       } 27 case Statement
;;;                                                     } 26 case Statement
;;;                                                     { 26 ExpressionStatement
;;;                                                       { 27 Expr l = r
;;;                                                         { 28 TypeName
;;;                                                           { 29 TypeSpecifier (all)
;;;                                                             spec = char (20000)
;;;                                                           } 29 TypeSpecifier (all)
;;;                                                           { 29 List<DeclItem>
;;;                                                             { 30 DeclItem
;;;                                                               what = DECL_NAME
;;;                                                               name = noprompt
;;;                                                             } 30 DeclItem
;;;                                                           } 29 List<DeclItem>
;;;                                                         } 28 TypeName
;;;                                                         { 28 NumericExpression (constant 1 = 0x1)
;--	load_rr_constant
	MOVE	#0x0001, RR
;;;                                                         } 28 NumericExpression (constant 1 = 0x1)
;--	store_rr_var noprompt = -2(FP), SP at -5
	MOVE	R, 3(SP)
;;;                                                       } 27 Expr l = r
;;;                                                     } 26 ExpressionStatement
;;;                                                     { 26 break/continue Statement
;--	branch
	JMP	L19_brk_73
;;;                                                     } 26 break/continue Statement
;;;                                                     { 26 case Statement
L19_case_73_0043:
;;;                                                       { 27 case Statement
L19_case_73_0063:
;;;                                                         { 28 ExpressionStatement
;;;                                                           { 29 Expr l(r)
;;;                                                             { 30 TypeName
;;;                                                               { 31 TypeSpecifier (all)
;;;                                                                 spec = void (10000)
;;;                                                               } 31 TypeSpecifier (all)
;;;                                                               { 31 List<DeclItem>
;;;                                                                 { 32 DeclItem
;;;                                                                   what = DECL_NAME
;;;                                                                   name = show_time
;;;                                                                 } 32 DeclItem
;;;                                                               } 31 List<DeclItem>
;;;                                                             } 30 TypeName
;--	push 0 bytes
;--	call
	CALL	Cshow_time
;--	pop 0 bytes
;;;                                                           } 29 Expr l(r)
;;;                                                         } 28 ExpressionStatement
;;;                                                       } 27 case Statement
;;;                                                     } 26 case Statement
;;;                                                     { 26 break/continue Statement
;--	branch
	JMP	L19_brk_73
;;;                                                     } 26 break/continue Statement
;;;                                                     { 26 case Statement
L19_case_73_0044:
;;;                                                       { 27 case Statement
L19_case_73_0064:
;;;                                                         { 28 ExpressionStatement
;;;                                                           { 29 Expr l = r
;;;                                                             { 30 TypeName
;;;                                                               { 31 TypeSpecifier (all)
;;;                                                                 spec = char (20000)
;;;                                                               } 31 TypeSpecifier (all)
;;;                                                               { 31 List<DeclItem>
;;;                                                                 { 32 DeclItem
;;;                                                                   what = DECL_NAME
;;;                                                                   name = last_c
;;;                                                                 } 32 DeclItem
;;;                                                               } 31 List<DeclItem>
;;;                                                             } 30 TypeName
;;;                                                             { 30 NumericExpression (constant 100 = 0x64)
;--	load_rr_constant
	MOVE	#0x0064, RR
;;;                                                             } 30 NumericExpression (constant 100 = 0x64)
;--	store_rr_var last_c = -3(FP), SP at -5
	MOVE	R, 2(SP)
;;;                                                           } 29 Expr l = r
;;;                                                         } 28 ExpressionStatement
;;;                                                       } 27 case Statement
;;;                                                     } 26 case Statement
;;;                                                     { 26 ExpressionStatement
;;;                                                       { 27 Expr l(r)
;;;                                                         { 28 TypeName
;;;                                                           { 29 TypeSpecifier (all)
;;;                                                             spec = int (80000)
;;;                                                           } 29 TypeSpecifier (all)
;;;                                                           { 29 List<DeclItem>
;;;                                                             { 30 DeclItem
;;;                                                               what = DECL_NAME
;;;                                                               name = printf
;;;                                                             } 30 DeclItem
;;;                                                           } 29 List<DeclItem>
;;;                                                         } 28 TypeName
;;;                                                         { 28 ParameterDeclaration
;;;                                                           isEllipsis = true
;;;                                                           { 29 TypeName
;;;                                                             { 30 TypeSpecifier (all)
;;;                                                               spec = const char (20100)
;;;                                                             } 30 TypeSpecifier (all)
;;;                                                             { 30 List<DeclItem>
;;;                                                               { 31 DeclItem
;;;                                                                 what = DECL_POINTER
;;;                                                                 { 32 List<Ptr>
;;;                                                                   { 33 Ptr
;;;                                                                   } 33 Ptr
;;;                                                                 } 32 List<Ptr>
;;;                                                               } 31 DeclItem
;;;                                                               { 31 DeclItem
;;;                                                                 what = DECL_NAME
;;;                                                                 name = format
;;;                                                               } 31 DeclItem
;;;                                                             } 30 List<DeclItem>
;;;                                                           } 29 TypeName
;;;                                                         } 28 ParameterDeclaration
;;;                                                         { 28 StringExpression
;--	load_rr_string
	MOVE	#Cstr_37, RR
;;;                                                         } 28 StringExpression
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;--	push 2 bytes
;--	call
	CALL	Cprintf
;--	pop 2 bytes
	ADD	SP, #2
;;;                                                       } 27 Expr l(r)
;;;                                                     } 26 ExpressionStatement
;;;                                                     { 26 ExpressionStatement
;;;                                                       { 27 Expr l = r
;;;                                                         { 28 TypeName
;;;                                                           { 29 TypeSpecifier (all)
;;;                                                             spec = unsigned char (22000)
;;;                                                           } 29 TypeSpecifier (all)
;;;                                                           { 29 List<DeclItem>
;;;                                                             { 30 DeclItem
;;;                                                               what = DECL_POINTER
;;;                                                               { 31 List<Ptr>
;;;                                                                 { 32 Ptr
;;;                                                                 } 32 Ptr
;;;                                                               } 31 List<Ptr>
;;;                                                             } 30 DeclItem
;;;                                                             { 30 DeclItem
;;;                                                               what = DECL_NAME
;;;                                                               name = address
;;;                                                             } 30 DeclItem
;;;                                                           } 29 List<DeclItem>
;;;                                                         } 28 TypeName
;;;                                                         { 28 Expression (cast)r
;;;                                                           { 29 Expr l(r)
;;;                                                             { 30 TypeName
;;;                                                               { 31 TypeSpecifier (all)
;;;                                                                 spec = int (80000)
;;;                                                               } 31 TypeSpecifier (all)
;;;                                                               { 31 List<DeclItem>
;;;                                                                 { 32 DeclItem
;;;                                                                   what = DECL_NAME
;;;                                                                   name = gethex
;;;                                                                 } 32 DeclItem
;;;                                                               } 31 List<DeclItem>
;;;                                                             } 30 TypeName
;;;                                                             { 30 ParameterDeclaration
;;;                                                               isEllipsis = false
;;;                                                               { 31 TypeName
;;;                                                                 { 32 TypeSpecifier (all)
;;;                                                                   spec = char (20000)
;;;                                                                 } 32 TypeSpecifier (all)
;;;                                                                 { 32 List<DeclItem>
;;;                                                                   { 33 DeclItem
;;;                                                                     what = DECL_NAME
;;;                                                                     name = echo
;;;                                                                   } 33 DeclItem
;;;                                                                 } 32 List<DeclItem>
;;;                                                               } 31 TypeName
;;;                                                             } 30 ParameterDeclaration
;;;                                                             { 30 NumericExpression (constant 1 = 0x1)
;--	load_rr_constant
	MOVE	#0x0001, RR
;;;                                                             } 30 NumericExpression (constant 1 = 0x1)
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;--	push 2 bytes
;--	call
	CALL	Cgethex
;--	pop 1 bytes
	ADD	SP, #1
;;;                                                           } 29 Expr l(r)
;;;                                                         } 28 Expression (cast)r
;--	store_rr_var address = -5(FP), SP at -5
	MOVE	RR, 0(SP)
;;;                                                       } 27 Expr l = r
;;;                                                     } 26 ExpressionStatement
;;;                                                     { 26 ExpressionStatement
;;;                                                       { 27 Expr l(r)
;;;                                                         { 28 TypeName
;;;                                                           { 29 TypeSpecifier (all)
;;;                                                             spec = int (80000)
;;;                                                           } 29 TypeSpecifier (all)
;;;                                                           { 29 List<DeclItem>
;;;                                                             { 30 DeclItem
;;;                                                               what = DECL_NAME
;;;                                                               name = printf
;;;                                                             } 30 DeclItem
;;;                                                           } 29 List<DeclItem>
;;;                                                         } 28 TypeName
;;;                                                         { 28 ParameterDeclaration
;;;                                                           isEllipsis = true
;;;                                                           { 29 TypeName
;;;                                                             { 30 TypeSpecifier (all)
;;;                                                               spec = const char (20100)
;;;                                                             } 30 TypeSpecifier (all)
;;;                                                             { 30 List<DeclItem>
;;;                                                               { 31 DeclItem
;;;                                                                 what = DECL_POINTER
;;;                                                                 { 32 List<Ptr>
;;;                                                                   { 33 Ptr
;;;                                                                   } 33 Ptr
;;;                                                                 } 32 List<Ptr>
;;;                                                               } 31 DeclItem
;;;                                                               { 31 DeclItem
;;;                                                                 what = DECL_NAME
;;;                                                                 name = format
;;;                                                               } 31 DeclItem
;;;                                                             } 30 List<DeclItem>
;;;                                                           } 29 TypeName
;;;                                                         } 28 ParameterDeclaration
;;;                                                         { 28 StringExpression
;--	load_rr_string
	MOVE	#Cstr_38, RR
;;;                                                         } 28 StringExpression
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;--	push 2 bytes
;--	call
	CALL	Cprintf
;--	pop 2 bytes
	ADD	SP, #2
;;;                                                       } 27 Expr l(r)
;;;                                                     } 26 ExpressionStatement
;;;                                                     { 26 ExpressionStatement
;;;                                                       { 27 Expr l(r)
;;;                                                         { 28 TypeName
;;;                                                           { 29 TypeSpecifier (all)
;;;                                                             spec = int (80000)
;;;                                                           } 29 TypeSpecifier (all)
;;;                                                           { 29 List<DeclItem>
;;;                                                             { 30 DeclItem
;;;                                                               what = DECL_NAME
;;;                                                               name = getchr
;;;                                                             } 30 DeclItem
;;;                                                           } 29 List<DeclItem>
;;;                                                         } 28 TypeName
;--	push 2 bytes
;--	call
	CALL	Cgetchr
;--	pop 0 bytes
;;;                                                       } 27 Expr l(r)
;;;                                                     } 26 ExpressionStatement
;;;                                                     { 26 ExpressionStatement
;;;                                                       { 27 Expr l(r)
;;;                                                         { 28 TypeName
;;;                                                           { 29 TypeSpecifier (all)
;;;                                                             spec = void (10000)
;;;                                                           } 29 TypeSpecifier (all)
;;;                                                           { 29 List<DeclItem>
;;;                                                             { 30 DeclItem
;;;                                                               what = DECL_NAME
;;;                                                               name = display_memory
;;;                                                             } 30 DeclItem
;;;                                                           } 29 List<DeclItem>
;;;                                                         } 28 TypeName
;;;                                                         { 28 ParameterDeclaration
;;;                                                           isEllipsis = false
;;;                                                           { 29 TypeName
;;;                                                             { 30 TypeSpecifier (all)
;;;                                                               spec = unsigned char (22000)
;;;                                                             } 30 TypeSpecifier (all)
;;;                                                             { 30 List<DeclItem>
;;;                                                               { 31 DeclItem
;;;                                                                 what = DECL_POINTER
;;;                                                                 { 32 List<Ptr>
;;;                                                                   { 33 Ptr
;;;                                                                   } 33 Ptr
;;;                                                                 } 32 List<Ptr>
;;;                                                               } 31 DeclItem
;;;                                                               { 31 DeclItem
;;;                                                                 what = DECL_NAME
;;;                                                                 name = address
;;;                                                               } 31 DeclItem
;;;                                                             } 30 List<DeclItem>
;;;                                                           } 29 TypeName
;;;                                                         } 28 ParameterDeclaration
;;;                                                         { 28 Expression (variable name)
;;;                                                           expr_type = "identifier" (address)
;--	load_rr_var address = -5(FP), SP at -5 (16 bit)
	MOVE	0(SP), RR
;;;                                                         } 28 Expression (variable name)
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;--	push 0 bytes
;--	call
	CALL	Cdisplay_memory
;--	pop 2 bytes
	ADD	SP, #2
;;;                                                       } 27 Expr l(r)
;;;                                                     } 26 ExpressionStatement
;;;                                                     { 26 break/continue Statement
;--	branch
	JMP	L19_brk_73
;;;                                                     } 26 break/continue Statement
;;;                                                     { 26 case Statement
L19_case_73_0045:
;;;                                                       { 27 case Statement
L19_case_73_0065:
;;;                                                         { 28 ExpressionStatement
;;;                                                           { 29 Expr l(r)
;;;                                                             { 30 TypeName
;;;                                                               { 31 TypeSpecifier (all)
;;;                                                                 spec = int (80000)
;;;                                                               } 31 TypeSpecifier (all)
;;;                                                               { 31 List<DeclItem>
;;;                                                                 { 32 DeclItem
;;;                                                                   what = DECL_NAME
;;;                                                                   name = printf
;;;                                                                 } 32 DeclItem
;;;                                                               } 31 List<DeclItem>
;;;                                                             } 30 TypeName
;;;                                                             { 30 ParameterDeclaration
;;;                                                               isEllipsis = true
;;;                                                               { 31 TypeName
;;;                                                                 { 32 TypeSpecifier (all)
;;;                                                                   spec = const char (20100)
;;;                                                                 } 32 TypeSpecifier (all)
;;;                                                                 { 32 List<DeclItem>
;;;                                                                   { 33 DeclItem
;;;                                                                     what = DECL_POINTER
;;;                                                                     { 34 List<Ptr>
;;;                                                                       { 35 Ptr
;;;                                                                       } 35 Ptr
;;;                                                                     } 34 List<Ptr>
;;;                                                                   } 33 DeclItem
;;;                                                                   { 33 DeclItem
;;;                                                                     what = DECL_NAME
;;;                                                                     name = format
;;;                                                                   } 33 DeclItem
;;;                                                                 } 32 List<DeclItem>
;;;                                                               } 31 TypeName
;;;                                                             } 30 ParameterDeclaration
;;;                                                             { 30 StringExpression
;--	load_rr_string
	MOVE	#Cstr_39, RR
;;;                                                             } 30 StringExpression
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;--	push 2 bytes
;--	call
	CALL	Cprintf
;--	pop 2 bytes
	ADD	SP, #2
;;;                                                           } 29 Expr l(r)
;;;                                                         } 28 ExpressionStatement
;;;                                                       } 27 case Statement
;;;                                                     } 26 case Statement
;;;                                                     { 26 ExpressionStatement
;;;                                                       { 27 Expr l(r)
;;;                                                         { 28 TypeName
;;;                                                           { 29 TypeSpecifier (all)
;;;                                                             spec = int (80000)
;;;                                                           } 29 TypeSpecifier (all)
;;;                                                           { 29 List<DeclItem>
;;;                                                             { 30 DeclItem
;;;                                                               what = DECL_NAME
;;;                                                               name = gethex
;;;                                                             } 30 DeclItem
;;;                                                           } 29 List<DeclItem>
;;;                                                         } 28 TypeName
;;;                                                         { 28 ParameterDeclaration
;;;                                                           isEllipsis = false
;;;                                                           { 29 TypeName
;;;                                                             { 30 TypeSpecifier (all)
;;;                                                               spec = char (20000)
;;;                                                             } 30 TypeSpecifier (all)
;;;                                                             { 30 List<DeclItem>
;;;                                                               { 31 DeclItem
;;;                                                                 what = DECL_NAME
;;;                                                                 name = echo
;;;                                                               } 31 DeclItem
;;;                                                             } 30 List<DeclItem>
;;;                                                           } 29 TypeName
;;;                                                         } 28 ParameterDeclaration
;;;                                                         { 28 NumericExpression (constant 1 = 0x1)
;--	load_rr_constant
	MOVE	#0x0001, RR
;;;                                                         } 28 NumericExpression (constant 1 = 0x1)
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;--	push 2 bytes
;--	call
	CALL	Cgethex
;--	pop 1 bytes
	ADD	SP, #1
;;;                                                       } 27 Expr l(r)
;;;                                                     } 26 ExpressionStatement
;;;                                                     { 26 ExpressionStatement
	OUT R, (OUT_LEDS)
;;;                                                     } 26 ExpressionStatement
;;;                                                     { 26 ExpressionStatement
;;;                                                       { 27 Expr l(r)
;;;                                                         { 28 TypeName
;;;                                                           { 29 TypeSpecifier (all)
;;;                                                             spec = int (80000)
;;;                                                           } 29 TypeSpecifier (all)
;;;                                                           { 29 List<DeclItem>
;;;                                                             { 30 DeclItem
;;;                                                               what = DECL_NAME
;;;                                                               name = printf
;;;                                                             } 30 DeclItem
;;;                                                           } 29 List<DeclItem>
;;;                                                         } 28 TypeName
;;;                                                         { 28 ParameterDeclaration
;;;                                                           isEllipsis = true
;;;                                                           { 29 TypeName
;;;                                                             { 30 TypeSpecifier (all)
;;;                                                               spec = const char (20100)
;;;                                                             } 30 TypeSpecifier (all)
;;;                                                             { 30 List<DeclItem>
;;;                                                               { 31 DeclItem
;;;                                                                 what = DECL_POINTER
;;;                                                                 { 32 List<Ptr>
;;;                                                                   { 33 Ptr
;;;                                                                   } 33 Ptr
;;;                                                                 } 32 List<Ptr>
;;;                                                               } 31 DeclItem
;;;                                                               { 31 DeclItem
;;;                                                                 what = DECL_NAME
;;;                                                                 name = format
;;;                                                               } 31 DeclItem
;;;                                                             } 30 List<DeclItem>
;;;                                                           } 29 TypeName
;;;                                                         } 28 ParameterDeclaration
;;;                                                         { 28 StringExpression
;--	load_rr_string
	MOVE	#Cstr_41, RR
;;;                                                         } 28 StringExpression
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;--	push 2 bytes
;--	call
	CALL	Cprintf
;--	pop 2 bytes
	ADD	SP, #2
;;;                                                       } 27 Expr l(r)
;;;                                                     } 26 ExpressionStatement
;;;                                                     { 26 ExpressionStatement
;;;                                                       { 27 Expr l(r)
;;;                                                         { 28 TypeName
;;;                                                           { 29 TypeSpecifier (all)
;;;                                                             spec = int (80000)
;;;                                                           } 29 TypeSpecifier (all)
;;;                                                           { 29 List<DeclItem>
;;;                                                             { 30 DeclItem
;;;                                                               what = DECL_NAME
;;;                                                               name = getchr
;;;                                                             } 30 DeclItem
;;;                                                           } 29 List<DeclItem>
;;;                                                         } 28 TypeName
;--	push 2 bytes
;--	call
	CALL	Cgetchr
;--	pop 0 bytes
;;;                                                       } 27 Expr l(r)
;;;                                                     } 26 ExpressionStatement
;;;                                                     { 26 break/continue Statement
;--	branch
	JMP	L19_brk_73
;;;                                                     } 26 break/continue Statement
;;;                                                     { 26 case Statement
L19_case_73_004D:
;;;                                                       { 27 case Statement
L19_case_73_006D:
;;;                                                         { 28 ExpressionStatement
;;;                                                           { 29 Expr l(r)
;;;                                                             { 30 TypeName
;;;                                                               { 31 TypeSpecifier (all)
;;;                                                                 spec = int (80000)
;;;                                                               } 31 TypeSpecifier (all)
;;;                                                               { 31 List<DeclItem>
;;;                                                                 { 32 DeclItem
;;;                                                                   what = DECL_NAME
;;;                                                                   name = printf
;;;                                                                 } 32 DeclItem
;;;                                                               } 31 List<DeclItem>
;;;                                                             } 30 TypeName
;;;                                                             { 30 ParameterDeclaration
;;;                                                               isEllipsis = true
;;;                                                               { 31 TypeName
;;;                                                                 { 32 TypeSpecifier (all)
;;;                                                                   spec = const char (20100)
;;;                                                                 } 32 TypeSpecifier (all)
;;;                                                                 { 32 List<DeclItem>
;;;                                                                   { 33 DeclItem
;;;                                                                     what = DECL_POINTER
;;;                                                                     { 34 List<Ptr>
;;;                                                                       { 35 Ptr
;;;                                                                       } 35 Ptr
;;;                                                                     } 34 List<Ptr>
;;;                                                                   } 33 DeclItem
;;;                                                                   { 33 DeclItem
;;;                                                                     what = DECL_NAME
;;;                                                                     name = format
;;;                                                                   } 33 DeclItem
;;;                                                                 } 32 List<DeclItem>
;;;                                                               } 31 TypeName
;;;                                                             } 30 ParameterDeclaration
;;;                                                             { 30 StringExpression
;--	load_rr_string
	MOVE	#Cstr_42, RR
;;;                                                             } 30 StringExpression
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;--	push 2 bytes
;--	call
	CALL	Cprintf
;--	pop 2 bytes
	ADD	SP, #2
;;;                                                           } 29 Expr l(r)
;;;                                                         } 28 ExpressionStatement
;;;                                                       } 27 case Statement
;;;                                                     } 26 case Statement
;;;                                                     { 26 ExpressionStatement
;;;                                                       { 27 Expr l = r
;;;                                                         { 28 TypeName
;;;                                                           { 29 TypeSpecifier (all)
;;;                                                             spec = unsigned char (22000)
;;;                                                           } 29 TypeSpecifier (all)
;;;                                                           { 29 List<DeclItem>
;;;                                                             { 30 DeclItem
;;;                                                               what = DECL_POINTER
;;;                                                               { 31 List<Ptr>
;;;                                                                 { 32 Ptr
;;;                                                                 } 32 Ptr
;;;                                                               } 31 List<Ptr>
;;;                                                             } 30 DeclItem
;;;                                                             { 30 DeclItem
;;;                                                               what = DECL_NAME
;;;                                                               name = address
;;;                                                             } 30 DeclItem
;;;                                                           } 29 List<DeclItem>
;;;                                                         } 28 TypeName
;;;                                                         { 28 Expression (cast)r
;;;                                                           { 29 Expr l(r)
;;;                                                             { 30 TypeName
;;;                                                               { 31 TypeSpecifier (all)
;;;                                                                 spec = int (80000)
;;;                                                               } 31 TypeSpecifier (all)
;;;                                                               { 31 List<DeclItem>
;;;                                                                 { 32 DeclItem
;;;                                                                   what = DECL_NAME
;;;                                                                   name = gethex
;;;                                                                 } 32 DeclItem
;;;                                                               } 31 List<DeclItem>
;;;                                                             } 30 TypeName
;;;                                                             { 30 ParameterDeclaration
;;;                                                               isEllipsis = false
;;;                                                               { 31 TypeName
;;;                                                                 { 32 TypeSpecifier (all)
;;;                                                                   spec = char (20000)
;;;                                                                 } 32 TypeSpecifier (all)
;;;                                                                 { 32 List<DeclItem>
;;;                                                                   { 33 DeclItem
;;;                                                                     what = DECL_NAME
;;;                                                                     name = echo
;;;                                                                   } 33 DeclItem
;;;                                                                 } 32 List<DeclItem>
;;;                                                               } 31 TypeName
;;;                                                             } 30 ParameterDeclaration
;;;                                                             { 30 NumericExpression (constant 1 = 0x1)
;--	load_rr_constant
	MOVE	#0x0001, RR
;;;                                                             } 30 NumericExpression (constant 1 = 0x1)
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;--	push 2 bytes
;--	call
	CALL	Cgethex
;--	pop 1 bytes
	ADD	SP, #1
;;;                                                           } 29 Expr l(r)
;;;                                                         } 28 Expression (cast)r
;--	store_rr_var address = -5(FP), SP at -5
	MOVE	RR, 0(SP)
;;;                                                       } 27 Expr l = r
;;;                                                     } 26 ExpressionStatement
;;;                                                     { 26 ExpressionStatement
;;;                                                       { 27 Expr l(r)
;;;                                                         { 28 TypeName
;;;                                                           { 29 TypeSpecifier (all)
;;;                                                             spec = int (80000)
;;;                                                           } 29 TypeSpecifier (all)
;;;                                                           { 29 List<DeclItem>
;;;                                                             { 30 DeclItem
;;;                                                               what = DECL_NAME
;;;                                                               name = printf
;;;                                                             } 30 DeclItem
;;;                                                           } 29 List<DeclItem>
;;;                                                         } 28 TypeName
;;;                                                         { 28 ParameterDeclaration
;;;                                                           isEllipsis = true
;;;                                                           { 29 TypeName
;;;                                                             { 30 TypeSpecifier (all)
;;;                                                               spec = const char (20100)
;;;                                                             } 30 TypeSpecifier (all)
;;;                                                             { 30 List<DeclItem>
;;;                                                               { 31 DeclItem
;;;                                                                 what = DECL_POINTER
;;;                                                                 { 32 List<Ptr>
;;;                                                                   { 33 Ptr
;;;                                                                   } 33 Ptr
;;;                                                                 } 32 List<Ptr>
;;;                                                               } 31 DeclItem
;;;                                                               { 31 DeclItem
;;;                                                                 what = DECL_NAME
;;;                                                                 name = format
;;;                                                               } 31 DeclItem
;;;                                                             } 30 List<DeclItem>
;;;                                                           } 29 TypeName
;;;                                                         } 28 ParameterDeclaration
;;;                                                         { 28 StringExpression
;--	load_rr_string
	MOVE	#Cstr_43, RR
;;;                                                         } 28 StringExpression
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;--	push 2 bytes
;--	call
	CALL	Cprintf
;--	pop 2 bytes
	ADD	SP, #2
;;;                                                       } 27 Expr l(r)
;;;                                                     } 26 ExpressionStatement
;;;                                                     { 26 ExpressionStatement
;;;                                                       { 27 Expr l(r)
;;;                                                         { 28 TypeName
;;;                                                           { 29 TypeSpecifier (all)
;;;                                                             spec = int (80000)
;;;                                                           } 29 TypeSpecifier (all)
;;;                                                           { 29 List<DeclItem>
;;;                                                             { 30 DeclItem
;;;                                                               what = DECL_NAME
;;;                                                               name = getchr
;;;                                                             } 30 DeclItem
;;;                                                           } 29 List<DeclItem>
;;;                                                         } 28 TypeName
;--	push 2 bytes
;--	call
	CALL	Cgetchr
;--	pop 0 bytes
;;;                                                       } 27 Expr l(r)
;;;                                                     } 26 ExpressionStatement
;;;                                                     { 26 ExpressionStatement
;;;                                                       { 27 Expr l = r
;;;                                                         { 28 TypeName
;;;                                                           { 29 TypeSpecifier (all)
;;;                                                             spec = unsigned char (22000)
;;;                                                           } 29 TypeSpecifier (all)
;;;                                                           { 29 List<DeclItem>
;;;                                                             { 30 DeclItem
;;;                                                               what = DECL_NAME
;;;                                                               name = address
;;;                                                             } 30 DeclItem
;;;                                                           } 29 List<DeclItem>
;;;                                                         } 28 TypeName
;;;                                                         { 28 Expr l(r)
;;;                                                           { 29 TypeName
;;;                                                             { 30 TypeSpecifier (all)
;;;                                                               spec = int (80000)
;;;                                                             } 30 TypeSpecifier (all)
;;;                                                             { 30 List<DeclItem>
;;;                                                               { 31 DeclItem
;;;                                                                 what = DECL_NAME
;;;                                                                 name = gethex
;;;                                                               } 31 DeclItem
;;;                                                             } 30 List<DeclItem>
;;;                                                           } 29 TypeName
;;;                                                           { 29 ParameterDeclaration
;;;                                                             isEllipsis = false
;;;                                                             { 30 TypeName
;;;                                                               { 31 TypeSpecifier (all)
;;;                                                                 spec = char (20000)
;;;                                                               } 31 TypeSpecifier (all)
;;;                                                               { 31 List<DeclItem>
;;;                                                                 { 32 DeclItem
;;;                                                                   what = DECL_NAME
;;;                                                                   name = echo
;;;                                                                 } 32 DeclItem
;;;                                                               } 31 List<DeclItem>
;;;                                                             } 30 TypeName
;;;                                                           } 29 ParameterDeclaration
;;;                                                           { 29 NumericExpression (constant 1 = 0x1)
;--	load_rr_constant
	MOVE	#0x0001, RR
;;;                                                           } 29 NumericExpression (constant 1 = 0x1)
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;--	push 2 bytes
;--	call
	CALL	Cgethex
;--	pop 1 bytes
	ADD	SP, #1
;;;                                                         } 28 Expr l(r)
;--	push_rr (8 bit)
	MOVE	R, -(SP)
;;;                                                         { 28 Expr * r
;;;                                                           { 29 Expression (variable name)
;;;                                                             expr_type = "identifier" (address)
;--	load_rr_var address = -5(FP), SP at -6 (16 bit)
	MOVE	1(SP), RR
;;;                                                           } 29 Expression (variable name)
;;;                                                         } 28 Expr * r
;--	move_rr_to_ll
	MOVE	RR, LL
;--	pop_rr (8 bit)
	MOVE	(SP)+, RU
;--	assign (8 bit)
	MOVE	R, (LL)
;;;                                                       } 27 Expr l = r
;;;                                                     } 26 ExpressionStatement
;;;                                                     { 26 ExpressionStatement
;;;                                                       { 27 Expr l(r)
;;;                                                         { 28 TypeName
;;;                                                           { 29 TypeSpecifier (all)
;;;                                                             spec = int (80000)
;;;                                                           } 29 TypeSpecifier (all)
;;;                                                           { 29 List<DeclItem>
;;;                                                             { 30 DeclItem
;;;                                                               what = DECL_NAME
;;;                                                               name = getchr
;;;                                                             } 30 DeclItem
;;;                                                           } 29 List<DeclItem>
;;;                                                         } 28 TypeName
;--	push 2 bytes
;--	call
	CALL	Cgetchr
;--	pop 0 bytes
;;;                                                       } 27 Expr l(r)
;;;                                                     } 26 ExpressionStatement
;;;                                                     { 26 ExpressionStatement
;;;                                                       { 27 Expr l(r)
;;;                                                         { 28 TypeName
;;;                                                           { 29 TypeSpecifier (all)
;;;                                                             spec = int (80000)
;;;                                                           } 29 TypeSpecifier (all)
;;;                                                           { 29 List<DeclItem>
;;;                                                             { 30 DeclItem
;;;                                                               what = DECL_NAME
;;;                                                               name = printf
;;;                                                             } 30 DeclItem
;;;                                                           } 29 List<DeclItem>
;;;                                                         } 28 TypeName
;;;                                                         { 28 ParameterDeclaration
;;;                                                           isEllipsis = true
;;;                                                           { 29 TypeName
;;;                                                             { 30 TypeSpecifier (all)
;;;                                                               spec = const char (20100)
;;;                                                             } 30 TypeSpecifier (all)
;;;                                                             { 30 List<DeclItem>
;;;                                                               { 31 DeclItem
;;;                                                                 what = DECL_POINTER
;;;                                                                 { 32 List<Ptr>
;;;                                                                   { 33 Ptr
;;;                                                                   } 33 Ptr
;;;                                                                 } 32 List<Ptr>
;;;                                                               } 31 DeclItem
;;;                                                               { 31 DeclItem
;;;                                                                 what = DECL_NAME
;;;                                                                 name = format
;;;                                                               } 31 DeclItem
;;;                                                             } 30 List<DeclItem>
;;;                                                           } 29 TypeName
;;;                                                         } 28 ParameterDeclaration
;;;                                                         { 28 StringExpression
;--	load_rr_string
	MOVE	#Cstr_44, RR
;;;                                                         } 28 StringExpression
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;--	push 2 bytes
;--	call
	CALL	Cprintf
;--	pop 2 bytes
	ADD	SP, #2
;;;                                                       } 27 Expr l(r)
;;;                                                     } 26 ExpressionStatement
;;;                                                     { 26 break/continue Statement
;--	branch
	JMP	L19_brk_73
;;;                                                     } 26 break/continue Statement
;;;                                                     { 26 case Statement
L19_case_73_0053:
;;;                                                       { 27 case Statement
L19_case_73_0073:
;;;                                                         { 28 ExpressionStatement
;;;                                                           { 29 Expr l(r)
;;;                                                             { 30 TypeName
;;;                                                               { 31 TypeSpecifier (all)
;;;                                                                 spec = int (80000)
;;;                                                               } 31 TypeSpecifier (all)
;;;                                                               { 31 List<DeclItem>
;;;                                                                 { 32 DeclItem
;;;                                                                   what = DECL_NAME
;;;                                                                   name = printf
;;;                                                                 } 32 DeclItem
;;;                                                               } 31 List<DeclItem>
;;;                                                             } 30 TypeName
;;;                                                             { 30 Expr (l , r)
;;;                                                               { 31 ParameterDeclaration
;;;                                                                 isEllipsis = true
;;;                                                                 { 32 TypeName
;;;                                                                   { 33 TypeSpecifier (all)
;;;                                                                     spec = const char (20100)
;;;                                                                   } 33 TypeSpecifier (all)
;;;                                                                   { 33 List<DeclItem>
;;;                                                                     { 34 DeclItem
;;;                                                                       what = DECL_POINTER
;;;                                                                       { 35 List<Ptr>
;;;                                                                         { 36 Ptr
;;;                                                                         } 36 Ptr
;;;                                                                       } 35 List<Ptr>
;;;                                                                     } 34 DeclItem
;;;                                                                     { 34 DeclItem
;;;                                                                       what = DECL_NAME
;;;                                                                       name = format
;;;                                                                     } 34 DeclItem
;;;                                                                   } 33 List<DeclItem>
;;;                                                                 } 32 TypeName
;;;                                                               } 31 ParameterDeclaration
	IN (IN_DIP_SWITCH), RU
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                                               { 31 ParameterDeclaration
;;;                                                                 isEllipsis = true
;;;                                                                 { 32 TypeName
;;;                                                                   { 33 TypeSpecifier (all)
;;;                                                                     spec = const char (20100)
;;;                                                                   } 33 TypeSpecifier (all)
;;;                                                                   { 33 List<DeclItem>
;;;                                                                     { 34 DeclItem
;;;                                                                       what = DECL_POINTER
;;;                                                                       { 35 List<Ptr>
;;;                                                                         { 36 Ptr
;;;                                                                         } 36 Ptr
;;;                                                                       } 35 List<Ptr>
;;;                                                                     } 34 DeclItem
;;;                                                                     { 34 DeclItem
;;;                                                                       what = DECL_NAME
;;;                                                                       name = format
;;;                                                                     } 34 DeclItem
;;;                                                                   } 33 List<DeclItem>
;;;                                                                 } 32 TypeName
;;;                                                               } 31 ParameterDeclaration
;;;                                                               { 31 StringExpression
;--	load_rr_string
	MOVE	#Cstr_45, RR
;;;                                                               } 31 StringExpression
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                                             } 30 Expr (l , r)
;--	push 2 bytes
;--	call
	CALL	Cprintf
;--	pop 4 bytes
	ADD	SP, #4
;;;                                                           } 29 Expr l(r)
;;;                                                         } 28 ExpressionStatement
;;;                                                       } 27 case Statement
;;;                                                     } 26 case Statement
;;;                                                     { 26 break/continue Statement
;--	branch
	JMP	L19_brk_73
;;;                                                     } 26 break/continue Statement
;;;                                                     { 26 case Statement
L19_case_73_0054:
;;;                                                       { 27 case Statement
L19_case_73_0074:
;;;                                                         { 28 ExpressionStatement
;;;                                                           { 29 Expr l(r)
;;;                                                             { 30 TypeName
;;;                                                               { 31 TypeSpecifier (all)
;;;                                                                 spec = int (80000)
;;;                                                               } 31 TypeSpecifier (all)
;;;                                                               { 31 List<DeclItem>
;;;                                                                 { 32 DeclItem
;;;                                                                   what = DECL_NAME
;;;                                                                   name = printf
;;;                                                                 } 32 DeclItem
;;;                                                               } 31 List<DeclItem>
;;;                                                             } 30 TypeName
;;;                                                             { 30 Expr (l , r)
;;;                                                               { 31 ParameterDeclaration
;;;                                                                 isEllipsis = true
;;;                                                                 { 32 TypeName
;;;                                                                   { 33 TypeSpecifier (all)
;;;                                                                     spec = const char (20100)
;;;                                                                   } 33 TypeSpecifier (all)
;;;                                                                   { 33 List<DeclItem>
;;;                                                                     { 34 DeclItem
;;;                                                                       what = DECL_POINTER
;;;                                                                       { 35 List<Ptr>
;;;                                                                         { 36 Ptr
;;;                                                                         } 36 Ptr
;;;                                                                       } 35 List<Ptr>
;;;                                                                     } 34 DeclItem
;;;                                                                     { 34 DeclItem
;;;                                                                       what = DECL_NAME
;;;                                                                       name = format
;;;                                                                     } 34 DeclItem
;;;                                                                   } 33 List<DeclItem>
;;;                                                                 } 32 TypeName
;;;                                                               } 31 ParameterDeclaration
	IN (IN_TEMPERAT), RU
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                                               { 31 ParameterDeclaration
;;;                                                                 isEllipsis = true
;;;                                                                 { 32 TypeName
;;;                                                                   { 33 TypeSpecifier (all)
;;;                                                                     spec = const char (20100)
;;;                                                                   } 33 TypeSpecifier (all)
;;;                                                                   { 33 List<DeclItem>
;;;                                                                     { 34 DeclItem
;;;                                                                       what = DECL_POINTER
;;;                                                                       { 35 List<Ptr>
;;;                                                                         { 36 Ptr
;;;                                                                         } 36 Ptr
;;;                                                                       } 35 List<Ptr>
;;;                                                                     } 34 DeclItem
;;;                                                                     { 34 DeclItem
;;;                                                                       what = DECL_NAME
;;;                                                                       name = format
;;;                                                                     } 34 DeclItem
;;;                                                                   } 33 List<DeclItem>
;;;                                                                 } 32 TypeName
;;;                                                               } 31 ParameterDeclaration
;;;                                                               { 31 StringExpression
;--	load_rr_string
	MOVE	#Cstr_47, RR
;;;                                                               } 31 StringExpression
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;;;                                                             } 30 Expr (l , r)
;--	push 2 bytes
;--	call
	CALL	Cprintf
;--	pop 4 bytes
	ADD	SP, #4
;;;                                                           } 29 Expr l(r)
;;;                                                         } 28 ExpressionStatement
;;;                                                       } 27 case Statement
;;;                                                     } 26 case Statement
;;;                                                     { 26 break/continue Statement
;--	branch
	JMP	L19_brk_73
;;;                                                     } 26 break/continue Statement
;;;                                                     { 26 case Statement
L19_case_73_0051:
;;;                                                       { 27 case Statement
L19_case_73_0071:
;;;                                                         { 28 case Statement
L19_case_73_0058:
;;;                                                           { 29 case Statement
L19_case_73_0078:
;;;                                                             { 30 ExpressionStatement
;;;                                                               { 31 Expr l(r)
;;;                                                                 { 32 TypeName
;;;                                                                   { 33 TypeSpecifier (all)
;;;                                                                     spec = int (80000)
;;;                                                                   } 33 TypeSpecifier (all)
;;;                                                                   { 33 List<DeclItem>
;;;                                                                     { 34 DeclItem
;;;                                                                       what = DECL_NAME
;;;                                                                       name = printf
;;;                                                                     } 34 DeclItem
;;;                                                                   } 33 List<DeclItem>
;;;                                                                 } 32 TypeName
;;;                                                                 { 32 ParameterDeclaration
;;;                                                                   isEllipsis = true
;;;                                                                   { 33 TypeName
;;;                                                                     { 34 TypeSpecifier (all)
;;;                                                                       spec = const char (20100)
;;;                                                                     } 34 TypeSpecifier (all)
;;;                                                                     { 34 List<DeclItem>
;;;                                                                       { 35 DeclItem
;;;                                                                         what = DECL_POINTER
;;;                                                                         { 36 List<Ptr>
;;;                                                                           { 37 Ptr
;;;                                                                           } 37 Ptr
;;;                                                                         } 36 List<Ptr>
;;;                                                                       } 35 DeclItem
;;;                                                                       { 35 DeclItem
;;;                                                                         what = DECL_NAME
;;;                                                                         name = format
;;;                                                                       } 35 DeclItem
;;;                                                                     } 34 List<DeclItem>
;;;                                                                   } 33 TypeName
;;;                                                                 } 32 ParameterDeclaration
;;;                                                                 { 32 StringExpression
;--	load_rr_string
	MOVE	#Cstr_49, RR
;;;                                                                 } 32 StringExpression
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;--	push 2 bytes
;--	call
	CALL	Cprintf
;--	pop 2 bytes
	ADD	SP, #2
;;;                                                               } 31 Expr l(r)
;;;                                                             } 30 ExpressionStatement
;;;                                                           } 29 case Statement
;;;                                                         } 28 case Statement
;;;                                                       } 27 case Statement
;;;                                                     } 26 case Statement
;;;                                                     { 26 while Statement
L19_loop_75:
;;;                                                       { 27 ExpressionStatement
;;;                                                       } 27 ExpressionStatement
L19_cont_75:
;;;                                                       { 27 Expression (variable name)
;;;                                                         expr_type = "identifier" (serial_out_length)
;--	load_rr_var serial_out_length, (8 bit)
	MOVE	(Cserial_out_length), RU
;;;                                                       } 27 Expression (variable name)
;--	branch_true
	JMP	RRNZ, L19_loop_75
L19_brk_76:
;;;                                                     } 26 while Statement
;;;                                                     { 26 ExpressionStatement
	DI
;;;                                                     } 26 ExpressionStatement
;;;                                                     { 26 ExpressionStatement
	HALT
;;;                                                     } 26 ExpressionStatement
;;;                                                     { 26 break/continue Statement
;--	branch
	JMP	L19_brk_73
;;;                                                     } 26 break/continue Statement
;;;                                                     { 26 case Statement
L19_deflt_73:
;;;                                                       { 27 ExpressionStatement
;;;                                                         { 28 Expr l(r)
;;;                                                           { 29 TypeName
;;;                                                             { 30 TypeSpecifier (all)
;;;                                                               spec = int (80000)
;;;                                                             } 30 TypeSpecifier (all)
;;;                                                             { 30 List<DeclItem>
;;;                                                               { 31 DeclItem
;;;                                                                 what = DECL_NAME
;;;                                                                 name = printf
;;;                                                               } 31 DeclItem
;;;                                                             } 30 List<DeclItem>
;;;                                                           } 29 TypeName
;;;                                                           { 29 ParameterDeclaration
;;;                                                             isEllipsis = true
;;;                                                             { 30 TypeName
;;;                                                               { 31 TypeSpecifier (all)
;;;                                                                 spec = const char (20100)
;;;                                                               } 31 TypeSpecifier (all)
;;;                                                               { 31 List<DeclItem>
;;;                                                                 { 32 DeclItem
;;;                                                                   what = DECL_POINTER
;;;                                                                   { 33 List<Ptr>
;;;                                                                     { 34 Ptr
;;;                                                                     } 34 Ptr
;;;                                                                   } 33 List<Ptr>
;;;                                                                 } 32 DeclItem
;;;                                                                 { 32 DeclItem
;;;                                                                   what = DECL_NAME
;;;                                                                   name = format
;;;                                                                 } 32 DeclItem
;;;                                                               } 31 List<DeclItem>
;;;                                                             } 30 TypeName
;;;                                                           } 29 ParameterDeclaration
;;;                                                           { 29 StringExpression
;--	load_rr_string
	MOVE	#Cstr_52, RR
;;;                                                           } 29 StringExpression
;--	push_rr (16 bit)
	MOVE	RR, -(SP)
;--	push 2 bytes
;--	call
	CALL	Cprintf
;--	pop 2 bytes
	ADD	SP, #2
;;;                                                         } 28 Expr l(r)
;;;                                                       } 27 ExpressionStatement
;;;                                                     } 26 case Statement
;;;                                                   } 25 List<case Statement>
;--	pop 0 bytes
;;;                                                 } 24 CompoundStatement
L19_brk_73:
;;;                                               } 23 SwitchStatement
;;;                                             } 22 List<ExpressionStatement>
;--	pop 0 bytes
;;;                                           } 21 CompoundStatement
L19_cont_70:
;--	branch
	JMP	L19_loop_70
L19_brk_71:
;;;                                         } 20 for Statement
;;;                                       } 19 List<ExpressionStatement>
;--	pop 5 bytes
	ADD	SP, #5
;;;                                     } 18 CompoundStatement
;--	ret
	RET
;;; ------------------------------------;
Cstr_19:				;
	.BYTE	0x30			;
	.BYTE	0x31			;
	.BYTE	0x32			;
	.BYTE	0x33			;
	.BYTE	0x34			;
	.BYTE	0x35			;
	.BYTE	0x36			;
	.BYTE	0x37			;
	.BYTE	0x38			;
	.BYTE	0x39			;
	.BYTE	0x41			;
	.BYTE	0x42			;
	.BYTE	0x43			;
	.BYTE	0x44			;
	.BYTE	0x45			;
	.BYTE	0x46			;
	.BYTE	0			;
Cstr_20:				;
	.BYTE	0x30			;
	.BYTE	0x58			;
	.BYTE	0			;
Cstr_21:				;
	.BYTE	0			;
Cstr_22:				;
	.BYTE	0			;
Cstr_23:				;
	.BYTE	0			;
Cstr_24:				;
	.BYTE	0x30			;
	.BYTE	0x31			;
	.BYTE	0x32			;
	.BYTE	0x33			;
	.BYTE	0x34			;
	.BYTE	0x35			;
	.BYTE	0x36			;
	.BYTE	0x37			;
	.BYTE	0x38			;
	.BYTE	0x39			;
	.BYTE	0x61			;
	.BYTE	0x62			;
	.BYTE	0x63			;
	.BYTE	0x64			;
	.BYTE	0x65			;
	.BYTE	0x66			;
	.BYTE	0			;
Cstr_25:				;
	.BYTE	0x30			;
	.BYTE	0x78			;
	.BYTE	0			;
Cstr_28:				;
	.BYTE	0x55			;
	.BYTE	0x70			;
	.BYTE	0x74			;
	.BYTE	0x69			;
	.BYTE	0x6D			;
	.BYTE	0x65			;
	.BYTE	0x20			;
	.BYTE	0x69			;
	.BYTE	0x73			;
	.BYTE	0x20			;
	.BYTE	0x25			;
	.BYTE	0x34			;
	.BYTE	0x2E			;
	.BYTE	0x34			;
	.BYTE	0x58			;
	.BYTE	0x25			;
	.BYTE	0x34			;
	.BYTE	0x2E			;
	.BYTE	0x34			;
	.BYTE	0x58			;
	.BYTE	0x25			;
	.BYTE	0x34			;
	.BYTE	0x2E			;
	.BYTE	0x34			;
	.BYTE	0x58			;
	.BYTE	0x20			;
	.BYTE	0x73			;
	.BYTE	0x65			;
	.BYTE	0x63			;
	.BYTE	0x6F			;
	.BYTE	0x6E			;
	.BYTE	0x64			;
	.BYTE	0x73			;
	.BYTE	0x0D			;
	.BYTE	0x0A			;
	.BYTE	0			;
Cstr_29:				;
	.BYTE	0x25			;
	.BYTE	0x34			;
	.BYTE	0x2E			;
	.BYTE	0x34			;
	.BYTE	0x58			;
	.BYTE	0x3A			;
	.BYTE	0			;
Cstr_30:				;
	.BYTE	0x20			;
	.BYTE	0x25			;
	.BYTE	0x32			;
	.BYTE	0x2E			;
	.BYTE	0x32			;
	.BYTE	0x58			;
	.BYTE	0			;
Cstr_31:				;
	.BYTE	0x20			;
	.BYTE	0x2D			;
	.BYTE	0x20			;
	.BYTE	0			;
Cstr_32:				;
	.BYTE	0x0D			;
	.BYTE	0x0A			;
	.BYTE	0			;
Cstr_35:				;
	.BYTE	0x2D			;
	.BYTE	0x3E			;
	.BYTE	0x20			;
	.BYTE	0			;
Cstr_36:				;
	.BYTE	0x08			;
	.BYTE	0x08			;
	.BYTE	0x08			;
	.BYTE	0x08			;
	.BYTE	0			;
Cstr_37:				;
	.BYTE	0x44			;
	.BYTE	0x69			;
	.BYTE	0x73			;
	.BYTE	0x70			;
	.BYTE	0x6C			;
	.BYTE	0x61			;
	.BYTE	0x79			;
	.BYTE	0x20			;
	.BYTE	0			;
Cstr_38:				;
	.BYTE	0x0D			;
	.BYTE	0x0A			;
	.BYTE	0			;
Cstr_39:				;
	.BYTE	0x4C			;
	.BYTE	0x45			;
	.BYTE	0x44			;
	.BYTE	0x73			;
	.BYTE	0x20			;
	.BYTE	0			;
Cstr_41:				;
	.BYTE	0x0D			;
	.BYTE	0x0A			;
	.BYTE	0			;
Cstr_42:				;
	.BYTE	0x4D			;
	.BYTE	0x65			;
	.BYTE	0x6D			;
	.BYTE	0x6F			;
	.BYTE	0x72			;
	.BYTE	0x79			;
	.BYTE	0x20			;
	.BYTE	0			;
Cstr_43:				;
	.BYTE	0x20			;
	.BYTE	0x56			;
	.BYTE	0x61			;
	.BYTE	0x6C			;
	.BYTE	0x75			;
	.BYTE	0x65			;
	.BYTE	0x20			;
	.BYTE	0			;
Cstr_44:				;
	.BYTE	0x0D			;
	.BYTE	0x0A			;
	.BYTE	0			;
Cstr_45:				;
	.BYTE	0x44			;
	.BYTE	0x49			;
	.BYTE	0x50			;
	.BYTE	0x20			;
	.BYTE	0x73			;
	.BYTE	0x77			;
	.BYTE	0x69			;
	.BYTE	0x74			;
	.BYTE	0x63			;
	.BYTE	0x68			;
	.BYTE	0x20			;
	.BYTE	0x69			;
	.BYTE	0x73			;
	.BYTE	0x20			;
	.BYTE	0x30			;
	.BYTE	0x78			;
	.BYTE	0x25			;
	.BYTE	0x58			;
	.BYTE	0x0D			;
	.BYTE	0x0A			;
	.BYTE	0			;
Cstr_47:				;
	.BYTE	0x54			;
	.BYTE	0x65			;
	.BYTE	0x6D			;
	.BYTE	0x70			;
	.BYTE	0x65			;
	.BYTE	0x72			;
	.BYTE	0x61			;
	.BYTE	0x74			;
	.BYTE	0x75			;
	.BYTE	0x72			;
	.BYTE	0x65			;
	.BYTE	0x20			;
	.BYTE	0x69			;
	.BYTE	0x73			;
	.BYTE	0x20			;
	.BYTE	0x25			;
	.BYTE	0x64			;
	.BYTE	0x20			;
	.BYTE	0x64			;
	.BYTE	0x65			;
	.BYTE	0x67			;
	.BYTE	0x72			;
	.BYTE	0x65			;
	.BYTE	0x65			;
	.BYTE	0x73			;
	.BYTE	0x20			;
	.BYTE	0x43			;
	.BYTE	0x65			;
	.BYTE	0x6C			;
	.BYTE	0x73			;
	.BYTE	0x69			;
	.BYTE	0x75			;
	.BYTE	0x73			;
	.BYTE	0x0D			;
	.BYTE	0x0A			;
	.BYTE	0			;
Cstr_49:				;
	.BYTE	0x48			;
	.BYTE	0x61			;
	.BYTE	0x6C			;
	.BYTE	0x74			;
	.BYTE	0x65			;
	.BYTE	0x64			;
	.BYTE	0x2E			;
	.BYTE	0x0D			;
	.BYTE	0x0A			;
	.BYTE	0			;
Cstr_52:				;
	.BYTE	0x0D			;
	.BYTE	0x0A			;
	.BYTE	0x43			;
	.BYTE	0x20			;
	.BYTE	0x2D			;
	.BYTE	0x20			;
	.BYTE	0x73			;
	.BYTE	0x68			;
	.BYTE	0x6F			;
	.BYTE	0x77			;
	.BYTE	0x20			;
	.BYTE	0x74			;
	.BYTE	0x69			;
	.BYTE	0x6D			;
	.BYTE	0x65			;
	.BYTE	0x0D			;
	.BYTE	0x0A			;
	.BYTE	0x44			;
	.BYTE	0x20			;
	.BYTE	0x2D			;
	.BYTE	0x20			;
	.BYTE	0x64			;
	.BYTE	0x69			;
	.BYTE	0x73			;
	.BYTE	0x70			;
	.BYTE	0x6C			;
	.BYTE	0x61			;
	.BYTE	0x79			;
	.BYTE	0x20			;
	.BYTE	0x6D			;
	.BYTE	0x65			;
	.BYTE	0x6D			;
	.BYTE	0x6F			;
	.BYTE	0x72			;
	.BYTE	0x79			;
	.BYTE	0x0D			;
	.BYTE	0x0A			;
	.BYTE	0x45			;
	.BYTE	0x20			;
	.BYTE	0x2D			;
	.BYTE	0x20			;
	.BYTE	0x73			;
	.BYTE	0x65			;
	.BYTE	0x74			;
	.BYTE	0x20			;
	.BYTE	0x4C			;
	.BYTE	0x45			;
	.BYTE	0x44			;
	.BYTE	0x73			;
	.BYTE	0x0D			;
	.BYTE	0x0A			;
	.BYTE	0x4D			;
	.BYTE	0x20			;
	.BYTE	0x2D			;
	.BYTE	0x20			;
	.BYTE	0x6D			;
	.BYTE	0x6F			;
	.BYTE	0x64			;
	.BYTE	0x69			;
	.BYTE	0x66			;
	.BYTE	0x79			;
	.BYTE	0x20			;
	.BYTE	0x6D			;
	.BYTE	0x65			;
	.BYTE	0x6D			;
	.BYTE	0x6F			;
	.BYTE	0x72			;
	.BYTE	0x79			;
	.BYTE	0x0D			;
	.BYTE	0x0A			;
	.BYTE	0x53			;
	.BYTE	0x20			;
	.BYTE	0x2D			;
	.BYTE	0x20			;
	.BYTE	0x72			;
	.BYTE	0x65			;
	.BYTE	0x61			;
	.BYTE	0x64			;
	.BYTE	0x20			;
	.BYTE	0x44			;
	.BYTE	0x49			;
	.BYTE	0x50			;
	.BYTE	0x20			;
	.BYTE	0x73			;
	.BYTE	0x77			;
	.BYTE	0x69			;
	.BYTE	0x74			;
	.BYTE	0x63			;
	.BYTE	0x68			;
	.BYTE	0x0D			;
	.BYTE	0x0A			;
	.BYTE	0x54			;
	.BYTE	0x20			;
	.BYTE	0x2D			;
	.BYTE	0x20			;
	.BYTE	0x72			;
	.BYTE	0x65			;
	.BYTE	0x61			;
	.BYTE	0x64			;
	.BYTE	0x20			;
	.BYTE	0x74			;
	.BYTE	0x65			;
	.BYTE	0x6D			;
	.BYTE	0x70			;
	.BYTE	0x65			;
	.BYTE	0x72			;
	.BYTE	0x61			;
	.BYTE	0x74			;
	.BYTE	0x75			;
	.BYTE	0x72			;
	.BYTE	0x65			;
	.BYTE	0x0D			;
	.BYTE	0x0A			;
	.BYTE	0x51			;
	.BYTE	0x20			;
	.BYTE	0x2D			;
	.BYTE	0x20			;
	.BYTE	0x71			;
	.BYTE	0x75			;
	.BYTE	0x69			;
	.BYTE	0x74			;
	.BYTE	0x0D			;
	.BYTE	0x0A			;
	.BYTE	0x58			;
	.BYTE	0x20			;
	.BYTE	0x2D			;
	.BYTE	0x20			;
	.BYTE	0x65			;
	.BYTE	0x78			;
	.BYTE	0x69			;
	.BYTE	0x74			;
	.BYTE	0x0D			;
	.BYTE	0x0A			;
	.BYTE	0x0D			;
	.BYTE	0x0A			;
	.BYTE	0			;
Cend_text:				;
