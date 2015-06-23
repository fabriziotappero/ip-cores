module port_clkcntl (
// Clock control module for PATLPP port interface

	// Inputs:
	clk,
	rst,
	en,				// Module Enable
	in_data,			// Input Data
	in_sof,			// Input Start of Frame
	in_eof,			// Input End of Frame
	in_src_rdy,		// Input Source Ready
	out_dst_rdy,	// Output Destination Ready
	
	usr_clk_in,		// User clock in

	// Outputs:
	out_data,		// Output Data
	out_sof,			// Output Start of Frame
	out_eof,			// Output End of Frame
	out_src_rdy,	// Output Source Ready
	in_dst_rdy,		// Input Destination Ready
	
	usr_clk_out,	// User clock out
	usr_rst_out		// User reset signal
);

// Port mode declarations:
	// Inputs:
input	clk;
input	rst;
input	en;
input	[7:0]	in_data;
input	in_sof;
input	in_eof;
input	in_src_rdy;
input	out_dst_rdy;
input usr_clk_in;

	// Outputs:
output	[7:0]	out_data;
output	out_sof;
output	out_eof;
output	out_src_rdy;
output	in_dst_rdy;
output	usr_clk_out;
output	usr_rst_out;

// Control Register Masks
`define	START		1
`define	FREERUN	2
reg	[7:0]		control_reg;
// Termination Count Register
reg	[31:0]	termination_count_reg;
reg	[31:0]	termination_count_reg_r;

assign in_dst_rdy = 1;
assign out_data = 0;
assign out_sof = 0;
assign out_eof = 0;
assign out_src_rdy = 0;
assign usr_rst_out = control_reg[2];

always @(posedge clk or posedge rst)
begin
	if (rst)
	begin
		control_reg <= 8'b00000000;
		termination_count_reg_r <= 32'd0;
	end
	else if (en & in_src_rdy & in_eof)
	begin
		control_reg <= in_data;
		termination_count_reg_r <= termination_count_reg;
	end
end


always @(posedge clk or posedge rst)
begin
	if (rst)
	begin
		termination_count_reg <= 0;
	end
	else if (en & in_src_rdy & ~in_eof)
	begin
		termination_count_reg[31:24] <= termination_count_reg[23:16];
		termination_count_reg[23:16] <= termination_count_reg[15:8];
		termination_count_reg[15:8] <= termination_count_reg[7:0];
		termination_count_reg[7:0] <= in_data;
	end
end

// The follow code was adapted from a clock control circuit by Brad Hutchings

clockcntl theclockcntl (
	.reset (rst),
	.userResetInternal (rst),
	.baseClock (usr_clk_in),
	.terminationCountRegister (termination_count_reg_r),
	.configurationRegister (control_reg),
	.gatedClock (usr_clk_out)
	);

endmodule
