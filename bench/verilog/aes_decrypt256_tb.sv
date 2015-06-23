////////////////////////////////////////////////////////////////// ////
//// 																////
//// AES Decryption Core for FPGA									////
//// 																////
//// This file is part of the AES Decryption Core for FPGA project 	////
//// http://www.opencores.org/cores/xxx/ 							////
//// 																////
//// Description 													////
//// Implementation of  AES Decryption Core for FPGA according to 	////
//// core specification document.		 							////
//// 																////
//// To Do: 														////
//// - 																////
//// 																////
//// Author(s): 													////
//// - scheng, schengopencores@opencores.org 						////
//// 																////
//////////////////////////////////////////////////////////////////////
//// 																////
//// Copyright (C) 2009 Authors and OPENCORES.ORG 					////
//// 																////
//// This source file may be used and distributed without 			////
//// restriction provided that this copyright statement is not 		////
//// removed from the file and that any derivative work contains 	////
//// the original copyright notice and the associated disclaimer. 	////
//// 																////
//// This source file is free software; you can redistribute it 	////
//// and/or modify it under the terms of the GNU Lesser General 	////
//// Public License as published by the Free Software Foundation; 	////
//// either version 2.1 of the License, or (at your option) any 	////
//// later version. 												////
//// 																////
//// This source is distributed in the hope that it will be 		////
//// useful, but WITHOUT ANY WARRANTY; without even the implied 	////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 		////
//// PURPOSE. See the GNU Lesser General Public License for more 	////
//// details. 														////
//// 																////
//// You should have received a copy of the GNU Lesser General 		////
//// Public License along with this source; if not, download it 	////
//// from http://www.opencores.org/lgpl.shtml 						////
//// 																//// ///
///////////////////////////////////////////////////////////////////
////																////
//// Testbench for 256-bit decryption								////
////																////
////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps

// Uncomment the following line if you're targeting Xilinx FPGA
//`define XILINX 1

// generic_muxfx.v defines a generic 2-to-1 MUX. This file is used to provide
// a generic definition of MUXF7 and MUXF8 in case you are not targetting Xilinx.
// When targetting Xilinx, skip this file to allow the simulator to locate the
// MUXF7 and MUXF8 in the Xilinx unisim library.
`ifndef XILINX
`include "generic/generic_muxfx.v"
`endif

`include "InvSbox.sv"
`include "InvSubBytes.sv"
`include "InvShiftRows.sv"
`include "InvAddRoundKey.sv"
`include "gfmul.sv"
`include "InvMixCol_slice.sv"
`include "InvMixColumns.sv"
`include "decrypt.sv"
`include "KschBuffer.sv"
`include "Sbox.sv"
`include "SubWord.sv"
`include "RotWord.sv"
`include "KeyExpand256.sv"
`include "aes_decrypt256.sv"
`include "aes_beh_model.sv"

`define PERIOD 10
`define T (`PERIOD/2)
`define Tcko 1

`define WAIT_N_CLK(num_of_clk) repeat(num_of_clk) @(posedge clk); #(`Tcko)

