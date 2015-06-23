/////////////////////////////////////////////////////////////////////
////                                                             ////
////  JPEG Entropy Coding, Huffman tables                        ////
////                                                             ////
////  These functions contain the default huffman tables as      ////
////  described in ITU-T.81 (ISO/IEC-10918-1) Annex K.           ////
////                                                             ////
////  Author: Richard Herveille                                  ////
////          richard@asics.ws                                   ////
////          www.asics.ws                                       ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2001 Richard Herveille                        ////
////                    richard@asics.ws                         ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////

//  CVS Log
//
//  $Id: huffman_tables.v,v 1.2 2002-10-31 12:50:40 rherveille Exp $
//
//  $Date: 2002-10-31 12:50:40 $
//  $Revision: 1.2 $
//  $Author: rherveille $
//  $Locker:  $
//  $State: Exp $
//


/* *********************** */
/* *** E N C O D I N G *** */
/* *********************** */

/*
  J P E G _ D C _ L U M I N A N C E _ H U F F M A N _ E N C

  ITU-T.81 annex K.3.1 Table K.3

  This function translates the luminance DC coefficient difference
  into the default huffman codeword.
  Output is given as:
  codelength[3:0]-1, codeword[8:0]

  The codewords are right-alligned to ease bitstream generation.

  example:
  dc_luminance_coefficient = 3
  codelength = 2 +1 = 3
  codeword   = 9'b0_0000_0100 => 3'b100
*/
function [12:0] jpeg_dc_luminance_huffman_enc;
  input [ 3:0] dc_luminance_coefficient;
begin
  case(dc_luminance_coefficient) // synopsys full_case parallel_case
    4'h0: jpeg_dc_luminance_huffman_enc = {4'h1, 9'b0_0000_0000};
    4'h1: jpeg_dc_luminance_huffman_enc = {4'h2, 9'b0_0000_0010};
    4'h2: jpeg_dc_luminance_huffman_enc = {4'h2, 9'b0_0000_0011};
    4'h3: jpeg_dc_luminance_huffman_enc = {4'h2, 9'b0_0000_0100};
    4'h4: jpeg_dc_luminance_huffman_enc = {4'h2, 9'b0_0000_0101};
    4'h5: jpeg_dc_luminance_huffman_enc = {4'h2, 9'b0_0000_0110};
    4'h6: jpeg_dc_luminance_huffman_enc = {4'h3, 9'b0_0000_1110};
    4'h7: jpeg_dc_luminance_huffman_enc = {4'h4, 9'b0_0001_1110};
    4'h8: jpeg_dc_luminance_huffman_enc = {4'h5, 9'b0_0011_1110};
    4'h9: jpeg_dc_luminance_huffman_enc = {4'h6, 9'b0_0111_1110};
    4'ha: jpeg_dc_luminance_huffman_enc = {4'h7, 9'b0_1111_1110};
    4'hb: jpeg_dc_luminance_huffman_enc = {4'h8, 9'b1_1111_1110};
  endcase
end
endfunction // jpeg_dc_luminance_huffman_enc


/*
  J P E G _ D C _ C H R O M I N A N C E _ H U F F M A N _ E N C

  ITU-T.81 annex K.3.1 Table K.4

  This function translates the chrominance DC coefficient difference
  into the default huffman codeword.
  Output is given as:
  codelength[3:0]-1, codeword[10:0]

  The codewords are right-alligned to ease bitstream generation.

  example:
  dc_chrominance_coefficient = 3
  codelength = 2 +1 = 3
  codeword   = 11'b0_0000_0110 => 3'b110
*/
function [14:0] jpeg_dc_chrominance_huffman_enc;
  input [ 3:0] dc_chrominance_coefficient;
begin
  case(dc_chrominance_coefficient) // synopsys full_case parallel_case
    4'h0: jpeg_dc_chrominance_huffman_enc = {4'h1, 11'b000_0000_0000};
    4'h1: jpeg_dc_chrominance_huffman_enc = {4'h1, 11'b000_0000_0001};
    4'h2: jpeg_dc_chrominance_huffman_enc = {4'h1, 11'b000_0000_0010};
    4'h3: jpeg_dc_chrominance_huffman_enc = {4'h2, 11'b000_0000_0110};
    4'h4: jpeg_dc_chrominance_huffman_enc = {4'h3, 11'b000_0000_1110};
    4'h5: jpeg_dc_chrominance_huffman_enc = {4'h4, 11'b000_0001_1110};
    4'h6: jpeg_dc_chrominance_huffman_enc = {4'h5, 11'b000_0011_1110};
    4'h7: jpeg_dc_chrominance_huffman_enc = {4'h6, 11'b000_0111_1110};
    4'h8: jpeg_dc_chrominance_huffman_enc = {4'h7, 11'b000_1111_1110};
    4'h9: jpeg_dc_chrominance_huffman_enc = {4'h8, 11'b001_1111_1110};
    4'ha: jpeg_dc_chrominance_huffman_enc = {4'h9, 11'b011_1111_1110};
    4'hb: jpeg_dc_chrominance_huffman_enc = {4'ha, 11'b111_1111_1110};
  endcase
end
endfunction // jpeg_dc_chrominance_huffman_enc


/*
  J P E G _ A C _ L U M I N A N C E _ H U F F M A N _ E N C

  ITU-T.81 annex K.3.2 Table K.5

  This function translates the luminance AC (RunLength, Size) codepair
  into the default huffman codeword.
  Output is given as:
  codelength[3:0]-1, codeword[15:0]

  The codewords are right-alligned to ease bitstream generation.

  example:
  ac_luminance_run_length      = 3
  ac_limunance_size (category) = 2
  codelength = 8 +1 = 9
  codeword   = 16'b0000_0001_1111_0111 => 9'b1_1111_0111
*/
function [19:0] jpeg_ac_luminance_huffman_enc;
  input [ 3:0] run_length;  // category
  input [ 3:0] size;
