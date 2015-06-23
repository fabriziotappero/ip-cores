
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


package mkBRAMMemController;

import MemControllerTypes::*;
import IMemClient::*;
import IMemClientBackend::*;
import IMemController::*;
import IMemScheduler::*;
import mkMemClient::*;
import BRAM::*;
import FIFOF::*;
import FIFO::*;
import Vector::*;


`define FIFO_SIZE 4

module mkBRAMMemController#(IMemScheduler#(client_number, address_type) scheduler) (IMemController#(client_number, address_type, data_type))
    provisos
          (Bits#(address_type, addr_p), 
	   Bits#(data_type, data_p),
           Bits#(MemReq#(address_type, data_type), mem_req_p),
           Literal#(address_type)
          );  
  
  BRAM#(address_type, data_type) bram <- mkBRAM_Full();
  
  Vector#(client_number, IMemClientBackend#(address_type, data_type)) client_backends = newVector(); 

  Vector#(client_number, IMemClient#(address_type, data_type)) mem_clients = newVector();
 
  FIFO#(Bit#((TAdd#(1,TLog#(client_number))))) client_tags_fifo <- mkSizedFIFO(`FIFO_SIZE);     

  for (Integer i = 0; i < valueof(client_number); i = i+1)
    begin
      client_backends[i] <- mkMemClient(i);
      mem_clients[i] = client_backends[i].client_interface;
    end
  
  rule send_request;

    Vector#(client_number, MemReqType#(address_type)) req_vec = newVector();
    //make a vector of the appropriate data
    for(int index = 0; index < fromInteger(valueof(client_number)); index = index + 1) 
      begin
        if(client_backends[index].request_fifo.notEmpty())
          begin
            req_vec[index] = case(client_backends[index].request_fifo.first()) matches
                           tagged StoreReq .sreq: return MemReqType{ prio: client_backends[index].get_priority(), 
                                                                              req: tagged StoreReq sreq.addr};
                           tagged LoadReq .lreq : return MemReqType{ prio: client_backends[index].get_priority(), 
                                                                      req:  tagged LoadReq lreq.addr};
                         endcase;
          end
        else
          begin
            req_vec[index] = MemReqType{ prio:client_backends[index].get_priority(), req: tagged Nop}; 
          end
      end
    

  Maybe#(Bit#(TAdd#(1, TLog#(client_number)))) scheduling_result <- scheduler.choose_client(req_vec);


  
  // Throw request to BRAM
  if(scheduling_result matches tagged Valid .v)
    begin
      case (client_backends[v].request_fifo.first()) matches
        tagged StoreReq .sreq: 
          begin
            $display("BRAMMemController: Write request, addr: %x data: %x, from client %d", sreq.addr, sreq.data, v); 
            bram.write(sreq.addr, sreq.data);
          end  
        tagged LoadReq .lreq: 
          begin
            bram.read_req(lreq.addr);
            client_tags_fifo.enq(v); 
            $display("BRAMMemController: Read request, addr: %x , from client %d", lreq.addr, v);           
          end         
      endcase
      client_backends[v].request_fifo.deq(); 
    end

  endrule
  
  // read response and shove it into the appropriate buffer.
  rule read_bram_response;
    Bit#((TAdd#(1, TLog#(client_number)))) target_client = client_tags_fifo.first(); 
    data_type read_result <- bram.read_resp();
    client_backends[target_client].enqueue_response(read_result);  
    client_tags_fifo.deq();
    $display("BRAMMemController: Read response, data: %x , to client %d", read_result, target_client);  
  endrule

  

  interface client_interfaces = mem_clients;
  
endmodule
endpackage