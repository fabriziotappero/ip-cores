
	
 include ../io_module/io_module.asm

	

	
	     * = $f000  ; assemble at $f000
               code

.start             nop
                   lda #$00
                   sta $04
                   sta $05
	           sta $06
                   sta $07
	           lda #$00
	           sta io_base+io_stat
		   lda io_base+io_stat
                   lda #$01
	           sta io_base+io_stat
	           lda io_base+io_stat
                   jmp .lab_00
                   lda #$00
                   jmp .lab_100
.lab_00            lda #$01
	           sta io_base+io_stat
	           lda io_base+io_stat
                   lda #$02
	           sta io_base+io_stat
	           lda io_base+io_stat
                   clc
                   bcc .lab_01
                   lda #$01
                   jmp .lab_100
.lab_01	           lda #$03
	           sta io_base+io_stat
	           lda io_base+io_stat	
                   sec
                   bcc .lab_02
                   jmp .lab_025
.lab_02	           lda #$02
                   jmp .lab_100
.lab_025           lda #$04
	           sta io_base+io_stat
                   lda io_base+io_stat
                   sec
	           bcs .lab_03
	           lda #$01
                   jmp .lab_100

.lab_03	           clc
                   bcs .lab_04
                   jmp .lab_045
.lab_04            lda #$02
                   jmp .lab_100
.lab_045           lda #$05
		   sta io_base+io_stat
                   lda #$05
                   cmp #$04
                   beq .lab_05
                   cmp #$05
	           beq .lab_06
.lab_05            lda #$03
                   jmp .lab_100
.lab_06            lda #$06
	           sta io_base+io_stat
                   lda #$c4
	           cmp #$e4
                   bne .lab_07
                   lda #$04
                   jmp .lab_100
.lab_07            cmp #$C4 
                   bne .lab_08
                   jmp .lab_085
.lab_08            lda #$05
                   jmp .lab_100
.lab_085           lda #$07
                   sta io_base+io_stat
                   ldx #$42
                   cpx #$32	
                   beq  .lab_09
                   cpx #$42
                   beq .lab_10
.lab_09            lda #$06
                   jmp .lab_100
.lab_10            lda #$08 
                   sta io_base+io_stat
                   ldy #$C3
                   cpy #$D3
                   beq .lab_11
                   cpy #$C3
                   beq  .lab_12
.lab_11            lda #$07
                   jmp  .lab_100
.lab_12            lda #$09
                   sta io_base+io_stat
                   ldx #$00
                   dex
	           cpx #$FF
	           beq .lab_13
                   lda #$08 
                   jmp .lab_100
.lab_13            lda #$0A
                   sta io_base+io_stat
                   ldy #$00
                   dey
                   cpy #$FF
                   beq .lab_14
                   lda #$09
                   jmp .lab_100
.lab_14            lda #$0B
                   sta io_base+io_stat
                   ldx #$0F
                   inx
                   cpx #$10
                   beq  .lab_15 
                   lda #$10
                   jmp .lab_100
.lab_15            lda #$0C
                   sta io_base+io_stat
                   ldy #$7F
                   iny
                   cpy #$80
                   beq  .lab_16
                   lda #$11
                   jmp .lab_100
.lab_16            lda #$0D
                   sta io_base+io_stat
                   lda #$ED
                   jsr  .lab_165
                   cmp #$42
                   beq  .lab_17
                   lda #$12
                   jmp .lab_100
.lab_165           lda #$42
                   rts
.lab_17            lda #$0E
                   sta io_base+io_stat
                   lda #$35
                   tax
                   cpx #$35
                   beq .lab_18
                   lda #$12
                   jmp .lab_100
.lab_18            lda #$0F
                   sta io_base+io_stat
                   lda #$76
                   tay
                   cpy #$76
                   beq  .lab_19
                   lda #$13
                   jmp .lab_100
.lab_19            lda #$10 
                   sta io_base+io_stat
                   ldx #$52
	           txa
                   cmp #$52
                   beq  .lab_20
                   lda #$14
                   jmp .lab_100
