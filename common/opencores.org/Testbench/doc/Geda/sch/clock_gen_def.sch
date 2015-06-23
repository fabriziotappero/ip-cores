v 20100214 1
C 2200 300 1 0 0 in_port_v.sym   
{
T 2200 300 5 10 1 1 0 6 1 1
refdes=STOP[STOP_WIDTH-1:0]
}
C 2200 700 1 0 0 in_port_v.sym   
{
T 2200 700 5 10 1 1 0 6 1 1
refdes=BAD[BAD_WIDTH-1:0]
}
C 2200 1100 1 0 0 in_port.sym  
{
T 2200 1100 5 10 1 1 0 6 1 1 
refdes=clk
}
C 2200 1500 1 0 0 in_port.sym  
{
T 2200 1500 5 10 1 1 0 6 1 1 
refdes=START
}
C 4100 300  1 0 0 out_port.sym
{
T 5100 300 5  10 1 1 0 0 1 1
refdes=reset
}
C 4100 700  1 0 0 out_port.sym
{
T 5100 700 5  10 1 1 0 0 1 1
refdes=FINISH
}
C 4100 1100  1 0 0 out_port.sym
{
T 5100 1100 5  10 1 1 0 0 1 1
refdes=FAIL
}
