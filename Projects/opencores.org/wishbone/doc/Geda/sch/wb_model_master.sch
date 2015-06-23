v 20100214 1
C 1700 300 1 0 0 in_port_v.sym   
{
T 1700 300 5 10 1 1 0 6 1 1
refdes=din[dwidth-1:0]
}
C 1700 700 1 0 0 in_port.sym  
{
T 1700 700 5 10 1 1 0 6 1 1 
refdes=rty
}
C 1700 1100 1 0 0 in_port.sym  
{
T 1700 1100 5 10 1 1 0 6 1 1 
refdes=reset
}
C 1700 1500 1 0 0 in_port.sym  
{
T 1700 1500 5 10 1 1 0 6 1 1 
refdes=err
}
C 1700 1900 1 0 0 in_port.sym  
{
T 1700 1900 5 10 1 1 0 6 1 1 
refdes=clk
}
C 1700 2300 1 0 0 in_port.sym  
{
T 1700 2300 5 10 1 1 0 6 1 1 
refdes=ack
}
C 5300 300  1 0  0 out_port_v.sym
{
T 6300 300 5  10 1 1 0 0 1 1 
refdes=sel[dwidth/8-1:0]
}
C 5300 700  1 0  0 out_port_v.sym
{
T 6300 700 5  10 1 1 0 0 1 1 
refdes=dout[wb_data_width-1:0]
}
C 5300 1100  1 0  0 out_port_v.sym
{
T 6300 1100 5  10 1 1 0 0 1 1 
refdes=adr[wb_addr_width-1:0]
}
C 5300 1500  1 0 0 out_port.sym
{
T 6300 1500 5  10 1 1 0 0 1 1
refdes=we
}
C 5300 1900  1 0 0 out_port.sym
{
T 6300 1900 5  10 1 1 0 0 1 1
refdes=stb
}
C 5300 2300  1 0 0 out_port.sym
{
T 6300 2300 5  10 1 1 0 0 1 1
refdes=cyc
}
