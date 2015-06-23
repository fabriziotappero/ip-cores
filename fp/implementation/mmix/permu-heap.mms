* Permutation generator a la Heap
N  IS   5               $n$ (3, 4, 5, or 6)
t  IS   $255
j  IS   $0              $8j$
k  IS   $1              $8k$
ak IS   $2
aj IS   $3

   LOC  Data_Segment
a  GREG @               Base address for $a_0\ldots a_{n-1}$
A0 IS   @
A1 IS   @+8
A2 IS   @+16
*  LOC  @+8*N           Space for $a_0\ldots a_{n-1}$
   BYTE "11111111","22222222","33333333"
   BYTE "44444444","55555555","66666666"
   BYTE #a,0
   LOC  (@+7)&-8        (align to octabyte)
c  GREG @-8*3           Location of $c_0$
   LOC  @-8*3+8*N       $8c_3\ldots 8c_{n-1}$, initially zero
   OCTA -1              $c_n=-1$, a convenient sentinel
u  GREG 0               Contents of $a_0$, except in inner loop
v  GREG 0               Contents of $a_1$, except in inner loop
w  GREG 0               Contents of $a_2$, except in inner loop

   LOC  #100
1H STCO 0,c,k           $c_k\gets 0$.
   INCL k,8             $k\gets k+1$.
0H LDO  j,c,k           $j\gets c_k$.
   CMP  t,j,k
   BZ   t,1B            Loop if $c_k=k$.
   BN   j,Done          Terminate if $c_k<0$ ($k=n$).
   LDO  ak,a,k          Fetch $a_k$.
   ADD  t,j,8
   STO  t,c,k           $c_k\gets j+1$.          
   AND  t,k,#8         
   CSZ  j,t,0           Set $j\gets 0$ if $k$ is even.
   LDO  aj,a,j          Fetch $a_j$.
   STO  ak,a,j          Replace it by $a_k$.
   CSZ  u,j,ak          Set $u\gets a_k$ if $j=0$.
   SUB  j,j,8           $j\gets j-1$.
   CSZ  v,j,ak          Set $v\gets a_k$ if $j=0$.
   SUB  j,j,8           $j\gets j-1$.
   CSZ  w,j,ak          Set $w\gets a_k$ if $j=0$.
   STO  aj,a,k          Replace $a_k$ by what was $a_j$.
In PUSHJ 0,Visit
   STO   v,A0           $a_0\gets v$.
   STO   u,A1           $a_1\gets u$.
   PUSHJ 0,Visit 
   STO   w,A0           $a_0\gets w$.
   STO   v,A2           $a_2\gets v$.
   PUSHJ 0,Visit 
   STO   u,A0           $a_0\gets u$.
   STO   w,A1           $a_1\gets w$.
   PUSHJ 0,Visit 
   STO   v,A0           $a_0\gets v$.
   STO   u,A2           $a_2\gets u$.
   PUSHJ 0,Visit 
   STO   w,A0           $a_0\gets w$.
   STO   v,A1           $a_1\gets v$.
   PUSHJ 0,Visit 
   SET   t,u            Swap $u\leftrightarrow w$.
   SET   u,w
   SET   w,t
   SET   k,8*3          $k\gets3$.
   JMP   0B

Visit LDA  t,A0
      TRAP 0,Fputs,StdOut
      POP
Main  LDO  u,A0
      LDO  v,A1
      LDO  w,A2
      JMP  In
Done  TRAP 0,Halt,0
