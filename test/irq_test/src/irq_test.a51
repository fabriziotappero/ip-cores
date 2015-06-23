; irq_test.a51 -- Basic interrupt service test.
;
; This program is only meant to work in the simulation test bench, because it
; requires the external interrupt inputs to be wired to the P1 output port.
; They are in the simulation test bench entity but not in the synthesizable
; demo top entity.
;
; Its purpose is to demonstrate the working of the interrupt service logic. No
; actual tests are performed (other than the co-simulation tests), only checks.
;
; This program makes the following assumptions about the MCU configuration:
;
; 1.- Port line P1.0 is wired to external input EXTINT0.0
; 2.- The timer prescaler is set to 20us@50MHz.
;
; NOTE: I am aware that this code is perfectly hideous and nearly useless as a 
; test bench; it will have to do for the time being. I can seldom find quality 
; time for this project...
;-------------------------------------------------------------------------------

        ; Include the definitions for the light52 derivative
        $nomod51
        $include (light52.mcu)
        
ext_irq_ctr     set     060h        ; Incremented by external irq routine
timer_irq_ctr   set     062h        ; Incremented by timer irq routine    
uart_irq_ctr    set     063h        ; Incremented by uart irq routine
irq_test_code   set     064h        ; Selects the behavior of the irq routines

    
        ;-- Macros -------------------------------------------------------------

        ; putc: send character in A to console (UART)
putc    macro   character
        local   putc_loop
        mov     SBUF,character
putc_loop:
        ; This program will only ever run in the simulated environment, where
        ; UART transmission is instantaneous. No need to loop here.
        ;mov     a,SCON
        ;anl     a,#10h
        ;jz      putc_loop
        endm
        
        ; put_crlf: send CR+LF to console
put_crlf macro
        putc    #13
        putc    #10
        endm
    
    
        ;-- Reset & interrupt vectors ------------------------------------------

        org     00h
        ljmp    start               ;
        org     03h
        ljmp    irq_ext
        org     0bh
        ljmp    irq_timer
        org     13h
        ljmp    irq_wrong
        org     1bh
        ljmp    irq_wrong
        org     23h
        ljmp    irq_wrong


        ;-- Main test program --------------------------------------------------
        org     30h
        
        ; Place a few utility routines here at the start so they are reachable 
        ; by CJNE.
        
        ; Did not get expected IRQ: print failure message and block.
fail_expected:
        mov     DPTR,#text3
        call    puts
        mov     IE,#00h
        ajmp    $

        ; Got unexpected IRQ: print failure message and block.
fail_unexpected:
        mov     DPTR,#text1
        call    puts
        mov     IE,#00h
        ajmp    $

        
