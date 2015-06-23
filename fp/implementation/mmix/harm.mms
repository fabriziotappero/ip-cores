* Sum of Rounded Harmonic Series
MaxN IS 10
a GREG % Accumulator
c GREG % $2\cdot10^n$
d GREG % Divisor or digit
r GREG % Scaled reciprocal
s GREG % Scaled sum
m GREG % $m_k$
mm GREG % $m_{k+1}$
nn GREG % $n-\.{MaxN}$
     LOC Data_Segment
dec  GREG @+3 % decimal point loc
     BYTE "   ."
%    LOC  @+MaxN+6
     LOC #100
Main NEG nn,MaxN-1
     SET c,20
1H   SET m,1
     SR  s,c,1
     JMP 2F
3H   SUB a,c,1
     SL  d,r,1
     SUB d,d,1
     DIV mm,a,d
4H   SUB a,mm,m
     MUL a,r,a
     ADD s,s,a
     SET m,mm
2H   ADD a,c,m
     2ADDU d,m,2
     DIV r,a,d
     PBNZ r,3B
5H   ADD a,nn,MaxN+1
     SET d,#a
     JMP 7F
6H   DIV s,s,10
     GET d,rR
     INCL d,'0'
7H   STB d,dec,a
     SUB a,a,1
     BZ  a,@-4
     PBNZ s,6B
8H   SUB $255,dec,3
     TRAP 0,Fputs,StdOut
9H   INCL nn,1
     MUL  c,c,10
     PBNP nn,1B
