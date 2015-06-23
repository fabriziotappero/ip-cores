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
import Interfaces::*;
import IFFT_Library::*;

import Pipelines::*;
import FIFO::*;
import FIFOF::*;
import Vector::*;


(* synthesize *)
module  mkIFFT_Circ(IFFT#(64));
  let _x <- mkIFFT(mkPipeline_Circ(2'd3, 2'd1, stagefunction));
  return (_x);
endmodule  

(* synthesize *)
module  mkIFFT_Pipe(IFFT#(64));
  let _x <- mkIFFT(mkPipeline_Sync(2'd3, 2'd1, stagefunction));
  return (_x);
endmodule  

(* synthesize *)
module  mkIFFT_Comb(IFFT#(64));
  let _x <- mkIFFT(mkPipeline_Comb(2'd3, 2'd1, stagefunction));
  return (_x);
endmodule  

(* synthesize *)
module  mkIFFT_Circ_w_1Radix(IFFT#(64));
  let _x <- mkIFFT(mkPipeline_Circ(6'd48, 6'd1, stagefunction2));
  return (_x);
endmodule  

(* synthesize *)
module  mkIFFT_Circ_w_2Radix(IFFT#(64));
  let _x <- mkIFFT(mkPipeline_Circ(6'd48, 6'd2, stagefunction2));
  return (_x);
endmodule 

(* synthesize *)
module  mkIFFT_Circ_w_4Radix(IFFT#(64));
  let _x <- mkIFFT(mkPipeline_Circ(6'd48, 6'd4, stagefunction2));
  return (_x);
endmodule 

(* synthesize *)
module  mkIFFT_Circ_w_8Radix(IFFT#(64));
  let _x <- mkIFFT(mkPipeline_Circ(6'd48, 6'd8, stagefunction2));
  return (_x);
endmodule 


module [Module] mkIFFT#(Module#(Pipeline#(IFFTData)) mkP)
              (IFFT#(64));

   Pipeline#(IFFTData) p <- mkP(); 
  
   method Action fromMapper(MsgComplexFVec#(64) x);
     IFFTData data = x.data;
     IFFTData reordered_data = newVector();
     for(Integer i = 0; i < 64; i = i + 1)
       begin
         // note swapped values
	 reordered_data[i].i = data[63-reorder[i]].q;
	 reordered_data[i].q = data[63-reorder[i]].i;
       end
     p.put(reordered_data);
   endmethod

   // output to cyclic extend queue method

   method ActionValue#(MsgComplexFVec#(64)) toCyclicExtender();

     IFFTData data <- p.get();

     IFFTData data_out = newVector();
     for(Integer i = 0; i < 64; i = i + 1)
       begin
	 data_out[i].i = data[63-i].q;
	 data_out[i].q = data[63-i].i;
       end
     return(MsgComplexFVec{
              new_message: True, 
	      data       : data_out
             });
   endmethod

  
  
  
  
endmodule
