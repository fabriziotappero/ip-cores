//
// Project      : High-Speed SDRAM Controller with adaptive bank management and command pipeline
// 
// Project Nick : HSSDRC
// 
// Version      : 1.0-beta 
//  
// Revision     : $Revision: 1.1 $ 
// 
// Date         : $Date: 2008-03-06 13:54:00 $ 
// 
// Workfile     : sdram_interpretator.sv
// 
// Description  : testbench only sdram command decoder
// 
// HSSDRC is licensed under MIT License
// 
// Copyright (c) 2007-2008, Denis V.Shekhalev (des00@opencores.org) 
// 
// Permission  is hereby granted, free of charge, to any person obtaining a copy of
// this  software  and  associated documentation files (the "Software"), to deal in
// the  Software  without  restriction,  including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the  Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
// 
// The  above  copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE  SOFTWARE  IS  PROVIDED  "AS  IS",  WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR  A  PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT  HOLDERS  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN  AN  ACTION  OF  CONTRACT,  TORT  OR  OTHERWISE,  ARISING  FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//



`include "hssdrc_timescale.vh"

module sdram_interpretator (ba, cs_n, ras_n, cas_n, we_n, a10);

  input wire [1:0] ba;
  input wire cs_n;
  input wire ras_n;
  input wire cas_n;
  input wire we_n;
  input wire a10;

  enum {
    nop, 
    act0, act1, act2, act3,
    rd0, rd1, rd2, rd3, 
    wr0, wr1, wr2, wr3, 
    bt,
    pre0, pre1, pre2, pre3,
    prea,  arefr, lmr, inop, unknown
    } cmd_e;


  always_comb begin 
    logic [3:0] tmp; 

    tmp = {cs_n, ras_n, cas_n, we_n};

    cmd_e = unknown;

    if (cs_n)
      cmd_e = inop;
    else 
      case (tmp) 
        4'b0111 : cmd_e = nop;  
        4'b0011 : begin
          case (ba) 
            2'd1    : cmd_e = act1;  
            2'd2    : cmd_e = act2;  
            2'd3    : cmd_e = act3;  
            default : cmd_e = act0;  
          endcase          
        end 
        4'b0101 : begin 
          case (ba) 
            2'd1    : cmd_e = rd1;  
            2'd2    : cmd_e = rd2;  
            2'd3    : cmd_e = rd3;  
            default : cmd_e = rd0;  
          endcase          
        end 
        4'b0100 : begin 
          case (ba) 
            2'd1    : cmd_e = wr1;  
            2'd2    : cmd_e = wr2;  
            2'd3    : cmd_e = wr3;  
            default : cmd_e = wr0;  
          endcase          
        end 
        4'b0110 : cmd_e = bt;   
        4'b0010 :  
          if (a10)  cmd_e = prea;
          else begin 
            case (ba) 
              2'd1    : cmd_e = pre1;  
              2'd2    : cmd_e = pre2;  
              2'd3    : cmd_e = pre3;  
              default : cmd_e = pre0;  
            endcase          
          end 
        4'b0001 : cmd_e = arefr;
        4'b0000 : cmd_e = lmr;
        default : cmd_e = unknown;
      endcase
  end 

endmodule
