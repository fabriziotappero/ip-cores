/////////////////////////////////////////////////////////////////////
////                                                             ////
////  OpenCores/Dragonix    DragonBall/68K to WISHBONE Interface ////
////                                                             ////
////  Author: Richard Herveille                                  ////
////          richard@asics.ws                                   ////
////          www.asics.ws                                       ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2002 Richard Herveille                        ////
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
//  $Id: dragonball_wbmaster.v,v 1.3 2003-01-09 16:46:14 rherveille Exp $
//
//  $Date: 2003-01-09 16:46:14 $
//  $Revision: 1.3 $
//  $Author: rherveille $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: not supported by cvs2svn $
//               Revision 1.2  2002/12/22 16:09:33  rherveille
//               Timing enhancement bug fixes
//
//



//
// This core converts a 16bit DragonBall bus interface into a 16bit
// WISHBONE Master interface
//

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on

module dragonball_wbmaster(
  clk, reset_n,
  a, cs_n, d, lwe_n, uwe_n, oe_n, dtack_n, berr,
  clk_o, rst_o, cyc_o, stb_o, adr_o, sel_o, we_o, dat_o, dat_i, ack_i, err_i
);

  //
  // Parameters
  //
  parameter adr_hi = 9;


  //
  // Inputs & outputs
  //

  // Motorola 68K bus
  input             clk;           // master clock
  input             reset_n;       // asynchronous active low reset
  input  [adr_hi:1] a;             // address inputs
  input             cs_n;          // active low wishbone range chip select
  inout  [    15:0] d;             // data in-out
  input             lwe_n, uwe_n;  // active low lower-write enable, upper write enable
  input             oe_n;          // active low output enable signal
  output            dtack_n;       // active low data acknowledge
  output            berr;          // bus error

  // 16bit, 8bit granular WISHBONE bus master
  output            clk_o;         // clock
  output            rst_o;         // reset (asynchronous active low)
  output            cyc_o;         // cycle
  output            stb_o;         // strobe  (cycle and strobe are the same signal)
  output [adr_hi:1] adr_o;         // address
  output [     1:0] sel_o;         // select line (16bit bus ==> 2 select lines)
  output            we_o;          // write enable
  output [    15:0] dat_o;         // data output
  input  [    15:0] dat_i;         // data input
  input             ack_i;         // normal bus termination
  input             err_i;         // abnormal bus termination (bus error)

  //
  //  Module body
  //

  reg            cyc_o, stb_o;
  reg [adr_hi:1] adr_o;
  reg [     1:0] sel_o;
  reg            we_o;
  reg            dtack;
  reg [    15:0] sdat_i;

  wire cs  = !cs_n & !(ack_i | err_i | dtack);   // generate active high chip select signal
  wire lwe = !lwe_n;                             // generate active high lo_write_enable signal
  wire uwe = !uwe_n;                             // generate active high hi_write_enable signal
  wire oe  = !oe_n;                              // generate active high output enable signal

  assign clk_o = clk;                            // wishbone clock == external clock
  assign rst_o = reset_n;                        // reset == external reset

  assign berr = err_i;

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      begin
          cyc_o  <= #1 1'b0;
          stb_o  <= #1 1'b0;
          adr_o  <= #1 {{adr_hi-1}{1'b0}};
          sel_o  <= #1 2'b00;
          we_o   <= #1 1'b0;
          dtack  <= #1 1'b0;
          sdat_i <= #1 16'h0;
      end
    else
      begin
          cyc_o  <= #1 cs;                       // assert cyc_o when CS asserted
          stb_o  <= #1 cs;                       // assert stb_o when CS asserted

          adr_o  <= #1 a;                        // address == external address
          sel_o  <= #1 oe ? 2'b11 : {uwe, lwe};  // generate select lines;
                                                 // read (oe asserted): SEL[1:0] = '11'
                                                 // write (oe negated): SEL[1:0] = 'uwe, lwe'
          we_o   <= #1 uwe | lwe;                // write == uwe OR lwe asserted

          dtack  <= #1 ack_i & !dtack;           // generate DTACK signal

          sdat_i <= #1 dat_i;                    // synchronize dat_i
      end

  assign dat_o   = d;                            // dat_o==external databus (not synchronised!!)

  assign d       = (~cs_n & oe) ? sdat_i : 16'hzzzz; // generate databus tri-state buffers
  assign dtack_n = !dtack;                       // generate active low DTACK signal

endmodule

