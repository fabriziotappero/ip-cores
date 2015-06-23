//////////////////////////////////////////////////////////////////////
////                                                              ////
////  $Id: wb_lpc_periph.v,v 1.4 2008-07-26 19:15:32 hharte Exp $ ////
////  wb_lpc_periph.v - LPC Peripheral to Wishbone Master Bridge  ////
////                                                              ////
////  This file is part of the Wishbone LPC Bridge project        ////
////  http://www.opencores.org/projects/wb_lpc/                   ////
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

`timescale 1 ns / 1 ns

`include "../../rtl/verilog/wb_lpc_defines.v"

//              I/O Write       I/O Read        DMA Read        DMA Write
//                                                          
//  States - 1. H Start         H Start         H Start         H Start
//           2. H CYCTYPE+DIR   H CYCTYPE+DIR   H CYCTYPE+DIR   H CYCTYPE+DIR
//           3. H Addr (4)      H Addr (4)      H CHAN+TC       H CHAN+TC
//                                              H SIZE          H SIZE
//           4. H Data (2)      H TAR  (2)    +-H DATA (2)      H TAR  (2)
//           5. H TAR  (2)      P SYNC (1+)   | H TAR  (2)    +-P SYNC (1+)
//           6. P SYNC (1+)     P DATA (2)    | H SYNC (1+)   +-P DATA (2)
//           7. P TAR  (2)      P TAR  (2)    +-P TAR  (2)      P TAR
//                                                          

