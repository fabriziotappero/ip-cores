* Fibonacci subroutines (exercise 1.4.1--13)

    LOC #100
Fib CMP   $1,$0,2
    PBN   $1,1F
    GET   $1,rJ
    SUB   $3,$0,1
    PUSHJ $2,Fib   $2=F_{n-1}
    SUB   $4,$0,2
    PUSHJ $3,Fib   $3=F_{n-2}
    ADDU  $0,$2,$3
    PUT   rJ,$1
1H  POP   1,0   

Fib1 CMP  $1,$0,2
     BN   $1,1F
     SUB  $2,$0,1
     SET  $0,1
     SET  $1,0
2H   ADDU $0,$0,$1  repeated n-1 times
     SUBU $1,$0,$1
     SUB  $2,$2,1
     PBNZ $2,2B
1H   POP  1,0

Fib2 CMP  $1,$0,1
     BNP  $1,1F
     SUB  $2,$0,1
     SET  $0,0
2H   ADDU $0,$0,$1
     ADDU $1,$0,$1
     SUB  $2,$2,2
     PBP  $2,2B
     CSZ  $0,$2,$1
1H   POP  1,0

Main SET   $1,5
     PUSHJ $0,Fib
     SET   $1,5
     PUSHJ $0,Fib1
     SET   $1,5
     PUSHJ $0,Fib2
     SET   $1,6
     PUSHJ $0,Fib2
