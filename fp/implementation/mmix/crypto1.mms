* Cryptanalysis Problem (CLASSIFIED) (pipelined)
a GREG
b GREG
bb GREG
c GREG
t GREG
x GREG
y GREG
       LOC Data_Segment
freq   GREG @           Base address for byte counts
       LOC @+8*(1<<8)   Space for the byte frequencies
p      GREG @
       BYTE "abracadabraa",0,"abc" Trivial test data
ones   GREG #0101010101010101
       LOC  #100
Start  LDOU a,p,0
       INCL p,8
       BDIF t,ones,a
       BNZ  t,3F        Do main loop, unless near the end.
2H     SRU  b,a,53
       LDO  c,freq,b   Load old count.
       SLU  bb,a,8
       INCL c,1
       SRU  bb,bb,53
       STO  c,freq,b   Store new count.
       LDO  c,freq,bb
       SLU  b,a,16
       INCL c,1
       SRU  b,b,53
       STO  c,freq,bb
       LDO  c,freq,b   Load old count.
       SLU  bb,a,24
       INCL c,1
       SRU  bb,bb,53
       STO  c,freq,b   Store new count.
       LDO  c,freq,bb
       SLU  b,a,32
       INCL c,1
       SRU  b,b,53
       STO  c,freq,bb
       LDO  c,freq,b   Load old count.
       SLU  bb,a,40
       INCL c,1
       SRU  bb,bb,53
       STO  c,freq,b   Store new count.
       LDO  c,freq,bb
       SLU  b,a,48
       INCL c,1
       SRU  b,b,53
       STO  c,freq,bb
       LDO  c,freq,b   Load old count.
       SLU  bb,a,56
       INCL c,1
       SRU  bb,bb,53
       STO  c,freq,b   Store new count.
       LDO  c,freq,bb
       LDOU a,p,0
       INCL p,8
       INCL c,1
       BDIF t,ones,a
       STO  c,freq,bb
       PBZ  t,2B        Do main loop, unless near the end.
3H     SRU  b,a,53
       LDO  c,freq,b   Load old count.
       INCL c,1
       STO  c,freq,b   Store new count.
       SRU  b,b,3
       SLU  a,a,8
       PBNZ b,3B        Continue unless done.
       POP

Main   IS   Start

