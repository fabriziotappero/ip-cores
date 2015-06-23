//============================================================================
// Sinclair ZX Spectrum host board
//
//  Copyright (C) 2014  Goran Devic
//
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation; either version 2 of the License, or (at your option)
//  any later version.
//
//  This program is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
//  more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, write to the Free Software Foundation, Inc.,
//  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//============================================================================
module zxspectrum_board
(
    //-------- Clocks and reset -----------------
    input wire CLOCK_27,            // Input clock 27 MHz
    input wire CLOCK_24,            // Input clock 24 MHz
    input wire KEY0,                // RESET button
    input wire KEY1,                // NMI button

    //-------- PS/2 Keyboard --------------------
    input wire PS2_CLK,
    input wire PS2_DAT,

    //-------- Audio (Tape player) --------------
    inout wire I2C_SCLK,
    inout wire I2C_SDAT,
    output wire AUD_XCK,
    output wire AUD_ADCLRCK,
    output wire AUD_DACLRCK,
    output wire AUD_BCLK,
    output wire AUD_DACDAT,
    input wire AUD_ADCDAT,

    //-------- VGA connector --------------------
    output wire [3:0] VGA_R,
    output wire [3:0] VGA_G,
    output wire [3:0] VGA_B,
    output reg VGA_HS,
    output reg VGA_VS,

    //-------- Flash memory interface -----------
    output wire [21:0] FL_ADDR,
    input wire [7:0] FL_DQ,
    output wire FL_CE_N,
    output wire FL_OE_N,
    output wire FL_WE_N,
    output wire FL_RST_N,

    //-------- SRAM memory interface ------------
    output wire [17:0] SRAM_ADDR,
    inout reg [15:0] SRAM_DQ,
    output wire SRAM_CE_N,
    output wire SRAM_OE_N,
    output wire SRAM_WE_N,
    output wire SRAM_UB_N,
    output wire SRAM_LB_N,

    //-------- My little imitation of a Kempston joystick -----------
    input wire [5:0] kempston,
    output wire [4:0] LEDG,         // Show the joystick state

    //-------- Misc and debug -------------------
    input wire SW0,                 // ROM selection
    input wire SW1,                 // Enable/disable interrupts
    input wire SW2,                 // Turbo speed (3.5 MHz x 2 = 7.0 MHz)
    output wire [2:0] LEDR,         // Shows the switch selection
    inout wire [31:0] GPIO_1,
    output wire [2:0] LEDGTOP       // Show additional information visually
);
`default_nettype none

wire reset;
wire locked;
assign reset = locked & KEY0;

// Export selected pins to the extension connector
assign GPIO_1[15:0] = A[15:0];
assign GPIO_1[23:16] = D[7:0];
assign GPIO_1[31:24] = {nM1,nMREQ,nIORQ,nRD,nWR,nRFSH,nHALT,nBUSACK};
//assign GPIO_1[] = {nWAIT,nINT,nNMI,nRESET,nBUSRQ,CLK};

// Top 3 green LEDs show various states:
assign LEDGTOP[2] = 0;              // Reserved for future use
assign LEDGTOP[1] = beeper;         // Show the beeper state
assign LEDGTOP[0] = pressed;        // Show when a key is being pressed

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Internal buses and address map selection logic
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
wire [15:0] A;                  // Global address bus
wire [7:0] D;                   // CPU data bus

wire [7:0] ram_data;            // Internal 16K RAM data
wire RamWE;
assign RamWE = A[15:14]==2'b01 && nIORQ==1 && nRD==1 && nWR==0;

wire ExtRamWE;                  // Extended (and external) 32K RAM
assign ExtRamWE = A[15]==1 && nIORQ==1 && nRD==1 && nWR==0;
assign SRAM_DQ[15:0] = ExtRamWE? {8'b0,D[7:0]} : {16{1'bz}};

wire [7:0] ula_data;            // ULA
wire io_we;
assign io_we = nIORQ==0 && nRD==1 && nWR==0;

// Memory map:
//   0000 - 3FFF  16K ROM (mapped to the external Flash memory)
//   4000 - 7FFF  16K dual-port RAM
//   8000 - FFFF  32K RAM (mapped to the external SRAM memory)
always_comb
begin
    case ({nIORQ,nRD,nWR})
        // -------------------------------- Memory read --------------------------------
        3'b101: begin
                casez (A[15:14])
                    2'b00:  D[7:0] = FL_DQ;
                    2'b01:  D[7:0] = ram_data;
                    2'b1?:  D[7:0] = SRAM_DQ[7:0];
                endcase
            end
        // ---------------------------------- IO read ----------------------------------
        3'b001: begin
                // Normally data supplied by the ULA
                D[7:0] = ula_data;

                // Kempston joystick at the IO address of 0x1F: active bits are high: 000FUDLR
                // The bits are scrambled since I just happen to solder them that way on a game
                // pad I've got (see my blog); you can remap it if you have another kind of joystick
                if (A[7:0]==8'h1F) begin
                    D[7:0] = { 3'b0, !kempston[3],!kempston[5],!kempston[4],!kempston[0],!kempston[2] };
                end
            end
    default:
        D[7:0] = {8{1'bz}};
    endcase
end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// 16K of the original ZX Spectrum ROM is in the flash at the address 0
// 16K of The GOSH WONDERFUL ZX Spectrum ROM is in the flash following it
//    http://www.wearmouth.demon.co.uk/gw03/gw03info.htm
// SW0 selectes which ROM is going to be used by feeding the address bit 14
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
assign FL_ADDR[13:0] = A[13:0];
assign FL_ADDR[14] = SW0;
assign LEDR[0] = SW0;           // Glow red when using alternate ROM
assign FL_ADDR[21:15] = '0;
assign FL_RST_N = KEY0;
assign FL_CE_N = 0;
assign FL_OE_N = 0;
assign FL_WE_N = 1;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Instantiate 16K dual-port RAM
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
wire clk_vram;
// "A" side is the CPU side, "B" side is the VGA image generator
ram16 ram16_(
    .clock      (clk_vram),     // RAM connects to the higher, pixel clock rate

    .address_a  (A[13:0]),      // Address in to the RAM from the CPU side
    .data_a     (D),            // Data in to the RAM from the CPU side
    .q_a        (ram_data),     // Data out from the RAM into the data bus selector
    .wren_a     (RamWE),

    .address_b  (vram_address),
    .data_b     (0),
    .q_b        (vram_data),
    .wren_b     (0));

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// 32K of ZX Spectrum extended RAM is using the external SRAM memory
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
assign SRAM_ADDR[14:0] = A[14:0];
assign SRAM_ADDR[17:15] = '0;
assign SRAM_CE_N = 0;
assign SRAM_OE_N = 0;
assign SRAM_WE_N = !ExtRamWE;
assign SRAM_UB_N = 1;
assign SRAM_LB_N = 0;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Instantiate ULA
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
wire clk_cpu;                   // Global CPU clock of 3.5 MHz
assign LEDR[2] = SW2;           // Glow red when in turbo mode (7.0 MHz)
wire [12:0] vram_address;       // ULA video block requests a byte from the video RAM
wire [7:0] vram_data;           // ULA video block reads a byte from the video RAM
wire vs_nintr;                  // Generates a vertical retrace interrupt
wire pressed;                   // Show that a key is being pressed
wire beeper;                    // Show the beeper state

ula ula_( .*, .turbo(SW2), .clk_cpu(clk_cpu) );

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Instantiate A-Z80 CPU
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
wire nM1;
wire nMREQ;
wire nIORQ;
wire nRD;
wire nWR;
wire nRFSH;
wire nHALT;
wire nBUSACK;

wire nWAIT = 1;
wire nINT = (SW1==0)? vs_nintr : '1;// SW1 disables interrupts and, hence, keyboard
assign LEDR[1] = SW1;               // Glow red when interrupts are *disabled*
wire nNMI = KEY1;                   // Pressing KEY1 issues a NMI
wire nBUSRQ = 1;

z80_top_direct_n z80_( .*, .nRESET(reset), .CLK(clk_cpu) );

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Lit green LEDs to show activity on a Kempston compatible joystick
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
assign LEDG[0] = !kempston[5];                  // UP
assign LEDG[1] = !kempston[4];                  // DOWN
assign LEDG[2] = !kempston[0];                  // LEFT
assign LEDG[3] = !kempston[2];                  // RIGHT
assign LEDG[4] = !kempston[3] | !kempston[1];   // BUTTON

endmodule
