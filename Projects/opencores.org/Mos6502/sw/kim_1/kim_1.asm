

          include  ../io_module/io_module.asm 
	
	
	


str_1          = $ff00
top            = $ff10
	

                 * = $10
inl            db  0		;
inh            db  0		;
pointl         db  0		;
pointh         db  0		;
chksum         db  0		;
chkhi          db  0		;
eal            db  0		;
eah            db  0		;
sbd            db  0		;


	
	     * = $c000  ; assemble start
               code

.vec               jmp  .nmi_vec	  
                   jmp  .irq_vec	



.start             jsr .init
                   ldx #$fe
.dloop             jsr .delay
	           dex
                   bne .dloop
	           jsr .crlf	
                   ldx #$04
                   jsr .prtst
                   jmp .show1

.space             jsr .open
.show              jsr .crlf
.show1             jsr .prtpnt
                   jsr .outsp
	           ldy #$00
                   lda (pointl),y
                   sta io_base+io_gpio_0
                   jsr .prtbyt
                   jsr .outsp	
	           jmp .clear

.clear             lda #$00
	           sta inl
	           sta inh
.read              jsr .getch
                   cmp #$0d
	           beq .scan
                   jsr .outch
                   jsr .pack
                   jmp .scan

.scan              cmp #$20
	           beq .space
	           cmp #$0d
	           beq .rtrn
	           cmp #$2f
	           beq .feed	
	           cmp #$2e
	           beq .modify
		   cmp #$51
	           beq .dumpv
		   cmp #$4C
	           beq .loadv
	
	           jmp .read
	
.rtrn              jsr .incpt
	           jmp .show
	

.dumpv             jmp .dump
.loadv             jmp .load

.feed              sec
	           lda  pointl
	           sbc #$01
	           sta  pointl
                   bcs .feed1
                   dec  pointh
.feed1             jmp .show



.modify            ldy #$00
	           lda inl
	           sta (pointl),y
	           jmp .rtrn




.load              jsr .getch
	           cmp #$3b
	           bne .load
.loads             lda #$00
	           sta chksum
	           sta chkhi
	           jsr .getbyt
                   tax
	           jsr .chk
	           jsr .getbyt
	           sta pointh
	           jsr .chk
	           jsr .getbyt
	           sta pointl
	           jsr .chk
	           txa
	           beq .load3
.load2            jsr .getbyt
	          sta (pointl),y
	          jsr .chk
	          jsr .incpt
	          dex
	          bne .load2
                  inx
.load3            jsr .getbyt
	          cmp chkhi
	          bne .loade1
	          jsr .getbyt
                  cmp chksum
	         bne .loader
	         txa
	         bne .load
.load7           ldx #$0c
.load8           lda #$27
	         sta sbd
	         jsr .prtst
	         jmp .start
.loade1          jsr .getbyt
.loader          ldx #$11
	         bne .load8
	
	




	

.dump               clc
	            lda inl
	            adc pointl
	            sta eal
                    lda inh
	            adc pointh
                    sta eah

                    lda #$00
                    sta inl
	            sta inh
.dump0              lda #$00
	            sta chkhi
	            sta chksum
.dump1              jsr .crlf

	            lda pointl
	            cmp eal
	            lda pointh
	            sbc eah
	            bcc .dump4

                    jsr .crlf	
	        
	            jmp .clear
	

	
.dump4              lda #$10
	            tax
                    jsr .prtpnt
                    jsr .outsp
	            jsr .outsp

.dump2              ldy #$00
	            lda (pointl),y
                    sta io_base+io_gpio_0
	            jsr .prtbyt
	            jsr .outsp	

	            jsr .incpt
	            dex
	            bne .dump2

                    inc inl
                    bne .dump3
	            inc inh
.dump3              jmp .dump0

	


	




	
.prtpnt           lda  pointh
	          jsr .prtbyt
                  jsr .chk
	          lda  pointl
	          jsr .prtbyt
	          jsr .chk
	          rts



.chk              clc
	          adc chksum
	          lda chkhi
	          adc #$00
	          sta chkhi
	          rts




.crlf             ldx #$01
.prtst            lda top,x
                  jsr .outch
	          dex
	          bpl .prtst
.prt1             rts	

	


.incpt             inc pointl
	           bne .incpt2
                   inc pointh
.incpt2            rts	
	

	

.getch             lda io_base+io_pic_int
	           and #$04
                   beq .getch
	           lda io_base+io_uart_rcv
                   rts
	

	
.getbyt            jsr   .getch
	           jsr   .pack
	           jsr   .getch
                   jsr   .pack
                   lda    inl
	           rts



	
.pack              cmp #$30
	           bmi .updat2
	           cmp #$47
	           bpl .updat2
.hexnum            cmp #$40
	           bmi .update
.hexalp            clc
	           adc #$09
.update            rol a
	           rol a
	           rol a
	           rol a
	           ldy #$04
.updat1            rol a
	           rol inl
                   rol inh
	           dey
	           bne .updat1
	           lda #$00
.updat2            rts


.open              lda inl
	           sta pointl
	           lda inh
	           sta pointh
	           rts
	
	

.init    	   lda #$c0
	           sta io_base+io_uart_cnt  	
                   ldx #$00
  	           ldy #$00
                   lda #$fa
	           sta pointl
	           lda #$ff
	           sta pointh	
                   lda #$00
                   sta eal
	           sta eah
	           rts

	


.outsp             lda #$20	
.outch             pha
.outchl	           lda io_base+io_pic_int
	           and #$08
                   beq .outchl
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
	           jmp .outch
	



.delay             lda #$ff
	           clc
	           adc #$01
 	           bne .delay
	           rts
	
	

.irq_vec           pha
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
    





