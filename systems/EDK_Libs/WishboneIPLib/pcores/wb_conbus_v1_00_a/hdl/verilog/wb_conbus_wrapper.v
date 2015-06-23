



module wb_conbus_wrapper(

  wb_clk_i,
  wb_rst_i,

  wb_m_dat_i, 
  wb_m_dat_o, 
  wb_m_adr_i, 
  wb_m_sel_i, 
  wb_m_we_i, 
  wb_m_cyc_i,
  wb_m_stb_i, 
  wb_m_ack_o, 
  wb_m_err_o, 
  wb_m_rty_o, 
  wb_m_cab_i,

  wb_s_dat_i, 
  wb_s_dat_o, 
  wb_s_adr_o, 
  wb_s_sel_o, 
  wb_s_we_o, 
  wb_s_cyc_o,
  wb_s_stb_o, 
  wb_s_ack_i, 
  wb_s_err_i, 
  wb_s_rty_i, 
  wb_s_cab_o


);



//////  MUST BE CONSTANT:  DON'T CHANGE THIS!! ///
parameter      WB_DAT_W       = 32;    // Data bus Width
parameter      WB_ADR_W       = 32;    // Address bus Width
parameter      wb_num_masters = 8;     // number of masters
parameter      wb_num_slaves  = 8;     // number of slavers
/////////
parameter      wb_s0_addr_w   = 4 ;    // slave 0 address decode width
parameter      wb_s0_addr     = 4'h0;  // slave 0 address
parameter      wb_s1_addr_w   = 4 ;    // slave 1 address decode width
parameter      wb_s1_addr     = 4'h1;  // slave 1 address 
parameter      wb_s27_addr_w  = 8 ;    // slave 2 to slave 7 address decode width
parameter      wb_s2_addr     = 8'h92; // slave 2 address
parameter      wb_s3_addr     = 8'h93; // slave 3 address
parameter      wb_s4_addr     = 8'h94; // slave 4 address
parameter      wb_s5_addr     = 8'h95; // slave 5 address
parameter      wb_s6_addr     = 8'h96; // slave 6 address
parameter      wb_s7_addr     = 8'h97; // slave 7 address



input                                             wb_clk_i;
input                                             wb_rst_i;
input    [(WB_DAT_W*wb_num_masters)-1     : 0 ]   wb_m_dat_i; 
output   [WB_DAT_W-1                      : 0 ]   wb_m_dat_o;
input    [(WB_ADR_W*wb_num_masters)-1     : 0 ]   wb_m_adr_i; 
input    [(WB_DAT_W/8*wb_num_masters)-1   : 0 ]   wb_m_sel_i; 
input    [wb_num_masters-1                : 0 ]   wb_m_we_i;
input    [wb_num_masters-1                : 0 ]   wb_m_cyc_i;
input    [wb_num_masters-1                : 0 ]   wb_m_stb_i; 
output   [wb_num_masters-1                : 0 ]   wb_m_ack_o; 
output   [wb_num_masters-1                : 0 ]   wb_m_err_o; 
output   [wb_num_masters-1                : 0 ]   wb_m_rty_o; 
input    [wb_num_masters-1                : 0 ]   wb_m_cab_i;
   
input    [WB_DAT_W*wb_num_slaves-1        : 0 ]   wb_s_dat_i; 
output   [WB_DAT_W-1                      : 0 ]   wb_s_dat_o; 
output   [WB_ADR_W-1                      : 0 ]   wb_s_adr_o; 
output   [WB_DAT_W/8-1                    : 0 ]   wb_s_sel_o; 
output                                            wb_s_we_o;
output                                            wb_s_cyc_o;
output   [wb_num_slaves-1                 : 0 ]   wb_s_stb_o; 
input    [wb_num_slaves-1                 : 0 ]   wb_s_ack_i; 
input    [wb_num_slaves-1                 : 0 ]   wb_s_err_i; 
input    [wb_num_slaves-1                 : 0 ]   wb_s_rty_i; 
output                                            wb_s_cab_o;







wb_conbus_top #(
   .s0_addr_w  ( wb_s0_addr_w  ),
   .s0_addr    ( wb_s0_addr    ),
   .s1_addr_w  ( wb_s1_addr_w  ),
   .s1_addr    ( wb_s1_addr    ),
   .s27_addr_w ( wb_s27_addr_w ),
   .s2_addr    ( wb_s2_addr    ),
   .s3_addr    ( wb_s3_addr    ),
   .s4_addr    ( wb_s4_addr    ),
   .s5_addr    ( wb_s5_addr    ),
   .s6_addr    ( wb_s6_addr    ),
   .s7_addr    ( wb_s7_addr    )
   )
