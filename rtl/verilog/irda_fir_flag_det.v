`include "irda_defines.v"
module irda_fir_flag_det (clk, wb_rst_i, fd_restart, fir_rx8_enable, bs_o, pa_det, sta_det, sto_det, 
	break_det, fd_data_bit, fd_o);

input		clk;
input		wb_rst_i;
input		fd_restart;
input		fir_rx8_enable;
input		bs_o;
output	pa_det;
output	sta_det;
output	sto_det;
output	break_det;
output	fd_data_bit; // is bit at fd_o is a data bit
output	fd_o;		// bit output

reg	[31:0]	temp32;
reg	[4:0]		front;

// temp shift register
always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i) begin
		temp32 <= #1 32'hffffffff;
	end else if (fd_restart) begin
		temp32 <= #1 32'hffffffff;
	end else if (fir_rx8_enable) begin
		temp32[31:1] <= #1 temp32[30:0];
		temp32[0]    <= #1 bs_o;
	end
end

assign pa_det = ( temp32[30:15] == 16'b1000_0000_1010_1000);
assign sta_det = ( {temp32[30:0], bs_o} == 32'b0000_1100_0000_1100_0110_0000_0110_0000 );
assign sto_det = ( {temp32[30:0], bs_o} == 32'b0000_1100_0000_1100_0000_0110_0000_0110 );
assign break_det = (temp32[30:23] == 8'b0000_0000);

// front pointer logic
always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i) begin
		front <= #1 0;
	end else if (fd_restart) begin
		front <= #1 0;
	end else if (fir_rx8_enable) begin
		if (pa_det)
			front <= #1 18;
		else if (sta_det || sto_det)
			front <= #1 2;
		else if (break_det)
			front <= #1 26;
		else if (front != 31)
			front <= #1 front + 1;
	end
end

assign fd_data_bit = (front == 31);
assign fd_o = temp32[31];

endmodule
