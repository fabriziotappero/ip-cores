v 20100214 1
C 1700 300 1 0 0 in_port_v.sym   
{
T 1700 300 5 10 1 1 0 6 1 1
refdes=wdata[7:0]
}
C 1700 700 1 0 0 in_port_v.sym   
{
T 1700 700 5 10 1 1 0 6 1 1
refdes=addr[3:0]
}
C 1700 1100 1 0 0 in_port.sym  
{
T 1700 1100 5 10 1 1 0 6 1 1 
refdes=wr
}
C 1700 1500 1 0 0 in_port.sym  
{
T 1700 1500 5 10 1 1 0 6 1 1 
refdes=reset
}
C 1700 1900 1 0 0 in_port.sym  
{
T 1700 1900 5 10 1 1 0 6 1 1 
refdes=rd
}
C 1700 2300 1 0 0 in_port.sym  
{
T 1700 2300 5 10 1 1 0 6 1 1 
refdes=ps2_data_pad_in
}
C 1700 2700 1 0 0 in_port.sym  
{
T 1700 2700 5 10 1 1 0 6 1 1 
refdes=ps2_clk_pad_in
}
C 1700 3100 1 0 0 in_port.sym  
{
T 1700 3100 5 10 1 1 0 6 1 1 
refdes=enable
}
C 1700 3500 1 0 0 in_port.sym  
{
T 1700 3500 5 10 1 1 0 6 1 1 
refdes=cs
}
C 1700 3900 1 0 0 in_port.sym  
{
T 1700 3900 5 10 1 1 0 6 1 1 
refdes=clk
}
C 4500 300  1 0  0 out_port_v.sym
{
T 5500 300 5  10 1 1 0 0 1 1 
refdes=rdata[7:0]
}
C 4500 700  1 0 0 out_port.sym
{
T 5500 700 5  10 1 1 0 0 1 1
refdes=rcv_data_avail
}
C 4500 1100  1 0 0 out_port.sym
{
T 5500 1100 5  10 1 1 0 0 1 1
refdes=ps2_data_pad_oe
}
C 4500 1500  1 0 0 out_port.sym
{
T 5500 1500 5  10 1 1 0 0 1 1
refdes=ps2_clk_pad_oe
}
