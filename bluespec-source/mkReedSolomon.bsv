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

import GetPut::*;
import FIFO::*;
import GFTypes::*;
import GFArith::*;
import SyndromeParallel::*;
import Berlekamp::*;
import ChienSearch::*;
import ErrorMagnitude::*;
import ErrorCorrector::*;

// Uncomment line below which defines BUFFER_LENGTH if   
// you get a compile error regarding BUFFER_LENGTH       

`define BUFFER_LENGTH  255

// ---------------------------------------------------------
// Reed-Solomon interface 
// ---------------------------------------------------------
interface IReedSolomon;
   interface Put#(Byte) rs_t_in;
   interface Put#(Byte) rs_k_in;
   interface Put#(Byte) rs_input;
   interface Get#(Byte) rs_output;
   interface Get#(Bool) rs_flag;
endinterface

// ---------------------------------------------------------
// Reed-Solomon module 
// ---------------------------------------------------------
(* synthesize *)
module mkReedSolomon (IReedSolomon);

   ISyndrome         syndrome          <- mkSyndromeParallel;
   IBerlekamp        berl              <- mkBerlekamp; 
   IChienSearch      chien_search      <- mkChienSearch;
   IErrorMagnitude   error_magnitude   <- mkErrorMagnitude;
   IErrorCorrector   error_corrector   <- mkErrorCorrector;
   
   // FIFOs
   FIFO#(Byte)               t_in                          <- mkSizedFIFO(2);
   FIFO#(Byte)               k_in                          <- mkSizedFIFO(2);
   FIFO#(Byte)               stream_in                     <- mkSizedFIFO(2);
   FIFO#(Byte)               stream_out                    <- mkSizedFIFO(2);
   FIFO#(Bool)               cant_correct_out              <- mkSizedFIFO(3);
   
   // FIFOs for input of syndrome module
   FIFO#(Byte)               ff_n_to_syndrome              <- mkSizedFIFO(1);
   FIFO#(Byte)               ff_r_to_syndrome              <- mkSizedFIFO(2);
   
   // FIFOs for input of berlekamp module
   FIFO#(Byte)               ff_t_to_berl             <- mkSizedFIFO(2);
   FIFO#(Syndrome#(TwoT))    ff_s_to_berl             <- mkSizedFIFO(1);

   // FIFOs for input of chien searach module   
   FIFO#(Byte)               ff_t_to_chien                 <- mkSizedFIFO(3);
   FIFO#(Byte)               ff_k_to_chien                 <- mkSizedFIFO(3);
   FIFO#(Bool)               ff_no_error_flag_to_chien     <- mkSizedFIFO(1);
   FIFO#(Syndrome#(T))       ff_l_to_chien                 <- mkSizedFIFO(1);
   
   // FIFOs for input of error magnitude module
   FIFO#(Byte)               ff_k_to_errormag              <- mkSizedFIFO(4);
   FIFO#(Bool)               ff_no_error_flag_to_errormag  <- mkSizedFIFO(2);
   FIFO#(Maybe#(Byte))       ff_loc_to_errormag            <- mkSizedFIFO(2);
   FIFO#(Maybe#(Byte))       ff_alpha_inv_to_errormag      <- mkSizedFIFO(2);
   FIFO#(Syndrome#(T))       ff_l_to_errormag              <- mkSizedFIFO(1);
   FIFO#(Syndrome#(T))       ff_w_to_errormag              <- mkSizedFIFO(2);
   
   // FIFOs for input of error corrector module
   FIFO#(Byte)               ff_r_to_errorcor              <- mkSizedFIFO(`BUFFER_LENGTH);
   FIFO#(Byte)               ff_e_to_errorcor              <- mkSizedFIFO(2);
   FIFO#(Byte)               ff_k_to_errorcor              <- mkSizedFIFO(5);
   FIFO#(Bool)               ff_no_error_flag_to_errorcor  <- mkSizedFIFO(3);
   
   // Regs
   Reg#(Bool)     info_count_done      <- mkReg (True);
   Reg#(Bool)     parity_count_done    <- mkReg (True);
   Reg#(Byte)     state                <- mkReg (0);
   Reg#(Bit#(32)) cycle_count          <- mkReg (0);
   Reg#(Byte)     info_count           <- mkReg (0);
   Reg#(Byte)     parity_count         <- mkReg (0);

   // ----------------------------------
   rule init (state == 0);
      state <= 1;
   endrule
   
   // ----------------------------------
   rule read_mac (state == 1 && info_count_done == True && parity_count_done == True);
      let k = k_in.first();
      k_in.deq ();
      info_count <= k;
      // k = 0, means no info bytes, stupid special case!
      if (k == 0)
         info_count_done <= True;
      else
         info_count_done <= False;
      ff_k_to_chien.enq(k);
      ff_k_to_errormag.enq(k);
      ff_k_to_errorcor.enq(k);

      let t = t_in.first();
      t_in.deq();
      ff_t_to_berl.enq(t);
      ff_t_to_chien.enq(t);
      
      let n = k + 2 * t;
      ff_n_to_syndrome.enq(n);

      parity_count <= 2 * t ;
      if (t == 0)
         parity_count_done <= True;
      else
         parity_count_done <= False;
      
      $display ("  [reedsol] read_mac z = %d, k = %d, t = %d", 255 - k - 2*t, k, t);
   endrule

   rule read_input (state == 1 && info_count_done == False);
      let datum = stream_in.first ();
      $display ("  [reedsol]  read_input [%d] = %d", info_count, datum);
      stream_in.deq();
      ff_r_to_syndrome.enq(datum);
      ff_r_to_errorcor.enq(datum);
      if (info_count == 1)
         info_count_done <= True;
      info_count <= info_count - 1;
   endrule
   
   rule read_parity (state == 1 && info_count_done == True && parity_count_done == False);
      let datum = stream_in.first ();
      $display ("  [reedsol]  read_parity [%d] = %d", parity_count, datum);
      stream_in.deq();
      ff_r_to_syndrome.enq (datum);
      if (parity_count == 1)
         parity_count_done <= True;
      parity_count <= parity_count - 1;
   endrule

   // ----------------------------------
   // rule for syndrome
   rule n_to_syndrome (state == 1);
      // $display ("    > > [t to syndrome] cycle count: %d", cycle_count);
      ff_n_to_syndrome.deq();
      let datum = ff_n_to_syndrome.first();
      syndrome.n_in(datum);
   endrule

   rule r_to_syndrome (state == 1);
      // $display ("    > > [r to syndrome] cycle count: %d", cycle_count);
      ff_r_to_syndrome.deq();
      let datum = ff_r_to_syndrome.first();
      syndrome.r_in(datum);
   endrule

   rule s_from_syndrome (state == 1);
      // $display ("    > > [s from syndrome] cycle count: %d", cycle_count);
      let datum <- syndrome.s_out();
      ff_s_to_berl.enq(datum);
   endrule

   // ----------------------------------
   // rules for berlekamp
   rule s_to_berl (state == 1);
      // $display ("    > > [s to berlekamp] cycle count: %d", cycle_count);
      ff_s_to_berl.deq();
      let datum = ff_s_to_berl.first();
      berl.s_in(datum);
   endrule

   rule t_to_berl (state == 1);
      // $display ("    > > [t to berlekamp] cycle count: %d", cycle_count);
      ff_t_to_berl.deq();
      let datum = ff_t_to_berl.first();
      berl.t_in(datum);
   endrule

   rule flag_from_berl (state == 1);
      // $display ("    > > [no error flag from syndrome] cycle count: %d", cycle_count);
      let no_error <- berl.no_error_flag_out();
      ff_no_error_flag_to_chien.enq(no_error);
      ff_no_error_flag_to_errormag.enq(no_error);      
      ff_no_error_flag_to_errorcor.enq(no_error);
   endrule

   rule l_from_berl (state == 1);
      // $display ("    > > [l from berlekamp] cycle count: %d", cycle_count);
      let datum <- berl.lambda_out();
      ff_l_to_chien.enq(datum);
   endrule

   rule w_from_berl(state == 1);
      // $display ("    > > [w from berlekamp] cycle count: %d", cycle_count);
      let datum <- berl.omega_out();
      ff_w_to_errormag.enq(datum);
   endrule

   // ----------------------------------
   // rules for chien_search
   rule t_to_chien (state == 1);
      // $display ("    > > [t to chien] cycle count: %d", cycle_count);
      ff_t_to_chien.deq();
      let datum = ff_t_to_chien.first();
      chien_search.t_in(datum);
   endrule

   rule k_to_chien (state == 1);
      ff_k_to_chien.deq ();
      let datum = ff_k_to_chien.first ();
      chien_search.k_in (datum);
   endrule

   rule l_to_chien (state == 1);
      // $display ("    > > [l to chien] cycle count: %d", cycle_count);
      ff_l_to_chien.deq();
      let datum = ff_l_to_chien.first();
      chien_search.lambda_in(datum);
   endrule

   rule no_error_flag_to_chien (state == 1);
      // $display ("    > > [no_error to chien] cycle count: %d", cycle_count);
      ff_no_error_flag_to_chien.deq ();
      let no_error = ff_no_error_flag_to_chien.first ();
      chien_search.no_error_flag_in (no_error);
   endrule

   rule flag_from_chien (state == 1);
      // $display ("    > > [flag from chien] cycle count: %d", cycle_count);
      let datum <- chien_search.cant_correct_flag_out();
      cant_correct_out.enq(datum);
   endrule
   
   rule loc_from_chien (state == 1);
      // $display ("    > > [loc from chien] cycle count: %d", cycle_count);
      let datum <- chien_search.loc_out();
      ff_loc_to_errormag.enq(datum);
   endrule
   
   rule alpha_inv_from_chien (state == 1);
      // $display ("    > > [alpha inv from chien] cycle count: %d", cycle_count);
      let datum <- chien_search.alpha_inv_out();
      ff_alpha_inv_to_errormag.enq(datum);
   endrule

   rule l_from_chien (state == 1);
      // $display ("    > > [l from berlekamp] cycle count: %d", cycle_count);
      let datum <- chien_search.lambda_out();
      ff_l_to_errormag.enq(datum);
   endrule
   
   // ----------------------------------
   // rules for error_magnitude
   rule k_to_errormag (state == 1);
      ff_k_to_errormag.deq();
      let datum = ff_k_to_errormag.first();
      error_magnitude.k_in(datum);
   endrule

   rule no_error_flag_to_errormag (state == 1);
      ff_no_error_flag_to_errormag.deq();
      let datum = ff_no_error_flag_to_errormag.first();
      error_magnitude.no_error_flag_in(datum);
   endrule
   
   rule loc_to_errormag (state == 1);
      ff_loc_to_errormag.deq();
      let datum = ff_loc_to_errormag.first();
      error_magnitude.loc_in(datum);
   endrule   
   
   rule alpha_inv_to_errormag (state == 1);
      ff_alpha_inv_to_errormag.deq();
      let datum = ff_alpha_inv_to_errormag.first();
      error_magnitude.alpha_inv_in(datum);
   endrule   

   rule l_to_errormag (state == 1);
      ff_l_to_errormag.deq();
      let datum = ff_l_to_errormag.first();
      error_magnitude.lambda_in(datum);
   endrule   
      
   rule w_to_errormag (state == 1);
      // $display ("    > > [w to chien] cycle count: %d", cycle_count);
      ff_w_to_errormag.deq();
      let datum = ff_w_to_errormag.first();
      error_magnitude.omega_in(datum);
   endrule
   
   rule e_from_errormag (state == 1);
      // $display ("    > > [e from chien] cycle count: %d", cycle_count);
      let datum <- error_magnitude.error_out();
      ff_e_to_errorcor.enq(datum);
   endrule
   
   // ----------------------------------
   // rules for error_corrector
   rule k_to_error_corrector (state == 1);
      // $display ("    > > [t to error_corrector] cycle count: %d", cycle_count);
      ff_k_to_errorcor.deq ();
      let datum = ff_k_to_errorcor.first ();
      error_corrector.k_in (datum);
   endrule

   rule no_error_flag_to_error_corrector (state == 1);
      // $display ("    > > [no_error to error_corrector] cycle count: %d", cycle_count);
      ff_no_error_flag_to_errorcor.deq();
      let no_error = ff_no_error_flag_to_errorcor.first();
      error_corrector.no_error_flag_in(no_error);
   endrule

   rule r_to_error_corrector (state == 1);
      // $display ("    > > [r to error corrector] cycle count: %d", cycle_count);
      ff_r_to_errorcor.deq ();
      let datum = ff_r_to_errorcor.first ();
      error_corrector.r_in (datum);
   endrule
   
   rule e_to_error_corrector (state == 1);
      // $display ("    > > [e to error corector] cycle count: %d", cycle_count);
      ff_e_to_errorcor.deq ();
      let error = ff_e_to_errorcor.first ();
      error_corrector.e_in (error);
   endrule
   
   rule d_from_error_corrector (state == 1);
      // $display ("    > > [d from error corector] cycle count: %d", cycle_count);
      let corrected_datum <- error_corrector.d_out ();
      stream_out.enq (corrected_datum);
   endrule
   
   // ----------------------------------
   rule cycle (state == 1);
      $display ("%d  -------------------------", cycle_count);
      cycle_count <= cycle_count + 1;
   endrule
   
   interface Put rs_t_in     = fifoToPut(t_in);
   interface Put rs_k_in     = fifoToPut(k_in);
   interface Put rs_input    = fifoToPut(stream_in);
   interface Get rs_output   = fifoToGet(stream_out);
   interface Get rs_flag     = fifoToGet(cant_correct_out);
      
endmodule

