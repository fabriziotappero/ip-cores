//////////////////////////////////////////////////////////////////////
////                                                              ////
////  XTEA IP Core                                                ////
////                                                              ////
////  This file is part of the xtea project                       ////
////  http://www.opencores.org/projects.cgi/web/xtea/overview     ////
////                                                              ////
////  Test-bench for the XTEA encryption algorithm.               ////
////                                                              ////
////  TODO:                                                       ////
////    * Update for new combined encipher/decipher module        ////
////    * Tidy                                                    ////
////    * Add interconnections                                    ////
////                                                              ////
////  Author: David Johnson, dj@david-web.co.uk                   ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2006 David Johnson                             ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, write to the  ////
//// Free Software Foundation, Inc., 51 Franklin Street, Fifth    ////
//// Floor, Boston, MA  02110-1301  USA                           ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
//

module cipher_testbench (clock, reset, all_done_encipher, all_done_decipher, data_out_encipher1, data_out_encipher2, data_out_decipher1, data_out_decipher2, data_in_encipher1, data_in_encipher2, data_in_decipher1, data_in_decipher2, key_out, result, reset_out);

input clock, reset, all_done_encipher, all_done_decipher;
input[31:0] data_in_encipher1, data_in_encipher2, data_in_decipher1, data_in_decipher2;
output result, reset_out;
output[31:0] data_out_encipher1, data_out_encipher2, data_out_decipher1, data_out_decipher2;
output[127:0] key_out;

reg result, reset_out, test_ciphertext, test_plaintext;
reg[7:0] state;
reg[31:0] data_out_encipher1, data_out_encipher2, data_out_decipher1, data_out_decipher2, tempdata1, tempdata2;
reg[127:0] key_out;

parameter s0 = 0, s1 = 1, s2 = 2, s3 = 3, s4 = 4, s5 = 5, s6 = 6, s7 = 7, s8 = 8, s9 = 9,
	s10 = 10, s11 = 11, s12 = 12, s13 = 13, s14 = 14, s15 = 15, s16 = 16, s17 = 17, s18 = 18, s19 = 19,
	s20 = 20, s21 = 21, s22 = 22, s23 = 23, s24 = 24, s25 = 25, s26 = 26, s27 = 27, s28 = 28, s29 = 29,
	s30 = 30, s31 = 31, s32 = 32, s33 = 33, s34 = 34, s35 = 35, s36 = 36, s37 = 37, s38 = 38, s39 = 39,
	s40 = 40, s41 = 41, s42 = 42, s43 = 43, s44 = 44, s45 = 45, s46 = 46, s47 = 47, s48 = 48, s49 = 49;

always @(posedge clock or posedge reset)
begin
	if (reset)
		state = s0;
	else
	begin
		case (state)
			s0: state = s1;
			s1: state = s2;
			s2: state = all_done_encipher ? s3 : s2;
			s3: state = s4;
			s4: state = s5;
			s5: state = all_done_decipher ? s6 : s5;
			s6: state = s7;
			s7: state = s8;
			s8: state = s9;
			s9: state = all_done_encipher ? s10 : s9;
			s10: state = s11;
			s11: state = s12;
			s12: state = all_done_decipher ? s13 : s12;
			s13: state = s14;
			s14: state = s15;
			s15: state = s16;
			s16: state = all_done_encipher ? s17 : s16;
			s17: state = s18;
			s18: state = s19;
			s19: state = all_done_decipher ? s20 : s19;
			s20: state = s21;
			s21: state = s22;
			s22: state = s23;
			s23: state = all_done_encipher ? s24 : s23;
			s24: state = s25;
			s25: state = s26;
			s26: state = all_done_decipher ? s27 : s26;
			s27: state = s28;
			s28: state = s29;
			s29: state = s30;
			s30: state = all_done_encipher ? s31 : s30;
			s31: state = s32;
			s32: state = s33;
			s33: state = all_done_decipher ? s34 : s33;
			s34: state = s35;
			s35: state = s36;
			s36: state = s37;
			s37: state = all_done_encipher ? s38 : s37;
			s38: state = s39;
			s39: state = s40;
			s40: state = all_done_decipher ? s41 : s40;
			s41: state = s42;
			s42: state = s43;
			s43: state = s44;
			s44: state = all_done_encipher ? s45 : s44;
			s45: state = s46;
			s46: state = s47;
			s47: state = all_done_decipher ? s48 : s47;
			s48: state = s49;
			s49: state = s49;
			default: state = 1'bz;
		endcase
	end
