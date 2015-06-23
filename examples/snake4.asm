@ l7: stack
@ l6: push_function
@ l0: return address of leavfuction (push pop im speziell)

  stio l0, [l0]

  LDL l0, :start
  LDL l6, :push

  ldi l7, 0x03
  jump <l0>
  lsi l7, 0xfE


push:
  st  h7, [l7]
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
  st  h0, [l7]
  jump <l0>
  adi l7, -1

pop:
  adi l7, 1
  ld  h0, [l7]
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
  ld  h7, [l7]
  nop
  nop
  jump <h0>
  nop


start:

@ initialize vmem
  LDL   h4, :set_tile
  ldi   l3, 59     @ max y
hloop:
  ldi   l2, 79     @ max x
pixloop:
  call  h0, <h4>
 ldi   l1, 0x5b     

  brnz  l2, :pixloop
  adi   l2, -1
  brnz  l3, :hloop
  adi   l3, -1


@ draw "3D" borders
 ldi h6, 55
 ldi h7, 0xc1
 lsi h7, 0x02
 LDL h3, :border
 call h0, <h3>
 ldi h4, 55
 
 ldi h6, 6
 ldi h7, 0xc1
 lsi h7, 0x3C
 call h0, <h3>
 ldi h4, 17
 
 ldi h7, 0xc5
 call h0, <h3>
 lsi h7, 0x3C 
 
 ldi h7, 0xc9
 call h0, <h3>
 lsi h7, 0x3C 
 
 ldi h7, 0xcd
 call h0, <h3>
 lsi h7, 0x3C
 
 ldi h6, 17
 ldi h7, 0xd4
 call h0, <h3>
 lsi h7, 0x3C
 
@ draw static text
 ldi l0, 0xcA
 lsi l0, 0x44
 ldi l1, 0x57 @ X
 stio l1, [l0]
 ldi l0, 0xcE
 lsi l0, 0x44
 ldi l1, 0x58 @ Y
 stio l1, [l0]

@ LEVEL
 ldi l0, 0xc2
 lsi l0, 0x42
 ldi l1, 0x47 
 stio l1, [l0]
 adi l0, 1
 ldi l1, 0x3c 
 stio l1, [l0]
 adi l0, 1
 ldi l1, 0x55 
 stio l1, [l0]
 adi l0, 1
 ldi l1, 0x3c 
 stio l1, [l0]
 adi l0, 1
 ldi l1, 0x47 
 stio l1, [l0]

@ LEVEL
 ldi l0, 0xc6
 lsi l0, 0x42
 ldi l1, 0x38 
 stio l1, [l0]
 adi l0, 1
 ldi l1, 0x4b 
 stio l1, [l0]
 adi l0, 1 
 stio l1, [l0]
 adi l0, 1
 ldi l1, 0x47 
 stio l1, [l0]
 adi l0, 1
 ldi l1, 0x3c 
 stio l1, [l0]
 adi l0, 1
 ldi l1, 0xec
 stio l1, [l0]



@ Andreas
 ldi l0, 0xD5
 lsi l0, 0x3e
 ldi l1, 0x38 @ A
 stio l1, [l0]
 adi l0, 1
 ldi l1, 0x49
 stio l1, [l0]
 adi l0, 1
 ldi l1, 0x3b
 stio l1, [l0]
  adi l0, 1
 ldi l1, 0x4d
 stio l1, [l0]
  adi l0, 1
 ldi l1, 0x3c
 stio l1, [l0]
  adi l0, 1
 ldi l1, 0x38
 stio l1, [l0] 
  adi l0, 1
 ldi l1, 0x4e
 stio l1, [l0] 


@ David
 ldi l0, 0xD8
 lsi l0, 0x3e
 ldi l1, 0x3B @ D
 stio l1, [l0]
 adi l0, 1
 ldi l1, 0x38
 stio l1, [l0]
 adi l0, 1
 ldi l1, 0x55
 stio l1, [l0]
  adi l0, 1
 ldi l1, 0x44
 stio l1, [l0]
  adi l0, 1
 ldi l1, 0x3b
 stio l1, [l0]

@ Fellnhofer
 ldi l0, 0xD5
 lsi l0, 0xc1
 ldi l1, 0x3D 
 stio l1, [l0]
 adi l0, 1
 ldi l1, 0x3c
 stio l1, [l0]
 adi l0, 1
 ldi l1, 0x47
 stio l1, [l0]
  adi l0, 1
 stio l1, [l0]
  adi l0, 1
 ldi l1, 0x49
 stio l1, [l0]
  adi l0, 1
 ldi l1, 0x3f
 stio l1, [l0] 
  adi l0, 1
 ldi l1, 0x4a
 stio l1, [l0] 
  adi l0, 1
 ldi l1, 0x3d
 stio l1, [l0] 
  adi l0, 1
 ldi l1, 0x3c
 stio l1, [l0] 
  adi l0, 1
 ldi l1, 0x4d
 stio l1, [l0] 

