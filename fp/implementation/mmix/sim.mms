% Stripped-Down Simulator for MMIX, derived from MMIX-SIM
% To run it on a program like "foo bar"
%   first say "mmix -Dfoo.mmb foo bar"
%   then "mmix <options> sim foo.mmb"

% I apologize for lack of comments; they're in the book though

t  IS   $255
lring_size IS 256 % octabytes in the local register ring

         LOC Data_Segment
Global   LOC  @+8*256
g        GREG Global  % base of 256 global registers
Local    LOC  @+8*lring_size
l        GREG Local  % base of lring_size local registers
         GREG @
IOArgs   OCTA 0,BinaryRead
Chunk0   IS   @

         LOC #100
         PREFIX :Mem:
head     GREG   % address of first chunk
curkey GREG   % KEY(head)
alloc    GREG   % address of next chunk to allocate
Chunk    IS   #1000  bytes per chunk, is power of 2
addr     IS   $0
key    IS   $1
test     IS   $2
newlink  IS   $3
p        IS   $4  % LINK(p)=head
t        IS   :t

KEY    IS   0
LINK     IS   8
DATA     IS   16
nodesize  GREG Chunk+3*8   pad with 8 zero bytes
mask      GREG Chunk-1

:MemFind ANDN  key,addr,mask
         CMPU  t,key,curkey
         PBZ   t,4F
         BN    addr,:Error
         SET   newlink,head
1H       SET   p,head
         LDOU  head,p,LINK
         PBNZ  head,2F
         SET   head,alloc
         STOU  key,head,KEY
         ADDU  alloc,alloc,nodesize
         JMP   3F
2H       LDOU  test,head,KEY
         CMPU  t,test,key
         BNZ   t,1B
3H       LDOU  t,head,LINK
         STOU  newlink,head,LINK
         SET   curkey,key
         STOU  t,p,LINK
4H       SUBU  t,addr,key
         LDA   $0,head,DATA
         ADDU  $0,t,$0
         POP   1,0
         PREFIX :

res      IS    $2
arg      IS    res+1

ss       GREG  % rS
oo       GREG  % rO
ll       GREG  % 8*rL
gg       GREG  % 8*rG
aa       GREG  % rA
ii       GREG  % rI
uu       GREG  % rU
cc       GREG  % rC

lring_mask GREG 8*lring_size-1
:GetReg    CMPU   t,$0,gg
           BN     t,1F
           LDOU   $0,g,$0
           POP    1,0
1H         CMPU   t,$0,ll
           ADDU   $0,$0,oo
           AND    $0,$0,lring_mask
           LDOU   $0,l,$0
           CSNN   $0,t,0
           POP    1,0

:StackStore GET  $0,rJ
           AND   t,ss,lring_mask        \S82
           LDOU  $1,l,t
           SET   arg,ss
           PUSHJ res,MemFind
           STOU  $1,res,0       M[rS]<-l[rS]
           ADDU  ss,ss,8
           PUT   rJ,$0
           POP
:StackLoad GET   $0,rJ
           SUBU  ss,ss,8                \S83
           SET   arg,ss
           PUSHJ res,MemFind
           LDOU  $1,res,0
           AND   t,ss,lring_mask
           STOU  $1,l,t
           PUT   rJ,$0
           POP
:StackRoom SUBU  t,ss,oo   idiom in \S81,\S101,\S102
           SUBU  t,t,ll
           AND   t,t,lring_mask
           PBNZ  t,1F
           GET   $0,rJ
           PUSHJ res,StackStore
           PUT   rJ,$0
1H         POP

* The main loop
loc        GREG      % where the simulator is at
inst_ptr   GREG      % where the simulator will be next
inst       GREG      % the current instruction being simulated
resuming   GREG      % are we resuming an instruction in rX?

Fetch      PBZ   resuming,1F      \S60 (main simulation loop)
           SUBU  loc,inst_ptr,4
           LDTU  inst,g,8*rX+4
           JMP   2F
1H         SET   loc,inst_ptr
           SET   arg,loc
           PUSHJ res,MemFind
           LDTU  inst,res,0
           ADDU  inst_ptr,loc,4
2H         CMPU  t,loc,g
           BNN   t,Error   loc>=Data_Segment

op         GREG      % opcode of the current instruction
xx         GREG      % X field of the current instruction
yy         GREG      % Y field of the current instruction
zz         GREG      % Z field of the current instruction
yz         GREG      % YZ field of the current instruction
f          GREG      % packed information about the current op
xxx        GREG      % X field times 8
x          GREG      % result, or X operand
y          GREG      % Y operand
z          GREG      % Z operand
xptr       GREG      % location where x should be stored
exc        GREG      % arithmetic exceptions

Z_is_immed_bit  IS #1
Z_is_source_bit IS #2
Y_is_immed_bit  IS #4
Y_is_source_bit IS #8
X_is_source_bit IS #10
X_is_dest_bit   IS #20
Rel_addr_bit    IS #40
Mem_bit         IS #80

Info IS #1000
Done IS Info+8*256
info       GREG  Info   % base address for master info table
c255    GREG 8*255
c256    GREG 8*256

           MOR   op,inst,#8
           MOR   xx,inst,#4
           MOR   yy,inst,#2
           MOR   zz,inst,#1
0H  GREG  -#10000
           ANDN  yz,inst,0B
           SLU   xxx,xx,3
           SLU   t,op,3
           LDOU  f,info,t
           SET   x,0
           SET   y,0
           SET   z,0
           SET   exc,0
           AND   t,f,Rel_addr_bit
           PBZ   t,1F
           PBEV  f,2F            Convert rel to abs, \S70
9H  GREG  -#1000000
           ANDN  yz,inst,9B   xyz
           ADDU  t,yz,9B
           JMP   3F
2H         ADDU  t,yz,0B
3H         CSOD   yz,op,t
           SL     t,yz,2
           ADDU   yz,loc,t
1H         PBNN   resuming,Install_X    Install operands \S71
           LDOU   y,g,8*rY       Install special operands \S127
           LDOU   z,g,8*rZ
           BOD    resuming,Install_Y
