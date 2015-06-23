/*
Copyright (c) 2008 MIT

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

Author: Kermin Fleming
*/

import GetPut::*;
import List::*;
import Vector::*;
import FIFO::*;


import Register::*;

/*******
 *
 * This file serves as an adapter between a register interface and another
 * communication interface, perhaps a bus.  We should probably put bus conversion 
 * shims in here, and maybe use something split phase - that is aligned with get-put
 *
 *******/


interface RegisterMapper#(type response, type request);
  method Action registerRequest(request req);
  method ActionValue#(response) registerResponse();
endinterface 

typedef enum {
  Read = 0,
  Write = 1
} MapperCommand deriving (Bits,Eq);

typedef struct {
  MapperCommand command;
  Bit#(TLog#(mapSize)) location;
  payloadType payload;
} MapperRequest#(numeric type mapSize, type payloadType) deriving (Bits,Eq); 


module mkRegisterMapper#(function (MapperRequest#(registerMapSize,registerType)) mapperRequestExtract(request req),
                         function response responseExtract(registerType resp),    
                         Vector#(registerMapSize,Reg#(registerType)) registers) (RegisterMapper#(response, request))
  provisos (Bits#(registerType, xxx));

  FIFO#(registerType) respFIFO <- mkFIFO;
 
  method Action registerRequest(request req);

    MapperRequest#(registerMapSize,registerType) mapReq = mapperRequestExtract(req);
    //$display("register request called, Regs number: %d, Reg touched: %d payload: %h", valueof(registerMapSize), mapReq.location, mapReq.payload);
    if(mapReq.command == Read) 
      begin
        respFIFO.enq(registers[mapReq.location]);
      end
    else
      begin
        registers[mapReq.location] <= mapReq.payload;
      end
  endmethod

  method ActionValue#(response) registerResponse();
    respFIFO.deq;
    return responseExtract(respFIFO.first);
  endmethod

endmodule