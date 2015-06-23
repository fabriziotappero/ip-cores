`include "irda_defines.v"
module irda_fir_tx (clk, wb_rst_i, fir_tx8_enable, fir_tx4_enable,
		count_mode, f_fcr, f_ofdlr, sip_o, sip_end_i, fir_tx_o,
// Data controller interface
		data_available, data_o, dc_restart_fir, next_data_fir	);

input				clk;
input				wb_rst_i;
input				fir_tx8_enable;
input				fir_tx4_enable;
input				count_mode;
input	[7:0]		f_fcr;
input	[15:0]	f_ofdlr;
input				sip_end_i; // changes to '1' when SIP pulse was sent

input				data_o; // data input from data controller
input				data_available;

output			dc_restart_fir;
output			next_data_fir;
output			sip_o;     // a '1' requests an SIP pulse output
output			fir_tx_o;  // transmitter output

wire				restart_tx = f_fcr[6];
wire				underrun_action = f_fcr[7];

reg				fir_tx_o;
reg		[1:0]	fir_flag;
reg				sip_o;
reg				fir_gen_start;
reg				next_data_fir;
reg				clrcrc;
reg				crcndata;

reg				do_dc_restart; // data controller restart from the FSM
reg				do_ppm_restart; // connected to ppm_restart

assign	dc_restart_fir = do_dc_restart | restart_tx;


// STx and PA flags generator
irda_fir_flag_gen flag_gen(
		.clk(					clk				),
		.wb_rst_i(			wb_rst_i			),
		.fir_tx8_enable(	fir_tx8_enable	),
		.fir_tx4_enable(	fir_tx4_enable	),
		.fir_gen_start(	fir_gen_start	),
		.fir_flag(			fir_flag			),
		.flag_gen_o(		flag_gen_o		),
		.eof(					eof				),
		.gen_signal(		gen_signal		)
	);

// 4ppm encoder
irda_fir_4ppm_encoder ppm_enc(
		.clk(					clk				),
		.wb_rst_i(			wb_rst_i			),
		.ppm_restart(		ppm_restart		),
		.fir_tx8_enable(	fir_tx8_enable	),
//		.fir_tx4_enable(	fir_tx4_enable	),
//		.next_data_fir(	next_data_fir	),
		.txdout(				txdout			),
		.ppm_o(				ppm_o				)
	);

// CRC32 transmiter
irda_crc32 crctx(
		.clk(					clk				),
		.wb_rst_i(			wb_rst_i			),
		.clrcrc(				clrcrc			),
		.fir_tx4_enable(	fir_tx4_enable ),
		.txdin(				txdin				),
		.crcndata(			crcndata			),
		.txdout(				txdout			),
		.bdcrc(				1'b0				)
	);

assign txdin = data_o;
assign ppm_restart = do_ppm_restart;// | restart_tx;


////////////////////////////
/// FIR transmitter FSM
////////////////////////////
parameter	st_idle=0, st_send_pa=1, st_send_sta=2, st_data=3,
				st_crc_out=4, st_break_out=5, st_send_sto=6, st_send_sip=7;

reg	[2:0]		state;

reg	[19:0]	ofdl_c;	// outgoing frame data length counter (it counts bits here)
reg	[1:0]		mux_select; // output mux select signal
reg	[5:0]		counter;

always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i) begin
		state				<= #1 st_idle;
		mux_select		<= #1 2'b10; // zero output
		ofdl_c			<= #1 0;
		next_data_fir	<= #1 0;
		fir_flag			<=	#1 0;
		sip_o				<=	#1 0;
		clrcrc			<= #1 0;
		fir_gen_start	<=	#1 0;
		do_dc_restart	<=	#1 0;
		do_ppm_restart <= #1 0;
		counter			<= #1 0;
		crcndata			<= #1 0;
	end else if (restart_tx) begin
		state				<= #1 st_break_out;
		mux_select		<= #1 2'b10; // zero output
		ofdl_c			<= #1 0;
		next_data_fir	<= #1 0;
		fir_flag			<=	#1 0;
		sip_o				<=	#1 0;
		clrcrc			<= #1 1;
		fir_gen_start	<=	#1 0;
		do_dc_restart	<=	#1 0;
		do_ppm_restart <= #1 0;
		crcndata			<= #1 0;
		counter			<= #1 0;
	end else if (fir_tx8_enable)
	case (state)
		st_idle :
			begin
				if (data_available) begin
					state 			  <= #1 st_send_pa;
					fir_gen_start 	  <= #1 1;
					fir_flag 		  <= #1 2'b01; // PA signal
					ofdl_c 			  <= #1 0;
					sip_o 			  <= #1 0;
					mux_select 		  <= #1 2'b00; // flag output
				end else begin
					fir_gen_start 	  <= #1 0;
					mux_select		  <= #1 2'b10;
				end
				crcndata 		  <= #1 0;
				next_data_fir 	  <= #1 0;
			end
		st_send_pa :
			begin
				clrcrc 				<= #1 1;
				if (eof) begin
					state 			  <= #1 st_send_sta;
					fir_gen_start 	  <= #1 1;
					fir_flag 		  <= #1 2'b10;
					mux_select 		  <= #1 2'b00; // flag output
				end else
					fir_gen_start <= #1 0;
			end
		st_send_sta :
			begin
				if (gen_signal) begin
					next_data_fir 		<= #1 1;
					do_ppm_restart 	<= #1 1;
					clrcrc 				<= #1 0;
				end else begin
					do_ppm_restart 	<= #1 0;
				end
				if (eof) begin
//					do_dc_restart <= #1 1;
					state 				<= #1 st_data;
					mux_select 			<= #1 2'b01;
				end else begin
					fir_gen_start <= #1 0;
				end
			end
		st_data :
			begin
				do_ppm_restart 	<= #1 0;
				clrcrc 				<= #1 0;
				// conditions for next step (CRC)
				if((count_mode && (ofdl_c[19:4]==f_ofdlr)) || (!count_mode && !data_available && underrun_action==1) ) begin
					state 			  <= #1 st_crc_out;
					crcndata 		  <= #1 1;
					mux_select 		  <= #1 2'b01;
					counter 			  <= #1 63;
					next_data_fir 	  <= #1 0;
				end else // next bit 
				if ((count_mode && (ofdl_c[19:4]!=f_ofdlr)) || (!count_mode && data_available)) begin
					next_data_fir 	  <= #1 1;
					ofdl_c 			  <= #1 ofdl_c + 1;
				end else begin /// break sequence
					counter 			  <= #1 8;
					state 			  <= #1 st_break_out;
					mux_select 		  <= #1 2'b10; // constant '0' output (break)
					next_data_fir 	  <= #1 0;
				end
			end
		st_crc_out :
			begin
				if (counter != 0)
					counter <= #1 counter - 1;
				else begin
					crcndata 		  <= #1 0;
					mux_select 		  <= #1 2'b00; // flag generator
					state 			  <= #1 st_send_sto;
					fir_gen_start 	  <= #1 1;
					fir_flag 		  <= #1 2'b11; // STO signal
				end
			end
		st_send_sto :
			begin
				fir_gen_start <= #1 0;
				if (eof) begin
					state 		  <= #1 st_send_sip;
					fir_flag 	  <= #1 0;
					mux_select 	  <= #1 2'b10;
				end
			end
		st_break_out :
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

// module output mux
always @(mux_select or ppm_o or flag_gen_o)
	case (mux_select)
		2'b00 : fir_tx_o = flag_gen_o;
		2'b01 : fir_tx_o = ppm_o;
		default : fir_tx_o = 1'b0; // for break
	endcase

endmodule
