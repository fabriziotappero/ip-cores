import FIFO::*;
import ClientServer::*;
import GetPut::*;
import Clocks::*;

import RegisterMapper::*;
import FIFOUtility::*;
import Debug::*;

Bool spiSlaveDebug = True;


typedef struct {
  data_t               data;
  MapperCommand        command;
} SPISlaveRequest#(type data_t) deriving (Bits,Eq);

interface SPISlaveWires;
 (* always_ready, always_enabled, prefix="", result="spi_slave_enable" *) 
  method Action slaveEnable(Bit#(1) enable);
 (* always_ready, always_enabled, result="spi_slave_output_line" *) 
  method Bit#(1) outputLine();
 (* always_ready, always_enabled, result="spi_slave_input_line" *) 
  method Action inputLine(Bit#(1) dataIn);
endinterface

interface SPISlave#(type data);
  interface Client#(SPISlaveRequest#(data),data) client;
  interface SPISlaveWires wires;
endinterface


typedef enum {
  Data,
  Cleanup
} SPIState deriving (Bits,Eq);

module mkSPISlaveWriteOnly#(Clock fastClock, Reset fastReset) (SPISlave#(data_t))
   provisos (Bits#(data_t,data_sz),
            Add#(1, TLog#(data_sz), TAdd#(1, TLog#(data_sz)))
            ); 

  FIFO#(SPISlaveRequest#(data_t)) outfifo <- mkFIFO(clocked_by fastClock, reset_by fastReset);
  SyncFIFOIfc#(Bit#(1)) enablefifo <- mkSyncFIFOFromCC(valueof(data_sz),fastClock);
  SyncFIFOIfc#(Bit#(1)) datafifo <- mkSyncFIFOFromCC(valueof(data_sz),fastClock);

  Reg#(Bit#(TLog#(data_sz))) dataCount <- mkRegA(0,clocked_by fastClock, reset_by fastReset);
  Reg#(SPIState) state <- mkRegA(Data,clocked_by fastClock, reset_by fastReset);
  Reg#(Bit#(data_sz)) data <- mkRegU(clocked_by fastClock, reset_by fastReset);

  
   
  // treat the top bit of ticks per transfer as the serial clock
  // We do a state transition on serial clock  1->0 to ensure signal stability in the slave.
  


  // this will reset us in the case that the enable is cranked up
  rule resetState(enablefifo.first == 1); 
    enablefifo.deq;
    datafifo.deq;
    debug(spiSlaveDebug,$display("SPI reset"));
    dataCount <= 0;   
  endrule


  rule dataAddr(enablefifo.first == 0);
    debug(spiSlaveDebug,$display("Slaving firing data count: %d, receiving: %h", dataCount, datafifo.first));
    enablefifo.deq;
    datafifo.deq;
    Bit#(TAdd#(1,TLog#(data_sz))) dataPlus = zeroExtend(dataCount) + 1;  
    // check for impending 1->0 transition
    if(dataPlus == fromInteger(valueof(data_sz)))
      begin
        dataCount <= 0;
        let dataFinal = data;
        dataFinal[dataCount] = datafifo.first;
        outfifo.enq(SPISlaveRequest{data:unpack(dataFinal), command:Write});
      end
    else
      begin
        dataCount <= truncate(dataPlus);
      end
    data[dataCount] <= datafifo.first;
  endrule


  interface Client client;
    interface Get request = fifoToGet(outfifo);
    interface Put response = ?;
  endinterface

  interface SPISlaveWires wires;
 
   method Action slaveEnable(Bit#(1) enable);
     enablefifo.enq(enable);
   endmethod

   method outputLine = ?;
 
   method Action inputLine(Bit#(1) dataIn);
     datafifo.enq(dataIn);
   endmethod
endinterface

endmodule

