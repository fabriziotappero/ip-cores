!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!                                                                              !
!                  IMSAI SCS-1 MONITOR/ASSEMBLER FOR 8080 CPU                  !
!                                                                              !
! This copy was converted to IP assembler, and is modified to run on the       !
! MITS serial I/O board, which had jumper selectable baud rates only.          !
!                                                                              !
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
!       page    62
!       title           'imsai scs-1 rev. 2 06 oct. 1976'
!
! MITS serial I/O board equates
!
tts:    equ     $20
tti:    equ     $21
tto:    equ     $21
ttyda:  equ     $01
ttytr:  equ     $80
!
        jmp     inita           ! dead start
        jmp     eor             ! restart monitor
!
        alignp  $08
        jmp     brkp            ! breakpoint restart
!
        alignp  $40
!
! this routine initializes the file aread for subsequent
! processing
!
inita:  
        lxi     h,file0
        mvi     c,maxfil*felen
        xra     a
init2:  mov     m,a
        inx     h
        dcr     c
        jnz     init2
!
! clear the breakpoint table
!
        mvi     b,nbr*3
        lxi     h,brt
init3:  mov     m,a
        inx     h
        dcr     b
        jnz     init3
!
! this is the starting point of the self contained
! system once the system has been initialized.  commands
! are read from the user, executed, and control returns
! back to this point to read another command.
!
eor:    lxi     sp,area+18
        call    crlf            ! print c/r, line feed
        call    read            ! read input line
        inx     h
        mov     a,m             ! fetch first character
        cpi     '9'+1           ! command or line number?
        jc      line            ! jump if line for file
        call    valc
        call    comm
        jmp     eor
!
! this routine reads in a line from the tty and places
! it in an input buffer.
! the following are special characters
!   cr          terminates read routine
!   lf          not recognized by routine
!   ctrl x      deletes current line
!   del         deletes characer
! all displayable characters between blank & z and the
! above are recognized by the read routine, all others
! are skipped over.  the routine will not accept more
! characters than the input buffer will hold.
!
read:   lxi     h,ibuf          ! get input buffer address
        shld    adds            ! save address
        mvi     e,2             ! initialize character count
next:   call    in8             ! read a line
        mov     a,b
        cpi     24              ! check for ctrl x
        jnz     cr
        call    crlf            ! output a crlf
        jmp     read
cr:     cpi     ascr            ! get an ascii cr
        jnz     del
        mov     a,l
        cpi     ibuf and $00ff  ! check for first char
        jz      read
        mvi     m,ascr          ! place cr at end of line
        inx     h
        mvi     m,1             ! place eof indicator in line
        inx     h
        mvi     a,ibuf+83 and $00ff
        call    cler            ! clear remaining buffer
        lxi     h,ibuf-1
        mov     m,e             ! save character count
        ret
del:    cpi     127             ! check for delete character
        jnz     char
        mvi     a,ibuf and $00ff
        cmp     l               ! is it 1st character
        jz      next
        dcx     h               ! decrement pointer
        dcr     e               ! decrement count
bspa:   mvi     b,$5f
        call    out8
        jmp     next
char:   cpi     ' '             ! check for legal character
        jc      next
        cpi     'z'+1
        jnc     next
        mov     b,a
        call    out8            ! echo character
        mov     m,b
        mvi     a,ibuf+81 and $00ff
        cmp     l               ! check for end of line
        jz      bspa
        inx     h
        inr     e               ! increment character count
        jmp     next
!
! this routine is used to blank out a portion of memory
!
cler:   cmp     l
        rz      
        mvi     m,' '           ! place blank in memory
        inx     h
        jmp     cler
!
! see if tty input ready and check for ctrl x.
!
ink:    in      tts             ! get tty status
        ani     ttyda           ! is data available?
        rnz                     ! return if not
        in      tti             ! get the char
        ani     $7f             ! strip off parity
        cpi     'x'-$40         ! is it a ctrl x?
        ret
!
! this routine reads a byte of data from the usart
!
in8:    in      tts             ! read usart status
        cma                     ! invert status
        ani     ttyda
        jz      in8
        in      tti             ! read data
        ani     127             ! strip off parity
        mov     b,a
        ret

!
! this routine outputs a byte of data to the usart
!
out8:   in      tts             ! read status
        cma                     ! invert status
        ani     ttytr
        jz      out8
ok:     mov     a,b
        out     tto             ! transmit data
        ret
!
! this routine will output a carriage return and
! line feed followed by two delete characters which
! provide time for print head to return.
!
crlf:   mvi     b,13            ! cr
        call    out8
lf:     mvi     b,10            ! lf
        call    out8
        mvi     b,127
        call    out8
        call    out8
        ret
!
! this routine jumps to a location in memory given by
! the input command and begins execution of program
! there.
!
exec:   call    vchk            ! check for parameters
        call    crlf
        lhld    bbuf            ! fetch address
        pchl                    ! jump to program
!
! this routine checks the input command agains all
! legal commands stored in a table.  if a legal command
! is found, a jump is made to that routine.  otherwise
! an error message is output to the user.
!
comm:   lxi     d,ctab          ! command table address
        mvi     b,ncom          ! number of commands
        mvi     a,4             ! length of command
        sta     nchr            ! save
        call    coms            ! search table
        jnz     what            ! jump if illegal command
        pchl                    ! be here now
!
! this routine checks to see if a base character string
! is equal to any of the strings contained in a table
! pointed to by d,e.  the table consists of any number
! of chars, with 2 bytes containing values associated
! with it.  reg b contains the # of strings to compare.
! this routine can be used to search through a command
! or symbol table.  on return, if the zero flag is set,
! a match was found! if not, no match was found.  if
! a match was found, d,e point to the last byte
! associated with the character string.  if not, d,e
! point to the next location after the end fo the table.
!
coms:   lhld    adds            ! fetch compare address
        lda     nchr            ! get length of string
        mov     c,a
        call    sear            ! compare strings
        ldax    d               ! fetch value
        mov     l,a
        inx     d
        ldax    d               ! fetch value
        mov     h,a
        rz      
        inx     d               ! set to next string
        dcr     b               ! decrement count
        jnz     coms
        inr     b               ! clear zero flag
        ret
!
! this routine checks to see if two character strings in
! memory are equal.  the strings are pointed to by d,e
! and h,l.  on return, the zero flag set indicates a
! match.  reg c indicates the length of the strings.  on
! return, the pointers point to the next address after
! the character strings.
!
sear:   ldax    d               ! fetch character
        cmp     m               ! compare characters
        jnz     inca
        inx     h
        inx     d
        dcr     c               ! decrement character count
        jnz     sear
        ret
inca:   inx     d
        dcr     c
        jnz     inca
        inr     c               ! clear zero flag
        ret
!
! this routine zeroes out a buffer in memory which is
! then used by other scanning routines
!
zbuf:   xra     a               ! get a zero
        lxi     d,abuf+12       ! buffer address
        mvi     b,12            ! buffer length
zbu1:   dcx     d               ! decrement address
        stax    d               ! zero buffer
        dcr     b
        jnz     zbu1
        ret
!
! this routine calls etra to obtain the input parameter
! values and calls an error routine if an error occured
! in that routine
!
valc:   call    etra            ! get input parameters
        jc      what            ! jump if error
        ret
!
! this routine extracts the values associated with a
! command from the input stream and places them in the
! ascii buffer (abuf).  it also calls a routine to
! convert the ascii hexadecimals to binary and stores
! them in the binary buffer (bbuf).  on return, carry
! set indicates an error in input parameters.
!
etra:   lxi     h,0             ! get a zero
        shld    bbuf+2          ! zero value
        shld    fbuf            ! set no file name
        call    zbuf            ! zero buffer
        lxi     h,ibuf-1
