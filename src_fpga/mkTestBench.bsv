
// The MIT License

// Copyright (c) 2006-2007 Massachusetts Institute of Technology

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


//**********************************************************************
// Top level test-bench.  Mimics BRAM interface.
//----------------------------------------------------------------------
//
//

package mkTestBench;

import RegFile::*;
import IFPGAInterface::*;
import IEDKBRAM::*;
import mkTH::*;
import ISRAMWires::*;
import SRAMEmulator::*;

`define INPUT_SIZE 5298616 

interface DoubleSRAM;
  interface ISRAMWires sram_controller1;
  interface ISRAMWires sram_controller2;
endinterface


module mkTestBench();

  IFPGAInterface h264 <- mkth();
  
  ISRAMEmulator sram1 <- mkSRAMEmulator(h264.sram_controller);
  ISRAMEmulator sram2 <- mkSRAMEmulator(h264.sram_controller2);

  RegFile#(Bit#(32), Bit#(8)) rfile <- mkRegFileLoad("./ww2.8.hex", 0, `INPUT_SIZE-1);
  Reg#(Bit#(32))  data_remaining <- mkReg(`INPUT_SIZE);
  Reg#(Bit#(32))  base_offset   <- mkReg(0);
  Reg#(Bit#(32))  index <- mkReg(0); 

  rule read (h264.bram_controller.wen_output() == 0); 
    index <= h264.bram_controller.addr_output();
    if(((index & ~3) == 32'hffc) || ((index & ~3) == 32'h1ffc))
      begin
        if(base_offset < `INPUT_SIZE) 
         begin
          Bit#(16) data_slice = (data_remaining > 1024) ? 1024 : truncate(data_remaining); 
          h264.bram_controller.data_input(zeroExtend({data_slice,8'hff}));
         end
        else
         begin
          h264.bram_controller.data_input(0);
         end
      end    
    else 
      begin
       h264.bram_controller.data_input({rfile.sub(base_offset + (index  & (~32'h1003))+0), rfile.sub(base_offset + (index  & (~32'h1003)) + 1), rfile.sub(base_offset + (index  & (~32'h1003)) + 2), rfile.sub(base_offset + (index  & (~32'h1003)) + 3)});
      end
  endrule
 
  rule write (h264.bram_controller.wen_output() != 0);
    h264.bram_controller.data_input(0);
    base_offset <= base_offset + 1024;
    data_remaining <= data_remaining - 1024;
  endrule

  //interface ISRAMWires sram_controller1 =  h264.sram_controller;
  //interface ISRAMWires sram_controller2 =  h264.sram_controller2;

endmodule 

endpackage