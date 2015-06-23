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
//  Scrambler.bsv 
// *************************************************************************
import DataTypes::*;
import Interfaces::*;

import LibraryFunctions::*;
import FIFO::*;
import RWire::*;
import Vector::*;

interface Interleaver#(type n, type m );
   //inputs
  method Action fromEncoder(RateData#(n) txSVec);
  
   //outputs
  method ActionValue#(RateData#(m))       toMapper(); 
endinterface

(* synthesize *)
module mkInterleaver(Interleaver#(48, 48));
  
  Reg#(Bit#(2))                     outCnt <- mkReg(0);
  FIFO#(Tuple2#(Rate, Bit#(192)))     buff <- mkFIFO();
 
  match {.buff_rate, .buff_data} = buff.first();
  
  Reg#(Rate)                     cur_rate <- mkReg(RNone);
  Reg#(Bit#(2))                     inCnt <- mkReg(0); 
  Reg#(Bit#(192))                    mapR <- mkReg(0);
     
  method Action fromEncoder(RateData#(48) i);
    //calc new value
    Rate this_rate = (i.rate == RNone) ? cur_rate : i.rate;
    Bit#(48)    in = i.data;
     
    cur_rate <=  this_rate;

    function Bit#(48) f1(Bit#(48) x);
       Vector#(16, Bit#(1)) va = bitBreak(x[47:32]),
                            vb = bitBreak(x[31:16]),
                            vc = bitBreak(x[15: 0]);
       function merge(a,b,c) = {a,b,c};
   
       let data_out = bitMerge(zipWith3(merge,va,vb,vc));

       return data_out;
    endfunction 
       
    function Bit#(96) f2(Bit#(48) x, Bit#(48) y);
       Vector#(16, Bit#(3)) va = bitBreak(y),
                            vb = bitBreak(f1(x));
            
       function merge(a,b) = {a,b};
   
       let data_out = bitMerge(zipWith(merge,va,vb));

       return {data_out,0};
    endfunction 
     
    function Bit#(192) switchBits(Bit#(192) x);
       Vector#(8 , Bit#(24)) va = bitBreak(x);

       function Bit#(24) swap(Bit#(24) b) = {b[23:10],b[8],b[9],b[7:4],b[2],b[3],b[1:0]};

       let out = bitMerge(map(swap,va));

       return out;
    endfunction
       
    Bit#(192) new_mapR =
       case (inCnt) 
         0 : return {?,f1(in)};
         1 : return {f2(in,mapR[47:0]),?};
         2 : return {mapR[191:96],?,f1(in)};
         3 : return switchBits({mapR[191:96],f2(in, mapR[47:0])});
       endcase;      

    Bit#(2) new_inCnt = pack(tuple2(cur_rate == R4, cur_rate != R1)) & (inCnt + 1);
    inCnt <= new_inCnt;

    if (new_inCnt == 2'b00) // we're done
      buff.enq(tuple2(cur_rate,new_mapR));
    else //store
      mapR <= new_mapR;
      
  endmethod   

  method ActionValue#(RateData#(48)) toMapper();
     Bit#(48) res = case (outCnt)
		       2'b00: return buff_data[191:144];
                       2'b01: return buff_data[143:96];
                       2'b10: return buff_data[95:48];
		       2'b11: return buff_data[47:0];
		    endcase;
     Bit#(2) new_outCnt = pack(tuple2(buff_rate == R4, buff_rate != R1)) & (outCnt + 1);
     outCnt <= new_outCnt;
   
     if(new_outCnt == 2'b00)
       buff.deq();
     
     return RateData{
               rate: buff_rate,
	       data: res
	      };
  endmethod
		     
		     
endmodule		     