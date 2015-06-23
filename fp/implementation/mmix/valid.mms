      LOC   4
      LDVTS $0,$0,0
      LOC   #100
Main  SET   $1,4
      PUSHJ 0,InstTest
      JMP   Main

a IS #ffffffff  % table entry when anything goes
b IS #ffff04ff  % table entry when Y <= ROUND_NEAR
c IS #001f00ff  % table entry for PUT and PUTI
d IS #ff000000  % table entry for RESUME
e IS #ffff0000  % table entry for SAVE
f IS #ff0000ff  % table entry for UNSAVE
g IS #ff000003  % table entry for SYNC
h IS #ffff001f  % table entry for GET
table GREG @
      TETRA a,a,a,a,a,b,a,b,b,b,b,b,b,b,b,b % 0x
      TETRA a,a,a,a,a,b,a,b,a,a,a,a,a,a,a,a % 1x
      TETRA a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a % 2x
      TETRA a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a % 3x
      TETRA a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a % 4x
      TETRA a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a % 5x
      TETRA a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a % 6x
      TETRA a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a % 7x
      TETRA a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a % 8x
      TETRA a,a,a,a,a,a,a,a,0,0,a,a,a,a,a,a % 9x
      TETRA a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a % Ax
      TETRA a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a % Bx
      TETRA a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a % Cx
      TETRA a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a % Dx
      TETRA a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a % Ex
      TETRA a,a,a,a,a,a,c,c,a,d,e,f,g,a,h,a % Fx
tetra    IS $1
maxXYZ   IS $2
InstTest BN     $0,9F
         LDTU   tetra,$0,0
         SR     $0,tetra,22
         LDT    maxXYZ,table,$0
         BDIF   $0,tetra,maxXYZ
         PBNP   maxXYZ,9F
         ANDNML $0,#ff00
         BNZ    $0,9F
         MOR    tetra,tetra,#4
         CMP    $0,tetra,18
         CSP    tetra,$0,0
         ODIF   $0,tetra,7
9H       POP    1,0
