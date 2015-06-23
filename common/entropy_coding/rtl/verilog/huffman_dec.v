/////////////////////////////////////////////////////////////////////
////                                                             ////
////  JPEG Entropy Coding, Huffman Decoding                      ////
////                                                             ////
////  Decomposes incomming datastream into packets for the       ////
////  Huffman tables.                                            ////
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
//  $Id: huffman_dec.v,v 1.2 2002-10-31 12:50:40 rherveille Exp $
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

module huffman_dec(clk, rst, tablesel, di, die, do, doe, busy);
  input         clk;      // clock
  input         rst;      // asynchronous active low reset
  input  [ 1:0] tablesel; // huffman table select
  input  [ 7:0] di;       // data input
  input         die;      // data-in enable
  output [ 7:0] do;       // category or Runlenght/Size codepair
  output        doe;      // data-out enable
  output        busy;     // busy. Do not assert die while busy asserted

  reg [7:0] do;
  reg       doe, busy;


  wire [ 7:0] hdec_dc_lum, hdec_dc_chr;
  wire [11:0] hdec_ac_lum, hdec_ac_chr;
  reg  [ 4:0] codelen;
  reg  [15:0] code;

  reg [ 1:0] state;
  reg [22:0] sreg;
  reg [ 4:0] cnt;


  `include "huffman_tables.v"

  //
  // hookup huffman tables
  //
  assign hdec_dc_lum = jpeg_dc_luminance_huffman_dec(code[15:7]);
  assign hdec_dc_chr = jpeg_dc_chrominance_huffman_dec(code[15:5]);
  assign hdec_ac_lum = jpeg_ac_luminance_huffman_dec(code);
  assign hdec_ac_chr = jpeg_ac_chrominance_huffman_dec(code);


  //
  // split table data into category Run/Size and codelength
  //
  always @(posedge clk)
    case (tablesel) // synopsys full_case parallel_case
      2'b00: // DC Luminance
        begin
            codelen <= #1 hdec_dc_lum[ 7: 4] +4'h1;
            do      <= #1 {4'h0, hdec_dc_lum[ 3: 0]};
        end

      2'b01: // DC Chrominance
        begin
            codelen <= #1 hdec_dc_chr[ 7: 4] +4'h1;
            do      <= #1 {4'h0, hdec_dc_chr[ 3: 0]};
        end

      2'b10: // AC Luminance
        begin
            codelen <= #1 hdec_ac_lum[11:8] +4'h1;
            do      <= #1 hdec_ac_lum[ 7:0];
        end

      2'b11: // AC Chrominance
        begin
            codelen <= #1 hdec_ac_chr[11:8] +4'h1;
            do      <= #1 hdec_ac_chr[ 7:0];
        end
    endcase


  //
  // Hookup din statemachine
  //
  always @(posedge clk or negedge rst)
    if(~rst)
      begin
          state <= #1 2'b00;
          sreg  <= #1 24'h0;
          cnt   <= #1 5'h0;
          busy  <= #1 1'b0;
		  doe   <= #1 1'b0;
      end
    else
      begin
          doe <= #1 1'b0;

          case(state)
            2'b00:
                if(die)
                  begin
                      if( (cnt + 5'h8) > 15 ) // guaranteed valid code in sreg
                        begin
                            state <= #1 2'b01;
                            busy  <= #1 1'b1;
                        end

                        sreg <= #1 ((sreg << 8) | di);
                        cnt  <= #1 (cnt + 5'h8);
                  end

            2'b01:
                begin
                    state <= #1 2'b11; // wait for codelen (data from table)
                    doe   <= #1 1'b1;
                end

            2'b11:
                begin
                    if( (cnt - codelen) > 15 ) // still valid codes in sreg
                      state <= #1 2'b01;
                    else
                      begin
                          state <= #1 2'b00;
                          busy  <= #1 1'b0;
                      end

                    cnt  <= #1 (cnt - codelen);
                end
          endcase
      end

  always @(posedge clk)
    if(die)
      code <= #1 ((sreg << 8) | di) >> ((cnt + 5'h8) -5'h10);
    else
      code <= #1 sreg >> ((cnt - codelen) -5'h10);

endmodule
