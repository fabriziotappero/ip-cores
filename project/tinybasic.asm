!**************************************************************
!* 
!*                tiny basic for intel 8080
!*                      version 1.0
!*                    by li-chen wang
!*                     10 june, 1976 
!*                       @copyleft 
!*                  all wrongs reserved
!* 
!**************************************************************
!* 
!*  !*** zero page subroutines ***
!* 
!*  the 8080 instruction set lets you have 8 routines in low 
!*  memory that may be called by rst n, n being 0 through 7. 
!*  this is a one byte instruction and has the same power as 
!*  the three byte instruction call llhh.  tiny basic will 
!*  use rst 0 as start and rst 1 through rst 7 for 
!*  the seven most frequently used subroutines.
!*  two other subroutines (crlf and tstnum) are also in this 
!*  section.  they can be reached only by 3-byte calls.
!
! Note: this version was extensively damaged to adapt to CP/M,
! I am attempting to find other copies to reference to in order
! to correct it.
!
!* 
       jmp  ninit     ! go main start
       alignp 8
*
       xthl           !*** tstc or rst 1 *** 
       rst  5         !ignore blanks and 
       cmp  m         !test character
       jmp  tc1       !rest of this is at tc1
* 
crlf:  mvi  a,0dh     !*** crlf ***
* 
       push psw       !*** outc or rst 2 *** 
       lda  ocsw      !print character only
       ora  a         !iff ocsw switch is on
       jmp  oc2       !rest of this is at oc2
* 
       call expr2     !*** expr or rst 3 *** 
       push h         !evaluate an expresion 
       jmp  expr1     !rest of it is at expr1
       defb 'w' 
* 
       mov  a,h       !*** comp or rst 4 *** 
       cmp  d         !compare hl with de
       rnz            !return correct c and
       mov  a,l       !z flags 
       cmp  e         !but old a is lost 
       ret
       defb 'an'
* 
ss1:   ldax d         !*** ignblk/rst 5 ***
       cpi  40q       !ignore blanks 
       rnz            !in text (where de->)
       inx  d         !and return the first
       jmp  ss1       !non-blank char. in a
* 
       pop  psw       !*** finish/rst 6 ***
       call fin       !check end of command
       jmp  qwhat     !print "what?" iff wrong
       defb 'g' 
* 
       rst  5         !*** tstv or rst 7 *** 
       sui  100q      !test variables
       rc             !c:not a variable
*
tstv1: jnz  tv1       !not "@" array 
       inx  d         !it is the "@" array 
       call parn      !@ should be followed
       dad  h         !by (expr) as its index
       jc   qhow      !is index too big? 
       push d         !will it overwrite 
       xchg           !text? 
       call size      !find size of free 
       rst  4         !and check that
       jc   asorry    !iff so, say "sorry"
ss1a:  lxi  h,varbgn  !iff not, get address 
       call subde     !of @(expr) and put it 
       pop  d         !in hl 
       ret            !c flag is cleared 
tv1:   cpi  33q       !not @, is it a to z?
       cmc            !iff not return c flag
       rc 
       inx  d         !iff a through z
tv1a:  lxi  h,varbgn  !compute address of
       rlc            !that variable 
       add  l         !and return it in hl 
       mov  l,a       !with c flag cleared 
       mvi  a,0 
       adc  h 
       mov  h,a 
       ret
!* 
!*                 tstc   xch  hl,(sp)   !*** tstc or rst 1 *** 
!*                        ignblk         this is at loc. 8 
!*                        cmp  m         and then jmp here 
tc1:   inx  h         !compare the byte that 
       jz   tc2       !follows the rst inst. 
       push b         !with the text (de->)
       mov  c,m       !iff not =, add the 2nd 
       mvi  b,0       !byte that follows the 
       dad  b         !rst to the old pc 
       pop  b         !i.e., do a relative 
       dcx  d         !jump iff not = 
tc2:   inx  d         !iff =, skip those bytes
       inx  h         !and continue
       xthl 
       ret
!* 
tstnum:lxi  h,0       !*** tstnum ***
       mov  b,h       !test iff the text is 
       rst  5         !a number
tn1:   cpi  60q       !iff not, return 0 in 
       rc             !b and hl
       cpi  72q       !iff numbers, convert 
       rnc            !to binary in hl and 
       mvi  a,360q    !set a to # of digits
       ana  h         !iff h>255, there is no 
       jnz  qhow      !room for next digit 
       inr  b         !b counts # of digits
       push b 
       mov  b,h       !hl=10!*hl+(new digit)
       mov  c,l 
       dad  h         !where 10!* is done by
       dad  h         !shift and add 
       dad  b 
       dad  h 
       ldax d         !and (digit) is from 
       inx  d         !stripping the ascii 
       ani  17q       !code
       add  l 
       mov  l,a 
       mvi  a,0 
       adc  h 
       mov  h,a 
       pop  b 
       ldax d         !do this digit after 
       jp   tn1       !digit. s says overflow
qhow:  push d         !*** error: "how?" *** 
ahow:  lxi  d,how 
       jmp  error 
how:   defb 'how?',0dh 
ok:    defb 'ok',0dh 
what:  defb 'what?',0dh 
sorry: defb 'sorry',0dh 
!* 
!**************************************************************
!* 
!* *** main ***
!* 
!* this is the main loop that collects the tiny basic program
!* and stores it in the memory.
!* 
!* at start, it prints out "(cr)ok(cr)", and initializes the 
!* stack and some other internal variables.  then it prompts 
!* ">" and reads a line.  iff the line starts with a non-zero 
!* number, this number is the line number.  the line number
!* (in 16 bit binary) and the rest of the line (including cr)
!* is stored in the memory.  iff a line with the same line
!* number is alredy there, it is replaced by the new one.  if
!* the rest of the line consists of a 0dhonly, it is not stored
!* and any existing line with the same line number is deleted. 
!* 
!* after a line iss inserted, replaced, or deleted, the program 
!* loops back and ask for another line.  this loop will be 
!* terminated when it reads a line with zero or no line
!* number! and control is transfered to "dirct".
!* 
!* tiny basic program save area starts at the memory location
!* labeled "txtbgn" and ended at "txtend".  we always fill this
!* area starting at "txtbgn", the unfilled portion is pointed
!* by the content of a memory location labeled "txtunf". 
!* 
!* the memory location "currnt" points to the line number
!* that is currently being interpreted.  while we are in 
!* this loop or while we are interpreting a direct command 
!* (see next section), "currnt" should point to a 0. 
!* 
rstart:lxi  sp,stack  !set stack pointer
st1:   call crlf      !and jump to here
       lxi  d,ok      !de->string
       sub  a         !a=0 
       call prtstg    !print string until 0dh
       lxi  h,st2+1   !literal 0 
       shld currnt    !currnt->line # = 0
st2:   lxi  h,0 
       shld lopvar
       shld stkgos
st3:   mvi  a,76q     !prompt '>' and
       call getln     !read a line 
       push d         !de->end of line 
st3a:  lxi  d,buffer  !de->beginning of line 
       call tstnum    !test iff it is a number
       rst  5 
       mov  a,h       !hl=value of the # or
       ora  l         !0 iff no # was found 
       pop  b         !bc->end of line 
       jz   direct
       dcx  d         !backup de and save
       mov  a,h       !value of line # there 
       stax d 
       dcx  d 
       mov  a,l 
       stax d 
       push b         !bc,de->begin, end 
       push d 
       mov  a,c 
       sub  e 
       push psw       !a=# of bytes in line
       call fndln     !find this line in save
       push d         !area, de->save area 
       jnz  st4       !nz:not found, insert
       push d         !z:found, delete it
       call fndnxt    !find next line
