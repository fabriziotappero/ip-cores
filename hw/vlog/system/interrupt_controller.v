//////////////////////////////////////////////////////////////////
//                                                              //
//  Interrupt Controller for Amber                              //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Wishbone slave module that arbitrates between a number of   //
//  interrupt sources.
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


module interrupt_controller  #(
parameter WB_DWIDTH  = 32,
parameter WB_SWIDTH  = 4
)(
input                       i_clk,

input       [31:0]          i_wb_adr,
input       [WB_SWIDTH-1:0] i_wb_sel,
input                       i_wb_we,
output      [WB_DWIDTH-1:0] o_wb_dat,
input       [WB_DWIDTH-1:0] i_wb_dat,
input                       i_wb_cyc,
input                       i_wb_stb,
output                      o_wb_ack,
output                      o_wb_err,

output                      o_irq,
output                      o_firq,

input                       i_uart0_int,
input                       i_uart1_int,
input                       i_ethmac_int,
input                       i_test_reg_irq,
input                       i_test_reg_firq,
input       [2:0]           i_tm_timer_int

);


`include "register_addresses.vh"


// Wishbone registers
reg  [31:0]     irq0_enable_reg  = 'd0;
reg  [31:0]     firq0_enable_reg = 'd0;
reg  [31:0]     irq1_enable_reg  = 'd0;
reg  [31:0]     firq1_enable_reg = 'd0;
reg             softint_0_reg    = 'd0;
reg             softint_1_reg    = 'd0;

wire [31:0]     raw_interrupts;
wire [31:0]     irq0_interrupts;
wire [31:0]     firq0_interrupts;
wire [31:0]     irq1_interrupts;
wire [31:0]     firq1_interrupts;

wire            irq_0;
wire            firq_0;
wire            irq_1;
wire            firq_1;

// Wishbone interface
reg  [31:0]     wb_rdata32 = 'd0;
wire            wb_start_write;
wire            wb_start_read;
reg             wb_start_read_d1 = 'd0;
wire [31:0]     wb_wdata32;


// ======================================================
// Wishbone Interface
// ======================================================

// Can't start a write while a read is completing. The ack for the read cycle
// needs to be sent first
assign wb_start_write = i_wb_stb && i_wb_we && !wb_start_read_d1;
assign wb_start_read  = i_wb_stb && !i_wb_we && !o_wb_ack;

always @( posedge i_clk )
    wb_start_read_d1 <= wb_start_read;


assign o_wb_err = 1'd0;
assign o_wb_ack = i_wb_stb && ( wb_start_write || wb_start_read_d1 );

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


// ======================================
// Interrupts
// ======================================
assign raw_interrupts =  {23'd0,
                          i_ethmac_int,             // 8: Ethernet MAC interrupt

                          i_tm_timer_int[2],        // 7: Timer Module Interrupt 2
                          i_tm_timer_int[1],        // 6: Timer Module Interrupt 1
                          i_tm_timer_int[0],        // 5: Timer Module Interrupt 0
                          1'd0,

                          1'd0,
                          i_uart1_int,              // 2: Uart 1 interrupt
                          i_uart0_int,              // 1: Uart 0 interrupt
                          1'd0                      // 0: Software interrupt not
                         };                         // here because its not maskable

assign irq0_interrupts  = {raw_interrupts[31:1], softint_0_reg} & irq0_enable_reg;
assign firq0_interrupts =  raw_interrupts                       & firq0_enable_reg;
assign irq1_interrupts  = {raw_interrupts[31:1], softint_1_reg} & irq1_enable_reg;
assign firq1_interrupts  = raw_interrupts                       & firq1_enable_reg;

// The interrupts from the test registers module are not masked,
// just to keep their usage really simple
assign irq_0  = |{irq0_interrupts,  i_test_reg_irq};
assign firq_0 = |{firq0_interrupts, i_test_reg_firq};
assign irq_1  = |irq1_interrupts;
assign firq_1 = |firq1_interrupts;

assign o_irq  = irq_0  | irq_1;
assign o_firq = firq_0 | firq_1;


// ========================================================
// Register Writes
// ========================================================
always @( posedge i_clk )
    if ( wb_start_write )
        case ( i_wb_adr[15:0] )
            AMBER_IC_IRQ0_ENABLESET:  irq0_enable_reg  <=  irq0_enable_reg  | ( i_wb_dat);
            AMBER_IC_IRQ0_ENABLECLR:  irq0_enable_reg  <=  irq0_enable_reg  & (~i_wb_dat);
            AMBER_IC_FIRQ0_ENABLESET: firq0_enable_reg <=  firq0_enable_reg | ( i_wb_dat);
            AMBER_IC_FIRQ0_ENABLECLR: firq0_enable_reg <=  firq0_enable_reg & (~i_wb_dat);

            AMBER_IC_INT_SOFTSET_0:   softint_0_reg    <=  softint_0_reg   | ( i_wb_dat[0]);
            AMBER_IC_INT_SOFTCLEAR_0: softint_0_reg    <=  softint_0_reg   & (~i_wb_dat[0]);

            AMBER_IC_IRQ1_ENABLESET:  irq1_enable_reg  <=  irq1_enable_reg  | ( i_wb_dat);
            AMBER_IC_IRQ1_ENABLECLR:  irq1_enable_reg  <=  irq1_enable_reg  & (~i_wb_dat);
            AMBER_IC_FIRQ1_ENABLESET: firq1_enable_reg <=  firq1_enable_reg | ( i_wb_dat);
            AMBER_IC_FIRQ1_ENABLECLR: firq1_enable_reg <=  firq1_enable_reg & (~i_wb_dat);

            AMBER_IC_INT_SOFTSET_1:   softint_1_reg    <=  softint_1_reg   | ( i_wb_dat[0]);
            AMBER_IC_INT_SOFTCLEAR_1: softint_1_reg    <=  softint_1_reg   & (~i_wb_dat[0]);
        endcase


// ========================================================
// Register Reads
// ========================================================
always @( posedge i_clk )
    if ( wb_start_read )
        case ( i_wb_adr[15:0] )

            AMBER_IC_IRQ0_ENABLESET:    wb_rdata32 <= irq0_enable_reg;
            AMBER_IC_FIRQ0_ENABLESET:   wb_rdata32 <= firq0_enable_reg;
            AMBER_IC_IRQ0_RAWSTAT:      wb_rdata32 <= raw_interrupts;
            AMBER_IC_IRQ0_STATUS:       wb_rdata32 <= irq0_interrupts;
            AMBER_IC_FIRQ0_RAWSTAT:     wb_rdata32 <= raw_interrupts;
            AMBER_IC_FIRQ0_STATUS:      wb_rdata32 <= firq0_interrupts;

            AMBER_IC_INT_SOFTSET_0:     wb_rdata32 <= {31'd0, softint_0_reg};
            AMBER_IC_INT_SOFTCLEAR_0:   wb_rdata32 <= {31'd0, softint_0_reg};

            AMBER_IC_IRQ1_ENABLESET:    wb_rdata32 <= irq1_enable_reg;
            AMBER_IC_FIRQ1_ENABLESET:   wb_rdata32 <= firq1_enable_reg;
            AMBER_IC_IRQ1_RAWSTAT:      wb_rdata32 <= raw_interrupts;
            AMBER_IC_IRQ1_STATUS:       wb_rdata32 <= irq1_interrupts;
            AMBER_IC_FIRQ1_RAWSTAT:     wb_rdata32 <= raw_interrupts;
            AMBER_IC_FIRQ1_STATUS:      wb_rdata32 <= firq1_interrupts;

            AMBER_IC_INT_SOFTSET_1:     wb_rdata32 <= {31'd0, softint_1_reg};
            AMBER_IC_INT_SOFTCLEAR_1:   wb_rdata32 <= {31'd0, softint_1_reg};

            default:                    wb_rdata32 <= 32'h22334455;

        endcase



// =======================================================================================
// =======================================================================================
// =======================================================================================
// Non-synthesizable debug code
// =======================================================================================


//synopsys translate_off
`ifdef AMBER_IC_DEBUG

