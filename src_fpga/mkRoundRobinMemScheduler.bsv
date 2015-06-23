
// The MIT License

// Copyright (c) 2006-2007 Massachusetts Institute of Technology

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

//This is a simple round robin memory scheduler.  It's kind of bad because it's a CAM, but hey, don't have so many clients

package mkRoundRobinMemScheduler;


import MemControllerTypes::*;
import IMemScheduler::*;
import Vector::*;

module mkRoundRobinMemScheduler  (IMemScheduler#(number_clients, address_type))
      provisos
          (Bits#(address_type, addr_p), 
           Eq#(address_type),
           Bits#(MemReqType#(address_type), mem_req_type_p),
           Eq#(MemReqType#(address_type))
           ); 
  Reg#(Bit#((TAdd#(1, TLog#(number_clients))))) first_index <- mkReg(0);
  
  function Bit#(TAdd#(1, TLog#(number_clients))) next_index ( Bit#(TAdd#(1, TLog#(number_clients))) curr_index );
   next_index = (curr_index < fromInteger(valueof(number_clients) - 1)) ? (curr_index + 1):(0);
  endfunction: next_index

  function Bit#(TAdd#(1, TLog#(number_clients))) prev_index ( Bit#(TAdd#(1, TLog#(number_clients))) curr_index );
   prev_index = (curr_index > 0) ? (curr_index - 1):(fromInteger(valueof(number_clients) - 1));
  endfunction: prev_index
   
  method ActionValue#(Maybe#(Bit#(TAdd#(1, TLog#(number_clients))))) choose_client(Vector#(number_clients, MemReqType#(address_type)) req_vec);
    Maybe#(Bit#(TAdd#(1,(TLog#(number_clients))))) target_index = tagged Invalid; 

    // Loop through command indicies backwards... this enables us to get the highest priority
    // command.
    for(Bit#((TAdd#(1, TLog#(number_clients)))) curr_index = prev_index(first_index), int count = 0; 
        count < fromInteger(valueof(number_clients)); 
        curr_index = prev_index(curr_index), count = count + 1)
      begin
        if(req_vec[curr_index].req != tagged Nop)
          begin
            target_index = tagged Valid curr_index;
          end
      end
    // set the next "high priority" index.
    if(target_index matches tagged Valid .v)
      begin 
        first_index <= next_index(v);
      end
    return target_index;
  endmethod
endmodule

endpackage