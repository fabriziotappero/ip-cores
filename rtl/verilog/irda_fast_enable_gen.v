`include "irda_defines.v"
module irda_fast_enable_gen (clk, wb_rst_i, tx_select, loopback_enable, mir_mode, mir_half, fir_mode,
		f_cdr, en_reload, fast_enable,
		mir_txbit_enable, mir_rxbit_enable,
		fir_tx8_enable, fir_tx4_enable, fir_rx8_enable, fir_rx4_enable);

parameter		MULT = 100000;
parameter		CDR_WIDTH = `IRDA_F_CDR_WIDTH;
parameter		BUS_CLOCK = 200;

input							clk;
input							wb_rst_i;
input							mir_mode;
input							mir_half;
input							fir_mode;
input	[CDR_WIDTH-1:0]	f_cdr;
input							en_reload;		// reload input forces reloading of l_cdr with f_cdr and restart the count
input							tx_select;
input							loopback_enable;

output						mir_txbit_enable;
output						mir_rxbit_enable;
output						fir_tx8_enable;
output						fir_tx4_enable;
output						fir_rx8_enable;
output						fir_rx4_enable;
output						fast_enable;

reg							fast_enable;
reg	[CDR_WIDTH-1:0]	l_cdr; // local cdr

reg	fir_tx8_enable;
reg	fir_tx4_enable;
reg	fir_rx8_enable;
reg	fir_rx4_enable;

wire	fast_tx_enable;
wire	fast_rx_enable;

always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i) begin
		fast_enable <= #1 0;
		l_cdr <= #1 (BUS_CLOCK/40)*MULT; // 40Mhz clock from a 200Mhz input clk
	end else begin
		if (en_reload) begin
			fast_enable <= #1 0;
			l_cdr <= #1 f_cdr;
		end else begin
			if (l_cdr > MULT) begin
				fast_enable <= #1 0;
				l_cdr <= #1 l_cdr - MULT;
			end else begin
				fast_enable <= #1 1;
				l_cdr <= #1 (f_cdr - MULT) + l_cdr;
			end
		end
	end
end

assign	fast_rx_enable = (loopback_enable || ! tx_select) ? fast_enable : 0;
assign	fast_tx_enable = (loopback_enable || tx_select )  ? fast_enable : 0;


reg	[2:0]	count8;
reg	[2:0]	count8a;
reg	[2:0]	count8_reset_value;

reg mir_txbit_enable; // enable for mir transmitter that operates on bit-time level
reg mir_rxbit_enable; // enable for mir receiver that operates on bit-time level

always @(mir_mode or mir_half)
begin
	if (mir_mode)
		if (mir_half)
			count8_reset_value <= 7;
		else
			count8_reset_value <= 3;
	else
		count8_reset_value <= 7;
end

// mir_txbit_enable generator
always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i) begin
		count8 <= #1 1;
		mir_txbit_enable <= #1 0;
	end else
		if (fast_tx_enable && mir_mode)
			if (count8==0) begin
				mir_txbit_enable <= #1 1;
				count8 <= #1 count8_reset_value;
			end else begin
				mir_txbit_enable <= #1 0;
				count8 <= #1 count8 - 1;
			end
		else
			mir_txbit_enable <= #1 0;
end

// mir_rxbit_enable generator
always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i) begin
		count8a <= #1 1;
		mir_rxbit_enable <= #1 0;
	end else
		if (fast_rx_enable && mir_mode)
			if (count8a==0) begin
				mir_rxbit_enable <= #1 1;
				count8a <= #1 count8_reset_value;
			end else begin
				mir_rxbit_enable <= #1 0;
				count8a <= #1 count8a - 1;
			end
		else
			mir_rxbit_enable <= #1 0;
end

//fir_tx8_enable
reg [2:0] count8b;

always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i) begin
		count8b <= #1 4;
		fir_tx8_enable <= #1 0;
	end else
		if (fast_tx_enable && fir_mode)
			if (count8b==0) begin
				fir_tx8_enable  <= #1 1;
				count8b <= #1 4;
			end else begin
				fir_tx8_enable <= #1 0;
				count8b <= #1 count8b - 1;
			end
		else
			fir_tx8_enable <= #1 0;
end

//fir_tx4_enable
reg [3:0] count16;

always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i) begin
		count16 <= #1 9;
		fir_tx4_enable <= #1 0;
	end else
		if (fast_tx_enable && fir_mode)
			if (count16==0) begin
				fir_tx4_enable  <= #1 1;
				count16 <= #1 9;
			end else begin
				fir_tx4_enable <= #1 0;
				count16 <= #1 count16 - 1;
			end
		else
			fir_tx4_enable <= #1 0;
end

//fir_rx8_enable
reg [2:0] count8c;

always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i) begin
		count8c <= #1 4;
		fir_rx8_enable <= #1 0;
	end else
		if (fast_rx_enable && fir_mode)
			if (count8c==0) begin
				fir_rx8_enable  <= #1 1;
				count8c <= #1 4;
			end else begin
				fir_rx8_enable <= #1 0;
				count8c <= #1 count8c - 1;
			end
		else
			fir_rx8_enable <= #1 0;
end

//fir_tx4_enable
reg [3:0] count16a;

always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i) begin
		count16a <= #1 9;
		fir_rx4_enable <= #1 0;
	end else
		if (fast_rx_enable && fir_mode)
			if (count16a==0) begin
				fir_rx4_enable  <= #1 1;
				count16a <= #1 9;
			end else begin
				fir_rx4_enable <= #1 0;
				count16a <= #1 count16a - 1;
			end
		else
			fir_rx4_enable <= #1 0;
end

endmodule
