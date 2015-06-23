* Cryptanalysis Problem (CLASSIFIED)
a GREG
b GREG
c GREG
t GREG
x GREG
y GREG
       LOC Data_Segment
count  GREG @           Base address for wyde counts
       LOC @+8*(1<<16)  Space for the wyde frequencies
freq   GREG @           Base address for byte counts
       LOC @+8*(1<<8)   Space for the byte frequencies
p      GREG @
       BYTE "abracadabraa",0,"abc" Trivial test data
ones   GREG #0101010101010101
       LOC  #100
2H     SRU  b,a,45      Isolate next wyde.
       LDO  c,count,b   Load old count.
       INCL c,1
       STO  c,count,b   Store new count.
       SLU  a,a,16      Delete one wyde.
       PBNZ a,2B        Done with octabyte? \bracetext...
Phase1 LDOU a,p,0       Start here: Fetch the next eight bytes.
       INCL p,8
       BDIF t,ones,a    Test if there's a zero byte.
       PBZ  t,2B        Do main loop, unless near the end.
2H     SRU  b,a,45      Isolate next wyde.
       LDO  c,count,b   Load old count.
       INCL c,1
       STO  c,count,b   Store new count.
       SRU  b,t,48
       SLU  a,a,16
       BDIF t,ones,a
       PBZ  b,2B        Continue unless done.
Phase2 SET  p,8*255     1
1H     SL   a,p,8       255
       LDA  a,count,a   255      $\.a\gets{}$address of row \.p
       SET  b,8*255     255
       LDO  c,a,0       255
       SET  t,p         255
2H     INCL t,#800      255*255
       LDO  x,count,t   255*255  Element of column \.p
       LDO  y,a,b       255*255  Element of row \.p
       ADD  c,c,x       255*255
       ADD  c,c,y       255*255
       SUB  b,b,8       255*255
       PBP  b,2B        255*255
       STO  c,freq,p    255
       SUB  p,p,8       255
       PBP  p,1B        255
       POP

Main   IS   Phase1

