v 20100214 1
C 1700 300 1 0 0 in_port_v.sym   
{
T 1700 300 5 10 1 1 0 6 1 1
refdes=wdata_in[7:0]
}
C 1700 700 1 0 0 in_port_v.sym   
{
T 1700 700 5 10 1 1 0 6 1 1
refdes=mem_wait[1:0]
}
C 1700 1100 1 0 0 in_port_v.sym   
{
T 1700 1100 5 10 1 1 0 6 1 1
refdes=mem_rdata[47:0]
}
C 1700 1500 1 0 0 in_port_v.sym   
{
T 1700 1500 5 10 1 1 0 6 1 1
refdes=addr_in[15:0]
}
C 1700 1900 1 0 0 in_port.sym  
{
T 1700 1900 5 10 1 1 0 6 1 1 
refdes=wr_in
}
C 1700 2300 1 0 0 in_port.sym  
{
T 1700 2300 5 10 1 1 0 6 1 1 
refdes=reset
}
C 1700 2700 1 0 0 in_port.sym  
{
T 1700 2700 5 10 1 1 0 6 1 1 
refdes=rd_in
}
C 1700 3100 1 0 0 in_port.sym  
{
T 1700 3100 5 10 1 1 0 6 1 1 
refdes=clk
}
C 4500 300  1 0  0 out_port_v.sym
{
T 5500 300 5  10 1 1 0 0 1 1 
refdes=rdata_out[7:0]
}
C 4500 700  1 0  0 out_port_v.sym
{
T 5500 700 5  10 1 1 0 0 1 1 
refdes=mem_wdata[15:0]
}
C 4500 1100  1 0  0 out_port_v.sym
{
T 5500 1100 5  10 1 1 0 0 1 1 
refdes=mem_cs[4:0]
}
C 4500 1500  1 0  0 out_port_v.sym
{
T 5500 1500 5  10 1 1 0 0 1 1 
refdes=mem_addr[15:0]
}
C 4500 1900  1 0 0 out_port.sym
{
T 5500 1900 5  10 1 1 0 0 1 1
refdes=mem_wr
}
C 4500 2300  1 0 0 out_port.sym
{
T 5500 2300 5  10 1 1 0 0 1 1
refdes=mem_rd
}
C 4500 2700  1 0 0 out_port.sym
{
T 5500 2700 5  10 1 1 0 0 1 1
refdes=enable
}