begin
  case( {run_length, size} ) // synopsys full_case parallel_case
    8'h00: jpeg_ac_luminance_huffman_enc = {4'h3, 16'b0000_0000_0000_1010}; // EOB
    8'h01: jpeg_ac_luminance_huffman_enc = {4'h1, 16'b0000_0000_0000_0000};
    8'h02: jpeg_ac_luminance_huffman_enc = {4'h1, 16'b0000_0000_0000_0001};
    8'h03: jpeg_ac_luminance_huffman_enc = {4'h2, 16'b0000_0000_0000_0100};
    8'h04: jpeg_ac_luminance_huffman_enc = {4'h3, 16'b0000_0000_0000_1011};
    8'h05: jpeg_ac_luminance_huffman_enc = {4'h4, 16'b0000_0000_0001_1010};
    8'h06: jpeg_ac_luminance_huffman_enc = {4'h6, 16'b0000_0000_0111_1000};
    8'h07: jpeg_ac_luminance_huffman_enc = {4'h7, 16'b0000_0000_1111_1000};
    8'h08: jpeg_ac_luminance_huffman_enc = {4'h9, 16'b0000_0011_1111_0110};
    8'h09: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1000_0010};
    8'h0a: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1000_0011};

    8'h11: jpeg_ac_luminance_huffman_enc = {4'h3, 16'b0000_0000_0000_1100};
    8'h12: jpeg_ac_luminance_huffman_enc = {4'h4, 16'b0000_0000_0001_1011};
    8'h13: jpeg_ac_luminance_huffman_enc = {4'h6, 16'b0000_0000_0111_1001};
    8'h14: jpeg_ac_luminance_huffman_enc = {4'h8, 16'b0000_0001_1111_0110};
    8'h15: jpeg_ac_luminance_huffman_enc = {4'ha, 16'b0000_0111_1111_0110};
    8'h16: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1000_0100};
    8'h17: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1000_0101};
    8'h18: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1000_0110};
    8'h19: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1000_0111};
    8'h1a: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1000_1000};

    8'h21: jpeg_ac_luminance_huffman_enc = {4'h4, 16'b0000_0000_0001_1100};
    8'h22: jpeg_ac_luminance_huffman_enc = {4'h7, 16'b0000_0000_1111_1001};
    8'h23: jpeg_ac_luminance_huffman_enc = {4'h9, 16'b0000_0011_1111_0111};
    8'h24: jpeg_ac_luminance_huffman_enc = {4'hb, 16'b0000_1111_1111_0100};
    8'h25: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1000_1001};
    8'h26: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1000_1010};
    8'h27: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1000_1011};
    8'h28: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1000_1100};
    8'h29: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1000_1101};
    8'h2a: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1000_1110};

    8'h31: jpeg_ac_luminance_huffman_enc = {4'h5, 16'b0000_0000_0011_1010};
    8'h32: jpeg_ac_luminance_huffman_enc = {4'h8, 16'b0000_0001_1111_0111};
    8'h33: jpeg_ac_luminance_huffman_enc = {4'hb, 16'b0000_1111_1111_0101};
    8'h34: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1000_1111};
    8'h35: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1001_0000};
    8'h36: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1001_0001};
    8'h37: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1001_0010};
    8'h38: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1001_0011};
    8'h39: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1001_0100};
    8'h3a: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1001_0101};

    8'h41: jpeg_ac_luminance_huffman_enc = {4'h5, 16'b0000_0000_0011_1011};
    8'h42: jpeg_ac_luminance_huffman_enc = {4'h9, 16'b0000_0011_1111_1000};
    8'h43: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1001_0110};
    8'h44: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1001_0111};
    8'h45: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1001_1000};
    8'h46: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1001_1001};
    8'h47: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1001_1010};
    8'h48: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1001_1011};
    8'h49: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1001_1100};
    8'h4a: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1001_1101};

    8'h51: jpeg_ac_luminance_huffman_enc = {4'h6, 16'b0000_0000_0111_1010};
    8'h52: jpeg_ac_luminance_huffman_enc = {4'ha, 16'b0000_0111_1111_0111};
    8'h53: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1001_1110};
    8'h54: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1001_1111};
    8'h55: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1010_0000};
    8'h56: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1010_0001};
    8'h57: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1010_0010};
    8'h58: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1010_0011};
    8'h59: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1010_0100};
    8'h5a: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1010_0101};

    8'h61: jpeg_ac_luminance_huffman_enc = {4'h6, 16'b0000_0000_0111_1011};
    8'h62: jpeg_ac_luminance_huffman_enc = {4'hb, 16'b0000_1111_1111_0110};
    8'h63: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1010_0110};
    8'h64: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1010_0111};
    8'h65: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1010_1000};
    8'h66: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1010_1001};
    8'h67: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1010_1010};
    8'h68: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1010_1011};
    8'h69: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1010_1100};
    8'h6a: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1010_1101};

    8'h71: jpeg_ac_luminance_huffman_enc = {4'h7, 16'b0000_0000_1111_1010};
    8'h72: jpeg_ac_luminance_huffman_enc = {4'hb, 16'b0000_1111_1111_0111};
    8'h73: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1010_1110};
    8'h74: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1010_1111};
    8'h75: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1011_0000};
    8'h76: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1011_0001};
    8'h77: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1011_0010};
    8'h78: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1011_0011};
    8'h79: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1011_0100};
    8'h7a: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1011_0101};

    8'h81: jpeg_ac_luminance_huffman_enc = {4'h8, 16'b0000_0001_1111_1000};
    8'h82: jpeg_ac_luminance_huffman_enc = {4'he, 16'b0111_1111_1100_0000};
    8'h83: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1011_0110};
    8'h84: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1011_0111};
    8'h85: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1011_1000};
    8'h86: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1011_1001};
    8'h87: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1011_1010};
    8'h88: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1011_1011};
    8'h89: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1011_1100};
    8'h8a: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1011_1101};

    8'h91: jpeg_ac_luminance_huffman_enc = {4'h8, 16'b0000_0001_1111_1001};
    8'h92: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1011_1110};
    8'h93: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1011_1111};
    8'h94: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1100_0000};
    8'h95: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1100_0001};
    8'h96: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1100_0010};
    8'h97: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1100_0011};
    8'h98: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1100_0100};
    8'h99: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1100_0101};
    8'h9a: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1100_0110};

    8'ha1: jpeg_ac_luminance_huffman_enc = {4'h8, 16'b0000_0001_1111_1010};
    8'ha2: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1100_0111};
    8'ha3: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1100_1000};
    8'ha4: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1100_1001};
    8'ha5: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1100_1010};
    8'ha6: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1100_1011};
    8'ha7: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1100_1100};
    8'ha8: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1100_1101};
    8'ha9: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1100_1110};
    8'haa: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1100_1111};

    8'hb1: jpeg_ac_luminance_huffman_enc = {4'h9, 16'b0000_0011_1111_1001};
    8'hb2: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1101_0000};
    8'hb3: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1101_0001};
    8'hb4: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1101_0010};
    8'hb5: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1101_0011};
    8'hb6: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1101_0100};
    8'hb7: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1101_0101};
    8'hb8: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1101_0110};
    8'hb9: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1101_0111};
    8'hba: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1101_1000};

    8'hc1: jpeg_ac_luminance_huffman_enc = {4'h9, 16'b0000_0011_1111_1010};
    8'hc2: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1101_1001};
    8'hc3: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1101_1010};
    8'hc4: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1101_1011};
    8'hc5: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1101_1100};
    8'hc6: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1101_1101};
    8'hc7: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1101_1110};
    8'hc8: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1101_1111};
    8'hc9: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1110_0000};
    8'hca: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1110_0001};

    8'hd1: jpeg_ac_luminance_huffman_enc = {4'ha, 16'b0000_0111_1111_1000};
    8'hd2: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1110_0010};
    8'hd3: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1110_0011};
    8'hd4: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1110_0100};
    8'hd5: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1110_0101};
    8'hd6: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1110_0110};
    8'hd7: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1110_0111};
    8'hd8: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1110_1000};
    8'hd9: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1110_1001};
    8'hda: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1110_1010};

    8'he1: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1110_1011};
    8'he2: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1110_1100};
    8'he3: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1110_1101};
    8'he4: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1110_1110};
    8'he5: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1110_1111};
    8'he6: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1111_0000};
    8'he7: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1111_0001};
    8'he8: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1111_0010};
    8'he9: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1111_0011};
    8'hea: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1111_0100};

    8'hf0: jpeg_ac_luminance_huffman_enc = {4'ha, 16'b0000_0111_1111_1001}; // ZRL
    8'hf1: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1111_0101};
    8'hf2: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1111_0110};
    8'hf3: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1111_0111};
    8'hf4: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1111_1000};
    8'hf5: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1111_1001};
    8'hf6: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1111_1010};
    8'hf7: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1111_1011};
    8'hf8: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1111_1100};
    8'hf9: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1111_1101};
    8'hfa: jpeg_ac_luminance_huffman_enc = {4'hf, 16'b1111_1111_1111_1110};
  endcase