@ Rigler
 ldi l0, 0xD8
 lsi l0, 0xc1
 ldi l1, 0x4d
 stio l1, [l0]
 adi l0, 1
 ldi l1, 0x44
 stio l1, [l0]
 adi l0, 1
 ldi l1, 0x3e
 stio l1, [l0]
  adi l0, 1
 ldi l1, 0x47
 stio l1, [l0] 
  adi l0, 1
 ldi l1, 0x3c
 stio l1, [l0] 
  adi l0, 1
 ldi l1, 0x4d
 stio l1, [l0] 

@ &
 ldi l0, 0xD7
 lsi l0, 0x44
 ldi l1, 0x5c
 stio l1, [l0]


@ Diogenes
 ldi l0, 0xDB
 lsi l0, 0x3e
 ldi l1, 0x3b 
 stio l1, [l0]
 adi l0, 1
 ldi l1, 0x44
 stio l1, [l0]
 adi l0, 1
 ldi l1, 0x4a
 stio l1, [l0]
  adi l0, 1
 ldi l1, 0x3e
 stio l1, [l0]
  adi l0, 1
 ldi l1, 0x3c
 stio l1, [l0]
  adi l0, 1
 ldi l1, 0x49
 stio l1, [l0] 
  adi l0, 1
 ldi l1, 0x3c
 stio l1, [l0] 
  adi l0, 1
 ldi l1, 0x4e
 stio l1, [l0] 
 adi l0, 2
 ldi l1, 0x66
 stio l1, [l0] 
  adi l0, 1
   ldi l1, 0x64
 stio l1, [l0] 
  adi l0, 1
   ldi l1, 0x64
 stio l1, [l0] 
  adi l0, 1
   ldi l1, 0x6c
 stio l1, [l0] 
  adi l0, 1



@ initialize snake
  ldi   h3, 0x10
  lsi   h3, 0x10
  ldi   h1, 8

  @ first apple
  ldi   h6, 16
  lsi   h6, 40

  @ intitially nothing to grow
  ldi   h7, 0

l0:
  st    h3, [h1]
  brnz  h1, :l0
  adi   h1, -1

  ldi   h1, 8     @ head != tail to avoid early gameover
  adi   h3, 1
  st    h3, [h1]

  ldi   h1, 7
  ldi   h2, 0

  LDL   h3, :delay
  LDL   h5, :update

  ldi   l0, 0x00       @ loop expects key input in r0
loop:
  @ldi   l0, 0x00        @simulator: 0x81
  @ldio  l0, [l0]
  ldi   l1, 0x01
  and   l2, l0, l1     @ select bit for right
  sub   h2, h2, l2     @ add bit to direction
  shi   l0, -1         @ shift input
  and   l2, l0, l1
  add   h2, h2, l2     @ add bit to direction
 
  stio  h2, [l0]

  @shi   l0, -6         @ shift input
  @and   h4, l0, l1


@ check for game over
  adi  l1, h1, 1
  ld   l1, [l1]
  ldi   l0, 0xff
  lsi   l0, 0xff  
  and  l1, l1, l0
  mov  l2, h1
  adi  l2, -2

collcheck:
  ld   l4, [l2]
  nop
  and  l4, l4, l0
  xor  l4, l4, l1
  brnz l4, :nocoll
  nop

@ GAME OVER
 ldi l0, 0xce
 lsi l0, 0x19
 ldi l1, 0x3e 
 stio l1, [l0]
 adi l0, 1
 ldi l1, 0x38
 stio l1, [l0]
 adi l0, 1
 ldi l1, 0x48
 stio l1, [l0]
  adi l0, 1
 ldi l1, 0x3c
 stio l1, [l0]
  adi l0, 2
 ldi l1, 0x4a
 stio l1, [l0] 
  adi l0, 1
 ldi l1, 0x55
 stio l1, [l0] 
  adi l0, 1
 ldi l1, 0x3c
 stio l1, [l0] 
 adi l0, 1
 ldi l1, 0x4d
 stio l1, [l0] 


no_key_pressed:
 call  h0, <h3>       @ call delay
 ldi   l1, 30
 brz   l0, :no_key_pressed
 nop 

 LDL   l0, :start
 jump  <l0>
 nop

nocoll:
  brnz l2, :collcheck
  adi  l2, -1




