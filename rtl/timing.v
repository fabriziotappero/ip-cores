`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// IBM 650 Reconstruction in Verilog (i650)
// 
// This file is part of the IBM 650 Reconstruction in Verilog (i650) project
// http:////www.opencores.org/project,i650
//
// Description: 650 Timing.
// 
// Additional Comments: See US 2959351, Fig. 53, 54 and 55. Additional index
//  counters provided to address general storage and register RAMs.
//
// Copyright (c) 2015 Robert Abeles
//
// This source file is free software; you can redistribute it
// and/or modify it under the terms of the GNU Lesser General
// Public License as published by the Free Software Foundation;
// either version 2.1 of the License, or (at your option) any
// later version.
//
// This source is distributed in the hope that it will be
// useful, but WITHOUT ANY WARRANTY; without even the implied
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
// PURPOSE.  See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General
// Public License along with this source; if not, download it
// from http://www.opencores.org/lgpl.shtml
//////////////////////////////////////////////////////////////////////////////////
module timing (
      input clk,
      input rst,
      output reg ap, bp, cp, dp,
      output reg dx, d0, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10,
      output reg d1_d5, d5_dx, d5_d10, d1_dx, d5_d9, d10_d1_d5,
      //output reg dxcu_d1cu, d10cl_d0cu,
      output dxl, dxu, d0l, d0u, d1l, d1u, d2l, d10u,
      output reg w0, w1, w2, w3, w4, w5, w6, w7, w8, w9,
      output reg wl, wu, ewl,
      output reg s0, s1, s2, s3, s4,
      output reg hp,
    
      output reg[0:9] digit_idx,
      output reg[0:3] early_idx, ontime_idx
   );

   reg ctr_reset;
   reg[0:3] digit_ctr;
   reg[0:3] word_ctr;
   reg[0:2] sector_ctr;
   
   assign dxl = dx & wl;
   assign dxu = dx & wu;
   assign d0l = d0 & wl;
   assign d0u = d0 & wu;
   assign d1l = d1 & wl;
   assign d1u = d1 & wu;
   assign d2l = d2 & wl;
   assign d10u = d10 & wu;
   
   //-----------------------------------------------------------------------------
   // 650 four-phase clock
   //-----------------------------------------------------------------------------
   always @(posedge clk)
      if (rst) begin
         ctr_reset <= 1;
         ap <= 1;
         bp <= 0;
         cp <= 0;
         dp <= 0;
      end else begin
         if (dp) ctr_reset <= 0;
         ap <= dp;
         bp <= ap;
         cp <= bp;
         dp <= cp;
      end;
   
   //-----------------------------------------------------------------------------
   // Counter-based timing signals
   //-----------------------------------------------------------------------------
   always @(posedge dp)
      if (ctr_reset) begin
         dx <= 0;
         d0 <= 0;
         d1 <= 0;
         d2 <= 0;
         d3 <= 0;
         d4 <= 0;
         d5 <= 0;
         d6 <= 0;
         d7 <= 0;
         d8 <= 0;
         d9 <= 0;
         d10 <= 0;
         d1_d5 <= 0;
         d5_dx <= 0; 
         d5_d10 <= 0; 
         d1_dx <= 0; 
         d5_d9 <= 0; 
         d10_d1_d5 <= 0;
         w0 <= 0;
         w1 <= 0;
         w2 <= 0;
         w3 <= 0;
         w4 <= 0;
         w5 <= 0;
         w6 <= 0;
         w7 <= 0;
         w8 <= 0;
         w9 <= 0;
         wu <= 0;
         wl <= 0;
         ewl <= 0;
         s0 <= 0;
         s1 <= 0;
         s2 <= 0;
         s3 <= 0;
         s4 <= 0;
         hp <= 0;
         digit_ctr <= 4'd0;
         word_ctr  <= 4'd0;
         sector_ctr <= 4'd0;
         digit_idx <= 10'd599;
         early_idx <= 4'd0;
         ontime_idx <= 4'd11;
      end else begin
         digit_idx <= (digit_idx + 1) % 600;
         early_idx <= (early_idx + 1) % 12;
         ontime_idx <= (ontime_idx + 1) % 12;
         digit_ctr <= (digit_ctr + 1) % 12;
         if (digit_ctr == 4'd11) begin
            word_ctr <= (word_ctr + 1) % 10;
            if (word_ctr == 9) begin
               sector_ctr <= (sector_ctr + 1) % 5;
            end;
         end;
      
         case (digit_ctr)
            4'd0: begin
                     d10 <= 0; dx <= 1;
                     d5_dx <= 0;
                     d1_dx <= 0;
                     d10_d1_d5 <= 0;
                     wl <= ~word_ctr[3];
                     wu <=  word_ctr[3];
                     case (word_ctr)
                        4'd0: begin
                                 w9 <= 0; w0 <= 1;
                                 case (sector_ctr)
                                    3'd0: begin
                                             s4 <= 0; s0 <= 1;
                                             hp <= 1;
                                          end
                                    3'd1: begin
                                             s0 <= 0; s1 <= 1;
                                          end
                                    3'd2: begin
                                             s1 <= 0; s2 <= 1;
                                          end
                                    3'd3: begin
                                             s2 <= 0; s3 <= 1;
                                          end
                                    3'd4: begin
                                             s3 <= 0; s4 <= 1;
                                          end
                                 endcase;
                              end
                        4'd1: begin
                                 w0 <= 0; w1 <= 1;
                              end
                        4'd2: begin
                                 w1 <= 0; w2 <= 1;
                              end
                        4'd3: begin
                                 w2 <= 0; w3 <= 1;
                              end
                        4'd4: begin
                                 w3 <= 0; w4 <= 1;
                              end
                        4'd5: begin
                                 w4 <= 0; w5 <= 1;
                              end
                        4'd6: begin
                                 w5 <= 0; w6 <= 1;
                              end
                        4'd7: begin
                                 w6 <= 0; w7 <= 1;
                              end
                        4'd8: begin
                                 w7 <= 0; w8 <= 1;
                              end
                        4'd9: begin
                                 w8 <= 0; w9 <= 1;
                              end
                     endcase;
                  end
            4'd1: begin
                     dx <= 0; d0 <= 1;
                     hp <= 0;
                  end
            4'd2: begin
                     d0 <= 0; d1 <= 1;
                     d1_d5 <= 1;
                  end
            4'd3: begin
                     d1 <= 0; d2 <= 1;
                     d1_dx <= 1;
                     d10_d1_d5 <= 1;
                  end
            4'd4: begin
                     d2 <= 0; d3 <= 1;
                  end
            4'd5: begin
                     d3 <= 0; d4 <= 1;
                     ewl <= wu;
                  end
            4'd6: begin
                     d4 <= 0; d5 <= 1;
                     d1_d5 <= 0;
                     d10_d1_d5 <= 0;
                     d5_dx <= 1;
                     d5_d10 <= 1;
                     d5_d9 <= 1;
                  end
            4'd7: begin
                     d5 <= 0; d6 <= 1;
                  end
            4'd8: begin
                     d6 <= 0; d7 <= 1;
                  end
            4'd9: begin
                     d7 <= 0; d8 <= 1;
                  end
            4'd10: begin
                     d8 <= 0; d9 <= 1;
                     d5_d9 <= 0;
                  end
            4'd11: begin
                     d9 <= 0; d10 <= 1;
                     d5_d10 <= 0;
                     d10_d1_d5 <= 1;
                  end
         endcase;
      end;
   
endmodule
