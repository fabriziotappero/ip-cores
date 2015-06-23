// F:\XILINX\MY-PROJECTS\SPACEWIRE_1355
// Verilog Test fixture created by
// HDL Bencher 6.1i
// Thu Mar 31 21:28:36 2005
// 
// Notes:
// 1) This test fixture has been automatically generated from
//   your Test Bench Waveform
// 2) To use this as a user modifiable test fixture do the following:
//   - Save it as a file with a .tf extension (i.e. File->Save As...)
//   - Add it to your project as a testbench source (i.e. Project->Add Source...)
// 

`timescale 1ns/1ns

module tb_Receiver;
	wire gotBIT_o;
	wire gotFCT_o;
	wire gotNchar_o;
	wire gotTIME_o;
	wire gotNULL_o;
	wire err_par;
	wire err_esc;
	wire err_dsc;
	wire RxErr_o;
	reg Si;
	reg Di;
	reg EnRx_i;
	reg C_Send_FCT_i;
	wire wrtbuf_o;
	wire type_o;
	wire [7:0] RxData_o;
	reg full_i;
//	reg [7:0] Vec_Rxfifo;
	wire Lnk_dsc_o;
	//wire RxClk_o;
	wire rx_drvclk_o;
	wire TICK_OUT;
	wire [1:0] CtrlFlg_o;
	wire [5:0] TIMEout;
	wire DLL_LOCKED;
	reg [5:0] state_i;
	reg reset;
	reg clk10;
	reg GSR; 	//Global signal, this was added automatically

	assign glbl.GSR = GSR;
	/*
	defparam UUT.StateNum = 3;
	defparam UUT.RESET = 1;
	defparam UUT.HUNTING = 2;
	defparam UUT.CHECK_CHAR = 4;
	defparam UUT.DEFLT = 0;
	defparam UUT.CrdCntW = 6;
	defparam UUT.RCVW = 14;
	defparam UUT.True = 1;
	defparam UUT.False = 0;
	defparam UUT.FCT = 1;
	defparam UUT.ESC = 7;
	defparam UUT.EOP = 5;
	defparam UUT.EEP = 3;
	defparam UUT.NULL = 23;
	defparam UUT.isESC_EEP = 55;
	defparam UUT.isESC_EOP = 87;
	defparam UUT.isESC_ESC = 119;
	defparam UUT.TIME_PATTERN = 15;		*/

	Receiver inst_Rx (
		.gotBIT_o(gotBIT_o),
		.gotFCT_o(gotFCT_o),
		.gotNchar_o(gotNchar_o),
		.gotTIME_o(gotTIME_o),
		.gotNULL_o(gotNULL_o),
		.err_par(err_par),
		.err_esc(err_esc),
		.err_dsc(err_dsc),
		.RxErr_o(RxErr_o),
		.Si(Si),
		.Di(Di),
		.EnRx_i(EnRx_i),
		.C_Send_FCT_i(C_Send_FCT_i),
		.wrtbuf_o(wrtbuf_o),
		.type_o(type_o),
		.RxData_o(RxData_o),
		.full_i(full_i),
	//	.Vec_Rxfifo(Vec_Rxfifo),
		.Lnk_dsc_o(Lnk_dsc_o),
		//.RxClk_o(RxClk_o),
		.rx_drvclk_o(rx_drvclk_o),
		.TICK_OUT(TICK_OUT),
		.CtrlFlg_o(CtrlFlg_o),
		.TIMEout(TIMEout),
		.DLL_LOCKED(DLL_LOCKED),
		.state_i(state_i),
		.reset(reset),
		.clk10(clk10)
	);

	integer TX_FILE;
	integer TX_ERROR;

always
begin 			//clock process
	clk10 = 1'b0;
	#10
	clk10 = 1'b1;
	#10
	#40
	clk10 = 1'b0;
	#40
	clk10 = 1'b0;
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
	Si = 1'b0;
	Di = 1'b0;
	EnRx_i = 1'b1;
	C_Send_FCT_i = 1'b0;
	full_i = 1'b0;
	Vec_Rxfifo = 8'b00000000; //0
	state_i = 6'b000001; //1
	reset = 1'b1;
	// --------------------
	#300 // Time=300 ns
	reset = 1'b0;
	// --------------------
	#1700 // Time=2000 ns
	state_i = 6'b000010; //2
	// --------------------
	#400 // Time=2400 ns
	Si = 1'b1;
	// --------------------
	#200 // Time=2600 ns
	Si = 1'b1;
	Di = 1'b1;
	// --------------------
	#200 // Time=2800 ns
	Si = 1'b0;
	Di = 1'b0;
	// --------------------
	#200 // Time=3000 ns
	Si = 1'b1;
	// --------------------
	#200 // Time=3200 ns
	Si = 1'b1;
	Di = 1'b1;
	// --------------------
	#200 // Time=3400 ns
	Si = 1'b0;
	// --------------------
	#200 // Time=3600 ns
	Di = 1'b0;
	// --------------------
	#200 // Time=3800 ns
	Si = 1'b1;
	// --------------------
	#200 // Time=4000 ns
	state_i = 6'b000100; //4
	// --------------------
	#800 // Time=4800 ns
	EnRx_i = 1'b0;
	// --------------------
	#500 // Time=5300 ns
	EnRx_i = 1'b1;
	// --------------------
	#300 // Time=5600 ns
	Si = 1'b0;
	// --------------------
	#400 // Time=6000 ns
	state_i = 6'b001000; //8
	// --------------------
	#200 // Time=6200 ns
	Si = 1'b1;
	// --------------------
	#200 // Time=6400 ns
	Di = 1'b1;
	// --------------------
	#200 // Time=6600 ns
	Si = 1'b0;
	// --------------------
	#100 // Time=6700 ns
	Si = 1'b0;
	// --------------------
	#100 // Time=6800 ns
	Si = 1'b1;
	// --------------------
	#200 // Time=7000 ns
	Di = 1'b0;
	// --------------------
	#200 // Time=7200 ns
	Di = 1'b1;
	// --------------------
	#200 // Time=7400 ns
	Di = 1'b0;
	// --------------------
	#200 // Time=7600 ns
	Si = 1'b0;
	// --------------------
	#200 // Time=7800 ns
	Si = 1'b1;
	// --------------------
	#200 // Time=8000 ns
	Si = 1'b0;
	state_i = 6'b010000; //10
	// --------------------
	#200 // Time=8200 ns
	Di = 1'b1;
	// --------------------
	#200 // Time=8400 ns
	Di = 1'b0;
	// --------------------
	#200 // Time=8600 ns
	Si = 1'b1;
	// --------------------
	#200 // Time=8800 ns
	Si = 1'b0;
	// --------------------
	#200 // Time=9000 ns
	Di = 1'b1;
	// --------------------
	#100 // Time=9100 ns
	state_i = 6'b010000; //10
	// --------------------
	#100 // Time=9200 ns
	Si = 1'b1;
	// --------------------
	#200 // Time=9400 ns
	Di = 1'b0;
	// --------------------
	#200 // Time=9600 ns
	Si = 1'b0;
	// --------------------
	#200 // Time=9800 ns
	Si = 1'b1;
	// --------------------
	#200 // Time=10000 ns
	Di = 1'b1;
	state_i = 6'b100000; //20
	// --------------------
	#200 // Time=10200 ns
	Di = 1'b0;
	// --------------------
	#200 // Time=10400 ns
	Si = 1'b0;
	// --------------------
	#200 // Time=10600 ns
	Di = 1'b1;
	// --------------------
	#200 // Time=10800 ns
	Si = 1'b1;
	// --------------------
	#200 // Time=11000 ns
	Di = 1'b0;
	// --------------------
	#200 // Time=11200 ns
	Si = 1'b0;
	// --------------------
	#200 // Time=11400 ns
	Si = 1'b1;
	// --------------------
	#200 // Time=11600 ns
	Si = 1'b0;
	// --------------------
	#200 // Time=11800 ns
	Di = 1'b1;
	// --------------------
	#200 // Time=12000 ns
	Si = 1'b1;
	state_i = 6'b100000; //20
	// --------------------
	#200 // Time=12200 ns
	Si = 1'b0;
	// --------------------
	#200 // Time=12400 ns
	Si = 1'b1;
	// --------------------
	#100 // Time=12500 ns
	Di = 1'b1;
	// --------------------
	#100 // Time=12600 ns
	Di = 1'b0;
	// --------------------
	#200 // Time=12800 ns
	Di = 1'b1;
	// --------------------
	#200 // Time=13000 ns
	Si = 1'b0;
	Di = 1'b0;
	// --------------------
	#100 // Time=13100 ns
	Si = 1'b0;
	// --------------------
	#900 // Time=14000 ns
	state_i = 6'b100000; //20
	// --------------------
	#2000 // Time=16000 ns
	state_i = 6'b000001; //1
	// --------------------
	#2000 // Time=18000 ns
	state_i = 6'b000010; //2
	// --------------------
	#2000 // Time=20000 ns
	state_i = 6'b000100; //4
	// --------------------
	#2000 // Time=22000 ns
	state_i = 6'b001000; //8
	// --------------------
	#2000 // Time=24000 ns
	state_i = 6'b010000; //10
	// --------------------
	#2000 // Time=26000 ns
	state_i = 6'b100000; //20
	// --------------------
	#2000 // Time=28000 ns
	state_i = 6'b100000; //20
	// --------------------
	#110 // Time=28110 ns
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

task CHECK_gotBIT_o;
	input NEXT_gotBIT_o;

	#0 begin
		if (NEXT_gotBIT_o !== gotBIT_o) begin
			$display("Error at time=%dns gotBIT_o=%b, expected=%b",
				$time, gotBIT_o, NEXT_gotBIT_o);
			$fdisplay(TX_FILE,"Error at time=%dns gotBIT_o=%b, expected=%b",
				$time, gotBIT_o, NEXT_gotBIT_o);
			TX_ERROR = TX_ERROR + 1;
		end
	end
endtask

task CHECK_gotFCT_o;
	input NEXT_gotFCT_o;

	#0 begin
		if (NEXT_gotFCT_o !== gotFCT_o) begin
			$display("Error at time=%dns gotFCT_o=%b, expected=%b",
				$time, gotFCT_o, NEXT_gotFCT_o);
			$fdisplay(TX_FILE,"Error at time=%dns gotFCT_o=%b, expected=%b",
				$time, gotFCT_o, NEXT_gotFCT_o);
			TX_ERROR = TX_ERROR + 1;
		end
	end
endtask

task CHECK_gotNchar_o;
	input NEXT_gotNchar_o;

	#0 begin
		if (NEXT_gotNchar_o !== gotNchar_o) begin
			$display("Error at time=%dns gotNchar_o=%b, expected=%b",
				$time, gotNchar_o, NEXT_gotNchar_o);
			$fdisplay(TX_FILE,"Error at time=%dns gotNchar_o=%b, expected=%b",
				$time, gotNchar_o, NEXT_gotNchar_o);
			TX_ERROR = TX_ERROR + 1;
		end
	end
endtask

task CHECK_gotTIME_o;
	input NEXT_gotTIME_o;

	#0 begin
		if (NEXT_gotTIME_o !== gotTIME_o) begin
			$display("Error at time=%dns gotTIME_o=%b, expected=%b",
				$time, gotTIME_o, NEXT_gotTIME_o);
			$fdisplay(TX_FILE,"Error at time=%dns gotTIME_o=%b, expected=%b",
				$time, gotTIME_o, NEXT_gotTIME_o);
			TX_ERROR = TX_ERROR + 1;
		end
	end
endtask

task CHECK_gotNULL_o;
	input NEXT_gotNULL_o;

	#0 begin
		if (NEXT_gotNULL_o !== gotNULL_o) begin
			$display("Error at time=%dns gotNULL_o=%b, expected=%b",
				$time, gotNULL_o, NEXT_gotNULL_o);
			$fdisplay(TX_FILE,"Error at time=%dns gotNULL_o=%b, expected=%b",
				$time, gotNULL_o, NEXT_gotNULL_o);
			TX_ERROR = TX_ERROR + 1;
		end
	end
endtask

task CHECK_err_par;
	input NEXT_err_par;

	#0 begin
		if (NEXT_err_par !== err_par) begin
			$display("Error at time=%dns err_par=%b, expected=%b",
				$time, err_par, NEXT_err_par);
			$fdisplay(TX_FILE,"Error at time=%dns err_par=%b, expected=%b",
				$time, err_par, NEXT_err_par);
			TX_ERROR = TX_ERROR + 1;
		end
	end
endtask

task CHECK_err_esc;
	input NEXT_err_esc;

	#0 begin
		if (NEXT_err_esc !== err_esc) begin
			$display("Error at time=%dns err_esc=%b, expected=%b",
				$time, err_esc, NEXT_err_esc);
			$fdisplay(TX_FILE,"Error at time=%dns err_esc=%b, expected=%b",
				$time, err_esc, NEXT_err_esc);
			TX_ERROR = TX_ERROR + 1;
		end
	end
endtask

task CHECK_err_dsc;
	input NEXT_err_dsc;

	#0 begin
		if (NEXT_err_dsc !== err_dsc) begin
			$display("Error at time=%dns err_dsc=%b, expected=%b",
				$time, err_dsc, NEXT_err_dsc);
			$fdisplay(TX_FILE,"Error at time=%dns err_dsc=%b, expected=%b",
				$time, err_dsc, NEXT_err_dsc);
			TX_ERROR = TX_ERROR + 1;
		end
	end
endtask

task CHECK_RxErr_o;
	input NEXT_RxErr_o;

	#0 begin
		if (NEXT_RxErr_o !== RxErr_o) begin
			$display("Error at time=%dns RxErr_o=%b, expected=%b",
				$time, RxErr_o, NEXT_RxErr_o);
			$fdisplay(TX_FILE,"Error at time=%dns RxErr_o=%b, expected=%b",
				$time, RxErr_o, NEXT_RxErr_o);
			TX_ERROR = TX_ERROR + 1;
		end
	end
endtask

task CHECK_wrtbuf_o;
	input NEXT_wrtbuf_o;

	#0 begin
		if (NEXT_wrtbuf_o !== wrtbuf_o) begin
			$display("Error at time=%dns wrtbuf_o=%b, expected=%b",
				$time, wrtbuf_o, NEXT_wrtbuf_o);
			$fdisplay(TX_FILE,"Error at time=%dns wrtbuf_o=%b, expected=%b",
				$time, wrtbuf_o, NEXT_wrtbuf_o);
			TX_ERROR = TX_ERROR + 1;
		end
	end
endtask

task CHECK_type_o;
	input NEXT_type_o;

	#0 begin
		if (NEXT_type_o !== type_o) begin
			$display("Error at time=%dns type_o=%b, expected=%b",
				$time, type_o, NEXT_type_o);
			$fdisplay(TX_FILE,"Error at time=%dns type_o=%b, expected=%b",
				$time, type_o, NEXT_type_o);
			TX_ERROR = TX_ERROR + 1;
		end
	end
endtask

task CHECK_RxData_o;
	input [7:0] NEXT_RxData_o;

	#0 begin
		if (NEXT_RxData_o !== RxData_o) begin
			$display("Error at time=%dns RxData_o=%b, expected=%b",
				$time, RxData_o, NEXT_RxData_o);
			$fdisplay(TX_FILE,"Error at time=%dns RxData_o=%b, expected=%b",
				$time, RxData_o, NEXT_RxData_o);
			TX_ERROR = TX_ERROR + 1;
		end
	end
endtask

task CHECK_Lnk_dsc_o;
	input NEXT_Lnk_dsc_o;

	#0 begin
		if (NEXT_Lnk_dsc_o !== Lnk_dsc_o) begin
			$display("Error at time=%dns Lnk_dsc_o=%b, expected=%b",
				$time, Lnk_dsc_o, NEXT_Lnk_dsc_o);
			$fdisplay(TX_FILE,"Error at time=%dns Lnk_dsc_o=%b, expected=%b",
				$time, Lnk_dsc_o, NEXT_Lnk_dsc_o);
			TX_ERROR = TX_ERROR + 1;
		end
	end
endtask

task CHECK_RxClk_o;
	input NEXT_RxClk_o;

	#0 begin
		if (NEXT_RxClk_o !== RxClk_o) begin
			$display("Error at time=%dns RxClk_o=%b, expected=%b",
				$time, RxClk_o, NEXT_RxClk_o);
			$fdisplay(TX_FILE,"Error at time=%dns RxClk_o=%b, expected=%b",
				$time, RxClk_o, NEXT_RxClk_o);
			TX_ERROR = TX_ERROR + 1;
		end
	end
endtask

task CHECK_rx_drvclk_o;
	input NEXT_rx_drvclk_o;

	#0 begin
		if (NEXT_rx_drvclk_o !== rx_drvclk_o) begin
			$display("Error at time=%dns rx_drvclk_o=%b, expected=%b",
				$time, rx_drvclk_o, NEXT_rx_drvclk_o);
			$fdisplay(TX_FILE,"Error at time=%dns rx_drvclk_o=%b, expected=%b",
				$time, rx_drvclk_o, NEXT_rx_drvclk_o);
			TX_ERROR = TX_ERROR + 1;
		end
	end
endtask

task CHECK_TICK_OUT;
	input NEXT_TICK_OUT;

	#0 begin
		if (NEXT_TICK_OUT !== TICK_OUT) begin
			$display("Error at time=%dns TICK_OUT=%b, expected=%b",
				$time, TICK_OUT, NEXT_TICK_OUT);
			$fdisplay(TX_FILE,"Error at time=%dns TICK_OUT=%b, expected=%b",
				$time, TICK_OUT, NEXT_TICK_OUT);
			TX_ERROR = TX_ERROR + 1;
		end
	end
endtask

task CHECK_CtrlFlg_o;
	input [1:0] NEXT_CtrlFlg_o;

	#0 begin
		if (NEXT_CtrlFlg_o !== CtrlFlg_o) begin
			$display("Error at time=%dns CtrlFlg_o=%b, expected=%b",
				$time, CtrlFlg_o, NEXT_CtrlFlg_o);
			$fdisplay(TX_FILE,"Error at time=%dns CtrlFlg_o=%b, expected=%b",
				$time, CtrlFlg_o, NEXT_CtrlFlg_o);
			TX_ERROR = TX_ERROR + 1;
		end
	end
endtask

task CHECK_TIMEout;
	input [5:0] NEXT_TIMEout;

	#0 begin
		if (NEXT_TIMEout !== TIMEout) begin
			$display("Error at time=%dns TIMEout=%b, expected=%b",
				$time, TIMEout, NEXT_TIMEout);
			$fdisplay(TX_FILE,"Error at time=%dns TIMEout=%b, expected=%b",
				$time, TIMEout, NEXT_TIMEout);
			TX_ERROR = TX_ERROR + 1;
		end
	end
endtask

task CHECK_DLL_LOCKED;
	input NEXT_DLL_LOCKED;

	#0 begin
		if (NEXT_DLL_LOCKED !== DLL_LOCKED) begin
			$display("Error at time=%dns DLL_LOCKED=%b, expected=%b",
				$time, DLL_LOCKED, NEXT_DLL_LOCKED);
			$fdisplay(TX_FILE,"Error at time=%dns DLL_LOCKED=%b, expected=%b",
				$time, DLL_LOCKED, NEXT_DLL_LOCKED);
			TX_ERROR = TX_ERROR + 1;
		end
	end
endtask

endmodule
