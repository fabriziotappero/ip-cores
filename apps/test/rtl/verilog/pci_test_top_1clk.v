module pci_test_top
(
    pci_clk_pad_i,
    pci_rst_pad_i,

    pci_req_pad_o,
    pci_gnt_pad_i,
    pci_idsel_pad_i,

    pci_ad0_pad_io,
    pci_ad1_pad_io,
    pci_ad2_pad_io,
    pci_ad3_pad_io,
    pci_ad4_pad_io,
    pci_ad5_pad_io,
    pci_ad6_pad_io,
    pci_ad7_pad_io,
    pci_ad8_pad_io,
    pci_ad9_pad_io,
    pci_ad10_pad_io,
    pci_ad11_pad_io,
    pci_ad12_pad_io,
    pci_ad13_pad_io,
    pci_ad14_pad_io,
    pci_ad15_pad_io,
    pci_ad16_pad_io,
    pci_ad17_pad_io,
    pci_ad18_pad_io,
    pci_ad19_pad_io,
    pci_ad20_pad_io,
    pci_ad21_pad_io,
    pci_ad22_pad_io,
    pci_ad23_pad_io,
    pci_ad24_pad_io,
    pci_ad25_pad_io,
    pci_ad26_pad_io,
    pci_ad27_pad_io,
    pci_ad28_pad_io,
    pci_ad29_pad_io,
    pci_ad30_pad_io,
    pci_ad31_pad_io,

    pci_cbe0_pad_io,
    pci_cbe1_pad_io,
    pci_cbe2_pad_io,
    pci_cbe3_pad_io,

    pci_frame_pad_io,
    pci_irdy_pad_io,
    pci_devsel_pad_io,
    pci_trdy_pad_io,        
    pci_stop_pad_io,
    pci_par_pad_io,
    pci_perr_pad_io,
    pci_serr_pad_o
);

// input/output inout declarations
input pci_clk_pad_i,
      pci_rst_pad_i ;

output pci_req_pad_o, pci_serr_pad_o ;
input  pci_gnt_pad_i, 
       pci_idsel_pad_i ;

inout        pci_frame_pad_io,
             pci_irdy_pad_io,
             pci_devsel_pad_io,
             pci_trdy_pad_io,
             pci_stop_pad_io,
             pci_par_pad_io,
             pci_perr_pad_io,
             pci_ad0_pad_io,
             pci_ad1_pad_io,
             pci_ad2_pad_io,
             pci_ad3_pad_io,
             pci_ad4_pad_io,
             pci_ad5_pad_io,
             pci_ad6_pad_io,
             pci_ad7_pad_io,
             pci_ad8_pad_io,
             pci_ad9_pad_io,
             pci_ad10_pad_io,
             pci_ad11_pad_io,
             pci_ad12_pad_io,
             pci_ad13_pad_io,
             pci_ad14_pad_io,
             pci_ad15_pad_io,
             pci_ad16_pad_io,
             pci_ad17_pad_io,
             pci_ad18_pad_io,
             pci_ad19_pad_io,
             pci_ad20_pad_io,
             pci_ad21_pad_io,
             pci_ad22_pad_io,
             pci_ad23_pad_io,
             pci_ad24_pad_io,
             pci_ad25_pad_io,
             pci_ad26_pad_io,
             pci_ad27_pad_io,
             pci_ad28_pad_io,
             pci_ad29_pad_io,
             pci_ad30_pad_io,
             pci_ad31_pad_io,
             pci_cbe0_pad_io,
             pci_cbe1_pad_io,
             pci_cbe2_pad_io,
             pci_cbe3_pad_io ;

// wires for test master to pci slave connections
wire wbm_test_wbs_pci_cyc,
     wbm_test_wbs_pci_stb,
     wbm_test_wbs_pci_cab,
     wbm_test_wbs_pci_we,
     wbs_pci_wbm_test_ack ;

wire [31:0] wbm_test_wbs_pci_adr,
            wbm_test_wbs_pci_dat,
            wbs_pci_wbm_test_dat ;

wire [3:0]  wbm_test_wbs_pci_sel ;

