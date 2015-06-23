;**************************************************************************
; M16C5x_Tst.ASM
;
; This sample program runs on most all PIC devices.  To ensure 
; proper execution, replace the processor specified in the LIST directive 
; with your target processor.
;
; Program execution starts at location H'50'.  The loop routine executes 
; seven times.  The routines Reduce and Double execute one time for each 
; loop.
;
; After the loop executes seven times, the program repeats execution from 
; the beginning.
;
;
; Variable    Initial    Description
;              Value
;--------------------------------------------------------------------------
; CountDown     255      Decreases to 128 by subtracting Doubler
; Doubler        1       Increases to 128 by adding to itself
; OuterLoop      7       Decrements by one to 0
;
;           
; The program generates the following values:
;
; Cycle #    CountDown   Doubler     OuterLoop
;   0           255           1           7
;   1           254           2           6
;   2           252           4           5
;   3           248           8           4
;   4           240          16           3
;   5           224          32           2  
;   6           192          64           1   
;   7           128         128           0  
;
;**************************************************************************

        LIST P=16F59, R=DEC

;--------------------------------------------------------------------------
;   Set ScratchPadRam here.  If you are using a PIC16C5X device, use: 
;ScratchPadRam EQU     0x10
;   Otherwise, use:
;ScratchPadRam EQU     0x20
;--------------------------------------------------------------------------

ScratchPadRam   EQU     0x10

;--------------------------------------------------------------------------
; Variables
;--------------------------------------------------------------------------

CountDown       EQU     ScratchPadRam+0
Doubler         EQU     ScratchPadRam+1
OuterLoop       EQU     ScratchPadRam+2


;--------------------------------------------------------------------------
; Program Code
;--------------------------------------------------------------------------
;--------------------------------------------------------------------------
;   Set the reset vector here.  If you are using a PIC16C5X device, use:
;               ORG     <last program memory location>
;   Otherwise, use:
;               ORG     0
;--------------------------------------------------------------------------

                ORG     H'7FF'       
                GOTO    Start

;--------------------------------------------------------------------------
; Main Program
;--------------------------------------------------------------------------

                ORG     H'50'

Start
                MOVLW   255             ;   Initialize the variables to
                MOVWF   CountDown       ; their starting values.
                MOVLW   1               
                MOVWF   Doubler      
                MOVLW   7
                MOVWF   OuterLoop    
Loop                    
                CALL    Reduce          ;   Perform the inner portion of
                DECFSZ  OuterLoop,f     ; the loop.
                GOTO    Loop   

                GOTO    Start           ;   Repeat the whole thing.

;--------------------------------------------------------------------------
Reduce
                SWAPF   Doubler,f       ;   Reduce CountDown by the
                SWAPF   Doubler,w       ; value of Doubler.  Then
                SWAPF   Doubler,f       ; call the doubling routine.
                SUBWF   CountDown,f     
                CALL    Double
                RETLW   0

;--------------------------------------------------------------------------
Double
                SWAPF   Doubler,f       ;   Double the value of Doubler
                SWAPF   Doubler,w       ; by adding it to itself.
                SWAPF   Doubler,f 
                ADDWF   Doubler,f       
                RETLW   0

                END

