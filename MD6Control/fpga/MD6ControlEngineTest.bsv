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

/**** 
 *
 * This module serves as the top level for the MD6 control engine.
 * 
 ****/
 
// Bluespec Lib
import FIFO::*;
import GetPut::*;
import Vector::*;
import Connectable::*;
import StmtFSM::*;
import RegFile::*;

// CSG Lib
import PLBMasterWires::*;
import BRAMInitiatorWires::*;
import PLBMaster::*;
import BRAMFeeder::*;
import PLBMaster::*;
import PLBMasterDefaultParameters::*;
import PLBMasterEmulator::*;
import RegisterMapper::*;
import Register::*;

// Local includes
import MD6Control::*;
import MD6Parameters::*;
import MD6Types::*;


typedef Bit#(16) ControlReg;



typedef 16 TotalMD6ControlRegs;


// This might ought to be baked out into some sort of BSP
function  MapperRequest#(regsSize, ControlReg) mapPPCMessageToMapperRequest(PPCMessage msg)
  provisos (Add#(xxx, TLog#(regsSize), 15));
  MapperRequest#(regsSize, ControlReg) mapperRequest;
  mapperRequest.command = unpack(msg[31]);
  mapperRequest.location = truncate(msg[30:16]); 
  mapperRequest.payload = msg[15:0]; 
  return mapperRequest;
endfunction

function PPCMessage mapMapperRequestToPPCMessage(ControlReg data);
  return 32'hc0000000 | zeroExtend(data);
endfunction


module mkMD6ControlEngineTest ();
  RegFile#(Bit#(26),BusWord) memory <- mkRegFileFullLoad("md6Input.hex");
  PLBMasterEmulator#(TExp#(26)) plbmaster <- mkPLBMasterEmulator(memory);
 
 
  MD6Control#(1,48) control <- mkMD6Control;




  Reg#(Bit#(32)) memPtr <- mkReg(0);

  RegFile#(Bit#(1), Bit#(32))  rfileSize <- mkRegFileFullLoad("inputSize.hex");
  RegFile#(Bit#(TLog#(MD6_c)), BusWord) rfileRes <- mkRegFileFullLoad("md6Result.hex");
  Reg#(Bit#(TAdd#(TLog#(MD6_c),1))) resPtr <- mkReg(0);
  



  /* create action-based registers */
  /* Maybe push this down? */
  function Action wrapStart(Bool bool);
    action
    $display("wrapStart");
    if(!control.running())
      begin
        $display("calling start decode");
        control.startDecode();
      end
    endaction
  endfunction
 
  Reg#(Bool) startReg = mkRegFromActions(control.running,wrapStart);

  // Probably build a list and map and concat would be best?

  
  let regBank = append(append(append(append(append(append(append(
                              explodeRegister(control.keyRegister), //32
                              explodeRegister(control.sourceAddress)),//2
                              explodeRegister(control.destinationAddress)),//2
                              explodeRegister(control.bufferAddress)), //2
                              explodeRegister(control.bitSize)),//4
                              explodeRegister(control.bigEndian)), // 1
                              explodeRegister(startReg)), //1         
                              explodeRegister(control.digestLength)); //1         
  RegisterMapper#(PPCMessage, 
                  PPCMessage
                 ) regMapper <- mkRegisterMapper(mapPPCMessageToMapperRequest,
                                                 mapMapperRequestToPPCMessage,
                                                 regBank);  


  // Hook up the system
  mkConnection(plbmaster.plbmaster.wordInput.put,control.wordOutput);
  mkConnection(control.wordInput,plbmaster.plbmaster.wordOutput.get);
  mkConnection(plbmaster.plbmaster.plbMasterCommandInput.put,control.outputCommand);
  // mkConnection(regMapper.registerRequest, feeder.ppcMessageOutput.get);
  // mkConnection(feeder.ppcMessageInput.put, regMapper.registerResponse); 
/*
  mapperRequest.command = unpack(msg[31]);
  mapperRequest.location = truncate(msg[30:16]); 
  mapperRequest.payload = msg[15:0]; 
  */
  Bit#(32) inputSize = (((rfileSize.sub(0))/fromInteger(8*valueof(MD6_b))) + 1)*fromInteger(valueof(MD6_b));

/******
 * The reg map
 * 0-31   key
 * 32-33  source ptr
 * 34-35  destination ptr
 * 36-37  buffer ptr
 * 38-41  bitSize
 * 42     endianess
 * 43     start/status
 * 44     digestLength
 ******/

  

  Reg#(Bit#(7)) i <- mkReg(0);
  Reg#(Bool) done <- mkReg(False);
  Bit#(64) sizeValue = zeroExtend(rfileSize.sub(0));

  Stmt s = seq
             for( i <= 0; i < 32; i <= i + 1)
               seq
                 regMapper.registerRequest({1'b1,zeroExtend(i),16'h0});
               endseq
             regMapper.registerRequest({1'b1,15'd32,0});
             regMapper.registerRequest({1'b1,15'd33,0});
             regMapper.registerRequest({1'b1,15'd34,(2*inputSize)[15:0]});
             regMapper.registerRequest({1'b1,15'd35,(2*inputSize)[31:16]});
             regMapper.registerRequest({1'b1,15'd36,(4*inputSize)[15:0]});
             regMapper.registerRequest({1'b1,15'd37,(4*inputSize)[31:16]});
             $display("InputSize: %h", sizeValue);
             regMapper.registerRequest({1'b1,15'd38,(sizeValue)[15:0]});
             regMapper.registerRequest({1'b1,15'd39,(sizeValue)[31:16]});
             regMapper.registerRequest({1'b1,15'd40,(sizeValue)[47:32]});
             regMapper.registerRequest({1'b1,15'd41,(sizeValue)[63:48]});
             regMapper.registerRequest({1'b1,15'd42,16'h1});
             regMapper.registerRequest({1'b1,15'd44,512});  
             regMapper.registerRequest({1'b1,15'd43,16'h0});  
             delay(100);
             regMapper.registerRequest({1'b0,15'd43,16'h0});
             while(!done)
               seq
                 regMapper.registerRequest({1'b0,15'd43,16'h0});
                 delay(100);
                 action 
                   let value <- regMapper.registerResponse();
                   $display("Doness: %d",value);
                   done <= (value[15:0] == 0);
                 endaction
               endseq
             delay(100);
             for(resPtr <= 0; 
                 resPtr < fromInteger(valueof(MD6_c)); 
                 resPtr <= resPtr+1)
             seq
               if(rfileRes.sub(truncate(resPtr)) != memory.sub(truncate(zeroExtend(resPtr) +  inputSize)))
                 seq
                   $display("Offset: %d rfile: %d",zeroExtend(resPtr), rfileSize.sub(0));
                   $display("FAILED at %d, %h != %h", inputSize+zeroExtend(resPtr),rfileRes.sub(truncate(resPtr)),memory.sub(truncate(zeroExtend(resPtr) +  inputSize)));
                   $finish;
                 endseq 
               else
                 seq
                   $display("Match at %d", zeroExtend(resPtr) + inputSize);
                 endseq
             endseq 
             $display("PASS");
             $finish;
           endseq;

  FSM fsm <- mkFSM(s);


  rule startFSM;
    fsm.start;
  endrule


endmodule