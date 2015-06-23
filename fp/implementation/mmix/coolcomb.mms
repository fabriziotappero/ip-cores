* The "cool-lex" combinations of Ruskey and Williams, ex 7.2.1.3--55(b)
s     IS    4   % the number of 0-bits in each combination
t     IS    3   % the number of 1-bits in each combination; s+t<=8 here
bits  GREG  0
ptr   GREG  0
      LOC   #100
Main  LDA   ptr,Data_Segment  % assemble this with the -x switch!
      SET   bits,(1<<t)-1
1H    PUSHJ $0,Visit
      ADDU  $0,bits,1
      AND   $0,$0,bits
      SUBU  $1,$0,1
      XOR   $1,$1,$0
      ADDU  $0,$1,1
      AND   $1,$1,bits
      AND   $0,$0,bits
      ODIF  $0,$0,1
      SUBU  $1,$1,$0
      ADDU  bits,bits,$1
      SRU   $0,bits,s+t
      PBZ   $0,1B
      TRAP  0,Halt,0           % simulate this with the -I switch!
Visit STBU  bits,ptr,0
      INCL  ptr,1
      POP   0,0

      