!*                                       de->next line 
       pop  b         !bc->line to be deleted
       lhld txtunf    !hl->unfilled save area
       call mvup      !move up to delete 
       mov  h,b       !txtunf->unfilled area 
       mov  l,c 
       shld txtunf    !update
st4:   pop  b         !get ready to insert 
       lhld txtunf    !but firt check if
       pop  psw       !the length of new line
       push h         !is 3 (line # and cr)
       cpi  3         !then do not insert
       jz   rstart    !must clear the stack
       add  l         !compute new txtunf
       mov  l,a 
       mvi  a,0 
       adc  h 
       mov  h,a       !hl->new unfilled area 
st4a:  lxi  d,txtend  !check to see if there 
       rst  4         !is enough space 
       jnc  qsorry    !sorry, no room for it 
       shld txtunf    !ok, update txtunf 
       pop  d         !de->old unfilled area 
       call mvdown
       pop  d         !de->begin, hl->end
       pop  h 
       call mvup      !move new line to save 
       jmp  st3       !area
!* 
!**************************************************************
!* 
!* *** tables *** direct *** & exec ***
!* 
!* this section of the code tests a string against a table.
!* when a match is found, control is transfered to the section 
!* of code according to the table. 
!* 
!* at 'exec', de should point to the string ad hl should point
!* to the table-1.  at 'direct', de should point to the string,
!* hl will be set up to point to tab1-1, which is the table of 
!* all direct and statement commands.
!* 
!* a '.' in the string will terminate the test and the partial 
!* match will be considered as a match.  e.g., 'p.', 'pr.',
!* 'pri.', 'prin.', or 'print' will all match 'print'. 
!* 
!* the table consists of any number of items.  each item 
!* is a string of characters with bit 7 set to 0 and 
!* a jump address stored hi-low with bit 7 of the high 
!* byte set to 1.
!* 
!* end of table is an item with a jump address only.  iff the 
!* string does not match any of the other items, it will 
!* match this null item as default.
!* 
tab1:  equ  $         !direct commands 
       defb 'list'
       defb list shr 8 + 128,list and 0ffh
       defb 'run'
       defb run shr 8 + 128,run and 255
       defb 'new'
       defb new shr 8 + 128,new and 255
       defb 'load'
       defb dload shr 8 + 128,dload and 255
       defb 'save'
       defb dsave shr 8 + 128,dsave and 255
       defb 'bye',80h,0h   !go back to cpm
tab2:  equ  $         !direct/tatement
       defb 'next'
       defb next shr 8 + 128,next and 255
       defb 'let'
       defb let shr 8 + 128,let and 255
       defb 'out'
       defb outcmd shr 8 + 128,outcmd and 255 
       defb 'poke'
       defb poke shr 8 + 128,poke and 255
       defb 'wait'
       defb waitcm shr 8 + 128,waitcm and 255
       defb 'if'
       defb iff shr 8 + 128,iff and 255
       defb 'goto'
       defb goto shr 8 + 128,goto and 255
       defb 'gosub'
       defb gosub shr 8 + 128,gosub and 255
       defb 'return'
       defb return shr 8 + 128,return and 255
       defb 'rem'
       defb rem shr 8 + 128,rem and 255
       defb 'for'
       defb for shr 8 + 128,for and 255
       defb 'input'
       defb input shr 8 + 128,input and 255
       defb 'print'
       defb print shr 8 + 128,print and 255
       defb 'stop'
       defb stop shr 8 + 128,stop and 255
       defb deflt shr 8 + 128,deflt and 255
       defb 'you can add more' !commands but
            !remember to move default down.
tab4:  equ  $         !functions 
       defb 'rnd'
       defb rnd shr 8 + 128,rnd and 255
       defb 'inp'
       defb inp shr 8 + 128,inp and 255
       defb 'peek'
       defb peek shr 8 + 128,peek and 255
       defb 'usr'
       defb usr shr 8 + 128,usr and 255
       defb 'abs'
       defb abs shr 8 + 128,abs and 255
       defb 'size'
       defb size shr 8 + 128,size and 255
       defb xp40 shr 8 + 128,xp40 and 255
       defb 'you can add more' !functions but remember
                      !to move xp40 down
tab5:  equ  $         !"to" in "for" 
       defb 'to'
       defb fr1 shr 8 + 128,fr1 and 255
       defb qwhat shr 8 + 128,qwhat and 255
tab6:  equ  $         !"step" in "for" 
       defb 'step'
       defb fr2 shr 8 + 128,fr2 and 255
       defb fr3 shr 8 + 128,fr3 and 255
tab8:  equ  $         !relation operators
       defb '>='
       defb xp11 shr 8 + 128,xp11 and 255
       defb '#'
       defb xp12 shr 8 + 128,xp12 and 255
       defb '>'
       defb xp13 shr 8 + 128,xp13 and 255
       defb '='
       defb xp15 shr 8 + 128,xp15 and 255
       defb '<='
       defb xp14 shr 8 + 128,xp14 and 255
       defb '<'
       defb xp16 shr 8 + 128,xp16 and 255
       defb xp17 shr 8 + 128,xp17 and 255
!* 
direct:lxi  h,tab1-1  !*** direct ***
!* 
exec:  equ  $         !*** exec ***
ex0:   rst  5         !ignore leading blanks 
       push d         !save pointer
ex1:   ldax d         !iff found '.' in string
       inx  d         !before any mismatch 
       cpi  56q       !we declare a match
       jz   ex3 
       inx  h         !hl->table 
       cmp  m         !iff match, test next 
       jz   ex1 
       mvi  a,177q    !else, see iff bit 7
       dcx  d         !of tableis set, which
       cmp  m         !is the jump addr. (hi)
       jc   ex5       !c:yes, matched
ex2:   inx  h         !nc:no, find jump addr.
       cmp  m 
       jnc  ex2 
       inx  h         !bump to next tab. item
       pop  d         !restore string pointer
       jmp  ex0       !test against next item
ex3:   mvi  a,177q    !partial match, find 
ex4:   inx  h         !jump addr., which is
       cmp  m         !flagged by bit 7
       jnc  ex4 
ex5:   mov  a,m       !load hl with the jump 
       inx  h         !address from the table
       mov  l,m 
       ani  177q      !mask off bit 7
       mov  h,a 
       pop  psw       !clean up the gabage 
       pchl           !and we go do it 
!* 
!**************************************************************
!* 
!* what follows is the code to execute direct and statement
!* commands.  control is transfered to these points via the
!* command table lookup code of 'direct' and 'exec' in last
!* section.  after the command is executed, control is 
!* tansfered to other sections as follows:
!* 
!* for 'list', 'new', and 'stop': go back to 'rstart'
!* for 'run': go execute the first stored line iff any! else
!* go back to 'rstart'.
!* for 'goto' and 'gosub': go execute the target line. 
!* for 'return' and 'next': go back to saved return line.
!* for all others: iff 'currnt' -> 0, go to 'rstart', else
!* go execute next command.  (this is done in 'finish'.) 
!* 
!**************************************************************
!* 
!* *** new *** stop *** run (& friends) *** & goto *** 
!* 
!* 'new(cr)' sets 'txtunf' to point to 'txtbgn'
!* 
!* 'stop(cr)' goes back to 'rstart'
!* 
!* 'run(cr)' finds the first stored line, store its address (in
!* 'currnt'), and start execute it.  note that only those
!* commands in tab2 are legal for stored program.
!* 
!* there are 3 more entries in 'run':
!* 'runnxl' finds next line, stores its addr. and executes it. 
!* 'runtsl' stores the address of this line and executes it. 
!* 'runsml' continues the execution on same line.
!* 
!* 'goto expr(cr)' evaluates the expression, find the target 
!* line, and jump to 'runtsl' to do it.
!* 'dload' loads a named program from disk.
!* 'dsave' saves a named program on disk.
!* 'fcbset' sets up the file control block for subsequent disk i/o.
!* 
new:   call endchk    !*** new(cr) *** 
       lxi  h,txtbgn
       shld txtunf
!* 
stop:  call endchk    !*** stop(cr) ***
       jmp rstart
!* 
run:   call endchk    !*** run(cr) *** 
       lxi  d,txtbgn  !first saved line
!* 
runnxl:lxi  h,0       !*** runnxl ***
       call fndlnp    !find whatever line #
       jc   rstart    !c:passed txtunf, quit 
!* 
runtsl:xchg           !*** runtsl ***
       shld currnt    !set 'currnt'->line #
       xchg 
       inx  d         !bump pass line #
       inx  d 
!* 
runsml:call chkio     !*** runsml ***
       lxi  h,tab2-1  !find command in tab2
       jmp  exec      !and execute it
!* 
goto:  rst  3         !*** goto expr *** 
       push d         !save for error routine
       call endchk    !must find a 0dh
       call fndln     !find the target line
       jnz  ahow      !no such line #
       pop  psw       !clear the "push de" 
       jmp  runtsl    !go do it
cpm:   equ  5         !disk parameters
fcb:   equ  5ch
setdma:equ  26
open:  equ  15
readd: equ  20
writed:equ  21
close: equ  16
make:  equ  22
delete:equ  19
!*
dload: rst  5         !ignore blanks
       push h         !save h
       call fcbset    !set up file control block
       push d         !save the rest
       push b         
       lxi  d,fcb     !get fcb address
       mvi  c,open    !prepare to open file
       call cpm       !open it
       cpi  0ffh      !is it there?
       jz   qhow      !no, send error
       xra  a         !clear a
       sta  fcb+32    !start at record 0
       lxi  d,txtunf  !get beginning
load:  push d         !save dma address
       mvi  c,setdma  !
       call cpm       !set dma address
       mvi  c,readd   !
       lxi  d,fcb
       call cpm       !read sector
       cpi  1         !done?
       jc   rdmore    !no, read more
       jnz  qhow      !bad read
       mvi  c,close
       lxi  d,fcb 
       call cpm       !close file
       pop  d         !throw away dma add.
       pop  b         !get old registers back
       pop  d
       pop  h
       rst  6         !finish
rdmore:pop  d         !get dma address
       lxi  h,80h     !get 128
       dad  d         !add 128 to dma add.
       xchg           !put it back in d
       jmp  load      !and read some more
!*
dsave: rst  5         !ignore blanks
       push h         !save h
       call fcbset    !setup fcb
       push d
       push b         !save others
       lxi  d,fcb
       mvi  c,delete
       call cpm       !erase file if it exists
       lxi  d,fcb  
       mvi  c,make
       call cpm       !make a new one
       cpi  0ffh      !is there space?
       jz   qhow      !no, error
       xra  a         !clear a
       sta  fcb+32    !start at record 0
       lxi  d,txtunf  !get beginning
save:  push d         !save dma address
       mvi  c,setdma  !
       call cpm       !set dma address
       mvi  c,writed
       lxi  d,fcb 
       call cpm       !write sector
       ora  a         !set flags
       jnz  qhow      !if not zero, error
       pop  d         !get dma add. back
       lda  txtunf+1  !and msb of last add.
       cmp  d         !is d smaller?
       jc   savdon    !yes, done
       jnz  writmor   !dont test e if not equal
       lda  txtunf    !is e smaller?
       cmp  e
       jc   savdon    !yes, done
writmor:lxi  h,80h 
       dad  d         !add 128 to dma add.
       xchg           !get it back in d
       jmp  save      !write some more
savdon:mvi  c,close
       lxi  d,fcb 
       call cpm       !close file
       pop  b         !get registers back
       pop  d
       pop  h
       rst  6         !finish
!*
fcbset:lxi  h,fcb     !get file control block address
       mvi  m,0       !clear entry type
fnclr: inx  h         !next location
       mvi  m,' '     !clear to space
       mvi  a,fcb+8 and 255
       cmp  l         !done?
       jnz  fnclr     !no, do it again
       inx  h         !next
       mvi  m,'t'     !set file type to 'tbi'
       inx  h
       mvi  m,'b'
       inx  h
       mvi  m,'i'
exrc:  inx  h         !clear rest of fcb
       mvi  m,0
       mvi  a,fcb+15 and 255
       cmp  l         !done?
       jnz  exrc      !no, continue
       lxi  h,fcb+1   !get filename start
fn:    ldax d         !get character
       cpi  0dh       !is it a 'cr'
       rz             !yes, done
       cpi  '!'       !legal character?
       jc   qwhat     !no, send error
       cpi  '['       !again
       jnc  qwhat     !ditto
       mov  m,a        !save it in fcb
       inx  h         !next
       inx  d
       mvi  a,fcb+9 and 255
       cmp  l         !last?
       jnz  fn        !no, continue
       ret            !truncate at 8 characters
!* 
!************************************************************* 
!* 
!* *** list *** & print ***
!* 
!* list has two forms: 
!* 'list(cr)' lists all saved lines
!* 'list #(cr)' start list at this line #
!* you can stop the listing by control c key 
!* 
!* print command is 'print ....!' or 'print ....(cr)'
!* where '....' is a list of expresions, formats, back-
!* arrows, and strings.  these items are seperated by commas.
!* 
!* a format is a pound sign followed by a number.  it controlss 
!* the number of spaces the value of a expresion is going to 
!* be printed.  it stays effective for the rest of the print 
!* command unless changed by another format.  iff no format is
!* specified, 6 positions will be used.
!* 
!* a string is quoted in a pair of single quotes or a pair of
!* double quotes.
!* 
!* a back-arrow means generate a (cr) without (lf) 
!* 
!* a (crlf) is generated after the entire list has been
!* printed or iff the list is a null list.  however iff the list 
!* ended with a comma, no (crl) is generated. 
!* 
list:  call tstnum    !test iff there is a #
       call endchk    !iff no # we get a 0
       call fndln     !find this or next line
ls1:   jc   rstart    !c:passed txtunf 
       call prtln     !print the line
       call chkio     !stop iff hit control-c 
       call fndlnp    !find next line
       jmp  ls1       !and loop back 
!* 
print: mvi  c,6       !c = # of spaces 
       rst  1         !iff null list & "!"
       defb 73q 
       defb 6q 
       call crlf      !give cr-lf and
       jmp  runsml    !continue same line
pr2:   rst  1         !iff null list (cr) 
       defb 0dh
       defb 6q
       call crlf      !also give cr-lf and 
       jmp  runnxl    !go to next line 
pr0:   rst  1         !else is it format?
       defb '#' 
       defb 5q
       rst  3         !yes, evaluate expr. 
       mov  c,l       !and save it in c
       jmp  pr3       !look for more to print
pr1:   call qtstg     !or is it a string?
       jmp  pr8       !iff not, must be expr. 
pr3:   rst  1         !iff ",", go find next
       defb ',' 
       defb 6q
       call fin       !in the list.
       jmp  pr0       !list continues
pr6:  call crlf      !list ends 
       rst  6 
pr8:   rst  3         !evaluate the expr 
       push b 
       call prtnum    !print the value 
       pop  b 
       jmp  pr3       !more to print?
!* 
!**************************************************************
!* 
!* *** gosub *** & return ***
!* 
!* 'gosub expr!' or 'gosub expr (cr)' is like the 'goto' 
!* command, except that the current text pointer, stack pointer
!* etc. are save so that execution can be continued after the
!* subroutine 'return'.  in order that 'gosub' can be nested 
!* (and even recursive), the save area must be stacked.
!* the stack pointer is saved in 'stkgos'. the old 'stkgos' is 
!* saved in the stack.  iff we are in the main routine, 'stkgos'
!* is zero (this was done by the "main" section of the code),
!* but we still save it as a flag forr no further 'return's.
!* 
!* 'return(cr)' undos everyhing that 'gosub' did, and thus
!* return the excution to the command after the most recent
!* 'gosub'.  iff 'stkgos' is zero, it indicates that we 
!* never had a 'gosub' and is thus an error. 
!* 
gosub: call pusha     !save the current "for"
       rst  3         !parameters
       push d         !and text pointer
       call fndln     !find the target line
       jnz  ahow      !not there. say "how?" 
       lhld currnt    !found it, save old
       push h         !'currnt' old 'stkgos' 
       lhld stkgos
       push h 
       lxi  h,0       !and load new ones 
       shld lopvar
       dad  sp
       shld stkgos
       jmp  runtsl    !then run that line
return:call endchk    !there must be a 0dh
       lhld stkgos    !old stack pointer 
       mov  a,h       !0 means not exist 
       ora  l 
       jz   qwhat     !so, we say: "what?" 
       sphl           !else, restore it
       pop  h 
       shld stkgos    !and the old 'stkgos'
       pop  h 
       shld currnt    !and the old 'currnt'
       pop  d         !old text pointer
       call popa      !old "for" parameters
       rst  6         !and we are back home
!* 
!**************************************************************
!* 
!* *** for *** & next ***
!* 
!* 'for' has two forms:
!* 'for var=exp1 to exp2 step exp1' and 'for var=exp1 to exp2' 
!* the second form means the same thing as the first form with 
!* exp1=1.  (i.e., with a step of +1.) 
!* tbi will find the variable var. and set its value to the
!* current value of exp1.  it also evaluates expr2 and exp1
!* and save all these together with the text pointerr etc. in 
!* the 'for' save area, which consists of 'lopvar', 'lopinc',
!* 'loplmt', 'lopln', and 'loppt'.  iff there is already some-
!* thing in the save area (this is indicated by a non-zero 
!* 'lopvar'), then the old save area is saved in the stack 
!* before the new one overwrites it. 
!* tbi will then dig in the stack and find out iff this same
!* variable was used in another currently active 'for' loop. 
!* iff that is the case then the old 'for' loop is deactivated.
!* (purged from the stack..) 
!* 
!* 'next var' serves as the logical (not necessarilly physical)
!* end of the 'for' loop.  the control variable var. is checked
!* with the 'lopvar'.  iff they are not the same, tbi digs in 
!* the stack to find the rightt one and purges all those that 
!* did not match.  either way, tbi then adds the 'step' to 
!* that variable and check the result with the limit.  iff it 
!* is within the limit, control loops back to the command
!* following the 'for'.  iff outside the limit, the save arer 
!* is purged and execution continues.
!* 
for:   call pusha     !save the old save area
       call setval    !set the control var.
       dcx  h         !hl is its address 
       shld lopvar    !save that 
       lxi  h,tab5-1  !use 'exec' to look
       jmp  exec      !for the word 'to' 
fr1:   rst  3         !evaluate the limit
       shld loplmt    !save that 
       lxi  h,tab6-1  !use 'exec' to look
       jmp  exec      !for the word 'step'
fr2:   rst  3         !found it, get step
       jmp  fr4 
fr3:   lxi  h,1q      !not found, set to 1 
fr4:   shld lopinc    !save that too 
fr5:   lhld currnt    !save current line # 
       shld lopln 
       xchg           !and text pointer
       shld loppt 
       lxi  b,12q     !dig into stack to 
       lhld lopvar    !find 'lopvar' 
       xchg 
       mov  h,b 
       mov  l,b       !hl=0 now
       dad  sp        !here is the stack 
       defb 76q 
fr7:   dad  b         !each level is 10 deep 
       mov  a,m       !get that old 'lopvar' 
       inx  h 
       ora  m 
       jz   fr8       !0 says no more in it
       mov  a,m 
       dcx  h 
       cmp  d         !same as this one? 
       jnz  fr7 
       mov  a,m       !the other half? 
       cmp  e 
       jnz  fr7 
       xchg           !yes, found one
       lxi  h,0q
       dad  sp        !try to move sp
       mov  b,h 
       mov  c,l 
       lxi  h,12q 
       dad  d 
       call mvdown    !and purge 10 words
       sphl           !in the stack
fr8:   lhld loppt     !job done, restore de
       xchg 
       rst  6         !and continue
!* 
next:  rst  7         !get address of var. 
       jc   qwhat     !no variable, "what?"
       shld varnxt    !yes, save it
nx0:   push d         !save text pointer 
       xchg 
       lhld lopvar    !get var. in 'for' 
       mov  a,h 
       ora  l         !0 says never had one
       jz   awhat     !so we ask: "what?"
       rst  4         !else we check them
       jz   nx3       !ok, they agree
       pop  d         !no, let's see 
       call popa      !purge current loop
       lhld varnxt    !and pop one level 
       jmp  nx0       !go check again
nx3:   mov  e,m       !come here when agreed 
       inx  h 
       mov  d,m       !de=value of var.
       lhld lopinc
       push h 
       dad  d         !add one step
       xchg 
       lhld lopvar    !put it back 
       mov  m,e 
       inx  h 
       mov  m,d 
       lhld loplmt    !hl->limit 
       pop  psw       !old hl
       ora  a 
       jp   nx1       !step > 0
       xchg 
nx1:   call ckhlde    !compare with limit
       pop  d         !restore text pointer
       jc   nx2       !outside limit 
       lhld lopln     !within limit, go
       shld currnt    !back to the saved 
       lhld loppt     !'currnt' and text 
       xchg           !pointer 
       rst  6 
nx2:   call popa      !purge this loop 
       rst  6 
!* 
!**************************************************************
!* 
!* *** rem *** iff *** input *** & let (& deflt) ***
!* 
!* 'rem' can be followed by anything and is ignored by tbi.
!* tbi treats it like an 'if' with a false condition.
!* 
!* 'if' is followed by an expr. as a condition and one or more 
!* commands (including outher 'if's) seperated by semi-colons. 
!* note that the word 'then' is not used.  tbi evaluates the 
!* expr. iff it is non-zero, execution continues.  iff the 
!* expr. is zero, the commands that follows are ignored and
!* execution continues at the next line. 
!* 
!* 'iput' command is like the 'print' command, and is followed
!* by a list of items.  iff the item is a string in single or 
!* double quotes, or is a back-arrow, it has the same effect as
!* in 'print'.  iff an item is a variable, this variable name is
!* printed out followed by a colon.  then tbi waits for an 
!* expr. to be typed in.  the variable iss then set to the
!* value of this expr.  iff the variable is proceded by a string
!* (again in single or double quotes), the string will be
!* printed followed by a colon.  tbi then waits for input expr.
!* and set the variable to the value of the expr.
!* 
!* iff the input expr. is invalid, tbi will print "what?",
!* "how?" or "sorry" and reprint the prompt and redo the input.
!* the execution will not terminate unless you type control-c. 
!* this is handled in 'inperr'.
!* 
!* 'let' is followed by a list of items seperated by commas. 
!* each item consists of a variable, an equal sign, and an expr. 
!* tbi evaluates the expr. and set the varible to that value.
!* tb will also handle 'let' command without the word 'let'.
!* this is done by 'deflt'.
!* 
rem:   lxi  h,0q      !*** rem *** 
       defb 76q 
!* 
iff:    rst  3         !*** iff ***
       mov  a,h       !is the expr.=0? 
       ora  l 
       jnz  runsml    !no, continue
       call fndskp    !yes, skip rest of line
       jnc  runtsl
       jmp  rstart
!* 
inperr:lhld stkinp    !*** inperr ***
       sphl           !restore old sp
       pop  h         !and old 'currnt'
       shld currnt
       pop  d         !and old text pointer
       pop  d         !redo input
!* 
input: equ  $         !*** input *** 
ip1:   push d         !save in case of error 
       call qtstg     !is next item a string?
       jmp  ip2       !no
       rst  7         !yes. but followed by a
       jc   ip4       !variable?   no. 
       jmp  ip3       !yes.  input variable
ip2:   push d         !save for 'prtstg' 
       rst  7         !must be variable now
       jc   qwhat     !"what?" it is not?
       ldax d         !get ready for 'rtstg'
       mov  c,a 
       sub  a 
       stax d 
       pop  d 
       call prtstg    !print string as prompt
       mov  a,c       !restore text
       dcx  d 
       stax d 
ip3:   push d         !save in case of error 
       xchg 
       lhld currnt    !also save 'currnt'
       push h 
       lxi  h,ip1     !a negative number 
       shld currnt    !as a flag 
       lxi  h,0q      !save sp too 
       dad  sp
       shld stkinp
       push d         !old hl
       mvi  a,72q     !print this too
       call getln     !and get a line
ip3a:  lxi  d,buffer  !points to buffer
       rst  3         !evaluate input
       nop            !can be 'call endchk'
       nop
       nop
       pop  d         !ok, get old hl
       xchg 
       mov  m,e       !save value in var.
       inx  h 
       mov  m,d 
       pop  h         !get old 'currnt'
       shld currnt
       pop  d         !and old text pointer
ip4:   pop  psw       !purge junk in stack 
       rst  1         !is next ch. ','?
       defb ',' 
       defb 3q
       jmp  ip1       !yes, more items.
ip5:   rst  6 
!* 
deflt: ldax d         !*** deflt *** 
       cpi  0dh       !empty line is ok
       jz   lt1       !else it is 'let'
!* 
let:   call setval    !*** let *** 
       rst  1         !set value to var. 
       defb ',' 
       defb 3q
       jmp  let       !item by item
lt1:   rst  6         !until finish
!* 
!**************************************************************
!* 
!* *** expr ***
!* 
!* 'expr' evaluates arithmetical or logical expressions. 
!* <expr>::=<expr2>
!*          <expr2><rel.op.><expr2>
!* where <rel.op.> is one of the operatorss in tab8 and the 
!* result of these operations is 1 iff true and 0 iff false. 
!* <expr2>::=(+ or -)<expr3>(+ or -<expr3>)(....)
!* where () are optional and (....) are optional repeats.
!* <expr3>::=<expr4>(<* or /><expr4>)(....)
!* <expr4>::=<variable>
!*           <function>
!*           (<expr>)
!* <expr> is recursive so that variable '@' can have an <expr> 
!* as index, fnctions can have an <expr> as arguments, and
!* <expr4> can be an <expr> in paranthese. 
!* 
!*                 expr   call expr2     this is at loc. 18
!*                        push hl        save <expr2> value
expr1: lxi  h,tab8-1  !lookup rel.op.
       jmp  exec      !go do it
xp11:  call xp18      !rel.op.">=" 
       rc             !no, return hl=0 
       mov  l,a       !yes, return hl=1
       ret
xp12:  call xp18      !rel.op."#"
       rz             !false, return hl=0
       mov  l,a       !true, return hl=1 
       ret
xp13:  call xp18      !rel.op.">"
       rz             !false 
       rc             !also false, hl=0
       mov  l,a       !true, hl=1
       ret
xp14:  call xp18      !rel.op."<=" 
       mov  l,a       !set hl=1
       rz             !rel. true, return 
       rc 
       mov  l,h       !else set hl=0 
       ret
xp15:  call xp18      !rel.op."="
       rnz            !false, retrun hl=0
       mov  l,a       !else set hl=1 
       ret
xp16:  call xp18      !rel.op."<"
       rnc            !false, return hl=0
       mov  l,a       !else set hl=1 
       ret
xp17:  pop  h         !not rel.op. 
       ret            !return hl=<expr2> 
xp18:  mov  a,c       !subroutine for all
       pop  h         !rel.op.'s 
       pop  b 
       push h         !reverse top of stack
       push b 
       mov  c,a 
       call expr2     !get 2nd <expr2> 
       xchg           !value in de now 
       xthl           !1st <expr2> in hl 
       call ckhlde    !compare 1st with 2nd
       pop  d         !restore text pointer
       lxi  h,0q      !set hl=0, a=1 
       mvi  a,1 
       ret
!* 
expr2: rst  1         !negative sign?
       defb '-' 
       defb 6q
       lxi  h,0q      !yes, fake '0-'
       jmp  xp26      !treat like subtract 
xp21:  rst  1         !positive sign?  ignore
       defb '+' 
       defb 0q
xp22:  call expr3     !1st <expr3> 
xp23:  rst  1         !add?
       defb '+' 
       defb 25q 
       push h         !yes, save value 
       call expr3     !get 2nd<expr3> 
xp24:  xchg           !2nd in de 
       xthl           !1st in hl 
       mov  a,h       !compare sign
       xra  d 
       mov  a,d 
       dad  d 
       pop  d         !restore text pointer
       jm   xp23      !1st 2nd sign differ 
       xra  h         !1st 2nd sign equal
       jp   xp23      !so isp result
       jmp  qhow      !else we have overflow 
xp25:  rst  1         !subtract? 
       defb '-' 
       defb 203q
xp26:  push h         !yes, save 1st <expr3> 
       call expr3     !get 2nd <expr3> 
       call chgsgn    !negate
       jmp  xp24      !and add them
!* 
expr3: call expr4     !get 1st <expr4> 
xp31:  rst  1         !multiply? 
       defb '*' 
       defb 54q 
       push h         !yes, save 1st 
       call expr4     !and get 2nd <expr4> 
       mvi  b,0q      !clear b for sign
       call chksgn    !check sign
       xchg           !2nd in de now 
       xthl           !1st in hl 
       call chksgn    !check sign of 1st 
       mov  a,h       !is hl > 255 ? 
       ora  a 
       jz   xp32      !no
       mov  a,d       !yes, how about de 
       ora  d 
       xchg           !put smaller in hl 
       jnz  ahow      !also >, will overflow 
xp32:  mov  a,l       !this is dumb
       lxi  h,0q      !clear result
       ora  a         !add and count 
       jz   xp35
xp33:  dad  d 
       jc   ahow      !overflow
       dcr  a 
       jnz  xp33
       jmp  xp35      !finished
xp34:  rst  1         !divide? 
       defb '/' 
       defb 104q
       push h         !yes, save 1st <expr4> 
       call expr4     !and get 2nd one 
       mvi  b,0q      !clear b for sign
       call chksgn    !check sign of 2nd 
       xchg           !put 2nd in de 
       xthl           !get 1st in hl 
       call chksgn    !check sign of 1st 
       mov  a,d       !divide by 0?
       ora  e 
       jz   ahow      !say "how?"
       push b         !else save sign
       call divide    !use subroutine
       mov  h,b       !result in hl now
       mov  l,c 
       pop  b         !get sign back 
xp35:  pop  d         !and text pointer
       mov  a,h       !hl must be +
       ora  a 
       jm   qhow      !else it is overflow 
       mov  a,b 
       ora  a 
       cm   chgsgn    !change sign iff needed 
       jmp  xp31      !look or more terms 
!* 
expr4: lxi  h,tab4-1  !find function in tab4 
       jmp  exec      !and go do it
xp40:  rst  7         !no, not a function
       jc   xp41      !nor a variable
       mov  a,m       !variable
       inx  h 
       mov  h,m       !value in hl 
       mov  l,a 
       ret
xp41:  call tstnum    !or is it a number 
       mov  a,b       !# of digit
       ora  a 
       rnz            !ok
parn:  rst  1         !no digit, must be 
       defb '(' 
       defb 5q
       rst  3         !"(expr)"
       rst  1 
       defb ')' 
       defb 1q
xp42:  ret
xp43:  jmp  qwhat     !else say: "what?" 
!* 
rnd:   call parn      !*** rnd(expr) *** 
       mov  a,h       !expr must be +
       ora  a 
       jm   qhow
       ora  l         !and non-zero
       jz   qhow
       push d         !save both 
       push h 
       lhld ranpnt    !get memory as random
       lxi  d,lstrom  !number
       rst  4 
       jc   ra1       !wrap around iff last 
       lxi  h,start 
ra1:   mov  e,m 
       inx  h 
       mov  d,m 
       shld ranpnt
       pop  h 
       xchg 
       push b 
       call divide    !rnd(n)=mod(m,n)+1 
       pop  b 
       pop  d 
       inx  h 
       ret
!* 
abs:   call parn      !*** abs(expr) *** 
       call chksgn    !check sign
       mov  a,h       !note that -32768
       ora  h         !cannot change sign
       jm   qhow      !so say: "how?"
       ret
size:  lhld txtunf    !*** size ***
       push d         !get the number of free
       xchg           !bytes between 'txtunf'
sizea: lxi  h,varbgn  !and 'varbgn'
       call subde 
       pop  d 
       ret
!*
!*********************************************************
!*
!*   *** out *** inp *** wait *** poke *** peek *** & usr
!*
!*  out i,j(,k,l)
!*
!*  outputs expression 'j' to port 'i', and may be repeated
!*  as in data 'l' to port 'k' as many times as needed
!*  this command modifies !*  this command modifies 
!*  this command modify's a small section of code located 
!*  just above address 2k
!*
!*  inp (i)
!*
!*  this function returns data read from input port 'i' as
!*  it's value.
!*  it also modifies code just above 2k.
!*
!*  wait i,j,k
!*
!*  this command reads the status of port 'i', exclusive or's
!*  the result with 'k' if there is one, or if not with 0, 
!*  and's with 'j' and returns when the result is nonzero.
!*  its modified code is also above 2k.
!*
!*  poke i,j(,k,l)
!*
!*  this command works like out except that it puts data 'j'
!*  into memory location 'i'.
!*
!*  peek (i)
!*
!*  this function works like inp except it gets it's value
!*  from memory location 'i'.
!*
!*  usr (i(,j))
!*
!*  usr calls a machine language subroutine at location 'i'
!*  if the optional parameter 'j' is used its value is passed
!*  in h&l.  the value of the function should be returned in h&l.
!*
!************************************************************
!*
outcmd:rst  3 
       mov  a,l
       sta  outio + 1
       rst  1
       defb ','
       defb 2fh
       rst  3
       mov  a,l
       call outio
       rst  1
       defb ','
       defb 03h
       jmp  outcmd 
       rst  6
waitcm:rst  3
       mov  a,l
       sta  waitio + 1
       rst  1
       defb ','
       defb 1bh
       rst  3
       push h
       rst  1
       defb ','
       defb 7h
       rst  3
       mov  a,l
       pop  h
       mov  h,a
       jmp  $ + 2
       mvi  h,0
       jmp  waitio
inp:   call parn
       mov  a,l
       sta  inpio + 1
       mvi  h,0
       jmp  inpio
       jmp  qwhat
poke:  rst  3
       push h
       rst  1
       defb ','
       defb 12h
       rst  3
       mov  a,l
       pop  h
       mov  m,a
       rst  1
       defb ',',03h
       jmp  poke
       rst 6
peek:  call parn
       mov  l,m
       mvi  h,0
       ret
       jmp  qwhat
usr:   push b
       rst  1
       defb '(',28d    !qwhat
       rst  3          !expr
       rst  1
       defb ')',7      !pasparm
       push d
       lxi  d,usret
       push d
       push h
       ret             !call usr routine
pasprm:rst  1
       defb ',',14d
       push h
       rst  3
       rst  1
       defb ')',9
       pop  b
       push d
       lxi  d,usret
       push d
       push b
       ret             !call usr routine
usret: pop  d
       pop  b
       ret
       jmp  qwhat
!*
!**************************************************************
!* 
!* *** divide *** subde *** chksgn *** chgsgn *** & ckhlde *** 
!* 
!* 'divide' divides hl by de, result in bc, remainder in hl
!* 
!* 'subde' subtracts de from hl
!* 
!* 'chksgn' checks sign of hl.  iff +, no change.  iff -, change 
!* sign and flip sign of b.
!* 
!* 'chgsgn' chnges sign of hl and b unconditionally. 
!* 
!* 'ckhle' checks sign of hl and de.  iff different, hl and de 
!* are interchanged.  iff same sign, not interchanged.  either
!* case, hl de are then compared to set the flags. 
!* 
divide:push h         !*** divide ***
       mov  l,h       !divide h by de
       mvi  h,0 
       call dv1 
       mov  b,c       !save result in b
       mov  a,l       !(remainder+l)/de
       pop  h 
       mov  h,a 
dv1:   mvi  c,377q    !result in c 
dv2:   inr  c         !dumb routine
       call subde     !divide by subtract
       jnc  dv2       !and count 
       dad  d 
       ret
!* 
subde: mov  a,l       !*** subde *** 
       sub  e         !subtract de from
       mov  l,a       !hl
       mov  a,h 
       sbb  d 
       mov  h,a 
       ret
!* 
chksgn:mov  a,h       !*** chksgn ***
       ora  a         !check sign of hl
       rp             !iff -, change sign 
!* 
chgsgn:mov  a,h       !*** chgsgn ***
       cma            !change sign of hl 
       mov  h,a 
       mov  a,l 
       cma
       mov  l,a 
       inx  h 
       mov  a,b       !and also flip b 
       xri  200q
       mov  b,a 
       ret
!* 
ckhlde:mov  a,h 
       xra  d         !same sign?
       jp   ck1       !yes, compare
       xchg           !no, xch and comp
ck1:   rst  4 
       ret
!* 
!**************************************************************
!* 
!* *** setval *** fin *** endchk *** & error (& friends) *** 
!* 
!* "setval" expects a variable, followed by an equal sign and
!* then an expr.  it evaluates the expr. and set the variable
!* to that value.
!* 
!* "fin" checks the end of a command.  iff it ended with "!", 
!* execution continues.  iff it ended with a cr, it finds the 
!* next line and continue from there.
!* 
!* "endchk" checks iff a command is ended with cr.  this is 
!* required in certain commands. (goto, return, and stop etc.) 
!* 
!* "error" prints the string pointed by de (and ends with cr). 
!* it then prints the line pointed by 'currnt' with a "?"
!* inserted at where the old text pointer (should be on top
!* o the stack) points to.  execution of tb is stopped
!* and tbi is restarted.  however, iff 'currnt' -> zero 
!* (indicating a direct command), the direct command is not
!*  printed.  and iff 'currnt' -> negative # (indicating 'input'
!* command, the input line is not printed and execution is 
!* not terminated but continued at 'inperr'. 
!* 
!* related to 'error' are the following: 
!* 'qwhat' saves text pointer in stack and get message "what?" 
!* 'awhat' just get message "what?" and jump to 'error'. 
!* 'qsorry' and 'asorry' do same kind of thing.
!* 'qhow' and 'ahow' in the zero page section also do this 
!* 
setval:rst  7         !*** setval ***
       jc   qwhat     !"what?" no variable 
       push h         !save address of var.
       rst  1         !pass "=" sign 
       defb '=' 
       defb 10q 
       rst  3         !evaluate expr.
       mov  b,h       !value in bc now 
       mov  c,l 
       pop  h         !get address 
       mov  m,c       !save value
       inx  h 
       mov  m,b 
       ret
sv1:   jmp  qwhat     !no "=" sign 
!* 
fin:   rst  1         !*** fin *** 
       defb 73q 
       defb 4q 
       pop  psw       !"!", purge ret addr.
       jmp  runsml    !continue same line
fi1:   rst  1         !not "!", is it cr?
       defb 0dh
       defb 4q 
       pop  psw       !yes, purge ret addr.
       jmp  runnxl    !run next line 
fi2:   ret            !else return to caller 
!* 
endchk:rst  5         !*** endchk ***
       cpi  0dh       !end with cr?
       rz             !ok, else say: "what?" 
!* 
qwhat: push d         !*** qwhat *** 
awhat: lxi  d,what    !*** awhat *** 
error: sub  a         !*** error *** 
       call prtstg    !print 'what?', 'how?' 
       pop  d         !or 'sorry'
       ldax d         !save the character
       push psw       !at where old de ->
       sub  a         !and put a 0 there 
       stax d 
       lhld currnt    !get current line #
       push h 
       mov  a,m       !check the value 
       inx  h 
       ora  m 
       pop  d 
       jz   rstart    !iff zero, just rerstart
       mov  a,m       !iff negative,
       ora  a 
       jm   inperr    !redo input
       call prtln     !else print the line 
       dcx  d         !upto where the 0 is 
       pop  psw       !restore the character 
       stax d 
       mvi  a,77q     !printt a "?" 
       rst  2 
       sub  a         !and the rest of the 
       call prtstg    !line
       jmp  rstart
qsorry:push d         !*** qsorry ***
asorry:lxi  d,sorry   !*** asorry ***
       jmp  error 
!* 
!**************************************************************
!* 
!* *** getln *** fndln (& friends) *** 
!* 
!* 'getln' reads a input line into 'buffer'.  it first prompt
!* the character in a (given by the caller), then it fills the 
!* the buffer and echos.  it ignores lf's and nulls, but still 
!* echos them back.  rub-out is used to cause it to delete 
!* the last charater (iff there is one), and alt-mod is used to 
!* cause it to delete the whole line and start it all over.
!* 0dhsignals the end of a line, and caue 'getln' to return.
!* 
!* 'fndln' finds a line with a given line # (in hl) in the 
!* text save area.  de is used as the text pointer.  iff the
!* line is found, de will point to the beginning of that line
!* (i.e., the low byte of the line #), and flags are nc & z. 
!* iff that line is not there and a line with a higher line # 
!* is found, de points to there and flags are nc & nz.  iff 
!* we reached the end of text save are and cannot find the 
!* line, flags are c & nz. 
!* 'fndln' will initialize de to the beginning of the text save
!* area to start the search.  some other entries of this 
!* routine will not initialize de and do the search. 
!* 'fndlnp' will start with de and search for the line #.
!* 'fndnxt' will bump de by 2, find a 0dhand then start search.
!* 'fndskp' use de to find a cr, and then strart search. 
!* 
getln: rst  2         !*** getln *** 
       lxi  d,buffer  !prompt and init
gl1:   call chkio     !check keyboard
       jz   gl1       !no input, wait
       cpi  177q      !delete lst character?
       jz   gl3       !yes 
       cpi  12q       !ignore lf 
       jz   gl1 
       ora  a         !ignore null 
       jz   gl1 
       cpi  134q      !delete the whole line?
       jz   gl4       !yes 
       stax d         !else, save input
       inx  d         !and bump pointer
       cpi  15q       !was it cr?
       jnz  gl2       !no
       mvi  a,12q     !yes, get line feed
       rst  2         !call outc and line feed
       ret            !we've got a line
gl2:   mov  a,e       !more free room?
       cpi  bufend and 0ffh
       jnz  gl1       !yes, get next input 
gl3:   mov  a,e       !delete last character 
       cpi  buffer and 0ffh    !but do we have any? 
       jz   gl4       !no, redo whole line 
       dcx  d         !yes, backup pointer 
       mvi  a,'_'     !and echo a back-space 
       rst  2 
       jmp  gl1       !go get next input 
gl4:   call crlf      !redo entire line
       mvi  a,136q    !cr, lf and up-arrow 
       jmp  getln 
!* 
fndln: mov  a,h       !*** fndln *** 
       ora  a         !check sign of hl
       jm   qhow      !it cannt be -
       lxi  d,txtbgn  !init. text pointer
!* 
fndlnp:equ  $         !*** fndlnp ***
fl1:   push h         !save line # 
       lhld txtunf    !check iff we passed end
       dcx  h 
       rst  4 
       pop  h         !get line # back 
       rc             !c,nz passed end 
       ldax d         !we did not, get byte 1
       sub  l         !is this the line? 
       mov  b,a       !compare low order 
       inx  d 
       ldax d         !get byte 2
       sbb  h         !compare high order
       jc   fl2       !no, not there yet 
       dcx  d         !else we either found
       ora  b         !it, or it is not there
       ret            !nc,z:found! nc,nz:no
!* 
fndnxt:equ  $         !*** fndnxt ***
       inx  d         !find next line
fl2:   inx  d         !just passed byte 1 & 2
!* 
fndskp:ldax d         !*** fndskp ***
       cpi  0dh       !try to find 0dh
       jnz  fl2       !keep looking
       inx  d         !found cr, skip over 
       jmp  fl1       !check iff end of text
!* 
!*************************************************************
!* 
!* *** prtstg *** qtstg *** prtnum *** & prtln *** 
!* 
!* 'prtstg' prints a string pointed by de.  it stops printing
!* and returns to calìer when either a 0dhis printed or when 
!* the next byte is the same as what was in a (given by the
!* caller).  old a is stored in b, old b is lost.
!* 
!* 'qtstg' looks for a back-arrow, single quote, or double 
!* quote.  iff none of these, return to caller.  iff back-arrow, 
!* output a 0dhwithout a lf.  iff single or double quote, print 
!* the string in the quote and demands a matching unquote. 
!* after the printing the next 3 bytes of the caller is skipped
!* over (usually a jump instruction).
!* 
!* 'prtnum' prints the number in hl.  leading blanks are added 
!* iff needed to pad the number of spaces to the number in c. 
!* however, iff the number of digits is larger than the # in
!* c, all digits are printed anyway.  negative sign is also
!* printed and counted in, positive sign is not. 
!* 
!* 'prtln' prinsra saved text line with line # and all. 
!* 
prtstg:mov  b,a       !*** prtstg ***
ps1:   ldax d         !get a characterr 
       inx  d         !bump pointer
       cmp  b         !same as old a?
       rz             !yes, return 
       rst  2         !else print it 
       cpi  0dh       !was it a cr?
       jnz  ps1       !no, next
       ret            !yes, return 
!* 
qtstg: rst  1         !*** qtstg *** 
       defb '"' 
       defb 17q 
       mvi  a,42q     !it is a " 
qt1:   call prtstg    !print until another 
       cpi  0dh       !was last one a cr?
       pop  h         !return address
       jz   runnxl    !was cr, run next line 
qt2:   inx  h         !skip 3 bytes on return
       inx  h 
       inx  h 
       pchl           !return
qt3:   rst  1         !is it a ' ? 
       defb 47q 
       defb 5q
       mvi  a,47q     !yes, do same
       jmp  qt1       !as in " 
qt4:   rst  1         !is it back-arrow? 
       defb 137q
       defb 10q 
       mvi  a,215q    !yes, 0dhwithout lf!!
       rst  2         !do it twice to give 
       rst  2         !tty enough time 
       pop  h         !return address
       jmp  qt2 
qt5:   ret            !none of above 
!* 
prtnum push d         !*** prtnum ***
       lxi  d,12q     !decimal 
       push d         !save as a flag
       mov  b,d       !b=sign
       dcr  c         !c=spaces
       call chksgn    !check sign
       jp   pn1       !no sign 
       mvi  b,55q     !b=sign
       dcr  c         !'-' takes space 
pn1:   push b         !save sign & space 
pn2:   call divide    !devide hl by 10 
       mov  a,b       !result 0? 
       ora  c 
       jz   pn3       !yes, we got all 
       xthl           !no, save remainder
       dcr  l         !and count space 
       push h         !hl is old bc
       mov  h,b       !move result to bc 
       mov  l,c 
       jmp  pn2       !and divide by 10
pn3:   pop  b         !we got all digits in
pn4:   dcr  c         !the stack 
       mov  a,c       !look at space count 
       ora  a 
       jm   pn5       !no leading blanks 
       mvi  a,40q     !leading blanks
       rst  2 
       jmp  pn4       !more? 
pn5:   mov  a,b       !print sign
       rst  2         !maybe - or null 
       mov  e,l       !last remainder in e 
pn6:   mov  a,e       !check digit in e
       cpi  12q       !10 is flag for no more
       pop  d 
       rz             !iff so, return 
       adi  60q		!else convert to ascii
       rst  2         !and print the digit 
       jmp  pn6       !go back for more
!* 
prtln: ldax d         !*** prtln *** 
       mov  l,a       !low order line #
       inx  d 
       ldax d         !high order
       mov  h,a 
       inx  d 
       mvi  c,4q      !print 4 digit line #
       call prtnum
       mvi  a,40q     !followed by a blank 
       rst  2 
       sub  a         !and then the text 
       call prtstg
       ret
!* 
!**************************************************************
!* 
!* *** mvup *** mvdown *** popa *** & pusha ***
!* 
!* 'mvup' moves a block up from here de-> to where bc-> until 
!* de = hl 
!* 
!* 'mvdown' moves a block down from where de-> to where hl-> 
!* until de = bc 
!* 
!* 'popa' restores the 'for' loop variable save area from the
!* stack 
!* 
!* 'pusha' stacks the 'for' loop variable save area into the 
!* stack 
!* 
mvup:  rst  4         !*** mvup ***
       rz             !de = hl, return 
       ldax d         !get one byte
       stax b         !move it 
       inx  d         !increase both pointers
       inx  b 
       jmp  mvup      !until done
!* 
mvdown:mov  a,b       !*** mvdown ***
       sub  d         !test iff de = bc 
       jnz  md1       !no, go move 
       mov  a,c       !maybe, other byte?
       sub  e 
       rz             !yes, return 
md1:   dcx  d         !else move a byte
       dcx  h         !but first decrease
       ldax d         !both pointers and 
       mov  m,a       !then do it
       jmp  mvdown    !loop back 
!* 
popa:  pop  b         !bc = return addr. 
       pop  h         !restore lopvar, but 
       shld lopvar    !=0 means no more
       mov  a,h 
       ora  l 
       jz   pp1       !yep, go return
       pop  h         !nop, restore others 
       shld lopinc
       pop  h 
       shld loplmt
       pop  h 
       shld lopln 
       pop  h 
       shld loppt 
pp1:   push b         !bc = return addr. 
       ret
!* 
pusha: lxi  h,stklmt  !*** pusha *** 
       call chgsgn
       pop  b         !bc=return address 
       dad  sp        !is stack near the top?
       jnc  qsorry    !yes, sorry for that.
       lhld lopvar    !else save loop var.s
       mov  a,h       !but iff lopvar is 0
       ora  l         !that will be all
       jz   pu1 
       lhld loppt     !else, more to save
       push h 
       lhld lopln 
       push h 
       lhld loplmt
       push h 
       lhld lopinc
       push h 
       lhld lopvar
pu1:   push h 
       push b         !bc = return addr. 
       ret
!* 
!**************************************************************
!* 
!* *** outc *** & chkio ****!
!* these are the only i/o routines in tbi. 
!* 'outc' is controlled by a software switch 'ocsw'.  iff ocsw=0
!* 'outc' will just return to the caller.  iff ocsw is not 0, 
!* it will output the byte in a.  iff that is a cr, a lf is also
!* send out.  only the flags may be changed at return, all reg.
!* are restored. 
!* 
!* 'chkio' checks the input.  iff no input, it will return to 
!* the caller with the z flag set.  iff there is input, z flag
!* is cleared and the input byte is in a.  howerer, iff the 
!* input is a control-o, the 'ocsw' switch is complimented, and
!* z flag is returned.  iff a control-c is read, 'chkio' will 
!* restart tbi and do not return to the caller.
!* 
!*                 outc   push af        this is at loc. 10
!*                        ld   a,ocsw    check software switch 
!*                        ior  a 
oc2:   jnz  oc3       !it is on
       pop  psw       !it is off 
       ret            !restore af and return 
oc3:   pop  a         !get old a back
       push b         !save b on stack
       push d         !and d
       push h         !and h too
       sta  outcar    !save character
       mov  e,a       !put char. in e for cpm
       mvi  c,2       !get conout command
       call cpm       !call cpm and do it
       lda  outcar    !get char. back
       cpi  0dh       !was it a 'cr'?
       jnz  done      !no, done
       mvi  e,0ah     !get linefeed
       mvi  c,2       !and conout again
       call cpm       !call cpm
done:  lda  outcar    !get character back
idone: pop  h         !get h back
       pop  d         !and d
       pop  b         !and b too
       ret            !done at last
chkio: push b         !save b on stack
       push d         !and d
       push h         !then h
       mvi  c,11      !get constat word
       call cpm       !call the bdos
       ora  a         !set flags
       jnz  ci1       !if ready get character
       jmp  idone     !restore and return
ci1:   mvi  c,1       !get conin word
       call cpm       !call the bdos
       cpi  0fh       !is it control-o?
       jnz  ci2       !no, more checking
       lda  ocsw      !control-o  flip ocsw
       cma            !on to off, off to on
       sta  ocsw      !and put it back
       jmp  chkio     !and get another character
ci2:   cpi  3         !is it control-c?
       jnz  idone     !return and restore if not
       jmp  rstart    !yes, restart tbi
lstrom:equ  $         !all above can be rom
outio: out  0ffh
       ret
waitio:in   0ffh
       xra  h
       ana  l
       jz   waitio
       rst  6
inpio: in   0ffh
       mov  l,a
       ret
outcar:defb 0         !output char. storage
ocsw:  defb 0ffh      !switch for output
currnt:defw 0         !points to current line
stkgos:defw 0         !saves sp in 'gosub'
varnxt:defw 0         !temporary storage
stkinp:defw 0         !saves sp in 'input'
lopvar:defw 0         !'for' loop save area
lopinc:defw 0         !increment
loplmt:defw 0         !limit
lopln: defw 0         !line number
loppt: defw 0         !text pointer
ranpnt:defw start     !random number pointer
txtunf:defw txtbgn    !->unfilled text area
txtbgn:defvs 1         !text save area begins 
msg1:  defb 7fh,7fh,7fh,'Tiny basic ver. 3.1',0dh 
init:  mvi  a,0ffh
       sta  ocsw      !turn on output switch 
       mvi  a,0ch     !get form feed 
       rst  2         !send to crt 
patlop:sub  a         !clear accumulator
       lxi  d,msg1    !get init message
       call prtstg    !send it
lstram:lda  7         !get fbase for top
       sta  rstart+2
       dcr  a         !decrement for other pointers
       sta  ss1a+2    !and fix them too
       sta  tv1a+2
       sta  st3a+2
       sta  st4a+2
       sta  ip3a+2
       sta  sizea+2
       sta  getln+3
       sta  pusha+2
       lxi  h,st1     !get new start jump
       shld start+1   !and fix it
       jmp  st1
       jmp  qwhat     !print "what?" iff wrong
txtend:equ  $         !text save area ends 
varbgn:defvs   2*27      !variable @(0)
       defvs   1         !extra byte for buffer
buffer:defvs   80        !input buffer
bufend:equ  $         !buffer ends
       defvs   40        !extra bytes for stack
stklmt:equ  $         !top limit for stack
       org  2000h
stack: equ  $         !stack starts here
