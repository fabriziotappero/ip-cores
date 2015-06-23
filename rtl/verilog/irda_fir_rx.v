`include "irda_defines.v"
module irda_fir_rx (clk, wb_rst_i, fast_enable, fir_rx8_enable, fir_rx_restart,
		fir_rx4_enable, rx_pad_i, negate_rx, fir_ifdlr_o, rxfifo_dat_i, rxfifo_add, crc32_error, fir_sto_detected, fir_rx_error);

input					clk;
input					wb_rst_i;
input					fast_enable;
input					fir_rx8_enable;
input					fir_rx4_enable;
input					fir_rx_restart;
input					rx_pad_i;
input					negate_rx;

output	[15:0]	fir_ifdlr_o;
output	[31:0]	rxfifo_dat_i;
output				rxfifo_add;
output				crc32_error;
output				fir_sto_detected;
output				fir_rx_error;

wire		[15:0]	fir_ifdlr_o;
reg		[31:0]	rxfifo_dat_i;
reg					rxfifo_add;
wire		[31:0]	crc32_par_o;
reg					crc32_error;
reg 					clrcrc;
reg 					ppmd_restart;

wire 					rx_i = rx_pad_i ^ negate_rx;

// Bit syncronizer (starts syncronizing on bs_restart)
irda_fir_bit_sync bit_sync(
		.clk(					clk				),
		.wb_rst_i(			wb_rst_i			),
		.fir_rx8_enable(	fir_rx8_enable	),
		.fir_rx4_enable(	fir_rx4_enable	),							
		.bs_restart(		bs_restart		),
		.rx_i(				rx_i	 			),
		.fast_enable(		fast_enable		),
		.bs_o(				bs_o				)
	);

// FIR flag detector
irda_fir_flag_det fir_fd(
		.clk(					clk				),
		.wb_rst_i(			wb_rst_i			),
		.fd_restart(		fd_restart		),
		.fir_rx8_enable(	fir_rx8_enable	),
		.bs_o (				bs_o 				),
		.pa_det(				pa_det			),
		.sta_det(			sta_det			),
		.sto_det(			sto_det			),
		.break_det(			break_det		),
		.fd_data_bit(		fd_data_bit		),
		.fd_o(				fd_o				)
	);

// 4ppm decoder
irda_fir_4ppm_decoder ppm_dec(
		.clk(					clk				),
		.wb_rst_i(			wb_rst_i			),
		.fir_rx8_enable(	fir_rx8_enable	),
		.ppmd_restart(		ppmd_restart	),
		.fd_o (				fd_o 				),
		.ppmd_o(				ppmd_o			),
		.ppmd_bad_chip(	ppmd_bad_chip	),
		.fd_data_bit(	fd_data_bit)					
	);

// CRC32 for receiver
irda_crc32_rx crc32rx(
		.clk(					clk				),
		.wb_rst_i(			wb_rst_i			),
		.clrcrc(				clrcrc			),
		.fir_rx4_enable(	fir_rx4_enable	),
		.txdin(				txdin				),
		.crcndata(			1'b0				),
		.txdout(							),
		.bdcrc(				1'b0				),
		.crc32_par_o(		crc32_par_o		)
	);

assign 		txdin = ppmd_o;
assign 		bs_restart = fir_rx_restart;
//assign ppmd_restart = fir_rx_restart;
assign 		fd_restart = fir_rx_restart;

/// STO signal delay for 2 4Mhz clocks
reg [1:0] 	sto_det_delay;
always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i) begin
		sto_det_delay <= #1 0;
	end else if (fir_rx4_enable) begin
		sto_det_delay[1] <= #1 sto_det_delay[0];
		sto_det_delay[0] <= #1 sto_det;
	end
end

wire fir_sto_detected = sto_det_delay[1];


////////////////////////
/// FIR Receiver FSM ///   <== Not finished yet!!!!
////////////////////////

parameter st_idle=0, st_rec_pa=1, st_rec_sta=2, st_data=3, st_crc_check=4;
reg	[2:0] state;
reg	[30:0] temp32; // temporary register for 4-byte word build
reg	[4:0] count32; // count position in temp32;
reg	[18:0] bitcount;

assign 		fir_rx_error = (ppmd_bad_chip | break_det) && (state==st_data);

always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i) begin
		state 			 <= #1 st_idle;
		temp32 			 <= #1 0;
		count32 			 <= #1 0;
		rxfifo_add 		 <= #1 0;
		rxfifo_dat_i 	 <= #1 0;
		bitcount 		 <= #1 0;
		crc32_error 	 <= #1 0;
		ppmd_restart 	 <= #1 0;
		clrcrc 			 <= #1 0;
	end else if (fir_rx_restart || ( fir_rx4_enable && (state==st_data) && (break_det | ppmd_bad_chip))) begin
		state 			 <= #1 st_idle;
		temp32 			 <= #1 0;
		count32 			 <= #1 0;
		rxfifo_add 		 <= #1 0;
		rxfifo_dat_i 	 <= #1 0;
		crc32_error 	 <= #1 0;
		clrcrc 			 <= #1 0;
	end else if (fir_rx8_enable )begin
	case (state)
		st_idle :
				if (pa_det)
					state <= #1 st_rec_pa;
		st_rec_pa :
			begin
				clrcrc <= #1 1;
				if (sta_det) begin
					state <= #1 st_rec_sta;
					count32 <= #1 17; // 16-flag + 3 delay through 4ppm decoder - 1
				end
				bitcount <= #1 0;
			end
		st_rec_sta :
			if (fir_rx4_enable)
				if (count32==0) begin
					state 	<= #1 st_data;
					clrcrc	<= #1 0;
				end else if (count32==2) begin
					ppmd_restart 	 <= #1 1;
					count32 			 <= #1 count32 - 1;
				end else begin
					count32 			 <= #1 count32 - 1;
					ppmd_restart 	 <= #1 0;
				end
		st_data :
			begin
				if (fir_rx8_enable)
					if (sto_det) begin // end of frame
						state <= #1 st_crc_check;
					end else if (fir_rx4_enable) begin // receiving data
						bitcount <= #1 bitcount + 1;
						if (count32==31) begin // end of word
							count32 <= #1 0;
						end else begin  // add next bit
							temp32[count32] <= #1 ppmd_o;
							count32 <= #1 count32 + 1;
						end
					end	
			end
		st_crc_check :
			begin
				if (fir_rx4_enable) begin
					if (crc32_par_o==32'b1100_0111_0000_0100_1101_1101_0111_1011) begin
						crc32_error <= #1 0;
					end else begin
						crc32_error <= #1 1;
					end
					state <= #1 st_idle;
				end
			end
		default :
			state <= #1 st_idle;
	endcase
	end // if (fir_rx4_enable)
end // always

// rx fifo signals
// The signals are only active for one clock
always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i) begin
		rxfifo_add <= #1 0;
		rxfifo_dat_i <= #1 0;
	end else if (fir_rx4_enable && state==st_data && (count32==31 || fir_sto_detected)) begin
		rxfifo_add <= #1 1;
		rxfifo_dat_i <= #1 {ppmd_o, temp32};
	end else begin
		rxfifo_add <= #1 0;
		rxfifo_dat_i <= #1 0;
	end
end // always @ (posedge clk or posedge wb_rst_i)

// DEBUG
always @(rxfifo_add)
	if (rxfifo_add) begin
		#1 $display("%m, Pushing %h", rxfifo_dat_i);
	end


assign fir_ifdlr_o = bitcount[18:3];

endmodule
