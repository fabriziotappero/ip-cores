v 20110115 2
C 4100 3000 1 0 0 in_port.sym
{
T 4100 3000 5 10 1 1 0 6 1
refdes=pad_oe 
}
C 4100 2600 1 0 0 in_port.sym
{
T 4100 2600 5 10 1 1 0 6 1
refdes=pad_out 
}
C 7900 2600 1 0 1 io_port_v.sym
{
T 7900 2600 5 10 1 1 0 0 1
refdes=PAD 
}
C 5000 2200 1 0 1 out_port.sym
{
T 4000 2200 5 10 1 1 0 6 1
refdes=pad_in 
}
C 5300 2100 1 0 0 cde_pad_se_dig.sym
{
T 6202 2218 5 10 1 1 0 0 1
device=cde_pad_se_dig
T 6400 3000 5 10 1 1 0 6 1
refdes=P?
}
N 5300 3100 5000 3100 4
N 5300 2700 5000 2700 4
N 5300 2300 5000 2300 4
U 6900 2700 6400 2700 10 0
B 2800 600 6000 4500 3 0 0 0 -1 -1 0 -1 -1 -1 -1 -1
