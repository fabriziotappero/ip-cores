v 20110115 2
C 4300 2900 1 0 0 in_port.sym
{
T 4300 2900 5 10 1 1 0 6 1
refdes=pad_oe 
}
C 8100 2500 1 0 1 io_port_v.sym
{
T 8100 2500 5 10 1 1 0 0 1
refdes=PAD 
}
C 5200 2100 1 0 1 out_port.sym
{
T 4200 2100 5 10 1 1 0 6 1
refdes=pad_in 
}
N 5500 3000 5200 3000 4
N 5500 2200 5200 2200 4
U 7100 2600 6600 2600 10 0
B 3000 500 6000 4500 3 0 0 0 -1 -1 0 -1 -1 -1 -1 -1
C 5400 2000 1 0 0 cde_pad_od_dig.sym
{
T 6402 2118 5 10 1 1 0 0 1
device=cde_pad_od_dig
T 6600 2900 5 10 1 1 0 6 1
refdes=P?
}