0H    GREG #C1<<56+(x-$0)<<48+(z-$0)<<40+1<<16+X_is_dest_bit
           SET    f,0B           Change to ORI instruction
           LDOU   exc,g,8*rX
           MOR    exc,exc,#20
           JMP    XDest
Install_X  AND    t,f,X_is_source_bit
           PBZ    t,1F
           SET    arg,xxx
           PUSHJ  res,GetReg
           SET    x,res
1H         SRU    t,f,5
           AND    t,t,#f8
           PBZ    t,Install_Z
           LDOU   x,g,t      Set x from third op, \S79
Install_Z  AND    t,f,Z_is_source_bit
           PBZ    t,1F
           SLU    arg,zz,3
           PUSHJ  res,GetReg
           SET    z,res
           JMP    Install_Y
1H         CSOD   z,f,zz     Z_is_immed_bit
           AND    t,op,#f0
           CMPU   t,t,#e0
           PBNZ   t,Install_Y
           AND    t,op,#3    Set z as immediate wyde, \S78
           NEG    t,3,t
           SLU    t,t,4
           SLU    z,yz,t
           SET    y,x
Install_Y  AND    t,f,Y_is_immed_bit
           PBZ    t,1F
           SET    y,yy
           SLU    t,yy,40
           ADDU   f,f,t
1H         AND    t,f,Y_is_source_bit
           BZ     t,1F
           SLU    arg,yy,3
           PUSHJ  res,GetReg
           SET    y,res          (end of \S71)
1H         AND    t,f,X_is_dest_bit
           BZ     t,1F
XDest      CMPU   t,xxx,gg      Install X as dest, \S80
           BN     t,3F
           LDA    xptr,g,xxx
           JMP    1F
2H         ADDU   t,oo,ll
           AND    t,t,lring_mask
           STCO   0,l,t
           INCL   ll,8
           PUSHJ  res,StackRoom
3H         CMPU   t,xxx,ll
           BNN    t,2B
           ADD    t,xxx,oo
           AND    t,t,lring_mask
           LDA    xptr,l,t
1H         AND    t,f,Mem_bit
           PBZ    t,1F
           ADDU   arg,y,z
           CMPU   t,op,#A0
           BN     t,2F
           CMPU   t,arg,g
           BN     t,Error
2H         PUSHJ  res,MemFind
1H         SRU    t,f,32
           PUT    rX,t
           PUT    rM,x
           PUT    rE,x
0H    GREG   #30000
           AND    t,aa,0B
           ORL    t,U_BIT<<8  enable underflow trip
           PUT    rA,t
0H    GREG   Done
           PUT    rW,0B
           RESUME

MulU       MULU   x,y,z
           GET    t,rH
           STOU   t,g,8*rH
           JMP    XDone

Div        DIV    x,y,z
           JMP    1F
DivU       PUT    rD,x
           DIVU   x,y,z
1H         GET    t,rR
           STO    t,g,8*rR
           JMP    XDone

Cswap      LDOU  z,g,8*rP
           LDOU  y,res,0
           CMPU  t,y,z
           BNZ   t,1F
           STOU  x,res,0
           JMP   2F
1H         STOU  y,g,8*rP
2H         ZSZ   x,t,1
           JMP   XDone

BTaken     ADDU   cc,cc,4
PBTaken    SUBU   cc,cc,2
           SET    inst_ptr,yz
           JMP    Update

Go         SET    x,inst_ptr
           ADDU   inst_ptr,y,z
           JMP    XDone

PushGo     ADDU   yz,y,z
PushJ      SET    inst_ptr,yz
           CMPU   t,xxx,gg
           PBN    t,1F
           SET    xxx,ll
           SRU    xx,xxx,3
           INCL   ll,8
           PUSHJ  0,StackRoom
1H         ADDU   t,xxx,oo
           AND    t,t,lring_mask
           STOU   xx,l,t
           ADDU   t,loc,4
           STOU   t,g,8*rJ
           INCL   xxx,8
           SUBU   ll,ll,xxx
           ADDU   oo,oo,xxx
           JMP    Update

Pop        SUBU   oo,oo,8
           BZ     xx,1F
           CMPU   t,ll,xxx
           BN     t,1F
           ADDU   t,xxx,oo
           AND    t,t,lring_mask
           LDOU   y,l,t
1H         CMPU   t,oo,ss
           PBNN   t,1F
           PUSHJ  0,StackLoad
1H         AND    t,oo,lring_mask
           LDOU   z,l,t
           AND    z,z,#ff
           SLU    z,z,3
1H         SUBU   t,oo,ss
           CMPU   t,t,z
           PBNN   t,1F
           PUSHJ  0,StackLoad actually gamma=beta possible here!
           JMP    1B
1H         ADDU   ll,ll,8
           CMPU   t,xxx,ll
           CSN    ll,t,xxx
           ADDU   ll,ll,z
           CMPU   t,gg,ll
           CSN    ll,t,gg
           CMPU   t,z,ll
           BNN    t,1F
           AND    t,oo,lring_mask
           STOU   y,l,t
1H         LDOU   y,g,8*rJ
           SUBU   oo,oo,z
           4ADDU  inst_ptr,yz,y
           JMP    Update

Save       BNZ    yz,Error     \S102
           CMPU   t,xxx,gg
           BN     t,Error
           ADDU   t,oo,ll
           AND    t,t,lring_mask
           SRU    y,ll,3
           STOU   y,l,t
           INCL   ll,8
           PUSHJ  0,StackRoom
           ADDU   oo,oo,ll
           SET    ll,0
1H         PUSHJ  0,StackStore
           CMPU   t,ss,oo
           PBNZ   t,1B
           SUBU   y,gg,8
4H         ADDU   y,y,8
1H         SET    arg,ss     \S103
           PUSHJ  res,MemFind
           CMPU   t,y,8*(rZ+1)
           LDOU   z,g,y
           PBNZ   t,2F
           SLU    z,gg,56-3
           ADDU   z,z,aa
