//---------------------------------------------------------------------------------------
//	Project:			High Throughput & Low Area AES Core 
//
//	File name:			tb_kat.v 			(Jan 1, 2011)
//
//	Writer:				Moti Litochevski 
//
//	Description:
//		This file contains the core test bench to check compatibility with the Known 
//		Answer Test (KAT) vectors. The test bench runs all files listed in the 
//		"KAT_files.txt" file. 
//		Note that only ECB mode test vectors should be included since other modes require 
//		additional logic to be implemented around the AES algorithm core. 
//
//	Revision History:
//
//	Rev <revnumber>			<Date>			<owner> 
//		<comment>
// 
//---------------------------------------------------------------------------------------

`timescale 1ns / 10ps

module test ();

// define input list file name 
`define	IN_FILE		"KAT_files.txt"

// global definitions 
`define EOF				-1
`define EOF16			16'hffff
`define CHAR_CR			8'h0d
`define CHAR_LF			8'h0a
`define CHAR_0			8'h30
`define CHAR_9			8'h39
`define CHAR_Eq			8'h3D
`define CHAR_A			8'h41
`define	CHAR_F			8'h46
`define CHAR_Z			8'h5A
`define CHAR_a			8'h61
`define	CHAR_f			8'h66
`define CHAR_z			8'h7A

//---------------------------------------------------------------------------------------
// test bench signals 
reg clk;
reg reset;
reg [255:0] in_file_name;
reg key_start, enc_dec, data_in_valid, enable, test_start;
reg [255:0] key_in;
reg [1:0] key_mode;
reg [127:0] data_in, exp_data_out, init_vec, tmp_val;
wire [127:0] data_out;
wire key_ready, ready_out;
reg [15:0] param_name;
integer listfid, infid, intmp, tst_count, key_len;

// function to read a line from an input file 
function [255:0] fgetl;
input [31:0] fileid;
integer intint;
reg [255:0] outline;
begin 
	// init output line 
	outline = 0;
	
	// pass over any CR and LF characters 
	intint = $fgetc(fileid);
	while (((intint == `CHAR_CR) || (intint == `CHAR_LF)) && (intint != `EOF))
		intint = $fgetc(fileid);
		
	// update output line 
	while ((intint != `CHAR_CR) && (intint != `CHAR_LF) && (intint != `EOF))
	begin 
		outline[255:8] = outline[247:0];
		outline[7:0] = intint;
		intint = $fgetc(fileid);
	end 
	
	// return the line read 
	fgetl = outline;
end 
endfunction 

// function to read the next field name from the input file 
function [15:0] fgetfield;
input [31:0] fileid;
integer intint;
reg [15:0] outfield;
begin
	// search for the start of the new line 
	intint = $fgetc(fileid);
	while ((intint != `CHAR_CR) && (intint != `CHAR_LF) && (intint != `EOF))
		intint = $fgetc(fileid);
	while (((intint < `CHAR_A) || (intint > `CHAR_Z)) && (intint != `EOF))
		intint = $fgetc(fileid);
	
	// the first two characters of the new line are the next field name 
	outfield[15:8] = intint;
	intint = $fgetc(fileid);
	outfield[7:0] = intint;
	
	// return the result 
	fgetfield = outfield;
end
endfunction

// function to read the file to the start of the parameter value 
function [7:0] fgetparam;
input [31:0] fileid;
integer intint;
begin 
	// search for the equal sign 
	intint = $fgetc(fileid);
	while (intint != `CHAR_Eq)
		intint = $fgetc(fileid);
	// read first char of parameter 
	while ((intint < `CHAR_0) || ((intint > `CHAR_9) && (intint < `CHAR_A)) || 
			((intint > `CHAR_Z) && (intint < `CHAR_a)) || (intint > `CHAR_z))
		intint = $fgetc(fileid);

	// return the read character 
	fgetparam = intint;
end 
endfunction

// function to convert a character to its HEX value 
function [7:0] char2val;
input [7:0] char_val;
integer out_val;
begin 
	if ((char_val >= `CHAR_0) && (char_val <= `CHAR_9))
		out_val = char_val - `CHAR_0;
	else if ((char_val >= `CHAR_A) && (char_val <= `CHAR_F))
		out_val = char_val - `CHAR_A + 'd10;
	else if ((char_val >= `CHAR_a) && (char_val <= `CHAR_f))
		out_val = char_val - `CHAR_a + 'd10;
	else 
		out_val = 0;
	
	// return the resulting value 
	char2val = out_val;
end 
endfunction

//---------------------------------------------------------------------------------------
// test bench implementation 
// global clock generator 
initial		clk = 1'b1;
always 		#10 clk = ~clk;

// gloabl reset generator 
initial 
begin 
	reset = 1'b1;
	#100;
	reset = 1'b0;
end 

// cosmetics 
initial 
begin 
	// announce start of simulation 
	$display("");
	$display("-------------------------------------");
	$display("        AES_HT_LA Simulation");
	$display("-------------------------------------");
	$display("");
	
	// VCD dump 
	$dumpfile("test.vcd");
	$dumpvars(0, test);
	$display("");
end 

// main test bench contorl module 
initial
begin 
	// signals reset values 
	enc_dec = 1'b0;			// 0: encryption; 1: decryption
	key_mode = 'b0;			// 0: 128; 1: 192; 2: 256 
	key_in = 'b0;
	key_start = 1'b0;
	data_in_valid = 1'b0;
	data_in = 'b0;
	enable = 1;
	test_start = 0;
	@(posedge clk);
	
	// wait for global reset 
	wait (reset == 1'b0);
	repeat (10) @(posedge clk);
	
	// open input list file 
	listfid = $fopen(`IN_FILE, "rb");
	
	// read first input filename 
	in_file_name = fgetl(listfid);
	
	// loop through input files 
	while (in_file_name != 0)
	begin 
		// announce start of simulation for the current file 
		$display("Starting simulation for input file: %0s", in_file_name);
		$display("--------------------------------------------------------------------------");
		$display("");
	
		// open current simulation input file 
		infid = $fopen(in_file_name, "rb");
		
		// read core mode for the current file 
		intmp = $fgetc(infid);	// first char is "[" 
		intmp = $fgetc(infid);	// second char should be either "E" or "D" 
		// check read character for mode of operation 
		if (intmp == "E")
			// set flag accordingly 
			enc_dec = 1'b0;
		else if (intmp == "D")
			// set flag accordingly 
			enc_dec = 1'b1;
		else 
		begin 
			// no valid mode was found, announce error and quit simulation 
			$display("ERROR: Simulation mode could not be determined!");
			$finish;
		end 
		
		// repeat reading the file till end of file 
		param_name = fgetfield(infid);
		while (param_name != `EOF16) 
		begin 
			// clear test start flag 
			test_start = 0;
			
			// check read parameter name  
			if (param_name == "CO") 
			begin 
				// init test count 
				tst_count = 0;
				// get file pointer to the start of value 
				intmp = fgetparam(infid);
				// update test count value 
				while ((intmp >= `CHAR_0) && (intmp <= `CHAR_9))
				begin 
					tst_count = (tst_count * 10) + (intmp - `CHAR_0);
					intmp = $fgetc(infid);
				end 
			end 
			else if (param_name == "KE") 
			begin 
				// init key value and length 
				key_in = 0;
				key_len = 0;
				
				// get file pointer to the start of value 
				intmp = fgetparam(infid);
				
				// update key value & length 
				while (((intmp >= `CHAR_0) && (intmp <= `CHAR_9)) || 
				       ((intmp >= `CHAR_A) && (intmp <= `CHAR_F)) || 
				       ((intmp >= `CHAR_a) && (intmp <= `CHAR_f)))
				begin 
					key_in[255:4] = key_in[251:0];
					key_in[3:0] = char2val(intmp);
					key_len = key_len + 4;
					intmp = $fgetc(infid);
				end 
				
				// check key length to see if it is legal and if the key needs zero padding 
				if (key_len == 'd128)
				begin 
					// update key value and mode 
					key_in = {key_in[127:0], 128'b0};
					key_mode = 2'd0;
				end 
				else if (key_len == 'd192) 
				begin 
					// update key value and mode 
					key_in = {key_in[191:0], 64'b0};
					key_mode = 2'd1;
				end 
				else if (key_len == 'd256)
				begin 
					// update key mode 
					key_mode = 2'd2;
				end 
				else 
				begin
					// illegal key length error 
					$display("ERROR: Illegal key length at test %0d (%0d)", tst_count, key_len);
					$finish;
				end 
			end 
			else if (param_name == "IV") 
			begin 
				// init init vector value 
				init_vec = 0;
				
				// get file pointer to the start of value 
				intmp = fgetparam(infid);
				// update init vector value 
				while (((intmp >= `CHAR_0) && (intmp <= `CHAR_9)) || 
				       ((intmp >= `CHAR_A) && (intmp <= `CHAR_F)) || 
				       ((intmp >= `CHAR_a) && (intmp <= `CHAR_f)))
				begin 
					init_vec[127:4] = init_vec[123:0];
					init_vec[3:0] = char2val(intmp);
					intmp = $fgetc(infid);
				end 
			end 
			else if (param_name == "CI") 
			begin 
				// init temp value 
				tmp_val = 0;
				
				// get file pointer to the start of value 
				intmp = fgetparam(infid);
				// update temp value 
				while (((intmp >= `CHAR_0) && (intmp <= `CHAR_9)) || 
				       ((intmp >= `CHAR_A) && (intmp <= `CHAR_F)) || 
				       ((intmp >= `CHAR_a) && (intmp <= `CHAR_f)))
				begin 
					tmp_val[127:4] = tmp_val[123:0];
					tmp_val[3:0] = char2val(intmp);
					intmp = $fgetc(infid);
				end 
			
				// check simulation mode to determine if this is the last value and if 
				// it is the data input or the expected data 
				if (enc_dec == 1'b0)
				begin 
					// for encryption the CIPHERTEXT is the expected result and the 
					// simulation should start 
					exp_data_out = tmp_val;
					test_start = 1'b1;
				end 
				else 
					// for decryption the CIPHERTEXT is the input data 
					data_in = tmp_val;
			end 
			else if (param_name == "PL") 
			begin 
				// init temp value 
				tmp_val = 0;
				
				// get file pointer to the start of value 
				intmp = fgetparam(infid);
				// update temp value 
				while (((intmp >= `CHAR_0) && (intmp <= `CHAR_9)) || 
				       ((intmp >= `CHAR_A) && (intmp <= `CHAR_F)) || 
				       ((intmp >= `CHAR_a) && (intmp <= `CHAR_f)))
				begin 
					tmp_val[127:4] = tmp_val[123:0];
					tmp_val[3:0] = char2val(intmp);
					intmp = $fgetc(infid);
				end 
			
				// check simulation mode to determine if this is the last value and if 
				// it is the data input or the expected data 
				if (enc_dec == 1'b0)
					// for encryption the PLAINTEXT is the input data 
					data_in = tmp_val;
				else 
				begin 
					// for decryption the PLAINTEXT is the expected result and the 
					// simulation should start 
					exp_data_out = tmp_val;
					test_start = 1'b1;
				end 
			end 
			else 
			begin 
				// no matching parameter was found 
				$display("ERROR: Could not find a matching parameter after test %0d", tst_count);
				$finish;
			end 
	
			// check if simulation should start 
			if (test_start) 
			begin 
				// run core simulation 
				repeat (10) @(posedge clk);
				// update input key 
				key_start <= 1'b1;
				@ (posedge clk);
				key_start <= 1'b0;
				@ (posedge clk);
				// wait for key to be ready 
				while (!key_ready) 
					@(posedge clk);
				// sign input data is valid 
				data_in_valid <= 1'b1;
				@(posedge clk);
			    data_in_valid <= 1'b0;
				repeat (3) @ (posedge clk);
				// wait for result to be ready 
				while (!data_out_valid)
					@ (posedge clk);
				@ (posedge clk);
				// check expected result 
				if (exp_data_out != data_out)
				begin 
					// data output error 
					$display("ERROR: Expected data output error at test %0d", tst_count);
					repeat (10) @(posedge clk);
					$finish;
				end 
				else 
				begin 
					$display("Test finished OK!");
					$display("");
				end 
			end 
			
			// read next parameter name 
			param_name = fgetfield(infid);
		end 
		
		// close input file 
		$fclose(infid);
		
		// read next input filename 
		in_file_name = fgetl(listfid);
	end 
	
	// close input list file 
	$fclose(listfid);
	// finish simulation 
	$finish;
end

aes dut(
   .clk(clk),
   .reset(reset),
   .i_start(key_start),
   .i_enable(enable), //TBD
   .i_ende(enc_dec),
   .i_key(key_in),
   .i_key_mode(key_mode),
   .i_data(data_in),
   .i_data_valid(data_in_valid),
   .o_ready(ready_out),
   .o_data(data_out),
   .o_data_valid(data_out_valid),
   .o_key_ready(key_ready)
);

// display mode of operation, input key length and value 
always @ (posedge clk)
	if (key_start)
	begin 
		// display mode of operation 
		if (enc_dec) 
			$display("Decryption test, count %0d, in file %0s", tst_count, in_file_name);
		else
			$display("Encryption test, count %0d, in file %0s", tst_count, in_file_name);
		
		// display key size 
		case (key_mode) 
			2'b00:	$display("Key size is 128 bits");
			2'b01:	$display("Key size is 192 bits");
			2'b10:	$display("Key size is 256 bits");
			2'b11:	$display("ERROR: Illegal key size");
		endcase 
		// display key value 
		$display("Key In:      %16h",key_in);
	end 

// display input data 
always @ (posedge clk)
	if (data_in_valid)
		$display("Data In:     %16h",data_in);

// display output data 
always @ (posedge clk)
	if (data_out_valid)
		$display("Data Out:    %16h",data_out);

endmodule
//---------------------------------------------------------------------------------------
//						Th.. Th.. Th.. Thats all folks !!!
//---------------------------------------------------------------------------------------