val1:   inx     h
        mov     a,m             ! fetch input character
        cpi     ' '             ! look for first character
        cmc
        rnc                     ! return if no carry
        jnz     val1            ! jump if no black
        shld    pntr            ! save pointer
        call    sblk            ! scan to first parameter
        cmc
        rnc                     ! return if cr
        cpi     '/'               
        jnz     val5            ! no file name
        lxi     d,fbuf          ! name follows put in fbuf
        mvi     c,nmlen
val2:   inx     h
        mov     a,m
        cpi     '/'
        jz      val3
        dcr     c
        jm      what
        stax    d               ! store file name
        inx     d
        jmp     val2
val3:   mvi     a,' '           ! get an ascii space
val4:   dcr     c
        jm      done
        stax    d               ! fill in with spaces
        inx     d
        jmp     val4
done:   call    sbl2
        cmc
        rnc
val5:   lxi     d,abuf
        call    alps            ! place parameter in buffer
        mov     a,b             ! get digit count
        cpi     5               ! check number of digits
        cmc
        rc                      ! return if too many digits
        lxi     b,abuf
        call    ahex            ! convert value
        rc                      ! illegal character
        shld    bbuf            ! save in binary buffer
        lxi     h,abuf
        call    norm            ! normalize ascii value
        call    sblk            ! scan to next parameter
        cmc
        rnc                     ! return if cr
        lxi     d,abuf+4          
        call    alps            ! place parameters in buffer
        mov     a,b             ! get digit count
        cpi     5               ! check number of digits
        cmc
        rc                      ! return if too many digits
        lxi     b,abuf+4
        call    ahex            ! convert value
        rc                      ! illegal value
        shld    bbuf+2          ! save in binary buffer
        lxi     h,abuf+4
        call    norm            ! normalize ascii value
        ora     a               ! clear carry
        ret
!
! this routine fetches digits from the buffer addressed
! by b,c and converts the ascii decimal digits into
! binary.  up to a 16-bit value can be converted.  the
! scan stops when a binary zero is found in the buffer.
!
adec:   lxi     h,0             ! get a 16 bit zero
ade1:   ldax    b               ! fetch ascii digit
        ora     a               ! set zero flag
        rz                      ! return iff finished
        mov     d,h             ! save current value
        mov     e,l             ! save current value
        dad     h               ! times two
        dad     h               ! times two
        dad     d               ! add in original value
        dad     h               ! times two
        sui     48              ! ascii bias
        cpi     10              ! check for legal value
        cmc
        rc                      ! return if error
        mov     e,a
        mvi     d,0
        dad     d               ! add in next digit
        inx     b               ! increment pointer
        jmp     ade1
!
! this routine fetches digits from the buffer addressed
! by b,c and converts the ascii hexadecimal digits into
! binary.  up to a 16-bit value can be converted.  the
! scan stops when a binary zero is foundin the buffer.
!
ahex:   lxi     h,0             ! get a 16 bit zero
ahe1:   ldax    b               ! fetch ascii digit
        ora     a               ! set zero flag
        rz                      ! return if done
        dad     h               ! left shift
        dad     h               ! left shift
        dad     h               ! left shift
        dad     h               ! left shift
        call    ahs1            ! convert to binary
        cpi     $10             ! check for legal value
        cmc
        rc                      ! return if error
        add     l
        mov     l,a
        inx     b               ! increment pointer
        jmp     ahe1
!
! this routine converts ascii hex digits into binary
!
ahs1:   sui     48              ! ascii bias
        cpi     10              ! digit 0-10
        rc
        sui     7               ! alpha bias
        ret
!
! this routine converts a binary value to ascii
! hexadecimal and outputs the characters to the tty.
!
hout:   call    binh
        lxi     h,hcon
chot:   mov     b,m
        call    out8
        inx     h
        mov     b,m
        call    out8
        ret
!
! this routine does the same as above but outputs a
! blank after the last character
!
hotb:   call    hout            ! convert and output
        call    blk1            ! output a blank
        ret
!
! this routine converts a binary value to ascii
! decimal digits and optputs the characters to the tty
!

dout:   call    bind            ! convert value
        call    hout+3          ! output value (2 digits)
        inx     h
        mov     b,m             ! get last digit
        call    out8            ! output
        ret
!
! this routine outputs a blank
!
blk1:   mvi     b,' '           ! get a blank
        call    out8
        ret
!
! this routine is used by other routines to increment
! the starting address in a command and compare it with
! the final address in the command.  on return, the
! carry flag set indicates that the final address has
! been reached.
!
achk:   lhld    bbuf            ! fetch start address
        lda     bbuf+3          ! stop address (high)
        cmp     h               ! compare addresses
        jnz     ach1
        lda     bbuf+2          ! stop address (low)
        cmp     l               ! compare addresses
        jnz     ach1
        stc                     ! set carry if equal
ach1:   inx     h               ! increment start addresses
        shld    bbuf            ! store start address
        ret
!
! this routine outputs character of a string
! until a carriage return is found
!
scrn:   mov     b,m             ! fetch character
        mvi     a,13            ! carriage return
        cmp     b               ! character = cr?
        rz      
        call    out8
        inx     h
        jmp     scrn
!
! this routine converts the binary value in reg a into
! ascii hexadecimal digits and stores them in memory
!
binh:   lxi     h,hcon          ! conversion
        mov     b,a             ! save value
        rar
        rar
        rar
        rar
        call    bin1
        mov     m,a
        inx     h
        mov     a,b
        call    bin1            ! convert to ascii
        mov     m,a
        ret
!
! this routine converts a value to hexadecimal
!
bin1:   ani     $f              ! low 4 bits
        adi     48              ! convert to ascii
        cpi     58              ! digit 0-9
        rc
        adi     7               ! modify for a-f
        ret
!
! this routine converts the binary value in reg a into
! ascii decimal digits and stores them in memory
!
bind:   lxi     h,hcon          ! conversion address
        mvi     b,100
        call    bid1            ! convert hundreds digit
        mvi     b,10
        call    bid1            ! convert tens digit
        adi     '0'             ! get units digit
        mov     m,a             ! store in memory
        ret
!
! this routine converts a value to decimal
!
bid1:   mvi     m,'0'-1         ! initialize digit count
        inr     m
        sub     b               ! check digit
        jnc     bid1+2
        add     b               ! restore value
        inx     h
        ret
!
! legal command table
!
ctab:   defb    'dump'
        defw    dump
        defb    'exec'
        defw    exec
        defb    'entr'
        defw    entr
        defb    'file'
        defw    file
        defb    'list'
        defw    list
        defb    'delt'
        defw    dell
        defb    'assm'
        defw    assm
        defb    'page'
        defw    pagemov
        defb    'cust'
        defw    $2000
        defb    'brek'
        defw    break
        defb    'proc'
        defw    proc
!
! this routine checks if any parameters were entered
! with the command, if not an error message is issued
!
vchk:   lda     abuf            ! fetch parameter byte
        ora     a               ! set flags
        jz      what            ! no parameter
        ret
!
! this routine dumps out the fontents of memory from
! the start to final addresses given in the command.
!
dump:   call    vchk            ! check for parameters
dums:   call    crlf            ! start new line
dum1:   lhld    bbuf            ! fetch memory address
        mov     a,m
        call    hotb            ! output value
        call    achk            ! check address
        rc                      ! return if finished
        mov     a,l             ! is next address
        ani     $0f             ! divisible by 16?
        jnz     dum1
        jmp     dums
!
! this routine will move 256 bytes from 1st address
! given in command to 2nd address in command.
!
pagemov:call    vchk            ! check for parameter
        lda     abuf+4          ! fetch 2nd parameter
        ora     a               ! does 2nd parameter exist?
        jz      what
        lhld    bbuf            ! fetch move to address
        xchg
        lhld    bbuf+2          ! fetch move to address
        mvi     b,0             ! set counter
