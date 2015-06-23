// ============================================================================
//  isqrt.v
//  - take the integer square root
//
//
//	2010,2011  Robert Finch
//	robfinch>remove<@sympatico.ca
//
//
//  This source code is available for evaluation and validation purposes
//  only. This copyright statement and disclaimer must remain present in
//  the file.
//
//
//	NO WARRANTY.
//  THIS Work, IS PROVIDEDED "AS IS" WITH NO WARRANTIES OF ANY KIND, WHETHER
//  EXPRESS OR IMPLIED. The user must assume the entire risk of using the
//  Work.
//
//  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR ANY
//  INCIDENTAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES WHATSOEVER RELATING TO
//  THE USE OF THIS WORK, OR YOUR RELATIONSHIP WITH THE AUTHOR.
//
//  IN ADDITION, IN NO EVENT DOES THE AUTHOR AUTHORIZE YOU TO USE THE WORK
//  IN APPLICATIONS OR SYSTEMS WHERE THE WORK'S FAILURE TO PERFORM CAN
//  REASONABLY BE EXPECTED TO RESULT IN A SIGNIFICANT PHYSICAL INJURY, OR IN
//  LOSS OF LIFE. ANY SUCH USE BY YOU IS ENTIRELY AT YOUR OWN RISK, AND YOU
//  AGREE TO HOLD THE AUTHOR AND CONTRIBUTORS HARMLESS FROM ANY CLAIMS OR
//  LOSSES RELATING TO SUCH UNAUTHORIZED USE.
//
//
//	Verilog 1995
//	Webpack 13.i  xc3s1200e-4fg320
//	94 slices / 172 LUTs / 141.906 MHz
//  101 ff's
//
// ============================================================================

module isqrt(rst, clk, ce, ld, a, o, done);
parameter WID = 32;
localparam MSB = WID-1;
parameter IDLE=3'd0;
parameter CALC=3'd1;
parameter DONE=3'd2;
input rst;
input clk;
input ce;
input ld;
input [MSB:0] a;
output [MSB:0] o;
output done;

reg [2:0] state;
reg [MSB:0] root;
wire [MSB:0] testDiv;
reg [MSB:0] remLo;
reg [MSB:0] remHi;

wire cnt_done;
assign testDiv = {root,1'b1};
wire [MSB:0] remHiShift = {remHi[MSB-2:0],remLo[MSB:MSB-1]};
wire doesGoInto = remHiShift >= testDiv;
assign o = root[MSB:1];

// Iteration counter
reg [7:0] cnt;

always @(posedge clk)
if (rst) begin
	cnt <= WID>>1;
	remLo <= {WID{1'b0}};
	remHi <= {WID{1'b0}};
	root <= {WID{1'b0}};
	state <= IDLE;
end
else if (ce) begin
	if (!cnt_done)
		cnt <= cnt + 8'd1;
case(state)
IDLE:
	if (ld) begin
		cnt <= 8'd0;
		state <= CALC;
		remLo <= a;
		remHi <= {WID{1'b0}};
		root <= {WID{1'b0}};
	end
CALC:
	if (!cnt_done) begin
		// Shift the remainder low
		remLo <= {remLo[MSB-2:0],2'd0};
		// Shift the remainder high
		remHi <= doesGoInto ? remHiShift - testDiv: remHiShift;
		// Shift the root
		root <= {root+doesGoInto,1'b0};	// root * 2 + 1/0
	end
	else
		state <= DONE;
DONE:
	begin
		state <= IDLE;
	end
endcase
end
assign cnt_done = (cnt==WID>>1);
assign done = state==DONE;

endmodule


module isqrt_tb();

reg clk;
reg rst;
reg [31:0] a;
wire [31:0] o;
reg ld;
wire done;
reg [7:0] state;

initial begin
	clk = 1;
	rst = 0;
	#100 rst = 1;
	#100 rst = 0;
end

always #10 clk = ~clk;	//  50 MHz

always @(posedge clk)
if (rst) begin
	state <= 8'd0;
	a <= 32'h123456;
end
else
begin
ld <= 1'b0;
case(state)
8'd0:
	begin	
		a <= 32'd1;
		ld <= 1'b1;
		state <= 8'd1;
	end
8'd1:
	if (done) begin
		$display("i=%h o=%h", a, o);
	end
endcase
end

isqrt #(32) u1 (.rst(rst), .clk(clk), .ce(1'b1), .ld(ld), .a(a), .o(o), .done(done));

endmodule