.lab_20            lda #$11
                   sta io_base+io_stat
                   ldy #$52
                   tya
                   cmp #$52
                   beq  .lab_21
                   lda #$15
                   jmp .lab_100
.lab_21            lda #$12
                   sta io_base+io_stat
                   clc
                   lda #$23
                   adc #$45
                   cmp #$68
                   beq  .lab_22
                   lda #$16
                   jmp .lab_100
.lab_22            sec
                   lda #$42
                   adc #$63
                   cmp #$A6
                   beq  .lab_23
                   lda #$17
                   jmp .lab_100
.lab_23            lda #$13
                   sta io_base+io_stat
                   lda #$36
                   and #$f0
	           cmp #$30
                   beq  .lab_24
                   lda #$18
                   jmp .lab_100
.lab_24            lda #$14
                   sta io_base+io_stat
                   clc
                   lda #$36
                   asl a
                   cmp #$6C
                   beq  .lab_25
                   lda #$19
                   jmp .lab_100
.lab_25            lda #$15
                   sta io_base+io_stat
                   lda #$89
                   eor #$96
                   cmp #$1F
                   beq  .lab_26
                   lda #$20
                   jmp .lab_100
.lab_26            lda #$16
                   sta io_base+io_stat
                   clc
                   lda #$52
                   lsr a
                   cmp #$29
                   beq  .lab_27
                   lda #$21
                   jmp .lab_100
.lab_27            lda #$17
                   sta io_base+io_stat
                   lda #$B6
                   ora #$4D
                   cmp #$FF
                   beq  .lab_28
                   lda #$22
                   jmp .lab_100
.lab_28            lda #$18
                   sta io_base+io_stat 
                   clc
                   lda #$23
                   rol a
                   cmp #$46
                   beq  .lab_29
                   lda #$23
                   jmp .lab_100
.lab_29            sec
                   lda #$42 
                   rol a
                   cmp #$85
                   beq  .lab_30
                   lda #$24
                   jmp .lab_100
.lab_30            lda #$19
                   sta io_base+io_stat
                   clc
                   lda #$23
                   ror a
                   cmp #$11
                   beq  .lab_31
                   lda #$25
                   jmp .lab_100
.lab_31            sec
                   lda #$42
                   ror a
                   cmp #$A1
                   beq  .lab_32
                   lda #$26
                   jmp .lab_100
.lab_32            lda #$20
                   sta io_base+io_stat
                   sec
                   lda #$86
                   sbc #$45
                   cmp #$41
                   beq  .lab_33
                   lda #$27
                   jmp .lab_100
.lab_33            clc
                   lda #$89
                   sbc #$23
                   cmp #$65
                   beq  .lab_34
                   lda #$28
                   jmp .lab_100
.lab_34            lda #$21
                   sta io_base+io_stat
                   lda #$42
                   sta $0200
                   lda #$9F
                   sta $0201
                   lda $0200
                   cmp #$42
                   beq  .lab_35 
                   lda #$29
                   jmp .lab_100
.lab_35            lda $0201
                   cmp #$9F
                   beq  .lab_36
                   lda #$30
                   jmp .lab_100
.lab_36            lda #$22
                   sta io_base+io_stat
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
                   jmp .lab_100 
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
                   jmp .lab_100
.lab_38            lda #$23
                   sta io_base+io_stat
                   ldy #$84
                   sty $0201
                   ldx #$B4
                   stx $0200
                   lda #$86
                   and $0200
                   cmp $0201
                   beq  .lab_39
                   lda #$33
                   jmp .lab_100
.lab_39            lda #$24
                   sta io_base+io_stat
                   ldx #$55
                   stx $0200
                   asl $0200
                   lda $0200
                   cmp #$AA
                   beq  .lab_40
                   lda #$34
                   jmp .lab_100
