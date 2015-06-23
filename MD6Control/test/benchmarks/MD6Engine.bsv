//----------------------------------------------------------------------//
// The MIT License 
// 
// Copyright (c) 2008 Kermin Fleming, kfleming@mit.edu 
// 
// Permission is hereby granted, free of charge, to any person 
// obtaining a copy of this software and associated documentation 
// files (the "Software"), to deal in the Software without 
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//----------------------------------------------------------------------//
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

/* This is the top-level sorter module.  It interfaces to the PLB bus, the 
   DSOCM, and the sorter core. Not much functionality, but it does have 
   a cycle timer, and sends periodic messages back to the PPC over the 
   DSOCM 
*/
 
// Bluespec Lib
import FIFO::*;
import GetPut::*;
import Vector::*;
import Connectable::*;

// CSG Lib
import PLBMasterWires::*;
import BRAMInitiatorWires::*;
import PLBMaster::*;
import BRAMFeeder::*;
import PLBMaster::*;
import PLBMasterDefaultParameters::*;

// Local includes
import CompressionFunction::*;
import CompressionFunctionLibrary::*;
import MD6Parameters::*;
import MD6Types::*;


interface MD6Engine;
  interface PLBMasterWires                  plbMasterWires;
  interface BRAMInitiatorWires#(Bit#(14))   bramInitiatorWires;
endinterface

// Might consider making this size 8 at some point so that it jives with
// other parameterizations
typedef 16 InterfaceRegister;
typedef Bit#(15) RegisterTag;

typedef enum {
  Read = 0,
  Write = 1
} Command deriving (Bits,Eq);


typedef 7 ControlRegisters;
typedef TMul#(MD6_u,TDiv#(MD6_WordWidth,InterfaceRegister)) IdentifierRegisters; 
typedef TMul#(MD6_k,TDiv#(MD6_WordWidth,InterfaceRegister)) KeyRegisters;
typedef 2 SourceRegisters;
typedef 2 DestinationRegisters;

typedef 0 RoundRegister;
typedef 1 TreeHeightRegister;
typedef 2 LastCompressionRegister;
typedef 3 PaddingBitsRegister;
typedef 4 KeyLengthRegister;
typedef 5 DigestLengthRegister;
typedef 6 CompressionFunctionStatus;
typedef 7 KeyRegisterBase;
typedef TAdd#(ControlRegisters,KeyRegisters) IdentifierRegisterBase;
typedef TAdd#(ControlRegisters, TAdd#(KeyRegisters,IdentifierRegisters)) SourceRegisterBase;
typedef TAdd#(TAdd#(ControlRegisters,IdentifierRegisters), TAdd#(KeyRegisters,SourceRegisters)) DestinationRegisterBase;
typedef TAdd#(IdentifierRegisters,TAdd#(TAdd#(ControlRegisters,DestinationRegisters), TAdd#(KeyRegisters,SourceRegisters))) TotalRegisters;

typedef TDiv#(TMul#(SizeOf#(BusWord),BeatsPerBurst), SizeOf#(MD6Word)) MD6WordsPerBurst;

typedef 32'hC0000 MD6CommunicationConstant;

typedef struct {
  Command command; 
  RegisterTag regTag;
  Bit#(InterfaceRegister) payload;
} IOCommand deriving (Bits,Eq);

typedef enum {
  Idle,
  Load
} LoadState deriving (Bits,Eq);

typedef enum {
  Idle,
  Store
} StoreState deriving (Bits,Eq);