pag1:   ldax    d
        mov     m,a
        inx     h
        inx     d
        dcr     b               ! decrement counter
        jnz     pag1
        ret
!
! this command initializes the beginning of file address
! and end of file address as well as the file area
! when the file command is used
!
file:   call    crlf
! check for file parameters
        lda     fbuf
        ora     a
        jz      fout            ! no ? go list
        call    fsea            ! look up file
        xchg                    ! pntr in de
        jnz     test
! no entry
        lda     abuf            ! check for param
        ora     a
        jz      wha1            ! no?? - error
! check for room in directory
        lda     fef
        ora     a
        jnz     room
        lxi     h,emes1
        jmp     mess
! entry found are these parameters
test:   lda     abuf
        ora     a
        jz      swaps
        lhld    bbuf
        mov     a,h
        ora     l
        jz      swaps
        lxi     h,emes2         ! no-no can?t do
        jmp     mess            ! it - delete first
! move file name to block pointed to by fread
room:   lhld    fread
        xchg
        lxi     h,fbuf          ! file name pointer in h,l
        push    d
        mvi     c,nmlen         ! name length count
mov23:  mov     a,m
        stax    d
        inx     d
        dcr     c               ! test count
        inx     h
        jnz     mov23
        pop     d               ! restore entry pointer
! make file pointed to by d,e current
swaps:  lxi     h,file0
        mvi     c,felen         ! entry length
swap:   ldax    d
        mov     b,m
        mov     m,a             ! exchange
        mov     a,b
        stax    d
        inx     d
        inx     h               ! bump pointer
        dcr     c               ! test count
        jnz     swap

! check for 2nd parameter
            lda abuf
        ora     a
        jz      foot            ! no second parameter
! process 2nd parameter
        lhld    bbuf            ! get address
        shld    bofp            ! set begin
        shld    eofp            ! set end
        mov     a,l             ! is address zero
        ora     h
        jz      fil35           ! yes
fil30:  mvi     m,1             ! non-zero ? set eof
fil35:  xra     a               ! and max line #
        sta     maxl
        jmp     foot            ! output parameters
fout:   lda     ibuf+4
        cpi     's'             ! is command files?
        mvi     c,maxfil
        jz      foul
foot:   mvi     c,1
! output the # of entries in c
foul:   lxi     h,file0
        mov     a,c
fine:   sta     focnt           ! save count
        push    h
        lxi     d,nmlen
        dad     d
        mov     a,m
        ora     a
        jnz     food
        inx     h
        add     m
        inx     h
        jnz     food            ! non zero, ok to output
        inx     sp
        inx     sp
        inx     h
        inx     h
        jmp     feet
! have an entry to output
food:   pop     h               ! ptr
        mvi     c,nmlen
fast:   mov     b,m             ! load character to b
        call    out8
        dcr     c
        inx     h
        jnz     fast            ! do the rest
! now output begin-end ptrs
        call    fool            ! output begin
        call    fool            ! output end
        call    crlf            ! and c/r
! test count, h,l points past eofp
feet:   lxi     d,felen-nmlen-4
        dad     d               ! move to next entry
        lda     focnt
        dcr     a               ! test count
        jnz     fine            ! more to do
        ret                     ! done!
! output number pointed to by h,l
! on ret, h,l point 2 words later
fool:   call    blk1            ! space
        inx     h
        mov     a,m
        dcx     h
        push    h
        call    hout            ! output
        pop     h
        mov     a,m
        inx     h
        inx     h
        push    h
        call    hotb            ! output
        pop     h               ! restore h,l
        ret
!
! search the file directory for the file
! whose name is in fbuf.
! return if found, zero if off, h,l point to
! entry while searching, on entry found with addr
! zero, set fef to >0 and fread to the addr of entry
!
fsea:   xra     a
        sta     fef             ! claim no free entries
        mvi     b,maxfil        ! count of entries
        lxi     d,file0         ! table address
fse10:  lxi     h,fbuf
        mvi     c,nmlen
        call    sear            ! test strings
        push    psw             ! save flag
        push    d
        ldax    d               ! get bofp
        ora     a               ! empty entry?
        jnz     fse20
        inx     d               ! store other word
        ldax    d
        ora     a
        jnz     fse20           ! nope-go test for match
        xchg
        lxi     d,-nmlen-1
        dad     d               ! move to beginning
        shld    fread           ! save addr
        mov     a,d
        sta     fef             ! set free entry found
        pop     h               ! restore interim ptr
        pop     psw             ! unjunk stack
! move to next entry
fse15:  lxi     d,felen-nmlen
        dad     d
        xchg                    ! next entry in de
        dcr     b               ! test count
        rz                      ! done--nope
        jmp     fse10           ! try next
! entry wasn?t free, test for match
fse20:  pop     h
        pop     psw
        jnz     fse15           ! if zero clear, no match
! entry found
        lxi     d,-nmlen        ! backup
        dad     d               ! h,l points to entry
        mov     a,d
        ora     a               ! clear zero
        ret                     ! that?s all
!
! output error message for illegal command
!
what:   call    crlf            ! out crlf
wha1:   lxi     h,emes          ! message address
mess:   call    scrn
        jmp     eor
!
emes:   defb    'what'
        defb    13
emes1:  defb    'full',13
emes2:  defb    'no no',13
!
! call routine to enter data into memory
! and check for error on return
!
! this routine is used to enter data values into memory.
! each value is one byte and is written in hexadecimal
! values greater than 255 will cause carry to be set
! and return to be made to calling program
!
entr:   call    vchk            ! check for parameters
        call    ents
        jc      what
        call    crlf
        ret
!
eend:   equ     '/'             ! termination character
ents:   call    crlf
        call    read            ! read input data
        lxi     h,ibuf          ! set line pointer
        shld    pntr            ! save pointer
ent1:   call    zbuf            ! clear buffer
        call    sblk            ! scan to first value
        jc      ents            ! jump if cr found
        cpi     eend
        rz                      ! return carry is zero
        call    alps            ! place value in buffer
        mov     a,b             ! get digit count
        cpi     3               ! check nmbr of digits
        cmc
        rc                      ! return if more than 2 digits
        lxi     b,abuf          ! conversion address
        call    ahex            ! convert value
        rc                      ! error in hex character
        mov     a,l
        lhld    bbuf            ! fetch memory address
        mov     m,a             ! put in memory
        call    ach1            ! increment memory location
        jmp     ent1
!
! this routine is used to enter lines into the file
! area.  the line number is first checked to see if it is
! a valid number (0000-9999).  next it is checked to see
! if it is greater than the maximum current line number.
! if it is, the next line is inserted at the end of the
! current file and the maximum line number is updated as
! well as the end of file position.  line numbers that
! already exist are inserted into the file area at the
! appropriate place and any extra characters in the old
! line are deleted.
!
line:   lda     file0           ! is a file defined?
        ora     a
        jz      what            ! abort if not
        mvi     c,4             ! no of digits to check
        lxi     h,ibuf-1                !initialize address
lick:   inx     h
        mov     a,m             ! fetch line digit
        cpi     '0'             ! check for valid number
        jc      what
        cpi     '9'+1
        jnc     what
        dcr     c
        jnz     lick
        shld    adds            ! find address
        lxi     d,maxl+3        ! get address
        call    com0
        jnc     insr
! get here if new line is greater than maximum line #
        inx     h
        call    lodm            ! get new line number
        lxi     h,maxl+3
        call    stom            ! make it maximum line number
        lxi     d,ibuf-1
        lhld    eofp            ! end of file position
        mvi     c,1
        call    lmov            ! place line in file
seof:   mvi     m,1             ! end of file indicator
        shld    eofp            ! end of file address
        jmp     eor
! get here if new line must be inserted into already
! eisting file area
insr:   call    fin1            ! find line in file
        mvi     c,2
        jz      equl
        dcr     c               ! new ln not equal to some old ln
