v 20100214 1
C 1900 300 1 0 0 in_port_v.sym   
{
T 1900 300 5 10 1 1 0 6 1 1
refdes=reg_mb_wdata[7:0]
}
C 1900 700 1 0 0 in_port_v.sym   
{
T 1900 700 5 10 1 1 0 6 1 1
refdes=reg_mb_addr[7:0]
}
C 1900 1100 1 0 0 in_port_v.sym   
{
T 1900 1100 5 10 1 1 0 6 1 1
refdes=pic_irq_in[7:0]
}
C 1900 1500 1 0 0 in_port_v.sym   
{
T 1900 1500 5 10 1 1 0 6 1 1
refdes=gpio_1_in[7:0]
}
C 1900 1900 1 0 0 in_port_v.sym   
{
T 1900 1900 5 10 1 1 0 6 1 1
refdes=gpio_0_in[7:0]
}
C 1900 2300 1 0 0 in_port.sym  
{
T 1900 2300 5 10 1 1 0 6 1 1 
refdes=uart_rxd_pad_in
}
C 1900 2700 1 0 0 in_port.sym  
{
T 1900 2700 5 10 1 1 0 6 1 1 
refdes=reset
}
C 1900 3100 1 0 0 in_port.sym  
{
T 1900 3100 5 10 1 1 0 6 1 1 
refdes=reg_mb_wr
}
C 1900 3500 1 0 0 in_port.sym  
{
T 1900 3500 5 10 1 1 0 6 1 1 
refdes=reg_mb_rd
}
C 1900 3900 1 0 0 in_port.sym  
{
T 1900 3900 5 10 1 1 0 6 1 1 
refdes=reg_mb_cs
}
C 1900 4300 1 0 0 in_port.sym  
{
T 1900 4300 5 10 1 1 0 6 1 1 
refdes=enable
}
C 1900 4700 1 0 0 in_port.sym  
{
T 1900 4700 5 10 1 1 0 6 1 1 
refdes=cts_pad_in
}
C 1900 5100 1 0 0 in_port.sym  
{
T 1900 5100 5 10 1 1 0 6 1 1 
refdes=clk
}
C 5000 300  1 0  0 out_port_v.sym
{
T 6000 300 5  10 1 1 0 0 1 1 
refdes=timer_irq[1:0]
}
C 5000 700  1 0  0 out_port_v.sym
{
T 6000 700 5  10 1 1 0 0 1 1 
refdes=reg_mb_rdata[15:0]
}
C 5000 1100  1 0  0 out_port_v.sym
{
T 6000 1100 5  10 1 1 0 0 1 1 
refdes=gpio_1_out[7:0]
}
C 5000 1500  1 0  0 out_port_v.sym
{
T 6000 1500 5  10 1 1 0 0 1 1 
refdes=gpio_1_oe[7:0]
}
C 5000 1900  1 0  0 out_port_v.sym
{
T 6000 1900 5  10 1 1 0 0 1 1 
refdes=gpio_0_out[7:0]
}
C 5000 2300  1 0  0 out_port_v.sym
{
T 6000 2300 5  10 1 1 0 0 1 1 
refdes=gpio_0_oe[7:0]
}
C 5000 2700  1 0 0 out_port.sym
{
T 6000 2700 5  10 1 1 0 0 1 1
refdes=wait_n
}
C 5000 3100  1 0 0 out_port.sym
{
T 6000 3100 5  10 1 1 0 0 1 1
refdes=uart_txd_pad_out
}
C 5000 3500  1 0 0 out_port.sym
{
T 6000 3500 5  10 1 1 0 0 1 1
refdes=tx_irq
}
C 5000 3900  1 0 0 out_port.sym
{
T 6000 3900 5  10 1 1 0 0 1 1
refdes=rx_irq
}
C 5000 4300  1 0 0 out_port.sym
{
T 6000 4300 5  10 1 1 0 0 1 1
refdes=rts_pad_out
}
C 5000 4700  1 0 0 out_port.sym
{
T 6000 4700 5  10 1 1 0 0 1 1
refdes=reg_mb_wait
}
C 5000 5100  1 0 0 out_port.sym
{
T 6000 5100 5  10 1 1 0 0 1 1
refdes=pic_nmi
}
C 5000 5500  1 0 0 out_port.sym
{
T 6000 5500 5  10 1 1 0 0 1 1
refdes=pic_irq
}
