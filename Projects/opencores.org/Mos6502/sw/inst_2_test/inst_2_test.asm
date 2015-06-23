
	
  include ../io_module/io_module.asm
	
	;;  page zero variables used during test

             * = $0060
t_cnt          db 00	
var_1          = $04    ;
var_2          = $05    ;
var_3          = $06    ;	
var_4          = $07    ;	
c_test         = $40    ;
n_test         = $41    ;
v_test         = $42    ;	
z_test         = $43    ;
pointer        = $44    ;	


	* = $f000 
               code


	
.start             nop
                   lda #$34
	           sta t_cnt
	           lda #$00
                   sta var_1
                   sta var_2
	           sta var_3
                   sta var_4
	           lda t_cnt
	           inc io_base+io_gpio_0
		   lda io_base+io_gpio_0
                   inc t_cnt
	           lda t_cnt
	           inc io_base+io_gpio_0
	           lda io_base+io_gpio_0
                   jmp .lab_00
                   lda #$00
                   jmp .error
.lab_00            inc t_cnt
	           lda t_cnt
	           inc io_base+io_gpio_0
	           lda io_base+io_gpio_0
                   inc t_cnt
	           lda t_cnt
	           inc io_base+io_gpio_0
	           lda io_base+io_gpio_0
                   clc
                   bcc .lab_01
                   lda #$01
                   jmp .error
.lab_01	           inc t_cnt
	           lda t_cnt
	           inc io_base+io_gpio_0
	           lda io_base+io_gpio_0	
                   sec
                   bcc .lab_02
                   jmp .lab_025
.lab_02	           lda #$02
                   jmp .error
.lab_025           inc t_cnt
	           lda t_cnt
	           inc io_base+io_gpio_0
                   lda io_base+io_gpio_0
                   sec
	           bcs .lab_03
	           lda #$01
                   jmp .error

.lab_03	           clc
                   bcs .lab_04
                   jmp .lab_045
.lab_04            lda #$02
                   jmp .error
.lab_045           inc t_cnt
	           lda t_cnt
		   inc io_base+io_gpio_0
                   lda #$05
                   cmp #$04
                   beq .lab_05
                   cmp #$05
	           beq .lab_06
.lab_05            lda #$03
                   jmp .error
.lab_06            inc t_cnt
	           lda t_cnt
	           inc io_base+io_gpio_0
                   lda #$c4
	           cmp #$e4
                   bne .lab_07
                   lda #$04
                   jmp .error
.lab_07            cmp #$C4 
                   bne .lab_08
                   jmp .lab_085
.lab_08            lda #$05
                   jmp .error
.lab_085           inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
                   ldx #$42
                   cpx #$32	
                   beq  .lab_09
                   cpx #$42
                   beq .lab_10
.lab_09            lda #$06
                   jmp .error
.lab_10            inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
                   ldy #$C3
                   cpy #$D3
                   beq .lab_11
                   cpy #$C3
                   beq  .lab_12
.lab_11            lda #$07
                   jmp  .error
.lab_12            inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
                   ldx #$00
                   dex
	           cpx #$FF
	           beq .lab_13
                   lda #$08 
                   jmp .error
.lab_13            inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
                   ldy #$00
                   dey
                   cpy #$FF
                   beq .lab_14
                   lda #$09
                   jmp .error
.lab_14            inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
                   ldx #$0F
                   inx
                   cpx #$10
                   beq  .lab_15 
                   lda #$10
                   jmp .error
.lab_15            inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
                   ldy #$7F
                   iny
                   cpy #$80
                   beq  .lab_16
                   lda #$11
                   jmp .error
.lab_16            inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
                   lda #$ED
                   jsr  .lab_165
                   cmp #$42
                   beq  .lab_17
                   lda #$12
                   jmp .error
.lab_165           lda #$42
                   rts
.lab_17            inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
                   lda #$35
                   tax
                   cpx #$35
                   beq .lab_18
                   lda #$12
                   jmp .error
.lab_18            inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
                   lda #$76
                   tay
                   cpy #$76
                   beq  .lab_19
                   lda #$13
                   jmp .error
