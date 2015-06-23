//////////////////////////////////////////////////////////////////////
////                                                              ////
////  $Id: wb_lpc_host.v,v 1.4 2008-07-26 19:15:31 hharte Exp $   ////
////  wb_lpc_host.v - Wishbone Slave to LPC Host Bridge           ////
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

//                  I/O Write       I/O Read        DMA Read        DMA Write
//                                                          
//  States -    1. H Start          H Start         H Start         H Start
//              2. H CYCTYPE+DIR    H CYCTYPE+DIR   H CYCTYPE+DIR   H CYCTYPE+DIR
//              3. H Addr (4)       H Addr (4)      H CHAN+TC       H CHAN+TC
//                                                  H SIZE          H SIZE
//              4. H Data (2)       H TAR  (2)    +-H DATA (2)      H TAR  (2)
//              5. H TAR  (2)       P SYNC (1+)   | H TAR  (2)    +-P SYNC (1+)
//              6. P SYNC (1+)      P DATA (2)    | H SYNC (1+)   +-P DATA (2)
//              7. P TAR  (2)       P TAR  (2)    +-P TAR  (2)      P TAR
//                                                          
module wb_lpc_host(clk_i, nrst_i, wbs_adr_i, wbs_dat_o, wbs_dat_i, wbs_sel_i, wbs_tga_i, wbs_we_i,
                   wbs_stb_i, wbs_cyc_i, wbs_ack_o, wbs_err_o,
                   dma_chan_i, dma_tc_i,
                   lframe_o, lad_i, lad_o, lad_oe
);
    // Wishbone Slave Interface
    input              clk_i;
    input              nrst_i;             // Active low reset.
    input       [31:0] wbs_adr_i;
    output      [31:0] wbs_dat_o;
    input       [31:0] wbs_dat_i;
    input       [3:0]  wbs_sel_i;
    input       [1:0]  wbs_tga_i;
    input              wbs_we_i;
    input              wbs_stb_i;
    input              wbs_cyc_i;
    output reg         wbs_ack_o;
    output reg         wbs_err_o;
    
    // LPC Master Interface
    output reg        lframe_o;     // LPC Frame output (active high)
    output reg        lad_oe;       // LPC AD Output Enable
    input       [3:0] lad_i;        // LPC AD Input Bus
    output reg  [3:0] lad_o;        // LPC AD Output Bus

    // DMA-Specific sideband signals
    input       [2:0] dma_chan_i;   // DMA Channel
    input             dma_tc_i;     // DMA Terminal Count

    reg         [13:0] state;       // Current state
    reg         [2:0] adr_cnt;      // Address nibbe counter
    reg         [3:0] dat_cnt;      // Data nibble counter
    reg         [2:0] xfr_len;      // Number of nibbls for transfer
    wire        [2:0] byte_cnt = dat_cnt[3:1];  // Byte Counter
    wire              nibble_cnt = dat_cnt[0];    // Nibble counter
    reg         [31:0] lpc_dat_i;           // Temporary storage for input word.

    //
    // generate wishbone register signals
    wire wbs_acc = wbs_cyc_i & wbs_stb_i;    // Wishbone access
    wire wbs_wr  = wbs_acc & wbs_we_i;       // Wishbone write access

    // Memory Cycle (tga== 1'b00) is bit 2=1 for LPC Cycle Type.
    wire    mem_xfr = (wbs_tga_i == `WB_TGA_MEM);
    wire    dma_xfr = (wbs_tga_i == `WB_TGA_DMA);
    wire    fw_xfr  = (wbs_tga_i == `WB_TGA_FW);
    
    assign wbs_dat_o[31:0] = lpc_dat_i; 

    always @(posedge clk_i or negedge nrst_i)
        if(~nrst_i)
        begin
            state <= `LPC_ST_IDLE;
            lframe_o <= 1'b0;
            wbs_ack_o <= 1'b0;
            wbs_err_o <= 1'b0;
            lad_oe <= 1'b0;
            lad_o <= 4'b0;
            adr_cnt <= 3'b0;
            dat_cnt <= 4'h0;
            xfr_len <= 3'b000;
            lpc_dat_i <= 32'h00000000;
        end
        else begin
            case(state)
                `LPC_ST_IDLE:
                    begin
                        wbs_ack_o <= 1'b0;
                        wbs_err_o <= 1'b0;
                        lframe_o <= 1'b0;
                        dat_cnt <= 4'h0;                        

                        if(wbs_acc)     // Wishbone access starts LPC transaction
                            state <= `LPC_ST_START;
                        else
                            state <= `LPC_ST_IDLE;
                    end
                `LPC_ST_START:
                    begin
                        lframe_o <= 1'b1;
                        if(~fw_xfr) begin       // For Memory and I/O Cycles
                            lad_o   <= `LPC_START;
                            state   <= `LPC_ST_CYCTYP;
                        end
                        else begin              // Firmware Read and Write Cycles
                            if(wbs_wr)
                                lad_o <= `LPC_FW_WRITE;
                            else
                                lad_o <= `LPC_FW_READ;
                            
                            state   <= `LPC_ST_ADDR;
                        end
                        lad_oe  <= 1'b1;
                        adr_cnt <= ((mem_xfr | fw_xfr) ? 3'b000 : 3'b100);
                    end
                `LPC_ST_CYCTYP:
                    begin
                        lframe_o    <= 1'b0;
                        lad_oe  <= 1'b1;                

                        if(~dma_xfr)
                            begin
                                lad_o   <= {1'b0,mem_xfr,wbs_wr,1'b0};      // Cycle Type/Direction for I/O or MEM
                                state       <= `LPC_ST_ADDR;
                            end
                        else // it is DMA
                            begin
                                lad_o   <= {1'b1,1'b0,~wbs_wr,1'b0};        // Cycle Type/Direction for DMA, r/w is inverted for DMA
                                state       <= `LPC_ST_CHAN;
                            end
                    end
                `LPC_ST_ADDR:   // Output four nubbles of address.
                    begin
                        lframe_o <= 1'b0;       // In case we came here from a Firmware cycle, which skips CYCTYP.
                        
                        // The LPC Bus Address is sent across the bus a nibble at a time;
                        // however, the most significant nibble is sent first.  For firmware and
                        // memory cycles, the address is 32-bits.  Actually, for firmware accesses,
                        // the most significant nibble is known as the IDSEL field.  For I/O,
                        // the address is only 16-bits wide.
                        case(adr_cnt)
                            3'h0:
                                lad_o <= wbs_adr_i[31:28];
                            3'h1:
                                lad_o <= wbs_adr_i[27:24];
                            3'h2:
                                lad_o <= wbs_adr_i[23:20];
                            3'h3:
                                lad_o <= wbs_adr_i[19:16];
                            3'h4:
                                lad_o <= wbs_adr_i[15:12];
                            3'h5:
                                lad_o <= wbs_adr_i[11:8];
                            3'h6:
                                lad_o <= wbs_adr_i[7:4];
                            3'h7:
                                lad_o <= wbs_adr_i[3:0];
                        endcase
                        
                        adr_cnt <= adr_cnt + 1;
                        
                        if(adr_cnt == 4'h7) // Last address nibble.
                            begin
                                if(~fw_xfr)
                                    if(wbs_wr)
                                        state <= `LPC_ST_H_DATA;
                                    else
                                        state <= `LPC_ST_H_TAR1;
                                else    // For firmware read/write, we need to transfer the MSIZE nibble
                                    state <= `LPC_ST_SIZE;
                            end
                        else
                            state <= `LPC_ST_ADDR;
        
                        lad_oe  <= 1'b1;
                        xfr_len     <= 3'b001;      // One Byte Transfer
                    end
                `LPC_ST_CHAN:
                    begin
                        lad_o   <= {dma_tc_i, dma_chan_i};
                        state <= `LPC_ST_SIZE;
                    end
                `LPC_ST_SIZE:
                    begin
                        case(wbs_sel_i)
                            `WB_SEL_BYTE:
                                begin
                                    xfr_len <= 3'b001;
                                    lad_o <= 4'h0;
                                end
                            `WB_SEL_SHORT:
                                begin
                                    xfr_len <= 3'b010;
                                    lad_o <= 4'h1;
                                end
                            `WB_SEL_WORD:
                                begin
                                    xfr_len <= 3'b100;
                                    if(fw_xfr)              // Firmware transfer uses '2' for 4-byte transfer.
                                        lad_o <= 4'h2;
                                    else                    // DMA uses '3' for 4-byte transfer.
                                        lad_o <= 4'h3;
                                end
                            default:
                                begin
                                    xfr_len <= 3'b001;
                                    lad_o <= 4'h0;
                                end
                        endcase
                        if(wbs_wr)
                            state <= `LPC_ST_H_DATA;
                        else
                            state <= `LPC_ST_H_TAR1;
                    end

                `LPC_ST_H_DATA:
                    begin
                        lad_oe  <= 1'b1;
                        case(dat_cnt)   // We only support a single byte for I/O.
                            4'h0:
                                lad_o <= wbs_dat_i[3:0];
                            4'h1:
                                lad_o <= wbs_dat_i[7:4];
                            4'h2:
                                lad_o <= wbs_dat_i[11:8];
                            4'h3:
                                lad_o <= wbs_dat_i[15:12];
                            4'h4:
                                lad_o <= wbs_dat_i[19:16];
                            4'h5:
                                lad_o <= wbs_dat_i[23:20];
                            4'h6:
                                lad_o <= wbs_dat_i[27:24];
                            4'h7:
                                lad_o <= wbs_dat_i[31:28];
                            default:
                                lad_o <= 4'hx;
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
                        lad_o <= 4'b1111;       // Drive LAD high
                        lad_oe <= 1'b1;
                        state <= `LPC_ST_H_TAR2;
                    end
                `LPC_ST_H_TAR2:
                    begin
                        lad_oe <= 1'b0;     // float LAD
                        state <= `LPC_ST_SYNC;
                    end
                `LPC_ST_SYNC:
                    begin
                        lad_oe <= 1'b0;     // float LAD
                        if((lad_i == `LPC_SYNC_READY) || (lad_i == `LPC_SYNC_MORE)) begin
                            if(wbs_wr) begin
                                state <= `LPC_ST_P_TAR1;
                            end
                            else begin
                                state <= `LPC_ST_P_DATA;
                            end
                        end else if(lad_i == `LPC_SYNC_ERROR) begin
                            dat_cnt <= { xfr_len, 1'b1 };    // Terminate data transfer
                            wbs_err_o <= 1'b1;    // signal wishbone error
                            state <= `LPC_ST_P_TAR1;
                        end else begin
                            state <= `LPC_ST_SYNC;
                        end
                    end
        
                `LPC_ST_P_DATA:
                    begin
                        case(dat_cnt)
                            4'h0:
                                lpc_dat_i[3:0] <= lad_i;
                            4'h1:
                                lpc_dat_i[7:4] <= lad_i;
                            4'h2:
                                lpc_dat_i[11:8] <= lad_i;
                            4'h3:
                                lpc_dat_i[15:12] <= lad_i;
                            4'h4:
                                lpc_dat_i[19:16] <= lad_i;
                            4'h5:
                                lpc_dat_i[23:20] <= lad_i;
                            4'h6:
                                lpc_dat_i[27:24] <= lad_i;
                            4'h7:
                                lpc_dat_i[31:28] <= lad_i;
                        endcase
                        
                        dat_cnt <= dat_cnt + 1;
                        
                        if(nibble_cnt == 1'b1)          // Byte transfer complete
                            if (byte_cnt == xfr_len-1)  // End of data transfer phase
                                state <= `LPC_ST_P_TAR1;
                            else begin
                                if(fw_xfr) // Firmware transfer does not have TAR between bytes.
                                    state <= `LPC_ST_P_DATA;
                                else
                                    state <= `LPC_ST_SYNC;
                            end
                        else                            // Go to next nibble
                            state <= `LPC_ST_P_DATA;
                    end
                `LPC_ST_P_TAR1:
                    begin
                        lad_oe <= 1'b0;
                        if(byte_cnt == xfr_len) begin
                            state <= `LPC_ST_WB_RETIRE;
                            wbs_ack_o <= wbs_acc;
                        end
                        else begin
                            if(wbs_wr) begin    // DMA READ (Host to Peripheral)
                                state <= `LPC_ST_H_DATA;
                            end
                            else begin  // unhandled READ case
                                state <= `LPC_ST_IDLE;
                            end
                        end
                    end
                `LPC_ST_WB_RETIRE:
                    begin
                        wbs_ack_o <= 1'b0;
                        wbs_err_o <= 1'b0;
                        if(wbs_acc) begin
                            state <= `LPC_ST_WB_RETIRE;
                        end
                        else begin
                            state <= `LPC_ST_IDLE;
                        end
                    end
            endcase
        end

endmodule

                            
