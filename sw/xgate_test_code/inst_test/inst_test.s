; 345678901234567890123456789012345678901234567890123456789012345678901234567890
; Instruction set test for xgate RISC processor core
; Bob Hayes - Sept 1 2009
;  Version 0.1 Basic test of all instruction done. Need to improve Condition
;               Code function testing.


        CPU     XGATE

        ORG     $fe00
        DS.W    2       ; reserve two words at channel 0
        ; channel 1
        DC.W    _START  ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 2
        DC.W    _START2 ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 3
        DC.W    _START3 ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 4
        DC.W    _START4 ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 5
        DC.W    _START5 ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 6
        DC.W    _START6 ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 7
        DC.W    _START7 ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 8
        DC.W    _START8 ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 9
        DC.W    _START9 ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 10
        DC.W    _START10        ; point to start address
        DC.W    V_PTR           ; point to initial variables
        ; channel 11
        DC.W    _ERROR          ; point to start address
        DC.W    V_PTR           ; point to initial variables
        ; channel 12
        DC.W    _ERROR          ; point to start address
        DC.W    V_PTR           ; point to initial variables
        ; channel 13
        DC.W    _ERROR          ; point to start address
        DC.W    V_PTR           ; point to initial variables
        ; channel 14
        DC.W    _ERROR          ; point to start address
        DC.W    V_PTR           ; point to initial variables
        ; channel 15
        DC.W    _ERROR          ; point to start address
        DC.W    V_PTR           ; point to initial variables
        ; channel 16
        DC.W    _ERROR  ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 17
        DC.W    _ERROR  ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 18
        DC.W    _ERROR  ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 19
        DC.W    _ERROR  ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 20
        DC.W    _ERROR  ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 21
        DC.W    _ERROR  ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 22
        DC.W    _ERROR  ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 23
        DC.W    _ERROR  ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 24
        DC.W    _ERROR  ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 25
        DC.W    _ERROR  ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 26
        DC.W    _ERROR  ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 27
        DC.W    _ERROR  ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 28
        DC.W    _ERROR  ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 29
        DC.W    _ERROR  ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 30
        DC.W    _ERROR  ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 31
        DC.W    _ERROR  ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 32
        DC.W    _ERROR  ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 33
        DC.W    _ERROR  ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 34
        DC.W    _ERROR  ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 35
        DC.W    _ERROR  ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 36
        DC.W    _ERROR  ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 37
        DC.W    _ERROR  ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 38
        DC.W    _ERROR  ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 39
        DC.W    _ERROR  ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 40
        DC.W    _ERROR  ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 41
        DC.W    _ERROR  ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 42
        DC.W    _ERROR  ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 43
        DC.W    _ERROR  ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 44
        DC.W    _ERROR  ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 45
        DC.W    _ERROR  ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 46
        DC.W    _ERROR  ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 47
        DC.W    _ERROR  ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 48
        DC.W    _ERROR  ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 49
        DC.W    _ERROR  ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 50
        DC.W    _ERROR  ; point to start address
        DC.W    V_PTR   ; point to initial variables

        ORG     $2000 ; with comment

V_PTR   EQU     123

        DC.W    BACK_
        DS.W    8
        DC.B    $56
        DS.B    11

        ALIGN   1