// wires for test slave to pci master connections
wire wbm_pci_wbs_test_cyc,
     wbm_pci_wbs_test_stb,
     wbm_pci_wbs_test_cab,
     wbm_pci_wbs_test_we,
     wbs_test_wbm_pci_ack ;

wire [31:0] wbm_pci_wbs_test_adr,
            wbm_pci_wbs_test_dat,
            wbs_test_wbm_pci_dat ;

wire [3:0]  wbm_pci_wbs_test_sel ;

wire wb_rst ;

wire wb_clk = pci_clk_pad_i;

// prevent concurent accesses through pci bridge master and slave interfaces
reg test_wbs_cyc ;
reg pci_wbs_cyc ;

always@(posedge wb_clk or posedge wb_rst)
begin
    if (wb_rst)
    begin
        test_wbs_cyc <= 1'b0 ;
        pci_wbs_cyc  <= 1'b0 ;
    end
    else
    begin
        if (~pci_wbs_cyc & ~test_wbs_cyc)
        begin
            // currently no cyc signal is asserted - the pci bridge wb master will have the priority here, so check if it has cycle asserted!
            if (wbm_pci_wbs_test_cyc)
                test_wbs_cyc <= 1'b1 ;
            else // no cycle is asserted and pci wb master is not starting the transaction - test wb master can start
                pci_wbs_cyc <= wbm_test_wbs_pci_cyc ;
        end
        else
        begin
            // at least one of the cycles is asserted - wait for transaction to finish
            if (test_wbs_cyc)
                test_wbs_cyc <= wbm_pci_wbs_test_cyc ;

            if (pci_wbs_cyc)
                pci_wbs_cyc <= wbm_test_wbs_pci_cyc ;
        end
    end
end

reg pci_irdy_reg,
    pci_irdy_en_reg ;

wire pci_trdy_reg = i_pci_bridge32.input_register.pci_trdy_reg_out ;

always@(posedge pci_clk_pad_i or negedge pci_rst_pad_i)
begin
    if (~pci_rst_pad_i)
    begin
        pci_irdy_reg    <= 1'b1 ;
        pci_irdy_en_reg <= 1'b0 ;
    end
    else
        pci_irdy_reg    <= i_pci_bridge32.output_backup.irdy_out    ;
        pci_irdy_en_reg <= i_pci_bridge32.output_backup.irdy_en_out ;
    end
end

