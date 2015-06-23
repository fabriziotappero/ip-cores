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
//  Mapper.bsv 
// *************************************************************************
import ComplexF::*;
import DataTypes::*;
import Interfaces::*;

import LibraryFunctions::*;
import FIFO::*;
import RWire::*;
import Vector::*;

function ComplexF#(16) r1_getMappedValue(Bit#(1) b0);
  return (ComplexF{
	    i : (b0 == 1) ?  16'h7FFF : 16'h8000,
	    q : 0
	   });   
endfunction

function ComplexF#(16) r2_getMappedValue(Bit#(2) b0);
  return (ComplexF{
	    i : (b0[1] == 1) ?   16'h5A82 : 16'hA57E, 
	    q : (b0[0] == 1) ?   16'h5A82 : 16'hA57E
	   }); 
endfunction

function ComplexF#(16) r4_getMappedValue(Bit#(4) b0);
 function f(x);
   case (x)
      2'b00: return(16'h8692);
      2'b01: return(16'hD786);
      2'b10: return(16'h796E);
      2'b11: return(16'h287A);
   endcase
 endfunction

   return (ComplexF{
      i : f(b0[3:2]),
      q : f(b0[1:0])
      }); 
endfunction


function Vector#(64, ComplexF#(16)) expandCFs(Bit#(1) ppv, Vector#(48, ComplexF#(16)) x);
   ComplexF#(16) zero = ComplexF{i: 0, q: 0};

   Integer i =0, j = 0;
   Vector#(64, ComplexF#(16)) syms = Vector::replicate(zero);

   //six zeros
   i = i + 6;

   for(i = 6; i < 11; i = i + 1, j = j + 1) // [6:10] = 5
      syms[i] = x[j];
   
   //pilot
   syms[i] = r1_getMappedValue(ppv); // [11] = 1
   i = i + 1;
   
   for(i = 12; i < 25; i = i + 1, j = j + 1) // [12:24] = 13
      syms[i] = x[j]; 

   //pilot
   syms[i] = r1_getMappedValue(ppv); // [25] = 1
   i = i + 1;

   for(i = 26; i < 32 ; i = i + 1, j = j + 1) // [26:31] = 6
      syms[i] = x[j];  

   // pilot 0                        // [32] = 1
   i = i + 1;  
   
   for(i = 33; i < 39 ; i = i + 1, j = j + 1) // [33:38] = 6
      syms[i] = x[j];   

   //pilot 7
   syms[i] = r1_getMappedValue(ppv); // [39] = 1
   i = i + 1; 

   for(i = 40; i < 53 ; i = i + 1, j = j + 1) // [40:52] = 13
      syms[i] = x[j];

   //pilot 21 NOTICE reversed value
   syms[i] = r1_getMappedValue(~ppv); // [53] = 1
   i = i + 1;  

   for(i = 54; i < 59 ; i = i + 1, j = j + 1) // [54:58] = 5
      syms[i] = x[j];
   
   
   return syms; // YYY: ndave this may need to be reversed
endfunction

