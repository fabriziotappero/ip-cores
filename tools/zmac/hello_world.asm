;==============================================================================
; Test code for the A-Z80 CPU that prints "Hello, World!"
; Also used to test responses to interrupts.
;==============================================================================
    org 0
start:
    jmp boot

    ; BDOS entry point for various functions
    ; We implement subfunctions:
    ;  C=2  Print a character given in E
    ;  C=9  Print a string pointed to by DE; string ends with '$'
    org 5
    ld  a,c
    cp  a,2
    jz  bdos_ascii
    cp  a,9
    jz  bdos_msg
    ret

bdos_ascii:
    ld  bc,10*256   ; Port to check for busy
    in  a,(c)       ; Poll until the port is not busy
    bit 0,a
    jnz bdos_ascii
    ld  bc,8*256    ; Port to write a character out
    out (c),e
    ret

bdos_msg:
    push de
    pop hl
lp0:
    ld  e,(hl)
    ld  a,e
    cp  a,'$'
    ret z
    call bdos_ascii
    inc hl
    jmp lp0

;---------------------------------------------------------------------
; RST38 (also INT M0)  handler
;---------------------------------------------------------------------
    org 038h
    push de
    ld  de,int_msg
int_common:
    push af
    push bc
    push hl
    ld  c,9
    call 5
    pop hl
    pop bc
    pop af
    pop de
    ei
    reti
int_msg:
    db  "_INT_",'$'

;---------------------------------------------------------------------
; NMI handler
;---------------------------------------------------------------------
    org 066h
    push af
    push bc
    push de
    push hl
    ld  de,nmi_msg
    ld  c,9
    call 5
    pop hl
    pop de
    pop bc
    pop af
    retn
nmi_msg:
    db  "_NMI_",'$'

;---------------------------------------------------------------------
; IM2 vector address and the handler (to push 0x80 by the IORQ)
;---------------------------------------------------------------------
    org 080h
    dw  im2_handler
im2_handler:
    push de
    ld  de,int_im2_msg
    jmp int_common
int_im2_msg:
    db  "_IM2_",'$'
boot:
    ; Set the stack pointer
    ld  sp, 16384    ; 16 Kb of RAM
    ; Set up for interrupt testing: see Z80\cpu\toplevel\test_top.sv
    ; IMPORTANT: To test IM0, Verilog test code needs to put 0xFF on the bus
    ;            To test IM2, the test code needs to put a vector of 0x80 !!
    ;            This is done in tb_iorq.sv
    im  2
    ld  a,0
    ld  i,a
    ei
    ;halt
    ; Jump into the executable at 100h
    jmp 100h

;==============================================================================
;
; Prints "Hello, World!"
;
;==============================================================================
    org 100h
    ld  hl,0
    ld  (counter),hl
exec:
    ld  de,hello
    ld  c,9
    call 5

    ; Print the counter and the stack pointer to make sure it does not change
    ld  hl, (counter)
    inc hl
    ld  (counter),hl

    ld  hl, text
    ld  a,(counter+1)
    call tohex
    ld  hl, text+2
    ld  a,(counter)
    call tohex

    ld  (stack),sp

    ld  hl, text+5
    ld  a,(stack+1)
    call tohex
    ld  hl, text+7
    ld  a,(stack)
    call tohex

; Two versions of the code: either keep printing the text indefinitely (which
; can be used for interrupt testing), or print it only once and die
die:
    jr exec
;    jr die

tohex:
    ; HL = Address to store a hex value
    ; A  = Hex value 00-FF
    push af
    and  a,0fh
    cmp  a,10
    jc   skip1
    add  a, 'A'-'9'-1
skip1:
    add  a, '0'
    inc  hl
    ld   (hl),a
    dec  hl
    pop  af
    rra
    rra
    rra
    rra
    and  a,0fh
    cmp  a,10
    jc   skip2
    add  a, 'A'-'9'-1
skip2:
    add  a, '0'
    ld   (hl),a
    ret

; Print a counter before Hello, World so we can see if the
; processor rebooted during one of the interrupts. Also, print the content
; of the SP register which should stay fixed and "uninterrupted"
counter: dw 0
stack: dw 0

hello:
    db  13,10
text:
    db '0000 0000 Hello, World!',13,10,'$'
end
