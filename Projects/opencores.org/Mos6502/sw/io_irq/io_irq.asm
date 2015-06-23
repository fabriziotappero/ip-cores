
  include ../io_module/io_module.asm









	* = $c000  ; assemble start
               code

                   jmp  .nmi_vec	       ;
                   jmp  .irq_vec	       ;	
.start             nop
                   ldx #00
	           ldy #00
                   lda io_base+io_gpio_0	
                   sec
	           adc #00
	           sta io_base+io_gpio_0
                   lda io_base+io_gpio_0	
                   sec
	           adc #00
	           sta io_base+io_gpio_0	


	           lda #$01
				;
	           sta io_base+io_pic_irq_en
	
	           lda #$04
	           sta io_base+io_pic_nmi_en
	


	           lda #$c0
	           sta io_base+io_uart_cnt  	
                   lda #$42
	           sta io_base+io_uart_xmt  
	           cli		; was cli
                   lda #$fe
                   sta io_base+io_tim0_start

	           ldx #$00
                   inx
                   inx
                   inx
                   inx
                   inx
                   inx
                   inx
                   inx
                   inx
                   inx
                   inx
                   inx 
                   inx
                   inx
                   inx
                   inx


.lab_80            lda $05
                   jmp .lab_80



	


.irq_vec           pha
                   txa
                   pha 
                   tya
                   pha
                   lda io_base+io_gpio_0	
                   sec
	           adc #00
	           sta io_base+io_gpio_0
                   lda #$fe
                   sta io_base+io_tim0_end   	
                   sta io_base+io_tim0_start   
	           pla
                   tay
                   pla
                   tax 
                   pla
                   rti

.nmi_vec           pha
	           lda io_base+io_uart_rcv
                   sec
	           adc #01
                   sta io_base+io_uart_xmt
                   lda io_base+io_gpio_1	
                   sec
	           adc #00
	           sta io_base+io_gpio_1
                   pla
                   rti

	
	     * = $c0fa         ; vectors
     dw .nmi_vec	       ;
     dw .start		       ;
     dw .irq_vec	       ;

 code
    





