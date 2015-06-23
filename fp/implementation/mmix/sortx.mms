          LOC   Data_Segment
x0        GREG  @
X0        IS    @
N         IS    100

j         IS    $0
m         IS    $1
kk        IS    $2
xk        IS    $3
t         IS    $255
          LOC   #100
Maximum   SL    kk,$0,3
          LDO   m,x0,kk
          JMP   ChangeJ
Loop      LDO   xk,x0,kk
          CMP   t,m,xk
          PBN   t,DecreaseK
ChangeM   SET   m,xk
ChangeJ   SR    j,kk,3
DecreaseK SUB   kk,kk,8
          PBP   kk,Loop
          POP   2,0

Main      GETA  t,8F
          TRAP  0,Fopen,StdIn
          GETA  t,9F
          TRAP  0,Fread,StdIn
          SET   $0,N<<3
1H        SR    $2,$0,3
          PUSHJ 1,Maximum
          TRAP  0,Halt,0
9H        OCTA  X0+1<<3,N<<3
8H        OCTA  7F,TextRead
7H        BYTE  "sort.dat",0