.lab_40            lda #$25
                   sta io_base+io_stat
                   lda #$53
                   sta $0200
                   lda #$00
                   ldx #$53
                   cpx $0200
                   beq  .lab_41
                   lda #$35
                   jmp .lab_100
.lab_41            lda #$26
                   sta io_base+io_stat
                   lda #$45 
                   sta $0200
                   lda #$00
                   ldy #$45
                   cpy $0200
                   beq  .lab_42
                   lda #$36
                   jmp .lab_100
.lab_42            lda #$27
                   sta io_base+io_stat
                   lda #$EF
                   sta $0200
                   dec $0200
                   lda #$EE
                   cmp $0200
                   beq  .lab_43
                   lda #$37
                   jmp .lab_100
.lab_43            lda #$01
                   sta $0200
                   dec $0200
                   beq  .lab_44
                   lda #$38
                   jmp .lab_100
.lab_44            lda #$28
                   sta io_base+io_stat
                   lda #$EF
                   sta $0200
                   inc $0200
                   lda #$F0
                   cmp $0200
                   beq  .lab_45
                   lda #$39
                   jmp .lab_100
.lab_45            lda #$FF
                   sta $0200
                   inc $0200
                   beq  .lab_46
                   lda #$40
                   jmp .lab_100
.lab_46            lda #$29
                   sta io_base+io_stat
                   ldy #$32
                   sty $0201
                   ldx #$B4
                   stx $0200
                   lda #$86
                   eor $0200
                   cmp $0201
                   beq  .lab_47
                   lda #$41
                   jmp .lab_100
.lab_47            lda #$2A
                   sta io_base+io_stat
                   ldy #$B6
                   sty $0201
                   ldx #$B4
                   stx $0200
                   lda #$86
                   ora $0200
                   cmp $0201
                   beq  .lab_48
                   lda #$42
                   jmp .lab_100
.lab_48            lda #$2B
                   sta io_base+io_stat
                   clc
                   ldx #$AA
                   stx $0200
                   rol $0200
                   bcs .lab_49
                   lda #$43
                   jmp .lab_100
.lab_49            lda $0200
                   cmp #$54
                   beq  .lab_50
                   lda #$44
                   jmp .lab_100
.lab_50            lda #$2C
                   sta io_base+io_stat
                   clc
                   ldx #$55
                   stx $0200
                   ror $0200
                   bcs .lab_51
                   lda #$45 
                   jmp .lab_100
.lab_51            lda $0200
                   cmp #$2A
                   beq  .lab_52
                   lda #$46
                   jmp .lab_100
.lab_52            lda #$2D
                   sta io_base+io_stat
                   ldx #$96
                   stx $0200
                   lsr $0200
                   lda $0200
                   cmp #$4B
                   beq  .lab_53
                   lda #$47
                   jmp .lab_100
.lab_53            lda #$2E
                   sta io_base+io_stat
                   ldx #$42
                   stx $0200
                   ldx #$9F
                   stx $0201
                   ldx $0200
                   cpx #$42
                   beq  .lab_54
                   lda #$48 
                   jmp .lab_100
.lab_54            ldx $0201
                   cpx #$9F
                   beq  .lab_55
                   lda #$49
                   jmp .lab_100
.lab_55            lda #$2F
                   sta io_base+io_stat
                   ldy #$34
                   sty $0200
                   ldy #$75
                   sty $0201
                   ldy $0200
                   cpy #$34
                   beq  .lab_56
                   lda #$4A
                   jmp .lab_100
.lab_56            ldy $0201
                   cpy #$75
                   beq  .lab_57
                   lda #$4B
                   jmp .lab_100
.lab_57            lda #$30
                   sta io_base+io_stat
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
                   jmp .lab_100
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
                   jmp .lab_100
.lab_59            lda #$31
                   sta io_base+io_stat
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
                   jmp .lab_100
.lab_605           lda #$32
                   sta io_base+io_stat
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
                   jmp .lab_100
.lab_615           lda #$33
                   sta io_base+io_stat
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
                   jmp .lab_100
