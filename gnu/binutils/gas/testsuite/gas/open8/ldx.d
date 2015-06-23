#objdump: -d
#name: Load R0 Indexed

.*: .*

Disassembly of section \.text:

0+ <\.text>:
[ 	]+[0-9a-f]+:[ 	]+f1          	ldx	r0 \+\+
[ 	]+[0-9a-f]+:[ 	]+f0          	ldx	r0
[ 	]+[0-9a-f]+:[ 	]+f3          	ldx	r2 \+\+
[ 	]+[0-9a-f]+:[ 	]+f2          	ldx	r2
[ 	]+[0-9a-f]+:[ 	]+f5          	ldx	r4 \+\+
[ 	]+[0-9a-f]+:[ 	]+f4          	ldx	r4
[ 	]+[0-9a-f]+:[ 	]+f7          	ldx	r6 \+\+
[ 	]+[0-9a-f]+:[ 	]+f6          	ldx	r6
