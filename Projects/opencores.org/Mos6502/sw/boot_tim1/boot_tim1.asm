
	
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
	


        * = $ff00  ; assemble at $ff00
               code


.str_1          ASC    "Mem  " ;
                DB   $00		;	


	* = $ff10  ; assemble at $ff10

.top       db $0a,$0d ;
	   ASC    "MIK";
	
	
        * = $fffa  ; vectors

          dw $c000	       ;nmi
          dw $c006	       ;reset
          dw $c003	       ;irq

 code
    





