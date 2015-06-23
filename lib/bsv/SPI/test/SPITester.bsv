import Vector::*;
import Clocks::*;
import FIFO::*;
import ClientServer::*;
import GetPut::*;

import SPIMaster::*;
import SPISlave::*;
import RegisterMapper::*;


module mkSPITester ();
  Clock clock <- exposeCurrentClock;  
  Reset reset <- exposeCurrentReset;  

  SPIMaster#(4,Bit#(8)) spiMaster <- mkSPIMaster(8);
  Reset slowReset <- mkAsyncReset(0,reset,spiMaster.wires.clock);
  
  Vector#(4,SPISlave#(Bit#(8))) spiSlaves <- replicateM(mkSPISlaveWriteOnly(clock, reset, clocked_by spiMaster.wires.clock, reset_by slowReset)); 

  Reg#(Bool) first <- mkReg(True);
  Reg#(Bit#(16)) count <- mkReg(0);
  FIFO#(Bit#(16)) fifo <- mkFIFO;
  Reg#(Bit#(3)) waitCount <- mkReg(~0);
  
  rule tickWait(waitCount != 0);
    waitCount <= waitCount - 1;
  endrule

  rule driveBus;
    $display("Driving bus");
    Bit#(4) slaveEnables = spiMaster.wires.slaveEnables;
    Bit#(1) masterOut = spiMaster.wires.outputLine;
    for(Integer i  = 0; i < 4; i = i + 1)
      begin
        spiSlaves[i].wires.inputLine(masterOut);     
        spiSlaves[i].wires.slaveEnable(slaveEnables[i]);
      end    
  endrule

  for(Integer i = 0; i < 4; i = i + 1)
    begin  
      rule checkResult (fifo.first[9:8] == fromInteger(i)) ;        
        let slaveIndex = fifo.first[9:8];
        let slaveData = fifo.first[7:0];
        
        fifo.deq;
        let masterResp <- spiMaster.server.response.get;
        let slaveResp <- spiSlaves[i].client.request.get; 
        if(slaveResp.data != slaveData)
          begin
            $display("Expected: %h, Got: %h", slaveData, slaveResp.data); 
            $finish;
          end    
       else 
          begin
            $display("Result checks.");
          end
       endrule
    end

  rule produceReq (waitCount == 0);
    $display("Sending Value %b to %d", count[7:0], count[9:8]);
    count <= count + 16'h6345;
    if(count == 9) 
      begin
        $display("PASS");
        $finish;
      end
    if(!first) 
      begin
        fifo.enq(count);
      end
    else
      begin
        first <= False;
      end
    spiMaster.server.request.put(SPIMasterRequest{data: count[7:0], slave: count[9:8]}); 
  endrule

 

endmodule