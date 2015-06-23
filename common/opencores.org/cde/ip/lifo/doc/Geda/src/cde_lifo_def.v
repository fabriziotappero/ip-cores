module 
cde_lifo_def
#(parameter WIDTH = 8,
  parameter SIZE  = 2,   // DEPTH = 2 ^ SIZE
  parameter WORDS = 4
)
  
(
input  wire	        	clk,
input  wire	        	reset,
input  wire       		push,
input  wire	[WIDTH-1:0]	din,
input  wire	        	pop,
output wire	[WIDTH-1:0]	dout

);



reg [SIZE-1:0] 	 push_pointer;
reg [SIZE-1:0] 	 pop_pointer;



   
always@(posedge clk)
  if(reset)
                          push_pointer <= {SIZE{1'b0}}; 
  else
    if( push && ~pop)     push_pointer <= push_pointer +  1;
  else
    if(~push &&  pop)     push_pointer <= push_pointer -  1;
  else
                          push_pointer <= push_pointer;




always@(posedge clk)
  if(reset)
                          pop_pointer <= {SIZE{1'b1}}; 
  else
    if( push && ~pop)     pop_pointer <= pop_pointer + 1;
  else
    if(~push &&  pop)     pop_pointer <= pop_pointer - 1;
  else
                          pop_pointer <= pop_pointer;

   



   



cde_sram_dp
  #(.ADDR (SIZE),
    .WIDTH (WIDTH),
    .WORDS (WORDS)
   )
fifo
   (
   .clk       ( clk          ),
   .cs        ( 1'b1         ),      
   .waddr     ( push_pointer ),
   .raddr     ( pop_pointer  ),
   .wr        ( push         ),
   .rd        ( 1'b1         ),
   .wdata     ( din          ),
   .rdata     ( dout         )
    );
   

   

endmodule