equl:   mov     b,m
        dcx     h
        mvi     m,2             ! move line indicator
        shld    insp            ! insert line position
        lda     ibuf-1          ! new line count
        dcr     c
        jz      less            !new ln not = old ln
        sub     b               !count difference
        jz      zero            !line lengths equal
        jc      more
! get here if # of chars in old line > # of chars in
! new line or new line # was not equal to sold old
! line #
less:   lhld    eofp            !end of file address
        mov     d,h
        mov     e,l
        call    adr             !move to address
        shld    eofp            !new end of file address
        mvi     c,2
        call    rmov            !open up file area
        jmp     zero
! get here if # of chars in old line < # of chars in
! new line
more:   cma
        inr     a               !count difference
        mov     d,h
        mov     e,l
        call    adr
        xchg
        call    lmov            !delete excess char in file
        mvi     m,1             !e-o-f indicator
        shld    eofp            !e-o-f address
! get here to insert line into file area
zero:   lhld    insp            !insert address
        mvi     m,ascr
        inx     h
        lxi     d,ibuf-1                !new line address
        mvi     c,1             !check value
        call    lmov            !place line in file
        jmp     eor
!
! this routine is used to find a ln in the file area
! which is greater than or equal to the current line #
!
find:   lxi     h,abuf+3                !buffer address
        shld    adds            !save address
fin1:   lhld    bofp            !begin file address
        mov     a,h             !return to monitor if
        ora     l               !  file is empty...
        jz      eor
fi1:    call    eo1             !check for end of file
        xchg
        lhld    adds            !fetch find address
        xchg
        mvi     a,4
        call    adr             !bump line address
        call    com0            !compare line numbers
        rc
        rz      
fi2:    mov     a,m
        call    adr             !next line address
        jmp     fi1
!
! when searching through the file area, this routine
! checks to see if the current address is the end of
! file
!
eof:    inx     h
eo1:    mvi     a,1             !e-o-f indicator
        cmp     m
        rnz
        jmp     eor
!
! this routine is used to add a value to an address
! contained in register h,l
!
adr:    add     l
        mov     l,a
        rnc
        inr     h
        ret
!
! this routine will move character strings from one
! location of memory to another
! characters are moved from location addressed by d,e
! to location addressed by h,l.  additional characters
! are moved by bumping pointers until the character in
! reg c is fetched.
!
lmov:   ldax    d               !fetch character
        inx     d               !increment fetch address
        cmp     c               !termination character
        rz      
        mov     m,a             !store character
        inx     h               !increment store address
        jmp     lmov
!
! this routine is similar to above except that the
! character address is decremented after each fetch
! and store
!
rmov:   ldax    d               !fetch character
        dcx     d               !decrement fetch character
        cmp     c               !termination character
        rz      
        mov     m,a             !store character
        dcx     h               !decrement store address
        jmp     rmov
!
! this routine is used to load four characters from
! memory into registers
!

lodm:   mov     b,m             !fetch character
        inx     h
        mov     c,m             !fetch character 
        inx     h
        mov     d,m             !fetch character 
        inx     h
        mov     e,m             !fetch character 
        ret
!
! this routine stores four characters from the registers
! into memory
!
stom:   mov     m,e             !store character
        dcx     h
        mov     m,d             !store character 
        dcx     h
        mov     m,c             !store character 
        dcx     h
        mov     m,b             !store character 
        ret
!
! this routine is used to compare two character strings
! of length 4, on return zero flag set means both
! strings are equal.  carry flag =0 means string address
! by d,e was greater than or equal to character string
! addressed by h,l
!
com0:   mvi     b,1             !equal counter
        mvi     c,4             !string length
        ora     a               !clear carry
co1:    ldax    d               !fetch character
        sbb     m               !compare characters
        jz      co2
        inr     b               !increment equal counter
co2:    dcx     d
        dcx     h
        dcr     c
        jnz     co1
        dcr     b
        ret
!
! this routine is similar to the above routine except on
! return carry flag = 0 means that character string
! addressed by d,e is only > string addressed by h,l.
!
com1:   mvi     c,4             !string length
        ldax    d               !tch character
        sui     1
        jmp     co1+1
!
! this routine will take ascii characters and add any
! necessary ascii zeroes so the result is a 4 character
! ascii value
!
norm:   call    lodm            !load characters
        xra     a               !fetch a zero
        cmp     b
        rz      
nor1:   cmp     e
        cnz     stom            !store values
        rnz
        mov     e,d             !normalize value
        mov     d,c
        mov     c,b
        mvi     b,'0'
        jmp     nor1
!
! this routine is used to list the contents of the file
! area starting at the line number given in the command
!
list:   call    crlf
        call    find            !find starting line number
list0:  inx     h               !output line...
        call    scrn
        call    crlf
        call    eof             !check for end of file
        call    ink             !check for ?x
        jnz     list0           !loop if no ?x
        ret
!
! this routine is used to delete lines from the
! file area.  the remaining file area is then moved in
! memory so that there is no excess space.
!
dell:   call    vchk            !check for parameter
        call    find            !find line in file area
        shld    delp            !save delete position
        lxi     h,abuf+7
        mov     a,m             !check for 2nd parameter
        ora     a               !set flags
        jnz     del1
        lxi     h,abuf+3                !use first parameter
del1:   shld    adds            !save find address
        xchg
        lxi     h,maxl+3
        call    com0            !compare line numbers
        lhld    delp            !load delete position
        jc      novr
! get here if deletion involves end of file
        shld    eofp            !change e-o-f position
        mvi     m,1             !set e-o-f indicator
        xchg
        lhld    bofp
        xchg
        mvi     b,13            !set scan switch
        dcx     h               !check for bofp
del2:   mov     a,l
        sub     e
        mov     a,h
        sbb     d
        mvi     a,ascr          !look for cr
        jc      del4            !decremented past bof
        dcr     b
        dcx     h
        cmp     m               !find new max ln
        jnz     del2
        dcx     h
        mov     a,l
        sub     e
        mov     a,h
        sbb     d
        jc      del5
        cmp     m               !end of previous line
        inx     h
        inx     h
        jz      del3
        inx     h
del3:   call    lodm            !load new max ln
        lxi     h,maxl+3                !set address
        call    stom            !store new max ln
        ret
del4:   cmp     b               !check switch
del5:   xchg
        jnz     del3-1
        sta     maxl            !make max ln a small number
        ret
! get here if deletion is in the middle of file area
novr:   call    fi1             !find end of delete area
        cz      fi2             !next line if this ln equal
nov1:   xchg
        lhld    delp            !char move to position
        mvi     c,1             !move terminator
        call    lmov            !compact file area
        shld    eofp            !set eof position
        mvi     m,1             !set eof indicator
        ret
!
! starting here is the self assembler program
! this program assembles programs which are
! in the file area
!
assm:   call    vchk            !check for parameters
        lda     abuf+4          !get 2nd parameter
        ora     a               !check for prarmeters
        jnz     asm4
        lhld    bbuf            !fetch 1st parameter
        shld    bbuf+2          !store into 2nd parameter
asm4:   lda     ibuf+4          !fetch input character
        sui     'e'             !reset a if errors only
        sta     aerr            !save error flag
        xra     a               !get a zero
        sta     nola            !initialize label count
asm3:   sta     pasi            !set pass indicator
        call    crlf            !indicate start of pass
        lhld    bbuf            !fetch origin
        shld    aspc            !initialize pc
        lhld    bofp            !get start of file
        shld    apnt
asm1:   lhld    apnt            !fetch line pointer
        lxi     sp,area+18
        mov     a,m             !fetch character
        cpi     1               !end of file?
        jz      eass            !jump if end of file
        xchg
        inx     d               !increment address
        lxi     h,obuf          !blank start address
        mvi     a,ibuf-5 and $0ff       !blank end address
        call    cler            !blank out buffer
        mvi     c,ascr          !stop character
        call    lmov            !move line into buffer
        mov     m,c             !place cr in buffer
        xchg
        shld    apnt            !save address
        lda     pasi            !fetch pass indicator
        ora     a               !set flagw
        jnz     asm2            !jump if pass 2
        call    pas1
        jmp     asm1
