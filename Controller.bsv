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




import FIFO::*;
import DataTypes::*;
import Interfaces::*;
import LibraryFunctions::*;

function Header#(24) makeHeader(Rate rate, Bit#(12) length);
   function Bit#(4) translate_rate(Rate r);
      case (r)
	R1:      return 4'b1101;
	R2:      return 4'b1111;
	R4:      return 4'b0101;
	default: return ?;
      endcase
   endfunction

   function Bit#(12) translate_length (Bit#(12) x) = reverseBits(x);
   
   Bit#(1) parity = getParity({translate_rate(rate),length});
      
   return({translate_rate(rate),1'b0,translate_length(length),parity,6'b0});
   
endfunction


(* synthesize *)
module mkController(Controller#(24,24,24));
  FIFO#(RateData#(24)) toS  <- mkFIFO();
  FIFO#(Header#(24))   toC  <- mkFIFO();

  Reg#(Bool)     active <- mkReg(False);
  Reg#(Bit#(12)) length <- mkRegU;
  Reg#(Rate)       rate <- mkRegU;
 
  method Action getFromMAC(TXMAC2ControllerInfo x) if (!active);
     active <= True;
     length <= x.length();
     rate   <= x.rate();
     toC.enq( makeHeader(x.rate, x.length));
  endmethod

  method Action getDataFromMAC(Data#(24) x) if (active);
     toS.enq(RateData{
	       rate: rate,
	       data: x.data
	      });
     rate   <= RNone;
     length <= length - 3;
     if (length <= 3 )
	active <= False;
  endmethod
   
  method ActionValue#(Header#(24)) getHeader();
     toC.deq();
     return(toC.first);
  endmethod
   
  method ActionValue#(RateData#(24)) getData();
     toS.deq();
     return(toS.first);
  endmethod

endmodule
