//////////////////////////////////////////////////////////////////
////
////
//// 	AES TESTBENCH BLOCK
////
////
////
//// This file is part of the APB to AES128 project
////
//// http://www.opencores.org/cores/apbtoaes128/
////
////
////
//// Description
////
//// Implementation of APB IP core according to
////
//// aes128_spec IP core specification document.
////
////
////
//// To Do: Things are right here but always all block can suffer changes
////
////
////
////
////
//// Author(s): - Felipe Fernandes Da Costa, fefe2560@gmail.com
////		  Julio Cesar 
////
///////////////////////////////////////////////////////////////// 
////
////
//// Copyright (C) 2009 Authors and OPENCORES.ORG
////
////
////
//// This source file may be used and distributed without
////
//// restriction provided that this copyright statement is not
////
//// removed from the file and that any derivative work contains
//// the original copyright notice and the associated disclaimer.
////
////
//// This source file is free software; you can redistribute it
////
//// and/or modify it under the terms of the GNU Lesser General
////
//// Public License as published by the Free Software Foundation;
//// either version 2.1 of the License, or (at your option) any
////
//// later version.
////
////
////
//// This source is distributed in the hope that it will be
////
//// useful, but WITHOUT ANY WARRANTY; without even the implied
////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
////
//// PURPOSE. See the GNU Lesser General Public License for more
//// details.
////
////
////
//// You should have received a copy of the GNU Lesser General
////
//// Public License along with this source; if not, download it
////
//// from http://www.opencores.org/lgpl.shtml
////
////
///////////////////////////////////////////////////////////////////
module tb_aes_ip();

localparam AES_CR    = 4'd00;
localparam AES_SR    = 4'd01;
localparam AES_DINR  = 4'd02;
localparam AES_DOUTR = 4'd03;
localparam AES_KEYR0 = 4'd04;
localparam AES_KEYR1 = 4'd05;
localparam AES_KEYR2 = 4'd06;
localparam AES_KEYR3 = 4'd07;
localparam AES_IVR0  = 4'd08;
localparam AES_IVR1  = 4'd09;
localparam AES_IVR2  = 4'd10;
localparam AES_IVR3  = 4'd11;

// Configuratin Bits
localparam DMAOUTEN    = 32'h00000001 << 12;
localparam DMAINEN     = 32'h00000001 << 11;
localparam ERRIE       = 32'h00000001 << 10;
localparam CCFIE       = 32'h00000001 << 9;
localparam ERRC        = 32'h00000001 << 8;
localparam CCFC	       = 32'h00000001 << 7;
localparam EBC         = 32'h00000000;
localparam CBC         = 32'h00000001 << 5;
localparam CTR         = 32'h00000001 << 6;
localparam ENCRYPTION  = 32'h00000000;
localparam KEY_DERIV   = 32'h00000001 << 3;
localparam DECRYPTION  = 32'h00000001 << 4;
localparam KEY_DECRYP  = KEY_DERIV | DECRYPTION;
localparam ENABLE      = 32'h00000001;
localparam DISABLE     = 32'h00000000;

wire int_ccf, int_err;
wire dma_req_wr, dma_req_rd;
wire [31:0] PRDATA;

reg [31:0] PWDATA;
reg [3:0] PADDR;
reg PCLK, PRESETn;
reg PSEL, PENABLE, PWRITE;

reg [31:0] data_rd;

reg [127:0] data_in;
reg [127:0] key_in;
reg [127:0] iv_in;
reg [127:0] result;
reg [127:0] golden;
reg [127:0] result_rd;
reg [127:0] iv_rd;
reg [127:0] key_rd;
reg error_chk;

aes_ip AES_IP
(
	.int_ccf    ( int_ccf    ),
	.int_err    ( int_err    ),
	.dma_req_wr ( dma_req_wr ),
	.dma_req_rd ( dma_req_rd ),
	.PRDATA     ( PRDATA     ),
	.PREADY     ( PREADY     ),
  .PSLVERR    ( PSLVERR    ),
  .PWDATA     ( PWDATA     ),    
  .PADDR      ( PADDR      ),     
  .PSEL       ( PSEL       ),      
  .PENABLE    ( PENABLE    ),   
  .PWRITE     ( PWRITE     ),    
  .PCLK       ( PCLK       ),      
  .PRESETn    ( PRESETn    )
);
initial
 begin
    $dumpfile("tb_aes_ip.vcd");
    $dumpvars(0,tb_aes_ip);
 end
