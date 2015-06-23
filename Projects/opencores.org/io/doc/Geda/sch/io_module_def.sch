v 20100214 1
C 1900 300 1 0 0 in_port_v.sym   
{
T 1900 300 5 10 1 1 0 6 1 1
refdes=vic_irq_in[7:0]
}
C 1900 700 1 0 0 in_port_v.sym   
{
T 1900 700 5 10 1 1 0 6 1 1
refdes=reg_mb_wdata[7:0]
}
C 1900 1100 1 0 0 in_port_v.sym   
{
T 1900 1100 5 10 1 1 0 6 1 1
refdes=reg_mb_addr[7:0]
}
C 1900 1500 1 0 0 in_port_v.sym   
{
T 1900 1500 5 10 1 1 0 6 1 1
refdes=pic_irq_in[7:0]
}
C 1900 1900 1 0 0 in_port_v.sym   
{
T 1900 1900 5 10 1 1 0 6 1 1
refdes=mem_wdata[15:0]
}
C 1900 2300 1 0 0 in_port_v.sym   
{
T 1900 2300 5 10 1 1 0 6 1 1
refdes=mem_addr[13:0]
}
C 1900 2700 1 0 0 in_port_v.sym   
{
T 1900 2700 5 10 1 1 0 6 1 1
refdes=gpio_1_in[7:0]
}
C 1900 3100 1 0 0 in_port_v.sym   
{
T 1900 3100 5 10 1 1 0 6 1 1
refdes=gpio_0_in[7:0]
}
C 1900 3500 1 0 0 in_port_v.sym   
{
T 1900 3500 5 10 1 1 0 6 1 1
refdes=ext_rdata[15:0]
}
C 1900 3900 1 0 0 in_port.sym  
{
T 1900 3900 5 10 1 1 0 6 1 1 
refdes=uart_rxd_pad_in
}
C 1900 4300 1 0 0 in_port.sym  
{
T 1900 4300 5 10 1 1 0 6 1 1 
refdes=reset
}
C 1900 4700 1 0 0 in_port.sym  
{
T 1900 4700 5 10 1 1 0 6 1 1 
refdes=reg_mb_wr
}
C 1900 5100 1 0 0 in_port.sym  
{
T 1900 5100 5 10 1 1 0 6 1 1 
refdes=reg_mb_rd
}
C 1900 5500 1 0 0 in_port.sym  
{
T 1900 5500 5 10 1 1 0 6 1 1 
refdes=reg_mb_cs
}
C 1900 5900 1 0 0 in_port.sym  
{
T 1900 5900 5 10 1 1 0 6 1 1 
refdes=ps2_data_pad_in
}
C 1900 6300 1 0 0 in_port.sym  
{
T 1900 6300 5 10 1 1 0 6 1 1 
refdes=ps2_clk_pad_in
}
C 1900 6700 1 0 0 in_port.sym  
{
T 1900 6700 5 10 1 1 0 6 1 1 
refdes=mem_wr
}
C 1900 7100 1 0 0 in_port.sym  
{
T 1900 7100 5 10 1 1 0 6 1 1 
refdes=mem_rd
}
C 1900 7500 1 0 0 in_port.sym  
{
T 1900 7500 5 10 1 1 0 6 1 1 
refdes=mem_cs
}
C 1900 7900 1 0 0 in_port.sym  
{
T 1900 7900 5 10 1 1 0 6 1 1 
refdes=ext_wait
}
C 1900 8300 1 0 0 in_port.sym  
{
T 1900 8300 5 10 1 1 0 6 1 1 
refdes=enable
}
C 1900 8700 1 0 0 in_port.sym  
{
T 1900 8700 5 10 1 1 0 6 1 1 
refdes=cts_pad_in
}
C 1900 9100 1 0 0 in_port.sym  
{
T 1900 9100 5 10 1 1 0 6 1 1 
refdes=clk
}
C 5400 300  1 0  0 out_port_v.sym
{
T 6400 300 5  10 1 1 0 0 1 1 
refdes=y_pos[9:0]
}
C 5400 700  1 0  0 out_port_v.sym
{
T 6400 700 5  10 1 1 0 0 1 1 
refdes=x_pos[9:0]
}
C 5400 1100  1 0  0 out_port_v.sym
{
T 6400 1100 5  10 1 1 0 0 1 1 
refdes=vga_red_pad_out[2:0]
}
C 5400 1500  1 0  0 out_port_v.sym
{
T 6400 1500 5  10 1 1 0 0 1 1 
refdes=vga_green_pad_out[2:0]
}
C 5400 1900  1 0  0 out_port_v.sym
{
T 6400 1900 5  10 1 1 0 0 1 1 
refdes=vga_blue_pad_out[1:0]
}
C 5400 2300  1 0  0 out_port_v.sym
{
T 6400 2300 5  10 1 1 0 0 1 1 
refdes=vector[7:0]
}
C 5400 2700  1 0  0 out_port_v.sym
{
T 6400 2700 5  10 1 1 0 0 1 1 
refdes=timer_irq[1:0]
}
C 5400 3100  1 0  0 out_port_v.sym
{
T 6400 3100 5  10 1 1 0 0 1 1 
refdes=reg_mb_rdata[15:0]
}
C 5400 3500  1 0  0 out_port_v.sym
{
T 6400 3500 5  10 1 1 0 0 1 1 
refdes=mem_rdata[15:0]
}
C 5400 3900  1 0  0 out_port_v.sym
{
T 6400 3900 5  10 1 1 0 0 1 1 
refdes=gpio_1_out[7:0]
}
C 5400 4300  1 0  0 out_port_v.sym
{
T 6400 4300 5  10 1 1 0 0 1 1 
refdes=gpio_1_oe[7:0]
}
C 5400 4700  1 0  0 out_port_v.sym
{
T 6400 4700 5  10 1 1 0 0 1 1 
refdes=gpio_0_out[7:0]
}
C 5400 5100  1 0  0 out_port_v.sym
{
T 6400 5100 5  10 1 1 0 0 1 1 
refdes=gpio_0_oe[7:0]
}
C 5400 5500  1 0  0 out_port_v.sym
{
T 6400 5500 5  10 1 1 0 0 1 1 
refdes=ext_wdata[15:0]
}
C 5400 5900  1 0  0 out_port_v.sym
{
T 6400 5900 5  10 1 1 0 0 1 1 
refdes=ext_cs[1:0]
}
C 5400 6300  1 0  0 out_port_v.sym
{
T 6400 6300 5  10 1 1 0 0 1 1 
refdes=ext_addr[23:1]
}
C 5400 6700  1 0 0 out_port.sym
{
T 6400 6700 5  10 1 1 0 0 1 1
refdes=vga_vsync_n_pad_out
}
C 5400 7100  1 0 0 out_port.sym
{
T 6400 7100 5  10 1 1 0 0 1 1
refdes=vga_hsync_n_pad_out
}
C 5400 7500  1 0 0 out_port.sym
{
T 6400 7500 5  10 1 1 0 0 1 1
refdes=uart_txd_pad_out
}
C 5400 7900  1 0 0 out_port.sym
{
T 6400 7900 5  10 1 1 0 0 1 1
refdes=tx_irq
}
C 5400 8300  1 0 0 out_port.sym
{
T 6400 8300 5  10 1 1 0 0 1 1
refdes=rx_irq
}
C 5400 8700  1 0 0 out_port.sym
{
T 6400 8700 5  10 1 1 0 0 1 1
refdes=rts_pad_out
}
C 5400 9100  1 0 0 out_port.sym
{
T 6400 9100 5  10 1 1 0 0 1 1
refdes=reg_mb_wait
}
C 5400 9500  1 0 0 out_port.sym
{
T 6400 9500 5  10 1 1 0 0 1 1
refdes=ps2_data_pad_oe
}
C 5400 9900  1 0 0 out_port.sym
{
T 6400 9900 5  10 1 1 0 0 1 1
refdes=ps2_data_avail
}
C 5400 10300  1 0 0 out_port.sym
{
T 6400 10300 5  10 1 1 0 0 1 1
refdes=ps2_clk_pad_oe
}
C 5400 10700  1 0 0 out_port.sym
{
T 6400 10700 5  10 1 1 0 0 1 1
refdes=pic_nmi
}
C 5400 11100  1 0 0 out_port.sym
{
T 6400 11100 5  10 1 1 0 0 1 1
refdes=pic_irq
}
C 5400 11500  1 0 0 out_port.sym
{
T 6400 11500 5  10 1 1 0 0 1 1
refdes=new_packet
}
C 5400 11900  1 0 0 out_port.sym
{
T 6400 11900 5  10 1 1 0 0 1 1
refdes=ms_right
}
C 5400 12300  1 0 0 out_port.sym
{
T 6400 12300 5  10 1 1 0 0 1 1
refdes=ms_mid
}
C 5400 12700  1 0 0 out_port.sym
{
T 6400 12700 5  10 1 1 0 0 1 1
refdes=ms_left
}
C 5400 13100  1 0 0 out_port.sym
{
T 6400 13100 5  10 1 1 0 0 1 1
refdes=mem_wait
}
C 5400 13500  1 0 0 out_port.sym
{
T 6400 13500 5  10 1 1 0 0 1 1
refdes=int_out
}
C 5400 13900  1 0 0 out_port.sym
{
T 6400 13900 5  10 1 1 0 0 1 1
refdes=ext_wr
}
C 5400 14300  1 0 0 out_port.sym
{
T 6400 14300 5  10 1 1 0 0 1 1
refdes=ext_ub
}
C 5400 14700  1 0 0 out_port.sym
{
T 6400 14700 5  10 1 1 0 0 1 1
refdes=ext_stb
}
C 5400 15100  1 0 0 out_port.sym
{
T 6400 15100 5  10 1 1 0 0 1 1
refdes=ext_rd
}
C 5400 15500  1 0 0 out_port.sym
{
T 6400 15500 5  10 1 1 0 0 1 1
refdes=ext_lb
}
