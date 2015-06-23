/*
Copyright (c) 2007 MIT

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


import Parameters::*;
import Types::*;
import Interfaces::*;

function String showReg (MatrixRegister r);

  case (r)
    A: return "A";
    B: return "B";
    C: return "C";
  endcase

endfunction

function String showFunctionalUnitOp(FunctionalUnitOp f);
  case (f)
    Multiply: return "Multiply";
    Zero: return "Zero";
    MultiplyAddAccumulate: return "MultiplyAddAccumulate";
    MultiplySubAccumulate:return "MultiplySubAccumulate";
    AddAccumulate: return "AddAccumulate";
    SubAccumulate:return "SubAccumulate";
  endcase
endfunction


function Action showInst (Instruction ins);

  case (ins) matches
    tagged ArithmeticInstruction .i:
      $display("ARITH %0b %0b", i.fus, i.op);
    tagged LoadInstruction .i:
      $display("LOAD %0b %s 0x%0h", i.fus, showReg(i.regName), i.addr);
    tagged StoreInstruction .i:
      $display("STORE %0b %s 0x%0h", i.fu, showReg(i.regName), i.addr);
    tagged ForwardInstruction .i:
      $display("FORWARD %0b %s %0b %s", i.fuSrc, showReg(i.regSrc), i.fuDests, showReg(i.regDest));
    tagged SetRowSizeInstruction .sz:
      $display("SetRowSizeInstruction 0x%0h", sz); 
  endcase
  
endfunction

function Action displayInst (Instruction ins);

  case (ins) matches
    tagged ArithmeticInstruction .i:
      $display("ARITH %0b %0b", i.fus, i.op);
    tagged LoadInstruction .i:
      $display("LOAD %0b %s 0x%0h", i.fus, showReg(i.regName), i.addr);
    tagged StoreInstruction .i:
      $display("STORE %0b %s 0x%0h", i.fu, showReg(i.regName), i.addr);
    tagged ForwardInstruction .i:
      $display("FORWARD %0b %s %0b %s", i.fuSrc, showReg(i.regSrc), i.fuDests, showReg(i.regDest));
    tagged SetRowSizeInstruction .sz:
      $display("SetRowSizeInstruction 0x%0h", sz); 
  endcase
  
endfunction

function Tuple2#(Bit#(32), Bit#(32)) splitInst(Instruction i) = split(zeroExtend(pack(i)));
function Instruction fuseInst(Bit#(32) x ,Bit#(32) y) = unpack(truncate({x, y}));


function Bit#(m) oneHot(Bit#(n) x) provisos (Log#(m, n));

   Bit#(m) tmp = 0;
   tmp[x] = 1;
   return tmp;

endfunction

//This can be mapped across Vectors, etc.

function FUNetworkLink getLink(FunctionalUnit#(t) f);
  return f.link;
endfunction

