v 20100214 1
C 2000 300 1 0 0 in_port_v.sym   
{
T 2000 300 5 10 1 1 0 6 1 1
refdes=data_in[WIDTH-1:0]
}
C 2000 700 1 0 0 in_port.sym  
{
T 2000 700 5 10 1 1 0 6 1 1 
refdes=reset_n
}
C 2000 1100 1 0 0 in_port.sym  
{
T 2000 1100 5 10 1 1 0 6 1 1 
refdes=clk
}
C 5200 300  1 0  0 out_port_v.sym
{
T 6200 300 5  10 1 1 0 0 1 1 
refdes=data_out[WIDTH-1:0]
}
