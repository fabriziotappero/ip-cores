!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!                                                                              !
!                            8080 CPU INSTRUCTION TEST                         !
!                             2006/10/07 Scott Moore                           !
!                                                                              !
! 8080 CPU instruction test for hardware simulation. The "cpu8080"             !
! environment, with its select controller and interrupt controller, is         !
! initialized, then we test each instruction type for the 8080. Each register  !
! and mode of each instruction is tested, which is possible for the rather     !
! small instruction set of the 8080. Each result is written out to memory, if  !
! required, so that all results are visible from the outside pins of the 8080. !
! This means that the pin states would be a valid basis for a vector test.     !
!                                                                              !
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

rom:    equ     $0000           ! base address of the instruction ROM
romlen: equ     $0400           ! length of ROM
ram:    equ     $0400           ! base address of instruction RAM
ramlen: equ     $0400           ! length of RAM
!
! Perform testbench initalize, program select controller to the following:
!
! Select 1 (ROM): base $0000, length $0400
! Select 2 (RAM): base $0400, length $0400
!
initalize:
        mvi     a,$fd           ! enable select 1 to $0000, 1kb
        out     $02             ! select 1 mask register
        mvi     a,$04           ! enable select 2 to $0400, 1kb
        out     $05             ! select 2 compare register
        mvi     a,$fd
        out     $04
        mvi     a,$00           ! exit bootstrap mode 
        out     $00
        lxi     sp,$0800        ! place stack at top of ram
!
! Instruction test
!
! You'll find the order of instructions to test in "the Intel 8080 Assembly
! language Programming Manual", available online.
!
instest:
!
! stc
! cmc
!
        xra     a               ! clear A and flags
        push    psw             ! send to bus
        pop     psw             ! keep stack neutral
        stc                     ! set carry
        push    psw             ! send to bus
        pop     psw             ! keep stack neutral
        cmc                     ! clear carry
        push    psw             ! send to bus
        pop     psw             ! keep stack neutral
!
! inr a
!
        mvi     a,$00           ! a = 0
        inr     a               ! a = 1, no zero, no sign, odd parity, no AC,
        push    psw             ! send to bus
        pop     psw             ! keep stack neutral
        inr     a               ! a = 1, no zero, no sign, odd parity, no AC,
        push    psw             ! send to bus
        pop     psw             ! keep stack neutral
        inr     a
        inr     a               ! a = 3, no zero, no sign, even parity, no AC,
                                ! carry x
        push    psw             ! send to bus
        pop     psw             ! keep stack neutral
        mvi     a,$0f           ! a = $0f
        inr     a               ! a = $10, no zero, no sign, odd parity, AC
        push    psw             ! send to bus
        pop     psw             ! keep stack neutral
        mvi     a,$fe           ! a = $fe
        inr     a               ! a = $ff, no zero, sign, even parity, no AC
        push    psw             ! send to bus
        pop     psw             ! keep stack neutral
        inr     a               ! a = $00, zero, no sign, even parity, AC
        push    psw             ! send to bus
        pop     psw             ! keep stack neutral
!
! inr b
!
        mvi     b,$00           ! a = 0
        inr     b               ! a = 1, no zero, no sign, odd parity, no AC,
                                ! carry x
        push    psw             ! send to bus
        pop     psw             ! keep stack neutral
        push    b               ! send to bus
        pop     b               ! keep stack neutral
        inr     b               ! a = 1, no zero, no sign, odd parity, no AC,
                                ! carry x
        push    psw             ! send to bus
        pop     psw             ! keep stack neutral
        push    b               ! send to bus
        pop     b               ! keep stack neutral
        inr     b
        inr     b               ! a = 3, no zero, no sign, even parity, no AC,
                                ! carry x
        push    psw             ! send to bus
        pop     psw             ! keep stack neutral
        push    b               ! send to bus
        pop     b               ! keep stack neutral
        mvi     b,$0f           ! a = $0f
        inr     b               ! a = $10, no zero, no sign, odd parity, AC
        push    psw             ! send to bus
        pop     psw             ! keep stack neutral
        push    b               ! send to bus
        pop     b               ! keep stack neutral
        mvi     b,$fe           ! a = $fe
        inr     b               ! a = $ff, no zero, sign, even parity, no AC
        push    psw             ! send to bus
        pop     psw             ! keep stack neutral
        push    b               ! send to bus
        pop     b               ! keep stack neutral
        inr     b               ! a = $00, zero, no sign, even parity, AC
        push    psw             ! send to bus
        pop     psw             ! keep stack neutral
        push    b               ! send to bus
        pop     b               ! keep stack neutral
