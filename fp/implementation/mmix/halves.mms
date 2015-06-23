% Example program ... 2^-n in decimal
%
       LOC #2000000000000000 % Data segment
HALF   BYTE '5'
       LOC  @+'0'-1
       BYTE "0011223344"     % Table of half-digits
DATA   BYTE '1',0
%
       GREGTOP $g250
pbase  GREG DATA-1
half   GREG HALF
p      GREG 0
starp  GREG 0
carry  GREG 0
acc    GREG 0
       LOC  #1000
Main   OR   p,pbase,0        % p = &DATA-1.
       SETL carry,0          % carry = 0.
       JMP  1F
Loop   ADD  acc,acc,carry    % acc += carry.
       ZSOD carry,starp,5    % carry = 5[*p odd].
       STB  acc,p,0          % *p = acc.
1H     LDB  starp,p,1
       INCL p,1              % p++.
       LDB  acc,half,starp  % acc = half[*p].
       PBNZ starp,Loop       % repeat until *p='\0'.
       STB  acc,p,0          % *p = '5'.
       JMP  Main             % repeat indefinitely.

