begin:
  @ set all 0
  ldi   l0, 0
  ldi   l3, 0xc0    @ RS
  stio  l0, [l3]
  nop
  ldi   l3, 0xd0    @ RW
  stio  l0, [l3]
  nop
  ldi   l3, 0xe0    @ E
  stio  l0, [l3]
  nop
  ldi   l3, 0xf0    @ DATA
  stio  l0, [l3]
  nop

  LDL   h3, :wr_cmd
  call  h4, <h3>
  ldi   l0, 0x33    @ enable 4Bit Mode

  LDL   h6, :wr_data
  call  h7, <h6>
  ldi   l0, 0x02

  LDL   h3, :wr_cmd
  call  h4, <h3>
  ldi   l0, 0x28    @ 2line
  call  h4, <h3>
  ldi   l0, 0x0c    @ disp on
  call  h4, <h3>
  ldi   l0, 0x01    @ clear

  ldi   l0, 1       @ set RS = 1
  ldi   l1, 0xc0
  stio  l0, [l1]

  call  h4, <h3>
  ldi   l0, 32
  call  h4, <h3>
  ldi   l0, 32
  call  h4, <h3>
  ldi   l0, 65 
  call  h4, <h3>
  ldi   l0, 78 
  call  h4, <h3>
  ldi   l0, 68 
  call  h4, <h3>
  ldi   l0, 73
  call  h4, <h3>
  ldi   l0, 32
  call  h4, <h3>
  ldi   l0, 38
  call  h4, <h3>
  ldi   l0, 32
  call  h4, <h3>
  ldi   l0, 68
  call  h4, <h3>
  ldi   l0, 65
  call  h4, <h3>
  ldi   l0, 86
  call  h4, <h3>
  ldi   l0, 73
  call  h4, <h3>
  ldi   l0, 68

  brnz  h4, :end    
  nop

wait_ms:
  shi   l1, 7
wait_us:
  shi   l1, 6
lo0:
  brnz  l1, :lo0
  adi   l1, -1 
  jump  <h5>
  nop

wr_cmd:
  or    l4, l0, l0
  LDL   h6, :wr_data
  shi   l0, -4
  call  h7, <h6>
  nop
  ldi   l0, 0x0f
  and   l0, l0, l4
  call  h7, <h6>
  nop
  jump  <h4>
  nop

wr_data:
  LDL   h5, :wait_ms
  call  h5, <h5>
  ldi   l1, 150

  ldi   l1, 0xf0    @ DATA
  stio  l0, [l1]
  ldi   l1, 0xe0    @ E
  ldi   l0, 0x1
  stio  l0, [l1]

  LDL   h5, :wait_us
  call  h5, <h5>
  ldi   l1, 250

  ldi   l1, 0xe0    @ E
  ldi   l0, 0x0
  stio  l0, [l1]
  jump  <h7>
  nop

end:
  stop