end
endfunction // jpeg_ac_luminance_huffman_enc


/*
  J P E G _ A C _ C H R O M I N A N C E _ H U F F M A N _ E N C

  ITU-T.81 annex K.3.2 Table K.6

  This function translates the chrominance AC (RunLength, Size) codepair
  into the default huffman codeword.
  Output is given as:
  codelength[3:0]-1, codeword[15:0]

  The codewords are right-alligned to ease bitstream generation.

  example:
  ac_luminance_run_length      = 2
  ac_limunance_size (category) = 5
  codelength = e +1 = 15(dec)
  codeword   = 16'b0111_1111_1100_0010 => 15'b0111_1111_1100_0010
*/
function [19:0] jpeg_ac_chrominance_huffman_enc;
  input [ 3:0] run_length;  // category
  input [ 3:0] size;
begin
  case( {run_length, size} ) // synopsys full_case parallel_case
    8'h00: jpeg_ac_chrominance_huffman_enc = {4'h1, 16'b0000_0000_0000_0000}; // EOB
    8'h01: jpeg_ac_chrominance_huffman_enc = {4'h1, 16'b0000_0000_0000_0001};
    8'h02: jpeg_ac_chrominance_huffman_enc = {4'h2, 16'b0000_0000_0000_0100};
    8'h03: jpeg_ac_chrominance_huffman_enc = {4'h3, 16'b0000_0000_0000_1010};
    8'h04: jpeg_ac_chrominance_huffman_enc = {4'h4, 16'b0000_0000_0001_1000};
    8'h05: jpeg_ac_chrominance_huffman_enc = {4'h4, 16'b0000_0000_0001_1001};
    8'h06: jpeg_ac_chrominance_huffman_enc = {4'h5, 16'b0000_0000_0011_1000};
    8'h07: jpeg_ac_chrominance_huffman_enc = {4'h6, 16'b0000_0000_0111_1000};
    8'h08: jpeg_ac_chrominance_huffman_enc = {4'h8, 16'b0000_0001_1111_0100};
    8'h09: jpeg_ac_chrominance_huffman_enc = {4'h9, 16'b0000_0011_1111_0110};
    8'h0a: jpeg_ac_chrominance_huffman_enc = {4'hb, 16'b0000_1111_1111_0100};

    8'h11: jpeg_ac_chrominance_huffman_enc = {4'h3, 16'b0000_0000_0000_1011};
    8'h12: jpeg_ac_chrominance_huffman_enc = {4'h5, 16'b0000_0000_0011_1001};
    8'h13: jpeg_ac_chrominance_huffman_enc = {4'h7, 16'b0000_0000_1111_0110};
    8'h14: jpeg_ac_chrominance_huffman_enc = {4'h8, 16'b0000_0001_1111_0101};
    8'h15: jpeg_ac_chrominance_huffman_enc = {4'ha, 16'b0000_0111_1111_0110};
    8'h16: jpeg_ac_chrominance_huffman_enc = {4'hb, 16'b0000_1111_1111_0101};
    8'h17: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1000_1000};
    8'h18: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1000_1001};
    8'h19: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1000_1010};
    8'h1a: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1000_1011};

    8'h21: jpeg_ac_chrominance_huffman_enc = {4'h4, 16'b0000_0000_0001_1010};
    8'h22: jpeg_ac_chrominance_huffman_enc = {4'h7, 16'b0000_0000_1111_0111};
    8'h23: jpeg_ac_chrominance_huffman_enc = {4'h9, 16'b0000_0011_1111_0111};
    8'h24: jpeg_ac_chrominance_huffman_enc = {4'hb, 16'b0000_1111_1111_0110};
    8'h25: jpeg_ac_chrominance_huffman_enc = {4'he, 16'b0111_1111_1100_0010};
    8'h26: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1000_1100};
    8'h27: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1000_1101};
    8'h28: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1000_1110};
    8'h29: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1000_1111};
    8'h2a: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1001_0000};

    8'h31: jpeg_ac_chrominance_huffman_enc = {4'h4, 16'b0000_0000_0001_1011};
    8'h32: jpeg_ac_chrominance_huffman_enc = {4'h7, 16'b0000_0000_1111_1000};
    8'h33: jpeg_ac_chrominance_huffman_enc = {4'h9, 16'b0000_0011_1111_1000};
    8'h34: jpeg_ac_chrominance_huffman_enc = {4'hb, 16'b0000_1111_1111_0111};
    8'h35: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1001_0001};
    8'h36: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1001_0010};
    8'h37: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1001_0011};
    8'h38: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1001_0100};
    8'h39: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1001_0101};
    8'h3a: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1001_0110};

    8'h41: jpeg_ac_chrominance_huffman_enc = {4'h5, 16'b0000_0000_0011_1010};
    8'h42: jpeg_ac_chrominance_huffman_enc = {4'h8, 16'b0000_0001_1111_0110};
    8'h43: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1001_0111};
    8'h44: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1001_1000};
    8'h45: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1001_1001};
    8'h46: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1001_1010};
    8'h47: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1001_1011};
    8'h48: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1001_1100};
    8'h49: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1001_1101};
    8'h4a: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1001_1110};

    8'h51: jpeg_ac_chrominance_huffman_enc = {4'h5, 16'b0000_0000_0011_1011};
    8'h52: jpeg_ac_chrominance_huffman_enc = {4'h9, 16'b0000_0011_1111_1001};
    8'h53: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1001_1111};
    8'h54: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1010_0000};
    8'h55: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1010_0001};
    8'h56: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1010_0010};
    8'h57: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1010_0011};
    8'h58: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1010_0100};
    8'h59: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1010_0101};
    8'h5a: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1010_0110};

    8'h61: jpeg_ac_chrominance_huffman_enc = {4'h6, 16'b0000_0000_0111_1001};
    8'h62: jpeg_ac_chrominance_huffman_enc = {4'ha, 16'b0000_0111_1111_0111};
    8'h63: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1010_0111};
    8'h64: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1010_1000};
    8'h65: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1010_1001};
    8'h66: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1010_1010};
    8'h67: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1010_1011};
    8'h68: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1010_1100};
    8'h69: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1010_1101};
    8'h6a: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1010_1110};

    8'h71: jpeg_ac_chrominance_huffman_enc = {4'h6, 16'b0000_0000_0111_1010};
    8'h72: jpeg_ac_chrominance_huffman_enc = {4'ha, 16'b0000_0111_1111_1000};
    8'h73: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1010_1111};
    8'h74: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1011_0000};
    8'h75: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1011_0001};
    8'h76: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1011_0010};
    8'h77: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1011_0011};
    8'h78: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1011_0100};
    8'h79: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1011_0101};
    8'h7a: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1011_0110};

    8'h81: jpeg_ac_chrominance_huffman_enc = {4'h7, 16'b0000_0000_1111_1001};
    8'h82: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1011_0111};
    8'h83: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1011_1000};
    8'h84: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1011_1001};
    8'h85: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1011_1010};
    8'h86: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1011_1011};
    8'h87: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1011_1100};
    8'h88: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1011_1101};
    8'h89: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1011_1110};
    8'h8a: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1011_1111};

    8'h91: jpeg_ac_chrominance_huffman_enc = {4'h8, 16'b0000_0001_1111_0111};
    8'h92: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1100_0000};
    8'h93: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1100_0001};
    8'h94: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1100_0010};
    8'h95: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1100_0011};
    8'h96: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1100_0100};
    8'h97: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1100_0101};
    8'h98: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1100_0110};
    8'h99: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1100_0111};
    8'h9a: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1100_1000};

    8'ha1: jpeg_ac_chrominance_huffman_enc = {4'h8, 16'b0000_0001_1111_1000};
    8'ha2: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1100_1001};
    8'ha3: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1100_1010};
    8'ha4: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1100_1011};
    8'ha5: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1100_1100};
    8'ha6: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1100_1101};
    8'ha7: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1100_1110};
    8'ha8: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1100_1111};
    8'ha9: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1101_0000};
    8'haa: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1101_0001};

    8'hb1: jpeg_ac_chrominance_huffman_enc = {4'h8, 16'b0000_0001_1111_1001};
    8'hb2: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1101_0010};
    8'hb3: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1101_0011};
    8'hb4: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1101_0100};
    8'hb5: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1101_0101};
    8'hb6: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1101_0110};
    8'hb7: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1101_0111};
    8'hb8: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1101_1000};
    8'hb9: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1101_1001};
    8'hba: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1101_1010};

    8'hc1: jpeg_ac_chrominance_huffman_enc = {4'h8, 16'b0000_0001_1111_1010};
    8'hc2: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1101_1011};
    8'hc3: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1101_1100};
    8'hc4: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1101_1101};
    8'hc5: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1101_1110};
    8'hc6: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1101_1111};
    8'hc7: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1110_0000};
    8'hc8: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1110_0001};
    8'hc9: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1110_0010};
    8'hca: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1110_0011};

    8'hd1: jpeg_ac_chrominance_huffman_enc = {4'ha, 16'b0000_0111_1111_1001};
    8'hd2: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1110_0100};
    8'hd3: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1110_0101};
    8'hd4: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1110_0110};
    8'hd5: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1110_0111};
    8'hd6: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1110_1000};
    8'hd7: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1110_1001};
    8'hd8: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1110_1010};
    8'hd9: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1110_1011};
    8'hda: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1110_1100};

    8'he1: jpeg_ac_chrominance_huffman_enc = {4'hd, 16'b0011_1111_1110_0000};
    8'he2: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1110_1101};
    8'he3: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1110_1110};
    8'he4: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1110_1111};
    8'he5: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1111_0000};
    8'he6: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1111_0001};
    8'he7: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1111_0010};
    8'he8: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1111_0011};
    8'he9: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1111_0100};
    8'hea: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1111_0101};

    8'hf0: jpeg_ac_chrominance_huffman_enc = {4'h9, 16'b0000_0011_1111_1010}; // ZRL
    8'hf1: jpeg_ac_chrominance_huffman_enc = {4'he, 16'b0111_1111_1100_0011};
    8'hf2: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1111_0110};
    8'hf3: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1111_0111};
    8'hf4: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1111_1000};
    8'hf5: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1111_1001};
    8'hf6: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1111_1010};
    8'hf7: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1111_1011};
    8'hf8: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1111_1100};
    8'hf9: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1111_1101};
    8'hfa: jpeg_ac_chrominance_huffman_enc = {4'hf, 16'b1111_1111_1111_1110};
  endcase
