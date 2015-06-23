module AC97_tb();
reg rst;
reg clk;
wire BIT_CLK;
wire RESET;
wire SDATA_IN;
wire SDATA_OUT;
wire SYNC;

reg cyc;
reg stb;
reg we;
wire ack;
reg [63:0] adr;
reg [15:0] dat;
wire [15:0] dato;

initial begin
	#0	rst = 1'b0;
	#0	clk = 1'b0;
	#100 rst = 1'b1;
	#100 rst = 1'b0;
end

always #10 clk = ~clk;

reg [7:0] state;
always @(posedge clk)
if (rst) begin
cyc <= 1'b0;
stb <= 1'b0;
we <= 1'b0;
state <= 8'd0;
end
else begin
case(state)
8'd0:	state <= 8'd1;
8'd1:	if (!cyc) begin
			cyc <= 1'b1;
			stb <= 1'b1;
			we <= 1'b1;
			adr <= 64'hFFFF_FFFF_FFDC_1026;
			dat <= 16'h0000;
		end
		else if (ack) begin
			cyc <= 1'b0;
			stb <= 1'b0;
			we <= 1'b0;
			state <= 8'd2;
		end
endcase
end

AC97 u1
(
	.rst_i(rst),
	.clk_i(clk),
	.cyc_i(cyc),
	.stb_i(stb),
	.ack_o(ack),
	.we_i(we),
	.adr_i(adr),
	.dat_i(dat),
	.dat_o(dato),
	.PSGout(),
	.BIT_CLK(BIT_CLK),
	.SYNC(SYNC),
	.SDATA_IN(SDATA_OUT),
	.SDATA_OUT(SDATA_IN),
	.RESET(RESET)
);

LM4550 u2
(
    .BIT_CLK(BIT_CLK), 
    .SDATA_OUT(SDATA_OUT),
    .RESET(RESET), 
    .SYNC(SYNC), 
    .SDATA_IN(SDATA_IN)
);


endmodule
