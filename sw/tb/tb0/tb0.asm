;***********************************************************************
; MICROCOSM ASSOCIATES  8080/8085 CPU DIAGNOSTIC VERSION 1.0  (C) 1980
;***********************************************************************
;
;DONATED TO THE "SIG/M" CP/M USER'S GROUP BY:
;KELLY SMITH, MICROCOSM ASSOCIATES
;3055 WACO AVENUE
;SIMI VALLEY, CALIFORNIA, 93065
;(805) 527-9321 (MODEM, CP/M-NET (TM))
;(805) 527-0518 (VERBAL)
;
;***********************************************************************
; Modified 2001/02/28 by Richard Cini for use in the Altair32 Emulator
;       Project
;
; Need to somehow connect this code to Windows so that failure messages
;       can be posted to Windows. Maybe just store error code in
;       Mem[0xffff]. Maybe trap NOP in the emulator code?
;
;***********************************************************************
; Modified 2006/11/16 by Scott Moore to work on CPU8080 FPGA core
;
;***********************************************************************
; Modified 2007/09/24 by Jose Ruiz for use in light8080 FPGA core
;
; 1.- Changed formatting for compatibility to CP/M's ASM
; 2.- Commented out all Altair / MITS hardware related stuff
; 3.- Set origin at 0H
; 
; Modified again in 2008 to make it compatible with TASM assembler.
;
; Modified 2012/02/12 to add a few CY checks.
; Flags go almost completely unchecked in this test.
;***********************************************************************

; DS pseudo-directive; reserve space in bytes, without initializing it
; (TASM does not have a DS directive)
#define ds(n)    \.org $+n

;
; Select controller defines
; 
;selmain: equ    00H             ; offset of main control register
;sel1msk: equ    02H             ; offset of select 1 mask
;sel1cmp: equ    03H             ; offset of select 1 compare
;sel2msk: equ    04H             ; offset of select 1 mask
;sel2cmp: equ    05H             ; offset of select 1 compare
;sel3msk: equ    06H             ; offset of select 1 mask
;sel3cmp: equ    07H             ; offset of select 1 compare
;sel4msk: equ    08H             ; offset of select 1 mask
;sel4cmp: equ    09H             ; offset of select 1 compare
;
; bits
;
;selenb:  equ    01H             ; enable select
;selio:   equ    02H             ; I/O address or memory

;
; Note: select 1 is ROM, 2, is RAM, 3 is interrupt controller, 4 is serial I/O.
;

;
; Where to place ROM and RAM for this test
;
;rombas: equ     0000H
;rambas: equ     rombas+4*1024
;
; Interrupt controller defines
;
;intbas: equ     10H
;intmsk: equ     intbas+00H      ; mask
;intsts: equ     intbas+01H      ; status
;intact: equ     intbas+02H      ; active interrupt
;intpol: equ     intbas+03H      ; polarity select
;intedg: equ     intbas+04H      ; edge/level select
;intvec: equ     intbas+05H      ; vector base page      
;
; Mits Serial I/O card
;
;siobas: equ     20H
;sioctl: equ     siobas+00H      ; control register
;siodat: equ     siobas+01H      ; data

;
; Set up selectors
;

;
; ROM
;
;        mvi     a,rombas shr 8  ; enable select 1 to 4kb at base
;        out     sel1cmp
;        mvi     a,(0f000H shr 8) or selenb
;        out     sel1msk
;
; RAM
;
;        mvi     a,rambas shr 8  ; enable select 2 to 1kb at base
;        out     sel2cmp
;        mvi     a,(0fc00H shr 8) or selenb
;        out     sel2msk
;
; ROM and RAM set up, exit bootstrap mode
;
;        mvi     a,00H           ; exit bootstrap mode 
;        out     selmain
;
; Serial I/O
;
;        mvi     a,siobas        ; enable serial controller for 4 addresses
;        out     sel4cmp
;        mvi     a,0fcH or selio or selenb
;        out     sel4msk

;************************************************************
;                8080/8085 CPU TEST/DIAGNOSTIC
;************************************************************
;
;note: (1) program assumes "call",and "lxi sp" instructions work;
;
;      (2) instructions not tested are "hlt","di","ei",
;          and "rst 0" thru "rst 7"
;
;
;
;test jump instructions and flags
;
        .org    0H