end
endfunction // jpeg_ac_chrominance_huffman_enc


/* *********************** */
/* *** D E C O D I N G *** */
/* *********************** */

/*
  J P E G _ D C _ L U M I N A N C E _ H U F F M A N _ D E C

  ITU-T.81 annex K.3.1 Table K.3

  This function translates the default Huffman codeword into the
  luminance DC coefficient difference category.
  Output is given as:
  codelength[3:0]-1, category[3:0]

  The codewords are left-alligned to ease bitstream decomposition.

  example:
  codeword = 9'b1_0011_010
  codelength = 2 +1 = 3
  category = 3
*/
function [7:0] jpeg_dc_luminance_huffman_dec;
  input [8:0] codeword;
begin
  casex(codeword) // synopsys full_case parallel_case
    9'b0_0???_????: jpeg_dc_luminance_huffman_dec = {4'h1, 4'h0};
    9'b0_10??_????: jpeg_dc_luminance_huffman_dec = {4'h2, 4'h1};
    9'b0_11??_????: jpeg_dc_luminance_huffman_dec = {4'h2, 4'h2};
    9'b1_00??_????: jpeg_dc_luminance_huffman_dec = {4'h2, 4'h3};
    9'b1_01??_????: jpeg_dc_luminance_huffman_dec = {4'h2, 4'h4};
    9'b1_10??_????: jpeg_dc_luminance_huffman_dec = {4'h2, 4'h5};
    9'b1_110?_????: jpeg_dc_luminance_huffman_dec = {4'h3, 4'h6};
    9'b1_1110_????: jpeg_dc_luminance_huffman_dec = {4'h4, 4'h7};
    9'b1_1111_0???: jpeg_dc_luminance_huffman_dec = {4'h5, 4'h8};
    9'b1_1111_10??: jpeg_dc_luminance_huffman_dec = {4'h6, 4'h9};
    9'b1_1111_110?: jpeg_dc_luminance_huffman_dec = {4'h7, 4'ha};
    9'b1_1111_1110: jpeg_dc_luminance_huffman_dec = {4'h8, 4'hb};
  endcase
end
endfunction // jpeg_dc_luminance_huffman_dec


/*
  J P E G _ D C _ C H R O M I N A N C E _ H U F F M A N _ D E C

  ITU-T.81 annex K.3.1 Table K.4

  This function translates the default Huffman codeword into
  the chrominance DC coefficient difference.
  Output is given as:
  codelength[3:0]-1, category [3:0]

  The codewords are left-alligned to ease bitstream decomposition.

  example:
  dc_chrominance_coefficient = 3
  codelength = 2 +1 = 3
  codeword   = 11'b0_0000_0110 => 3'b110
*/
function [7:0] jpeg_dc_chrominance_huffman_dec;
  input [10:0] codeword;
