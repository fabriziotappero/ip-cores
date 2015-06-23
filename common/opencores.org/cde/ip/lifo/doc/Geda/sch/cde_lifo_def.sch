v 20100214 1
C 1600 300 1 0 0 in_port_v.sym   
{
T 1600 300 5 10 1 1 0 6 1 1
refdes=din[WIDTH-1:0]
}
C 1600 700 1 0 0 in_port.sym  
{
T 1600 700 5 10 1 1 0 6 1 1 
refdes=reset
}
C 1600 1100 1 0 0 in_port.sym  
{
T 1600 1100 5 10 1 1 0 6 1 1 
refdes=push
}
C 1600 1500 1 0 0 in_port.sym  
{
T 1600 1500 5 10 1 1 0 6 1 1 
refdes=pop
}
C 1600 1900 1 0 0 in_port.sym  
{
T 1600 1900 5 10 1 1 0 6 1 1 
refdes=clk
}
C 4400 300  1 0  0 out_port_v.sym
{
T 5400 300 5  10 1 1 0 0 1 1 
refdes=dout[WIDTH-1:0]
}