!
! inr c
!
        mvi     c,$00           ! a = 0
        inr     c               ! a = 1, no zero, no sign, odd parity, no AC,
                                ! carry x
        push    psw             ! send to bus
        pop     psw             ! keep stack neutral
        push    b               ! send to bus
        pop     b               ! keep stack neutral
        inr     c               ! a = 1, no zero, no sign, odd parity, no AC,
                                ! carry x
        push    psw             ! send to bus
        pop     psw             ! keep stack neutral
        push    b               ! send to bus
        pop     b               ! keep stack neutral
        inr     c
        inr     c               ! a = 3, no zero, no sign, even parity, no AC,
                                ! carry x
        push    psw             ! send to bus
        pop     psw             ! keep stack neutral
        push    b               ! send to bus
        pop     b               ! keep stack neutral
        mvi     c,$0f           ! a = $0f
        inr     c               ! a = $10, no zero, no sign, odd parity, AC
        push    psw             ! send to bus
        pop     psw             ! keep stack neutral
        push    b               ! send to bus
        pop     b               ! keep stack neutral
        mvi     c,$fe           ! a = $fe
        inr     c               ! a = $ff, no zero, sign, even parity, no AC
        push    psw             ! send to bus
        pop     psw             ! keep stack neutral
        push    b               ! send to bus
        pop     b               ! keep stack neutral
        inr     c               ! a = $00, zero, no sign, even parity, AC
        push    psw             ! send to bus
        pop     psw             ! keep stack neutral
        push    b               ! send to bus
        pop     b               ! keep stack neutral
!
! inr d
!
        mvi     d,$00           ! a = 0
        inr     d               ! a = 1, no zero, no sign, odd parity, no AC,
                                ! carry x
        push    psw             ! send to bus
        pop     psw             ! keep stack neutral
        push    d               ! send to bus
        pop     d               ! keep stack neutral
        inr     d               ! a = 1, no zero, no sign, odd parity, no AC,
                                ! carry x
        push    psw             ! send to bus
        pop     psw             ! keep stack neutral
        push    d               ! send to bus
        pop     d               ! keep stack neutral
        inr     d
        inr     d               ! a = 3, no zero, no sign, even parity, no AC,
                                ! carry x
        push    psw             ! send to bus
        pop     psw             ! keep stack neutral
        push    d               ! send to bus
        pop     d               ! keep stack neutral
        mvi     d,$0f           ! a = $0f
        inr     d               ! a = $10, no zero, no sign, odd parity, AC
        push    psw             ! send to bus
        pop     psw             ! keep stack neutral
        push    d               ! send to bus
        pop     d               ! keep stack neutral
        mvi     d,$fe           ! a = $fe
        inr     d               ! a = $ff, no zero, sign, even parity, no AC
        push    psw             ! send to bus
        pop     psw             ! keep stack neutral
        push    d               ! send to bus
        pop     d               ! keep stack neutral
        inr     d               ! a = $00, zero, no sign, even parity, AC
        push    psw             ! send to bus
        pop     psw             ! keep stack neutral
        push    d               ! send to bus
        pop     d               ! keep stack neutral
!
! inr e
!
        mvi     e,$00           ! a = 0
        inr     e               ! a = 1, no zero, no sign, odd parity, no AC,
                                ! carry x
        push    psw             ! send to bus
        pop     psw             ! keep stack neutral
        push    d               ! send to bus
        pop     d               ! keep stack neutral
        inr     e               ! a = 1, no zero, no sign, odd parity, no AC,
                                ! carry x
        push    psw             ! send to bus
        pop     psw             ! keep stack neutral
        push    d               ! send to bus
        pop     d               ! keep stack neutral
        inr     e
        inr     e               ! a = 3, no zero, no sign, even parity, no AC,
                                ! carry x
        push    psw             ! send to bus
        pop     psw             ! keep stack neutral
        push    d               ! send to bus
        pop     d               ! keep stack neutral
        mvi     e,$0f           ! a = $0f
        inr     e               ! a = $10, no zero, no sign, odd parity, AC
        push    psw             ! send to bus
        pop     psw             ! keep stack neutral
        push    d               ! send to bus
        pop     d               ! keep stack neutral
        mvi     e,$fe           ! a = $fe
        inr     e               ! a = $ff, no zero, sign, even parity, no AC
        push    psw             ! send to bus
        pop     psw             ! keep stack neutral
        push    d               ! send to bus
        pop     d               ! keep stack neutral
        inr     e               ! a = $00, zero, no sign, even parity, AC
        push    psw             ! send to bus
        pop     psw             ! keep stack neutral
        push    d               ! send to bus
        pop     d               ! keep stack neutral