start:

        mov     IE,#00              ; Disable all interrupts...
        mov     IP,#01              ; ...and set EXTINT as high-priority.
        mov     irq_test_code,#00h  ; Tell irq routines to only inc the counters

        
        ;---- External interrupt test --------------------------------------
        
        ; Basic interrupt test.
        
        ; We'll be asserting the external interrupt request line 0, making
        ; sure the interrupt enable flags work properly. No other interrupt
        ; will be asserted simultaneously or while in the interrupt service
        ; routine.
        
        ; Trigger external IRQ with IRQs disabled, it should be ignored.
        mov     P1,#01h             ; Assert external interrupt line 0...
        nop                         ; ...give the CPU some time to acknowledge
        nop                         ; the interrupt...
        nop
        mov     a,ext_irq_ctr       ; ...and then make sure it hasn't.
        cjne    a,#00,fail_unexpected
        setb    EXTINT0.0           ; Clear external IRQ flag

        ; Trigger timer IRQ with external IRQ enabled but global IE disabled
        mov     IE,#01h             ; Enable external interrupt...
        mov     P1,#01h             ; ...and assert interrupt line.
        nop                         ; Wait a little...
        nop
        nop
        mov     a,ext_irq_ctr       ; ...and make sure the interrupt was NOT
        cjne    a,#00,fail_unexpected   ; serviced.
        setb    EXTINT0.0           ; Clear external IRQ flag

        ; Trigger external IRQ with external and global IRQ enabled
        mov     P1,#00h             ; Clear the external interrupt line...
        mov     IE,#81h             ; ...before enabling interrupts globally.
        mov     ext_irq_ctr,#00     ; Reset the interrupt counter...
        mov     P1,#01h             ; ...and assert the external interrupt.
        nop                         ; Give it some time to be acknowledged...
        nop
        nop
        mov     a,ext_irq_ctr       ; ...and make sure it has been serviced.
        cjne    a,#01,fail_expected
        setb    EXTINT0.0           ; Clear external IRQ flag
        
        ; Somewhat less basic interrupt test: priorities.
        
        ; Here we are going to use the test code byte (irq_test_code) to tell
        ; the interrupt routines what we want them to do. Since we only use two
        ; interrupt routines to test everything, each routine has to perform 
        ; a few different roles.
        ; Basically we want to make sure that the irq priority rules hold:
        ;
        ; A.-Nothing can interrupt a high priority irq routine.
        ; B.- Only a high-priority irq can interrupt a low-priority irq.
        ; C.- Simultaneous irqs get ordered by their vector number.
        ;
        ; Rule C will NOT be tested in this program; and rules B and A get only
        ; the most basic of basic tests.
        
        ; Run test 1: Trigger another external interrupt while serving an 
        ; external interrupt. Since both are high-priority, the timer interrupt 
        ; should be ignored.
        mov     irq_test_code,#01h
        mov     P1,#00h             ; Clear the external interrupt line...
        mov     IE,#83h             ; ...before enabling interrupts globally.
        mov     ext_irq_ctr,#00     ; Reset the interrupt counter...
        mov     P1,#01h             ; ...and assert the external interrupt.
        nop                         ; Give it some time to be acknowledged...
        nop
        mov     a,ext_irq_ctr       ; ...and make sure it has been serviced.
        cjne    a,#01,fail_expected
        setb    EXTINT0.0           ; Clear external IRQ flag

        ; Run test 2: Trigger Timer interrupt while serving an external 
        ; interrupt. Since the Timer irq is low-priority, it should be ignored.
        mov     irq_test_code,#02h
        mov     P1,#00h             ; Clear the external interrupt line...
        mov     IE,#83h             ; ...before enabling interrupts globally.
        mov     ext_irq_ctr,#00     ; Reset the interrupt counter...
        mov     P1,#01h             ; ...and assert the external interrupt.
        nop                         ; Give it some time to be acknowledged...
        nop
        mov     a,ext_irq_ctr       ; ...and make sure it has been serviced.
        cjne    a,#01,fail_expected
        setb    EXTINT0.0           ; Clear external IRQ flag

        ; Run test 3: Trigger interrupts within the timer interrupt service 
        ; routine.
        mov     irq_test_code,#03h
        mov     timer_irq_ctr,#00h
        mov     P1,#00h             ; Clear the external interrupt line...
        mov     IE,#83h             ; ...before enabling interrupts globally.
        mov     ext_irq_ctr,#00     ; Reset the interrupt counter...
        mov     TSTAT,#01           ; Stop timer and clear timer interrupt...
        mov     TH,#00h             ; ...set counter = 000h...
        mov     TL,#00h             ;
        mov     TCH,#00h            ; ...and set Compare register = 0001h...
        mov     TCL,#01h            ;
        mov     TSTAT,#030h         ; ...then start counting.

        mov     r1,#95              ; Wait for the timer IRQ to trigger...
