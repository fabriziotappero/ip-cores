#objdump: -d
#name: Push Register to Stack

.*: .*

Disassembly of section \.text:

0+ <\.text>:
[ 	]+[0-9a-f]+:[ 	]+80          	psh	r0
[ 	]+[0-9a-f]+:[ 	]+81          	psh	r1
[ 	]+[0-9a-f]+:[ 	]+82          	psh	r2
[ 	]+[0-9a-f]+:[ 	]+83          	psh	r3
[ 	]+[0-9a-f]+:[ 	]+84          	psh	r4
[ 	]+[0-9a-f]+:[ 	]+85          	psh	r5
[ 	]+[0-9a-f]+:[ 	]+86          	psh	r6
[ 	]+[0-9a-f]+:[ 	]+87          	psh	r7