!
asm2:   call    pas2
        lxi     h,obuf          !output buffer address
        call    aout            !output line
        jmp     asm1
!
! this routine is used to output the listing for
! an assembly.  it checks the error switch to see if
! all lines are to be printed or just those with
! errors.
!
aout:   lda     aerr            !fetch error switch
        ora     a               !set flags
        jnz     aou1            !output all lines
aou2:   lda     obuf            !fetch error indicator
        cpi     ' '             !check for an error
        rz                      !return if no error
aou1:   lxi     h,obuf          !output buffer address
        call    scrn            !output line...
        call    crlf
        ret
!
! pass 1 of assembler, used to form symbol table
!
pas1:   call    zbuf            !clear buffer
        sta     pasi            !set for pass1
        lxi     h,ibuf          !initialize line pointer
        shld    pntr
        mov     a,m             !fetch character
        cpi     ' '             !check for a blank
        jz      opc             !jump if no lable
        cpi     '*'             !check for comment
        rz                      !return if comment
!
! process label
!
        call    slab            !get and check label
        jc      op5             !error in label
        jz      errd            !duplicate label
        call    lchk            !check character after label
        jnz     op5             !error if no blank
        mvi     c,llab          !length of labels
        lxi     h,abuf          !set buffer address
mlab:   mov     a,m             !fetch next character
        stax    d               !store in symbol table
        inx     d
        inx     h
        dcr     c
        jnz     mlab
        xchg
        shld    taba            !save table address for equ
        lda     aspc+1          !fetch pc (high)
        mov     m,a
        inx     h
        lda     aspc            !fetch pc (low)
        mov     m,a             !store in table
        lxi     h,nola
        inr     m               !increment number of labels
!
! process opcode
!
opc:    call    zbuf            !zero working buffer
        call    sblk            !scan to opcode
        jc      oerr            !found carriage return
        call    alps            !place opcode in buffer
        cpi     ' '             !check for blank after opcode
        jc      opcd            !cr after opcode
        jnz     oerr            !error if no blank
        jmp     opcd            !check opcode
!
! this routine checks the character after a label
! for a blank or colon
!
lchk:   lhld    pntr
        mov     a,m             !get character after label
        cpi     ' '             !check for blank
        rz                      !return if a blank
        cpi     ':'             !check for colon
        rnz
        inx     h
        shld    pntr            !save pointer
        ret
!
! process any pseudo ops that need to be in pass 1
!
psu1:   call    sblk            !scan to operand
        ldax    d               !fetch value
        ora     a               !set flags
        jz      org1            !org opcode
        jm      dat1            !data statement
        jpo     equ1            !equ opcode
        cpi     5
        jc      res1            !res opcode
        jnz     eass            !jump if end
! do dw pseudo/op
aco1:   mvi     c,2             !2 byte instruction
        xra     a               !get a zero
        jmp     ocn1            !add value to program counter
! do org psuedo op
org1:   call    ascn            !get operand
        lda     obuf            !fetch error indicator
        cpi     ' '             !check for an error
        rnz
        shld    aspc            !store new origin
        lda     ibuf            !get first character
        cpi     ' '             !check for an error
        rz                      !no label
        jmp     equs            !change label value
! do equ psuedo-op
equ1:   call    ascn            !get operand
        lda     ibuf            !fetch 1st character
        cpi     ' '             !check for label
        jz      errm            !missing label
equs:   xchg
        lhld    taba            !symbol table address
        mov     m,d             !store label value
        inx     h
        mov     m,e
        ret
! do ds pseudo-op
res1:   call    ascn            !get operand
        mov     b,h
        mov     c,l
        jmp     res21           !add value to program counter
!
! do db pseudo-op
!
dat1:   jmp     dat2a
!
! perform pass 2 of the assembler
!
pas2:   lxi     h,obuf+2                !set output buffer address
        lda     aspc+1          !fetch pc (high)
        call    binh+3          !convert for output
        inx     h
        lda     aspc            !fetch pc(low)
        call    binh+3          !convert for output
        inx     h
        shld    oind            !save output address
        call    zbuf            !clear buffer
        lxi     h,ibuf          !initialize line pointer
pabl:   shld    pntr            !save pointer
        mov     a,m             !fetch first character
        cpi     ' '             !check for label
        jz      opc             !get opcode
        cpi     '*'             !check for comment
        rz                      !return if comment
        call    slab            !scan off label
        jc      errl            !error in label
        call    lchk            !check for a blank or colon
        jnz     errl            !error if not a blank
        jmp     opc
!
! process pseudo ops for pass2
!
psu2:   ldax    d
        ora     a               !set flags
        jz      org2            !org opcode
        jm      dat2            !data opcode
        jpo     equ2            !equate pseudo-op
        cpi     5
        jc      res2            !res opcode
        jnz     eass            !end opcode
! do dw opcode
aco2:   call    tys6            !get value
        jmp     aco1
! do ds pseudo-op
res2:   call    asbl            !get operand
        mov     b,h
        mov     c,l
        lhld    bbuf+2          !fetch storage counter
        dad     b               !add value
        shld    bbuf+2
res21:  xra     a               !get a zero
        jmp     ocn2
! do db pseudo-op
dat2:   call    ty55            !get operand
dat2a:  xra     a               !make zero
        mvi     c,1             !byte count
        jmp     ocn1
!
! handle equates on 2nd pass
!
equ2:   call    asbl            !get operand into hl and
                                !  fall into next routine
!
! store contents of hl as hex ascii at obuf+2
!   on return, de holds value which was in hl.
!
binad:  xchg                    !put value into de
        lxi     h,obuf+2                !pointer to addr in obuf
        mov     a,d             !store hi byte
        call    binh+3
        inx     h
        mov     a,e             !store low byte...
        call    binh+3
        inx     h
        ret
! do org pseudo-op
org2:   call    asbl            !get new origin
        lda     obuf            !get error indicator
        cpi     ' '             !check for an error
        rnz                     !don?t modify pc if error
        call    binad           !store new addr in obuf
        lhld    aspc            !fetch pc
        xchg
        shld    aspc            !store new pc
        mov     a,l
        sub     e               !form difference of origins
        mov     e,a
        mov     a,h
        sbb     d
        mov     d,a
        lhld    bbuf+2          !fetch storage pointer
        dad     d               !modify
        shld    bbuf+2          !save
        ret
!
! process 1 byte instructions without operands
!
typ1:   call    asto            !store value in memory
        ret
!
! process stax and ldax instructions
!
typ2:   call    asbl            !fetch operand
        cnz     errr            !illegal register
        mov     a,l             !get low order operand
        ora     a               !set flags
        jz      ty31            !operand = 0
        cpi     2               !operand = 2
        cnz     errr            !illegal register
        jmp     ty31
!
! process push, pop, inx, dcx, dad instructions
!
typ3:   call    asbl            !fetch operand
        cnz     errr            !illegal register
        mov     a,l             !get low order operand
        rrc                     !check low order bit
        cc      errr            !illegal register
        ral                     !restore
        cpi     8
        cnc     errr            !illegal register
ty31:   rlc                     !multiply by 8
        ral
        ral
ty32:   mov     b,a
        ldax    d               !fetch opcode base
        add     b               !form opcode
        cpi     118             !check for mov m,m
        cz      errr            !illegal register
        jmp     typ1
!
! process accumulator, inr,dcr,mov,rst instructions
!
typ4:   call    asbl            !fetch operand
        cnz     errr            !illegal register
        mov     a,l             !get low order operand
        cpi     8
        cnc     errr            !illegal register
        ldax    d               !fetch opcode base
        cpi     64              !check for mov instruction
        jz      ty41
        cpi     199
        mov     a,l
        jz      ty31            !rst instruction
        jm      ty32            !accumulator instruction
        jmp     ty31            !inr, dcr
