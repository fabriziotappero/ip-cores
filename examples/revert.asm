  ldi   h0, 0x02
  ldi   h1, 0x01
  ldi	l1, 0x81
  ldi   l0, 0x80
  ldi   l2, 0x00
  ldi   h4, 0x00    @ memory address
1:
  ldio  l3, [l0]
  nop
  and   l4, l3, h0
  brz   l4, :1
  nop
  ldio  l3, [l1]    @ uart rcv
  nop
  nop
  st    l3, [h4]
  ldi   h2, 13
  sub   h2, h2, l3
  brz   h2, :print_back
  nop
  adi   h4, 1
  stio  l3, [l1]   @ uart echo
  nop
  nop
  brnz  h2, :1
  nop

print_back:
  brz   h4, :2
  nop
  adi   h4, -1
2:
  ldio  l3, [l0]
  nop
  and   l4, l3, h1
  brz   l4, :2
  nop
  ld    l3, [h4]
  nop
  stio  l3, [l1]    @ uart send
  nop
  nop
  brnz  h4, :print_back
  nop
3:
  brz   h2, :1
  nop
  stop



