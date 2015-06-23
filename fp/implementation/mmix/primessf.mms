% Example program ... Table of primes (using short floats)
L      IS   500          The number of primes to find
t      IS   $255         Temporary storage
fn      GREG
q      GREG
r      GREG
jj     GREG
kk     GREG
pk     GREG
mm     IS   kk

       LOC  Data_Segment
PRIME1 TETRA #40000000
       LOC  PRIME1+4*L
ptop   GREG @
j0     GREG PRIME1+4-@
BUF    OCTA

       LOC  #100
Main   FLOT  fn,3
       SET  jj,j0
2H     STSF fn,ptop,jj
       INCL jj,4
3H     BZ   jj,2F
0H     GREG #4000000000000000
4H     FADD fn,fn,0B
5H     SET  kk,j0
sqrtn GREG 0
      FSQRT sqrtn,fn
6H     LDSF pk,ptop,kk
      FREM r,fn,pk
       BZ   r,4B
7H    FCMP t,pk,sqrtn
       BNN  t,2B
8H     INCL kk,4
       JMP  6B
       GREG @
Title  BYTE "First Five Hundred Primes"
NewLn  BYTE #a,0
Blanks BYTE "   ",0
2H     LDA  t,Title
       TRAP 0,Fputs,StdOut
       NEG  mm,4
3H     ADD  mm,mm,j0
       LDA  t,Blanks
       TRAP 0,Fputs,StdOut
2H     LDSF pk,ptop,mm
       FIX  pk,pk
0H     GREG #2030303030000000
       STOU 0B,BUF
       LDA  t,BUF+4
1H     DIV  pk,pk,10
       GET  r,rR
       INCL r,'0'
       STBU r,t,0
       SUB  t,t,1
       PBNZ pk,1B
       LDA  t,BUF
       TRAP 0,Fputs,StdOut
       INCL mm,4*L/10
       PBN  mm,2B
       LDA  t,NewLn
       TRAP 0,Fputs,StdOut
       CMP  t,mm,4*(L/10-1)
       PBNZ t,3B
       TRAP 0,Halt,0
