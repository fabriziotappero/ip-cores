import FIFO::*;
import FIFOF::*;
import ClientServer::*;
import StmtFSM::*;
import GetPut::*;
import CBus::*;
import Clocks::*;

import Debug::*;
import CBusUtils::*;
// This import should be dragged to some other generic header file
import RegisterMapper::*;


Bool avalonDebug = False;

typedef struct {
  Bit#(address_width)  addr;
  Bit#(data_width)     data;
  MapperCommand        command;
} AvalonRequest#(numeric type address_width, 
                 numeric type data_width) deriving (Bits,Eq);


interface AvalonSlaveWires#(numeric type address_width, numeric type data_width);
  (* always_ready, always_enabled, prefix="", result="read" *) 
  method Action read(Bit#(1) read);
  
  (* always_ready, always_enabled, prefix="", result="write" *) 
  method Action write(Bit#(1) write);

  (* always_ready, always_enabled, prefix="", result="address" *) 
  method Action address(Bit#(address_width) address);

  (* always_ready, always_enabled, prefix="", result="writedata" *) 
  method Action writedata(Bit#(data_width) writedata);  

  (* always_ready, always_enabled, prefix="", result="readdata" *) 
  method Bit#(data_width) readdata();

  (* always_ready, always_enabled, prefix="", result="waitrequest" *) 
  method Bit#(1) waitrequest();

  (* always_ready, always_enabled, prefix="", result="readdatavalid" *) 
  method Bit#(1) readdatavalid();
  	 
endinterface
  
interface AvalonSlave#(numeric type address_width, numeric type data_width);
  interface AvalonSlaveWires#(address_width,data_width) slaveWires;
  interface Client#(AvalonRequest#(address_width,data_width), Bit#(data_width)) busClient;
endinterface

module mkAvalonSlave#(Clock asicClock, Reset asicReset) (AvalonSlave#(address_width,data_width));
  Clock clock <- exposeCurrentClock;
  Reset reset <- exposeCurrentReset;
  AvalonSlave#(address_width,data_width) m;

  if(asicClock == clock && asicReset == reset)
    begin
      m <- mkAvalonSlaveSingleDomain;
    end 
  else
    begin
      m <- mkAvalonSlaveDualDomain(asicClock,asicReset);
    end
  return m;
endmodule

module mkAvalonSlaveSingleDomain (AvalonSlave#(address_width,data_width));
  RWire#(Bit#(1)) readInValue <- mkRWire;
  RWire#(Bit#(1)) writeInValue <- mkRWire;
  RWire#(Bit#(address_width)) addressInValue <- mkRWire;
  RWire#(Bit#(data_width)) readdataOutValue <- mkRWire;
  RWire#(Bit#(data_width)) writedataInValue <- mkRWire;
  PulseWire putResponseCalled <- mkPulseWire;

  // In avalon read/write asserted for a single cycle unless 
  // waitreq also asserted.
  
  FIFOF#(AvalonRequest#(address_width,data_width)) reqFifo <- mkFIFOF;

  rule produceRequest;
    //Reads and writes are assumed not to occur simultaneously.  
    if(fromMaybe(0,readInValue.wget) == 1) 
      begin
       debug(avalonDebug,$display("AvalonSlave Side Read Req addr: %h", fromMaybe(0,addressInValue.wget())));
       reqFifo.enq(AvalonRequest{addr: fromMaybe(0,addressInValue.wget()),
                                 data: ?, 
                                 command: Read});
      end  
    else if(fromMaybe(0,writeInValue.wget) == 1) 
      begin
       debug(avalonDebug,$display("AvalonSlave Side Write Req: addr: %h data: %h", fromMaybe(0,addressInValue.wget()), fromMaybe(0,writedataInValue.wget())));
       reqFifo.enq(AvalonRequest{addr: fromMaybe(0,addressInValue.wget()),
                                 data: fromMaybe(0,writedataInValue.wget()), 
                                 command: Write});
      end  
  endrule

  interface AvalonSlaveWires slaveWires;

    method Action read(Bit#(1) readIn);
      readInValue.wset(readIn);  
    endmethod

    method Action write(Bit#(1) writeIn);
      writeInValue.wset(writeIn);  
    endmethod

    method Action address(Bit#(address_width) addressIn);
      addressInValue.wset(addressIn);  
    endmethod

    method Bit#(data_width) readdata();  
      return fromMaybe(0,readdataOutValue.wget);
    endmethod

    method Action writedata(Bit#(data_width) writedataValue);
      writedataInValue.wset(writedataValue);
    endmethod

    method Bit#(1) waitrequest();
      return (reqFifo.notFull)?0:1; 
    endmethod

    method Bit#(1) readdatavalid();
      return (putResponseCalled)?1:0;
    endmethod

  endinterface


 interface Client busClient;
   interface Get request;
     method ActionValue#(AvalonRequest#(address_width,data_width)) get();
       reqFifo.deq;
       return reqFifo.first;
     endmethod
   endinterface 

   interface Put response;
     method Action put(Bit#(data_width) data);
       debug(avalonDebug,$display("Avalon Slave Resp"));
       readdataOutValue.wset(data);
       putResponseCalled.send;
     endmethod
   endinterface
 endinterface
endmodule


interface AvalonSlaveDriverCBusWrapper#(numeric type address_width, numeric type data_width);
  method Action putBusRequest(CBusCommand isWrite, Bit#(address_width) addr, Bit#(data_width) data);
  method ActionValue#(Bit#(data_width)) getBusResponse();
endinterface

// This function converts a CBus request to a Avalon request.  It also handles the null resp from the avalon
module mkAvalonSlaveDriverCBusWrapper#(Server#(AvalonRequest#(address_width,data_width),Bit#(data_width)) server) (AvalonSlaveDriverCBusWrapper#(address_width,data_width));
  FIFO#(CBusCommand) commandFIFO <- mkSizedFIFO(50); // have to story many requests.
  
  rule deqNullResp(commandFIFO.first == CBusUtils::Write);
    commandFIFO.deq;
    debug(avalonDebug,$display("Avalon CBus Wrapper Driver Null response drop"));   
    let data <- server.response.get;
  endrule

  method Action putBusRequest(CBusCommand isWrite, Bit#(address_width) addr, Bit#(data_width) data);
  AvalonRequest#(address_width,data_width) req = AvalonRequest{addr: addr,
                                                  data: data,
                                                  command: (isWrite == Read)?Read:Write};
    debug(avalonDebug,$display("Avalon CBus Wrapper Null putBusRequest addr: %h data: %h", addr, data));   
    server.request.put(req);
    commandFIFO.enq(isWrite);
  endmethod

  method ActionValue#(Bit#(data_width)) getBusResponse() if(commandFIFO.first == CBusUtils::Read);
    commandFIFO.deq;   
    debug(avalonDebug,$display("Avalon Cbus Wrapper returning a response"));   
    let data <- server.response.get;
    return data;
  endmethod
endmodule



// This is a simple driver for the Avalon slave.  This might at somepoint serve as a starting point for an 
// Avalon master
module mkAvalonSlaveDriver#(AvalonSlaveWires#(address_width,data_width) slaveWires) (Server#(AvalonRequest#(address_width,data_width),Bit#(data_width)));
  FIFOF#(AvalonRequest#(address_width,data_width)) reqFIFO <- mkFIFOF;
  FIFOF#(Bit#(data_width)) respFIFO <- mkFIFOF;
  
  Reg#(Bit#(address_width)) addr <- mkReg(0); 
  Reg#(Bit#(data_width)) data <- mkReg(0);
  Reg#(Bit#(1)) read <- mkReg(0);
  Reg#(Bit#(1)) write <- mkReg(0);

  rule drivePins;
    slaveWires.read(read);
    slaveWires.write(write);   
    slaveWires.address(addr);
    slaveWires.writedata(data);
  endrule 

  Stmt readStmt = seq
                 addr <= reqFIFO.first.addr;
                 await(slaveWires.waitrequest==0);                   
                 read <= 1; 
                 while(slaveWires.readdatavalid==0)                   
                   action
                     debug(avalonDebug,$display("Avalon Master awaits read resp addr: %h ", addr));
                     read <= 0;                   
                     data <= slaveWires.readdata; 
                   endaction
                 action
                   debug(avalonDebug,$display("Avalon Master Driver Read resp addr: %h data: %h", addr, slaveWires.readdata)); 
                   read <= 0;                   
                   data <= slaveWires.readdata; 
                 endaction
                 action
                   debug(avalonDebug,$display("Avalaon Master Drive enq resp addr: %h data: %h", addr, data));
                   respFIFO.enq(data);
                 endaction
                 reqFIFO.deq; 
              endseq;


  Stmt writeStmt = seq                
                 debug(avalonDebug,$display("Avalon Master issues write: addr: %h data: %h",reqFIFO.first.addr,reqFIFO.first.data));
                 addr <= reqFIFO.first.addr;
                 data <= reqFIFO.first.data;
                 await(slaveWires.waitrequest==0);
                 write <= 1;
                 write <= 0;
                 respFIFO.enq(?);
                 reqFIFO.deq; 
               endseq;

  FSM readFSM <- mkFSM(readStmt);
  FSM writeFSM <- mkFSM(writeStmt);

  rule startRead(readFSM.done && writeFSM.done && reqFIFO.first.command == Read);
    debug(avalonDebug,$display("Avalon Master starts Read FSM: addr: %h ",reqFIFO.first.addr));
    readFSM.start;
  endrule

  rule startWrite(readFSM.done && writeFSM.done && reqFIFO.first.command == Write);
    debug(avalonDebug,$display("Avalon Master starts Write FSM: addr: %h data: %h",reqFIFO.first.addr,reqFIFO.first.data));
    writeFSM.start;
  endrule

  interface Put request;
    method Action put(AvalonRequest#(address_width,data_width) req);    
      reqFIFO.enq(req);
      debug(avalonDebug,$display("Avalon Master receives request: addr: %h data: %h", req.addr, req.data));
    endmethod
  endinterface 

  interface Get response = fifoToGet(fifofToFifo(respFIFO));
 
endmodule


module mkAvalonSlaveDualDomain#(Clock asicClock, Reset asicReset) (AvalonSlave#(address_width,data_width));
  RWire#(Bit#(1)) readInValue <- mkRWire;
  RWire#(Bit#(1)) writeInValue <- mkRWire;
  RWire#(Bit#(address_width)) addressInValue <- mkRWire;
  RWire#(Bit#(data_width)) readdataOutValue <- mkRWire;
  RWire#(Bit#(data_width)) writedataInValue <- mkRWire;
  PulseWire putResponseCalled <- mkPulseWire;
  
  // In avalon read/write asserted for a single cycle unless 
  // waitreq also asserted.
  
  SyncFIFOIfc#(AvalonRequest#(address_width,data_width)) reqFIFO <- mkSyncFIFOFromCC(2,asicClock);
  SyncFIFOIfc#(Bit#(data_width)) respFIFO <- mkSyncFIFOToCC(2,asicClock,asicReset);
  FIFOF#(Bit#(0)) tokenFIFO <- mkSizedFIFOF(2);

  rule produceRequest;
    //Reads and writes are assumed not to occur simultaneously.  
    if(fromMaybe(0,readInValue.wget) == 1) 
      begin
       debug(avalonDebug,$display("Avalon Slave Side Read Req: addr: %h", fromMaybe(0,addressInValue.wget())));
       tokenFIFO.enq(?);
       reqFIFO.enq(AvalonRequest{addr: fromMaybe(0,addressInValue.wget()),
                                 data: ?, 
                                 command: Read});
      end  
    else if(fromMaybe(0,writeInValue.wget) == 1) 
      begin // We are dropping data here.... need to ensure that reqFIFO has room
       debug(avalonDebug,$display("DualAvalonSlave Side Write Req"));
  
       reqFIFO.enq(AvalonRequest{addr: fromMaybe(0,addressInValue.wget()),
                                 data: fromMaybe(0,writedataInValue.wget()), 
                                 command: Write});
      end  
  endrule

  rule produceResponse;
    debug(avalonDebug,$display("Avalon Slave Resp"));
    respFIFO.deq;
    tokenFIFO.deq;
    readdataOutValue.wset(respFIFO.first);
    putResponseCalled.send;
  endrule

  interface AvalonSlaveWires slaveWires;

    method Action read(Bit#(1) readIn);
      readInValue.wset(readIn);  
    endmethod

    method Action write(Bit#(1) writeIn);
      writeInValue.wset(writeIn);  
    endmethod

    method Action address(Bit#(address_width) addressIn);
      addressInValue.wset(addressIn);  
    endmethod

    method Bit#(data_width) readdata();  
      return fromMaybe(0,readdataOutValue.wget);
    endmethod

    method Action writedata(Bit#(data_width) writedataValue);
      writedataInValue.wset(writedataValue);
    endmethod

    method Bit#(1) waitrequest();
      return (tokenFIFO.notFull && reqFIFO.notFull)?0:1; 
    endmethod

    method Bit#(1) readdatavalid();
      return (putResponseCalled)?1:0;
    endmethod

  endinterface

 interface Client busClient;
   interface Get request;
     method ActionValue#(AvalonRequest#(address_width,data_width)) get();
       reqFIFO.deq;
       return reqFIFO.first;
     endmethod
   endinterface 

   interface Put response;
     method Action put(Bit#(data_width) data);
       debug(avalonDebug,$display("Avalon Slave Resp"));
       respFIFO.enq(data);
     endmethod
   endinterface
 endinterface

endmodule

