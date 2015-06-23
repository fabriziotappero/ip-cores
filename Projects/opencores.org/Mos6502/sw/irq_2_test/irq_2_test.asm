
  include  ../io_module/io_module.asm
	
	
	;;  page zero variables used during test
c_test         = $40    ;
n_test         = $41    ;
v_test         = $42    ;	
z_test         = $43    ;
pointer        = $44    ;	
counter0       = $46    ;	
counter1       = $48    ;
	
	* = $f000  ; assemble at $f000
               code

	
.start             nop
                   lda #$00
                   sta counter0
                   sta counter1
                   sta $04	
                   sta $05
	           sta $06
                   sta $07
	           lda #$00
	           sta io_base+io_gpio_0
		   lda io_base+io_gpio_0
                   lda #$01
	           sta io_base+io_gpio_0
	           lda io_base+io_gpio_0
                   sta io_base+io_pic_irq_en 
	           lda #$f7
	           sta io_base+io_vic_irq_en
                   jmp .lab_00
                   lda #$00
                   jmp .error
.lab_00            lda #$01
	           sta io_base+io_gpio_0
	           lda io_base+io_gpio_0
                   lda #$02
	           sta io_base+io_gpio_0
	           lda io_base+io_gpio_0
                   clc
                   bcc .lab_44
                   lda #$01
                   jmp .error

.lab_44            lda #$28
                   sta io_base+io_gpio_0
                   lda #$EF
                   sta $0200
                   inc $0200
                   lda #$F0
                   cmp $0200
                   beq  .lab_45
                   lda #$39
                   jmp .error
.lab_45            lda #$FF
                   sta $0200
                   inc $0200
                   beq  .lab_46
                   lda #$40
                   jmp .error
.lab_46            lda #$29
                   sta io_base+io_gpio_0
                   ldy #$32
                   sty $0201
                   ldx #$B4
                   stx $0200
                   lda #$86
                   eor $0200
                   cmp $0201
                   beq  .lab_47
                   lda #$41
                   jmp .error
.lab_47            lda #$2A
                   sta io_base+io_gpio_0
                   ldy #$B6
                   sty $0201
                   ldx #$B4
                   stx $0200
                   lda #$86
                   ora $0200
                   cmp $0201
                   beq  .lab_59
                   lda #$42
                   jmp .error



.lab_59            lda #$31
                   sta io_base+io_gpio_0
                   lda #$42
                   pha
                   lda #$ED
                   pha
                   lda #$BE
                   pha
                   lda #$00
                   pla
                   cmp #$BE
                   bne .lab_60
                   pla
                   cmp #$ED
                   bne .lab_60
                   pla
                   cmp #$42
                   bne .lab_60
                   jmp  .lab_605
.lab_60            lda #$4E
                   jmp .error
.lab_605           lda #$32
                   sta io_base+io_gpio_0
                   ldx #$00
                   clc
                   lda #$03 
                   sta $0200,X
                   adc #$07
                   inx
                   sta $0200,X
                   adc #$07
                   inx
                   sta $0200,X
                   adc #$07
                   inx
                   sta $0200,X
                   adc #$07
                   inx
                   sta $0200,X
                   adc #$07
                   inx
                   sta $0200,X
                   adc #$07
                   inx
                   sta $0200,X
                   ldx #$00
                   clc
                   lda $0200,X
                   cmp #$03
                   bne .lab_61
                   inx
                   lda $0200,X
                   cmp #$0A
                   bne .lab_61
                   inx
                   lda $0200,X
                   cmp #$11
                   bne .lab_61
                   inx
                   lda $0200,X
                   cmp #$18
                   bne .lab_61
                   inx
                   lda $0200,X
                   cmp #$1F
                   bne .lab_61
                   inx
                   lda $0200,X
                   cmp #$26
                   bne .lab_61
                   inx
                   lda $0200,X
                   cmp #$2D
                   bne .lab_61
                   jmp .lab_615
.lab_61            lda #$4F
                   jmp .error
