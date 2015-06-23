// Empty module for cacheless Simply RISC S1 Core

module bw_r_dcd (
   // Outputs
   so, dcache_rdata_wb, dcache_rparity_wb, dcache_rparity_err_wb, 
   dcache_rdata_msb_w0_m, dcache_rdata_msb_w1_m, 
   dcache_rdata_msb_w2_m, dcache_rdata_msb_w3_m, 
   dcd_fuse_repair_value, dcd_fuse_repair_en, 
   // Inputs
   dcache_rd_addr_e, dcache_alt_addr_e, dcache_rvld_e, dcache_wvld_e, 
   dcache_wdata_e, dcache_wr_rway_e, dcache_byte_wr_en_e, 
   dcache_alt_rsel_way_e, dcache_rsel_way_wb, dcache_alt_mx_sel_e, 
   si, se, sehold, rst_tri_en, arst_l, rclk, dcache_alt_data_w0_m, 
   dcache_arry_data_sel_m, efc_spc_fuse_clk1, fuse_dcd_wren, 
   fuse_dcd_rid, fuse_dcd_repair_value, fuse_dcd_repair_en
   ) ;  

input [10:3]    dcache_rd_addr_e;     // read cache index [10:4] + bit [3] offset
input [10:3]    dcache_alt_addr_e;    // write/bist/diagnostic read cache index + offset 

input           dcache_rvld_e;        // read accesses d$.
input           dcache_wvld_e;        // valid write setup to m-stage.
   
input [143:0]   dcache_wdata_e;       // write data - 16Bx8 + 8b parity.
input [3:0]     dcache_wr_rway_e;     // replacement way for load miss/store.
input [15:0]    dcache_byte_wr_en_e;  // 16b byte wr enable for stores.

input [3:0]     dcache_alt_rsel_way_e ; // bist/diagnostic read way select
input [3:0]     dcache_rsel_way_wb;     // load way select, connect to cache_way_hit
input           dcache_alt_mx_sel_e;
       
input           si;
input           se;
input           sehold;
   
output          so;

input		rst_tri_en ;		

input           arst_l;	// used for redundancy flops - do not reset on wrm reset.

input           rclk;

output  [63:0]  dcache_rdata_wb;
output  [7:0]   dcache_rparity_wb;
output          dcache_rparity_err_wb; 

   input [63:0] dcache_alt_data_w0_m; //from qdp1
   input        dcache_arry_data_sel_m;            //from dctl
   
   output [7:0] dcache_rdata_msb_w0_m;    //to dcdp
   output [7:0] dcache_rdata_msb_w1_m;    //to dcdp
   output [7:0] dcache_rdata_msb_w2_m;    //to dcdp
   output [7:0] dcache_rdata_msb_w3_m;    //to dcdp

input           efc_spc_fuse_clk1;
   
input           fuse_dcd_wren;          //redundancy register write enable, qualified
input [2:0]     fuse_dcd_rid;           //redundancy register id
input [7:0]     fuse_dcd_repair_value;  //data in for redundancy register
input [1:0]	    fuse_dcd_repair_en;     //enable bits to turn on redundancy
output [7:0]    dcd_fuse_repair_value;  //data out for redundancy register
output [1:0]	  dcd_fuse_repair_en;     //enable bits out 
   
   
endmodule