begin
  casex(codeword) // synopsys full_case parallel_case
    11'b00?_????_????: jpeg_dc_chrominance_huffman_dec = {4'h1, 4'h0};
    11'b01?_????_????: jpeg_dc_chrominance_huffman_dec = {4'h1, 4'h1};
    11'b10?_????_????: jpeg_dc_chrominance_huffman_dec = {4'h1, 4'h2};
    11'b110_????_????: jpeg_dc_chrominance_huffman_dec = {4'h2, 4'h3};
    11'b111_0???_????: jpeg_dc_chrominance_huffman_dec = {4'h3, 4'h4};
    11'b111_10??_????: jpeg_dc_chrominance_huffman_dec = {4'h4, 4'h5};
    11'b111_110?_????: jpeg_dc_chrominance_huffman_dec = {4'h5, 4'h6};
    11'b111_1110_????: jpeg_dc_chrominance_huffman_dec = {4'h6, 4'h7};
    11'b111_1111_0???: jpeg_dc_chrominance_huffman_dec = {4'h7, 4'h8};
    11'b111_1111_10??: jpeg_dc_chrominance_huffman_dec = {4'h8, 4'h9};
    11'b111_1111_110?: jpeg_dc_chrominance_huffman_dec = {4'h9, 4'ha};
    11'b111_1111_1110: jpeg_dc_chrominance_huffman_dec = {4'ha, 4'hb};
  endcase
end
endfunction // jpeg_dc_chrominance_huffman_dec


/*
  J P E G _ A C _ L U M I N A N C E _ H U F F M A N _ D E C

  ITU-T.81 annex K.3.2 Table K.5

  This function translates the default Huffman codeword into
  luminance AC (RunLength, Size) codepair.

  Output is given as:
  codelength[3:0]-1, RunLength[3:0], size[3:0]

  The codewords are left-alligned to ease bitstream decomposition.

  example:
  codeword   = 16'b0000_0001_1111_0111
  codelength = 8 +1 = 9
  ac_luminance_run_length      = 3
  ac_limunance_size (category) = 2
*/
function [11:0] jpeg_ac_luminance_huffman_dec;
  input [15:0] codeword;
