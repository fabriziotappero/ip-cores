//////////////////////////////////////////////////////////////////////
////                                                              ////
////  $Id: wb_mmu.v,v 1.4 2008-12-15 06:42:44 hharte Exp $        ////
////  wb_mmu.v - Simple Memory Mapping Unit with Wishbone         ////
////             Slave interface for configuration.               ////
////                                                              ////
////  This file is part of the Vector Graphic Z80 SBC Project     ////
////  http://www.opencores.org/projects/vg_z80_sbc/               ////
////                                                              ////
////  Author:                                                     ////
////      - Howard M. Harte (hharte@opencores.org)                ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008 Howard M. Harte                           ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

//+---------------------------------------------------------------------------+
//|
//| Simple Memory Mapping Unit (MMU) for allowing a CPU with a 16-bit address
//| space to access a 16MB address space, using 16 4K pages.
//| 
//| The MMU has a table of 16 4K "pages" that can be map an address in the
//| 64K space into a corresponding address in a 16MB space.  Each 4K page can
//| map to any 4K boundary in a 16MB (24-bit) physical address space.
//| 
//| The MMU occupies four byte-wide memory locations, and must be accessed as
//| bytes.  The registers are as follows:
//|
//| 0 - MMR_L       Lower 8-bits = MMR_L  <ll>
//| 1 - MMR_H       Upper 4-bits = MMR_H  <h>
//| 2 - ADR_INDEX   (0x0-0xF to select the memory region modified by the MMR_x
//|                 registers.  This register defaults to 0 at reset.
//| 3 - LOCK        Writing 0xA5 to this register unlocks to MMU, any other
//|                 value locks it.  When locked, the MMR_L, MMR_H registers
//|                 are read-only.  Reading the LOCK register returns 0x51
//|                 if locked, 0x50 if unlocked.  The MMU is locked on reset.
//| 
//| The MMU forms the final 24-bit address on the 4K page as follows:
//|
//|      <pxxx> - 64K unmapped address (mmu_adr_i)
//| <h>:<llxxx> - 16M mapped address (mmu_adr_o)
//| 
//| where: p = 4K page in 64K address space
//|        h = MMR_H register
//|        l = MMR_L register
//|        x = address bits passed through the MMU unchanged.
//|
//+---------------------------------------------------------------------------+
module wb_mmu(
    clk_i, nrst_i, wbs_adr_i, wbs_dat_o, wbs_dat_i, wbs_sel_i, wbs_we_i,
    wbs_stb_i, wbs_cyc_i, wbs_ack_o,
    mmu_adr_i,
    mmu_adr_o,
    rom_sel_i
);

//`define USE_SERIAL_MONITOR  // Define to use MON4.0C Serial Monitor, 'G E80C' to boot floppy
    // Wishbone Slave Interface
    input          clk_i;
    input          nrst_i;
    input    [1:0] wbs_adr_i;
    output reg [7:0] wbs_dat_o;
    input    [7:0] wbs_dat_i;
    input    [3:0] wbs_sel_i;
    input          wbs_we_i;
    input          wbs_stb_i;
    input          wbs_cyc_i;
    output  reg    wbs_ack_o;
    
    // MMU Address Interface
    output  [23:0] mmu_adr_o;
    input   [23:0] mmu_adr_i;
    
    // Reset memory mapping selection
    input          rom_sel_i;

    // Internal storage for mapping and state information
    reg     [11:0] mmu_lut[0:15];
    reg      [3:0] adr_index;
    reg            mmu_lock;

    //
    // generate wishbone register bank writes
    wire wbs_acc = wbs_cyc_i & wbs_stb_i;    // WISHBONE access
    wire wbs_wr  = wbs_acc & wbs_we_i;       // WISHBONE write access
    wire wbs_rd  = wbs_acc & !wbs_we_i;      // WISHBONE read access
    reg      [4:0] i;

    always @(posedge clk_i or negedge nrst_i)
        if(~nrst_i) // Reset
        begin
            wbs_ack_o <= 1'b0;
            adr_index <= 4'b0;
            mmu_lock <= 1'b1;               // Lock MMU on reset
                
            // Initial values for MMU mapping table.
            mmu_lut[0]  <= 12'h100;      // 0x0xxx - Shadow of Monitor, only used to jump to monitor at 0xE000.
                                         // But not the same copy as at E000, because the init patches RST38.        
            mmu_lut[1]  <= 12'h201;      // 0x1000
            mmu_lut[2]  <= 12'h801;      // 0x2000
            mmu_lut[3]  <= 12'h802;      // 0x3000
            mmu_lut[4]  <= 12'h803;      // 0x4000
            mmu_lut[5]  <= 12'h804;      // 0x5000
            mmu_lut[6]  <= 12'h805;      // 0x6000
            mmu_lut[7]  <= 12'h806;      // 0x7000
            mmu_lut[8]  <= 12'h807;      // 0x8000
            mmu_lut[9]  <= 12'h808;      // 0x9000
            mmu_lut[10] <= 12'h809;      // 0xA000
            mmu_lut[11] <= 12'h200;      // 0xB000 - SRAM2-0
            mmu_lut[12] <= 12'h101;      // 0xC000 - SRAM0-3
