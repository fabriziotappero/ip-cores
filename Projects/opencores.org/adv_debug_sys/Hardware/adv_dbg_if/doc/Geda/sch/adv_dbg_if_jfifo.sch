v 20100214 1
C 1900 300 1 0 0 in_port_v.sym   
{
T 1900 300 5 10 1 1 0 6 1 1
refdes=wb_jsp_dat_i[7:0]
}
C 1900 700 1 0 0 in_port.sym  
{
T 1900 700 5 10 1 1 0 6 1 1 
refdes=wb_jsp_stb_i
}
C 1900 1100 1 0 0 in_port.sym  
{
T 1900 1100 5 10 1 1 0 6 1 1 
refdes=wb_clk_i
}
C 1900 1500 1 0 0 in_port.sym  
{
T 1900 1500 5 10 1 1 0 6 1 1 
refdes=update_dr_i
}
C 1900 1900 1 0 0 in_port.sym  
{
T 1900 1900 5 10 1 1 0 6 1 1 
refdes=tdi_i
}
C 1900 2300 1 0 0 in_port.sym  
{
T 1900 2300 5 10 1 1 0 6 1 1 
refdes=tck_i
}
C 1900 2700 1 0 0 in_port.sym  
{
T 1900 2700 5 10 1 1 0 6 1 1 
refdes=shift_dr_i
}
C 1900 3100 1 0 0 in_port.sym  
{
T 1900 3100 5 10 1 1 0 6 1 1 
refdes=rst_i
}
C 1900 3500 1 0 0 in_port.sym  
{
T 1900 3500 5 10 1 1 0 6 1 1 
refdes=debug_select_i
}
C 1900 3900 1 0 0 in_port.sym  
{
T 1900 3900 5 10 1 1 0 6 1 1 
refdes=capture_dr_i
}
C 4900 300  1 0  0 out_port_v.sym
{
T 5900 300 5  10 1 1 0 0 1 1 
refdes=jsp_data_out[7:0]
}
C 4900 700  1 0 0 out_port.sym
{
T 5900 700 5  10 1 1 0 0 1 1
refdes=tdo_o
}
C 4900 1100  1 0 0 out_port.sym
{
T 5900 1100 5  10 1 1 0 0 1 1
refdes=biu_wr_strobe
}