!
! inr h
!
        mvi     h,$00           ! a = 0
        inr     h               ! a = 1, no zero, no sign, odd parity, no AC,
                                ! carry x
        push    psw             ! send to bus
        pop     psw             ! keep stack neutral
        push    h               ! send to bus
        pop     h               ! keep stack neutral
        inr     h               ! a = 1, no zero, no sign, odd parity, no AC,
                                ! carry x
        push    psw             ! send to bus
        pop     psw             ! keep stack neutral
        push    h               ! send to bus
        pop     h               ! keep stack neutral
        inr     h
        inr     h               ! a = 3, no zero, no sign, even parity, no AC,
                                ! carry x
        push    psw             ! send to bus
        pop     psw             ! keep stack neutral
        push    h               ! send to bus
        pop     h               ! keep stack neutral
        mvi     h,$0f           ! a = $0f
        inr     h               ! a = $10, no zero, no sign, odd parity, AC
        push    psw             ! send to bus
        pop     psw             ! keep stack neutral
        push    h               ! send to bus
        pop     h               ! keep stack neutral
        mvi     h,$fe           ! a = $fe
        inr     h               ! a = $ff, no zero, sign, even parity, no AC
        push    psw             ! send to bus
        pop     psw             ! keep stack neutral
        push    h               ! send to bus
        pop     h               ! keep stack neutral
        inr     h               ! a = $00, zero, no sign, even parity, AC
        push    psw             ! send to bus
        pop     psw             ! keep stack neutral
        push    h               ! send to bus
        pop     h               ! keep stack neutral
!
! inr l
!
        mvi     l,$00           ! a = 0
        inr     l               ! a = 1, no zero, no sign, odd parity, no AC,
                                ! carry x
        push    psw             ! send to bus
        pop     psw             ! keep stack neutral
        push    h               ! send to bus
        pop     h               ! keep stack neutral
        inr     l               ! a = 1, no zero, no sign, odd parity, no AC,
                                ! carry x
        push    psw             ! send to bus
        pop     psw             ! keep stack neutral
        push    h               ! send to bus
        pop     h               ! keep stack neutral
        inr     l
        inr     l               ! a = 3, no zero, no sign, even parity, no AC,
                                ! carry x
        push    psw             ! send to bus
        pop     psw             ! keep stack neutral
        push    h               ! send to bus
        pop     h               ! keep stack neutral
        mvi     l,$0f           ! a = $0f
        inr     l               ! a = $10, no zero, no sign, odd parity, AC
        push    psw             ! send to bus
        pop     psw             ! keep stack neutral
        push    h               ! send to bus
        pop     h               ! keep stack neutral
        mvi     l,$fe           ! a = $fe
        inr     l               ! a = $ff, no zero, sign, even parity, no AC
        push    psw             ! send to bus
        pop     psw             ! keep stack neutral
        push    h               ! send to bus
        pop     h               ! keep stack neutral
        inr     l               ! a = $00, zero, no sign, even parity, AC
        push    psw             ! send to bus
        pop     psw             ! keep stack neutral
        push    h               ! send to bus
        pop     h               ! keep stack neutral
!
! dcr a
!
        mvi     a,$00           ! a = $00
        dcr     a               ! a = $ff, no zero, sign, even parity, no AC,
                                ! carry x
        push    psw             ! send to bus
        pop     psw             ! keep stack neutral
        dcr     a               ! a = $fe, no zero, sign, odd parity, no AC,
        push    psw             ! send to bus
        pop     psw             ! keep stack neutral
        mvi     a,$10           ! a = $10
        dcr     a               ! a = $0f, no zero, no sign, odd parity, AC
        push    psw             ! send to bus
        pop     psw             ! keep stack neutral
        mvi     a,$01           ! a = $01
        dcr     a               ! a = $00, zero, no sign, even parity, no AC
        push    psw             ! send to bus
        pop     psw             ! keep stack neutral

        

        
        