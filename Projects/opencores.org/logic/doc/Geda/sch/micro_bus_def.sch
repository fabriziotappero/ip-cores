v 20100214 1
C 2900 300 1 0 0 in_port_v.sym   
{
T 2900 300 5 10 1 1 0 6 1 1
refdes=wdata_in[7:0]
}
C 2900 700 1 0 0 in_port_v.sym   
{
T 2900 700 5 10 1 1 0 6 1 1
refdes=sh_prog_rom_mem_rdata[15:0]
}
C 2900 1100 1 0 0 in_port_v.sym   
{
T 2900 1100 5 10 1 1 0 6 1 1
refdes=prog_rom_mem_rdata[15:0]
}
C 2900 1500 1 0 0 in_port_v.sym   
{
T 2900 1500 5 10 1 1 0 6 1 1
refdes=mem_wait[1:0]
}
C 2900 1900 1 0 0 in_port_v.sym   
{
T 2900 1900 5 10 1 1 0 6 1 1
refdes=mem_rdata[15:0]
}
C 2900 2300 1 0 0 in_port_v.sym   
{
T 2900 2300 5 10 1 1 0 6 1 1
refdes=io_reg_rdata[15:0]
}
C 2900 2700 1 0 0 in_port_v.sym   
{
T 2900 2700 5 10 1 1 0 6 1 1
refdes=ext_mem_rdata[15:0]
}
C 2900 3100 1 0 0 in_port_v.sym   
{
T 2900 3100 5 10 1 1 0 6 1 1
refdes=data_rdata[15:0]
}
C 2900 3500 1 0 0 in_port_v.sym   
{
T 2900 3500 5 10 1 1 0 6 1 1
refdes=addr_in[15:0]
}
C 2900 3900 1 0 0 in_port.sym  
{
T 2900 3900 5 10 1 1 0 6 1 1 
refdes=wr_in
}
C 2900 4300 1 0 0 in_port.sym  
{
T 2900 4300 5 10 1 1 0 6 1 1 
refdes=reset
}
C 2900 4700 1 0 0 in_port.sym  
{
T 2900 4700 5 10 1 1 0 6 1 1 
refdes=rd_in
}
C 2900 5100 1 0 0 in_port.sym  
{
T 2900 5100 5 10 1 1 0 6 1 1 
refdes=io_reg_wait
}
C 2900 5500 1 0 0 in_port.sym  
{
T 2900 5500 5 10 1 1 0 6 1 1 
refdes=ext_mem_wait
}
C 2900 5900 1 0 0 in_port.sym  
{
T 2900 5900 5 10 1 1 0 6 1 1 
refdes=clk
}
C 6900 300  1 0  0 out_port_v.sym
{
T 7900 300 5  10 1 1 0 0 1 1 
refdes=sh_prog_rom_mem_wdata[15:0]
}
C 6900 700  1 0  0 out_port_v.sym
{
T 7900 700 5  10 1 1 0 0 1 1 
refdes=sh_prog_rom_mem_addr[11:0]
}
C 6900 1100  1 0  0 out_port_v.sym
{
T 7900 1100 5  10 1 1 0 0 1 1 
refdes=rdata_out[15:0]
}
C 6900 1500  1 0  0 out_port_v.sym
{
T 7900 1500 5  10 1 1 0 0 1 1 
refdes=prog_rom_mem_wdata[15:0]
}
C 6900 1900  1 0  0 out_port_v.sym
{
T 7900 1900 5  10 1 1 0 0 1 1 
refdes=prog_rom_mem_addr[11:0]
}
C 6900 2300  1 0  0 out_port_v.sym
{
T 7900 2300 5  10 1 1 0 0 1 1 
refdes=mem_wdata[15:0]
}
C 6900 2700  1 0  0 out_port_v.sym
{
T 7900 2700 5  10 1 1 0 0 1 1 
refdes=mem_addr[15:0]
}
C 6900 3100  1 0  0 out_port_v.sym
{
T 7900 3100 5  10 1 1 0 0 1 1 
refdes=io_reg_wdata[7:0]
}
C 6900 3500  1 0  0 out_port_v.sym
{
T 7900 3500 5  10 1 1 0 0 1 1 
refdes=io_reg_addr[7:0]
}
C 6900 3900  1 0  0 out_port_v.sym
{
T 7900 3900 5  10 1 1 0 0 1 1 
refdes=ext_mem_wdata[15:0]
}
C 6900 4300  1 0  0 out_port_v.sym
{
T 7900 4300 5  10 1 1 0 0 1 1 
refdes=ext_mem_addr[13:0]
}
C 6900 4700  1 0  0 out_port_v.sym
{
T 7900 4700 5  10 1 1 0 0 1 1 
refdes=data_wdata[15:0]
}
C 6900 5100  1 0  0 out_port_v.sym
{
T 7900 5100 5  10 1 1 0 0 1 1 
refdes=data_be[1:0]
}
C 6900 5500  1 0  0 out_port_v.sym
{
T 7900 5500 5  10 1 1 0 0 1 1 
refdes=data_addr[11:1]
}
C 6900 5900  1 0 0 out_port.sym
{
T 7900 5900 5  10 1 1 0 0 1 1
refdes=sh_prog_rom_mem_wr
}
C 6900 6300  1 0 0 out_port.sym
{
T 7900 6300 5  10 1 1 0 0 1 1
refdes=sh_prog_rom_mem_rd
}
C 6900 6700  1 0 0 out_port.sym
{
T 7900 6700 5  10 1 1 0 0 1 1
refdes=sh_prog_rom_mem_cs
}
C 6900 7100  1 0 0 out_port.sym
{
T 7900 7100 5  10 1 1 0 0 1 1
refdes=prog_rom_mem_wr
}
C 6900 7500  1 0 0 out_port.sym
{
T 7900 7500 5  10 1 1 0 0 1 1
refdes=prog_rom_mem_rd
}
C 6900 7900  1 0 0 out_port.sym
{
T 7900 7900 5  10 1 1 0 0 1 1
refdes=prog_rom_mem_cs
}
C 6900 8300  1 0 0 out_port.sym
{
T 7900 8300 5  10 1 1 0 0 1 1
refdes=mem_wr
}
C 6900 8700  1 0 0 out_port.sym
{
T 7900 8700 5  10 1 1 0 0 1 1
refdes=mem_rd
}
C 6900 9100  1 0 0 out_port.sym
{
T 7900 9100 5  10 1 1 0 0 1 1
refdes=mem_cs
}
C 6900 9500  1 0 0 out_port.sym
{
T 7900 9500 5  10 1 1 0 0 1 1
refdes=io_reg_wr
}
C 6900 9900  1 0 0 out_port.sym
{
T 7900 9900 5  10 1 1 0 0 1 1
refdes=io_reg_rd
}
C 6900 10300  1 0 0 out_port.sym
{
T 7900 10300 5  10 1 1 0 0 1 1
refdes=io_reg_cs
}
C 6900 10700  1 0 0 out_port.sym
{
T 7900 10700 5  10 1 1 0 0 1 1
refdes=ext_mem_wr
}
C 6900 11100  1 0 0 out_port.sym
{
T 7900 11100 5  10 1 1 0 0 1 1
refdes=ext_mem_rd
}
C 6900 11500  1 0 0 out_port.sym
{
T 7900 11500 5  10 1 1 0 0 1 1
refdes=ext_mem_cs
}
C 6900 11900  1 0 0 out_port.sym
{
T 7900 11900 5  10 1 1 0 0 1 1
refdes=enable
}
C 6900 12300  1 0 0 out_port.sym
{
T 7900 12300 5  10 1 1 0 0 1 1
refdes=data_wr
}
C 6900 12700  1 0 0 out_port.sym
{
T 7900 12700 5  10 1 1 0 0 1 1
refdes=data_rd
}
C 6900 13100  1 0 0 out_port.sym
{
T 7900 13100 5  10 1 1 0 0 1 1
refdes=data_cs
}
