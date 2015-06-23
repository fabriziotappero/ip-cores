* Fibonacci with frame pointers (exercise 1.4.1--15)
sp GREG
fp GREG
n  GREG
fn IS n

    LOC #100
    GREG  @
Fib CMP   $1,n,2
    PBN   $1,1F
    STO   fp,sp,0
    SET   fp,sp
    INCL  sp,8*4
    STO   $0,fp,8
    STO   n,fp,16
    SUB   n,n,1
    GO    $0,Fib
    STO   fn,fp,24 $F_{n-1}$
    LDO   n,fp,16
    SUB   n,n,2
    GO    $0,Fib
    LDO   $0,fp,24
    ADDU  fn,fn,$0
    LDO   $0,fp,8
    SET   sp,fp
    LDO   fp,sp,0
1H  GO    $0,$0,0

Main SETH  sp,Data_Segment>>48
     SET   n,5
     GO    $0,Fib



