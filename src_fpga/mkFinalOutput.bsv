
// The MIT License

// Copyright (c) 2006-2007 Massachusetts Institute of Technology

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

//**********************************************************************
// final output implementation
//----------------------------------------------------------------------
//
//

package mkFinalOutput;

import H264Types::*;
import IFinalOutput::*;
import FIFO::*;

import Connectable::*;
import GetPut::*;

//-----------------------------------------------------------
// Final Output Module
//-----------------------------------------------------------

module mkFinalOutput( IFinalOutput );

   FIFO#(BufferControlOT)  infifo    <- mkFIFO;

   //-----------------------------------------------------------
   // Rules
   rule finalout (True);
      if(infifo.first() matches tagged YUV .xdata)
	 begin
	    $display("ccl5finalout %h", xdata[7:0]);
	    $display("ccl5finalout %h", xdata[15:8]);
	    $display("ccl5finalout %h", xdata[23:16]);
	    $display("ccl5finalout %h", xdata[31:24]);
	    infifo.deq();
	 end
      else
	 $finish(0);
   endrule


   interface Put ioin  = fifoToPut(infifo);

endmodule

endpackage