wire wb_read_ack = i_wb_stb && ( wb_start_write || wb_start_read_d1 );

// -----------------------------------------------
// Report Interrupt Controller Register accesses
// -----------------------------------------------
always @(posedge i_clk)
    if ( wb_read_ack || wb_start_write )
        begin
        `TB_DEBUG_MESSAGE

        if ( wb_start_write )
            $write("Write 0x%08x to   ", i_wb_dat);
        else
            $write("Read  0x%08x from ", o_wb_dat);

        case ( i_wb_adr[15:0] )
            AMBER_IC_IRQ0_STATUS:
                $write(" Interrupt Controller module IRQ0 Status");
            AMBER_IC_IRQ0_RAWSTAT:
                $write(" Interrupt Controller module IRQ0 Raw Status");
            AMBER_IC_IRQ0_ENABLESET:
                $write(" Interrupt Controller module IRQ0 Enable Set");
            AMBER_IC_IRQ0_ENABLECLR:
                $write(" Interrupt Controller module IRQ0 Enable Clear");
            AMBER_IC_FIRQ0_STATUS:
                $write(" Interrupt Controller module FIRQ0 Status");
            AMBER_IC_FIRQ0_RAWSTAT:
                $write(" Interrupt Controller module FIRQ0 Raw Status");
            AMBER_IC_FIRQ0_ENABLESET:
                $write(" Interrupt Controller module FIRQ0 Enable set");
            AMBER_IC_FIRQ0_ENABLECLR:
                $write(" Interrupt Controller module FIRQ0 Enable Clear");
            AMBER_IC_INT_SOFTSET_0:
                $write(" Interrupt Controller module SoftInt 0 Set");
            AMBER_IC_INT_SOFTCLEAR_0:
                $write(" Interrupt Controller module SoftInt 0 Clear");
            AMBER_IC_IRQ1_STATUS:
                $write(" Interrupt Controller module IRQ1 Status");
            AMBER_IC_IRQ1_RAWSTAT:
                $write(" Interrupt Controller module IRQ1 Raw Status");
            AMBER_IC_IRQ1_ENABLESET:
                $write(" Interrupt Controller module IRQ1 Enable Set");
            AMBER_IC_IRQ1_ENABLECLR:
                $write(" Interrupt Controller module IRQ1 Enable Clear");
            AMBER_IC_FIRQ1_STATUS:
                $write(" Interrupt Controller module FIRQ1 Status");
            AMBER_IC_FIRQ1_RAWSTAT:
                $write(" Interrupt Controller module FIRQ1 Raw Status");
            AMBER_IC_FIRQ1_ENABLESET:
                $write(" Interrupt Controller module FIRQ1 Enable set");
            AMBER_IC_FIRQ1_ENABLECLR:
                $write(" Interrupt Controller module FIRQ1 Enable Clear");
            AMBER_IC_INT_SOFTSET_1:
                $write(" Interrupt Controller module SoftInt 1 Set");
            AMBER_IC_INT_SOFTCLEAR_1:
                $write(" Interrupt Controller module SoftInt 1 Clear");

            default:
                begin
                $write(" unknown Amber IC Register region");
                $write(", Address 0x%08h\n", i_wb_adr);
                `TB_ERROR_MESSAGE
                end
        endcase

        $write(", Address 0x%08h\n", i_wb_adr);
        end
`endif

//synopsys translate_on


endmodule

