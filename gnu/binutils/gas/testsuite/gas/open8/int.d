#objdump: -d
#name: Interrupt

.*: .*

Disassembly of section \.text:

0+ <\.text>:
[ 	]+[0-9a-f]+:[ 	]+a8          	int	0
[ 	]+[0-9a-f]+:[ 	]+a9          	int	1
[ 	]+[0-9a-f]+:[ 	]+aa          	int	2
[ 	]+[0-9a-f]+:[ 	]+ab          	int	3
[ 	]+[0-9a-f]+:[ 	]+ac          	int	4
[ 	]+[0-9a-f]+:[ 	]+ad          	int	5
[ 	]+[0-9a-f]+:[ 	]+ae          	int	6
[ 	]+[0-9a-f]+:[ 	]+af          	int	7
