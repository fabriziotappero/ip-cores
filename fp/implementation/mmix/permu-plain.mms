* Permutation generator a la plain-changes (mockup only)
t IS $255
a GREG 0
p GREG 0
c GREG 0
fmask GREG #f
magic GREG #8844221188442211
ffmask GREG #ff000000
u IS $0
    LOC  #100
    GREG @
T   OCTA #194cb4594cb4594c,#b44,0
Main SET a,#1234
    SLU a,a,12 [needed to make the MXOR stuff work]
    LDA p,T
    JMP 3F

1H  SRU u,a,12  (trace this)

%    SLU u,fmask,t
%    SLU t,a,4
%    XOR t,t,a
%    AND t,t,u
%    SRU u,t,4
%    OR  t,t,u
%    XOR a,a,t
    SLU  u,a,t
    MXOR u,magic,u
    AND  u,u,ffmask
    SRU  u,u,t
    XOR  a,a,u

    SRU c,c,3
2H  AND t,c,#1c
    PBNZ t,1B
    ADD  p,p,8
3H  LDO  c,p,0
    PBNZ c,2B
    TRAP 0,Halt,0

