// F:\XILINX\MY-PROJECTS\SPACEWIRE_1355
// Verilog Test fixture created by
// HDL Bencher 6.1i
// Fri Apr 01 09:21:08 2005
// 
// Notes:
// 1) This test fixture has been automatically generated from
//    Test Bench Waveform	
// 2) Modified by btltz	  

`timescale 1ns/100ps

module tb_CODEC;
	wire Do;
	wire So;
	reg Di;
	reg Si;
	wire [5:0] PPUstate;
	wire LINK_ERR_o;
	wire err_int_o;
	wire tx_drvclk_o;
	wire rdbuf_o;
	reg Tx_type_i;
	reg [7:0] data_i;
	reg Txbuf_Empty;
	wire rx_drvclk_o;
	wire wrbuf_o;
	wire Rx_type_o;
	wire [7:0] data_o;
	reg Rxbuf_Full;
	wire [5:0] TIMEout;
	wire [1:0] CtrlFlg_o;
	wire TICK_OUT;		
	wire Rx_DLL_LOCKED;
	reg [5:0] TIMEin;
	reg [1:0] CtrlFlg_i;
	reg TICK_IN;
	wire active;
	reg lnk_start;
	reg lnk_dis;
	reg AUTOSTART;
	reg reset;
	//reg clk10;
	reg gclk;
	reg GSR; 	//Global signal, this was added automatically

	assign glbl.GSR = GSR;
					/*
	defparam UUT.DW = 8;
	defparam UUT.True = 1;
	defparam UUT.False = 0;	 */

	SPW_CODEC intl_CODEC (
		.Do(Do),
		.So(So),
		.Di(Di),
		.Si(Si),
		.PPUstate(PPUstate),
		.LINK_ERR_o(LINK_ERR_o),
		.err_int_o(err_int_o),
		.tx_drvclk_o(tx_drvclk_o),
		.rdbuf_o(rdbuf_o),
		.Tx_type_i(Tx_type_i),
		.data_i(data_i),
		.Txbuf_Empty(Txbuf_Empty),
		.Rx_DLL_LOCKED(Rx_DLL_LOCKED),
		.rx_drvclk_o(rx_drvclk_o),
		.wrbuf_o(wrbuf_o),
		.Rx_type_o(Rx_type_o),
		.data_o(data_o),
		.Rxbuf_Full(Rxbuf_Full),
		.TIMEout(TIMEout),
		.CtrlFlg_o(CtrlFlg_o),
		.TICK_OUT(TICK_OUT),
		.TIMEin(TIMEin),
		.CtrlFlg_i(CtrlFlg_i),
		.TICK_IN(TICK_IN),
		.active(active),
		.lnk_start(lnk_start),
		.lnk_dis(lnk_dis),
		.AUTOSTART(AUTOSTART),
		.reset(reset),
	//	.clk10(clk10),
		.gclk(gclk)
	);

	integer TX_FILE;
	integer TX_ERROR;

  /*
always
begin 			//clock process
	clk10 = 1'b0;
	#4
	clk10 = 1'b1;
	#20  //output valid
	#30
	clk10 = 1'b0;
	#46
	clk10 = 1'b0;
end	*/

always
begin 			//clock process
	gclk = 1'b0;
	#4	//L
	gclk = 1'b1;
	#5	/*outpur valid*/
	#5
	gclk = 1'b0;
	#6//L
	gclk = 1'b0;
end

initial	 //FPGA GSR
begin	
	GSR = 1;
	#100 GSR = 0;
end

initial
begin
	TX_ERROR=0;
	TX_FILE=$fopen("results.txt");

	// --------------------
	Di = 1'b0;
	Si = 1'b0;
	Rxbuf_Full = 1'b0;
	lnk_start = 1'b0;
	lnk_dis = 1'b0;
	AUTOSTART = 1'b0;
	// --------------------
	#100 // Time=100 ns
	lnk_start = 1'b1;
	// --------------------
	#100 // Time=200 ns
	AUTOSTART = 1'b1;
	//========================================wait for PPU 6.4uS + 12.8uS + 1clk
	#20000   //20uS
		Di = 1'b0;
		Si = 1'b0;
	// =========================================================================
	#1800 // Time=2000 ns
	Si = 1'b1;
	// --------------------
	#100 // Time=2100 ns
	Di = 1'b1;
	// --------------------
	#100 // Time=2200 ns
	Si = 1'b0;
	// --------------------
	#100 // Time=2300 ns
	Si = 1'b1;
	// --------------------
	#100 // Time=2400 ns
	Di = 1'b0;
	// --------------------
	#100 // Time=2500 ns
	Di = 1'b1;
	// --------------------
	#100 // Time=2600 ns
	Di = 1'b0;
	// --------------------
	#100 // Time=2700 ns
	Si = 1'b0;
	// --------------------
	#100 // Time=2800 ns
	Di = 1'b1;
	// --------------------
	#100 // Time=2900 ns
	Si = 1'b1;
	// --------------------
	#100 // Time=3000 ns
	Si = 1'b0;
	// --------------------
	#100 // Time=3100 ns
	Si = 1'b1;
	// --------------------
	#100 // Time=3200 ns
	Di = 1'b0;
	// --------------------
	#100 // Time=3300 ns
	Di = 1'b1;
	// --------------------
	#100 // Time=3400 ns
	Di = 1'b0;
	// --------------------
	#100 // Time=3500 ns
	Si = 1'b0;
	// --------------------
	#100 // Time=3600 ns
	Si = 1'b1;
	// --------------------
	#100 // Time=3700 ns
	Di = 1'b1;
	// --------------------
	#100 // Time=3800 ns
	Si = 1'b0;
	// --------------------
	#100 // Time=3900 ns
	Si = 1'b1;
	// --------------------
	#100 // Time=4000 ns
	Di = 1'b0;
	// --------------------
	#100 // Time=4100 ns
	Di = 1'b1;
	// --------------------
	#100 // Time=4200 ns
	Di = 1'b0;
	// --------------------
	#100 // Time=4300 ns
	Si = 1'b0;
	// --------------------
	#100 // Time=4400 ns
	Di = 1'b1;
	// --------------------
	#100 // Time=4500 ns
	Si = 1'b1;
	// --------------------
	#100 // Time=4600 ns
	Di = 1'b0;
	// --------------------
	#100 // Time=4700 ns
	Si = 1'b0;
	// --------------------
	#100 // Time=4800 ns
	Di = 1'b1;
	// --------------------
	#100 // Time=4900 ns
	Di = 1'b0;
	// --------------------
	#100 // Time=5000 ns
	Di = 1'b1;
	Si = 1'b0;
	// --------------------
	#100 // Time=5100 ns
	Si = 1'b1;
	// --------------------
	#100 // Time=5200 ns
	Si = 1'b0;
	// --------------------
	#100 // Time=5300 ns
	Si = 1'b1;
	// --------------------
	#100 // Time=5400 ns
	Si = 1'b0;
	// --------------------
	#100 // Time=5500 ns
	Di = 1'b0;
	// --------------------
	#800 // Time=6300 ns
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

initial
begin
	TX_ERROR=0;
	TX_FILE=$fopen("results.txt");

	// --------------------
	Tx_type_i = 1'b0;
	data_i = 8'b00000000; //0
	Txbuf_Empty = 1'b0;
	TIMEin = 6'b000000; //0
	CtrlFlg_i = 2'b00; //0
	TICK_IN = 1'b0;
	reset = 1'b0;
	// --------------------
	#1600 // Time=1600 ns
	reset = 1'b1;
	// --------------------
	#150 // Time=1750 ns
	reset = 1'b0;
	//=========================================================== 
		#20000   //20uS
   data_i = 8'b00000001; //1
	// ===============================================
	#1300 // Time=3050 ns
	reset = 1'b0;
	// --------------------
	#550 // Time=3600 ns
	reset = 1'b1;
	// --------------------
	#50 // Time=3650 ns
	data_i = 8'b01111011; //7B
	// --------------------
	#100 // Time=3750 ns
	reset = 1'b0;
	// --------------------
	#400 // Time=4150 ns
	data_i = 8'b01111111; //7F
	// --------------------
	#500 // Time=4650 ns
	data_i = 8'b10000011; //83
	// --------------------
	#500 // Time=5150 ns
	data_i = 8'b10000111; //87
	// --------------------
	#500 // Time=5650 ns
	Tx_type_i = 1'b1;
	data_i = 8'b00000101; //5
	// --------------------
	#450 // Time=6100 ns
	Tx_type_i = 1'b1;
	// --------------------
	#50 // Time=6150 ns
	Tx_type_i = 1'b0;
	data_i = 8'b10001111; //8F
	// --------------------
	#150 // Time=6300 ns
	// --------------------

	if (TX_ERROR == 0) begin
		$display("No errors or warnings---Model Sim 5.7c");
		$fdisplay(TX_FILE,"No errors or warnings");
	end else begin
		$display("%d errors found in simulation",TX_ERROR);
		$fdisplay(TX_FILE,"%d errors found in simulation",TX_ERROR);
	end

	$fclose(TX_FILE);
	$stop;

end

task CHECK_Do;
	input NEXT_Do;

	#0 begin
		if (NEXT_Do !== Do) begin
			$display("Error at time=%dns Do=%b, expected=%b",
				$time, Do, NEXT_Do);
			$fdisplay(TX_FILE,"Error at time=%dns Do=%b, expected=%b",
				$time, Do, NEXT_Do);
			TX_ERROR = TX_ERROR + 1;
		end
	end
endtask

task CHECK_So;
	input NEXT_So;

	#0 begin
		if (NEXT_So !== So) begin
			$display("Error at time=%dns So=%b, expected=%b",
				$time, So, NEXT_So);
			$fdisplay(TX_FILE,"Error at time=%dns So=%b, expected=%b",
				$time, So, NEXT_So);
			TX_ERROR = TX_ERROR + 1;
		end
	end
endtask

task CHECK_PPUstate;
	input [5:0] NEXT_PPUstate;

	#0 begin
		if (NEXT_PPUstate !== PPUstate) begin
			$display("Error at time=%dns PPUstate=%b, expected=%b",
				$time, PPUstate, NEXT_PPUstate);
			$fdisplay(TX_FILE,"Error at time=%dns PPUstate=%b, expected=%b",
				$time, PPUstate, NEXT_PPUstate);
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

task CHECK_err_int_o;
	input NEXT_err_int_o;

	#0 begin
		if (NEXT_err_int_o !== err_int_o) begin
			$display("Error at time=%dns err_int_o=%b, expected=%b",
				$time, err_int_o, NEXT_err_int_o);
			$fdisplay(TX_FILE,"Error at time=%dns err_int_o=%b, expected=%b",
				$time, err_int_o, NEXT_err_int_o);
			TX_ERROR = TX_ERROR + 1;
		end
	end
endtask

task CHECK_tx_drvclk_o;
	input NEXT_tx_drvclk_o;

	#0 begin
		if (NEXT_tx_drvclk_o !== tx_drvclk_o) begin
			$display("Error at time=%dns tx_drvclk_o=%b, expected=%b",
				$time, tx_drvclk_o, NEXT_tx_drvclk_o);
			$fdisplay(TX_FILE,"Error at time=%dns tx_drvclk_o=%b, expected=%b",
				$time, tx_drvclk_o, NEXT_tx_drvclk_o);
			TX_ERROR = TX_ERROR + 1;
		end
	end
endtask

task CHECK_rdbuf_o;
	input NEXT_rdbuf_o;

	#0 begin
		if (NEXT_rdbuf_o !== rdbuf_o) begin
			$display("Error at time=%dns rdbuf_o=%b, expected=%b",
				$time, rdbuf_o, NEXT_rdbuf_o);
			$fdisplay(TX_FILE,"Error at time=%dns rdbuf_o=%b, expected=%b",
				$time, rdbuf_o, NEXT_rdbuf_o);
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

task CHECK_wrbuf_o;
	input NEXT_wrbuf_o;

	#0 begin
		if (NEXT_wrbuf_o !== wrbuf_o) begin
			$display("Error at time=%dns wrbuf_o=%b, expected=%b",
				$time, wrbuf_o, NEXT_wrbuf_o);
			$fdisplay(TX_FILE,"Error at time=%dns wrbuf_o=%b, expected=%b",
				$time, wrbuf_o, NEXT_wrbuf_o);
			TX_ERROR = TX_ERROR + 1;
		end
	end
endtask

task CHECK_Rx_type_o;
	input NEXT_Rx_type_o;

	#0 begin
		if (NEXT_Rx_type_o !== Rx_type_o) begin
			$display("Error at time=%dns Rx_type_o=%b, expected=%b",
				$time, Rx_type_o, NEXT_Rx_type_o);
			$fdisplay(TX_FILE,"Error at time=%dns Rx_type_o=%b, expected=%b",
				$time, Rx_type_o, NEXT_Rx_type_o);
			TX_ERROR = TX_ERROR + 1;
		end
	end
endtask

task CHECK_data_o;
	input [7:0] NEXT_data_o;

	#0 begin
		if (NEXT_data_o !== data_o) begin
			$display("Error at time=%dns data_o=%b, expected=%b",
				$time, data_o, NEXT_data_o);
			$fdisplay(TX_FILE,"Error at time=%dns data_o=%b, expected=%b",
				$time, data_o, NEXT_data_o);
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

task CHECK_active;
	input NEXT_active;

	#0 begin
		if (NEXT_active !== active) begin
			$display("Error at time=%dns active=%b, expected=%b",
				$time, active, NEXT_active);
			$fdisplay(TX_FILE,"Error at time=%dns active=%b, expected=%b",
				$time, active, NEXT_active);
			TX_ERROR = TX_ERROR + 1;
		end
	end
endtask

endmodule
