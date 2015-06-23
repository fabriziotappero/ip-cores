//////////////////////////////////////////////////////////////////
//                                                              //
//  Test Module                                                 //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Contains a random number generator and a couple of timers   //
//  that connect to interrupt lines. Used for testing the       //
//  ssytem.                                                     //
//                                                              //
//  Author(s):                                                  //
//      - Conor Santifort, csantifort.amber@gmail.com           //
//                                                              //
//////////////////////////////////////////////////////////////////
//                                                              //
// Copyright (C) 2010 Authors and OPENCORES.ORG                 //
//                                                              //
// This source file may be used and distributed without         //
// restriction provided that this copyright statement is not    //
// removed from the file and that any derivative work contains  //
// the original copyright notice and the associated disclaimer. //
//                                                              //
// This source file is free software; you can redistribute it   //
// and/or modify it under the terms of the GNU Lesser General   //
// Public License as published by the Free Software Foundation; //
// either version 2.1 of the License, or (at your option) any   //
// later version.                                               //
//                                                              //
// This source is distributed in the hope that it will be       //
// useful, but WITHOUT ANY WARRANTY; without even the implied   //
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      //
// PURPOSE.  See the GNU Lesser General Public License for more //
// details.                                                     //
//                                                              //
// You should have received a copy of the GNU Lesser General    //
// Public License along with this source; if not, download it   //
// from http://www.opencores.org/lgpl.shtml                     //
//                                                              //
//////////////////////////////////////////////////////////////////


module test_module   #(
parameter WB_DWIDTH  = 32,
parameter WB_SWIDTH  = 4
)(
input                       i_clk,

output                      o_irq,
output                      o_firq,
output                      o_mem_ctrl,  // 0=128MB, 1=32MB
input       [31:0]          i_wb_adr,
input       [WB_SWIDTH-1:0] i_wb_sel,
input                       i_wb_we,
output      [WB_DWIDTH-1:0] o_wb_dat,
input       [WB_DWIDTH-1:0] i_wb_dat,
input                       i_wb_cyc,
input                       i_wb_stb,
output                      o_wb_ack,
output                      o_wb_err,
output     [3:0]            o_led,
output                      o_phy_rst_n

);