! process mov instruction
ty41:   dad     h               !multiply operand by 8
        dad     h
        dad     h
        add     l               !form opcode
        stax    d               !save opcode
        call    mpnt
        call    ascn
        cnz     errr            !increment pointer
        mov     a,l
        cpi     8
        cnc     errr            !illegal register
        jmp     ty32
!
! process immediate instructions
! immediate byte can between -256 and +255
! mvi instruction is a special case and contains
! 2 arguments in operand
!
typ5:   cpi     6               !check for mvi
        cz      ty56
        call    asto            !store object byte
ty55:   call    asbl            !get immediate argument
        inr     a
        cpi     2               !check operand for range
        cnc     errv
        mov     a,l
        jmp     typ1
!
! fetch 1st arg for mvi and lxi instructions
!
ty56:   call    asbl            !fetch arg
        cnz     errr            !illegal register
        mov     a,l             !get low order argument
        cpi     8
        cnc     errr            !illegal register
        dad     h
        dad     h
        dad     h
        ldax    d               !fetch opcode base
        add     l               !for opcode
        mov     e,a             !save object byte
mpnt:   lhld    pntr            !fetch pointer
        mov     a,m             !fetch character
        cpi     ','             !check for comma
        inx     h               !increment pointer
        shld    pntr
        jnz     errs            !syntax error if no comma
        mov     a,e
        ret
!
! process 3 byte instructions
! lxi instruction is a special case
!
typ6:   cpi     1               !check for lxi instruction
        jnz     ty6             !jump if not lxi
        call    ty56            !get register
        ani     $08             !check for illegal register
        cnz     errr            !register error
        mov     a,e             !get opcode
        ani     $f7             !clear bit in error
ty6:    call    asto            !store object byte
tys6:   call    asbl            !fetch operand
        mov     a,l
        mov     d,h
        call    asto            !store 2nd byte
        mov     a,d
        jmp     typ1
        ret
!
! this routine is used to store object code produced
! by the assembler during pass 2 into memory
!
asto:   lhld    bbuf+2          !fetch storage address
        mov     m,a             !store object byte
        inx     h               !increment location
        shld    bbuf+2
        lhld    oind            !fetch output address
        inx     h
        call    binh+3          !convert object byte
        shld    oind
        ret
!
! get here when end pseudo-op is found or when
! end-of-file occurs in source file.  control is set
! for either pass 2 or assembly terminator if finished
!
eass:   lda     pasi            !fetch pass indicator
        ora     a               !set flags
        jnz     eor             !jump if finished
        mvi     a,1             !pass indicator for 2nd pass
        jmp     asm3            !do 2nd pass
!
! this routine scans through a character string until
! the first non-blank character is found
!
! on return, carry set indicates a carriage return
! as  first non-blank character.
!
sblk:   lhld    pntr            !fetch address
sbl1:   mov     a,m             !fetch character
        cpi     ' '             !check for blank
        rnz                     !return if non-blank
sbl2:   inx     h               !increment
        shld    pntr            !save pointer
        jmp     sbl1
!
! this routine is used to check the condition
! code nmeumonics for conditional jumps, calls,
! and returns.
!
cond:   lxi     h,abuf+1
        shld    adds
        mvi     b,2             !2 characters
        call    copc
        ret
!
! the following is the opcode table
!
otab:   defb    'org'
        defb    0
        defb    0
        defb    'equ'
        defb    0
        defb    1
        defb    'db'
        defb    0
        defb    0
        defb    -1 and $0ff
        defb    'ds'
        defb    0
        defb    0
        defb    3
        defb    'dw'
        defb    0
        defb    0
        defb    5
        defb    'end'
        defb    0
        defb    6
        defb    0
        defb    'hlt'
        defb    118
        defb    'rlc'
        defb    7
        defb    'rrc'
        defb    15
        defb    'ral'
        defb    23
        defb    'rar'
        defb    31
        defb    'ret'
        defb    201
        defb    'cma'
        defb    47
        defb    'stc'
        defb    55
        defb    'daa'
        defb    39
        defb    'cmc'
        defb    63
        defb    'ei'
        defb    0
        defb    251
        defb    'di'
        defb    0
        defb    243
        defb    'nop'
        defb    0
        defb    0
        defb    'xchg'
        defb    235
        defb    'xthl'
        defb    227
        defb    'sphl'
        defb    249
        defb    'pchl'
        defb    233
        defb    0
        defb    'stax'
        defb    2
        defb    'ldax'
        defb    10
        defb    0
        defb    'push'
        defb    197
        defb    'pop'
        defb    0
        defb    193
        defb    'inx'
        defb    0
        defb    3
        defb    'dcx'
        defb    0
        defb    11
        defb    'dad'
        defb    0
        defb    9
        defb    0
        defb    'inr'
        defb    4
        defb    'dcr'
        defb    5
        defb    'mov'
        defb    64
        defb    'add'
        defb    128
        defb    'adc'
        defb    136
        defb    'sub'
        defb    144
        defb    'sbb'
        defb    152
        defb    'ana'
        defb    160
        defb    'xra'
        defb    168
        defb    'ora'
        defb    176
        defb    'cmp'
        defb    184
        defb    'rst'
        defb    199
        defb    0
        defb    'adi'
        defb    198
        defb    'aci'
        defb    206
        defb    'sui'
        defb    214
        defb    'sbi'
        defb    222
        defb    'ani'
        defb    230
        defb    'xri'
        defb    238
        defb    'ori'
        defb    246
        defb    'cpi'
        defb    254
        defb    'in'
        defb    0
        defb    219
        defb    'out'
        defb    211
        defb    'mvi'
        defb    6
        defb    0
        defb    'jmp'
        defb    0
        defb    195
        defb    'call'
        defb    205
        defb    'lxi'
        defb    0
        defb    1
        defb    'lda'
        defb    0
        defb    58
        defb    'sta'
        defb    0
        defb    50
        defb    'shld'
        defb    34
        defb    'lhld'
        defb    42
        defb    0
!       condition       code    table
        defb    'nz'
        defb    0
        defb    'z'
        defb    0
        defb    8
        defb    'nc'
        defb    16
        defb    'c'
        defb    0
        defb    24
        defb    'po'
        defb    32
        defb    'pe'
        defb    40
        defb    'p'
        defb    0
        defb    48
        defb    'm'
        defb    0
        defb    56
        defb    0
!
! this routine is used to check a given opcode
! against the legal opcodes in the opcode table
!
copc:   lhld    adds
        ldax    d               !fetch character
        ora     a               !set flags
        jz      cop1            !jump if termination character
        mov     c,b
        call    sear
        ldax    d
        rz                      !return if a match
        inx     d               ! next string
        jmp     copc            !continue search
cop1:   inr     a               !clear zero flag
        inx     d               !increment address
        ret
!
! this routine checks the legal opcodes in both pass 1
! and pass 2.  in pass 1 the program counter is incre-
! mented by the correct number of bytes.  an address is
! also set so that an indexed jump can be made to
! process the opcode for pass 2.
!
opcd:   lxi     h,abuf          !get address
        shld    adds
        lxi     d,otab          !opcode table address
        mvi     b,4             !character count
        call    copc            !check opcode
        jz      pseu            !jump if pseudo-op
        dcr     b               !3-character opcodes
        call    copc
        jz      op1
        inr     b               !4 character opcodes
        call    copc
op1:    lxi     h,typ1          !type 1 instructions
op2:    mvi     c,1             !1 byte instructions
        jz      ocnt
