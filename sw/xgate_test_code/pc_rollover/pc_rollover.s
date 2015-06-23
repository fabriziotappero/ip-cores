; 345678901234567890123456789012345678901234567890123456789012345678901234567890
; PC underflow/overflow test for xgate RISC processor core
; Bob Hayes - Jan 21 2012


        CPU     XGATE

;-------------------------------------------------------------------------------
;   Error Code - Program should never get here
;-------------------------------------------------------------------------------
        ORG     $0000 ;
_START_OF_MEM
        LDL     R2,#$04    ; Sent Message to Testbench Error Register
        LDH     R2,#$80
        LDL     R3,#$08
        STB     R3,(R2,#0)

        SIF
        RTS

        BRA     _START_OF_MEM  ; Final hex code for test will need hack
        BRA     _START_OF_MEM  ; Final hex code for test will need hack
        BRA     _START_OF_MEM  ; Final hex code for test will need hack
        BRA     _START_OF_MEM  ; Final hex code for test will need hack
        BRA     _START_OF_MEM  ; Final hex code for test will need hack
        BRA     _START_OF_MEM  ; Final hex code for test will need hack
        BRA     _START_OF_MEM  ; Final hex code for test will need hack



;-------------------------------------------------------------------------------
;   Backward branch past #$0000
;-------------------------------------------------------------------------------
        ORG     $0200 ;
_START3
        LDL     R2,#$00    ; Sent Message to Testbench Check Point Register
        LDH     R2,#$80
        LDL     R3,#$01
        STB     R3,(R2,#0)
        STB     R3,(R2,#2) ; Send Message to clear Testbench interrupt register

        BRA     _START_OF_MEM  ; Final hex code for test will need hack

        
;-------------------------------------------------------------------------------
; Dummy space to store initial variables for default interrupts
        ORG     $2000 ; with comment

V_PTR   DC.W    $0000  ; All Variable Pointers are set to here

        DC.W    $AAAA
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
        ORG     $8800   ; $8000 reserved for testbench
        DC.W    $5555   ; reserve two words at channel 0
        DC.W    $AAAA
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
        DC.W    _ERROR  ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 5
        DC.W    _ERROR  ; point to start address
        DC.W    V_PTR   ; point to initial variables
        ; channel 6
        DC.W    _ERROR   ; point to start address
        DC.W    V_PTR   ; point to initial variables

;-------------------------------------------------------------------------------
        ORG     $fe00
        DC.W    $3c3c
        DC.W    $9696
        DC.W    $a5a5
        DC.W    $5a5a
        DC.W    $7878
        DC.W    $8181

;-------------------------------------------------------------------------------
;   Foward branch past #$ffff
;-------------------------------------------------------------------------------
        ORG     $FFC0 ;
_START2
        LDL     R2,#$00    ; Sent Message to Testbench Check Point Register
        LDH     R2,#$80
        LDL     R3,#$01
        STB     R3,(R2,#0)
        STB     R3,(R2,#2) ; Send Message to clear Testbench interrupt register

        BRA     _END_OFCODE  ; Final hex code for test will need hack

        
;-------------------------------------------------------------------------------
;   Test PC single step past #$ffff
;-------------------------------------------------------------------------------
        ORG     $FFE8 ;
_START
        LDL     R2,#$00    ; Sent Message to Testbench Check Point Register
        LDH     R2,#$80
        LDL     R3,#$01
        STB     R3,(R2,#0)
        STB     R3,(R2,#2) ; Send Message to clear Testbench interrupt register

        NOP
        NOP
        NOP
        NOP
        NOP
_END_OFCODE
        NOP
        

