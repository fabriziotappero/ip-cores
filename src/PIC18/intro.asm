;/////////////////////////////////////////////////////////////////////////////////
;// Code Generator: BoostC Compiler and Linker - http://www.picant.com/c2c/c.html
;// License Type  : Full License
;// Limitations   : PIC18 max code size:Unlimited, max RAM banks:Unlimited, Non commercial use only
;/////////////////////////////////////////////////////////////////////////////////

	include "P18F4620.inc"
__HEAPSTART                      EQU	0x00000041 ; Start address of heap 
__HEAPEND                        EQU	0x00000F7F ; End address of heap 
gbl_porta                        EQU	0x00000F80 ; bytes:1
gbl_portb                        EQU	0x00000F81 ; bytes:1
gbl_portc                        EQU	0x00000F82 ; bytes:1
gbl_portd                        EQU	0x00000F83 ; bytes:1
gbl_porte                        EQU	0x00000F84 ; bytes:1
gbl_lata                         EQU	0x00000F89 ; bytes:1
gbl_latb                         EQU	0x00000F8A ; bytes:1
gbl_latc                         EQU	0x00000F8B ; bytes:1
gbl_latd                         EQU	0x00000F8C ; bytes:1
gbl_late                         EQU	0x00000F8D ; bytes:1
gbl_ddra                         EQU	0x00000F92 ; bytes:1
gbl_trisa                        EQU	0x00000F92 ; bytes:1
gbl_ddrb                         EQU	0x00000F93 ; bytes:1
gbl_trisb                        EQU	0x00000F93 ; bytes:1
gbl_ddrc                         EQU	0x00000F94 ; bytes:1
gbl_trisc                        EQU	0x00000F94 ; bytes:1
gbl_ddrd                         EQU	0x00000F95 ; bytes:1
gbl_trisd                        EQU	0x00000F95 ; bytes:1
gbl_ddre                         EQU	0x00000F96 ; bytes:1
gbl_trise                        EQU	0x00000F96 ; bytes:1
gbl_osctune                      EQU	0x00000F9B ; bytes:1
gbl_pie1                         EQU	0x00000F9D ; bytes:1
gbl_pir1                         EQU	0x00000F9E ; bytes:1
gbl_ipr1                         EQU	0x00000F9F ; bytes:1
gbl_pie2                         EQU	0x00000FA0 ; bytes:1
gbl_pir2                         EQU	0x00000FA1 ; bytes:1
gbl_ipr2                         EQU	0x00000FA2 ; bytes:1
gbl_eecon1                       EQU	0x00000FA6 ; bytes:1
gbl_eecon2                       EQU	0x00000FA7 ; bytes:1
gbl_eedata                       EQU	0x00000FA8 ; bytes:1
gbl_eeadr                        EQU	0x00000FA9 ; bytes:1
gbl_eeadrh                       EQU	0x00000FAA ; bytes:1
gbl_rcsta                        EQU	0x00000FAB ; bytes:1
gbl_txsta                        EQU	0x00000FAC ; bytes:1
gbl_txreg                        EQU	0x00000FAD ; bytes:1
gbl_rcreg                        EQU	0x00000FAE ; bytes:1
gbl_spbrg                        EQU	0x00000FAF ; bytes:1
gbl_spbrgh                       EQU	0x00000FB0 ; bytes:1
gbl_t3con                        EQU	0x00000FB1 ; bytes:1
gbl_tmr3l                        EQU	0x00000FB2 ; bytes:1
gbl_tmr3h                        EQU	0x00000FB3 ; bytes:1
gbl_cmcon                        EQU	0x00000FB4 ; bytes:1
gbl_cvrcon                       EQU	0x00000FB5 ; bytes:1
gbl_eccp1as                      EQU	0x00000FB6 ; bytes:1
gbl_pwm1con                      EQU	0x00000FB7 ; bytes:1
gbl_baudcon                      EQU	0x00000FB8 ; bytes:1
gbl_ccp2con                      EQU	0x00000FBA ; bytes:1
gbl_ccpr2                        EQU	0x00000FBB ; bytes:1
gbl_ccpr2h                       EQU	0x00000FBC ; bytes:1
gbl_ccp1con                      EQU	0x00000FBD ; bytes:1
gbl_ccpr1                        EQU	0x00000FBE ; bytes:1
gbl_ccpr1h                       EQU	0x00000FBF ; bytes:1
gbl_adcon2                       EQU	0x00000FC0 ; bytes:1
gbl_adcon1                       EQU	0x00000FC1 ; bytes:1
gbl_adcon0                       EQU	0x00000FC2 ; bytes:1
gbl_adres                        EQU	0x00000FC3 ; bytes:1
gbl_adresh                       EQU	0x00000FC4 ; bytes:1
gbl_sspcon2                      EQU	0x00000FC5 ; bytes:1
gbl_sspcon1                      EQU	0x00000FC6 ; bytes:1
gbl_sspstat                      EQU	0x00000FC7 ; bytes:1
gbl_sspadd                       EQU	0x00000FC8 ; bytes:1
gbl_sspbuf                       EQU	0x00000FC9 ; bytes:1
gbl_t2con                        EQU	0x00000FCA ; bytes:1
gbl_pr2                          EQU	0x00000FCB ; bytes:1
gbl_tmr2                         EQU	0x00000FCC ; bytes:1
gbl_t1con                        EQU	0x00000FCD ; bytes:1
gbl_tmr1l                        EQU	0x00000FCE ; bytes:1
gbl_tmr1h                        EQU	0x00000FCF ; bytes:1
gbl_rcon                         EQU	0x00000FD0 ; bytes:1
gbl_wdtcon                       EQU	0x00000FD1 ; bytes:1
gbl_hlvdcon                      EQU	0x00000FD2 ; bytes:1
gbl_osccon                       EQU	0x00000FD3 ; bytes:1
gbl_debug                        EQU	0x00000FD4 ; bytes:1
gbl_t0con                        EQU	0x00000FD5 ; bytes:1
gbl_tmr0l                        EQU	0x00000FD6 ; bytes:1
gbl_tmr0h                        EQU	0x00000FD7 ; bytes:1
gbl_status                       EQU	0x00000FD8 ; bytes:1
gbl_fsr2l                        EQU	0x00000FD9 ; bytes:1
gbl_fsr2h                        EQU	0x00000FDA ; bytes:1
gbl_plusw2                       EQU	0x00000FDB ; bytes:1
gbl_preinc2                      EQU	0x00000FDC ; bytes:1
gbl_postdec2                     EQU	0x00000FDD ; bytes:1
gbl_postinc2                     EQU	0x00000FDE ; bytes:1
gbl_indf2                        EQU	0x00000FDF ; bytes:1
gbl_bsr                          EQU	0x00000FE0 ; bytes:1
gbl_fsr1l                        EQU	0x00000FE1 ; bytes:1
gbl_fsr1h                        EQU	0x00000FE2 ; bytes:1
gbl_plusw1                       EQU	0x00000FE3 ; bytes:1
gbl_preinc1                      EQU	0x00000FE4 ; bytes:1
gbl_postdec1                     EQU	0x00000FE5 ; bytes:1
gbl_postinc1                     EQU	0x00000FE6 ; bytes:1
gbl_indf1                        EQU	0x00000FE7 ; bytes:1
gbl_wreg                         EQU	0x00000FE8 ; bytes:1
gbl_fsr0l                        EQU	0x00000FE9 ; bytes:1
gbl_fsr0h                        EQU	0x00000FEA ; bytes:1
gbl_plusw0                       EQU	0x00000FEB ; bytes:1
gbl_preinc0                      EQU	0x00000FEC ; bytes:1
gbl_postdec0                     EQU	0x00000FED ; bytes:1
gbl_postinc0                     EQU	0x00000FEE ; bytes:1
gbl_indf0                        EQU	0x00000FEF ; bytes:1
gbl_intcon3                      EQU	0x00000FF0 ; bytes:1
gbl_intcon2                      EQU	0x00000FF1 ; bytes:1
gbl_intcon                       EQU	0x00000FF2 ; bytes:1
gbl_prod                         EQU	0x00000FF3 ; bytes:1
gbl_prodh                        EQU	0x00000FF4 ; bytes:1
gbl_tablat                       EQU	0x00000FF5 ; bytes:1
gbl_tblptr                       EQU	0x00000FF6 ; bytes:1
gbl_tblptrh                      EQU	0x00000FF7 ; bytes:1
gbl_tblptru                      EQU	0x00000FF8 ; bytes:1
gbl_pc                           EQU	0x00000FF9 ; bytes:1
gbl_pclath                       EQU	0x00000FFA ; bytes:1
gbl_pclatu                       EQU	0x00000FFB ; bytes:1
gbl_stkptr                       EQU	0x00000FFC ; bytes:1
gbl_tos                          EQU	0x00000FFD ; bytes:1
gbl_tosh                         EQU	0x00000FFE ; bytes:1
gbl_tosu                         EQU	0x00000FFF ; bytes:1
drawtoback_00007_arg_source      EQU	0x00000020 ; bytes:8
drawsprite_00000_arg_sprite      EQU	0x00000020 ; bytes:17
drawsprite_00000_1_destina_0000D EQU	0x00000031 ; bytes:4
load_alpha_00008_arg_alphaOp     EQU	0x0000003D ; bit:0
load_l_siz_00009_arg_size        EQU	0x0000003D ; bytes:2
load_s_lin_0000A_arg_lines       EQU	0x0000003D ; bytes:2
load_t_add_0000B_arg_address     EQU	0x0000003D ; bytes:4
load_s_add_0000C_arg_address     EQU	0x0000003D ; bytes:4
bootup_00000_1_i                 EQU	0x00000005 ; bytes:1
bootup_00000_1_j                 EQU	0x00000006 ; bytes:1
bootup_00000_1_black             EQU	0x00000007 ; bytes:8
bootup_00000_1_frame             EQU	0x0000000F ; bytes:17
main_1_temp                      EQU	0x00000004 ; bytes:1
gbl_prodl                        EQU	0x00000FF3 ; bytes:1
__mul_32_3_00006_arg_a           EQU	0x00000035 ; bytes:4
__mul_32_3_00006_arg_b           EQU	0x00000039 ; bytes:4
delay_us_00000_arg_del           EQU	0x00000005 ; bytes:1
delay_ms_00000_arg_del           EQU	0x00000020 ; bytes:1
CompTempVarRet0                  EQU	0x00000000 ; bytes:4
	ORG 0x00000000
	GOTO	_startup
	ORG 0x00000004
