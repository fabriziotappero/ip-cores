//************************************************************************************************
// 			
// Version 0.5 
// Designed by Ruslan Lepetenok 
// Modified 07.03.2007
//************************************************************************************************

`timescale 1 ns / 1 ns

module ext_dbg_top(
   ireset,
   cp2,
   d_adr,
   d_iore,
   d_iowe,
   d_iowait,
   d_io_dbusout,
   d_io_dbusin,
   d_ramadr,
   d_ramre,
   d_ramwe,
   d_ramwait,
   d_dm_dbusout,
   d_dm_dbusin,
   irqlines,
   bm_ramadr,
   bm_ramre,
   bm_ramdata,
   trst_n,
   tck,
   tdi,
   tap_sm_st,
   ir,
   tdo_ext,
   tlr_st
);
   parameter               num_of_irqs = 23;		// 23 - Mega103 / 33 - Mega 128 
   parameter               ir_len = 4;
   parameter               impl_chain_c = 0;
   parameter               chain_c_len = 6;
   input                   ireset;
   input                   cp2;
   // I/O
   output [5:0]            d_adr;
   output                  d_iore;
   output                  d_iowe;
   input                   d_iowait;
   output [7:0]            d_io_dbusout;
   input [7:0]             d_io_dbusin;
   // RAM
   output [15:0]           d_ramadr;
   output                  d_ramre;
   output                  d_ramwe;
   input                   d_ramwait;
   output [7:0]            d_dm_dbusout;
   input [7:0]             d_dm_dbusin;
   // IRQ
   input [num_of_irqs-1:0] irqlines;
   // Bus monitor(optional)
   output [15:0]           bm_ramadr;
   output                  bm_ramre;
   input [7:0]             bm_ramdata;
   // JTAG i/f 
   input                   trst_n;
   input                   tck;
   input                   tdi;
   // OCD/Flash programmer i/f                               
   input                   tap_sm_st;
   input [ir_len-1:0]      ir;
   output                  tdo_ext;
   input                   tlr_st;
   
   wire                    upd_ac_cp2;
   wire                    upd_d_cp2;
   wire                    tlr_st_cp2;
   
   wire                    chain_ac_ud_tck;
   wire                    chain_d_ud_tck;
   wire                    chain_c_ud_tck;
   
   wire [18:0]             chain_ac_o;
   wire [8:0]              chain_d_o;
   wire [chain_c_len-1:0]  chain_c_o;
   wire [18:0]             chain_ac_i;
   wire [8:0]              chain_d_i;
   wire [chain_c_len-1:0]  chain_c_i;
   
   		// 23 - Mega103 / 33 - Mega 128 
   ext_dbg_mod #(.num_of_irqs(num_of_irqs)) ext_dbg_mod_inst(
      .ireset(ireset),
      .cp2(cp2),
      // I/O
      .d_adr(d_adr),
      .d_iore(d_iore),
      .d_iowe(d_iowe),
      .d_iowait(d_iowait),
      .d_io_dbusout(d_io_dbusout),
      .d_io_dbusin(d_io_dbusin),
      // RAM
      .d_ramadr(d_ramadr),
      .d_ramre(d_ramre),
      .d_ramwe(d_ramwe),
      .d_ramwait(d_ramwait),
      .d_dm_dbusout(d_dm_dbusout),
      .d_dm_dbusin(d_dm_dbusin),
      // IRQ
      .irqlines(irqlines),
      // Bus monitor(optional)
      .bm_ramadr(bm_ramadr),
      .bm_ramre(bm_ramre),
      .bm_ramdata(bm_ramdata),
      // JTAG module i/f !!!TBD!!!
      .j_chain_ac_in(chain_ac_o),
      .j_chain_d_in(chain_d_o),
      .j_chain_ac_out(chain_ac_i),
      .j_chain_d_out(chain_d_i),
      .j_upd_ac(upd_ac_cp2),
      .j_upd_d(upd_d_cp2),
      .tlr_st(tlr_st_cp2)
   );
   
   
   ext_chains #(.impl_chain_c(impl_chain_c), .chain_c_len(chain_c_len), .ir_len(4)) ext_chains_inst(
      .trst_n(trst_n),
      .tck(tck),
      .tdi(tdi),
      // OCD/Flash programmer i/f
      .tap_sm_st(tap_sm_st),
      .ir(ir),
      .tdo_ext(tdo_ext),
      // Chain i/f
      .chain_ac_o(chain_ac_o),
      .chain_d_o(chain_d_o),
      .chain_c_o(chain_c_o),
      .chain_ac_i(chain_ac_i),
      .chain_d_i(chain_d_i),
      .chain_c_i(chain_c_i),
      .chain_ac_ud(chain_ac_ud_tck),
      .chain_d_ud(chain_d_ud_tck),
      .chain_c_ud(chain_c_ud_tck)
   );
   
   assign chain_c_i = {chain_c_len{1'b0}};
   
   // ******************** Resynchronizers ************************************
   
   
   rsnc_bit #(.add_stgs_num(0), .inv_f_stgs(0)) rsnc_ac_upd_st_inst(
      .clk(cp2),
      .di(chain_ac_ud_tck),
      .do(upd_ac_cp2)
   );
   
   
   rsnc_bit #(.add_stgs_num(0), .inv_f_stgs(0)) rsnc_chain_d_ud_inst(
      .clk(cp2),
      .di(chain_d_ud_tck),
      .do(upd_d_cp2)
   );
   
   
   rsnc_bit #(.add_stgs_num(0), .inv_f_stgs(0)) rsnc_tlr_st_inst(
      .clk(cp2),
      .di(tlr_st),
      .do(tlr_st_cp2)
   );
   
endmodule

// ******************** Resynchronizers ************************************
