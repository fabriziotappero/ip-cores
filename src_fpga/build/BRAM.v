//////////////////////////////////////////////////////////////////////
//
// BRAM.v
// Copyright (C) 2005 Carnegie Mellon University
//
// Description:
// Dual-ported BRAM Verilog model
//
// Revision History
// File created
// 5-18-2006, Eric Chung
//
//
// Triple read port, single write port synchronous Block RAM (synthesizable onto Xilinx block rams)
// Created on 5-17-2006
// Eric S. Chung
//


module BRAM(CLK, RST_N,
            RD_ADDR, RD_RDY,   RD_EN,
            DOUT,    DOUT_RDY, DOUT_EN,
            WR_ADDR, WR_VAL,   WR_EN);

   // synopsys template   
   parameter                   addr_width = 1;
   parameter                   data_width = 1;
   parameter                   lo = 0;
   parameter                   hi = 1;
   
   input                       CLK;
   input                       RST_N;   

   // Read Port
   // req
   input [addr_width - 1 : 0]  RD_ADDR;
   input                       RD_EN;
   output                      RD_RDY;
   // resp
   output [data_width - 1 : 0] DOUT;
   output                      DOUT_RDY;
   input                       DOUT_EN;

   // Write Port
   // req
   input [addr_width - 1 : 0]  WR_ADDR;
   input [data_width - 1 : 0]  WR_VAL;
   input                       WR_EN;

   reg [data_width - 1 : 0]    arr[lo:hi]; /*synthesis syn_ramstyle = "block_ram"*/
   
   reg                         RD_REQ_MADE;
   reg [data_width - 1 : 0]    RAM_OUT;
   
   reg  [1:0] CTR;
   
   FIFOL2#(.width(data_width)) q(.RST_N(RST_N),
                                             .CLK(CLK),
                                             .D_IN(RAM_OUT),
                                             .ENQ(RD_REQ_MADE),
                                             .DEQ(DOUT_EN),
                                             .CLR(1'b0),
                                             .D_OUT(DOUT),
                                             .FULL_N(),
                                             .EMPTY_N(DOUT_RDY));

   assign RD_RDY = (CTR > 0) || DOUT_EN;
   
   integer x;

   always@(posedge CLK)
     begin

       
       if (!RST_N)
         begin  //Make simulation behavior consistent with Xilinx synthesis
           // synopsys translate_off
           for (x = lo; x < hi; x = x + 1)
           begin
             arr[x] <= 0;
           end
           // synopsys translate_on
           CTR <= 2;
         end
       else
         begin
          
           RD_REQ_MADE <= RD_EN;
          
           if (WR_EN)
             arr[WR_ADDR] <= WR_VAL;
          
           CTR <= (RD_EN) ?
                    (DOUT_EN) ? CTR : CTR - 1 :
                    (DOUT_EN) ? CTR + 1 : CTR;
          
           RAM_OUT <= arr[RD_ADDR];
 
         end
     end // always@ (posedge CLK)

endmodule