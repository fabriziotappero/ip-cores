v 20100214 1
C 2900 300 1 0 0 in_port_v.sym   
{
T 2900 300 5 10 1 1 0 6 1 1
refdes=wb_dat_i[wb_data_width-1:0]
}
C 2900 700 1 0 0 in_port_v.sym   
{
T 2900 700 5 10 1 1 0 6 1 1
refdes=wb_adr_i[wb_addr_width-1:0]
}
C 2900 1100 1 0 0 in_port.sym  
{
T 2900 1100 5 10 1 1 0 6 1 1 
refdes=wb_we_i
}
C 2900 1500 1 0 0 in_port.sym  
{
T 2900 1500 5 10 1 1 0 6 1 1 
refdes=wb_stb_i
}
C 2900 1900 1 0 0 in_port.sym  
{
T 2900 1900 5 10 1 1 0 6 1 1 
refdes=wb_sel_i
}
C 2900 2300 1 0 0 in_port.sym  
{
T 2900 2300 5 10 1 1 0 6 1 1 
refdes=wb_rst_i
}
C 2900 2700 1 0 0 in_port.sym  
{
T 2900 2700 5 10 1 1 0 6 1 1 
refdes=wb_cyc_i
}
C 2900 3100 1 0 0 in_port.sym  
{
T 2900 3100 5 10 1 1 0 6 1 1 
refdes=wb_clk_i
}
C 2900 3500 1 0 0 in_port.sym  
{
T 2900 3500 5 10 1 1 0 6 1 1 
refdes=srx_pad_i
}
C 2900 3900 1 0 0 in_port.sym  
{
T 2900 3900 5 10 1 1 0 6 1 1 
refdes=ri_pad_i
}
C 2900 4300 1 0 0 in_port.sym  
{
T 2900 4300 5 10 1 1 0 6 1 1 
refdes=dsr_pad_i
}
C 2900 4700 1 0 0 in_port.sym  
{
T 2900 4700 5 10 1 1 0 6 1 1 
refdes=dcd_pad_i
}
C 2900 5100 1 0 0 in_port.sym  
{
T 2900 5100 5 10 1 1 0 6 1 1 
refdes=cts_pad_i
}
C 6900 300  1 0  0 out_port_v.sym
{
T 7900 300 5  10 1 1 0 0 1 1 
refdes=wb_dat_o[wb_data_width-1:0]
}
C 6900 700  1 0 0 out_port.sym
{
T 7900 700 5  10 1 1 0 0 1 1
refdes=wb_ack_o
}
C 6900 1100  1 0 0 out_port.sym
{
T 7900 1100 5  10 1 1 0 0 1 1
refdes=stx_pad_o
}
C 6900 1500  1 0 0 out_port.sym
{
T 7900 1500 5  10 1 1 0 0 1 1
refdes=rts_pad_o
}
C 6900 1900  1 0 0 out_port.sym
{
T 7900 1900 5  10 1 1 0 0 1 1
refdes=int_o
}
C 6900 2300  1 0 0 out_port.sym
{
T 7900 2300 5  10 1 1 0 0 1 1
refdes=dtr_pad_o
}
C 6900 2700  1 0 0 out_port.sym
{
T 7900 2700 5  10 1 1 0 0 1 1
refdes=baud_o
}
