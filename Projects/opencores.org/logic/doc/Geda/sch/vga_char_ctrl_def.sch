v 20100214 1
C 1900 300 1 0 0 in_port_v.sym   
{
T 1900 300 5 10 1 1 0 6 1 1
refdes=wdata[7:0]
}
C 1900 700 1 0 0 in_port_v.sym   
{
T 1900 700 5 10 1 1 0 6 1 1
refdes=cursor_color[7:0]
}
C 1900 1100 1 0 0 in_port_v.sym   
{
T 1900 1100 5 10 1 1 0 6 1 1
refdes=char_color[7:0]
}
C 1900 1500 1 0 0 in_port_v.sym   
{
T 1900 1500 5 10 1 1 0 6 1 1
refdes=back_color[7:0]
}
C 1900 1900 1 0 0 in_port.sym  
{
T 1900 1900 5 10 1 1 0 6 1 1 
refdes=reset
}
C 1900 2300 1 0 0 in_port.sym  
{
T 1900 2300 5 10 1 1 0 6 1 1 
refdes=clk
}
C 1900 2700 1 0 0 in_port.sym  
{
T 1900 2700 5 10 1 1 0 6 1 1 
refdes=ascii_load
}
C 1900 3100 1 0 0 in_port.sym  
{
T 1900 3100 5 10 1 1 0 6 1 1 
refdes=add_l_load
}
C 1900 3500 1 0 0 in_port.sym  
{
T 1900 3500 5 10 1 1 0 6 1 1 
refdes=add_h_load
}
C 5000 300  1 0  0 out_port_v.sym
{
T 6000 300 5  10 1 1 0 0 1 1 
refdes=red_pad_out[2:0]
}
C 5000 700  1 0  0 out_port_v.sym
{
T 6000 700 5  10 1 1 0 0 1 1 
refdes=green_pad_out[2:0]
}
C 5000 1100  1 0  0 out_port_v.sym
{
T 6000 1100 5  10 1 1 0 0 1 1 
refdes=blue_pad_out[1:0]
}
C 5000 1500  1 0  0 out_port_v.sym
{
T 6000 1500 5  10 1 1 0 0 1 1 
refdes=address[13:0]
}
C 5000 1900  1 0 0 out_port.sym
{
T 6000 1900 5  10 1 1 0 0 1 1
refdes=vsync_n_pad_out
}
C 5000 2300  1 0 0 out_port.sym
{
T 6000 2300 5  10 1 1 0 0 1 1
refdes=hsync_n_pad_out
}
