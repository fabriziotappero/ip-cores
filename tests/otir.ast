; basic test of OTIR block-transfer instruction
;
; initializes a memory region and then transfers that region
; to an accumulator

    .module otir

;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
_sim_ctl_port	=	0x0080
_msg_port	=	0x0081
_timeout_port	=	0x0082
_max_timeout_low	=	0x0083
_max_timeout_high	=	0x0084
_intr_cntdwn	=	0x0090
_cksum_value    =       0x0091
_cksum_accum    =       0x0092
_inc_on_read    =       0x0093

    .area INIT (ABS)
    .org  0

    jp      init


init:
    ld      sp, #0xffff

    ;; initialize dbuf memory area with regular pattern
    ;; pattern starts with 1 and increments

    ld      hl, #dbuf
    ld      b, #255
    ld      c, #1

dbuf_init:
    ld      (hl), c
    inc     hl
    inc     c
    djnz    dbuf_init

    call    reset_timeout
    ld      b, #16
    call    xfer_test

    call    reset_timeout
    ld      b, #63
    call    xfer_test

    call    reset_timeout
    ld      b, #127
    call    xfer_test

    call    reset_timeout
    ld      b, #128
    call    xfer_test

    call    reset_timeout
    ld      b, #254
    call    xfer_test

    call    reset_timeout
    ld      b, #255
    call    xfer_test

    ;; finish simulation with test passed
    ld      a, #1
    out     (_sim_ctl_port), a
    ret
    
    ;; test sending X amount of data from the buffer to the
    ;; accumulator.  Amount of data to transfer is in B.
    ;; After tranferring data to checksummer, perform
    ;; checksum and compare
xfer_test:
    push    bc
    ld      hl, #dbuf
    ld      a, #0
    out     (_cksum_value), a

    ld      c, #_cksum_accum
    otir

    ;; do checksum over same region
    pop     bc
    ld      hl, #dbuf
    ld      a, #0
    
xfer_test_cksum:    
    add     a, (hl)
    inc     hl
    djnz    xfer_test_cksum
    
    ;; store calc'ed checksum in D and read out cksum register
    ld      d, a
    in      a, (_cksum_value)

    ;; compare two values and fail test if not equal
    cp      d
    jp      nz, xfer_fail
    ret

xfer_fail:
    ld      a, #2
    out     (_sim_ctl_port), a
    ret

reset_timeout:
    ld      a, #2
    out     (_timeout_port), a
    ret
    
    .org    0x8000

dbuf:
    .ds     256