delay_ms_00000
; { delay_ms ; function begin
	MOVF delay_ms_00000_arg_del, F
	BTFSS STATUS,Z
	GOTO	label4026531859
	RETURN
label4026531859
	MOVLW 0xFF
label4026531860
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	ADDLW 0xFF
	BTFSS STATUS,Z
	GOTO	label4026531860
	NOP
	DECFSZ delay_ms_00000_arg_del, F
	GOTO	label4026531859
	RETURN
; } delay_ms function end

	ORG 0x0000007C
delay_us_00000
; { delay_us ; function begin
	MOVF delay_us_00000_arg_del, F
	BTFSS STATUS,Z
	GOTO	label4026531844
	RETURN
label4026531844
	MOVLW 0x02
label4026531845
	ADDLW 0xFF
	BTFSS STATUS,Z
	GOTO	label4026531845
	DECFSZ delay_us_00000_arg_del, F
	GOTO	label4026531844
	RETURN
; } delay_us function end

	ORG 0x00000098
__mul_32_3_00006
; { __mul_32_32 ; function begin
	CLRF CompTempVarRet0
	CLRF CompTempVarRet0+D'1'
	CLRF CompTempVarRet0+D'2'
	CLRF CompTempVarRet0+D'3'
	CLRF CompTempVarRet0+D'2'
	CLRF CompTempVarRet0+D'3'
	MOVF __mul_32_3_00006_arg_a, W
	MULWF __mul_32_3_00006_arg_b
	MOVF gbl_prodl, W
	MOVWF CompTempVarRet0
	MOVF gbl_prodh, W
	MOVWF CompTempVarRet0+D'1'
	MOVF __mul_32_3_00006_arg_a+D'1', W
	MULWF __mul_32_3_00006_arg_b
	MOVF gbl_prodl, W
	ADDWF CompTempVarRet0+D'1', F
	MOVF gbl_prodh, W
	ADDWFC CompTempVarRet0+D'2', F
	BTFSC gbl_status,0
	INCF CompTempVarRet0+D'3', F
	MOVF __mul_32_3_00006_arg_a+D'2', W
	MULWF __mul_32_3_00006_arg_b
	MOVF gbl_prodl, W
	ADDWF CompTempVarRet0+D'2', F
	MOVF gbl_prodh, W
	ADDWFC CompTempVarRet0+D'3', F
	MOVF __mul_32_3_00006_arg_a+D'3', W
	MULWF __mul_32_3_00006_arg_b
	MOVF gbl_prodl, W
	ADDWF CompTempVarRet0+D'3', F
	MOVF __mul_32_3_00006_arg_a, W
	MULWF __mul_32_3_00006_arg_b+D'1'
	MOVF gbl_prodl, W
	ADDWF CompTempVarRet0+D'1', F
	MOVF gbl_prodh, W
	ADDWFC CompTempVarRet0+D'2', F
	BTFSC gbl_status,0
	INCF CompTempVarRet0+D'3', F
	MOVF __mul_32_3_00006_arg_a+D'1', W
	MULWF __mul_32_3_00006_arg_b+D'1'
	MOVF gbl_prodl, W
	ADDWF CompTempVarRet0+D'2', F
	MOVF gbl_prodh, W
	ADDWFC CompTempVarRet0+D'3', F
	MOVF __mul_32_3_00006_arg_a+D'2', W
	MULWF __mul_32_3_00006_arg_b+D'1'
	MOVF gbl_prodl, W
	ADDWF CompTempVarRet0+D'3', F
	MOVF __mul_32_3_00006_arg_a, W
	MULWF __mul_32_3_00006_arg_b+D'2'
	MOVF gbl_prodl, W
	ADDWF CompTempVarRet0+D'2', F
	MOVF gbl_prodh, W
	ADDWFC CompTempVarRet0+D'3', F
	MOVF __mul_32_3_00006_arg_a+D'1', W
	MULWF __mul_32_3_00006_arg_b+D'2'
	MOVF gbl_prodl, W
	ADDWF CompTempVarRet0+D'3', F
	MOVF __mul_32_3_00006_arg_a, W
	MULWF __mul_32_3_00006_arg_b+D'3'
	MOVF gbl_prodl, W
	ADDWF CompTempVarRet0+D'3', F
	RETURN
; } __mul_32_32 function end

	ORG 0x00000116