begin
  casex(codeword) // synopsys full_case parallel_case
    16'b1010_????_????_????: jpeg_ac_luminance_huffman_dec = {4'h3, 8'h00}; // EOB
    16'b00??_????_????_????: jpeg_ac_luminance_huffman_dec = {4'h1, 8'h01};
    16'b01??_????_????_????: jpeg_ac_luminance_huffman_dec = {4'h1, 8'h02};
    16'b100?_????_????_????: jpeg_ac_luminance_huffman_dec = {4'h2, 8'h03};
    16'b1011_????_????_????: jpeg_ac_luminance_huffman_dec = {4'h3, 8'h04};
    16'b1101_0???_????_????: jpeg_ac_luminance_huffman_dec = {4'h4, 8'h05};
    16'b1111_000?_????_????: jpeg_ac_luminance_huffman_dec = {4'h6, 8'h06};
    16'b1111_1000_????_????: jpeg_ac_luminance_huffman_dec = {4'h7, 8'h07};
    16'b1111_1101_10??_????: jpeg_ac_luminance_huffman_dec = {4'h9, 8'h08};
    16'b1111_1111_1000_0010: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h09};
    16'b1111_1111_1000_0011: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h0a};

    16'b1100_????_????_????: jpeg_ac_luminance_huffman_dec = {4'h3, 8'h11};
    16'b1101_1???_????_????: jpeg_ac_luminance_huffman_dec = {4'h4, 8'h12};
    16'b1111_001?_????_????: jpeg_ac_luminance_huffman_dec = {4'h6, 8'h13};
    16'b1111_1011_0???_????: jpeg_ac_luminance_huffman_dec = {4'h8, 8'h14};
    16'b1111_1110_110?_????: jpeg_ac_luminance_huffman_dec = {4'ha, 8'h15};
    16'b1111_1111_1000_0100: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h16};
    16'b1111_1111_1000_0101: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h17};
    16'b1111_1111_1000_0110: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h18};
    16'b1111_1111_1000_0111: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h19};
    16'b1111_1111_1000_1000: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h1a};

    16'b1110_0???_????_????: jpeg_ac_luminance_huffman_dec = {4'h4, 8'h21};
    16'b1111_1001_????_????: jpeg_ac_luminance_huffman_dec = {4'h7, 8'h22};
    16'b1111_1101_11??_????: jpeg_ac_luminance_huffman_dec = {4'h9, 8'h23};
    16'b1111_1111_0100_????: jpeg_ac_luminance_huffman_dec = {4'hb, 8'h24};
    16'b1111_1111_1000_1001: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h25};
    16'b1111_1111_1000_1010: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h26};
    16'b1111_1111_1000_1011: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h27};
    16'b1111_1111_1000_1100: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h28};
    16'b1111_1111_1000_1101: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h29};
    16'b1111_1111_1000_1110: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h2a};

    16'b1110_10??_????_????: jpeg_ac_luminance_huffman_dec = {4'h5, 8'h31};
    16'b1111_1011_1???_????: jpeg_ac_luminance_huffman_dec = {4'h8, 8'h32};
    16'b1111_1111_0101_????: jpeg_ac_luminance_huffman_dec = {4'hb, 8'h33};
    16'b1111_1111_1000_1111: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h34};
    16'b1111_1111_1001_0000: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h35};
    16'b1111_1111_1001_0001: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h36};
    16'b1111_1111_1001_0010: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h37};
    16'b1111_1111_1001_0011: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h38};
    16'b1111_1111_1001_0100: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h39};
    16'b1111_1111_1001_0101: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h3a};

    16'b1110_11??_????_????: jpeg_ac_luminance_huffman_dec = {4'h5, 8'h41};
    16'b1111_1110_00??_????: jpeg_ac_luminance_huffman_dec = {4'h9, 8'h42};
    16'b1111_1111_1001_0110: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h43};
    16'b1111_1111_1001_0111: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h44};
    16'b1111_1111_1001_1000: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h45};
    16'b1111_1111_1001_1001: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h46};
    16'b1111_1111_1001_1010: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h47};
    16'b1111_1111_1001_1011: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h48};
    16'b1111_1111_1001_1100: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h49};
    16'b1111_1111_1001_1101: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h4a};

    16'b1111_010?_????_????: jpeg_ac_luminance_huffman_dec = {4'h6, 8'h51};
    16'b1111_1110_111?_????: jpeg_ac_luminance_huffman_dec = {4'ha, 8'h52};
    16'b1111_1111_1001_1110: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h53};
    16'b1111_1111_1001_1111: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h54};
    16'b1111_1111_1010_0000: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h55};
    16'b1111_1111_1010_0001: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h56};
    16'b1111_1111_1010_0010: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h57};
    16'b1111_1111_1010_0011: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h58};
    16'b1111_1111_1010_0100: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h59};
    16'b1111_1111_1010_0101: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h5a};

    16'b1111_011?_????_????: jpeg_ac_luminance_huffman_dec = {4'h6, 8'h61};
    16'b1111_1111_0110_????: jpeg_ac_luminance_huffman_dec = {4'hb, 8'h62};
    16'b1111_1111_1010_0110: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h63};
    16'b1111_1111_1010_0111: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h64};
    16'b1111_1111_1010_1000: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h65};
    16'b1111_1111_1010_1001: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h66};
    16'b1111_1111_1010_1010: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h67};
    16'b1111_1111_1010_1011: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h68};
    16'b1111_1111_1010_1100: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h69};
    16'b1111_1111_1010_1101: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h6a};

    16'b1111_1010_????_????: jpeg_ac_luminance_huffman_dec = {4'h7, 8'h71};
    16'b1111_1111_0111_????: jpeg_ac_luminance_huffman_dec = {4'hb, 8'h72};
    16'b1111_1111_1010_1110: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h73};
    16'b1111_1111_1010_1111: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h74};
    16'b1111_1111_1011_0000: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h75};
    16'b1111_1111_1011_0001: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h76};
    16'b1111_1111_1011_0010: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h77};
    16'b1111_1111_1011_0011: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h78};
    16'b1111_1111_1011_0100: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h79};
    16'b1111_1111_1011_0101: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h7a};

    16'b1111_1100_0???_????: jpeg_ac_luminance_huffman_dec = {4'h8, 8'h81};
    16'b1111_1111_1000_000?: jpeg_ac_luminance_huffman_dec = {4'he, 8'h82};
    16'b1111_1111_1011_0110: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h83};
    16'b1111_1111_1011_0111: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h84};
    16'b1111_1111_1011_1000: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h85};
    16'b1111_1111_1011_1001: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h86};
    16'b1111_1111_1011_1010: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h87};
    16'b1111_1111_1011_1011: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h88};
    16'b1111_1111_1011_1100: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h89};
    16'b1111_1111_1011_1101: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h8a};

    16'b1111_1100_1???_????: jpeg_ac_luminance_huffman_dec = {4'h8, 8'h91};
    16'b1111_1111_1011_1110: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h92};
    16'b1111_1111_1011_1111: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h93};
    16'b1111_1111_1100_0000: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h94};
    16'b1111_1111_1100_0001: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h95};
    16'b1111_1111_1100_0010: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h96};
    16'b1111_1111_1100_0011: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h97};
    16'b1111_1111_1100_0100: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h98};
    16'b1111_1111_1100_0101: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h99};
    16'b1111_1111_1100_0110: jpeg_ac_luminance_huffman_dec = {4'hf, 8'h9a};

    16'b1111_1101_0???_????: jpeg_ac_luminance_huffman_dec = {4'h8, 8'ha1};
    16'b1111_1111_1100_0111: jpeg_ac_luminance_huffman_dec = {4'hf, 8'ha2};
    16'b1111_1111_1100_1000: jpeg_ac_luminance_huffman_dec = {4'hf, 8'ha3};
    16'b1111_1111_1100_1001: jpeg_ac_luminance_huffman_dec = {4'hf, 8'ha4};
    16'b1111_1111_1100_1010: jpeg_ac_luminance_huffman_dec = {4'hf, 8'ha5};
    16'b1111_1111_1100_1011: jpeg_ac_luminance_huffman_dec = {4'hf, 8'ha6};
    16'b1111_1111_1100_1100: jpeg_ac_luminance_huffman_dec = {4'hf, 8'ha7};
    16'b1111_1111_1100_1101: jpeg_ac_luminance_huffman_dec = {4'hf, 8'ha8};
    16'b1111_1111_1100_1110: jpeg_ac_luminance_huffman_dec = {4'hf, 8'ha9};
    16'b1111_1111_1100_1111: jpeg_ac_luminance_huffman_dec = {4'hf, 8'haa};

    16'b1111_1110_01??_????: jpeg_ac_luminance_huffman_dec = {4'h9, 8'hb1};
    16'b1111_1111_1101_0000: jpeg_ac_luminance_huffman_dec = {4'hf, 8'hb2};
    16'b1111_1111_1101_0001: jpeg_ac_luminance_huffman_dec = {4'hf, 8'hb3};
    16'b1111_1111_1101_0010: jpeg_ac_luminance_huffman_dec = {4'hf, 8'hb4};
    16'b1111_1111_1101_0011: jpeg_ac_luminance_huffman_dec = {4'hf, 8'hb5};
    16'b1111_1111_1101_0100: jpeg_ac_luminance_huffman_dec = {4'hf, 8'hb6};
    16'b1111_1111_1101_0101: jpeg_ac_luminance_huffman_dec = {4'hf, 8'hb7};
    16'b1111_1111_1101_0110: jpeg_ac_luminance_huffman_dec = {4'hf, 8'hb8};
    16'b1111_1111_1101_0111: jpeg_ac_luminance_huffman_dec = {4'hf, 8'hb9};
    16'b1111_1111_1101_1000: jpeg_ac_luminance_huffman_dec = {4'hf, 8'hba};

    16'b1111_1110_10??_????: jpeg_ac_luminance_huffman_dec = {4'h9, 8'hc1};
    16'b1111_1111_1101_1001: jpeg_ac_luminance_huffman_dec = {4'hf, 8'hc2};
    16'b1111_1111_1101_1010: jpeg_ac_luminance_huffman_dec = {4'hf, 8'hc3};
    16'b1111_1111_1101_1011: jpeg_ac_luminance_huffman_dec = {4'hf, 8'hc4};
    16'b1111_1111_1101_1100: jpeg_ac_luminance_huffman_dec = {4'hf, 8'hc5};
    16'b1111_1111_1101_1101: jpeg_ac_luminance_huffman_dec = {4'hf, 8'hc6};
    16'b1111_1111_1101_1110: jpeg_ac_luminance_huffman_dec = {4'hf, 8'hc7};
    16'b1111_1111_1101_1111: jpeg_ac_luminance_huffman_dec = {4'hf, 8'hc8};
    16'b1111_1111_1110_0000: jpeg_ac_luminance_huffman_dec = {4'hf, 8'hc9};
    16'b1111_1111_1110_0001: jpeg_ac_luminance_huffman_dec = {4'hf, 8'hca};

    16'b1111_1111_000?_????: jpeg_ac_luminance_huffman_dec = {4'ha, 8'hd1};
    16'b1111_1111_1110_0010: jpeg_ac_luminance_huffman_dec = {4'hf, 8'hd2};
    16'b1111_1111_1110_0011: jpeg_ac_luminance_huffman_dec = {4'hf, 8'hd3};
    16'b1111_1111_1110_0100: jpeg_ac_luminance_huffman_dec = {4'hf, 8'hd4};
    16'b1111_1111_1110_0101: jpeg_ac_luminance_huffman_dec = {4'hf, 8'hd5};
    16'b1111_1111_1110_0110: jpeg_ac_luminance_huffman_dec = {4'hf, 8'hd6};
    16'b1111_1111_1110_0111: jpeg_ac_luminance_huffman_dec = {4'hf, 8'hd7};
    16'b1111_1111_1110_1000: jpeg_ac_luminance_huffman_dec = {4'hf, 8'hd8};
    16'b1111_1111_1110_1001: jpeg_ac_luminance_huffman_dec = {4'hf, 8'hd9};
    16'b1111_1111_1110_1010: jpeg_ac_luminance_huffman_dec = {4'hf, 8'hda};

    16'b1111_1111_1110_1011: jpeg_ac_luminance_huffman_dec = {4'hf, 8'he1};
    16'b1111_1111_1110_1100: jpeg_ac_luminance_huffman_dec = {4'hf, 8'he2};
    16'b1111_1111_1110_1101: jpeg_ac_luminance_huffman_dec = {4'hf, 8'he3};
    16'b1111_1111_1110_1110: jpeg_ac_luminance_huffman_dec = {4'hf, 8'he4};
    16'b1111_1111_1110_1111: jpeg_ac_luminance_huffman_dec = {4'hf, 8'he5};
    16'b1111_1111_1111_0000: jpeg_ac_luminance_huffman_dec = {4'hf, 8'he6};
    16'b1111_1111_1111_0001: jpeg_ac_luminance_huffman_dec = {4'hf, 8'he7};
    16'b1111_1111_1111_0010: jpeg_ac_luminance_huffman_dec = {4'hf, 8'he8};
    16'b1111_1111_1111_0011: jpeg_ac_luminance_huffman_dec = {4'hf, 8'he9};
    16'b1111_1111_1111_0100: jpeg_ac_luminance_huffman_dec = {4'hf, 8'hea};

    16'b1111_1111_001?_????: jpeg_ac_luminance_huffman_dec = {4'ha, 8'hf0}; // ZRL
    16'b1111_1111_1111_0101: jpeg_ac_luminance_huffman_dec = {4'hf, 8'hf1};
    16'b1111_1111_1111_0110: jpeg_ac_luminance_huffman_dec = {4'hf, 8'hf2};
    16'b1111_1111_1111_0111: jpeg_ac_luminance_huffman_dec = {4'hf, 8'hf3};
    16'b1111_1111_1111_1000: jpeg_ac_luminance_huffman_dec = {4'hf, 8'hf4};
    16'b1111_1111_1111_1001: jpeg_ac_luminance_huffman_dec = {4'hf, 8'hf5};
    16'b1111_1111_1111_1010: jpeg_ac_luminance_huffman_dec = {4'hf, 8'hf6};
    16'b1111_1111_1111_1011: jpeg_ac_luminance_huffman_dec = {4'hf, 8'hf7};
    16'b1111_1111_1111_1100: jpeg_ac_luminance_huffman_dec = {4'hf, 8'hf8};
    16'b1111_1111_1111_1101: jpeg_ac_luminance_huffman_dec = {4'hf, 8'hf9};
    16'b1111_1111_1111_1110: jpeg_ac_luminance_huffman_dec = {4'hf, 8'hfa};

  endcase
