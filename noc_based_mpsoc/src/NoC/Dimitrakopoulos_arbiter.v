/*
 ***************************************************
 * Round-robin arbiter with variable priority vector
 * ---------------------
 * G. Dimitrakopoulos
 * Nov. 2008
 ***************************************************
 */
`timescale 1ns/1ps 
`include "../define.v"

module arbiter #(
	parameter ARBITER_WIDTH	=8,
	parameter CHOISE 			= 1  // 0 blind round-robin and 1 true round robin
)
(	
	clk, 
   reset, 
   request, 
   grant,
   anyGrant
);

	`LOG2
  localparam N = ARBITER_WIDTH;
  localparam S = log2(ARBITER_WIDTH); // ceil of log_2 of N - put manually
  

  // I/O interface
  input           clk;
  input           reset;
  input  [N-1:0]  request;
  output [N-1:0]  grant;
  output          anyGrant;
  
  // internal pointers
  reg [N-1:0] priority_reg; // one-hot priority vector
  
  
  // Outputs of combinational logic - real wires - declared as regs for use in a alway block
  // Better to change to wires and use generate statements in the future
  
  reg [N-1:0]  g[S:0]; // S levels of priority generate
  reg [N-1:0]  p[S-1:0]; // S-1 levels of priority propagate

  // internal synonym wires of true outputs anyGrant and grant 
  wire anyGnt;
  wire [N-1:0] gnt;

  assign anyGrant = anyGnt;
  assign grant = gnt;
  
  


/////////////////////////////////////////////////
// Parallel prefix arbitration phase
/////////////////////////////////////////////////
  integer i,j;

  // arbitration phase
  always@(request or priority_reg)
    begin
      // transfer request vector to the fireset propagate positions
      p[0] = {~request[N-2:0], ~request[N-1]};

      // transfer priority vector to the fireset generate positions
      g[0] = priority_reg;
      
      // fireset log_2n - 1 prefix levels
      for (i=1; i < S; i = i + 1) begin
        for (j = 0; j < N ; j = j + 1) begin
          if (j-2**(i-1) < 0) begin
            g[i][j] = g[i-1][j] | (p[i-1][j] & g[i-1][N+j-2**(i-1)]);           
            p[i][j] = p[i-1][j] & p[i-1][N+j-2**(i-1)];
          end else begin
            g[i][j] = g[i-1][j] | (p[i-1][j] & g[i-1][j-2**(i-1)]);           
            p[i][j] = p[i-1][j] & p[i-1][j-2**(i-1)];
          end            
        end
      end  
      
      // last prefix level
      for (j = 0; j < N; j = j + 1) begin
        if (j-2**(S-1) < 0) 
          g[S][j] = g[S-1][j] | (p[S-1][j] & g[S-1][N+j-2**(S-1)]);           
        else
          g[S][j] = g[S-1][j] | (p[S-1][j] & g[S-1][j-2**(S-1)]);           
      end
    end      
  
  // any grant generation at last prefix level
  assign anyGnt = ~(p[S-1][N-1] & p[S-1][N/2-1]);
  
  // output stage logic
  assign gnt  = request & g[S];  


/////////////////////////////////////////////////
// Pointer update logic
// ------------------------
// Version 1 - blind round robin CHOISE = 0
// Priority visits each input in a circural manner irrespective the granted output
// ------------------------
// Version 2 - true round robin CHOISE = 1
// Priority moves next to the granted output
// ------------------------
// Priority moves only when a grant was given, i.e., at least one active request
//////////////////////////////////////////////////

  always@(posedge clk or posedge reset)
    begin
      if (reset == 1'b1) begin
        priority_reg <= 1;
      end else begin
        // update pointers only if at leas one match exists
        if (anyGnt == 1'b1) begin  
            if (CHOISE == 0) begin // blind circular round robin
                // shift left one-hot priority vector
                priority_reg[N-1:1] <= priority_reg[N-2:0];
                priority_reg[0] <= priority_reg[N-1];  
            end else begin // true round robin
                // shift left one-hot grant vector
                priority_reg[N-1:1] <= grant[N-2:0];
                priority_reg[0] <= grant[N-1];  
            end    
        end
      end
    end

 
endmodule


/************************

	fixed priority one hot arbiter


**************************/

module fixed_arbiter#(
	parameter ARBITER_WIDTH=8

	)
	(
	 input [ARBITER_WIDTH-1	:	0]request, 
    output[ARBITER_WIDTH-1	:	0]grant
	);
	
	assign grant[0]=request[0];
	genvar i;
	generate
	for(i=1;i<ARBITER_WIDTH; i=i+1	)begin : arbiter_loop
	 assign grant[i]=request[i]&( request[i-1:0]=={i{1'b0}});
	end
	endgenerate
endmodule