/*
 This module is intended as an in-place model for a plb-based memory subsystem.
 This code was used in Memocode 08 design project.  Memory size is
 given in 32 bit words.  */

// CSG lib includes
import PLBMaster::*;
import PLBMasterWires::*;
`ifdef PLB_DEFAULTS
  import PLBMasterDefaultParameters::*;
`endif 

// BSC includes
import Vector::*;
import FIFO::*;
import FIFOF::*;
import GetPut::*;
import RegFile::*;

interface PLBMasterEmulator#(numeric type memorySize);
  interface PLBMaster plbmaster;
endinterface
  
typedef enum {
  Load,
  Store,
  Idle
} State deriving (Bits, Eq);

module mkPLBMasterEmulator#(RegFile#(Bit#(TLog#(memorySize)),BusWord) memory) (PLBMasterEmulator#(memorySize))
  provisos(Add#(xxx,TLog#(memorySize),SizeOf#(BlockAddr)));
  Integer lineDelay = 14;

  Reg#(Bit#(TLog#(BeatsPerBurst))) plbCount <- mkReg(0);
  FIFOF#(BusWord)                   storeFIFO <- mkSizedFIFOF(valueof(BeatsPerBurst));  
  FIFOF#(PLBMasterCommand)              plbLoadCommand <- mkFIFOF();
  FIFOF#(PLBMasterCommand)              plbStoreCommand <- mkFIFOF();
  Reg#(Maybe#(Bit#(6)))   plbDelay <- mkReg(tagged Invalid);
  Reg#(State) state <- mkReg(Idle);
  

  // Only start store if store is full
  rule startStoreDelay(plbDelay matches tagged Invalid &&& plbStoreCommand.notEmpty && !storeFIFO.notFull);
    state <= Store;
    plbDelay <= tagged Valid fromInteger(lineDelay);
  endrule

  rule startLoadDelay(plbDelay matches tagged Invalid &&& plbLoadCommand.notEmpty);
    state <= Load;
    plbDelay <= tagged Valid fromInteger(lineDelay);
  endrule

  rule tickCount(plbDelay matches tagged Valid .count &&& count > 0);
    plbDelay <= tagged Valid (count - 1);
  endrule

  rule storeRule(plbStoreCommand.first matches tagged StorePage .addr &&& plbDelay matches tagged Valid .count &&& count == 0 &&& (state == Store));
    Bit#(64) wordInput = storeFIFO.first;
    // The addr refers to  32 bit addresses
    Bit#(TLog#(memorySize)) addrMod = truncate((addr>>1)+ zeroExtend(plbCount));
      
    storeFIFO.deq;
    memory.upd(addrMod,wordInput);
    $display("plbMaster store count: %d, mem[%d] <= %h",plbCount, addrMod, storeFIFO.first);
    plbCount <= plbCount + 1;
    if(plbCount + 1 == 0)
      begin
        state <= Idle;
        plbDelay <= tagged Invalid;
        plbStoreCommand.deq;
      end
  endrule

  interface PLBMaster plbmaster;
    
    interface Put wordInput;
      method Action put(Bit#(64) wordInput);
        storeFIFO.enq(wordInput);
      endmethod 
    endinterface
  
    interface Get wordOutput;
      method ActionValue#(Bit#(64)) get() if(plbLoadCommand.first matches tagged LoadPage .addr &&& plbDelay matches tagged Valid .count &&& count == 0 &&& (state == Load));   
        plbCount <= plbCount + 1;

        if(plbCount + 1 == 0)
          begin 
            $display("plbMaster load command dequed!");
            plbLoadCommand.deq;
            state <= Idle;
            plbDelay <= tagged Invalid;
          end
        // This may not be correct.
        Bit#(TLog#(memorySize)) addrMod = truncate((addr>>1) + zeroExtend(plbCount));
        $display("plbMaster load count: %d, mem[%d]: %h",plbCount, addrMod, memory.sub(addrMod));
        return memory.sub(addrMod);
      endmethod
    endinterface

    interface Put plbMasterCommandInput;
      method Action put(PLBMasterCommand command);
        $display("PLB Master got a command: %s", command matches tagged LoadPage .addr?"Load":"Store");
        if(command matches tagged StorePage .addr)
          begin          
            plbStoreCommand.enq(command);
          end
        else
          begin
            plbLoadCommand.enq(command);
          end
      endmethod
    endinterface

    interface plbMasterWires = ?;
   
  endinterface
 


endmodule