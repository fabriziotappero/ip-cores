v 20100214 1
C 1600 300 1 0 0 in_port_v.sym   
{
T 1600 300 5 10 1 1 0 6 1 1
refdes=wdata[15:0]
}
C 1600 700 1 0 0 in_port_v.sym   
{
T 1600 700 5 10 1 1 0 6 1 1
refdes=be[1:0]
}
C 1600 1100 1 0 0 in_port_v.sym   
{
T 1600 1100 5 10 1 1 0 6 1 1
refdes=addr[ADDR-1:0]
}
C 1600 1500 1 0 0 in_port.sym  
{
T 1600 1500 5 10 1 1 0 6 1 1 
refdes=wr
}
C 1600 1900 1 0 0 in_port.sym  
{
T 1600 1900 5 10 1 1 0 6 1 1 
refdes=rd
}
C 1600 2300 1 0 0 in_port.sym  
{
T 1600 2300 5 10 1 1 0 6 1 1 
refdes=cs
}
C 1600 2700 1 0 0 in_port.sym  
{
T 1600 2700 5 10 1 1 0 6 1 1 
refdes=clk
}
C 4000 300  1 0  0 out_port_v.sym
{
T 5000 300 5  10 1 1 0 0 1 1 
refdes=rdata[15:0]
}
