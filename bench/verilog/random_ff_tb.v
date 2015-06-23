//////////////////////////////////////////////////////////////////////
////                                                              ////
//// random_ff_tb.v                                               ////
////                                                              ////
//// This file is part of the boundaries opencores effort.        ////
//// <http://www.opencores.org/cores/boundaries/>                 ////
////                                                              ////
//// Module Description:                                          ////
//// random flipflop testbench                                    ////
////                                                              ////
//// To Do:                                                       ////
//// Done.                                                        ////
////                                                              ////
//// Author(s):                                                   ////
//// - Shannon Hill                                               ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2004 Shannon Hill and OPENCORES.ORG            ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE. See the GNU Lesser General Public License for more  ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from <http://www.opencores.org/lgpl.shtml>                   ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// $Id: random_ff_tb.v,v 1.1 2004-07-07 12:39:14 esquehill Exp $
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
//
//

`timescale 1ns/1ps

module random_ff_tb();

reg     CLRN;  //  reset when 0
reg     SETN;  // preset when 0
reg     D;
reg     CLK;
reg     SI;
reg     SE;

wire    Q;

real       cur_delta;
parameter  max_delta = 10.0;

integer    asy_count;
integer    syn_count;

reg       [3:0] cur_state;
parameter [3:0] D2C = 4'd0;
parameter [3:0] R2C = 4'd1;
parameter [3:0] P2C = 4'd2;
parameter [3:0] R2P = 4'd3;
parameter [3:0] RW  = 4'd4;
parameter [3:0] PW  = 4'd5;
parameter [3:0] RX  = 4'd6;
parameter [3:0] PX  = 4'd7;
parameter [3:0] SE2C= 4'd8;
parameter [3:0] CKX = 4'd9;
parameter [3:0] DONE= 4'd10;

initial
begin
 cur_state   = 4'h0;
 cur_delta   = max_delta / 4.0;
       CLRN <= 1'b1;
       SETN <= 1'b1;
         D  <= 1'b0;
       CLK  <= 1'b0;
        SI  <= 1'b0;
        SE  <= 1'b0;
 #(0.3);
  asy_count  = 0;
  syn_count  = 0;
end

always #(max_delta/2.0) CLK <= ~CLK;

always @( u_ff.asy_notify ) asy_count = asy_count + 1;
always @( u_ff.syn_notify ) syn_count = syn_count + 1;

always @( negedge CLK )
begin

case( cur_state )

D2C: begin // D vs. CLK
     cur_delta = cur_delta + 0.100;
     #(cur_delta) D <= ~D;
     if( cur_delta >= (max_delta - (max_delta/4.0)) )
      begin
       cur_delta = max_delta / 4.0;

       cur_state <= R2C;

       if( asy_count != 0  )
           begin
           $display( "%d:D2C wrong number of async setup/hold violations exp=00,act=%d",$time,asy_count);
           $stop;
           end
       if( syn_count != 10 )
           begin
           $display( "%d:D2C wrong number of  sync setup/hold violations exp=10,act=%d",$time,syn_count);
           $stop;
           end

       asy_count = 0;
       syn_count = 0;
      end
     end

R2C: begin // CLRN de-assertion vs. CLK
     cur_delta = cur_delta + 0.100;
     #(cur_delta    ) CLRN <= 0;
     #(cur_delta+0.5) CLRN <= 1;
     if( cur_delta >= (max_delta - (max_delta/4.0)) )
      begin
       cur_delta = max_delta / 4.0;

       cur_state <= P2C;

       if( asy_count != 6 )
           begin
           $display( "%d:R2C wrong number of async setup/hold violations exp=06,act=%d",$time,asy_count);
           $stop;
           end
       if( syn_count != 0 )
           begin
           $display( "%d:R2C wrong number of  sync setup/hold violations exp=00,act=%d",$time,syn_count);
           $stop;
           end
       asy_count = 0;
       syn_count = 0;
      end
     end

P2C: begin // SETN de-assertion vs. CLK
     cur_delta = cur_delta + 0.100;
     #(cur_delta  ) SETN <= 0;
     #(0.7)         SETN <= 1;
     if( cur_delta >= (max_delta - (max_delta/4.0)) )
      begin
       cur_delta = max_delta / 4.0;
       cur_state <= R2P;
       if( asy_count != 11)
           begin
           $display( "%d:P2C wrong number of async setup/hold violations exp=11,act=%d",$time,asy_count);
           $stop;
           end

       if( syn_count != 0 )
           begin
           $display( "%d:P2C wrong number of  sync setup/hold violations exp=00,act=%d",$time,syn_count);
           $stop;
           end

       asy_count = 0;
       syn_count = 0;
      end
     end

R2P: begin // SETN vs CLRN;
     CLRN <= ~CLRN;   // toggles every time
     cur_delta = cur_delta + 0.100;
     #(cur_delta ) SETN <= 0;
     #( 0.7      ) SETN <= 1;
     if( cur_delta >= max_delta )
      begin
       cur_delta = max_delta / 4.0;

       cur_state <= RW;

       if( asy_count != 8 )
           begin
           $display( "%d:R2P wrong number of async setup/hold violations exp=08,act=%d",$time,asy_count);
           $stop;
           end
       if( syn_count != 0 )
           begin
           $display( "%d:R2P wrong number of  sync setup/hold violations exp=00,act=%d",$time,syn_count);
           $stop;
           end
       asy_count = 0;
       syn_count = 0;
      end
    end

RW: begin // CLRN width
             CLRN <= 1'b0;
            #(0.3);
             CLRN <= 1'b1;
            #(0.6);

      cur_state <= PW;

       if( asy_count != 1 )
           begin
           $display( "%d:RW wrong number of async setup/hold violations exp=01,act=%d",$time,asy_count);
           $stop;
           end
       if( syn_count != 0 )
           begin
           $display( "%d:RW wrong number of  sync setup/hold violations exp=00,act=%d",$time,syn_count);
           $stop;
           end
       asy_count = 0;
       syn_count = 0;
    end

PW: begin // SETN width
             SETN <= 1'b0;
            #(0.3);
             SETN <= 1'b1;
            #(0.6);

      cur_state <= RX;

       if( asy_count != 1 )
           begin
           $display( "%d:PW wrong number of async setup/hold violations exp=01,act=%d",$time,asy_count);
           $stop;
           end
       if( syn_count != 0 )
           begin
           $display( "%d:PW wrong number of  sync setup/hold violations exp=00,act=%d",$time,syn_count);
           $stop;
           end
       asy_count = 0;
       syn_count = 0;
     end

RX: begin // CLRN goes X
             CLRN <= 1'bX;
            #(0.6);
             CLRN <= 1'b1;
            #(0.6);

             if( Q !== 1'bX )
             begin
               $display( "%d:%m: Q !== X after CLRN X glitch",$time);
               $stop;
             end

             CLRN <= 1'b0;
            #(0.6);
             CLRN <= 1'b1;

      cur_state <= PX;

       if( asy_count != 0 )
           begin
           $display( "%d:RX wrong number of async setup/hold violations exp=00,act=%d",$time,asy_count);
           $stop;
           end
       if( syn_count != 0 )
           begin
           $display( "%d:RX wrong number of  sync setup/hold violations exp=00,act=%d",$time,syn_count);
           $stop;
           end
       asy_count = 0;
       syn_count = 0;
     end

PX: begin // SETN goes X
             SETN <= 1'bX;
            #(0.6);
             SETN <= 1'b1;
            #(0.6);

             if( Q !== 1'bX )
             begin
               $display( "%d:%m: Q !== X after SETN X glitch",$time);
               $stop;
             end

             SETN <= 1'b0;
            #(0.6);
             SETN <= 1'b1;

      cur_state <= SE2C;

       if( asy_count != 0 )
           begin
           $display( "%d:PX wrong number of async setup/hold violations exp=00,act=%d",$time,asy_count);
           $stop;
           end
       if( syn_count != 0 )
           begin
           $display( "%d:PX wrong number of  sync setup/hold violations exp=00,act=%d",$time,syn_count);
           $stop;
           end

       asy_count = 0;
       syn_count = 0;
    end

SE2C: begin // SE vs. CLK
     cur_delta = cur_delta + 0.100;
     #(cur_delta) SE <= ~SE;
     if( cur_delta >= (max_delta - (max_delta/4.0)) )
      begin
       cur_delta = max_delta / 4.0;
       SE        <= 1'b0;

       cur_state <= CKX;

       if( asy_count != 0 )
           begin
           $display( "%d:SE2C wrong number of async setup/hold violations exp=00,act=%d",$time,asy_count);
           $stop;
           end
       if( syn_count != 11)
           begin
           $display( "%d:SE2C wrong number of  sync setup/hold violations exp=11,act=%d",$time,syn_count);
           $stop;
           end
        asy_count = 0;
        syn_count = 0;
      end
     end

CKX: begin // CLK goes X
            CLK   <= 1'bX;
           #(0.6);
            CLK   <= 1'b1;
           #(0.6);

             if( Q !== 1'bX )
             begin
               $display( "%d:%m: Q !== X after CLK X glitch",$time);
               $stop;
             end

       cur_state <= DONE;

       if( asy_count != 0 )
           begin
           $display( "%d:CKX wrong number of async setup/hold violations exp=00,act=%d",$time,asy_count);
           $stop;
           end
       if( syn_count != 0 )
           begin
           $display( "%d:CKX wrong number of  sync setup/hold violations exp=00,act=%d",$time,syn_count);
           $stop;
           end
        asy_count = 0;
        syn_count = 0;
     end

DONE: begin
     #(100);
     $display("OK");
     $finish;
      end

default: ;
endcase
end

random_ff u_ff ( /*AUTOINST*/
                // Outputs
                .Q                      (Q),
                // Inputs
                .D                      (D),
                .CLK                    (CLK),
                .CLRN                   (CLRN),
                .SETN                   (SETN),
                .SI                     (SI),
                .SE                     (SE));

endmodule

