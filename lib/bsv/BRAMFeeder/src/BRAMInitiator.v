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

module BRAMInitiator(CLK, RST_N,
            RD_ADDR, RD_RDY,   RD_EN,
            DOUT,    DOUT_RDY, DOUT_EN,
            WR_ADDR, WR_VAL,   WR_EN,
            BRAM_Addr, BRAM_Dout, BRAM_Din,BRAM_Dummy_Enable, 
            BRAM_WEN, BRAM_EN, BRAM_RST, 
            BRAM_CLK); 

   // synopsys template   
   parameter                   addr_width = 1;
   
   input                       CLK;
   input                       RST_N;   

   // Read Port
   // req
   input [addr_width -1 : 0]   RD_ADDR;
   input                       RD_EN;
   output                      RD_RDY;
   // resp
   output [31 : 0]             DOUT;
   output                      DOUT_RDY;
   input                       DOUT_EN;

   // Write Port
   // req
   input [addr_width - 1 : 0]  WR_ADDR;
   input [31 : 0]              WR_VAL;
   input                       WR_EN;

   // BRAM Wires
   output [addr_width - 1 : 0] BRAM_Addr; 
   output [31 : 0]             BRAM_Dout;
   input  [31 : 0]             BRAM_Din; 
   input                       BRAM_Dummy_Enable;
   output [3  : 0]             BRAM_WEN;
   output                      BRAM_EN; 
   output                      BRAM_RST; 
   output                      BRAM_CLK;


   // Assignments
   assign BRAM_CLK = CLK; 
   assign BRAM_EN = RST_N; // disable the BRAM if we are in reset  
   assign BRAM_RST = 1'b0; // Never reset the BRAM.
   assign BRAM_Addr = (WR_EN)?(WR_ADDR):(RD_ADDR);
   assign BRAM_WEN  = {WR_EN,WR_EN,WR_EN,WR_EN};
   assign BRAM_Dout = WR_VAL;
   
   reg                         RD_REQ_MADE;
   
   reg  [1:0] CTR;
   
   /*always@(BRAM_Din)
     $display("BRAMInitiator.v BRAM_Din: %x",BRAM_Din); 
   */

   FIFO2#(.width(32)) q(.RST_N(RST_N),
                        .CLK(CLK),
                        .D_IN(BRAM_Din),
                        .ENQ(RD_REQ_MADE),
                        .DEQ(DOUT_EN),
                        .CLR(1'b0),
                        .D_OUT(DOUT),
                        .FULL_N(),
                        .EMPTY_N(DOUT_RDY));

   assign RD_RDY = (CTR > 0);

   always@(posedge CLK)
     begin       
       if (!RST_N)
         begin  
           CTR <= 2;
         end
       else
         begin
           /*if(RD_EN)
             $display("BRAMInitiator: RD_EN");
           if(WR_EN)
             $display("BRAMInitiator: WR_EN");
           */

           RD_REQ_MADE <= RD_EN;
          
           CTR <= (RD_EN) ?
                    (DOUT_EN) ? CTR : CTR - 1 :
                    (DOUT_EN) ? CTR + 1 : CTR; 
         end
     end // always@ (posedge CLK)

endmodule