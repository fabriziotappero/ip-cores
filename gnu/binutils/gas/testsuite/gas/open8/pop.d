#objdump: -d
#name: Pop Register from Stack

.*: .*

Disassembly of section \.text:

0+ <\.text>:
[ 	]+[0-9a-f]+:[ 	]+88          	pop	r0
[ 	]+[0-9a-f]+:[ 	]+89          	pop	r1
[ 	]+[0-9a-f]+:[ 	]+8a          	pop	r2
[ 	]+[0-9a-f]+:[ 	]+8b          	pop	r3
[ 	]+[0-9a-f]+:[ 	]+8c          	pop	r4
[ 	]+[0-9a-f]+:[ 	]+8d          	pop	r5
[ 	]+[0-9a-f]+:[ 	]+8e          	pop	r6
[ 	]+[0-9a-f]+:[ 	]+8f          	pop	r7
