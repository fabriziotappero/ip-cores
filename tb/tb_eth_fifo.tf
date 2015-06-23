// F:\XILINX\MY-PROJECTS\SPACEWIRE_1355
// Verilog Test fixture created by
// HDL Bencher 6.1i
// Tue Apr 26 16:13:38 2005
// 
// Notes:
// 1) This test fixture has been automatically generated from
//   your Test Bench Waveform
// 2) To use this as a user modifiable test fixture do the following:
//   - Save it as a file with a .tf extension (i.e. File->Save As...)
//   - Add it to your project as a testbench source (i.e. Project->Add Source...)
// 

`timescale 1ns/1ns

module tb_eth_fifo;
	reg [31:0] data_in;
	wire [31:0] data_out;
	reg clk;
	reg reset;
	reg write;
	reg read;
	wire almost_full;
	wire full;
	wire almost_empty;
	wire empty;
	wire [3:0] cnt;
	/*
	defparam UUT.DATA_WIDTH = 32;
	defparam UUT.DEPTH = 15;
	defparam UUT.CNT_WIDTH = 4;	 */

	eth_fifo UUT (
		.data_in(data_in),
		.data_out(data_out),
		.clk(clk),
		.reset(reset),
		.write(write),
		.read(read),
		.almost_full(almost_full),
		.full(full),
		.almost_empty(almost_empty),
		.empty(empty),
		.cnt(cnt)
	);

	integer TX_FILE;
	integer TX_ERROR;

always
begin 			//clock process
	clk = 1'b0;
	#8
	clk = 1'b1;
	#20
	#30
	clk = 1'b0;
	#42
	clk = 1'b0;
end

initial
begin
	TX_ERROR=0;
	TX_FILE=$fopen("results.txt");

	// --------------------
	data_in = 32'b00000000000000000000000000011000; //18
	reset = 1'b1;
	write = 1'b0;
	read = 1'b0;
	// --------------------
	#300 // Time=300 ns
	reset = 1'b0;
	// --------------------
	#100 // Time=400 ns
	data_in = 32'b00000000000000000000000000011001; //19
	// --------------------
	#100 // Time=500 ns
	write = 1'b1;
	// --------------------
	#100 // Time=600 ns
	write = 1'b0;
	// --------------------
	#200 // Time=800 ns
	data_in = 32'b00000000000000000000000000011010; //1A
	// --------------------
	#100 // Time=900 ns
	write = 1'b1;
	// --------------------
	#100 // Time=1000 ns
	write = 1'b0;
	// --------------------
	#200 // Time=1200 ns
	data_in = 32'b00000000000000000000000000011011; //1B
	write = 1'b1;
	// --------------------
	#100 // Time=1300 ns
	write = 1'b0;
	// --------------------
	#100 // Time=1400 ns
	read = 1'b1;
	// --------------------
	#100 // Time=1500 ns
	read = 1'b0;
	// --------------------
	#100 // Time=1600 ns
	data_in = 32'b00000000000000000000000000011100; //1C
	// --------------------
	#200 // Time=1800 ns
	read = 1'b1;
	// --------------------
	#100 // Time=1900 ns
	read = 1'b0;
	// --------------------
	#100 // Time=2000 ns
	data_in = 32'b00000000000000000000000000011101; //1D
	// --------------------
	#200 // Time=2200 ns
	read = 1'b1;
	// --------------------
	#100 // Time=2300 ns
	read = 1'b0;
	// --------------------
	#100 // Time=2400 ns
	data_in = 32'b00000000000000000000000000011110; //1E
	// --------------------
	#100 // Time=2500 ns
	read = 1'b1;
	// --------------------
	#200 // Time=2700 ns
	read = 1'b0;
	// --------------------
	#100 // Time=2800 ns
	data_in = 32'b00000000000000000000000000011111; //1F
	// --------------------
	#400 // Time=3200 ns
	data_in = 32'b00000000000000000000000000100000; //20
	// --------------------
	#100 // Time=3300 ns
	write = 1'b1;
	read = 1'b1;
	// --------------------
	#300 // Time=3600 ns
	data_in = 32'b00000000000000000000000000100001; //21
	// --------------------
	#400 // Time=4000 ns
	data_in = 32'b00000000000000000000000000100010; //22
	// --------------------
	#100 // Time=4100 ns
	read = 1'b0;
	// --------------------
	#100 // Time=4200 ns
	reset = 1'b0;
	// --------------------
	#200 // Time=4400 ns
	data_in = 32'b00000000000000000000000000100011; //23
	// --------------------
	#100 // Time=4500 ns
	write = 1'b1;
	// --------------------
	#100 // Time=4600 ns
	write = 1'b0;
	// --------------------
	#200 // Time=4800 ns
	data_in = 32'b00000000000000000000000000100100; //24
	write = 1'b0;
	// --------------------
	#400 // Time=5200 ns
	data_in = 32'b00000000000000000000000000100101; //25
	// --------------------
	#300 // Time=5500 ns
	write = 1'b1;
	// --------------------
	#100 // Time=5600 ns
	data_in = 32'b00000000000000000000000000100110; //26
	// --------------------
	#400 // Time=6000 ns
	data_in = 32'b00000000000000000000000000100111; //27
	// --------------------
	#300 // Time=6300 ns
	read = 1'b1;
	// --------------------
	#100 // Time=6400 ns
	data_in = 32'b00000000000000000000000000101000; //28
	// --------------------
	#300 // Time=6700 ns
	reset = 1'b0;
	// --------------------
	#100 // Time=6800 ns
	data_in = 32'b00000000000000000000000000101001; //29
	// --------------------
	#400 // Time=7200 ns
	data_in = 32'b00000000000000000000000000101010; //2A
	write = 1'b1;
	// --------------------
	#400 // Time=7600 ns
	data_in = 32'b00000000000000000000000000101011; //2B
	// --------------------
	#300 // Time=7900 ns
	write = 1'b0;
	// --------------------
	#100 // Time=8000 ns
	data_in = 32'b00000000000000000000000000101100; //2C
	// --------------------
	#8000 // Time=8400 ns
	data_in = 32'b00000000000000000000000000101101; //2D
	read = 1'b0;
	// --------------------
	#108 // Time=8508 ns
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

task CHECK_data_out;
	input [31:0] NEXT_data_out;

	#0 begin
		if (NEXT_data_out !== data_out) begin
			$display("Error at time=%dns data_out=%b, expected=%b",
				$time, data_out, NEXT_data_out);
			$fdisplay(TX_FILE,"Error at time=%dns data_out=%b, expected=%b",
				$time, data_out, NEXT_data_out);
			TX_ERROR = TX_ERROR + 1;
		end
	end
endtask

task CHECK_almost_full;
	input NEXT_almost_full;

	#0 begin
		if (NEXT_almost_full !== almost_full) begin
			$display("Error at time=%dns almost_full=%b, expected=%b",
				$time, almost_full, NEXT_almost_full);
			$fdisplay(TX_FILE,"Error at time=%dns almost_full=%b, expected=%b",
				$time, almost_full, NEXT_almost_full);
			TX_ERROR = TX_ERROR + 1;
		end
	end
endtask

task CHECK_full;
	input NEXT_full;

	#0 begin
		if (NEXT_full !== full) begin
			$display("Error at time=%dns full=%b, expected=%b",
				$time, full, NEXT_full);
			$fdisplay(TX_FILE,"Error at time=%dns full=%b, expected=%b",
				$time, full, NEXT_full);
			TX_ERROR = TX_ERROR + 1;
		end
	end
endtask

task CHECK_almost_empty;
	input NEXT_almost_empty;

	#0 begin
		if (NEXT_almost_empty !== almost_empty) begin
			$display("Error at time=%dns almost_empty=%b, expected=%b",
				$time, almost_empty, NEXT_almost_empty);
			$fdisplay(TX_FILE,"Error at time=%dns almost_empty=%b, expected=%b",
				$time, almost_empty, NEXT_almost_empty);
			TX_ERROR = TX_ERROR + 1;
		end
	end
endtask

task CHECK_empty;
	input NEXT_empty;

	#0 begin
		if (NEXT_empty !== empty) begin
			$display("Error at time=%dns empty=%b, expected=%b",
				$time, empty, NEXT_empty);
			$fdisplay(TX_FILE,"Error at time=%dns empty=%b, expected=%b",
				$time, empty, NEXT_empty);
			TX_ERROR = TX_ERROR + 1;
		end
	end
endtask

task CHECK_cnt;
	input [3:0] NEXT_cnt;

	#0 begin
		if (NEXT_cnt !== cnt) begin
			$display("Error at time=%dns cnt=%b, expected=%b",
				$time, cnt, NEXT_cnt);
			$fdisplay(TX_FILE,"Error at time=%dns cnt=%b, expected=%b",
				$time, cnt, NEXT_cnt);
			TX_ERROR = TX_ERROR + 1;
		end
	end
endtask

endmodule
