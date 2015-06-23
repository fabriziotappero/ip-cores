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




//////////////////////////////////////////////////////////////////////////////////

// Copyright (c) 2006 Nirav Dave (ndave@csail.mit.edu)

// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:

// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

//////////////////////////////////////////////////////////////////////////////////

import FIFO::*;
import FIFOF::*;
import Vector::*;

interface Pipeline#(type alpha);
  method Action put(alpha x);
  method ActionValue#(alpha) get();
endinterface

function alpha repeatFN(Bit#(b) reps, function alpha f(Bit#(b) stage, alpha fx), Bit#(b) stage, alpha in);
  alpha new_in = f(stage, in);
  return (reps == 0) ? in : repeatFN(reps - 1, f, stage+1, new_in);
endfunction				

module mkPipeline_Circ#(Bit#(b) numstages,
                        Bit#(b) step,
                        function alpha sf(Bit#(b) s, alpha x))
       (Pipeline#(alpha))
    provisos
       (Bits#(alpha, asz));
  		  
  // input queue
  FIFOF#(alpha)       inputQ <- mkLFIFOF();
  
  // internal state
  Reg#(Bit#(b))          stage <- mkReg(0);
  Reg#(alpha)             s <- mkRegU;  
  
  // output queue
  FIFO#(alpha)        outputQ <- mkLFIFO();
  
  rule compute(True);
   // get input (implicitly stalls if no input)

   alpha s_in = s; // default is from register
   if (stage == 0)
     begin    
       s_in = inputQ.first();
       inputQ.deq();
     end

   //do stage
   let s_out = repeatFN(step, sf, stage, s_in);

   // store output
   stage <= (stage + step == numstages) ? 0 : stage + step;

   if(stage + step == numstages)
     outputQ.enq(s_out);
   else
     s <= s_out;
  endrule 
  
  // The Interface
  
  method Action put(alpha x);
    inputQ.enq(x);   
  endmethod
  
  method ActionValue#(alpha) get();
    outputQ.deq();
    return outputQ.first();
  endmethod
  
endmodule

module mkPipeline_Sync#(Bit#(b) numstages,
                        Bit#(b) step,
                        function alpha sf(Bit#(b) s, alpha x))
       (Pipeline#(alpha))
    provisos
       (Bits#(alpha, asz),Add#(b,k,32));

  // input queue
  FIFOF#(alpha)       inputQ <- mkLFIFOF();
  
  // internal state
  // This is an over estimate of the space we need
  // we're artificially restricted because there is no
  // "reasonable way to pass a "static" parameter.
  // We will only create/initialize the used registers though.

  Vector#(TExp#(b), Reg#(Maybe#(alpha))) piperegs = newVector();

  for(Bit#(b) i = 0; i < numstages; i = i + step)
   begin
     let pipereg <- mkReg(Nothing);
     piperegs[i] = pipereg;
   end

  // output queue
  FIFO#(alpha)        outputQ <- mkLFIFO();
  
  rule compute(True);
    for(Bit#(b) stage = 0; stage < numstages; stage = stage + step)
      begin
        //Determine Inputs

        Maybe#(alpha) in = Nothing; // Default Value Is Nothing
  
        if (stage != 0)                         // Not-First Stage takes from reg
           in = (piperegs[stage - step])._read;
        else if(inputQ.notEmpty) // take from queue at stage 0
          begin    
            in = Just(inputQ.first());
            inputQ.deq();
	  end
        alpha s_in = fromMaybe(?,in);
  
        //do stage
	  
        alpha s_out = repeatFN(step, sf, stage, s_in);

	//deal with outputs
        if (stage + step < numstages) // it's not the last stage
          (piperegs[stage]) <= isJust(in) ? Just(s_out): Nothing;
        else if(isValid(in)) // && stage == 2
          outputQ.enq(s_out);
	else
	  noAction;
        end     
  endrule
	   
  // The Interface
  method Action put(alpha x);
    inputQ.enq(x);   
  endmethod
  
  method ActionValue#(alpha) get();
    outputQ.deq();
    return outputQ.first();
  endmethod
  
endmodule
		     
				     
module mkPipeline_Comb#(Bit#(b) numstages,
                        Bit#(b) step,
                        function alpha sf(Bit#(b) s, alpha x))
       (Pipeline#(alpha))
    provisos
       (Bits#(alpha, asz));

  // input queue
  FIFOF#(alpha)       inputQ <- mkLFIFOF();
  
  // output queue
  FIFO#(alpha)        outputQ <- mkLFIFO();
  
  rule compute(True);
    alpha  stage_in, stage_out;

    stage_in = inputQ.first();
    inputQ.deq();
     
    for(Bit#(b) stage = 0; stage < numstages; stage = stage + step)
      begin
        //do stage
        stage_out = repeatFN(step, sf, stage, stage_in);

        //deal with outputs
        stage_in = stage_out;
      end     

    outputQ.enq(stage_out);
  endrule	 
	   
  // The Interface
  method Action put(alpha x);
    inputQ.enq(x);   
  endmethod
  
  method ActionValue#(alpha) get();
    outputQ.deq();
    return outputQ.first();
  endmethod
  
endmodule				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
				     