task reset;
	begin
		PCLK = 0;
		PSEL = 0;
		PENABLE = 0;
		PWDATA = 0;
		PWRITE = 0;
		PADDR = 0;
		PRESETn = 0;
		@(posedge PCLK);
		PRESETn = 1;
	end
endtask

task apb_write;
	input [31:0] addr;
	input [31:0] data_in;
	begin
		PSEL <= 1;
		PWRITE <= 1;
		PENABLE <= 0;
		PADDR <= addr;
		PWDATA <= data_in;
		@(posedge PCLK);
		PENABLE <= 1;
		@(posedge PCLK);
		PSEL <= 0;
		PENABLE <= 0;
	end
endtask

task apb_read;
	input  [31:0] addr;
	output [31:0] data_out;
	begin
		PSEL <= 1;
		PENABLE <= 0;
		PWRITE <= 0;
		PADDR <= addr;
		@(posedge PCLK);
		PENABLE <= 1;
		@(posedge PCLK);
		data_out = PRDATA;
		PENABLE <= 0;
		PSEL <= 0;
	end
endtask

task write_iv;
	input [127:0] iv_in;
	begin
		apb_write(AES_IVR0, iv_in[ 31:0]);
		apb_write(AES_IVR1, iv_in[ 63:32]);
		apb_write(AES_IVR2, iv_in[ 95:64]);
		apb_write(AES_IVR3, iv_in[127:96]);
	end
endtask

task read_iv;
	output [127:0] iv_out;
	begin
		apb_read(AES_IVR0, iv_out[ 31:0]);
		apb_read(AES_IVR1, iv_out[ 63:32]);
		apb_read(AES_IVR2, iv_out[ 95:64]);
		apb_read(AES_IVR3, iv_out[127:96]);
	end
endtask

task write_key;
	input [127:0] key_in;
	begin
		apb_write(AES_KEYR0, key_in[ 31:0]);
		apb_write(AES_KEYR1, key_in[ 63:32]);
		apb_write(AES_KEYR2, key_in[ 95:64]);
		apb_write(AES_KEYR3, key_in[127:96]);
	end
endtask

task read_key;
	output [127:0] key_out;
	begin
		apb_read(AES_KEYR0, key_out[ 31:0]);
		apb_read(AES_KEYR1, key_out[ 63:32]);
		apb_read(AES_KEYR2, key_out[ 95:64]);
		apb_read(AES_KEYR3, key_out[127:96]);
	end
endtask

task write_data;
	input [127:0] data_in;
	begin
		apb_write(AES_DINR, data_in[127:96]);
		apb_write(AES_DINR, data_in[ 95:64]);
		apb_write(AES_DINR, data_in[ 63:32]);
		apb_write(AES_DINR, data_in[ 31: 0]);
	end
endtask

task write_data_dma;
	input [127:0] data_in;
	begin
		@(posedge dma_req_wr);
		apb_write(AES_DINR, data_in[127:96]);
		@(posedge dma_req_wr);
		apb_write(AES_DINR, data_in[ 95:64]);
		@(posedge dma_req_wr);
		apb_write(AES_DINR, data_in[ 63:32]);
		@(posedge dma_req_wr);
		apb_write(AES_DINR, data_in[ 31: 0]);
	end
endtask

task read_data;
	output [127:0] data_rd;
	begin
		apb_read(AES_DOUTR, data_rd[127:96]);
		apb_read(AES_DOUTR, data_rd[ 95:64]);
		apb_read(AES_DOUTR, data_rd[ 63:32]);
		apb_read(AES_DOUTR, data_rd[ 31: 0]);
	end
endtask

task read_data_dma;
	output [127:0] data_rd;
	begin
		@(posedge dma_req_rd);
		apb_read(AES_DOUTR, data_rd[127:96]);
		@(posedge dma_req_rd);
		apb_read(AES_DOUTR, data_rd[ 95:64]);
		@(posedge dma_req_rd);
		apb_read(AES_DOUTR, data_rd[ 63:32]);
		@(posedge dma_req_rd);
		apb_read(AES_DOUTR, data_rd[ 31: 0]);
	end
