///////////////////////////////////////////////////////////////////////////////////////////////////
////                                                                                           ////
////  file name:   z80_bist_logic.v                                                               ////
////  description: built in self test logic                                                    ////
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
//  $Id: z80_bist_logic.v,v 1.2 2004-05-27 14:23:36 bporcella Exp $
//
//  $Date: 2004-05-27 14:23:36 $
//  $Revision: 1.2 $
//  $Author: bporcella $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//      $Log: not supported by cvs2svn $
//      Revision 1.1  2004/05/13 14:57:35  bporcella
//      testbed files
//
//      Revision 1.1.1.1  2004/04/13 23:47:42  bporcella
//      import first files
//
//
//
//  There are a few things here:
//  1) A register to sequence the bist signals.  A bist is run after rst, and the program
//     indicates completion by setting bist_ack.   
//  2) A simple I/O device to aid in I/O instruction testing.  The input device sequences 
//     through a set of "interesting" data.  The output device simply displays anything 
//     written to it.
//  3) A very simple interrupt generator.  I guess this could be used as a clock in a real 
//     system.   Priority logic needs some work if that is to be done. 
//
//  Note that if thes bist is to be 
//  actually synthesized a different method of loading the core SRAM 
//  (eq from external PROM) must be implemented.
//
//-------1---------2---------3--------Module Name and Port List------7---------8---------9--------0
module z80_bist_logic( bist_err_o, 
                       bist_ack_o,
                       wb_dat_o  ,
                       wb_ack_o  ,
                       int_req_o  ,
                       wb_adr_i  , 
                       wb_dat_i  , 
                       wb_we_i   , 
                       wb_cyc_i  ,
                       wb_stb_i  , 
                       wb_clk_i  ,
                       wb_tga_i  , 
                       int_req_i ,
                       wb_rst_i     );


//-------1---------2---------3--------Output Ports---------6---------7---------8---------9--------0
output       bist_err_o;
output       bist_ack_o;
output [7:0] wb_dat_o;
output       wb_ack_o;
output       int_req_o;
//-------1---------2---------3--------Input Ports----------6---------7---------8---------9--------0

input [15:0]  wb_adr_i;  
input         wb_we_i;   
input         wb_cyc_i;  
input         wb_stb_i;  
input [1:0]   wb_tga_i;
input         wb_clk_i;
input         wb_rst_i;  
input [7:0]   wb_dat_i;
input         int_req_i;


//-------1---------2---------3--------Parameters-----------6---------7---------8---------9--------0
//-------1---------2---------3--------Wires------5---------6---------7---------8---------9--------0
//-------1---------2---------3--------Registers--5---------6---------7---------8---------9--------0
reg   [2:0]  bist_reg;
integer      i;
reg          wb_ack_o;
reg [7:0]    out_state;
reg [9:0]    int_count;
reg          int_req;
wire         int_ack;
wire         bist_int_en;

//-------1---------2---------3--------Assignments----------6---------7---------8---------9--------0
assign bist_err_o = bist_reg[1];
assign bist_ack_o = bist_reg[0];
assign bist_int_en = bist_reg[2];
wire    clk = wb_clk_i;
wire    rst = wb_rst_i;
assign  int_req_o = int_req_i | int_req & bist_int_en;
//-------1---------2---------3--------State Machines-------6---------7---------8---------9--------0
// The following parameters are "known" to the instruction test program.  
// If you change them change the test program accorcingly.
//
parameter   INT_OFFSET = 8'hfe;   // int device provides offset to last entry of int table.
parameter   BIST_ADR = 16'hffff ; // address of bist register
parameter   MY_IO_ADR = 8'h20 ;  // Map to " " for minor reasons related to "embedded test"


parameter   TAG_MEM   = 2'b00,
            TAG_IO    = 2'b01,   // need to review general wb usage to undrstand how best to 
            TAG_INT   = 2'b10;   // document this.





// ----------------- a pretty simple I/O device   ----------------------------------

wire a2io = (wb_adr_i[7:0] == MY_IO_ADR) & wb_stb_i & wb_cyc_i & (wb_tga_i == TAG_IO);
wire a2bist = (wb_adr_i == BIST_ADR) & wb_stb_i & wb_cyc_i & (wb_tga_i == TAG_MEM);
assign int_ack = wb_stb_i & wb_cyc_i & (wb_tga_i == TAG_INT);


always @(posedge clk or posedge rst)
begin
    if (wb_rst_i )                                 wb_ack_o <= 1'b0;
    else if((a2io | a2bist | int_ack) & !wb_ack_o) wb_ack_o <= 1'b1;
    else                                           wb_ack_o <= 1'b0;    
end

// the "output" device  - output simply displays the data written   --    
always @(posedge clk or posedge rst)
    if (a2io & wb_we_i & wb_ack_o)  $write("%s",wb_dat_i); 

// the "input" device --------------------------------------------------
//  
//  input cycles through 
//  various interesting data  patterens as used by the instruction test
//  namely   7f 55 80 0  ff  aa

assign wb_dat_o = int_ack ? INT_OFFSET : out_state;

always @(posedge clk or posedge rst)
begin
    if (wb_rst_i)          out_state <=  8'h7f;
    else if (a2io & !wb_we_i & wb_ack_o)
        case (out_state)
            8'h7f:         out_state <=  8'h55 ;
            8'h55:         out_state <=  8'h80 ;
            8'h80:         out_state <=  8'h00 ;
            8'h00:         out_state <=  8'hff ;
            8'hff:         out_state <=  8'haa ;
            8'haa:         out_state <=  8'h7f ;
            default:       out_state <=  8'h7f ;
        endcase
end


//-----   memory mapped register -----------  for bist control  
//  my address is selected as memory mapped to top of SDRAM.
//  any system implementation may choose to modify this.

wire wb_wr = wb_cyc_i & wb_stb_i & wb_we_i;
wire my_adr = (wb_tga_i == 2'b00) & ( wb_adr_i == BIST_ADR);

always @(posedge wb_clk_i or wb_rst_i) 
    if (wb_rst_i)                         bist_reg <= 3'b0;
    else if (my_adr & wb_wr & wb_ack_o)   bist_reg <= wb_dat_i[2:0];


initial 
begin
    $display("BL messages from Bist logic  TB messages from test bench  - others from test" );
    $display("BL dump a few memory locations to be sure initialization is sane") ;
    $readmemh( "readmem.txt", z80_testbed.i_z80_core_top.i_z80_sram.mem );
    // be sure at least some of the data got properly loaded.
    for (i=0; i<10; i=i+1)
        $display( "BL mem [%0d] = %h", i, z80_testbed.i_z80_core_top.i_z80_sram.mem[i]); 
end

//--------------------- the interrupt device ------------------------------

always @(posedge wb_clk_i or wb_rst_i) 
    if (wb_rst_i)              int_count <=10'h0;
    else                       int_count <= int_count + 10'h1;

always @(posedge wb_clk_i or wb_rst_i)
    if (wb_rst_i)                 int_req <= 1'b0;
    else if (int_count==10'h3ff)  int_req <= 1'b1;
    else if ( int_ack )           int_req <= 1'b0;
endmodule