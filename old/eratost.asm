ldi     l7, 10
mov		l5, l7
ldi		l4, 0
ldi     l0, 0
ldi		l1, 1
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
  cmpg  l3, l4, l5
  brnz  l3, :10
  ld    l3, [l4]
  brnz  l3, :4
  nop
  brz   l3, :2
  nop
10:
  ldi	l3, 1
11:
  adi   l3, 1
  cmpl  l4, l3, l7
  brz   l4, :99
  ld	l5, [l3]
  brnz  l5, :11
  nop
  LDL	h0, :22
  call  h7, <h0>   @ 0x23
  mov	l0, l3
  brz 	l5, :11
  nop


@ This is a function:

22:
  ldi   h3, 15
  ldi	h1, 48
  ldi   h2, 10
  shi   h0, l0, -4
  and	l1, h0, h3
  cmpl  h4, l1, h2
  brnz  h4, :23
  nop
  adi   l1, 7
23:
  add	l1, l1, h1
  stio	l1, [l1]
  and	l1, l0, h3
  cmpl  h4, l1, h2
  brnz  h4, :24
  nop
  adi   l1, 7
24:
  add	l1, l1, h1
  stio	l1, [l1]
  ldi	l1, 32
  jump	<h7>
  stio	l1, [l1]
99:
  ldi   l1, 10
  stio  l1, [l1]