module aes_decrypt256_tb;

	logic	[0:127]	ct;
	logic	ct_vld;
	wire	ct_rdy;

	logic	[0:255]	kt;
	logic	kt_vld;
	wire	kt_rdy;
	
	wire	[0:127]	pt;
	wire	pt_vld;
	
	logic	clk;
	logic	rst;
	
	int	sample_vec_failed = 0;
	int	back_to_back_failed = 0;
	int	RandVec_256_failed = 0;
	int	failed = 0;
	
	aes256_decrypt_t ref_model;
	
	logic	[0:255]	tmp_kt;
	logic	[0:127]	tmp_ct;

	`include "decrypt_vec.sv"
	
	task set_kt(input [0:255] x);
		kt = x;
		kt_vld = 1;
		`WAIT_N_CLK(1);
		kt_vld = 0;
		`WAIT_N_CLK(1);
	endtask
	
	task set_ct(input [0:127] x);
		ct = x;
		ct_vld = 1;
		`WAIT_N_CLK(1);
		ct_vld = 0;
		`WAIT_N_CLK(1);
	endtask
	
	function logic [0:127] rand128;
		rand128 = {$random, $random, $random, $random};
	endfunction
	
	
	function logic [0:255] rand256;
		rand256 = {$random, $random, $random, $random, $random, $random, $random, $random};
	endfunction
	
	always
	begin
		clk <= 1;
		#(`T);
		clk <= 0;
		#(`T);
	end
	
	aes_decrypt256 uut(.*);
	
	initial begin
		ref_model = new;
		
		rst = 1;
		kt_vld = 0;
		ct_vld = 0;
		`WAIT_N_CLK(3);
		
		rst = 0;
		`WAIT_N_CLK(1);

		// FIPS-197 sample vector test. FIPS-197 appendix C.3.
				
		$display("FIPS-197 sample vector test");
		$display("kt=000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f ct=8ea2b7ca516745bfeafc49904b496089");
		wait (kt_rdy);
		set_kt(256'h000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f);
		wait (ct_rdy);
		set_ct(128'h8ea2b7ca516745bfeafc49904b496089);
		wait (pt_vld);
		$display("pt=%h expected=00112233445566778899aabbccddeeff",pt);
		if (pt != 128'h00112233445566778899aabbccddeeff)
		begin
			$display("***Mismatch");
			sample_vec_failed = 1;
			failed = 1;
		end
		$display("FIPS-197 sample vector test finished : %s", (sample_vec_failed)? "FAILED" : "PASSED");
		`WAIT_N_CLK(2);
		
		// Back-to-back ciphertext test.
		// Two ciphertext are applied back-to-back with no dead cycle in between.
		
		$display("\nBack-to-back ciphertext test");
		tmp_ct = rand128();
		tmp_kt = rand256();
		ref_model.KeyExpand(tmp_kt);
		ref_model.LoadCt(tmp_ct);
		ref_model.run(0);
		
		wait (kt_rdy);
		set_kt(tmp_kt);
		wait (ct_rdy);
		set_ct(tmp_ct);
		wait (pt_vld);
		$display("kt=%h ct=%h pt=%h expected=%h",tmp_kt,tmp_ct,pt,ref_model.GetState());
		if (pt != ref_model.GetState())
		begin
			$display("***Mismatch");
			back_to_back_failed = 1;
			failed = 1;
		end
		
		tmp_ct = rand128();
		ref_model.LoadCt(tmp_ct);
		ref_model.run(0);
		wait (ct_rdy);
		set_ct(tmp_ct);
		wait (pt_vld);
		$display("kt=%h ct=%h pt=%h expected=%h",tmp_kt,tmp_ct,pt,ref_model.GetState());
		if (pt != ref_model.GetState())
		begin
			$display("***Mismatch");
			back_to_back_failed = 1;
			failed = 1;
		end
		
		$display("Back-to-back ciphertext test finished : %s", (back_to_back_failed)? "FAILED" : "PASSED");
		`WAIT_N_CLK(2);
		
		// ECB-AES256.Decrypt sample vector test. SP800-38a appendix F.1.6
		
		$display("\nECB-AES256.Decrypt sample vector test");
		for (int k=0; k<`ECB_DECRYPT_256_VEC_SIZE; k++)
		begin
			set_kt(ECBDecrypt_256_kt);
			wait(ct_rdy);
			set_ct(ECBDecrypt_256_ct[k]);
			wait(pt_vld);
			$display("kt=%h ct=%h pt=%h expected=%h",ECBDecrypt_256_kt,ECBDecrypt_256_ct[k],pt,ECBDecrypt_256_pt[k]);
			if (pt != ECBDecrypt_256_pt[k])
			begin
				$display("***Mismatch");
				ECBDecrypt_256_failed = 1;
			end
		end
		
		$display("ECB-AES192.Decrypt sample vector test finished : %s", (ECBDecrypt_256_failed)? "FAILED" : "PASSED");
		`WAIT_N_CLK(2);
		
		// GFSbox Known Answer Test. AESAVS appendix B.3.
		
		$display("\nGFSbox Known Answer Test");
		for (int k=0; k<`GFSbox_256_VEC_SIZE; k++)
		begin
			set_kt(GFSbox_256_kt);
			wait(ct_rdy);
			set_ct(GFSbox_256_ct[k]);
			wait(pt_vld);
			$display("kt=%h ct=%h pt=%h expected=%h",GFSbox_256_kt,GFSbox_256_ct[k],pt,GFSbox_256_pt[k]);
			if (pt != GFSbox_256_pt[k])
			begin
				$display("***Mismatch");
				GFSbox_256_failed = 1;
			end
		end
		
		$display("GFSbox test finished : %s", (GFSbox_256_failed)? "FAILED" : "PASSED");
		`WAIT_N_CLK(2);
		
		// KeySbox Known Answer Test. AESAVS appendix C.3.
		
		$display("\nKeySbox Known Answer Test");
		for (int k=0; k<`KEYSBOX_256_VEC_SIZE; k++)
		begin
			set_kt(KeySbox_256_kt[k]);
			wait(ct_rdy);
			set_ct(KeySbox_256_ct[k]);
			wait(pt_vld);
			$display("kt=%h ct=%h pt=%h expected=%h",KeySbox_256_kt[k],KeySbox_256_ct[k],pt,KeySbox_256_pt);
			if (pt != KeySbox_256_pt[k])
			begin
				$display("***Mismatch");
				KeySbox_256_failed = 1;
			end
		end
		
		$display("KeySbox test finished : %s", (KeySbox_256_failed)? "FAILED" : "PASSED");
		`WAIT_N_CLK(2);
		
		// VarTxt Known Answer Test. AESAVS appendix D.3.
		
		$display("\nVarTxt Known Answer Test");
		for (int k=0; k<`VARTXT_256_VEC_SIZE; k++)
		begin
			set_kt(VarTxt_256_kt);
			wait(ct_rdy);
			set_ct(VarTxt_256_ct[k]);
			wait(pt_vld);
			$display("kt=%h ct=%h pt=%h expected=%h",VarTxt_256_kt,VarTxt_256_ct[k],pt,VarTxt_256_pt[k]);
			if (pt != VarTxt_256_pt[k])
			begin
				$display("***Mismatch");
				VarTxt_256_failed = 1;
			end
		end
		
		$display("VarTxt Known Answer Test finished : %s", (VarTxt_256_failed)? "FAILED" : "PASSED");
		`WAIT_N_CLK(2);
		
		// VarKey Known Answer Test. AESAVS appendix E.3.
		
		$display("\nVarKey Known Answer Test");
		for (int k=0; k<`VARKEY_256_VEC_SIZE; k++)
		begin
			set_kt(VarKey_256_kt[k]);
			wait(ct_rdy);
			set_ct(VarKey_256_ct[k]);
			wait(pt_vld);
			$display("kt=%h ct=%h pt=%h expected=%h",VarKey_256_kt[k],VarKey_256_ct[k],pt,VarKey_256_pt);
			if (pt != VarKey_256_pt)
			begin
				$display("***Mismatch");
				VarKey_256_failed = 1;
			end
		end
		
		$display("VarKey Known Answer Test finished : %s", (VarKey_256_failed)? "FAILED" : "PASSED");
		`WAIT_N_CLK(2);
		
		// Random vector test against golden model.
		
		$display("\nRandom Vector Test");
		for (int k=0; k<1000; k++)
		begin
			tmp_ct = rand128();
			tmp_kt = rand256();
			ref_model.KeyExpand(tmp_kt);
			ref_model.LoadCt(tmp_ct);
			ref_model.run(0);
		
			wait (kt_rdy);
			set_kt(tmp_kt);
			wait (ct_rdy);
			set_ct(tmp_ct);
			wait (pt_vld);
			$display("kt=%h ct=%h pt=%h expected=%h",tmp_kt,tmp_ct,pt,ref_model.GetState());
			if (pt != ref_model.GetState())
			begin
				$display("***Mismatch");
				RandVec_256_failed = 1;
			failed = 1;
			end
		end
		
		$display("Random Vector Test finished : %s", (RandVec_256_failed)? "FAILED" : "PASSED");
		`WAIT_N_CLK(2);
		
		$display("\nAll tests finished : %s", (failed)? "FAILED" : "OK");
		
		$stop;
	end

endmodule