;-------------------------------------------------------------------------------
;   Place where undefined interrupts go
;-------------------------------------------------------------------------------
_ERROR
        LDL     R2,#$04    ; Sent Message to Testbench Error Register
        LDH     R2,#$80
        LDL     R3,#$ff
        STB     R3,(R2,#0)

        SIF
        RTS


;-------------------------------------------------------------------------------
;   Test Shift instructions
;-------------------------------------------------------------------------------
_START
        LDL     R2,#$00    ; Sent Message to Testbench Check Point Register
        LDH     R2,#$80
        LDL     R3,#$01
        STB     R3,(R2,#0)
        STB     R3,(R2,#2) ; Send Message to clear Testbench interrupt register


        ; Test Bit Field Find First One
        LDL     R5,#$01  ; R5=$0001
        LDH     R5,#$4f  ; R5=$4f01
        BFFO    R4,R5    ; Result in R4
        BVS     _FAIL    ; Negative Flag should be clear
        LDL     R6,#$0e  ; First one should have been in bit position 14
        SUB     R0,R6,R4
        BNE     _FAIL
        BFFO    R4,R0    ; Zero Value should set Carry Bit
        BCC     _FAIL
        LDH     R5,#$00  ; R5=$0001
        BFFO    R4,R5
        BCS     _FAIL    ; Carry should be clear
        BVS     _FAIL    ; Overflow Flag should be clear
        SUB     R0,R0,R4 ; R4 Should be zero - ie. zero bit set
        BNE     _FAIL

       ; Test ASR instruction **************************************************
        LDL     R5,#$04  ; R5=$0008
        LDH     R5,#$81  ; R5=$8108
        LDL     R3,#$03
        ASR     R5,R3    ; R5=$f000, Carry flag set
        BCC     _FAIL
        BVS     _FAIL    ; Negative Flag should be clear
        LDL     R4,#$20  ; R4=$0020
        LDH     R4,#$f0  ; R4=$f020
        SUB     R0,R5,R4 ; Compare R5 to R4
        BNE     _FAIL

       ; Test CSL instruction **************************************************
        LDL     R5,#$10  ; R5=$0010
        LDH     R5,#$88  ; R5=$8810
        LDL     R3,#$05
        CSL     R5,R3    ; R5=$081f, Carry flag set
        BCC     _FAIL
        LDL     R4,#$00  ; R4=$0000
        LDH     R4,#$02  ; R4=$0200
        SUB     R0,R5,R4 ; Compare R5 to R4
        BNE     _FAIL

       ;Test CSR instruction ***************************************************
        LDL     R5,#$88  ; R5=$0088
        LDH     R5,#$10  ; R5=$1088
        LDL     R3,#$04
        CSR     R5,R3    ; R5=$0108, Carry flag set
        BCC     _FAIL
        LDL     R4,#$08  ; R4=$0008
        LDH     R4,#$01  ; R4=$0108
        SUB     R0,R5,R4 ; Compare R5 to R4
        BNE     _FAIL

       ;Test LSL instruction ***************************************************
        LDL     R2,#$ff  ; R2=$00ff
        LDH     R2,#$07  ; R2=$07ff
        LDL     R1,#$06
        LSL     R2,R1    ; R2=$ffc0, Carry flag set
        BCC     _FAIL
        LDL     R4,#$c0  ; R4=$0008
        LDH     R4,#$ff  ; R4=$0108
        SUB     R0,R2,R4 ; Compare R2 to R4
        BNE     _FAIL

       ;Test LSR instruction ***************************************************
        LDL     R7,#$02  ; R7=$0002
        LDH     R7,#$c3  ; R7=$c302
        LDL     R6,#$02
        LSR     R7,R6    ; R7=$30c0, Carry flag set
        BCC     _FAIL
        LDL     R4,#$c0  ; R4=$00c0
        LDH     R4,#$30  ; R4=$30c0
        SUB     R0,R7,R4 ; Compare R7 to R4
        BNE     _FAIL

       ;Test ROL instruction ***************************************************
        LDL     R7,#$62  ; R7=$0062
        LDH     R7,#$c3  ; R7=$c362
        LDL     R6,#$04
        ROL     R7,R6    ; R7=$362c
        BVS     _FAIL    ; Overflow Flag should be clear
        LDL     R4,#$2c  ; R4=$002c
        LDH     R4,#$36  ; R4=$362c
        SUB     R0,R7,R4 ; Compare R7 to R4
        BNE     _FAIL

       ;Test ROR instruction ***************************************************
        LDL     R7,#$62  ; R7=$0062
        LDH     R7,#$c3  ; R7=$c362
        LDL     R6,#$08
        ROR     R7,R6    ; R7=$62c3
        BVS     _FAIL    ; Overflow Flag should be clear
        LDL     R4,#$c3  ; R4=$00c3
        LDH     R4,#$62  ; R4=$62c3
        SUB     R0,R7,R4 ; Compare R7 to R4
        BNE     _FAIL

       ; Test ASR instruction **************************************************
        LDL     R5,#$00  ; R5=$0000
        LDH     R5,#$80  ; R5=$8000
        ASR     R5,#0    ; R5=$ffff, Carry flag set
        BCC     _FAIL
        BVS     _FAIL    ; Overflow Flag should be clear
        LDL     R4,#$ff  ; R4=$00ff
        LDH     R4,#$ff  ; R4=$ffff
        SUB     R0,R5,R4 ; Compare R5 to R4
        BNE     _FAIL

       ; Test CSL insrtruction
        LDL     R5,#$01  ; R5=$0001
        LDH     R5,#$0f  ; R5=$0f01
        CSL     R5,#0    ; R5=$0000, Carry flag set
        BCC     _FAIL
        LDL     R4,#$00  ; R4=$0000
        LDH     R4,#$00  ; R4=$0000
        SUB     R0,R5,R4 ; Compare R5 to R4
        BNE     _FAIL

       ;Test CSR instruction ***************************************************
        LDL     R5,#$ff  ; R5=$00ff
        LDH     R5,#$80  ; R5=$80ff
        CSR     R5,#15   ; R5=$0001, Carry flag clear
        BCS     _FAIL
        LDL     R4,#$01  ; R4=$0001
        LDH     R4,#$00  ; R4=$0001
        SUB     R0,R5,R4 ; Compare R5 to R4
        BNE     _FAIL

       ;Test LSL instruction ***************************************************
        LDL     R2,#$1a  ; R2=$001a
        LDH     R2,#$ff  ; R2=$ff1a
        LSL     R2,#12   ; R2=$a000, Carry flag set
        BCC     _FAIL
        LDL     R4,#$00  ; R4=$0000
        LDH     R4,#$a0  ; R4=$a000
        SUB     R0,R2,R4 ; Compare R2 to R4
        BNE     _FAIL

       ;Test LSR instruction ***************************************************
        LDL     R7,#$8f  ; R7=$008f
        LDH     R7,#$b2  ; R7=$b18f
        LSR     R7,#8    ; R7=$00b0, Carry flag set
        BCC     _FAIL
        LDL     R4,#$b2  ; R4=$00b0
        LDH     R4,#$00  ; R4=$00b0
        SUB     R0,R7,R4 ; Compare R7 to R4
        BNE     _FAIL

       ;Test ROL instruction ***************************************************
        LDL     R7,#$62  ; R7=$0062
        LDH     R7,#$c3  ; R7=$c362
        ROL     R7,#8    ; R7=$62c3
        BVS     _FAIL    ; Overflow Flag should be clear
        LDL     R4,#$c3  ; R4=$00c3
        LDH     R4,#$62  ; R4=$62c3
        SUB     R0,R7,R4 ; Compare R7 to R4
        BNE     _FAIL

       ;Test ROR instruction ***************************************************
        LDL     R7,#$62  ; R7=$0062
        LDH     R7,#$c3  ; R7=$c362
        ROR     R7,#12   ; R7=$362c
        BVS     _FAIL    ; Overflow Flag should be clear
        LDL     R4,#$2c  ; R4=$002c
        LDH     R4,#$36  ; R4=$362c
        SUB     R0,R7,R4 ; Compare R7 to R4
        BNE     _FAIL

        LDL     R2,#$00    ; Sent Message to Testbench Check Point Register
        LDH     R2,#$80
        LDL     R3,#$02
        STB     R3,(R2,#0)

        NOP
        NOP
        SIF
        RTS

_FAIL
        LDL     R2,#$04    ; Sent Message to Testbench Error Register
        LDH     R2,#$80
        LDL     R3,#$02
        STB     R3,(R2,#0)

        SIF
        RTS

;-------------------------------------------------------------------------------
;   Test Logical Byte wide instructions
;-------------------------------------------------------------------------------
_START2
        LDL     R2,#$00    ; Sent Message to Testbench Check Point Register
        LDH     R2,#$80
        LDL     R3,#$03    ; Checkpoint Value
        STB     R3,(R2,#0)
        LDL     R3,#$02    ; Thread Value
        STB     R3,(R2,#2) ; Send Message to clear Testbench interrupt register

       ;Test ANDL instruction **************************************************
        LDL     R7,#$55  ; R7=$0055
        LDH     R7,#$a5  ; R7=$a555
        ANDL    R7,#$00  ; R7=&a500
        BNE     _FAIL2   ; Zero Flag should be set
        BVS     _FAIL2   ; Overflow Flag should be clear
        BMI     _FAIL2   ; Negative Flag should be clear
        LDL     R3,#$00  ; R3=$0000
        LDH     R3,#$a5  ; R3=$a500
        SUB     R0,R7,R3 ; Compare R7 to R3
        BNE     _FAIL2
        LDL     R7,#$c5  ; R7=$00c5
        LDH     R7,#$a5  ; R7=$a5c5
        ANDL    R7,#$80  ; R7=$a580
        BPL     _FAIL2   ; Negative Flag should be set
        BEQ     _FAIL2   ; Zero Flag should be clear
        BVS     _FAIL2   ; Overflow Flag should be clear
        LDL     R3,#$80  ; R3=$0080
        LDH     R3,#$a5  ; R3=$a580
        SUB     R0,R7,R3 ; Compare R7 to R3
        BNE     _FAIL2

       ;Test ANDH instruction **************************************************
        LDL     R7,#$55  ; R7=$0055
        LDH     R7,#$a5  ; R7=$a555
        ANDH    R7,#$00  ; R7=&0055
        BNE     _FAIL2   ; Zero Flag should be set
        BVS     _FAIL2   ; Overflow Flag should be clear
        BMI     _FAIL2   ; Negative Flag should be clear
        LDL     R3,#$55  ; R3=$0000
        LDH     R3,#$00  ; R3=$a500
        SUB     R0,R7,R3 ; Compare R7 to R3
        BNE     _FAIL2
        LDL     R7,#$c5  ; R7=$00c5
        LDH     R7,#$a5  ; R7=$a5c5
        ANDH    R7,#$80  ; R7=$80c5
        BPL     _FAIL2   ; Negative Flag should be set
        BEQ     _FAIL2   ; Zero Flag should be clear
        BVS     _FAIL2   ; Overflow Flag should be clear
        LDL     R3,#$c5  ; R3=$00c5
        LDH     R3,#$80  ; R3=$80c5
        SUB     R0,R7,R3 ; Compare R7 to R3
        BNE     _FAIL2

       ;Test BITL instruction **************************************************
        LDL     R7,#$55  ; R7=$0055
        LDH     R7,#$a5  ; R7=$a555
        BITL    R7,#$00  ; R7=&a500
        BNE     _FAIL2   ; Zero Flag should be set
        BVS     _FAIL2   ; Overflow Flag should be clear
        BMI     _FAIL2   ; Negative Flag should be clear
        LDL     R7,#$c5  ; R7=$00c5
        LDH     R7,#$a5  ; R7=$a5c5
        BITL    R7,#$80  ; R7=$a580
        BPL     _FAIL2   ; Negative Flag should be set
        BEQ     _FAIL2   ; Zero Flag should be clear
        BVS     _FAIL2   ; Overflow Flag should be clear

       ;Test BITH instruction **************************************************
        LDL     R7,#$55  ; R7=$0055
        LDH     R7,#$a5  ; R7=$a555
        BITH    R7,#$00  ; R7=&0055
        BNE     _FAIL2   ; Zero Flag should be set
        BVS     _FAIL2   ; Overflow Flag should be clear
        BMI     _FAIL2   ; Negative Flag should be clear
        LDL     R7,#$c5  ; R7=$00c5
        LDH     R7,#$a5  ; R7=$a5c5
        BITH    R7,#$80  ; R7=$80c5
        BPL     _FAIL2   ; Negative Flag should be set
        BEQ     _FAIL2   ; Zero Flag should be clear
        BVS     _FAIL2   ; Overflow Flag should be clear

       ;Test ORL instruction ***************************************************
        LDL     R2,#$0b
        TFR     CCR,R2   ; Negative=1, Zero=0, Overflow=1, Carry=1
        LDL     R7,#$00  ; R7=$0000
        LDH     R7,#$a5  ; R7=$a500
        ORL     R7,#$00  ; R7=&a500
        BMI     _FAIL2   ; Negative Flag should be clear
        BNE     _FAIL2   ; Zero Flag should be set
        BVS     _FAIL2   ; Overflow Flag should be clear
        BCC     _FAIL2   ; Carry Flag should be set
        LDL     R3,#$00  ; R3=$0000
        LDH     R3,#$a5  ; R3=$a500
        SUB     R0,R7,R3 ; Compare R7 to R3
        BNE     _FAIL2
        LDL     R2,#$06
        TFR     CCR,R2   ; Negative=0, Zero=1, Overflow=1, Carry=0
        LDL     R7,#$9f  ; R7=$009f
        LDH     R7,#$a5  ; R7=$a59f
        ORL     R7,#$60  ; R7=$a5ff
        BPL     _FAIL2   ; Negative Flag should be set
        BEQ     _FAIL2   ; Zero Flag should be clear
        BVS     _FAIL2   ; Overflow Flag should be clear
        BCS     _FAIL2   ; Carry Flag should be clear
        LDL     R3,#$ff  ; R3=$00ff
        LDH     R3,#$a5  ; R3=$a5ff
        SUB     R0,R7,R3 ; Compare R7 to R3
        BNE     _FAIL2

       ;Test ORH instruction ***************************************************
        LDL     R2,#$0b
        TFR     CCR,R2   ; Negative=1, Zero=0, Overflow=1, Carry=1
        LDL     R7,#$88  ; R7=$0088
        LDH     R7,#$00  ; R7=$0088
        ORH     R7,#$00  ; R7=&0088
        BMI     _FAIL2   ; Negative Flag should be clear
        BNE     _FAIL2   ; Zero Flag should be set
        BVS     _FAIL2   ; Overflow Flag should be clear
        BCC     _FAIL2   ; Carry Flag should be set
        LDL     R3,#$88  ; R3=$0088
        LDH     R3,#$00  ; R3=$0088
        SUB     R0,R7,R3 ; Compare R7 to R3
        BNE     _FAIL2
        LDL     R2,#$06
        TFR     CCR,R2   ; Negative=0, Zero=1, Overflow=1, Carry=0
        LDL     R7,#$36  ; R7=$0036
        LDH     R7,#$a1  ; R7=$a136
        ORH     R7,#$50  ; R7=$f136
        BPL     _FAIL2   ; Negative Flag should be set
        BEQ     _FAIL2   ; Zero Flag should be clear
        BVS     _FAIL2   ; Overflow Flag should be clear
        BCS     _FAIL2   ; Carry Flag should be clear
        LDL     R3,#$36  ; R3=$0036
        LDH     R3,#$f1  ; R3=$f136
        SUB     R0,R7,R3 ; Compare R7 to R3
        BNE     _FAIL2

       ;Test XNORL instruction *************************************************
        LDL     R2,#$0b
        TFR     CCR,R2   ; Negative=1, Zero=0, Overflow=1, Carry=1
        LDL     R7,#$c3  ; R7=$00c3
        LDH     R7,#$96  ; R7=$96c3
        XNORL   R7,#$3c  ; R7=$9600
        BMI     _FAIL2   ; Negative Flag should be clear
        BNE     _FAIL2   ; Zero Flag should be set
        BVS     _FAIL2   ; Overflow Flag should be clear
        BCC     _FAIL2   ; Carry Flag should be set
        LDL     R3,#$00  ; R3=$0000
        LDH     R3,#$96  ; R3=$9600
        SUB     R0,R7,R3 ; Compare R7 to R3
        BNE     _FAIL2
        LDL     R2,#$06
        TFR     CCR,R2   ; Negative=0, Zero=1, Overflow=1, Carry=0
        LDL     R6,#$00  ; R6=$0000
        LDH     R6,#$a5  ; R6=$a500
        XNORL   R6,#$73  ; R6=$a58c
        BPL     _FAIL2   ; Negative Flag should be set
        BEQ     _FAIL2   ; Zero Flag should be clear
        BVS     _FAIL2   ; Overflow Flag should be clear
        BCS     _FAIL2   ; Carry Flag should be clear
        LDL     R3,#$8c  ; R3=$008c
        LDH     R3,#$a5  ; R3=$a58c
        SUB     R0,R6,R3 ; Compare R6 to R3
        BNE     _FAIL2

       ;Test XNORH instruction *************************************************
        LDL     R2,#$0b
        TFR     CCR,R2   ; Negative=1, Zero=0, Overflow=1, Carry=1
        LDL     R7,#$c3  ; R7=$00c3
        LDH     R7,#$96  ; R7=$96c3
        XNORH   R7,#$69  ; R7=$00c3
        BMI     _FAIL2   ; Negative Flag should be clear
        BNE     _FAIL2   ; Zero Flag should be set
        BVS     _FAIL2   ; Overflow Flag should be clear
        BCC     _FAIL2   ; Carry Flag should be set
        LDL     R3,#$c3  ; R3=$00c3
        LDH     R3,#$00  ; R3=$00c3
        SUB     R0,R7,R3 ; Compare R7 to R3
        BNE     _FAIL2
        LDL     R2,#$06
        TFR     CCR,R2   ; Negative=0, Zero=1, Overflow=1, Carry=0
        LDL     R6,#$66  ; R6=$0066
        LDH     R6,#$66  ; R6=$6666
        XNORH   R6,#$66  ; R6=$ff66
        BPL     _FAIL2   ; Negative Flag should be set
        BEQ     _FAIL2   ; Zero Flag should be clear
        BVS     _FAIL2   ; Overflow Flag should be clear
        BCS     _FAIL2   ; Carry Flag should be clear
        LDL     R3,#$66  ; R3=$0066
        LDH     R3,#$ff  ; R3=$ff66
        SUB     R0,R6,R3 ; Compare R6 to R3
        BNE     _FAIL2


        LDL     R2,#$00    ; Sent Message to Testbench Check Point Register
        LDH     R2,#$80
        LDL     R3,#$04
        STB     R3,(R2,#0)

        SIF
        RTS

_FAIL2
        LDL     R2,#$04    ; Sent Message to Testbench Error Register
        LDH     R2,#$80
        LDL     R3,#$04
        STB     R3,(R2,#0)

        SIF
        RTS

;-------------------------------------------------------------------------------
;   Test Logical Word Wide instructions
;-------------------------------------------------------------------------------
_START3
        LDL     R2,#$00    ; Sent Message to Testbench Check Point Register
        LDH     R2,#$80
        LDL     R3,#$05    ; Checkpoint Value
        STB     R3,(R2,#0)
        LDL     R3,#$03    ; Thread Value
        STB     R3,(R2,#2) ; Send Message to clear Testbench interrupt register

       ;Test SEX instruction ***************************************************
        LDL     R2,#$0b
        TFR     CCR,R2   ; Negative=1, Zero=0, Overflow=1, Carry=1
        LDL     R3,#$00  ; R3=$0000
        LDH     R3,#$ff  ; R3=$ff00
        SEX     R3       ; R3=$0000
        BMI     _FAIL3   ; Negative Flag should be clear
        BNE     _FAIL3   ; Zero Flag should be set
        BVS     _FAIL3   ; Overflow Flag should be clear
        BCC     _FAIL3   ; Carry Flag should be set
        LDL     R6,#$00  ; R6=$0000
        LDH     R6,#$00  ; R6=$0000
        SUB     R0,R6,R3 ; Compare R6 to R3
        BNE     _FAIL3
        LDL     R2,#$06
        TFR     CCR,R2   ; Negative=0, Zero=1, Overflow=1, Carry=0
        LDL     R6,#$83  ; R6=$0083
        LDH     R6,#$00  ; R6=$0083
        SEX     R6       ; R6=$ff83
        BPL     _FAIL3   ; Negative Flag should be set
        BEQ     _FAIL3   ; Zero Flag should be clear
        BVS     _FAIL3   ; Overflow Flag should be clear
        BCS     _FAIL3   ; Carry Flag should be clear
        LDL     R3,#$83  ; R3=$0083
        LDH     R3,#$ff  ; R3=$ff83
        SUB     R0,R6,R3 ; Compare R6 to R3
        BNE     _FAIL3

       ;Test PAR instruction ***************************************************
        LDL     R2,#$0a
        TFR     CCR,R2   ; Negative=1, Zero=0, Overflow=1, Carry=0
        LDL     R4,#$00  ; R4=$0000
        LDH     R4,#$00  ; R4=$0000
        PAR     R4       ; R4=$0000
        BMI     _FAIL3   ; Negative Flag should be clear
        BNE     _FAIL3   ; Zero Flag should be set
        BVS     _FAIL3   ; Overflow Flag should be clear
        BCS     _FAIL3   ; Carry Flag should be clear
        LDL     R6,#$00  ; R6=$0000
        LDH     R6,#$00  ; R6=$0000
        SUB     R0,R6,R4 ; Compare R6 to R4
        BNE     _FAIL3
        LDL     R2,#$0e
        TFR     CCR,R2   ; Negative=1, Zero=1, Overflow=1, Carry=0
        LDL     R6,#$01  ; R6=$0001
        LDH     R6,#$03  ; R6=$0301
        PAR     R6       ; R6=$0301
        BMI     _FAIL3   ; Negative Flag should be clear
        BEQ     _FAIL3   ; Zero Flag should be clear
        BVS     _FAIL3   ; Overflow Flag should be clear
        BCC     _FAIL3   ; Carry Flag should be set
        LDL     R3,#$01  ; R3=$0001
        LDH     R3,#$03  ; R3=$0301
        SUB     R0,R6,R3 ; Compare R6 to R3
        BNE     _FAIL3

       ;Test AND instruction ***************************************************
        LDL     R2,#$0a
        TFR     CCR,R2   ; Negative=1, Zero=0, Overflow=1, Carry=0
        LDL     R6,#$55  ; R6=$0055
        LDH     R6,#$aa  ; R6=$aa55
        LDL     R5,#$aa  ; R5=$00aa
        LDH     R5,#$55  ; R5=$55aa
        AND     R3,R5,R6 ; R3=$0000
        BMI     _FAIL3   ; Negative Flag should be clear
        BNE     _FAIL3   ; Zero Flag should be set
        BVS     _FAIL3   ; Overflow Flag should be clear
        BCS     _FAIL3   ; Carry Flag should be clear
        SUB     R0,R0,R3 ; Compare R0 to R3
        BNE     _FAIL3
        LDL     R7,#$55  ; R7=$00c5
        LDH     R7,#$aa  ; R7=$aa55
        LDL     R2,#$07
        TFR     CCR,R2   ; Negative=0, Zero=1, Overflow=1, Carry=1
        AND     R4,R6,R7 ; R4=$aa55
        BPL     _FAIL3   ; Negative Flag should be set
        BEQ     _FAIL3   ; Zero Flag should be clear
        BVS     _FAIL3   ; Overflow Flag should be clear
        BCC     _FAIL3   ; Carry Flag should be set
        SUB     R0,R4,R7 ; Compare R4 to R7
        BNE     _FAIL2

       ;Test OR instruction ****************************************************
        LDL     R2,#$0a
        TFR     CCR,R2   ; Negative=1, Zero=0, Overflow=1, Carry=0
        LDL     R6,#$00  ; R6=$0000
        LDL     R5,#$00  ; R5=$0000
        OR      R3,R5,R6 ; R3=$0000
        BMI     _FAIL3   ; Negative Flag should be clear
        BNE     _FAIL3   ; Zero Flag should be set
        BVS     _FAIL3   ; Overflow Flag should be clear
        BCS     _FAIL3   ; Carry Flag should be clear
        SUB     R0,R0,R3 ; Compare R0 to R3
        BNE     _FAIL3
        LDL     R7,#$55  ; R7=$00c5
        LDH     R7,#$aa  ; R7=$aa55
        LDL     R6,#$8a  ; R6=$008a
        LDH     R6,#$10  ; R7=$108a
        LDL     R2,#$07
        TFR     CCR,R2   ; Negative=0, Zero=1, Overflow=1, Carry=1
        OR      R4,R6,R7 ; R4=$badf
        BPL     _FAIL3   ; Negative Flag should be set
        BEQ     _FAIL3   ; Zero Flag should be clear
        BVS     _FAIL3   ; Overflow Flag should be clear
        BCC     _FAIL3   ; Carry Flag should be set
        LDL     R3,#$df  ; R3=$00df
        LDH     R3,#$ba  ; R3=$badf
        SUB     R0,R4,R3 ; Compare R6 to R3
        BNE     _FAIL3

       ;Test XNOR instruction **************************************************
        LDL     R2,#$0a
        TFR     CCR,R2   ; Negative=1, Zero=0, Overflow=1, Carry=0
        LDL     R1,#$55  ; R1=$0055
        LDH     R1,#$aa  ; R1=$aa55
        LDL     R5,#$aa  ; R5=$00aa
        LDH     R5,#$55  ; R5=$55aa
        XNOR    R3,R5,R1 ; R3=$0000
        BMI     _FAIL3   ; Negative Flag should be clear
        BNE     _FAIL3   ; Zero Flag should be set
        BVS     _FAIL3   ; Overflow Flag should be clear
        BCS     _FAIL3   ; Carry Flag should be clear
        SUB     R0,R0,R3 ; Compare R0 to R3
        BNE     _FAIL3
        LDL     R7,#$cc  ; R7=$00cc
        LDH     R7,#$33  ; R7=$33cc
        LDL     R2,#$01  ; R2=$0001
        LDH     R2,#$40  ; R2=$4001
        TFR     CCR,R2   ; Negative=0, Zero=1, Overflow=1, Carry=1
        XNOR    R4,R7,R2 ; R4=$8c32
        BPL     _FAIL3   ; Negative Flag should be set
        BEQ     _FAIL3   ; Zero Flag should be clear
        BVS     _FAIL3   ; Overflow Flag should be clear
        BCC     _FAIL3   ; Carry Flag should be set
        LDL     R3,#$32  ; R3=$0032
        LDH     R3,#$8c  ; R3=$8c32
        SUB     R0,R4,R3 ; Compare R4 to R3
        BNE     _FAIL3


       ;Test TFR instruction ***************************************************
        MOV     R1,R0
        COM     R1
        TFR     CCR,R1   ; Negative=1, Zero=1, Overflow=1, Carry=1
        TFR     R5,CCR   ; R5=$000f
        LDL     R6,#$0f  ; R6=$xx0f
        LDH     R6,#$00  ; R5=$000f
        CMP     R5,R6
        BNE     _FAIL3

       
        LDL     R2,#$00    ; Sent Message to Testbench Check Point Register
        LDH     R2,#$80
        LDL     R3,#$06
        STB     R3,(R2,#0)

        NOP
        SIF
        RTS

_FAIL3
        LDL     R2,#$04    ; Sent Message to Testbench Error Register
        LDH     R2,#$80
        LDL     R3,#$06
        STB     R3,(R2,#0)

        SIF
        RTS


;-------------------------------------------------------------------------------
;   Test Bit Field instructions
;-------------------------------------------------------------------------------
_START4
        LDL     R2,#$00    ; Sent Message to Testbench Check Point Register
        LDH     R2,#$80
        LDL     R3,#$07    ; Checkpoint Value
        STB     R3,(R2,#0)
        LDL     R3,#$04    ; Thread Value
        STB     R3,(R2,#2) ; Send Message to clear Testbench interrupt register

       ;Test BFEXT instruction *************************************************
        LDL     R2,#$0e
        TFR     CCR,R2     ; Negative=1, Zero=1, Overflow=1, Carry=0
        LDL     R6,#$34    ; Set offset to 4 and width to 3(4 bits)
        LDL     R5,#$a6    ; Set R5=$00a6
        LDH     R5,#$c3    ; Set R5=$c3a6
        LDL     R4,#$ff    ; Set R4=$00ff
        SEX     R4         ; Set R4=$ffff
        BFEXT   R4,R5,R6   ; R4=$000a
        BMI     _FAIL4     ; Negative Flag should be clear
        BEQ     _FAIL4     ; Zero Flag should be clear
        BVS     _FAIL4     ; Overflow Flag should be clear
        BCS     _FAIL4     ; Carry Flag should be clear
        LDL     R7,#$0a    ; R7=$00cc
        SUB     R0,R7,R4 ; Compare R7 to R4
        BNE     _FAIL4

        LDL     R6,#$b8    ; Set offset to 8 and width to 11(12 bits)
        BFEXT   R4,R5,R6   ; R4=$00c3
        LDL     R7,#$c3    ; R7=$00c3
        SUB     R0,R7,R4 ; Compare R7 to R4
        BNE     _FAIL4

       ;Test BFINS instruction *************************************************
        LDL     R2,#$06
        TFR     CCR,R2     ; Negative=0, Zero=1, Overflow=1, Carry=0
        LDL     R6,#$34    ; Set offset to 4 and width to 3(4 bits)
        LDL     R5,#$a6    ; Set R5=$00a6
        LDH     R5,#$c3    ; Set R5=$c3a6
        LDL     R4,#$ff    ; Set R4=$00ff
        SEX     R4         ; Set R4=$ffff
        BFINS   R4,R5,R6   ; R4=$ffaf
        BPL     _FAIL4     ; Negative Flag should be set
        BEQ     _FAIL4     ; Zero Flag should be clear
        BVS     _FAIL4     ; Overflow Flag should be clear
        BCS     _FAIL4     ; Carry Flag should be clear
        LDL     R7,#$6f    ; R7=$006f
        LDH     R7,#$ff    ; R7=$ff6f
        SUB     R0,R7,R4 ; Compare R7 to R4
        BNE     _FAIL4

        LDL     R6,#$b0    ; Set offset to 0 and width to 11(12 bits)
        BFINS   R4,R5,R6   ; R4=$f3a6
        LDL     R7,#$a6    ; R7=$00a6
        LDH     R7,#$f3    ; R7=$f3a6
        SUB     R0,R7,R4 ; Compare R7 to R4
        BNE     _FAIL4

       ;Test BFINSI instruction ************************************************
        LDL     R2,#$06
        TFR     CCR,R2     ; Negative=0, Zero=1, Overflow=1, Carry=0
        LDL     R6,#$3c    ; Set offset to 12 and width to 3(4 bits)
        LDL     R5,#$a6    ; Set R5=$00a6
        LDH     R5,#$c3    ; Set R5=$c3a6
        LDL     R4,#$ff    ; Set R4=$00ff
        SEX     R4         ; Set R4=$ffff
        BFINSI  R4,R5,R6   ; R4=$9fff
        BPL     _FAIL4     ; Negative Flag should be set
        BEQ     _FAIL4     ; Zero Flag should be clear
        BVS     _FAIL4     ; Overflow Flag should be clear
        BCS     _FAIL4     ; Carry Flag should be clear
        LDL     R7,#$ff    ; R7=$00ff
        LDH     R7,#$9f    ; R7=$ff6f
        SUB     R0,R7,R4 ; Compare R7 to R4
        BNE     _FAIL4

        LDL     R6,#$78    ; Set offset to 8 and width to 7(8 bits)
        BFINSI  R4,R5,R6   ; R4=$59ff
        LDL     R7,#$ff    ; R7=$00ff
        LDH     R7,#$59    ; R7=$59ff
        SUB     R0,R7,R4 ; Compare R7 to R4
        BNE     _FAIL4

       ;Test BFINSX instruction ************************************************
        LDL     R2,#$06
        TFR     CCR,R2     ; Negative=0, Zero=1, Overflow=1, Carry=0
        LDL     R6,#$38    ; Set offset to 8 and width to 3(4 bits)
        LDL     R5,#$a6    ; Set R5=$00a6
        LDH     R5,#$c3    ; Set R5=$c3a6
        LDL     R4,#$ff    ; Set R4=$00ff
        LDH     R4,#$fa    ; Set R4=$faff
        BFINSX  R4,R5,R6   ; R4=$f3ff
        BPL     _FAIL4     ; Negative Flag should be set
        BEQ     _FAIL4     ; Zero Flag should be clear
        BVS     _FAIL4     ; Overflow Flag should be clear
        BCS     _FAIL4     ; Carry Flag should be clear
        LDL     R7,#$ff    ; R7=$00ff
        LDH     R7,#$f3    ; R7=$f3ff
        SUB     R0,R7,R4   ; Compare R7 to R4
        BNE     _FAIL4

        LDL     R6,#$70    ; Set offset to 0 and width to 7(8 bits)
        BFINSX  R4,R5,R6   ; R4=$f3a6
        LDL     R7,#$a6    ; R7=$00a6
        LDH     R7,#$f3    ; R7=$f3a6
        SUB     R0,R7,R4 ; Compare R7 to R4
        BNE     _FAIL4


        LDL     R2,#$00    ; Sent Message to Testbench Check Point Register
        LDH     R2,#$80
        LDL     R3,#$08
        STB     R3,(R2,#0)

        NOP
        SIF
        RTS

_FAIL4
        LDL     R2,#$04    ; Sent Message to Testbench Error Register
        LDH     R2,#$80
        LDL     R3,#$08
        STB     R3,(R2,#0)

        SIF
        RTS


;-------------------------------------------------------------------------------
;   Test Branch instructions
;-------------------------------------------------------------------------------
_START5
        LDL     R2,#$00    ; Sent Message to Testbench Check Point Register
        LDH     R2,#$80
        LDL     R3,#$09    ; Checkpoint Value
        STB     R3,(R2,#0)
        LDL     R3,#$05    ; Thread Value
        STB     R3,(R2,#2) ; Send Message to clear Testbench interrupt register

       ;Test BCC instruction  C = 0   ******************************************
        LDL     R2,#$00
        TFR     CCR,R2   ; Negative=0, Zero=0, Overflow=0, Carry=0
        BCC     _BCC_OK1 ; Take Branch
        BRA     _BR_ERR
_BCC_OK1
        LDL     R2,#$01
        TFR     CCR,R2   ; Negative=0, Zero=0, Overflow=0, Carry=1
        BCC     _BR_ERR  ; Don't take branch


       ;Test BCS instruction  C = 1   ******************************************
        LDL     R2,#$01
        TFR     CCR,R2   ; Negative=0, Zero=0, Overflow=0, Carry=1
        BCS     _BCS_OK1 ; Take Branch
        BRA     _BR_ERR
_BCS_OK1
        LDL     R2,#$00
        TFR     CCR,R2   ; Negative=0, Zero=0, Overflow=0, Carry=0
        BCS     _BR_ERR  ; Don't take branch


       ;Test BEQ instruction  Z = 1   ******************************************
        LDL     R2,#$04
        TFR     CCR,R2   ; Negative=0, Zero=1, Overflow=0, Carry=0
        BEQ     _BEQ_OK1 ; Take Branch
        BRA     _BR_ERR
_BEQ_OK1
        LDL     R2,#$00
        TFR     CCR,R2   ; Negative=0, Zero=0, Overflow=0, Carry=0
        BEQ     _BR_ERR  ; Don't take branch


       ;Test BNE instruction  Z = 0   ******************************************
        LDL     R2,#$00
        TFR     CCR,R2   ; Negative=0, Zero=0, Overflow=0, Carry=0
        BNE     _BNE_OK1 ; Take Branch
        BRA     _BR_ERR
_BNE_OK1
        LDL     R2,#$04
        TFR     CCR,R2   ; Negative=0, Zero=1, Overflow=0, Carry=0
        BNE     _BR_ERR  ; Don't take branch


       ;Test BPL instruction  N = 0   ******************************************
        LDL     R2,#$00
        TFR     CCR,R2   ; Negative=0, Zero=0, Overflow=0, Carry=0
        BPL     _BPL_OK1 ; Take Branch
        BRA     _BR_ERR
_BPL_OK1
        LDL     R2,#$08
        TFR     CCR,R2   ; Negative=1, Zero=0, Overflow=0, Carry=0
        BPL     _BR_ERR  ; Don't take branch


       ;Test BMI instruction  N = 1   ******************************************
        LDL     R2,#$08
        TFR     CCR,R2   ; Negative=1, Zero=0, Overflow=0, Carry=0
        BMI     _BMI_OK1 ; Take Branch
        BRA     _BR_ERR
_BMI_OK1
        LDL     R2,#$00
        TFR     CCR,R2   ; Negative=0, Zero=0, Overflow=0, Carry=0
        BMI     _BR_ERR  ; Don't take branch


       ;Test BVC instruction  V = 0   ******************************************
        LDL     R2,#$00
        TFR     CCR,R2   ; Negative=0, Zero=0, Overflow=0, Carry=0
        BVC     _BVC_OK1 ; Take Branch
        BRA     _BR_ERR
_BVC_OK1
        LDL     R2,#$02
        TFR     CCR,R2   ; Negative=0, Zero=0, Overflow=1, Carry=0
        BVC     _BR_ERR  ; Don't take branch


       ;Test BVS instruction  V = 1   ******************************************
        LDL     R2,#$02
        TFR     CCR,R2   ; Negative=0, Zero=0, Overflow=1, Carry=0
        BVS     _BVS_OK1 ; Take Branch
        BRA     _BR_ERR
_BVS_OK1
        LDL     R2,#$00
        TFR     CCR,R2   ; Negative=0, Zero=0, Overflow=0, Carry=0
        BVS     _BR_ERR  ; Don't take branch


       ;Test BLS instruction  C | Z = 1   **************************************
        LDL     R2,#$01
        TFR     CCR,R2   ; Negative=0, Zero=0, Overflow=0, Carry=1
        BLS     _BLS_OK1 ; Take Branch
        BRA     _BR_ERR
_BLS_OK1
        LDL     R2,#$04
        TFR     CCR,R2   ; Negative=0, Zero=1, Overflow=0, Carry=0
        BLS     _BLS_OK2 ; Take Branch
        BRA     _BR_ERR
_BLS_OK2
        LDL     R2,#$00
        TFR     CCR,R2   ; Negative=0, Zero=0, Overflow=0, Carry=0
        BLS     _BR_ERR  ; Don't take branch


       ;Test BGE instruction  N ^ V = 0   **************************************
        LDL     R2,#$0a
        TFR     CCR,R2   ; Negative=1, Zero=0, Overflow=1, Carry=0
        BGE     _BGE_OK1 ; Take Branch
        BRA     _BR_ERR
_BGE_OK1
        LDL     R2,#$05
        TFR     CCR,R2   ; Negative=0, Zero=1, Overflow=0, Carry=1
        BGE     _BGE_OK2 ; Take Branch
        BRA     _BR_ERR
_BGE_OK2
        LDL     R2,#$08
        TFR     CCR,R2   ; Negative=1, Zero=0, Overflow=0, Carry=0
        BGE     _BR_ERR  ; Don't take branch


       ;Test BLT instruction  N ^ V = 1   **************************************
        LDL     R2,#$08
        TFR     CCR,R2   ; Negative=1, Zero=0, Overflow=1, Carry=0
        BLT     _BLT_OK1 ; Take Branch
        BRA     _BR_ERR
_BLT_OK1
        LDL     R2,#$02
        TFR     CCR,R2   ; Negative=0, Zero=1, Overflow=0, Carry=1
        BLT     _BLT_OK2 ; Take Branch
        BRA     _BR_ERR
_BLT_OK2
        LDL     R2,#$0a
        TFR     CCR,R2   ; Negative=1, Zero=0, Overflow=1, Carry=0
        BLT     _BR_ERR  ; Don't take branch

        LDL     R2,#$00
        TFR     CCR,R2   ; Negative=0, Zero=0, Overflow=0, Carry=0
        BLT     _BR_ERR  ; Don't take branch


       ;Test BHI instruction  Z | C = 0   **************************************
        LDL     R2,#$0a
        TFR     CCR,R2   ; Negative=1, Zero=0, Overflow=1, Carry=0
        BHI     _BHI_OK1 ; Take Branch
        BRA     _BR_ERR
_BHI_OK1
        LDL     R2,#$0b
        TFR     CCR,R2   ; Negative=1, Zero=0, Overflow=1, Carry=1
        BHI     _BR_ERR  ; Don't take branch

        LDL     R2,#$0e
        TFR     CCR,R2   ; Negative=1, Zero=1, Overflow=1, Carry=0
        BHI     _BR_ERR  ; Don't take branch


       ;Test BGT instruction  Z | (N ^ V) = 0   ********************************
        LDL     R2,#$0a
        TFR     CCR,R2   ; Negative=1, Zero=0, Overflow=1, Carry=0
        BGT     _BGT_OK1 ; Take Branch
        BRA     _BR_ERR
_BGT_OK1
        LDL     R2,#$01
        TFR     CCR,R2   ; Negative=0, Zero=0, Overflow=0, Carry=1
        BGT     _BGT_OK2 ; Take Branch
        BRA     _BR_ERR
_BGT_OK2
        LDL     R2,#$0e
        TFR     CCR,R2   ; Negative=1, Zero=1, Overflow=1, Carry=0
        BGT     _BR_ERR  ; Don't take branch

        LDL     R2,#$02
        TFR     CCR,R2   ; Negative=0, Zero=0, Overflow=1, Carry=0
        BGT     _BR_ERR  ; Don't take branch

        LDL     R2,#$08
        TFR     CCR,R2   ; Negative=1, Zero=0, Overflow=0, Carry=0
        BGT     _BR_ERR  ; Don't take branch


       ;Test BLE instruction  Z | (N ^ V) = 1   ********************************
        LDL     R2,#$04
        TFR     CCR,R2   ; Negative=0, Zero=1, Overflow=0, Carry=0
        BLE     _BLE_OK1 ; Take Branch
        BRA     _BR_ERR
_BLE_OK1
        LDL     R2,#$02
        TFR     CCR,R2   ; Negative=0, Zero=0, Overflow=1, Carry=0
        BLE     _BLE_OK2 ; Take Branch
        BRA     _BR_ERR
_BLE_OK2
        LDL     R2,#$08
        TFR     CCR,R2   ; Negative=1, Zero=0, Overflow=0, Carry=0
        BLE     _BLE_OK3 ; Take Branch
        BRA     _BR_ERR
_BLE_OK3
        LDL     R2,#$0a
        TFR     CCR,R2   ; Negative=1, Zero=0, Overflow=1, Carry=0
        BLE     _BR_ERR  ; Don't take branch

        LDL     R2,#$00
        TFR     CCR,R2   ; Negative=0, Zero=0, Overflow=0, Carry=0
        BLE     _BR_ERR  ; Don't take branch


       ;Test BRA instruction  **************************************************
        BRA     BRA_FWARD


_BR_ERR
        LDL     R2,#$04    ; Sent Message to Testbench Error Register
        LDH     R2,#$80
        LDL     R3,#$0a
        STB     R3,(R2,#0)

        SIF
        RTS

_BRA_OK
        LDL     R2,#$00    ; Sent Message to Testbench Check Point Register
        LDH     R2,#$80
        LDL     R3,#$0a
        STB     R3,(R2,#0)

        SIF
        RTS

BRA_FWARD
        BRA     _BRA_OK    ; Test backward branch caculation


;-------------------------------------------------------------------------------
;   Test Subroutine Call and return instructions
;-------------------------------------------------------------------------------
_START6
        LDL     R2,#$00    ; Sent Message to Testbench Check Point Register
        LDH     R2,#$80
        LDL     R3,#$0b    ; Checkpoint Value
        STB     R3,(R2,#0)
        LDL     R3,#$06    ; Thread Value
        STB     R3,(R2,#2) ; Send Message to clear Testbench interrupt register

        LDL     R4,#$00
        TFR     R5,PC      ; Subroutine Call
        BRA     SUB_TST

RET_SUB

        LDL     R2,#$00    ; Sent Message to Testbench Check Point Register
        LDH     R2,#$80
        LDL     R3,#$0c
        STB     R3,(R2,#0)

        SIF
        RTS

_FAIL6
        LDL     R2,#$04    ; Sent Message to Testbench Error Register
        LDH     R2,#$80
        LDL     R3,#$0c
        STB     R3,(R2,#0)

        SIF
        RTS

SUB_TST
        LDL     R4,#$88    ; If we branch to far then the wrong data will get loaded
        LDH     R4,#$99    ;  and we'll make a bad compare to cause test to fail
        LDL     R7,#$88    ; R7=$0088
        LDH     R7,#$99    ; R7=$9988
        SUB     R0,R7,R4   ; Compare R7 to R4
        BNE     _FAIL6
        JAL     R5         ; Jump to return address

;-------------------------------------------------------------------------------
;   Test 16 bit Addition and Substract instructions
;-------------------------------------------------------------------------------
_START7
        LDL     R2,#$00    ; Sent Message to Testbench Check Point Register
        LDH     R2,#$80
        LDL     R3,#$0d    ; Checkpoint Value
        STB     R3,(R2,#0)
        LDL     R3,#$07    ; Thread Value
        STB     R3,(R2,#2) ; Send Message to clear Testbench interrupt register

       ;Test SUB instruction ***************************************************
        LDL     R4,#$0f    ; R4=$000f
        LDH     R4,#$01    ; R4=$010f
        LDL     R7,#$0e    ; R7=$000e
        LDH     R7,#$01    ; R7=$010e
        LDL     R2,#$0f
        TFR     CCR,R2     ; Negative=1, Zero=1, Overflow=1, Carry=1
        SUB     R1,R4,R7   ; R4 - R7 => R1
        BMI     _FAIL7     ; Negative Flag should be clear
        BEQ     _FAIL7     ; Zero Flag should be clear
        BVS     _FAIL7     ; Overflow Flag should be clear
        BCS     _FAIL7     ; Carry Flag should be clear
        LDL     R3,#$01    ; R3=$0001
        SUB     R0,R1,R3   ; Compare R1 to R3
        BNE     _FAIL7

        LDL     R7,#$0f    ; R7=$000f
        LDH     R7,#$01    ; R7=$010f
        LDL     R2,#$0b
        TFR     CCR,R2     ; Negative=1, Zero=0, Overflow=1, Carry=1
        SUB     R1,R4,R7   ; R4 - R7 => R1
        BMI     _FAIL7     ; Negative Flag should be clear
        BNE     _FAIL7     ; Zero Flag should be set
        BVS     _FAIL7     ; Overflow Flag should be clear
        BCS     _FAIL7     ; Carry Flag should be clear


       ;Test SBC instruction ***************************************************
        LDL     R4,#$11    ; R4=$0011
        LDH     R4,#$01    ; R4=$0111
        LDL     R7,#$0e    ; R7=$000e
        LDH     R7,#$01    ; R7=$010e
        LDL     R2,#$0f
        TFR     CCR,R2     ; Negative=1, Zero=1, Overflow=1, Carry=1
        SBC     R1,R4,R7   ; R4 - R7 => R1
        BMI     _FAIL7     ; Negative Flag should be clear
        BEQ     _FAIL7     ; Zero Flag should be clear
        BVS     _FAIL7     ; Overflow Flag should be clear
        BCS     _FAIL7     ; Carry Flag should be clear
        LDL     R3,#$02    ; R3=$0002
        SUB     R0,R1,R3   ; Compare R1 to R3
        BNE     _FAIL7

        LDL     R4,#$0f    ; R4=$000f
        LDH     R4,#$01    ; R4=$010f
        LDL     R7,#$0f    ; R7=$000f
        LDH     R7,#$01    ; R7=$010f
        LDL     R2,#$0a
        TFR     CCR,R2     ; Negative=1, Zero=0, Overflow=1, Carry=0
        SBC     R1,R4,R7   ; R4 - R7 => R1
        BMI     _FAIL7     ; Negative Flag should be clear
        BEQ     _FAIL7     ; Zero Flag should be clear
        BVS     _FAIL7     ; Overflow Flag should be clear
        BCS     _FAIL7     ; Carry Flag should be clear


       ;Test ADD instruction ***************************************************
        LDL     R4,#$0f    ; R4=$000f
        LDH     R4,#$70    ; R4=$700f
        LDL     R7,#$01    ; R7=$0001
        LDH     R7,#$10    ; R7=$1001
        LDL     R2,#$05
        TFR     CCR,R2     ; Negative=0, Zero=1, Overflow=0, Carry=1
        ADD     R1,R4,R7   ; R4 + R7 => R1
        BPL     _FAIL7     ; Negative Flag should be set
        BEQ     _FAIL7     ; Zero Flag should be clear
        BVC     _FAIL7     ; Overflow Flag should be set
        BCS     _FAIL7     ; Carry Flag should be clear
        LDL     R3,#$10    ; R3=$0010
        LDH     R3,#$80    ; R3=$8010
        SUB     R0,R1,R3   ; Compare R1 to R3
        BNE     _FAIL7

        LDL     R4,#$00    ; R4=$0000
        LDH     R4,#$80    ; R4=$8000
        LDL     R7,#$00    ; R7=$0000
        LDH     R7,#$80    ; R7=$8000
        LDL     R2,#$0f
        TFR     CCR,R2     ; Negative=1, Zero=1, Overflow=0, Carry=0
        ADD     R1,R4,R7   ; R4 + R7 => R1
        BMI     _FAIL7     ; Negative Flag should be clear
        BNE     _FAIL7     ; Zero Flag should be set
        BVC     _FAIL7     ; Overflow Flag should be set
        BCC     _FAIL7     ; Carry Flag should be set
        SUB     R0,R1,R0   ; Compare R1 to R0(Zero)
        BNE     _FAIL7


       ;Test ADC instruction ***************************************************
        LDL     R4,#$0f    ; R4=$000f
        LDH     R4,#$70    ; R4=$700f
        LDL     R7,#$01    ; R7=$0001
        LDH     R7,#$10    ; R7=$1001
        LDL     R2,#$05
        TFR     CCR,R2     ; Negative=0, Zero=1, Overflow=0, Carry=1
        ADC     R1,R4,R7   ; R4 + R7 => R1
        BPL     _FAIL7     ; Negative Flag should be set
        BEQ     _FAIL7     ; Zero Flag should be clear
        BVC     _FAIL7     ; Overflow Flag should be set
        BCS     _FAIL7     ; Carry Flag should be clear
        LDL     R3,#$11    ; R3=$0011
        LDH     R3,#$80    ; R3=$8011
        SUB     R0,R1,R3   ; Compare R1 to R3
        BNE     _FAIL7

        LDL     R4,#$00    ; R4=$0000
        LDH     R4,#$80    ; R4=$8000
        LDL     R7,#$00    ; R7=$0000
        LDH     R7,#$80    ; R7=$8000
        LDL     R2,#$0c
        TFR     CCR,R2     ; Negative=1, Zero=1, Overflow=0, Carry=0
        ADC     R1,R4,R7   ; R4 + R7 => R1
        BMI     _FAIL7     ; Negative Flag should be clear
        BNE     _FAIL7     ; Zero Flag should be set
        BVC     _FAIL7     ; Overflow Flag should be set
        BCC     _FAIL7     ; Carry Flag should be set
        SUB     R0,R1,R0   ; Compare R1 to R0(Zero)
        BNE     _FAIL7


_END_7
        LDL     R2,#$00    ; Sent Message to Testbench Check Point Register
        LDH     R2,#$80
        LDL     R3,#$0e
        STB     R3,(R2,#0)

        SIF
        RTS

_FAIL7
        LDL     R2,#$04    ; Sent Message to Testbench Error Register
        LDH     R2,#$80
        LDL     R3,#$0e
        STB     R3,(R2,#0)

        SIF
        RTS

;-------------------------------------------------------------------------------
;   Test 8 bit Addition and Substract instructions
;-------------------------------------------------------------------------------
_START8
        LDL     R2,#$00    ; Sent Message to Testbench Check Point Register
        LDH     R2,#$80
        LDL     R3,#$0f    ; Checkpoint Value
        STB     R3,(R2,#0)
        LDL     R3,#$08    ; Thread Value
        STB     R3,(R2,#2) ; Send Message to clear Testbench interrupt register

       ;Test SUBL instruction **************************************************
        LDL     R5,#$0f    ; R5=$000f
        LDL     R2,#$0f
        TFR     CCR,R2     ; Negative=1, Zero=1, Overflow=1, Carry=1
        SUBL    R5,#$0e    ; R5 - $0e => R5
        BMI     _FAIL8     ; Negative Flag should be clear
        BEQ     _FAIL8     ; Zero Flag should be clear
        BVS     _FAIL8     ; Overflow Flag should be clear
        BCS     _FAIL8     ; Carry Flag should be clear
        LDL     R3,#$01    ; R3=$0001
        SUB     R0,R5,R3   ; Compare R5 to R3
        BNE     _FAIL8

        LDL     R7,#$0f    ; R7=$000f
        LDL     R2,#$0d
        TFR     CCR,R2     ; Negative=1, Zero=1, Overflow=1, Carry=0
        SUBL    R7,#$10    ; R7 - $10 => R7
        BPL     _FAIL8     ; Negative Flag should be set
        BEQ     _FAIL8     ; Zero Flag should be clear
        BVS     _FAIL8     ; Overflow Flag should be clear
        BCC     _FAIL8     ; Carry Flag should be set
        CMPL    R7,#$FF    ; Result should be -1 or $FFFF
        CPCH    R7,#$FF
        BNE     _FAIL8

       ;Test SUBH instruction **************************************************
        LDL     R6,#$11    ; R4=$0011
        LDH     R6,#$81    ; R4=$8111
        LDL     R2,#$0d
        TFR     CCR,R2     ; Negative=1, Zero=1, Overflow=0, Carry=1
        SUBH    R6,#$70    ; R6 - $70 => R6
        BMI     _FAIL8     ; Negative Flag should be clear
        BEQ     _FAIL8     ; Zero Flag should be clear
        BVC     _FAIL8     ; Overflow Flag should be set
        BCS     _FAIL8     ; Carry Flag should be clear
        LDL     R3,#$11    ; R3=$0011
        LDH     R3,#$11    ; R3=$1111
        SUB     R0,R6,R3   ; Compare R6 to R3
        BNE     _FAIL8

        LDL     R6,#$00    ; R6=$0000
        LDH     R6,#$01    ; R6=$0100
        LDL     R2,#$06
        TFR     CCR,R2     ; Negative=0, Zero=1, Overflow=1, Carry=0
        SUBH    R6,#$02    ; R6 - $70 => R6
        BPL     _FAIL8     ; Negative Flag should be set
        BEQ     _FAIL8     ; Zero Flag should be clear
        BVS     _FAIL8     ; Overflow Flag should be clear
        BCC     _FAIL8     ; Carry Flag should be set


       ;Test CMPL instruction **************************************************
        LDL     R5,#$0f    ; R5=$000f
        LDL     R2,#$0b
        TFR     CCR,R2     ; Negative=1, Zero=0, Overflow=1, Carry=1
        CMPL    R5,#$0f    ; R5 - $0f => R5
        BMI     _FAIL8     ; Negative Flag should be clear
        BNE     _FAIL8     ; Zero Flag should be set
        BVS     _FAIL8     ; Overflow Flag should be clear
        BCS     _FAIL8     ; Carry Flag should be clear

        LDL     R7,#$0f    ; R7=$000f
        LDL     R2,#$07
        TFR     CCR,R2     ; Negative=0, Zero=1, Overflow=1, Carry=1
        CMPL    R7,#$10    ; R7 - $10 => R7
        BPL     _FAIL8     ; Negative Flag should be set
        BEQ     _FAIL8     ; Zero Flag should be clear
        BVS     _FAIL8     ; Overflow Flag should be clear
        BCC     _FAIL8     ; Carry Flag should be set


       ;Test CPCH instruction **************************************************
        LDL     R5,#$00    ; R5=$0000
        LDH     R5,#$01    ; R5=$0001
        LDL     R2,#$0f
        TFR     CCR,R2     ; Negative=1, Zero=1, Overflow=1, Carry=1
        CPCH    R5,#$00    ; R5 - $00 - carryflag => nowhere
        BMI     _FAIL8     ; Negative Flag should be clear
        BNE     _FAIL8     ; Zero Flag should be set
        BVS     _FAIL8     ; Overflow Flag should be clear
        BCS     _FAIL8     ; Carry Flag should be clear
        LDL     R2,#$06
        TFR     CCR,R2     ; Negative=0, Zero=1, Overflow=1, Carry=0
        CPCH    R5,#$02    ; R5 - $00 - carryflag => nowhere
        BPL     _FAIL8     ; Negative Flag should be set
        BEQ     _FAIL8     ; Zero Flag should be clear
        BVS     _FAIL8     ; Overflow Flag should be clear
        BCC     _FAIL8     ; Carry Flag should be set


       ;Test ADDH instruction **************************************************
        LDL     R5,#$0f    ; R5=$000f
        LDH     R5,#$70    ; R5=$700f
        LDL     R2,#$0e
        TFR     CCR,R2     ; Negative=1, Zero=1, Overflow=1, Carry=0
        ADDH    R5,#$a0    ; R5 + $a0 => R5
        BMI     _FAIL8     ; Negative Flag should be clear
        BEQ     _FAIL8     ; Zero Flag should be clear
        BVS     _FAIL8     ; Overflow Flag should be clear
        BCC     _FAIL8     ; Carry Flag should be set
        LDL     R3,#$0f    ; R3=$000f
        LDH     R3,#$10    ; R3=$100f
        SUB     R0,R5,R3   ; Compare R5 to R3
        BNE     _FAIL8

        LDL     R2,#$07
        TFR     CCR,R2     ; Negative=0, Zero=1, Overflow=1, Carry=1
        ADDH    R5,#$70    ; R5 + $70 => R5
        BPL     _FAIL8     ; Negative Flag should be set
        BEQ     _FAIL8     ; Zero Flag should be clear
        BVC     _FAIL8     ; Overflow Flag should be set
        BCS     _FAIL8     ; Carry Flag should be clear
        LDL     R3,#$0f    ; R3=$000f
        LDH     R3,#$80    ; R3=$800f
        SUB     R0,R5,R3   ; Compare R5 to R3
        BNE     _FAIL8


       ;Test ADDL instruction **************************************************
        LDL     R4,#$ff    ; R4=$00ff
        LDH     R4,#$70    ; R4=$70ff
        LDL     R2,#$0e
        TFR     CCR,R2     ; Negative=1, Zero=1, Overflow=1, Carry=0
        ADDL    R4,#$01    ; R4 + $01 => R4
        BMI     _FAIL8     ; Negative Flag should be clear
        BEQ     _FAIL8     ; Zero Flag should be clear
        BVS     _FAIL8     ; Overflow Flag should be clear
        BCC     _FAIL8     ; Carry Flag should be set
        LDL     R5,#$00    ; R5=$0000
        LDH     R5,#$71    ; R5=$7100
        SUB     R0,R4,R5   ; Compare R4 to R5
        BNE     _FAIL8

        LDL     R4,#$8e    ; R4=$008e
        LDH     R4,#$7f    ; R4=$7f8e
        LDL     R2,#$0c
        TFR     CCR,R2     ; Negative=1, Zero=1, Overflow=0, Carry=0
        ADDL    R4,#$81    ; R4 + $81 => R4
        BPL     _FAIL8     ; Negative Flag should be set
        BEQ     _FAIL8     ; Zero Flag should be clear
        BVC     _FAIL8     ; Overflow Flag should be set
        BCC     _FAIL8     ; Carry Flag should be set
        LDL     R6,#$0f    ; R6=$000f
        LDH     R6,#$80    ; R6=$800f
        SUB     R0,R4,R6   ; Compare R4 to R6
        BNE     _FAIL8


_END_8
        LDL     R2,#$00    ; Sent Message to Testbench Check Point Register
        LDH     R2,#$80
        LDL     R3,#$10
        STB     R3,(R2,#0)

        SIF
        RTS

_FAIL8
        LDL     R2,#$00    ; Sent Message to Testbench Error Register
        LDH     R2,#$80
        LDL     R3,#$10
        STB     R3,(R2,#4)

        SIF
        RTS


;-------------------------------------------------------------------------------
;   Test Load and Store instructions
;-------------------------------------------------------------------------------
_START9
        LDL     R2,#$00    ; Sent Message to Testbench Check Point Register
        LDH     R2,#$80
        LDL     R3,#$11    ; Checkpoint Value
        STB     R3,(R2,#0)
        LDL     R3,#$09    ; Thread Value
        STB     R3,(R2,#2) ; Send Message to clear Testbench interrupt register

        LDL     R1,#$aa    ; R1=$00aa
        LDH     R1,#$7f    ; R1=$7faa
        LDL     R2,#$55    ; R2=$0055
        LDH     R2,#$6f    ; R2=$6f55
        LDL     R3,#$66    ; R3=$0066
        LDH     R3,#$5f    ; R3=$5f66
        LDL     R7,#$ff    ; R7=$00ff
        LDH     R7,#$ff    ; R7=$ffff

       ;Test STB/LDB instruction ***********************************************
        STB     R1,(R0,#$00)    ;
        STB     R2,(R0,#$01)    ;
        STB     R3,(R0,#$1f)    ;
        LDL     R4,#$00         ; R4=$0000
        LDB     R5,(R4,#$00)    ;
        LDB     R6,(R4,#$01)    ;
        LDB     R7,(R4,#$1f)    ;
        CMPL    R5,#$aa         ;
        BNE     _FAIL9
        CMPL    R6,#$55         ;
        BNE     _FAIL9
        CMPL    R7,#$66         ;
        BNE     _FAIL9
        LDL     R6,#$66         ; R6=$0066
        CMP     R6,R7           ; Make sure the high byte has been cleared
        BNE     _FAIL9

       ;Test STW/LDW instruction ***********************************************
        STW     R1,(R0,#$04)    ; Should be even offsets
        STW     R2,(R0,#$06)    ;
        STW     R3,(R0,#$0a)    ;
        LDL     R4,#$00         ; R4=$0000
        LDL     R5,#$00         ; R5=$0000
        LDL     R6,#$00         ; R6=$0000
        LDL     R7,#$00         ; R7=$0000
        LDW     R5,(R4,#$04)    ;
        LDW     R6,(R4,#$06)    ;
        LDW     R7,(R4,#$0a)    ;
        CMP     R1,R5           ;
        BNE     _FAIL9
        CMP     R2,R6           ;
        BNE     _FAIL9
        CMP     R3,R7           ;
        BNE     _FAIL9

       ;Test STB/LDB instruction ***********************************************
        LDL     R1,#$cc    ; R1=$00cc
        LDH     R1,#$1f    ; R1=$1f66
        LDL     R2,#$99    ; R2=$0099
        LDH     R2,#$2f    ; R2=$2f99

        LDL     R4,#$20         ; R4=$0020 - Base Address
        LDL     R5,#$02         ; R5=$0002 - even offset
        LDL     R6,#$07         ; R6=$0007 - odd offset
        STB     R1,(R4,R5)      ;
        STB     R2,(R4,R6)      ;
        LDB     R5,(R4,R5)      ;
        LDB     R6,(R4,R6)      ;
        CMPL    R5,#$cc         ;
        BNE     _FAIL9
        LDL     R3,#$99         ; R3=$0099
        CMP     R3,R6           ; Make sure the high byte has been cleared
        BNE     _FAIL9

       ;Test STW/LDW instruction ***********************************************
        LDL     R1,#$cc    ; R1=$00cc
        LDH     R1,#$1f    ; R1=$1f66
        LDL     R2,#$99    ; R2=$0099
        LDH     R2,#$2f    ; R2=$2f99

        LDL     R4,#$30         ; R3=$0030 - Base Address
        LDL     R5,#$02         ; R5=$0002
        LDL     R6,#$08         ; R6=$0008
        STW     R1,(R4,R5)      ;
        STW     R2,(R4,R6)      ;
        LDW     R5,(R4,R5)      ;
        LDW     R6,(R4,R6)      ;
        CMP     R5,R1           ;
        BNE     _FAIL9
        CMP     R6,R2           ;
        BNE     _FAIL9

       ;Test STB/LDB instruction ***********************************************
        LDL     R1,#$33    ; R1=$0033
        LDH     R1,#$1f    ; R1=$1f33
        LDL     R2,#$55    ; R2=$0055
        LDH     R2,#$2f    ; R2=$2f55

        LDL     R4,#$40         ; R4=$0040 - Base Address
        LDL     R5,#$02         ; R5=$0002 - even offset
        LDL     R6,#$07         ; R6=$0007 - odd offset
        STB     R1,(R4,R5+)     ;
        STB     R2,(R4,R6+)     ;
        CMPL    R5,#$03         ; Test for 1 byte increment
        BNE     _FAIL9
        CMPL    R6,#$08         ; Test for 1 byte increment
        BNE     _FAIL9
        LDB     R3,(R4,-R5)     ;
        LDB     R7,(R4,-R6)     ;
        CMPL    R5,#$02         ; Test for 1 byte decrement
        BNE     _FAIL9
        CMPL    R6,#$07         ; Test for 1 byte decrement
        BNE     _FAIL9
        CMPL    R3,#$33         ;
        BNE     _FAIL9
        LDL     R3,#$55         ; R3=$0055
        CMP     R3,R7           ; Make sure the high byte has been cleared
        BNE     _FAIL9

       ;Test STB/LDB instruction ***********************************************
        LDL     R1,#$66    ; R1=$0066
        LDH     R1,#$1f    ; R1=$1f66
        LDL     R2,#$99    ; R2=$0099
        LDH     R2,#$2f    ; R2=$2f99

        LDL     R4,#$50         ; R4=$0050 - Base Address
        LDL     R5,#$04         ; R5=$0004 - even offset
        LDL     R6,#$09         ; R6=$0009 - odd offset
        STB     R1,(R4,-R5)     ;
        STB     R2,(R4,-R6)     ;
        CMPL    R5,#$03         ; Test for 1 byte decrement
        BNE     _FAIL9
        CMPL    R6,#$08         ; Test for 1 byte decrement
        BNE     _FAIL9
        LDB     R3,(R4,R5+)     ;
        LDB     R7,(R4,R6+)     ;
        CMPL    R5,#$04         ; Test for 1 byte increment
        BNE     _FAIL9
        CMPL    R6,#$09         ; Test for 1 byte increment
        BNE     _FAIL9
        CMPL    R3,#$66         ;
        BNE     _FAIL9
        LDL     R3,#$99         ; R3=$0099
        CMP     R3,R7           ; Make sure the high byte has been cleared
        BNE     _FAIL9

       ;Test STW/LDW instruction ***********************************************
        LDL     R1,#$aa         ; R1=$00aa
        LDH     R1,#$1f         ; R1=$1faa
        LDL     R2,#$cc         ; R2=$00cc
        LDH     R2,#$2f         ; R2=$2fcc

        LDL     R4,#$60         ; R4=$0060 - Base Address
        LDL     R5,#$02         ; R5=$0002 - even offset
        LDL     R6,#$08         ; R6=$0008
        STW     R1,(R4,R5+)     ;
        STW     R2,(R4,R6+)     ;
        CMPL    R5,#$04         ; Test for 2 byte increment
        BNE     _FAIL9
        CMPL    R6,#$0a         ; Test for 2 byte increment
        BNE     _FAIL9
        LDW     R3,(R4,-R5)     ;
        LDW     R7,(R4,-R6)     ;
        CMPL    R5,#$02         ; Test for 2 byte decrement
        BNE     _FAIL9
        CMPL    R6,#$08         ; Test for 2 byte decrement
        BNE     _FAIL9
        CMP     R1,R3           ;
        BNE     _FAIL9
        CMP     R2,R7           ;
        BNE     _FAIL9

       ;Test STW/LDW instruction ***********************************************
        LDL     R1,#$66         ; R1=$0066
        LDH     R1,#$99         ; R1=$9966
        LDL     R2,#$33         ; R2=$0033
        LDH     R2,#$75         ; R2=$7533

        LDL     R4,#$80         ; R4=$0080 - Base Address
        LDL     R5,#$02         ; R5=$0002 - even offset
        LDL     R6,#$08         ; R6=$0008
        STW     R1,(R4,-R5)     ;
        STW     R2,(R4,-R6)     ;
        CMPL    R5,#$00         ; Test for 2 byte increment
        BNE     _FAIL9
        CMPL    R6,#$06         ; Test for 2 byte increment
        BNE     _FAIL9
        LDW     R3,(R4,R5+)     ;
        LDW     R7,(R4,R6+)     ;
        CMPL    R5,#$02         ; Test for 2 byte decrement
        BNE     _FAIL9
        CMPL    R6,#$08         ; Test for 2 byte decrement
        BNE     _FAIL9
        CMP     R1,R3           ;
        BNE     _FAIL9
        CMP     R2,R7           ;
        BNE     _FAIL9

_END_9
        LDL     R2,#$00    ; Sent Message to Testbench Check Point Register
        LDH     R2,#$80
        LDL     R3,#$12
        STB     R3,(R2,#0)

        SIF
        RTS

_FAIL9
        LDL     R2,#$04    ; Sent Message to Testbench Error Register
        LDH     R2,#$80
        LDL     R3,#$12
        STB     R3,(R2,#0)

        SIF
        RTS


;-------------------------------------------------------------------------------
;   Test Semaphore instructions
;-------------------------------------------------------------------------------
_START10
        LDL     R2,#$00    ; Sent Message to Testbench Check Point Register
        LDH     R2,#$80
        LDL     R3,#$13    ; Checkpoint Value
        STB     R3,(R2,#0)
        LDL     R3,#$0a    ; Thread Value
        STB     R3,(R2,#2) ; Send Message to clear Testbench interrupt register

        LDL     R1,#$5     ; R1=$0005

       ;Test SSEM instruction **************************************************
        SSEM    #7      ; semaphores
        BCC     _FAIL10 ; Should be set
        SSEM    R1      ; semaphores
        BCC     _FAIL10 ; Should be set

        SSEM    #6      ; semaphore has been set by host
        BCS     _FAIL10 ; Should be clear

        CSEM    #7      ; semaphore
        CSEM    R1      ; semaphore #5
                        ; Host will test that these semaphores are clear

        SSEM    #3      ; set this semaphore for the host to test


_END_10
        LDL     R2,#$00    ; Sent Message to Testbench Check Point Register
        LDH     R2,#$80
        LDL     R3,#$14
        STB     R3,(R2,#0)

        SIF
        RTS

_FAIL10
        LDL     R2,#$04    ; Sent Message to Testbench Error Register
        LDH     R2,#$80
        LDL     R3,#$14
        STB     R3,(R2,#0)

        SIF
        RTS


;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------


;empty line

BACK_


        SIF     R7
        BRK

        ORG     $8000 ; Special Testbench Addresses
_BENCH  DS.W    8




