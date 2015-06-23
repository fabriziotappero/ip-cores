////////////////////////////////////////////////////////////////////////
////																////
//// This file is part of the AES SystemVerilog Behavioral			////
//// Model project													////
//// http://www.opencores.org/cores/aes_beh_model/					////
////																////
//// Description													////
//// Implementation of AES SystemVerilog Behavioral					////
//// Model according to AES Behavioral Model specification document.////
////																////
//// To Do:															////
//// -																////
////																////
//// Author(s):														////
//// - scheng, schengopencores@opencores.org						////
////																////
////////////////////////////////////////////////////////////////////////
////																////
//// Copyright (C) 2009 Authors and OPENCORES.ORG					////
////																////
//// This source file may be used and distributed without			////
//// restriction provided that this copyright statement is not		////
//// removed from the file and that any derivative work contains	////
//// the original copyright notice and the associated disclaimer.	////
////																////
//// This source file is free software; you can redistribute it		////
//// and/or modify it under the terms of the GNU Lesser General		////
//// Public License as published by the Free Software Foundation;	////
//// either version 2.1 of the License, or (at your option) any		////
//// later version.													////
////																////
//// This source is distributed in the hope that it will be			////
//// useful, but WITHOUT ANY WARRANTY; without even the implied		////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR		////
//// PURPOSE. See the GNU Lesser General Public License for more	////
//// details.														////
////																////
//// You should have received a copy of the GNU Lesser General		////
//// Public License along with this source; if not, download it		////
//// from http://www.opencores.org/lgpl.shtml 						////
//// 																////
////////////////////////////////////////////////////////////////////////

// This is a testbench for verification of the aes encryption model against
// selected test vectors in FIPS-197, SP800-38a, and AESAVS. 128/192/256-bit
// encryption models are tested. Each model is tested with the following
// vectors
//
// - FIPS-197 sample vector test. FIPS-197 appendix C.
// - ECB-AES128/192/256.Encrypt sample vector test. SP800-38a appendix F.
// - GFSbox Known Answer Test vectors. AESAVS appendix B.
// - KeySbox Known Answer Test. AESAVS appendix C.
// - VarTxt Known Answer Test. AESAVS appendix D.
// - VarKey Known Answer Test. AESAVS appendix E.

module aes_beh_model_encrypt_tb;

	// Include source file for AES behavioral model
	`include "aes_beh_model.sv"
	
	aes128_encrypt_t encrypt128;
	aes192_encrypt_t encrypt192;
	aes256_encrypt_t encrypt256;
	
	logic	[0:127] ct;

	// Test vector file
	`include "aes_vec.sv"

	initial
	begin
		//--------------------------------------------------------------------------------
		//
		// Start of 128-bit model test
		//
		//--------------------------------------------------------------------------------
		
		encrypt128 = new;
		
		// FIPS-197 128-bit Sample Vector Test
		// FIPS-197 appendix C.1
		$display("\nFIPS-197 128-bit Sample Vector Test");
		for (int k=0; k<`FIPS197_128_VEC_SIZE; k++)
		begin
			encrypt128.KeyExpand(FIPS197_128_kt[k]);
			encrypt128.LoadPt(FIPS197_128_pt[k]);
			encrypt128.run(0);
			ct = encrypt128.GetState();
			$display("kt=%h pt=%h ct=%h expected=%h",FIPS197_128_kt[k],FIPS197_128_pt[k],ct,FIPS197_128_ct[k]);
			if (ct != FIPS197_128_ct[k])
			begin
				$display("***Mismatch");
				$stop;
			end
		end
		$display("FIPS-197 128-bit Sample Vector Test finished");
		
		// ECB-AES128.Encrypt sample vector test
		// SP800-38a appendix F.1.1
		$display("\nECB-AES128.Encrypt sample vector test");
		for (int k=0; k<`ECB_ENCRYPT_128_VEC_SIZE; k++)
		begin
			encrypt128.KeyExpand(ECBEncrypt_128_kt);
			encrypt128.LoadPt(ECBEncrypt_128_pt[k]);
			encrypt128.run(0);
			ct = encrypt128.GetState();
			$display("kt=%h pt=%h ct=%h expected=%h",ECBEncrypt_128_kt,ECBDecrypt_128_pt[k],ct,ECBDecrypt_128_ct[k]);
			if (ct != ECBEncrypt_128_ct[k])
			begin
				$display("***Mismatch");
				$stop;
			end
		end
		$display("ECB-AES128.Encrypt sample vector test finished");
		
		// 128-bit GFSbox Known Answer Test vectors.
		// AESAVS appendix B.1
		$display("\n128-bit GFSbox Known Answer Test");
		for (int k=0; k<`GFSbox_128_VEC_SIZE; k++)
		begin
			encrypt128.KeyExpand(GFSbox_128_kt);
			encrypt128.LoadPt(GFSbox_128_pt[k]);
			encrypt128.run(0);
			ct = encrypt128.GetState();
			$display("kt=%h pt=%h ct=%h expected=%h",GFSbox_128_kt,GFSbox_128_pt[k],ct,GFSbox_128_ct[k]);
			if (ct != GFSbox_128_ct[k])
			begin
				$display("***Mismatch");
				$stop;
			end
		end
		$display("128-bit GFSbox Known Answer Test finished");
		
		// KeySbox Known Answer Test. AESAVS appendix C.1.		
		$display("\n128-bit KeySbox Known Answer Test");
		for (int k=0; k<`KEYSBOX_128_VEC_SIZE; k++)
		begin
			encrypt128.KeyExpand(KeySbox_128_kt[k]);
			encrypt128.LoadPt(KeySbox_128_pt);
			encrypt128.run(0);
			ct = encrypt128.GetState();
			$display("kt=%h pt=%h ct=%h expected=%h",KeySbox_128_kt[k],KeySbox_128_pt,ct,KeySbox_128_ct[k]);
			if (ct != KeySbox_128_ct[k])
			begin
				$display("***Mismatch");
				$stop;
			end
		end
		$display("128-bit KeySbox Known Answer Test finished");
		
		// VarTxt Known Answer Test. AESAVS appendix D.1.		
		$display("\n128-bit VarTxt Known Answer Test");
		for (int k=0; k<`VARTXT_128_VEC_SIZE; k++)
		begin
			encrypt128.KeyExpand(VarTxt_128_kt);
			encrypt128.LoadPt(VarTxt_128_pt[k]);
			encrypt128.run(0);
			ct = encrypt128.GetState();
			$display("kt=%h pt=%h ct=%h expected=%h",VarTxt_128_kt,VarTxt_128_pt[k],ct,VarTxt_128_ct[k]);
			if (ct != VarTxt_128_ct[k])
			begin
				$display("***Mismatch");
				$stop;
			end
		end
		$display("128-bit VarTxt Known Answer Test finished");
		
		// VarKey Known Answer Test. AESAVS appendix E.1.		
		$display("\n128-bit VarKey Known Answer Test");
		for (int k=0; k<`VARKEY_128_VEC_SIZE; k++)
		begin
			encrypt128.KeyExpand(VarKey_128_kt[k]);
			encrypt128.LoadPt(VarKey_128_pt);
			encrypt128.run(0);
			ct = encrypt128.GetState();
			$display("kt=%h pt=%h ct=%h expected=%h",VarKey_128_kt[k],VarKey_128_pt[k],ct,VarKey_128_ct[k]);
			if (ct != VarKey_128_ct[k])
			begin
				$display("***Mismatch");
				$stop;
			end
		end
		$display("128-bit VarKey Known Answer Test finished");
		
		//--------------------------------------------------------------------------------
		//
		// Start of 192-bit model test
		//
		//--------------------------------------------------------------------------------
		
		encrypt192 = new;
		
		// FIPS-197 192-bit Sample Vector Test
		// FIPS-197 appendix C.2
		$display("\nFIPS-197 192-bit Sample Vector Test");
		for (int k=0; k<`FIPS197_192_VEC_SIZE; k++)
		begin
			encrypt192.KeyExpand(FIPS197_192_kt[k]);
			encrypt192.LoadPt(FIPS197_192_pt[k]);
			encrypt192.run(0);
			ct = encrypt192.GetState();
			$display("kt=%h pt=%h ct=%h expected=%h",FIPS197_192_kt[k],FIPS197_192_pt[k],ct,FIPS197_192_ct[k]);
			if (ct != FIPS197_192_ct[k])
			begin
				$display("***Mismatch");
				$stop;
			end
		end
		$display("FIPS-197 192-bit Sample Vector Test finished");
		
		// ECB-AES192.Encrypt sample vector test
		// SP800-38a appendix F.1.3
		$display("\nECB-AES192.Encrypt sample vector test");
		for (int k=0; k<`ECB_ENCRYPT_192_VEC_SIZE; k++)
		begin
			encrypt192.KeyExpand(ECBEncrypt_192_kt);
			encrypt192.LoadPt(ECBEncrypt_192_pt[k]);
			encrypt192.run(0);
			ct = encrypt192.GetState();
			$display("kt=%h pt=%h ct=%h expected=%h",ECBDecrypt_192_kt,ECBDecrypt_192_pt[k],ct,ECBDecrypt_192_ct[k]);
			if (ct != ECBEncrypt_192_ct[k])
			begin
				$display("***Mismatch");
				$stop;
			end
		end
		$display("ECB-AES192.Encrypt sample vector test finished");
		
		// 192-bit GFSbox Known Answer Test vectors.
		// AESAVS appendix B.2
		$display("\n192-bit GFSbox Known Answer Test");
		for (int k=0; k<`GFSbox_192_VEC_SIZE; k++)
		begin
			encrypt192.KeyExpand(GFSbox_192_kt);
			encrypt192.LoadPt(GFSbox_192_pt[k]);
			encrypt192.run(0);
			ct = encrypt192.GetState();
			$display("kt=%h pt=%h ct=%h expected=%h",GFSbox_192_kt,GFSbox_192_pt[k],ct,GFSbox_192_ct[k]);
			if (ct != GFSbox_192_ct[k])
			begin
				$display("***Mismatch");
				$stop;
			end
		end
		$display("192-bit GFSbox Known Answer Test finished");
		
		// 192-bit KeySbox Known Answer Test. AESAVS appendix C.2.		
		$display("\n192-bit KeySbox Known Answer Test");
		for (int k=0; k<`KEYSBOX_192_VEC_SIZE; k++)
		begin
			encrypt192.KeyExpand(KeySbox_192_kt[k]);
			encrypt192.LoadPt(KeySbox_192_pt);
			encrypt192.run(0);
			ct = encrypt192.GetState();
			$display("kt=%h pt=%h ct=%h expected=%h",KeySbox_192_kt[k],KeySbox_192_pt,ct,KeySbox_192_ct[k]);
			if (ct != KeySbox_192_ct[k])
			begin
				$display("***Mismatch");
				$stop;
			end
		end
		$display("192-bit KeySbox Known Answer Test finished");
		
		// 192-bit VarTxt Known Answer Test. AESAVS appendix D.2.		
		$display("\n192-bit VarTxt Known Answer Test");
		for (int k=0; k<`VARTXT_192_VEC_SIZE; k++)
		begin
			encrypt192.KeyExpand(VarTxt_192_kt);
			encrypt192.LoadPt(VarTxt_192_pt[k]);
			encrypt192.run(0);
			ct = encrypt192.GetState();
			$display("kt=%h pt=%h ct=%h expected=%h",VarTxt_192_kt,VarTxt_192_pt[k],ct,VarTxt_192_ct[k]);
			if (ct != VarTxt_192_ct[k])
			begin
				$display("***Mismatch");
				$stop;
			end
		end
		$display("192-bit VarTxt Known Answer Test finished");
		
		// 192-bit VarKey Known Answer Test. AESAVS appendix E.2.		
		$display("\n192-bit VarKey Known Answer Test");
		for (int k=0; k<`VARKEY_192_VEC_SIZE; k++)
		begin
			encrypt192.KeyExpand(VarKey_192_kt[k]);
			encrypt192.LoadPt(VarKey_192_pt);
			encrypt192.run(0);
			ct = encrypt192.GetState();
			$display("kt=%h pt=%h ct=%h expected=%h",VarKey_192_kt[k],VarKey_192_pt,ct,VarKey_192_ct[k]);
			if (ct != VarKey_192_ct[k])
			begin
				$display("***Mismatch");
				$stop;
			end
		end
		$display("192-bit VarKey Known Answer Test finished");
		
		//--------------------------------------------------------------------------------
		//
		// Start of 256-bit model test
		//
		//--------------------------------------------------------------------------------
		
		encrypt256 = new;
		
		// FIPS-197 256-bit Sample Vector Test
		// FIPS-197 appendix C.3
		$display("\nFIPS-197 256-bit Sample Vector Test");
		for (int k=0; k<`FIPS197_256_VEC_SIZE; k++)
		begin
			encrypt256.KeyExpand(FIPS197_256_kt[k]);
			encrypt256.LoadPt(FIPS197_256_pt[k]);
			encrypt256.run(0);
			ct = encrypt256.GetState();
			$display("kt=%h pt=%h ct=%h expected=%h",FIPS197_256_kt[k],FIPS197_256_pt[k],ct,FIPS197_256_ct[k]);
			if (ct != FIPS197_256_ct[k])
			begin
				$display("***Mismatch");
				$stop;
			end
		end
		$display("FIPS-197 256-bit Sample Vector Test finished");
		
		// ECB-AES256.Encrypt sample vector test
		// SP800-38a appendix F.1.5
		$display("\nECB-AES256.Encrypt sample vector test");
		for (int k=0; k<`ECB_ENCRYPT_256_VEC_SIZE; k++)
		begin
			encrypt256.KeyExpand(ECBEncrypt_256_kt);
			encrypt256.LoadPt(ECBEncrypt_256_pt[k]);
			encrypt256.run(0);
			ct  = encrypt256.GetState();
			$display("kt=%h pt=%h ct=%h expected=%h",ECBDecrypt_256_kt,ECBDecrypt_256_pt[k],ct,ECBDecrypt_256_ct[k]);
			if (ct != ECBDecrypt_256_ct[k])
			begin
				$display("***Mismatch");
				$stop;
			end
		end
		$display("ECB-AES256.Encrypt sample vector test finished");
		
		// 256-bit GFSbox Known Answer Test vectors.
		// AESAVS appendix B.2
		$display("\n256-bit GFSbox Known Answer Test");
		for (int k=0; k<`GFSbox_256_VEC_SIZE; k++)
		begin
			encrypt256.KeyExpand(GFSbox_256_kt);
			encrypt256.LoadPt(GFSbox_256_pt[k]);
			encrypt256.run(0);
			ct  = encrypt256.GetState();
			$display("kt=%h pt=%h ct=%h expected=%h",GFSbox_256_kt,GFSbox_256_pt[k],ct,GFSbox_256_ct[k]);
			if (ct != GFSbox_256_ct[k])
			begin
				$display("***Mismatch");
				$stop;
			end
		end
		$display("256-bit GFSbox Known Answer Test finished");
		
		// 256-bit KeySbox Known Answer Test. AESAVS appendix C.2.		
		$display("\n256-bit KeySbox Known Answer Test");
		for (int k=0; k<`KEYSBOX_256_VEC_SIZE; k++)
		begin
			encrypt256.KeyExpand(KeySbox_256_kt[k]);
			encrypt256.LoadPt(KeySbox_256_pt);
			encrypt256.run(0);
			ct  = encrypt256.GetState();
			$display("kt=%h pt=%h ct=%h expected=%h",KeySbox_256_kt[k],KeySbox_256_pt,ct,KeySbox_256_ct[k]);
			if (ct != KeySbox_256_ct[k])
			begin
				$display("***Mismatch");
				$stop;
			end
		end
		$display("256-bit KeySbox Known Answer Test finished");
		
		// 256-bit VarTxt Known Answer Test. AESAVS appendix D.2.		
		$display("\n256-bit VarTxt Known Answer Test");
		for (int k=0; k<`VARTXT_256_VEC_SIZE; k++)
		begin
			encrypt256.KeyExpand(VarTxt_256_kt);
			encrypt256.LoadPt(VarTxt_256_pt[k]);
			encrypt256.run(0);
			ct  = encrypt256.GetState();
			$display("kt=%h pt=%h ct=%h expected=%h",VarTxt_256_kt,VarTxt_256_pt[k],ct,VarTxt_256_ct[k]);
			if (ct != VarTxt_256_ct[k])
			begin
				$display("***Mismatch");
				$stop;
			end
		end
		$display("256-bit VarTxt Known Answer Test finished");
		
		// 256-bit VarKey Known Answer Test. AESAVS appendix E.2.		
		$display("\n256-bit VarKey Known Answer Test");
		for (int k=0; k<`VARKEY_256_VEC_SIZE; k++)
		begin
			encrypt256.KeyExpand(VarKey_256_kt[k]);
			encrypt256.LoadPt(VarKey_256_pt);
			encrypt256.run(0);
			ct  = encrypt256.GetState();
			$display("kt=%h pt=%h ct=%h expected=%h",VarKey_256_kt[k],VarKey_256_pt,ct,VarKey_256_ct[k]);
			if (ct != VarKey_256_ct[k])
			begin
				$display("***Mismatch");
				$stop;
			end
		end
		$display("256-bit VarKey Known Answer Test finished");
	end
endmodule
