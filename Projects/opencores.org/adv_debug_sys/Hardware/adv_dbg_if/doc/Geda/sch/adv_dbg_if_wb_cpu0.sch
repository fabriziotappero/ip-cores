v 20100214 1
C 1900 300 1 0 0 in_port_v.sym   
{
T 1900 300 5 10 1 1 0 6 1 1
refdes=wb_dat_i[31:0]
}
C 1900 700 1 0 0 in_port_v.sym   
{
T 1900 700 5 10 1 1 0 6 1 1
refdes=cpu0_data_i[31:0]
}
C 1900 1100 1 0 0 in_port.sym  
{
T 1900 1100 5 10 1 1 0 6 1 1 
refdes=wb_rst_i
}
C 1900 1500 1 0 0 in_port.sym  
{
T 1900 1500 5 10 1 1 0 6 1 1 
refdes=wb_err_i
}
C 1900 1900 1 0 0 in_port.sym  
{
T 1900 1900 5 10 1 1 0 6 1 1 
refdes=wb_clk_i
}
C 1900 2300 1 0 0 in_port.sym  
{
T 1900 2300 5 10 1 1 0 6 1 1 
refdes=wb_ack_i
}
C 1900 2700 1 0 0 in_port.sym  
{
T 1900 2700 5 10 1 1 0 6 1 1 
refdes=update_dr_i
}
C 1900 3100 1 0 0 in_port.sym  
{
T 1900 3100 5 10 1 1 0 6 1 1 
refdes=tdi_i
}
C 1900 3500 1 0 0 in_port.sym  
{
T 1900 3500 5 10 1 1 0 6 1 1 
refdes=tck_i
}
C 1900 3900 1 0 0 in_port.sym  
{
T 1900 3900 5 10 1 1 0 6 1 1 
refdes=shift_dr_i
}
C 1900 4300 1 0 0 in_port.sym  
{
T 1900 4300 5 10 1 1 0 6 1 1 
refdes=rst_i
}
C 1900 4700 1 0 0 in_port.sym  
{
T 1900 4700 5 10 1 1 0 6 1 1 
refdes=debug_select_i
}
C 1900 5100 1 0 0 in_port.sym  
{
T 1900 5100 5 10 1 1 0 6 1 1 
refdes=cpu0_clk_i
}
C 1900 5500 1 0 0 in_port.sym  
{
T 1900 5500 5 10 1 1 0 6 1 1 
refdes=cpu0_bp_i
}
C 1900 5900 1 0 0 in_port.sym  
{
T 1900 5900 5 10 1 1 0 6 1 1 
refdes=cpu0_ack_i
}
C 1900 6300 1 0 0 in_port.sym  
{
T 1900 6300 5 10 1 1 0 6 1 1 
refdes=capture_dr_i
}
C 4900 300  1 0  0 out_port_v.sym
{
T 5900 300 5  10 1 1 0 0 1 1 
refdes=wb_sel_o[3:0]
}
C 4900 700  1 0  0 out_port_v.sym
{
T 5900 700 5  10 1 1 0 0 1 1 
refdes=wb_dat_o[31:0]
}
C 4900 1100  1 0  0 out_port_v.sym
{
T 5900 1100 5  10 1 1 0 0 1 1 
refdes=wb_cti_o[2:0]
}
C 4900 1500  1 0  0 out_port_v.sym
{
T 5900 1500 5  10 1 1 0 0 1 1 
refdes=wb_bte_o[1:0]
}
C 4900 1900  1 0  0 out_port_v.sym
{
T 5900 1900 5  10 1 1 0 0 1 1 
refdes=wb_adr_o[31:0]
}
C 4900 2300  1 0  0 out_port_v.sym
{
T 5900 2300 5  10 1 1 0 0 1 1 
refdes=cpu0_data_o[31:0]
}
C 4900 2700  1 0  0 out_port_v.sym
{
T 5900 2700 5  10 1 1 0 0 1 1 
refdes=cpu0_addr_o[31:0]
}
C 4900 3100  1 0 0 out_port.sym
{
T 5900 3100 5  10 1 1 0 0 1 1
refdes=wb_we_o
}
C 4900 3500  1 0 0 out_port.sym
{
T 5900 3500 5  10 1 1 0 0 1 1
refdes=wb_stb_o
}
C 4900 3900  1 0 0 out_port.sym
{
T 5900 3900 5  10 1 1 0 0 1 1
refdes=wb_cyc_o
}
C 4900 4300  1 0 0 out_port.sym
{
T 5900 4300 5  10 1 1 0 0 1 1
refdes=wb_cab_o
}
C 4900 4700  1 0 0 out_port.sym
{
T 5900 4700 5  10 1 1 0 0 1 1
refdes=tdo_o
}
C 4900 5100  1 0 0 out_port.sym
{
T 5900 5100 5  10 1 1 0 0 1 1
refdes=cpu0_we_o
}
C 4900 5500  1 0 0 out_port.sym
{
T 5900 5500 5  10 1 1 0 0 1 1
refdes=cpu0_stb_o
}
C 4900 5900  1 0 0 out_port.sym
{
T 5900 5900 5  10 1 1 0 0 1 1
refdes=cpu0_stall_o
}
C 4900 6300  1 0 0 out_port.sym
{
T 5900 6300 5  10 1 1 0 0 1 1
refdes=cpu0_rst_o
}
