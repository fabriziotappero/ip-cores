/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Non-restoring signed by unsigned divider                   ////
////  Uses the non-restoring unsigned by unsigned divider        ////
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
//  $Id: div_su.v,v 1.2 2002/10/31 13:54:58 rherveille Exp $
//
//  $Date: 2002/10/31 13:54:58 $
//  $Revision: 1.2 $
//  $Author: rherveille $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: div_su.v,v $
//               Revision 1.2  2002/10/31 13:54:58  rherveille
//               Fixed a bug in the remainder output of div_su.v
//
//               Revision 1.1.1.1  2002/10/29 20:29:09  rherveille
//
//
//

//synopsys translate_off
`include "timescale.v"
//synopsys translate_on

module div_su(clk, ena, z, d, q, s, div0, ovf);

  //
  // parameters
  //
  parameter z_width = 16;
  parameter d_width = z_width /2;
  
  //
  // inputs & outputs
  //
  input clk;              // system clock
  input ena;              // clock enable

  input  [z_width-1:0] z; // divident
  input  [d_width-1:0] d; // divisor
  output [d_width  :0] q; // quotient
  output [d_width  :0] s; // remainder
  output div0;
  output ovf;

  reg [d_width:0] q, s;
  reg div0;
  reg ovf;

  //
  // variables
  //
  reg [z_width -1:0] iz;
  reg [d_width -1:0] id;
  reg [d_width +1:0] szpipe, sdpipe;

  wire [d_width -1:0] iq, is;
  wire                idiv0, iovf;

  //
  // module body
  //

  // check d, take abs value
  always @(posedge clk)
    if (ena)
      if (d[d_width-1])
         id <= ~d +1'h1;
      else
         id <= d;

  // check z, take abs value
  always @(posedge clk)
    if (ena)
      if (z[z_width-1])
         iz <= ~z +1'h1;
      else
         iz <= z;

  // generate szpipe (z sign bit pipe)
  integer n;
  always @(posedge clk)
    if(ena)
    begin
        szpipe[0] <= z[z_width-1];

        for(n=1; n <= d_width+1; n=n+1)
           szpipe[n] <= szpipe[n-1];
    end

  // generate sdpipe (d sign bit pipe)
  integer m;
  always @(posedge clk)
    if(ena)
    begin
        sdpipe[0] <= d[d_width-1];

        for(m=1; m <= d_width+1; m=m+1)
           sdpipe[m] <= sdpipe[m-1];
    end

  // hookup non-restoring divider
  div_uu #(z_width, d_width)
  divider (
    .clk(clk),
    .ena(ena),
    .z(iz),
    .d(id),
    .q(iq),
    .s(is),
    .div0(idiv0),
    .ovf(iovf)
  );

  // correct divider results if 'd' was negative
  always @(posedge clk)
    if(ena)
      begin
         q <= (szpipe[d_width+1]^sdpipe[d_width+1]) ?
              ((~iq) + 1'h1) : ({1'b0, iq});
         s <= (szpipe[d_width+1]) ?
              ((~is) + 1'h1) : ({1'b0, is});
      end

  // delay flags same as results
  always @(posedge clk)
    if(ena)
    begin
        div0 <= idiv0;
        ovf  <= iovf;
    end
endmodule
