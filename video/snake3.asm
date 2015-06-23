@ l7: stack
@ l6: push_function
@ l0: return address of leavfuction (push pop im speziell)

  stio l0, [l0]

  LDL l0, :start
  LDL l6, :push

  ldi l7, 0x03
  jump <l0>
  lsi l7, 0xff


push:
  st  h0, [l7]
  adi l7, -1
  st  h1, [l7]
  adi l7, -1
  st  h2, [l7]
  adi l7, -1
  st  h3, [l7]
  adi l7, -1
  st  h4, [l7]
  adi l7, -1
  st  h5, [l7]
  adi l7, -1
  st  h6, [l7]
  adi l7, -1
  st  h7, [l7]
  jump <l0>
  adi l7, -1

pop:
  adi l7, 1
  ld  h7, [l7]
  adi l7, 1
  ld  h6, [l7]
  adi l7, 1
  ld  h5, [l7]
  adi l7, 1
  ld  h4, [l7]
  adi l7, 1
  ld  h3, [l7]
  adi l7, 1
  ld  h2, [l7]
  adi l7, 1
  ld  h1, [l7]
  adi l7, 1
  ld  h0, [l7]
  nop
  nop
  jump <h0>
  nop


start:

@ initialize snake
  ldi   h1, 8
l0:
  st    h1, [h1]
  brnz  h1, :l0
  adi   h1, -1

  ldi   h1, 4
  ldi   h2, 0


@ initialize vmem
  LDL   h4, :set_tile
  ldi   l3, 59     @ max y
hloop:
  ldi   l2, 79     @ max x
pixloop:
  call  h0, <h4>
  ldi   l1, 0x6b     @ white=0x7f  (black = 6b)

  brnz  l2, :pixloop
  adi   l2, -1
  brnz  l3, :hloop
  adi   l3, -1

  LDL   h3, :delay
  LDL   h5, :update
loop:
  call  h0, <h3>       @ call delay
  ldi   l1, 20         @ 2^20 steps

  ldi   l1, 0x01
  and   l2, l0, l1     @ select bit for right
  sub   h2, h2, l2     @ add bit to direction
  shi   l0, -1         @ shift input
  and   l2, l0, l1
  add   h2, h2, l2     @ add bit to direction
  stio  h2, [l0]

  shi   l0, -6         @ shift input
  and   h4, l0, l1

  call h0, <h5>        @ call update
  mov  l1, h2

  add   h1, h1, h4

  brnz  h5, :loop
  nop


update:
  call l0, <l6>
  nop

  brz   h4, :no_grow    @ if snake does not grow
  mov   l0, h1
  adi   l0, 2
  adi   h1, 1
  ld    l1, [h1]        @ if snake grows
  brnz  h4, :cloope
  mov   l2, h1

no_grow:
  ldi   l0, 0
  ld    l1, [l0]

  @ extract tile,y,x  (l1=tile, l2=x, l3=y)
  ldi   l4, 0xff
  and   l2, l1, l4
  shi   l1, -8
  and   l3, l1, l4
  ldi   l1, 0x6b

  LDL   l0, :set_tile
  call  h0, <l0>
  nop

  ldi   l0, 0
  ldi   l2, 1

cloop:
  ld    l1, [l2]      @ src
  adi   l2, 1         @ src + 1
  st    l1, [l0]      @ dst
  cmpl  l3, l0, h1    @ until dst=highest address)
  brnz  l3, :cloop
  adi   l0, 1         @ dst + 1
cloope:
  
  ldi   l5, 3
  and   h2, h2, l5    @ trunc direction

  @ extract tile,y,x  (l1=tile, l2=x, l3=y)
  ldi   l4, 0xff
  and   l2, l1, l4
  shi   l1, -8
  and   l3, l1, l4
  
  shi   l1, -8        @ old direction
  shi   l1, 4         @ old direction << 2
  or    l1, l1, h2    @  00OO 00NN (old new combination)
  adi   l1, 4

  mov   h5, l0
  mov   h6, l2
  mov   h7, l3

  LDL   l4, :set_tile
  call  h0, <l4>
  nop
  mov   l0, h5
  mov   l2, h6
  mov   l3, h7

down:
  xor   l4, h2, l5
  brnz  l4, :up
  nop
  adi   l3, 1
  ldi   l1, 8
up:
  ldi   l5, 1
  xor   l4, h2, l5
  brnz  l4, :right
  nop
  adi   l3, -1
  ldi   l1, 9
right:
  brnz  h2, :left
  ldi   l5, 2
  adi   l2, 1
  ldi   l1, 10
left:
  xor   l4, h2, l5
  brnz  l4, :end_key
  nop
  adi   l2, -1
  ldi   l1, 11
end_key:

  mov   l4, h2
  shi   l4, 8
  or    l4, l4, l3
  shi   l4, 8
  or    l4, l4, l2
  st    l4, [l0]       @ write new head

  LDL   l0, :set_tile
  call  h0, <l0>
  nop

  ldi   l0, 0
  ld    l1, [l0]
  @ extract tail tile,y,x  (l1=tile, l2=x, l3=y)
  ldi   l4, 0xff
  and   l2, l1, l4
  shi   l1, -8
  and   l3, l1, l4
  ldi   l0, 1
  ld    l1, [l0]
  nop
  shi   l1, -16        @ old direction
  adi   l1, 0x0c

  LDL   l0, :set_tile
  call  h0, <l0>
  nop

  adi  h6, l6, 17
  jump <h6>
  nop


set_stile:
  call l0, <l6>
  nop

  ldi  l0, 0xff
  and  l2, l1, l0
  shi  l1, -8
  and  l3, l1, l0

  LDL  h4, :set_tile
  call h0, <h4>
  shi  l1, -8

  adi  h6, l6, 17
  jump <h6>
  nop


set_tile:
  call l0, <l6>
  nop

  ldi   l4, 0xc0   @ vmem starts at 0xc000
  shi   l4, 8

  shi   h3, l3, 7
  add   l0, l2, h3
  add   l0, l0, l4
  stio  l1, [l0]

  adi  h6, l6, 17
  jump <h6>
  nop

delay:
  call l0, <l6>
  nop
  ldi   l2, 1
  sh    l2, l2, l1
  ldi   l4, 0xff
  shi   l4, 10
  ldi   l1, 0
  ldi   l0, 0
delay_loop:
  ldio  l3, [l1]
  ldi   l5, 0x0B              @ filter left, right, switch
  and   l3, l3, l5
  brz   l3, :goon
  nop
  brnz  l4, :goon
  adi   l4, -1
  mov   l0, l3
goon:
  brnz  l2, :delay_loop
  adi   l2, -1

  adi  h6, l6, 17
  jump <h6>
  nop


stop

