v 20100214 1
C 1500 300 1 0 0 in_port_v.sym   
{
T 1500 300 5 10 1 1 0 6 1 1
refdes=vec_int[7:0]
}
C 1500 700 1 0 0 in_port_v.sym   
{
T 1500 700 5 10 1 1 0 6 1 1
refdes=rdata[15:0]
}
C 1500 1100 1 0 0 in_port_v.sym   
{
T 1500 1100 5 10 1 1 0 6 1 1
refdes=pg0_data[7:0]
}
C 1500 1500 1 0 0 in_port.sym  
{
T 1500 1500 5 10 1 1 0 6 1 1 
refdes=reset
}
C 1500 1900 1 0 0 in_port.sym  
{
T 1500 1900 5 10 1 1 0 6 1 1 
refdes=nmi
}
C 1500 2300 1 0 0 in_port.sym  
{
T 1500 2300 5 10 1 1 0 6 1 1 
refdes=enable
}
C 1500 2700 1 0 0 in_port.sym  
{
T 1500 2700 5 10 1 1 0 6 1 1 
refdes=clk
}
C 4500 300  1 0  0 out_port_v.sym
{
T 5500 300 5  10 1 1 0 0 1 1 
refdes=wdata[7:0]
}
C 4500 700  1 0  0 out_port_v.sym
{
T 5500 700 5  10 1 1 0 0 1 1 
refdes=pg0_add[7:0]
}
C 4500 1100  1 0  0 out_port_v.sym
{
T 5500 1100 5  10 1 1 0 0 1 1 
refdes=alu_status[7:0]
}
C 4500 1500  1 0  0 out_port_v.sym
{
T 5500 1500 5  10 1 1 0 0 1 1 
refdes=addr[CPU_ADD-1:0]
}
C 4500 1900  1 0 0 out_port.sym
{
T 5500 1900 5  10 1 1 0 0 1 1
refdes=wr
}
C 4500 2300  1 0 0 out_port.sym
{
T 5500 2300 5  10 1 1 0 0 1 1
refdes=rd
}
C 4500 2700  1 0 0 out_port.sym
{
T 5500 2700 5  10 1 1 0 0 1 1
refdes=pg0_wr
}
C 4500 3100  1 0 0 out_port.sym
{
T 5500 3100 5  10 1 1 0 0 1 1
refdes=pg0_rd
}
