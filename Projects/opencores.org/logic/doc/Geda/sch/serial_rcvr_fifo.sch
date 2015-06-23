v 20100214 1
C 1500 300 1 0 0 in_port.sym  
{
T 1500 300 5 10 1 1 0 6 1 1 
refdes=reset
}
C 1500 700 1 0 0 in_port.sym  
{
T 1500 700 5 10 1 1 0 6 1 1 
refdes=rcv_stb
}
C 1500 1100 1 0 0 in_port.sym  
{
T 1500 1100 5 10 1 1 0 6 1 1 
refdes=parity_type
}
C 1500 1500 1 0 0 in_port.sym  
{
T 1500 1500 5 10 1 1 0 6 1 1 
refdes=parity_force
}
C 1500 1900 1 0 0 in_port.sym  
{
T 1500 1900 5 10 1 1 0 6 1 1 
refdes=parity_enable
}
C 1500 2300 1 0 0 in_port.sym  
{
T 1500 2300 5 10 1 1 0 6 1 1 
refdes=pad_in
}
C 1500 2700 1 0 0 in_port.sym  
{
T 1500 2700 5 10 1 1 0 6 1 1 
refdes=edge_enable
}
C 1500 3100 1 0 0 in_port.sym  
{
T 1500 3100 5 10 1 1 0 6 1 1 
refdes=clk
}
C 4700 300  1 0  0 out_port_v.sym
{
T 5700 300 5  10 1 1 0 0 1 1 
refdes=data_out[WIDTH-1:0]
}
C 4700 700  1 0 0 out_port.sym
{
T 5700 700 5  10 1 1 0 0 1 1
refdes=stop_error
}
C 4700 1100  1 0 0 out_port.sym
{
T 5700 1100 5  10 1 1 0 0 1 1
refdes=parity_error
}
C 4700 1500  1 0 0 out_port.sym
{
T 5700 1500 5  10 1 1 0 0 1 1
refdes=data_avail
}
