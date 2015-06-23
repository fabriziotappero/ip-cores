* Exercise 1.3.2'--18, Solution 1
      LOC #100
t IS $255
a00 GREG Data_Segment
a10 GREG Data_Segment+8
ij  IS $0  % element index and return register
j   GREG  % column index
k   GREG  % size of list of minima
x   GREG  % current minimum
y   GREG  % current element
Saddle SET  ij,9*8
RowMin SET  j,8
       LDB  x,a10,ij  Candidate for row minimum
2H     SET  k,0       Set list empty.
4H     INCL k,1
       STB  j,a00,k   Put column index in list.
1H     SUB  ij,ij,1    Go left one.
       SUB  j,j,1         
       BZ   j,ColMax  Done with row?
3H     LDB  y,a10,ij
       SUB  t,x,y
       PBN  t,1B      Is \.x still minimum?
       SET  x,y
       PBP  t,2B      New minimum?
       JMP  4B        Remember another minimum.
ColMax LDB  $1,a00,k   Get column from list.
       ADD  j,$1,9*8-8
1H     LDB  y,a10,j
       CMP  t,x,y
       PBN  t,No        Is row min${}<{}$column element?
       SUB  j,j,8
       PBP  j,1B      Done with column?
Yes    ADD  ij,ij,$1  Yes; $\.{ij}\gets{}$index of saddle.
       LDA  ij,a10,ij
       POP  1,0
No     SUB  k,k,1     Is list empty?
       BP   k,ColMax  If not, try again.
       PBP  ij,RowMin Have all rows been tried?
       POP  1,0       Yes; $\$0=0$, no saddle.\quad\slug\endmmix

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
       PUSHJ 2,Saddle
       JMP  Main