.lab_19            inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
                   ldx #$52
	           txa
                   cmp #$52
                   beq  .lab_20
                   lda #$14
                   jmp .error
.lab_20            inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
                   ldy #$52
                   tya
                   cmp #$52
                   beq  .lab_21
                   lda #$15
                   jmp .error
.lab_21            inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
                   clc
                   lda #$23
                   adc #$45
                   cmp #$68
                   beq  .lab_22
                   lda #$16
                   jmp .error
.lab_22            sec
                   lda #$42
                   adc #$63
                   cmp #$A6
                   beq  .lab_23
                   lda #$17
                   jmp .error
.lab_23            inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
                   lda #$36
                   and #$f0
	           cmp #$30
                   beq  .lab_24
                   lda #$18
                   jmp .error
.lab_24            inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
                   clc
                   lda #$36
                   asl a
                   cmp #$6C
                   beq  .lab_25
                   lda #$19
                   jmp .error
.lab_25            inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
                   lda #$89
                   eor #$96
                   cmp #$1F
                   beq  .lab_26
                   lda #$20
                   jmp .error
.lab_26            inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
                   clc
                   lda #$52
                   lsr a
                   cmp #$29
                   beq  .lab_27
                   lda #$21
                   jmp .error
.lab_27            inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
                   lda #$B6
                   ora #$4D
                   cmp #$FF
                   beq  .lab_28
                   lda #$22
                   jmp .error
.lab_28            inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0 
                   clc
                   lda #$23
                   rol a
                   cmp #$46
                   beq  .lab_29
                   lda #$23
                   jmp .error
.lab_29            sec
                   lda #$42 
                   rol a
                   cmp #$85
                   beq  .lab_30
                   lda #$24
                   jmp .error
.lab_30            inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
                   clc
                   lda #$23
                   ror a
                   cmp #$11
                   beq  .lab_31
                   lda #$25
                   jmp .error
.lab_31            sec
                   lda #$42
                   ror a
                   cmp #$A1
                   beq  .lab_32
                   lda #$26
                   jmp .error
.lab_32            inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
                   sec
                   lda #$86
                   sbc #$45
                   cmp #$41
                   beq  .lab_33
                   lda #$27
                   jmp .error
.lab_33            clc
                   lda #$89
                   sbc #$23
                   cmp #$65
                   beq  .lab_34
                   lda #$28
                   jmp .error
.lab_34            inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
                   lda #$42
                   sta $0200
                   lda #$9F
                   sta $0201
                   lda $0200
                   cmp #$42
                   beq  .lab_35 
                   lda #$29
                   jmp .error
.lab_35            lda $0201
                   cmp #$9F
                   beq  .lab_36
                   lda #$30
                   jmp .error
.lab_36            inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
                   lda #$94
                   sta $0201 
                   lda #$41
                   sta $0200  
                   lda #$53
                   clc
                   adc $0200
                   cmp $0201 
                   beq .lab_37
                   lda #$31
                   jmp .error 
.lab_37            lda #$8D
                   sta $0201
                   lda #$98
                   sta $0200 
                   lda #$F4
                   sec
                   adc $0200 
                   cmp $0201
                   beq  .lab_38
                   lda #$32
                   jmp .error
.lab_38            inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
                   ldy #$84
                   sty $0201
                   ldx #$B4
                   stx $0200
                   lda #$86
                   and $0200
                   cmp $0201
                   beq  .lab_39
                   lda #$33
                   jmp .error
.lab_39            inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
                   ldx #$55
                   stx $0200
                   asl $0200
                   lda $0200
                   cmp #$AA
                   beq  .lab_40
                   lda #$34
                   jmp .error
.lab_40            inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
                   lda #$53
                   sta $0200
                   lda #$00
                   ldx #$53
                   cpx $0200
                   beq  .lab_41
                   lda #$35
                   jmp .error
.lab_41            inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
                   lda #$45 
                   sta $0200
                   lda #$00
                   ldy #$45
                   cpy $0200
                   beq  .lab_42
                   lda #$36
                   jmp .error
.lab_42            inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
                   lda #$EF
                   sta $0200
                   dec $0200
                   lda #$EE
                   cmp $0200
                   beq  .lab_43
                   lda #$37
                   jmp .error
