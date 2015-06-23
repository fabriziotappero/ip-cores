v 20100214 1
C 1800 300 1 0 0 in_port_v.sym   
{
T 1800 300 5 10 1 1 0 6 1 1
refdes=wdata[WIDTH-1:0]
}
C 1800 700 1 0 0 in_port_v.sym   
{
T 1800 700 5 10 1 1 0 6 1 1
refdes=waddr[ADDR-1:0]
}
C 1800 1100 1 0 0 in_port_v.sym   
{
T 1800 1100 5 10 1 1 0 6 1 1
refdes=raddr[ADDR-1:0]
}
C 1800 1500 1 0 0 in_port.sym  
{
T 1800 1500 5 10 1 1 0 6 1 1 
refdes=wr
}
C 1800 1900 1 0 0 in_port.sym  
{
T 1800 1900 5 10 1 1 0 6 1 1 
refdes=rd
}
C 1800 2300 1 0 0 in_port.sym  
{
T 1800 2300 5 10 1 1 0 6 1 1 
refdes=cs
}
C 1800 2700 1 0 0 in_port.sym  
{
T 1800 2700 5 10 1 1 0 6 1 1 
refdes=clk
}
C 4700 300  1 0  0 out_port_v.sym
{
T 5700 300 5  10 1 1 0 0 1 1 
refdes=rdata[WIDTH-1:0]
}