endtask

task check_result;
	input [127:0] result;
	input [127:0] golden;
	output error;
	begin
		error = 0;
		if(result != golden)
			begin
				$display("TEST FAILED!");
				$display("Expected %x, obtained %x", golden, result);
				error = 1;
			end
	end
endtask

integer i, error;

initial
	begin
		reset;
		iv_in  = 128'h2b7e151628aed2a6abf7158809cf4f3c;
		key_in = 128'h00112233445566778899aabbccddeeff;
		write_iv(iv_in);
		read_iv(iv_rd);
		if(iv_rd != iv_in)
			begin
				$display("Access to IV register failed!");
				$display("Expected %x, obtained %x", iv_in, iv_rd);
				$stop;
			end
		write_key(key_in);
		read_key(key_rd);
		if(key_rd != key_in)
			begin
				$display("Access to KEY register failed!");
				$display("Expected %x, obtained %x", key_in, key_rd);
				$stop;
			end
		apb_write(AES_CR, ENABLE);
		write_key(128'd50);
		read_iv(data_rd);
		read_data(result);
		apb_write(AES_CR, DISABLE);
		apb_read(AES_SR, data_rd);
		apb_write(AES_CR, ERRC);

		//ECB TESTS
		//ENCRYPTION
		error = 0;
		data_in = 128'h00112233445566778899aabbccddeeff;
		key_in  = 128'h000102030405060708090a0b0c0d0e0f;
		golden  = 128'h69c4e0d86a7b0430d8cdb78070b4c55a;
		write_key(key_in);
		apb_write(AES_CR, ENABLE | CCFIE);
		write_data(data_in);
		@(posedge int_ccf);
		read_data(result);
		check_result(result, golden, error_chk);
		error = error + error_chk;

		data_in = 128'h3243f6a8885a308d313198a2e0370734;
		key_in  = 128'h2b7e151628aed2a6abf7158809cf4f3c;
		golden  = 128'h3925841d02dc09fbdc118597196a0b32;
		apb_write(AES_CR, DISABLE);
		write_key(key_in);
		apb_write(AES_CR, ENABLE | CCFIE);
		write_data(data_in);
		@(posedge int_ccf);
		read_data(result);
		check_result(result, golden, error_chk);
		error = error + error_chk;

		// KEY DERIVATION
		key_in  = 128'h2b7e151628aed2a6abf7158809cf4f3c;
		golden  = 128'hd014f9a8c9ee2589e13f0cc8b6630ca6;
		apb_write(AES_CR, DISABLE);
		write_key(key_in);
		apb_write(AES_CR, KEY_DERIV | ENABLE | CCFIE);
		@(posedge int_ccf);
		@(posedge PCLK);
		read_key(result);
		check_result(result, golden, error_chk);
		error = error + error_chk;

		// DECRYPTION
		data_in = 128'h69c4e0d86a7b0430d8cdb78070b4c55a;
		key_in  = 128'h13111d7fe3944a17f307a78b4d2b30c5;
		golden  = 128'h00112233445566778899aabbccddeeff;
		apb_write(AES_CR, DISABLE);
		write_key(key_in);
		apb_write(AES_CR, DECRYPTION | ENABLE | CCFIE);
		write_data(data_in);
		@(posedge int_ccf);
		read_data(result);
		check_result(result, golden, error_chk);
		error = error + error_chk;
		
		// DECCYPTION WITH DERIVATION
		data_in = 128'h69c4e0d86a7b0430d8cdb78070b4c55a;
		key_in  = 128'h000102030405060708090a0b0c0d0e0f;
		golden  = 128'h00112233445566778899aabbccddeeff;
		apb_write(AES_CR, DISABLE);
		write_key(key_in);
		apb_write(AES_CR, KEY_DECRYP | ENABLE | CCFIE);
		write_data(data_in);
		@(posedge int_ccf);
		read_data(result);
		check_result(result, golden, error_chk);
		error = error + error_chk;

		key_in  = 128'h000102030405060708090a0b0c0d0e0f;
		apb_write(AES_CR, DISABLE);
		write_key(key_in);
		apb_write(AES_CR, KEY_DERIV | ENABLE | CCFIE);
		@(posedge int_ccf);
		data_in = 128'h69c4e0d86a7b0430d8cdb78070b4c55a;
		golden  = 128'h00112233445566778899aabbccddeeff;
		apb_write(AES_CR, DISABLE);
		apb_write(AES_CR, DECRYPTION | ENABLE | CCFIE);
		write_data(data_in);
		@(posedge int_ccf);
		read_data(result);
		check_result(result, golden, error_chk);
		error = error + error_chk;
		if(!error)
			$display("ECB TEST PASSED!");
		else
			$display("ECB TEST FAILED!\n Founded %d errors", error);

		// CBC Encryption
		error = 0;
		apb_write(AES_CR, DISABLE);
		key_in  = 128'h2b7e151628aed2a6abf7158809cf4f3c;
		iv_in   = 128'h000102030405060708090a0b0c0d0e0f;

		//BLOCK 1
		data_in = 128'h6bc1bee22e409f96e93d7e117393172a;
		golden  = 128'h7649abac8119b246cee98e9b12e9197d;
		write_key(key_in);
		write_iv(iv_in);
		apb_write(AES_CR, CBC | ENABLE | CCFIE);
		write_data(data_in);
		@(posedge int_ccf);
		read_data(result);
		check_result(result, golden, error_chk);
		error = error + error_chk;
		
		// BLOCK 2
		data_in = 128'hae2d8a571e03ac9c9eb76fac45af8e51;
		golden = 128'h5086cb9b507219ee95db113a917678b2;
		write_data(data_in);
		@(posedge int_ccf);
		read_data(result);
		check_result(result, golden, error_chk);
		error = error + error_chk;

		// BLOCK 3
		data_in = 128'h30c81c46a35ce411e5fbc1191a0a52ef;
		golden = 128'h73bed6b8e3c1743b7116e69e22229516;
		write_data(data_in);
		@(posedge int_ccf);
		read_data(result);
		check_result(result, golden, error_chk);
		error = error + error_chk;

		// BLOCK 4
		data_in = 128'hf69f2445df4f9b17ad2b417be66c3710; 
		golden = 128'h3ff1caa1681fac09120eca307586e1a7;
		write_data(data_in);
		@(posedge int_ccf);
		read_data(result);
		check_result(result, golden, error_chk);
		error = error + error_chk;

		// CBC DECRYPTION
		apb_write(AES_CR, DISABLE);
		key_in  = 128'h2b7e151628aed2a6abf7158809cf4f3c;
		iv_in   = 128'h000102030405060708090a0b0c0d0e0f;

		//BLOCK 1
		data_in = 128'h7649abac8119b246cee98e9b12e9197d;
		golden  = 128'h6bc1bee22e409f96e93d7e117393172a;
		write_key(key_in);
		write_iv(iv_in);
		apb_write(AES_CR, CBC | KEY_DECRYP | ENABLE | CCFIE);
		write_data(data_in);
		@(posedge int_ccf);
		read_data(result);
		check_result(result, golden, error_chk);
		error = error + error_chk;
		
		// BLOCK 2
		data_in = 128'h5086cb9b507219ee95db113a917678b2;
		golden = 128'hae2d8a571e03ac9c9eb76fac45af8e51 ;
		write_data(data_in);
		@(posedge int_ccf);
		read_data(result);
		check_result(result, golden, error_chk);
		error = error + error_chk;

		// BLOCK 3
		data_in = 128'h73bed6b8e3c1743b7116e69e22229516; 
		golden = 128'h30c81c46a35ce411e5fbc1191a0a52ef ;
		write_data(data_in);
		@(posedge int_ccf);
		read_data(result);
		check_result(result, golden, error_chk);
		error = error + error_chk;

		// BLOCK 4
		data_in = 128'h3ff1caa1681fac09120eca307586e1a7;  
		golden  = 128'hf69f2445df4f9b17ad2b417be66c3710;
		write_data(data_in);
		@(posedge int_ccf);
		read_data(result);
		check_result(result, golden, error_chk);
		error = error + error_chk;
		if(!error)
			$display("CBC TEST PASSED!");
		else
			$display("CBC TEST FAILED!\n Founded %d errors", error);

		// CTR Encryption
		error = 0;
		apb_write(AES_CR, DISABLE);
		key_in  = 128'h2b7e151628aed2a6abf7158809cf4f3c;
		iv_in   = 128'hf0f1f2f3f4f5f6f7f8f9fafbfcfdfeff;

		//BLOCK 1
		data_in = 128'h6bc1bee22e409f96e93d7e117393172a;
		golden  = 128'h874d6191b620e3261bef6864990db6ce ;
		write_key(key_in);
		write_iv(iv_in);
		apb_write(AES_CR, CTR | ENABLE | CCFIE);
		write_data(data_in);
		@(posedge int_ccf);
		read_data(result);
		check_result(result, golden, error_chk);
		error = error + error_chk;
		
		// BLOCK 2
		data_in = 128'hae2d8a571e03ac9c9eb76fac45af8e51;
		golden = 128'h9806f66b7970fdff8617187bb9fffdff;
		write_data(data_in);
		@(posedge int_ccf);
		read_data(result);
		check_result(result, golden, error_chk);
		error = error + error_chk;

		// BLOCK 3
		data_in = 128'h30c81c46a35ce411e5fbc1191a0a52ef;
		golden = 128'h5ae4df3edbd5d35e5b4f09020db03eab;
		write_data(data_in);
		@(posedge int_ccf);
		read_data(result);
		check_result(result, golden, error_chk);
		error = error + error_chk;

		// BLOCK 4
		data_in = 128'hf69f2445df4f9b17ad2b417be66c3710; 
		golden = 128'h1e031dda2fbe03d1792170a0f3009cee ;
		write_data(data_in);
		@(posedge int_ccf);
		read_data(result);
		check_result(result, golden, error_chk);
		error = error + error_chk;

		// CTR DECRYPTION
		apb_write(AES_CR, DISABLE);
		iv_in   = 128'hf0f1f2f3f4f5f6f7f8f9fafbfcfdfeff;
		//BLOCK 1
		data_in = 128'h874d6191b620e3261bef6864990db6ce;
		golden  = 128'h6bc1bee22e409f96e93d7e117393172a;
		write_iv(iv_in);
		apb_write(AES_CR, CTR | KEY_DECRYP | ENABLE | CCFIE);
		write_data(data_in);
		@(posedge int_ccf);
		read_data(result);
		check_result(result, golden, error_chk);
		error = error + error_chk;
		
		// BLOCK 2
		data_in = 128'h9806f66b7970fdff8617187bb9fffdff;
		golden  = 128'hae2d8a571e03ac9c9eb76fac45af8e51;
		write_data(data_in);
		@(posedge int_ccf);
		read_data(result);
		check_result(result, golden, error_chk);
		error = error + error_chk;

		// BLOCK 3
		data_in = 128'h5ae4df3edbd5d35e5b4f09020db03eab;
		golden  = 128'h30c81c46a35ce411e5fbc1191a0a52ef;
		write_data(data_in);
		@(posedge int_ccf);
		read_data(result);
		check_result(result, golden, error_chk);
		error = error + error_chk;

		// BLOCK 4
		data_in = 128'h1e031dda2fbe03d1792170a0f3009cee;
		golden  = 128'hf69f2445df4f9b17ad2b417be66c3710;
		write_data(data_in);
		@(posedge int_ccf);
		read_data(result);
		check_result(result, golden, error_chk);
		error = error + error_chk;
		if(!error)
			$display("CTR TEST PASSED!");
		else
			$display("CTR TEST FAILED!\n Founded %d errors", error);

		error = 0;
		data_in = 128'h00112233445566778899aabbccddeeff;
		key_in  = 128'h000102030405060708090a0b0c0d0e0f;
		golden  = 128'h69c4e0d86a7b0430d8cdb78070b4c55a;
		write_key(key_in);
		apb_write(AES_CR, ENABLE | CCFIE);
		write_data(data_in);
		repeat(30)
			@(posedge PCLK);
		apb_write(AES_CR, DISABLE);
		// KEY DERIVATION
		key_in  = 128'h2b7e151628aed2a6abf7158809cf4f3c;
		golden  = 128'hd014f9a8c9ee2589e13f0cc8b6630ca6;
		write_key(key_in);
		apb_write(AES_CR, KEY_DERIV | ENABLE | CCFIE);
		@(posedge int_ccf);
		@(posedge PCLK); // A LEITURA DA CHAVE DEVE SER INICIADA UM CLOCK AP\D2S A SUBIDA DE CCF
		read_key(result);
		check_result(result, golden, error_chk);

		// TEST SUSPEND FUNCTIONALITY
		key_in  = 128'h2b7e151628aed2a6abf7158809cf4f3c;
		iv_in   = 128'h000102030405060708090a0b0c0d0e0f;

		//BLOCK 1
		data_in = 128'h6bc1bee22e409f96e93d7e117393172a;
		golden  = 128'h7649abac8119b246cee98e9b12e9197d;
		write_key(key_in);
		write_iv(iv_in);
		apb_write(AES_CR, CBC | ENABLE | CCFIE);
		write_data(data_in);
		@(posedge int_ccf);
		read_data(result);
		check_result(result, golden, error_chk);
		error = error + error_chk;
		
		// BLOCK 2
		data_in = 128'hae2d8a571e03ac9c9eb76fac45af8e51;
		golden = 128'h5086cb9b507219ee95db113a917678b2;
		write_data(data_in);
		@(posedge int_ccf);
		read_data(result);
		check_result(result, golden, error_chk);
		error = error + error_chk;

		//suspend processing
		apb_write(AES_CR, DISABLE);
		result_rd = result;
		read_iv(iv_rd);
		read_key(key_rd);

		//begin new processing		
		key_in  = 128'h2b7e151628aed2a6abf7158809cf4f3c;
		golden  = 128'hd014f9a8c9ee2589e13f0cc8b6630ca6;
		write_key(key_in);
		apb_write(AES_CR, KEY_DERIV | ENABLE | CCFIE);
		@(posedge int_ccf);
		@(posedge PCLK); // A LEITURA DA CHAVE DEVE SER INICIADA UM CLOCK AP\D2S A SUBIDA DE CCF
		read_key(result);
		check_result(result, golden, error_chk);
		error = error + error_chk;

		//continues processing
		// BLOCK 3
		key_in  = 128'h2b7e151628aed2a6abf7158809cf4f3c;
		apb_write(AES_CR, DISABLE);
		write_key(key_in);
		write_iv(result_rd);
		data_in = 128'h30c81c46a35ce411e5fbc1191a0a52ef;
		golden = 128'h73bed6b8e3c1743b7116e69e22229516;
		apb_write(AES_CR, CBC | ENABLE | CCFIE);
		write_data(data_in);
		@(posedge int_ccf);
		read_data(result);
		check_result(result, golden, error_chk);
		error = error + error_chk;

		// BLOCK 4
		data_in = 128'hf69f2445df4f9b17ad2b417be66c3710; 
		golden = 128'h3ff1caa1681fac09120eca307586e1a7;
		write_data(data_in);
		@(posedge int_ccf);
		read_data(result);
		check_result(result, golden, error_chk);
		error = error + error_chk;	
		if(!error)
			$display("SUSPEND MODE TEST PASSED!");
		else
			$display("SUSPEND MODE TEST FAILED!\n Founded %d errors", error);

		//DMA TEST
		error = 0;
		apb_write(AES_CR, DISABLE);
		data_in = 128'h00112233445566778899aabbccddeeff;
		key_in  = 128'h000102030405060708090a0b0c0d0e0f;
		golden  = 128'h69c4e0d86a7b0430d8cdb78070b4c55a;
		write_key(key_in);
		apb_write(AES_CR, DMAINEN | DMAOUTEN | ENABLE | CCFIE);
		write_data_dma(data_in);
		@(posedge int_ccf);
		read_data_dma(result);
		check_result(result, golden, error_chk);
		error = error + error_chk;
		if(!error)
			$display("DMA TEST PASSED!");
		else
			$display("DMA TEST FAILED!\n Founded %d errors", error);
		$stop;
	end

always #10
	PCLK = !PCLK;
endmodule
