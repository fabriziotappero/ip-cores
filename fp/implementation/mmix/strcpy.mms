in IS $2
out IS $3
r IS $4
l IS $5
m IS $6
t IS $7
mm IS $8
tt IS $9
flip GREG #0102040810204080
ones GREG #0101010101010101

       LOC #100
StrCpy AND in,$0,#7
       SLU in,in,3
       AND out,$1,#7
       SLU out,out,3
       SUB r,out,in
       LDOU out,$1,0
       SUB $1,$1,$0
       NEG m,0,1
       SRU m,m,in
       LDOU in,$0,0
       PUT rM,m
       NEG mm,0,1
       BN  r,1F
       NEG l,64,r
       SLU tt,out,r
       MUX in,in,tt
       BDIF t,ones,in
       AND t,t,m
       SRU mm,mm,r
       PUT rM,mm
       JMP 4F
1H     NEG l,0,r
       INCL r,64
       SUB $1,$1,8
       SRU out,out,l
       MUX in,in,out
       BDIF t,ones,in
       AND t,t,m
       SRU mm,mm,r
       PUT rM,mm
       PBZ t,2F
       JMP 5F
3H     MUX out,tt,out
       STOU out,$0,$1
2H     SLU out,in,l
       LDOU in,$0,8
       INCL $0,8
       BDIF t,ones,in
4H     SRU  tt,in,r
       PBZ  t,3B
       SRU  mm,t,r
       MUX  out,tt,out
       BNZ  mm,1F
       STOU out,$0,$1
5H     INCL $0,8
       SLU  out,in,l
       SLU  mm,t,l  
1H     LDOU in,$0,$1
       MOR  mm,mm,flip
       SUBU t,mm,1
       ANDN mm,mm,t
       MOR  mm,mm,flip
       SUBU mm,mm,1
       PUT  rM,mm
       MUX  in,in,out
       STOU in,$0,$1
       POP  0

Main   SET $3,#8001
0H     SET $0,0
       SET $1,#aa
1H     STB $1,$0,0
       INCL $1,#11
       CMP $2,$1,#dd
       CSZ $1,$2,#aa
       INCL $0,1
       CMP  $6,$0,32
       PBNZ  $6,1B
       SET $0,$3
       ADD $2,$3,$5
       SET $1,3
       JMP 2F
1H     STB $1,$0,0
       SUB $1,$1,1
       CSZ $1,$1,3
       INCL $0,1
2H     CMP $6,$0,$2
       PBNZ $6,1B
       SET $1,0
       STB $1,$0,0
       PUSHJ 2,StrCpy
       SET $6,0
       JMP  0B
% put src address in $3
% put dest addr in $4
% put string length in $5
