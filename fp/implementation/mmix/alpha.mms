* The "alpha channel" exercise in section 7.1.3
x     GREG
y     GREG
z     GREG
m     GREG
alpha GREG
t     IS  $255
l     GREG #0101010101010101
h     GREG #8080808080808080
mone  GREG -1
rodd  GREG #4020100804020101
lsh   GREG #0080402010080402

      LOC  #100
Main  XOR  t,x,y
      MOR  z,rodd,t
      AND  t,x,y
      ADDU z,z,t
      AND  t,alpha,h
      MOR  m,mone,t
      PUT  rM,m
      MUX  x,z,x
      MUX  y,y,z
      MOR  alpha,lsh,alpha
      XOR  t,x,y
      MOR  z,t,rodd
      AND  t,x,y
      ADDU z,z,t
      AND  t,alpha,h
      MOR  m,t,mone
      PUT  rM,m
      MUX  x,z,x
      MUX  y,y,z
      MOR  alpha,alpha,lsh
      XOR  t,x,y
      MOR  z,t,rodd
      AND  t,x,y
      ADDU z,z,t
      AND  t,alpha,h
      MOR  m,t,mone
      PUT  rM,m
      MUX  x,z,x
      MUX  y,y,z
      MOR  alpha,alpha,lsh
      XOR  t,x,y
      MOR  z,t,rodd
      AND  t,x,y
      ADDU z,z,t
      AND  t,alpha,h
      MOR  m,t,mone
      PUT  rM,m
      MUX  x,z,x
      MUX  y,y,z
      MOR  alpha,alpha,lsh
      XOR  t,x,y
      MOR  z,t,rodd
      AND  t,x,y
      ADDU z,z,t
      AND  t,alpha,h
      MOR  m,t,mone
      PUT  rM,m
      MUX  x,z,x
      MUX  y,y,z
      MOR  alpha,alpha,lsh
      XOR  t,x,y
      MOR  z,t,rodd
      AND  t,x,y
      ADDU z,z,t
      AND  t,alpha,h
      MOR  m,t,mone
      PUT  rM,m
      MUX  x,z,x
      MUX  y,y,z
      MOR  alpha,alpha,lsh
      XOR  t,x,y
      MOR  z,t,rodd
      AND  t,x,y
      ADDU z,z,t
      AND  t,alpha,h
      MOR  m,t,mone
      PUT  rM,m
      MUX  x,z,x
      MUX  y,y,z
      MOR  alpha,alpha,lsh
      XOR  t,x,y
      MOR  z,t,rodd
      AND  t,x,y
      ADDU z,z,t
      TRAP 0,Halt,0