!
opc2:   call    copc            !check for stax, ldax
        lxi     h,typ2
        jz      op2
        call    copc            !check for push,pop,inx
                                ! dcx and dad
        lxi     h,typ3
        jz      op2
        dcr     b               !3 char opcodes
        call    copc            !accumulator instructions,
                                ! inr, dcr, mov, rst
        lxi     h,typ4
        jz      op2
!
opc3:   call    copc            !immediate instructions
        lxi     h,typ5
        mvi     c,2             !2 byte instructions
        jz      ocnt
        inr     b               !4 character opcodes
        call    copc            !jmp, call, lix, lda, sta,
                                ! lhld, shld opcodes
        jz      op4
        call    cond            !conditional instructions
        jnz     oerr            !illegal opcode
        adi     192             !add base value to return
        mov     d,a
        mvi     b,3             !3 character opcodes
        lda     abuf            !fetch first character
        mov     c,a             !save character
        cpi     'r'             !conditional return
        mov     a,d
        jz      op1
        mov     a,c
        inr     d               !form conditional jump
        inr     d
        cpi     'j'             !conditional jump
        jz      opad
        cpi     'c'             !conditional call
        jnz     oerr            !illegal opcode
        inr     d               !form conditional call
        inr     d
opad:   mov     a,d             !get opcode
op4:    lxi     h,typ6
op5:    mvi     c,3             !3 byte instruction
ocnt:   sta     temp            !save opcode
!
! check for opcode only containing the correct number of
! characters.  thus addq, say, would give an error
!
        mvi     a,abuf and $0ff !load buffer address
        add     b               !add length of buffer
        mov     e,a
        mvi     a,abuf/256
        aci     0               !get high order address
        mov     d,a
        ldax    d               !fetch character after opcode
        ora     a               !it should be zero
        jnz     oerr            !opcode error
        lda     pasi            !fetch pass indicator
ocn1:   mvi     b,0
        xchg
ocn2:   lhld    aspc            !fetch program counter
        dad     b               !add in byte count
        shld    aspc            !store pc
        ora     a               !which pass?
        rz                      !return if pass 1
        lda     temp            !fetch opcode
        xchg
        pchl
!
oerr:   lxi     h,erro          !get error address
        mvi     c,3             !leave 3 bytes for patch
        jmp     ocn1-3
!
pseu:   lxi     h,abuf+4                !set buffer address
        mov     a,m             !fetch character after opcode
        ora     a               !should be a zero
        jnz     oerr
        lda     pasi            !fetch pass indicator
        ora     a
        jz      psu1
        jmp     psu2
!
! this routine is used to process labels.
! it checks to see if a label is in the symbol table
! or not.  on return, z=1 indicates a match was found
! and h,l contain the value associated with the label.
! the register names a, b, c, d, e, h, l, p, and s are
! pre-defined and need not be entered by the user.
! on return, c=1 indicates a label error.
!
slab:   cpi     'a'             !check for legal character
        rc
        cpi     'z'+1           !check for illegal character
        cmc
        rc                      !return if illegal character
        call    alps            !place symbol in buffer
        lxi     h,abuf          !set buffer address
        shld    adds            !save address
        dcr     b               !check if one character
        jnz     sla1
! check if prefefined register name
        inr     b               !set b=1
        lxi     d,rtab          !register name table
        call    copc            !check name of register
        jnz     sla1            !not a prefefined regigter
        mov     l,a             !set value (high)
        mvi     h,0
        jmp     sla2
sla1:   lda     nola            !fetch symbol count
        mov     b,a
        lxi     d,symt          !set symbol table address
        ora     a               !are there any labels?
        jz      sla3            !jump if no labels
        mvi     a,llab          !fetch length of label
        sta     nchr
        call    coms            !check table
        mov     c,h             !swap h and l
        mov     h,l
        mov     l,c
sla2:   stc                     !set carry
        cmc                     !clear carry
        ret                     !return
sla3:   inr     a               !clear zero flag
        ora     a               !clear carry
        ret
!
! predefine register values in this table
!
rtab:   defb    'a'
        defb    7
        defb    'b'
        defb    0
        defb    'c'
        defb    1
        defb    'd'
        defb    2
        defb    'e'
        defb    3
        defb    'h'
        defb    4
        defb    'l'
        defb    5
        defb    'm'
        defb    6
        defb    'p'
        defb    6
        defb    's'
        defb    6
        defb    0               !end of table indicator.
!
! this routine scans the input line and places th
! opcodes and labels in the buffer.  the scan terminates
! when a character other than 0-9 or a-z is found.
!
alps:   mvi     b,0             !set count
alp1:   stax    d               !store character in buffer
        inr     b               !increment count
        mov     a,b             !fetch count
        cpi     11              !maximum buffer size
        rnc                     !return if buffer filled
        inx     d               !increment buffer
        inx     h               !increment input pointer
        shld    pntr            !save line pointer
        mov     a,m             !fetch character
        cpi     '0'             !check for illegal characters
        rc
        cpi     '9'+1
        jc      alp1
        cpi     'a'
        rc
        cpi     'z'+1
        jc      alp1
        ret
!
! this routine is used to scan through the input line
! to fetch the value of the operand field.  on return,
! the value of the operand is contained in reg?s h,l
!
asbl:   call    sblk            !get 1st argument
ascn:   lxi     h,0             !get a zero
        shld    oprd            !initialize operand
        inr     h
        shld    opri-1          !initialize operand indicator
nxt1:   lhld    pntr            !fetch scan pointer
        dcx     h
        call    zbuf            !clear buffer
        sta     sign            !zero sign indicator
nxt2:   inx     h               !increment pointer
        mov     a,m             !fetch next character
        cpi     ' '+1
        jc      send            !jump if cr or blank
        cpi     ','             !field separator
        jz      send
! check for operator
        cpi     '+'             !check for plus
        jz      asc1
        cpi     '-'             !check for minus
        jnz     asc2
        sta     sign
asc1:   lda     opri            !fetch operand indicator
        cpi     2               !check for 2 operators
        jz      errs            !syntax error
        mvi     a,2
        sta     opri            !set indicator
        jmp     nxt2
! check for operands
asc2:   mov     c,a             !save character
        lda     opri            !get indicator
        ora     a               !check for 2 operands
        jz      errs            !syntax error
        mov     a,c
        cpi     '$'             !lc expression
        jnz     asc3
        inx     h               !increment pointer
        shld    pntr            !save pointer
        lhld    aspc            !fetch location counter
        jmp     aval
!check for ascii characters
asc3:   cpi     $27             !check for single quote
        jnz     asc5            !jump if not quote
        lxi     d,0             !get a zero
        mvi     c,3             !character count
asc4:   inx     h               !bump pointer
        shld    pntr            !save
        mov     a,m             !fetch next character
        cpi     ascr            !is it a carriage return?
        jz      erar            !argument error
        cpi     $27             !is it a quote?
        jnz     sstr
        inx     h               !increment pointer
        shld    pntr            !save
        mov     a,m             !fetch next char
        cpi     $27             !check for 2 quotes in a row
        jnz     aval+1          !terminal quote
sstr:   dcr     c               !check count
        jz      erar            !too many characters
        mov     d,e
        mov     e,a             !set character in buffer
        jmp     asc4
asc5:   cpi     '0'             !check for numeric
        jc      erar            !illegal character
        cpi     '9'+1
        jnc     alab
        call    nums            !get numeric value
        jc      erar            !argument error
aval:   xchg
        lhld    oprd            !fetch operand
        xra     a               !get a zero
        sta     opri            !stor in operand indicator
        lda     sign            !get sign indicator
        ora     a               !set flags
        jnz     asub
        dad     d               !form result
asc7:   shld    oprd            !save result
        jmp     nxt1
asub:   mov     a,l
        sub     e
        mov     l,a
        mov     a,h
        sbb     d
        mov     h,a
        jmp     asc7
alab:   call    slab
        jz      aval
        jc      erar            !illegal symbol
        jmp     erru            !undefined symbol
