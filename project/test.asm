!***********************************************************************
! MICROCOSM ASSOCIATES  8080/8085 CPU DIAGNOSTIC VERSION 1.0  (C) 1980
!***********************************************************************
!
!DONATED TO THE "SIG/M" CP/M USER'S GROUP BY:
!KELLY SMITH, MICROCOSM ASSOCIATES
!3055 WACO AVENUE
!SIMI VALLEY, CALIFORNIA, 93065
!(805) 527-9321 (MODEM, CP/M-NET (TM))
!(805) 527-0518 (VERBAL)
!
!***********************************************************************
! Modified 2001/02/28 by Richard Cini for use in the Altair32 Emulator
!       Project
!
! Need to somehow connect this code to Windows so that failure messages
!       can be posted to Windows. Maybe just store error code in
!       Mem[0xffff]. Maybe trap NOP in the emulator code?
!
!***********************************************************************
! Modified 2006/11/16 by Scott Moore to work on CPU8080 FPGA core
!
!***********************************************************************

!
! Select controller defines
! 
selmain: equ    $00             ! offset of main control register
sel1msk: equ    $02             ! offset of select 1 mask
sel1cmp: equ    $03             ! offset of select 1 compare
sel2msk: equ    $04             ! offset of select 1 mask
sel2cmp: equ    $05             ! offset of select 1 compare
sel3msk: equ    $06             ! offset of select 1 mask
sel3cmp: equ    $07             ! offset of select 1 compare
sel4msk: equ    $08             ! offset of select 1 mask
sel4cmp: equ    $09             ! offset of select 1 compare
!
! bits
!
selenb:  equ    $01             ! enable select
selio:   equ    $02             ! I/O address or memory

!
! Note: select 1 is ROM, 2, is RAM, 3 is interrupt controller, 4 is serial I/O.
!

!
! Where to place ROM and RAM for this test
!
rombas: equ     $0000
rambas: equ     rombas+4*1024
!
! Interrupt controller defines
!
intbas: equ     $10
intmsk: equ     intbas+$00      ! mask
intsts: equ     intbas+$01      ! status
intact: equ     intbas+$02      ! active interrupt
intpol: equ     intbas+$03      ! polarity select
intedg: equ     intbas+$04      ! edge/level select
intvec: equ     intbas+$05      ! vector base page      
!
! Mits Serial I/O card
!
siobas: equ     $20
sioctl: equ     siobas+$00      ! control register
siodat: equ     siobas+$01      ! data

!
! Set up selectors
!

!
! ROM
!
        mvi     a,rombas shr 8  ! enable select 1 to 4kb at base
        out     sel1cmp
        mvi     a,($f000 shr 8) or selenb
        out     sel1msk
!
! RAM
!
        mvi     a,rambas shr 8  ! enable select 2 to 1kb at base
        out     sel2cmp
        mvi     a,($fc00 shr 8) or selenb
        out     sel2msk
!
! ROM and RAM set up, exit bootstrap mode
!
        mvi     a,$00           ! exit bootstrap mode 
        out     selmain
!
! Serial I/O
!
        mvi     a,siobas        ! enable serial controller for 4 addresses
        out     sel4cmp
        mvi     a,$fc or selio or selenb
        out     sel4msk

!************************************************************
!                8080/8085 CPU TEST/DIAGNOSTIC
!************************************************************
!
!note: (1) program assumes "call",and "lxi sp" instructions work!
!
!      (2) instructions not tested are "hlt","di","ei",
!          and "rst 0" thru "rst 7"
!
!
!
!test jump instructions and flags
!
cpu:    lxi     sp,stack !set the stack pointer
        ani     0       !initialize a reg. and clear all flags
        jz      j010    !test "jz"
        call    cpuer
j010:   jnc     j020    !test "jnc"
        call    cpuer
j020:   jpe     j030    !test "jpe"
        call    cpuer
j030:   jp      j040    !test "jp"
        call    cpuer
