v 20100214 1
C 1800 300 1 0 0 in_port.sym  
{
T 1800 300 5 10 1 1 0 6 1 1 
refdes=txd_buffer_empty
}
C 1800 700 1 0 0 in_port.sym  
{
T 1800 700 5 10 1 1 0 6 1 1 
refdes=rxd_stop_error
}
C 1800 1100 1 0 0 in_port.sym  
{
T 1800 1100 5 10 1 1 0 6 1 1 
refdes=rxd_parity_error
}
C 1800 1500 1 0 0 in_port.sym  
{
T 1800 1500 5 10 1 1 0 6 1 1 
refdes=rxd_data_avail
}
C 1800 1900 1 0 0 in_port.sym  
{
T 1800 1900 5 10 1 1 0 6 1 1 
refdes=reset
}
C 1800 2300 1 0 0 in_port.sym  
{
T 1800 2300 5 10 1 1 0 6 1 1 
refdes=clk
}
C 4700 300  1 0 0 out_port.sym
{
T 5700 300 5  10 1 1 0 0 1 1
refdes=txd_parity
}
C 4700 700  1 0 0 out_port.sym
{
T 5700 700 5  10 1 1 0 0 1 1
refdes=txd_force_parity
}
C 4700 1100  1 0 0 out_port.sym
{
T 5700 1100 5  10 1 1 0 0 1 1
refdes=parity_enable
}
