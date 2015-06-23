v 20100214 1
C 1700 300 1 0 0 in_port_v.sym   
{
T 1700 300 5 10 1 1 0 6 1 1
refdes=wdata[7:0]
}
C 1700 700 1 0 0 in_port_v.sym   
{
T 1700 700 5 10 1 1 0 6 1 1
refdes=mem_wdata[15:0]
}
C 1700 1100 1 0 0 in_port_v.sym   
{
T 1700 1100 5 10 1 1 0 6 1 1
refdes=mem_addr[13:0]
}
C 1700 1500 1 0 0 in_port_v.sym   
{
T 1700 1500 5 10 1 1 0 6 1 1
refdes=ext_rdata[15:0]
}
C 1700 1900 1 0 0 in_port_v.sym   
{
T 1700 1900 5 10 1 1 0 6 1 1
refdes=addr[3:0]
}
C 1700 2300 1 0 0 in_port.sym  
{
T 1700 2300 5 10 1 1 0 6 1 1 
refdes=wr
}
C 1700 2700 1 0 0 in_port.sym  
{
T 1700 2700 5 10 1 1 0 6 1 1 
refdes=reset
}
C 1700 3100 1 0 0 in_port.sym  
{
T 1700 3100 5 10 1 1 0 6 1 1 
refdes=rd
}
C 1700 3500 1 0 0 in_port.sym  
{
T 1700 3500 5 10 1 1 0 6 1 1 
refdes=mem_wr
}
C 1700 3900 1 0 0 in_port.sym  
{
T 1700 3900 5 10 1 1 0 6 1 1 
refdes=mem_rd
}
C 1700 4300 1 0 0 in_port.sym  
{
T 1700 4300 5 10 1 1 0 6 1 1 
refdes=mem_cs
}
C 1700 4700 1 0 0 in_port.sym  
{
T 1700 4700 5 10 1 1 0 6 1 1 
refdes=ext_wait
}
C 1700 5100 1 0 0 in_port.sym  
{
T 1700 5100 5 10 1 1 0 6 1 1 
refdes=enable
}
C 1700 5500 1 0 0 in_port.sym  
{
T 1700 5500 5 10 1 1 0 6 1 1 
refdes=cs
}
C 1700 5900 1 0 0 in_port.sym  
{
T 1700 5900 5 10 1 1 0 6 1 1 
refdes=clk
}
C 4500 300  1 0  0 out_port_v.sym
{
T 5500 300 5  10 1 1 0 0 1 1 
refdes=wait_st[7:0]
}
C 4500 700  1 0  0 out_port_v.sym
{
T 5500 700 5  10 1 1 0 0 1 1 
refdes=rdata[7:0]
}
C 4500 1100  1 0  0 out_port_v.sym
{
T 5500 1100 5  10 1 1 0 0 1 1 
refdes=mem_rdata[15:0]
}
C 4500 1500  1 0  0 out_port_v.sym
{
T 5500 1500 5  10 1 1 0 0 1 1 
refdes=ext_wdata[15:0]
}
C 4500 1900  1 0  0 out_port_v.sym
{
T 5500 1900 5  10 1 1 0 0 1 1 
refdes=ext_cs[1:0]
}
C 4500 2300  1 0  0 out_port_v.sym
{
T 5500 2300 5  10 1 1 0 0 1 1 
refdes=ext_add[23:1]
}
C 4500 2700  1 0  0 out_port_v.sym
{
T 5500 2700 5  10 1 1 0 0 1 1 
refdes=bank[7:0]
}
C 4500 3100  1 0 0 out_port.sym
{
T 5500 3100 5  10 1 1 0 0 1 1
refdes=mem_wait
}
C 4500 3500  1 0 0 out_port.sym
{
T 5500 3500 5  10 1 1 0 0 1 1
refdes=ext_wr
}
C 4500 3900  1 0 0 out_port.sym
{
T 5500 3900 5  10 1 1 0 0 1 1
refdes=ext_ub
}
C 4500 4300  1 0 0 out_port.sym
{
T 5500 4300 5  10 1 1 0 0 1 1
refdes=ext_stb
}
C 4500 4700  1 0 0 out_port.sym
{
T 5500 4700 5  10 1 1 0 0 1 1
refdes=ext_rd
}
C 4500 5100  1 0 0 out_port.sym
{
T 5500 5100 5  10 1 1 0 0 1 1
refdes=ext_lb
}