(*synthesize*)
module mkCompressionFunction16 (CompressionFunction#(16));
  let m <- mkSimpleCompressionFunction;
  return m;
endmodule

(*synthesize*)
module mkCompressionFunction8 (CompressionFunction#(8));
  let m <- mkSimpleCompressionFunction;
  return m;
endmodule

(*synthesize*)
module mkCompressionFunction4 (CompressionFunction#(4));
  let m <- mkSimpleCompressionFunction;
  return m;
endmodule

(*synthesize*)
module mkCompressionFunction2 (CompressionFunction#(2));
  let m <- mkSimpleCompressionFunction;
  return m;
endmodule

(*synthesize*)
module mkCompressionFunction1 (CompressionFunction#(1));
  let m <- mkSimpleCompressionFunction;
  return m;
endmodule


module mkMD6Engine (MD6Engine);
  Feeder feeder <- mkBRAMFeeder();
  PLBMaster     plbMaster <- mkPLBMaster;
  CompressionFunction#(4) compressionFunction <- mkSimpleCompressionFunction;  
  FIFO#(PPCMessage) outputFIFO <- mkFIFO;
  Vector#(TotalRegisters, Reg#(Bit#(InterfaceRegister))) interfaceRegisters <-
        replicateM(mkReg(0));
 

  // Hook Control, PLBMaster and MD6 engine components together.
  // This solution WILL NOT WORK for multiple Compression functions
  mkConnection(plbMaster.wordInput.put, compressionFunction.outputWord);
  mkConnection(compressionFunction.inputWord,plbMaster.wordOutput.get);
  mkConnection(feeder.ppcMessageInput.put,(fifoToGet(outputFIFO)).get);

  Reg#(Bit#(TAdd#(1,TDiv#(MD6_b,MD6WordsPerBurst)))) loadCount <- mkReg(0);     

  Reg#(Bit#(TAdd#(1,TDiv#(MD6_c,MD6WordsPerBurst)))) storeCount <- mkReg(0);     
    
  Reg#(LoadState) loadState <- mkReg(Idle);

  Reg#(StoreState) storeState <- mkReg(Idle);

  FIFO#(IOCommand) incomingCommands <- mkFIFO;

  function IOCommand extractIOCommand(PPCMessage ppcMessage);
    IOCommand command = IOCommand {command: unpack(ppcMessage[31]), 
                                   regTag: ppcMessage[30:16], 
                                   payload: ppcMessage[15:0]}; 
    return command;
  endfunction

  // This function may require its own unit test
  // It should convert interface words to MD6 Words
  function Vector#(length,MD6Word) convertWords(
           Vector#(TMul#(length,TDiv#(MD6_WordWidth,InterfaceRegister)),Bit#(InterfaceRegister)) inVector);
    Vector#(length,MD6Word) outVector = newVector;
    for(Integer totalNumber = 0; 
        totalNumber < valueof(length); 
        totalNumber = totalNumber + 1)
      begin
        Vector#(TDiv#(MD6_WordWidth,InterfaceRegister),Bit#(InterfaceRegister)) wordVector = newVector;
        for(Integer wordsInMD6Word = 0; 
            wordsInMD6Word < valueof(TDiv#(MD6_WordWidth,InterfaceRegister)); 
            wordsInMD6Word = wordsInMD6Word + 1) 
           begin
             wordVector[wordsInMD6Word] = inVector[totalNumber*valueof(TDiv#(MD6_WordWidth,InterfaceRegister))
                                                   +wordsInMD6Word];
           end
        outVector[totalNumber] = unpack(pack(wordVector)); // is this sane?
      end
    return outVector;
  endfunction

  rule getCommand;
    PPCMessage msg <- feeder.ppcMessageOutput.get;          
    IOCommand command = extractIOCommand(msg);
    incomingCommands.enq(command);    
  endrule

  // Writing to the CompressionFunctionStatus means kickoff a compression operation
  // Reading from it will grab the current status of the Compression Engine

  rule processWrite(incomingCommands.first.command == Write);
    incomingCommands.deq;
  
    if(fromInteger(valueof(CompressionFunctionStatus)) == incomingCommands.first.regTag) 
      begin
        // we can leave this unguarded because the properties of the compression function 
        // will prevent doing nasty things like confusing the order of memory accesses.
        let controlWord =  makeControlWord(truncate(interfaceRegisters[valueof(RoundRegister)]),
                                           truncate(interfaceRegisters[valueof(TreeHeightRegister)]),
                                           truncate(interfaceRegisters[valueof(LastCompressionRegister)]),
                                           truncate(interfaceRegisters[valueof(PaddingBitsRegister)]),
                                           truncate(interfaceRegisters[valueof(KeyLengthRegister)]),
                                           truncate(interfaceRegisters[valueof(DigestLengthRegister)]));

        compressionFunction.start(convertWords(takeAt(valueof(IdentifierRegisterBase),readVReg(interfaceRegisters))),
                                  controlWord,
                                  convertWords(takeAt(valueof(KeyRegisterBase),readVReg(interfaceRegisters))));
        loadState <= Load;
        loadCount <= 0;
      end
    else 
      begin
        interfaceRegisters[incomingCommands.first.regTag] <= incomingCommands.first.payload;
      end
  endrule

  rule processRead(incomingCommands.first.command == Read);
    incomingCommands.deq;

    // This is a bit ugly, and we should possibly fix it.
    if(fromInteger(valueof(CompressionFunctionStatus)) == incomingCommands.first.regTag)
      begin
        outputFIFO.enq(fromInteger(valueof(MD6CommunicationConstant))|zeroExtend(compressionFunction.status));
      end
    else
      begin
        outputFIFO.enq(fromInteger(valueof(MD6CommunicationConstant))|zeroExtend((interfaceRegisters[incomingCommands.first.regTag])));  
      end 

  endrule




  // Probably should handle non-fitting burst sizes.  But, don't have to
  // for now.
  if(valueof(TotalRegisters) != 47)
    begin
      error("Total Registers: %d\n",valueof(TotalRegisters));
    end

  if(valueof(MD6_b)%valueof(MD6WordsPerBurst) != 0)
    begin
      error("MD6_b:%d not divisible by MD6WordsPerBurst:%d",valueof(MD6_b), valueof(MD6WordsPerBurst));
    end

  if(valueof(MD6_c)%valueof(MD6WordsPerBurst) != 0)
    begin
      error("MD6_c:%d not divisible by MD6WordsPerBurst:%d",valueof(MD6_c), valueof(MD6WordsPerBurst));
    end

  rule issueLoads(loadState == Load);
    if(loadCount + 1 == fromInteger(valueof(MD6_b)/valueof(MD6WordsPerBurst)))
      begin
        loadState <= Idle;
        storeState <= Store;
        storeCount <= 0;
      end
    loadCount <= loadCount + 1;
    BlockAddr refAddr = truncateLSB({interfaceRegisters[valueof(SourceRegisterBase)+1],
                                     interfaceRegisters[valueof(SourceRegisterBase)]})
                                     + (zeroExtend(loadCount) << (valueof(TLog#(WordsPerBurst))));
    
    plbMaster.plbMasterCommandInput.put(tagged LoadPage refAddr);
  endrule



  rule issueStores(storeState == Store);
    if(storeCount + 1 == fromInteger(valueof(MD6_c)/valueof(MD6WordsPerBurst)))
      begin
        storeState <= Idle;
      end
    storeCount <= storeCount + 1;

    BlockAddr refAddr = truncateLSB({interfaceRegisters[valueof(DestinationRegisterBase)+1],
                                     interfaceRegisters[valueof(DestinationRegisterBase)]})
                                     + (zeroExtend(storeCount) << (valueof(TLog#(WordsPerBurst))));

    plbMaster.plbMasterCommandInput.put(tagged StorePage refAddr);
  endrule

  interface plbMasterWires = plbMaster.plbMasterWires;
  interface bramInitiatorWires = feeder.bramInitiatorWires;  
	
endmodule