draw_00000
; { draw ; function begin
	MOVLW 0x02
	MOVWF gbl_porta
	CLRF gbl_porta
label268435830
	BTFSS gbl_portd,7
	BRA	label268435830
	RETURN
; } draw function end

	ORG 0x00000122
load_s_add_0000C
; { load_s_addr ; function begin
	MOVLW 0x02
	MOVWF gbl_portc
	MOVF load_s_add_0000C_arg_address, W
	ANDLW 0xFF
	MOVWF gbl_portb
	MOVLW 0x01
	MOVWF gbl_porta
	CLRF gbl_porta
	MOVF load_s_add_0000C_arg_address+D'1', W
	MOVWF load_s_add_0000C_arg_address
	MOVF load_s_add_0000C_arg_address+D'2', W
	MOVWF load_s_add_0000C_arg_address+D'1'
	MOVF load_s_add_0000C_arg_address+D'3', W
	MOVWF load_s_add_0000C_arg_address+D'2'
	CLRF load_s_add_0000C_arg_address+D'3'
	MOVLW 0x01
	MOVWF gbl_portc
	MOVF load_s_add_0000C_arg_address, W
	ANDLW 0xFF
	MOVWF gbl_portb
	MOVLW 0x01
	MOVWF gbl_porta
	CLRF gbl_porta
	MOVF load_s_add_0000C_arg_address+D'1', W
	MOVWF load_s_add_0000C_arg_address
	MOVF load_s_add_0000C_arg_address+D'2', W
	MOVWF load_s_add_0000C_arg_address+D'1'
	MOVF load_s_add_0000C_arg_address+D'3', W
	MOVWF load_s_add_0000C_arg_address+D'2'
	CLRF load_s_add_0000C_arg_address+D'3'
	CLRF gbl_portc
	MOVF load_s_add_0000C_arg_address, W
	ANDLW 0xFF
	MOVWF gbl_portb
	MOVLW 0x01
	MOVWF gbl_porta
	CLRF gbl_porta
	RETURN
; } load_s_addr function end

	ORG 0x0000016E
