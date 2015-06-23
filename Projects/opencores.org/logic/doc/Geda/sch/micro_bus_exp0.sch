v 20100214 1
C 2100 300 1 0 0 in_port_v.sym   
{
T 2100 300 5 10 1 1 0 6 1 1
refdes=wdata_in[7:0]
}
C 2100 700 1 0 0 in_port_v.sym   
{
T 2100 700 5 10 1 1 0 6 1 1
refdes=mas_0_rdata_in[7:0]
}
C 2100 1100 1 0 0 in_port_v.sym   
{
T 2100 1100 5 10 1 1 0 6 1 1
refdes=addr_in[7:0]
}
C 2100 1500 1 0 0 in_port.sym  
{
T 2100 1500 5 10 1 1 0 6 1 1 
refdes=wr_in
}
C 2100 1900 1 0 0 in_port.sym  
{
T 2100 1900 5 10 1 1 0 6 1 1 
refdes=reset
}
C 2100 2300 1 0 0 in_port.sym  
{
T 2100 2300 5 10 1 1 0 6 1 1 
refdes=rd_in
}
C 2100 2700 1 0 0 in_port.sym  
{
T 2100 2700 5 10 1 1 0 6 1 1 
refdes=enable
}
C 2100 3100 1 0 0 in_port.sym  
{
T 2100 3100 5 10 1 1 0 6 1 1 
refdes=cs_in
}
C 2100 3500 1 0 0 in_port.sym  
{
T 2100 3500 5 10 1 1 0 6 1 1 
refdes=clk
}
C 5400 300  1 0  0 out_port_v.sym
{
T 6400 300 5  10 1 1 0 0 1 1 
refdes=rdata_out[15:0]
}
C 5400 700  1 0  0 out_port_v.sym
{
T 6400 700 5  10 1 1 0 0 1 1 
refdes=mas_0_wdata_out[7:0]
}
C 5400 1100  1 0  0 out_port_v.sym
{
T 6400 1100 5  10 1 1 0 0 1 1 
refdes=mas_0_addr_out[7:0]
}
C 5400 1500  1 0 0 out_port.sym
{
T 6400 1500 5  10 1 1 0 0 1 1
refdes=wait_out
}
C 5400 1900  1 0 0 out_port.sym
{
T 6400 1900 5  10 1 1 0 0 1 1
refdes=mas_0_wr_out
}
C 5400 2300  1 0 0 out_port.sym
{
T 6400 2300 5  10 1 1 0 0 1 1
refdes=mas_0_rd_out
}
C 5400 2700  1 0 0 out_port.sym
{
T 6400 2700 5  10 1 1 0 0 1 1
refdes=mas_0_cs_out
}
