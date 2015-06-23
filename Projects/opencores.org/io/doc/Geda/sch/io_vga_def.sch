v 20100214 1
C 1200 300 1 0 0 in_port_v.sym   
{
T 1200 300 5 10 1 1 0 6 1 1
refdes=wdata[7:0]
}
C 1200 700 1 0 0 in_port_v.sym   
{
T 1200 700 5 10 1 1 0 6 1 1
refdes=addr[3:0]
}
C 1200 1100 1 0 0 in_port.sym  
{
T 1200 1100 5 10 1 1 0 6 1 1 
refdes=wr
}
C 1200 1500 1 0 0 in_port.sym  
{
T 1200 1500 5 10 1 1 0 6 1 1 
refdes=reset
}
C 1200 1900 1 0 0 in_port.sym  
{
T 1200 1900 5 10 1 1 0 6 1 1 
refdes=rd
}
C 1200 2300 1 0 0 in_port.sym  
{
T 1200 2300 5 10 1 1 0 6 1 1 
refdes=enable
}
C 1200 2700 1 0 0 in_port.sym  
{
T 1200 2700 5 10 1 1 0 6 1 1 
refdes=cs
}
C 1200 3100 1 0 0 in_port.sym  
{
T 1200 3100 5 10 1 1 0 6 1 1 
refdes=clk
}
C 4700 300  1 0  0 out_port_v.sym
{
T 5700 300 5  10 1 1 0 0 1 1 
refdes=vga_red_pad_out[2:0]
}
C 4700 700  1 0  0 out_port_v.sym
{
T 5700 700 5  10 1 1 0 0 1 1 
refdes=vga_green_pad_out[2:0]
}
C 4700 1100  1 0  0 out_port_v.sym
{
T 5700 1100 5  10 1 1 0 0 1 1 
refdes=vga_blue_pad_out[1:0]
}
C 4700 1500  1 0  0 out_port_v.sym
{
T 5700 1500 5  10 1 1 0 0 1 1 
refdes=rdata[7:0]
}
C 4700 1900  1 0 0 out_port.sym
{
T 5700 1900 5  10 1 1 0 0 1 1
refdes=vga_vsync_n_pad_out
}
C 4700 2300  1 0 0 out_port.sym
{
T 5700 2300 5  10 1 1 0 0 1 1
refdes=vga_hsync_n_pad_out
}
