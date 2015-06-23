//////////////////////////////////////////////////////////////////////////////////
// Company:         ;)
// Engineer:        Kuzmi4
// 
// Create Date:     14:39:52 05/19/2010 
// Design Name:     
// Module Name:     core64_pb_wishbone_ctrl
// Project Name:    DS_DMA
// Target Devices:  
// Tool versions:   
// Description: 
//                  
//                  Module serves for PB<->WB conversion
//                  
//                  Data Transfers:
//                  ==>   1 WORD  (64bit)
//                  ==> 512 WORDS (64bit) - in this case slave must have holder for N*64bit,
//                                              because PB_MASTER stops data transfer after K cycles "o_pb_slave_ready" falling (N>K)
//                  
//                  For now: 
//                      1) we have 64bit data transfer at WB bus
//                      2) i_wbm_err/i_wbm_rty - not avaliable func
//                  
//
// Revision: 
// Revision 0.01 - File Created
// Revision 0.02 - upd PB_SLAVE if with COMPLETE/READY signals, upgrade LOGIC
//
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module core64_pb_wishbone_ctrl
(
    // SYS_CON (same for PB/WB bus)
    input               i_clk,
    input               i_rst,
    //
    // PB_MASTER (in) IF
    input               i_pb_master_stb0,   // CMD STB
    input               i_pb_master_stb1,   // DATA STB
    input       [ 2:0]  iv_pb_master_cmd,   // CMD
    input       [31:0]  iv_pb_master_addr,  // ADDR
    input       [63:0]  iv_pb_master_data,  // DATA
    //
    // PB_SLAVE (out) IF:
    output              o_pb_slave_ready,
    output  reg         o_pb_slave_complete,
    output  reg         o_pb_slave_stb0,    // WR CMD ACK STB   (to pcie_core64_m6)
    output  reg         o_pb_slave_stb1,    // DATA ACK STB     (to pcie_core64_m6)
    output  reg [63:0]  ov_pb_slave_data,   // DATA             (to pcie_core64_m6)
    output      [ 1:0]  ov_pb_slave_dmar,   // ...
    output              o_pb_slave_irq,     // ...
    //
    // WB BUS:
    output      [31:0]  ov_wbm_addr,    
    output      [63:0]  ov_wbm_data,    
    output      [ 7:0]  ov_wbm_sel,     
    output              o_wbm_we,       
    output  reg         o_wbm_cyc,      
    output              o_wbm_stb,      
    output  reg [ 2:0]  ov_wbm_cti,     // Cycle Type Identifier Address Tag
    output      [ 1:0]  ov_wbm_bte,     // Burst Type Extension Address Tag
    
    input       [63:0]  iv_wbm_data,    // 
    input               i_wbm_ack,      // 
    input               i_wbm_err,      // error input - abnormal cycle termination
    input               i_wbm_rty,      // retry input - interface is not ready
    
    input               i_wdm_irq_0,
    input       [ 1:0]  iv_wbm_irq_dmar
    
);
//////////////////////////////////////////////////////////////////////////////////
// 
localparam  lp_CASE0    =   0;
localparam  lp_RD_CASE0 =   1;
localparam  lp_RD_CASE1 =   2;
localparam  lp_RD_CASE2 =   3;
localparam  lp_WR_CASE0 =   4;
localparam  lp_WR_CASE1 =   5;
localparam  lp_WR_CASE2 =   6;
//
localparam  lp_PB_VOL512    =   2;
localparam  lp_PB_RD        =   1;
localparam  lp_PB_WR        =   0;
//////////////////////////////////////////////////////////////////////////////////
    // Declare PB_MASTER stuff:
    reg             s_pb_master_stb0;
    reg             s_pb_master_stb1;
    reg     [ 2:0]  sv_pb_master_cmd;
    reg     [31:0]  sv_pb_master_addr;
    // Declare WB_COMP_OUTGOING_FIFO stuff:
    wire            s_wb_comp_outgoing_fifo_rd_en; 
    wire            s_wb_comp_outgoing_fifo_full;  
    wire            s_wb_comp_outgoing_fifo_empty; 
    wire    [ 8:0]  sv_wb_comp_outgoing_fifo_data_count;
    // PB_SLAVE.COMPLETE stuff:
    reg             s_pb_slave_complete;
    // PB_DATA_COUNTERs stuff:
    reg     [8:0]   sv_wb_comp_outgoing_in_data_count;
    reg     [8:0]   sv_wb_comp_outgoing_out_data_count;
    reg     [8:0]   sv_wb_comp_incoming_data_count;
    //
    // FSM
    reg     [3:0]   sv_wbm_fsm;
    reg     [3:0]   sv_pb_fsm;