end

always @(posedge clock or posedge reset)
begin
	if (reset)
	begin
		result = 1'b0;
		reset_out = 1'b0;
		test_ciphertext = 1'b0;
		test_plaintext = 1'b0;
		data_out_encipher1 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
		data_out_encipher2 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
		data_out_decipher1 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
		data_out_decipher2 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
		key_out = 128'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	end
	else begin
		case (state)
			//Test 1
			s1: begin
			    reset_out = 1'b1;
			    data_out_encipher1 = 32'h00000000;
			    data_out_encipher2 = 32'h00000000;
			    key_out = 128'h00000000000000000000000000000000;
			    end
			s2: reset_out = 1'b0;
			s3: begin
			test_ciphertext = ((data_in_encipher1 == 32'hdee9d4d8) && (data_in_encipher2 == 32'hf7131ed9));
			tempdata1 = data_in_encipher1;
			tempdata2 = data_in_encipher2;
			end
			s4: begin
			reset_out = 1'b1;
			data_out_decipher1 = tempdata1;
			data_out_decipher2 = tempdata2;
			end
			s5: reset_out = 1'b0;
			s6: test_plaintext = ((data_in_decipher1 == 32'h00000000) && (data_in_decipher2 == 32'h00000000));
			s7: result = (test_ciphertext && test_plaintext);
			//Test 2
			s8: begin
			    result = 1'b0;
			    reset_out = 1'b1;
			    data_out_encipher1 = 32'h00000000;
			    data_out_encipher2 = 32'h00000000;
			    key_out = 128'h11111111222222223333333344444444;
			    end
			s9: reset_out = 1'b0;
			s10: begin
			test_ciphertext = ((data_in_encipher1 == 32'hf07ac290) && (data_in_encipher2 == 32'h23c92672));
			tempdata1 = data_in_encipher1;
			tempdata2 = data_in_encipher2;
			end
			s11: begin
			reset_out = 1'b1;
			data_out_decipher1 = tempdata1;
			data_out_decipher2 = tempdata2;
			end
			s12: reset_out = 1'b0;
			s13: test_plaintext = ((data_in_decipher1 == 32'h00000000) && (data_in_decipher2 == 32'h00000000));
			s14: result = (test_ciphertext && test_plaintext);
			//Test 3
			s15: begin
			    result = 1'b0;
			    reset_out = 1'b1;
			    data_out_encipher1 = 32'h12345678;
			    data_out_encipher2 = 32'h9abcdeff;
			    key_out = 128'h6a1d78c88c86d67f2a65bfbeb4bd6e46;
			    end
			s16: reset_out = 1'b0;
			s17: begin
			test_ciphertext = ((data_in_encipher1 == 32'h99bbb92b) && (data_in_encipher2 == 32'h3ebd1644));
			tempdata1 = data_in_encipher1;
			tempdata2 = data_in_encipher2;
			end
			s18: begin
			reset_out = 1'b1;
			data_out_decipher1 = tempdata1;
			data_out_decipher2 = tempdata2;
			end
			s19: reset_out = 1'b0;
			s20: test_plaintext = ((data_in_decipher1 == 32'h12345678) && (data_in_decipher2 == 32'h9abcdeff));
			s21: result = (test_ciphertext && test_plaintext);
			//Test 4
			s22: begin
			    result = 1'b0;
			    reset_out = 1'b1;
			    data_out_encipher1 = 32'h00000001;
			    data_out_encipher2 = 32'h00000001;
			    key_out = 128'h62ee209f69b7afce376a8936cdc9e923;
			    end
			s23: reset_out = 1'b0;
			s24: begin
			test_ciphertext = ((data_in_encipher1 == 32'he57220dd) && (data_in_encipher2 == 32'h2622745b));
			tempdata1 = data_in_encipher1;
			tempdata2 = data_in_encipher2;
			end
			s25: begin
			reset_out = 1'b1;
			data_out_decipher1 = tempdata1;
			data_out_decipher2 = tempdata2;
			end
			s26: reset_out = 1'b0;
			s27: test_plaintext = ((data_in_decipher1 == 32'h00000001) && (data_in_decipher2 == 32'h00000001));
			s28: result = (test_ciphertext && test_plaintext);
			//Test 5
			s29: begin
			    result = 1'b0;
			    reset_out = 1'b1;
			    data_out_encipher1 = 32'h77777777;
			    data_out_encipher2 = 32'h98765432;
			    key_out = 128'hbc3a7de2845846cf2794a1276b8ea8b8;
			    end
			s30: reset_out = 1'b0;
			s31: begin
			test_ciphertext = ((data_in_encipher1 == 32'hda6b0b0a) && (data_in_encipher2 == 32'ha15e9758));
			tempdata1 = data_in_encipher1;
			tempdata2 = data_in_encipher2;
			end
			s32: begin
			reset_out = 1'b1;
			data_out_decipher1 = tempdata1;
			data_out_decipher2 = tempdata2;
			end
			s33: reset_out = 1'b0;
			s34: test_plaintext = ((data_in_decipher1 == 32'h77777777) && (data_in_decipher2 == 32'h98765432));
			s35: result = (test_ciphertext && test_plaintext);
			//Test 6
			s36: begin
			    result = 1'b0;
			    reset_out = 1'b1;
			    data_out_encipher1 = 32'hffffffff;
			    data_out_encipher2 = 32'hffffffff;
			    key_out = 128'h6a1d78c88c86d6712a65bfbeb4bd6e46;
			    end
			s37: reset_out = 1'b0;
			s38: begin
			test_ciphertext = ((data_in_encipher1 == 32'h674e0539) && (data_in_encipher2 == 32'h5ad31ab8));
			tempdata1 = data_in_encipher1;
			tempdata2 = data_in_encipher2;
			end
			s39: begin
			reset_out = 1'b1;
			data_out_decipher1 = tempdata1;
			data_out_decipher2 = tempdata2;
			end
			s40: reset_out = 1'b0;
			s41: test_plaintext = ((data_in_decipher1 == 32'hffffffff) && (data_in_decipher2 == 32'hffffffff));
			s42: result = (test_ciphertext && test_plaintext);
			//Test 7
			s43: begin
			    result = 1'b0;
			    reset_out = 1'b1;
			    data_out_encipher1 = 32'hffffffff;
			    data_out_encipher2 = 32'hffffffff;
			    key_out = 128'hffffffffffffffffffffffffffffffff;
			    end
			s44: reset_out = 1'b0;
			s45: begin
			test_ciphertext = ((data_in_encipher1 == 32'h28fc2891) && (data_in_encipher2 == 32'he623566a));
			tempdata1 = data_in_encipher1;
			tempdata2 = data_in_encipher2;
			end
			s46: begin
			reset_out = 1'b1;
			data_out_decipher1 = tempdata1;
			data_out_decipher2 = tempdata2;
			end
			s47: reset_out = 1'b0;
			s48: test_plaintext = ((data_in_decipher1 == 32'hffffffff) && (data_in_decipher2 == 32'hffffffff));
			s49: result = (test_ciphertext && test_plaintext);
			//End tests
			default: begin
			reset_out = 1'b1;
			data_out_encipher1 = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
			data_out_encipher2 = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
			data_out_decipher1 = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
			data_out_decipher2 = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
			key_out = 128'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
			result = 1'bz;
			end
		endcase
	end
end

endmodule