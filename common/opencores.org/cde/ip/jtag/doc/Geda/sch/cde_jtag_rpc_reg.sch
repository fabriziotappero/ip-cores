v 20100214 1
C 2500 300 1 0 0 in_port_v.sym   
{
T 2500 300 5 10 1 1 0 6 1 1
refdes=capture_value[BITS-1:0]
}
C 2500 700 1 0 0 in_port.sym  
{
T 2500 700 5 10 1 1 0 6 1 1 
refdes=update_dr
}
C 2500 1100 1 0 0 in_port.sym  
{
T 2500 1100 5 10 1 1 0 6 1 1 
refdes=tdi
}
C 2500 1500 1 0 0 in_port.sym  
{
T 2500 1500 5 10 1 1 0 6 1 1 
refdes=shift_dr
}
C 2500 1900 1 0 0 in_port.sym  
{
T 2500 1900 5 10 1 1 0 6 1 1 
refdes=select
}
C 2500 2300 1 0 0 in_port.sym  
{
T 2500 2300 5 10 1 1 0 6 1 1 
refdes=reset
}
C 2500 2700 1 0 0 in_port.sym  
{
T 2500 2700 5 10 1 1 0 6 1 1 
refdes=clk
}
C 2500 3100 1 0 0 in_port.sym  
{
T 2500 3100 5 10 1 1 0 6 1 1 
refdes=capture_dr
}
C 6000 300  1 0  0 out_port_v.sym
{
T 7000 300 5  10 1 1 0 0 1 1 
refdes=update_value[BITS-1:0]
}
C 6000 700  1 0 0 out_port.sym
{
T 7000 700 5  10 1 1 0 0 1 1
refdes=tdo
}