.lab_625           lda #$34
                   sta io_base+io_stat
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
                   jmp .lab_100
.lab_63            lda #$35
                   sta io_base+io_stat 
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
                   jmp .lab_100
.lab_64            lda #$36	
                   sta io_base+io_stat
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
                   jmp .lab_100
.lab_65            lda #$37
                   sta io_base+io_stat
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
                   jmp .lab_100
.lab_66            lda #$38
                   sta io_base+io_stat
                   lda #$64
                   sta $00
                   lda #$39
                   clc
                   adc $00 
                   cmp #$9D
                   beq  .lab_67
                   lda #$55
                   jmp .lab_100
.lab_67            lda #$39
                   sta io_base+io_stat
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
                   jmp .lab_100
.lab_68            lda #$3A
                   sta io_base+io_stat
                   lda #$64
                   sta $00
                   lda #$39
                   and $00
                   cmp #$20
                   beq  .lab_69
                   lda #$57
                   jmp .lab_100
.lab_69            lda #$3B
                   sta io_base+io_stat
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
                   jmp .lab_100
.lab_70            lda #$3C 
                   sta io_base+io_stat
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
                   jmp .lab_100
.lab_715           lda #$3D
                   sta io_base+io_stat
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
                   jmp .lab_100
.lab_725           lda #$3E
                   sta io_base+io_stat
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
                   jmp .lab_100
.lab_735           lda #$3F
                   sta io_base+io_stat
                   lda #$95
                   sta $02
                   lda #$00
                   lda #$95
                   cmp  $02
                   beq  .lab_74
                   lda #$5C 
                   jmp .lab_100
.lab_74            lda #$75
                   sta $02
                   lda #$67
                   cmp  $02
                   bne .lab_75
                   lda #$5D
                   jmp .lab_100
.lab_75            lda #$40
                   sta io_base+io_stat
                   lda #$36
                   sta $02
                   lda #$00
                   ldx #$36
                   cpx $02
                   beq  .lab_76
                   lda #$5E
                   jmp .lab_100
.lab_76            lda #$57
                   sta $02
                   ldx #$39
	           cpx $02 
                   bne .lab_77
                   lda #$5F
                   jmp .lab_100
.lab_77            lda #$41
                   sta io_base+io_stat
                   lda #$75
                   sta $02 
                   lda #$00
                   ldy #$75
                   cpy $02
                   beq  .lab_78
                   lda #$60
                   jmp .lab_100
.lab_78            lda #$43
                   sta $02
                   ldy #$24
                   cpy $02
                   bne .lab_79
                   lda #$61
                   jmp .lab_100
.lab_79            lda #$42
                   sta io_base+io_stat
                   nop		; was cli
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
                   jmp .lab_100
.lab_80            lda $05
                   cmp #$00	; was 1 if int serviced
                   beq  .lab_81
                   lda #$63
                   jmp .lab_100
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
                   jmp .lab_100
.lab_82            lda $05
                   cmp #$00
                   beq  .lab_83
                   lda #$63
                   jmp .lab_100
.lab_83            lda #$00
                   sta $04
                   sta io_base+io_tim0_end
                   lda #$43
                   sta io_base+io_stat
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
                   jmp .lab_100
.lab_84            lda $07
                   cmp #$00	; change to 1 if nmi serviced
                   beq  .lab_85
                   lda #$65
                   jmp .lab_100
.lab_85            lda #$00
                   sta $06
                   sta io_base+io_tim1_end
                   lda #$44
                   sta io_base+io_stat
                   jmp .lab_865
.lab_86            jmp .lab_866
.lab_865           sec
                   bcs .lab_86
                   nop
                   nop
                   nop
                   lda #$66
                   jmp .lab_100
.lab_866           lda #$45 
                   sta io_base+io_stat
                   sec
                   lda #$34
                   sbc #$75
                   bcc .lab_87
                   lda #$67
                   jmp .lab_100
