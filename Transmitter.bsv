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


import Controller::*;
import ConvEncoder::*;
import CyclicExtender::*;
import IFFT::*;
import Interleaver::*;
import LibraryFunctions::*;
import Mapper::*;
import Scrambler::*;


(* synthesize *)
module mkTransmitter_Pipe(Transmitter#(24,81));
  let ifft <- mkIFFT_Pipe();
  let _x <- mkTransmitter(ifft);   
  return _x; 
endmodule

(* synthesize *)
module mkTransmitter_Comb(Transmitter#(24,81));
  let ifft <- mkIFFT_Comb();
  let _x <- mkTransmitter(ifft); 
  return _x; 
endmodule

(* synthesize *)
module mkTransmitter_Circ(Transmitter#(24,81));
  let ifft <- mkIFFT_Circ();
  let _x <- mkTransmitter(ifft);   
  return _x; 
endmodule

(* synthesize *)
module mkTransmitter_1Radix(Transmitter#(24,81));
  let ifft <- mkIFFT_Circ_w_1Radix();
  let _x <- mkTransmitter(ifft);   
  return _x; 
endmodule

(* synthesize *)
module mkTransmitter_2Radix(Transmitter#(24,81));
  let ifft <- mkIFFT_Circ_w_2Radix();
  let _x <- mkTransmitter(ifft);   
  return _x; 
endmodule


(* synthesize *)
module mkTransmitter_4Radix(Transmitter#(24,81));
  let ifft <- mkIFFT_Circ_w_4Radix();
  let _x <- mkTransmitter(ifft);   
  return _x; 
endmodule

(* synthesize *)
module mkTransmitter_8Radix(Transmitter#(24,81));
  let ifft <- mkIFFT_Circ_w_8Radix();
  let _x <- mkTransmitter(ifft);   
  return _x; 
endmodule

module [Module] mkTransmitter#(IFFT#(64) ifft)(Transmitter#(24,81));

  function Action stitch(ActionValue#(a) x, function Action f(a v));
    action
      let v <- x;
      f(v); 
    endaction 				
  endfunction
   
  let controller   <- mkController();   
  let scrambler    <- mkScrambler_48();     
  let conv_encoder <- mkConvEncoder_24_48();
  let interleaver  <- mkInterleaver(); 
  let mapper       <- mkMapper_48_64();
  //  let ifft         <- mkIFFT();
  let cyc_extender <- mkCyclicExtender();

   rule controller2scrambler(True);
      stitch(controller.getData, scrambler.fromControl);
   endrule
   
   rule controller2conv_encoder(True);
      stitch(controller.getHeader,conv_encoder.encode_fromController);
   endrule   

   rule scrambler2conv_encoder(True);
      stitch(scrambler.toEncoder, conv_encoder.encode_fromScrambler);
   endrule   
  
   rule conv_encoder2interleaver(True);
      stitch(conv_encoder.getOutput, interleaver.fromEncoder);
   endrule

   rule interleaver2mapper(True);
      stitch(interleaver.toMapper, mapper.fromInterleaver);
   endrule
 
   rule mapper2ifft(True);
      stitch(mapper.toIFFT, ifft.fromMapper);
   endrule
     
   rule ifft2cyclicExtender(True);
      stitch(ifft.toCyclicExtender, cyc_extender.fromIFFT);
   endrule

   method ActionValue#(MsgComplexFVec#(81)) toAnalogTX() if(True);
     let x <- cyc_extender.toAnalogTX();
     return(x);
   endmethod
     
   method Action getFromMAC(TXMAC2ControllerInfo x);
     controller.getFromMAC(x); 
   endmethod
     
   method Action getDataFromMAC(Data#(24) x); 
     controller.getDataFromMAC(x);
   endmethod 
     
endmodule