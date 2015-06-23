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

/*  This module serves as an abstraction layer for wrapping an external memory
    system.  In particular, it emulates a parametric number  of
    read and write virtual channels, sheilding the user module from the actual 
    details of the underlying memory system.  Thus, user modules may be 
    implemented targeting the same "External Memory" and then used in 
    systems with radically different memory subsystems. The module orders writes
    before reads. It is additionally parameterized by address width (Addr) 
    and data width.
*/ 


import Memocode08Types::*;
import Vector::*;
import FIFOF::*;
import Types::*;
import Interfaces::*;
import Parameters::*;
import DebugFlags::*;
import GetPut::*;

module mkExternalMemory#(PLBMaster plbmaster) (ExternalMemory);

  FIFOF#(Bit#(TAdd#(1,TLog#(ReadPortNum)))) readRespFIFO <- mkFIFOF();  
  FIFOF#(Bit#(TAdd#(1,TLog#(ReadPortNum)))) writeFIFO <- mkFIFOF();  

  Reg#(Bit#(TLog#(RecordsPerBlock))) readRespCount  <- mkReg(0);
  Reg#(Bit#(TLog#(RecordsPerBlock))) writeCount <- mkReg(0);
  Reg#(Bit#(TLog#(TAdd#(TAdd#(WritePortNum,ReadPortNum),1))))  outstandingCount <- mkReg(0);
  Reg#(Bit#(TLog#(TAdd#(WritePortNum,ReadPortNum))))  nextToSend <- mkReg(0);

  
  FIFOF#(Vector#(TAdd#(ReadPortNum, WritePortNum), Maybe#(PLBMasterCommand))) reqSnapshot <- mkSizedFIFOF(1);
  
  Vector#(ReadPortNum, RWire#(Addr)) readReqs <- replicateM(mkRWire);
  Vector#(WritePortNum, RWire#(Addr)) writeReqs <- replicateM(mkRWire);
    
  Vector#(ReadPortNum, Read) readInterfaces = newVector();
  Vector#(WritePortNum, Write) writeInterfaces = newVector();

 
  for(Integer i = 0; i < valueof(ReadPortNum); i = i + 1)
    begin
      readInterfaces[i] = 
        interface Read;
          // Should we go round robin?
          method Action readReq(Addr addr) if(reqSnapshot.notFull());
            debug(externalMemoryDebug,$display("ReadPort %d making ReadReq %h at %d", i, addr,$time));
            readReqs[i].wset(addr);                        
          endmethod

          // May want to use some buffering here.  Might help things out.
          method ActionValue#(Record) read() if(readRespFIFO.first() == 
                                                fromInteger(i));
            debug(externalMemoryDebug,$display("ReadPort %d making Read %d", i, readRespCount));
            if(readRespCount + 1 == 0)
              begin
                debug(externalMemoryDebug,$display("ReadPort %d Load Complete!", i));
                readRespFIFO.deq;
                readRespCount <= 0;
              end
            else
              begin
                readRespCount <= readRespCount + 1;
              end
            Record record <- plbmaster.wordOutput.get;
            return record;
          endmethod
        endinterface;                       
    end

  for(Integer i = 0; i < valueof(WritePortNum); i = i + 1)
    begin
      writeInterfaces[i] = 
        interface Write;
          // Should we go round robin?  SHould we delay as long as possible?
          method Action writeReq(Addr addr) if(reqSnapshot.notFull());
            debug(externalMemoryDebug,$display("WritePort %d making WriteReq %h", i, addr));
            writeReqs[i].wset(addr);
          endmethod

          // May want to use some buffering here.  Might help things out.
          method Action write(Record record) if(writeFIFO.first() == 
                                                fromInteger(i));
            if(writeCount + 1 == 0)
              begin
                debug(externalMemoryDebug,$display("WritePort %d Load Complete!", i));
                writeFIFO.deq;
                writeCount <= 0;
              end
            else
              begin
                writeCount <= writeCount + 1;
              end
            plbmaster.wordInput.put(record);
          endmethod
        endinterface;
                       
    end


  function checkMaybe(previous, maybeVal);
    if(maybeVal matches tagged Valid .data)
      begin
        return True;
      end
    else
      begin
        return previous;
      end
  endfunction
  
  function castStore(addrMaybe);
    if(addrMaybe matches tagged Valid .addr)
      begin 
        return tagged Valid StorePage(unpack(truncate(pack(addr))));    
      end
    else 
      begin
        return tagged Invalid; 
      end
  endfunction

  function castLoad(addrMaybe);
    if(addrMaybe matches tagged Valid .addr)
      begin 
        return tagged Valid LoadPage(unpack(truncate(pack(addr))));    
      end
    else 
      begin
        return tagged Invalid; 
      end
  endfunction

  function Maybe#(Addr) callwget(RWire#(Addr) rwire);
    return rwire.wget;
  endfunction

  rule processReqs;
    Bool shouldEnq = foldl(checkMaybe,False,append(map(callwget,writeReqs),map(callwget,readReqs)));
    if(shouldEnq)
      begin
        debug(externalMemoryDebug,$display("Processing Reqs at %d", $time));
        reqSnapshot.enq(append(map(castLoad, map(callwget,readReqs)),map(castStore,map(callwget,writeReqs))));        
      end
  endrule

  rule chooseReq;
    Maybe#(Bit#(TLog#(TAdd#(WritePortNum,ReadPortNum)))) sendTarget = tagged Invalid;
    for(Integer i = valueof(WritePortNum) + valueof(ReadPortNum) - 1; i >= 0; i = i - 1)
      begin
        if(reqSnapshot.first[i] matches tagged Valid .cmd &&& (fromInteger(i) >= nextToSend))
          begin
            sendTarget = tagged Valid fromInteger(i);
          end
      end   

    debug(externalMemoryDebug,$display("Sending Reqs, upto: %d, next index: %d", nextToSend, fromMaybe(-1,sendTarget)));

    if(sendTarget matches tagged Valid .index &&& reqSnapshot.first[index] matches tagged Valid .cmd)
      begin
        plbmaster.plbMasterCommandInput.put(cmd);
        if(cmd matches tagged LoadPage .addr)
          begin
            debug(externalMemoryDebug,$display("Issuing Load %d actual: %d", index, index));
            readRespFIFO.enq(truncate(index));                                
          end
        else 
          begin
            debug(externalMemoryDebug,$display("Issuing Store %d actual: %d", index, index-fromInteger(valueof(WritePortNum))));
            writeFIFO.enq(truncate(index-fromInteger(valueof(ReadPortNum))));                                
          end

        if(index >= fromInteger(valueof(WritePortNum)+ valueof(ReadPortNum) - 1)) 
          begin
            debug(externalMemoryDebug,$display("Req Q deq, due to last request"));
            reqSnapshot.deq;
            nextToSend <= 0;
          end 
        else
          begin
            nextToSend <= index + 1;
          end
      end 
    else 
      begin
        debug(externalMemoryDebug,$display("Req Q deq, due to no valid requests"));
        nextToSend <= 0;
        reqSnapshot.deq;
      end
     
  endrule


  // This is conservative...
  method Bool readsPending(); 
    return reqSnapshot.notEmpty || readRespFIFO.notEmpty;
  endmethod

  method Bool writesPending();
    return reqSnapshot.notEmpty || writeFIFO.notEmpty;
  endmethod

  interface  read = readInterfaces;
  interface  write = writeInterfaces;


endmodule