.lab_43            lda #$01
                   sta $0200
                   dec $0200
                   beq  .lab_44
                   lda #$38
                   jmp .error
.lab_44            inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
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
.lab_46            inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
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
.lab_47            inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
                   ldy #$B6
                   sty $0201
                   ldx #$B4
                   stx $0200
                   lda #$86
                   ora $0200
                   cmp $0201
                   beq  .lab_48
                   lda #$42
                   jmp .error
.lab_48            inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
                   clc
                   ldx #$AA
                   stx $0200
                   rol $0200
                   bcs .lab_49
                   lda #$43
                   jmp .error
.lab_49            lda $0200
                   cmp #$54
                   beq  .lab_50
                   lda #$44
                   jmp .error
.lab_50            inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
                   clc
                   ldx #$55
                   stx $0200
                   ror $0200
                   bcs .lab_51
                   lda #$45 
                   jmp .error
.lab_51            lda $0200
                   cmp #$2A
                   beq  .lab_52
                   lda #$46
                   jmp .error
.lab_52            inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
                   ldx #$96
                   stx $0200
                   lsr $0200
                   lda $0200
                   cmp #$4B
                   beq  .lab_53
                   lda #$47
                   jmp .error
.lab_53            inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
                   ldx #$42
                   stx $0200
                   ldx #$9F
                   stx $0201
                   ldx $0200
                   cpx #$42
                   beq  .lab_54
                   lda #$48 
                   jmp .error
.lab_54            ldx $0201
                   cpx #$9F
                   beq  .lab_55
                   lda #$49
                   jmp .error
.lab_55            inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
                   ldy #$34
                   sty $0200
                   ldy #$75
                   sty $0201
                   ldy $0200
                   cpy #$34
                   beq  .lab_56
                   lda #$4A
                   jmp .error
.lab_56            ldy $0201
                   cpy #$75
                   beq  .lab_57
                   lda #$4B
                   jmp .error
.lab_57            inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
                   lda #$12
                   sta $0201 
                   lda #$41
                   sta $0200
                   lda #$53
                   sec
                   sbc $0200
                   cmp $0201
                   beq  .lab_58 
                   lda #$4C
                   jmp .error
.lab_58            lda #$5B
                   sta $0201
                   lda #$98
                   sta $0200
                   lda #$F4
                   clc
                   sbc $0200
                   cmp $0201
                   beq  .lab_59
                   lda #$4D
                   jmp .error
.lab_59            inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
                   lda #$42
	           inc t_cnt
                   pha
                   lda #$ED
                   inc t_cnt	
                   pha
                   lda #$BE
	           inc t_cnt
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
.lab_605           inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
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
.lab_615           inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
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
.lab_625           inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
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
.lab_63            inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0 
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
.lab_64            inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
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
.lab_65            inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
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
.lab_66            inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
                   lda #$64
                   sta $00
                   lda #$39
                   clc
                   adc $00 
                   cmp #$9D
                   beq  .lab_67
                   lda #$55
                   jmp .error
.lab_67            inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
                   lda #$95 
                   sta $00
                   lda #$76
                   sta $01
                   lda #$45
                   sta $02
                   ldx #$00
                   lda #$00
                   clc
                   adc  $00,X
                   inx
                   clc
                   adc $00,X
                   inx
	           clc
                   adc $00,X
                   cmp #$50
                   beq  .lab_68
                   lda #$56
                   jmp .error
.lab_68            inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
                   lda #$64
                   sta $00
                   lda #$39
                   and $00
                   cmp #$20
                   beq  .lab_69
                   lda #$57
                   jmp .error
.lab_69            inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
                   lda #$95
                   sta $00
                   lda #$76
                   sta $01
                   lda #$45
                   sta $02
                   ldx #$00
                   lda #$FF
                   and $00,X
                   inx 
                   and $00,X
                   inx
                   and $00,X
                   cmp #$04
                   beq  .lab_70
                   lda #$58
                   jmp .error
