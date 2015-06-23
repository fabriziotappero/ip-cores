;*******************************************************************************
; tb1.asm -- light8080 core test bench 1: interrupt & halt test
;*******************************************************************************
; Should be used with test bench template vhdl\test\tb_template.vhdl
; Assembler format compatible with TASM for DOS and Linux.
;*******************************************************************************
; This program will test a few different interrupt vectors and the interrupt
; enable/disable flag, but not exhaustively. 
; Besides, it will not test long intr assertions (more than 1 cycle). 
;*******************************************************************************

; DS pseudo-directive; reserve space in bytes, without initializing it
#define ds(n)    \.org $+n

; OUTing some value here will trigger intr in the n-th cycle from the end of 
; the 'out' instruction. For example, writing a 0 will trigger intr in the 1st 
; cycle of the following instruction, and so on.
intr_trigger: .equ 11h
; The value OUTput to this address will be used as the 'interrupt source' when
; the intr line is asserted. In the inta acknowledge cycle, the simulated 
; interrupt logic will feed the CPU the instruction at memory address
; 40h+source*4. See vhdl\test\tb_template.vhdl for details.
intr_source:  .equ 10h
; The value OUTput to this port is the number of cycles the intr signal will 
; remain high after being asserted. By default this is 1 cycle.
intr_width:   .equ 12h
; OUTing something here will stop the simulation. A 0x055 will signal a 
; success, a 0x0aa a failure.
test_outcome: .equ 20h

;*******************************************************************************

        .org    0H
        jmp     start           ; skip the rst address area
        
        ; used to test that RST works
        .org    20H
        adi     1H
        ei
        ret
        
        ; used to test the RST instruction as intr vector
        .org    28H
        inr     a
        ei
        ret
                
        ;***** simulated interrupt vectors in area 0040h-005fh *****************
        
        .org    40h+(0*4)       ; simulated interrupt vector 0 
        inr     a
        .org    40h+(1*4)       ; simulated interrupt vector 1
        rst     5
        .org    40h+(2*4)       ; simulated interrupt vector 2
        inx     h
        .org    40h+(3*4)       ; simulated interrupt vector 3
        mvi     a,42h
        .org    40h+(4*4)       ; simulated interrupt vector 4
        lxi     h,1234h
        .org    40h+(5*4)       ; simulated interrupt vector 5
        jmp     test_jump
        .org    40h+(6*4)       ; simulated interrupt vector 6
        call    test_call
        .org    40h+(7*4)       ; simulated interrupt vector 7
        call    shouldnt_trigger
                
        
        ;***** program entry point *********************************************
                
start:  .org    60H
        lxi     sp,stack
        
        ; first of all, make sure the RST instruction works, we have a valid
        ; simulated stack, etc.
        mvi     a,13h
        rst     4               ; this should add 1 to ACC
        cpi     14h
        jnz     fail
        
        ; now we'll try a few different interrupt vectors (single byte and 
        ; multi-byte). Since interrupts are disabled upon acknowledge, we have
        ; to reenable them after every test.
        
        ; try single-byte interrupt vector: INR A
        mvi     a,0
        out     intr_source
        ei
        mvi     a,014h
        out     intr_trigger
        mvi     a,027h
        nop                       ; the interrupt will hit in this nop area
        nop
        nop
        nop
        cpi     028h
        jnz     fail
        
        ; another single-byte vector: RST 5
        mvi     a,1
        out     intr_source
        ei
        mvi     a,014h
        out     intr_trigger      ; the interrupt vector will do a rst 5, and
        mvi     a,020h            ; the rst routine will add 1 to the ACC 
        nop                       ; and reenable interrupts
        nop
        nop
        nop
        cpi     021h
        jnz     fail
        
        ; another single-byte code: INX H
        lxi     h,13ffh
        mvi     a,2
        out     intr_source
        ei
        mvi     a,4
        out     intr_trigger
        nop
        nop
        mov     a,l
        cpi     0H
        jnz     fail
        mov     a,h
        cpi     14h
        jnz     fail
        
        ; a two-byte instruction: mvi a, 42h
        mvi     a,3
        out     intr_source
        ei
        mvi     a,4
        out     intr_trigger
        nop
        nop
        cpi     42h
        jnz     fail
        
        ; a three-byte instruction: lxi h,1234h
        mvi     a,4
        out     intr_source
        ei
        mvi     a,4
        out     intr_trigger
        nop
        nop
        mov     a,h
        cpi     12h
        jnz     fail
        mov     a,l
        cpi     34h
        jnz     fail
        
        ; a 3-byte jump: jmp test_jump
        ; if this fails, the test will probably derail
        mvi     a,5
        out     intr_source
        ei
        mvi     a,4
        out     intr_trigger
        nop
        nop
comeback:
        cpi     79h
        jnz     fail

        ; a 3-byte call: call test_call
        ; if this fails, the test will probably derail
        mvi     a,6
        out     intr_source
        ei
        mvi     a,4
        out     intr_trigger
        inr     a
        ; the interrupt will come back here, hopefully
        nop
        cpi     05h
        jnz     fail
        mov     a,b
        cpi     19h
        jnz     fail
        
        ; now, with interrupts disabled, make sure interrupts are ignored
        di
        mvi     a,07h           ; source 7 catches any unwanted interrupts
        out     intr_source
        mvi     a,04h
        out     intr_trigger
        nop
        nop                     
        nop
        
        ; Ok. So far we have tested only 1-cycle intr assertions. Now we'll
        ; see what happens when we leave intr asserted for a long time (as would
        ; happen intr was used for single-step debugging, for instance)
        
        ; try single-byte interrupt vector (INR A)
        mvi     a, 80
        out     intr_width
        mvi     a,1
        out     intr_source
        ei
        mvi     a,014h
        out     intr_trigger
        mvi     a,027h
        nop                       ; the interrupts will hit in this nop area
        nop
        inr     a
        nop
        nop
        inr     a
        nop
        nop
        nop
        nop
        nop
        cpi     02bh
        jnz     fail        
        
        
        ; finished, run into the success outcome code

success:
        mvi     a,55h
        out     test_outcome
        hlt
fail:   mvi     a,0aah
        out     test_outcome
        hlt        
         
test_jump:
        mvi     a,79h
        jmp     comeback         

test_call:
        mvi     b,19h
        ret
                
; called when an interrupt has been acknowledged that shouldn't have 
shouldnt_trigger:
        jmp     fail
        
        ; data space
        ds(64)
stack:  ds(2)
        .end
        