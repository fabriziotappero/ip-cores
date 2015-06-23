* Exercise 1.3.2'--18, Solution 2
      LOC #100
t IS $255
a00 GREG Data_Segment
a10 GREG Data_Segment+8
a20 GREG Data_Segment+8*2
ij  GREG  % element index
ii  GREG  % row index times 8
j   GREG  % column index
x   GREG  % current maximum
y   GREG  % current element
z   GREG  % current min max
ans IS $0 % return register
Phase1 SET j,8 Start at column 8.
       SET z,1000  $\.z\gets\infty$ (more or less).
3H     ADD ij,j,9*8-2*8
       LDB x,a20,ij
1H     LDB y,a10,ij
       CMP t,x,y    Is x<y?
       CSN x,t,y   If so, update the maximum.
2H     SUB ij,ij,8  Move up one.
       PBP ij,1B
       STB x,a10,ij Store column maximum.
       CMP t,x,z    Is x<z?
       CSN z,t,x   If so, update the min max.
       SUB  j,j,1   Move left a column.
       PBP  j,3B
Phase2 SET  ii,9*8-8 At this point $\.z=\min_jC(j)$
3H     ADD  ij,ii,8  Prepare to search a row.
       SET  j,8
1H     LDB  x,a10,ij
       SUB  t,z,x    Is $\.z>a_{ij}$?
       PBP  t,No     No saddle in this row
       PBN  t,2F
       LDB  x,a00,j  Is $a_{ij}=C(j)$?
       CMP  t,x,z
       CSZ  ans,t,ij If so, remember a possible saddle point.
2H     SUB  j,j,1    Move left in row.
       SUB  ij,ij,1
       PBP  j,1B
       LDA  ans,a10,ans  A saddle point was found here.
       POP  1,0
No     SUB  ii,ii,8
       PBP  ii,3B     Try another row.
       SET  ans,0
       POP  1,0     $\.{ans} = 0$; no saddle.\quad\slug

aaaa   GREG 6364136223846793005  C E Haynes's multiplier
Main   SET  ij,9*8      assume that $1 = seed
1H     MULU $1,$1,aaaa
       INCL $1,1
       MULU x,$1,5
       GET  x,rH
       SUB  x,x,2
       STB  x,a10,ij
       SUB  ij,ij,1
       PBP  ij,1B
       PUSHJ 2,Phase1
       JMP  Main
