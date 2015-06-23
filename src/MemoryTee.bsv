
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

import H264Types::*;
import GetPut::*;
import ClientServer::*;


module mkMemoryTee#(Client#(req_type,resp_type) client, Server#(req_type,resp_type) server, String prefix) () 
  provisos(
            Bits#(req_type, req_type_sz),
            Bits#(resp_type, resp_type_sz))  ;

  rule clientToServer;
    let clientReq <- client.request.get();
    server.request.put(clientReq);
    $write(prefix);
    $write(" REQ ");
    $display("%h", clientReq);
  endrule

  rule serverToClient;
    let clientResp <- server.response.get();
    client.response.put(clientResp);
    $write(prefix);
    $write(" RESP ");
    $display("%h", clientResp);
  endrule 

endmodule