///////////////////////////////////////////////////////////////////////////////////////////////
////                                                                                           
////  file name:   z80_core_top.v                                                                   
////  description: interconnect module for z80 core.                                          
////  project:     wb_z80                                                                                       ////
////                                                                                           
////  Author: B.J. Porcella                                                                    
////          bporcella@sbcglobal.net                                                          
////                                                                                           
////                                                                                           
////                                                                                           
///////////////////////////////////////////////////////////////////////////////////////////////
////                                                                                           
//// Copyright (C) 2000-2002 B.J. Porcella                                                     
////                         Real Time Solutions                                               
////                                                                                           
////                                                                                           
//// This source file may be used and distributed without                                      
//// restriction provided that this copyright statement is not                                 
//// removed from the file and that any derivative work contains                               
//// the original copyright notice and the associated disclaimer.                              
////                                                                                           
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY                                   
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED                                 
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS                                 
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR                                    
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,                                       
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES                                  
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE                                 
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR                                      
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF                                
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT                                
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT                                
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE                                       
//// POSSIBILITY OF SUCH DAMAGE.                                                               
////                                                                                           
///////////////////////////////////////////////////////////////////////////////////////////////
//  CVS Log
//
//  $Id: z80_core_top.v,v 1.6 2004-05-27 14:23:36 bporcella Exp $
//
//  $Date: 2004-05-27 14:23:36 $
//  $Revision: 1.6 $
//  $Author: bporcella $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//      $Log: not supported by cvs2svn $
//      Revision 1.5  2004/05/21 02:51:25  bporcella
//      inst test  got to the worked macro
//
//      Revision 1.4  2004/05/18 22:31:21  bporcella
//      instruction test getting to final stages
//
//      Revision 1.3  2004/05/13 14:58:53  bporcella
//      testbed built and verification in progress
//
//      Revision 1.2  2004/04/27 21:38:22  bporcella
//      test lint on core
//
//      Revision 1.1  2004/04/27 21:27:13  bporcella
//      first core build
//
//      Revision 1.1.1.1  2004/04/13 23:47:42  bporcella
//      import first files
//
//
//
// connects modules:
//  z80_memstate2.v        main state machine for z8  pc - sp  and wishbone regiters
//  z80_inst_exec.v        main execution engine for z80 general programming registers - alu's
//  z80_sram.v             main memory  (on board)
//  z80_bist_logic.v       memory initialization and some simple test peripherals.
//
//  WARNING   be sure the "test peripherals" in the bist_logic do not interfere with your
//    system.   
//  
//-------1---------2---------3--------Module Name and Port List------7---------8---------9--------0
module z80_core_top(  
                      wb_dat_o,      
                      wb_stb_o,      
                      wb_cyc_o,      
                      wb_we_o,       
                      wb_adr_o,      
                      wb_tga_o,
                      wb_ack_i,
                      wb_clk_i,
                      wb_dat_i,
                      wb_rst_i,
`ifdef COMPILE_BIST
                      bist_ack_o,
                      bist_err_o,
                      bist_req_i,
`endif
                      int_req_i 

);

//-------1---------2---------3--------Output Ports---------6---------7---------8---------9--------0

output [7:0]    wb_dat_o;
output          wb_stb_o;
output          wb_cyc_o;
output          wb_we_o;
output [15:0]   wb_adr_o;
output [1:0]    wb_tga_o;


//-------1---------2---------3--------Input Ports----------6---------7---------8---------9--------0

input           wb_ack_i;
input           wb_clk_i;
input  [7:0]    wb_dat_i;
input           wb_rst_i;
input           int_req_i;


`ifdef COMPILE_BIST
output          bist_err_o;
output          bist_ack_o;
input           bist_req_i;
`endif


//-------1---------2---------3--------Parameters-----------6---------7---------8---------9--------0
//-------1---------2---------3--------Wires------5---------6---------7---------8---------9--------0
wire   [15:0]    wb_adr_o; 
wire   [9:0]     ir1, ir2;
wire   [15:0]    nn;
wire   [15:0]    sp;
wire   [7:0]     ar, fr, br, cr, dr, er, hr, lr, intr;
wire   [15:0]    ixr, iyr;
wire   [7:0]     wb_dat_i, wb_dat_o, sdram_do, cfg_do, bist_do;
wire   [15:0]    add16;     //  ir2 execution engine output for sp updates
wire   [15:0]    adr_alu;   //  address alu to inst to update hl and de on block moves      
wire   [7:0]     alu8_out, sh_alu, bit_alu;  //  gotta move these to data out register
                                             //  for memory operations.  

wire          sram_addr;
wire          ce_sram;  
wire    [7:0] wb_rd_dat;
wire          wb_ack; 
//-------1---------2---------3--------Registers--5---------6---------7---------8---------9--------0
//-------1---------2---------3--------Assignments----------6---------7---------8---------9--------0
//-------1---------2---------3--------State Machines-------6---------7---------8---------9--------0