loop_001:
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        djnz    r1,loop_001         ; ...then make sure the timer irq has
        mov     a,timer_irq_ctr     ; been triggered.
        cjne    a,#01h,fail_expected_irq_bridge

        ; End of irq test, print message and continue
        mov     DPTR,#text2
        call    puts

        ;---- Timer test ---------------------------------------------------
        ; Assume the prescaler is set for a 20us count period.
        
        ; All we will do here is make sure the counter changes at the right
        ; time, i.e. 20us after being started. We will NOT test the full
        ; functionality of the timer (not in this version of the test).
        
        ; Note that the irq tests above already assume the timer works... this
        ; test is somewhat redundant.
        
        mov     IE,#000h            ; Disable all interrupts...
                                    ; ...and put timer in
        mov     TSTAT,#00           ; Stop timer...
        mov     TH,#00              ; ...set counter = 0...
        mov     TL,#00              ;
        mov     TCH,#0c3h           ; ...and set Compare register = 50000.
        mov     TCL,#050h           ; (50000 counts = 1 second)
        mov     TSTAT,#030h         ; Start counting.

        ; Ok, now wait for a little less than 20us and make sure TH:TL has not
        ; changed yet.
        mov     r0,#95              ; We need to wait for 950 clock cycles...
loop0:                              ; ...and this is a 10-clock loop
        nop
        djnz    r0,loop0
        mov     a,TH
        cjne    a,#000h,fail_timer_error
        mov     a,TL
        cjne    a,#000h,fail_timer_error
        
        ; Now wait for another 100 clock cycles and make sure TH:TL has already
        ; changed.
        mov     r0,#10              ; We need to wait for 100 clock cycles...
loop1:                              ; ...and this is a 10-clock loop
        nop
        djnz    r0,loop1
        mov     a,TH
        cjne    a,#000h,fail_timer_error
        mov     a,TL
        cjne    a,#001h,fail_timer_error

        ; End of timer test, print message and continue
        mov     DPTR,#text5
        call    puts

        ;-- End of test program, enter single-instruction endless loop
quit:   ajmp    $

fail_expected_irq_bridge:
        jmp     fail_expected_irq

fail_timer_error:
        mov     DPTR,#text4
        call    puts
        mov     IE,#00h
        ajmp    $

        ; End of the test code. Now let's define a few utility routines.

;-- puts: output to UART a zero-terminated string at DPTR ----------------------
puts:
        mov     r0,#00h
puts_loop:
        mov     a,r0
        inc     r0
        movc    a,@a+DPTR
        jz      puts_done

        putc    a
        sjmp    puts_loop
puts_done:
        ret

;-- irq_ext: interrupt routine for external irq lines --------------------------
; Note we don't bother to preserve any registers.
irq_ext:
        mov     P1,#00h             ; Remove the external interrupt request
        mov     EXTINT0,#0ffh       ; Clear all external IRQ flags
        inc     ext_irq_ctr         ; Increment irq counter
        ; Ok, now check the test code byte to see what we have to do here.
        mov     a,irq_test_code
        cjne    a,#00h,irq_ext_0
        
        ; Test 0: Just increment irq counter (already done).
        mov     DPTR,#text0         ; Print IRQ message...
        call    puts
        reti                        ; ...and quit
        
irq_ext_0:
        cjne    a,#02h,irq_ext_1
        ; Test 2: Trigger timer interrupt while in the service routine.
        ; Verify that low-priority interrupts get ignored while in the service 
        ; routine of a high-priority interrupt.
        mov     timer_irq_ctr,#00h
        mov     TSTAT,#01           ; Stop timer and clear timer interrupt...
        mov     TH,#00h             ; ...set counter = 000h...
        mov     TL,#00h             ;
        mov     TCH,#00h            ; ...and set Compare register = 0001h.
        mov     TCL,#01h            ;
        mov     IE,#82h             ; Enable timer interrupt...
        mov     TSTAT,#030h         ; ...and start counting.

        mov     r0,#95               ; Wait for the timer interrupt to trigger...
irq_ext_test0_loop0:
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        djnz    r0,irq_ext_test0_loop0  ; ...the make sure the timer irq has
        mov     a,timer_irq_ctr         ; NOT triggered.
        cjne    a,#00h,fail_unexpected_irq
        reti

