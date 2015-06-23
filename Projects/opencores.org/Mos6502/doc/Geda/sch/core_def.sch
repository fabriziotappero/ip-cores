v 20100214 1
C 2100 300 1 0 0 in_port_v.sym   
{
T 2100 300 5 10 1 1 0 6 1 1
refdes=vec_int[7:0]
}
C 2100 700 1 0 0 in_port_v.sym   
{
T 2100 700 5 10 1 1 0 6 1 1
refdes=stk_pull_data[15:0]
}
C 2100 1100 1 0 0 in_port_v.sym   
{
T 2100 1100 5 10 1 1 0 6 1 1
refdes=rdata[15:0]
}
C 2100 1500 1 0 0 in_port_v.sym   
{
T 2100 1500 5 10 1 1 0 6 1 1
refdes=prog_data[15:0]
}
C 2100 1900 1 0 0 in_port_v.sym   
{
T 2100 1900 5 10 1 1 0 6 1 1
refdes=pg0_data[7:0]
}
C 2100 2300 1 0 0 in_port.sym  
{
T 2100 2300 5 10 1 1 0 6 1 1 
refdes=reset
}
C 2100 2700 1 0 0 in_port.sym  
{
T 2100 2700 5 10 1 1 0 6 1 1 
refdes=nmi
}
C 2100 3100 1 0 0 in_port.sym  
{
T 2100 3100 5 10 1 1 0 6 1 1 
refdes=enable
}
C 2100 3500 1 0 0 in_port.sym  
{
T 2100 3500 5 10 1 1 0 6 1 1 
refdes=clk
}
C 5300 300  1 0  0 out_port_v.sym
{
T 6300 300 5  10 1 1 0 0 1 1 
refdes=wdata[7:0]
}
C 5300 700  1 0  0 out_port_v.sym
{
T 6300 700 5  10 1 1 0 0 1 1 
refdes=stk_push_data[15:0]
}
C 5300 1100  1 0  0 out_port_v.sym
{
T 6300 1100 5  10 1 1 0 0 1 1 
refdes=prog_counter[15:0]
}
C 5300 1500  1 0  0 out_port_v.sym
{
T 6300 1500 5  10 1 1 0 0 1 1 
refdes=pg0_add[7:0]
}
C 5300 1900  1 0  0 out_port_v.sym
{
T 6300 1900 5  10 1 1 0 0 1 1 
refdes=alu_status[7:0]
}
C 5300 2300  1 0  0 out_port_v.sym
{
T 6300 2300 5  10 1 1 0 0 1 1 
refdes=addr[15:0]
}
C 5300 2700  1 0 0 out_port.sym
{
T 6300 2700 5  10 1 1 0 0 1 1
refdes=wr
}
C 5300 3100  1 0 0 out_port.sym
{
T 6300 3100 5  10 1 1 0 0 1 1
refdes=stk_push
}
C 5300 3500  1 0 0 out_port.sym
{
T 6300 3500 5  10 1 1 0 0 1 1
refdes=stk_pull
}
C 5300 3900  1 0 0 out_port.sym
{
T 6300 3900 5  10 1 1 0 0 1 1
refdes=rd
}
C 5300 4300  1 0 0 out_port.sym
{
T 6300 4300 5  10 1 1 0 0 1 1
refdes=pg0_wr
}
C 5300 4700  1 0 0 out_port.sym
{
T 6300 4700 5  10 1 1 0 0 1 1
refdes=pg0_rd
}
