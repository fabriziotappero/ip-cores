//----------------------------------------------------------------------//
// The MIT License 
// 
// Copyright (c) 2008 Alfred Man Cheuk Ng, mcn02@mit.edu 
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

// unguarded bram
// When synthesized, one basic BRAM instance  = 4096 bits, 
// the maximum width = 16, depth = 256
module UGBRAM (CLK,
               RST_N,
               READ_A_ADDR_EN,
               READ_A_ADDR,
               READ_A_DATA,
               READ_A_DATA_RDY,
               WRITE_B_EN,
               WRITE_B_ADDR,
               WRITE_B_DATA
               );
   parameter addr_width = 1;
   parameter  data_width = 1;
   parameter  lo = 0;
   parameter  hi = 1;

   input                    CLK;
   input                    RST_N;

   // read port
   // req, always ready
   input                    READ_A_ADDR_EN;
   input [addr_width-1:0]   READ_A_ADDR;

   // resp
   output [data_width-1:0]  READ_A_DATA;
   output                   READ_A_DATA_RDY; 

   // write port, always ready
   input                    WRITE_B_EN;
   input [addr_width-1:0]   WRITE_B_ADDR;
   input [data_width-1:0]   WRITE_B_DATA;

   reg [addr_width-1:0]     READ_ADDR; // read addr need to be registered for block ram to be inferred
   reg                      READ_A_DATA_RDY;
    
   reg [data_width-1:0]     RAM [hi:lo]; /*synthesis syn_ramstyle = "block_ram"*/

   assign READ_A_DATA = RAM[READ_ADDR];

   always@(posedge CLK)
      begin
         if (!RST_N)
           READ_A_DATA_RDY <= 0;
         else
	   begin 
              if(WRITE_B_EN)
                RAM[WRITE_B_ADDR] <= WRITE_B_DATA;

              READ_ADDR <= READ_A_ADDR;
              READ_A_DATA_RDY <= (READ_A_ADDR_EN) ? 1 : 0;
           end	
      end // always@ (posedge CLK)

endmodule
