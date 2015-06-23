// F:\XILINX\MY-PROJECTS\SPACEWIRE_1355
// Verilog Test fixture created by
// HDL Bencher 6.1i
// Fri Apr 01 11:54:23 2005
// 
// Notes:
// 1) This test fixture has been automatically generated from
//   your Test Bench Waveform
// 2) To use this as a user modifiable test fixture do the following:
//   - Save it as a file with a .tf extension (i.e. File->Save As...)
//   - Add it to your project as a testbench source (i.e. Project->Add Source...)
// 

`timescale 1ns/1ns

module tb_PPU;
	wire [5:0] state_o;
	wire active_o;
	reg lnk_start;
	reg lnk_dis;
	reg AUTOSTART;
	wire LINK_ERR_o;
	wire err_sqc;
	wire RST_tx_o;
	wire enTx_o;
	reg err_crd_i;
	wire RST_rx_o;
	wire enRx_o;
	reg Lnk_dsc_i;
	reg gotBit_i;
	reg gotFCT_i;
	reg gotNchar_i;
	reg gotTime_i;
	reg gotNULL_i;
	reg err_par_i;
	reg err_esc_i;
	reg err_dsc_i;
	reg reset;
	reg gclk;
	reg clk10;
	reg GSR; 	//Global signal, this was added automatically

	assign glbl.GSR = GSR;
			/*
	defparam UUT.StateNum = 6;
	defparam UUT.ErrorReset = 1;
	defparam UUT.ErrorWait = 2;
	defparam UUT.Ready = 4;
	defparam UUT.Started = 8;
	defparam UUT.Connecting = 16;
	defparam UUT.Run = 32;
	defparam UUT.DEFLT = 0;
	defparam UUT.True = 1;
	defparam UUT.False = 0;
	defparam UUT.NUM_T6_4uS = 63;
	defparam UUT.NUM_T12_8uS = 127;
	defparam UUT.TIMERW = 7;		 */

	SPW_FSM UUT (
		.state_o(state_o),
		.active_o(active_o),
		.lnk_start(lnk_start),
		.lnk_dis(lnk_dis),
		.AUTOSTART(AUTOSTART),
		.LINK_ERR_o(LINK_ERR_o),
		.err_sqc(err_sqc),
		.RST_tx_o(RST_tx_o),
		.enTx_o(enTx_o),
		.err_crd_i(err_crd_i),
		.RST_rx_o(RST_rx_o),
		.enRx_o(enRx_o),
		.Lnk_dsc_i(Lnk_dsc_i),
		.gotBit_i(gotBit_i),
		.gotFCT_i(gotFCT_i),
		.gotNchar_i(gotNchar_i),
		.gotTime_i(gotTime_i),
		.gotNULL_i(gotNULL_i),
		.err_par_i(err_par_i),
		.err_esc_i(err_esc_i),
		.err_dsc_i(err_dsc_i),
		.reset(reset),
		.gclk(gclk)
	//	.clk10(clk10)
	);

	integer TX_FILE;
	integer TX_ERROR;

always
begin 			//clock process
	clk10 = 1'b0;
	#4
	clk10 = 1'b1;
	#20
	#30
	clk10 = 1'b0;
	#46
	clk10 = 1'b0;
end

always
begin 			//clock process
	gclk = 1'b0;
	#4
	gclk = 1'b1;
	#5
	#5
	gclk = 1'b0;
	#6
	gclk = 1'b0;
end

initial
begin
	GSR = 1;
	#100 GSR = 0;
end

initial
begin
	TX_ERROR=0;
	TX_FILE=$fopen("results.txt");

	// --------------------
	lnk_start = 1'b0;
	lnk_dis = 1'b0;
	AUTOSTART = 1'b0;
	err_crd_i = 1'b0;
	Lnk_dsc_i = 1'b0;
	gotBit_i = 1'b0;
	gotFCT_i = 1'b0;
	gotNchar_i = 1'b0;
	gotTime_i = 1'b0;
	gotNULL_i = 1'b0;
	err_par_i = 1'b0;
	err_esc_i = 1'b0;
	err_dsc_i = 1'b0;
	reset = 1'b1;
	// --------------------
	#60 // Time=60 ns
	reset = 1'b0;
	// --------------------
	#40 // Time=100 ns
	lnk_start = 1'b1;
	AUTOSTART = 1'b1;
	//=============================200uS
	#1600
	gotNULL_i = 1'b0;
	// --------------------
	#200 // Time=300 ns
	gotBit_i = 1'b1;
	// --------------------
	#220 // Time=520 ns
	gotNULL_i = 1'b1;
	// --------------------
	#60 // Time=580 ns
	gotNULL_i = 1'b0;
	// --------------------
	#100 // Time=680 ns
	gotFCT_i = 1'b1;
	// --------------------
	#60 // Time=740 ns
	gotFCT_i = 1'b0;
	// --------------------
	#540 // Time=1280 ns
	lnk_dis = 1'b1;
	// --------------------
	#40 // Time=1320 ns
	lnk_dis = 1'b0;
	// --------------------
	#134 // Time=1454 ns
	// --------------------

	if (TX_ERROR == 0) begin
		$display("No errors or warnings");
		$fdisplay(TX_FILE,"No errors or warnings");
	end else begin
		$display("%d errors found in simulation",TX_ERROR);
		$fdisplay(TX_FILE,"%d errors found in simulation",TX_ERROR);
	end

	$fclose(TX_FILE);
	$stop;

end

task CHECK_state_o;
	input [5:0] NEXT_state_o;

	#0 begin
		if (NEXT_state_o !== state_o) begin
			$display("Error at time=%dns state_o=%b, expected=%b",
				$time, state_o, NEXT_state_o);
			$fdisplay(TX_FILE,"Error at time=%dns state_o=%b, expected=%b",
				$time, state_o, NEXT_state_o);
			TX_ERROR = TX_ERROR + 1;
		end
	end
endtask

task CHECK_active_o;
	input NEXT_active_o;

	#0 begin
		if (NEXT_active_o !== active_o) begin
			$display("Error at time=%dns active_o=%b, expected=%b",
				$time, active_o, NEXT_active_o);
			$fdisplay(TX_FILE,"Error at time=%dns active_o=%b, expected=%b",
				$time, active_o, NEXT_active_o);
			TX_ERROR = TX_ERROR + 1;
		end
	end
endtask

task CHECK_LINK_ERR_o;
	input NEXT_LINK_ERR_o;

	#0 begin
		if (NEXT_LINK_ERR_o !== LINK_ERR_o) begin
			$display("Error at time=%dns LINK_ERR_o=%b, expected=%b",
				$time, LINK_ERR_o, NEXT_LINK_ERR_o);
			$fdisplay(TX_FILE,"Error at time=%dns LINK_ERR_o=%b, expected=%b",
				$time, LINK_ERR_o, NEXT_LINK_ERR_o);
			TX_ERROR = TX_ERROR + 1;
		end
	end
endtask

task CHECK_err_sqc;
	input NEXT_err_sqc;

	#0 begin
		if (NEXT_err_sqc !== err_sqc) begin
			$display("Error at time=%dns err_sqc=%b, expected=%b",
				$time, err_sqc, NEXT_err_sqc);
			$fdisplay(TX_FILE,"Error at time=%dns err_sqc=%b, expected=%b",
				$time, err_sqc, NEXT_err_sqc);
			TX_ERROR = TX_ERROR + 1;
		end
	end
endtask

task CHECK_RST_tx_o;
	input NEXT_RST_tx_o;

	#0 begin
		if (NEXT_RST_tx_o !== RST_tx_o) begin
			$display("Error at time=%dns RST_tx_o=%b, expected=%b",
				$time, RST_tx_o, NEXT_RST_tx_o);
			$fdisplay(TX_FILE,"Error at time=%dns RST_tx_o=%b, expected=%b",
				$time, RST_tx_o, NEXT_RST_tx_o);
			TX_ERROR = TX_ERROR + 1;
		end
	end
endtask

task CHECK_enTx_o;
	input NEXT_enTx_o;

	#0 begin
		if (NEXT_enTx_o !== enTx_o) begin
			$display("Error at time=%dns enTx_o=%b, expected=%b",
				$time, enTx_o, NEXT_enTx_o);
			$fdisplay(TX_FILE,"Error at time=%dns enTx_o=%b, expected=%b",
				$time, enTx_o, NEXT_enTx_o);
			TX_ERROR = TX_ERROR + 1;
		end
	end
endtask

task CHECK_RST_rx_o;
	input NEXT_RST_rx_o;

	#0 begin
		if (NEXT_RST_rx_o !== RST_rx_o) begin
			$display("Error at time=%dns RST_rx_o=%b, expected=%b",
				$time, RST_rx_o, NEXT_RST_rx_o);
			$fdisplay(TX_FILE,"Error at time=%dns RST_rx_o=%b, expected=%b",
				$time, RST_rx_o, NEXT_RST_rx_o);
			TX_ERROR = TX_ERROR + 1;
		end
	end
endtask

task CHECK_enRx_o;
	input NEXT_enRx_o;

	#0 begin
		if (NEXT_enRx_o !== enRx_o) begin
			$display("Error at time=%dns enRx_o=%b, expected=%b",
				$time, enRx_o, NEXT_enRx_o);
			$fdisplay(TX_FILE,"Error at time=%dns enRx_o=%b, expected=%b",
				$time, enRx_o, NEXT_enRx_o);
			TX_ERROR = TX_ERROR + 1;
		end
	end
endtask

endmodule
