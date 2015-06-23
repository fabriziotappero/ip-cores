v 20100214 1
C 1700 300 1 0 0 in_port_v.sym   
{
T 1700 300 5 10 1 1 0 6 1 1
refdes=tx_data[7:0]
}
C 1700 700 1 0 0 in_port.sym  
{
T 1700 700 5 10 1 1 0 6 1 1 
refdes=tx_write
}
C 1700 1100 1 0 0 in_port.sym  
{
T 1700 1100 5 10 1 1 0 6 1 1 
refdes=rx_clear
}
C 1700 1500 1 0 0 in_port.sym  
{
T 1700 1500 5 10 1 1 0 6 1 1 
refdes=reset
}
C 1700 1900 1 0 0 in_port.sym  
{
T 1700 1900 5 10 1 1 0 6 1 1 
refdes=ps2_data_pad_in
}
C 1700 2300 1 0 0 in_port.sym  
{
T 1700 2300 5 10 1 1 0 6 1 1 
refdes=ps2_clk_pad_in
}
C 1700 2700 1 0 0 in_port.sym  
{
T 1700 2700 5 10 1 1 0 6 1 1 
refdes=clk
}
C 4500 300  1 0  0 out_port_v.sym
{
T 5500 300 5  10 1 1 0 0 1 1 
refdes=rx_data[7:0]
}
C 4500 700  1 0 0 out_port.sym
{
T 5500 700 5  10 1 1 0 0 1 1
refdes=tx_buffer_empty
}
C 4500 1100  1 0 0 out_port.sym
{
T 5500 1100 5  10 1 1 0 0 1 1
refdes=tx_ack_error
}
C 4500 1500  1 0 0 out_port.sym
{
T 5500 1500 5  10 1 1 0 0 1 1
refdes=rx_read
}
C 4500 1900  1 0 0 out_port.sym
{
T 5500 1900 5  10 1 1 0 0 1 1
refdes=rx_parity_rcv
}
C 4500 2300  1 0 0 out_port.sym
{
T 5500 2300 5  10 1 1 0 0 1 1
refdes=rx_parity_error
}
C 4500 2700  1 0 0 out_port.sym
{
T 5500 2700 5  10 1 1 0 0 1 1
refdes=rx_parity_cal
}
C 4500 3100  1 0 0 out_port.sym
{
T 5500 3100 5  10 1 1 0 0 1 1
refdes=rx_full
}
C 4500 3500  1 0 0 out_port.sym
{
T 5500 3500 5  10 1 1 0 0 1 1
refdes=rx_frame_error
}
C 4500 3900  1 0 0 out_port.sym
{
T 5500 3900 5  10 1 1 0 0 1 1
refdes=ps2_data_pad_oe
}
C 4500 4300  1 0 0 out_port.sym
{
T 5500 4300 5  10 1 1 0 0 1 1
refdes=ps2_clk_pad_oe
}
C 4500 4700  1 0 0 out_port.sym
{
T 5500 4700 5  10 1 1 0 0 1 1
refdes=busy
}
