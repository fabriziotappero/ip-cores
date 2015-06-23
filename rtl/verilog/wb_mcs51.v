/////////////////////////////////////////////////////////////////////
////                                                             ////
//// MCS51 to Wishbone Interface                                 ////
////                                                             ////
//// $Id: wb_mcs51.v,v 1.2 2008-03-10 13:58:10 hharte Exp $          ////
////                                                             ////
//// Copyright (C) 2007 Howard M. Harte                          ////
////                    hharte@opencores.org                     ////
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

module wb_mcs51 (nrst_i, clk_i, mcs51_ale, mcs51_rd, mcs51_wr, mcs51_ad_inout,
                 wbm_adr_o, wbm_dat_i, wbm_dat_o, wbm_sel_o, wbm_cyc_o,
                 wbm_stb_o, wbm_we_o, wbm_ack_i, wbm_rty_i, wbm_err_i);

   parameter mcs51_aw = 8 ;
    parameter wb_aw = 16;

   input nrst_i;
   input clk_i;
   input mcs51_ale;
   input mcs51_rd;
   input mcs51_wr;
   inout [mcs51_aw-1:0] mcs51_ad_inout;

   // WISHBONE master interface
   output [wb_aw-1:0]  wbm_adr_o;
   input  [7:0]   wbm_dat_i;
   output [7:0]   wbm_dat_o;
   output         wbm_sel_o;
   output         wbm_cyc_o;
   output         wbm_stb_o;
   output         wbm_we_o;
   input          wbm_ack_i;
   input          wbm_rty_i;
   input          wbm_err_i;

   wire  l_wbm_stb;
   wire  mcs51_ad_oe;
   
   reg   [mcs51_aw-1:0]   mcs51_addr;

   always @(negedge mcs51_ale or negedge nrst_i)
      if (~nrst_i)
         begin
            mcs51_addr <= {{wb_aw}{1'b0}};
         end
      else if(~mcs51_ale)     // Latch address
         mcs51_addr <= { {{16-mcs51_aw}{1'b0}} , mcs51_ad_inout[mcs51_aw-1:0] };

   assign mcs51_ad_oe = ~mcs51_rd;

   assign wbm_adr_o = { {{wb_aw-16}{1'b0}}, mcs51_addr };
   assign wbm_we_o = ~mcs51_wr;
   assign wbm_stb_o = ~mcs51_wr | ~mcs51_rd;
   assign wbm_cyc_o = wbm_stb_o;
   assign mcs51_ad_inout = mcs51_ad_oe ? wbm_dat_i : 8'bzzzzzzzz;
   assign wbm_sel_o = wbm_stb_o;

   assign wbm_dat_o = mcs51_ad_inout[7:0];

    assign wmb_sel_o = 4'b0001;
   
endmodule
