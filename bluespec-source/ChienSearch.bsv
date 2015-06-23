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
{ 
   LOC_SEARCH,
   LOC_DONE
} Stage deriving (Bits, Eq);

// ---------------------------------------------------------
// Reed-Solomon Chien Error Magnitude computer interface 
// ---------------------------------------------------------
interface IChienSearch;
   // input methods
   method Action                         t_in(Byte t_new);
   method Action                         k_in(Byte k_new);
   method Action                         no_error_flag_in(Bool no_error_new);
   method Action                         lambda_in(Syndrome#(T) lamdba_new);
      
   // output methods
   method ActionValue#(Maybe#(Byte))     loc_out();       // use Invalid to show new packet
   method ActionValue#(Maybe#(Byte))     alpha_inv_out(); // the alpha_inv of location that has error
   method ActionValue#(Bool)             cant_correct_flag_out();
   method ActionValue#(Syndrome#(T))     lambda_out();
endinterface

// ---------------------------------------------------------
// Auxiliary Function
// ---------------------------------------------------------
(* noinline *)
function Syndrome#(T) times_alpha_n_v(Syndrome#(T) lambda_a, Byte t);
   Syndrome#(T) lambda_a_new = lambda_a;
   for (Byte x = 0; x < fromInteger(valueOf(T)); x = x + 1)
      lambda_a_new[x] = times_alpha_n(lambda_a[x], x + 1) & ((x < t)? 8'hFF : 8'h00);
   return lambda_a_new;   
endfunction 

// ---------------------------------------------------------
// Reed-Solomon Chien Error Magnitude computer module 
// ---------------------------------------------------------
(* synthesize *)
module mkChienSearch (IChienSearch);
   
   // comb. circuit sharing
   Wrapper2#(Syndrome#(T),Byte,
             Syndrome#(T))       times_alpha_n_vec   <- mkUniqueWrapper2(times_alpha_n_v);
   
   // input queues
   FIFO#(Bool)                   no_error_flag_q     <- mkSizedFIFO(1);
   FIFO#(Byte)                   t_q                 <- mkSizedFIFO(1);
   FIFO#(Byte)                   k_q                 <- mkSizedFIFO(1);
   FIFO#(Syndrome#(T))           lambda_q            <- mkSizedFIFO(1);
   
   // output queues
   FIFO#(Bool)                   cant_correct_flag_q <- mkSizedFIFO(1);
   FIFO#(Maybe#(Byte))           loc_q               <- mkSizedFIFO(2);
   FIFO#(Maybe#(Byte))           alpha_inv_q         <- mkSizedFIFO(2);
   MFIFO#(1,Syndrome#(T))        lambda_a_q          <- mkMFIFO1();
   
   // book-keep state
   Reg#(Byte)                    i                   <- mkRegU();
   Reg#(Byte)                    count_error         <- mkRegU();
   Reg#(Stage)                   stage               <- mkReg(LOC_DONE);
   Reg#(Byte)                    block_number        <- mkReg(0);
   Reg#(Byte)                    alpha_inv           <- mkRegU();

   // variables   
   let no_error_flag = no_error_flag_q.first();
   let t = t_q.first();
   let k = k_q.first();
   Reg#(Syndrome#(T)) lambda_a = lambda_a_q.first;                       
   
   // ------------------------------------------------
   rule calc_loc (stage == LOC_SEARCH);
      $display ("  [chien %d]  calc_loc, i = %d", block_number, i);
      
      let zero_padding = (i >= k + 2 * t);
      let parity_bytes = (i < 2 * t);
      let process_error = ((i < k + 2 * t) && (i >= 2 * t));
      Byte result_location = 1;

      if (!no_error_flag)
         begin
            result_location = fold(gf_add, cons(1,lambda_a)); // lambda_a add up + 1
            alpha_inv <= times_alpha(alpha_inv);

            $display ("  [chien %d]  calc_loc, result location = %d", block_number, result_location);
         end
      
      let is_no_error = (result_location != 0);
      
      if (!is_no_error)
         count_error <= count_error + 1;
      
      if (i == 0)
         begin
            stage <= LOC_DONE; 
            cant_correct_flag_q.enq(count_error == 0);
            t_q.deq();
            k_q.deq();
            no_error_flag_q.deq();
            if (!no_error_flag)
               begin
                  lambda_a_q.deq();
                  loc_q.enq(tagged Invalid);
                  alpha_inv_q.enq(tagged Invalid);
               end
         end
      else
         begin
            i <= i - 1;
            if (!no_error_flag)
               begin                  
                  let lambda_a_new <- times_alpha_n_vec.func(lambda_a,t); 
                  lambda_a <= lambda_a_new;

                  //$display ("  [chien %d]  calc_loc, lambda_a = %d", block_number, lambda_a_new);
               end  
            if (process_error)
               begin
                  if (!is_no_error) // enq loc_q an alpha_inv_q if there is error
                     begin
                        alpha_inv_q.enq(tagged Valid alpha_inv);
                        loc_q.enq(tagged Valid (k + 2 * t - i - 1)); // process range 1 - k
                     end
         end

         end
   endrule
   
   // ------------------------------------------------
   rule start_next_chien (stage == LOC_DONE);
      $display ("Start Next Chien ");
      
      stage <= LOC_SEARCH;
      i <= 254;
      count_error <= no_error_flag ? 1 : 0;
      block_number <= block_number + 1;
      if (!no_error_flag)
         begin
            let lambda_a_new <- times_alpha_n_vec.func(lambda_a,t); 
            lambda_a <= lambda_a_new; // if correctable, initialize lambda_a  
            alpha_inv <= 2; // = alpha^(1) = alpha^(-254)
         end                                                                 
   endrule

   // ------------------------------------------------
   method Action no_error_flag_in (Bool no_error_new);
      $display ("  [chien %d]  no_error_in : %d", block_number, no_error_new);
      
      no_error_flag_q.enq(no_error_new);
   endmethod
   
   // ------------------------------------------------
   method Action t_in (Byte t_new);
      $display ("  [chien %d]  t_in : %d", block_number, t_new);

      t_q.enq(t_new);
   endmethod
   
   // ------------------------------------------------
   method Action k_in (Byte k_new);
      $display ("  [chien %d]  k_in : %d", block_number, k_new);
      
      k_q.enq(k_new);
   endmethod
    
   // ------------------------------------------------
   method Action lambda_in(Syndrome#(T) lambda_new);
      //$display ("  [chien %d]  lambda_in : %d", block_number, lambda_new);
   
      lambda_a_q.enq(lambda_new);
      lambda_q.enq(lambda_new);
   endmethod
   
   // ------------------------------------------------
   method ActionValue#(Maybe#(Byte)) loc_out();
      $display ("  [chien %d]  loc_out : %d, stage : %d", block_number, loc_q.first(), stage);
      loc_q.deq();
      $display ("No of Errors %d", count_error);
      
      return loc_q.first();
   endmethod
   
   // ------------------------------------------------
   method ActionValue#(Maybe#(Byte)) alpha_inv_out();
      $display ("  [chien %d]  alpha_inv_out : %d, stage : %d", block_number, alpha_inv_q.first(), stage);
      alpha_inv_q.deq();
      $display ("No of Errors %d", count_error);
      
      return alpha_inv_q.first();
   endmethod
   
   // ------------------------------------------------
   method ActionValue#(Bool) cant_correct_flag_out();
      $display ("  [chien %d]  Can't Correct Flag : %d", block_number, cant_correct_flag_q.first());

      cant_correct_flag_q.deq();
      return cant_correct_flag_q.first();
   endmethod
                       
   // ------------------------------------------------
   method ActionValue#(Syndrome#(T)) lambda_out();
      //$display ("  [chien %d]  lambda_out : %d", block_number, lambda_q.first());
                       
      lambda_q.deq();
      return lambda_q.first();
   endmethod                    
                       
endmodule






