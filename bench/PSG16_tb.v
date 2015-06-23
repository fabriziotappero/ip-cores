`define PSG		64'hFFFF_FFFF_FFD5_0000

module PSG16_tb();
reg clk;
reg rst;
reg cyc;
reg stb;
wire ack;
reg we;
reg [63:0] adr;
reg [15:0] dat;
reg [7:0] state;
wire [17:0] out;
reg [31:0] cnt;

initial begin
	rst = 0;
	clk = 0;
	#100 rst = 1;
	#100 rst = 0;
end

always #1 clk = ~clk;

always @(posedge clk)
if (rst) begin
	state <= 8'd0;
	cyc <= 1'b0;
	stb <= 1'b0;
	we <= 1'b0;
end
else
case (state)
8'd0:	state <= 8'd1;
// Set master volume at 15
8'd1:
	if (!cyc) begin
		cyc <= 1'b1;
		stb <= 1'b1;
		we <= 1'b1;
		adr <= `PSG+128;
		dat <= 16'd15;
	end
	else if (ack) begin
		cyc <= 1'b0;
		stb <= 1'b0;
		we <= 1'b0;
		state <= 8'd2;
	end
// Set frequency to 800Hz
8'd2:
	if (!cyc) begin
		cyc <= 1'b1;
		stb <= 1'b1;
		we <= 1'b1;
		adr <= `PSG;
		dat <= 16'd13422;
	end
	else if (ack) begin
		cyc <= 1'b0;
		stb <= 1'b0;
		we <= 1'b0;
		state <= 8'd3;
	end
// Set ADSR
8'd3:
	if (!cyc) begin
		cyc <= 1'b1;
		stb <= 1'b1;
		we <= 1'b1;
		adr <= `PSG + 6;
		dat <= 16'hCA12;
	end
	else if (ack) begin
		cyc <= 1'b0;
		stb <= 1'b0;
		we <= 1'b0;
		state <= 8'd4;
	end
// Set gate,triangle wave,output enable
8'd4:
	if (!cyc) begin
		cyc <= 1'b1;
		stb <= 1'b1;
		we <= 1'b1;
		adr <= `PSG + 4;
		dat <= 16'h1104;
	end
	else if (ack) begin
		cyc <= 1'b0;
		stb <= 1'b0;
		we <= 1'b0;
		cnt <= 32'd0;
		state <= 8'd5;
	end
// wait 1 second
8'd5:
	if (cnt==32'd50000)
		state <= 8'd6;
	else
		cnt <= cnt + 1;
// Set gate off,triangle wave,output enable
8'd6:
	if (!cyc) begin
		cyc <= 1'b1;
		stb <= 1'b1;
		we <= 1'b1;
		adr <= `PSG + 4;
		dat <= 16'h0104;
	end
	else if (ack) begin
		cyc <= 1'b0;
		stb <= 1'b0;
		we <= 1'b0;
		cnt <= 32'd0;
		state <= 8'd7;
	end
// wait 1 second
8'd7:
	if (cnt==32'd50000)
		state <= 8'd8;
	else
		cnt <= cnt + 1;
// Set gate off,triangle wave,output enable
8'd8:
	if (!cyc) begin
		cyc <= 1'b1;
		stb <= 1'b1;
		we <= 1'b1;
		adr <= `PSG + 4;
		dat <= 16'h0000;
	end
	else if (ack) begin
		cyc <= 1'b0;
		stb <= 1'b0;
		we <= 1'b0;
		cnt <= 32'd0;
		state <= 8'd9;
	end
default:	;
endcase


PSG16 #(.pClkDivide(50)) u1
(
	.rst_i(rst),
	.clk_i(clk),
	.cyc_i(cyc),
	.stb_i(stb),
	.ack_o(ack),
	.we_i(we),
	.sel_i(2'b11),
	.adr_i(adr),
	.dat_i(dat),
	.dat_o(),
	.vol_o(),
	.bg(), 
	.m_cyc_o(),
	.m_stb_o(),
	.m_ack_i(),
	.m_we_o(),
	.m_sel_o(),
	.m_adr_o(),
	.m_dat_i(),
	.o(out)
);

endmodule
