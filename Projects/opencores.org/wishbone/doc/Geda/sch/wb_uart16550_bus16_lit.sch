v 20100214 1
C 1600 300 1 0 0 in_port_v.sym   
{
T 1600 300 5 10 1 1 0 6 1 1
refdes=wb_sel_i[1:0]
}
C 1600 700 1 0 0 in_port_v.sym   
{
T 1600 700 5 10 1 1 0 6 1 1
refdes=wb_dat_i[15:0]
}
C 1600 1100 1 0 0 in_port_v.sym   
{
T 1600 1100 5 10 1 1 0 6 1 1
refdes=wb_adr_i[7:1]
}
C 1600 1500 1 0 0 in_port.sym  
{
T 1600 1500 5 10 1 1 0 6 1 1 
refdes=wb_we_i
}
C 1600 1900 1 0 0 in_port.sym  
{
T 1600 1900 5 10 1 1 0 6 1 1 
refdes=wb_stb_i
}
C 1600 2300 1 0 0 in_port.sym  
{
T 1600 2300 5 10 1 1 0 6 1 1 
refdes=wb_rst_i
}
C 1600 2700 1 0 0 in_port.sym  
{
T 1600 2700 5 10 1 1 0 6 1 1 
refdes=wb_cyc_i
}
C 1600 3100 1 0 0 in_port.sym  
{
T 1600 3100 5 10 1 1 0 6 1 1 
refdes=wb_clk_i
}
C 1600 3500 1 0 0 in_port.sym  
{
T 1600 3500 5 10 1 1 0 6 1 1 
refdes=srx_pad_i
}
C 1600 3900 1 0 0 in_port.sym  
{
T 1600 3900 5 10 1 1 0 6 1 1 
refdes=ri_pad_i
}
C 1600 4300 1 0 0 in_port.sym  
{
T 1600 4300 5 10 1 1 0 6 1 1 
refdes=dsr_pad_i
}
C 1600 4700 1 0 0 in_port.sym  
{
T 1600 4700 5 10 1 1 0 6 1 1 
refdes=dcd_pad_i
}
C 1600 5100 1 0 0 in_port.sym  
{
T 1600 5100 5 10 1 1 0 6 1 1 
refdes=cts_pad_i
}
C 4300 300  1 0  0 out_port_v.sym
{
T 5300 300 5  10 1 1 0 0 1 1 
refdes=wb_dat_o[15:0]
}
C 4300 700  1 0 0 out_port.sym
{
T 5300 700 5  10 1 1 0 0 1 1
refdes=wb_ack_o
}
C 4300 1100  1 0 0 out_port.sym
{
T 5300 1100 5  10 1 1 0 0 1 1
refdes=stx_pad_o
}
C 4300 1500  1 0 0 out_port.sym
{
T 5300 1500 5  10 1 1 0 0 1 1
refdes=rts_pad_o
}
C 4300 1900  1 0 0 out_port.sym
{
T 5300 1900 5  10 1 1 0 0 1 1
refdes=int_o
}
C 4300 2300  1 0 0 out_port.sym
{
T 5300 2300 5  10 1 1 0 0 1 1
refdes=dtr_pad_o
}
C 4300 2700  1 0 0 out_port.sym
{
T 5300 2700 5  10 1 1 0 0 1 1
refdes=baud_o
}
