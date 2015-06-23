@ l2 : current address for memwrites
@ h1 : remaining bytes to write
begin:
  ldi   l2, 0xc0
  lsi   l2, 0x00     @ address of vram

  ldi   h1, 0x01
  shi   h1, 13       @ vram is 8192 byte

1: @ wait for byte
  ldi   l0, 0x80     @ uart status address
  ldio  l3, [l0]
  ldi   h0, 2        @ uart data ready bit
  and   l4, l3, h0
  brz   l4, :1
  ldi   h0, 0x81     @ uart data address

  ldio  l3, [h0]     @ uart rcv
  nop

  stio  l3, [l2]     @ write instruction to program-mem
  
  adi   h1, -1	
  brnz  h1, :1
  adi   l2, 1
  brz   h1, :begin
  nop
@@ vram loaded
  stop



