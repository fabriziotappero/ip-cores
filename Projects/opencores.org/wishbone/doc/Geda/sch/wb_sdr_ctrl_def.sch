v 20100214 1
C 3900 300 1 0 0 in_port_v.sym   
{
T 3900 300 5 10 1 1 0 6 1 1
refdes=wb_sel_i[3:0]
}
C 3900 700 1 0 0 in_port_v.sym   
{
T 3900 700 5 10 1 1 0 6 1 1
refdes=wb_dat_i[31:0]
}
C 3900 1100 1 0 0 in_port_v.sym   
{
T 3900 1100 5 10 1 1 0 6 1 1
refdes=wb_addr_i[24:0]
}
C 3900 1500 1 0 0 in_port_v.sym   
{
T 3900 1500 5 10 1 1 0 6 1 1
refdes=sdr_din[SDR_DW-1:0]
}
C 3900 1900 1 0 0 in_port_v.sym   
{
T 3900 1900 5 10 1 1 0 6 1 1
refdes=cfg_sdr_width[1:0]
}
C 3900 2300 1 0 0 in_port_v.sym   
{
T 3900 2300 5 10 1 1 0 6 1 1
refdes=cfg_sdr_twr_d[3:0]
}
C 3900 2700 1 0 0 in_port_v.sym   
{
T 3900 2700 5 10 1 1 0 6 1 1
refdes=cfg_sdr_trp_d[3:0]
}
C 3900 3100 1 0 0 in_port_v.sym   
{
T 3900 3100 5 10 1 1 0 6 1 1
refdes=cfg_sdr_trcd_d[3:0]
}
C 3900 3500 1 0 0 in_port_v.sym   
{
T 3900 3500 5 10 1 1 0 6 1 1
refdes=cfg_sdr_trcar_d[3:0]
}
C 3900 3900 1 0 0 in_port_v.sym   
{
T 3900 3900 5 10 1 1 0 6 1 1
refdes=cfg_sdr_tras_d[3:0]
}
C 3900 4300 1 0 0 in_port_v.sym   
{
T 3900 4300 5 10 1 1 0 6 1 1
refdes=cfg_sdr_rfsh[SDR_RFSH_TIMER_W-1:0]
}
C 3900 4700 1 0 0 in_port_v.sym   
{
T 3900 4700 5 10 1 1 0 6 1 1
refdes=cfg_sdr_rfmax[SDR_RFSH_ROW_CNT_W-1:0]
}
C 3900 5100 1 0 0 in_port_v.sym   
{
T 3900 5100 5 10 1 1 0 6 1 1
refdes=cfg_sdr_mode_reg[11:0]
}
C 3900 5500 1 0 0 in_port_v.sym   
{
T 3900 5500 5 10 1 1 0 6 1 1
refdes=cfg_sdr_cas[2:0]
}
C 3900 5900 1 0 0 in_port_v.sym   
{
T 3900 5900 5 10 1 1 0 6 1 1
refdes=cfg_req_depth[1:0]
}
C 3900 6300 1 0 0 in_port_v.sym   
{
T 3900 6300 5 10 1 1 0 6 1 1
refdes=cfg_colbits[1:0]
}
C 3900 6700 1 0 0 in_port.sym  
{
T 3900 6700 5 10 1 1 0 6 1 1 
refdes=wb_we_i
}
C 3900 7100 1 0 0 in_port.sym  
{
T 3900 7100 5 10 1 1 0 6 1 1 
refdes=wb_stb_i
}
C 3900 7500 1 0 0 in_port.sym  
{
T 3900 7500 5 10 1 1 0 6 1 1 
refdes=wb_rst_i
}
C 3900 7900 1 0 0 in_port.sym  
{
T 3900 7900 5 10 1 1 0 6 1 1 
refdes=wb_cyc_i
}
C 3900 8300 1 0 0 in_port.sym  
{
T 3900 8300 5 10 1 1 0 6 1 1 
refdes=wb_clk_i
}
C 3900 8700 1 0 0 in_port.sym  
{
T 3900 8700 5 10 1 1 0 6 1 1 
refdes=sdram_resetn
}
C 3900 9100 1 0 0 in_port.sym  
{
T 3900 9100 5 10 1 1 0 6 1 1 
refdes=sdram_clk
}
C 3900 9500 1 0 0 in_port.sym  
{
T 3900 9500 5 10 1 1 0 6 1 1 
refdes=cfg_sdr_en
}
C 3900 9900 1 0 0 io_port_v.sym   
{
T 3900 9900 5 10 1 1 0 6 1 1
refdes=sdr_dq[SDR_DW-1:0]
}
C 7200 300  1 0  0 out_port_v.sym
{
T 8200 300 5  10 1 1 0 0 1 1 
refdes=wb_dat_o[31:0]
}
C 7200 700  1 0  0 out_port_v.sym
{
T 8200 700 5  10 1 1 0 0 1 1 
refdes=sdr_dqm[SDR_BW-1:0]
}
C 7200 1100  1 0  0 out_port_v.sym
{
T 8200 1100 5  10 1 1 0 0 1 1 
refdes=sdr_dout[SDR_DW-1:0]
}
C 7200 1500  1 0  0 out_port_v.sym
{
T 8200 1500 5  10 1 1 0 0 1 1 
refdes=sdr_ba[1:0]
}
C 7200 1900  1 0  0 out_port_v.sym
{
T 8200 1900 5  10 1 1 0 0 1 1 
refdes=sdr_addr[11:0]
}
C 7200 2300  1 0 0 out_port.sym
{
T 8200 2300 5  10 1 1 0 0 1 1
refdes=wb_ack_o
}
C 7200 2700  1 0 0 out_port.sym
{
T 8200 2700 5  10 1 1 0 0 1 1
refdes=sdr_we_n
}
C 7200 3100  1 0 0 out_port.sym
{
T 8200 3100 5  10 1 1 0 0 1 1
refdes=sdr_ras_n
}
C 7200 3500  1 0 0 out_port.sym
{
T 8200 3500 5  10 1 1 0 0 1 1
refdes=sdr_init_done
}
C 7200 3900  1 0 0 out_port.sym
{
T 8200 3900 5  10 1 1 0 0 1 1
refdes=sdr_den
}
C 7200 4300  1 0 0 out_port.sym
{
T 8200 4300 5  10 1 1 0 0 1 1
refdes=sdr_cs_n
}
C 7200 4700  1 0 0 out_port.sym
{
T 8200 4700 5  10 1 1 0 0 1 1
refdes=sdr_cke
}
C 7200 5100  1 0 0 out_port.sym
{
T 8200 5100 5  10 1 1 0 0 1 1
refdes=sdr_cas_n
}
