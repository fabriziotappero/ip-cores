// The MIT License
//
// Copyright (c) 2006 Nirav Dave (ndave@csail.mit.edu)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.




import ComplexF::*;
import DataTypes::*;

import LibraryFunctions::*;
import Vector::*;


//This function just serves as a short hand for grabbing 4 consecutive indices in
//a vector
function Vector#(4, a) take4(Vector#(n, a) sv, alpha idx)
  provisos (Add#(4,k,n), Log#(n,logn),
            Eq#(alpha), Literal#(alpha), Arith#(alpha), Ord#(alpha),
	    PrimIndex#(alpha, beta)
            );
  Vector#(4,a) retval = newVector();  
  
  for(alpha i = 0; i < 4; i = i + 1)
     retval[i] = sv[idx+i];
  return retval;
endfunction


// The Radix function. Note that it is noinlined, because 
// there's no point in doing a per-instance optimizations
(* noinline *)
function Radix4Data radix4(OmegaData omegas,
                           Radix4Data xs);

   Radix4Data retval = newVector();

   ComplexF#(16) alpha = xs[0];
   ComplexF#(16) beta = omegas[0] * xs[1];
   ComplexF#(16) gamma = omegas[1] * xs[2];
   ComplexF#(16) delta = omegas[2] * xs[3];

   ComplexF#(16) tao_0 = alpha + gamma;
   ComplexF#(16) tao_1 = alpha - gamma;
   ComplexF#(16) tao_2 = beta + delta;
   ComplexF#(16) tao_3 = beta - delta;

   // rotate tao_3 by 90 degrees
   ComplexF#(16) tao_3_rot90;
   tao_3_rot90.i = -tao_3.q;
   tao_3_rot90.q = tao_3.i;

   retval[0] = tao_0 + tao_2;
   retval[1] = tao_1 - tao_3_rot90;
   retval[2] = tao_0 - tao_2;
   retval[3] = tao_1 + tao_3_rot90;

   return retval;
endfunction



//This describes a permutation such that
//If the ith value in this is j, then the
//ith value of the output will be the jth
// input value.

// This permutation is used on the values directly into the IFFT

function Vector#(64, Integer) reorder();
   Vector#(64, Integer) retval = replicate(?);

   retval[ 0] =  0;
   retval[ 1] = 16;
   retval[ 2] = 32;
   retval[ 3] = 48;
   retval[ 4] =  4;
   retval[ 5] = 20;
   retval[ 6] = 36;
   retval[ 7] = 52;
   retval[ 8] =  8;
   retval[ 9] = 24;
   retval[10] = 40;
   retval[11] = 56;
   retval[12] = 12;
   retval[13] = 28;
   retval[14] = 44;
   retval[15] = 60;
   
   retval[16] =  1;
   retval[17] = 17;
   retval[18] = 33;
   retval[19] = 49;
   retval[20] =  5;
   retval[21] = 21;
   retval[22] = 37;
   retval[23] = 53;
   retval[24] =  9;
   retval[25] = 25;
   retval[26] = 41;
   retval[27] = 57;
   retval[28] = 13;
   retval[29] = 29;
   retval[30] = 45;
   retval[31] = 61;
   
   retval[32] =  2;
   retval[33] = 18;
   retval[34] = 34;
   retval[35] = 50;
   retval[36] =  6;
   retval[37] = 22;
   retval[38] = 38;
   retval[39] = 54;
   retval[40] = 10;
   retval[41] = 26;
   retval[42] = 42;
   retval[43] = 58;
   retval[44] = 14;
   retval[45] = 30;
   retval[46] = 46;
   retval[47] = 62;
   
   retval[48] =  3;
   retval[49] = 19;
   retval[50] = 35;
   retval[51] = 51;
   retval[52] =  7;
   retval[53] = 23;
   retval[54] = 39;
   retval[55] = 55;
   retval[56] = 11;
   retval[57] = 27;
   retval[58] = 43;
   retval[59] = 59;
   retval[60] = 15;
   retval[61] = 31;
   retval[62] = 47;
   retval[63] = 63;

   return retval;
endfunction

