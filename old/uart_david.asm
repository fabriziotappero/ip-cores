  ldi   h0, 0x02
  ldi	l1, 0xc1
  ldi   l0, 0xc0
  ldi   l2, 0x00
1:
  ldio  l3, [l0]
  nop
  and   l4, l3, h0
  brz   l4, :1
  nop
  ldio  l3, [l1]    @ uart rcv
  nop
  stio  l3, [l1]    @ uart echo
  nop
  LDL   h6, :12
  ldi   h7, 0x40
  add   h6, h6, h7    @ FFFFFFFIIIIIIXXXXXXXMMMMMMMEEEEEEE: FIXME: add 0x40 offset in assembler
  call  h7, <h6>
  nop
  stio  h2, [l2]    @ leds
  nop
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





