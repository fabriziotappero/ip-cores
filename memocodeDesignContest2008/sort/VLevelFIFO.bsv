//----------------------------------------------------------------------//
// The MIT License 
// 
// Copyright (c) 2008 Alfred Man Cheuk Ng, mcn02@mit.edu 
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

// import standard library
import DReg::*;
import FIFO::*;
import Vector::*;

// interface definition of a vector of logical fifos indexed by fifo_idx_t
// with data type data_t. Each fifos gives a usage report too   
interface VLevelFIFO#(numeric type no_fifo, 
                      numeric type fifo_sz, 
                      type data_t);
   
   // enq fifo idx
   method Action enq(Bit#(TLog#(no_fifo)) idx, data_t data);
      
   // deq fifo idx
   method Action deq(Bit#(TLog#(no_fifo)) idx);
      
   // read_req for first of fifo idx
   method Action firstReq(Bit#(TLog#(no_fifo)) idx);
      
   // first_resp
   method data_t firstResp();
      
   // clear all fifos
   method Action clear();
     
   // return no. elements in each fifo at the beginning of cycle
   method Vector#(no_fifo,Bit#(TLog#(TAdd#(fifo_sz,1)))) used();
            
   // return no. elements in each fifo at the end of cycle
//   method Vector#(no_fifo,Bit#(TLog#(TAdd#(fifo_sz,1)))) used2();
            
   // return no. enq credit tokens in each fifo
   method Vector#(no_fifo,Bit#(TLog#(TAdd#(fifo_sz,1)))) free();
      
   // decrement amnt of "enq credit tokens" of fifo idx
   method Action decrFree(Bit#(TLog#(no_fifo)) idx, Bit#(TLog#(TAdd#(fifo_sz,1))) amnt);   
         
endinterface
