v 20100214 1
C 1200 300 1 0 0 in_port.sym  
{
T 1200 300 5 10 1 1 0 6 1 1 
refdes=reset
}
C 1200 700 1 0 0 in_port.sym  
{
T 1200 700 5 10 1 1 0 6 1 1 
refdes=clk
}
C 1200 1100 1 0 0 io_port_v.sym   
{
T 1200 1100 5 10 1 1 0 6 1 1
refdes=rdata[7:0]
}
C 4500 300  1 0  0 out_port_v.sym
{
T 5500 300 5  10 1 1 0 0 1 1 
refdes=wdata[7:0]
}
C 4500 700  1 0  0 out_port_v.sym
{
T 5500 700 5  10 1 1 0 0 1 1 
refdes=addr[addr_width-1:0]
}
C 4500 1100  1 0 0 out_port.sym
{
T 5500 1100 5  10 1 1 0 0 1 1
refdes=wr
}
C 4500 1500  1 0 0 out_port.sym
{
T 5500 1500 5  10 1 1 0 0 1 1
refdes=rd
}
C 4500 1900  1 0 0 out_port.sym
{
T 5500 1900 5  10 1 1 0 0 1 1
refdes=cs
}