2H         STOU   z,res,0
           INCL   ss,8
           BNZ    t,1F
           CMPU   t,y,c255
           BZ     t,2F
           CMPU   t,y,8*rR
           PBNZ   t,4B
           SET    y,8*rP
           JMP    1B
2H         SET    y,8*rB
           JMP    1B
1H         SET    oo,ss
           SUBU   x,oo,8
           JMP    XDone

Unsave     BNZ    xx,Error    \S104
           BNZ    yy,Error
           ANDNL  z,#7
           ADDU   ss,z,8
           SET    y,8*(rZ+2)
1H         SUBU   y,y,8
4H         SUBU   ss,ss,8      \S105
           SET    arg,ss
           PUSHJ  res,MemFind
           LDOU   x,res,0
           CMPU   t,y,8*(rZ+1)
           PBNZ   t,2F
           SRU    gg,x,56-3
           SLU    aa,x,64-18
           SRU    aa,aa,64-18
           JMP    1B
2H         STOU   x,g,y
3H         CMPU   t,y,8*rP
           CSZ    y,t,8*(rR+1)
           CSZ    y,y,c256
           CMPU   t,y,gg
           PBNZ   t,1B
           PUSHJ  0,StackLoad
           AND    t,ss,lring_mask
           LDOU   x,l,t
           AND    x,x,#ff
           BZ     x,1F
           SET    y,x
2H         PUSHJ  0,StackLoad
           SUBU   y,y,1
           PBNZ   y,2B
           SLU    x,x,3
1H         SET    ll,x
           CMPU   t,gg,x
           CSN    ll,t,gg
           SET    oo,ss
           PBNZ   uu,Update
           BZ     resuming,Update
           JMP    AllDone

Get        CMPU   t,yz,32
           BNN    t,Error
           STOU   ii,g,8*rI
           STOU   cc,g,8*rC
           STOU   oo,g,8*rO
           STOU   ss,g,8*rS
           STOU   uu,g,8*rU
           STOU   aa,g,8*rA
           SR     t,ll,3
           STOU   t,g,8*rL
           SR     t,gg,3
           STOU   t,g,8*rG
           SLU    t,zz,3
           LDOU   x,g,t
           JMP    XDone

Put        BNZ    yy,Error
           CMPU   t,xx,32
           BNN     t,Error
           CMPU   t,xx,rC
           BN     t,PutOK
           CMPU   t,xx,rF
           BN     t,1F
PutOK      STOU   z,g,xxx
           JMP    Update
1H         CMPU   t,xx,rG
           BN     t,Error
           SUB    t,xx,rL
           PBP    t,PutA
           BN     t,PutG
PutL       SLU    z,z,3     \S98, PUT rL
           CMPU   t,z,ll
           CSN    ll,t,z
           JMP    Update
0H    GREG   #40000
PutA       CMPU   t,z,0B    \S100, PUT rA
           BNN    t,Error
           SET    aa,z
           JMP    Update
PutG       SRU    t,z,8
           BNZ    t,Error
           CMPU   t,z,32
           BN     t,Error
           SLU    z,z,3
           CMPU   t,z,ll
           BN     t,Error
           JMP    2F
1H         SUBU   gg,gg,8
           STCO   0,g,gg
2H         CMPU   t,z,gg
           PBN    t,1B
           SET    gg,z
           JMP    Update

Resume     SLU    t,inst,40    \S125
           BNZ    t,Error
           LDOU   inst_ptr,g,8*rW
           LDOU   x,g,8*rX
           BN     x,Update
           SRU    xx,x,56
           SUBU   t,xx,2
           BNN    t,1F
           PBZ    xx,2F
           SRU    y,x,28   rop=1 (RESUME_CONT)
           AND    y,y,#f
           SET    z,1
           SLU    z,z,y
           ANDNL  z,#70cf
           BNZ    z,Error
1H         BP     t,Error
           SRU    t,x,13
           AND    t,t,c255
           CMPU   y,t,ll
           BN     y,2F
           CMPU   y,t,gg
           BN     y,Error
2H         MOR    t,x,#8
           CMPU   t,t,#F9  RESUME
           BZ     t,Error
           NEG    resuming,xx
           CSNN   resuming,resuming,1
           JMP    Update

Sync       BNZ    xx,Error
           CMPU   t,yz,4
           BNN    t,Error
           JMP    Update

Trip       SET    xx,0
           JMP    TakeTrip

Trap       STOU   inst_ptr,g,8*rWW
0H    GREG   #8000000000000000
           ADDU   t,inst,0B
           STOU   t,g,8*rXX
           STOU   y,g,8*rYY
           STOU   z,g,8*rZZ
           SRU    y,inst,6
           CMPU   t,y,4*11
           BNN    t,Error
           LDOU   t,g,c255
0H    GREG  @+4
           GO     y,0B,y
           JMP    SimHalt
           JMP    SimFopen
           JMP    SimFclose
           JMP    SimFread
           JMP    SimFgets
           JMP    SimFgetws
           JMP    SimFwrite
           JMP    SimFputs
           JMP    SimFputws
           JMP    SimFseek
           JMP    SimFtell

:GetArgs   GET   $0,rJ
           SET   y,t
           SET   arg,t
           PUSHJ res,MemFind
           LDOU  z,res,0        z = virtual address of buffer
           SET   arg,z
           PUSHJ res,MemFind
           SET   x,res          x = physical address of buffer
           STO   x,IOArgs
           SET   xx,Mem:Chunk
           AND   zz,x,Mem:mask
           SUB   xx,xx,zz       xx = bytes from x to chunk end
           ADDU  arg,y,8
           PUSHJ res,MemFind
           LDOU  zz,res,0       zz = size of buffer
           STOU  zz,IOArgs+8
           PUT   rJ,$0
           POP

           GREG  @
:SimInst   LDA   t,IOArgs
           JMP   DoInst
SimFinish  LDA   t,IOArgs
SimFclose  GETA  $0,TrapDone
:DoInst    PUT   rW,$0
           PUT   rX,inst
           RESUME

