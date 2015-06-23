/////////////////////////////////////////////////////////////////////
////                                                             ////
////  JPEG Entropy Coding, Huffman Encoding                      ////
////                                                             ////
////  Creates 8bit output stream from huffman codes.             ////
////  See accompanying testbench how to use this code.           ////
////                                                             ////
////  Author: Richard Herveille                                  ////
////          richard@asics.ws                                   ////
////          www.asics.ws                                       ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2001 Richard Herveille                        ////
////                    richard@asics.ws                         ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////

//  CVS Log
//
//  $Id: huffman_enc.v,v 1.2 2002-10-31 12:50:40 rherveille Exp $
//
//  $Date: 2002-10-31 12:50:40 $
//  $Revision: 1.2 $
//  $Author: rherveille $
//  $Locker:  $
//  $State: Exp $
//

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on

module huffman_enc(clk, rst, tablesel, di, die, do, doe, busy);
  input        clk;      // clock
  input        rst;      // asynchronous active low reset
  input  [1:0] tablesel; // huffman table select (0-3)
  input  [7:0] di;       // data-in
  input        die;      // data-in enable
  output [7:0] do;       // data out
  output       doe;      // data-out enable
  output       busy;     // busy. Do not assert die while busy asserted

  reg [7:0] do;
  reg       doe;


  wire [12:0] henc_dc_lum;
  wire [14:0] henc_dc_chr;
  wire [19:0] henc_ac_lum, henc_ac_chr;
  reg  [ 4:0] codelen;
  reg  [15:0] code;
  reg         ddie;

  reg         state;
  reg  [22:0] sreg;
  reg  [ 4:0] cnt;


  // include default tables
  `include "huffman_tables.v"

  //
  // hookup huffman tables
  //
  assign henc_dc_lum = jpeg_dc_luminance_huffman_enc( di[3:0] );
  assign henc_dc_chr = jpeg_dc_chrominance_huffman_enc( di[3:0] );
  assign henc_ac_lum = jpeg_ac_luminance_huffman_enc( di[7:4], di[3:0] );
  assign henc_ac_chr = jpeg_ac_chrominance_huffman_enc( di[7:4], di[3:0] );

  //
  // split table-data into codeword and codeword-length
  //
  always @(posedge clk)
    case (tablesel) // synopsys full_case parallel_case
      2'b00: // DC Luminance
        begin
            codelen <= #1 henc_dc_lum[12: 9] +4'h1;
            code    <= #1 henc_dc_lum[ 8: 0];
        end

      2'b01: // DC Chrominance
        begin
            codelen <= #1 henc_dc_chr[14:11] +4'h1;
            code    <= #1 henc_dc_chr[10: 0];
        end

      2'b10: // AC Luminance
        begin
            codelen <= #1 henc_ac_lum[19:16] +4'h1;
            code    <= #1 henc_ac_lum[15: 0];
        end

      2'b11: // AC Chrominance
        begin
            codelen <= #1 henc_ac_chr[19:16] +4'h1;
            code    <= #1 henc_ac_chr[15: 0];
        end
    endcase

  //
  // wait for encoder table(s)
  //
  always @(posedge clk)
    ddie <= #1 die;

  //
  // data out statemachine
  //
  always @(posedge clk or negedge rst)
    if(~rst)
      begin
          state <= #1 1'b0;
          cnt   <= #1 5'h0;
      end
    else
      case (state)
        1'b0:
         if(ddie)
           begin
               if( (cnt + codelen) > 7 )
                 state <= #1 1'b1;

               cnt <= #1 (cnt + codelen);
           end

        1'b1:
         begin
             if (ddie)
             begin
                 cnt <= #1 (cnt + codelen) - 5'h8;

                 if( (cnt + codelen) - 5'h8 < 8)
                   state <= #1 1'b0;
             end
	     else
	     begin
                if( (cnt -5'h8) < 8)
                  state <= #1 1'b0;

                cnt <= #1 (cnt -5'h8);
             end
         end
      endcase

  assign busy = state;

  always @(posedge clk)
    if(ddie)
      sreg <= #1 (sreg << codelen) | code;

  always @(posedge clk)
    doe <= #1 state;

  always @(posedge clk)
    do <= #1 sreg >> (cnt -5'h8);
endmodule
