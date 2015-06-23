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

// CSG Lib
import PLBMasterWires::*;
import BRAMInitiatorWires::*;
import PLBMaster::*;
import BRAMFeeder::*;
import PLBMaster::*;
import PLBMasterDefaultParameters::*;
import RegisterMapper::*;
import Register::*;

// Local includes
import MD6Control::*;
import MD6Parameters::*;
import MD6Types::*;


interface MD6Engine;
  interface PLBMasterWires                  plbMasterWires;
  interface BRAMInitiatorWires#(Bit#(14))   bramInitiatorWires;
endinterface



typedef Bit#(16) ControlReg;

/******
 * The reg map
 * 0-31   key
 * 32-33  source ptr
 * 34-35  destination ptr
 * 36-37  buffer ptr
 * 38-41  bitSize
 * 42     endianess
 * 43     start/status
 ******/

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
  return 32'hc0000 | zeroExtend(data);
endfunction

module mkMD6ControlEngine (MD6Engine);
  Feeder feeder <- mkBRAMFeeder();
  PLBMaster     plbmaster <- mkPLBMaster;
  MD6Control#(1,32) control <- mkMD6Control;

  /* create action-based registers */
  /* Maybe push this down? */
  function Action wrapStart(Bool bool);
    action
    if(!control.running())
      begin
        control.startDecode();
      end
    endaction
  endfunction
 
  Reg#(Bool) startReg = mkRegFromActions(control.running,wrapStart);

  // Probably build a list and map and concat would be best?
  
    let regBank = append(append(append(append(append(append(append(
                              explodeRegister(control.keyRegister),
                              explodeRegister(control.sourceAddress)),
                              explodeRegister(control.destinationAddress)),
                              explodeRegister(control.bufferAddress)), 
                              explodeRegister(control.bitSize)),
			      explodeRegister(control.bigEndian)), 
                              explodeRegister(startReg)),
                              explodeRegister(control.digestLength));         

  RegisterMapper#(PPCMessage, 
                  PPCMessage
                 ) regMapper <- mkRegisterMapper(mapPPCMessageToMapperRequest,
                                                 mapMapperRequestToPPCMessage,
                                                 regBank);  


  // Hook up the system
  mkConnection(plbmaster.wordInput.put,control.wordOutput);
  mkConnection(control.wordInput,plbmaster.wordOutput.get);
  mkConnection(plbmaster.plbMasterCommandInput.put,control.outputCommand);
  mkConnection(regMapper.registerRequest, feeder.ppcMessageOutput.get);
  mkConnection(feeder.ppcMessageInput.put, regMapper.registerResponse); 

  interface plbMasterWires = plbmaster.plbMasterWires;
  interface bramInitiatorWires = feeder.bramInitiatorWires; 

endmodule