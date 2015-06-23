`include "irda_defines.v"
module irda_fir_flag_gen (clk, wb_rst_i, fir_tx4_enable, fir_tx8_enable,
		fir_gen_start, fir_flag, flag_gen_o, eof, gen_signal);
// generates PA/STA/STO flags
// fir_flag == 00 => 0 constant
// fir_flag == 01 => PA
// fir_flag == 10 => STA
// fir_flag == 11 => STO

input			clk;
input			wb_rst_i;
input			fir_tx8_enable;
input			fir_tx4_enable;
input			fir_gen_start;
input [1:0]	fir_flag;

output		flag_gen_o;
output		eof;  // end of flag signal
output		gen_signal;

// mux outputs (not from flip flop)
reg			flag_gen_o;
reg			eof;

// internal registers
wire	[1:0]	fir_flag;
//reg	[1:0]	flag;  // current flag
//reg			start; // start flag

wire [1:0]	flag = fir_flag;
//wire			start = ;

// internal signals logic
//always @(posedge clk or posedge wb_rst_i)
//begin
//	if (wb_rst_i) begin
//		flag <= #1 2'b00;
//		start <= #1 0;
//	end else if (fir_tx4_enable && fir_gen_start) begin
//		flag <= #1 fir_flag;
//		start <= #1 1;
//	end
//	else
//		start <= #1 0;
//end

// PA flag logic
reg	pa;
reg	[3:0] pa_symbol_count;
reg	pa_end;
reg	sending_pa;
reg	[3:0] count16;

always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i) begin
		pa <= #1 0;
		pa_symbol_count <= #1 0;
		pa_end <= #1 0;
		sending_pa <= #1 0;
		count16 <= #1 0;
	end else begin
		if (flag == 2'b01) begin
			if (fir_tx8_enable) begin
				if (/*fir_tx8_enable &&  fir_tx4_enable && */ fir_gen_start) begin
					pa <= #1 1;
					pa_symbol_count <= #1 1;				
					pa_end <= #1 0;
					sending_pa <= #1 1;
					count16 <= #1 0;
				end else if (sending_pa)begin
					case (pa_symbol_count)
						0,8,10,12 : pa <= #1 1;
						default : pa <= #1 0;
					endcase
					if (pa_symbol_count == 14) begin
						if (count16 == 15) begin  
							pa_end <= #1 1;
							sending_pa <= #1 0;
						end else begin
							count16 <= #1 count16 + 1;
						end
					end
					else
						pa_end <= #1 0;
					pa_symbol_count <= pa_symbol_count + 1;
				end // start
			end // fir_tx8_enable
		end else begin// flag == 2'b01
			pa <= #1 0;
			pa_end <= #1 0;
		end
	end
end

// STx flags logic
reg	st;
reg	[4:0] st_symbol_count;
reg	st_end;

always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i) begin
		st <= #1 0;
		st_symbol_count <= #1 0;
		st_end <= #1 0;
	end else begin
		if (flag[1] == 1'b1) begin
			if (fir_tx8_enable) begin // STA or STO
				if (/*fir_tx8_enable && fir_tx4_enable &&*/ fir_gen_start) begin
					st <= #1 0;
					st_symbol_count <= #1 1;		
					st_end <= #1 0;
				end else begin
					if (flag[0] == 1'b0)  // STA
						case (st_symbol_count)
							4,5,12,13,17,18,25,26 : st <= #1 1;
							default : st <= #1 0;
						endcase
					else // STO
						case (st_symbol_count)
							4,5,12,13,21,22,29,30 : st <= #1 1;
							default : st <= #1 0;
						endcase
					if (st_symbol_count == 31)
						st_end <= #1 1;
					else
						st_end <= #1 0;
					st_symbol_count <= st_symbol_count + 1;
				end // start
			end // fir_tx8_enable
		end else begin // flag[1] == 1'b1
			st_end <= #1 0;
			st <= #1 0;
		end
	end
end

assign gen_signal = (st_symbol_count == 29); // ppm_restart is sent 3 clocks before STA ends

// flag generator stream output
always @(flag or st or pa)
	case (flag)
		2'b00 : flag_gen_o = 0;
		2'b01 : flag_gen_o = pa;
		2'b10,
		2'b11 : flag_gen_o = st;
	endcase

// flag generator end of flag output
reg tmp_eof;
always @(flag or st_end or pa_end)
	case (flag)
		2'b00 : tmp_eof = 0;
		2'b01 : tmp_eof = pa_end;
		2'b10,
		2'b11 : tmp_eof = st_end;
	endcase

// eof signal is held for one 4Mhz clock
// needed because tmp_eof is held for 8Mhz clock period only
//always @(posedge clk or posedge wb_rst_i)
//	if (wb_rst_i)
//		eof <= #1 0;
//	else if (fir_tx8_enable)
//		eof <= #1 tmp_eof;

always @(tmp_eof)
begin
	eof = tmp_eof;
end


endmodule