//////////////////////////////////////////////////////////////////////////////////
    //
    // WB stuff:
    assign  ov_wbm_addr =   sv_pb_master_addr;
    assign  o_wbm_we    =   sv_wbm_fsm==lp_WR_CASE0 | sv_wbm_fsm==lp_WR_CASE2;
    
    assign  o_wbm_stb   =   o_wbm_cyc;
    assign  ov_wbm_sel  =   8'hFF;                                      // --> always ENA all 64bit
    assign  ov_wbm_bte  =   0;                                          // --> always Linear burst
    //
    // DMAR[1:0] and IRQ direct route:
    assign  ov_pb_slave_dmar    = iv_wbm_irq_dmar;
    assign  o_pb_slave_irq      = i_wdm_irq_0;
    //
    //
    assign  o_pb_slave_ready    =   (sv_wb_comp_outgoing_fifo_data_count < 32);
    //
    // OUTGOING FIFO controls:
    assign  s_wb_comp_outgoing_fifo_rd_en   =   (i_wbm_ack & o_wbm_we & o_wbm_cyc) |
                                                (o_wbm_we & !o_wbm_cyc);
    // because at WR side of FIFO we have no WR brackes - 
    //  at RD side of FIFO we will have speed always EQU
    //      or LESS than at WR side
    
//////////////////////////////////////////////////////////////////////////////////
//
// Register Inputs from PB MASTER (in) IF:
//
always @ (posedge i_clk or posedge i_rst)
begin   :   REG_PB_MASTER
    if (i_rst)
        begin   :   RST
            s_pb_master_stb0    <= 0;
            s_pb_master_stb1    <= 0;
            sv_pb_master_cmd    <= 0;
            sv_pb_master_addr   <= 0;
        end
    else
        begin   :   WRK
            // REG controls
            s_pb_master_stb0    <= i_pb_master_stb0;
            s_pb_master_stb1    <= i_pb_master_stb1;
            // CMD STB
            if (i_pb_master_stb0)
                begin
                    sv_pb_master_cmd    <= iv_pb_master_cmd;
                    sv_pb_master_addr   <= iv_pb_master_addr;
                end
        end
end
//////////////////////////////////////////////////////////////////////////////////
//
// Construct WB Master logic for 1W/512W trasfers:
//
always @ (posedge i_clk or posedge i_rst)
begin   :   WBM_LOGIC
    if (i_rst)
        begin   :   RST
            sv_wbm_fsm  <= lp_CASE0;
            o_wbm_cyc   <= 0;
            ov_wbm_cti  <= 0;
        end
    else
        begin   :   WRK
            case (sv_wbm_fsm)
                // init case
                lp_CASE0    :   begin // WRK with registered controls
                                    if (s_pb_master_stb0)
                                        begin   :   START_CYC
                                            if (sv_pb_master_cmd[lp_PB_WR])
                                                begin   :   WR_DEAL
                                                    if (sv_pb_master_cmd[lp_PB_VOL512]) // 512 WORDs
                                                        sv_wbm_fsm <= lp_WR_CASE1;
                                                    else                                //   1 WORD
                                                        sv_wbm_fsm <= lp_WR_CASE0;
                                                end
                                            else
                                                begin   :   RD_DEAL
                                                    if (sv_pb_master_cmd[lp_PB_VOL512]) // 512 WORDs
                                                        sv_wbm_fsm <= lp_RD_CASE1;
                                                    else                                //   1 WORD
                                                        sv_wbm_fsm <= lp_RD_CASE0;
                                                end
                                        end
                                    //
                                    o_wbm_cyc   <= s_pb_master_stb0 & sv_pb_master_cmd[lp_PB_RD];
                                    ov_wbm_cti  <= (s_pb_master_stb0 & sv_pb_master_cmd[lp_PB_RD] & sv_pb_master_cmd[lp_PB_VOL512])?3'b001 : // Const_Addr Burst
                                                                                                                                    3'b000 ; // Classic Cycle
                                end
                //
                lp_WR_CASE0 :   begin   //   1 WORD
                                    o_wbm_cyc   <= !(s_wb_comp_outgoing_fifo_empty & i_wbm_ack);
                                    ov_wbm_cti  <= 3'b000;// Classic Cycle
                                    
                                    if (s_wb_comp_outgoing_fifo_empty & i_wbm_ack)
                                        sv_wbm_fsm <= lp_CASE0;
                                end
                lp_WR_CASE1 :   begin   // WR0: 512 WORDs
                                    if (s_pb_master_stb1)
                                        sv_wbm_fsm <= lp_WR_CASE2;
                                end
                lp_WR_CASE2 :   begin   // WR1: 512 WORDs
                                    o_wbm_cyc   <= (sv_wb_comp_outgoing_out_data_count==511 & i_wbm_ack)? 1'b0 : 1'b1;
                                    ov_wbm_cti  <=  (
                                                        (sv_wb_comp_outgoing_out_data_count==510 & i_wbm_ack) |
                                                         sv_wb_comp_outgoing_out_data_count==511
                                                    )? 3'b111 : 3'b001; // End-of-Burst:Const_Addr Burst
                                    
                                    if (sv_wb_comp_outgoing_out_data_count==511 & i_wbm_ack)
                                        sv_wbm_fsm <= lp_CASE0;
                                end
                //
                lp_RD_CASE0 :   begin   //   1 WORD
                                    o_wbm_cyc   <= !i_wbm_ack; // !!!
                                    ov_wbm_cti  <= 3'b000;// Classic Cycle
                                    
                                    if (i_wbm_ack)
                                        sv_wbm_fsm <= lp_CASE0;
                                end
                lp_RD_CASE1 :   begin   // 512 WORDs
                                    o_wbm_cyc   <= (i_wbm_ack & sv_wb_comp_incoming_data_count==511)? 1'b0 : 1'b1;
                                    ov_wbm_cti  <=  (
                                                        (sv_wb_comp_incoming_data_count==510 & i_wbm_ack) |
                                                        sv_wb_comp_incoming_data_count==511
                                                    )? 3'b111 : 3'b001; // End-of-Burst:Const_Addr Burst
                                    
                                    if (i_wbm_ack & sv_wb_comp_incoming_data_count==511)
                                        sv_wbm_fsm <= lp_CASE0;
                                end
            endcase
            
        end