irq_ext_1:
        cjne    a,#01h,irq_ext_2
        
        ; Test 1: Trigger external interrupt while in the service routine.
        ; Verify that high-priority interrupts get ignored while in the service 
        ; routine of another high-priority interrupt.
        mov     ext_irq_ctr,#00h
        mov     irq_test_code,#00h
        mov     IE,#81h                 ; ...enable the UART irq...
        mov     P1,#01h                 ; ...and trigger it

        mov     r0,#10                  ; Give time for the irq to trigger...
irq_ext_test2_loop0:
        nop
        djnz    r0,irq_ext_test2_loop0  ; ...the make sure the Timer irq has
        mov     a,ext_irq_ctr           ; NOT triggered.
        cjne    a,#00h,fail_unexpected_irq
        reti

irq_ext_2:
        ; Code byte irq_test_code not used; ignored.
        reti

        
;-- irq_timer: interrupt routine for timer -------------------------------------
; Note we don't bother to preserve any registers.
irq_timer:
        ; Check the test code to see what we have to do here.
        mov     a,irq_test_code
        cjne    a,#03,irq_timer_0
        
        ; Test code 3: interrupts within timer irq service routine.
        
        ; Trigger external interrupt within this irq service routine and make
        ; sure it gets serviced.
        mov     ext_irq_ctr,#00h
        mov     irq_test_code,#00h
        mov     IE,#81h                 ; ...enable the UART irq...
        mov     P1,#01h                 ; ...and trigger it

        mov     r0,#10                  ; Give time for the irq to trigger...
irq_timer_test3_loop0:
        nop
        djnz    r0,irq_timer_test3_loop0  ; ...the make sure the Timer irq has
        mov     a,ext_irq_ctr           ; NOT triggered.
        cjne    a,#01h,fail_expected_irq
        
        ; Ok, now re-trigger the timer interrupt within the timer service
        ; interrupt and make sure the new interrupt is not serviced.
        mov     irq_test_code,#00h
        mov     timer_irq_ctr,#00h
        mov     TSTAT,#01           ; Stop timer and clear timer interrupt...
        mov     TH,#00h             ; ...set counter = 000h...
        mov     TL,#00h             ;
        mov     TCH,#00h            ; ...and set Compare register = 0001h...
        mov     TCL,#01h            ;
        mov     TSTAT,#030h         ; ...then start counting.

        mov     r1,#95              ; Wait for the timer IRQ to trigger...
irq_timer_test3_loop1:
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        djnz    r1,irq_timer_test3_loop1 ; ...then make sure the timer irq has
        mov     a,timer_irq_ctr     ; been ignored.
        cjne    a,#00h,fail_unexpected_irq

        inc     timer_irq_ctr       ; Increment timer interrupt counter...
        mov     TSTAT,#01           ; Stop timer and clear timer interrupt.

        reti

        
irq_timer_0:
        ; Test code 0: increment irq counter.
        ; Just increment the timer irq counter and quit.
        inc     timer_irq_ctr       ; Increment timer interrupt counter...
        mov     TSTAT,#01           ; Stop timer and clear timer interrupt.
        reti                        ; ...and quit.

irq_wrong:
        ajmp    irq_wrong

        ; Utility functions -- error messages to console, etc.
        
        ; Got unexpected IRQ: print failure message and block.
fail_unexpected_irq:
        mov     DPTR,#text1
        call    puts
        mov     IE,#00h
        ajmp    $

        ; Did not get expected IRQ: print failure message and block.
fail_expected_irq:
        mov     DPTR,#text3
        call    puts
        mov     IE,#00h
        ajmp    $

        ; End of the utility routines. Define constant data and we're done.

text0:  db      '<External irq>',13,10,00h,00h
text1:  db      'Unexpected IRQ',13,10,00h,00h
text2:  db      'IRQ test finished, no errors',13,10,0
text3:  db      'Missing IRQ',13,10,0
text4:  db      'Timer error',13,10,0
text5:  db      'Timer test finished, no errors',13,10,0
    
        end