load_t_add_0000B
; { load_t_addr ; function begin
	MOVLW 0x05
	MOVWF gbl_portc
	MOVF load_t_add_0000B_arg_address, W
	ANDLW 0xFF
	MOVWF gbl_portb
	MOVLW 0x01
	MOVWF gbl_porta
	CLRF gbl_porta
	MOVF load_t_add_0000B_arg_address+D'1', W
	MOVWF load_t_add_0000B_arg_address
	MOVF load_t_add_0000B_arg_address+D'2', W
	MOVWF load_t_add_0000B_arg_address+D'1'
	MOVF load_t_add_0000B_arg_address+D'3', W
	MOVWF load_t_add_0000B_arg_address+D'2'
	CLRF load_t_add_0000B_arg_address+D'3'
	MOVLW 0x04
	MOVWF gbl_portc
	MOVF load_t_add_0000B_arg_address, W
	ANDLW 0xFF
	MOVWF gbl_portb
	MOVLW 0x01
	MOVWF gbl_porta
	CLRF gbl_porta
	MOVF load_t_add_0000B_arg_address+D'1', W
	MOVWF load_t_add_0000B_arg_address
	MOVF load_t_add_0000B_arg_address+D'2', W
	MOVWF load_t_add_0000B_arg_address+D'1'
	MOVF load_t_add_0000B_arg_address+D'3', W
	MOVWF load_t_add_0000B_arg_address+D'2'
	CLRF load_t_add_0000B_arg_address+D'3'
	MOVLW 0x03
	MOVWF gbl_portc
	MOVF load_t_add_0000B_arg_address, W
	ANDLW 0xFF
	MOVWF gbl_portb
	MOVLW 0x01
	MOVWF gbl_porta
	CLRF gbl_porta
	RETURN
; } load_t_addr function end

	ORG 0x000001BC