end
//////////////////////////////////////////////////////////////////////////////////
//
// Construct logic for answer to PB Master via PB Slave (complete) IF:
//
always @ (posedge i_clk or posedge i_rst)
begin   :   CRE_PB_COMPLETE_LOGIC
    if (i_rst)
        begin   :   RST
            o_pb_slave_complete <= 0;
            s_pb_slave_complete <= 0;
        end
    else
        begin   :   WRK
            // 
            s_pb_slave_complete <=  (sv_wbm_fsm==lp_RD_CASE0 & i_wbm_ack)                                           | // 
                                    (sv_wbm_fsm==lp_RD_CASE1 & i_wbm_ack & sv_wb_comp_incoming_data_count==511)     | // 
                                    
                                    (sv_wbm_fsm==lp_WR_CASE0 & s_wb_comp_outgoing_fifo_empty & i_wbm_ack)           | // 
                                    (sv_wbm_fsm==lp_WR_CASE2 & sv_wb_comp_outgoing_out_data_count==511 & i_wbm_ack) ; // 
            //
            o_pb_slave_complete <= s_pb_slave_complete;
        end
end
//////////////////////////////////////////////////////////////////////////////////
//
// Construct Logic for PB Slave (data) IF:
//
always@ (posedge i_clk or posedge i_rst)
begin   :   CRE_PB_SLAVE_DATA
    if (i_rst)
        begin   :   RST
            ov_pb_slave_data <= 0;
        end
    else
        begin   :   WRK
            if (i_wbm_ack)  // ENA
                ov_pb_slave_data <= iv_wbm_data;
        end
end
//////////////////////////////////////////////////////////////////////////////////
//
// Construct Logic for PB Slave (stb1/stb0) IF:
//
always @ (posedge i_clk or posedge i_rst)
begin   :   CRE_PB_SLAVE_STB_1_LOGIC
    if (i_rst)
        begin   :   RST
            sv_pb_fsm <= lp_CASE0;
            o_pb_slave_stb1 <= 0;
        end
    else
        begin   :   WRK
            case (sv_pb_fsm)
                // 
                lp_CASE0    :   begin   // WRK with registered controls
                                    if (s_pb_master_stb0 & sv_pb_master_cmd[lp_PB_RD])
                                        begin   :   RD_DEAL
                                            sv_pb_fsm <= lp_RD_CASE0;
                                        end
                                    //
                                    o_pb_slave_stb1 <= 0;
                                end
                //
                lp_RD_CASE0 :   begin   //   1/512 WORD
                                    o_pb_slave_stb1 <= i_wbm_ack;
                                    if  (
                                            (i_wbm_ack & sv_wb_comp_incoming_data_count==511) | // 512 WORD case
                                            s_pb_slave_complete                                 //   1 WORD case
                                        )
                                        sv_pb_fsm <= lp_CASE0;
                                end
                
            endcase
        end
end
/**/
always @ (posedge i_clk or posedge i_rst)
begin   :   CRE_PB_SLAVE_STB_0
    if (i_rst)
        o_pb_slave_stb0 <= 0;
    else if (sv_wbm_fsm==lp_CASE0)
        o_pb_slave_stb0 <= i_pb_master_stb0;
    else
        o_pb_slave_stb0 <= 0;