end
endfunction // jpeg_ac_luminance_huffman_dec


/*
  J P E G _ A C _ C H R O M I N A N C E _ H U F F M A N _ D E C

  ITU-T.81 annex K.3.2 Table K.5

  This function translates the default Huffman codeword into
  chrominance AC (RunLength, Size) codepair.

  Output is given as:
  codelength[3:0]-1, RunLength[3:0], size[3:0]

  The codewords are left-alligned to ease bitstream decomposition.

  example:
  codeword   = 16'b0000_0001_1111_0111
  codelength = 8 +1 = 9
  ac_luminance_run_length      = 3
  ac_limunance_size (category) = 2
*/
function [11:0] jpeg_ac_chrominance_huffman_dec;
  input [15:0] codeword;
begin
  casex(codeword) // synopsys full_case parallel_case
    16'b00??_????_????_????: jpeg_ac_chrominance_huffman_dec = {4'h1, 8'h00}; // EOB
    16'b01??_????_????_????: jpeg_ac_chrominance_huffman_dec = {4'h1, 8'h01};
    16'b100?_????_????_????: jpeg_ac_chrominance_huffman_dec = {4'h2, 8'h02};
    16'b1010_????_????_????: jpeg_ac_chrominance_huffman_dec = {4'h3, 8'h03};
    16'b1100_0???_????_????: jpeg_ac_chrominance_huffman_dec = {4'h4, 8'h04};
    16'b1100_1???_????_????: jpeg_ac_chrominance_huffman_dec = {4'h4, 8'h05};
    16'b1110_00??_????_????: jpeg_ac_chrominance_huffman_dec = {4'h5, 8'h06};
    16'b1111_000?_????_????: jpeg_ac_chrominance_huffman_dec = {4'h6, 8'h07};
    16'b1111_1010_0???_????: jpeg_ac_chrominance_huffman_dec = {4'h8, 8'h08};
    16'b1111_1101_10??_????: jpeg_ac_chrominance_huffman_dec = {4'h9, 8'h09};
    16'b1111_1111_0100_????: jpeg_ac_chrominance_huffman_dec = {4'hb, 8'h0a};

    16'b1011_????_????_????: jpeg_ac_chrominance_huffman_dec = {4'h3, 8'h11};
    16'b1110_01??_????_????: jpeg_ac_chrominance_huffman_dec = {4'h5, 8'h12};
    16'b1111_0110_????_????: jpeg_ac_chrominance_huffman_dec = {4'h7, 8'h13};
    16'b1111_1010_1???_????: jpeg_ac_chrominance_huffman_dec = {4'h8, 8'h14};
    16'b1111_1110_110?_????: jpeg_ac_chrominance_huffman_dec = {4'ha, 8'h15};
    16'b1111_1111_0101_????: jpeg_ac_chrominance_huffman_dec = {4'hb, 8'h16};
    16'b1111_1111_1000_1000: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h17};
    16'b1111_1111_1000_1001: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h18};
    16'b1111_1111_1000_1010: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h19};
    16'b1111_1111_1000_1011: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h1a};

    16'b1101_0???_????_????: jpeg_ac_chrominance_huffman_dec = {4'h4, 8'h21};
    16'b1111_0111_????_????: jpeg_ac_chrominance_huffman_dec = {4'h7, 8'h22};
    16'b1111_1101_11??_????: jpeg_ac_chrominance_huffman_dec = {4'h9, 8'h23};
    16'b1111_1111_0110_????: jpeg_ac_chrominance_huffman_dec = {4'hb, 8'h24};
    16'b1111_1111_1000_010?: jpeg_ac_chrominance_huffman_dec = {4'he, 8'h25};
    16'b1111_1111_1000_1100: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h26};
    16'b1111_1111_1000_1101: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h27};
    16'b1111_1111_1000_1110: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h28};
    16'b1111_1111_1000_1111: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h29};
    16'b1111_1111_1001_0000: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h2a};

    16'b1101_1???_????_????: jpeg_ac_chrominance_huffman_dec = {4'h4, 8'h31};
    16'b1111_1000_????_????: jpeg_ac_chrominance_huffman_dec = {4'h7, 8'h32};
    16'b1111_1110_00??_????: jpeg_ac_chrominance_huffman_dec = {4'h9, 8'h33};
    16'b1111_1111_0111_????: jpeg_ac_chrominance_huffman_dec = {4'hb, 8'h34};
    16'b1111_1111_1001_0001: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h35};
    16'b1111_1111_1001_0010: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h36};
    16'b1111_1111_1001_0011: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h37};
    16'b1111_1111_1001_0100: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h38};
    16'b1111_1111_1001_0101: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h39};
    16'b1111_1111_1001_0110: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h3a};

    16'b1110_10??_????_????: jpeg_ac_chrominance_huffman_dec = {4'h5, 8'h41};
    16'b1111_1011_0???_????: jpeg_ac_chrominance_huffman_dec = {4'h8, 8'h42};
    16'b1111_1111_1001_0111: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h43};
    16'b1111_1111_1001_1000: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h44};
    16'b1111_1111_1001_1001: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h45};
    16'b1111_1111_1001_1010: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h46};
    16'b1111_1111_1001_1011: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h47};
    16'b1111_1111_1001_1100: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h48};
    16'b1111_1111_1001_1101: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h49};
    16'b1111_1111_1001_1110: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h4a};

    16'b1110_11??_????_????: jpeg_ac_chrominance_huffman_dec = {4'h5, 8'h51};
    16'b1111_1110_01??_????: jpeg_ac_chrominance_huffman_dec = {4'h9, 8'h52};
    16'b1111_1111_1001_1111: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h53};
    16'b1111_1111_1010_0000: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h54};
    16'b1111_1111_1010_0001: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h55};
    16'b1111_1111_1010_0010: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h56};
    16'b1111_1111_1010_0011: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h57};
    16'b1111_1111_1010_0100: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h58};
    16'b1111_1111_1010_0101: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h59};
    16'b1111_1111_1010_0110: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h5a};

    16'b1111_001?_????_????: jpeg_ac_chrominance_huffman_dec = {4'h6, 8'h61};
    16'b1111_1110_111?_????: jpeg_ac_chrominance_huffman_dec = {4'ha, 8'h62};
    16'b1111_1111_1010_0111: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h63};
    16'b1111_1111_1010_1000: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h64};
    16'b1111_1111_1010_1001: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h65};
    16'b1111_1111_1010_1010: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h66};
    16'b1111_1111_1010_1011: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h67};
    16'b1111_1111_1010_1100: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h68};
    16'b1111_1111_1010_1101: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h69};
    16'b1111_1111_1010_1110: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h6a};

    16'b1111_010?_????_????: jpeg_ac_chrominance_huffman_dec = {4'h6, 8'h71};
    16'b1111_1111_000?_????: jpeg_ac_chrominance_huffman_dec = {4'ha, 8'h72};
    16'b1111_1111_1010_1111: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h73};
    16'b1111_1111_1011_0000: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h74};
    16'b1111_1111_1011_0001: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h75};
    16'b1111_1111_1011_0010: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h76};
    16'b1111_1111_1011_0011: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h77};
    16'b1111_1111_1011_0100: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h78};
    16'b1111_1111_1011_0101: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h79};
    16'b1111_1111_1011_0110: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h7a};

    16'b1111_1001_????_????: jpeg_ac_chrominance_huffman_dec = {4'h7, 8'h81};
    16'b1111_1111_1011_0111: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h82};
    16'b1111_1111_1011_1000: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h83};
    16'b1111_1111_1011_1001: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h84};
    16'b1111_1111_1011_1010: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h85};
    16'b1111_1111_1011_1011: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h86};
    16'b1111_1111_1011_1100: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h87};
    16'b1111_1111_1011_1101: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h88};
    16'b1111_1111_1011_1110: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h89};
    16'b1111_1111_1011_1111: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h8a};

    16'b1111_1011_1???_????: jpeg_ac_chrominance_huffman_dec = {4'h8, 8'h91};
    16'b1111_1111_1100_0000: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h92};
    16'b1111_1111_1100_0001: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h93};
    16'b1111_1111_1100_0010: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h94};
    16'b1111_1111_1100_0011: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h95};
    16'b1111_1111_1100_0100: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h96};
    16'b1111_1111_1100_0101: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h97};
    16'b1111_1111_1100_0110: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h98};
    16'b1111_1111_1100_0111: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h99};
    16'b1111_1111_1100_1000: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'h9a};

    16'b1111_1100_0???_????: jpeg_ac_chrominance_huffman_dec = {4'h8, 8'ha1};
    16'b1111_1111_1100_1001: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'ha2};
    16'b1111_1111_1100_1010: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'ha3};
    16'b1111_1111_1100_1011: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'ha4};
    16'b1111_1111_1100_1100: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'ha5};
    16'b1111_1111_1100_1101: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'ha6};
    16'b1111_1111_1100_1110: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'ha7};
    16'b1111_1111_1100_1111: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'ha8};
    16'b1111_1111_1101_0000: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'ha9};
    16'b1111_1111_1101_0001: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'haa};

    16'b1111_1100_1???_????: jpeg_ac_chrominance_huffman_dec = {4'h8, 8'hb1};
    16'b1111_1111_1101_0010: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'hb2};
    16'b1111_1111_1101_0011: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'hb3};
    16'b1111_1111_1101_0100: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'hb4};
    16'b1111_1111_1101_0101: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'hb5};
    16'b1111_1111_1101_0110: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'hb6};
    16'b1111_1111_1101_0111: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'hb7};
    16'b1111_1111_1101_1000: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'hb8};
    16'b1111_1111_1101_1001: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'hb9};
    16'b1111_1111_1101_1010: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'hba};

    16'b1111_1101_0???_????: jpeg_ac_chrominance_huffman_dec = {4'h8, 8'hc1};
    16'b1111_1111_1101_1011: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'hc2};
    16'b1111_1111_1101_1100: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'hc3};
    16'b1111_1111_1101_1101: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'hc4};
    16'b1111_1111_1101_1110: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'hc5};
    16'b1111_1111_1101_1111: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'hc6};
    16'b1111_1111_1110_0000: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'hc7};
    16'b1111_1111_1110_0001: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'hc8};
    16'b1111_1111_1110_0010: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'hc9};
    16'b1111_1111_1110_0011: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'hca};

    16'b1111_1111_001?_????: jpeg_ac_chrominance_huffman_dec = {4'ha, 8'hd1};
    16'b1111_1111_1110_0100: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'hd2};
    16'b1111_1111_1110_0101: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'hd3};
    16'b1111_1111_1110_0110: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'hd4};
    16'b1111_1111_1110_0111: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'hd5};
    16'b1111_1111_1110_1000: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'hd6};
    16'b1111_1111_1110_1001: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'hd7};
    16'b1111_1111_1110_1010: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'hd8};
    16'b1111_1111_1110_1011: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'hd9};
    16'b1111_1111_1110_1100: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'hda};

    16'b1111_1111_1000_00??: jpeg_ac_chrominance_huffman_dec = {4'hd, 8'he1};
    16'b1111_1111_1110_1101: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'he2};
    16'b1111_1111_1110_1110: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'he3};
    16'b1111_1111_1110_1111: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'he4};
    16'b1111_1111_1111_0000: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'he5};
    16'b1111_1111_1111_0001: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'he6};
    16'b1111_1111_1111_0010: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'he7};
    16'b1111_1111_1111_0011: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'he8};
    16'b1111_1111_1111_0100: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'he9};
    16'b1111_1111_1111_0101: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'hea};

    16'b1111_1110_10??_????: jpeg_ac_chrominance_huffman_dec = {4'h9, 8'hf0};
    16'b1111_1111_1000_011?: jpeg_ac_chrominance_huffman_dec = {4'he, 8'hf1};
    16'b1111_1111_1111_0110: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'hf2};
    16'b1111_1111_1111_0111: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'hf3};
    16'b1111_1111_1111_1000: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'hf4};
    16'b1111_1111_1111_1001: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'hf5};
    16'b1111_1111_1111_1010: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'hf6};
    16'b1111_1111_1111_1011: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'hf7};
    16'b1111_1111_1111_1100: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'hf8};
    16'b1111_1111_1111_1101: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'hf9};
    16'b1111_1111_1111_1110: jpeg_ac_chrominance_huffman_dec = {4'hf, 8'hfa};
  endcase
end
endfunction // jpeg_ac_chrominance_huffman_dec