.lab_70            inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
                   lda #$97
                   sta $0200
                   lda #$78
                   sta $0201
                   lda #$45
                   sta $0202
                   ldx #$00
                   lda #$97
                   cmp $0200,X
                   bne .lab_71
                   lda #$78
                   inx
                   cmp $0200,X
                   bne .lab_71
                   lda #$45
                   inx
                   cmp $0200,X
                   bne .lab_71
                   jmp .lab_715
.lab_71            lda #$59 
                   jmp .error
.lab_715           inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
                   lda #$97
                   sta $0200
                   lda #$78
                   sta $0201
                   lda #$45
                   sta $0202
                   ldy #$00
                   lda #$97
                   cmp  $0200,Y
                   bne .lab_72
                   lda #$78
                   iny
                   cmp $0200,Y
                   bne .lab_72
                   lda #$45
                   iny
                   cmp $0200,Y
                   bne .lab_72 
                   jmp .lab_725
.lab_72            lda #$5A
                   jmp .error
.lab_725           inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
                   lda #$97
                   sta $0200
                   lda #$78
                   sta $0201
                   lda #$45
                   sta $0202
                   ldx #$00
                   lda #$97 
                   cmp $0200,X
                   bne .lab_73
                   lda #$78
                   inx
                   cmp $0200,X
                   bne .lab_73
                   lda #$45
                   inx 
                   cmp $0200,X
                   bne .lab_73
                   jmp .lab_735
.lab_73            lda #$5B
                   jmp .error
.lab_735           inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
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
.lab_75            inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
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
.lab_77            inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
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
.lab_79            inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
                   nop		; was cli
                   lda #$00
                   sta var_2
                   lda #$01
                   sta var_1
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
.lab_80            lda var_2
                   cmp #$00	; was 1 if int serviced
                   beq  .lab_81
                   lda #$63
                   jmp .error
.lab_81            nop		;   was sei to disable interrupt
                   lda #$00
                   sta var_2
                   lda #$01
                   sta var_1
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
.lab_82            lda var_2
                   cmp #$00
                   beq  .lab_83
                   lda #$63
                   jmp .error
.lab_83            lda #$00
                   sta var_1
                   sta io_base+io_tim0_end
                   inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
                   lda #$00
                   sta var_4
                   lda #$01
                   sta var_3
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
.lab_84            lda var_4
                   cmp #$00	; change to 1 if nmi serviced
                   beq  .lab_85
                   lda #$65
                   jmp .error
.lab_85            lda #$00
                   sta var_3
                   sta io_base+io_tim1_end
                   inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
                   jmp .lab_865
.lab_86            jmp .lab_866
.lab_865           sec
                   bcs .lab_86
                   nop
                   nop
                   nop
                   lda #$66
                   jmp .error
.lab_866           inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
                   sec
                   lda #$34
                   sbc #$75
                   bcc .lab_87
                   lda #$67
                   jmp .error
.lab_87            inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0

	;;  Break test
	;; 
.lab_89            ldx $00 
                   
                   inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
                   lda #$24	; keep int disabled
                   pha
                   plp
                   stx $08     
                   lda #$00
                   sta var_2 
                   lda #$01
                   sta var_1
                   sta var_3
                   ldx #$59
                   nop		; was brk
                   inx
                   lda #$00
                   sta var_1
                   lda var_2
                   cmp #$00	; was 1 if brk taken
                   beq  .lab_92
                   lda #$70
                   jmp .error
	
.lab_92            inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0 
                   lda #$53
                   sta $30
                   lda #$00
                   ldx #$40
                   lda $F0,X
                   cmp #$53
                   beq  .lab_93
                   lda #$73 
                   jmp .error
.lab_93            inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
                   clc
                   lda #$FF
                   adc #$01
                   bcs .lab_94
                   lda #$74
                   jmp .error
.lab_94            inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
                   sec
                   lda #$7F
                   sbc #$7E
                   bvc  .lab_95 
                   lda #$75
                   jmp .error
.lab_95            inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
                   lda #$FF
                   pha
	           plp
                   php
                   pla
                   cmp #$FF
                   beq  .lab_96
                   lda #$76
                   jmp .error