SimFopen   PUSHJ 0,GetArgs
           ADDU  xx,Mem:alloc,Mem:nodesize
           STOU  xx,IOArgs   % we'll copy the file name here
           SET   x,xx
1H         SET   arg,z
           PUSHJ res,MemFind
           LDBU  t,res,0
           STBU  t,x,0
           INCL  x,1
           INCL  z,1
           PBNZ  t,1B
           GO    $0,SimInst
3H         STCO  0,x,0     % clean up the copied string
           CMPU  z,xx,x
           SUB   x,x,8
           PBN   z,3B
           JMP   TrapDone

TrapDone   STO    t,g,8*rBB    "RESUME 1" works this way
           STO    t,g,c255
           JMP    Update

SimFread   PUSHJ  0,GetArgs
           SET    y,zz   number of bytes to read
1H         CMP    t,xx,y
           PBNN   t,SimFinish
           STO    xx,IOArgs+8  oops, we must cross chunk bdry
           SUB    y,y,xx
           GO     $0,SimInst
           BN     t,1F
           ADD    z,z,xx
           SET    arg,z
           PUSHJ  res,MemFind
           STOU   res,IOArgs
           STO    y,IOArgs+8
           ADD    xx,Mem:mask,1
           JMP    1B
1H         SUB    t,t,y
           JMP    TrapDone

SimFgets   PUSHJ  0,GetArgs
           CMP    t,xx,zz
           PBNN   t,SimFinish     easy if all in one chunk
           SET    y,zz  remaining buf size
           SET    yy,0  bytes successfully read so far
1H         ADD    t,xx,1
           STO    t,IOArgs+8   null character spills off end
           GO     $0,SimInst
           BN     t,TrapDone
           ADD    yy,yy,t
           CMP    $0,t,xx
           SET    t,yy
           PBNZ   $0,TrapDone
           ADDU   z,z,xx
           SET    arg,z
           PUSHJ  res,MemFind
           SUBU   x,x,1
           LDBU   t,x,xx      look at last byte read
           CMP    t,t,#0a     is it newline?
           BZ     t,1F
           SUB    y,y,xx
           SET    x,res
           STOU   x,IOArgs
           STO    y,IOArgs+8
           ADD    xx,Mem:mask,1
           CMP    t,xx,y
           BN     t,1B
           GO     $0,SimInst
           BN     t,TrapDone
2H         ADD    t,yy,t
           JMP    TrapDone
1H         SET    t,0
           STBU   t,res,0
           JMP    2B

SimFgetws  PUSHJ  0,GetArgs
           ADD    y,zz,zz  remaining buf size (bytes)
           CMP    t,xx,y
           PBNN   t,SimFinish     easy if all in one chunk
           SET    yy,0  wydes successfully read so far
1H         ADD    zz,xx,3
           SR     zz,zz,1        wydes in current chunk, plus 1
           STO    zz,IOArgs+8   null character spills off end
           GO     $0,SimInst
           BN     t,TrapDone
           ADDU   yy,yy,t
           SUB    zz,zz,1
           CMP    $0,t,zz
           SET    t,yy
           PBNZ   $0,TrapDone
           ADD    z,z,xx
           SET    arg,z
           PUSHJ  res,MemFind
           SUBU   x,x,2
           LDWU   t,x,xx      look at last wyde read
           CMP    t,t,#0a     is it newline?
           BZ     t,1F
           SUB    y,y,xx
           SET    x,res
           STOU   x,IOArgs
           SR     t,y,1
           STO    t,IOArgs+8
           ADD    xx,Mem:mask,1
           ANDN   y,y,1
           CMP    t,xx,y
           BN     t,1B
           GO     $0,SimInst
           BN     t,TrapDone
2H         ADD    t,yy,t
           JMP    TrapDone
1H         SET    t,0
           STWU   t,res,0
           JMP    2B

SimFwrite  IS     SimFread    yes it works!

SimFputs   SET    xx,0       this many bytes written
           SET    z,t        virtual address of string
1H         SET    arg,z
           PUSHJ  res,MemFind
           SET    t,res      physical address of string
           GO     $0,DoInst
           BN     t,TrapDone
           BZ     t,1F
           ADD    xx,xx,t
           ADDU   z,z,t
           AND    t,z,Mem:mask
           BZ     t,1B
1H         SET    t,xx
           JMP    TrapDone

SimFputws  SET    xx,0       this many wydes written
           SET    z,t        virtual address of string
1H         SET    arg,z
           PUSHJ  res,MemFind
           SET    t,res      physical address of string
           GO     $0,DoInst
           BN     t,TrapDone
           BZ     t,1F
           ADD    xx,xx,t
           2ADDU  z,t,z
           AND    t,z,Mem:mask
           BZ     t,1B
1H         SET    t,xx
           JMP    TrapDone

SimFseek   IS    SimFclose
SimFtell   IS    SimFclose

  GREG @
1H BYTE "Warning: ",0
2H BYTE " at location ",0
3H BYTE #a,0
T0 BYTE "TRIP",0
T1 BYTE "integer divide check",0
T2 BYTE "integer overflow",0
T3 BYTE "float-to-fix overflow",0
T4 BYTE "invalid floating point operation",0
T5 BYTE "floating point overflow",0
T6 BYTE "floating point underflow",0
T7 BYTE "floating point division by zero",0
T8 BYTE "floating point inexact",0
TripType OCTA T0,T1,T2,T3,T4,T5,T6,T7,T8
SimHalt    CMP   t,zz,1
           BZ    inst,Exit  t=0 on normal exit
           BNZ   t,Error
           CMPU  t,loc,#90
           BNN   t,Error    Halt 1 from loc<#90 gives warning
           LDA   t,1B
           TRAP  0,Fputs,StdErr
           SR    x,loc,1
           LDA   t,TripType
           LDOU  t,t,x
           TRAP  0,Fputs,StdErr
           LDA   t,2B
           TRAP  0,Fputs,StdErr
           LDOU  x,g,8*rW
           SUBU  x,x,4
           SRU   arg,x,32
           PUSHJ res,OutTetra
           SET   arg,x
           PUSHJ res,OutTetra
           LDA   t,3B
           TRAP  0,Fputs,StdErr
           LDOU  t,g,c255
           JMP   TrapDone

