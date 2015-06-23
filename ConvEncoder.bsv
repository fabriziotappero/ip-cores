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




// *************************************************************************
//  ConvEncoder.bsv 
// *************************************************************************
import DataTypes::*;
import Interfaces::*;

import LibraryFunctions::*;
import FIFO::*;

(* synthesize *)
module mkConvEncoder_24_48(ConvEncoder#(24, 48));
  let _c <- mkConvEncoder();
  return(_c); 
endmodule

// n has to be 24 here
module mkConvEncoder(ConvEncoder#(n, nn))
       provisos
         (Add#(n,n,nn),Add#(6,n,n6));

  //-----------------------------------------
  // State
  //-----------------------------------------
  
  // input queues
  FIFO#(Header#(n))           headerQ <- mkLFIFO();
  FIFO#(RateData#(n))           dataQ <- mkLFIFO();

  // internal state
  FIFO#(RateData#(n))        orderedQ <- mkLFIFO();
  Reg#(Bool)                getHeader <- mkReg(True);
  Reg#(Bit#(5))               timeOut <- mkReg(24);
  Reg#(Bit#(6))               histVal <- mkReg(0);
  
  // output queue
  FIFO#(RateData#(nn))               outputQ <- mkLFIFO();

  //-----------------------------------------
  // Rules
  //-----------------------------------------
  
  rule sort(True);
  
    // look at heads of header and data input queues
    Header#(n)       header = headerQ.first();
    RateData#(n)     data = dataQ.first();
  
    // if we've not started a header  and the data rate is nonzero, enq a header
    if(getHeader && data.rate != RNone)
       begin
          orderedQ.enq(RateData{
			      rate: R1,
		       data: header
			      });
          headerQ.deq();
	  let ntimeOut = (timeOut - fromInteger(valueOf(n)));
	  
          timeOut <= (ntimeOut > 0) ? ntimeOut : 24; // reset

          if (!(ntimeOut > 0))
             getHeader <= False;
       end
    else // otherwise, enq a data
       begin
	  if (data.rate != RNone) // newpacket
	     getHeader <= True;
	  
          dataQ.deq();
          orderedQ.enq(data);
       end
  endrule
   
  rule compute(True);
  
    // get input out of input queues
    Bit#(n) input_data = reverseBits((orderedQ.first).data);
    Rate    input_rate  = (orderedQ.first).rate;
    orderedQ.deq();

    // if this is a new message, reset history

    Bit#(n6)       history;

    if(input_rate == RNone) // new entry
      history = {input_data, histVal};
    else
      history = {input_data, 6'b0};

    // local variables
    Bit#(nn) rev_output_data = 0;
    Bit#(1)  shared = 0; 
    Bit#(6)  newHistVal = histVal;

    // convolutionally encode data
    for(Integer i = 0; i < valueOf(n); i = i + 1)
      begin
      shared = input_data[i] ^ history[i + 4] ^ history[i + 3] ^ history[i + 0];
      rev_output_data[(2*i) + 0] = shared ^ history[i + 1];
      rev_output_data[(2*i) + 1] = shared ^ history[i + 5];
      newHistVal = {input_data[i], newHistVal[5:1]}; // only last update will be saved
      end

    // enqueue result
    RateData#(nn) retval = RateData{
                             rate: input_rate,
                             data: reverseBits(rev_output_data)
                            };
    outputQ.enq(retval);

    // setup for next cycle
    histVal <= newHistVal;
  endrule

  
  //-----------------------------------------
  // Methods
  //-----------------------------------------

  // input from controller queue method
  method Action encode_fromController(Header#(n) header);
    headerQ.enq(header);
  endmethod

  // input from scrambler queue method
  method Action encode_fromScrambler(RateData#(n) data);
    dataQ.enq(data);
  endmethod

  // output to interleaver queue method
  method ActionValue#(RateData#(nn)) getOutput();
    outputQ.deq();
    return(outputQ.first());
  endmethod

endmodule

