v 20110115 2
C 4500 6100 1 0 0 frame_800x600.sym
T 5600 9700 9 10 1 0 0 0 1
.FOO_1_PHY(FOO_1_PHY)
B 4500 6100 3400 3500 3 0 0 0 -1 -1 0 -1 -1 -1 -1 -1
B 4500 6100 6100 4500 3 0 0 0 -1 -1 0 -1 -1 -1 -1 -1
B 4500 6100 8600 5800 3 0 0 0 -1 -1 0 -1 -1 -1 -1 -1
T 4600 10600 9 10 1 0 0 0 2
CMP_2
U1
T 4600 12000 9 10 1 0 0 0 1
CMP_1
T 4600 9700 9 10 1 0 0 0 2
CMP_3
U2
T 4800 8300 9 10 1 0 0 0 6
busInterface
name               FOO_1
abstractor          VLNV
Port         
logical                 LOG
physical FOO_1_PHY
L 6700 9900 6700 10600 3 0 0 0 -1 -1
L 6700 10600 6600 10400 3 0 0 0 -1 -1
L 6700 10600 6800 10400 3 0 0 0 -1 -1
L 6700 10900 6700 11900 3 0 0 0 -1 -1
L 6700 11900 6600 11700 3 0 0 0 -1 -1
L 6700 11900 6800 11700 3 0 0 0 -1 -1
T 8300 7300 9 10 1 0 0 0 8
interconnection
name                 FOO_1
compinstance           U2
busRef              FOO_1
portmap
logical         LOG
physical    FOO_1_PHY

T 4700 6200 9 10 1 0 0 0 1
LEAF CELL
T 8200 6200 9 10 1 0 0 0 1
HIER LEVEL
T 10900 6200 9 10 1 0 0 0 1
HIER LEVEL
T 8300 9300 9 10 1 0 0 0 5
busInterface
name               FOO_1
abstractor          VLNV
Port         logical  LOG
physical FOO_1_PHY
T 10800 9400 9 10 1 0 0 0 5
busInterface
name               FOO_1
abstractor          VLNV
Port         logical  LOG
physical FOO_1_PHY
T 5700 10700 9 10 1 0 0 0 1
.FOO_1_PHY(FOO_1_PHY)
T 5700 12000 9 10 1 0 0 0 1
.FOO_1_PHY()
T 10800 7300 9 10 1 0 0 0 8
interconnection
name                 FOO_1
compinstance           U1
busRef              FOO_1
portmap
logical         LOG
physical    FOO_1_PHY

