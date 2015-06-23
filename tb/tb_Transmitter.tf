// F:\XILINX\MY-PROJECTS\SPACEWIRE_1355
// Verilog Test fixture created by
// HDL Bencher 6.1i
// Mon Apr 04 15:29:02 2005
// 
// Notes:
//  1) This test fixture has been automatically generated from
//   your Test Bench Waveform
//  2) Modified by btltz
// 

`timescale 1ns/1ns

module tb_transmitter;
	wire Do;
	wire So;
	wire err_crd_o; 
	wire C_SEND_FCT_o;
	wire [6:0] STATE_O;
	wire [5:0] CRD_CNT_O;
	wire rdbuf_o;

	reg EnTx;
	reg gotFCT_i;
	reg empty_i;
	reg type_i;
	reg nedsFCT_i;
	reg [7:0] TxData_i;
	reg TICK_IN;
	reg [1:0] CtrlFlg_i;
	reg [5:0] TIMEin;
	reg [5:0] state_i;
	reg reset;
	reg gclk;
	reg GSR; 	//Global signal, this was added automatically

	assign glbl.GSR = GSR;
	 /*
	defparam UUT.PaseW = 14;
	defparam UUT.True = 1;
	defparam UUT.False = 0;
	defparam UUT.FCT = 1;
	defparam UUT.ESC = 7;
	defparam UUT.EOP = 5;
	defparam UUT.EEP = 3;
	defparam UUT.NULL = 23;
	defparam UUT.TIME_PATTERN = 15;
	defparam UUT.StateNum = 7;
	defparam UUT.RESET = 1;
	defparam UUT.SEND_NULL = 2;
	defparam UUT.SEND_FCT = 4;
	defparam UUT.SEND_DATA = 8;
	defparam UUT.SEND_EOP = 16;
	defparam UUT.SEND_EEP = 32;
	defparam UUT.SEND_TIME = 64;
	defparam UUT.DEFLT = 0;
	defparam UUT.CntW = 10;
	defparam UUT.gFreq = 80;
	defparam UUT.RQ = 10;
	defparam UUT.divNum = 7;	 */

	Transmitter UUTinternal (
		.Do(Do),
		.So(So),
		.err_crd_o(err_crd_o),
		.gotFCT_i(gotFCT_i),
		.C_SEND_FCT_o(C_SEND_FCT_o),
		.EnTx(EnTx),
		.rdbuf_o(rdbuf_o),
		.empty_i(empty_i),
		.type_i(type_i),
		.TxData_i(TxData_i),
		.TICK_IN(TICK_IN),
		.CtrlFlg_i(CtrlFlg_i),
		.nedsFCT_i(nedsFCT_i),
		.TIMEin(TIMEin),
		.STATE_O(STATE_O),
	   .CRD_CNT_O(CRD_CNT_O),
		.state_i(state_i),
		.reset(reset),
		.gclk(gclk)
	);

	integer TX_FILE;
	integer TX_ERROR;

always
begin 			//clock process
	gclk = 1'b0;
	#4
	gclk = 1'b1;
	#20
	#30
	gclk = 1'b0;
	#46
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
	gotFCT_i = 1'b0;
	EnTx = 1'b0;
	empty_i = 1'b0;
	type_i = 1'b0;
	TxData_i = 8'b00000000; //0
	TICK_IN = 1'b0;
	CtrlFlg_i = 2'b00; //0
	TIMEin = 6'b000000; //0
	state_i = 6'b000000; //0
	reset = 1'b1;
	// --------------------
	#100 // Time=100 ns
	state_i = 6'b000001; //1
	// --------------------
	#200 // Time=300 ns
	EnTx = 1'b1;
	TIMEin = 6'b000000; //0	 
	// --------------------
	#600 // Time=900 ns
	TIMEin = 6'b000001; //1
	// --------------------
	#200 // Time=1100 ns
	state_i = 6'b000010; //2
	// --------------------
	#400 // Time=1500 ns
	TIMEin = 6'b000010; //2
	//////////////////////////// State == Ready ////////////////////
	#600 // Time=2100 ns
	TIMEin = 6'b000011; //3
	reset = 1'b0;
	state_i = 6'b000100; //4
	nedsFCT_i = 1;
	// --------------------
	#600 // Time=2700 ns
	TIMEin = 6'b000100; //4
	// --------------------
	////////////////////////// state==Started & send NULLs///////////////////////
	#400 // Time=3100 ns
	state_i = 6'b001000; //8
	// --------------------
	#20000 // Time=3300 ns
	TIMEin = 6'b000101; //5
	// --------------------
	#20000 // Time=3900 ns
	TIMEin = 6'b000110; //6
	// --------------------
	////////////////////////// state==Connecting & waiting for a FCT /////////////
	#4000 // Time=4100 ns
	state_i = 6'b010000; //10
	// --------------------
	#30000 // Time=4500 ns
	TIMEin = 6'b000111; //7
	nedsFCT_i = 1'b0;
	// --------------------
	#20000
	TIMEin = 6'b001001; //9
	// --------------------
	#2000 // Time=5900 ns
	gotFCT_i = 1'b1;
	// --------------------
	#100 // Time=6000 ns
	gotFCT_i = 1'b0;
	/////////////////////////////State = Run //////////////////////////////
	TxData_i = 8'b01010110; //56
	state_i = 6'b100000; 
	// --------------------
	#4000
	TIMEin = 6'b001010; //A
	// --------------------
	#6000 // Time=6900 ns
	TIMEin = 6'b001011; //B
	// --------------------
	#2000 // Time=7100 ns
	TxData_i = 8'b01010111; //57		
	// --------------------
	#4000 // Time=7500 ns
	TIMEin = 6'b001100; //C
	// --------------------
	#60000 // Time=8100 ns
	empty_i = 1'b0;
	TxData_i = 8'b01100110; //0
	TIMEin = 6'b001101; //D
	// --------------------
	#6000 // Time=8700 ns
	TIMEin = 6'b001110; //E
	// --------------------
	#40000 // Time=9100 ns
	type_i = 1'b1;
	TxData_i = 8'b00000001; //0
	// --------------------
	#6000 // Time=9300 ns
	TIMEin = 6'b001111; //F
	// --------------------
	#6000 // Time=9900 ns
	TIMEin = 6'b010000; //10
	// /////////////////////////// fifo Empty //////////////////////////// 
	#8000 // Time=10100 ns
	type_i = 1'b0;
	empty_i = 1'b1;
	TxData_i = 8'b00000000; //0
	//---------------------
	#4000 // Time=10500 ns
	TIMEin = 6'b010001; //11
	// --------------------
	#1000 // Time=10600 ns
	TICK_IN = 1'b1;
	// --------------------
   #6000	  
	TxData_i = 8'b00000000; //0
	TIMEin = 6'b010010; //12
	// --------------------
	#6000 // Time=11700 ns
	TIMEin = 6'b010011; //13
	#20000
   TIMEin = 6'b010100;
	//----------------------
	#10000
	TICK_IN = 1'b0;
	// --------------------
	#50000 // Time=12200 ns
	state_i = 6'b000001; //1
	// --------------------
	#8000 // Time=12900 ns
	TIMEin = 6'b010101; //15
	// --------------------
	#2000 // Time=13100 ns
	TxData_i = 8'b00000000; //0
	// --------------------
	#20000 // Time=13204 ns
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

task CHECK_err_crd_o;
	input NEXT_err_crd_o;

	#0 begin
		if (NEXT_err_crd_o !== err_crd_o) begin
			$display("Error at time=%dns err_crd_o=%b, expected=%b",
				$time, err_crd_o, NEXT_err_crd_o);
			$fdisplay(TX_FILE,"Error at time=%dns err_crd_o=%b, expected=%b",
				$time, err_crd_o, NEXT_err_crd_o);
			TX_ERROR = TX_ERROR + 1;
		end
	end
endtask

task CHECK_C_SEND_FCT_o;
	input NEXT_C_SEND_FCT_o;

	#0 begin
		if (NEXT_C_SEND_FCT_o !== C_SEND_FCT_o) begin
			$display("Error at time=%dns C_SEND_FCT_o=%b, expected=%b",
				$time, C_SEND_FCT_o, NEXT_C_SEND_FCT_o);
			$fdisplay(TX_FILE,"Error at time=%dns C_SEND_FCT_o=%b, expected=%b",
				$time, C_SEND_FCT_o, NEXT_C_SEND_FCT_o);
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

endmodule
