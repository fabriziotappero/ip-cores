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
          CMP   t,xk,m
          PBNP  t,DecreaseK
ChangeM   SET   m,xk
ChangeJ   SR    j,kk,3
DecreaseK SUB   kk,kk,8
          PBP   kk,Loop
          POP   2,0

Main      GETA  t,9F
          TRAP  0,Fread,StdIn
          SET   $0,N<<3
1H        SR    $2,$0,3
          PUSHJ 1,Maximum
          LDO   $3,x0,$0
          SL    $2,$2,3
          STO   $1,x0,$0
          STO   $3,x0,$2
          SUB   $0,$0,1<<3
          PBNZ  $0,1B
          GETA  t,9F
          TRAP  0,Fwrite,StdOut
          TRAP  0,Halt,0
9H        OCTA  X0+1<<3,N<<3

          
