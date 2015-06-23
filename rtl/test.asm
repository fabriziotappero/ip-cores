;addi r1,r0,0xaaaaaaaa
addi r1,r0,0xffffffff
swi r1,r0,0
bri -4
or r0,r0,r0
