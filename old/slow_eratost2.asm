ldi     l7, 30 
mov	l5, l7
stio	l5, [l5]
ldi	l4, 0
ldi	l0, 0
ldi	l1, 1
1:
  st    l0, [l4]
  adi   l4, 1
  brnz 	l5, :1
  adi	l5, -1
  ldi   l4, 2
  mov   l5, l7
2:
  mov   l2, l4
3:
  add   l2, l2, l4
  cmpl  l6, l2, l5
  brz   l6, :4
  nop
  brnz  l6, :3
  st	l1, [l2]
4:
  adi   l4, 1
  nop
  cmpl  l3, l5, l4
  brnz  l3, :10
  ld    l3, [l4]
  nop
  brnz  l3, :4
  nop
  brz   l3, :2
  nop
10:
  ldi	l3, 1
@  stio  l3, [l3]
11:
  adi   l3, 1
  cmpl  l4, l3, l7
  brz   l4, :99
  ld	l5, [l3]
  nop
  brnz  l5, :11
  nop
  nop
  ldi   h4, 0x1
  lsi   h4, 0
  lsi   h4, 0
@  lsi   h4, 0
  ldi   h1, 0
@  LDL   h5, :40
@  call	h6, <h5>
  stio  l3, [l0]
  lsi   h4, 0
32:
  cmpl  h0, h1, h4
  brnz  h0, :32
  adi   h1, 1
  brz   h0, :11
  nop
99:
  brnz  l1, :99
  nop
  nop
  nop
  nop
  nop
  nop
40:
@  shi   h3, l3, -1
  stio  l3, [l0]
  nop
  jump  <h6>
  nop
  nop
  nop
  stop

