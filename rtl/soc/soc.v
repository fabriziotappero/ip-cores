//-----------------------------------------------------------------
//                           AltOR32 
//                Alternative Lightweight OpenRisc 
//                            V2.0
//                     Ultra-Embedded.com
//                   Copyright 2011 - 2013
//
//               Email: admin@ultra-embedded.com
//
//                       License: LGPL
//-----------------------------------------------------------------
//
// Copyright (C) 2011 - 2013 Ultra-Embedded.com
//
// This source file may be used and distributed without         
// restriction provided that this copyright statement is not    
// removed from the file and that any derivative work contains  
// the original copyright notice and the associated disclaimer. 
//
// This source file is free software; you can redistribute it   
// and/or modify it under the terms of the GNU Lesser General   
// Public License as published by the Free Software Foundation; 
// either version 2.1 of the License, or (at your option) any   
// later version.
//
// This source is distributed in the hope that it will be       
// useful, but WITHOUT ANY WARRANTY; without even the implied   
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
// PURPOSE.  See the GNU Lesser General Public License for more 
// details.
//
// You should have received a copy of the GNU Lesser General    
// Public License along with this source; if not, write to the 
// Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
// Boston, MA  02111-1307  USA
//-----------------------------------------------------------------

//-----------------------------------------------------------------
// Module:
//-----------------------------------------------------------------
module soc
(
    // General - Clocking & Reset
    clk_i,
    rst_i,
    ext_intr_i,
    intr_o,

    // Memory interface
    io_addr_i,
    io_data_i,
    io_data_o,
    io_we_i,
    io_stb_i,    
    io_ack_o
);

//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
parameter  [31:0]   CLK_KHZ              = 12288;
parameter  [31:0]   EXTERNAL_INTERRUPTS  = 1;
parameter           SYSTICK_INTR_MS      = 1;
parameter           ENABLE_SYSTICK_TIMER = "ENABLED";
parameter           ENABLE_HIGHRES_TIMER = "ENABLED";

//-----------------------------------------------------------------
// I/O
//-----------------------------------------------------------------
input                   clk_i /*verilator public*/;
input                   rst_i /*verilator public*/;
input [(EXTERNAL_INTERRUPTS - 1):0]  ext_intr_i /*verilator public*/;
output                  intr_o /*verilator public*/;

// Memory Port
input [31:0]            io_addr_i /*verilator public*/;
input [31:0]            io_data_i /*verilator public*/;
output [31:0]           io_data_o /*verilator public*/;
input                   io_we_i /*verilator public*/;
input                   io_stb_i /*verilator public*/;
output                  io_ack_o /*verilator public*/;

//-----------------------------------------------------------------
// Registers / Wires
//-----------------------------------------------------------------
wire [7:0]         timer_addr;
wire [31:0]        timer_data_o;
wire [31:0]        timer_data_i;
wire               timer_we;
wire               timer_stb;
wire               timer_intr_systick;
wire               timer_intr_hires;

wire [7:0]         intr_addr;
wire [31:0]        intr_data_o;
wire [31:0]        intr_data_i;
wire               intr_we;
wire               intr_stb;

