#objdump: -d
#name: Clear Bit in PSR

.*: .*

Disassembly of section \.text:

0+ <\.text>:
[ 	]+[0-9a-f]+:[ 	]+68          	clz
[ 	]+[0-9a-f]+:[ 	]+69          	clc
[ 	]+[0-9a-f]+:[ 	]+6a          	cln
[ 	]+[0-9a-f]+:[ 	]+6b          	cli
[ 	]+[0-9a-f]+:[ 	]+6c          	clp	4
[ 	]+[0-9a-f]+:[ 	]+6d          	clp	5
[ 	]+[0-9a-f]+:[ 	]+6e          	clp	6
[ 	]+[0-9a-f]+:[ 	]+6f          	clp	7