Error      NEG    t,22       catch-22
Exit       TRAP   0,Halt,0

s IS $1
0H GREG #0008000400020001
:OutTetra MOR t,$0,0B
     SLU s,t,4
     XOR t,s,t
0H GREG #0f0f0f0f0f0f0f0f
     AND t,t,0B
0H GREG #0606060606060606
     ADDU t,t,0B
0H GREG #0000002700000000
     MOR s,0B,t
0H GREG #2a2a2a2a2a2a2a2a
     ADDU t,t,0B
     ADDU s,t,s
     STOU s,g,c255
     GETA t,OctaArgs
     TRAP 0,Fwrite,StdErr
     POP  0

O   IS  Done-4
           LOC    Info
 JMP Trap+@-O; BYTE 0,5,0,#0a  TRAP
 FCMP x,y,z; BYTE 0,1,0,#2a  FCMP
 FUN x,y,z; BYTE 0,1,0,#2a  FUN
 FEQL x,y,z; BYTE 0,1,0,#2a  FEQL
 FADD x,y,z; BYTE 0,4,0,#2a  FADD
 FIX  x,0,z; BYTE 0,4,0,#26  FIX
 FSUB x,y,z; BYTE 0,4,0,#2a  FSUB
 FIXU x,0,z; BYTE 0,4,0,#26  FIXU
 FLOT x,0,z; BYTE 0,4,0,#26  FLOT
 FLOT x,0,z; BYTE 0,4,0,#25  FLOTI
 FLOTU x,0,z; BYTE 0,4,0,#26  FLOTU
 FLOTU x,0,z; BYTE 0,4,0,#25  FLOTUI
 SFLOT x,0,z; BYTE 0,4,0,#26  SFLOT
 SFLOT x,0,z; BYTE 0,4,0,#25  SFLOTI
 SFLOTU x,0,z; BYTE 0,4,0,#26  SFLOTU
 SFLOTU x,0,z; BYTE 0,4,0,#25  SFLOTUI
 FMUL x,y,z; BYTE 0,4,0,#2a  FMUL
 FCMPE x,y,z; BYTE 0,4,rE,#2a  FCMPE
 FUNE x,y,z; BYTE 0,1,rE,#2a  FUNE
 FEQLE x,y,z; BYTE 0,4,rE,#2a  FEQLE
 FDIV x,y,z; BYTE 0,40,0,#2a  FDIV
 FSQRT x,0,z; BYTE 0,40,0,#26  FSQRT
 FREM x,y,z; BYTE 0,4,0,#2a  FREM
 FINT x,0,z; BYTE 0,4,0,#26  FINT
 MUL x,y,z; BYTE 0,10,0,#2a  MUL
 MUL x,y,z; BYTE 0,10,0,#29  MULI
 JMP MulU+@-O; BYTE 0,10,0,#2a  MULU
 JMP MulU+@-O; BYTE 0,10,0,#29  MULUI
 JMP Div+@-O; BYTE 0,60,0,#2a  DIV
 JMP Div+@-O; BYTE 0,60,0,#29  DIVI
 JMP DivU+@-O; BYTE 0,60,rD,#2a  DIVU
 JMP DivU+@-O; BYTE 0,60,rD,#29  DIVUI
 ADD x,y,z; BYTE 0,1,0,#2a  ADD
 ADD x,y,z; BYTE 0,1,0,#29  ADDI
 ADDU x,y,z; BYTE 0,1,0,#2a  ADDU
 ADDU x,y,z; BYTE 0,1,0,#29  ADDUI
 SUB x,y,z; BYTE 0,1,0,#2a  SUB
 SUB x,y,z; BYTE 0,1,0,#29  SUBI
 SUBU x,y,z; BYTE 0,1,0,#2a  SUBU
 SUBU x,y,z; BYTE 0,1,0,#29  SUBUI
 2ADDU x,y,z; BYTE 0,1,0,#2a  2ADDU
 2ADDU x,y,z; BYTE 0,1,0,#29  2ADDUI
 4ADDU x,y,z; BYTE 0,1,0,#2a  4ADDU
 4ADDU x,y,z; BYTE 0,1,0,#29  4ADDUI
 8ADDU x,y,z; BYTE 0,1,0,#2a  8ADDU
 8ADDU x,y,z; BYTE 0,1,0,#29  8ADDUI
 16ADDU x,y,z; BYTE 0,1,0,#2a  16ADDU
 16ADDU x,y,z; BYTE 0,1,0,#29  16ADDUI
 CMP x,y,z; BYTE 0,1,0,#2a  CMP
 CMP x,y,z; BYTE 0,1,0,#29  CMPI
 CMPU x,y,z; BYTE 0,1,0,#2a  CMPU
 CMPU x,y,z; BYTE 0,1,0,#29  CMPUI
 NEG x,0,z; BYTE 0,1,0,#26  NEG
 NEG x,0,z; BYTE 0,1,0,#25  NEGI
 NEGU x,0,z; BYTE 0,1,0,#26  NEGU
 NEGU x,0,z; BYTE 0,1,0,#25  NEGUI
 SL x,y,z; BYTE 0,1,0,#2a  SL
 SL x,y,z; BYTE 0,1,0,#29  SLI
 SLU x,y,z; BYTE 0,1,0,#2a  SLU
 SLU x,y,z; BYTE 0,1,0,#29  SLUI
 SR x,y,z; BYTE 0,1,0,#2a  SR
 SR x,y,z; BYTE 0,1,0,#29  SRI
 SRU x,y,z; BYTE 0,1,0,#2a  SRU
 SRU x,y,z; BYTE 0,1,0,#29  SRUI
 BN x,BTaken+@-O; BYTE 0,1,0,#50  BN
 BN x,BTaken+@-O; BYTE 0,1,0,#50  BNB
 BZ x,BTaken+@-O; BYTE 0,1,0,#50  BZ
 BZ x,BTaken+@-O; BYTE 0,1,0,#50  BZB
 BP x,BTaken+@-O; BYTE 0,1,0,#50  BP
 BP x,BTaken+@-O; BYTE 0,1,0,#50  BPB
 BOD x,BTaken+@-O; BYTE 0,1,0,#50  BOD
 BOD x,BTaken+@-O; BYTE 0,1,0,#50  BODB
 BNN x,BTaken+@-O; BYTE 0,1,0,#50  BNN
 BNN x,BTaken+@-O; BYTE 0,1,0,#50  BNNB
 BNZ x,BTaken+@-O; BYTE 0,1,0,#50  BNZ
 BNZ x,BTaken+@-O; BYTE 0,1,0,#50  BNZB
 BNP x,BTaken+@-O; BYTE 0,1,0,#50  BNP
 BNP x,BTaken+@-O; BYTE 0,1,0,#50  BNPB
 BEV x,BTaken+@-O; BYTE 0,1,0,#50  BEV
 BEV x,BTaken+@-O; BYTE 0,1,0,#50  BEVB
 PBN x,PBTaken+@-O; BYTE 0,3,0,#50  PBN
 PBN x,PBTaken+@-O; BYTE 0,3,0,#50  PBNB
 PBZ x,PBTaken+@-O; BYTE 0,3,0,#50  PBZ
 PBZ x,PBTaken+@-O; BYTE 0,3,0,#50  PBZB
 PBP x,PBTaken+@-O; BYTE 0,3,0,#50  PBP
 PBP x,PBTaken+@-O; BYTE 0,3,0,#50  PBPB
 PBOD x,PBTaken+@-O; BYTE 0,3,0,#50  PBOD
 PBOD x,PBTaken+@-O; BYTE 0,3,0,#50  PBODB
 PBNN x,PBTaken+@-O; BYTE 0,3,0,#50  PBNN
 PBNN x,PBTaken+@-O; BYTE 0,3,0,#50  PBNNB
 PBNZ x,PBTaken+@-O; BYTE 0,3,0,#50  PBNZ
 PBNZ x,PBTaken+@-O; BYTE 0,3,0,#50  PBNZB
 PBNP x,PBTaken+@-O; BYTE 0,3,0,#50  PBNP
 PBNP x,PBTaken+@-O; BYTE 0,3,0,#50  PBNPB
 PBEV x,PBTaken+@-O; BYTE 0,3,0,#50  PBEV
 PBEV x,PBTaken+@-O; BYTE 0,3,0,#50  PBEVB
 CSN x,y,z; BYTE 0,1,0,#3a  CSN
 CSN x,y,z; BYTE 0,1,0,#39  CSNI
 CSZ x,y,z; BYTE 0,1,0,#3a  CSZ
 CSZ x,y,z; BYTE 0,1,0,#39  CSZI
 CSP x,y,z; BYTE 0,1,0,#3a  CSP
 CSP x,y,z; BYTE 0,1,0,#39  CSPI
 CSOD x,y,z; BYTE 0,1,0,#3a  CSOD
 CSOD x,y,z; BYTE 0,1,0,#39  CSODI
 CSNN x,y,z; BYTE 0,1,0,#3a  CSNN
 CSNN x,y,z; BYTE 0,1,0,#39  CSNNI
 CSNZ x,y,z; BYTE 0,1,0,#3a  CSNZ
 CSNZ x,y,z; BYTE 0,1,0,#39  CSNZI
 CSNP x,y,z; BYTE 0,1,0,#3a  CSNP
 CSNP x,y,z; BYTE 0,1,0,#39  CSNPI
 CSEV x,y,z; BYTE 0,1,0,#3a  CSEV
 CSEV x,y,z; BYTE 0,1,0,#39  CSEVI
 ZSN x,y,z; BYTE 0,1,0,#2a  ZSN
 ZSN x,y,z; BYTE 0,1,0,#29  ZSNI
 ZSZ x,y,z; BYTE 0,1,0,#2a  ZSZ
 ZSZ x,y,z; BYTE 0,1,0,#29  ZSZI
 ZSP x,y,z; BYTE 0,1,0,#2a  ZSP
 ZSP x,y,z; BYTE 0,1,0,#29  ZSPI
 ZSOD x,y,z; BYTE 0,1,0,#2a  ZSOD
 ZSOD x,y,z; BYTE 0,1,0,#29  ZSODI
 ZSNN x,y,z; BYTE 0,1,0,#2a  ZSNN
 ZSNN x,y,z; BYTE 0,1,0,#29  ZSNNI
 ZSNZ x,y,z; BYTE 0,1,0,#2a  ZSNZ
 ZSNZ x,y,z; BYTE 0,1,0,#29  ZSNZI
 ZSNP x,y,z; BYTE 0,1,0,#2a  ZSNP
 ZSNP x,y,z; BYTE 0,1,0,#29  ZSNPI
 ZSEV x,y,z; BYTE 0,1,0,#2a  ZSEV
 ZSEV x,y,z; BYTE 0,1,0,#29  ZSEVI
 LDB x,res,0; BYTE 1,1,0,#aa  LDB
 LDB x,res,0; BYTE 1,1,0,#a9  LDBI
 LDBU x,res,0; BYTE 1,1,0,#aa  LDBU
 LDBU x,res,0; BYTE 1,1,0,#a9  LDBUI
 LDW x,res,0; BYTE 1,1,0,#aa  LDW
 LDW x,res,0; BYTE 1,1,0,#a9  LDWI
 LDWU x,res,0; BYTE 1,1,0,#aa  LDWU
 LDWU x,res,0; BYTE 1,1,0,#a9  LDWUI
 LDT x,res,0; BYTE 1,1,0,#aa  LDT
 LDT x,res,0; BYTE 1,1,0,#a9  LDTI
 LDTU x,res,0; BYTE 1,1,0,#aa  LDTU
 LDTU x,res,0; BYTE 1,1,0,#a9  LDTUI
 LDO x,res,0; BYTE 1,1,0,#aa  LDO
 LDO x,res,0; BYTE 1,1,0,#a9  LDOI
 LDOU x,res,0; BYTE 1,1,0,#aa  LDOU
 LDOU x,res,0; BYTE 1,1,0,#a9  LDOUI
 LDSF x,res,0; BYTE 1,1,0,#aa  LDSF
 LDSF x,res,0; BYTE 1,1,0,#a9  LDSFI
 LDHT x,res,0; BYTE 1,1,0,#aa  LDHT
 LDHT x,res,0; BYTE 1,1,0,#a9  LDHTI
 JMP Cswap+@-O; BYTE 2,2,0,#ba  CSWAP
 JMP Cswap+@-O; BYTE 2,2,0,#b9  CSWAPI
 LDUNC x,res,0; BYTE 1,1,0,#aa  LDUNC
 LDUNC x,res,0; BYTE 1,1,0,#a9  LDUNCI
 JMP Error+@-O; BYTE 0,1,0,#2a  LDVTS
 JMP Error+@-O; BYTE 0,1,0,#29  LDVTSI
 SWYM 0; BYTE 0,1,0,#0a  PRELD
 SWYM 0; BYTE 0,1,0,#09  PRELDI
 SWYM 0; BYTE 0,1,0,#0a  PREGO
 SWYM 0; BYTE 0,1,0,#09  PREGOI
 JMP Go+@-O; BYTE 0,3,0,#2a  GO
 JMP Go+@-O; BYTE 0,3,0,#29  GOI
 STB x,res,0; BYTE 1,1,0,#9a  STB
 STB x,res,0; BYTE 1,1,0,#99  STBI
 STBU x,res,0; BYTE 1,1,0,#9a  STBU
 STBU x,res,0; BYTE 1,1,0,#99  STBUI
 STW x,res,0; BYTE 1,1,0,#9a  STW
 STW x,res,0; BYTE 1,1,0,#99  STWI
 STWU x,res,0; BYTE 1,1,0,#9a  STWU
 STWU x,res,0; BYTE 1,1,0,#99  STWUI
 STT x,res,0; BYTE 1,1,0,#9a  STT
 STT x,res,0; BYTE 1,1,0,#99  STTI
 STTU x,res,0; BYTE 1,1,0,#9a  STTU
 STTU x,res,0; BYTE 1,1,0,#99  STTUI
 STO x,res,0; BYTE 1,1,0,#9a  STO
 STO x,res,0; BYTE 1,1,0,#99  STOI
 STOU x,res,0; BYTE 1,1,0,#9a  STOU
 STOU x,res,0; BYTE 1,1,0,#99  STOUI
 STSF x,res,0; BYTE 1,1,0,#9a  STSF
 STSF x,res,0; BYTE 1,1,0,#99  STSFI
 STHT x,res,0; BYTE 1,1,0,#9a  STHT
 STHT x,res,0; BYTE 1,1,0,#99  STHTI
 STO xx,res,0; BYTE 1,1,0,#8a  STCO
 STO xx,res,0; BYTE 1,1,0,#89  STCOI
 STUNC x,res,0; BYTE 1,1,0,#9a  STUNC
 STUNC x,res,0; BYTE 1,1,0,#99  STUNCI
 SWYM 0; BYTE 0,1,0,#0a  SYNCD
 SWYM 0; BYTE 0,1,0,#09  SYNCDI
 SWYM 0; BYTE 0,1,0,#0a  PREST
 SWYM 0; BYTE 0,1,0,#09  PRESTI
 SWYM 0; BYTE 0,1,0,#0a  SYNCID
 SWYM 0; BYTE 0,1,0,#09  SYNCIDI
 JMP PushGo+@-O; BYTE 0,3,0,#2a  PUSHGO
 JMP PushGo+@-O; BYTE 0,3,0,#29  PUSHGOI
 OR x,y,z; BYTE 0,1,0,#2a  OR
 OR x,y,z; BYTE 0,1,0,#29  ORI
 ORN x,y,z; BYTE 0,1,0,#2a  ORN
 ORN x,y,z; BYTE 0,1,0,#29  ORNI
 NOR x,y,z; BYTE 0,1,0,#2a  NOR
 NOR x,y,z; BYTE 0,1,0,#29  NORI
 XOR x,y,z; BYTE 0,1,0,#2a  XOR
 XOR x,y,z; BYTE 0,1,0,#29  XORI
 AND x,y,z; BYTE 0,1,0,#2a  AND
 AND x,y,z; BYTE 0,1,0,#29  ANDI
 ANDN x,y,z; BYTE 0,1,0,#2a  ANDN
 ANDN x,y,z; BYTE 0,1,0,#29  ANDNI
 NAND x,y,z; BYTE 0,1,0,#2a  NAND
 NAND x,y,z; BYTE 0,1,0,#29  NANDI
 NXOR x,y,z; BYTE 0,1,0,#2a  NXOR
 NXOR x,y,z; BYTE 0,1,0,#29  NXORI
 BDIF x,y,z; BYTE 0,1,0,#2a  BDIF
 BDIF x,y,z; BYTE 0,1,0,#29  BDIFI
 WDIF x,y,z; BYTE 0,1,0,#2a  WDIF
 WDIF x,y,z; BYTE 0,1,0,#29  WDIFI
 TDIF x,y,z; BYTE 0,1,0,#2a  TDIF
 TDIF x,y,z; BYTE 0,1,0,#29  TDIFI
 ODIF x,y,z; BYTE 0,1,0,#2a  ODIF
 ODIF x,y,z; BYTE 0,1,0,#29  ODIFI
 MUX x,y,z; BYTE 0,1,rM,#2a  MUX
 MUX x,y,z; BYTE 0,1,rM,#29  MUXI
 SADD x,y,z; BYTE 0,1,0,#2a  SADD
 SADD x,y,z; BYTE 0,1,0,#29  SADDI
 MOR x,y,z; BYTE 0,1,0,#2a  MOR
 MOR x,y,z; BYTE 0,1,0,#29  MORI
 MXOR x,y,z; BYTE 0,1,0,#2a  MXOR
 MXOR x,y,z; BYTE 0,1,0,#29  MXORI
 SET x,z; BYTE 0,1,0,#20  SETH
 SET x,z; BYTE 0,1,0,#20  SETMH
 SET x,z; BYTE 0,1,0,#20  SETML
 SET x,z; BYTE 0,1,0,#20  SETL
 ADDU x,x,z; BYTE 0,1,0,#30  INCH
 ADDU x,x,z; BYTE 0,1,0,#30  INCMH
 ADDU x,x,z; BYTE 0,1,0,#30  INCML
 ADDU x,x,z; BYTE 0,1,0,#30  INCL
 OR x,x,z; BYTE 0,1,0,#30  ORH
 OR x,x,z; BYTE 0,1,0,#30  ORMH
 OR x,x,z; BYTE 0,1,0,#30  ORML
 OR x,x,z; BYTE 0,1,0,#30  ORL
 ANDN x,x,z; BYTE 0,1,0,#30  ANDNH
 ANDN x,x,z; BYTE 0,1,0,#30  ANDNMH
 ANDN x,x,z; BYTE 0,1,0,#30  ANDNML
 ANDN x,x,z; BYTE 0,1,0,#30  ANDNL
 SET inst_ptr,yz; BYTE 0,1,0,#41  JMP
 SET inst_ptr,yz; BYTE 0,1,0,#41  JMPB
 JMP PushJ+@-O; BYTE 0,1,0,#60  PUSHJ
 JMP PushJ+@-O; BYTE 0,1,0,#60  PUSHJB
 SET x,yz; BYTE 0,1,0,#60  GETA
 SET x,yz; BYTE 0,1,0,#60  GETAB
 JMP Put+@-O; BYTE 0,1,0,#02  PUT
 JMP Put+@-O; BYTE 0,1,0,#01  PUTI
 JMP Pop+@-O; BYTE 0,3,rJ,#00  POP
 JMP Resume+@-O; BYTE 0,5,0,#00  RESUME
 JMP Save+@-O; BYTE 20,1,0,#20  SAVE
 JMP Unsave+@-O; BYTE 20,1,0,#02  UNSAVE
 JMP Sync+@-O; BYTE 0,1,0,#01  SYNC
 SWYM x,y,z; BYTE 0,1,0,#00  SWYM
 JMP Get+@-O; BYTE 0,1,0,#20  GET
 JMP Trip+@-O; BYTE 0,5,0,#0a  TRIP

