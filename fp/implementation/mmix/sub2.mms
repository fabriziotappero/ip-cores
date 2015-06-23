x0 GREG Data_Segment
t IS $255
 LOC Data_Segment+8
 OCTA 1,3,2,3
 LOC Data_Segment+8*100
 OCTA -1
 LOC #100
* Maximum of X[1..100]
j GREG ;m GREG ;kk GREG ;xk GREG ; GREG @
GoMax100 SETL kk,100*8
       LDO  m,x0,kk
       JMP  1F
3H     LDO  xk,x0,kk
       CMP  t,xk,m
       PBNP t,5F
4H     SET  m,xk
1H     SR   j,kk,3
5H     SUB  kk,kk,8
       PBP  kk,3B
6H     GO   kk,$0,0

Main   GO   $0,GoMax100

