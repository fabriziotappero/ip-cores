`include "irda_defines.v"
module irda_data_ctrl(clk, wb_rst_i, dc_restart, dc_restart_fir, next_data, next_data_fir, txfifo_count, 
	mir_txbit_enable, fir_tx4_enable, fir_mode, mir_mode,
	txfifo_dat_o, data_available,	txfifo_remove, data_o);
// This	block outputs the current next data	bit.
// It receives requests	with next_data signal to move to next bit
// and it fetches the data from	TX fifo, if	needed

input				clk;
input				wb_rst_i;
input				next_data;
input				next_data_fir;
input	[31:0]	txfifo_dat_o;
input	[`IRDA_FIFO_POINTER_W:0]	txfifo_count;
input				dc_restart;
input				dc_restart_fir;
input				mir_txbit_enable;
input				fir_tx4_enable;
input				fir_mode;
input				mir_mode;

output			data_available;
output			txfifo_remove;
output			data_o;

reg		[31:0]	sr;		// register	that holds the data
reg		[4:0]		sr_p; // pointer to	current	position in	sr

wire	data_o = sr[sr_p];	// The output from the block - next	data bit (not bit-stuffed)
wire				txfifo_empty = (txfifo_count	==	0);

reg				txfifo_remove;
reg				data_available;	

always @(posedge clk or	posedge wb_rst_i)
begin
	if (wb_rst_i) begin
		sr <= #1 32'b0;
		txfifo_remove <= #1 0;
		sr_p <= #1 5'b0;
		data_available <= #1 0;
	end else
	if (dc_restart || dc_restart_fir) begin
		sr <= #1 32'b0;
		txfifo_remove <= #1 0;
		sr_p <= #1 5'b0;
		data_available <= #1 0;
	end else
	if (! data_available && ! txfifo_empty) begin
		sr <= #1 txfifo_dat_o;
		sr_p <= #1 0;
		txfifo_remove <= #1 1;
		data_available <= #1 1;
	end else
	if ((next_data || next_data_fir) && ( (mir_mode && mir_txbit_enable) || (fir_mode && fir_tx4_enable)))
	begin
		if (sr_p==5'b11110) begin
			if (txfifo_empty)
				data_available <= #1 0;
			else 
				data_available <= #1 1;
			sr_p <= #1 sr_p + 1;
		end else
		if (sr_p==5'b11111)
			if (! txfifo_empty)	begin
				sr <= #1 txfifo_dat_o;
				sr_p <= #1 0;
				txfifo_remove <= #1 1;
				data_available <= #1 1;
			end else begin
				txfifo_remove <= #1 0;
				sr_p <= #1 0;
				sr <= #1 0;
				data_available <= #1 0;
			end
		else 
		if (data_available) begin
			sr_p <= #1 sr_p + 1;
			txfifo_remove <= #1 0;
			data_available <= #1 1;
		end
	end
	else
		txfifo_remove <= #1 0; // so that txfifo_remove	won't stick	to 1
end

endmodule // data_controller
