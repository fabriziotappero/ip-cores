
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


package mkMemClient;


import MemControllerTypes::*;
import IMemClient::*;
import IMemClientBackend::*;
import FIFOF::*;
import FIFO::*;
import mkSatCounter::*;
import FIFO_2::*;

`define FIFO_SIZE 2

typedef enum {
  NORMAL,  
  WRITE_AFTER_READ
}
  MemClientState
    deriving(Bits, Eq);


module mkMemClient#(Integer client_num)  (IMemClientBackend#(addr_type, data_type))
  provisos
          (Bits#(addr_type, addr_p), 
	   Bits#(data_type, data_p),
           Bits#(MemReq#(addr_type, data_type), mem_req_p)
);

  Reg#(PRIORITY_LEVEL) priority_level <- mkReg(0);
  FIFOF#(MemReq#(addr_type, data_type)) req_fifo <- mkFIFOF(); 
  FIFOF#(Maybe#(MemReq#(addr_type, data_type))) read_fifo <- mkFIFOF();
  FIFOF#(Maybe#(MemReq#(addr_type, data_type))) write_fifo <- mkFIFOF();
  RWire#(MemReq#(addr_type, data_type)) read_enqueue <- mkRWire();
  RWire#(MemReq#(addr_type, data_type)) write_enqueue <- mkRWire();
  FIFO#(data_type) load_responses <- mkSizedFIFO(`FIFO_SIZE);
  SatCounter#(TAdd#(1, TLog#(`FIFO_SIZE))) counter <- mkSatCounter(0);
  Reg#(Bool) read_has_priority <- mkReg(True); 
  Reg#(Bool) write_has_priority <- mkReg(False);
  Reg#(MemClientState) state <- mkReg(NORMAL);

  rule process_input; 
    Maybe#(MemReq#(addr_type, data_type)) r_enq = read_enqueue.wget;
    Maybe#(MemReq#(addr_type, data_type)) w_enq = write_enqueue.wget;
    if(r_enq matches tagged Valid .r)
      begin
        read_fifo.enq(r_enq);
        write_fifo.enq(w_enq);
      end
    else if(w_enq matches tagged Valid .w)
      begin
        read_fifo.enq(r_enq);
        write_fifo.enq(w_enq);
      end    
  endrule

  rule process_queues_normal ((state == NORMAL) && (counter.value() < `FIFO_SIZE));
    if(read_fifo.first() matches tagged Valid .r )
      begin
        if(write_fifo.first() matches tagged Valid .w )
          begin 
            req_fifo.enq(r);
            counter.up();
            state <= WRITE_AFTER_READ;
          end     
        else
          begin
            req_fifo.enq(r);
            counter.up();
            read_fifo.deq();
            write_fifo.deq();            
          end
      end 
    else
      begin
        if(write_fifo.first() matches tagged Valid .w )
           begin
             req_fifo.enq(w);
             read_fifo.deq();
             write_fifo.deq();
           end
      end
  endrule

  rule process_queues_war (state == WRITE_AFTER_READ);
    if(write_fifo.first() matches tagged Valid .w ) 
      begin
        req_fifo.enq(w);
      end
    else
      begin
        $display("MemClient error, attempting to enqueue invalid write instruction");
      end
    read_fifo.deq();
    write_fifo.deq();    
    state <= NORMAL;
  endrule

  interface IMemClient client_interface; 
    // comment about read_fifo/write_fifo....
    method Action read_req(addr_type addr_in) if(read_fifo.notFull() && write_fifo.notFull());
      //$display("MemClient%dReadReq: received read_req, addr:%x", fromInteger(client_num), addr_in);
      read_enqueue.wset(tagged LoadReq{addr:addr_in}); 
    endmethod

    method ActionValue#(data_type) read_resp();
      let resp = load_responses.first();
       //$display("MemClient%dReadResp: delivered read_resp, data:%x", fromInteger(client_num), resp);
      load_responses.deq();
      if(counter.value() != 0)
        begin
          counter.down(); 
        end
      return resp;
    endmethod

    method Action write(addr_type addr_in, data_type data_in) if(read_fifo.notFull() && write_fifo.notFull());
       //$display("MemClient%d: received write_req, addr:%x, data:%x", client_num , addr_in, data_in);
      write_enqueue.wset(tagged StoreReq{addr:addr_in, data:data_in});
    endmethod

    method Action set_priority(PRIORITY_LEVEL prio);
      priority_level <= prio;
    endmethod
  endinterface

  interface request_fifo = req_fifo;  // Does this compile?

  method PRIORITY_LEVEL get_priority(); 
    return priority_level;
  endmethod

  method Action enqueue_response(data_type data_in);  
    load_responses.enq(data_in); 
  endmethod
endmodule

endpackage
