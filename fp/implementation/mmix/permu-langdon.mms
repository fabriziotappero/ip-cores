* Permutation generator a la Langdon
N  IS   6               $n$ (2, 3, ..., 15)
t  IS   $255
k  IS   $0
kk IS   $1
c  IS   $2
d  IS   $3
a  GREG 0
ones GREG #1111111111111111&(1<<(4*N)-1)

     LOC  #100
     GREG @
ElGordo OCTA #fedcba9876543210&(1<<(4*N)-1)
Main LDOU a,ElGordo         $a\gets\.{\#...3210}$.
     JMP  2F
1H   SRU  a,a,4*(16-N)
     OR   a,a,t

2H   ADDU c,a,ones    Trace this location to see the perm!
     
     SRU  t,a,4*(N-1)
     SLU  a,a,4*(17-N)
     PBNZ t,1B
     SET  k,1
3H   SRU  d,a,60
     SLU  a,a,4
     CMP  c,d,k
     SLU  kk,k,2
     SLU  d,d,kk
     OR   t,t,d
     PBNZ c,1B
     INCL k,1
     PBNZ a,3B
     TRAP 0,Halt,0