(* synthesize *)
module mkMapper_48_64(Mapper#(48, 64));
         
   Bit#(127) ppv_init = truncate(128'hF10D36FDD9D149f32b184bd505AE4700 >> 1); // shift needed for alignment
   Reg#(Bit#(127)) pilotPolarityVector <- mkReg(ppv_init); // NOTE that 0s represet -1.
        
   Reg#(Rate)            cur_rate <- mkReg(RNone);
   Reg#(Bit#(2))          inM_cnt <- mkReg(0);
    
   Reg#(Vector#(48,ComplexF#(16))) curM <- mkRegU();
   FIFO#(MsgComplexFVec#(64)) outQ <- mkFIFO(); 
   
   
   method Action fromInterleaver(RateData#(48) i);
      Rate rate = (i.rate == RNone) ? cur_rate : i.rate;
   
      //update placement regs
      cur_rate <= rate;
      Bit#(2) new_inM_cnt = pack(tuple2(rate == R4, rate != R1)) & (inM_cnt + 1);
      inM_cnt <= new_inM_cnt;
   
      Vector#(48,ComplexF#(16)) cfs = newVector();

      //generate values
      case (rate)
	 R1:
	 begin
	    Vector#(48, Bit#(1)) va = bitBreak(i.data);
	    cfs = Vector::map(r1_getMappedValue, va);
	 end
	 R2:
	 begin
	    Vector#(24, Bit#(2)) va = bitBreak(i.data);
	    Vector#(24 ,ComplexF#(16)) cs = Vector::map(r2_getMappedValue, va);
	    cfs = v_truncate(Vector::append(curM, cs));
	 end
	 R4:
	 begin
	    Vector#(12, Bit#(4)) va = bitBreak(i.data);
	    Vector#(12 ,ComplexF#(16)) cs = Vector::map(r4_getMappedValue, va);
	    cfs = v_truncate(Vector::append(curM, cs)); 
	 end
      endcase
   
      if (new_inM_cnt == 2'b00)
	 begin
            MsgComplexFVec#(64) p = MsgComplexFVec{
				       new_message: True,
	                               data:        expandCFs(pilotPolarityVector[126], cfs)
				    };
            outQ.enq(p);
	    //rotate ppvs
	    pilotPolarityVector <= {pilotPolarityVector[125:0], pilotPolarityVector[126]};
         end
      


   endmethod

   method ActionValue#(MsgComplexFVec#(64)) toIFFT();
     outQ.deq();
     return (outQ.first());      
   endmethod
   
endmodule






(* synthesize *)
module mkMapper_48_16(Mapper#(48, 16));
         
   Bit#(127) ppv_init = truncate(128'hF10D36FDD9D149f32b184bd505AE4700 >> 1); // shift needed for alignment
   Reg#(Bit#(127)) pilotPolarityVector <- mkReg(ppv_init); // NOTE that 0s represet -1.
        
   Reg#(Rate)            cur_rate <- mkReg(RNone);
   Reg#(Bit#(2))          inM_cnt <- mkReg(0);
    
   Reg#(Vector#(48, ComplexF#(16)))  curM <- mkRegU();
   FIFO#(Vector#(64, ComplexF#(16))) outQ <- mkFIFO(); 
   Reg#(Bit#(2))                  outM_cnt <- mkReg(0);   
   
   method Action fromInterleaver(RateData#(48) i);
      Rate rate = (i.rate == RNone) ? cur_rate : i.rate;
   
      //update placement regs
      cur_rate <= rate;
      Bit#(2) new_inM_cnt = pack(tuple2(rate == R4, rate != R1)) & (inM_cnt + 1);
      inM_cnt <= new_inM_cnt;
   
      Vector#(48,ComplexF#(16)) cfs = newVector();

      //generate values
      case (rate)
	 R1:
	 begin
	    Vector#(48, Bit#(1)) va = bitBreak(i.data);
	    cfs = Vector::map(r1_getMappedValue, va);
	 end
	 R2:
	 begin
	    Vector#(24, Bit#(2)) va = bitBreak(i.data);
	    Vector#(24 ,ComplexF#(16)) cs = Vector::map(r2_getMappedValue, va);
	    cfs = v_truncate(Vector::append(curM, cs));
	 end
	 R4:
	 begin
	    Vector#(12, Bit#(4)) va = bitBreak(i.data);
	    Vector#(12 ,ComplexF#(16)) cs = Vector::map(r4_getMappedValue, va);
	    cfs = v_truncate(Vector::append(curM, cs)); 
	 end
      endcase
   
      if (new_inM_cnt == 2'b00)
	 begin
            Vector#(64, ComplexF#(16)) p = expandCFs(pilotPolarityVector[126], cfs);
	    outQ.enq(p);
	    //rotate ppvs
	    pilotPolarityVector <= {pilotPolarityVector[125:0], pilotPolarityVector[126]};
         end

   endmethod

   method ActionValue#(MsgComplexFVec#(16)) toIFFT();
     outM_cnt <= outM_cnt + 1;
    
     Vector#(48, ComplexF#(16)) t1 = v_truncate(outQ.first);
     Vector#(32, ComplexF#(16)) t2 = v_truncate(outQ.first);     

     Vector#(16, ComplexF#(16)) v1 = v_rtruncate(outQ.first); 
     Vector#(16, ComplexF#(16)) v2 = v_rtruncate(t1);    
     Vector#(16, ComplexF#(16)) v3 = v_rtruncate(t2);         
     Vector#(16, ComplexF#(16)) v4 = v_truncate(t2);      
      
     let r =  case (outM_cnt)
		 2'b00: return v1;
		 2'b01: return v2;
		 2'b10: return v3;
		 2'b11: return v4;
	      endcase;
       
     outQ.deq();
     return (MsgComplexFVec{
                 new_message: (outM_cnt == 2'b00),
                 data:        r
	});
  endmethod
	
   
endmodule












