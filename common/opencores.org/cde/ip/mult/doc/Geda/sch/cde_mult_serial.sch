v 20100214 1
C 1700 300 1 0 0 in_port_v.sym   
{
T 1700 300 5 10 1 1 0 6 1 1
refdes=b_in[WIDTH-1:0]
}
C 1700 700 1 0 0 in_port_v.sym   
{
T 1700 700 5 10 1 1 0 6 1 1
refdes=a_in[WIDTH-1:0]
}
C 1700 1100 1 0 0 in_port.sym  
{
T 1700 1100 5 10 1 1 0 6 1 1 
refdes=reset
}
C 1700 1500 1 0 0 in_port.sym  
{
T 1700 1500 5 10 1 1 0 6 1 1 
refdes=ex_freeze
}
C 1700 1900 1 0 0 in_port.sym  
{
T 1700 1900 5 10 1 1 0 6 1 1 
refdes=clk
}
C 1700 2300 1 0 0 in_port.sym  
{
T 1700 2300 5 10 1 1 0 6 1 1 
refdes=alu_op_mul
}
C 5300 300  1 0  0 out_port_v.sym
{
T 6300 300 5  10 1 1 0 0 1 1 
refdes=mul_prod_r[2*WIDTH-1:0]
}
C 5300 700  1 0 0 out_port.sym
{
T 6300 700 5  10 1 1 0 0 1 1
refdes=mul_stall
}
