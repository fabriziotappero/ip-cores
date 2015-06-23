//---------------------------------------------------------------------------------------
//	Project:			High Throughput & Low Area AES Core 
//
//	File name:			tb_kat.v 			(Jan 1, 2011)
//
//	Writer:				Moti Litochevski 
//
//	Description:
//		This file contains a basic test bench to demonstrate the core functionality & 
//		interfaces including pipelined operation. For each key length the test bench 
//		encrypts four plain text vectors using a single key and then decrypts the four 
//		cipher text vectors using the same key. 
//		The test bench demonstrates the key expansion, encryption and decryption for all 
//		three key lengths with pipelined operation. 
//
//	Revision History:
//
//	Rev <revnumber>			<Date>			<owner> 
//		<comment>
// 
//---------------------------------------------------------------------------------------

`timescale 1ns / 10ps
module test ();

//---------------------------------------------------------------------------------------
// global signals 
reg clock;
reg reset;

// test bench variables 
integer dout_count;

// UUT interface signals 
reg key_start;
reg enable;
reg enc_dec;
reg [255:0] key_in; 
reg [1:0] key_mode; 
reg [127:0] data_in; 
reg data_in_valid; 
wire ready_out; 
wire [127:0] data_out; 
wire data_out_valid; 
wire key_ready; 

//---------------------------------------------------------------------------------------
// test bench implementation 
// global clock generator 
initial		clock = 1'b1;
always 		#10 clock = ~clock;

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

// main test bench process control 
initial 
begin 
	// default input values 
	key_start = 1'b0;
	enable = 1'b1;
	enc_dec = 1'b0;
	key_in = 256'b0;
	key_mode = 2'b0;
	data_in = 128'b0;
	data_in_valid = 1'b0;
	dout_count = 0;
	
	// wait for reset release 
	@(posedge clock);
	wait (~reset);
	@(posedge clock);
	
	// encryption for 128 bit key mode 
	$display("Testing encryption for 128 bit key:");
	$display("-------------------------------------");
	// set core mode to encryption and key size to 128 
	enc_dec <= 1'b0;
	key_mode <= 2'b00;
	// set the key value and start 	key expansion 
	key_in[255:128] <= 128'h2b7e151628aed2a6abf7158809cf4f3c;
	key_start <= 1'b1;
	@(posedge clock);
	key_start <= 1'b0;
	@(posedge clock);
	// display key value 
	$display("Key: 128'h%32h", key_in[255:128]);
	// wait for key expansion to finish 
	while (!key_ready) @(posedge clock);
	// announce key expansion ended 
	$display("Key expansion done");
	$display("");
	
	// first plain text input data 
	data_in[127:0] <= 128'hdda97ca4864cdfe06eaf70a0ec0d7191;
	data_in_valid <= 1'b1;
	@ (posedge clock);
	// display data value 
	$display("Plaintext Data 1: 128'h%32h", data_in);
	// second plain text input data 
	data_in[127:0] <= 128'h3243f6a8885a308d313198a2e0370731;
	data_in_valid <= 1'b1;
	@ (posedge clock);
	// display data value 
	$display("Plaintext Data 2: 128'h%32h", data_in);
	// third plain text input data 
	data_in[127:0] <= 128'h00112233445566778899aabbccddeeff;
	data_in_valid <= 1'b1;
	@ (posedge clock);
	// display data value 
	$display("Plaintext Data 3: 128'h%32h", data_in);
	// forth plain text input data 
	data_in[127:0] <= 128'h8ea2b7ca516745bfeafc49904b496089;
	data_in_valid <= 1'b1;
	@ (posedge clock);
	// display data value 
	$display("Plaintext Data 4: 128'h%32h", data_in);
	// no more data can be given to the core 
	data_in_valid <= 1'b0;
	@(posedge clock);
	
	// announce state 
	$display("");
	$display("Waiting for cipher text data");
	
	// wait for all output cipher text data 
	dout_count = 0;
	while (dout_count < 4)
	begin 
		// check for a new output data 
		if (data_out_valid) 
			dout_count <= dout_count + 1;
		// wait for next clock cycle 
		@(posedge clock);
	end 
	$display("");
	
	// continue with decryption of the same cipher text without key expansion 
	$display("Testing decryption for 128 bit key:");
	$display("-------------------------------------");
	// set core mode to decryption 
	enc_dec <= 1'b1;
	@(posedge clock);
	// display key value 
	$display("Key: 128'h%32h", key_in[255:128]);
	// announce key expansion is not done again 
	$display("Using the same key, expansion is not required.");
	$display("");
	
	// first cipher text input data 
	data_in[127:0] <= 128'hef0bc156ed8ff21223f247b3e0318a99;
	data_in_valid <= 1'b1;
	@ (posedge clock);
	// display data value 
	$display("Ciphertext Data 1: 128'h%32h", data_in);
	// second cipher text input data 
	data_in[127:0] <= 128'hf91914cd01924b124c2ec316b4b35a79;
	data_in_valid <= 1'b1;
	@ (posedge clock);
	// display data value 
	$display("Ciphertext Data 2: 128'h%32h", data_in);
	// third cipher text input data 
	data_in[127:0] <= 128'h8df4e9aac5c7573a27d8d055d6e4d64b;
	data_in_valid <= 1'b1;
	@ (posedge clock);
	// display data value 
	$display("Ciphertext Data 3: 128'h%32h", data_in);
	// forth cipher text input data 
	data_in[127:0] <= 128'hec8ce641087165a463d4118dc35f9001;
	data_in_valid <= 1'b1;
	@ (posedge clock);
	// display data value 
	$display("Ciphertext Data 4: 128'h%32h", data_in);
	// no more data can be given to the core 
	data_in_valid <= 1'b0;
	
	// announce state 
	$display("");
	$display("Waiting for plain text data");
	
	// wait for all output plain text data 
	dout_count = 0;
	while (dout_count < 4)
	begin 
		// check for a new output data 
		if (data_out_valid) 
			dout_count <= dout_count + 1;
		// wait for next clock cycle 
		@(posedge clock);
	end 
	$display("");
	
	// encryption for 192 bit key mode 
	$display("Testing encryption for 192 bit key:");
	$display("-------------------------------------");
	// set core mode to encryption and key size to 192 
	enc_dec <= 1'b0;
	key_mode <= 2'b01;
	// set the key value and start 	key expansion 
	key_in[255:64] <= 192'h8e73b0f7da0e6452c810f32b809079e562f8ead2522c6b7b;
	key_start <= 1'b1;
	@(posedge clock);
	key_start <= 1'b0;
	@(posedge clock);
	// display key value 
	$display("Key: 192'h%32h", key_in[255:64]);
	// wait for key expansion to finish 
	while (!key_ready) @(posedge clock);
	// announce key expansion ended 
	$display("Key expansion done");
	$display("");
	
	// first plain text input data 
	data_in[127:0] <= 128'hdda97ca4864cdfe06eaf70a0ec0d7191;
	data_in_valid <= 1'b1;
	@ (posedge clock);
	// display data value 
	$display("Plaintext Data 1: 128'h%32h", data_in);
	// second plain text input data 
	data_in[127:0] <= 128'h3243f6a8885a308d313198a2e0370731;
	data_in_valid <= 1'b1;
	@ (posedge clock);
	// display data value 
	$display("Plaintext Data 2: 128'h%32h", data_in);
	// third plain text input data 
	data_in[127:0] <= 128'h00112233445566778899aabbccddeeff;
	data_in_valid <= 1'b1;
	@ (posedge clock);
	// display data value 
	$display("Plaintext Data 3: 128'h%32h", data_in);
	// forth plain text input data 
	data_in[127:0] <= 128'h8ea2b7ca516745bfeafc49904b496089;
	data_in_valid <= 1'b1;
	@ (posedge clock);
	// display data value 
	$display("Plaintext Data 4: 128'h%32h", data_in);
	// no more data can be given to the core 
	data_in_valid <= 1'b0;
	@(posedge clock);

	// announce state 
	$display("");
	$display("Waiting for cipher text data");
	
	// wait for all output cipher text data 
	dout_count = 0;
	while (dout_count < 4)
	begin 
		// check for a new output data 
		if (data_out_valid) 
			dout_count <= dout_count + 1;
		// wait for next clock cycle 
		@(posedge clock);
	end 
	$display("");
	
	// continue with decryption of the same cipher text without key expansion 
	$display("Testing decryption for 192 bit key:");
	$display("-------------------------------------");
	// set core mode to decryption 
	enc_dec <= 1'b1;
	@(posedge clock);
	// display key value 
	$display("Key: 192'h%32h", key_in[255:64]);
	// announce key expansion is not done again 
	$display("Using the same key, expansion is not required.");
	$display("");
	
	// first cipher text input data 
	data_in[127:0] <= 128'h17d3cbb6a98f64ccd134e0d0b7695aa9;
	data_in_valid <= 1'b1;
	@ (posedge clock);
	// display data value 
	$display("Ciphertext Data 1: 128'h%32h", data_in);
	// second cipher text input data 
	data_in[127:0] <= 128'h4a7d86377de2a8faf00f8ef97c2eb982;
	data_in_valid <= 1'b1;
	@ (posedge clock);
	// display data value 
	$display("Ciphertext Data 2: 128'h%32h", data_in);
	// third cipher text input data 
	data_in[127:0] <= 128'heb1b03f2acb64bcf28c9991cc8a4fa50;
	data_in_valid <= 1'b1;
	@ (posedge clock);
	// display data value 
	$display("Ciphertext Data 3: 128'h%32h", data_in);
	// forth cipher text input data 
	data_in[127:0] <= 128'h2adc503e1c9b669de6b5bc904035547d;
	data_in_valid <= 1'b1;
	@ (posedge clock);
	// display data value 
	$display("Ciphertext Data 4: 128'h%32h", data_in);
	// no more data can be given to the core 
	data_in_valid <= 1'b0;
	
	// announce state 
	$display("");
	$display("Waiting for plain text data");
	
	// wait for all output plain text data 
	dout_count = 0;
	while (dout_count < 4)
	begin 
		// check for a new output data 
		if (data_out_valid) 
			dout_count <= dout_count + 1;
		// wait for next clock cycle 
		@(posedge clock);
	end 
	$display("");
	
	// encryption for 256 bit key mode 
	$display("Testing encryption for 256 bit key:");
	$display("-------------------------------------");
	// set core mode to encryption and key size to 256 
	enc_dec <= 1'b0;
	key_mode <= 2'b10;
	// set the key value and start 	key expansion 
	key_in[255:0] <= 256'h603deb1015ca71be2b73aef0857d77811f352c073b6108d72d9810a30914dff4;
	key_start <= 1'b1;
	@(posedge clock);
	key_start <= 1'b0;
	@(posedge clock);
	// display key value 
	$display("Key: 256'h%32h", key_in[255:64]);
	// wait for key expansion to finish 
	while (!key_ready) @(posedge clock);
	// announce key expansion ended 
	$display("Key expansion done");
	$display("");
	
	// first plain text input data 
	data_in[127:0] <= 128'hdda97ca4864cdfe06eaf70a0ec0d7191;
	data_in_valid <= 1'b1;
	@ (posedge clock);
	// display data value 
	$display("Plaintext Data 1: 128'h%32h", data_in);
	// second plain text input data 
	data_in[127:0] <= 128'h3243f6a8885a308d313198a2e0370731;
	data_in_valid <= 1'b1;
	@ (posedge clock);
	// display data value 
	$display("Plaintext Data 2: 128'h%32h", data_in);
	// third plain text input data 
	data_in[127:0] <= 128'h00112233445566778899aabbccddeeff;
	data_in_valid <= 1'b1;
	@ (posedge clock);
	// display data value 
	$display("Plaintext Data 3: 128'h%32h", data_in);
	// forth plain text input data 
	data_in[127:0] <= 128'h8ea2b7ca516745bfeafc49904b496089;
	data_in_valid <= 1'b1;
	@ (posedge clock);
	// display data value 
	$display("Plaintext Data 4: 128'h%32h", data_in);
	// no more data can be given to the core 
	data_in_valid <= 1'b0;
	@(posedge clock);

	// announce state 
	$display("");
	$display("Waiting for cipher text data");
	
	// wait for all output cipher text data 
	dout_count = 0;
	while (dout_count < 4)
	begin 
		// check for a new output data 
		if (data_out_valid) 
			dout_count <= dout_count + 1;
		// wait for next clock cycle 
		@(posedge clock);
	end 
	$display("");
	
	// continue with decryption of the same cipher text without key expansion 
	$display("Testing decryption for 256 bit key:");
	$display("-------------------------------------");
	// set core mode to decryption 
	enc_dec <= 1'b1;
	@(posedge clock);
	// display key value 
	$display("Key: 256'h%32h", key_in[255:0]);
	// announce key expansion is not done again 
	$display("Using the same key, expansion is not required.");
	$display("");
	
	// first cipher text input data 
	data_in[127:0] <= 128'h32573d9003bfd345029779298be53b96;
	data_in_valid <= 1'b1;
	@ (posedge clock);
	// display data value 
	$display("Ciphertext Data 1: 128'h%32h", data_in);
	// second cipher text input data 
	data_in[127:0] <= 128'ha5f464b57512d05db2bae8d2415b921d;
	data_in_valid <= 1'b1;
	@ (posedge clock);
	// display data value 
	$display("Ciphertext Data 2: 128'h%32h", data_in);
	// third cipher text input data 
	data_in[127:0] <= 128'hd83414223d20a0c928b136c884d07ea2;
	data_in_valid <= 1'b1;
	@ (posedge clock);
	// display data value 
	$display("Ciphertext Data 3: 128'h%32h", data_in);
	// forth cipher text input data 
	data_in[127:0] <= 128'hc1f968d2a6859137bd9ad9111ad7f6dc;
	data_in_valid <= 1'b1;
	@ (posedge clock);
	// display data value 
	$display("Ciphertext Data 4: 128'h%32h", data_in);
	// no more data can be given to the core 
	data_in_valid <= 1'b0;
	
	// announce state 
	$display("");
	$display("Waiting for plain text data");
	
	// wait for all output plain text data 
	dout_count = 0;
	while (dout_count < 4)
	begin 
		// check for a new output data 
		if (data_out_valid) 
			dout_count <= dout_count + 1;
		// wait for next clock cycle 
		@(posedge clock);
	end 
	$display("");

	// announce simulation end 
	$display("   Simulation Done !!!");
		
	repeat (10) @(posedge clock);
	$finish;
end

// unit under test 
aes dut
(
	.clk(clock),
	.reset(reset),
	.i_start(key_start),
	.i_enable(enable),
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

// display output data from the core 
always @ (posedge clock)
   if (data_out_valid)
      $display("Output Data %1d: 128'h%16h", dout_count+1, data_out);

endmodule
//---------------------------------------------------------------------------------------
//						Th.. Th.. Th.. Thats all folks !!!
//---------------------------------------------------------------------------------------
