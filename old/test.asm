ldi		l7, 0x3
stio		l7, [l7]
ldi		h7, 0x8
ldi		l3, 0x1
lsi		l3, 0
lsi		l3, 0
lsi		l3, 0
1:
  ldi   l1, 0
  stio  h7, [h7]
2:
  cmpl  l0, l1, l3
  brnz	l0, :2
  adi 	l1, 1
  brz   l0, :1
  adi 	h7, 1
  
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop

