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

// This is a testbench for verification of the aes descryption model against
// selected test vectors in FIPS-197, SP800-38a, and AESAVS. 128/192/256-bit
// decryption models are tested. Each model is tested with the following
// vectors
//
// - FIPS-197 sample vector test. FIPS-197 appendix C.
// - ECB-AES128/192/256.Decrypt sample vector test. SP800-38a appendix F.
// - GFSbox Known Answer Test vectors. AESAVS appendix B.
// - KeySbox Known Answer Test. AESAVS appendix C.
// - VarTxt Known Answer Test. AESAVS appendix D.
// - VarKey Known Answer Test. AESAVS appendix E.

module aes_beh_model_decrypt_tb;

	// Include source file for AES behavioral model
	`include "aes_beh_model.sv"
	
	aes128_decrypt_t decrypt128;
	aes192_decrypt_t decrypt192;
	aes256_decrypt_t decrypt256;
	
	logic	[0:127] pt;

	// Test vector file
	`include "aes_vec.sv"

	initial
	begin
		//--------------------------------------------------------------------------------
		//
		// Start of 128-bit model test
		//
		//--------------------------------------------------------------------------------
		
		decrypt128 = new;
		
		// FIPS-197 128-bit Sample Vector Test
		// FIPS-197 appendix C.1
		$display("\nFIPS-197 128-bit Sample Vector Test");
		for (int k=0; k<`FIPS197_128_VEC_SIZE; k++)
		begin
			decrypt128.KeyExpand(FIPS197_128_kt[k]);
			decrypt128.LoadCt(FIPS197_128_ct[k]);
			decrypt128.run(0);
			pt = decrypt128.GetState();
			$display("kt=%h ct=%h pt=%h expected=%h",FIPS197_128_kt[k],FIPS197_128_ct[k],pt,FIPS197_128_pt[k]);
			if (pt != FIPS197_128_pt[k])
			begin
				$display("***Mismatch");
				$stop;
			end
		end
		$display("FIPS-197 128-bit Sample Vector Test finished");
		
		// ECB-AES128.Decrypt sample vector test
		// SP800-38a appendix F.1.2
		$display("\nECB-AES128.Decrypt sample vector test");
		for (int k=0; k<`ECB_DECRYPT_128_VEC_SIZE; k++)
		begin
			decrypt128.KeyExpand(ECBDecrypt_128_kt);
			decrypt128.LoadCt(ECBDecrypt_128_ct[k]);
			decrypt128.run(0);
			pt = decrypt128.GetState();
			$display("kt=%h ct=%h pt=%h expected=%h",ECBDecrypt_128_kt,ECBDecrypt_128_ct[k],pt,ECBDecrypt_128_pt[k]);
			if (pt != ECBDecrypt_128_pt[k])
			begin
				$display("***Mismatch");
				$stop;
			end
		end
		$display("ECB-AES128.Decrypt sample vector test finished");
		
		// 128-bit GFSbox Known Answer Test vectors.
		// AESAVS appendix B.1
		$display("\n128-bit GFSbox Known Answer Test");
		for (int k=0; k<`GFSbox_128_VEC_SIZE; k++)
		begin
			decrypt128.KeyExpand(GFSbox_128_kt);
			decrypt128.LoadCt(GFSbox_128_ct[k]);
			decrypt128.run(0);
			pt = decrypt128.GetState();
			$display("kt=%h ct=%h pt=%h expected=%h",GFSbox_128_kt,GFSbox_128_ct[k],pt,GFSbox_128_pt[k]);
			if (pt != GFSbox_128_pt[k])
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
			decrypt128.KeyExpand(KeySbox_128_kt[k]);
			decrypt128.LoadCt(KeySbox_128_ct[k]);
			decrypt128.run(0);
			pt = decrypt128.GetState();
			$display("kt=%h ct=%h pt=%h expected=%h",KeySbox_128_kt[k],KeySbox_128_ct[k],pt,KeySbox_128_pt);
			if (pt != KeySbox_128_pt)
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
			decrypt128.KeyExpand(VarTxt_128_kt);
			decrypt128.LoadCt(VarTxt_128_ct[k]);
			decrypt128.run(0);
			pt = decrypt128.GetState();
			$display("kt=%h ct=%h pt=%h expected=%h",VarTxt_128_kt,VarTxt_128_ct[k],pt,VarTxt_128_pt[k]);
			if (pt != VarTxt_128_pt[k])
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
			decrypt128.KeyExpand(VarKey_128_kt[k]);
			decrypt128.LoadCt(VarKey_128_ct[k]);
			decrypt128.run(0);
			pt = decrypt128.GetState();
			$display("kt=%h ct=%h pt=%h expected=%h",VarKey_128_kt[k],VarKey_128_ct[k],pt,VarKey_128_pt);
			if (pt != VarKey_128_pt)
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
		
		decrypt192 = new;
		
		// FIPS-197 192-bit Sample Vector Test
		// FIPS-197 appendix C.2
		$display("\nFIPS-197 192-bit Sample Vector Test");
		for (int k=0; k<`FIPS197_192_VEC_SIZE; k++)
		begin
			decrypt192.KeyExpand(FIPS197_192_kt[k]);
			decrypt192.LoadCt(FIPS197_192_ct[k]);
			decrypt192.run(0);
			pt = decrypt192.GetState();
			$display("kt=%h ct=%h pt=%h expected=%h",FIPS197_192_kt[k],FIPS197_192_ct[k],pt,FIPS197_192_pt[k]);
			if (pt != FIPS197_192_pt[k])
			begin
				$display("***Mismatch");
				$stop;
			end
		end
		$display("FIPS-197 192-bit Sample Vector Test finished");
		
		// ECB-AES192.Decrypt sample vector test
		// SP800-38a appendix F.1.4
		$display("\nECB-AES192.Decrypt sample vector test");
		for (int k=0; k<`ECB_DECRYPT_192_VEC_SIZE; k++)
		begin
			decrypt192.KeyExpand(ECBDecrypt_192_kt);
			decrypt192.LoadCt(ECBDecrypt_192_ct[k]);
			decrypt192.run(0);
			pt = decrypt192.GetState();
			$display("kt=%h ct=%h pt=%h expected=%h",ECBDecrypt_192_kt,ECBDecrypt_192_ct[k],pt,ECBDecrypt_192_pt[k]);
			if (pt != ECBDecrypt_192_pt[k])
			begin
				$display("***Mismatch");
				$stop;
			end
		end
		$display("ECB-AES192.Decrypt sample vector test finished");
		
		// 192-bit GFSbox Known Answer Test vectors.
		// AESAVS appendix B.2
		$display("\n192-bit GFSbox Known Answer Test");
		for (int k=0; k<`GFSbox_192_VEC_SIZE; k++)
		begin
			decrypt192.KeyExpand(GFSbox_192_kt);
			decrypt192.LoadCt(GFSbox_192_ct[k]);
			decrypt192.run(0);
			pt = decrypt192.GetState();
			$display("kt=%h ct=%h pt=%h expected=%h",GFSbox_192_kt,GFSbox_192_ct[k],pt,GFSbox_192_pt[k]);
			if (pt != GFSbox_192_pt[k])
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
			decrypt192.KeyExpand(KeySbox_192_kt[k]);
			decrypt192.LoadCt(KeySbox_192_ct[k]);
			decrypt192.run(0);
			pt = decrypt192.GetState();
			$display("kt=%h ct=%h pt=%h expected=%h",KeySbox_192_kt[k],KeySbox_192_ct[k],pt,KeySbox_192_pt);
			if (pt != KeySbox_192_pt)
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
			decrypt192.KeyExpand(VarTxt_192_kt);
			decrypt192.LoadCt(VarTxt_192_ct[k]);
			decrypt192.run(0);
			pt = decrypt192.GetState();
			$display("kt=%h ct=%h pt=%h expected=%h",VarTxt_192_kt,VarTxt_192_ct[k],pt,VarTxt_192_pt[k]);
			if (pt != VarTxt_192_pt[k])
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
			decrypt192.KeyExpand(VarKey_192_kt[k]);
			decrypt192.LoadCt(VarKey_192_ct[k]);
			decrypt192.run(0);
			pt = decrypt192.GetState();
			$display("kt=%h ct=%h pt=%h expected=%h",VarKey_192_kt[k],VarKey_192_ct[k],pt,VarKey_192_pt);
			if (pt != VarKey_192_pt)
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
		
		decrypt256 = new;
		
		// FIPS-197 256-bit Sample Vector Test
		// FIPS-197 appendix C.3
		$display("\nFIPS-197 256-bit Sample Vector Test");
		for (int k=0; k<`FIPS197_256_VEC_SIZE; k++)
		begin
			decrypt256.KeyExpand(FIPS197_256_kt[k]);
			decrypt256.LoadCt(FIPS197_256_ct[k]);
			decrypt256.run(0);
			pt = decrypt256.GetState();
			$display("kt=%h ct=%h pt=%h expected=%h",FIPS197_256_kt[k],FIPS197_256_ct[k],pt,FIPS197_256_pt[k]);
			if (pt != FIPS197_256_pt[k])
			begin
				$display("***Mismatch");
				$stop;
			end
		end
		$display("FIPS-197 256-bit Sample Vector Test finished");
		
		// ECB-AES256.Decrypt sample vector test
		// SP800-38a appendix F.1.4
		$display("\nECB-AES256.Decrypt sample vector test");
		for (int k=0; k<`ECB_DECRYPT_256_VEC_SIZE; k++)
		begin
			decrypt256.KeyExpand(ECBDecrypt_256_kt);
			decrypt256.LoadCt(ECBDecrypt_256_ct[k]);
			decrypt256.run(0);
			pt = decrypt256.GetState();
			$display("kt=%h ct=%h pt=%h expected=%h",ECBDecrypt_256_kt,ECBDecrypt_256_ct[k],pt,ECBDecrypt_256_pt[k]);
			if (pt != ECBDecrypt_256_pt[k])
			begin
				$display("***Mismatch");
				$stop;
			end
		end
		$display("ECB-AES256.Decrypt sample vector test finished");
		
		// 256-bit GFSbox Known Answer Test vectors.
		// AESAVS appendix B.2
		$display("\n256-bit GFSbox Known Answer Test");
		for (int k=0; k<`GFSbox_256_VEC_SIZE; k++)
		begin
			decrypt256.KeyExpand(GFSbox_256_kt);
			decrypt256.LoadCt(GFSbox_256_ct[k]);
			decrypt256.run(0);
			pt = decrypt256.GetState();
			$display("kt=%h ct=%h pt=%h expected=%h",GFSbox_256_kt,GFSbox_256_ct[k],pt,GFSbox_256_pt[k]);
			if (pt != GFSbox_256_pt[k])
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
			decrypt256.KeyExpand(KeySbox_256_kt[k]);
			decrypt256.LoadCt(KeySbox_256_ct[k]);
			decrypt256.run(0);
			pt = decrypt256.GetState();
			$display("kt=%h ct=%h pt=%h expected=%h",KeySbox_256_kt[k],KeySbox_256_ct[k],pt,KeySbox_256_pt);
			if (pt != KeySbox_256_pt)
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
			decrypt256.KeyExpand(VarTxt_256_kt);
			decrypt256.LoadCt(VarTxt_256_ct[k]);
			decrypt256.run(0);
			pt = decrypt256.GetState();
			$display("kt=%h ct=%h pt=%h expected=%h",VarTxt_256_kt,VarTxt_256_ct[k],pt,VarTxt_256_pt[k]);
			if (pt != VarTxt_256_pt[k])
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
			decrypt256.KeyExpand(VarKey_256_kt[k]);
			decrypt256.LoadCt(VarKey_256_ct[k]);
			decrypt256.run(0);
			pt = decrypt256.GetState();
			$display("kt=%h ct=%h pt=%h expected=%h",VarKey_256_kt[k],VarKey_256_ct[k],pt,VarKey_256_pt);
			if (pt != VarKey_256_pt)
			begin
				$display("***Mismatch");
				$stop;
			end
		end
		$display("256-bit VarKey Known Answer Test finished");
	end
endmodule