.lab_87            lda #$46
                   sta io_base+io_stat
                   tsx
                   stx $00
                   lda #$42
                   pha
                   lda #$00
                   tsx
                   inx
                   lda $0100,X
                   cmp #$42
                   beq  .lab_88
                   lda #$68
                   jmp .lab_100
.lab_88            lda #$69
                   sta $0112
                   lda #$00
                   ldx #$11
                   txs
                   pla
                   cmp #$69
                   beq  .lab_89
                   lda #$69
                   jmp .lab_100
.lab_89            ldx $00 
                   txs
                   lda #$47
                   sta io_base+io_stat
                   lda #$04	; keep int disabled
                   pha
                   plp
                   stx $08     
                   lda #$00
                   sta $05 
                   lda #$01
                   sta $04
                   ldx #$59
                   nop		; was brk
                   inx
                   lda #$00
                   sta $04
                   lda $05
                   cmp #$00	; was 1 if brk taken
                   beq  .lab_90
                   lda #$70
                   jmp .lab_100
.lab_90            lda $08
                   and #$10
                   bne .lab_91
                   lda #$71
                   jmp .lab_100
.lab_91            cpx  #$59
                   bne  .lab_92	; was beq
                   lda #$72
                   jmp .lab_100
.lab_92            lda #$48
                   sta io_base+io_stat 
                   lda #$53
                   sta $30
                   lda #$00
                   ldx #$40
                   lda $F0,X
                   cmp #$53
                   beq  .lab_93
                   lda #$73 
                   jmp .lab_100
.lab_93            lda #$49
                   sta io_base+io_stat
                   clc
                   lda #$FF
                   adc #$01
                   bcs .lab_94
                   lda #$74
                   jmp .lab_100
.lab_94            lda #$4A
                   sta io_base+io_stat
                   sec
                   lda #$7F
                   sbc #$7E
                   bvc  .lab_95 
                   lda #$75
                   jmp .lab_100
.lab_95            lda #$4B
                   sta io_base+io_stat
                   lda #$FF
                   pha
	           plp
                   php
                   pla
                   cmp #$FF
                   beq  .lab_96
                   lda #$76
                   jmp .lab_100
.lab_96            lda #$4C
                   sta io_base+io_stat
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
                   jmp  .lab_100 
.lab_97            lda #$4D
                   sta io_base+io_stat 
                   ldx #$42
                   ldy #$00
                   stx $0200
                   ldx #$9F
                   stx $0201
                   ldx $0200,Y
                   cpx #$42
                   beq  .lab_98
                   lda #$48
                   jmp .lab_100
.lab_98            ldx $0201,Y
                   cpx #$9F
                   beq  .lab_99
                   lda #$78
                   jmp .lab_100
.lab_99            sei
                   lda #$FF
                   sta io_base+io_stat 
                   lda io_base+io_stat 
                   lda #$F0
	           sta io_base
	           lda io_base
                   jmp .lab_99
.lab_100           sei
                   sta io_base
	           lda io_base
                   jmp .lab_100
.lab_10X           pha
                   txa
                   pha 
                   tya
                   pha
                   tsx
                   inx
                   inx
                   inx
                   inx
                   lda $0100,X
                   sta $08
                   lda $04
                   cmp #$00 
                   bne .lab_101
                   lda #$E0
                   jmp .lab_100
.lab_101           sta io_base+io_tim0_end
                   inc $05
                   pla
                   tay
                   pla
                   tax 
                   pla
                   rti
.lab_10Y           pha
                   txa
                   pha
                   tya
                   pha
                   lda $06
                   cmp #$00
                   bne .lab_102
                   lda #$E0
                   jmp .lab_100
.lab_102           sta io_base+io_tim1_end
                   inc $07
                   pla
                   tay
                   pla
                   tax
                   pla
                   rti
                   jmp .lab_10X
                   jmp .lab_10Y  

     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00,$00,$00,$00,$00,$00;
     db $00;

     dw .lab_10X	       ;
     dw .start		       ;
     dw .lab_10Y	       ;

 code
    