load_s_lin_0000A
; { load_s_lines ; function begin
	MOVLW 0x07
	MOVWF gbl_portc
	MOVF load_s_lin_0000A_arg_lines, W
	ANDLW 0xFF
	MOVWF gbl_portb
	MOVLW 0x01
	MOVWF gbl_porta
	CLRF gbl_porta
	MOVF load_s_lin_0000A_arg_lines+D'1', W
	MOVWF load_s_lin_0000A_arg_lines
	CLRF load_s_lin_0000A_arg_lines+D'1'
	MOVLW 0x06
	MOVWF gbl_portc
	MOVF load_s_lin_0000A_arg_lines, W
	ANDLW 0xFF
	MOVWF gbl_portb
	MOVLW 0x01
	MOVWF gbl_porta
	CLRF gbl_porta
	RETURN
; } load_s_lines function end

	ORG 0x000001E4
load_l_siz_00009
; { load_l_size ; function begin
	MOVLW 0x09
	MOVWF gbl_portc
	MOVF load_l_siz_00009_arg_size, W
	ANDLW 0xFF
	MOVWF gbl_portb
	MOVLW 0x01
	MOVWF gbl_porta
	CLRF gbl_porta
	MOVF load_l_siz_00009_arg_size+D'1', W
	MOVWF load_l_siz_00009_arg_size
	CLRF load_l_siz_00009_arg_size+D'1'
	MOVLW 0x08
	MOVWF gbl_portc
	MOVF load_l_siz_00009_arg_size, W
	ANDLW 0x0F
	MOVWF gbl_portb
	MOVLW 0x01
	MOVWF gbl_porta
	CLRF gbl_porta
	RETURN
; } load_l_size function end

	ORG 0x0000020C
load_alpha_00008
; { load_alphaOp ; function begin
	MOVLW 0x0A
	MOVWF gbl_portc
	BTFSS load_alpha_00008_arg_alphaOp,0
	BRA	label268435770
	MOVLW 0x01
	MOVWF gbl_portb
	BRA	label268435773
label268435770
	CLRF gbl_portb
label268435773
	MOVLW 0x01
	MOVWF gbl_porta
	CLRF gbl_porta
	RETURN
; } load_alphaOp function end

	ORG 0x00000224
drawsprite_00000
; { drawsprite ; function begin
	MOVF drawsprite_00000_arg_sprite+D'12', W
	MOVWF __mul_32_3_00006_arg_a
	MOVF drawsprite_00000_arg_sprite+D'13', W
	MOVWF __mul_32_3_00006_arg_a+D'1'
	MOVF drawsprite_00000_arg_sprite+D'14', W
	MOVWF __mul_32_3_00006_arg_a+D'2'
	MOVF drawsprite_00000_arg_sprite+D'15', W
	MOVWF __mul_32_3_00006_arg_a+D'3'
	MOVLW 0xA0
	MOVWF __mul_32_3_00006_arg_b
	CLRF __mul_32_3_00006_arg_b+D'1'
	CLRF __mul_32_3_00006_arg_b+D'2'
	CLRF __mul_32_3_00006_arg_b+D'3'
	CALL __mul_32_3_00006
	MOVF CompTempVarRet0, W
	MOVWF drawsprite_00000_1_destina_0000D
	MOVF CompTempVarRet0+D'1', W
	MOVWF drawsprite_00000_1_destina_0000D+D'1'
	MOVF CompTempVarRet0+D'2', W
	MOVWF drawsprite_00000_1_destina_0000D+D'2'
	MOVF CompTempVarRet0+D'3', W
	MOVWF drawsprite_00000_1_destina_0000D+D'3'
	MOVF drawsprite_00000_arg_sprite+D'8', W
	ADDWF drawsprite_00000_1_destina_0000D, F
	MOVF drawsprite_00000_arg_sprite+D'9', W
	ADDWFC drawsprite_00000_1_destina_0000D+D'1', F
	MOVF drawsprite_00000_arg_sprite+D'10', W
	ADDWFC drawsprite_00000_1_destina_0000D+D'2', F
	MOVF drawsprite_00000_arg_sprite+D'11', W
	ADDWFC drawsprite_00000_1_destina_0000D+D'3', F
	MOVF drawsprite_00000_1_destina_0000D, W
	MOVWF load_t_add_0000B_arg_address
	MOVF drawsprite_00000_1_destina_0000D+D'1', W
	MOVWF load_t_add_0000B_arg_address+D'1'
	MOVF drawsprite_00000_1_destina_0000D+D'2', W
	MOVWF load_t_add_0000B_arg_address+D'2'
	MOVF drawsprite_00000_1_destina_0000D+D'3', W
	MOVWF load_t_add_0000B_arg_address+D'3'
	CALL load_t_add_0000B
	MOVF drawsprite_00000_arg_sprite, W
	MOVWF load_s_add_0000C_arg_address
	MOVF drawsprite_00000_arg_sprite+D'1', W
	MOVWF load_s_add_0000C_arg_address+D'1'
	MOVF drawsprite_00000_arg_sprite+D'2', W
	MOVWF load_s_add_0000C_arg_address+D'2'
	MOVF drawsprite_00000_arg_sprite+D'3', W
	MOVWF load_s_add_0000C_arg_address+D'3'
	CALL load_s_add_0000C
	MOVF drawsprite_00000_arg_sprite+D'6', W
	MOVWF load_s_lin_0000A_arg_lines
	MOVF drawsprite_00000_arg_sprite+D'7', W
	MOVWF load_s_lin_0000A_arg_lines+D'1'
	CALL load_s_lin_0000A
	MOVF drawsprite_00000_arg_sprite+D'4', W
	MOVWF load_l_siz_00009_arg_size
	MOVF drawsprite_00000_arg_sprite+D'5', W
	MOVWF load_l_siz_00009_arg_size+D'1'
	CALL load_l_siz_00009
	MOVF drawsprite_00000_arg_sprite+D'16', F
	BZ	label268435755
	BSF load_alpha_00008_arg_alphaOp,0
	CALL load_alpha_00008
	BRA	label268435761
label268435755
	BCF load_alpha_00008_arg_alphaOp,0
	CALL load_alpha_00008
label268435761
	CALL draw_00000
	RETURN
; } drawsprite function end

	ORG 0x000002BA