`include "register_addresses.vh"

        
reg [7:0]       firq_timer          = 'd0;
reg [7:0]       irq_timer           = 'd0;
reg [7:0]       random_num          = 8'hf3;

//synopsys translate_off
reg [1:0]       tb_uart_control_reg = 'd0;
reg [1:0]       tb_uart_status_reg  = 'd0;
reg             tb_uart_push        = 'd0;
reg [7:0]       tb_uart_txd_reg     = 'd0;
//synopsys translate_on

reg [2:0]       sim_ctrl_reg        = 'd0; // 0 = fpga, other values for simulations
reg             mem_ctrl_reg        = 'd0; // 0 = 128MB, 1 = 32MB main memory
reg [31:0]      test_status_reg     = 'd0;
reg             test_status_set     = 'd0; // used to terminate tests
reg [31:0]      cycles_reg          = 'd0;
     
wire            wb_start_write;
wire            wb_start_read;
reg             wb_start_read_d1    = 'd0;
reg  [31:0]     wb_rdata32          = 'd0;
wire [31:0]     wb_wdata32;

reg  [3:0]      led_reg             = 'd0;
reg             phy_rst_reg         = 'd0;


// Can't start a write while a read is completing. The ack for the read cycle
// needs to be sent first
assign wb_start_write = i_wb_stb && i_wb_we && !wb_start_read_d1;
assign wb_start_read  = i_wb_stb && !i_wb_we && !o_wb_ack;

always @( posedge i_clk )
    wb_start_read_d1 <= wb_start_read;

assign o_wb_ack     = i_wb_stb && ( wb_start_write || wb_start_read_d1 );
assign o_wb_err     = 1'd0;
assign o_mem_ctrl   = mem_ctrl_reg;
assign o_led        = led_reg;
assign o_phy_rst_n  = phy_rst_reg;

generate
if (WB_DWIDTH == 128) 
    begin : wb128
    assign wb_wdata32   = i_wb_adr[3:2] == 2'd3 ? i_wb_dat[127:96] :
                          i_wb_adr[3:2] == 2'd2 ? i_wb_dat[ 95:64] :
                          i_wb_adr[3:2] == 2'd1 ? i_wb_dat[ 63:32] :
                                                  i_wb_dat[ 31: 0] ;
                                                                                                                                            
    assign o_wb_dat    = {4{wb_rdata32}};
    end
else
    begin : wb32
    assign wb_wdata32  = i_wb_dat;
    assign o_wb_dat    = wb_rdata32;
    end
endgenerate


// ========================================================
// Register Reads
// ========================================================
always @( posedge i_clk )
    if ( wb_start_read )
        case ( i_wb_adr[15:0] )
            AMBER_TEST_STATUS:           wb_rdata32 <= test_status_reg;
            AMBER_TEST_FIRQ_TIMER:       wb_rdata32 <= {24'd0, firq_timer};
            AMBER_TEST_IRQ_TIMER:        wb_rdata32 <= {24'd0, irq_timer};
            AMBER_TEST_RANDOM_NUM:       wb_rdata32 <= {24'd0, random_num};
            
            /* Allow access to the random register over
               a 16-word address range to load a series
               of random numbers using lmd instruction. */
            AMBER_TEST_RANDOM_NUM00: wb_rdata32 <= {24'd0, random_num};
            AMBER_TEST_RANDOM_NUM01: wb_rdata32 <= {24'd0, random_num};
            AMBER_TEST_RANDOM_NUM02: wb_rdata32 <= {24'd0, random_num};
            AMBER_TEST_RANDOM_NUM03: wb_rdata32 <= {24'd0, random_num};
            AMBER_TEST_RANDOM_NUM04: wb_rdata32 <= {24'd0, random_num};
            AMBER_TEST_RANDOM_NUM05: wb_rdata32 <= {24'd0, random_num};
            AMBER_TEST_RANDOM_NUM06: wb_rdata32 <= {24'd0, random_num};
            AMBER_TEST_RANDOM_NUM07: wb_rdata32 <= {24'd0, random_num};
            AMBER_TEST_RANDOM_NUM08: wb_rdata32 <= {24'd0, random_num};
            AMBER_TEST_RANDOM_NUM09: wb_rdata32 <= {24'd0, random_num};
            AMBER_TEST_RANDOM_NUM10: wb_rdata32 <= {24'd0, random_num};
            AMBER_TEST_RANDOM_NUM11: wb_rdata32 <= {24'd0, random_num};
            AMBER_TEST_RANDOM_NUM12: wb_rdata32 <= {24'd0, random_num};
            AMBER_TEST_RANDOM_NUM13: wb_rdata32 <= {24'd0, random_num};
            AMBER_TEST_RANDOM_NUM14: wb_rdata32 <= {24'd0, random_num};
            AMBER_TEST_RANDOM_NUM15: wb_rdata32 <= {24'd0, random_num};
            
            //synopsys translate_off
            AMBER_TEST_UART_CONTROL:     wb_rdata32 <= {30'd0, tb_uart_control_reg};
            AMBER_TEST_UART_STATUS:      wb_rdata32 <= {30'd0, tb_uart_status_reg};
            AMBER_TEST_UART_TXD:         wb_rdata32 <= {24'd0, tb_uart_txd_reg};
            //synopsys translate_on
            
            AMBER_TEST_SIM_CTRL:         wb_rdata32 <= {29'd0, sim_ctrl_reg};
            AMBER_TEST_MEM_CTRL:         wb_rdata32 <= {31'd0, mem_ctrl_reg};
            
            AMBER_TEST_CYCLES:           wb_rdata32 <=  cycles_reg;
            AMBER_TEST_LED:              wb_rdata32 <= {27'd0, led_reg};
            AMBER_TEST_PHY_RST:          wb_rdata32 <= {31'd0, phy_rst_reg};
            default:                     wb_rdata32 <= 32'haabbccdd;
            
        endcase


// ======================================
// Simulation bit
// ======================================

// This register bit is a 1 in simulation but a 0 in the real fpga
// Used by software to tell the difference    
//synopsys translate_off

`ifndef AMBER_SIM_CTRL
    `define AMBER_SIM_CTRL 0
`endif

