`timescale 10ns / 1ns

module tb_cia8520();

reg clk_60;
reg reset;
reg CYC_I;
reg STB_I;
reg WE_I;
reg [3:0] ADR_I;
reg [7:0] DAT_I;
reg [7:0] pa_i;
reg [7:0] pb_i;
reg flag_n;
reg tod;
reg sp_i;
reg cnt_i;

wire ACK_O;
wire [7:0] DAT_O;
wire [7:0] pa_o;
wire [7:0] pb_o;
wire pc_n;
wire irq_n;
wire sp_o;
wire cnt_o;

cia8520 cia8520_inst (
    .clk_60(clk_60),
    .reset(reset),
    
    // WISHBONE slave
    .CYC_I(CYC_I),
    .STB_I(STB_I),
    .WE_I(WE_I),
    .ADR_I(ADR_I), /*[3:0]*/
    .DAT_I(DAT_I), /*[7:0]*/
    .ACK_O(ACK_O),
    .DAT_O(DAT_O), /*[7:0]*/
    
    // 8520 synchronous interface
    .pa_o(pa_o), /*[7:0]*/
    .pb_o(pb_o), /*[7:0]*/
    .pa_i(pa_i), /*[7:0]*/
    .pb_i(pb_i), /*[7:0]*/
    
    .flag_n(flag_n),
    .pc_n(pc_n),
    .tod(tod),
    .irq_n(irq_n),
    
    .sp_i(sp_i),
    .sp_o(sp_o),
    .cnt_i(cnt_i),
    .cnt_o(cnt_o)
);

initial begin
	clk_60 = 1'b0;
	forever #5 clk_60 = ~clk_60;
end

initial begin
    $dumpfile("tb_cia8520.vcd");
	$dumpvars(0);
	$dumpon();
	
	reset = 1'b1;
	#10
	reset = 1'b0;
	
	// DDR A write
	CYC_I = 1'b1;
	STB_I = 1'b1;
	WE_I = 1'b1;
	ADR_I = 4'd2;
	DAT_I = 8'h7F;
	#10
	CYC_I = 1'b0;
	STB_I = 1'b0;
	#10
	
	// DDR A read
	CYC_I = 1'b1;
	STB_I = 1'b1;
	WE_I = 1'b0;
	ADR_I = 4'd2;
	#10
	CYC_I = 1'b0;
	STB_I = 1'b0;
	$display("DDR A: ", DAT_O);
	#10
	
	// Port A write
	CYC_I = 1'b1;
	STB_I = 1'b1;
	WE_I = 1'b1;
	ADR_I = 4'd0;
	DAT_I = 8'h5A;
	#10
	CYC_I = 1'b0;
	STB_I = 1'b0;
	#10
	
	// Port A read
	pa_i = 8'h80;
	CYC_I = 1'b1;
	STB_I = 1'b1;
	WE_I = 1'b0;
	ADR_I = 4'd0;
	#10
	CYC_I = 1'b0;
	STB_I = 1'b0;
	$display("Port A: ", DAT_O);
	#10
	
	// TOD pulse
	tod = 1'b1;
	#10
	tod = 1'b0;
	#10
	
	// CRA write alarm
	CYC_I = 1'b1;
	STB_I = 1'b1;
	WE_I = 1'b1;
	ADR_I = 4'd15;
	DAT_I = 8'h80;
	#10
	CYC_I = 1'b0;
	STB_I = 1'b0;
	#10
	
	// TOD alarm high write
	CYC_I = 1'b1;
	STB_I = 1'b1;
	WE_I = 1'b1;
	ADR_I = 4'd10;
	DAT_I = 8'h0;
	#10
	CYC_I = 1'b0;
	STB_I = 1'b0;
	#10
	
	// TOD alarm med write
	CYC_I = 1'b1;
	STB_I = 1'b1;
	WE_I = 1'b1;
	ADR_I = 4'd9;
	DAT_I = 8'h0;
	#10
	CYC_I = 1'b0;
	STB_I = 1'b0;
	#10
	
	// TOD alarm low write
	CYC_I = 1'b1;
	STB_I = 1'b1;
	WE_I = 1'b1;
	ADR_I = 4'd8;
	DAT_I = 8'h2;
	#10
	CYC_I = 1'b0;
	STB_I = 1'b0;
	#10
	
	// TOD pulse
	tod = 1'b1;
	#10
	tod = 1'b0;
	#10
	
	#3000
	
	$dumpoff();
	
	$finish();
end

endmodule