test i_test
(
    .clk_i     (wb_clk),
    .rst_i     (wb_rst),

    .wbm_cyc_o (wbm_test_wbs_pci_cyc),
    .wbm_stb_o (wbm_test_wbs_pci_stb),
    .wbm_cab_o (wbm_test_wbs_pci_cab),
    .wbm_we_o  (wbm_test_wbs_pci_we),
    .wbm_adr_o (wbm_test_wbs_pci_adr),
    .wbm_sel_o (wbm_test_wbs_pci_sel),
    .wbm_dat_o (wbm_test_wbs_pci_dat),
    .wbm_dat_i (wbs_pci_wbm_test_dat),
    .wbm_ack_i (wbs_pci_wbm_test_ack),
    .wbm_rty_i (1'b0),
    .wbm_err_i (1'b0),

    .wbs_cyc_i (test_wbs_cyc),
    .wbs_stb_i (wbm_pci_wbs_test_stb),
    .wbs_cab_i (wbm_pci_wbs_test_cab),
    .wbs_we_i  (wbm_pci_wbs_test_we),
    .wbs_adr_i (wbm_pci_wbs_test_adr),
    .wbs_sel_i (wbm_pci_wbs_test_sel),
    .wbs_dat_i (wbm_pci_wbs_test_dat),
    .wbs_dat_o (wbs_test_wbm_pci_dat),
    .wbs_ack_o (wbs_test_wbm_pci_ack),
    .wbs_rty_o (),
    .wbs_err_o (),

    .pci_irdy_reg_i    (pci_irdy_reg),
    .pci_irdy_en_reg_i (pci_irdy_en_reg),
    .pci_trdy_reg_i    (pci_trdy_reg)
);

wire pci_req_o,
     pci_req_oe,
     pci_frame_i,
     pci_frame_o,
     pci_frame_oe,
     pci_irdy_oe,
     pci_devsel_oe,
     pci_trdy_oe,
     pci_stop_oe,
     pci_irdy_i,
     pci_irdy_o,
     pci_devsel_i,
     pci_devsel_o,
     pci_trdy_i,
     pci_trdy_o,
     pci_stop_i,
     pci_stop_o,
     pci_par_i,
     pci_par_o,
     pci_par_oe,
     pci_perr_i,
     pci_perr_o,
     pci_perr_oe,
     pci_serr_o,
     pci_serr_oe
;

wire [31:0] pci_ad_oe,
            pci_ad_i,
            pci_ad_o ;

wire [3:0]  pci_cbe_oe,
            pci_cbe_i,
            pci_cbe_o ;
     
bufif0 ad_buffer00  (pci_ad0_pad_io ,  pci_ad_o[0] ,  pci_ad_oe[0] ) ;
bufif0 ad_buffer01  (pci_ad1_pad_io ,  pci_ad_o[1] ,  pci_ad_oe[1] ) ;
bufif0 ad_buffer02  (pci_ad2_pad_io ,  pci_ad_o[2] ,  pci_ad_oe[2] ) ;
bufif0 ad_buffer03  (pci_ad3_pad_io ,  pci_ad_o[3] ,  pci_ad_oe[3] ) ;
bufif0 ad_buffer04  (pci_ad4_pad_io ,  pci_ad_o[4] ,  pci_ad_oe[4] ) ;
bufif0 ad_buffer05  (pci_ad5_pad_io ,  pci_ad_o[5] ,  pci_ad_oe[5] ) ;
bufif0 ad_buffer06  (pci_ad6_pad_io ,  pci_ad_o[6] ,  pci_ad_oe[6] ) ;
bufif0 ad_buffer07  (pci_ad7_pad_io ,  pci_ad_o[7] ,  pci_ad_oe[7] ) ;
bufif0 ad_buffer08  (pci_ad8_pad_io ,  pci_ad_o[8] ,  pci_ad_oe[8] ) ;
bufif0 ad_buffer09  (pci_ad9_pad_io ,  pci_ad_o[9] ,  pci_ad_oe[9] ) ;
bufif0 ad_buffer10  (pci_ad10_pad_io,  pci_ad_o[10],  pci_ad_oe[10]) ;
bufif0 ad_buffer11  (pci_ad11_pad_io,  pci_ad_o[11],  pci_ad_oe[11]) ;
bufif0 ad_buffer12  (pci_ad12_pad_io,  pci_ad_o[12],  pci_ad_oe[12]) ;
bufif0 ad_buffer13  (pci_ad13_pad_io,  pci_ad_o[13],  pci_ad_oe[13]) ;
bufif0 ad_buffer14  (pci_ad14_pad_io,  pci_ad_o[14],  pci_ad_oe[14]) ;
bufif0 ad_buffer15  (pci_ad15_pad_io,  pci_ad_o[15],  pci_ad_oe[15]) ;
bufif0 ad_buffer16  (pci_ad16_pad_io,  pci_ad_o[16],  pci_ad_oe[16]) ;
bufif0 ad_buffer17  (pci_ad17_pad_io,  pci_ad_o[17],  pci_ad_oe[17]) ;
bufif0 ad_buffer18  (pci_ad18_pad_io,  pci_ad_o[18],  pci_ad_oe[18]) ;
bufif0 ad_buffer19  (pci_ad19_pad_io,  pci_ad_o[19],  pci_ad_oe[19]) ;
bufif0 ad_buffer20  (pci_ad20_pad_io,  pci_ad_o[20],  pci_ad_oe[20]) ;
bufif0 ad_buffer21  (pci_ad21_pad_io,  pci_ad_o[21],  pci_ad_oe[21]) ;
bufif0 ad_buffer22  (pci_ad22_pad_io,  pci_ad_o[22],  pci_ad_oe[22]) ;
bufif0 ad_buffer23  (pci_ad23_pad_io,  pci_ad_o[23],  pci_ad_oe[23]) ;
bufif0 ad_buffer24  (pci_ad24_pad_io,  pci_ad_o[24],  pci_ad_oe[24]) ;
bufif0 ad_buffer25  (pci_ad25_pad_io,  pci_ad_o[25],  pci_ad_oe[25]) ;
bufif0 ad_buffer26  (pci_ad26_pad_io,  pci_ad_o[26],  pci_ad_oe[26]) ;
bufif0 ad_buffer27  (pci_ad27_pad_io,  pci_ad_o[27],  pci_ad_oe[27]) ;
bufif0 ad_buffer28  (pci_ad28_pad_io,  pci_ad_o[28],  pci_ad_oe[28]) ;
bufif0 ad_buffer29  (pci_ad29_pad_io,  pci_ad_o[29],  pci_ad_oe[29]) ;
bufif0 ad_buffer30  (pci_ad30_pad_io,  pci_ad_o[30],  pci_ad_oe[30]) ;
bufif0 ad_buffer31  (pci_ad31_pad_io,  pci_ad_o[31],  pci_ad_oe[31]) ;

bufif0 cbe_buffer0 (pci_cbe0_pad_io, pci_cbe_o[0], pci_cbe_oe[0]) ;
bufif0 cbe_buffer1 (pci_cbe1_pad_io, pci_cbe_o[1], pci_cbe_oe[1]) ;
bufif0 cbe_buffer2 (pci_cbe2_pad_io, pci_cbe_o[2], pci_cbe_oe[2]) ;
bufif0 cbe_buffer3 (pci_cbe3_pad_io, pci_cbe_o[3], pci_cbe_oe[3]) ;

assign pci_ad_i  = {
    pci_ad31_pad_io,
    pci_ad30_pad_io,
    pci_ad29_pad_io,
    pci_ad28_pad_io,
    pci_ad27_pad_io,
    pci_ad26_pad_io,
    pci_ad25_pad_io,
    pci_ad24_pad_io,
    pci_ad23_pad_io,
    pci_ad22_pad_io,
    pci_ad21_pad_io,
    pci_ad20_pad_io,
    pci_ad19_pad_io,
    pci_ad18_pad_io,
    pci_ad17_pad_io,
    pci_ad16_pad_io,
    pci_ad15_pad_io,
    pci_ad14_pad_io,
    pci_ad13_pad_io,
    pci_ad12_pad_io,
    pci_ad11_pad_io,
    pci_ad10_pad_io,
    pci_ad9_pad_io,
    pci_ad8_pad_io,
    pci_ad7_pad_io,
    pci_ad6_pad_io,
    pci_ad5_pad_io,
    pci_ad4_pad_io,
    pci_ad3_pad_io,
    pci_ad2_pad_io,
    pci_ad1_pad_io,
    pci_ad0_pad_io
} ;

assign pci_cbe_i = {
    pci_cbe3_pad_io,
    pci_cbe2_pad_io,
    pci_cbe1_pad_io,
    pci_cbe0_pad_io
} ;

bufif0 req_buf (pci_req_pad_o, pci_req_o, pci_req_oe) ;

bufif0 frame_buf (pci_frame_pad_io, pci_frame_o, pci_frame_oe) ;
assign pci_frame_i = pci_frame_pad_io ;

bufif0 irdy_buf (pci_irdy_pad_io, pci_irdy_o, pci_irdy_oe) ;
assign pci_irdy_i = pci_irdy_pad_io ;

bufif0 devsel_buf (pci_devsel_pad_io, pci_devsel_o, pci_devsel_oe) ;
assign pci_devsel_i = pci_devsel_pad_io ;

bufif0 trdy_buf (pci_trdy_pad_io, pci_trdy_o, pci_trdy_oe) ;
assign pci_trdy_i = pci_trdy_pad_io ;

bufif0 stop_buf (pci_stop_pad_io, pci_stop_o, pci_stop_oe) ;
assign pci_stop_i = pci_stop_pad_io ;

bufif0 par_buf (pci_par_pad_io, pci_par_o, pci_par_oe) ;
assign pci_par_i = pci_par_pad_io ;

bufif0 perr_buf (pci_perr_pad_io, pci_perr_o, pci_perr_oe) ;
assign pci_perr_i = pci_perr_pad_io ;

bufif0 serr_buf (pci_serr_pad_o, pci_serr_o, pci_serr_oe) ;

pci_bridge32 i_pci_bridge32
(
    // WISHBONE system signals
    .wb_clk_i(wb_clk),
    .wb_rst_i(1'b0),
    .wb_rst_o(wb_rst),
    .wb_int_i(1'b0),
    .wb_int_o(),

    // WISHBONE slave interface
    .wbs_adr_i(wbm_test_wbs_pci_adr),
    .wbs_dat_i(wbm_test_wbs_pci_dat),
    .wbs_dat_o(wbs_pci_wbm_test_dat),
    .wbs_sel_i(wbm_test_wbs_pci_sel),
    .wbs_cyc_i(pci_wbs_cyc),
    .wbs_stb_i(wbm_test_wbs_pci_stb),
    .wbs_we_i (wbm_test_wbs_pci_we),
    .wbs_cab_i(wbm_test_wbs_pci_cab),
    .wbs_ack_o(wbs_pci_wbm_test_ack),
    .wbs_rty_o(),
    .wbs_err_o(),

    // WISHBONE master interface
    .wbm_adr_o(wbm_pci_wbs_test_adr),
    .wbm_dat_i(wbs_test_wbm_pci_dat),
    .wbm_dat_o(wbm_pci_wbs_test_dat),
    .wbm_sel_o(wbm_pci_wbs_test_sel),
    .wbm_cyc_o(wbm_pci_wbs_test_cyc),
    .wbm_stb_o(wbm_pci_wbs_test_stb),
    .wbm_we_o (wbm_pci_wbs_test_we),
    .wbm_cab_o(wbm_pci_wbs_test_cab),
    .wbm_ack_i(wbs_test_wbm_pci_ack),
    .wbm_rty_i(1'b0),
    .wbm_err_i(1'b0),

    // pci interface - system pins
    .pci_clk_i      (pci_clk_pad_i),
    .pci_rst_i      (pci_rst_pad_i),
    .pci_rst_o      (),
    .pci_inta_i     (1'b1),
    .pci_inta_o     (),
    .pci_rst_oe_o   (),
    .pci_inta_oe_o  (),

    // arbitration pins
    .pci_req_o      (pci_req_o),
    .pci_req_oe_o   (pci_req_oe),

    .pci_gnt_i      (pci_gnt_pad_i),

    // protocol pins
    .pci_frame_i    (pci_frame_i),
    .pci_frame_o    (pci_frame_o),

    .pci_frame_oe_o (pci_frame_oe),
    .pci_irdy_oe_o  (pci_irdy_oe),
    .pci_devsel_oe_o(pci_devsel_oe),
    .pci_trdy_oe_o  (pci_trdy_oe),
    .pci_stop_oe_o  (pci_stop_oe),
    .pci_ad_oe_o    (pci_ad_oe),
    .pci_cbe_oe_o   (pci_cbe_oe),

    .pci_irdy_i     (pci_irdy_i),
    .pci_irdy_o     (pci_irdy_o),

    .pci_idsel_i    (pci_idsel_pad_i),

    .pci_devsel_i   (pci_devsel_i),
    .pci_devsel_o   (pci_devsel_o),

    .pci_trdy_i     (pci_trdy_i),
    .pci_trdy_o     (pci_trdy_o),

    .pci_stop_i     (pci_stop_i),
    .pci_stop_o     (pci_stop_o),

    // data transfer pins
    .pci_ad_i       (pci_ad_i),
    .pci_ad_o       (pci_ad_o),

    .pci_cbe_i      (pci_cbe_i),
    .pci_cbe_o      (pci_cbe_o),

    // parity generation and checking pins
    .pci_par_i      (pci_par_i),
    .pci_par_o      (pci_par_o),
    .pci_par_oe_o   (pci_par_oe),

    .pci_perr_i     (pci_perr_i),
    .pci_perr_o     (pci_perr_o),
    .pci_perr_oe_o  (pci_perr_oe),

    // system error pin
    .pci_serr_o     (pci_serr_o),
    .pci_serr_oe_o  (pci_serr_oe)
);
endmodule // pci_test_top
