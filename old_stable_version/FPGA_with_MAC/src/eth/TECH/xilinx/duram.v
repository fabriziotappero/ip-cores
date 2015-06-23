module duram(
data_a,
data_b,
wren_a,
wren_b,
address_a,
address_b,
clock_a,
clock_b,
q_a,
q_b);

parameter DATA_WIDTH    = 36; 
parameter ADDR_WIDTH    = 10;  
parameter dummy = "dummy";
parameter dummy2 = "dummy2";

input   [DATA_WIDTH -1:0]   data_a;
input                       wren_a;
input   [ADDR_WIDTH -1:0]   address_a;
input                       clock_a;
output  reg [DATA_WIDTH -1:0]   q_a;
input   [DATA_WIDTH -1:0]   data_b;
input                       wren_b;
input   [ADDR_WIDTH -1:0]   address_b;
input                       clock_b;
output  reg [DATA_WIDTH -1:0]   q_b;
 
   // Shared memory
   reg [DATA_WIDTH-1:0] mem [(2**ADDR_WIDTH)-1:0];
	 
   // Port A
   always @(posedge clock_a) begin
	    q_a      <= mem[address_a];
	    if(wren_a) begin
	        q_a      <= data_a;
	        mem[address_a] <= data_a;
	    end
	end
	 
	// Port B
	always @(posedge clock_b) begin
	    q_b      <= mem[address_b];
	    if(wren_b) begin
	        q_b      <= data_b;
	        mem[address_b] <= data_b;
	    end
	end
	 
endmodule
