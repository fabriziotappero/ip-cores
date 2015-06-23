!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
! Code for the test bench. This gets dumped and placed into testbench.v as byte
! definitions.
!

!
! Select controller defines
! 
selmain: equ    $00             ! offset of main control register
sel1msk: equ    $02             ! offset of select 1 mask
sel1cmp: equ    $03             ! offset of select 1 compare
sel2msk: equ    $04             ! offset of select 1 mask
sel2cmp: equ    $05             ! offset of select 1 compare
sel3msk: equ    $06             ! offset of select 1 mask
sel3cmp: equ    $07             ! offset of select 1 compare
sel4msk: equ    $08             ! offset of select 1 mask
sel4cmp: equ    $09             ! offset of select 1 compare
!
! bits
!
selenb:  equ    $01             ! enable select
selio:   equ    $02             ! I/O address or memory

!
! Note: select 1 is ROM, 2, is RAM, 3 is interrupt controller, 4 is serial I/O.
!

!
! Where to place ROM and RAM for this test
!
rombas: equ     $0000
rambas: equ     rombas+1024
!
! Interrupt controller defines
!
intbas: equ     $10
intmsk: equ     intbas+$00      ! mask
intsts: equ     intbas+$01      ! status
intact: equ     intbas+$02      ! active interrupt
intpol: equ     intbas+$03      ! polarity select
intedg: equ     intbas+$04      ! edge/level select
intvec: equ     intbas+$05      ! vector base page      
!
! Mits Serial I/O card
!
siobas: equ     $20
sioctl: equ     siobas+$00      ! control register
siodat: equ     siobas+$01      ! status

!
! Set up selectors
!

!
! ROM
!
        mvi     a,rombas shr 8  ! enable select 1 to 1kb at base
        out     sel1cmp
        mvi     a,($fc00 shr 8) or selenb
        out     sel1msk
!
! RAM
!
        mvi     a,rambas shr 8  ! enable select 2 to 1kb at base
        out     sel2cmp
        mvi     a,($fc00 shr 8) or selenb
        out     sel2msk
!
! ROM and RAM set up, exit bootstrap mode
!
        mvi     a,$00           ! exit bootstrap mode 
        out     selmain
!
        lxi     sp,rambas+1024  ! set stack to top of ram
!
! Serial I/O
!
        mvi     a,siobas        ! enable interrupt controller for 4 addresses           
        out     sel4cmp
        mvi     a,$fc or selio or selenb
        out     sel4msk
!
! Print "hello, world" and stop
!
        lxi     h,helstr        ! index string
loop:
        mov     a,m             ! get character
        inx     h               ! next character
        ora     a               ! check end of string
        jz      endstr          ! yes, skip
        call    wrtout          ! output character
        jmp     loop            ! loop next character
endstr:
!
! halt
!
        hlt

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
! Serial output routine
!
! Outputs the character in a.
!
wrtout:
        push    psw             ! save character to output
wrtout01:
        in      sioctl          ! get output ready status /n
        ani     $80             ! mask
        jnz     wrtout01        ! no, loop
        pop     psw             ! restore character
        out     siodat          ! output
        ret                     ! return to caller
!
! String to print
!
helstr:
        defb    'Hello, FPGA world\cr\lf', 0        

        