v 20100214 1
C 1700 300 1 0 0 in_port_v.sym   
{
T 1700 300 5 10 1 1 0 6 1 1
refdes=timer_irq[1:0]
}
C 1700 700 1 0 0 in_port_v.sym   
{
T 1700 700 5 10 1 1 0 6 1 1
refdes=pg0_add[7:0]
}
C 1700 1100 1 0 0 in_port_v.sym   
{
T 1700 1100 5 10 1 1 0 6 1 1
refdes=mem_wdata[15:0]
}
C 1700 1500 1 0 0 in_port_v.sym   
{
T 1700 1500 5 10 1 1 0 6 1 1
refdes=mem_addr[0:0]
}
C 1700 1900 1 0 0 in_port_v.sym   
{
T 1700 1900 5 10 1 1 0 6 1 1
refdes=ext_irq_in[2:0]
}
C 1700 2300 1 0 0 in_port.sym  
{
T 1700 2300 5 10 1 1 0 6 1 1 
refdes=tx_irq
}
C 1700 2700 1 0 0 in_port.sym  
{
T 1700 2700 5 10 1 1 0 6 1 1 
refdes=rx_irq
}
C 1700 3100 1 0 0 in_port.sym  
{
T 1700 3100 5 10 1 1 0 6 1 1 
refdes=ps2_data_avail
}
C 1700 3500 1 0 0 in_port.sym  
{
T 1700 3500 5 10 1 1 0 6 1 1 
refdes=pg0_wr
}
C 1700 3900 1 0 0 in_port.sym  
{
T 1700 3900 5 10 1 1 0 6 1 1 
refdes=pg0_rd
}
C 1700 4300 1 0 0 in_port.sym  
{
T 1700 4300 5 10 1 1 0 6 1 1 
refdes=mem_wr
}
C 1700 4700 1 0 0 in_port.sym  
{
T 1700 4700 5 10 1 1 0 6 1 1 
refdes=mem_rd
}
C 1700 5100 1 0 0 in_port.sym  
{
T 1700 5100 5 10 1 1 0 6 1 1 
refdes=mem_cs
}
C 1700 5500 1 0 0 in_port.sym  
{
T 1700 5500 5 10 1 1 0 6 1 1 
refdes=clk
}
C 5500 300  1 0  0 out_port_v.sym
{
T 6500 300 5  10 1 1 0 0 1 1 
refdes=mem_rdata[15:0]
}
C 5500 700  1 0  0 out_port_v.sym
{
T 6500 700 5  10 1 1 0 0 1 1 
refdes=io_module_vic_irq_in[7:0]
}
C 5500 1100  1 0  0 out_port_v.sym
{
T 6500 1100 5  10 1 1 0 0 1 1 
refdes=io_module_pic_irq_in[7:0]
}
C 5500 1500  1 0  0 out_port_v.sym
{
T 6500 1500 5  10 1 1 0 0 1 1 
refdes=cpu_pg0_data[7:0]
}
C 5500 1900  1 0 0 out_port.sym
{
T 6500 1900 5  10 1 1 0 0 1 1
refdes=pg00_ram_rd
}
C 5500 2300  1 0 0 out_port.sym
{
T 6500 2300 5  10 1 1 0 0 1 1
refdes=pg00_ram_l_wr
}
C 5500 2700  1 0 0 out_port.sym
{
T 6500 2700 5  10 1 1 0 0 1 1
refdes=pg00_ram_h_wr
}
