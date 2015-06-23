///////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                               //
//  file name:   inst_exec.v                                                                     //
//  description: main execution engine for wishbone z80                                          //
//  project:     wb_z80                                                                          //
//                                                                                               //
//  Author: B.J. Porcella                                                                        //
//  e-mail: bporcella@sbcglobal.net                                                              //
//                                                                                               //
//                                                                                               //
//                                                                                               //
///////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                               //
// Copyright (C) 2000-2002 B.J. Porcella                                                         //
//                         Real Time Solutions                                                   //
//                                                                                               //
//                                                                                               //
// This source file may be used and distributed without                                          //
// restriction provided that this copyright statement is not                                     //
// removed from the file and that any derivative work contains                                   //
// the original copyright notice and the associated disclaimer.                                  //
//                                                                                               //
//     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY                                       //
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED                                     //
// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS                                     //
// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR                                        //
// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,                                           //
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES                                      //
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE                                     //
// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR                                          //
// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF                                    //
// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT                                    //
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT                                    //
// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE                                           //
// POSSIBILITY OF SUCH DAMAGE.                                                                   //
//                                                                                               //
//-------1---------2---------3--------Comments on file  -------------7---------8---------9--------0
//
// This file contains the data related registers of the z80 and the
// logic required to update them.  Included registers are:
//  ar   fr
//  br   cr
//  dr   er
//  hr   lr
//    ixr
//    iyr
//  intr
//
//  and the "prime" registers
//  ap  fp
//  bp  cp
//  dp  ep
//  hp  lp
//
// This logic can be considered a "slave" to the memstate sequencer (in memstate2.v).  
// as memstate sequencer executes any instruction from ir1 (the of - os pipe) the instruction
// gets transferred to ir2 - which now becomes active.  
//
// In the case of any memory type instruction (HL) , the pipeline must stall 1 tick to get the
// operand into the nn register.  This file logic needs not understand any of that --  just 
// execute when told to (ir2_val).
//
// From a block diagram standpoint this file is somewhat messy.  There are multiple ALU's and 
// multiple source multiplexors.  Part of the reason for this is hardware speed  -  the 
// various additions start pretty early in the cycle ( as not much decode logic is needed to 
// get them started.   In parallel with that - the destination selectors ( which require more
// complex decoding logic ) are "doing thier thing"  No claim that this is absolute optimum - any 
// good synthesizer should be able to make the basic structure faster when flattened.   However, 
// the intention is that even if the synthesizer is pretty primitive -- reasonably fast hardware 
// will be produced.
// 
//-------1---------2---------3--------CVS Log -----------------------7---------8---------9--------0
//
//  $Id: z80_inst_exec.v,v 1.5 2007-10-02 20:25:12 bporcella Exp $
//
//  $Date: 2007-10-02 20:25:12 $
//  $Revision: 1.5 $
//  $Author: bporcella $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//      $Log: not supported by cvs2svn $
//      Revision 1.4  2004/05/21 02:51:25  bporcella
//      inst test  got to the worked macro
//
//      Revision 1.3  2004/05/18 22:31:21  bporcella
//      instruction test getting to final stages
//
//      Revision 1.2  2004/05/13 14:58:53  bporcella
//      testbed built and verification in progress
//
//      Revision 1.1  2004/04/27 21:27:13  bporcella
//      first core build
//
//      Revision 1.4  2004/04/19 19:13:27  bporcella
//      real lint problems pretty much fixed   --  need another look - but need to get on to other things first
//
//      Revision 1.3  2004/04/19 05:09:11  bporcella
//      fixed some lint problems  --
//
//      Revision 1.2  2004/04/18 18:50:08  bporcella
//      fixed some lint problems  --
//
//      Revision 1.1.1.1  2004/04/13 23:49:54  bporcella
//      import first files
//
//
//
//-------1---------2---------3--------Module Name and Port List------7---------8---------9--------0
module z80_inst_exec( br_eq0,
                  cr_eq0,
                  upd_ar, upd_br, upd_cr, upd_dr, upd_er, upd_hr, upd_lr,upd_fr,
                  ar, fr, br, cr, dr, er, hr, lr, intr,  
                  ixr, iyr, add16, alu8_out,  sh_alu, bit_alu,
                   exec_ir2,
                   exec_decbc, exec_decb,
                   adr_alu,
                   blk_mv_upd_hl,
                   blk_mv_upd_de,
                   ir2,
                   clk,
                   rst,
                   nn, sp,
                   ir2dd,
                   ir2fd
                   );

//-------1---------2---------3--------Output Ports---------6---------7---------8---------9--------0
output          br_eq0;
output          cr_eq0;
output          upd_ar, upd_br, upd_cr, upd_dr, upd_er, upd_hr, upd_lr,upd_fr;
output  [7:0]   ar, fr, br, cr, dr, er, hr, lr, intr; 
output  [15:0]  ixr, iyr;
output  [15:0]  add16;
output  [7:0]   alu8_out;   // used for INCs6HL7 and DECs6HL7 types ---   flags need updating
                            // also so need to do with alu8. 
