#include "hardware.h"
.text
.global fllInit                         ; SW FLL to init DCO/SMCLK -frequency
        .type   fllInit, @function
fllInit:
        mov.b   #BCSCTL1_FLL, &BCSCTL1  ; Init basic clock control reg 1
        mov.b   #BCSCTL2_FLL, &BCSCTL2  ; Init basic clock control reg 2
        mov     #TACTL_FLL, &TACTL      ; SMCLK is TA-clock / Timer stopped
        bis     #MC1, &TACTL            ; Start timer: Continuos Mode
        mov     #CCTL2_FLL, &CCTL2      ; Init CCR2 and Clear capture flag

.Lwait0:bit     #CCIFG, &CCTL2          ; Test/Wait for capture flag
        jz      .Lwait0                 ; May be used with INT / LPM0 later ?
        mov     &CCR2, r15              ; Store CCR2 init-value
        bic     #CCIFG, &CCTL2          ; Clear capture flag
.Lwait1:bit     #CCIFG, &CCTL2          ; Test/Wait for capture flag
        jz      .Lwait1                 ; May be used with INT / LPM0 later ?
        bic     #CCIFG, &CCTL2          ; Clear capture flag
        mov.b   &BCSCTL1, r14           ; Store current Rsel value
        bic.b   #0x0f8, r14             ; Mask for Rsel bits
        mov.b   &DCOCTL, r13            ; Store current DCO value

.LfllUP:cmp.b   #DCOCTL_MAX, r13        ; Needs Rsel to be increased ?
        jne     .LfllDN                 ; No
        cmp.b   #7, r14                 ; Is max Rsel already selected ?
        jge     .LfllER                 ; Yes, Rsel can not be increased
        inc.b   &BCSCTL1                ; Increase Rsel
        jmp     .LfllRx                 ; Test DCO again

.LfllDN:cmp.b   #DCOCTL_MIN, r13        ; Needs Rsel to be decreased ?
        jne     .LfllCP                 ; No
        cmp.b   #0, r14                 ; Is min Rsel already selected ?
        jeq     .LfllER                 ; Yes, Rsel can not be increased
        dec.b   &BCSCTL1                ; Decrease Rsel
.LfllRx:
	mov.b   #60h, &DCOCTL           ; Center DCO (may be optimized later ?)
        jmp     .Lwait0                 ; Test DCO again
.LfllCP:
        mov     &CCR2, r12              ; Read captured value
        sub     r15, r12                ; Subtract last captured value
        mov     &CCR2, r15              ; Store CCR2 value for next pass
        cmp     #DCO_FSET, r12          ; DCO_FSET= SMCLK/(32768/4)
        jl      .LfllI                  ;
        jeq     .LfllOK                 ;
.LfllD: dec.b   &DCOCTL                 ; Decrement value
        jmp     .Lwait0                 ;
.LfllI: inc.b   &DCOCTL                 ; Increment value
        jmp     .Lwait0                 ;

.LfllER:                                ; error, currently ingnored
.LfllOK:clr     &CCTL2                  ; stop CCR2
        ret                             ;
