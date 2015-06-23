///////////////////////////////////////////////////////////////////////////////////////////////////
////                                                                                           ////
////  file name:   z80_testbed.v                                                               ////
////  description: testbed for Wishbone z80                                                    ////
////  project:     wb_z80                                                                      ////
////                                                                                           ////
////                                                                                           ////
////  Author: B.J. Porcella                                                                    ////
////          bporcella@sbcglobal.net                                                          ////
////                                                                                           ////
////                                                                                           ////
////                                                                                           ////
///////////////////////////////////////////////////////////////////////////////////////////////////
////                                                                                           ////
//// Copyright (C) 2000-2002 B.J. Porcella                                                     ////
////                         Real Time Solutions                                               ////
////                                                                                           ////
////                                                                                           ////
//// This source file may be used and distributed without                                      ////
//// restriction provided that this copyright statement is not                                 ////
//// removed from the file and that any derivative work contains                               ////
//// the original copyright notice and the associated disclaimer.                              ////
////                                                                                           ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY                                   ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED                                 ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS                                 ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR                                    ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,                                       ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES                                  ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE                                 ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR                                      ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF                                ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT                                ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT                                ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE                                       ////
//// POSSIBILITY OF SUCH DAMAGE.                                                               ////
////                                                                                           ////
///////////////////////////////////////////////////////////////////////////////////////////////////
//  CVS Log
//
//  $Id: z80_testbed.v,v 1.5 2007-10-02 20:25:12 bporcella Exp $
//
//  $Date: 2007-10-02 20:25:12 $
//  $Revision: 1.5 $
//  $Author: bporcella $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//      $Log: not supported by cvs2svn $
//      Revision 1.4  2004/05/27 14:25:04  bporcella
//      Instruction test (with interrupts) runs!!!
//
//      Revision 1.3  2004/05/21 02:51:25  bporcella
//      inst test  got to the worked macro
//
//      Revision 1.2  2004/05/18 22:31:21  bporcella
//      instruction test getting to final stages
//
//      Revision 1.1  2004/05/13 14:57:35  bporcella
//      testbed files
//
//      Revision 1.1.1.1  2004/04/13 23:47:42  bporcella
//      import first files
//
//
//
//-------1---------2---------3--------Module Name and Port List------7---------8---------9--------0


`timescale 1ns/10ps
`define  COMPILE_BIST   // need this for this file to work

// testbench - do not synthesize.  this just sequences the bist signals
module z80_testbed();

reg      rst, bist_req, clk;
wire     bist_ack;
wire     bist_err;



//-------   CAUTION  TEST RESULTS DEPEND ON INITIAL CONDITIONS -------
//  bist will not pass if some of these inputs are not as specified.
//
z80_core_top i_z80_core_top(                   
    .wb_dat_o(),      
    .wb_stb_o(),      
    .wb_cyc_o(),      
    .wb_we_o(),       
    .wb_adr_o(),      
    .wb_tga_o(),
    .wb_ack_i(1'b0),
    .wb_clk_i(clk),
    .wb_dat_i(8'h0),
    .wb_rst_i(rst),
    .bist_ack_o(bist_ack),
    .bist_err_o(bist_err),
    .bist_req_i(bist_req),
    .int_req_i(1'b0)        //  
    );            


initial
begin
    clk = 0;
    //  timeout if u hang up  -- always a good idea.
    #500000     $finish;
    $display("simulation timeout"); 
end

always   #5 clk = ~clk;

// The bist sequencer  --- pertty trivial
initial
begin
    rst = 1'b0;
    bist_req = 1'b0;
    @( posedge clk)  rst = 1'b1;
    @( posedge clk)  rst = 1'b0;
    @( posedge clk)  bist_req = 1'b1;
    @( bist_ack ) ;
    @( posedge clk)
        if ( bist_err ) $display("TB bist error");
        else            $display( "TB bist ok"    );
    $finish;
end


initial
begin
    $dumpfile("dump.vcd");
    $dumpvars;
end

endmodule