Done       AND    t,f,X_is_dest_bit   % doubly defined but OK
           BZ     t,1F
XDone      STOU   x,xptr,0
1H         GET    t,rA
           AND    t,t,#ff
           OR     exc,exc,t
           AND    t,exc,U_BIT+X_BIT  Check for trip, \S123
           CMPU   t,t,U_BIT
           PBNZ   t,1F        branch unless underflow is exact
0H    GREG   U_BIT<<8
           AND    t,aa,0B
           BNZ    t,1F        branch if underflow is enabled
           ANDNL  exc,U_BIT   ignore U if exact and not enabled
1H         PBZ    exc,Update
           SRU    t,aa,8
           AND    t,t,exc
           PBZ    t,4F
           SET    xx,0         Initiate a trip, \S124
           SLU    t,t,55
2H         INCL   xx,1
           SLU    t,t,1
           PBNN   t,2B
           SET    t,#100
           SRU    t,t,xx
           ANDN   exc,exc,t
TakeTrip   STOU   inst_ptr,g,8*rW
           SLU    inst_ptr,xx,4
           INCH   inst,#8000
           STOU   inst,g,8*rX
           AND    t,f,Mem_bit
           PBZ    t,1F
           ADDU   y,y,z
           SET    z,x
1H         STOU   y,g,8*rY
           STOU   z,g,8*rZ
           LDOU   t,g,c255
           STOU   t,g,8*rB
           LDOU   t,g,8*rJ
           STOU   t,g,c255
