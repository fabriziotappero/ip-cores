v 20100214 1
C 2600 300 1 0 0 in_port_v.sym   
{
T 2600 300 5 10 1 1 0 6 1 1
refdes=txd_data_in[SIZE-1:0]
}
C 2600 700 1 0 0 in_port_v.sym   
{
T 2600 700 5 10 1 1 0 6 1 1
refdes=divider_in[DIV_SIZE-1:0]
}
C 2600 1100 1 0 0 in_port.sym  
{
T 2600 1100 5 10 1 1 0 6 1 1 
refdes=txd_parity
}
C 2600 1500 1 0 0 in_port.sym  
{
T 2600 1500 5 10 1 1 0 6 1 1 
refdes=txd_load
}
C 2600 1900 1 0 0 in_port.sym  
{
T 2600 1900 5 10 1 1 0 6 1 1 
refdes=txd_force_parity
}
C 2600 2300 1 0 0 in_port.sym  
{
T 2600 2300 5 10 1 1 0 6 1 1 
refdes=txd_break
}
C 2600 2700 1 0 0 in_port.sym  
{
T 2600 2700 5 10 1 1 0 6 1 1 
refdes=rxd_parity
}
C 2600 3100 1 0 0 in_port.sym  
{
T 2600 3100 5 10 1 1 0 6 1 1 
refdes=rxd_pad_in
}
C 2600 3500 1 0 0 in_port.sym  
{
T 2600 3500 5 10 1 1 0 6 1 1 
refdes=rxd_force_parity
}
C 2600 3900 1 0 0 in_port.sym  
{
T 2600 3900 5 10 1 1 0 6 1 1 
refdes=rxd_data_avail_stb
}
C 2600 4300 1 0 0 in_port.sym  
{
T 2600 4300 5 10 1 1 0 6 1 1 
refdes=rts_in
}
C 2600 4700 1 0 0 in_port.sym  
{
T 2600 4700 5 10 1 1 0 6 1 1 
refdes=reset
}
C 2600 5100 1 0 0 in_port.sym  
{
T 2600 5100 5 10 1 1 0 6 1 1 
refdes=parity_enable
}
C 2600 5500 1 0 0 in_port.sym  
{
T 2600 5500 5 10 1 1 0 6 1 1 
refdes=cts_pad_in
}
C 2600 5900 1 0 0 in_port.sym  
{
T 2600 5900 5 10 1 1 0 6 1 1 
refdes=clk
}
C 6100 300  1 0  0 out_port_v.sym
{
T 7100 300 5  10 1 1 0 0 1 1 
refdes=rxd_data_out[SIZE-1:0]
}
C 6100 700  1 0 0 out_port.sym
{
T 7100 700 5  10 1 1 0 0 1 1
refdes=txd_pad_out
}
C 6100 1100  1 0 0 out_port.sym
{
T 7100 1100 5  10 1 1 0 0 1 1
refdes=txd_buffer_empty
}
C 6100 1500  1 0 0 out_port.sym
{
T 7100 1500 5  10 1 1 0 0 1 1
refdes=rxd_stop_error
}
C 6100 1900  1 0 0 out_port.sym
{
T 7100 1900 5  10 1 1 0 0 1 1
refdes=rxd_parity_error
}
C 6100 2300  1 0 0 out_port.sym
{
T 7100 2300 5  10 1 1 0 0 1 1
refdes=rxd_data_avail_IRQ
}
C 6100 2700  1 0 0 out_port.sym
{
T 7100 2700 5  10 1 1 0 0 1 1
refdes=rxd_data_avail
}
C 6100 3100  1 0 0 out_port.sym
{
T 7100 3100 5  10 1 1 0 0 1 1
refdes=rts_pad_out
}
C 6100 3500  1 0 0 out_port.sym
{
T 7100 3500 5  10 1 1 0 0 1 1
refdes=cts_out
}
