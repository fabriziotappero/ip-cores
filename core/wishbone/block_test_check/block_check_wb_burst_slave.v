//////////////////////////////////////////////////////////////////////////////////
// Company:         ;)
// Engineer:        Kuzmi4
// 
// Create Date:     14:39:52 05/19/2010 
// Design Name: 
// Module Name:     block_check_wb_burst_slave 
// Project Name:    DS_DMA
// Target Devices:  any
// Tool versions:   
// Description:     
//                  
//                  For now we have such restrictions for WB component:
//                      1) no WB_RTY syupport
//                      2) WB_ERR arize only at event detection and fall after it goes.
//                      3) WB Transfer granularity - 64bit
//                      4) (TBD)...
//                  
//                  ==> Design SUPPORT Master DELAY in Transfer !!!
//
// Revision: 
// Revision 0.01 - File Created
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
    output reg          o_wbs_burst_err,
    output              o_wbs_burst_rty,
    //
    // TEST_CHECK IF (Output data with ENA)
    output reg  [63:0]  ov_test_check_data,
    output reg          o_test_check_data_ena,
    //
    // TEST_CHECK Controls (WBS_CFG)
    input       [15:0]  iv_control
    
);
//////////////////////////////////////////////////////////////////////////////////
    // 
    wire    s_wb_transfer_ok_0;
    //wire    s_wb_transfer_master_hold;
    // define WB stuff:
    reg     [8:0]   sv_wbs_burst_counter;
    
//////////////////////////////////////////////////////////////////////////////////
    // 
    assign  s_wb_transfer_ok_0  =   (iv_wbs_burst_addr==0)                              & // START from INIT ADDR
                                    i_wbs_burst_cyc & i_wbs_burst_stb & i_wbs_burst_we  & // WB Transfer strobes
                                    iv_wbs_burst_sel==8'hFF                             & // WB_SEL point to 64bit transfer
                                    iv_wbs_burst_bte==2'b00                             ; // WB Burst Transfer type check (Linear Burst)
  //FIX  
    assign  s_wb_transfer_master_hold   =   (iv_wbs_burst_addr==0)                            & // START from INIT ADDR
                                            i_wbs_burst_cyc & !i_wbs_burst_stb & i_wbs_burst_we & // WB Transfer strobes (MASTER STALL case)
                                            iv_wbs_burst_sel==8'hFF                             & // WB_SEL point to 64bit transfer
                                            iv_wbs_burst_bte==2'b00                             ; // WB Burst Transfer type check (Linear Burst)*/
    // WB stuff:
    assign  o_wbs_burst_ack =   s_wb_transfer_ok_0;
    assign  o_wbs_burst_rty =   0;  // for now no WB Retry func, only WB_ERR for now
//////////////////////////////////////////////////////////////////////////////////
//
// 
//
//always @ (posedge i_clk or posedge i_rst)
always @ (posedge i_clk)
begin   :   TEST_CHECK_DATA_OUT
    //
    o_test_check_data_ena   <= s_wb_transfer_ok_0;
    ov_test_check_data      <= iv_wbs_burst_data;
    
end
//////////////////////////////////////////////////////////////////////////////////
//
// Create WB ERROR logic:
//
always @ (posedge i_clk or posedge i_rst)
begin   :   WB_ERR
    if (i_rst)
        begin   :   RST
            o_wbs_burst_err         <= 0;
            sv_wbs_burst_counter    <= 0;
        end
    else
        begin   :   WRK
            // BURST counter
            if (i_wbs_burst_cyc)
                begin   :   TIME_TO_COUNT
                    if (o_wbs_burst_ack) // count ENA
                        sv_wbs_burst_counter <= sv_wbs_burst_counter + 1'b1;
                end
            else            // W8 for COUNT Time, CLR COUNTER 
                sv_wbs_burst_counter <= 0;
            // ERR logic
            if  (
                    (sv_wbs_burst_counter == 511 & o_wbs_burst_ack & iv_wbs_burst_cti!=3'b111)  |   // check End-of-Burst
                    (sv_wbs_burst_counter <  511 & o_wbs_burst_ack & iv_wbs_burst_cti!=3'b001)      // check Const-Addr-Burst
                                                                                                    // ==> WB_BTE check at "s_wb_transfer_ok"
                )
                o_wbs_burst_err <= 1;
            else
                o_wbs_burst_err <= 0;
        end
end
//////////////////////////////////////////////////////////////////////////////////
endmodule
