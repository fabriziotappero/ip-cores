v 20100214 1
C 1500 300 1 0 0 in_port.sym  
{
T 1500 300 5 10 1 1 0 6 1 1 
refdes=ser_in
}
C 1500 700 1 0 0 in_port.sym  
{
T 1500 700 5 10 1 1 0 6 1 1 
refdes=reset
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
refdes=edge_enable
}
C 1500 2700 1 0 0 in_port.sym  
{
T 1500 2700 5 10 1 1 0 6 1 1 
refdes=clk
}
C 5100 300  1 0  0 out_port_v.sym
{
T 6100 300 5  10 1 1 0 0 1 1 
refdes=shift_buffer[WIDTH-1:0]
}
C 5100 700  1 0 0 out_port.sym
{
T 6100 700 5  10 1 1 0 0 1 1
refdes=stop_cnt
}
C 5100 1100  1 0 0 out_port.sym
{
T 6100 1100 5  10 1 1 0 0 1 1
refdes=parity_samp
}
C 5100 1500  1 0 0 out_port.sym
{
T 6100 1500 5  10 1 1 0 0 1 1
refdes=parity_calc
}
C 5100 1900  1 0 0 out_port.sym
{
T 6100 1900 5  10 1 1 0 0 1 1
refdes=last_cnt
}
C 5100 2300  1 0 0 out_port.sym
{
T 6100 2300 5  10 1 1 0 0 1 1
refdes=frame_err
}
