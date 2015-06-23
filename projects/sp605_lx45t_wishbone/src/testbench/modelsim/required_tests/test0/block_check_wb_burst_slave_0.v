//////////////////////////////////////////////////////////////////////////////////
// Company:         ;)
// Engineer:        Kuzmi4
// 
// Create Date:     14:39:52 05/19/2010 
// Design Name: 
// Module Name:     block_check_wb_burst_slave_0
// Project Name:    DS_DMA
// Target Devices:  any
// Tool versions:   
// Description:     
//                  This component designed for test "pcie_core64_m6" inner logis (dsmv req)
//                  
//
// Revision: 
// Revision 0.01 - File Created
// Revision 0.02 - add full wrk functionality.
//
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module block_check_wb_burst_slave
(
    //
    // SYS_CON
    input   i_clk,
    input   i_rst,
    //
    // WB BURST SLAVE IF (WRITE-ONLY IF)
    input       [11:0]  iv_wbs_burst_addr,
    input       [63:0]  iv_wbs_burst_data,
    input       [ 7:0]  iv_wbs_burst_sel,
    input               i_wbs_burst_we,
    input               i_wbs_burst_cyc,
    input               i_wbs_burst_stb,
    input       [ 2:0]  iv_wbs_burst_cti,
    input       [ 1:0]  iv_wbs_burst_bte,
    
    output              o_wbs_burst_ack,
    output              o_wbs_burst_err,
    output              o_wbs_burst_rty,
    //
    // TEST_CHECK IF (Output data with ENA) ==> always LOW
    output  reg [63:0]  ov_test_check_data,
    output  reg         o_test_check_data_ena,
    //
    // TEST_CHECK Controls (WBS_CFG)
    input       [15:0]  iv_control
);
//////////////////////////////////////////////////////////////////////////////////
/*
localparam  lp_ENA_DLY          =   1;
localparam  lp_START_DLY_POS    =   473;    // Stop IDX == 510
localparam  lp_WB_ACK_DLY       =    40;*/
//
localparam  lp_WB_BURST_DLY_POS_START       =    0;
localparam  lp_WB_BURST_DLY_POS_END         =    8;

localparam  lp_WB_BURST_ACK_DLY_POS_START   =    9;
localparam  lp_WB_BURST_ACK_DLY_POS_END     =   14;

localparam  lp_WB_BURST_DLY_ENA             =   15;
//////////////////////////////////////////////////////////////////////////////////
    // WBS stuff:
    wire            s_wb_transfer_ok_0;
    reg     [8:0]   sv_wbs_burst_counter;
    reg     [5:0]   sv_wb_ack_dly_counter;
    // WBS ACK delay output:
    wire    [lp_WB_BURST_ACK_DLY_POS_END-lp_WB_BURST_ACK_DLY_POS_START:0]   sv_wbs_ack_dly_value;
    wire    [lp_WB_BURST_DLY_POS_END-lp_WB_BURST_DLY_POS_START:0]           sv_wbs_dly_position;
    wire                                                                    s_wbs_dly_ena;
//////////////////////////////////////////////////////////////////////////////////
    // WBS ACK delay route/flags:
    assign  sv_wbs_ack_dly_value    =   iv_control[lp_WB_BURST_ACK_DLY_POS_END  : lp_WB_BURST_ACK_DLY_POS_START];
    assign  sv_wbs_dly_position     =   iv_control[lp_WB_BURST_DLY_POS_END      : lp_WB_BURST_DLY_POS_START];
    assign  s_wbs_dly_ena           =   iv_control[lp_WB_BURST_DLY_ENA];
    //
    // WBS controls output:
    assign  o_wbs_burst_ack =   (s_wbs_dly_ena)?  
                                                (
                                                    (sv_wbs_burst_counter==sv_wbs_dly_position)?  0 : s_wb_transfer_ok_0
                                                ) : 
                                                s_wb_transfer_ok_0; 
    assign  o_wbs_burst_err =   0;
    assign  o_wbs_burst_rty =   0;
    // WBS inner ack flag:
    assign  s_wb_transfer_ok_0  =   (iv_wbs_burst_addr==0)                              & // START from INIT ADDR
                                    i_wbs_burst_cyc & i_wbs_burst_stb & i_wbs_burst_we  & // WB Transfer strobes
                                    iv_wbs_burst_sel==8'hFF                             & // WB_SEL point to 64bit transfer
                                    iv_wbs_burst_bte==2'b00                             ; // WB Burst Transfer type check (Linear Burst)
//////////////////////////////////////////////////////////////////////////////////
//
// Create TEST_CHECK data output:
//
always  @ (posedge i_clk or posedge i_rst)
begin   :   TEST_CHECK_DATA_OUT
    if (i_rst)
        begin   :   RST
            ov_test_check_data      <= 0;
            o_test_check_data_ena   <= 0;
        end
    else
        begin   :   WRK
            o_test_check_data_ena   <= o_wbs_burst_ack;
            ov_test_check_data      <= iv_wbs_burst_data;
        end
end
//////////////////////////////////////////////////////////////////////////////////
//
// Provide WBS ACK delay counter:
//
always @ (posedge i_clk or posedge i_rst)
begin   :   WB_ACK_ADD
    if (i_rst)
        begin   :   RST
            sv_wb_ack_dly_counter <= 0;
        end
    else
        begin   :   WRK
            if (sv_wbs_burst_counter!=0 & !o_wbs_burst_ack)
                begin   :   ENA_CNT
                    if (sv_wb_ack_dly_counter < sv_wbs_ack_dly_value)
                        sv_wb_ack_dly_counter <= sv_wb_ack_dly_counter + 1;
                    else
                        sv_wb_ack_dly_counter <= 0;
                end
        end
end
//////////////////////////////////////////////////////////////////////////////////
//
// Provide WBS Burst counter logic:
//
always @ (posedge i_clk or posedge i_rst)
begin   :   WB_BURST_COUNTER
    if (i_rst)
        begin   :   RST
            sv_wbs_burst_counter <= 0;
        end
    else
        begin   :   WRK
            if (i_wbs_burst_cyc)
                begin   :   TIME_TO_COUNT
                    if (o_wbs_burst_ack | sv_wb_ack_dly_counter==sv_wbs_ack_dly_value) // count ENA: wb_ack OR wb_ack_dly_counter issue
                        sv_wbs_burst_counter <= sv_wbs_burst_counter + 1;
                end
            else            // W8 for COUNT Time, CLR COUNTER 
                sv_wbs_burst_counter <= 0;
        end
end
//////////////////////////////////////////////////////////////////////////////////
endmodule
