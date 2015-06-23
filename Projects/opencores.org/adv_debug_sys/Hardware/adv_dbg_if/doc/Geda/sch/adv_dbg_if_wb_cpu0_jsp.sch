v 20100214 1
C 2000 300 1 0 0 in_port_v.sym   
{
T 2000 300 5 10 1 1 0 6 1 1
refdes=wb_jsp_sel_i[3:0]
}
C 2000 700 1 0 0 in_port_v.sym   
{
T 2000 700 5 10 1 1 0 6 1 1
refdes=wb_jsp_dat_i[31:0]
}
C 2000 1100 1 0 0 in_port_v.sym   
{
T 2000 1100 5 10 1 1 0 6 1 1
refdes=wb_jsp_cti_i[2:0]
}
C 2000 1500 1 0 0 in_port_v.sym   
{
T 2000 1500 5 10 1 1 0 6 1 1
refdes=wb_jsp_bte_i[1:0]
}
C 2000 1900 1 0 0 in_port_v.sym   
{
T 2000 1900 5 10 1 1 0 6 1 1
refdes=wb_jsp_adr_i[31:0]
}
C 2000 2300 1 0 0 in_port_v.sym   
{
T 2000 2300 5 10 1 1 0 6 1 1
refdes=wb_dat_i[31:0]
}
C 2000 2700 1 0 0 in_port_v.sym   
{
T 2000 2700 5 10 1 1 0 6 1 1
refdes=cpu0_data_i[31:0]
}
C 2000 3100 1 0 0 in_port.sym  
{
T 2000 3100 5 10 1 1 0 6 1 1 
refdes=wb_rst_i
}
C 2000 3500 1 0 0 in_port.sym  
{
T 2000 3500 5 10 1 1 0 6 1 1 
refdes=wb_jsp_we_i
}
C 2000 3900 1 0 0 in_port.sym  
{
T 2000 3900 5 10 1 1 0 6 1 1 
refdes=wb_jsp_stb_i
}
C 2000 4300 1 0 0 in_port.sym  
{
T 2000 4300 5 10 1 1 0 6 1 1 
refdes=wb_jsp_cyc_i
}
C 2000 4700 1 0 0 in_port.sym  
{
T 2000 4700 5 10 1 1 0 6 1 1 
refdes=wb_jsp_cab_i
}
C 2000 5100 1 0 0 in_port.sym  
{
T 2000 5100 5 10 1 1 0 6 1 1 
refdes=wb_err_i
}
C 2000 5500 1 0 0 in_port.sym  
{
T 2000 5500 5 10 1 1 0 6 1 1 
refdes=wb_clk_i
}
C 2000 5900 1 0 0 in_port.sym  
{
T 2000 5900 5 10 1 1 0 6 1 1 
refdes=wb_ack_i
}
C 2000 6300 1 0 0 in_port.sym  
{
T 2000 6300 5 10 1 1 0 6 1 1 
refdes=update_dr_i
}
C 2000 6700 1 0 0 in_port.sym  
{
T 2000 6700 5 10 1 1 0 6 1 1 
refdes=tdi_i
}
C 2000 7100 1 0 0 in_port.sym  
{
T 2000 7100 5 10 1 1 0 6 1 1 
refdes=tck_i
}
C 2000 7500 1 0 0 in_port.sym  
{
T 2000 7500 5 10 1 1 0 6 1 1 
refdes=shift_dr_i
}
C 2000 7900 1 0 0 in_port.sym  
{
T 2000 7900 5 10 1 1 0 6 1 1 
refdes=rst_i
}
C 2000 8300 1 0 0 in_port.sym  
{
T 2000 8300 5 10 1 1 0 6 1 1 
refdes=debug_select_i
}
C 2000 8700 1 0 0 in_port.sym  
{
T 2000 8700 5 10 1 1 0 6 1 1 
refdes=cpu0_clk_i
}
C 2000 9100 1 0 0 in_port.sym  
{
T 2000 9100 5 10 1 1 0 6 1 1 
refdes=cpu0_bp_i
}
C 2000 9500 1 0 0 in_port.sym  
{
T 2000 9500 5 10 1 1 0 6 1 1 
refdes=cpu0_ack_i
}
C 2000 9900 1 0 0 in_port.sym  
{
T 2000 9900 5 10 1 1 0 6 1 1 
refdes=capture_dr_i
}
C 5100 300  1 0  0 out_port_v.sym
{
T 6100 300 5  10 1 1 0 0 1 1 
refdes=wb_sel_o[3:0]
}
C 5100 700  1 0  0 out_port_v.sym
{
T 6100 700 5  10 1 1 0 0 1 1 
refdes=wb_jsp_dat_o[31:0]
}
C 5100 1100  1 0  0 out_port_v.sym
{
T 6100 1100 5  10 1 1 0 0 1 1 
refdes=wb_dat_o[31:0]
}
C 5100 1500  1 0  0 out_port_v.sym
{
T 6100 1500 5  10 1 1 0 0 1 1 
refdes=wb_cti_o[2:0]
}
C 5100 1900  1 0  0 out_port_v.sym
{
T 6100 1900 5  10 1 1 0 0 1 1 
refdes=wb_bte_o[1:0]
}
C 5100 2300  1 0  0 out_port_v.sym
{
T 6100 2300 5  10 1 1 0 0 1 1 
refdes=wb_adr_o[31:0]
}
C 5100 2700  1 0  0 out_port_v.sym
{
T 6100 2700 5  10 1 1 0 0 1 1 
refdes=jsp_data_out[7:0]
}
C 5100 3100  1 0  0 out_port_v.sym
{
T 6100 3100 5  10 1 1 0 0 1 1 
refdes=cpu0_data_o[31:0]
}
C 5100 3500  1 0  0 out_port_v.sym
{
T 6100 3500 5  10 1 1 0 0 1 1 
refdes=cpu0_addr_o[31:0]
}
C 5100 3900  1 0 0 out_port.sym
{
T 6100 3900 5  10 1 1 0 0 1 1
refdes=wb_we_o
}
C 5100 4300  1 0 0 out_port.sym
{
T 6100 4300 5  10 1 1 0 0 1 1
refdes=wb_stb_o
}
C 5100 4700  1 0 0 out_port.sym
{
T 6100 4700 5  10 1 1 0 0 1 1
refdes=wb_jsp_err_o
}
C 5100 5100  1 0 0 out_port.sym
{
T 6100 5100 5  10 1 1 0 0 1 1
refdes=wb_jsp_ack_o
}
C 5100 5500  1 0 0 out_port.sym
{
T 6100 5500 5  10 1 1 0 0 1 1
refdes=wb_cyc_o
}
C 5100 5900  1 0 0 out_port.sym
{
T 6100 5900 5  10 1 1 0 0 1 1
refdes=wb_cab_o
}
C 5100 6300  1 0 0 out_port.sym
{
T 6100 6300 5  10 1 1 0 0 1 1
refdes=tdo_o
}
C 5100 6700  1 0 0 out_port.sym
{
T 6100 6700 5  10 1 1 0 0 1 1
refdes=int_o
}
C 5100 7100  1 0 0 out_port.sym
{
T 6100 7100 5  10 1 1 0 0 1 1
refdes=cpu0_we_o
}
C 5100 7500  1 0 0 out_port.sym
{
T 6100 7500 5  10 1 1 0 0 1 1
refdes=cpu0_stb_o
}
C 5100 7900  1 0 0 out_port.sym
{
T 6100 7900 5  10 1 1 0 0 1 1
refdes=cpu0_stall_o
}
C 5100 8300  1 0 0 out_port.sym
{
T 6100 8300 5  10 1 1 0 0 1 1
refdes=cpu0_rst_o
}
C 5100 8700  1 0 0 out_port.sym
{
T 6100 8700 5  10 1 1 0 0 1 1
refdes=biu_wr_strobe
}
