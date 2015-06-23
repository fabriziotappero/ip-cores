ldi l0, 0
stio l0, [l0]

1:
ldi     h0, 0x1
ldi	l0, 7
10:
ldi   h1, 0        
ldio  h0, [h1]
nop
stio  h0, [h1]     @ leds echo
nop

brz   h1, :1
nop
stop

