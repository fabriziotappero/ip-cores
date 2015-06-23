;*******************************************************************************
; soc_tb.asm -- light8080 SoC basic test bench.
;*******************************************************************************
; Should be used with SoC core test bench entity vhdl\test\l80soc_tb.vhdl.
; Assembler format compatible with TASM for DOS and Linux.
;*******************************************************************************
; This program will send a few bytes over a looped-back UART, using the UART 
; interrupt capability and verifying that received and transmitted data match.
; It will then try one of the external interrupts, connected to one of the 
; general purpose outputs.
; This minimal test bench relies on an already tested CPU core to do a 
; This program does not deserve to even be called a 'test' but if if works it 
; will at least rule out many obvious bug in the SoC core.
;*******************************************************************************

; DS pseudo-directive; reserve space in bytes, without initializing it
#define ds(n)    \.org $+n

MASK_RX_IRQ:  .equ 20h
MASK_TX_IRQ:  .equ 10h
MASK_RX_RDY:  .equ 02h
MASK_TX_RDY:  .equ 01h

UART_DATA:    .equ 80h
UART_STATUS:  .equ 81h
UART_BAUDL:   .equ 82h
UART_BAUDH:   .equ 83h
IRQ_ENABLE:   .equ 88h

P1IN:         .equ 84h
P2OUT:        .equ 86h


;*******************************************************************************

          .org  0H              ; Reset entry point
          jmp   start           ; Skip the rst address area
                        
        ;***** Interrupt vectors in area 0008h-0038h *****************
          
          .org  0h+(1*8)        ; interrupt vector 1 (IRQ0)
          jmp   isr0
          .org  0h+(2*8)        ; interrupt vector 2
          ei
          ret
          .org  0h+(3*8)        ; interrupt vector 3 (IRQ1)
          jmp   isr1
          .org  0h+(4*8)        ; interrupt vector 4
          ei
          ret
          .org  0h+(5*8)        ; interrupt vector 5 (IRQ2)
          ei
          ret
          .org  0h+(6*8)        ; interrupt vector 6
          ei
          ret
          
          .org  0h+(7*8)        ; interrupt vector 7 (IRQ3, UART)
int38h:   jmp   irq_uart        ; UART interrupt 
       
          ;***** program entry point *******************************************
                
start:    .org  60H
          lxi   sp,stack

          ; Initialize UART RX and TX buffers
          lxi   h,void_buffer
          shld  ptr_tx
          lxi   h,rx_buffer
          shld  ptr_rx
          mvi   a,00h
          sta   len_rx
          
          ; Clear all P2 output lines (used to simulate external interrupts)
          mvi   a,00h
          out   P2OUT
          
          ; Set up interrupts
          mvi   a,0bh           ; Enable UART irq plus IRQ0 and IRQ1...
          out   IRQ_ENABLE
          ei                    ; ...and enable interrupts in the CPU
        
          ; print hello message to console
          lxi   h,msg_hello
          call  print_string
          ; Ok, now the message is being transferred through the looped back
          ; UART, using the UART interrupts, which have the lowest priority.
          ; We have plenty of time to make a few tests on the external interrupt
          ; lines before the message transmission is finished.
          
          ; The irq routines will leave some data at 'irq_data, each routine a
          ; different value and all non-zero. This is how we know what irq 
          ; routines have executed and in which order.
          
          ; Test IRQ0 alone 
          mvi   a,01h           ; Initialize irq data 
          sta   irq_data
          mvi   a,01h           ; Trigger IRQ0
          out   P2OUT
test_irq0:
          lda   irq_data        
          cpi   004h            ; Do we see the IRQ test data?
          jz    done_irq0       ; If we do, proceed to next test 
          cpi   001h            ; Do we see some other IRQ test data instead?
          jnz   test_fail       ; If we do, there's trouble with the irqs
          jmp   test_irq0       ; Keep waiting for some IRQ test data
done_irq0: 
          mvi   a,00h           ; Deassert all interrupt lines
          out   P2OUT
          
          ; Test IRQ1 alone 
          mvi   a,01h           ; Initialize irq data 
          sta   irq_data
          mvi   a,02h           ; Trigger IRQ1
          out   P2OUT
test_irq1:
          lda   irq_data        
          cpi   002h            ; Do we see the IRQ test data?
          jz    done_irq1       ; If we do, proceed to next test 
          cpi   001h            ; Do we see some other IRQ test data instead?
          jnz   test_fail       ; If we do, there's trouble with the irqs
          jmp   test_irq1       ; Keep waiting for some IRQ test data
done_irq1: 
          xra   a               ; Deassert all interrupt lines
          out   P2OUT
          
          ; Test IRQ0 and IRQ1 simultaneously
          mvi   a,01h           ; Initialize irq data 
          sta   irq_data
          mvi   a,03h           ; Trigger IRQ0 and IRQ1 
          out   P2OUT
          
          ; Sequence IRQ0->IRQ1 will result in (1 << 2) + 1 = 5
          ; Sequence IRQ1->IRQ0 would result in (1 + 1) << 2 = 6
          ; We expect IRQ0->IRQ1, since IRQ0 has higher priority