`ifdef COMPILE_BIST
wire [7:0] bist_dat_o;
wire bist_io_ack;

z80_bist_logic i_z80_bist_logic( 
        .bist_err_o(bist_err_o), 
        .bist_ack_o(bist_ack_o),
        .wb_dat_o(bist_dat_o),
        .wb_ack_o(bist_io_ack),
        .int_req_o(bist_int_req),
        .wb_adr_i(wb_adr_o), 
        .wb_dat_i(wb_dat_o), 
        .wb_we_i(wb_we_o), 
        .wb_cyc_i(wb_cyc_o),
        .wb_stb_i(wb_stb_o), 
        .wb_tga_i(wb_tga_o), 
        .int_req_i(int_req_i),
        .wb_clk_i(wb_clk_i), 
        .wb_rst_i(wb_rst_i)
        );

`else
wire bist_io_ack = 1'b0; 
wire [7:0] bist_dat_o = 8'b0;
`endif



z80_memstate2 i_z80_memstate2(
                .wb_adr_o(wb_adr_o), .wb_we_o(wb_we_o), .wb_cyc_o(wb_cyc_o), .wb_stb_o(wb_stb_o), .wb_tga_o(wb_tga_o), .wb_dat_o(wb_dat_o), 
                .exec_ir2(exec_ir2), 
                .exec_decbc(exec_decbc), .exec_decb(exec_decb), 
                .ir1(ir1), .ir2(ir2), .ir1dd(ir1dd), .ir1fd(ir1fd), .ir2dd(ir2dd), .ir2fd(ir2fd), .nn(nn), .sp(sp),
                .upd_ar(upd_ar), .upd_br(upd_br), .upd_cr(upd_cr), .upd_dr(upd_dr), .upd_er(upd_er), .upd_hr(upd_hr), .upd_lr(upd_lr),.upd_fr(upd_fr),
                .beq0(br_eq0), .ceq0(cr_eq0),
                .ar(ar), .fr(fr), .br(br), .cr(cr), .dr(dr), .er(er), .hr(hr), .lr(lr), 
                .ixr(ixr), .iyr(iyr), .intr(intr),
                .wb_dat_i(wb_rd_dat), .wb_ack_i(wb_ack), 
                .int_req_i(bist_int_req),
                .add16(add16),
                .alu8_out(alu8_out),
                .adr_alu(adr_alu),   
                .blk_mv_upd_hl(blk_mv_upd_hl),
                .blk_mv_upd_de(blk_mv_upd_de),
                .sh_alu(sh_alu),
                .bit_alu(bit_alu),
                .wb_clk_i(wb_clk_i),
                .rst_i(wb_rst_i)         // keep this generic - may turn out to be different from wb_rst
                 );


z80_inst_exec i_z80_inst_exec( 
                  .br_eq0(br_eq0),
                  .cr_eq0(cr_eq0),
                  .upd_ar(upd_ar), .upd_br(upd_br), .upd_cr(upd_cr), .upd_dr(upd_dr), .upd_er(upd_er), .upd_hr(upd_hr), .upd_lr(upd_lr),.upd_fr(upd_fr),
                  .ar(ar), .fr(fr), .br(br), .cr(cr), .dr(dr), .er(er), .hr(hr), .lr(lr), .intr(intr), 
                  .ixr(ixr), .iyr(iyr), .add16(add16), .alu8_out(alu8_out),
                  .adr_alu(adr_alu),   
                  .blk_mv_upd_hl(blk_mv_upd_hl),
                  .blk_mv_upd_de(blk_mv_upd_de),
                   .sh_alu(sh_alu),
                   .bit_alu(bit_alu),
                   .exec_ir2(exec_ir2),
                   .exec_decbc(exec_decbc), .exec_decb(exec_decb), 
                   .ir2(ir2),
                   .clk(wb_clk_i),
                   .rst(wb_rst_i),
                   .nn(nn), .sp(sp),
                   .ir2dd(ir2dd),
                   .ir2fd(ir2fd)
                   );

//-------------------  routing logic for the wishbone ------------------------
//
// I guess purists would prefer this logic in a lower module  --- "no logic on top level"
// Somehow I tend to think that this is the kind of logic that belongs on the top 
// level. 

assign       sram_addr   = ~wb_adr_o[15] & (wb_tga_o == 2'b00);
assign       ce_sram     = sram_addr & wb_cyc_o & wb_stb_o;
assign       wb_rd_dat   =  sram_addr   ? sdram_do :
                            bist_io_ack ? bist_dat_o :
                                          wb_dat_i;
assign       wb_ack = ce_sram | bist_io_ack | wb_ack_i;



z80_sram #(15) i_z80_sram(
    // Generic synchronous single-port RAM interface
    .clk(wb_clk_i), .rst(wb_rst_i), .ce(ce_sram), .we(wb_we_o), .oe(1'b1), 
    .addr(wb_adr_o[14:0]), .di(wb_dat_o), .do(sdram_do)
    );








endmodule