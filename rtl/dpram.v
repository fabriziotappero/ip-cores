
//----------------------------------------------------------------------------
// Wishbone DDR Controller
// 
// (c) Joerg Bornschein (<jb@capsec.org>)
//----------------------------------------------------------------------------

module dpram
#(
	parameter adr_width = 9,
	parameter dat_width = 36
) (
	input                       clk,
	// Port 0
	input      [adr_width-1:0]  adr0,
	input                       we0,
	input      [dat_width-1:0]  din0,
	output reg [dat_width-1:0]  dout0,
	// Port 1
	input      [adr_width-1:0]  adr1,
	input                       we1,
	input      [dat_width-1:0]  din1,
	output reg [dat_width-1:0]  dout1
);

parameter depth = (1 << adr_width);

// actual ram 
reg [dat_width-1:0] ram [0:depth-1];

//------------------------------------------------------------------
// Syncronous Dual Port RAM Access
//------------------------------------------------------------------
always @(posedge clk)
begin
	// Frst port
	if (we0) 
		ram[adr0] <= din0;

	dout0 <= ram[adr0];
end


always @(posedge clk)
begin
	// Second port
	if (we1) 
		ram[adr1] <= din1;

	dout1 <= ram[adr1];
end

//------------------------------------------------------------------
// Initialize content to Zero
//------------------------------------------------------------------
integer i;

initial 
begin
	for(i=0; i<depth; i=i+1) 
		ram[i] <= 'b0;
end

endmodule