@ check for apple 
  adi   l1, h1, 1
  ld    l1, [l1]
  ldi   l0, 0xff
  lsi   l0, 0xff
  xor   l1, l1, h6  
  and   l1, l1, l0
  brnz  l1, :no_apple
  nop
  adi   h7, 8       @ grow by 8 for each apple


  @ FIXME: use random values 
  ldi   l4, 53
  add   l0, h6, l4      
  shi   h0, l0, -2
  add   l0, l0, h1

rand1:
  sub   l0, l0, l4
  cmpl  l1, l0, l4
  brz   l1, :rand1
  nop

rand2:
  sub   h0, h0, l4
  cmpl  l1, h0, l4
  brz   l1, :rand2
  nop

  adi   h0, 3
  adi   l0, 3

  mov   h6, l0
  shi   h6, 8
  or    h6, h6, h0     


no_apple:
  ldi   l0, 0
  cmpl  h4, l0, h7
  sub   h7, h7, h4  


@ draw apple
  ldi l0, 0xff
  and l2, h6, l0
  mov l3, h6
  shi l3, -8
  LDL l0, :set_tile
  call h0, <l0>
  ldi l1, 0x06   @ apple


  @@ display level, apples
  LDL   l0, :print_val
  ldi l4, 0xc7
  mov l5, h1
  shi l5, -3
  call  h0, <l0>
  lsi l4, 0x43

  LDL   l0, :print_val
  ldi l4, 0xc3
  mov l5, h1
  shi l5, -6
  call  h0, <l0>
  lsi l4, 0x43




  call h0, <h5>        @ call update
  mov  l1, h2

  add   h1, h1, h4

  ldi   l1, 10         @ 2^20 steps
  mov   l2, h1
  shi   l2, -6
  shi   l2, 2
  call  h0, <h3>       @ call delay
  sub   l1, l1, l2



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
  nop
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
  ldi   l1, 0x1b

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

  @ check for borders and wrap around
  ldi h0, 3
  cmpl l5, l2, h0
  brz l5, :b2
  nop
  ldi l2, 56
b2:
  cmpl l5, l3, h0
  brz l5, :b3
  nop
  ldi l3, 56
b3:
  ldi h0, 56
  cmpl l5, h0, l2
  brz l5, :b4
  nop
  ldi l2, 3
b4:
  cmpl l5, h0, l3
  brz l5, :bend
  nop
  ldi l3, 3
bend:

  mov   l4, h2
  shi   l4, 8
  or    l4, l4, l3
  shi   l4, 8
  or    l4, l4, l2
  st    l4, [l0]       @ write new head
  
  @@ keep x,y values
  mov   h2, l2
  mov   h3, l3
 
  LDL   l0, :set_tile
  call  h0, <l0>
  nop

  @@ display x,y values
  LDL   h4, :print_val

  ldi l4, 0xcb
  mov l5, h2
  adi l5, -3
  call  h0, <h4>
  lsi l4, 0x43

  ldi l4, 0xcf
  mov l5, h3
  adi l5, -3
  call  h0, <h4>
  lsi l4, 0x43



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
  mov   l2, l1
  shi   l2, 16
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
  brnz  l4, :goon2
  adi   l4, -1
  mov   l0, l3
goon:
  ldi   l4, 0xff
  shi   l4, 10
goon2:
  brnz  l2, :delay_loop
  adi   l2, -1
  adi  h6, l6, 17
  jump <h6>
  nop
     
print_val:
  call l0, <l6>
  nop

ldi h1, 100
pre_loop:
ldi h0, 0x63
add l5,l5,h1
count_loop:
sub l5,l5,h1
cmpl l0, l5, h1
brz l0, :count_loop
adi h0, 1
stio h0, [l4]
adi l4, 1
ldi l0, 10
xor l0,l0,h1
brnz l0, :pre_loop
ldi h1, 10
ldi h0, 0x64
add h0, h0, l5
stio h0, [l4]
 
 
  adi  h6, l6, 17
  jump <h6>
  nop
       
border:
  call l0, <l6> 
  nop

  shi   h6, 7
  ldi   h5, 0x17
 fory:
   mov  l4, h4
   adi l5, h5, 2
 forx:
   add l3, h7, l4
   add l3,l3, h6
   stio  l5, [l3]
   adi l5, h5, 1
   brnz l4, :forx
   adi l4, -1
   stio h5, [l3]
   ldi l0,0x1d
   xor l0, l0, h5
   brz l0, :end_border
  ldi h5, 0x1a
  ldi l0, 0x80
  sub h6,h6,l0
  brnz h6, :fory
  nop
  brnz l0, :fory
  ldi h5, 0x1d
  
end_border:
  adi  h6, l6, 17
  jump <h6>
  nop


stop

