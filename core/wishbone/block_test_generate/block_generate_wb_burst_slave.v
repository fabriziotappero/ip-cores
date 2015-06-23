//////////////////////////////////////////////////////////////////////////////////
// Company:         ;)
// Engineer:        Kuzmi4
// 
// Create Date:     14:39:52 05/19/2010 
// Design Name:     
// Module Name:     block_generate_wb_burst_slave 
// Project Name:    DS_DMA
// Target Devices:  any
// Tool versions:   
// Description:     
//                  
//                  For now we have such restrictions for WB component:
//                      1) no WB_RTY syupport
//                      2) WB_ERR arize only at event detection and fall after it goes.
//                      3) WB Transfers muts be without STB->LOW (NO Master DELAY in Transfer) --> !!! (because counted on standard FIFO IF)
//                      4) (TBD)...
//                  
//
// Revision: 
// Revision 0.01 - File Created, 
//                      2do: provide "Master DELAY in Transfer" functionality (STB->LOW when CYC==HIGH) (looks like FW FIFO can provide such func)
//
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module block_generate_wb_burst_slave
(
    //
    // SYS_CON
    input   i_clk,
    input   i_rst,
    //
    // WB BURST SLAVE IF (READ-ONLY IF)
    input       [11:0]  iv_wbs_burst_addr,
    input       [ 7:0]  iv_wbs_burst_sel,
    input               i_wbs_burst_we,
    input               i_wbs_burst_cyc,
    input               i_wbs_burst_stb,
    input       [ 2:0]  iv_wbs_burst_cti,
    input       [ 1:0]  iv_wbs_burst_bte,
    
    output reg  [63:0]  ov_wbs_burst_data,
    output reg          o_wbs_burst_ack,
    output reg          o_wbs_burst_err,
    output              o_wbs_burst_rty,
    //
    // TEST_GEN_FIFO IF
    input       [63:0]  iv_test_gen_fifo_data,      
    output              o_test_gen_fifo_rd,         
    input               i_test_gen_fifo_full,       // unused for now
    input               i_test_gen_fifo_empty,      
    input               i_test_gen_fifo_prog_full   // unused for now
);
//////////////////////////////////////////////////////////////////////////////////
//
localparam  lp_INIT_STATE   =   0;
localparam  lp_WRK_STATE    =   1;
//////////////////////////////////////////////////////////////////////////////////
    // 
    wire            s_wb_transfer_ok_0;
    // define WB stuff:
    reg     [8:0]   sv_wbs_burst_counter;
    reg     [0:0]   sv_wbs_fsm;
//////////////////////////////////////////////////////////////////////////////////
    // 
    assign  s_wb_transfer_ok_0  =   (iv_wbs_burst_addr==0)                              & // START from INIT ADDR
                                    i_wbs_burst_cyc & i_wbs_burst_stb & !i_wbs_burst_we & // WB Transfer strobes
                                    iv_wbs_burst_sel==8'hFF                             & // WB_SEL point to 64bit transfer 
                                    iv_wbs_burst_bte==2'b00                             ; // WB Burst Transfer type check (Linear Burst)
    // TEST_GEN_FIFO IF deal:
    assign  o_test_gen_fifo_rd   =   s_wb_transfer_ok_0 & !i_test_gen_fifo_empty & (sv_wbs_burst_counter < 510);
    // WB stuff deal:
    assign  o_wbs_burst_rty =   0;  // for now no WB retry func, only WB_ERR for now
//////////////////////////////////////////////////////////////////////////////////
//
// Create WB DATA_OUT logic:
//
always @ (posedge i_clk or posedge i_rst)
begin   :   WB_DATA_OUT
    if (i_rst)
        begin   :   RST
            ov_wbs_burst_data   <= 0;
            o_wbs_burst_ack     <= 0;
            sv_wbs_fsm          <= lp_INIT_STATE;
        end
    else
        begin   :   WRK
            //
            o_wbs_burst_ack     <=0;
            // 
            case(sv_wbs_fsm)
                lp_INIT_STATE   :   begin
                                        if (o_test_gen_fifo_rd/*s_wb_transfer_ok_1*/)
                                            sv_wbs_fsm <= lp_WRK_STATE;
                                    end
                lp_WRK_STATE    :   begin
                                        // 
                                        ov_wbs_burst_data   <=  (i_test_gen_fifo_empty)? 0 : iv_test_gen_fifo_data;
                                        //
                                        o_wbs_burst_ack     <=  (
                                                                    iv_wbs_burst_cti==3'b111    |   // End-of-Burst
                                                                    !s_wb_transfer_ok_0             // No Transfer
                                                                )?  1'b0                    :       // ...
                                                                    !i_test_gen_fifo_empty  ;       // FIFO EMPTY control here
                                        // 
                                        if (i_test_gen_fifo_empty | !s_wb_transfer_ok_0)
                                            sv_wbs_fsm <= lp_INIT_STATE;
                                            
                                    end
            endcase
        end
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
                    (sv_wbs_burst_counter <  511 & o_wbs_burst_ack & iv_wbs_burst_cti!=3'b001)  |   // check Const-Addr-Burst
                    (sv_wbs_burst_counter!=0 & i_wbs_burst_cyc & !i_wbs_burst_stb)                  // check delays in MASTER transfer --> !!!
                                                                                                    // ==> WB_BTE check at "s_wb_transfer_ok"
                ) 
                o_wbs_burst_err <= 1;
            else
                o_wbs_burst_err <= 0;
        end
end
//////////////////////////////////////////////////////////////////////////////////
endmodule
