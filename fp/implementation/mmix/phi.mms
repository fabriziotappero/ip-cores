t IS $255
n IS $0
new GREG
old GREG
phi GREG
rt5 GREG
acc GREG
f   GREG
     LOC  #100
Main FLOT t,5
     FSQRT rt5,t
     FLOT t,1
     FADD phi,t,rt5
     INCH phi,#fff0
     FDIV acc,phi,rt5
     SET n,1
     SET new,1
1H   ADDU new,new,old
     INCL n,1
     CMPU t,new,old
     BN   t,9F
     SUBU old,new,old
     FMUL acc,acc,phi
     FIXU f,acc
     CMP  t,f,new
     PBZ  t,1B
     SET  t,1
9H   TRAP 0,Halt,0
