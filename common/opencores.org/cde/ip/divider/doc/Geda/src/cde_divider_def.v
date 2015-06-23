module 
cde_divider_def
  
#(parameter   SIZE=4,
  parameter   SAMPLE=0,            
  parameter   RESET=1            
 )  
(
input  wire              clk,
input  wire              reset,
input  wire              enable,
input  wire [SIZE-1:0]   divider_in,
output  reg              divider_out
                         );

reg  [SIZE-1:0]        divide_cnt;

always@(posedge clk)
  if(reset)            divider_out    <= RESET;
  else
  if(!enable)          divider_out    <= 1'b0;  
  else                 divider_out    <=  ( divide_cnt == SAMPLE );       



always@(posedge clk)
  if(reset)            divide_cnt    <= divider_in;
  else
  if(!enable)          divide_cnt    <= divide_cnt;
  else
  if(!(|divide_cnt))   divide_cnt    <= divider_in;
  else                 divide_cnt    <= divide_cnt - 'b1;





   
endmodule



