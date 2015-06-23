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
import Vector::*;

// ---------------------------------------------------------
// Reed-Solomon Error Magnitude computer interface 
// ---------------------------------------------------------
interface IErrorMagnitude;
   method Action              k_in(Byte k_new);
   method Action              no_error_flag_in(Bool no_error_new);
   method Action              loc_in(Maybe#(Byte) loc_new);
   method Action              alpha_inv_in(Maybe#(Byte) alpha_inv_new);
   method Action              lambda_in(Syndrome#(T) lambda_new);
   method Action              omega_in(Syndrome#(T) omega_new);     
      
   method ActionValue#(Byte)  error_out();
endinterface

// ---------------------------------------------------------
// Reed-Solomon Error Magnitude computer module 
// ---------------------------------------------------------
(* synthesize *)
module mkErrorMagnitude (IErrorMagnitude);
   
   // input queues
   FIFO#(Byte)             k_q             <- mkSizedFIFO(1);
   FIFO#(Bool)             no_error_flag_q <- mkSizedFIFO(1);
   FIFO#(Syndrome#(T))     lambda_q        <- mkSizedFIFO(1);
   FIFO#(Syndrome#(T))     omega_q         <- mkSizedFIFO(1);
   FIFO#(Maybe#(Byte))     loc_q           <- mkSizedFIFO(valueOf(TwoT));
   FIFO#(Maybe#(Byte))     alpha_inv_q     <- mkSizedFIFO(valueOf(T));
   
   // output queues
   FIFO#(Byte)             err_q           <- mkSizedFIFO(2);
   
   // internal quques
   FIFO#(Byte)             int_err_q       <- mkSizedFIFO(valueOf(T));
   
   // booking state
   Reg#(Byte)              omega_val       <- mkReg(0);
   Reg#(Byte)              lambda_d_val    <- mkReg(0);

   Reg#(Byte)              i               <- mkReg(0);
   Reg#(Byte)              count           <- mkReg(0);
   Reg#(Byte)              block_number    <- mkReg(1);
   
   // variables
   Byte t = fromInteger(valueOf(T)); 
   let k = k_q.first();
   let no_error_flag = no_error_flag_q.first();
   let loc = fromMaybe(255,loc_q.first()); // next location has no error?
   let alpha_inv = fromMaybe(?,alpha_inv_q.first());
   let lambda = lambda_q.first();
   let omega  = omega_q.first();
 
   // -----------------------------------------------
   rule eval_lambda_omega (count < t && isValid(alpha_inv_q.first()));
      // Derivative of Lambda is done by dropping even terms and shifting odd terms by one
      // So count is incremented by 2
      // valid_t - 2 is the index used as the final term since valid_t - 1 term gets dropped
      Byte idx = (t - 1) - count;
      Byte lambda_add_val = ((count & 8'd1) == 8'd1) ? lambda[idx] : 0;
      lambda_d_val <= gf_add(gf_mult(lambda_d_val, alpha_inv),lambda_add_val);
      omega_val <= gf_mult(omega_val, alpha_inv) ^ omega[idx];
      count <= count + 1;

      $display ("  [errMag %d]  Evaluating Lambda_der count : %d, lambda_d_val[prev] : %d, lambda_add_val : %d, idx : %d", 
                block_number, count, lambda_d_val, lambda_add_val, idx);
      $display ("  [errMag %d]  Evaluating Omega count : %d, omega_val[prev] : %d", 
                block_number, count, omega_val); 
   endrule
   
   // ------------------------------------------------
   rule enq_error (count == t);
      $display ("  [errMag %d]  Finish Evaluating Lambda Omega", block_number);

      let err_val = gf_mult(omega_val, gf_inv(lambda_d_val));
      int_err_q.enq(err_val);
      count <= 0;
      lambda_d_val <= 0;
      omega_val <= 0;
      alpha_inv_q.deq();
   endrule
   
   rule deq_invalid_alpha_inv (alpha_inv_q.first() matches Invalid);
      $display ("  [errMag %d]  Deq Invalid Alpha Inv", block_number);
      
      alpha_inv_q.deq();
      lambda_q.deq();
      omega_q.deq();
   endrule
   
   // ------------------------------------------------
   rule process_error_no_error (i < k && !no_error_flag);
      
      Byte err_val;
      if (i == loc)
         begin
            $display ("  [errMag %d]  Processing location %d which is in error ", block_number, i);

            err_val = int_err_q.first();
            int_err_q.deq();
            loc_q.deq();
         end
      else
         begin
            $display ("  [errMag %d]  process location %d which has no error ", block_number, i);
            
            err_val = 0;
         end
      err_q.enq(err_val);
      i <= i + 1;
   endrule

   // ------------------------------------------------
   rule bypass(i < k && no_error_flag);
      $display ("  [errMag %d]  process location %d bypass which has no error ", block_number, i);
      
      i <= k;
   endrule
     
   // ------------------------------------------------
   rule start_next_errMag (i == k);
      $display ("Start Next ErrMag");
      
      k_q.deq();
      no_error_flag_q.deq();
      i <= 0;
      block_number <= block_number + 1;
      if (!no_error_flag)
         begin
            loc_q.deq(); // this one should be the Invalid denomiator
         end
   endrule

   // ------------------------------------------------
   method Action k_in(Byte k_new);
      $display ("  [errMag %d]  k_in : %d", block_number, k_new);
      
      k_q.enq(k_new);
   endmethod 
   
   // ------------------------------------------------
   method Action no_error_flag_in(Bool no_error_new);
      $display ("  [errMag %d]  no_error_flag_in : %d", block_number, no_error_new);
      
      no_error_flag_q.enq(no_error_new);
   endmethod 
   
   // ------------------------------------------------
   method Action loc_in(Maybe#(Byte) loc_new);
      $display ("  [errMag %d]  loc_in : %d", block_number, loc_new);
      
      loc_q.enq(loc_new);
   endmethod    
   
   // ------------------------------------------------
   method Action alpha_inv_in(Maybe#(Byte) alpha_inv_new);
      $display ("  [errMag %d]  alpha_inv_in : %d", block_number, alpha_inv_new);
      
      alpha_inv_q.enq(alpha_inv_new);
   endmethod    
   
   // ------------------------------------------------
   method Action lambda_in(Syndrome#(T) lambda_new);
      $display ("  [errMag %d]  lambda_in : %d", block_number, lambda_new);
   
      lambda_q.enq(lambda_new);
   endmethod
   
   // ------------------------------------------------
   method Action omega_in(Syndrome#(T) omega_new);
      $display ("  [errMag %d]  w_in : %d", block_number, omega_new);
   
      omega_q.enq(omega_new);
   endmethod
   
   // ------------------------------------------------
   method ActionValue#(Byte) error_out();
      $display ("  [errMag %d]  err_out: %d", block_number, err_q.first());
      err_q.deq();
      
      return err_q.first();
   endmethod
   
endmodule