.lab_615           lda #$33
                   sta io_base+io_gpio_0
                   ldy #$00 
                   clc
                   lda #$03
                   sta $0200,Y
                   adc #$07
                   iny
                   sta $0200,Y
                   adc #$07
                   iny
                   sta $0200,Y
                   adc #$07
                   iny
                   sta $0200,Y
                   adc #$07
                   iny
                   sta $0200,Y
                   adc #$07 
                   iny
                   sta $0200,Y
                   adc #$07
                   iny
                   sta $0200,Y
                   ldy #$00
                   clc
                   lda $0200,Y
                   cmp #$03
                   bne .lab_62
                   iny
                   lda $0200,Y
                   cmp #$0A
                   bne .lab_62
                   iny
                   lda $0200,Y 
                   cmp #$11
                   bne .lab_62
                   iny
                   lda $0200,Y
                   cmp #$18
                   bne .lab_62
                   iny
                   lda $0200,Y 
                   cmp #$1F
                   bne .lab_62
                   iny
                   lda $0200,Y
                   cmp #$26
                   bne .lab_62
                   iny
                   lda $0200,Y 
                   cmp #$2D
                   bne .lab_62
                   jmp .lab_625
.lab_62            lda #$50
                   jmp .error
.lab_625           lda #$34
                   sta io_base+io_gpio_0
                   lda #$52
                   sta $0200
                   lda #$24
                   sta $0201
                   lda #$78
                   sta $0202 
                   lda #$00
                   ldx #$00
                   clc
                   adc $0200,X
                   clc
                   inx
                   adc $0200,X
                   clc
                   inx
                   adc $0200,X
                   cmp #$EE
                   beq .lab_63
                   lda #$51
                   jmp .error
.lab_63            lda #$35
                   sta io_base+io_gpio_0 
                   lda #$68
                   sta $0200
                   lda #$13
                   sta $0201
                   lda #$95
                   sta $0202
                   lda #$00
                   ldy #$00
                   clc
                   adc $0200,Y
                   clc
                   iny
                   adc $0200,Y
                   clc
                   iny
                   adc $0200,Y
                   cmp #$10
                   beq  .lab_64
                   lda #$52
                   jmp .error
.lab_64            lda #$36	
                   sta io_base+io_gpio_0
                   lda #$34
                   sta $0200
                   lda #$54
                   sta $0201
                   lda #$97
                   sta $0202
                   lda #$FF 
                   ldy #$00
                   and $0200,Y
                   iny
                   and $0200,Y
                   iny
                   and $0200,Y
                   cmp #$14
                   beq .lab_65
                   lda #$53
                   jmp .error
.lab_65            lda #$37
                   sta io_base+io_gpio_0
                   lda #$34
                   sta $0200 
                   lda #$54
                   sta $0201
                   lda #$97
                   sta $0202
                   lda #$FF
                   ldx #$00
                   and $0200,X
                   inx
                   and $0200,X
                   inx
                   and $0200,X
                   cmp #$14
                   beq .lab_66
                   lda #$54
                   jmp .error
.lab_66            lda #$38
                   sta io_base+io_gpio_0
                   lda #$64
                   sta $00
                   lda #$39
                   clc
                   adc $00 
                   cmp #$9D
                   beq  .lab_735
                   lda #$55
                   jmp .error
.lab_735           lda #$3F
                   sta io_base+io_gpio_0
                   lda #$95
                   sta $02
                   lda #$00
                   lda #$95
                   cmp  $02
                   beq  .lab_74
                   lda #$5C 
                   jmp .error
.lab_74            lda #$75
                   sta $02
                   lda #$67
                   cmp  $02
                   bne .lab_75
                   lda #$5D
                   jmp .error
.lab_75            lda #$40
                   sta io_base+io_gpio_0
                   lda #$36
                   sta $02
                   lda #$00
                   ldx #$36
                   cpx $02
                   beq  .lab_76
                   lda #$5E
                   jmp .error
.lab_76            lda #$57
                   sta $02
                   ldx #$39
	           cpx $02 
                   bne .lab_77
                   lda #$5F
                   jmp .error
.lab_77            lda #$41
                   sta io_base+io_gpio_0
                   lda #$75
                   sta $02 
                   lda #$00
                   ldy #$75
                   cpy $02
                   beq  .lab_78
                   lda #$60
                   jmp .error
