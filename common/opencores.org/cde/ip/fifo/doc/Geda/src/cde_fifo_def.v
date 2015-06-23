module 
cde_fifo_def
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
output wire	[WIDTH-1:0]	dout,
output reg                      full,
output reg                      empty, 
output reg                      over_run,
output reg                      under_run 
);


reg [SIZE-1:0]                  push_pointer;
reg [SIZE-1:0]                  pop_pointer;


reg 				r;
reg 				w;
reg [SIZE:0]                  push_1;
reg [SIZE:0]                  pop_1;   

   always@(*)  push_1 =  (push_pointer + 1'b1);
   always@(*)  pop_1  =  (pop_pointer  + 1'b1); 


   always@(*)  r =  (pop_pointer == push_1[SIZE-1:0]);
   always@(*)  w =  (push_pointer == pop_1[SIZE-1:0]);

   

   
always@(posedge clk)
  if(reset)
                                begin
                                full         <=  1'b0;
                                empty        <=  1'b1;
                                over_run     <=  1'b0;
                                under_run    <=  1'b0;
                                push_pointer <= {SIZE{1'b0}};
                                pop_pointer  <= {SIZE{1'b0}};         
                                end
  else
  if(empty && !full)
       if( push && ~pop)           
                                begin
	                        full         <=  1'b0;
                                empty        <=  1'b0;
                                over_run     <=  1'b0;
                                under_run    <=  1'b0;
                                push_pointer <= push_pointer+1;
                                pop_pointer  <= pop_pointer;
                                end
       else
       if(~push &&  pop)        
                                begin
	                        full         <=  1'b0;
                                empty        <=  1'b1;
                                over_run     <=  1'b0;
                                under_run    <=  1'b1;
                                push_pointer <= push_pointer;
                                pop_pointer  <= pop_pointer;
                                end
       else
       if( push &&  pop)        
                                begin
	                        full         <=  1'b0;
                                empty        <=  1'b1;
                                over_run     <=  1'b0;
                                under_run    <=  1'b0;
                                push_pointer <= push_pointer +  1;
                                pop_pointer  <= pop_pointer + 1;
                                end
       else
                                begin
                                full         <=  1'b0;
                                empty        <=  1'b1;
                                over_run     <=  1'b0;
                                under_run    <=  1'b0;
                                push_pointer <= push_pointer;
                                pop_pointer  <= pop_pointer;
                                end
   else
   if(!empty && !full)
       if( push &&  pop)        
                                begin
	                        full         <=  1'b0;
                                empty        <=  1'b0;
                                over_run     <=  1'b0;
                                under_run    <=  1'b0;
                                push_pointer <= push_pointer +  1;
                                pop_pointer  <= pop_pointer + 1;
                                end
       else
       if( push && !pop && r)           
                                begin
	                        full         <=  1'b1;
                                empty        <=  1'b0;
                                over_run     <=  1'b0;
                                under_run    <=  1'b0;
                                push_pointer <= push_pointer+1;
                                pop_pointer  <= pop_pointer;
                                end
       else
       if( push && !pop && !r)           
                                begin
	                        full         <=  1'b0;
                                empty        <=  1'b0;
                                over_run     <=  1'b0;
                                under_run    <=  1'b0;
                                push_pointer <= push_pointer+1;
                                pop_pointer  <= pop_pointer;
                                end
       else
       if(~push &&  pop && w)        
                                begin
	                        full         <=  1'b0;
                                empty        <=  1'b1;
                                over_run     <=  1'b0;
                                under_run    <=  1'b0;
                                push_pointer <= push_pointer;
                                pop_pointer  <= pop_pointer+1;
                                end
       else
       if(~push &&  pop && !w)        
                                begin
	                        full         <=  1'b0;
                                empty        <=  1'b0;
                                over_run     <=  1'b0;
                                under_run    <=  1'b0;
                                push_pointer <= push_pointer;
                                pop_pointer  <= pop_pointer+1;
                                end
       else	 
                                begin
                                full         <=  1'b0;
                                empty        <=  1'b0;
                                over_run     <=  1'b0;
                                under_run    <=  1'b0;
                                push_pointer <= push_pointer;
                                pop_pointer  <= pop_pointer;
                                end
  else      
  if(!empty && full)
      if( push && ~pop) 
                                begin
	                        full         <=  1'b1;
                                empty        <=  1'b0;
                                over_run     <=  1'b1;
                                under_run    <=  1'b0;
                                push_pointer <= push_pointer;
                                pop_pointer  <= pop_pointer;
                                end
       else
       if(~push &&  pop)        
                                begin
	                        full         <=  1'b0;
                                empty        <=  1'b0;
                                over_run     <=  1'b0;
                                under_run    <=  1'b0;
                                push_pointer <= push_pointer;
                                pop_pointer  <= pop_pointer+1;
                                end
       else
       if( push &&  pop)        
                                begin
	                        full         <=  1'b1;
                                empty        <=  1'b0;
                                over_run     <=  1'b0;
                                under_run    <=  1'b0;
                                push_pointer <= push_pointer +  1;
                                pop_pointer  <= pop_pointer + 1;
                                end
       else
                                begin
                                full         <=  1'b1;
                                empty        <=  1'b0;
                                over_run     <=  1'b0;
                                under_run    <=  1'b0;
                                push_pointer <= push_pointer;
                                pop_pointer  <= pop_pointer;
                                end
//  full and empty at the same time should never occur

   
    else
                                begin
                                full         <=  1'b0;
                                empty        <=  1'b1;
                                over_run     <=  1'b0;
                                under_run    <=  1'b0;
                                push_pointer <= {SIZE{1'b0}};
                                pop_pointer  <= {SIZE{1'b0}};         
                                end

   




cde_sram_dp
  #(.ADDR      (SIZE),
    .WIDTH     (WIDTH),
    .WORDS     (WORDS),
    .WRITETHRU (0)
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