wb_conbus_top(

   .clk_i( wb_clk_i ), 
   .rst_i( wb_rst_i ),

   // Master 0 Interface
   .m0_dat_i( wb_m_dat_i[ (0+1)*WB_DAT_W-1   : 0*WB_DAT_W ]    ), 
   .m0_dat_o( wb_m_dat_o ),
   .m0_adr_i( wb_m_adr_i[ (0+1)*WB_ADR_W-1   : 0*WB_ADR_W ]    ), 
   .m0_sel_i( wb_m_sel_i[ (0+1)*WB_DAT_W/8-1 : 0*WB_DAT_W/8] ), 
   .m0_we_i ( wb_m_we_i[0]  ), 
   .m0_cyc_i( wb_m_cyc_i[0] ),
   .m0_stb_i( wb_m_stb_i[0] ), 
   .m0_ack_o( wb_m_ack_o[0] ), 
   .m0_err_o( wb_m_err_o[0] ), 
   .m0_rty_o( wb_m_rty_o[0] ), 
   .m0_cab_i( wb_m_cab_i[0] ),


   // Master 1 Interface
   .m1_dat_i( wb_m_dat_i[ (1+1)*WB_DAT_W-1   : 1*WB_DAT_W ]    ), 
   .m1_dat_o( ),
   .m1_adr_i( wb_m_adr_i[ (1+1)*WB_ADR_W-1   : 1*WB_ADR_W ]    ), 
   .m1_sel_i( wb_m_sel_i[ (1+1)*WB_DAT_W/8-1 : 1*WB_DAT_W/8] ), 
   .m1_we_i (  wb_m_we_i[1] ), 
   .m1_cyc_i( wb_m_cyc_i[1] ),
   .m1_stb_i( wb_m_stb_i[1] ), 
   .m1_ack_o( wb_m_ack_o[1] ), 
   .m1_err_o( wb_m_err_o[1] ), 
   .m1_rty_o( wb_m_rty_o[1] ), 
   .m1_cab_i( wb_m_cab_i[1] ),


   // Master 2 Interface
   .m2_dat_i( wb_m_dat_i[ (2+1)*WB_DAT_W-1   : 2*WB_DAT_W ]    ), 
   .m2_dat_o( ),
   .m2_adr_i( wb_m_adr_i[ (2+1)*WB_ADR_W-1   : 2*WB_ADR_W ]    ), 
   .m2_sel_i( wb_m_sel_i[ (2+1)*WB_DAT_W/8-1 : 2*WB_DAT_W/8] ), 
   .m2_we_i (  wb_m_we_i[2] ), 
   .m2_cyc_i( wb_m_cyc_i[2] ),
   .m2_stb_i( wb_m_stb_i[2] ), 
   .m2_ack_o( wb_m_ack_o[2] ), 
   .m2_err_o( wb_m_err_o[2] ), 
   .m2_rty_o( wb_m_rty_o[2] ), 
   .m2_cab_i( wb_m_cab_i[2] ),


   // Master 3 Interface
   .m3_dat_i( wb_m_dat_i[ (3+1)*WB_DAT_W-1   : 3*WB_DAT_W ]    ), 
   .m3_dat_o( ),
   .m3_adr_i( wb_m_adr_i[ (3+1)*WB_ADR_W-1   : 3*WB_ADR_W ]    ), 
   .m3_sel_i( wb_m_sel_i[ (3+1)*WB_DAT_W/8-1 : 3*WB_DAT_W/8] ), 
   .m3_we_i (  wb_m_we_i[3] ), 
   .m3_cyc_i( wb_m_cyc_i[3] ),
   .m3_stb_i( wb_m_stb_i[3] ), 
   .m3_ack_o( wb_m_ack_o[3] ), 
   .m3_err_o( wb_m_err_o[3] ), 
   .m3_rty_o( wb_m_rty_o[3] ), 
   .m3_cab_i( wb_m_cab_i[3] ),


   // Master 4 Interface
   .m4_dat_i( wb_m_dat_i[ (4+1)*WB_DAT_W-1   : 4*WB_DAT_W ]    ), 
   .m4_dat_o( ),
   .m4_adr_i( wb_m_adr_i[ (4+1)*WB_ADR_W-1   : 4*WB_ADR_W ]    ), 
   .m4_sel_i( wb_m_sel_i[ (4+1)*WB_DAT_W/8-1 : 4*WB_DAT_W/8] ), 
   .m4_we_i (  wb_m_we_i[4] ), 
   .m4_cyc_i( wb_m_cyc_i[4] ),
   .m4_stb_i( wb_m_stb_i[4] ), 
   .m4_ack_o( wb_m_ack_o[4] ), 
   .m4_err_o( wb_m_err_o[4] ), 
   .m4_rty_o( wb_m_rty_o[4] ), 
   .m4_cab_i( wb_m_cab_i[4] ),


   // Master 5 Interface
   .m5_dat_i( wb_m_dat_i[ (5+1)*WB_DAT_W-1   : 5*WB_DAT_W ]    ), 
   .m5_dat_o( ),
   .m5_adr_i( wb_m_adr_i[ (5+1)*WB_ADR_W-1   : 5*WB_ADR_W ]    ), 
   .m5_sel_i( wb_m_sel_i[ (5+1)*WB_DAT_W/8-1 : 5*WB_DAT_W/8] ), 
   .m5_we_i (  wb_m_we_i[5] ), 
   .m5_cyc_i( wb_m_cyc_i[5] ),
   .m5_stb_i( wb_m_stb_i[5] ), 
   .m5_ack_o( wb_m_ack_o[5] ), 
   .m5_err_o( wb_m_err_o[5] ), 
   .m5_rty_o( wb_m_rty_o[5] ), 
   .m5_cab_i( wb_m_cab_i[5] ),


   // Master 6 Interface
   .m6_dat_i( wb_m_dat_i[ (6+1)*WB_DAT_W-1   : 6*WB_DAT_W ]    ), 
   .m6_dat_o( ),
   .m6_adr_i( wb_m_adr_i[ (6+1)*WB_ADR_W-1   : 6*WB_ADR_W ]    ), 
   .m6_sel_i( wb_m_sel_i[ (6+1)*WB_DAT_W/8-1 : 6*WB_DAT_W/8] ), 
   .m6_we_i (  wb_m_we_i[6] ), 
   .m6_cyc_i( wb_m_cyc_i[6] ),
   .m6_stb_i( wb_m_stb_i[6] ), 
   .m6_ack_o( wb_m_ack_o[6] ), 
   .m6_err_o( wb_m_err_o[6] ), 
   .m6_rty_o( wb_m_rty_o[6] ), 
   .m6_cab_i( wb_m_cab_i[6] ),


   // Master 7 Interface
   .m7_dat_i( wb_m_dat_i[ (7+1)*WB_DAT_W-1   : 7*WB_DAT_W ]    ), 
   .m7_dat_o( ),
   .m7_adr_i( wb_m_adr_i[ (7+1)*WB_ADR_W-1   : 7*WB_ADR_W ]    ), 
   .m7_sel_i( wb_m_sel_i[ (7+1)*WB_DAT_W/8-1 : 7*WB_DAT_W/8] ), 
   .m7_we_i (  wb_m_we_i[7] ), 
   .m7_cyc_i( wb_m_cyc_i[7] ),
   .m7_stb_i( wb_m_stb_i[7] ), 
   .m7_ack_o( wb_m_ack_o[7] ), 
   .m7_err_o( wb_m_err_o[7] ), 
   .m7_rty_o( wb_m_rty_o[7] ), 
   .m7_cab_i( wb_m_cab_i[7] ),



   // Slave 0 Interface
   .s0_dat_i( wb_s_dat_i[ (0+1)*WB_DAT_W-1 : 0*WB_DAT_W ] ), 
   .s0_dat_o( wb_s_dat_o ), 
   .s0_adr_o( wb_s_adr_o ),
   .s0_sel_o( wb_s_sel_o ),
   .s0_we_o ( wb_s_we_o  ),
   .s0_cyc_o( wb_s_cyc_o ),
   .s0_stb_o( wb_s_stb_o[0] ),
   .s0_ack_i( wb_s_ack_i[0] ),
   .s0_err_i( wb_s_err_i[0] ),
   .s0_rty_i( wb_s_rty_i[0] ),
   .s0_cab_o( wb_s_cab_o ),

   // Slave 1 Interface
   .s1_dat_i( wb_s_dat_i[ (1+1)*WB_DAT_W-1 : 1*WB_DAT_W ] ), 
   .s1_dat_o(  ), 
   .s1_adr_o(  ),
   .s1_sel_o(  ),
   .s1_we_o (  ),
   .s1_cyc_o(  ),
   .s1_stb_o( wb_s_stb_o[1] ),
   .s1_ack_i( wb_s_ack_i[1] ),
   .s1_err_i( wb_s_err_i[1] ),
   .s1_rty_i( wb_s_rty_i[1] ),
   .s1_cab_o( ),

   // Slave 2 Interface
   .s2_dat_i( wb_s_dat_i[ (2+1)*WB_DAT_W-1 : 2*WB_DAT_W ] ), 
   .s2_dat_o(  ), 
   .s2_adr_o(  ),
   .s2_sel_o(  ),
   .s2_we_o (  ),
   .s2_cyc_o(  ),
   .s2_stb_o( wb_s_stb_o[2] ),
   .s2_ack_i( wb_s_ack_i[2] ),
   .s2_err_i( wb_s_err_i[2] ),
   .s2_rty_i( wb_s_rty_i[2] ),
   .s2_cab_o( ),

   // Slave 3 Interface
   .s3_dat_i( wb_s_dat_i[ (3+1)*WB_DAT_W-1 : 3*WB_DAT_W ] ), 
   .s3_dat_o(  ), 
   .s3_adr_o(  ),
   .s3_sel_o(  ),
   .s3_we_o (  ),
   .s3_cyc_o(  ),
   .s3_stb_o( wb_s_stb_o[3] ),
   .s3_ack_i( wb_s_ack_i[3] ),
   .s3_err_i( wb_s_err_i[3] ),
   .s3_rty_i( wb_s_rty_i[3] ),
   .s3_cab_o( ),

   // Slave 4 Interface
   .s4_dat_i( wb_s_dat_i[ (4+1)*WB_DAT_W-1 : 4*WB_DAT_W ] ), 
   .s4_dat_o(  ), 
   .s4_adr_o(  ),
   .s4_sel_o(  ),
   .s4_we_o (  ),
   .s4_cyc_o(  ),
   .s4_stb_o( wb_s_stb_o[4] ),
   .s4_ack_i( wb_s_ack_i[4] ),
   .s4_err_i( wb_s_err_i[4] ),
   .s4_rty_i( wb_s_rty_i[4] ),
   .s4_cab_o( ),

   // Slave 5 Interface
   .s5_dat_i( wb_s_dat_i[ (5+1)*WB_DAT_W-1 : 5*WB_DAT_W ] ), 
   .s5_dat_o(  ), 
   .s5_adr_o(  ),
   .s5_sel_o(  ),
   .s5_we_o (  ),
   .s5_cyc_o(  ),
   .s5_stb_o( wb_s_stb_o[5] ),
   .s5_ack_i( wb_s_ack_i[5] ),
   .s5_err_i( wb_s_err_i[5] ),
   .s5_rty_i( wb_s_rty_i[5] ),
   .s5_cab_o( ),

   // Slave 6 Interface
   .s6_dat_i( wb_s_dat_i[ (6+1)*WB_DAT_W-1 : 6*WB_DAT_W ] ), 
   .s6_dat_o(  ), 
   .s6_adr_o(  ),
   .s6_sel_o(  ),
   .s6_we_o (  ),
   .s6_cyc_o(  ),
   .s6_stb_o( wb_s_stb_o[6] ),
   .s6_ack_i( wb_s_ack_i[6] ),
   .s6_err_i( wb_s_err_i[6] ),
   .s6_rty_i( wb_s_rty_i[6] ),
   .s6_cab_o( ),

   // Slave 7 Interface
   .s7_dat_i( wb_s_dat_i[ (7+1)*WB_DAT_W-1 : 7*WB_DAT_W ] ), 
   .s7_dat_o(  ), 
   .s7_adr_o(  ),
   .s7_sel_o(  ),
   .s7_we_o (  ),
   .s7_cyc_o(  ),
   .s7_stb_o( wb_s_stb_o[7] ),
   .s7_ack_i( wb_s_ack_i[7] ),
   .s7_err_i( wb_s_err_i[7] ),
   .s7_rty_i( wb_s_rty_i[7] ),
   .s7_cab_o( )

);




endmodule
