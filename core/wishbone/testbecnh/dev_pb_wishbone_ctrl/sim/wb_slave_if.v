//////////////////////////////////////////////////////////////////////////////////
// Company:         ;)
// Engineer:        Kuzmi4
// 
// Create Date:     14:39:52 05/19/2010 
// Design Name:     
// Module Name:     wb_slave_if
// Project Name:    DS_DMA
// Target Devices:  no
// Tool versions:   any with SV support
// Description: 
//
//
// Revision: 
// Revision 0.01 - File Created
//
//////////////////////////////////////////////////////////////////////////////////

interface wb_slave_if # (parameter time pt_Tdly = 1ns )
(
    input   i_clk, input i_rst
);
//////////////////////////////////////////////////////////////////////////////////
    // WB SLAVE Input signals:
    logic   [31:0]  iv_wbs_addr;    
    logic   [63:0]  iv_wbs_data;    
    logic   [ 7:0]  iv_wbs_sel;     
    logic           i_wbs_we;       
    logic           i_wbs_cyc;      
    logic           i_wbs_stb;      
    logic   [ 2:0]  iv_wbs_cti;     // Cycle Type Identifier Address Tag
    logic   [ 1:0]  iv_wbs_bte;     // Burst Type Extension Address Tag
    // WB SLAVE Output signals:
    logic   [63:0]  ov_wbs_data;    // 
    logic           o_wbs_ack;      // 
    logic           o_wbs_err;      // error input - abnormal cycle termination
    logic           o_wbs_rty;      // retry input - interface is not ready
    //  WB SLAVE IRQ Output signals:
    logic           o_wds_irq_0;
    logic   [ 1:0]  ov_wbs_irq_dmar;
    
//////////////////////////////////////////////////////////////////////////////////
//
// Define Clocking block:
//
default clocking cb @(posedge i_clk);
    default input #(pt_Tdly) output #(pt_Tdly);
    output ov_wbs_data, o_wbs_ack, o_wbs_err, o_wbs_rty, o_wds_irq_0, ov_wbs_irq_dmar;
    input iv_wbs_addr, iv_wbs_data, iv_wbs_sel, i_wbs_we, i_wbs_cyc, i_wbs_stb, iv_wbs_cti, iv_wbs_bte;
endclocking
//////////////////////////////////////////////////////////////////////////////////
//
// Tasks:
//
// Init DATA_OUT
task    init;
    //
    ov_wbs_data     <= 0;
    o_wbs_ack       <= 0;
    o_wbs_err       <= 0;
    o_wbs_rty       <= 0;
    o_wds_irq_0     <= 0;
    ov_wbs_irq_dmar <= 0;
    //
endtask

task run;
    //
    
    //
endtask

/*
task rx_1_word(output [31:0] iv_addr, output [63:0] iv_data);
    //
    
    //
endtask
// 
task rx_512_word(output [31:0] iv_addr, output [63:0] iv_data [512]);
    //
    
    //
endtask
// 
task tx_1_word(input [31:0] iv_addr, input [63:0] iv_data);
    //
    
    //
endtask
// 
task tx_512_word(input [31:0] iv_addr, input [63:0] iv_data [512]);
    //
    
    //
endtask
*/ 
task set_irq_0(input i_irq_0);
    cb.o_wds_irq_0 <= i_irq_0;
endtask
// 
task set_irq_dmar(input [1:0] iv_irq_dmar);
    cb.ov_wbs_irq_dmar <= iv_irq_dmar;
endtask
//////////////////////////////////////////////////////////////////////////////////
//
// Functions:
//
// 
function automatic get_irq_0;
    return o_wds_irq_0;
endfunction
//
function automatic bit [1:0] get_irq_dmar;
    return ov_wbs_irq_dmar;
endfunction
//////////////////////////////////////////////////////////////////////////////////
endinterface
