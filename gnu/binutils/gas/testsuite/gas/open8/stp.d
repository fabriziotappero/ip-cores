#objdump: -d
#name: Set Bit in PSR

.*: .*

Disassembly of section \.text:

0+ <.text>:
[ 	]+[0-9a-f]+:[ 	]+58          	stz
[ 	]+[0-9a-f]+:[ 	]+59          	stc
[ 	]+[0-9a-f]+:[ 	]+5a          	stn
[ 	]+[0-9a-f]+:[ 	]+5b          	sti
[ 	]+[0-9a-f]+:[ 	]+5c          	stp	4
[ 	]+[0-9a-f]+:[ 	]+5d          	stp	5
[ 	]+[0-9a-f]+:[ 	]+5e          	stp	6
[ 	]+[0-9a-f]+:[ 	]+5f          	stp	7
