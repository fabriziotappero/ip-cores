//////////////////////////////////////////////////////////////////
////
////
//// 	AES CORE BLOCK
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
module AES_GLADIC_tb;

	
	reg PCLK;
	wire PRESETn;
	wire PSEL;
	wire PENABLE;
	wire PWRITE;

	wire [31:0] PWDATA;
	wire [31:0] PADDR;
	wire [31:0] PRDATA;


	wire PREADY;
	wire PSLVERR;

	wire int_ccf;
	wire int_err;
	wire dma_req_wr;
	wire dma_req_rd;

	
	wire [3:0] core_addr;

	assign core_addr = PADDR[5:2];

	aes_ip 	DUT (

		.PCLK (PCLK),
		.PRESETn (PRESETn),
		.PENABLE (PENABLE),
		.PSEL (PSEL),
		.PWDATA (PWDATA),
		.PADDR (core_addr),
		.PWRITE(PWRITE),
		.PRDATA (PRDATA),
		.PREADY (PREADY),
		.PSLVERR (PSLVERR),
		.int_ccf(int_ccf),
		.int_err(int_err),
		.dma_req_wr(dma_req_wr),
		.dma_req_rd(dma_req_rd)
	);

	integer i,a;

	initial
	 begin
	    $dumpfile("AES_GLADIC_tb.vcd");
	    $dumpvars(0,AES_GLADIC_tb);
	    $init;
	    $init_reset;
	 end

	initial PCLK = 1'b0;
	always #(5) PCLK = ~PCLK;

	//ECB
	always@(posedge PCLK)
		$bfm_encryption_ecb_aes128;

	always@(posedge PCLK)
		$bfm_encryption_ecb_dma_aes128;

	always@(posedge PCLK)
		$bfm_encryption_ccfie_ecb_aes128;

	//CBC
	always@(posedge PCLK)
		$bfm_encryption_cbc_aes128;	

	always@(posedge PCLK)
		$bfm_encryption_cbc_dma_aes128;	

	always@(posedge PCLK)
		$bfm_encryption_ccfie_cbc_aes128;

	//CTR
	always@(posedge PCLK)
		$bfm_encryption_ctr_aes128;	

	always@(posedge PCLK)
		$bfm_encryption_ctr_dma_aes128;	

	always@(posedge PCLK)
		$bfm_encryption_ccfie_ctr_aes128;


	//ECB
	always@(posedge PCLK)
		$bfm_key_generation_ecb_aes128;

	always@(posedge PCLK)
		$bfm_key_generation_dma_ecb_aes128;

	always@(posedge PCLK)
		$bfm_key_generation_ccfie_ecb_aes128;

	//CBC
	always@(posedge PCLK)
		$bfm_key_generation_cbc_aes128;

	always@(posedge PCLK)
		$bfm_key_generation_dma_cbc_aes128;

	always@(posedge PCLK)
		$bfm_key_generation_ccfie_cbc_aes128;

	//CTR
	always@(posedge PCLK)
		$bfm_key_generation_ctr_aes128;

	always@(posedge PCLK)
		$bfm_key_generation_dma_ctr_aes128;

	always@(posedge PCLK)
		$bfm_key_generation_ccfie_ctr_aes128;

	//ECB
	always@(posedge PCLK)
		$bfm_decryption_ecb_aes128;

	always@(posedge PCLK)
		$bfm_decryption_ecb_dma_aes128;

	always@(posedge PCLK)
		$bfm_decryption_ccfie_ecb_aes128;

	//CBC
	always@(posedge PCLK)
		$bfm_decryption_cbc_aes128;

	always@(posedge PCLK)
		$bfm_decryption_cbc_dma_aes128;

	always@(posedge PCLK)
		$bfm_decryption_ccfie_cbc_aes128;

	//CTR
	always@(posedge PCLK)
		$bfm_decryption_ctr_aes128;

	always@(posedge PCLK)
		$bfm_decryption_ctr_dma_aes128;

	always@(posedge PCLK)
		$bfm_decryption_ccfie_ctr_aes128;

	//ECB
	always@(posedge PCLK)
		$bfm_derivation_decryption_ecb_aes128;

	always@(posedge PCLK)
		$bfm_derivation_decryption_dma_ecb_aes128;

	always@(posedge PCLK)
		$bfm_derivation_decryption_ccfie_ecb_aes128;

	//CTR
	always@(posedge PCLK)
		$bfm_derivation_decryption_ctr_aes128;

	always@(posedge PCLK)
		$bfm_derivation_decryption_dma_ctr_aes128;

	always@(posedge PCLK)
		$bfm_derivation_decryption_ccfie_ctr_aes128;

	//CBC
	always@(posedge PCLK)
		$bfm_derivation_decryption_cbc_aes128;

	always@(posedge PCLK)
		$bfm_derivation_decryption_dma_cbc_aes128;

	always@(posedge PCLK)
		$bfm_derivation_decryption_ccfie_cbc_aes128;

	//SUFLE
	always@(posedge PCLK)
		$bfm_sufle_aes128;

	//WRITE READ REGISTERS
	always@(posedge PCLK)
		$bfm_wr_aes128;

	//TRY TO WRITE ON DINR WHILE CR[0] EQUAL 1 
	always@(posedge PCLK)
		$bfm_wr_error_dinr_aes128;

	//TRY TO READ/WRITE ON DOUTR/DINR WHILE CR[0] EQUAL 1 
	always@(posedge PCLK)
		$bfm_wr_error_doutr_aes128;

	//CHOOSE WHAT BFM WILL BE ENABLED
	always@(posedge PCLK)
	   	$bfm_generate_type;

	//RESET DUT A FEW TIMES TO GO TO RIGHT STATE
	always@(posedge PCLK)
		$reset_aes128;

	//THIS CATCH INFORMATION FROM INPUT and CHECK IT 
	always@(posedge PCLK)
	begin
		$monitor_aes;
		@(posedge PENABLE);
	end

	//THIS MAKE REGISTER INITIAL ASSIGNMENT
	always@(negedge PRESETn)
		$init;

	//FLAG USED TO FINISH SIMULATION PROGRAM 
	always@(posedge PCLK)
	begin

		wait(i == 1);		
		$finish();
	end



endmodule
