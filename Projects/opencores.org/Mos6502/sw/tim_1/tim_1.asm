
         include ../io_module/io_module.asm
	
	
	
address       = $00
str_1         = $ff00
	
	
	     * = $c000  ; assemble start
               code

.vec               jmp  .nmi_vec	  
                   jmp  .irq_vec	
                   jmp  .start
	

.put_c          pha
.put_cl	        lda io_base+io_pic_int
	           and #$08
                   beq .put_cl
	           pla
                   sta io_base+io_uart_xmt
                   rts 
	
.prtbyt            pha
	           lsr a
	           lsr a
	           lsr a
	           lsr a
	           jsr  .hexta
	           pla  

.hexta             and #$0f
	           cmp #$0a
	           clc
	           bmi .hexta1
	           adc #$07
.hexta1            adc #$30
	           jmp .put_c
	

.delay             lda #$ff
	           clc
	           adc #$01
 	           bne .delay
	           rts


.send_ps	   sta io_base+io_ps2_data 	
                   lda #$64
                   sta io_base+io_utim_cnt 	
	           lda #$02
	           sta io_base+io_ps2_cntrl
.lp_100            lda io_base+io_utim_cnt 	
                   bne .lp_100
	           lda #$00
	           sta io_base+io_ps2_cntrl

.rcv_ps            lda io_base+io_ps2_stat 	
                   and #$40
	           beq .rcv_ps
                   lda io_base+io_ps2_data
 	           nop
	           rts
   

.start             lda #$ff
	           jsr .send_ps 	
	           jsr .rcv_ps 	
	           jsr .rcv_ps 	

	           jsr .delay
 	           jsr .delay
 	           jsr .delay
	 	   jsr .delay

	           lda #$f3
	           jsr .send_ps 	
	           jsr .delay

                   lda #$c8
	           jsr .send_ps 		
	           jsr .delay

                   lda #$f3
	           jsr .send_ps 	
	           jsr .delay

                   lda #$64
	           jsr .send_ps 	
	           jsr .delay

                   lda #$f3
	           jsr .send_ps 	
	           jsr .delay

                   lda #$50
	           jsr .send_ps 	
	           jsr .delay


                   lda #$f2
	           jsr .send_ps 	
	           jsr .delay

	           jsr .rcv_ps 	
	           jsr .delay

                   lda #$e8
	           jsr .send_ps 	
	           jsr .delay

                   lda #$03
	           jsr .send_ps 	
	           jsr .delay

                   lda #$f3
	           jsr .send_ps 	
	           jsr .delay
	
                   lda #$28
	           jsr .send_ps 	
	           jsr .delay

                   lda #$f4
	           jsr .send_ps

	
	           nop
 	           nop
 	           nop
 	           nop
                   nop
 	           nop
 	           nop
 	           nop
                   nop
 	           nop
 	           nop
	           nop
 	           nop
	           lda #$01
	           sta io_base+io_ps2_cntrl
	
	

	           lda #$c0
	           sta io_base+io_uart_cnt  	
                   ldx #$00
  	           ldy #$00
                   lda #$fa
	           sta address
	           lda #$ff
	           sta address+1
	        
.prn_add           ldy #$00
	           lda address+1
	           jsr .prtbyt	
                   lda address
	           jsr .prtbyt	
	           lda #$20
	           jsr .put_c


	           ldy  #$00
                   lda (address),y
	           jsr .prtbyt	
	           lda #$20
	           jsr .put_c

	           ldx #$00

.lab_01            lda  str_1,X	;
                   beq .lab_80
	           jsr .put_c	
                   inx
	           bne .lab_01  ;
.lab_80	           lda #$0d
	           jsr .put_c	
	           lda #$0a
	           jsr .put_c	

.lab_81            lda io_base+io_ps2_xpos
                   sta io_base+io_gpio_0
                   lda io_base+io_ps2_ypos
                   sta io_base+io_gpio_1

	           lda io_base+io_pic_int

	           and #$04
                   beq .lab_81
	           lda io_base+io_uart_rcv
	           sta io_base+io_vga_ascii
	           inc address	
                   bne .prn_add
	           inc address+1		
                   jmp .prn_add




.irq_vec           pha
                   txa
                   tax 
                   pla
                   rti

.nmi_vec           pha
                   pla
                   rti


	     * = $c3fa  ; vectors
	

     dw .nmi_vec	       ;
     dw .start		       ;
     dw .irq_vec	       ;

 code
    





