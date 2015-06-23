import FIFO::*;
import ClientServer::*;
import GetPut::*;
import Clocks::*;

import RegisterMapper::*;
import FIFOUtility::*;
import Debug::*;

Bool spiMasterDebug = False;



/* This module implements the SPI bus, a simple protocol. */
typedef struct {
  Bit#(TLog#(slaves))  slave;
  data_t               data;
} SPIMasterRequest#( numeric type slaves,
                     type data_t) deriving (Bits,Eq);

interface SPIMasterWires#(numeric type slaves);
 (* always_ready, always_enabled, prefix="", result="spi_slave_enable" *) 
  method Bit#(slaves) slaveEnables();
 (* always_ready, always_enabled, result="spi_output_line" *) 
  method Bit#(1) outputLine();
 (* always_ready, always_enabled, result="spi_input_line" *) 
  method Action inputLine(Bit#(1) dataIn);
  interface Clock clock;
endinterface

interface SPIMaster#(numeric type slaves, type data);
  interface Server#(SPIMasterRequest#(slaves,data),data) server;
  interface SPIMasterWires#(slaves) wires;
endinterface

  typedef enum {
    Idle,
    ClockWait,
    Data,
    Cleanup
  } SPIState deriving (Bits,Eq); 


//Need to chop 

module mkSPIMaster#(Integer divisor) (SPIMaster#(slaves,data_t))
  provisos (Bits#(data_t,data_sz),
            Add#(1, TLog#(data_sz), TAdd#(1, TLog#(data_sz)))
            );
   
  Clock clock <- exposeCurrentClock;
  Reset reset <- exposeCurrentReset;

  if(divisor < 2) 
    begin
      error("divisor must be at least 2");
    end

  ClockDividerIfc spiClock <- mkClockDivider(divisor);
  ClockDividerIfc toggleClock <- mkClockDivider(divisor/2);

  Reset toggleReset <- mkAsyncReset(1,reset,toggleClock.slowClock);  // is this right?
  Reset spiReset <- mkAsyncReset(1,reset,spiClock.slowClock);  // is this right?

  // This could be disasterous, if we up clock during the high edge of the gated clock.  toggle reg should prevent this
  GatedClockIfc gatedSlowClock <- mkGatedClock(False,spiClock.slowClock, clocked_by toggleClock.slowClock, reset_by toggleReset);  

  SyncFIFOIfc#(SPIMasterRequest#(slaves, data_t)) infifo <- mkSyncFIFOToSlow(2,toggleClock,toggleReset);
  SyncFIFOIfc#(data_t) outfifo <- mkSyncFIFOToFast(2,toggleClock,toggleReset);

  Reg#(Bit#(TLog#(data_sz))) dataCount <- mkRegA(0,clocked_by toggleClock.slowClock,
                                                 reset_by toggleReset);
  Reg#(SPIState) state <- mkRegA(Idle, clocked_by toggleClock.slowClock,
                                                 reset_by toggleReset);

  Reg#(Bit#(data_sz)) data <- mkRegU(clocked_by toggleClock.slowClock,
                                                 reset_by toggleReset);

  // toggle may not be quite right.
  Reg#(Bool) toggle <- mkReg(False, clocked_by toggleClock.slowClock, reset_by toggleReset); // this reg makes sure the we are in-phase with the low edge of spiClock


  Reg#(Bit#(slaves)) enableReg <- mkReg(~0, clocked_by toggleClock.slowClock, reset_by toggleReset); 
  ReadOnly#(Bit#(slaves)) enableCrossing <- mkNullCrossingWire(spiClock.slowClock,enableReg._read, clocked_by toggleClock.slowClock, reset_by toggleReset);

  Reg#(Bit#(1))      outputReg <- mkReg(~0, clocked_by toggleClock.slowClock, reset_by toggleReset); 
  ReadOnly#(Bit#(1)) outputCrossing <- mkNullCrossingWire(spiClock.slowClock, outputReg._read, clocked_by toggleClock.slowClock, reset_by toggleReset);
  
//XXX fix me
//  Reg#(Bit#(1)) inputReg <- mkReg(0,clocked_by spiClock.slowClock, reset_by spiReset);
//  ReadOnly#(Bit#(1)) outputCrossing <- mkNullCrossingWire(spiClock.slowClock, inputReg.read, clocked_by spiClock.slowClock, reset_by spiReset);

  Bit#(TAdd#(1,TLog#(data_sz))) dataPlus = zeroExtend(dataCount) + 1;  

  // treat the top bit of ticks per transfer as the serial clock
  // We do a state transition on serial clock  1->0 to ensure signal stability in the slave.

  rule toggleTick;
    toggle <= !toggle; 
  endrule

  rule setup(state == Idle && infifo.notEmpty && toggle);
    debug(spiMasterDebug,$display("SPIMaster Setup called data: %b slave: %d",infifo.first.data ,infifo.first.slave )); 
    gatedSlowClock.setGateCond(True);
    state <= Data;
    enableReg <= ~(1<<(infifo.first.slave));
    debug(spiMasterDebug,$display("SPIMaster sending setupWait:  %h", pack(infifo.first.data)[dataCount]));
    outputReg <= (pack(infifo.first.data)[dataCount]);
  endrule


  rule cleanup(state == Cleanup && toggle);
    outfifo.enq(unpack(data));
    state <= Idle;
    enableReg <= ~0;
  endrule


  rule handleData(state == Data && toggle);
    debug(spiMasterDebug,$display("SPIMaster Data  called"));
    if(dataPlus == fromInteger(valueof(data_sz)))
      begin
        debug(spiMasterDebug,$display("SPIMaster transfer done"));
        dataCount <= 0;
        infifo.deq;
        state <= Cleanup;
        gatedSlowClock.setGateCond(False); // may be too early
      end
    else
      begin
        dataCount <= truncate(dataPlus);
      end

  
    Bit#(TLog#(data_sz)) dataIndex = truncate(dataPlus);
    outputReg <= pack(infifo.first.data)[dataIndex];
    debug(spiMasterDebug,$display("SPIMaster sending:  %h", pack(infifo.first.data)[dataIndex]));
  //  data[dataCount] <= fromMaybe(0,inputWire.wget);
  endrule  

  interface Server server;
    interface Put request = syncFifoToPut(infifo);
    interface Get response = syncFifoToGet(outfifo);
  endinterface

interface SPIMasterWires wires;
  //method slaveEnables = enableCrossing._read;
  //method outputLine = outputCrossing._read; 

  method Bit#(slaves) slaveEnables();
    return enableCrossing._read;
  endmethod

  method Bit#(1) outputLine();
    return outputCrossing._read;
  endmethod

  method Action inputLine(Bit#(1) dataIn);
//    inputWire.wset(dataIn);
  endmethod

  interface clock = gatedSlowClock.new_clk;
endinterface  

endmodule

