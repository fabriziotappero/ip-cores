ldi l0, 0
stio l0, [l0]

1:
ldi     h0, 0x1
ldi	l0, 7
10:
ldi   h1, 0        
stio  h0, [h1]     @ leds echo
nop

adi	  l0, -1

ldi	  l1, 0x1f
lsi   l1, 0
lsi   l1, 0
11:
brnz  l1, :11
adi   l1, -1



brnz  l0, :10
shi	  h0, 1

ldi l0, 7
20:
ldi   h1, 0        
stio  h0, [h1]     @ leds echo
nop
adi	  l0, -1

ldi	  l1, 0x1f
lsi   l1, 0
lsi   l1, 0
21:
brnz  l1, :21
adi   l1, -1


brnz  l0, :20
shi	  h0, -1

brz   l0, :1
nop
stop

