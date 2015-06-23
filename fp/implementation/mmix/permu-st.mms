* Permutation generator for n=6 using sigma-tau transforms only
t     IS   $255
magic GREG #8844221188442211
a     GREG 0
p     GREG 0
c     GREG 0
x     GREG #f000000

      LOC  #100
      GREG @
Magic OCTA #7df76fbb7df6ebe8,#f7dd5dafbedbedd0,#5f5df7ddadd5dbc0
*      (that was $\alpha\sigma\beta$)
      OCTA #5f7dd5dbeddf5f70,#6b7576fbefbbedf0,#6eafaeefbebedd70
*      (that was $\tau\gamma\sigma$)
      OCTA #6fbeeaedf6efafb0,#b5babb7df7ddf6f0,#b757d777df5f6eb0
*      (that was $\tau\sigma$\gamma)
      OCTA #77db7dbabebbefb0,#b5babb7df7ddbee8,#befb75f7df7576b0
*      (that was $\tau\beta\sigma\alpha\sigma$)
      OCTA 0
%Main  SETML a,#12
%      INCL  a,#3456
Main  SETML a,#02
      INCL  a,#3415
      LDA   p,Magic
      JMP   3F
0H    OR    $0,a,x    (trace this)
      PBN   c,Sigma
Tau   MXOR  t,magic,a
      ANDNL t,#ffff
      JMP   1F
Sigma SRU   t,a,20
      SLU   a,a,4
      ANDNML a,#f00
1H    XOR   a,a,t
      SLU   c,c,1
2H    PBNZ  c,0B
      INCL  p,8
3H    LDOU  c,p,0
      PBNZ  c,0B