drawtoback_00007
; { drawtobackground ; function begin
	CLRF load_t_add_0000B_arg_address
	CLRF load_t_add_0000B_arg_address+D'1'
	CLRF load_t_add_0000B_arg_address+D'2'
	CLRF load_t_add_0000B_arg_address+D'3'
	CALL load_t_add_0000B
	MOVF drawtoback_00007_arg_source, W
	MOVWF load_s_add_0000C_arg_address
	MOVF drawtoback_00007_arg_source+D'1', W
	MOVWF load_s_add_0000C_arg_address+D'1'
	MOVF drawtoback_00007_arg_source+D'2', W
	MOVWF load_s_add_0000C_arg_address+D'2'
	MOVF drawtoback_00007_arg_source+D'3', W
	MOVWF load_s_add_0000C_arg_address+D'3'
	CALL load_s_add_0000C
	MOVF drawtoback_00007_arg_source+D'6', W
	MOVWF load_s_lin_0000A_arg_lines
	MOVF drawtoback_00007_arg_source+D'7', W
	MOVWF load_s_lin_0000A_arg_lines+D'1'
	CALL load_s_lin_0000A
	MOVF drawtoback_00007_arg_source+D'4', W
	MOVWF load_l_siz_00009_arg_size
	MOVF drawtoback_00007_arg_source+D'5', W
	MOVWF load_l_siz_00009_arg_size+D'1'
	CALL load_l_siz_00009
	BCF load_alpha_00008_arg_alphaOp,0
	CALL load_alpha_00008
	CALL draw_00000
	RETURN
; } drawtobackground function end

	ORG 0x000002FE
setupinput_00000
; { setupinput ; function begin
	BCF gbl_trisc,6
	BSF gbl_trisc,7
	BSF gbl_trisc,5
	SETF gbl_spbrg
	BSF gbl_txsta,4
	BSF gbl_rcsta,7
	BSF gbl_txsta,7
	BCF gbl_rcsta,5
	BCF gbl_rcsta,4
	BCF gbl_portd,5
	RETURN
; } setupinput function end

	ORG 0x00000314
getinput_00000
; { getinput ; function begin
	BSF gbl_portd,5
	MOVLW 0x0C
	MOVWF delay_us_00000_arg_del
	CALL delay_us_00000
	BCF gbl_portd,5
	MOVLW 0x06
	MOVWF delay_us_00000_arg_del
	CALL delay_us_00000
	BSF gbl_rcsta,5
	BTFSS gbl_pir1,5
	BRA	label268437510
	MOVF gbl_rcreg, W
	MOVWF CompTempVarRet0
label268437510
	RETURN
; } getinput function end

	ORG 0x00000334
