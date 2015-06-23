
   include  ../io_module/io_module.asm

	
	
	     * = $ff00  ; assemble start
               code

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

	


	           lda #$c0
	           sta io_base+io_uart_cnt  	
                   lda #$42
	           sta io_base+io_uart_xmt  

.lab_80            lda io_base+io_pic_int
                   sta io_base+io_gpio_1
	           and #$04
                   beq .lab_80
	           lda io_base+io_uart_rcv
                   sec
	           adc #01
                   sta io_base+io_uart_xmt
	           inc io_base+io_gpio_0	
                   jmp .lab_80




.irq_vec           pha
                   txa
                   tax 
                   pla
                   rti

.nmi_vec           pha
                   pla
                   rti

	     * = $fffa  ; vectors


     dw .nmi_vec	       ;
     dw .start		       ;
     dw .irq_vec	       ;

 code
    