.lab_96            inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0
                   lda #$40 
                   ldx #$00
                   sta $0200,X
                   inx
                   lsr a
                   sta $0200,X
                   inx
                   lsr a
                   sta $0200,X
                   inx 
                   lsr a
                   sta $0200,X
                   inx
                   lsr a
                   sta $0200,X
                   inx
                   lsr a
                   sta $0200,X
                   inx
                   lsr a 
                   sta $0200,X
                   ldx #$00
                   asl $0200,X
                   inx
                   asl $0200,X
                   inx
                   asl $0200,X
                   inx
                   asl $0200,X
                   inx
                   asl $0200,X
                   inx
                   asl $0200,X
                   inx
                   asl $0200,X
                   lda #$00
                   clc
                   cld
                   adc $0200
                   adc $0201
                   adc $0202
                   adc $0203
                   adc $0204
                   adc $0205
                   adc $0206
                   cmp #$FE
                   beq  .lab_97
                   lda #$77
                   jmp  .error 
.lab_97            inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0 
                   ldx #$42
                   ldy #$00
                   stx $0200
                   ldx #$9F
                   stx $0201
                   ldx $0200,Y
                   cpx #$42
                   beq  .lab_98
                   lda #$48
                   jmp .error
.lab_98            ldx $0201,Y
                   cpx #$9F
                   beq  .lab_100
                   lda #$78
                   jmp .error


	;; indirectx test

	
.lab_100           inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0 
                   ldy #$00
                   ldx #$00
                   lda #$00
                   sta c_test
	           sta n_test
	           sta v_test
	           sta z_test
                   sta pointer
	           lda #$c0
	           sta pointer+1
                   clc
.lab_101           adc (pointer,x)
                   bpl .lab_103
                   bne .lab_102
                   inc n_test
                   inc z_test
                   jmp .lab_104
.lab_102           inc n_test
                   jmp .lab_104
.lab_103           bne .lab_104
                   inc z_test	
.lab_104           bcc .lab_105
                   inc c_test
.lab_105           bvc .lab_106	
                   inc v_test 
.lab_106           inc pointer
	           bne .lab_101

	           cmp #$c8
	           bne .error
                   lda c_test
                   cmp #$4d
	           bne .error
	           lda n_test
                   cmp #$8b
	           bne .error
                   lda v_test
                   cmp #$36
	           bne .error
                   lda z_test
                   cmp #$02
	           bne .error





	;; indirecty test

	
.lab_110           inc t_cnt
	           lda t_cnt
                   inc io_base+io_gpio_0 
                   ldy #$00
                   ldx #$00
                   lda #$00
                   sta c_test
	           sta n_test
	           sta v_test
	           sta z_test
                   sta pointer
	           lda #$c0
	           sta pointer+1
                   clc
.lab_111           adc (pointer),y
                   bpl .lab_113
                   bne .lab_112
                   inc n_test
                   inc z_test
                   jmp .lab_114
.lab_112           inc n_test
                   jmp .lab_114
.lab_113           bne .lab_114
                   inc z_test	
.lab_114           bcc .lab_115
                   inc c_test
.lab_115           bvc .lab_116	
                   inc v_test 
.lab_116           iny
	           bne .lab_111

	           cmp #$c8
	           bne .error
                   lda c_test
                   cmp #$4d
	           bne .error
	           lda n_test
                   cmp #$8b
	           bne .error
                   lda v_test
                   cmp #$36
	           bne .error
                   lda z_test
                   cmp #$02
	           bne .error
	









	





	

	;;  pass end loop
.good              sei
                   lda #$FF
                   sta io_base+io_gpio_0 
                   lda #$FF
	           sta io_base+io_gpio_1
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
                   lda var_1
                   cmp #$00 
                   bne .nmi_001
                   lda #$E0
                   jmp .error
.nmi_001           sta io_base+io_tim0_end
                   inc var_2
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
                   lda var_3
                   cmp #$00
                   bne .irq_001
                   lda #$E0
                   jmp .error
.irq_001           sta io_base+io_tim1_end
                   inc var_4
                   inc var_2
                   pla
                   tay
                   pla
                   tax
                   pla
                   rti


 * = $fffa  ; vectors


	
     dw .nmi_vec	       ;
     dw .start	               ;
     dw .irq_vec	       ;


	


 code
    





