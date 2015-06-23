; 345678901234567890123456789012345678901234567890123456789012345678901234567890
; Interrupt test for xgate RISC processor core
; Bob Hayes - May 11 2010


        CPU     XGATE

        ORG     $fe00
        DS.W    2       ; reserve two words at channel 0
        ; channel 1
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 2
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 3
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 4
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 5
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 6
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 7
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 8
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 9
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 10
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 11
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 12
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 13
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 14
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 15
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 16
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 17
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 18
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 19
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 20
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 21
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 22
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 23
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 24
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 25
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 26
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 27
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 28
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 29
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 30
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 31
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 32
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 33
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 34
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 35
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 36
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 37
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 38
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 39
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 40
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 41
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 42
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 43
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 44
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 45
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 46
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 47
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 48
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 49
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 50
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 51
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 52
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 53
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 54
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 55
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 56
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 57
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 58
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 59
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 60
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 61
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 62
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 63
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 64
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 65
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 66
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 67
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 68
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 69
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 70
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 71
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 72
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 73
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 74
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 75
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 76
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 77
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 78
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 79
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 80
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 81
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 82
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 83
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 84
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 85
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 86
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 87
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 88
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 89
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 80
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 81
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 82
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 83
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 84
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 85
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 86
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 87
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 88
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 89
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 100
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 101
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 102
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 103
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 104
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 105
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 106
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 107
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 108
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 109
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 110
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 111
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 112
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 113
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 114
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 115
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 116
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 117
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 118
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 119
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 120
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 121
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 122
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 123
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 124
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 125
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 126
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 127
        DC.W    _IRQn   ; point to start address
        DC.W    V_PTR   ; point to initial variables

        ORG     $2000 ; with comment

V_PTR   DC.W    $0000  ; All Variable Pointers are set to here

        DC.W    END_CODE_
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
;   Test IRQ - All interrupts are pointed here. For proper function the interrupts
;               must be activated in sequential order. The data at address V_PTR
;               holds the last interrupt processed and is incremented and
;               re-stored as part of the interrup service routine.
;-------------------------------------------------------------------------------
_IRQn
        LDL     R2,#$00    ; Sent Message to Testbench Check Point Register
        LDH     R2,#$80    ; R3 = Testbench base address = Checkpoint address
        LDW     R3,(R1,#0) ; Load Checkpoint Value from V_PTR address
        ADDL    R3,#1      ; Increment interrupt number
        STW     R3,(R1,#0) ; Store new value for next interrupt
        STB     R3,(R2,#0) ; Send Checkpoint value

        ;Test Interrupt
        STW     R3,(R2,#$0a)    ; TB_SEMPHORE address - Should be even offsets
_TB_POLL_n
        LDW     R4,(R2,#$0a)    ;
        CMP     R3,R4           ;
        BEQ     _TB_POLL_n

_END_n
        ADDL    R3,#100
        STB     R3,(R2,#0) ; Send Checkpoint value

        SIF
        RTS

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
END_CODE_

        ORG     $8000 ; Special Testbench Addresses
_BENCH  DS.W    16




