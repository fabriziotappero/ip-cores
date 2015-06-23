x0 GREG Data_Segment
t IS $255
 LOC Data_Segment+8
 OCTA 1,3,2,3
 LOC Data_Segment+8*100
 OCTA -1
 LOC #100
* Maximum of X[1..100]
j IS $0 ;m IS $1 ;kk IS $2 ;xk IS $3
Max100 SETL kk,100*8
       LDO  m,x0,kk
       JMP  2F
3H     LDO  xk,x0,kk
       CMP  t,xk,m
       PBNP t,5F
       SET  m,xk
2H     SR   j,kk,3
5H     SUB  kk,kk,8
       PBP  kk,3B
6H     POP  2,0

Main  PUSHJ 0,Max100
