  ldi   l2, 0x80
  lsi   l2, 0xff   @ start of user program
  ldi   h1, 1      @  toggle bit (hi low)

1: @ wait for byte
  ldio  l3, [l0]
  ldi   h0, 2
  and   l4, l3, h0
  brz   l4, :1
  ldi   h0, 0x41


  ldio  l3, [h0]    @ uart rcv
  ldi   h0, 0x40
  stio  l3, [h0]    @ uart echo
  ldi   h0, 0x00
  stio  l3, [h0]    @ leds
  adi   l2, 1
  stio  l3, [l2]
  brnz  l4, :1
  nop