bootup_00000
; { bootup ; function begin
	CLRF bootup_00000_1_i
	CLRF bootup_00000_1_j
	CLRF bootup_00000_1_black
	MOVLW 0xC2
	MOVWF bootup_00000_1_black+D'1'
	MOVLW 0x01
	MOVWF bootup_00000_1_black+D'2'
	CLRF bootup_00000_1_black+D'3'
	MOVLW 0xF0
	MOVWF bootup_00000_1_black+D'6'
	CLRF bootup_00000_1_black+D'7'
	MOVLW 0xA0
	MOVWF bootup_00000_1_black+D'4'
	CLRF bootup_00000_1_black+D'5'
	CLRF bootup_00000_1_frame
	MOVLW 0x68
	MOVWF bootup_00000_1_frame+D'1'
	MOVLW 0x37
	MOVWF bootup_00000_1_frame+D'2'
	CLRF bootup_00000_1_frame+D'3'
	MOVLW 0xA0
	MOVWF bootup_00000_1_frame+D'6'
	CLRF bootup_00000_1_frame+D'7'
	MOVLW 0x4F
	MOVWF bootup_00000_1_frame+D'4'
	CLRF bootup_00000_1_frame+D'5'
	CLRF bootup_00000_1_frame+D'8'
	CLRF bootup_00000_1_frame+D'9'
	CLRF bootup_00000_1_frame+D'10'
	CLRF bootup_00000_1_frame+D'11'
	CLRF bootup_00000_1_frame+D'12'
	CLRF bootup_00000_1_frame+D'13'
	CLRF bootup_00000_1_frame+D'14'
	CLRF bootup_00000_1_frame+D'15'
	CLRF bootup_00000_1_frame+D'16'
	MOVLW 0x28
	MOVWF bootup_00000_1_frame+D'8'
	CLRF bootup_00000_1_frame+D'9'
	CLRF bootup_00000_1_frame+D'10'
	CLRF bootup_00000_1_frame+D'11'
	MOVLW 0x28
	MOVWF bootup_00000_1_frame+D'12'
	CLRF bootup_00000_1_frame+D'13'
	CLRF bootup_00000_1_frame+D'14'
	CLRF bootup_00000_1_frame+D'15'
	MOVF bootup_00000_1_black+D'7', W
	MOVWF drawtoback_00007_arg_source+D'7'
	MOVF bootup_00000_1_black+D'6', W
	MOVWF drawtoback_00007_arg_source+D'6'
	MOVF bootup_00000_1_black+D'5', W
	MOVWF drawtoback_00007_arg_source+D'5'
	MOVF bootup_00000_1_black+D'4', W
	MOVWF drawtoback_00007_arg_source+D'4'
	MOVF bootup_00000_1_black+D'3', W
	MOVWF drawtoback_00007_arg_source+D'3'
	MOVF bootup_00000_1_black+D'2', W
	MOVWF drawtoback_00007_arg_source+D'2'
	MOVF bootup_00000_1_black+D'1', W
	MOVWF drawtoback_00007_arg_source+D'1'
	MOVF bootup_00000_1_black, W
	MOVWF drawtoback_00007_arg_source
	CALL drawtoback_00007
	MOVLW 0xC8
	MOVWF delay_ms_00000_arg_del
	CALL delay_ms_00000
	CLRF bootup_00000_1_i
label268437212
	MOVLW 0x15
	CPFSLT bootup_00000_1_i
	BRA	label268437213
	MOVF bootup_00000_1_frame+D'16', W
	MOVWF drawsprite_00000_arg_sprite+D'16'
	MOVF bootup_00000_1_frame+D'15', W
	MOVWF drawsprite_00000_arg_sprite+D'15'
	MOVF bootup_00000_1_frame+D'14', W
	MOVWF drawsprite_00000_arg_sprite+D'14'
	MOVF bootup_00000_1_frame+D'13', W
	MOVWF drawsprite_00000_arg_sprite+D'13'
	MOVF bootup_00000_1_frame+D'12', W
	MOVWF drawsprite_00000_arg_sprite+D'12'
	MOVF bootup_00000_1_frame+D'11', W
	MOVWF drawsprite_00000_arg_sprite+D'11'
	MOVF bootup_00000_1_frame+D'10', W
	MOVWF drawsprite_00000_arg_sprite+D'10'
	MOVF bootup_00000_1_frame+D'9', W
	MOVWF drawsprite_00000_arg_sprite+D'9'
	MOVF bootup_00000_1_frame+D'8', W
	MOVWF drawsprite_00000_arg_sprite+D'8'
	MOVF bootup_00000_1_frame+D'7', W
	MOVWF drawsprite_00000_arg_sprite+D'7'
	MOVF bootup_00000_1_frame+D'6', W
	MOVWF drawsprite_00000_arg_sprite+D'6'
	MOVF bootup_00000_1_frame+D'5', W
	MOVWF drawsprite_00000_arg_sprite+D'5'
	MOVF bootup_00000_1_frame+D'4', W
	MOVWF drawsprite_00000_arg_sprite+D'4'
	MOVF bootup_00000_1_frame+D'3', W
	MOVWF drawsprite_00000_arg_sprite+D'3'
	MOVF bootup_00000_1_frame+D'2', W
	MOVWF drawsprite_00000_arg_sprite+D'2'
	MOVF bootup_00000_1_frame+D'1', W
	MOVWF drawsprite_00000_arg_sprite+D'1'
	MOVF bootup_00000_1_frame, W
	MOVWF drawsprite_00000_arg_sprite
	CALL drawsprite_00000
	MOVLW 0x12
	CPFSGT bootup_00000_1_i
	BRA	label268437220
	MOVLW 0x64
	MOVWF delay_ms_00000_arg_del
	CALL delay_ms_00000
	BRA	label268437226
label268437220
	MOVLW 0x3C
	MOVWF delay_ms_00000_arg_del
	CALL delay_ms_00000
label268437226
	MOVLW 0x50
	ADDWF bootup_00000_1_frame, F
	MOVLW 0x00
	ADDWFC bootup_00000_1_frame+D'1', F
	MOVLW 0x00
	ADDWFC bootup_00000_1_frame+D'2', F
	MOVLW 0x00
	ADDWFC bootup_00000_1_frame+D'3', F
	MOVF bootup_00000_1_frame+D'16', W
	MOVWF drawsprite_00000_arg_sprite+D'16'
	MOVF bootup_00000_1_frame+D'15', W
	MOVWF drawsprite_00000_arg_sprite+D'15'
	MOVF bootup_00000_1_frame+D'14', W
	MOVWF drawsprite_00000_arg_sprite+D'14'
	MOVF bootup_00000_1_frame+D'13', W
	MOVWF drawsprite_00000_arg_sprite+D'13'
	MOVF bootup_00000_1_frame+D'12', W
	MOVWF drawsprite_00000_arg_sprite+D'12'
	MOVF bootup_00000_1_frame+D'11', W
	MOVWF drawsprite_00000_arg_sprite+D'11'
	MOVF bootup_00000_1_frame+D'10', W
	MOVWF drawsprite_00000_arg_sprite+D'10'
	MOVF bootup_00000_1_frame+D'9', W
	MOVWF drawsprite_00000_arg_sprite+D'9'
	MOVF bootup_00000_1_frame+D'8', W
	MOVWF drawsprite_00000_arg_sprite+D'8'
	MOVF bootup_00000_1_frame+D'7', W
	MOVWF drawsprite_00000_arg_sprite+D'7'
	MOVF bootup_00000_1_frame+D'6', W
	MOVWF drawsprite_00000_arg_sprite+D'6'
	MOVF bootup_00000_1_frame+D'5', W
	MOVWF drawsprite_00000_arg_sprite+D'5'
	MOVF bootup_00000_1_frame+D'4', W
	MOVWF drawsprite_00000_arg_sprite+D'4'
	MOVF bootup_00000_1_frame+D'3', W
	MOVWF drawsprite_00000_arg_sprite+D'3'
	MOVF bootup_00000_1_frame+D'2', W
	MOVWF drawsprite_00000_arg_sprite+D'2'
	MOVF bootup_00000_1_frame+D'1', W
	MOVWF drawsprite_00000_arg_sprite+D'1'
	MOVF bootup_00000_1_frame, W
	MOVWF drawsprite_00000_arg_sprite
	CALL drawsprite_00000
	MOVLW 0x12
	CPFSGT bootup_00000_1_i
	BRA	label268437236
	MOVLW 0x64
	MOVWF delay_ms_00000_arg_del
	CALL delay_ms_00000
	BRA	label268437242
label268437236
	MOVLW 0x3C
	MOVWF delay_ms_00000_arg_del
	CALL delay_ms_00000
label268437242
	MOVLW 0xB0
	ADDWF bootup_00000_1_frame, F
	MOVLW 0x63
	ADDWFC bootup_00000_1_frame+D'1', F
	MOVLW 0x00
	ADDWFC bootup_00000_1_frame+D'2', F
	MOVLW 0x00
	ADDWFC bootup_00000_1_frame+D'3', F
	INCF bootup_00000_1_i, F
	BRA	label268437212
label268437213
	RETURN
; } bootup function end

	ORG 0x000004A8
main
; { main ; function begin
	MOVLW 0x07
	MOVWF gbl_adcon1
	CLRF gbl_trisa
	CLRF gbl_trisb
	MOVLW 0x80
	MOVWF gbl_trisc
	MOVWF gbl_trisd
	CLRF gbl_porta
	CLRF gbl_portb
	CLRF gbl_portc
	CLRF gbl_portc
	CALL bootup_00000
	CALL setupinput_00000
label268437264
	CALL getinput_00000
	MOVF CompTempVarRet0, W
	MOVWF main_1_temp
	MOVLW 0xF7
	ANDWF main_1_temp, W
	BTFSS STATUS,Z
	BSF gbl_portd,0
	MOVLW 0xFB
	ANDWF main_1_temp, W
	BTFSS STATUS,Z
	BCF gbl_portd,0
	BRA	label268437264
; } main function end

	ORG 0x000004E0
_startup
	GOTO	main
	END
