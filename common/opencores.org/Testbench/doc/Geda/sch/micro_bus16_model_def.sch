v 20100214 1
C 1300 300 1 0 0 in_port.sym  
{
T 1300 300 5 10 1 1 0 6 1 1 
refdes=reset
}
C 1300 700 1 0 0 in_port.sym  
{
T 1300 700 5 10 1 1 0 6 1 1 
refdes=clk
}
C 1300 1100 1 0 0 io_port_v.sym   
{
T 1300 1100 5 10 1 1 0 6 1 1
refdes=rdata[15:0]
}
C 3700 300  1 0  0 out_port_v.sym
{
T 4700 300 5  10 1 1 0 0 1 1 
refdes=wdata[15:0]
}
C 3700 700  1 0  0 out_port_v.sym
{
T 4700 700 5  10 1 1 0 0 1 1 
refdes=addr[23:0]
}
C 3700 1100  1 0 0 out_port.sym
{
T 4700 1100 5  10 1 1 0 0 1 1
refdes=wr
}
C 3700 1500  1 0 0 out_port.sym
{
T 4700 1500 5  10 1 1 0 0 1 1
refdes=ub
}
C 3700 1900  1 0 0 out_port.sym
{
T 4700 1900 5  10 1 1 0 0 1 1
refdes=rd
}
C 3700 2300  1 0 0 out_port.sym
{
T 4700 2300 5  10 1 1 0 0 1 1
refdes=lb
}
