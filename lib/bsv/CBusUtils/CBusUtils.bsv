import Register::*;
import Vector::*;
import GetPut::*;
import CBus::*;
import StmtFSM::*;
import Debug::*;

/* eventually we should refactor the CBUS get/put in terms of the wide
register r/w, since these are effectively the data payloads. We can probably also merge 
r/w to form one cohesive */

Bool cBusDebug = False;

/*

  This module is a CBUS mapped Put interface. 
  It behaves as if there is buffer space.  If the user does not 
  check that the interface is ready, data may be dropped on the floor. 
  The base address is a for control information.
  Subsequent addresses map the data bits in the bluespec manner.

  Read Map:
  Bit 0: busy/full

  Writing a one to a bit results in activating the method.
  Hardware will not check this stuff, for now.
  Write Map:
  Bit 0: put

*/

module  mkIWithCBusWideRegR#(Integer baseAddress, ReadOnly#(data_reg) register) (IWithCBus#(CBus#(size_bus_addr, size_bus_data), Empty))
   provisos(
            //Add#(1, k, bus_data_t_size)
            Bits#(data_reg,data_reg_size),
            Add#(xxx, 1, size_bus_data),
            Div#(data_reg_size, size_bus_data, reg_vec_size),
            Add#(data_reg_size, extra_bits, TMul#(reg_vec_size, size_bus_data)),
            Add#(not_sure_of_this, size_bus_data, TMul#(reg_vec_size, size_bus_data))); 

   // need a vector of registers
   Vector#(reg_vec_size,Reg#(Bit#(size_bus_data))) regVector = explodeRegister(readOnlyToRegister(register));

      
   interface CBus cbus_ifc;
     method Action write(Bit#(size_bus_addr) addr, Bit#(size_bus_data) data);
       noAction;
     endmethod

    // for no apparent reason they or things together.. This seems like a really bad idea..
    method ActionValue#(Bit#(size_bus_data)) read(Bit#(size_bus_addr) addr);
      Bit#(size_bus_data) result = 0;

      for(Integer i = 0; i < valueof(TDiv#(data_reg_size,size_bus_data)); i = i+1)
        begin
          if(addr == fromInteger(baseAddress + i))
            begin
              result = regVector[i]; 
            end          
        end
      debug(cBusDebug,$display("CBus Wide Reg Read: addr: %h data %h", addr, result));
      return result;
    endmethod                  
  endinterface
              
  interface Empty device_ifc = ?;   
endmodule

module [ModWithCBus#(size_bus_addr,size_bus_data)] mkCBusWideRegR#(Integer baseAddress, ReadOnly#(data_reg) register) (Empty)
   provisos(
            Bits#(data_reg,data_reg_size),
            Add#(xxx, 1, size_bus_data),
            Div#(data_reg_size, size_bus_data, reg_vec_size),
            Add#(data_reg_size, extra_bits, TMul#(reg_vec_size, size_bus_data)),
            Add#(not_sure_of_this, size_bus_data, TMul#(reg_vec_size, size_bus_data))); 
   
  Empty returnIFC <- collectCBusIFC(mkIWithCBusWideRegR(baseAddress, register));
  return returnIFC;
endmodule


module  mkIWithCBusPut#(Integer baseAddress, Put#(data_put) put) (IWithCBus#(CBus#(size_bus_addr, size_bus_data), Empty))
   provisos(
            //Add#(1, k, bus_data_t_size)
            Bits#(data_put,data_put_size),
            Add#(xxx, 1, size_bus_data),
            Div#(data_put_size, size_bus_data, reg_vec_size),
            Add#(data_put_size, extra_bits, TMul#(reg_vec_size, size_bus_data)),
            Add#(not_sure_of_this, size_bus_data, TMul#(reg_vec_size, size_bus_data))); 

   // need a vector of registers
   Reg#(Bool) attemptPut <- mkReg(False);
   Reg#(data_put) dataContainer <- mkRegU();
   Vector#(reg_vec_size,Reg#(Bit#(size_bus_data))) regVector = explodeRegister(dataContainer);

   rule attemptGetRule(attemptPut);
     debug(cBusDebug,$display("CBus Put Dumping Data: %x", dataContainer));
     put.put(dataContainer);
     attemptPut <= False;
   endrule

   
   interface CBus cbus_ifc;
     method Action write(Bit#(size_bus_addr) addr, Bit#(size_bus_data) data);
       debug(cBusDebug,$display("CBus[%h] Put Write: addr: %h data: %h", baseAddress,addr, data));
       if(addr == fromInteger(baseAddress))
         begin
           debug(cBusDebug,$display("CBus Put Activating attempt put"));
           attemptPut <= (data[0] == 1);         
         end
       else
         begin
           for(Integer i = 0; i < valueof(TDiv#(data_put_size,size_bus_data)); i = i+1)
             begin
               if(addr == fromInteger(baseAddress + 1 + i))
                 begin
                   regVector[i] <= data; 
                 end          
             end
         end
     endmethod

 
    // for no apparent reason they or things together.. This seems like a really bad idea..
    method ActionValue#(Bit#(size_bus_data)) read(Bit#(size_bus_addr) addr);
      Bit#(size_bus_data) result = 0;
      
      if(addr == fromInteger(baseAddress))
        begin
          result = {fromInteger(baseAddress),((attemptPut)?1'b1:1'b0)};
        end
      else
        begin
          for(Integer i = 0; i < valueof(TDiv#(data_put_size,size_bus_data)); i = i+1)
            begin
              if(addr == fromInteger(baseAddress + 1 + i))
                begin
                  result = regVector[i]; 
                end          
            end
        end
      debug(cBusDebug,$display("CBus Put Read: addr: %h data %h", addr, result));
      return result;
    endmethod                  
  endinterface
              
  interface Empty device_ifc = ?;   
endmodule

module [ModWithCBus#(size_bus_addr,size_bus_data)] mkCBusPut#(Integer baseAddress, Put#(data_put) put) (Empty)
   provisos(
            //Add#(1, k, bus_data_t_size)
            Bits#(data_put,data_put_size),
            Add#(xxx, 1, size_bus_data),
            Div#(data_put_size, size_bus_data, reg_vec_size),
            Add#(data_put_size, extra_bits, TMul#(reg_vec_size, size_bus_data)),
            Add#(not_sure_of_this, size_bus_data, TMul#(reg_vec_size, size_bus_data))); 
   
  Empty returnIFC <- collectCBusIFC(mkIWithCBusPut(baseAddress, put));
  return returnIFC;
endmodule



/*
  This module is a CBUS mapped Put interface. 
  It behaves as if there is buffer space.  If the user does not 
  check that the interface is ready, data may be dropped on the floor. 
  The base address is a for control information.
  Subsequent addresses map the data bits in the bluespec manner.

  Read Map:
  Bit 0: busy/full

  Writing a one to a bit results in activating the method.
  Hardware will not check this stuff, for now.
  Write Map:
  Bit 0: put

*/

module  mkIWithCBusGet#(Integer baseAddress, Get#(data_get) get) (IWithCBus#(CBus#(size_bus_addr, size_bus_data), Empty))
   provisos(
            //Add#(1, k, bus_data_t_size)
            Bits#(data_get,data_get_size),
            Add#(xxx, 1, size_bus_data),
            Div#(data_get_size, size_bus_data, reg_vec_size),
            Add#(data_get_size, extra_bits, TMul#(reg_vec_size, size_bus_data)),
            Add#(not_sure_of_this, size_bus_data, TMul#(reg_vec_size, size_bus_data))); 

   // need a vector of registers
   Reg#(Bool) attemptGet <- mkReg(False);
   Reg#(data_get) dataContainer <- mkRegU();
   Vector#(reg_vec_size,Reg#(Bit#(size_bus_data))) regVector = explodeRegister(dataContainer);

   rule attemptGetRule(attemptGet);
     let data <- get.get;
     debug(cBusDebug,$display("CBus[%h] Get invoking get: data %h", baseAddress, data));
     dataContainer <= data;
     attemptGet <= False;
   endrule

   
               interface CBus cbus_ifc;
                 method Action write(Bit#(size_bus_addr) addr, Bit#(size_bus_data) data);
                   if(addr == fromInteger(baseAddress))
                     begin
                       debug(cBusDebug,$display("CBus[%h] enable get", baseAddress));
                       attemptGet <= (data[0] == 1);         
                     end
                 endmethod


             // for no apparent reason they or things together.. This seems like a really bad idea..
                 method ActionValue#(Bit#(size_bus_data)) read(Bit#(size_bus_addr) addr);
                   Bit#(size_bus_data) result = 0;
                     if(addr == fromInteger(baseAddress))
                       begin
                         result = {fromInteger(baseAddress),((attemptGet)?1'b1:1'b0)};
                       end
                     else
                       begin
                         for(Integer i = 0; i < valueof(TDiv#(data_get_size,size_bus_data)); i = i+1)
                           begin
                             if(addr == fromInteger(baseAddress + 1 + i))
                               begin
                                 result = regVector[i]; 
                               end          
                           end
                       end
                     debug(cBusDebug,$display("CBus[%h] Get Read: addr: %h data %h", baseAddress, addr, result));
                     return result;
                 endmethod                  
               endinterface
              
               interface Empty device_ifc = ?;

   
endmodule

module [ModWithCBus#(size_bus_addr,size_bus_data)] mkCBusGet#(Integer baseAddress, Get#(data_get) get) (Empty)
   provisos(
            //Add#(1, k, bus_data_t_size)
            Bits#(data_get,data_get_size),
            Add#(xxx, 1, size_bus_data),
            Div#(data_get_size, size_bus_data, reg_vec_size),
            Add#(data_get_size, extra_bits, TMul#(reg_vec_size, size_bus_data)),
            Add#(not_sure_of_this, size_bus_data, TMul#(reg_vec_size, size_bus_data))); 
   
  Empty returnIFC <- collectCBusIFC(mkIWithCBusGet(baseAddress, get));
  return returnIFC;
endmodule

typedef enum {
  Read,
  Write
} CBusCommand deriving (Bits,Eq);

module mkMarshalCBusPut#(Integer baseAddr, Integer wordOffset, function Action putBusRequest(CBusCommand isWrite, Bit#(size_bus_addr) addr, Bit#(size_bus_data) data), function ActionValue#(Bit#(size_bus_data)) getBusResponse()) (Put#(data_t))
  provisos(
            //Add#(1, k, bus_data_t_size)
            Bits#(data_t,data_t_size),
            Div#(data_t_size, size_bus_data, reg_vec_size),
            Add#(data_t_size, extra_bits, TMul#(reg_vec_size, size_bus_data)),
            Add#(not_sure_of_this, size_bus_data, TMul#(reg_vec_size, size_bus_data))); 
  Reg#(data_t) dataContainer <- mkRegU;
  Reg#(Bit#(size_bus_addr)) transmitCount <- mkReg(0);
  Reg#(Bool) putReady <- mkReg(False);
  Vector#(reg_vec_size,Reg#(Bit#(size_bus_data))) regVector = explodeRegister(dataContainer);
  
 Stmt s = seq
            debug(cBusDebug,$display("CBusPut[%h] Marshall begins: data: %h", baseAddr, dataContainer));
            while(!putReady)
              seq
                action
                  putBusRequest(CBusUtils::Read,fromInteger(baseAddr), ?); 
                  debug(cBusDebug,$display("CBusPut[%h] Marshall sends putReady req: data:%h", baseAddr, dataContainer));
                endaction
                action
                  Bit#(size_bus_data) data <- getBusResponse;
                  debug(cBusDebug,$display("CBusPut[%h] Marshall receives putReady: %h data:%h", baseAddr, data, dataContainer));
                  putReady <= data[0] == 0;
                endaction
              endseq
            for(transmitCount <= 0; transmitCount < fromInteger(valueof(reg_vec_size)); transmitCount <= transmitCount + 1)
              seq
                putBusRequest(CBusUtils::Write,fromInteger(baseAddr+wordOffset)+fromInteger(wordOffset)*transmitCount,regVector[transmitCount]);
              endseq            
                putBusRequest(CBusUtils::Write,fromInteger(baseAddr),1);
            putReady <= False;   
            debug(cBusDebug,$display("CBusPut[%h] Marshall completes data: %h", baseAddr, dataContainer));
          endseq;

  FSM fsm <- mkFSM(s);

  method Action put(data_t data) if(fsm.done);
    debug(cBusDebug,$display("CBusPut[%h] Marshall receives data: %h", baseAddr, data));
    dataContainer <= data;
    fsm.start;
  endmethod
endmodule










// For better or worse this does a straight pull get, rather than requiring the external module to make a request
// We assume module will address words.  Thus we have a word conversion factor.
module mkMarshalCBusGet#(Integer baseAddr, Integer wordOffset, function Action putBusRequest(CBusCommand isWrite, Bit#(size_bus_addr) addr, Bit#(size_bus_data) data), function ActionValue#(Bit#(size_bus_data)) getBusResponse()) (Get#(data_t))
  provisos(
            //Add#(1, k, bus_data_t_size)
            Bits#(data_t,data_t_size),
            Div#(data_t_size, size_bus_data, reg_vec_size),
            Add#(data_t_size, extra_bits, TMul#(reg_vec_size, size_bus_data)),
            Add#(not_sure_of_this, size_bus_data, TMul#(reg_vec_size, size_bus_data))); 
  Reg#(data_t) dataContainer <- mkRegU;
  Reg#(Bit#(size_bus_addr)) transmitCount <- mkReg(0);
  Reg#(Bool) getReady <- mkReg(False);
  Reg#(Bool) hasData <- mkReg(False);
  Vector#(reg_vec_size,Reg#(Bit#(size_bus_data))) regVector = explodeRegister(dataContainer);



 Stmt s = seq
            debug(cBusDebug,$display("Cbus SIZEINFO AddrBase: %h, data_sz: %d", baseAddr, valueof(data_t_size))); 
            while(!getReady)
              seq
                putBusRequest(CBusUtils::Read,fromInteger(baseAddr), ?); 
                action
                  Bit#(size_bus_data) data <- getBusResponse;
                  getReady <= data[0] == 0;
                endaction
              endseq
            // Execute the get and then pull out the data
            putBusRequest(CBusUtils::Write,fromInteger(baseAddr),1);
            // Now we need to wait for this to go away before attempting to read.
            getReady <= False;
            while(!getReady)
              seq
                putBusRequest(CBusUtils::Read,fromInteger(baseAddr), ?); 
                action
                  Bit#(size_bus_data) data <- getBusResponse;
                  getReady <= data[0] == 0; // Wait for the 1 to get cleared...
                endaction
              endseq
            debug(cBusDebug,$display("CBus Get Marshal sees available data"));
            for(transmitCount <= 0; transmitCount < fromInteger(valueof(reg_vec_size)); transmitCount <= transmitCount + 1)
              seq
                putBusRequest(CBusUtils::Read,fromInteger(baseAddr+wordOffset)+fromInteger(wordOffset)*transmitCount,?);
                action
                  Bit#(size_bus_data) data <- getBusResponse;
                  regVector[transmitCount] <= data;
                endaction
              endseq            
            hasData <= True;
            getReady <= False;
          endseq;

  FSM fsm <- mkFSM(s);

  rule kickoffMachine(!hasData && fsm.done);
    fsm.start;
  endrule

  method ActionValue#(data_t) get() if(hasData);
    debug(cBusDebug,$display("CBusGet Marshall returns data"));
    hasData <= False;
    return dataContainer;
  endmethod
endmodule