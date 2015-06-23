     LOC #100
a IS $0
n IS $1
z IS $2
t IS $255

1H   STB   z,a,0
     SUB   n,n,1
     ADD   a,a,1
Zero BZ    n,9F
     SET   z,0
     AND   t,a,7
     BNZ   t,1B
     CMP   t,n,64
     PBNN  t,3F
     JMP   5F
2H   STCO  0,a,0
     SUB   n,n,8
     ADD   a,a,8
3H   AND   t,a,63
     PBNZ  t,2B
     CMP   t,n,64
     BN    t,5F
4H   PREST 63,a,0
     SUB   n,n,64
     CMP   t,n,64
     STCO  0,a,0
     STCO  0,a,8
     STCO  0,a,16
     STCO  0,a,24
     STCO  0,a,32
     STCO  0,a,40
     STCO  0,a,48
     STCO  0,a,56
     ADD   a,a,64
     PBNN  t,4B
5H   CMP   t,n,8
     BN    t,7F
6H   STCO  0,a,0
     SUB   n,n,8
     ADD   a,a,8
     CMP   t,n,8
     PBNN  t,6B
7H   BZ    n,9F
8H   STB   z,a,0
     SUB   n,n,1
     ADD   a,a,1
     PBNZ  n,8B
9H   POP

Main SET   a+1,#fff7
     SET   n+1,146
     PUSHJ 0,Zero