!
! get here when terminating character is found.
! check for leading field separator
!
send:   lda     opri            !fetch operand indicator
        ora     a               !set flags
        jnz     errs            !syntax error
        lhld    oprd
sen1:   mov     a,h             !get high order byte
        lxi     d,temp          !get address
        ora     a               !set flags
        ret
!
! get a numeric value which is either hexadecimal or
! decimal.  on return, carry set indicates an error.
!
nums:   call    alps            !get numeric
        dcx     d
        ldax    d               !get last character
        lxi     b,abuf          !set buffer address
        cpi     'h'             !is it hexadecimal?
        jz      num2
        cpi     'd'             !is it decimal
        jnz     num1
        xra     a               !get a zero
        stax    d               !clear d from buffer
num1:   call    adec            !convert decimal value
        ret
num2:   xra     a               !get a zero
        stax    d               !clear h from buffer
        call    ahex
        ret
!
! process register error
!
errr:   mvi     a,'r'           !get indicator
        lxi     h,0             !get a zero
        sta     obuf            !set in output buffer
        ret
!
! process syntax error
!
errs:   mvi     a,'s'           !get indicator
        sta     obuf            !store in output buffer
        lxi     h,0
        jmp     sen1
!
! process undefined symbol error
!
erru:   mvi     a,'u'           !get indicator
        jmp     errs+2
!
! process value error
!
errv:   mvi     a,'v'           !get indicator
        jmp     errr+2
!
! process missing label error
!
errm:   mvi     a,'m'           !get indicator
        sta     obuf            !store in output buffer
        call    aou1            !display error
        ret
!
!process argument error
!
erar:   mvi     a,'a'           !get indicator
        jmp     errs+2
!
! process opcode error
! store 3 bytes of zero in object code to provide
! for a patch
!
erro:   mvi     a,'o'           !get indicator
        sta     obuf            !store in output buffer
        lda     pasi            !fetch pass indicator
        ora     a               !which pass
        rz                      !return if pass 1
        mvi     c,3             !need 3 bytes
ero1:   xra     a               !get a zero
        call    asto            !put in listing and memory
        dcr     c
        jnz     ero1
        ret
!
! process label error
!
errl:   mvi     a,'l'           !get indicator
        jmp     erro+2
!
! process duplicate label error
!
errd:   mvi     a,'d'           !get indicator
        sta     obuf
        call    aout
        jmp     opc
!
! this routine sets or clears breakpoints
!
break:  lda     abuf            !check for an arg
        ora     a
        jz      clrb            !if no argument, go clear breakpoint
        mvi     d, nbr          !else get number of breakpoints
        lxi     h,brt           !and addr of table
b1:     mov     a,m             !get hi byte of entry
        inx     h
        mov     b,m             !get low byte of entry
        ora     b               !check for empty entry
        jz      b2              !branch if empty
        inx     h               !else go on to next entry
        inx     h
        dcr     d               !bump count
        jnz     b1              !and try again
        jmp     what            !oops no room
b2:     dcx     h
        xchg
        lhld    bbuf            !get address
        xchg                    !in d,e
        mov     a,d             !check for addr > 11d
        ora     a
        jnz     b3
        mov     a,e
        cpi     11
        jc      what            !oops, too low
b3:     mov     m,d             !save address
        inx     h
        mov     m,e
        inx     h
        ldax    d               !pick up instruction
        mov     m,a             !save it
        mvi     a,$cf           !rst 1 instruction
        stax    d
        mvi     a,$c3           !set up lo memory
        sta     8               !with a jump to breakpoint
        lxi     h,brkp
        shld    9
        ret                     !then return
!
! this routine clears all breakpoints
!
clrb:   lxi     h,brt           !get table address
        mvi     b,nbr           !get number of breakpoints
clbl:   xra     a               !get a zero
        mov     d,m             !get hi-byte of entry
        mov     m,a
        inx     h
        mov     e,m             !get lo-byte of entry
        mov     m,a
        inx     h
        mov     b,m             !get inst byte
        inx     h
        mov     a,d             !was this a null entry
        ora     e
        jz      cl2             !branch if it was
        mov     a,b
        stax    d               !else plug inst back in
cl2:    dcr     b               !bump count
        jnz     clbl            !go do next one
        ret
!
! come here when we hit a breakpoint
!
brkp:   shld    hold+8          !save h,l
        pop     h               !get pc
        dcx     h               !adjust it
        shld    hold+10         !save it
        push    psw             !save flags
        pop     h               !get them into h,l
        shld    hold            !now store them for user
        lxi     h,0
        dad     sp              !get stack pointer
        lxi     sp,hold+8       !set stack pointer again
        push    h               !save old sp
        push    d               !save d,e
        push    b               !save b,c
        cma                     !complement accumulator
        out     $ff             !display it in lights
        lxi     sp,area+18      !set sp again
        lhld    hold+10         !get pc
        xchg                    !into d,e
        lxi     h,brt           !get addr of table
        mvi     b,nbr           !and number of entries
bl1:    mov     a,m             !get an entry from the table
        inx     h
        cmp     d               !does it match?
        jnz     bl2             !branch if not
        mov     a,m             !else get next byte
        cmp     e               !check it
        jz      bl3             !it matches!
bl2:    inx     h               !bump around this entry
        inx     h
        dcr     b               !bump count
        jz      what            !not in our table
        jmp     bl1
!
bl3:    inx     h
        mov     a,m             !get instr byte
        stax    d               !put it back
        xra     a               !clear entry in table
        dcx     h
        mov     m,a
        dcx     h
        mov     m,a
        call    crlf            !restore the carriage
        lda     hold+11         !get hi-byte of pc
        call    hout            !type it
        lda     hold+10         !get lo-byte of pc
        call    hout            !type it
        lxi     h,bmes          !tell user what it is
        call    scrn
        jmp     eor             !go back to command level
!
bmes:   defb    ' break',13
!
! this routine proceeds from a breakpoint
!
proc:   lda     abuf            !check for arg
        ora     a
        jz      p1              !jump if no arg
        lhld    bbuf            !else get arg
        shld    hold+10         !plug it into pc slot
p1:     lxi     sp,hold         !set sp to point at reg?s
        pop     psw             !restore psw
        pop     b               !restore b,c
        pop     d               !restore d,e
        pop     h               !get old sp
        sphl                    !restore it
        lhld    hold+10         !get pc
        push    h               !put it on stack
        lhld    hold+8          !restore h,l
        ret                     !and proceed
!
! system ram
!

!
! define breakpoint region
!
nbr:    equ     8               !number of breakpoints
hold:   defvs   12              !register hold area
brt:    defvs   3*nbr           !breakpoint table
!
! file area parameters
!
maxfil: equ     6
nmlen:  equ     5
felen:  equ     nmlen+8
file0:  defvs   nmlen
bofp:   defvs   2
eofp:   defvs   2
maxl:   defvs   4
filtb:  defvs   (maxfil-1)*felen
insp:   defvs   2
delp:   equ     insp
ascr:   equ     13
hcon:   defvs   2
adds:   equ     hcon
fbuf:   defvs   nmlen
fread:  defvs   2
fef:    defvs   1
focnt:  equ     fef
abuf:   defvs   12
bbuf:   defvs   4
scnt:   defvs   1
dcnt:   defvs   1
ncom:   equ     11
taba:   defvs   2
aspc:   defvs   2
pasi:   defvs   1
nchr:   defvs   1
pntr:   defvs   2
nola:   defvs   1
sign:   defvs   1
oprd:   defvs   2
opri:   defvs   1
temp:   defvs   1
apnt:   equ     insp
aerr:   equ     scnt
oind:   defvs    2
llab:   equ     5
area:   defvs    18
obuf:   defvs    16
        defvs    5
ibuf:   defvs    83
swch:   equ     $ff
symt:   defvs
