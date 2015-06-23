v 20100214 1
T 40 40 8 10 1 1 0 0 1 1
refdes=U?
C 1900 300 1 0 0 in_port.sym   
{
T 1900 300 5 10 1 1 0 6 1 1
refdes=BAD 
}
C 1900 700 1 0 0 in_port.sym   
{
T 1900 700 5 10 1 1 0 6 1 1
refdes=STOP 
}
C 1900 1100 1 0 0 in_port.sym   
{
T 1900 1100 5 10 1 1 0 6 1 1
refdes=START 
}
C 1900 1500 1 0 0 in_port_v.sym   
{
T 1900 1500 5 10 1 1 0 6 1 1
refdes=clock__master_clk
}
C 7100 300  1 0  0 out_port.sym
{
T 8100 300 5  10 1 1 0 0 1 1 
refdes=FINISH 
}
C 7100 700  1 0  0 out_port.sym
{
T 8100 700 5  10 1 1 0 0 1 1 
refdes=FAIL 
}
C 7100 1100  1 0  0 out_port_v.sym
{
T 8100 1100 5  10 1 1 0 0 1 1 
refdes=reset__master_reset
}