test_irq01:
          lda   irq_data        
          cpi   005h            ; Do we see the IRQ0->IRQ1 test data?
          jz    done_irq01      ; If we do, proceed to next test 
          cpi   001h            ; Do we see some other IRQ test data instead?
          jnz   test_fail       ; If we do, there's trouble with the irqs
          jmp   test_irq01      ; Keep waiting for some IRQ test data
done_irq01: 
          xra   a               ; Deassert all interrupt lines
          out   P2OUT
          
          ; Ok, the external interrupts have been tested (well, 'tested'). Now
          ; wait for the UART looped-back transmission to end and compare 
          ; the data.

          ; Wait until the number of UART received characters equals the length 
          ; of the test message.
wait_for_message:          
          lda   len_rx
          cpi   msg_len
          jnz   wait_for_message
          
          ; Compare the TX and RX strings
          lxi   h,rx_buffer
          lxi   d,msg_hello
compare_loop:
          ldax  d
          cpi   '$'
          jz    test_ok
          cmp   m
          jnz   test_fail
          inx   h
          inx   d
          jmp   compare_loop
          
          
          
          
          
test_ok:          
          mvi   a,80h           ; Raise 'success' output flag...
          out   P2OUT
done:     di                    ; ...and block here.
          hlt                   

test_fail:
          mvi   a,40h           ; Raise 'failure' flag...
          out   P2OUT
          jmp   done            ; ...and block.
          
          

msg_hello: .text "\n\r\nHello World!$"     
msg_end:  .equ $
          ; compute message length (-1 for the '$' that does not get TX'd)
msg_len:  .equ msg_end - msg_hello - 1    

          ; IRQ0 routine will shift irq_data left twice
isr0:     push  psw
          lda   irq_data
          rlc
          rlc
          sta   irq_data
          pop   psw
          ei
          ret

          ; IRQ1 routine will increment irq_data
isr1:     push  psw
          lda   irq_data
          adi   1
          sta   irq_data
          pop   psw
          ei
          ret
          
;irq_uart: UART interrupt processing 
irq_uart:
          push  h
          push  psw
          
          ; Deal with RX interrupt (if any) first and then the TX interrupt.
          in    UART_STATUS     ; Is there new data in the RX register?
          ani   MASK_RX_IRQ
          jz    irq_uart_rx_done ; If there isn't, process TX interrupt.
          
          ; Process UART RX interrupt
irq_uart_rx:     
          mvi   a,MASK_RX_IRQ   ; Clear IRQ flag.
          out   UART_STATUS     
          in    UART_DATA       ; Get RX byte...
          lhld  ptr_rx          ; ...and store it in the rx buffer.
          mov   m,a
          inx   h
          shld  ptr_rx          ; Update the rx buffer pointer.
          lda   len_rx          ; Update RX buffer length
          inr   a
          sta   len_rx 
          
          ; Note there's no check for RX buffer overrun! we shouldn't need it 
          ; here, a runaway condition would be readily apparent in the 
          ; simulation, anyway.

irq_uart_rx_done:
          ; Ok, RX is done. Now deal with TX irq, if any
          in    UART_STATUS     ; Is the TX buffer re new data in the RX register?
          ani   MASK_TX_IRQ
          jz    irq_uart_end    ; If there isn't, we're done.
          
          ; process UART TX interrupt
irq_uart_tx:
          mvi   a,MASK_TX_IRQ   ; Clear IRQ flag.
          out   UART_STATUS
          lhld  ptr_tx          ; Get next byte from the TX buffer 
          mov   a,m
          cpi   '$'             ; Did we reach the end of the buffer?
          jz    irq_uart_tx_done ; If we did, we're done here...
          inx   h               ; ...otherwise increment the TX pointer...
          shld  ptr_tx
          out   UART_DATA       ; ...and transmit the data byte.
          
irq_uart_tx_done:
        
irq_uart_end:
          pop   psw             ; Done, quit.
          pop   h
          ei
          ret                
        
;print_string: print $-terminated string at HL
print_string:
          ; We don't check if there's a transmission going on
          mov   a,m             ; Get first character from string...
          inx   h               ; ...and move updated string pointer to TX  
          shld  ptr_tx          ; buffer pointer.
          cpi   '$'             ; Kickstart transmission by sending 1st byte...
          jz    print_string_end; ...unless its the end of string marker.
          out   UART_DATA       ; 
print_string_end:
          ret

          
          ; data space, placed immediately after object code in memory
irq_data:     ds(1)
void_buffer:  .text "$"
ptr_tx:       ds(2)
ptr_rx:       ds(2)
len_rx:       ds(1)
rx_buffer:    ds(32)
              ds(64)
stack:        ds(2)
          .end
        