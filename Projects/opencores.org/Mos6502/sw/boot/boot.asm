
	
       cpu 6502
           output HEX



io_base        = $8000 ;

io_gpio_0      = $02    ;
io_gpio_1      = $06    ;

io_tim0_start  = $10    ;
io_tim0_count  = $12    ;
io_tim0_end    = $14    ;

io_tim1_start  = $18    ;
io_tim1_count  = $1A    ;	
io_tim1_end    = $1C    ;

io_uart_xmt    = $20    ;
io_uart_rcv    = $22    ;	
io_uart_cnt    = $24    ;	
io_uart_stat   = $26    ;


io_pic_int     = $30    ;	
io_pic_irq_en  = $32    ;	
io_pic_nmi_en  = $34    ;	
io_pic_irq_ac  = $36    ;	
io_pic_nmi_ac  = $38    ;	

io_ps2_data    = $40    ;	
io_ps2_stat    = $42    ;	
io_ps2_cntrl   = $44    ;	
io_ps2_xpos    = $46    ;	
io_ps2_ypos    = $48    ;	


io_utim_lat    = $50    ;	
io_utim_cnt    = $52    ;	

io_vga_ascii   = $60    ;	
io_vga_addl    = $62    ;	
io_vga_addh    = $64    ;	
io_vga_cntrl   = $66    ;	
	
	;;  page zero variables used during test
c_test         = $40    ;
n_test         = $41    ;
v_test         = $42    ;	
z_test         = $43    ;
pointer        = $44    ;	


	* = $ff00  ; assemble at $fe00
               code

.table             db $01,$02,$03,$04,$05,$06,$07,$08 ;
                   db $09,$a1,$b2,$c3,$d4,$e5,$f6,$07 ;
                   db $80,$09,$01,$02,$03,$04,$05,$06 ;
                   db $70,$8a,$b9,$c1,$d2,$e3,$f4,$05 ;
                   db $60,$70,$80,$09,$01,$02,$03,$04 ;
                   db $50,$6a,$7b,$8c,$d9,$e1,$02,$03 ;
                   db $40,$50,$60,$70,$80,$09,$f1,$00 ;
                   db $30,$4a,$5b,$6c,$7d,$8e,$09,$01 ;
                   db $20,$30,$40,$50,$60,$70,$8f,$09 ;
                   db $19,$2a,$3b,$4c,$5d,$6e,$70,$80 ;
                   db $08,$19,$20,$30,$40,$50,$6f,$70 ;
                   db $07,$a8,$19,$2c,$3d,$4e,$50,$60 ;
                   db $06,$07,$b8,$19,$20,$30,$4f,$50 ;
                   db $05,$a6,$07,$08,$19,$2e,$30,$40 ;
                   db $04,$05,$b6,$c7,$08,$19,$2f,$30 ;
                   db $03,$a4,$05,$06,$d7,$08,$19,$20 ;
                   db $02,$03,$b4,$c5,$06,$e7,$f8,$19 ;
                   db $00,$a2,$03,$04,$d5,$06,$07,$08 ;
                   db $91,$00,$b2,$c3,$04,$e5,$f6,$07 ;
                   db $80,$91,$00,$02,$d3,$04,$05,$06 ;
                   db $70,$8a,$91,$c0,$02,$e3,$f4,$05 ;
                   db $60,$70,$8b,$91,$d0,$02,$03,$04 ;
                   db $50,$6a,$70,$8c,$91,$e0,$f2,$03 ;
                   db $40,$50,$6b,$70,$80,$91,$00,$02 ;
	           db $30,$4a,$50,$6c,$7d,$8e,$91,$00 ;
                   db $20,$30,$4b,$50,$60,$70,$8f,$91 ;
                   db $00,$2a,$30,$4c,$5d,$6e,$70,$80 ;
                   db $10,$00,$2b,$30,$40,$50,$6f,$70 ;
                   db $00,$1a,$00,$2c,$3d,$4e,$50,$60 ;
                   db $00,$00,$1b,$00,$20,$30,$4f,$50 ;
                   db $00,$0a,$00,$1c,$0d,$2e,$30,$40 ;
                   db $00,$00;
	
     * = $fffa  ; vectors

     dw $c000	       ;nmi
     dw $c006	       ;reset
     dw $c003	       ;irq

 code
    





