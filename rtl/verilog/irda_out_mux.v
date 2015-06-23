`include "irda_defines.v"
module irda_out_mux (clk, wb_rst_i, sir_enc_o, mir_enc_o, fir_tx_o, sip_gen_o, 
			fast_mode, tx_select, mir_mode, negate_tx, tx_pad_o);
// sampled mux for IrDA main output 
input		clk;
input		wb_rst_i;
input		sir_enc_o;
input		mir_enc_o;
input		fir_tx_o;
input		sip_gen_o;
input		fast_mode;
input		tx_select;
input		mir_mode;
input		negate_tx;

output	tx_pad_o;
reg		tx_pad_o;

always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i) begin
		tx_pad_o <= #1 0;
	end else if (tx_select) begin
		if (~fast_mode)
			tx_pad_o <= #1 sir_enc_o ^ negate_tx;
		else if (mir_mode)
			tx_pad_o <= #1 (mir_enc_o | sip_gen_o) ^ negate_tx;
		else
			tx_pad_o <= #1 (fir_tx_o | sip_gen_o) ^ negate_tx;
	end
end

endmodule
