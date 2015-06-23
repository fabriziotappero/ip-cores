
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

import RegFile::*;
import ISRAMWires::*;

interface ISRAMEmulator;

endinterface


module mkSRAMEmulator#(ISRAMWires wires) (ISRAMEmulator);
  RegFile#(Bit#(18), Bit#(32))  arr <- mkRegFileFull();
  Reg#(Bit#(18)) addr_p <- mkReg(0);
  Reg#(Bit#(18)) addr_pp <- mkReg(0);
  Reg#(Bit#(1))  we_p <- mkReg(0);
  Reg#(Bit#(1))  we_pp <- mkReg(0);
 
  rule tick;
    Bit#(18) addr_pt = wires.address_out();
    Bit#(32) data_Ot = wires.data_O();
    wires.data_I(arr.sub(addr_pp)); 
    addr_p <= addr_pt;
    addr_pp <= addr_p;
    we_p <= wires.we_out();
    we_pp <= we_p;
      
    if(we_pp == 1)
      begin
        //$display("MemClient SRAM Emulator: index %h reading %h", addr_pp, arr.sub(addr_pp));   
      end   
    else
      begin
        //$display("MemClient SRAM Emulator: index %h writing %h", addr_pp, data_Ot);
        arr.upd(addr_pp, data_Ot);
      end
  endrule

endmodule