// Similiar to the reorder ipermuation. However, this is used after each set of 16 radices
function Vector#(64, Integer) permute();
   Vector#(64, Integer) retval = replicate(?);
  
   retval[ 0] =  0;
   retval[ 1] =  4;
   retval[ 2] =  8;
   retval[ 3] = 12;
   retval[ 4] = 16;
   retval[ 5] = 20;
   retval[ 6] = 24;
   retval[ 7] = 28;
   retval[ 8] = 32;
   retval[ 9] = 36;
   retval[10] = 40;
   retval[11] = 44;
   retval[12] = 48;
   retval[13] = 52;
   retval[14] = 56;
   retval[15] = 60;
   
   retval[16] =  1;
   retval[17] =  5;
   retval[18] =  9;
   retval[19] = 13;
   retval[20] = 17;
   retval[21] = 21;
   retval[22] = 25;
   retval[23] = 29;
   retval[24] = 33;
   retval[25] = 37;
   retval[26] = 41;
   retval[27] = 45;
   retval[28] = 49;
   retval[29] = 53;
   retval[30] = 57;
   retval[31] = 61;
   
   retval[32] =  2;
   retval[33] =  6;
   retval[34] = 10;
   retval[35] = 14;
   retval[36] = 18;
   retval[37] = 22;
   retval[38] = 26;
   retval[39] = 30;
   retval[40] = 34;
   retval[41] = 38;
   retval[42] = 42;
   retval[43] = 46;
   retval[44] = 50;
   retval[45] = 54;
   retval[46] = 58;
   retval[47] = 62;
   
   retval[48] =  3;
   retval[49] =  7;
   retval[50] = 11;
   retval[51] = 15;
   retval[52] = 19;
   retval[53] = 23;
   retval[54] = 27;
   retval[55] = 31;
   retval[56] = 35;
   retval[57] = 39;
   retval[58] = 43;
   retval[59] = 47;
   retval[60] = 51;
   retval[61] = 55;
   retval[62] = 59;
   retval[63] = 63;

   return retval;
endfunction

// Calculate the correct omegas. This gets sent into the
// radix4 block
function Vector#(3, ComplexF#(16)) omega(Bit#(2) stage, Bit#(4) index);

  Vector#(3, ComplexF#(16)) retval = replicate(?);

  case(stage)
   // stage 1
   0:
    begin
      retval[0].i = 16'h7fff;   retval[0].q = 16'h0000;
      retval[1].i = 16'h7fff;   retval[1].q = 16'h0000;
      retval[2].i = 16'h7fff;   retval[2].q = 16'h0000;
    end
   // stage 2
   1:
    case(index >> 2)
      0: begin
           retval[0].i = 16'h7fff;   retval[0].q = 16'h0000;
           retval[1].i = 16'h7fff;   retval[1].q = 16'h0000;
           retval[2].i = 16'h7fff;   retval[2].q = 16'h0000;
         end
      1: begin
           retval[0].i = 16'h7640;   retval[0].q = 16'hcf05;
           retval[1].i = 16'h5a81;   retval[1].q = 16'ha57f;
           retval[2].i = 16'h30fb;   retval[2].q = 16'h89c0;
         end
      2: begin
           retval[0].i = 16'h5a81;   retval[0].q = 16'ha57f;
           retval[1].i = 16'h0000;   retval[1].q = 16'h8000;
           retval[2].i = 16'ha57f;   retval[2].q = 16'ha57f;
         end
      3: begin
           retval[0].i = 16'h30fb;   retval[0].q = 16'h89c0;
           retval[1].i = 16'ha57f;   retval[1].q = 16'ha57f;
           retval[2].i = 16'h89c0;   retval[2].q = 16'h30fb;
         end
    endcase
   // stage 3
   2:
    case(index)
      0: begin
           retval[0].i = 16'h7fff;   retval[0].q = 16'h0000;
           retval[1].i = 16'h7fff;   retval[1].q = 16'h0000;
           retval[2].i = 16'h7fff;   retval[2].q = 16'h0000;
         end
      1: begin
           retval[0].i = 16'h7f61;   retval[0].q = 16'hf375;
           retval[1].i = 16'h7d89;   retval[1].q = 16'he708;
           retval[2].i = 16'h7a7c;   retval[2].q = 16'hdad9;
         end
      2: begin
           retval[0].i = 16'h7d89;   retval[0].q = 16'he708;
           retval[1].i = 16'h7640;   retval[1].q = 16'hcf05;
           retval[2].i = 16'h6a6c;   retval[2].q = 16'hb8e4;
         end
      3: begin
           retval[0].i = 16'h7a7c;   retval[0].q = 16'hdad9;
           retval[1].i = 16'h6a6c;   retval[1].q = 16'hb8e4;
           retval[2].i = 16'h5133;   retval[2].q = 16'h9d0f;
         end
      4: begin
           retval[0].i = 16'h7640;   retval[0].q = 16'hcf05;
           retval[1].i = 16'h5a81;   retval[1].q = 16'ha57f;
           retval[2].i = 16'h30fb;   retval[2].q = 16'h89c0;
         end
      5: begin
           retval[0].i = 16'h70e1;   retval[0].q = 16'hc3aa;
           retval[1].i = 16'h471c;   retval[1].q = 16'h9594;
           retval[2].i = 16'h0c8b;   retval[2].q = 16'h809f;
         end
      6: begin
           retval[0].i = 16'h6a6c;   retval[0].q = 16'hb8e4;
           retval[1].i = 16'h30fb;   retval[1].q = 16'h89c0;
           retval[2].i = 16'he708;   retval[2].q = 16'h8277;
         end
      7: begin
           retval[0].i = 16'h62f1;   retval[0].q = 16'haecd;
           retval[1].i = 16'h18f8;   retval[1].q = 16'h8277;
           retval[2].i = 16'hc3aa;   retval[2].q = 16'h8f1f;
         end
      8: begin
           retval[0].i = 16'h5a81;   retval[0].q = 16'ha57f;
           retval[1].i = 16'h0000;   retval[1].q = 16'h8000;
           retval[2].i = 16'ha57f;   retval[2].q = 16'ha57f;
         end
      9: begin
           retval[0].i = 16'h5133;   retval[0].q = 16'h9d0f;
           retval[1].i = 16'he708;   retval[1].q = 16'h8277;
           retval[2].i = 16'h8f1f;   retval[2].q = 16'hc3aa;
        end
      10: begin
            retval[0].i = 16'h471c;   retval[0].q = 16'h9594;
            retval[1].i = 16'hcf05;   retval[1].q = 16'h89c0;
            retval[2].i = 16'h8277;   retval[2].q = 16'he708;
          end
      11: begin
            retval[0].i = 16'h3c56;   retval[0].q = 16'h8f1f;
            retval[1].i = 16'hb8e4;   retval[1].q = 16'h9594;
            retval[2].i = 16'h809f;   retval[2].q = 16'h0c8b;
          end
      12: begin
            retval[0].i = 16'h30fb;   retval[0].q = 16'h89c0;
            retval[1].i = 16'ha57f;   retval[1].q = 16'ha57f;
            retval[2].i = 16'h89c0;   retval[2].q = 16'h30fb;
          end
      13: begin
            retval[0].i = 16'h2527;   retval[0].q = 16'h8584;
            retval[1].i = 16'h9594;   retval[1].q = 16'hb8e4;
            retval[2].i = 16'h9d0f;   retval[2].q = 16'h5133;
          end
      14: begin
            retval[0].i = 16'h18f8;   retval[0].q = 16'h8277;
            retval[1].i = 16'h89c0;   retval[1].q = 16'hcf05;
            retval[2].i = 16'hb8e4;   retval[2].q = 16'h6a6c;
          end
      15: begin
            retval[0].i = 16'h0c8b;   retval[0].q = 16'h809f;
            retval[1].i = 16'h8277;   retval[1].q = 16'he708;
            retval[2].i = 16'hdad9;   retval[2].q = 16'h7a7c;
          end
    endcase
  endcase
   
  return retval;
