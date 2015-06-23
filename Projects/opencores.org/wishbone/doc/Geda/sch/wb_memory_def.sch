v 20100214 1
C 2600 300 1 0 0 in_port_v.sym   
{
T 2600 300 5 10 1 1 0 6 1 1
refdes=sel_i[wb_byte_lanes-1:0]
}
C 2600 700 1 0 0 in_port_v.sym   
{
T 2600 700 5 10 1 1 0 6 1 1
refdes=dat_i[wb_data_width-1:0]
}
C 2600 1100 1 0 0 in_port_v.sym   
{
T 2600 1100 5 10 1 1 0 6 1 1
refdes=adr_i[wb_addr_width-1:0]
}
C 2600 1500 1 0 0 in_port.sym  
{
T 2600 1500 5 10 1 1 0 6 1 1 
refdes=we_i
}
C 2600 1900 1 0 0 in_port.sym  
{
T 2600 1900 5 10 1 1 0 6 1 1 
refdes=stb_i
}
C 2600 2300 1 0 0 in_port.sym  
{
T 2600 2300 5 10 1 1 0 6 1 1 
refdes=rst_i
}
C 2600 2700 1 0 0 in_port.sym  
{
T 2600 2700 5 10 1 1 0 6 1 1 
refdes=cyc_i
}
C 2600 3100 1 0 0 in_port.sym  
{
T 2600 3100 5 10 1 1 0 6 1 1 
refdes=clk_i
}
C 6300 300  1 0  0 out_port_v.sym
{
T 7300 300 5  10 1 1 0 0 1 1 
refdes=dat_o[wb_data_width-1:0]
}
C 6300 700  1 0 0 out_port.sym
{
T 7300 700 5  10 1 1 0 0 1 1
refdes=ack_o
}
