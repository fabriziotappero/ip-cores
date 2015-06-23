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

import BRAMInitiatorWires::*;
import BRAM::*;

interface BRAMInitiator#(type idx_type);
  interface BRAM#(idx_type, Bit#(32)) bram;
  interface BRAMInitiatorWires#(idx_type) bramInitiatorWires;
endinterface

interface BRAMInitiatorFlat#(type idx_type);
  method ActionValue#(Bit#(32)) read_resp();
  method Action read_req(idx_type idx);
  method Action write(idx_type idx, Bit#(32) value);
  method Bit#(1) bramCLK();
  method Bit#(1) bramRST();
  method idx_type bramAddr();
  method Bit#(32) bramDout();
  method Action bramDin(Bit#(32) value);
  method Bit#(4) bramWEN();
  method Bit#(1) bramEN();
endinterface


module mkBRAMInitiator (BRAMInitiator#(idx_type))
  provisos
          (Bits#(idx_type, idx),
	   Literal#(idx_type));
  BRAMInitiatorFlat#(idx_type) bramFlat <- mkBRAMInitiatorFlat();  
 
  interface BRAM bram;
     method write = bramFlat.write;
     method read_req = bramFlat.read_req;
     method read_resp = bramFlat.read_resp;
  endinterface

  interface BRAMInitiatorWires bramInitiatorWires;
  method bramCLK    = bramFlat.bramCLK;
  method bramRST    = bramFlat.bramRST;
  method bramAddr   = bramFlat.bramAddr;
  method bramDout   = bramFlat.bramDout;
  method bramDin    = bramFlat.bramDin;
  method bramWEN    = bramFlat.bramWEN;
  method bramEN     = bramFlat.bramEN;
  endinterface

endmodule



import "BVI" BRAMInitiator = module mkBRAMInitiatorFlat
  //interface:
              (BRAMInitiatorFlat#(idx_type)) 
  provisos
          (Bits#(idx_type, idx),
	   Literal#(idx_type));

  default_clock clk(CLK);

  parameter addr_width = valueof(idx);

  method DOUT read_resp() ready(DOUT_RDY) enable(DOUT_EN);
  
  method read_req(RD_ADDR) ready(RD_RDY) enable(RD_EN);
  method write(WR_ADDR, WR_VAL) enable(WR_EN);

  method BRAM_CLK bramCLK();
  method BRAM_RST bramRST();
  method BRAM_Addr bramAddr();
  method BRAM_Dout bramDout();
  method bramDin(BRAM_Din) enable(BRAM_Dummy_Enable);
  method BRAM_WEN bramWEN();
  method BRAM_EN bramEN();

  schedule read_req  CF (read_resp, write, bramCLK, bramRST, bramAddr, bramDout, bramDin, bramWEN, bramEN);
  schedule read_resp CF (read_req, write, bramCLK, bramRST, bramAddr, bramDout, bramDin, bramWEN, bramEN);
  schedule write     CF (read_req, read_resp, bramCLK, bramRST, bramAddr, bramDout, bramDin, bramWEN, bramEN);
  // All the BRAM methods are CF
  schedule bramCLK  CF (read_resp, read_req, write, bramCLK, bramRST, bramAddr, bramDout, bramDin, bramWEN, bramEN);
  schedule bramRST  CF (read_resp, read_req, write, bramCLK, bramRST, bramAddr, bramDout, bramDin, bramWEN, bramEN);
  schedule bramAddr CF (read_resp, read_req, write, bramCLK, bramRST, bramAddr, bramDout, bramDin, bramWEN, bramEN);
  schedule bramDout CF (read_resp, read_req, write, bramCLK, bramRST, bramAddr, bramDout, bramDin, bramWEN, bramEN);
  schedule bramDin  CF (read_resp, read_req, write, bramCLK, bramRST, bramAddr, bramDout, bramDin, bramWEN, bramEN);
  schedule bramWEN  CF (read_resp, read_req, write, bramCLK, bramRST, bramAddr, bramDout, bramDin, bramWEN, bramEN);
  schedule bramEN   CF (read_resp, read_req, write, bramCLK, bramRST, bramAddr, bramDout, bramDin, bramWEN, bramEN);
 
  schedule read_req  C read_req;
  schedule read_resp C read_resp;
  schedule write     C write;

endmodule