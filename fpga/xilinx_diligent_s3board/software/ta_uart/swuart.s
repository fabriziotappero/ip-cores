
#include "hardware.h"

;variables
.data
;        .comm   rxdata,1,1              ;char var
        .comm   rxshift,1,1             ;char var
        .comm   rxbit,2,2               ;short var, aligned

.text

;interrupt(TIMERA0_VECTOR)               ;register interrupt vector
;interrupt handler to receive as Timer_A UART
.global ccr0                            ;place a label afterwards so
ccr0:                                   ;that it is used in the listing
        add     &rxbit, r0
        jmp     .Lrxstart               ;start bit
        jmp     .Lrxdatabit             ;D0
        jmp     .Lrxdatabit             ;D1
        jmp     .Lrxdatabit             ;D2
        jmp     .Lrxdatabit             ;D3
        jmp     .Lrxdatabit             ;D4
        jmp     .Lrxdatabit             ;D5
        jmp     .Lrxdatabit             ;D6
;        jmp     .Lrxlastbit             ;D7 that one is following anyway
        
.Lrxlastbit:                            ;last bit, handle byte
        bit     #SCCI, &CCTL0           ;read last bit
        rrc.b   &rxshift                 ;and save it
        clr     &rxbit                   ;reset state
        mov     #CCIE|CAP|CM_2|CCIS_1|SCS, &CCTL0   ;restore capture mode
;        mov.b   &rxshift, &rxdata         ;copy received data
;        bic     #CPUOFF|OSCOFF|SCG0|SCG1, 0(r1) ;exit all lowpower modes
        ;here you might do other things too, like setting a flag
        ;that the wakeup comes from the Timer_A UART. however
        ;it should not take longer than one bit time, otherwise
        ;charcetrs will be lost.
;        reti
        mov.b   &rxshift, r15           ;return received data
        ret

.Lrxstart:                              ;startbit, init
        clr     &rxshift                 ;clear input buffer
        add     #(BAUD/2), &CCR0        ;startbit + 1.5 bits -> first bit
        mov     #CCIE|CCIS_1|SCS, &CCTL0;set compare mode, sample bits
        jmp     .Lrxex                  ;set state,...

.Lrxdatabit:                            ;save databit
        bit     #SCCI, &CCTL0           ;measure databit
        rrc.b   &rxshift                 ;rotate in databit

.Lrxex: add     #BAUD, &CCR0            ;one bit delay
        incd    &rxbit                  ;setup next state
;        reti
        mov     #0xffff, r15            ;return 0xffff
        ret

; void serPutc(char)
;use an other Capture/Compare than for receiving (full duplex).
;this one is without interrupts and OUTMOD, because only
;this way P1.1 can be used. P1.1 is prefered because the
;BSL is on that pin too.
.global putchar
        .type putchar, @function
putchar:                                ;send a byte
        mov     #0, &CCTL1              ;select compare mode
        mov     #10, r13                ;ten bits: Start, 8 Data, Stop
        rla     r15                     ;shift in start bit (0)
        bis     #0x0200, r15            ;set tenth bit (1), thats the stop bit
        mov     &TAR, &CCR1             ;set up start time
.Lt1lp: add     #BAUD, &CCR1            ;set up for one bit
        rrc     r15                     ;shift data trough carry
        jc      .Lt1                    ;test carry bit
.Lt0:   bic.b   #TX, &P1OUT             ;generate pulse
        jmp     .Ltc                    ;
.Lt1:   bis.b   #TX, &P1OUT             ;just use the same amount of time as for a zero
        jmp     .Ltc                    ;
.Ltc:   bit     #CCIFG, &CCTL1          ;wait for compare
        jz      .Ltc                    ;loop until the bit is set
        bic     #CCIFG, &CCTL1          ;clear for next loop
        dec     r13                     ;decrement bit counter
        jnz     .Lt1lp                  ;loop until all bits are transmitted
        ret