j040:   jnz     j050    !test "jnz"
        jc      j050    !test "jc"
        jpo     j050    !test "jpo"
        jm      j050    !test "jm"
        jmp     j060    !test "jmp" (it's a little late,but what the hell!
j050:   call    cpuer
j060:   adi     6       !a=6,c=0,p=1,s=0,z=0
        jnz     j070    !test "jnz"
        call    cpuer
j070:   jc      j080    !test "jc"
        jpo     j080    !test "jpo"
        jp      j090    !test "jp"
j080:   call    cpuer
j090:   adi     $070    !a=76h,c=0,p=0,s=0,z=0
        jpo     j100    !test "jpo"
        call    cpuer
j100:   jm      j110    !test "jm"
        jz      j110    !test "jz"
        jnc     j120    !test "jnc"
j110:   call    cpuer
j120:   adi     $081    !a=f7h,c=0,p=0,s=1,z=0
        jm      j130    !test "jm"
        call    cpuer
j130:   jz      j140    !test "jz"
        jc      j140    !test "jc"
        jpo     j150    !test "jpo"
j140:   call    cpuer
j150:   adi     $0fe    !a=f5h,c=1,p=1,s=1,z=0
        jc      j160    !test "jc"
        call    cpuer
j160:   jz      j170    !test "jz"
        jpo     j170    !test "jpo"
        jm      aimm    !test "jm"
j170:   call    cpuer
!
!
!
!test accumulator immediate instructions
!
aimm:   cpi     0       !a=f5h,c=0,z=0
        jc      cpie    !test "cpi" for re-set carry
        jz      cpie    !test "cpi" for re-set zero
        cpi     $0f5    !a=f5h,c=0,z=1
        jc      cpie    !test "cpi" for re-set carry ("adi")
        jnz     cpie    !test "cpi" for re-set zero
        cpi     $0ff    !a=f5h,c=1,z=0
        jz      cpie    !test "cpi" for re-set zero
        jc      acii    !test "cpi" for set carry
cpie:   call    cpuer
acii:   aci     $00a    !a=f5h+0ah+carry(1)=0,c=1
        aci     $00a    !a=0+0ah+carry(0)=0bh,c=0
        cpi     $00b
        jz      suii    !test "aci"
        call    cpuer
suii:   sui     $00c    !a=ffh,c=0
        sui     $00f    !a=f0h,c=1
        cpi     $0f0
        jz      sbii    !test "sui"
        call    cpuer
sbii:   sbi     $0f1    !a=f0h-0f1h-carry(0)=ffh,c=1
        sbi     $00e    !a=ffh-oeh-carry(1)=f0h,c=0
        cpi     $0f0
        jz      anii    !test "sbi"
        call    cpuer
anii:   ani     $055    !a=f0h<and>55h=50h,c=0,p=1,s=0,z=0
        cpi     $050
        jz      orii    !test "ani"
        call    cpuer
orii:   ori     $03a    !a=50h<or>3ah=7ah,c=0,p=0,s=0,z=0
        cpi     $07a
        jz      xrii    !test "ori"
        call    cpuer
xrii:   xri     $00f    !a=7ah<xor>0fh=75h,c=0,p=0,s=0,z=0
        cpi     $075
        jz      c010    !test "xri"
        call    cpuer
!
!
!
!test calls and returns
!
c010:   ani     $0      !a=0,c=0,p=1,s=0,z=1
        cc      cpuer   !test "cc"
        cpo     cpuer   !test "cpo"
        cm      cpuer   !test "cm"
        cnz     cpuer   !test "cnz"
        cpi     $0
        jz      c020    !a=0,c=0,p=0,s=0,z=1
        call    cpuer
c020:   sui     $077    !a=89h,c=1,p=0,s=1,z=0
        cnc     cpuer   !test "cnc"
        cpe     cpuer   !test "cpe"
        cp      cpuer   !test "cp"
        cz      cpuer   !test "cz"
        cpi     $089
        jz      c030    !test for "calls" taking branch
        call    cpuer
c030:   ani     $0ff    !set flags back!
        cpo     cpoi    !test "cpo"
        cpi     $0d9
        jz      movi    !test "call" sequence success
        call    cpuer
cpoi:   rpe             !test "rpe"
        adi     $010    !a=99h,c=0,p=0,s=1,z=0
        cpe     cpei    !test "cpe"
        adi     $002    !a=d9h,c=0,p=0,s=1,z=0
        rpo             !test "rpo"
        call    cpuer
cpei:   rpo             !test "rpo"
        adi     $020    !a=b9h,c=0,p=0,s=1,z=0
        cm      cmi     !test "cm"
        adi     $004    !a=d7h,c=0,p=1,s=1,z=0
        rpe             !test "rpe"
        call    cpuer
cmi:    rp              !test "rp"
        adi     $080    !a=39h,c=1,p=1,s=0,z=0
        cp      tcpi    !test "cp"
        adi     $080    !a=d3h,c=0,p=0,s=1,z=0
        rm              !test "rm"
        call    cpuer
tcpi:   rm              !test "rm"
        adi     $040    !a=79h,c=0,p=0,s=0,z=0
        cnc     cnci    !test "cnc"
        adi     $040    !a=53h,c=0,p=1,s=0,z=0
        rp              !test "rp"
        call    cpuer
cnci:   rc              !test "rc"
        adi     $08f    !a=08h,c=1,p=0,s=0,z=0
        cc      cci     !test "cc"
        sui     $002    !a=13h,c=0,p=0,s=0,z=0
        rnc             !test "rnc"
        call    cpuer
cci:    rnc             !test "rnc"
        adi     $0f7    !a=ffh,c=0,p=1,s=1,z=0
        cnz     cnzi    !test "cnz"
        adi     $0fe    !a=15h,c=1,p=0,s=0,z=0
        rc              !test "rc"
        call    cpuer
cnzi:   rz              !test "rz"
        adi     $001    !a=00h,c=1,p=1,s=0,z=1
        cz      czi     !test "cz"
        adi     $0d0    !a=17h,c=1,p=1,s=0,z=0
        rnz             !test "rnz"
        call    cpuer
czi:    rnz             !test "rnz"
        adi     $047    !a=47h,c=0,p=1,s=0,z=0
        cpi     $047    !a=47h,c=0,p=1,s=0,z=1
        rz              !test "rz"
        call    cpuer
!
!
!
!test "mov","inr",and "dcr" instructions
!
movi:   mvi     a,$077
        inr     a
        mov     b,a
        inr     b
        mov     c,b
        dcr     c
        mov     d,c
        mov     e,d
        mov     h,e
        mov     l,h
        mov     a,l     !test "mov" a,l,h,e,d,c,b,a
        dcr     a
        mov     c,a
        mov     e,c
        mov     l,e
        mov     b,l
        mov     d,b
        mov     h,d
        mov     a,h     !test "mov" a,h,d,b,l,e,c,a
        mov     d,a
        inr     d
        mov     l,d
        mov     c,l
        inr     c
        mov     h,c
        mov     b,h
        dcr     b
        mov     e,b
        mov     a,e     !test "mov" a,e,b,h,c,l,d,a
        mov     e,a
        inr     e
        mov     b,e
        mov     h,b
        inr     h
        mov     c,h
        mov     l,c
        mov     d,l
        dcr     d
        mov     a,d     !test "mov" a,d,l,c,h,b,e,a
        mov     h,a
        dcr     h
        mov     d,h
        mov     b,d
        mov     l,b
        inr     l
        mov     e,l
        dcr     e
        mov     c,e
        mov     a,c     !test "mov" a,c,e,l,b,d,h,a
        mov     l,a
        dcr     l
        mov     h,l
        mov     e,h
        mov     d,e
        mov     c,d
        mov     b,c
        mov     a,b
        cpi     $077
        cnz     cpuer   !test "mov" a,b,c,d,e,h,l,a
!
!
!
!test arithmetic and logic instructions
!
        xra     a
        mvi     b,$001
        mvi     c,$003
        mvi     d,$007
        mvi     e,$00f
        mvi     h,$01f
        mvi     l,$03f
        add     b
        add     c
        add     d
        add     e
        add     h
        add     l
        add     a
        cpi     $0f0
        cnz     cpuer   !test "add" b,c,d,e,h,l,a
        sub     b
        sub     c
        sub     d
        sub     e
        sub     h
        sub     l
        cpi     $078
        cnz     cpuer   !test "sub" b,c,d,e,h,l
        sub     a
        cnz     cpuer   !test "sub" a
        mvi     a,$080
        add     a
        mvi     b,$001
        mvi     c,$002
        mvi     d,$003
        mvi     e,$004
        mvi     h,$005
        mvi     l,$006
        adc     b
        mvi     b,$080
        add     b
        add     b
        adc     c
        add     b
        add     b
        adc     d
        add     b
        add     b
        adc     e
        add     b
        add     b
        adc     h
        add     b
        add     b
        adc     l
        add     b
        add     b
        adc     a
        cpi     $037
        cnz     cpuer   !test "adc" b,c,d,e,h,l,a
        mvi     a,$080
        add     a
        mvi     b,$001
        sbb     b
        mvi     b,$0ff
        add     b
        sbb     c
        add     b
        sbb     d
        add     b
        sbb     e
        add     b
        sbb     h
        add     b
        sbb     l
        cpi     $0e0
        cnz     cpuer   !test "sbb" b,c,d,e,h,l
        mvi     a,$080
        add     a
        sbb     a
        cpi     $0ff
        cnz     cpuer   !test "sbb" a
        mvi     a,$0ff
        mvi     b,$0fe
        mvi     c,$0fc
        mvi     d,$0ef
        mvi     e,$07f
        mvi     h,$0f4
        mvi     l,$0bf
        ana     a
        ana     c
        ana     d
        ana     e
        ana     h
        ana     l
        ana     a
        cpi     $024
        cnz     cpuer   !test "ana" b,c,d,e,h,l,a
        xra     a
        mvi     b,$001
        mvi     c,$002
        mvi     d,$004
        mvi     e,$008
        mvi     h,$010
        mvi     l,$020
        ora     b
        ora     c
        ora     d
        ora     e
        ora     h
        ora     l
        ora     a
        cpi     $03f
        cnz     cpuer   !test "ora" b,c,d,e,h,l,a
        mvi     a,$0
        mvi     h,$08f
        mvi     l,$04f
        xra     b
        xra     c
        xra     d
        xra     e
        xra     h
        xra     l
        cpi     $0cf
        cnz     cpuer   !test "xra" b,c,d,e,h,l
        xra     a
        cnz     cpuer   !test "xra" a
        mvi     b,$044
        mvi     c,$045
        mvi     d,$046
        mvi     e,$047
        mvi     h,(temp0 / $0ff)        !high byte of test memory location
        mvi     l,(temp0 and $0ff)      !low byte of test memory location
        mov     m,b
        mvi     b,$0
        mov     b,m
        mvi     a,$044
        cmp     b
        cnz     cpuer   !test "mov" m,b and b,m
        mov     m,d
        mvi     d,$0
        mov     d,m
        mvi     a,$046
        cmp     d
        cnz     cpuer   !test "mov" m,d and d,m
        mov     m,e
        mvi     e,$0
        mov     e,m
        mvi     a,$047
        cmp     e
        cnz     cpuer   !test "mov" m,e and e,m
        mov     m,h
        mvi     h,(temp0 / $0ff)
        mvi     l,(temp0 and $0ff)
        mov     h,m
        mvi     a,(temp0 / $0ff)
        cmp     h
        cnz     cpuer   !test "mov" m,h and h,m
        mov     m,l
        mvi     h,(temp0 / $0ff)
        mvi     l,(temp0 and $0ff)
        mov     l,m
        mvi     a,(temp0 and $0ff)
        cmp     l
        cnz     cpuer   !test "mov" m,l and l,m
        mvi     h,(temp0 / $0ff)
        mvi     l,(temp0 and $0ff)
        mvi     a,$032
        mov     m,a
        cmp     m
        cnz     cpuer   !test "mov" m,a
        add     m
        cpi     $064
        cnz     cpuer   !test "add" m
        xra     a
        mov     a,m
        cpi     $032
        cnz     cpuer   !test "mov" a,m
        mvi     h,(temp0 / $0ff)
        mvi     l,(temp0 and $0ff)
        mov     a,m
        sub     m
        cnz     cpuer   !test "sub" m
        mvi     a,$080
        add     a
        adc     m
        cpi     $033
        cnz     cpuer   !test "adc" m
        mvi     a,$080
        add     a
        sbb     m
        cpi     $0cd
        cnz     cpuer   !test "sbb" m
        ana     m
        cnz     cpuer   !test "ana" m
        mvi     a,$025
        ora     m
        cpi     $37
        cnz     cpuer   !test "ora" m
        xra     m
        cpi     $005
        cnz     cpuer   !test "xra" m
        mvi     m,$055
        inr     m
        dcr     m
        add     m
        cpi     $05a
        cnz     cpuer   !test "inr","dcr",and "mvi" m
        lxi     b,$12ff
        lxi     d,$12ff
        lxi     h,$12ff
        inx     b
        inx     d
        inx     h
        mvi     a,$013
        cmp     b
        cnz     cpuer   !test "lxi" and "inx" b
        cmp     d
        cnz     cpuer   !test "lxi" and "inx" d
        cmp     h
        cnz     cpuer   !test "lxi" and "inx" h
        mvi     a,$0
        cmp     c
        cnz     cpuer   !test "lxi" and "inx" b
        cmp     e
        cnz     cpuer   !test "lxi" and "inx" d
        cmp     l
        cnz     cpuer   !test "lxi" and "inx" h
        dcx     b
        dcx     d
        dcx     h
        mvi     a,$012
        cmp     b
        cnz     cpuer   !test "dcx" b
        cmp     d
        cnz     cpuer   !test "dcx" d
        cmp     h
        cnz     cpuer   !test "dcx" h
        mvi     a,$0ff
        cmp     c
        cnz     cpuer   !test "dcx" b
        cmp     e
        cnz     cpuer   !test "dcx" d
        cmp     l
        cnz     cpuer   !test "dcx" h
        sta     temp0
        xra     a
        lda     temp0
        cpi     $0ff
        cnz     cpuer   !test "lda" and "sta"
        lhld    tempp
        shld    temp0
        lda     tempp
        mov     b,a
        lda     temp0
        cmp     b
        cnz     cpuer   !test "lhld" and "shld"
        lda     tempp+1
        mov     b,a
        lda     temp0+1
        cmp     b
        cnz     cpuer   !test "lhld" and "shld"
        mvi     a,$0aa
        sta     temp0
        mov     b,h
        mov     c,l
        xra     a
        ldax    b
        cpi     $0aa
        cnz     cpuer   !test "ldax" b
        inr     a
        stax    b
        lda     temp0
        cpi     $0ab
        cnz     cpuer   !test "stax" b
        mvi     a,$077
        sta     temp0
        lhld    tempp
        lxi     d,$00000
        xchg
        xra     a
        ldax    d
        cpi     $077
        cnz     cpuer   !test "ldax" d and "xchg"
        xra     a
        add     h
        add     l
        cnz     cpuer   !test "xchg"
        mvi     a,$0cc
        stax    d
        lda     temp0
        cpi     $0cc
        stax    d
        lda     temp0
        cpi     $0cc
        cnz     cpuer   !test "stax" d
        lxi     h,$07777
        dad     h
        mvi     a,$0ee
        cmp     h
        cnz     cpuer   !test "dad" h
        cmp     l
        cnz     cpuer   !test "dad" h
        lxi     h,$05555
        lxi     b,$0ffff
        dad     b
        mvi     a,$055
        cnc     cpuer   !test "dad" b
        cmp     h
        cnz     cpuer   !test "dad" b
        mvi     a,$054
        cmp     l
        cnz     cpuer   !test "dad" b
        lxi     h,$0aaaa
        lxi     d,$03333
        dad     d
        mvi     a,$0dd
        cmp     h
        cnz     cpuer   !test "dad" d
        cmp     l
        cnz     cpuer   !test "dad" b
        stc
        cnc     cpuer   !test "stc"
        cmc
        cc      cpuer   !test "cmc
        mvi     a,$0aa
        cma     
        cpi     $055
        cnz     cpuer   !test "cma"
        ora     a       !re-set auxiliary carry
        daa
        cpi     $055
        cnz     cpuer   !test "daa"
        mvi     a,$088
        add     a
        daa
        cpi     $076
        cnz     cpuer   !test "daa"
        xra     a
        mvi     a,$0aa
        daa
        cnc     cpuer   !test "daa"
        cpi     $010
        cnz     cpuer   !test "daa"
        xra     a
        mvi     a,$09a
        daa
        cnc     cpuer   !test "daa"
        cnz     cpuer   !test "daa"
        stc
        mvi     a,$042
        rlc
        cc      cpuer   !test "rlc" for re-set carry
        rlc
        cnc     cpuer   !test "rlc" for set carry
        cpi     $009
        cnz     cpuer   !test "rlc" for rotation
        rrc
        cnc     cpuer   !test "rrc" for set carry
        rrc
        cpi     $042
        cnz     cpuer   !test "rrc" for rotation
        ral
        ral
        cnc     cpuer   !test "ral" for set carry
        cpi     $008
        cnz     cpuer   !test "ral" for rotation
        rar
        rar
        cc      cpuer   !test "rar" for re-set carry
        cpi     $002
        cnz     cpuer   !test "rar" for rotation
        lxi     b,$01234
        lxi     d,$0aaaa
        lxi     h,$05555
        xra     a
        push    b
        push    d
        push    h
        push    psw
        lxi     b,$00000
        lxi     d,$00000
        lxi     h,$00000
        mvi     a,$0c0
        adi     $0f0
        pop     psw
        pop     h
        pop     d
        pop     b
        cc      cpuer   !test "push psw" and "pop psw"
        cnz     cpuer   !test "push psw" and "pop psw"
        cpo     cpuer   !test "push psw" and "pop psw"
        cm      cpuer   !test "push psw" and "pop psw"
        mvi     a,$012
        cmp     b
        cnz     cpuer   !test "push b" and "pop b"
        mvi     a,$034
        cmp     c
        cnz     cpuer   !test "push b" and "pop b"
        mvi     a,$0aa
        cmp     d
        cnz     cpuer   !test "push d" and "pop d"
        cmp     e
        cnz     cpuer   !test "push d" and "pop d"
        mvi     a,$055
        cmp     h
        cnz     cpuer   !test "push h" and "pop h"
        cmp     l
        cnz     cpuer   !test "push h" and "pop h"
        lxi     h,$00000
        dad     sp
        shld    savstk  !save the "old" stack-pointer!
        lxi     sp,temp4
        dcx     sp
        dcx     sp
        inx     sp
        dcx     sp
        mvi     a,$055
        sta     temp2
        cma
        sta     temp3
        pop     b
        cmp     b
        cnz     cpuer   !test "lxi","dad","inx",and "dcx" sp
        cma
        cmp     c
        cnz     cpuer   !test "lxi","dad","inx", and "dcx" sp
        lxi     h,temp4
        sphl
        lxi     h,$07733
        dcx     sp
        dcx     sp
        xthl
        lda     temp3
        cpi     $077
        cnz     cpuer   !test "sphl" and "xthl"
        lda     temp2
        cpi     $033
        cnz     cpuer   !test "sphl" and "xthl"
        mvi     a,$055
        cmp     l
        cnz     cpuer   !test "sphl" and "xthl"
        cma
        cmp     h
        cnz     cpuer   !test "sphl" and "xthl"
        lhld    savstk  !restore the "old" stack-pointer
        sphl
        lxi     h,cpuok
        pchl            !test "pchl"

cpuer:  mvi     a, $aa  ! set exit code (failure)
        hlt             ! stop here

cpuok:  mvi     a, $55  !
        hlt             ! stop here - no trap


!
! Data area in program space
!
tempp:  defw    temp0   !pointer used to test "lhld","shld",
                        ! and "ldax" instructions
!
! Data area in variable space
!
temp0:  defvs   1       !temporary storage for cpu test memory locations
temp1:  defvs   1       !temporary storage for cpu test memory locations
temp2:  defvs   1       !temporary storage for cpu test memory locations
temp3:  defvs   1       !temporary storage for cpu test memory locations
temp4:  defvs   1       !temporary storage for cpu test memory locations
savstk: defvs   2       !temporary stack-pointer storage location

        defvs   256     !de-bug stack pointer storage area
stack:  defvs           

