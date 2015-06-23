`include "irda_defines.v"

module irda_wb (clk, wb_rst_i, wb_stb_i, wb_cyc_i,  wb_we_i, wb_ack_o, we_i, re_i);

input			clk;
input			wb_rst_i;
input			wb_stb_i;
input			wb_cyc_i;
input			wb_we_i;
output		wb_ack_o;
output		we_i;		// Write enable output for the registers
output		re_i;    // Read enable from the core
reg			wb_ack_o;

always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i) begin
		wb_ack_o <= #1 0;
	end else begin
		wb_ack_o <= #1 wb_stb_i & wb_cyc_i & ~wb_ack_o; // one clock delay on acknowledge output
	end
end

assign we_i = wb_we_i & wb_stb_i & wb_cyc_i;
assign re_i = ~wb_we_i & wb_stb_i & wb_cyc_i;

endmodule
