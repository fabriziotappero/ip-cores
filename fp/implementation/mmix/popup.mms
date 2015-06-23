* Testing the solution to exercise 1.4.1--16
 LOC #100
B GET $2,rJ
  PUSHJ $3,C
  PUT rJ,$2; POP 2,0
  SET $1,1
  SET $0,$3
  PUT rJ,$2; POP 2,0

C BZ  $0,1F
  CMP $2,$0,5
  PBNZ $2,2F
  POP 1,0
2H GET $1,rJ
  SUB $3,$0,1
  PUSHJ $2,C
  PUT rJ,$1; POP 1,0
  ADD $0,$2,2
  PUT rJ,$1
1H POP 1,2

Main SET $5,2   manually change this to 5 or 6 or ...
     PUSHJ $0,B