output  [7:0]   sh_alu;
output  [7:0]   bit_alu;
//-------1---------2---------3--------Input Ports----------6---------7---------8---------9--------0
input        exec_ir2;
input        exec_decbc;  // in general this needs to happen at different time from exec
input        exec_decb;   // in general - we don't have the EB instruction (yet) when this hits
input [9:0]  ir2;
input        clk;
input        rst;
input [15:0] nn, sp;
input        ir2dd;       // this must be ir2
input        ir2fd;
input [15:0] adr_alu;
input        blk_mv_upd_hl;
input        blk_mv_upd_de;
//-------1---------2---------3--------Parameters-----------6---------7---------8---------9--------0
`include "opcodes.v"

//-------1---------2---------3--------Wires----------------6---------7---------8---------9--------0

//wire [7:0]   src_pqr;    //  arithmetic sources gven by ir2[2:0]
wire [7:0]   src_hr ;
wire [7:0]   src_lr ;
//wire [7:0]   alu_out;  // {CF. 8bit_result}
//wire         alu_cry;

//wire            c_in0, c_out7, c_in8, c_out11, cout15;
wire   [15:0]   src_a, src_b;
wire   [15:0]   add16;
wire            sf, zf, f5f, hf, f3f, pvf, nf, cf; 
wire   [7:0]    daa_alu; // {cry, number}   hf goes to 0 always.
wire            daa_cry;
wire            upd_ar, upd_br, upd_cr, upd_dr, upd_er, upd_fr, upd_hr, upd_lr;
wire        c_8out3;
wire [7:0]  add_8bit;

wire  [15:0]  src_dblhr       ;
//wire          src_cb_r20      ;
wire  [7:0]  src_pqr20       ;
wire  [7:0]   src_pqr53       ;
wire  [15:0]  src_dbl         ;
wire  [7:0]   alu8_fr         ;
wire          alu8_nf         ;
wire          c_8out7         ;
wire          alu8_cry        ;
wire          alu8_pvf        ;
wire          alu8_hcry       ;
wire  [7:0]   alu8_out        ;
wire          add16_ofl       ;
wire          c_16out7        ;
wire          c_16out11       ;
wire          c_16out15       ;
wire          c_16in0         ;
wire          sh_cry          ;
wire  [7:0]   sh_alu          ;
wire          sh_alu_act      ;
wire          bit_alu_act     ;
wire  [7:0]   bit_alu         ;
wire  [7:0]   decc_alu        ;
wire  [7:0]   decb_alu        ;
wire          upd_a_alu8      ;
wire          up_a_sh_alu     ;
wire          up_a_src_pqr    ;
wire          up_a_n          ;
wire          upd_b_alu8      ;
wire          up_b_src_pqr    ;
wire          up_b_add16      ;
wire [7:0]    sh_src          ;    

wire          up_c_add16       ;
wire          upd_c_alu8       ;
wire          up_c_src_pqr     ;
wire          up_d_add16       ;
wire          upd_d_alu8       ;
wire          up_d_src_pqr     ;
wire          up_e_add16       ;
wire          upd_e_alu8       ;
wire          up_e_src_pqr     ;
wire          up_h_add16       ;
wire          upd_h_alu8       ;
wire          upd_h_src_pqr    ;
wire          up_l_add16       ;
wire          upd_l_alu8       ;
wire          upd_l_src_pqr    ;
wire          upd_bc_cpi       ;                      
wire          upd_fr_alu8      ;
wire          upd_fr_add16     ;
wire          upd_fr_edadd16   ;
wire          upd_fr_sh        ;
wire          upd_fr_cbsh      ;
//wire          eb_blk_mv        ;
wire          ed_blk_cp        ;  
wire          c_8in0           ;

//-------1---------2---------3--------Registers------------6---------7---------8---------9--------0

reg [7:0] ar, fr, br, cr, dr, er, hr, lr, intr;
reg [7:0] ap, fp, bp, cp, dp, ep, hp, lp; 
reg [15:0] ixr, iyr;
//-------1---------2---------3--------Assignments----------6---------7---------8---------9--------0

//  it appears that dd and fd as a prefix to cb has a significantly modfied fuction......
//  specifically, it is assumed that a memory operation is to be implemented (ix + d)
// ,  In fact the 
// pipeline is such that we can make a fetch for free  - so we will do that.....   the 
// prefix flags should not be set here   -- all we will know on execution is that it is a 
// cb instruction.   ----   src is always nn 
assign  src_hr = ir2dd ? ixr[15:8] : 
                 ir2fd ? iyr[15:8] :
                 hr                   ;
                 
assign  src_lr = ir2dd ? ixr[7:0] : 
                 ir2fd ? iyr[7:0] :
                 lr                 ;

assign src_dblhr = ir2dd ? ixr :    // ed grp instructions (ADC HL ; SBC HL are not affected -
                   ir2fd ? iyr :    // instruction assembler assures this - ed_grp has no prefix
                   {hr, lr}      ;
//  ddcb_grp not defined  - src_cb_r20  not used.  Why these lines?  4/17/2004
//assign  src_cb_r20 = (ddcb_grp | fdcb_grp) ? nn[7:0]   :
//                             cb_grp        ? src_pqr20 :
//                             ar                        ;
assign  br_eq0 = ~|br; // for first cut do this quick and dirty.   
assign  cr_eq0 = ~|cr; // if this becomes a critical path - make these registers.
assign  src_pqr20 = {8{ir2[2:0]==REG8_B   }} & br     |
                    {8{ir2[2:0]==REG8_C   }} & cr     |
                    {8{ir2[2:0]==REG8_D   }} & dr     |
                    {8{ir2[2:0]==REG8_E   }} & er     |
                    {8{ir2[2:0]==REG8_H   }} & src_hr |
                    {8{ir2[2:0]==REG8_L   }} & src_lr |
                    {8{ir2[2:0]==REG8_MEM}} & nn[15:8] |
                    {8{ir2[2:0]==REG8_A   }} & ar      ;
                    
assign src_pqr53 =  {8{ir2[5:3]==REG8_B   }} & br     |
                    {8{ir2[5:3]==REG8_C   }} & cr     |
                    {8{ir2[5:3]==REG8_D   }} & dr     |
                    {8{ir2[5:3]==REG8_E   }} & er     |
                    {8{ir2[5:3]==REG8_H   }} & src_hr |
                    {8{ir2[5:3]==REG8_L   }} & src_lr |
                    {8{ir2[5:3]==REG8_MEM}} & nn[15:8] |
                    {8{ir2[5:3]==REG8_A   }} & ar      ;


assign src_dbl =   {16{ir2[5:4]==2'b00}} & {br, cr}  |
                   {16{ir2[5:4]==2'b01}} & {dr, er}  |
                   {16{ir2[5:4]==2'b10}} & src_dblhr |   // HL, ixr, iyr
                   {16{ir2[5:4]==2'b11}} & sp         ;

assign sh_src =   ir2[8] & ir2dd ?  nn[15:8]   :
                  ir2[8] & ir2fd ?  nn[15:8]   :
                  ir2[8]          ?  src_pqr20  :
                                     ar          ;
// I wonder how well the synthesizer can reduce this??? - It is probably worth spending
// some time during physical design to see if a more low level description would help --
// there is somebody out there who knows  -  and there is probably a good low level description.
//
// guess its kind of important to understand precisely what the synthesizer does 
// with some of the status things we need also. 
//
//
//  The nastiest status to get is HF.  Really need 4 bit adders to do that  ( or reproduce a lot
//  of logic.)  I don't have a lot of confdence in the synthesier's ability to minimize arithmetic
//  operations   --  Its a moving target of course, but I've seen some really silly stuff come out
//  of synthesis when you use a "+" operator.   guess I will be pretty explicit here.  
//  Documentation of the HF is srange.  IN and OUT operators are defined as X  -- but 16 bit operations
//  get set by CRY from bit 11.  (Do I care??? ) well probably not but it is documented  - so should 
//  be tested i guess.   
//
//  
//  may want to re-define as a module with carry look-ahead ?  
//
//  Had a notion to define a single adder - subtractor for both 8 and 16 bit operations, but 
//  getting into source mux issues that solution scared me.....   Worry the cry flag might
//  become a worst case path.   As defined, a good chunk of the decode process can go on in 
//  parallel with the cry computation ---   with final decisions made using a small mux at 
//  the flag register.
//  ------------ 8 bit adder for accumulator ops  plus the INC DEC ops ---------------------
//  It is documented that the hf is modified by the INC and DEC ops even if ar is not the 
//  destination of result   ---   clearly hf and nf are pretty usless on a INC B but ours is 
//  not to reason why :-)  ----   well its fun to bitch about silly stuff like this.  
//  ( not as much fun to deal with instruction tests testing "features" -- or worse programmers
//   who figure out ways to use theses "features". )
//
//  8 bit adder with cry out of bit 3   used for most operations on A as well as the 
//  inc/dec instructions.   also need to get ED44 (ar <= -ar) working here
wire [7:0]  src_pqri;  // use just here and below
wire [7:0]  src_aor_cnst = ed_blk_cp ?  ar    :  // CPI CPIR CPD CPDR
                              ir2[9] ?  8'h0  :  // for ed44 -a  //ed_grp == ir2[9]
                              ir2[7] ?  ar    :
                              ir2[0] ?  8'hff :
                                        8'h00  ;
                                    
//---------------  the "standard" flag logic -----------------------------
//                 sf           zf            f5f          hf        
assign alu8_fr ={alu8_out[7], ~|alu8_out, alu8_out[5], alu8_hcry,
//                 f3f          fpv           fn         fc
                 alu8_out[3], alu8_pvf, alu8_nf,  alu8_cry };
 //   excludeINC_r DEC_r        AND               XOR                    OR
assign alu8_pvf = ir2[7] & (ir2[5:3]==7'b100 | ir2[5:3]==7'b101 | ir2[5:3]==7'b110) ?
                                                                    ~^alu8_out   : // even parity
                (src_aor_cnst[7]==src_pqri[7]) & (src_aor_cnst[7]!=alu8_out[7])  ; // ofl 

assign alu8_nf = (ir2[7:3]==5'b10010)       | 
                 (ir2[7:3]==5'b10011)       | 
                 (ir2[7:6]==2'b00) & ir2[0] | 
                 ir2[9]                      ;

assign {c_8out3, add_8bit[3:0]} = {1'b0, src_aor_cnst[3:0]} + {1'b0, src_pqri[3:0]}   + {4'b0, c_8in0};
//wire [4:0] ha_temp = {1'b0, src_aor_cnst[3:0]} + {1'b0, src_pqri[3:0]}   + {4'b0, c_8in0};
//assign c_8out3 

assign {c_8out7, add_8bit[7:4]} = {1'b0, src_aor_cnst[7:4]} + {1'b0, src_pqri[7:4]}   + {4'b0, c_8out3};

//  notice that both inputs and outputs of the adder are being selected below.
//  making ed_blk_cp high priority kind of negates the origional idea of making the
//  decodes fast here  ---   course when all is included this can't be too fast.
//  Just note for syntheses that this is a slow path that could be improved with some thought.
//         1         1          8          8        1
assign {alu8_cry, alu8_hcry, alu8_out,  src_pqri, c_8in0 }=
   
   ed_blk_cp ?                         {c_8out7,c_8out3,  add_8bit,   ~nn[15:8], 1'h1} :   //CPI CPIR CPD CPDR

   {19{ir2[7] & ir2[5:3]==3'b000}} & ({c_8out7,c_8out3,  add_8bit,    src_pqr20, 1'b0} )  |// a+src
   {19{ir2[7] & ir2[5:3]==5'b001}} & ({c_8out7,c_8out3,  add_8bit,    src_pqr20,   cf} )  |// a+src+cf
   {19{ir2[7] & ir2[5:3]==5'b010}} & ({~c_8out7,c_8out3,  add_8bit,   ~src_pqr20, 1'h1} )  |// a-src
   {19{ir2[7] & ir2[5:3]==5'b011}} & ({~c_8out7,c_8out3,  add_8bit,   ~src_pqr20, ~cf } )  |// a-src-cf
   {19{ir2[7] & ir2[5:3]==5'b100}} & ({1'b0   ,1'b1   , ar & src_pqr20, src_pqr20, 1'b0} )|// a&src
   {19{ir2[7] & ir2[5:3]==5'b101}} & ({1'b0   ,1'b0   , ar ^ src_pqr20, src_pqr20, 1'b0} )|// a^src
   {19{ir2[7] & ir2[5:3]==5'b110}} & ({1'b0   ,1'b0   , ar | src_pqr20, src_pqr20, 1'b0} )|// a|src
   {19{ir2[7] & ir2[5:3]==5'b111}} & ({~c_8out7,c_8out3,  add_8bit,   ~src_pqr20,  1'h1})  |// a-src
   {19{(ir2[7:6]==2'b00)& ~ir2[0] }}& ({     cf,c_8out3,  add_8bit,    src_pqr53,  1'h1}) |// inc_r main
   {19{(ir2[7:6]==2'b00)&  ir2[0] }}& ({     cf,c_8out3,  add_8bit,    src_pqr53,  1'h0}) |// dec_r
   {19{(ir2[7:6]==2'b01)          }}& ({~c_8out7,c_8out3,  add_8bit,          ~ar,  1'h1})  ;// ed44 -a


// do some hand  decoding here                                        
//  ADDsHL_BC    = 'h09,  DECsBC       = 'h0B, INCsBC       = 'h03    compair with {ir2[7:6],ir2[3:0]}
//  ADDsHL_DE    = 'h19,  DECsDE       = 'h1B  INCsDE       = 'h13    ED_SBCsHL_REG  = 6'b01__0010
//  ADDsHL_HL    = 'h29,  DECsHL       = 'h2B  INCsHL       = 'h23    ED_ADCsHL_REG  = 6'b01__1010
//  ADDsHL_SP    = 'h39,  DECsSP       = 'h3B  INCsSP       = 'h33
//  by inspection just use ir2[3:0]  -  i guess in a pinch we do't need ir2[2]  =  but let the 
//  synthesizer figure that out. - it should be able to.
//


// ---------------- 16 bit adder with bit 11 carrry out and bit 8 carry in ------------------
//
assign add16_ofl = (src_a[15] == src_b[15]) & (src_a[15] != add16[15]);
 ///tmp/lint/wb_z80/rtl/inst_exec.v(363): Warning 22014: synchronous loop without set/reset detected on signal "src_b[11:8]" (OC)
assign {c_16out7,  add16[7:0]}  = {1'b0, src_a[7:0]}   + {1'b0, src_b[7:0]   } + {8'b0, c_16in0};
assign {c_16out11, add16[11:8]} = {1'b0, src_a[11:8]}  + {1'b0, src_b[11:8]  } + {4'b0, c_16out7};
assign {c_16out15, add16[15:12]} = {1'b0, src_a[15:12]} + {1'b0, src_b[15:12]} + {4'b0, c_16out11};

assign  { src_a,     src_b, c_16in0} =         // assigning 33 bits
   {33{ir2[3:0] == 4'h9}} & {src_dblhr, src_dbl  ,1'b0 }   |  //ADD
   {33{ir2[3:0] == 4'hb}} & {16'hffff , src_dbl  ,1'b0 }   |  //DEC 
   {33{ir2[3:0] == 4'h3}} & {16'h0001 , src_dbl  ,1'b0 }   |  //INC
   {33{ir2[3:0] == 4'h2}} & {src_dblhr, ~src_dbl , ~cf }   |  //SBC
   {33{ir2[3:0] == 4'ha}} & {src_dblhr, src_dbl  , cf  }    ; //ADC
                          
//-------------------------- sh alu --------------------------------------------------
//  shift insructions.  Think of these as 8 shift types:
//  RLC RL RRC RR SLA SLL SRA SRL  The SLL types appear to be undocumented  -- but possibly used 
//   in assembly code as they appear to have some utility  -  and by all accounts operate reliably. 
//   The first four are implemented in a single byte inaruction . (A <= sh_op A )
//   All 8  are implemented in the CB group with all registers as potential sources (and dests).
//   if ir2dd or ir2fd is prefix.....   source is always the memory. This is undocumented - but
//   may be a useful hint for simplyfing the total machine.  Destination registers
//   (if any) get a copy of the updated memory location  (This is also true of the bit set and 
//   clear instructions in the cb_grp.

assign {sh_cry, sh_alu} =  {9{ir2[5:3]==3'b000}} & {sh_src, sh_src[7] }                 | //RLC
                           {9{ir2[5:3]==3'b001}} & {sh_src[0], sh_src[0], sh_src[7:1]}  | // RRC
                           {9{ir2[5:3]==3'b010}} & {sh_src, cf  }                       | //RL 
                           {9{ir2[5:3]==3'b011}} & {sh_src[0], cf, sh_src[7:1] }        | // RR 
                           {9{ir2[5:3]==3'b100}} & {sh_src, 1'b0}                       |  //SLA
                           {9{ir2[5:3]==3'b101}} & {sh_src[0], sh_src[7], sh_src[7:1]}  |  //SRA
                           {9{ir2[5:3]==3'b110}} & {sh_src, 1'b1}                       |  //SLL
                           {9{ir2[5:3]==3'b111}} & {sh_src[0], 1'b0, sh_src[7:1]}      ;   //SRL


 // shift insts
 assign sh_alu_act = ir2[9:6] == 4'b0100;
 //CB_RLC   = 7'b01_00_000,  // these must be compaired with ir2[9:3]
 //CB_RRC   = 7'b01_00_001,  // these must be compaired with ir2[9:3]
 //CB_RL    = 7'b01_00_010,  // these must be compaired with ir2[9:3]
 //CB_RR    = 7'b01_00_011,  // these must be compaired with ir2[9:3]
 //CB_SLA   = 7'b01_00_100,  // these must be compaired with ir2[9:3]
 //CB_SRA   = 7'b01_00_101,  // these must be compaired with ir2[9:3]
 //CB_SLL   = 7'b01_00_110,  // these must be compaired with ir2[9:3]
 //CB_SRL   = 7'b01_00_111,  // these must be compaired with ir2[9:3]

//---------------------------- bit test alu ---------------------------------------
//  bit test insts
//CB_BIT   = 4'b01_01,    // these must be compaired with ir2[9:6]
//CB_RES   = 4'b01_10,    // these must be compaired with ir2[9:6]assign 
//CB_SET   = 4'b01_11,    // these must be compaired with ir2[9:6] 
assign bit_alu_act = ir2[9:6] == CB_RES |
                     ir2[9:6] == CB_SET ;

wire [7:0] bit_decode = {8{ir2[5:3] == 3'h0}} & 8'h01 |
                        {8{ir2[5:3] == 3'h1}} & 8'h02 |
                        {8{ir2[5:3] == 3'h2}} & 8'h04 |
                        {8{ir2[5:3] == 3'h3}} & 8'h08 |
                        {8{ir2[5:3] == 3'h4}} & 8'h10 |
                        {8{ir2[5:3] == 3'h5}} & 8'h20 |
                        {8{ir2[5:3] == 3'h6}} & 8'h40 |
                        {8{ir2[5:3] == 3'h7}} & 8'h80 ;

assign bit_alu = {8{ir2[9:6] == CB_BIT}} & ( sh_src & bit_decode)  |
                 {8{ir2[9:6] == CB_RES}} & ( sh_src & ~bit_decode) |
                 {8{ir2[9:6] == CB_SET}} & ( sh_src | bit_decode)   ;
                 

//------------ dec bc alu ---------------------------------------------
//exec_decbc;  these are all we know (in general)
//exec_decb;
assign decc_alu  =  cr + 8'hff ;
assign decb_alu  =  br + ( exec_decb ? 8'hff :    // just dec b if io blk move
                              cr_eq0 ? 8'hff :    // cry out if c in this case
                                      8'h00 );   // only dec c reg this tick
// ------------------ daa alu -------------------------------------------------------
// the documentation does not cover all cases here  -- only those that matter (i suppose).
// ( documentation assumes you are operating with 2 daa'd numbers  --  but of course the
// ar can contain many values that don't fit that assumption when this instruction is executed.
// Any arbitrary instruction test may test un-documented cases.
//
// this leaves me to guess what the actual logic is  - and how to match it.   
// So I am doing that -- see what happens. If an instruction test breaks this...  I should be 
// able to fix it easily.
//
wire [3:0] ls_nbl   =  (!nf & hf)                 ?  4'h6:
                       (!nf & (ar[3:0] > 4'h9))   ?  4'h6:
                       (nf  & hf )                ?  4'ha:                              
                                                     4'h0;

wire [4:0] ms_nbl   =  (!nf & cf)                 ?  5'h16:    //  includes new cry
                       (!nf & (ar[3:0]  > 4'h9))  ?  5'h16:
                       (!nf & (ar[3:0] == 4'h9) & 
                               (ar[3:0] > 4'h9))  ?  5'h16:
                       (nf  & !cf  &  hf )        ?  5'h0f:        
                       (nf  &  cf  & !hf )        ?  5'h1a:
                       (nf  &  cf  &  hf )        ?  5'h19:
                                                     5'h00;


assign {daa_cry, daa_alu} = { ms_nbl[4], {ar + { ms_nbl[3:0], ls_nbl}}  } ; 


//-------1---------2---------3--------State Machines-------6---------7---------8---------9--------0

//  update ar

assign upd_a_alu8 =
    ADDsA_B      == ir2 | SUBsB      == ir2 |  ANDsB      == ir2 | ORsB         == ir2   |
    ADDsA_C      == ir2 | SUBsC      == ir2 |  ANDsC      == ir2 | ORsC         == ir2   |
    ADDsA_D      == ir2 | SUBsD      == ir2 |  ANDsD      == ir2 | ORsD         == ir2   |
    ADDsA_E      == ir2 | SUBsE      == ir2 |  ANDsE      == ir2 | ORsE         == ir2   |
    ADDsA_H      == ir2 | SUBsH      == ir2 |  ANDsH      == ir2 | ORsH         == ir2   |
    ADDsA_L      == ir2 | SUBsL      == ir2 |  ANDsL      == ir2 | ORsL         == ir2   |
    ADDsA_6HL7   == ir2 | SUBs6HL7   == ir2 |  ANDs6HL7   == ir2 | ORs6HL7      == ir2   |
    ADDsA_A      == ir2 | SUBsA      == ir2 |  ANDsA      == ir2 | ORsA         == ir2   |
    ADCsA_B      == ir2 | SBCsB      == ir2 |  XORsB      == ir2 |
    ADCsA_C      == ir2 | SBCsC      == ir2 |  XORsC      == ir2 | INCsA        == ir2   |
    ADCsA_D      == ir2 | SBCsD      == ir2 |  XORsD      == ir2 | DECsA        == ir2   |
    ADCsA_E      == ir2 | SBCsE      == ir2 |  XORsE      == ir2 |
    ADCsA_H      == ir2 | SBCsH      == ir2 |  XORsH      == ir2 |
    ADCsA_L      == ir2 | SBCsL      == ir2 |  XORsL      == ir2 |
    ADCsA_6HL7   == ir2 | SBCs6HL7   == ir2 |  XORs6HL7   == ir2 |
    ADCsA_A      == ir2 | SBCsA      == ir2 |  XORsA      == ir2 |
    ADDsA_N      == ir2 | //      ADD A,N      ; C6 XX   ADDsA_6HL7   = 'h86
    ADCsA_N      == ir2 | //      ADC A,N      ; CE XX   ADCsA_6HL7   = 'h8E
    SUBsN        == ir2 | //      SUB N        ; D6 XX   SUBs6HL7     = 'h96
    SBCsA_N      == ir2 | //      SBC A,N      ; DE XX
    ANDsN        == ir2 | //      AND N        ; E6 XX
    XORsN        == ir2 | //      XOR N        ; EE XX
    ORsN         == ir2 ; //      OR N         ; F6 XX
assign up_a_sh_alu = 
    RLCA         == ir2   | //      RLCA        ; 07
    RRCA         == ir2   | //      RRCA        ; 0F
    RRA          == ir2   | //      RRA          ; 1F
    RLA          == ir2   ; //      RLA          ; 17
assign up_a_src_pqr = 
    LDsA_B       == ir2 |    //      LD A,B       ; 78
    LDsA_C       == ir2 |    //      LD A,C       ; 79
    LDsA_D       == ir2 |    //      LD A,D       ; 7A
    LDsA_E       == ir2 |    //      LD A,E       ; 7B
    LDsA_H       == ir2 |    //      LD A,H       ; 7C
    LDsA_L       == ir2 |    //      LD A,L       ; 7D
    LDsA_6HL7    == ir2 |    //      LD A,(HL)    ; 7E
    LDsA_A       == ir2 ;    //      LD A,A       ; 7F
assign up_a_n =            
    LDsA_N       == ir2 | //      LD A,N       ; 3E XX
    LDsA_6BC7    == ir2 | //      LD A,(BC)    ; 0A
    LDsA_6DE7    == ir2 | //      LD A,(DE)    ; 1A
    LDsA_6NN7    == ir2 | //      LD A,(NN)    ; 3A XX XX
    INsA_6N7     == ir2 | //      IN A,(N)     ; DB XX        
    (ED_INsREG_6C7 == {ir2[9:6],ir2[2:0]}) & (ir2[5:3] == REG8_A) ;


//EXsAF_AFp    = 10'h08,//      EX AF,AF'    ; 08
//EXX          = 10'hD9,//      EXX          ; D9
//DAA          = 10'h27,//      DAA          ; 27
//CPL          = 10'h2F,//      CPL          ; 2F   a <= ~a
//POPsAF       = 10'hF1,//      POP AF       ; F1
//  don't forget these beauties  not affected by prefixes
//ED_RRD       =  'h67//      RRD        ;  
//ED_RLD       =  'h6F//      RLD        ; ED 6F   nibble roates A (HL)
//ED_NEG         =    5'b01___100, // A<= -A   compair with {ir2[9:6],ir2[2:0]}                

//------------------------------- ar ------------------------------------------

assign upd_ar = upd_a_alu8 | up_a_sh_alu | up_a_src_pqr | up_a_n |  ir2 == EXsAF_AFp |
                ir2 == EXX | ir2 == DAA  | ir2 == CPL   | ir2 == POPsAF | 
                ir2[2:0] == REG8_A & bit_alu_act | ir2[2:0] == REG8_A & sh_alu_act |
                ir2== ED_RRD | {ir2[9:6], ir2[2:0]} == ED_NEG | 
                ir2 == ED_LDsA_I ;
                
always @(posedge clk)
begin
    if (upd_a_alu8 & exec_ir2)       ar <= alu8_out;
    if (up_a_sh_alu & exec_ir2)      ar <= sh_alu; 
    if (up_a_src_pqr & exec_ir2)     ar <= src_pqr20;
    if (up_a_n  & exec_ir2)          ar <= nn[15:8];    // changed for LD A N
    if (ir2 == EXsAF_AFp & exec_ir2) ar <= ap; 
    if (ir2 == EXX & exec_ir2)       ar <= ap;
    if (ir2 == DAA & exec_ir2)       ar <= daa_alu;
    if (ir2 == CPL & exec_ir2)       ar <= ~ar;
    if (ir2 == POPsAF & exec_ir2)    ar <= nn[15:8];
    if (ir2[2:0] == REG8_A & 
             bit_alu_act & exec_ir2) ar <= bit_alu;
    if (ir2[2:0] == REG8_A & 
             sh_alu_act & exec_ir2)  ar <= sh_alu;
    if (ir2 == ED_RRD & exec_ir2) ar[3:0] <= nn[11:8];         
    if (ir2 == ED_RLD & exec_ir2) ar[3:0] <= nn[15:12];
    if ({ir2[9:6], ir2[2:0]} == ED_NEG & exec_ir2) ar <= alu8_out;  // ED44 this done by alu8 for flags
    if (ir2 == ED_LDsA_I & exec_ir2) ar <= intr ;
end




// update br
//assign upd_b_decbc = 
//    ED_LDI       == ir2 | //      LDI        ; ED A0
//    ED_CPI       == ir2 | //      CPI        ; ED A1
//    ED_LDD       == ir2 | //      LDD        ; ED A8
//    ED_CPD       == ir2 | //      CPD        ; ED A9
//    ED_LDIR      == ir2 | //      LDIR       ; ED B0
//    ED_CPIR      == ir2 | //      CPIR       ; ED B1
//    ED_LDDR      == ir2 | //      LDDR       ; ED B8
//    ED_CPDR      == ir2  ;//      CPDR       ; ED B9

//assign eb_io = 

//    ED_INI       == ir2 | //      INI        ; ED A2
//    ED_IND       == ir2 | //      IND        ; ED AA
//    ED_OUTD      == ir2 | //      OUTD       ; ED AB
//    ED_OUTI      == ir2 | //      OUTI       ; ED A3
//    ED_INIR      == ir2 | //      INIR       ; ED B2
//    ED_OTIR      == ir2 | //      OTIR       ; ED B3
//    ED_INDR      == ir2 | //      INDR       ; ED BA
//    ED_OTDR      == ir2  ; //      OTDR       ; ED BB

assign upd_b_alu8 =
    INCsB         == ir2 |//      INC B       ; 04
    DECsB         == ir2 ;//      DEC B       ; 05


assign up_b_src_pqr =
    LDsB_B       == ir2 |//      LD B,B       ; 40
    LDsB_C       == ir2 |//      LD B,C       ; 41
    LDsB_D       == ir2 |//      LD B,D       ; 42
    LDsB_E       == ir2 |//      LD B,E       ; 43
    LDsB_H       == ir2 |//      LD B,H       ; 44
    LDsB_L       == ir2 |//      LD B,L       ; 45
    LDsB_6HL7    == ir2 |//      LD B,(HL)    ; 46
    LDsB_A       == ir2 ;//      LD B,A       ; 47
assign up_b_add16 = 
    INCsBC       == ir2 |//      INC BC      ; 03
    DECsBC       == ir2 ;//      DEC BC      ; 0B
//LDsBC_nn     = 10'h01,//      LD BC,NN    ; 01 XX XX
//POPsBC       = 10'hC1,//      POP BC       ; C1
//EXX          = 10'hD9,//      EXX          ; D9
//LDsB_N       = 10'h06,//      LD B,N      ; 06 XX
//DJNZs$t2     = 10'h10,//      DJNZ $+2     ; 10 XX   //pre dec br
//ED_RRD       =  'h67//      RRD        ; ED 67   nibble roates A HL
//ED_RLD       =  'h6F//      RLD        ; ED 6F   nibble roates A HL
//ED_INsREG_6C7  =    5'b01___000,// compair with {ir2[7:6],ir2[2:0]} really (BCio)

//------------------------------- br -----------------------------------------

assign upd_bc_cpi = ed_blk_cp & exec_ir2;

assign upd_br = upd_b_alu8 | up_b_src_pqr | up_b_add16 | LDsBC_NN  == ir2 | 
                POPsBC    == ir2 | EXX       == ir2 | LDsB_N    == ir2    | 
                ir2[2:0] == REG8_B & bit_alu_act | ir2[2:0] == REG8_B & sh_alu_act |
                DJNZs$t2  == ir2 | (ED_INsREG_6C7 == {ir2[9:6],ir2[2:0]}) & (ir2[5:3] == REG8_B) |
                (ED_LDsREG_6NN7 == {ir2[9:6],ir2[3:0]}) & (ir2[5:4] == DBL_REG_BC);


always @(posedge clk)
begin
    if ( upd_b_alu8 & exec_ir2)        br <= alu8_out;
    if ( up_b_src_pqr & exec_ir2)      br <= src_pqr20;
    if ( up_b_add16   & exec_ir2)      br <= add16[15:8];
    if ( LDsBC_NN  == ir2 & exec_ir2)  br <= nn[15:8];
    if ( POPsBC    == ir2 & exec_ir2)  br <= nn[15:8];
    if ( EXX       == ir2  & exec_ir2) br <= bp;
    if ( LDsB_N    == ir2  & exec_ir2) br <= nn[15:8];
    if (ir2[2:0] == REG8_B & 
             bit_alu_act & exec_ir2)   br <= bit_alu;
    if (ir2[2:0] == REG8_B & 
             sh_alu_act & exec_ir2)    br <= sh_alu;  
    if ( DJNZs$t2  == ir2  & exec_ir2) br <= br + 8'hff; // use seperate adder here as no flags  
                                                        // change  -- we need br==0.  for now 
                                                        // use |br.   If we need more speed add
                                                        // a ff.
    if (exec_decb | exec_decbc |upd_bc_cpi)        br <= decb_alu; 
    if ( (ED_INsREG_6C7 == {ir2[9:6],ir2[2:0]}) & (ir2[5:3] == REG8_B) & exec_ir2 ) br <= nn[15:8];
    if ( (ED_LDsREG_6NN7 == {ir2[9:6],ir2[3:0]}) & (ir2[5:4] == DBL_REG_BC) & exec_ir2 ) br <= nn[15:8];
end


//  update cr
assign up_c_add16 = 
    INCsBC       == ir2 |//      INC BC      ; 03
    DECsBC       == ir2 ;//      DEC BC      ; 0B,
assign upd_c_alu8 =
    INCsC        == ir2 |//      INC C       ; 0C
    DECsC        == ir2 ;//      DEC C       ; 0D
assign up_c_src_pqr =
    LDsC_B       == ir2 |//      LD C,B       ; 48
    LDsC_C       == ir2 |//      LD C,C       ; 49
    LDsC_D       == ir2 |//      LD C,D       ; 4A
    LDsC_E       == ir2 |//      LD C,E       ; 4B
    LDsC_H       == ir2 |//      LD C,H       ; 4C
    LDsC_L       == ir2 |//      LD C,L       ; 4D
    LDsC_6HL7    == ir2 |//      LD C,(HL)    ; 4E
    LDsC_A       == ir2 ;//      LD C,A       ; 4F


//LDsC_N       == ir2 |//      LD C,N      ; 0E XX
//LDsBC_NN     = 10'h01,//      LD BC,NN    ; 01 XX XX
//POPsBC       = 10'hC1,//      POP BC       ; C1
//EXX          = 10'hD9,//      EXX          ; D9
//ED_INsREG_6C7  =    5'b01___000,// compair with {ir2[9:6],ir2[2:0]} really (BCio)

//------------------------------- cr -----------------------------------------
assign upd_cr = upd_c_alu8 | up_c_src_pqr | up_c_add16 | LDsBC_NN  == ir2 | 
                POPsBC    == ir2 | EXX       == ir2 | LDsC_N    == ir2    | 
                ir2[2:0] == REG8_C & bit_alu_act | ir2[2:0] == REG8_C & sh_alu_act |
                (ED_INsREG_6C7 == {ir2[9:6],ir2[2:0]}) & (ir2[5:3] == REG8_C)      |
                (ED_LDsREG_6NN7 == {ir2[9:6],ir2[3:0]}) & (ir2[5:4] == DBL_REG_BC);



always @(posedge clk)
begin
    if ( upd_c_alu8 & exec_ir2)        cr <= alu8_out;
    if ( up_c_src_pqr & exec_ir2)      cr <= src_pqr20;
    if ( up_c_add16   & exec_ir2)      cr <= add16[7:0];
    if ( LDsBC_NN  == ir2 & exec_ir2)  cr <= nn[7:0];
    if ( POPsBC    == ir2 & exec_ir2)  cr <= nn[7:0];
    if ( EXX       == ir2  & exec_ir2) cr <= cp;
    if ( LDsC_N    == ir2  & exec_ir2) cr <= nn[15:8];
    if (ir2[2:0] == REG8_C & 
             bit_alu_act & exec_ir2)   cr <= bit_alu;
    if (ir2[2:0] == REG8_C & 
             sh_alu_act & exec_ir2)    cr <= sh_alu;  
    if ( exec_decbc |upd_bc_cpi)       cr <= decc_alu;
    if ((ED_INsREG_6C7 == {ir2[9:6],ir2[2:0]}) & (ir2[5:3] == REG8_C) & exec_ir2)    
                                           cr <= nn[15:8];    
    if ( (ED_LDsREG_6NN7 == {ir2[9:6],ir2[3:0]}) & (ir2[5:4] == DBL_REG_BC) & exec_ir2 ) cr <= nn[7:0];

end


//  update dr
assign up_d_add16 =
    INCsDE       == ir2 |  //      INC DE       ; 13
    DECsDE       == ir2  ; //      DEC DE       ; 1B

assign upd_d_alu8 =
    INCsD        == ir2 |  //      INC D        ; 14
    DECsD        == ir2  ; //      DEC D        ; 15
assign up_d_src_pqr =
    LDsD_B       == ir2 |      //LD D,B       ; 50
    LDsD_C       == ir2 |      //LD D,C       ; 51
    LDsD_D       == ir2 |      //LD D,D       ; 52
    LDsD_E       == ir2 |      //LD D,E       ; 53
    LDsD_H       == ir2 |      //LD D,H       ; 54
    LDsD_L       == ir2 |      //LD D,L       ; 55             
    LDsD_6HL7    == ir2 |      //LD D,(HL)    ; 56endmodule
    LDsD_A       == ir2 ;      //LD D,A       ; 57
             

//LDsD_N       = 10'h16,//      LD D,N       ; 16 XX
//LDsDE_NN     = 10'h11,//      LD DE,NN     ; 11 XX XX
//POPsDE       = 10'hD1,//      POP DE       ; D1
//EXX          = 10'hD9,//      EXX          ; D9
//EXsDE_HL     = 10'hEB,//      EX DE,HL     ; EB
//ED_INsREG_6C7  =    5'b01___000,// compair with {ir2[9:6],ir2[2:0]} really (BCio)

//---------------------------------- dr ------------------------------------

assign upd_dr = upd_d_alu8 | up_d_src_pqr | up_d_add16 | LDsDE_NN  == ir2 | 
                POPsDE    == ir2 | EXX       == ir2 | EXsDE_HL == ir2 | LDsD_N    == ir2 | 
                ir2[2:0] == REG8_D & bit_alu_act | ir2[2:0] == REG8_D & sh_alu_act |
                 (ED_INsREG_6C7 == {ir2[9:6],ir2[2:0]}) & (ir2[5:3] == REG8_D)     |
                 (ED_LDsREG_6NN7 == {ir2[9:6],ir2[3:0]}) & (ir2[5:4] == DBL_REG_DE);





wire ed_ld_dereg = (ED_LDsREG_6NN7 == {ir2[9:6],ir2[3:0]}) & (ir2[5:4] == DBL_REG_DE);
always @(posedge clk)
begin
    if ( upd_d_alu8 & exec_ir2)        dr <= alu8_out;
    if ( up_d_src_pqr & exec_ir2)      dr <= src_pqr20;
    if ( up_d_add16   & exec_ir2)      dr <= add16[15:8];
    if ( LDsDE_NN  == ir2 & exec_ir2)  dr <= nn[15:8];
    if ( POPsDE    == ir2 & exec_ir2)  dr <= nn[15:8];
    if ( EXX       == ir2  & exec_ir2) dr <= dp;
    if ( EXsDE_HL  == ir2  & exec_ir2) dr <= hr;
    if ( LDsD_N    == ir2  & exec_ir2) dr <= nn[15:8];
    if (ir2[2:0] == REG8_D & 
             bit_alu_act & exec_ir2)   dr <= bit_alu;
    if (ir2[2:0] == REG8_D & 
             sh_alu_act & exec_ir2)    dr <= sh_alu;  
    if ((ED_INsREG_6C7 == {ir2[9:6],ir2[2:0]}) 
         & (ir2[5:3] == REG8_D) & exec_ir2)             
                                        dr <= nn[15:8];
    if ( ed_ld_dereg & exec_ir2 ) 
                                        dr <= nn[15:8];
    if (blk_mv_upd_de)                  dr <= adr_alu[15:8];
end

//  update er
assign up_e_add16 =
    INCsDE       == ir2 |//      INC DE       ; 13
    DECsDE       == ir2 ;//      DEC DE       ; 1B
assign upd_e_alu8 =
    INCsE        == ir2 |//      INC E        ; 1C
    DECsE        == ir2 ;//      DEC E        ; 1D
assign up_e_src_pqr =
    LDsE_B       == ir2 |//      LD E,B       ; 58
    LDsE_C       == ir2 |//      LD E,C       ; 59
    LDsE_D       == ir2 |//      LD E,D       ; 5A
    LDsE_E       == ir2 |//      LD E,E       ; 5B
    LDsE_H       == ir2 |//      LD E,H       ; 5C
    LDsE_L       == ir2 |//      LD E,L       ; 5D
    LDsE_6HL7    == ir2 |//      LD E,(HL)    ; 5E
    LDsE_A       == ir2 ;//      LD E,A       ; 5F

//LDsE_N       = 10'h1E,//      LD E,N       ; 1E XX
//LDsDE_NN     = 10'h11,//      LD DE,NN     ; 11 XX XX
//POPsDE       = 10'hD1,//      POP DE       ; D1
//EXX          = 10'hD9,//      EXX          ; D9
//EXsDE_HL     = 10'hEB,//      EX DE,HL     ; EB
//ED_INsREG_6C7  =    5'b01___000,// compair with {ir2[9:6],ir2[2:0]} really (BCio)

//---------------------------------- er ------------------------------------


assign upd_er = upd_e_alu8 | up_e_src_pqr | up_e_add16 | LDsDE_NN  == ir2 | 
                POPsDE    == ir2 | EXX       == ir2 | EXsDE_HL == ir2 | LDsE_N    == ir2 | 
                ir2[2:0] == REG8_E & bit_alu_act | ir2[2:0] == REG8_E & sh_alu_act |
                 (ED_INsREG_6C7 == {ir2[9:6],ir2[2:0]}) & (ir2[5:3] == REG8_E)     |
                 (ED_LDsREG_6NN7 == {ir2[9:6],ir2[3:0]}) & (ir2[5:4] == DBL_REG_DE);

always @(posedge clk)
begin
    if ( upd_e_alu8 & exec_ir2)        er <= alu8_out;
    if ( up_e_src_pqr & exec_ir2)      er <= src_pqr20;
    if ( up_e_add16   & exec_ir2)      er <= add16[7:0];
    if ( LDsDE_NN  == ir2 & exec_ir2)  er <= nn[7:0];
    if ( POPsDE    == ir2 & exec_ir2)  er <= nn[7:0];
    if ( EXX       == ir2  & exec_ir2) er <= ep;
    if ( EXsDE_HL  == ir2  & exec_ir2) er <= lr;   // hharte was er <= hr
    if ( LDsE_N    == ir2  & exec_ir2) er <= nn[15:8];
    if (ir2[2:0] == REG8_E & 
             bit_alu_act & exec_ir2)   er <= bit_alu;
    if (ir2[2:0] == REG8_E & 
             sh_alu_act & exec_ir2)    er <= sh_alu;
    if ((ED_INsREG_6C7 == {ir2[9:6],ir2[2:0]}) & (ir2[5:3] == REG8_E) & exec_ir2)              
                                           er <= nn[15:8];             
    if ( ed_ld_dereg & exec_ir2 ) 
                                        er <= nn[7:0];
    if (blk_mv_upd_de)                  er <= adr_alu[7:0];
     
end


//  update hr
assign up_h_add16 =
    ADDsHL_BC    == ir2 | //      ADD HL,BC   ; 09
    ADDsHL_DE    == ir2 | //      ADD HL,DE    ; 19
    ADDsHL_HL    == ir2 | //      ADD HL,HL    ; 29
    ADDsHL_SP    == ir2 | //      ADD HL,SP    ; 39
    ED_SBCsHL_REG  == {ir2[9:6],ir2[3:0]}  |  // compair with {ir[9:6],ir[3:0]}
    ED_ADCsHL_REG  == {ir2[9:6],ir2[3:0]}  |  // compair with {ir[9:6],ir[3:0]}

    INCsHL       == ir2 | //      INC HL       ; 23
    DECsHL       == ir2 ; //      DEC HL       ; 2B
assign upd_h_alu8 =
    INCsH        == ir2 | //      INC H        ; 24
    DECsH        == ir2 ; //      DEC H        ; 25
assign upd_h_src_pqr =
    LDsH_B       == ir2 | //      LD H,B       ; 60
    LDsH_C       == ir2 | //      LD H,C       ; 61
    LDsH_D       == ir2 | //      LD H,D       ; 62
    LDsH_E       == ir2 | //      LD H,E       ; 63
    LDsH_H       == ir2 | //      LD H,H       ; 64
    LDsH_L       == ir2 | //      LD H,L       ; 65
    LDsH_6HL7    == ir2 | //      LD H,(HL)    ; 66
    LDsH_A       == ir2 ; //      LD H,A       ; 67
//ED_INsREG_6C7  =    5'b01___000,// compair with {ir2[9:6],ir2[2:0]} really (BCio)

//POPsHL       = 10'hE1,//      POP HL       ; E1
//EXs6SP7_HL   = 10'hE3,//      EX (SP),HL   ; E3
//LDsHL_NN     = 10'h21,//      LD HL,NN     ; 21 XX XX
//LDsHL_6NN7   = 10'h2A,//      LD HL,(NN)   ; 2A XX XX
//LDsH_N       = 10'h26,//      LD H,N       ; 26 XX

//  only these are not affected by dd and fd prefixes
//EXsDE_HL     = 10'hEB,//      EX DE,HL     ; EB
//EXX          = 10'hD9,//      EXX          ; D9

//---------------------------------- hr ------------------------------------
// we just check hr and lr - the prefixes for use of ix and iy imply that something
// pretty strange has to happen for a hazard related to use of those registers.  We can 
// assume upd hr impies upd ix and iy without adverse timing consequences.
// 
assign upd_hr = upd_h_alu8 | upd_h_src_pqr | up_h_add16 | LDsHL_NN  == ir2 | LDsHL_6NN7== ir2 |
                POPsHL    == ir2 | EXX       == ir2 | EXsDE_HL == ir2 | LDsH_N    == ir2 | 
                ir2[2:0] == REG8_H & bit_alu_act | ir2[2:0] == REG8_H & sh_alu_act |
                 (ED_INsREG_6C7 == {ir2[9:6],ir2[2:0]}) & (ir2[5:3] == REG8_H)     |
                 (ED_LDsREG_6NN7 == {ir2[9:6],ir2[3:0]}) & (ir2[5:4] == DBL_REG_HL);




wire exec_hlir2 = exec_ir2 & !(ir2dd | ir2fd);

always @(posedge clk)
begin
    if ( upd_h_alu8 & exec_hlir2)        hr <= alu8_out;
    if ( upd_h_src_pqr & exec_hlir2)      hr <= src_pqr20;
    if ( up_h_add16   & exec_hlir2)      hr <= add16[15:8];
    if ( LDsHL_NN  == ir2 & exec_hlir2)  hr <= nn[15:8];
    if ( LDsHL_6NN7== ir2 & exec_hlir2)  hr <= nn[15:8];
    if ( POPsHL    == ir2 & exec_hlir2)  hr <= nn[15:8];
    if ( EXs6SP7_HL== ir2 & exec_hlir2)  hr <= nn[15:8];
    if ( EXX       == ir2  & exec_ir2)   hr <= hp;
    if ( EXsDE_HL  == ir2  & exec_ir2)   hr <= dr;
    if ( LDsH_N    == ir2  & exec_hlir2) hr <= nn[15:8];
    if (ir2[2:0] == REG8_H & 
             bit_alu_act & exec_hlir2)   hr <= bit_alu;
    if (ir2[2:0] == REG8_H & 
             sh_alu_act & exec_hlir2)    hr <= sh_alu;  
    if ((ED_INsREG_6C7 == {ir2[9:6],ir2[2:0]}) & (ir2[5:3] == REG8_H) & exec_ir2)              
                                           hr <= nn[15:8];
    if ( (ED_LDsREG_6NN7 == {ir2[9:6],ir2[3:0]}) & (ir2[5:4] == DBL_REG_HL) & exec_ir2 ) 
                                         hr <= nn[15:8];
    if (blk_mv_upd_hl)                   hr <= adr_alu[15:8];

end

//  update lr
assign up_l_add16 =
    ADDsHL_BC    == ir2 |//      ADD HL,BC   ; 09
    ADDsHL_DE    == ir2 |//      ADD HL,DE    ; 19
    ADDsHL_HL    == ir2 |//      ADD HL,HL    ; 29
    ADDsHL_SP    == ir2 |//      ADD HL,SP    ; 39
    ED_SBCsHL_REG  == {ir2[9:6],ir2[3:0]}  |  // compair with {ir[9:6],ir[3:0]}
    ED_ADCsHL_REG  == {ir2[9:6],ir2[3:0]}  |  // compair with {ir[9:6],ir[3:0]}
    INCsHL       == ir2 |//      INC HL       ; 23
    DECsHL       == ir2 ;//      DEC HL       ; 2B
assign upd_l_alu8 =
    INCsL        == ir2 |//      INC L        ; 2C
    DECsL        == ir2 ;//      DEC L        ; 2D
assign upd_l_src_pqr =
    LDsL_B       == ir2 |//      LD L,B       ; 68
    LDsL_C       == ir2 |//      LD L,C       ; 69
    LDsL_D       == ir2 |//      LD L,D       ; 6A
    LDsL_E       == ir2 |//      LD L,E       ; 6B
    LDsL_H       == ir2 |//      LD L,H       ; 6C
    LDsL_L       == ir2 |//      LD L,L       ; 6D
    LDsL_6HL7    == ir2 |//      LD L,(HL)    ; 6E
    LDsL_A       == ir2 ;//      LD L,A       ; 6F
//EXX          = 10'hD9,//      EXX          ; D9
//POPsHL       = 10'hE1,//      POP HL       ; E1
//EXs6SP7_HL   = 10'hE3,//      EX (SP),HL   ; E3
//EXsDE_HL     = 10'hEB,//      EX DE,HL     ; EB
//LDsHL_NN     = 10'h21,//      LD HL,NN     ; 21 XX XX
//LDsHL_6NN7   = 10'h2A,//      LD HL,(NN)   ; 2A XX XX
//LDsL_N       = 10'h2E,//      LD L,N       ; 2E XX
//ED_INsREG_6C7



//---------------------------------- lr ------------------------------------
assign upd_lr = upd_l_alu8 | upd_l_src_pqr | up_l_add16 | LDsHL_NN  == ir2 | LDsHL_6NN7== ir2 |
                POPsHL    == ir2 | EXX       == ir2 | EXsDE_HL == ir2 | LDsL_N    == ir2 | 
                ir2[2:0] == REG8_L & bit_alu_act | ir2[2:0] == REG8_L & sh_alu_act |
                 (ED_INsREG_6C7 == {ir2[9:6],ir2[2:0]}) & (ir2[5:3] == REG8_L)     |
                 (ED_LDsREG_6NN7 == {ir2[9:6],ir2[3:0]}) & (ir2[5:4] == DBL_REG_HL);



always @(posedge clk)
begin
    if ( upd_l_alu8 & exec_hlir2)        lr <= alu8_out;
    if ( upd_l_src_pqr & exec_hlir2)      lr <= src_pqr20;
    if ( up_l_add16   & exec_hlir2)      lr <= add16[7:0];
    if ( LDsHL_NN  == ir2 & exec_hlir2)  lr <= nn[7:0];
    if ( LDsHL_6NN7== ir2 & exec_hlir2)  lr <= nn[7:0];
    if ( POPsHL    == ir2 & exec_hlir2)  lr <= nn[7:0];
    if ( EXs6SP7_HL== ir2 & exec_hlir2)  lr <= nn[7:0];
    if ( EXX       == ir2  & exec_ir2)   lr <= lp;
    if ( EXsDE_HL  == ir2  & exec_ir2)   lr <= er;
    if ( LDsL_N    == ir2  & exec_hlir2) lr <= nn[15:8];
    if (ir2[2:0] == REG8_L & 
             bit_alu_act & exec_hlir2)   lr <= bit_alu;
    if (ir2[2:0] == REG8_L & 
             sh_alu_act & exec_hlir2)    lr <= sh_alu;
    if ((ED_INsREG_6C7 == {ir2[9:6],ir2[2:0]}) & (ir2[5:3] == REG8_L) & exec_ir2)              
                                         lr <= nn[15:8];             
    if ( (ED_LDsREG_6NN7 == {ir2[9:6],ir2[3:0]}) & (ir2[5:4] == DBL_REG_HL) & exec_ir2 ) 
                                         lr <= nn[7:0];
    if (blk_mv_upd_hl)                   lr <= adr_alu[7:0];
     
end
//------------------------ ixr ---------------------------------------------
wire exec_ixir2 = exec_ir2 & ir2dd;
always @(posedge clk)
begin
    if ( upd_l_alu8 & exec_ixir2)        ixr[7:0] <= alu8_out;
    if ( upd_l_src_pqr & exec_ixir2)      ixr[7:0] <= src_pqr20;
    if ( up_l_add16   & exec_ixir2)      ixr[7:0] <= add16[7:0];
    if ( LDsHL_NN  == ir2 & exec_ixir2)  ixr[7:0] <= nn[7:0];
    if ( LDsHL_6NN7== ir2 & exec_ixir2)  ixr[7:0] <= nn[7:0];
    if ( POPsHL    == ir2 & exec_ixir2)  ixr[7:0] <= nn[7:0];
    if ( EXs6SP7_HL== ir2 & exec_ixir2)  ixr[7:0] <= nn[7:0];

    if ( LDsL_N    == ir2  & exec_ixir2) ixr[7:0] <= nn[15:8];
    if (ir2[2:0] == REG8_L & 
             bit_alu_act & exec_ixir2)   ixr[7:0] <= bit_alu;
    if (ir2[2:0] == REG8_L & 
             sh_alu_act & exec_ixir2)    ixr[7:0] <= sh_alu;  
             
end

always @(posedge clk)
begin
    if ( upd_h_alu8 & exec_ixir2)        ixr[15:8] <= alu8_out;
    if ( upd_h_src_pqr & exec_ixir2)      ixr[15:8] <= src_pqr20;
    if ( up_h_add16   & exec_ixir2)      ixr[15:8] <= add16[15:8];
    if ( LDsHL_NN  == ir2 & exec_ixir2)  ixr[15:8] <= nn[15:8];
    if ( LDsHL_6NN7== ir2 & exec_ixir2)  ixr[15:8] <= nn[15:8];
    if ( POPsHL    == ir2 & exec_ixir2)  ixr[15:8] <= nn[15:8];
    if ( EXs6SP7_HL== ir2 & exec_ixir2)  ixr[15:8] <= nn[15:8];

    if ( LDsH_N    == ir2  & exec_ixir2) ixr[15:8] <= nn[15:8];
    if (ir2[2:0] == REG8_H & 
             bit_alu_act & exec_ixir2)   ixr[15:8] <= bit_alu;
    if (ir2[2:0] == REG8_H & 
             sh_alu_act & exec_ixir2)    ixr[15:8] <= sh_alu;  
             
end

//------------------------ iyr ---------------------------------------------
wire exec_iyir2 = exec_ir2 & ir2fd;
always @(posedge clk)
begin
    if ( upd_l_alu8 & exec_iyir2)        iyr[7:0] <= alu8_out;
    if ( upd_l_src_pqr & exec_iyir2)      iyr[7:0] <= src_pqr20;
    if ( up_l_add16   & exec_iyir2)      iyr[7:0] <= add16[7:0];
    if ( LDsHL_NN  == ir2 & exec_iyir2)  iyr[7:0] <= nn[7:0];
    if ( LDsHL_6NN7== ir2 & exec_iyir2)  iyr[7:0] <= nn[7:0];
    if ( POPsHL    == ir2 & exec_iyir2)  iyr[7:0] <= nn[7:0];
    if ( EXs6SP7_HL== ir2 & exec_iyir2)  iyr[7:0] <= nn[7:0];

    if ( LDsL_N    == ir2  & exec_iyir2) iyr[7:0] <= nn[15:8];
    if (ir2[2:0] == REG8_L & 
             bit_alu_act & exec_iyir2)   iyr[7:0] <= bit_alu;
    if (ir2[2:0] == REG8_L & 
             sh_alu_act & exec_iyir2)    iyr[7:0] <= sh_alu;  
             
end

always @(posedge clk)
begin
    if ( upd_h_alu8 & exec_iyir2)        iyr[15:8] <= alu8_out;
    if ( upd_h_src_pqr & exec_iyir2)      iyr[15:8] <= src_pqr20;
    if ( up_h_add16   & exec_iyir2)      iyr[15:8] <= add16[15:8];
    if ( LDsHL_NN  == ir2 & exec_iyir2)  iyr[15:8] <= nn[15:8];
    if ( LDsHL_6NN7== ir2 & exec_iyir2)  iyr[15:8] <= nn[15:8];
    if ( POPsHL    == ir2 & exec_iyir2)  iyr[15:8] <= nn[15:8];
    if ( EXs6SP7_HL== ir2 & exec_iyir2)  iyr[15:8] <= nn[15:8];

    if ( LDsH_N    == ir2  & exec_iyir2) iyr[15:8] <= nn[15:8];
    if (ir2[2:0] == REG8_H & 
             bit_alu_act & exec_iyir2)   iyr[15:8] <= bit_alu;
    if (ir2[2:0] == REG8_H & 
             sh_alu_act & exec_iyir2)    iyr[15:8] <= sh_alu;  
             
end


//---------------------------- prime regiters  (shadows?) ----------------

always @(posedge clk)
begin
    if (ir2 == EXsAF_AFp & exec_ir2) 
    begin
        ap <= ar; 
        fp <= fr; 
    end
    if (ir2 == EXX & exec_ir2)       
    begin
        ap <= ar;
        fp <= fr;
        bp <= br;
        cp <= cr;
        dp <= dr;
        ep <= er;
        hp <= hr;
        lp <= lr;
    end
end
//-------------------------- flag registers -------------------------------
//  This is a mess  -  There is in general no reasonable way to get this stuff to follow
//  z80 exactly. ---   in some of the undocumented cases, there is not even a 
//  guess expressed about what is actually done.   In some of the other undocumented
//  cases, what is claimed happens is soo silly that It is hard for me to believe
//  it matters   ( unfortunately i am far too aware that one man's garbage can be 
//  anothers treasure  --- or....., its amazing how silly 
//  behavior (bug?) can become a feature.  In any case, The attempt (at first blush) is 
//  only to get the documented stuff right  --  although if undocumented behavior
//  falls out, great. For exmple, I will typically update f3f and f5f with alu output - 
//  these flags are documented as "undefined".  
//
//   some of the wierd stuff to worry about:
//   16 bit ops:
//   the ed insts SBC ADC muck with all flags  but 
//   the ADD inst doesn't change sf zf or pvf.
//   and the 16 bit INC and DEC insts touch nothing
//  
//   the ED_RLD and RRD instructions muck with flags based on ar  -- these operations
//   should be correct rleative to subsequent DAA's i suppose.

//  update all flags from alu8   for logic operations pv <= parity else ofl
//  INC and DEC same as  but no cf change  oh my god why?  done in logic above

assign upd_fr_alu8 = 
    ADCsA_A  == ir2 |   ANDsA    == ir2 |  ORsA     == ir2 | SUBsA    == ir2 | DECsA       == ir2 |
    ADCsA_B  == ir2 |   ANDsB    == ir2 |  ORsB     == ir2 | SUBsB    == ir2 | DECsB       == ir2 |
    ADCsA_C  == ir2 |   ANDsC    == ir2 |  ORsC     == ir2 | SUBsC    == ir2 | DECsC       == ir2 |
    ADCsA_D  == ir2 |   ANDsD    == ir2 |  ORsD     == ir2 | SUBsD    == ir2 | DECsD       == ir2 |
    ADCsA_E  == ir2 |   ANDsE    == ir2 |  ORsE     == ir2 | SUBsE    == ir2 | DECsE       == ir2 |
    ADCsA_H  == ir2 |   ANDsH    == ir2 |  ORsH     == ir2 | SUBsH    == ir2 | DECsH       == ir2 |
    ADCsA_L  == ir2 |   ANDsL    == ir2 |  ORsL     == ir2 | SUBsL    == ir2 | DECsL       == ir2 |
    ADCsA_6HL7==ir2 |   ANDs6HL7  ==ir2 |  ORs6HL7  ==ir2  | SUBs6HL7  ==ir2 | INCsA       == ir2 |
    ADDsA_A  == ir2 |   CPsA     == ir2 |  SBCsA    == ir2 | XORsA    == ir2 | INCsB       == ir2 |
    ADDsA_B  == ir2 |   CPsB     == ir2 |  SBCs6HL7  ==ir2 | XORsB    == ir2 | INCsC       == ir2 |
    ADDsA_C  == ir2 |   CPsC     == ir2 |  SBCsB    == ir2 | XORsC    == ir2 | INCsD       == ir2 |
    ADDsA_D  == ir2 |   CPsD     == ir2 |  SBCsC    == ir2 | XORsD    == ir2 | INCsE       == ir2 |
    ADDsA_E  == ir2 |   CPsE     == ir2 |  SBCsD    == ir2 | XORsE    == ir2 | INCsH       == ir2 |
    ADDsA_H  == ir2 |   CPsH     == ir2 |  SBCsE    == ir2 | XORsH    == ir2 | INCsL       == ir2 |
    ADDsA_L  == ir2 |   CPsL     == ir2 |  SBCsH    == ir2 | XORsL    == ir2 | INCs6HL7    == ir2 |
    ADDsA_6HL7== ir2|   CPs6HL7  == ir2 |  SBCsL    == ir2 | XORs6HL7 == ir2 | DECs6HL7    == ir2 |
    ADDsA_N   == ir2|   SUBsN    == ir2 | ANDsN     == ir2 |  ORsN    == ir2 |
    ADCsA_N   ==ir2 |   SBCsA_N  ==ir2  | XORsN     ==ir2  |  CPsN    == ir2 |
    ED_NEG   ==  {ir2[9:6],ir2[2:0]} ; //7'b1001___100,   A<= -A                  

                                       

// update h n c (f5, f3) from alu16
assign upd_fr_add16 = 
    ADDsHL_BC    == ir2 |      //      ADD HL,BC    ; 09
    ADDsHL_DE    == ir2 |      //      ADD HL,DE    ; 19
    ADDsHL_HL    == ir2 |      //      ADD HL,HL    ; 29
    ADDsHL_SP    == ir2 ;      //      ADD HL,SP    ; 39
//    INCsBC       == ir2 |      //      INC BC       ; 03    no flag changes for these
//    INCsDE       == ir2 |      //      INC DE       ; 13
//    INCsHL       == ir2 |      //      INC HL       ; 23
//    INCsSP       == ir2 ;      //      INC SP       ; 33

// update all flags from alu16
assign upd_fr_edadd16 = 
    ED_SBCsHL_REG  == {ir2[9:6],ir2[3:0]} | // compair with {ir2[9:6],ir2[3:0]}
    ED_ADCsHL_REG  == {ir2[9:6],ir2[3:0]} ; // compair with {ir2[9:6],ir2[3:0]}

wire borrow = ED_SBCsHL_REG  == {ir2[9:6],ir2[3:0]};
//  the shifts probably muck with all flags (some operations are 
//  guarenteed not to change certain flags )
//   docs say sf and zf  never change for these ops.
assign upd_fr_sh =
    RLA          == ir2 |//      RLA          ; 17
    RLCA         == ir2 |//      RLCA         ; 07
    RRA          == ir2 |//      RRA          ; 1F
    RRCA         == ir2 ;//      RRCA         ; 0F
// sf and zf do change for theses
assign upd_fr_cbsh = 
    CB_RLC   == ir2[9:3] |  // these must be compaired with ir2[9:3]
    CB_RRC   == ir2[9:3] |  // these must be compaired with ir2[9:3]
    CB_RL    == ir2[9:3] |  // these must be compaired with ir2[9:3]
    CB_RR    == ir2[9:3] |  // these must be compaired with ir2[9:3]
    CB_SLA   == ir2[9:3] |  // these must be compaired with ir2[9:3]
    CB_SRA   == ir2[9:3] |  // these must be compaired with ir2[9:3]
    CB_SLL   == ir2[9:3] |  // these must be compaired with ir2[9:3]
    CB_SRL   == ir2[9:3] ;  // these must be compaired with ir2[9:3]

//  pretty nomal stuff here
//CB_BIT   = 4'b01_01,    // these must be compaired with ir2[9:6]
//  which alu? --  done from alu8  
//ED_NEG         =    5'b01___100, // compair with {ir2[9:6],ir2[2:0]} all A<= -A

// rmw 8 types    these handled by standard INC and DEC logic    done.
//INCs6HL7     = 'h34,//      INC (HL)     ; 34
//DECs6HL7     = 'h35,//      DEC (HL)     ; 35

//  ED Block Move messyness    upd_b_decbc  4/19/2004 not used  - probably not needed
//  hf and nf <= 0   pnf<= BC==0
//assign eb_blk_mv = 
//    ED_LDI       == ir2 | //      LDI        ; ED A0   (DE++) <= (HL++) , BC-- 
//    ED_LDD       == ir2 | //      LDD        ; ED A8   (DE--) <= (HL--) , BC--
//    ED_LDIR      == ir2 | //      LDIR       ; ED B0   (DE++) <= (HL++) , BC-- Repeat til BC==0 
//    ED_LDDR      == ir2  ;//      LDDR       ; ED B8   (DE--) <= (HL--) , BC-- Repeat til BC==0
// only c not affected - nf<=1 ? 
assign ed_blk_cp =
    ED_CPI       == ir2 | //      CPI        ; ED A1    A - (HL++) , BC--
    ED_CPD       == ir2 | //      CPD        ; ED A9    A - (HL--) , BC--
    ED_CPIR      == ir2 | //      CPIR       ; ED B1    A - (HL++) , BC-- repeat if(|B
    ED_CPDR      == ir2  ;//      CPDR       ; ED B9    A - (HL--) , BC-- repeat if(|B

//  all the ed i/o muck with all flags  -- wonderful  cf?
//  use the aluoutput for the b-1 computation.  
// --------- eb_io
//ED_INI       =  'hA2//      INI        ; ED A2   (HL++) <- (Cio) , B--
//ED_IND       =  'hAA//      IND        ; ED AA   (HL--) <- (Cio) , B--
//ED_INIR      =  'hB2//      INIR       ; ED B2   (HL++) <- (Cio) , B-- repeat if(|B)
//ED_INDR      =  'hBA//      INDR       ; ED BA   (HL--) <- (Cio) , B-- repeat if(|B)
//ED_OUTI      =  'hA3//      OUTI       ; ED A3   (Cio)  <-(HL++) , B--
//ED_OUTD      =  'hAB//      OUTD       ; ED AB   (Cio)  <-(HL--) , B--
//ED_OTIR      =  'hB3//      OTIR       ; ED B3   (Cio)  <-(HL++) , B--  rpt if(|B)
//ED_OTDR      =  'hBB//      OTDR       ; ED BB   (Cio)  <-(HL--) , B--  rpt if(|B)

//ED_INsREG_6C7  =    5'b01___000,// compair with {ir2[9:6],ir2[2:0]} really (BCio)



// special problems  --  lol   more special problems ????
//CCF          = 'h3F,//      CCF          ; 3F  // h<=c  c<=~C N<=0  F3,F5?
//CPL          = 'h2F,//      CPL          ; 2F  // H<=1  N<=1  F3,F5?
//DAA          = 'h27,//      DAA          ; 27  // H<=0???  
//SCF          = 'h37,//      SCF          ; 37
//ED_RRD       =  'h67//      RRD        ; ED 67   nibble roates A HL
//ED_RLD       =  'h6F//      RLD        ; ED 6F   nibble roates A HL
//ED_LDsA_I    =  'h57//      LD A,I     ; ED 57   move I to A

assign { sf, zf, f5f, hf, f3f, pvf, nf,  cf} = fr;
//   gotta say those little ~^ operators down there worry me.  Only 4 levels of xor - but jeeze
//   there are a lot of them.  I guess in most FPGA's it doesn't matter what the op is  - just
//   how many terms.   


// do we need the exe_ir2 term here?   isn't it added in the hazard term anyway?
assign upd_fr =  exec_ir2 & ( ( upd_fr_alu8 )                       |
                              ( upd_fr_add16)                       |
                              ( upd_fr_edadd16)                     |
                              ( upd_fr_sh )                         |
                              ( upd_fr_cbsh )                       |
                              (CB_BIT == ir2[9:6])                  |
                              ( ed_blk_cp )                         |
                              (ED_INsREG_6C7 == {ir2[9:6],ir2[2:0]})  |
                              (CCF == ir2 )                         |
                              (CPL == ir2 )                         |
                              (DAA == ir2 )                         |
                              (SCF == ir2 )                         |
                              (ED_RRD == ir2)                       |
                              (ED_RLD == ir2)                       |
                              (ED_LDsA_I == ir2)                    | 
                              (ir2 == EXsAF_AFp )                   |  
                              (ir2 == EXX )                         );



wire iff2 = 1'b0; // this is supposed to be int ff #2  which is not (yet) implmented
wire upd_fr_ed_in =  ED_INsREG_6C7 == {ir2[9:6],ir2[2:0]} ;
wire bc_eq1 = {br,cr} == 16'h1;
always @(posedge clk)
begin
    if (exec_ir2)
    begin
        if ( upd_fr_alu8 )      fr <= alu8_fr;    //  assembled above with 8 bit ALU
        if ( upd_fr_add16)      fr <= {sf, zf, add16[13], c_16out11, add16[11], pvf, 1'b0, c_16out15};
        if ( upd_fr_edadd16)    fr <= {add16[15],   ~|add16, add16[13], c_16out11, 
                                       add16[11], add16_ofl,   ~ir2[3], borrow ^ c_16out15};
        if ( upd_fr_sh )        fr <= {sf, zf, sh_alu[5], 1'b0, sh_alu[3], pvf, 1'b0, sh_cry};
        if ( upd_fr_cbsh )      fr <= {sh_alu[7], ~|sh_alu, sh_alu[5], 1'b0, 
                                       sh_alu[3], ~^sh_alu,      1'b0, sh_cry};
        if (CB_BIT == ir2[9:6]) fr <={bit_alu[7], ~|bit_alu, bit_alu[5], 1'b1, //no idea why hf<=1
                                      bit_alu[3], ~|bit_alu, 1'b0      , cf  };// pvf == zf ??? 
        if ( ed_blk_cp )        fr <= {alu8_out[7], ~|alu8_out, alu8_out[5], alu8_hcry,//std a-n stuff
                                   alu8_out[3], ~bc_eq1,       1'b1,  cf };    //cept nf and cf
        if (upd_fr_ed_in)
                                fr <= {nn[15], ~|nn[15:8], nn[13], 1'b0, nn[11], ~^nn[15:8], 1'b0, cf};
        if (CCF == ir2 )        fr <= {sf, zf, f5f, cf, f3f, pvf, nf, ~cf};
        if (CPL == ir2 )        fr <= {sf, zf, ar[5], 1'b1, ar[3], pvf, 1'b1, cf};
        if (DAA == ir2 )        fr <= {daa_alu[7], ~|daa_alu, daa_alu[5], 1'b0, // hf sb (logically) 0
                                    daa_alu[3], ~^daa_alu,         nf, daa_cry };
        if (SCF == ir2 )        fr <= { sf, zf, ar[5], 1'b0, ar[3], pvf, 1'b0, 1'b1 }; // very strange
        if (ED_RRD == ir2)      fr <= {     ar[7], ~|{ar[7:4],nn[11:8]}, ar[5], 1'b0, 
                                     ar[3],  ~^{ar[7:4],nn[11:8]}, 1'b0 , cf    };
        if (ED_RLD == ir2)      fr <= {     ar[7], ~|{ar[7:4],nn[15:12]}, ar[5], 1'b0, 
                                     ar[3],  ~^{ar[7:4],nn[15:12]}, 1'b0 , cf    };
        if (ED_LDsA_I == ir2)   fr <= { intr[7], ~|intr, intr[5], 1'b0, intr[3], iff2, 1'b0, cf }; // iff2 ?
        if (ir2 == EXsAF_AFp)   fr <= fp;
        if (ir2 == EXX  )       fr <= fp;
        if (ir2 == POPsAF)      fr <= nn[7:0];

    
    end
    // in the case of blk_cp the update above is executed 2nd - and so these are don't cares.
    if (exec_decb )          fr <=  {decb_alu[7], ~|decb_alu, decb_alu[5], hf,
                                     decb_alu[3],        pvf,        1'b0, cf };
    if (exec_decbc )         fr[5:1] <= { decb_alu[5], 1'b0, decb_alu[3],
                                           ((|decb_alu) | (|decc_alu)) , 1'b0 };
end    
    
    
 //----------------------- intr -----------------------------------------------------------
 
always @(posedge clk or posedge rst)
    if (rst) intr <= 8'h0;
    else if (( ED_LDsI_A == ir2) & exec_ir2) intr <= ar;

endmodule
