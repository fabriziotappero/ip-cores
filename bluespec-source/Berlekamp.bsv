//----------------------------------------------------------------------//
// The MIT License 
// 
// Copyright (c) 2010 Abhinav Agarwal, Alfred Man Cheuk Ng
// Contact: abhiag@gmail.com
// 
// Permission is hereby granted, free of charge, to any person 
// obtaining a copy of this software and associated documentation 
// files (the "Software"), to deal in the Software without 
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//----------------------------------------------------------------------//

import FIFO::*;
import GFArith::*;
import GFTypes::*;
import MFIFO::*;
import UniqueWrappers::*;
import Vector::*;

typedef enum 
{  CALC_D, 
   CALC_LAMBDA, 
   CALC_LAMBDA_2, 
   CALC_LAMBDA_3,
   START,
   BERLEKAMP_DONE
} Stage deriving (Bits, Eq);

// ---------------------------------------------------------
// Reed-Solomon Berlekamp algoritm interface 
// ---------------------------------------------------------
interface IBerlekamp;
   // input methods
   method Action                     t_in(Byte t_new);
   method Action                     s_in(Syndrome#(TwoT) syndrome_new);
   
   // output methods
   method ActionValue#(Bool)         no_error_flag_out();
   method ActionValue#(Syndrome#(T)) lambda_out();
   method ActionValue#(Syndrome#(T)) omega_out();
endinterface

// ---------------------------------------------------------
// Reed-Solomon Berlekamp module 
// ---------------------------------------------------------
(* synthesize *)
module mkBerlekamp(IBerlekamp);
   
   // state elements
   // ------------------------------------------------
   // input fifos, to increase throughput, can have size > 1
   FIFO#(Byte)                     t_q             <- mkSizedFIFO(1);
   FIFO#(Syndrome#(TwoT))          syndrome_q      <- mkSizedFIFO(1);
   
   // output fifos, for correctness, size need to be 1
   MFIFO#(1,Syndrome#(TPlusTwo))   c_q             <- mkMFIFO1(); // lambda
   MFIFO#(1,Syndrome#(TPlusTwo))   w_q             <- mkMFIFO1(); // omega
   MFIFO#(1,Bool)                  no_error_flag_q <- mkMFIFO1();
  
   // regs
   Reg#(Syndrome#(TPlusTwo))       syn_shf_reg     <- mkRegU;
    
   Reg#(Syndrome#(TPlusTwo))       p               <- mkRegU; // B
   Reg#(Syndrome#(TPlusTwo))       a               <- mkRegU; // A

   Reg#(Byte)                      d               <- mkRegU;
   Reg#(Byte)                      dstar           <- mkRegU;
   Reg#(Byte)                      d_dstar         <- mkRegU;

   Reg#(Byte)                      i               <- mkRegU;
   Reg#(Byte)                      l               <- mkRegU;
   Reg#(Bool)                      is_i_gt_2l      <- mkRegU; // is i + 1 > 2*l?
   Reg#(Stage)                     stage           <- mkReg(BERLEKAMP_DONE);
   Reg#(Byte)                      block_number    <- mkReg(0);
   
   // function wrapper (for resource sharing)
   // ------------------------------------------------
   Wrapper2#(Syndrome#(TPlusTwo),
             Syndrome#(TPlusTwo),
             Syndrome#(TPlusTwo))    gf_mult_vec  <- mkUniqueWrapper2(zipWith(gf_mult_inst));   
   Wrapper2#(Syndrome#(TPlusTwo),
             Syndrome#(TPlusTwo),
             Syndrome#(TPlusTwo))    gf_add_vec   <- mkUniqueWrapper2(zipWith(gf_add_inst));   
   
   // define constants
   // ------------------------------------------------
   Syndrome#(TPlusTwo) p_init = replicate(0);
   Syndrome#(TPlusTwo) c_init = replicate(0);
   Syndrome#(TPlusTwo) w_init = replicate(0);
   Syndrome#(TPlusTwo) a_init = replicate(0);
   c_init[0] = 1;
   p_init[0] = 1;
   a_init[0] = 1;
   let t = t_q.first();
   let syndrome = syndrome_q.first();
   Reg#(Syndrome#(TPlusTwo)) c = c_q.first;
   Reg#(Syndrome#(TPlusTwo)) w = w_q.first;
   Reg#(Bool) no_error_flag = no_error_flag_q.first;
   
   // ------------------------------------------------
   rule calc_d (stage == CALC_D);
      let syn             = syndrome[i];
      let newSynShiftReg  = shiftInAt0(syn_shf_reg,syn); // shift in one syndrome input to syn
      let d_vec          <- gf_mult_vec.func(c, newSynShiftReg); // get convolution
      let new_d           = fold( \^ ,d_vec);
      let new_no_err_flag = no_error_flag && syndrome[i] == 0;
      
      if (i < 2 * t)
         begin
            syn_shf_reg <= newSynShiftReg;
            d <= new_d;
            stage <= CALC_LAMBDA;
            i <= i + 1;
            no_error_flag <= new_no_err_flag;
         end
      else // i == 2 * t
         begin
            stage <= BERLEKAMP_DONE;
            t_q.deq();
            syndrome_q.deq();
            if (no_error_flag) // no error, don't need to send lambda and omega
               begin
                  c_q.deq();
                  w_q.deq();
               end
         end
      
      $display ("  [berlekamp %d]  calc_d, L = %d, i = %d, d = %d, s [%d] = %d", 
                block_number, l, i, new_d, i, syn);       
   endrule

   // ------------------------------------------------
   rule calc_lambda (stage == CALC_LAMBDA);   
      stage <= (d == 0) ? CALC_D : CALC_LAMBDA_2;
      d_dstar <= gf_mult_inst(d, dstar); // d_dstar = d * dstar
      p <= shiftInAt0(p,0); // increase polynomial p degree by 1
      a <= shiftInAt0(a,0); // increase polynomial a degree by 1
      is_i_gt_2l <= (i > 2 * l); // check i + 2 > 2 * l?

      //$display ("  [berlekamp %d]  calc_lambda. d = %d, dstar = %d, i(%d) > 2*L(%d)?", block_number, d, dstar, i, l);
   endrule
   
   // ------------------------------------------------
   rule calc_lambda_2 (stage == CALC_LAMBDA_2);
      let d_dstar_p <- gf_mult_vec.func(replicate(d_dstar),p);
      let new_c     <- gf_add_vec.func(c,d_dstar_p);
      c <= new_c;
      stage <= CALC_LAMBDA_3;
      if (is_i_gt_2l)  // p = old_c only if i + 1 > 2 * l
         p <= c;

      //$display ("  [berlekamp %d] calc_lambda_2. c (%x) = d_d* (%x) x p (%x)", block_number, new_c, d_dstar, p);      
   endrule
   
   // ------------------------------------------------
   rule calc_lambda_3 (stage == CALC_LAMBDA_3);      
      let d_dstar_a <- gf_mult_vec.func(replicate(d_dstar),a);
      let new_w     <- gf_add_vec.func(w,d_dstar_a);
      w <= new_w;
      stage <= CALC_D;
      if (is_i_gt_2l)  // a = old_w only if i + 1 > 2 * l
         begin
            a <= w;
            l <= i - l;
            dstar <= gf_inv(d);
         end

      //$display ("  [berlekamp %d] calc_lambda_3. w (%x) = d_d* (%x) x a (%x)", block_number, new_w, d_dstar, a);      
   endrule      

   // ------------------------------------------------
   rule start_new_syndrome (stage == START);
      //$display ("  [berlekamp %d] start_new_syndrome t : %d, s : %x", block_number, t, syndrome);      

      block_number <= block_number + 1;
      // initiatize state
      p <= p_init;
      a <= a_init;
      c_q.enq(c_init);
      w_q.enq(w_init);
      no_error_flag_q.enq(True);
      d <= 0;
      dstar <= 1;
      i <= 0;
      l <= 0;
      syn_shf_reg <= replicate(0);
      // next state becomes calc_d
      stage <= CALC_D;
   endrule
   
   // ------------------------------------------------
   method Action t_in (Byte t_new);      
      $display ("  [berlekamp %d]  t_in : %d", block_number, t_new);
      
      t_q.enq(t_new);
   endmethod
   
   // ------------------------------------------------
   method Action s_in(Syndrome#(TwoT) syndrome_new) if (stage == BERLEKAMP_DONE);      
      //$display ("  [berlekamp %d]  s_in : %x", block_number, syndrome_new);
      stage <= START;
      syndrome_q.enq(syndrome_new);
   endmethod   
   
   // ------------------------------------------------
   method ActionValue#(Bool) no_error_flag_out() if (stage == BERLEKAMP_DONE);
      $display ("  [berlekamp %d]  no_error_flag_out : %d", block_number, no_error_flag);
      
      no_error_flag_q.deq();
      return no_error_flag;
   endmethod
   
   // ------------------------------------------------
   method ActionValue#(Syndrome#(T)) lambda_out() if (stage == BERLEKAMP_DONE);                       
      //$display ("  [berlekamp %d]  lambda_out : %x", block_number, c);
      
      c_q.deq();      
      return take(tail(c)); // drop lsb && msb
   endmethod
   
   // ------------------------------------------------
   method ActionValue#(Syndrome#(T)) omega_out() if (stage == BERLEKAMP_DONE);
      //$display ("  [berlekamp %d]  omega_out : %x", block_number, w);
      
      w_q.deq();
      return take(tail(w)); // drop lsb && msb
   endmethod
   
endmodule