always @( posedge i_clk )
    begin
    // Value reads as 1 in simulation, and zero in the FPGA
    sim_ctrl_reg <= 3'd `AMBER_SIM_CTRL ;
    end
//synopsys translate_on


// ======================================
// Interrupts
// ======================================
assign o_irq  = irq_timer  == 8'd1;
assign o_firq = firq_timer == 8'd1;

        
// ======================================
// FIRQ Timer Register
// ======================================
    // Write a value > 1 to set the firq timer
    // Write 0 to clear it
always @( posedge i_clk )
    if ( wb_start_write && i_wb_adr[15:0] == AMBER_TEST_FIRQ_TIMER )
        firq_timer <= wb_wdata32[7:0];
    else if ( firq_timer > 8'd1 )
        firq_timer <= firq_timer - 1'd1;


// ======================================
// IRQ Timer Register
// ======================================
    // Write a value > 1 to set the irq timer
    // Write 0 to clear it
always @( posedge i_clk )
    if ( wb_start_write && i_wb_adr[15:0] == AMBER_TEST_IRQ_TIMER )
        irq_timer <= wb_wdata32[7:0];
    else if ( irq_timer > 8'd1 )
        irq_timer <= irq_timer - 1'd1;


// ======================================
// Random Number Generator Register
// ======================================
// Write a value > 1 to set the irq timer
// Write 0 to clear it
always @( posedge i_clk )
    begin
    if ( wb_start_write && i_wb_adr[15:8] == AMBER_TEST_RANDOM_NUM[15:8] )
        random_num <= wb_wdata32[7:0];
        
    // generate a new random number on every read access
    else if ( wb_start_read && i_wb_adr[15:8] == AMBER_TEST_RANDOM_NUM[15:8] )
        random_num <= { random_num[3]^random_num[1], 
                        random_num[0]^random_num[5], 
                        ~random_num[7]^random_num[4], 
                        ~random_num[2],
                        random_num[6],
                        random_num[4]^~random_num[3],
                        random_num[7]^~random_num[1],
                        random_num[7]                     
                      };
    end    


// ======================================
// Test Status Write
// ======================================
always @( posedge i_clk )
    if ( wb_start_write && i_wb_adr[15:0] == AMBER_TEST_STATUS )
        test_status_reg <= wb_wdata32;  
     

// ======================================
// Test Status Write
// ======================================
always @( posedge i_clk )
    if ( wb_start_write && i_wb_adr[15:0] == AMBER_TEST_STATUS )
        test_status_set <= 1'd1;     


// ======================================
// Cycles counter
// ======================================
always @( posedge i_clk )
    cycles_reg <= cycles_reg + 1'd1;

  
// ======================================
// Memory Configuration Register Write
// ======================================
always @( posedge i_clk )
    if ( wb_start_write && i_wb_adr[15:0] == AMBER_TEST_MEM_CTRL )
        mem_ctrl_reg <= wb_wdata32[0];     


// ======================================
// Test LEDs
// ======================================
always @( posedge i_clk )
    if ( wb_start_write && i_wb_adr[15:0] == AMBER_TEST_LED )
        led_reg <= wb_wdata32[3:0];     


// ======================================
// PHY Reset Register
// ======================================
always @( posedge i_clk )
    if ( wb_start_write && i_wb_adr[15:0] == AMBER_TEST_PHY_RST )
        phy_rst_reg <= wb_wdata32[0];     


// ======================================
// Test UART registers
// ======================================
// These control the testbench UART, not the real
// UART in system

//synopsys translate_off
always @( posedge i_clk )
    begin
    if ( wb_start_write && i_wb_adr[15:0] == AMBER_TEST_UART_CONTROL )
        tb_uart_control_reg <= wb_wdata32[1:0];  
        
    if ( wb_start_write && i_wb_adr[15:0] == AMBER_TEST_UART_TXD )
        begin
        tb_uart_txd_reg   <= wb_wdata32[7:0];
        tb_uart_push      <= !tb_uart_push;
        end
    end
//synopsys translate_on


    
endmodule

