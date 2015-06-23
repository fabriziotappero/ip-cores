* Coroutine example for 1.4.2
t        IS    $255
in       GREG
out      GREG

* Input and output buffers
         LOC  Data_Segment
         GREG  @
OutBuf   TETRA "               ",#a,0
Period   BYTE  '.'
InArgs   OCTA  InBuf,1000
InBuf    LOC   #100

* Subroutine for character input
inptr    GREG
1H       LDA   t,InArgs
         TRAP  0,Fgets,StdIn
         LDA   inptr,InBuf
0H       GREG  Period
         CSN   inptr,t,0B
NextChar LDBU  $0,inptr,0
         INCL  inptr,1
         BZ    $0,1B
         CMPU  t,$0,' '
         BNP   t,NextChar
         POP   1,0

* First coroutine
count    GREG
1H       GO    in,out,0
In1      PUSHJ $0,NextChar
         CMPU  t,$0,'9'
         PBP   t,1B
         SUB   count,$0,'0'
         BN    count,1B
         PUSHJ $0,NextChar
1H       GO    in,out,0
         SUB   count,count,1
         PBNN  count,1B
         JMP   In1

* Second coroutine
outptr   GREG
1H       LDA   t,OutBuf
         TRAP  0,Fputs,StdOut
Out1     LDA   outptr,OutBuf
2H       GO    out,in,0
         STBU  $0,outptr,0
         CMP   t,$0,'.'
         BZ    t,1F
         GO    out,in,0
         STBU  $0,outptr,1
         CMP   t,$0,'.'
         BZ    t,2F
         GO    out,in,0
         STBU  $0,outptr,2
         CMP   t,$0,'.'
         BZ    t,3F
         INCL  outptr,4
0H       GREG  OutBuf+4*16
         CMP   t,outptr,0B
         PBNZ  t,2B
         JMP   1B
3H       INCL  outptr,1
2H       INCL  outptr,1
0H       GREG  #a
1H       STBU  0B,outptr,1
0H       GREG  0
         STBU  0B,outptr,2
         LDA   t,OutBuf
         TRAP  0,Fputs,StdOut
         TRAP  0,Halt,0

* Initialization
Main     LDA   inptr,InBuf
         GETA  in,In1
         JMP   Out1         