//-----------------------------------------------------------------
// Peripheral Interconnect
//-----------------------------------------------------------------
soc_pif8
u2_soc
(
    // General - Clocking & Reset
    .clk_i(clk_i),
    .rst_i(rst_i),

    // I/O bus (from mem_mux)
    // 0x12000000 - 0x12FFFFFF
    .io_addr_i(io_addr_i),
    .io_data_i(io_data_i),
    .io_data_o(io_data_o),
    .io_we_i(io_we_i),
    .io_stb_i(io_stb_i),
    .io_ack_o(io_ack_o),

    // Peripherals
    // Unused = 0x12000000 - 0x120000FF
    .periph0_addr_o(/*open*/),
    .periph0_data_o(/*open*/),
    .periph0_data_i(32'h00000000),
    .periph0_we_o(/*open*/),
    .periph0_stb_o(/*open*/),

    // Timer = 0x12000100 - 0x120001FF
    .periph1_addr_o(timer_addr),
    .periph1_data_o(timer_data_o),
    .periph1_data_i(timer_data_i),
    .periph1_we_o(timer_we),
    .periph1_stb_o(timer_stb),

    // Interrupt Controller = 0x12000200 - 0x120002FF
    .periph2_addr_o(intr_addr),
    .periph2_data_o(intr_data_o),
    .periph2_data_i(intr_data_i),
    .periph2_we_o(intr_we),
    .periph2_stb_o(intr_stb),

    // Unused = 0x12000300 - 0x120003FF
    .periph3_addr_o(/*open*/),
    .periph3_data_o(/*open*/),
    .periph3_data_i(32'h00000000),
    .periph3_we_o(/*open*/),
    .periph3_stb_o(/*open*/),

    // Unused = 0x12000400 - 0x120004FF
    .periph4_addr_o(/*open*/),
    .periph4_data_o(/*open*/),
    .periph4_data_i(32'h00000000),
    .periph4_we_o(/*open*/),
    .periph4_stb_o(/*open*/),

    // Unused = 0x12000500 - 0x120005FF
    .periph5_addr_o(/*open*/),
    .periph5_data_o(/*open*/),
    .periph5_data_i(32'h00000000),
    .periph5_we_o(/*open*/),
    .periph5_stb_o(/*open*/),

    // Unused = 0x12000600 - 0x120006FF
    .periph6_addr_o(/*open*/),
    .periph6_data_o(/*open*/),
    .periph6_data_i(32'h00000000),
    .periph6_we_o(/*open*/),
    .periph6_stb_o(/*open*/),

    // Unused = 0x12000700 - 0x120007FF
    .periph7_addr_o(/*open*/),
    .periph7_data_o(/*open*/),
    .periph7_data_i(32'h00000000),
    .periph7_we_o(/*open*/),
    .periph7_stb_o(/*open*/)
);

//-----------------------------------------------------------------
// Timer
//-----------------------------------------------------------------
timer_periph
#(
    .CLK_KHZ(CLK_KHZ),
    .SYSTICK_INTR_MS(SYSTICK_INTR_MS),
    .ENABLE_SYSTICK_TIMER(ENABLE_SYSTICK_TIMER),
    .ENABLE_HIGHRES_TIMER(ENABLE_HIGHRES_TIMER)
)
u5_timer
(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .intr_systick_o(timer_intr_systick),
    .intr_hires_o(timer_intr_hires),
    .addr_i(timer_addr),
    .data_o(timer_data_i),
    .data_i(timer_data_o),
    .we_i(timer_we),
    .stb_i(timer_stb)
);

//-----------------------------------------------------------------
// Interrupt Controller
//-----------------------------------------------------------------
intr_periph
#(
    .EXTERNAL_INTERRUPTS(EXTERNAL_INTERRUPTS)
)
u6_intr
(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .intr_o(intr_o),

    .intr0_i(1'b0),

    .intr1_i(timer_intr_systick),
    .intr2_i(timer_intr_hires),
    .intr3_i(1'b0),

    .intr4_i(1'b0),

    .intr5_i(1'b0),

    .intr6_i(1'b0),

    .intr7_i(1'b0),
    .intr_ext_i(ext_intr_i),

    .addr_i(intr_addr),
    .data_o(intr_data_i),
    .data_i(intr_data_o),
    .we_i(intr_we),
    .stb_i(intr_stb)
);

//-------------------------------------------------------------------
// Hooks for debug
//-------------------------------------------------------------------
`ifdef verilator
   function [0:0] get_uart_wr;
      // verilator public
      get_uart_wr = 1'b0;
   endfunction
   
   function [7:0] get_uart_data;
      // verilator public
      get_uart_data = 8'b0;
   endfunction
`endif

endmodule