4H         OR     aa,aa,exc
0H    GREG   #0000000800000004  Update the clocks, \S128
Update     MOR    t,f,0B      $2^{32}$mems + oops
           ADDU   cc,cc,t
           ADDU   uu,uu,1
           SUBU   ii,ii,1
AllDone    PBZ    resuming,Fetch
           CMPU   t,op,#F9   RESUME
           CSNZ   resuming,t,0
           JMP    Fetch

OctaArgs   OCTA   Global+8*255,8
Infile     IS     3
Main       LDA    Mem:head,Chunk0
           ADDU   Mem:alloc,Mem:head,Mem:nodesize
           GET    t,rN
           INCL   t,1
           STOU   t,g,8*rN
           LDOU   t,$1,8      argv[1]
           STOU   t,IOArgs
           LDA    t,IOArgs
           TRAP   0,Fopen,Infile
           BN     t,Error
1H         GETA   t,OctaArgs
           TRAP   0,Fread,Infile
           BN     t,9F
           LDOU   loc,g,c255
2H         GETA   t,OctaArgs
           TRAP   0,Fread,Infile
           LDOU   x,g,c255
           BN     t,Error
           SET    arg,loc
           BZ     x,1B
           PUSHJ  res,MemFind
           STOU   x,res,0
           INCL   loc,8
           JMP    2B
9H         TRAP   0,Fclose,Infile
           SUBU   loc,loc,8
           STOU   loc,g,c255  place to UNSAVE
           SUBU   arg,loc,8*13
           PUSHJ  res,MemFind
           LDOU   inst_ptr,res,0   Main
           SET    arg,#90          Get ready to UNSAVE, \S162
           PUSHJ  res,MemFind
           LDTU   x,res,0
           SET    resuming,1       RESUME_AGAIN
           CSNZ   inst_ptr,x,#90
0H    GREG   #FB<<24+255      UNSAVE $255
           STOU   0B,g,8*rX
           SET    gg,c255
           JMP    Fetch

 LOC Global+8*rK; OCTA -1
 LOC Global+8*rT; OCTA #8000000500000000
 LOC Global+8*rTT; OCTA #8000000600000000
 LOC Global+8*rV; OCTA #369c200400000000

           LOC    U_Handler
           ORL    exc,U_BIT
           JMP    Done