module wb_lpc_periph(clk_i, nrst_i, wbm_adr_o, wbm_dat_o, wbm_dat_i, wbm_sel_o, wbm_tga_o, wbm_we_o,
                     wbm_stb_o, wbm_cyc_o, wbm_ack_i, wbm_err_i,
                     dma_chan_o, dma_tc_o,
                     lframe_i, lad_i, lad_o, lad_oe
);

    // Wishbone Master Interface
    input              clk_i;
    input              nrst_i;
    output reg  [31:0] wbm_adr_o;
    output reg  [31:0] wbm_dat_o;
    input       [31:0] wbm_dat_i;
    output reg   [3:0] wbm_sel_o;
    output reg   [1:0] wbm_tga_o;
    output reg         wbm_we_o;
    output reg         wbm_stb_o;
    output reg         wbm_cyc_o;
    input              wbm_ack_i;
    input              wbm_err_i;	 

    // LPC Slave Interface
    input              lframe_i;    // LPC Frame input (active high)
    output reg         lad_oe;      // LPC AD Output Enable
    input        [3:0] lad_i;       // LPC AD Input Bus
    output reg   [3:0] lad_o;       // LPC AD Output Bus

    // DMA-Specific sideband signals
    output       [2:0] dma_chan_o;  // DMA Channel
    output             dma_tc_o;    // DMA Terminal Count

    reg         [13:0] state;       // Current state
    reg          [2:0] adr_cnt;     // Address nibble counter
    reg          [3:0] dat_cnt;     // Data nibble counter
    wire         [2:0] byte_cnt = dat_cnt[3:1];  // Byte counter
    wire               nibble_cnt = dat_cnt[0];  // Nibble counter

    reg         [31:0] lpc_dat_i;   // Temporary storage for LPC input data.
    reg                mem_xfr;     // LPC Memory Transfer (not I/O)
    reg                dma_xfr;     // LPC DMA Transfer
    reg                fw_xfr;      // LPC Firmware memory read/write
    reg          [2:0] xfr_len;     // Number of nibbls for transfer
    reg                dma_tc;      // DMA Terminal Count
    reg          [2:0] dma_chan;    // DMA Channel

    // These buffer enough state to delay the start of the next Wishbone cycle
    // until the previous Firmware Write has completed.
    reg         [31:0] lpc_adr_reg; // Temporary storage for address received on LPC bus.
    reg         [31:0] lpc_dat_o;   // Temporary storage for LPC output data.
    reg                lpc_write;   // Holds current LPC transfer direction
    reg          [1:0] lpc_tga_o;
    reg                got_ack;     // Set when ack has been received from wbm

    assign dma_chan_o = dma_chan;
    assign dma_tc_o = dma_tc;
    
    always @(posedge clk_i or negedge nrst_i)
    begin
        if(~nrst_i)
        begin
            state <= `LPC_ST_IDLE;
            lpc_adr_reg <= 32'h00000000;
            lpc_dat_o <= 32'h00000000;
            lpc_write <= 1'b0;
            lpc_tga_o <= `WB_TGA_MEM;
            lad_oe <= 1'b0;
            lad_o <= 8'hFF;
            lpc_dat_i <= 32'h00000000;
            mem_xfr <= 1'b0;
            dma_xfr <= 1'b0;
            fw_xfr <= 1'b0;
            xfr_len <= 3'b000;
            dma_tc <= 1'b0;
            dma_chan <= 3'b000;
        end
        else begin
            case(state)
                `LPC_ST_IDLE:
                    begin
                        dat_cnt <= 4'h0;
                        if(lframe_i) begin
                            lad_oe <= 1'b0;
                            xfr_len <= 3'b001;
                                
                            if(lad_i == `LPC_START) begin
                                state <= `LPC_ST_CYCTYP;
                                lpc_write <= 1'b0;
                                fw_xfr <= 1'b0;                                 
                            end
                            else if ((lad_i == `LPC_FW_WRITE) || (lad_i == `LPC_FW_READ)) begin
                                state <= `LPC_ST_ADDR;
                                lpc_write <= (lad_i == `LPC_FW_WRITE) ? 1'b1 : 1'b0;
                                adr_cnt <= 3'b000;
                                fw_xfr <= 1'b1;
                                dma_xfr <= 1'b0;
                                lpc_tga_o <= `WB_TGA_FW;
                            end
                            else
                                state <= `LPC_ST_IDLE;
                        end
                        else
                            state <= `LPC_ST_IDLE;
                    end
                `LPC_ST_CYCTYP:
                    begin
                        lpc_write <= (lad_i[3] ? ~lad_i[1] : lad_i[1]);  // Invert we_o if we are doing DMA.
                        adr_cnt <= (lad_i[2] ? 3'b000 : 3'b100);
                        if(lad_i[3]) begin // dma_xfr
                            lpc_tga_o <= `WB_TGA_DMA;
                            dma_xfr <= 1'b1;
                            mem_xfr <= 1'b0;
                            state <= `LPC_ST_CHAN;									 
                        end
                        else if(lad_i[2]) begin // mem_xfr
                            lpc_tga_o <= `WB_TGA_MEM;
                            dma_xfr <= 1'b0;
                            mem_xfr <= 1'b1;
                            state <= `LPC_ST_ADDR;
                        end
                        else begin
                            lpc_tga_o <= `WB_TGA_IO;
                            dma_xfr <= 1'b0;
                            mem_xfr <= 1'b0;
                            state <= `LPC_ST_ADDR;
                        end
                    end
                `LPC_ST_ADDR:
                    begin
                        case(adr_cnt)
                            3'h0: lpc_adr_reg[31:28] <= lad_i;
                            3'h1: lpc_adr_reg[27:24] <= lad_i;
                            3'h2: lpc_adr_reg[23:20] <= lad_i;
                            3'h3: lpc_adr_reg[19:16] <= lad_i;
                            3'h4: lpc_adr_reg[15:12] <= lad_i;
                            3'h5: lpc_adr_reg[11: 8] <= lad_i;
                            3'h6: lpc_adr_reg[ 7: 4] <= lad_i;
                            3'h7: lpc_adr_reg[ 3: 0] <= lad_i;
                        endcase
                        
                        adr_cnt <= adr_cnt + 1;
                        
                        if(adr_cnt == 3'h7) // Last address nibble.
                            begin
                                if(~fw_xfr)
                                    if(lpc_write)
                                        state <= `LPC_ST_H_DATA;
                                    else
                                        state <= `LPC_ST_H_TAR1;
                                else    // For firmware read/write, we need to read the MSIZE nibble
                                    state <= `LPC_ST_SIZE;
                            end
                        else
                            state <= `LPC_ST_ADDR;
                    end
                `LPC_ST_CHAN:
                    begin
                        lpc_adr_reg <= 32'h00000000;      // Address lines not used for DMA.
                        dma_tc <= lad_i[3];
                        dma_chan <= lad_i[2:0];
                        state <= `LPC_ST_SIZE;
                    end
                `LPC_ST_SIZE:
                    begin
                        case(lad_i)
                            4'h0:    xfr_len <= 3'b001;
                            4'h1:    xfr_len <= 3'b010;
                            4'h2:    xfr_len <= 3'b100;   // Firmware transfer uses '2' for 4-byte transfer.
                            4'h3:    xfr_len <= 3'b100;   // DMA uses '3' for 4-byte transfer.
                            default: xfr_len <= 3'b001;
                        endcase
                        if(lpc_write)
                            state <= `LPC_ST_H_DATA;
                        else
                            state <= `LPC_ST_H_TAR1;
                    end
                `LPC_ST_H_DATA:
                    begin
                        case(dat_cnt)
                            4'h0: lpc_dat_o[ 3: 0] <= lad_i;
                            4'h1: lpc_dat_o[ 7: 4] <= lad_i;
                            4'h2: lpc_dat_o[11: 8] <= lad_i;
                            4'h3: lpc_dat_o[15:12] <= lad_i;
                            4'h4: lpc_dat_o[19:16] <= lad_i;
                            4'h5: lpc_dat_o[23:20] <= lad_i;
                            4'h6: lpc_dat_o[27:24] <= lad_i;
                            4'h7: lpc_dat_o[31:28] <= lad_i;
                        endcase
                        
                        dat_cnt <= dat_cnt + 1;
                        
                        if(nibble_cnt == 1'b1) // end of byte
                            begin
                                if((fw_xfr) && (byte_cnt != xfr_len-1)) // Firmware transfer does not have TAR between bytes.
                                    state <= `LPC_ST_H_DATA;
										  else
                                    state <= `LPC_ST_H_TAR1;
                            end
                        else
                            state <= `LPC_ST_H_DATA;
        
                    end
        
                `LPC_ST_H_TAR1:
                    begin
                        // It is ok to start the Wishbone Cycle, done below...
                        state <= `LPC_ST_H_TAR2;
                    end
                `LPC_ST_H_TAR2:
                    begin
                        state <= (fw_xfr & lpc_write) ? `LPC_ST_FWW_SYNC : `LPC_ST_SYNC;
                        lad_o <= (fw_xfr & lpc_write) ? `LPC_SYNC_READY : `LPC_SYNC_SWAIT;
                        lad_oe <= 1'b1;     // start driving LAD
                    end
                `LPC_ST_SYNC:
                    begin
                        lad_oe <= 1'b1;     // start driving LAD
                        // First byte of WB read, last byte of WB write
                        if(((byte_cnt == xfr_len) & lpc_write) | ((byte_cnt == 0) & ~lpc_write)) begin
                            // Errors can not be signalled for Firmware Memory accesses according to the spec.
                            if((wbm_err_i) && (~fw_xfr)) begin
                                dat_cnt <= { xfr_len, 1'b1 }; // Abort remainder of transfer
                                lad_o <= `LPC_SYNC_ERROR;   // Bus error
                                state <= `LPC_ST_P_TAR1;
                            end else if(got_ack) begin
                                if(lpc_write) begin
                                    lad_o <= `LPC_SYNC_READY;   // Ready
                                    state <= `LPC_ST_P_TAR1;
                                end
                                else begin
                                    // READY+MORE for multi-byte DMA, except the final byte.
                                    // For non-DMA cycles, only READY
                                    lad_o <= (((xfr_len == 1) & ~lpc_write) || (~dma_xfr)) ? `LPC_SYNC_READY : `LPC_SYNC_MORE;
                                    state <= `LPC_ST_P_DATA;
                                end
                            end
                            else begin
                                state <= `LPC_ST_SYNC;
                                lad_o <= `LPC_SYNC_SWAIT;
                            end
                        end
                        else begin  // Multi-byte transfer, just ack right away.
                            if(lpc_write) begin
                                lad_o <= (dma_xfr) ? `LPC_SYNC_MORE : `LPC_SYNC_READY;
                                state <= `LPC_ST_P_TAR1;
                            end
									 else begin
                                lad_o <= ((byte_cnt == xfr_len-1) || (~dma_xfr)) ? `LPC_SYNC_READY : `LPC_SYNC_MORE;   // Ready-More									 
                                state <= `LPC_ST_P_DATA;
                            end
                        end
                    end
                `LPC_ST_FWW_SYNC:	// Firmware write requires a special SYNC without wait-states.
                    begin
                        lad_o <= 4'hF;
                        state <= `LPC_ST_P_TAR2;
                    end
        
                `LPC_ST_P_DATA:
                    begin
                        case(dat_cnt)
                            4'h0: lad_o <= lpc_dat_i[ 3: 0];
                            4'h1: lad_o <= lpc_dat_i[ 7: 4];
                            4'h2: lad_o <= lpc_dat_i[11: 8];
                            4'h3: lad_o <= lpc_dat_i[15:12];
                            4'h4: lad_o <= lpc_dat_i[19:16];
                            4'h5: lad_o <= lpc_dat_i[23:20];
                            4'h6: lad_o <= lpc_dat_i[27:24];
                            4'h7: lad_o <= lpc_dat_i[31:28];
                        endcase
                        
                        dat_cnt <= dat_cnt + 1;
                        
                        if(nibble_cnt == 1'b1)  // Byte transfer complete
                            if (byte_cnt == xfr_len-1) // Byte transfer complete
                                state <= `LPC_ST_P_TAR1;
                            else begin
                                if(fw_xfr) // Firmware transfer does not have TAR between bytes.
                                    state <= `LPC_ST_P_DATA;
                                else
                                    state <= `LPC_ST_SYNC;
                            end
                        else
                            state <= `LPC_ST_P_DATA;
        
                        lad_oe <= 1'b1;
                    end
                `LPC_ST_P_TAR1:
                    begin
                        lad_oe <= 1'b1;
                        lad_o <= 4'hF;
                        state <= `LPC_ST_P_TAR2;
                    end
                `LPC_ST_P_TAR2:
                    begin
                        lad_oe <= 1'b0;     // float LAD
                        if(byte_cnt == xfr_len) begin
                            state <= `LPC_ST_IDLE;
                        end
                        else begin
                            if(lpc_write) begin  // DMA READ (Host to Peripheral)
                                state <= `LPC_ST_P_WAIT1;
                            end
                            else begin  // unhandled READ case
                                state <= `LPC_ST_IDLE;
                            end
                        end

                    end
                    `LPC_ST_P_WAIT1:
                         state <= `LPC_ST_H_DATA;
            endcase
        end

// The goal here is to split the Wishbone cycle handling out of the main state-machine
// so it can run independently.  This is needed so that in the case of a firmware write,
// where the FLASH requires wait-states (which are not allowed for FW write according to
// the LPC Specification.)  In this case, since the FLASH cannot insert wait-states,
// a subsequent LPC operation (which must not be another FW Write) will insert wait-
// states before starting the next Wishbone master cycle.
//
// The only reason that I can think of for the LPC spec to mandate that Firmware Writes
// must not insert wait-states is that since FLASH writes can take a very long time,
// the LPC spec disallowed them to force LPC FLASH programming software to use polling
// to determine when the write is complete rather than inserting a bunch of wait-states,
// which would use up too much LPC bus bandwidth, and block other requests from getting
// through.
//
        if(~nrst_i)
        begin
            wbm_adr_o <= 32'h00000000;
            wbm_dat_o <= 32'h00000000;
            wbm_stb_o <= 1'b0;
            wbm_cyc_o <= 1'b0;
            wbm_we_o <= 1'b0;
            wbm_sel_o <= 4'b0000;
            wbm_tga_o <= `WB_TGA_MEM;
            got_ack <= 1'b0;
        end
        else begin
            if ((state == `LPC_ST_H_TAR1) && (((byte_cnt == xfr_len) & lpc_write) | ((byte_cnt == 0) & ~lpc_write)))
            begin
                // Start Wishbone Cycle
                wbm_stb_o <= 1'b1;
                wbm_cyc_o <= 1'b1;
                wbm_adr_o <= lpc_adr_reg;
                wbm_dat_o <= lpc_dat_o;					 
                wbm_we_o <= lpc_write;
                wbm_tga_o <= lpc_tga_o;
                got_ack <= 1'b0;
                case(xfr_len)
                    3'h0: wbm_sel_o <= `WB_SEL_BYTE;
                    3'h2: wbm_sel_o <= `WB_SEL_SHORT;
                    3'h4: wbm_sel_o <= `WB_SEL_WORD;
                endcase
            end
            else if((wbm_stb_o == 1'b1) && (wbm_ack_i == 1'b1)) begin
                // End Wishbone Cycle
                wbm_stb_o <= 1'b0;
                wbm_cyc_o <= 1'b0;
                wbm_we_o <= 1'b0;
                got_ack <= 1'b1;
                if(~wbm_we_o) begin
                    lpc_dat_i <= wbm_dat_i;
                end
             end
        end
    end
endmodule

                            
