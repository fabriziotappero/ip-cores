/////////////////////////////////////////////////////////////////////
////                                                             ////
//// TV80 to Wishbone Master Interface Wrapper                   ////
////                                                             ////
//// $Id: wb_tv80.v,v 1.2 2008-12-17 07:46:29 hharte Exp $       ////
////                                                             ////
//// Copyright (C) 2008 Howard M. Harte                          ////
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

`define TAG_MEM  2'b00
`define TAG_IO   2'b01

module wb_tv80 (nrst_i, clk_i,
                wbm_adr_o, wbm_tga_o, wbm_dat_i, wbm_dat_o, wbm_cyc_o,
                wbm_stb_o, wbm_we_o, wbm_ack_i,
                nmi_req_i,
                int_req_i,
                busrq_i,
                busak_o);

    input          nrst_i;
    input          clk_i;

    // WISHBONE master interface
    output [15:0]  wbm_adr_o;
    output [1:0]   wbm_tga_o;
    input  [7:0]   wbm_dat_i;
    output [7:0]   wbm_dat_o;
    output         wbm_cyc_o;
    output         wbm_stb_o;
    output         wbm_we_o;
    input          wbm_ack_i;
    
    // Z80-specific interface
    input          nmi_req_i;
    input          int_req_i;
    input          busrq_i;
    output         busak_o;

    // TV80 Interface
    wire           m1_n;
    wire           mreq_n;
    wire           iorq_n;
    wire           rd_n; 
    wire           wr_n;
    wire           rfsh_n;
    wire           halt_n;
    wire           busak_n;
    wire [15:0]    tv80_adr; 
    wire  [7:0]    tv80_dat_o;
    wire           wait_n;
    wire           int_n;
    wire           nmi_n;
    wire           busrq_n;
    wire  [7:0]    tv80_dat_i;

    assign wbm_adr_o = tv80_adr;
    assign wbm_dat_o = tv80_dat_o;
    assign wbm_we_o  = ~wr_n & (~mreq_n | ~iorq_n);
    assign wbm_stb_o = (~wr_n | ~rd_n) & (~mreq_n | ~iorq_n | ~m1_n);
    assign wbm_cyc_o = wbm_stb_o;
    assign wbm_tga_o = (~iorq_n ? `TAG_IO : `TAG_MEM);

    assign wait_n    = wbm_stb_o == 1'b0 ? 1'b1 : wbm_ack_i;

    assign tv80_dat_i = wbm_dat_i;   

    assign int_n   = ~int_req_i;
    assign nmi_n   = ~nmi_req_i;
    assign busrq_n = ~busrq_i;
    assign busak_o = ~busak_n;

// Instantiate TV80 CPU Core
tv80s z80_core (
    .m1_n(m1_n), 
    .mreq_n(mreq_n), 
    .iorq_n(iorq_n), 
    .rd_n(rd_n), 
    .wr_n(wr_n), 
    .rfsh_n(rfsh_n), 
    .halt_n(halt_n), 
    .busak_n(busak_n), 
    .A(tv80_adr), 
    .do(tv80_dat_o), 
    .reset_n(nrst_i), 
    .clk(clk_i), 
    .wait_n(wait_n), 
    .int_n(int_n), 
    .nmi_n(nmi_n), 
    .busrq_n(busrq_n), 
    .di(tv80_dat_i)
    );
   
endmodule