.lab_78            lda #$43
                   sta $02
                   ldy #$24
                   cpy $02
                   bne .lab_79
                   lda #$61
                   jmp .error
.lab_79            lda #$42
                   sta io_base+io_gpio_0
                   cli		; was cli
                   lda #$00
                   sta $05
                   lda #$01
                   sta $04
                   lda #$10
                   sta io_base+io_tim0_end
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
                   cpx  #$10
                   beq .lab_80
                   lda #$62
                   jmp .error
.lab_80            lda $05
                   cmp #$00	; was 1 if int serviced
                   beq  .lab_81
                   lda #$63
                   jmp .error
.lab_81            nop		;   was sei to disable interrupt
                   lda #$00
                   sta $05
                   lda #$01
                   sta $04
                   lda #$10
                   sta io_base+io_tim0_end
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
                   cpx #$10
                   beq .lab_82
                   lda #$62
                   jmp .error
.lab_82            lda $05
                   cmp #$00
                   beq  .lab_83
                   lda #$63
                   jmp .error
.lab_83            lda #$00
                   sta $04
                   sta io_base+io_tim0_end
                   lda #$43
                   sta io_base+io_gpio_0
                   lda #$00
                   sta $07
                   lda #$01
                   sta $06
                   lda #$10
                   sta io_base+io_tim0_end ; change to tim1 for nmi
                   sta io_base+io_tim0_start   ; change to tim1 for nmi
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
                   cpx  #$10
                   beq  .lab_84
                   lda #$64
                   jmp .error
.lab_84            lda $07
                   cmp #$00	; change to 1 if nmi serviced
                   beq  .lab_85
                   lda #$65
                   jmp .error
.lab_85            lda #$00
                   sta $06
                   sta io_base+io_tim1_end
                   lda #$44
                   sta io_base+io_gpio_0
                   jmp .lab_865
.lab_86            jmp .lab_866
.lab_865           sec
                   bcs .lab_86
                   nop
                   nop
                   nop
                   lda #$66
                   jmp .error
.lab_866           lda #$45 
                   sta io_base+io_gpio_0
                   sec
                   lda #$34
                   sbc #$75
                   bcc .lab_92
                   lda #$67
                   jmp .error
	
.lab_92            lda #$48
                   sta io_base+io_gpio_0 
                   lda #$53
                   sta $30
                   lda #$00
                   ldx #$40
                   lda $F0,X
                   cmp #$53
                   beq  .lab_93
                   lda #$73 
                   jmp .error
.lab_93            lda #$49
                   sta io_base+io_gpio_0
                   clc
                   lda #$FF
                   adc #$01
                   bcs .lab_94
                   lda #$74
                   jmp .error
.lab_94            lda #$4A
                   sta io_base+io_gpio_0
                   sec
                   lda #$7F
                   sbc #$7E
                   bvc  .good
                   lda #$75
                   jmp .error



	;;  pass end loop
.good              nop
                   lda #$FF
                   sta io_base+io_gpio_0 
                   jmp .end_lp

	;; error  & end loop
.error             sei
                   sta io_base+io_gpio_1
.end_lp            lda #$00
                   pha
                   plp
                   jmp .end_lp
	

	;; Interrupt service routine
.nmi_vec           pha
                   txa
                   pha 
                   tya
                   pha
                   lda #$10
.nmi_001           sta io_base+io_tim0_end
                   inc $05
                   pla
                   tay
                   pla
                   tax 
                   pla
                   rti

	;; Interrupt service routine
	
.irq_vec           pha
                   txa
                   pha
                   tya
                   pha
                   lda #$10
                   sta io_base+io_tim0_end
                   lda #$80
.irq_001           sta io_base+io_tim0_start
                   inc counter0
	           bne .irq_002
	           inc counter1
	           bne .irq_002	
                   inc io_base+io_gpio_1 	
.irq_002           pla
                   tay
                   pla
                   tax
                   pla
                   rti



 * = $ffe0  ; vectors


	
     dw .irq_vec	       ;
	
	
    
 * = $fffa  ; vectors


	
     dw .nmi_vec	       ;
     dw .start	       ;
     dw .irq_vec	       ;


	


 code
    