end
//////////////////////////////////////////////////////////////////////////////////
//
// Construct counter logic for PB Master/Slave control purposes:
//
always @ (posedge i_clk or posedge i_rst)
begin   :   CRE_PB_DATA_COUNTERs
    if (i_rst)
        begin   :   RST
            sv_wb_comp_outgoing_in_data_count   <= 0;
            sv_wb_comp_outgoing_out_data_count  <= 0;
            
            sv_wb_comp_incoming_data_count      <= 0;
        end
    else
        begin
            // INCOMING PB_MASTER data counter for WB_COMP_OUTGOING_FIFO
            if (sv_wbm_fsm==lp_WR_CASE0 | sv_wbm_fsm==lp_WR_CASE1 | sv_wbm_fsm==lp_WR_CASE2)
                begin   :   IN_COUNT_TIME
                    if (i_pb_master_stb1)
                        sv_wb_comp_outgoing_in_data_count <= sv_wb_comp_outgoing_in_data_count + 1'b1;
                end
            else
                sv_wb_comp_outgoing_in_data_count <= 0;
            // OUTGOING PB_MASTER data counter for WB_COMP_OUTGOING_FIFO
            if (sv_wbm_fsm==lp_WR_CASE0 | sv_wbm_fsm==lp_WR_CASE1 | sv_wbm_fsm==lp_WR_CASE2)
                begin   :   OUT_COUNT_TIME
                    if (i_wbm_ack)
                        sv_wb_comp_outgoing_out_data_count <= sv_wb_comp_outgoing_out_data_count + 1'b1;
                end
            else
                sv_wb_comp_outgoing_out_data_count <= 0;
            //
            // IN WB/OUT PB_SLAVE data transfer counter
            if (sv_wbm_fsm==lp_RD_CASE1)
                begin   :   COUNT_TIME
                    if (i_wbm_ack)
                        sv_wb_comp_incoming_data_count <= sv_wb_comp_incoming_data_count + 1'b1;
                end
            else
                sv_wb_comp_incoming_data_count <= 0;
        end
end
//////////////////////////////////////////////////////////////////////////////////
//
// Instantiate "WB_COMP_FIFO" (because PB_MASTER IF stops Transaction after K cycles of falling "o_pb_slave_ready")
//  
// ==> all outgoing DATA transaction routes throught this FIFO: from PB_MASTER IF to WB IF
// 
ctrl_fifo512x64st_v0 WB_COMP_OUTGOING_FIFO
(
.clk                (i_clk),
.rst                (i_rst),
//
.wr_en              (i_pb_master_stb1),
.din                (iv_pb_master_data),
//
.rd_en              (s_wb_comp_outgoing_fifo_rd_en),
.dout               (ov_wbm_data),
//
.full               (s_wb_comp_outgoing_fifo_full),
.empty              (s_wb_comp_outgoing_fifo_empty),
//
.data_count         (sv_wb_comp_outgoing_fifo_data_count)
);

// synthesis translate_off
integer si_wb_outgoing_fifo_wr_counter=0;
always @ (posedge i_clk or posedge i_rst)
begin   :   SIM_FIFO_WR_COUNTER
    if (i_rst)
        si_wb_outgoing_fifo_wr_counter=0;
    else if (i_pb_master_stb1)
        si_wb_outgoing_fifo_wr_counter=si_wb_outgoing_fifo_wr_counter+1;
    else if (o_pb_slave_complete)
        si_wb_outgoing_fifo_wr_counter=0;
end

initial
begin : WB_COMP_OUTGOING_FIFO_WR_SNIFF
 forever
  begin : LOGIC
   @(posedge i_clk);
   if (si_wb_outgoing_fifo_wr_counter>512)
    begin : ERR_MSG
     $display("[%t]: %m", $time);
     $stop;
    end
  end
end
// synthesis translate_on

//////////////////////////////////////////////////////////////////////////////////
//
// Process WB ERR functionality here:
//  ==> Now only SNIFF, MSG and STOP
//

// synthesis translate_off
initial 
begin   :   WB_ERR
    @(posedge i_clk);
    forever
        begin   :   ERR_SNIFF
            @(posedge i_wbm_err);
            $display("[%t]: %m: WB_ERR functionality NOT SUPPORTED, ONLY INFORM!!!", $time); #1;
            $stop;
        end
    
end
initial 
begin   :   WB_RTY
    @(posedge i_clk);
    forever
        begin   :   ERR_SNIFF
            @(posedge i_wbm_rty);
            $display("[%t]: %m: WB_RTY functionality NOT SUPPORTED, ONLY INFORM!!!", $time); #1;
            $stop;
        end
    
end
// synthesis translate_on
//////////////////////////////////////////////////////////////////////////////////
endmodule
