import ClientServer::*;
import FIFO::*;
import GetPut::*;
import Vector::*;
import Debug::*;

Bool clientServerDebug = False;

module mkReplicatedServer#(Server#(req_t,resp_t) server,Integer reqDepth) (Vector#(num_servers,Server#(req_t,resp_t)));
  FIFO#(Bit#(TLog#(num_servers))) numFIFO <- mkSizedFIFO(reqDepth);
  Vector#(num_servers,Server#(req_t,resp_t)) interfaces = newVector();     
  Reg#(Bit#(TAdd#(1,TLog#(num_servers)))) counter <- mkReg(0);

  rule roundRobin;
   if(counter + 1 == fromInteger(valueof(num_servers)))
     begin
       counter <= 0;
     end
   else
     begin
       counter <= counter + 1; 
     end
  endrule

  for(Integer i = 0; i < valueof(num_servers); i=i+1)
    begin
      interfaces[i] = interface Server;
                        interface Put request;
                          method Action put(req_t req) if(counter == fromInteger(i));
                            debug(clientServerDebug,$display("Replicate Server %d Req", i));
                            numFIFO.enq(fromInteger(i));
                            server.request.put(req);
                          endmethod
                        endinterface

                        interface Get response;
                          method ActionValue#(resp_t) get() if(numFIFO.first == fromInteger(i));
                              begin
                                debug(clientServerDebug,$display("Replicate Server %d Resp",i));
                                numFIFO.deq;
                                let data <- server.response.get;
                                return data;
                              end 
                          endmethod
                        endinterface
                      endinterface;
    end


  return interfaces;
endmodule