endfunction


// This is the stage function which does the IFFT in 3 stages
(* noinline *)
function IFFTData stagefunction(Bit#(2) stage, IFFTData s_in);
  
   IFFTData s_mid = newVector();
   for(Integer i = 0; i < 16; i = i + 1)
     begin
       Nat four_i = fromInteger(4*i);
       Radix4Data temp = radix4(omega(stage, fromInteger(i)),
                                take4(s_in, four_i));
       for(Integer j = 0; j < 4; j = j + 1)
         s_mid[4*i+j]  = temp[j];
     end

     // permute
     IFFTData s_out = newVector();
     for(Integer i = 0; i < 64; i = i + 1)
       s_out[i] = s_mid[permute[i]];
   
  return (s_out);

endfunction

//These two functions are little hacks which prevent the compiler
//from optimizing past these function boundaries.
(* noinline *)
function IFFTData stopOpt64(IFFTData s_in);
  return s_in;
endfunction  
 
function Vector#(4, ComplexF#(16)) stopOpt4(Vector#(4, ComplexF#(16)) s_in);
  return s_in;
endfunction  

// This is a stage function which does the IFFT in 48 stages, doing 
// 1 radix4 each stage and permuting the values every 16 cycles.

(* noinline *)
function IFFTData stagefunction2(Bit#(6) stage, IFFTData s_in);
  
   IFFTData s_mid = stopOpt64(s_in);
   Bit#(4) step  = stage[3:0]; 
   Bit#(6) step4 = {step,2'b00};  
  
   Radix4Data temp = radix4(omega(stage[5:4],step),
                            take4(s_in, step4));

   for(Bit#(6) j = 0; j < 4; j = j + 1)
      s_mid = update(s_mid, step4+j,temp[j]);

   // permute
   IFFTData s_mid2 = stopOpt64(s_mid);
   IFFTData s_out  = newVector();
  
   for(Integer i = 0; i < 64; i = i + 1)
     s_out[i] = s_mid2[permute[i]];
   
  return ((step == 15) ? s_out : s_mid2);

endfunction
