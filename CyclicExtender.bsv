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
import LibraryFunctions::*;


import Vector::*;
import FIFO::*;

(* synthesize *)
module mkCyclicExtender(CyclicExtender#(64,81));

   FIFO#(MsgComplexFVec#(64)) fifoQ <- mkLFIFO();
   
   method Action fromIFFT(MsgComplexFVec#(64) x);
      fifoQ.enq(x);
   endmethod

   method ActionValue#(MsgComplexFVec#(81)) toAnalogTX();   
     fifoQ.deq();
     Vector#(64, ComplexF#(16))       v = (fifoQ.first().data);
     Vector#(1 , ComplexF#(16))    last = v_truncate(v);
     Vector#(16, ComplexF#(16))  prefix = v_rtruncate(v);
     
     return MsgComplexFVec{
	       new_message : True,
	       data        : Vector::append(Vector::append(last,v),prefix)
	};
      
   endmethod
   
endmodule   
