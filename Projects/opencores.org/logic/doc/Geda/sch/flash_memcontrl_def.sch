v 20100214 1
C 2100 300 1 0 0 in_port_v.sym   
{
T 2100 300 5 10 1 1 0 6 1 1
refdes=wdata[15:0]
}
C 2100 700 1 0 0 in_port_v.sym   
{
T 2100 700 5 10 1 1 0 6 1 1
refdes=memdb_in[15:0]
}
C 2100 1100 1 0 0 in_port_v.sym   
{
T 2100 1100 5 10 1 1 0 6 1 1
refdes=cs[1:0]
}
C 2100 1500 1 0 0 in_port_v.sym   
{
T 2100 1500 5 10 1 1 0 6 1 1
refdes=addr[ADDR_BITS-1:1]
}
C 2100 1900 1 0 0 in_port.sym  
{
T 2100 1900 5 10 1 1 0 6 1 1 
refdes=wr
}
C 2100 2300 1 0 0 in_port.sym  
{
T 2100 2300 5 10 1 1 0 6 1 1 
refdes=ub
}
C 2100 2700 1 0 0 in_port.sym  
{
T 2100 2700 5 10 1 1 0 6 1 1 
refdes=stb
}
C 2100 3100 1 0 0 in_port.sym  
{
T 2100 3100 5 10 1 1 0 6 1 1 
refdes=reset
}
C 2100 3500 1 0 0 in_port.sym  
{
T 2100 3500 5 10 1 1 0 6 1 1 
refdes=rd
}
C 2100 3900 1 0 0 in_port.sym  
{
T 2100 3900 5 10 1 1 0 6 1 1 
refdes=ramwait_in
}
C 2100 4300 1 0 0 in_port.sym  
{
T 2100 4300 5 10 1 1 0 6 1 1 
refdes=lb
}
C 2100 4700 1 0 0 in_port.sym  
{
T 2100 4700 5 10 1 1 0 6 1 1 
refdes=flashststs_in
}
C 2100 5100 1 0 0 in_port.sym  
{
T 2100 5100 5 10 1 1 0 6 1 1 
refdes=clk
}
C 5900 300  1 0  0 out_port_v.sym
{
T 6900 300 5  10 1 1 0 0 1 1 
refdes=rdata[15:0]
}
C 5900 700  1 0  0 out_port_v.sym
{
T 6900 700 5  10 1 1 0 0 1 1 
refdes=memdb_out[15:0]
}
C 5900 1100  1 0  0 out_port_v.sym
{
T 6900 1100 5  10 1 1 0 0 1 1 
refdes=memadr_out[ADDR_BITS-1:1]
}
C 5900 1500  1 0 0 out_port.sym
{
T 6900 1500 5  10 1 1 0 0 1 1
refdes=wait_out
}
C 5900 1900  1 0 0 out_port.sym
{
T 6900 1900 5  10 1 1 0 0 1 1
refdes=ramub_n_out
}
C 5900 2300  1 0 0 out_port.sym
{
T 6900 2300 5  10 1 1 0 0 1 1
refdes=ramlb_n_out
}
C 5900 2700  1 0 0 out_port.sym
{
T 6900 2700 5  10 1 1 0 0 1 1
refdes=ramcs_n_out
}
C 5900 3100  1 0 0 out_port.sym
{
T 6900 3100 5  10 1 1 0 0 1 1
refdes=ramcre_out
}
C 5900 3500  1 0 0 out_port.sym
{
T 6900 3500 5  10 1 1 0 0 1 1
refdes=ramclk_out
}
C 5900 3900  1 0 0 out_port.sym
{
T 6900 3900 5  10 1 1 0 0 1 1
refdes=ramadv_n_out
}
C 5900 4300  1 0 0 out_port.sym
{
T 6900 4300 5  10 1 1 0 0 1 1
refdes=memwr_n_out
}
C 5900 4700  1 0 0 out_port.sym
{
T 6900 4700 5  10 1 1 0 0 1 1
refdes=memoe_n_out
}
C 5900 5100  1 0 0 out_port.sym
{
T 6900 5100 5  10 1 1 0 0 1 1
refdes=memdb_oe
}
C 5900 5500  1 0 0 out_port.sym
{
T 6900 5500 5  10 1 1 0 0 1 1
refdes=flashrp_n_out
}
C 5900 5900  1 0 0 out_port.sym
{
T 6900 5900 5  10 1 1 0 0 1 1
refdes=flashcs_n_out
}
