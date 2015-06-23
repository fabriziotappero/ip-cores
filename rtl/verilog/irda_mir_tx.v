`include "irda_defines.v"

module irda_mir_tx (clk, wb_rst_i, mir_txbit_enable, sip_end_i, data_o,
	 count_mode, f_fcr, f_ofdlr, mir_tx_o, sip_o,
	 dc_restart, next_data, data_available);

input								clk;
input								wb_rst_i;
input								count_mode;
input	[7:0]						f_fcr;
input	[15:0]					f_ofdlr;
input								sip_end_i; // changes to '1' when SIP pulse was sent
input								mir_txbit_enable;
input								data_o;
input								data_available;

output							mir_tx_o;
output							sip_o;     // a '1' requests an SIP pulse output
output							dc_restart; // data controller restart
output							next_data; // next data request for data controller

//	Internal	registers
// Data bit controller
//reg				next_data;
// STA/STO sequence generator
reg				st_restart;
reg				st_shift;

reg [1:0]		mux_select;
reg				sip_o;
reg				mir_tx_o;
// CRC registers
reg				clrcrc;	// clear crc logic
reg				crcndata; // when '0' the crc is calculated, when '1' - the crc is output serially. see crc file.

reg				bs_restart;
reg				dc_restart;
wire				underrun_action = f_fcr[7];

wire	bdcrc = 0; // set to 1 to create bad crc output (for debug)

//	STA/STO sequence generators
irda_mir_st_gen st_gen(
		.clk(					clk				),	
		.wb_rst_i(			wb_rst_i			),	
		.st_restart(		st_restart		),	
		.st_shift(			st_shift			),
		.st_out(				st_out			),
		.mir_txbit_enable(	mir_txbit_enable	)
	 );

//	Bit stuffer	
irda_mir_bit_stuffer	bst (
		.clk(					clk				),
		.wb_rst_i(			wb_rst_i			),
		.bs_restart(		bs_restart		),
//		.stuffer_shift_i(	stuffer_shift_i),
		.stuffer_i(			stuffer_i		),
		.shift_req_o(		shift_req_o		),
		.stuffer_o(			stuffer_o		),
		.mir_txbit_enable(	mir_txbit_enable	)
	 );

// CRC-CCITT 16-bit
irda_crc_ccitt16 crc16(
		.clk(					clk				), 
		.wb_rst_i(			wb_rst_i			), 
		.clrcrc(				clrcrc			), 
		.txdin(				txdin				), 
		.crcndata(			crcndata			),
		.mir_txbit_enable(	crc_mir_txbit_enable	),
		.txdout(				txdout			), 
		.bdcrc(				bdcrc				)
	);

// interblock assignments
assign txdin = data_o;
assign stuffer_i = crcndata ? txdout : data_o; // stuffer should handle both data and crc
assign next_data = shift_req_o && (mux_select == 2'b11);
assign crc_mir_txbit_enable = mir_txbit_enable && shift_req_o;

////////////////////////////
/// MIR transmitter FSM
////////////////////////////
parameter	st_idle=0, st_sta_count=1, st_send_data=2, st_break=3,
				st_crc_out1=4, st_stop_frame=5, st_send_sip=6;

reg [3:0] counter;	// short counter up to 16
reg [18:0] ofdl_c;	// outgoing frame data length counter (it counts bits here)

reg [2:0] state;

always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i) begin
		state 		  <= #1 st_idle;
		mux_select 	  <= #1 0;
		st_restart 	  <= #1 0;
		st_shift 	  <= #1 0;
		counter 		  <= #1 0;
		ofdl_c 		  <= #1 0;
		sip_o 		  <= #1 0;
		clrcrc 		  <= #1 0;
		crcndata 	  <= #1 0;
		bs_restart 	  <= #1 0;
	end else
	if (f_fcr[6]) begin // if clear transmitter
		counter 		  <= #1 7;
		mux_select 	  <= #1 2'b0;
		state 		  <= #1 st_break;
		crcndata 	  <= #1 0;
		dc_restart 	  <= #1 1;
	end else
	if (mir_txbit_enable) // only work when enabled
	case (state)
	st_idle :  // between frames
	  begin
		  dc_restart 	 <= #1 0;
		  bs_restart 	 <= #1 1;
		  sip_o 			 <= #1 0;
			if (data_available) begin
				state 		  <= #1 st_sta_count;
				mux_select 	  <= #1 2'b01; // ST signal selection
				ofdl_c 		  <= #1 0;
				st_restart 	  <= #1 0;
				st_shift 	  <= #1 1;
				counter 		  <= #1 15; // two start flags in each frame
			end
			else begin
				st_restart 	  <= #1 1;
				st_shift 	  <= #1 0;
				mux_select 	  <= #1 2'b0; /// break
			end
			crcndata <= #1 0;
		end
	st_sta_count :
	  begin
		  if (counter==1) begin
			  bs_restart 	 <= #1 0;
		  end	
		  if (counter==0) begin
			  state 			 <= #1 st_send_data; //
			  mux_select 	 <= #1 2'b11; // select data in mux
			  st_shift 		 <= #1 0;
			  ofdl_c 		 <= #1 ofdl_c + 1;
			  clrcrc 		 <= #1 0;
		  end else begin
			  counter 	  <= #1 counter - 1;
			  st_shift 	  <= #1 1;
			  clrcrc 	  <= #1 1;
		  end
	  end
	st_send_data :
	  begin
		  //// DEBUG
		 /// $display("%m, %t, sending: %b", $time, mir_tx_o);
		  //// END DEBUG
			st_restart <= #1 1;
			// conditions for next step (CRC)
			if((count_mode && (ofdl_c[18:3]==f_ofdlr)) || (!count_mode && !data_available && underrun_action==1) ) begin
				state 		  <= #1 st_crc_out1;
				/// DEBUG
//				$display("%m, %t CRCOUT: %x", $time, ~crc16.nxtxcrc);
				/// END DEBUG
				crcndata 	  <= #1 1;
				mux_select 	  <= #1 2'b10;
				counter 		  <= #1 15;
			end else // next bit 
			if ((count_mode && (ofdl_c[18:3]!=f_ofdlr)) || (!count_mode && data_available)) begin
				if (shift_req_o) // don't count if we're sending a stuffed 0
					ofdl_c <= #1 ofdl_c + 1;
			end else begin /// break sequence
				counter 		  <= #1 7;
				state 		  <= #1 st_break;
				mux_select 	  <= #1 0; // constant '1' output (break)
			end
		end
	st_crc_out1 :
		begin
			st_restart <= #1 0;
			if (counter!=0) begin
				if (shift_req_o) begin
					counter <= #1 counter - 1;
				end
			end
			else begin
				state 		  <= #1 st_stop_frame;
				mux_select 	  <= #1 2'b01; // ST signal selection
				counter 		  <= #1 7;
				crcndata 	  <= #1 0;
				st_shift 	  <= #1 1;
			end
		end
	st_stop_frame :
		begin
			if (counter==0) begin
				state 		  <= #1 st_send_sip; // send sip after frame's end
				st_shift 	  <= #1 0;
				mux_select 	  <= #1 2'b0;
			end else begin
				counter 		<= #1 counter - 1;
				st_shift 	<= #1 1;
			end
		end
	st_break :
		begin
			if (counter!=0)
				counter <= #1 counter - 1;
			else
				state <= #1 st_send_sip; // send SIP
		end
	st_send_sip :
		begin
			sip_o <= #1 1;
			if (sip_end_i)
				state <= #1 st_idle;
		end
		default : 
			state <= #1 st_idle;
	endcase
end

always @(mux_select or st_out or stuffer_o)
begin
	case (mux_select)
		2'b00 : mir_tx_o = 1; // constant 1 (break)
		2'b01 : mir_tx_o = st_out;
		2'b10 : mir_tx_o = stuffer_o; // crc is outputted through bit stuffer
		2'b11 : mir_tx_o = stuffer_o; // data out is passed through bit stuffer ,too
	endcase
end

endmodule	//	irda_mir_tx
