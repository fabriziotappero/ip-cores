
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

package mkSatCounter;

interface SatCounter#(numeric type bits);
  method Action up();
  method Action down();
  method Bit#(bits) value(); 
endinterface


module mkSatCounter#(Bit#(bits) init) (SatCounter#(bits));
  Reg#(Bit#(bits)) counter <- mkReg(init);
  RWire#(Bit#(0)) up_called <- mkRWire();
  RWire#(Bit#(0)) down_called <- mkRWire();  

  rule update;
    if(up_called.wget matches tagged Valid .x)
      begin
        if(down_called.wget matches tagged Invalid)
          if(counter != ~0)
            counter <= counter + 1;
      end   
    else
        if(down_called.wget matches tagged Valid .x)
            if(counter != 0)
               counter <= counter - 1;
  endrule

  method Action up();
    up_called.wset(0);
  endmethod

  method Action down();
    down_called.wset(0);
  endmethod

  method Bit#(bits) value();
    return counter;
  endmethod 


endmodule

endpackage 