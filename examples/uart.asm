  ldi   h0, 0x02
  ldi	l1, 0x81
  ldi   l0, 0x80
  ldi   l2, 0x00
1:
  ldio  l3, [l0]
  nop
  and   l4, l3, h0
@  stio  l4, [h0]
  brz   l4, :1
  nop
  ldio  l3, [l1]    @ uart rcv
  nop
  nop
  ldi   h2, 1
  add   h2, l3, h2 
  nop
  nop
  nop
  stio  h2, [l1]    @ uart echo
  nop
@  LDL   h6, :12
@  ldi   h7, 0x3F
@  add   h6, h6, h7
@  call  h7, <h6>
  nop
  stio  l3, [l2]    @ leds
  brnz  l4, :1
  nop

12:
  ldi h3, 10
  ldi h2, 0
13:
  cmpl   h1, l3, h3
  brnz   h1, :14
  nop
  sub    l3, l3, h3
  adi    h2, 0x10
  brz    h1, :13
  nop
14:
  jump   <h7>
  add    h2, h2, l3

  stop