`ifdef USE_SERIAL_MONITOR
            // Use Serial Monitor
            mmu_lut[13] <= 12'h103;  // 0xD000 - MON 4.3  (Flashwriter2 Monitor)
            mmu_lut[14] <= 12'h102;  // 0xE000 - MON 4.0c (Serial Monitor)
`else
            // Use Flashwriter2 Monitor
            mmu_lut[13] <= 12'h102;  // 0xD000 - MON 4.0c (Serial Monitor)
            mmu_lut[14] <= 12'h103;  // 0xE000 - MON 4.3  (Flashwriter2 Monitor)
`endif // USE_SERIAL_MONITOR
            mmu_lut[15] <= 12'h600;      // 0xF000 - VGA
        end
        else begin
            if(wbs_wr)  // Wishbone Write, decode byte enables to determine register offset.
                case(wbs_adr_i)
                    2'h0: begin   // Data L Register
                        if(mmu_lock == 1'b0)
                            mmu_lut[adr_index[3:0]][7:0] <= wbs_dat_i;
                    end
                    2'h1: begin   // Data H Register
                        if(mmu_lock == 1'b0)
                            mmu_lut[adr_index[3:0]][11:8] <= wbs_dat_i[3:0];
                    end
                    2'h2: begin   // Index Register
                        adr_index <= wbs_dat_i[3:0];
                    end
                    2'h3: begin   // Lock Register
                        if(wbs_dat_i == 8'hA5) begin
                            mmu_lock <= 1'b0;
                        end else begin
                            mmu_lock <= 1'b1;
                        end
                    end
                endcase

            if(wbs_rd) begin
                case(wbs_adr_i) // Wishbone Read, decode byte enables to determine register offset.
                    2'h0: begin   // Data L Register
                        wbs_dat_o <= mmu_lut[adr_index[3:0]][7:0];
                    end
                    2'h1: begin   // Data H Register
                        wbs_dat_o <= { 4'h0, mmu_lut[adr_index[3:0]][11:8] };
                    end
                    2'h2: begin   // Index Register
                        wbs_dat_o <= {4'b0, adr_index};
                    end
                    2'h3: begin   // Lock Register
                        wbs_dat_o <= {4'h5, 3'b0, mmu_lock};
                    end
                endcase
            end
          
            wbs_ack_o <= wbs_acc & !wbs_ack_o;
        end

    // Make the address mapping based on the MMU input address.
    wire [11:0] mmu_out = { mmu_lut[mmu_adr_i[15:12]] };
    
    // Output the mapped address with the lower 12-bits passed through.
    assign mmu_adr_o = {mmu_out[11:0], mmu_adr_i[11:0]};

endmodule

                            