cpu:    lxi     sp,stack ;set the stack pointer
        mvi     a,077H  ;@ initialize A to remove X values from simulation
        ani     0       ;initialize a reg. and clear all flags
        jz      j010    ;test "jz"
        call    cpuer
j010:   jnc     j020    ;test "jnc"
        call    cpuer
j020:   jpe     j030    ;test "jpe"
        call    cpuer
j030:   jp      j040    ;test "jp"
        call    cpuer
j040:   jnz     j050    ;test "jnz"
        jc      j050    ;test "jc"
        jpo     j050    ;test "jpo"
        jm      j050    ;test "jm"
        jmp     j060    ;test "jmp" (it's a little late,but what the hell;
j050:   call    cpuer
j060:   adi     6       ;a=6,c=0,p=1,s=0,z=0
        jnz     j070    ;test "jnz"
        call    cpuer
j070:   jc      j080    ;test "jc"
        jpo     j080    ;test "jpo"
        jp      j090    ;test "jp"
j080:   call    cpuer
j090:   adi     70H     ;a=76h,c=0,p=0,s=0,z=0
        jpo     j100    ;test "jpo"
        call    cpuer
j100:   jm      j110    ;test "jm"
        jz      j110    ;test "jz"
        jnc     j120    ;test "jnc"
j110:   call    cpuer
j120:   adi     81H     ;a=f7h,c=0,p=0,s=1,z=0
        jm      j130    ;test "jm"
        call    cpuer
j130:   jz      j140    ;test "jz"
        jc      j140    ;test "jc"
        jpo     j150    ;test "jpo"
j140:   call    cpuer
j150:   adi     0feH    ;a=f5h,c=1,p=1,s=1,z=0
        jc      j160    ;test "jc"
        call    cpuer
j160:   jz      j170    ;test "jz"
        jpo     j170    ;test "jpo"
        jm      aimm    ;test "jm"
j170:   call    cpuer
;
;
;
;test accumulator immediate instructions
;
aimm:   cpi     0       ;a=f5h,c=0,z=0
        jc      cpie    ;test "cpi" for re-set carry
        jz      cpie    ;test "cpi" for re-set zero
        cpi     0f5H    ;a=f5h,c=0,z=1
        jc      cpie    ;test "cpi" for re-set carry ("adi")
        jnz     cpie    ;test "cpi" for re-set zero
        cpi     0ffH    ;a=f5h,c=1,z=0
        jz      cpie    ;test "cpi" for re-set zero
        jc      acii    ;test "cpi" for set carry
cpie:   call    cpuer
acii:   aci     00aH    ;a=f5h+0ah+carry(1)=0,c=1
        aci     00aH    ;a=0+0ah+carry(0)=0bh,c=0
        cpi     00bH
        jz      suii    ;test "aci"
        call    cpuer
suii:   sui     00cH    ;a=ffh,c=0
        sui     00fH    ;a=f0h,c=1
        cpi     0f0H
        jz      sbii    ;test "sui"
        call    cpuer
sbii:   sbi     0f1H    ;a=f0h-0f1h-carry(0)=ffh,c=1
        sbi     0eH    ;a=ffh-oeh-carry(1)=f0h,c=0
        cpi     0f0H
        jz      anii    ;test "sbi"
        call    cpuer
anii:   ani     055H    ;a=f0h<and>55h=50h,c=0,p=1,s=0,z=0
        cc      cpuer
        cz      cpuer
        cpi     050H
        jz      orii    ;test "ani"
        call    cpuer
orii:   ori     03aH    ;a=50h<or>3ah=7ah,c=0,p=0,s=0,z=0
        cc      cpuer
        cz      cpuer
        cpi     07aH
        jz      xrii    ;test "ori"
        call    cpuer
xrii:   xri     00fH    ;a=7ah<xor>0fh=75h,c=0,p=0,s=0,z=0
        cc      cpuer
        cz      cpuer
        cpi     075H
        jz      c010    ;test "xri"
        call    cpuer
;
;
;
;test calls and returns
;
c010:   ani     0H      ;a=0,c=0,p=1,s=0,z=1
        cc      cpuer   ;test "cc"
        cpo     cpuer   ;test "cpo"
        cm      cpuer   ;test "cm"
        cnz     cpuer   ;test "cnz"
        cpi     0H
        jz      c020    ;a=0,c=0,p=0,s=0,z=1
        call    cpuer
c020:   sui     077H    ;a=89h,c=1,p=0,s=1,z=0
        cnc     cpuer   ;test "cnc"
        cpe     cpuer   ;test "cpe"
        cp      cpuer   ;test "cp"
        cz      cpuer   ;test "cz"
        cpi     089H
        jz      c030    ;test for "calls" taking branch
        call    cpuer
c030:   ani     0ffH    ;set flags back;
        cpo     cpoi    ;test "cpo"
        cpi     0d9H
        jz      movi    ;test "call" sequence success
        call    cpuer
cpoi:   rpe             ;test "rpe"
        adi     010H    ;a=99h,c=0,p=0,s=1,z=0
        cpe     cpei    ;test "cpe"
        adi     002H    ;a=d9h,c=0,p=0,s=1,z=0
        rpo             ;test "rpo"
        call    cpuer
cpei:   rpo             ;test "rpo"
        adi     020H    ;a=b9h,c=0,p=0,s=1,z=0
        cm      cmi     ;test "cm"
        adi     004H    ;a=d7h,c=0,p=1,s=1,z=0
        rpe             ;test "rpe"
        call    cpuer
cmi:    rp              ;test "rp"
        adi     080H    ;a=39h,c=1,p=1,s=0,z=0
        cp      tcpi    ;test "cp"
        adi     080H    ;a=d3h,c=0,p=0,s=1,z=0
        rm              ;test "rm"
        call    cpuer
tcpi:   rm              ;test "rm"
        adi     040H    ;a=79h,c=0,p=0,s=0,z=0
        cnc     cnci    ;test "cnc"
        adi     040H    ;a=53h,c=0,p=1,s=0,z=0
        rp              ;test "rp"
        call    cpuer
cnci:   rc              ;test "rc"
        adi     08fH    ;a=08h,c=1,p=0,s=0,z=0
        cc      cci     ;test "cc"
        sui     002H    ;a=13h,c=0,p=0,s=0,z=0
        rnc             ;test "rnc"
        call    cpuer
cci:    rnc             ;test "rnc"
        adi     0f7H    ;a=ffh,c=0,p=1,s=1,z=0
        cnz     cnzi    ;test "cnz"
        adi     0feH    ;a=15h,c=1,p=0,s=0,z=0
        rc              ;test "rc"
        call    cpuer
cnzi:   rz              ;test "rz"
        adi     001H    ;a=00h,c=1,p=1,s=0,z=1
        cz      czi     ;test "cz"
        adi     0d0H    ;a=17h,c=1,p=1,s=0,z=0
        rnz             ;test "rnz"
        call    cpuer
czi:    rnz             ;test "rnz"
        adi     047H    ;a=47h,c=0,p=1,s=0,z=0
        cpi     047H    ;a=47h,c=0,p=1,s=0,z=1
        rz              ;test "rz"
        call    cpuer
;
;
;
;test "mov","inr",and "dcr" instructions
;
movi:   mvi     a,077H
        inr     a
        mov     b,a
        inr     b
        mov     c,b
        dcr     c
        mov     d,c
        mov     e,d
        mov     h,e
        mov     l,h
        mov     a,l     ;test "mov" a,l,h,e,d,c,b,a
        dcr     a
        mov     c,a
        mov     e,c
        mov     l,e
        mov     b,l
        mov     d,b
        mov     h,d
        mov     a,h     ;test "mov" a,h,d,b,l,e,c,a
        mov     d,a
        inr     d
        mov     l,d
        mov     c,l
        inr     c
        mov     h,c
        mov     b,h
        dcr     b
        mov     e,b
        mov     a,e     ;test "mov" a,e,b,h,c,l,d,a
        mov     e,a
        inr     e
        mov     b,e
        mov     h,b
        inr     h
        mov     c,h
        mov     l,c
        mov     d,l
        dcr     d
        mov     a,d     ;test "mov" a,d,l,c,h,b,e,a
        mov     h,a
        dcr     h
        mov     d,h
        mov     b,d
        mov     l,b
        inr     l
        mov     e,l
        dcr     e
        mov     c,e
        mov     a,c     ;test "mov" a,c,e,l,b,d,h,a
        mov     l,a
        dcr     l
        mov     h,l
        mov     e,h
        mov     d,e
        mov     c,d
        mov     b,c
        mov     a,b
        cpi     077H
        cnz     cpuer   ;test "mov" a,b,c,d,e,h,l,a
;
;
;
;test arithmetic and logic instructions
;
        xra     a
        mvi     b,001H
        mvi     c,003H
        mvi     d,007H
        mvi     e,00fH
        mvi     h,01fH
        mvi     l,03fH
        add     b
        add     c
        add     d
        add     e
        add     h
        add     l
        add     a
        cpi     0f0H
        cnz     cpuer   ;test "add" b,c,d,e,h,l,a
        sub     b
        sub     c
        sub     d
        sub     e
        sub     h
        sub     l
        cpi     078H
        cnz     cpuer   ;test "sub" b,c,d,e,h,l
        sub     a
        cnz     cpuer   ;test "sub" a
        mvi     a,080H
        add     a
        mvi     b,001H
        mvi     c,002H
        mvi     d,003H
        mvi     e,004H
        mvi     h,005H
        mvi     l,006H
        adc     b
        mvi     b,080H
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
        cpi     037H
        cnz     cpuer   ;test "adc" b,c,d,e,h,l,a
        mvi     a,080H
        add     a
        mvi     b,001H
        sbb     b
        mvi     b,0ffH
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
        cpi     0e0H
        cnz     cpuer   ;test "sbb" b,c,d,e,h,l
        mvi     a,080H
        add     a
        sbb     a
        cpi     0ffH
        cnz     cpuer   ;test "sbb" a
        mvi     a,0ffH
        mvi     b,0feH
        mvi     c,0fcH
        mvi     d,0efH
        mvi     e,07fH
        mvi     h,0f4H
        mvi     l,0bfH
        stc
        ana     a
        cc      cpuer 
        ana     c
        ana     d
        ana     e
        ana     h
        ana     l
        ana     a
        cpi     024H
        cnz     cpuer   ;test "ana" b,c,d,e,h,l,a
        xra     a
        mvi     b,001H
        mvi     c,002H
        mvi     d,004H
        mvi     e,008H
        mvi     h,010H
        mvi     l,020H
        stc
        ora     b
        cc      cpuer
        ora     c
        ora     d
        ora     e
        ora     h
        ora     l
        ora     a
        cpi     03fH
        cnz     cpuer   ;test "ora" b,c,d,e,h,l,a
        mvi     a,0H
        mvi     h,08fH
        mvi     l,04fH
        stc
        xra     b
        cc      cpuer
        xra     c
        xra     d
        xra     e
        xra     h
        xra     l
        cpi     0cfH
        cnz     cpuer   ;test "xra" b,c,d,e,h,l
        xra     a
        cnz     cpuer   ;test "xra" a
        mvi     b,044H
        mvi     c,045H
        mvi     d,046H
        mvi     e,047H
        mvi     h,temp0 / 0ffH        ;high byte of test memory location
        mvi     l,temp0 & 0ffH        ;low byte of test memory location
        mov     m,b
        mvi     b,0H
        mov     b,m
        mvi     a,044H
        cmp     b
        cnz     cpuer   ;test "mov" m,b and b,m
        mov     m,d
        mvi     d,0H
        mov     d,m
        mvi     a,046H
        cmp     d
        cnz     cpuer   ;test "mov" m,d and d,m
        mov     m,e
        mvi     e,0H
        mov     e,m
        mvi     a,047H
        cmp     e
        cnz     cpuer   ;test "mov" m,e and e,m
        mov     m,h
        mvi     h,temp0 / 0ffH
        mvi     l,temp0 & 0ffH
        mov     h,m
        mvi     a,temp0 / 0ffH
        cmp     h
        cnz     cpuer   ;test "mov" m,h and h,m
        mov     m,l
        mvi     h,temp0 / 0ffH
        mvi     l,temp0 & 0ffH
        mov     l,m
        mvi     a,temp0 & 0ffH
        cmp     l
        cnz     cpuer   ;test "mov" m,l and l,m
        mvi     h,temp0 / 0ffH
        mvi     l,temp0 & 0ffH
        mvi     a,032H
        mov     m,a
        cmp     m
        cnz     cpuer   ;test "mov" m,a
        add     m
        cpi     064H
        cnz     cpuer   ;test "add" m
        xra     a
        mov     a,m
        cpi     032H
        cnz     cpuer   ;test "mov" a,m
        mvi     h,temp0 / 0ffH
        mvi     l,temp0 & 0ffH
        mov     a,m
        sub     m
        cnz     cpuer   ;test "sub" m
        mvi     a,080H
        add     a
        adc     m
        cpi     033H
        cnz     cpuer   ;test "adc" m
        mvi     a,080H
        add     a
        sbb     m
        cpi     0cdH
        cnz     cpuer   ;test "sbb" m
        stc
        ana     m
        cc      cpuer
        cnz     cpuer   ;test "ana" m
        mvi     a,025H
        stc
        ora     m
        cc      cpuer
        cpi     37H
        cnz     cpuer   ;test "ora" m
        stc
        xra     m
        cc      cpuer
        cpi     005H
        cnz     cpuer   ;test "xra" m
        mvi     m,055H
        inr     m
        dcr     m
        add     m
        cpi     05aH
        cnz     cpuer   ;test "inr","dcr",and "mvi" m
        lxi     b,12ffH
        lxi     d,12ffH
        lxi     h,12ffH
        inx     b
        inx     d
        inx     h
        mvi     a,013H
        cmp     b
        cnz     cpuer   ;test "lxi" and "inx" b
        cmp     d
        cnz     cpuer   ;test "lxi" and "inx" d
        cmp     h
        cnz     cpuer   ;test "lxi" and "inx" h
        mvi     a,0H
        cmp     c
        cnz     cpuer   ;test "lxi" and "inx" b
        cmp     e
        cnz     cpuer   ;test "lxi" and "inx" d
        cmp     l
        cnz     cpuer   ;test "lxi" and "inx" h
        dcx     b
        dcx     d
        dcx     h
        mvi     a,012H
        cmp     b
        cnz     cpuer   ;test "dcx" b
        cmp     d
        cnz     cpuer   ;test "dcx" d
        cmp     h
        cnz     cpuer   ;test "dcx" h
        mvi     a,0ffH
        cmp     c
        cnz     cpuer   ;test "dcx" b
        cmp     e
        cnz     cpuer   ;test "dcx" d
        cmp     l
        cnz     cpuer   ;test "dcx" h
        sta     temp0
        xra     a
        lda     temp0
        cpi     0ffH
        cnz     cpuer   ;test "lda" and "sta"
        lhld    tempp
        shld    temp0
        lda     tempp
        mov     b,a
        lda     temp0
        cmp     b
        cnz     cpuer   ;test "lhld" and "shld"
        lda     tempp+1
        mov     b,a
        lda     temp0+1
        cmp     b
        cnz     cpuer   ;test "lhld" and "shld"
        mvi     a,0aaH
        sta     temp0
        mov     b,h
        mov     c,l
        xra     a
        ldax    b
        cpi     0aaH
        cnz     cpuer   ;test "ldax" b
        inr     a
        stax    b
        lda     temp0
        cpi     0abH
        cnz     cpuer   ;test "stax" b
        mvi     a,077H
        sta     temp0
        lhld    tempp
        lxi     d,00000H
        xchg
        xra     a
        ldax    d
        cpi     077H
        cnz     cpuer   ;test "ldax" d and "xchg"
        xra     a
        add     h
        add     l
        cnz     cpuer   ;test "xchg"
        mvi     a,0ccH
        stax    d
        lda     temp0
        cpi     0ccH
        stax    d
        lda     temp0
        cpi     0ccH
        cnz     cpuer   ;test "stax" d
        lxi     h,07777H
        dad     h
        mvi     a,0eeH
        cmp     h
        cnz     cpuer   ;test "dad" h
        cmp     l
        cnz     cpuer   ;test "dad" h
        lxi     h,05555H
        lxi     b,0ffffH
        dad     b
        mvi     a,055H
        cnc     cpuer   ;test "dad" b
        cmp     h
        cnz     cpuer   ;test "dad" b
        mvi     a,054H
        cmp     l
        cnz     cpuer   ;test "dad" b
        lxi     h,0aaaaH
        lxi     d,03333H
        dad     d
        mvi     a,0ddH
        cmp     h
        cnz     cpuer   ;test "dad" d
        cmp     l
        cnz     cpuer   ;test "dad" b
        stc
        cnc     cpuer   ;test "stc"
        cmc
        cc      cpuer   ;test "cmc
        mvi     a,0aaH
        cma     
        cpi     055H
        cnz     cpuer   ;test "cma"
        ora     a       ;re-set auxiliary carry
        daa
        cpi     055H
        cnz     cpuer   ;test "daa"
        mvi     a,088H
        add     a
        daa
        cpi     076H
        cnz     cpuer   ;test "daa"
        xra     a
        mvi     a,0aaH
        daa
        cnc     cpuer   ;test "daa"
        cpi     010H
        cnz     cpuer   ;test "daa"
        xra     a
        mvi     a,09aH
        daa
        cnc     cpuer   ;test "daa"
        cnz     cpuer   ;test "daa"
        stc
        mvi     a,042H
        rlc
        cc      cpuer   ;test "rlc" for re-set carry
        rlc
        cnc     cpuer   ;test "rlc" for set carry
        cpi     009H
        cnz     cpuer   ;test "rlc" for rotation
        rrc
        cnc     cpuer   ;test "rrc" for set carry
        rrc
        cpi     042H
        cnz     cpuer   ;test "rrc" for rotation
        ral
        ral
        cnc     cpuer   ;test "ral" for set carry
        cpi     008H
        cnz     cpuer   ;test "ral" for rotation
        rar
        rar
        cc      cpuer   ;test "rar" for re-set carry
        cpi     002H
        cnz     cpuer   ;test "rar" for rotation
        lxi     b,01234H
        lxi     d,0aaaaH
        lxi     h,05555H
        xra     a
        push    b
        push    d
        push    h
        push    psw
        lxi     b,00000H
        lxi     d,00000H
        lxi     h,00000H
        mvi     a,0c0H
        adi     0f0H
        pop     psw
        pop     h
        pop     d
        pop     b
        cc      cpuer   ;test "push psw" and "pop psw"
        cnz     cpuer   ;test "push psw" and "pop psw"
        cpo     cpuer   ;test "push psw" and "pop psw"
        cm      cpuer   ;test "push psw" and "pop psw"
        mvi     a,012H
        cmp     b
        cnz     cpuer   ;test "push b" and "pop b"
        mvi     a,034H
        cmp     c
        cnz     cpuer   ;test "push b" and "pop b"
        mvi     a,0aaH
        cmp     d
        cnz     cpuer   ;test "push d" and "pop d"
        cmp     e
        cnz     cpuer   ;test "push d" and "pop d"
        mvi     a,055H
        cmp     h
        cnz     cpuer   ;test "push h" and "pop h"
        cmp     l
        cnz     cpuer   ;test "push h" and "pop h"
        lxi     h,00000H
        dad     sp
        shld    savstk  ;save the "old" stack-pointer;
        lxi     sp,temp4
        dcx     sp
        dcx     sp
        inx     sp
        dcx     sp
        mvi     a,055H
        sta     temp2
        cma
        sta     temp3
        pop     b
        cmp     b
        cnz     cpuer   ;test "lxi","dad","inx",and "dcx" sp
        cma
        cmp     c
        cnz     cpuer   ;test "lxi","dad","inx", and "dcx" sp
        lxi     h,temp4
        sphl
        lxi     h,07733H
        dcx     sp
        dcx     sp
        xthl
        lda     temp3
        cpi     077H
        cnz     cpuer   ;test "sphl" and "xthl"
        lda     temp2
        cpi     033H
        cnz     cpuer   ;test "sphl" and "xthl"
        mvi     a,055H
        cmp     l
        cnz     cpuer   ;test "sphl" and "xthl"
        cma
        cmp     h
        cnz     cpuer   ;test "sphl" and "xthl"
        lhld    savstk  ;restore the "old" stack-pointer
        sphl
        lxi     h,cpuok
        pchl            ;test "pchl"

cpuer:  mvi     a, 0aaH ; set exit code (failure)
        out     20h
        hlt             ; stop here

cpuok:  mvi     a, 55H  ;
        out     20h
        hlt             ; stop here - no trap


;
; Data area in program space
;
tempp:  .dw    temp0   ;pointer used to test "lhld","shld",
                        ; and "ldax" instructions
;
; Data area in variable space
;
temp0:  ds(1)       ;temporary storage for cpu test memory locations
temp1:  ds(1)       ;temporary storage for cpu test memory locations
temp2:  ds(1)       ;temporary storage for cpu test memory locations
temp3:  ds(1)       ;temporary storage for cpu test memory locations
temp4:  ds(1)       ;temporary storage for cpu test memory locations
savstk: ds(2)       ;temporary stack-pointer storage location

        ds(256)     ;de-bug stack pointer storage area
stack:  .dw 0        

        .end
        
