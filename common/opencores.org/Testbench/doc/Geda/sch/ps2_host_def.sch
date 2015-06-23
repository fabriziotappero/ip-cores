v 20100214 1
C 1700 300 1 0 0 in_port.sym  
{
T 1700 300 5 10 1 1 0 6 1 1 
refdes=rx_read
}
C 1700 700 1 0 0 in_port.sym  
{
T 1700 700 5 10 1 1 0 6 1 1 
refdes=rx_parity_rcv
}
C 1700 1100 1 0 0 in_port.sym  
{
T 1700 1100 5 10 1 1 0 6 1 1 
refdes=rx_parity_error
}
C 1700 1500 1 0 0 in_port.sym  
{
T 1700 1500 5 10 1 1 0 6 1 1 
refdes=rx_parity_cal
}
C 1700 1900 1 0 0 in_port.sym  
{
T 1700 1900 5 10 1 1 0 6 1 1 
refdes=rx_full
}
C 1700 2300 1 0 0 in_port.sym  
{
T 1700 2300 5 10 1 1 0 6 1 1 
refdes=rx_frame_error
}
C 1700 2700 1 0 0 in_port.sym  
{
T 1700 2700 5 10 1 1 0 6 1 1 
refdes=reset
}
C 1700 3100 1 0 0 in_port.sym  
{
T 1700 3100 5 10 1 1 0 6 1 1 
refdes=clk
}
C 1700 3500 1 0 0 in_port.sym  
{
T 1700 3500 5 10 1 1 0 6 1 1 
refdes=busy
}
C 3800 300  1 0 0 out_port.sym
{
T 4800 300 5  10 1 1 0 0 1 1
refdes=tx_write
}
C 3800 700  1 0 0 out_port.sym
{
T 4800 700 5  10 1 1 0 0 1 1
refdes=rx_clr
}
