#objdump: -d
#name: Store R0 Indexed

.*: .*

Disassembly of section \.text:

0+ <.text>:
[ 	]+[0-9a-f]+:[ 	]+d1          	stx	r0 \+\+
[ 	]+[0-9a-f]+:[ 	]+d0          	stx	r0
[ 	]+[0-9a-f]+:[ 	]+d3          	stx	r2 \+\+
[ 	]+[0-9a-f]+:[ 	]+d2          	stx	r2
[ 	]+[0-9a-f]+:[ 	]+d5          	stx	r4 \+\+
[ 	]+[0-9a-f]+:[ 	]+d4          	stx	r4
[ 	]+[0-9a-f]+:[ 	]+d7          	stx	r6 \+\+
[ 	]+[0-9a-f]+:[ 	]+d6          	stx	r6
