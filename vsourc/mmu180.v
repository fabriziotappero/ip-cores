/** @package zGlue

    @file mmu180.v
        
    @brief Memory Management Unit, mimics classic Z180;
            for eZ80 Family host processor with 24-bit address bus.

<BR>Simplified (2-clause) BSD License

Copyright (c) 2012, Douglas Beattie Jr.
All rights reserved.

Redistribution and use in source and hardware/binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice,
   this list of conditions and the following disclaimer.

2. Redistributions in hardware/binary form must reproduce the above
   copyright notice, this list of conditions and the following disclaimer in
   the documentation and/or other materials provided with the distribution.

THIS RTL SOURCE IS PROVIDED BY DOUGLAS BEATTIE JR. "AS IS" AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL DOUGLAS BEATTIE JR. BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
THIS RTL SOURCE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
        
    Author: Douglas Beattie
    Created on: 4/12/2012 8:50:12 PM
	Last change: DBJR 4/27/2012 7:55:01 PM
*/
`timescale 1ns / 100ps

// User-defined I/O addresses from eZ80 address bus;
// these match the original Z180 MMU defaults at reset.
// These must not be defined within eZ80 on-chip i/o space (7F..FF)
`define CBR_IO_ADDR     16'h0038  // Common Bank Register
`define BBR_IO_ADDR     16'h0039  // Bank Base Register
`define CBAR_IO_ADDR    16'h003A  // Common/Bank Address Register

module mmu180(reset_n, en, iorq_n, mreq_n, rd_n, wr_n, phi, addr_in, dq, addr_out,
        cbar_hinyb, cbar_lonyb);

input           reset_n, en, iorq_n, mreq_n, rd_n, wr_n, phi;
input   [23:0]  addr_in; //processor address bus
inout   [7:0]   dq;     // processor data bus
output  [19:12]  addr_out; // memory address bus


reg [7:0]  cpu_data_buf;

wire cbar_hinyb_gteq;   // for CBR valid address match
wire cbar_lonyb_gteq;   // for BBR valid address match

// These are for verification only
output cbar_hinyb, cbar_lonyb;
// These are for verification only
assign cbar_hinyb = cbar_hinyb_gteq;
assign cbar_lonyb = cbar_lonyb_gteq;

/** *************************************************************** */
/** define 3 I/O Ports, 1 each for CBR, BBR, and CBAR               */

wire [7:0] iolatched_oup_CBR;
wire [7:0] iolatched_oup_BBR;
wire [7:0] iolatched_oup_CBAR;


/**************
wire addr16_msb_zero;
assign addr16_msb_zero = (addr_in[15:8] == 8'b0);

wire iosel_CBR, iosel_BBR, iosel_CBAR;
assign iosel_CBR = (addr16_msb_zero && (addr_in[7:0] == `CBR_IO_ADDR) && ! iorq_n && ! phi);
assign iosel_BBR = (addr16_msb_zero && (addr_in[7:0] == `BBR_IO_ADDR) && ! iorq_n && ! phi);
assign iosel_CBAR = (addr16_msb_zero && (addr_in[7:0] == `CBAR_IO_ADDR) && ! iorq_n && ! phi);
********************/
wire iosel_CBR, iosel_BBR, iosel_CBAR;
assign iosel_CBR = ((addr_in[15:0] == `CBR_IO_ADDR) && ! iorq_n && ! phi);
assign iosel_BBR = ((addr_in[15:0] == `BBR_IO_ADDR) && ! iorq_n && ! phi);
assign iosel_CBAR = ((addr_in[15:0] == `CBAR_IO_ADDR) && ! iorq_n && ! phi);


wire iosel_CBR_wr, iosel_BBR_wr, iosel_CBAR_wr;
assign iosel_CBR_wr = ! (iosel_CBR & ! wr_n);
assign iosel_BBR_wr = ! (iosel_BBR & ! wr_n);
assign iosel_CBAR_wr = ! (iosel_CBAR & ! wr_n);

assign dq = ( (iosel_CBR | iosel_BBR | iosel_CBAR) & (! rd_n)) ? cpu_data_buf : 8'bz;

wire iosel;
assign iosel = (! iorq_n && ! phi);
always  @ (posedge iosel)
    if (! rd_n) begin
        case (addr_in[15:0])
            `CBR_IO_ADDR: begin
                cpu_data_buf <= iolatched_oup_CBR;
            end
            `BBR_IO_ADDR: begin
                cpu_data_buf <= iolatched_oup_BBR;
            end
            `CBAR_IO_ADDR: begin
                cpu_data_buf <= iolatched_oup_CBAR;
            end
        endcase
    end

/// define I/O port to read/write CBR
ioport_a16_d8_wo   ioport_CBR(
    .reset_n   (reset_n),
//    .rd_n   (iosel_CBR_rd),
    .wr_n   (iosel_CBR_wr),
    .data_in   (dq),
    .ouplatched_bus (iolatched_oup_CBR)
);

/// define I/O port to read/write BBR
ioport_a16_d8_wo  ioport_BBR(
    .reset_n   (reset_n),
//    .rd_n   (iosel_BBR_rd),
    .wr_n   (iosel_BBR_wr),
    .data_in   (dq),
    .ouplatched_bus (iolatched_oup_BBR)
);

/// define I/O port to read/write CBAR
ioport_a16_d8_wo  #(.INIT_VAL(8'hF0)) ioport_CBAR(
    .reset_n   (reset_n),
//    .rd_n   (iosel_CBAR_rd),
    .wr_n   (iosel_CBAR_wr),
    .data_in   (dq),
    .ouplatched_bus (iolatched_oup_CBAR)
);

/** **************************************************************** */
/** define MMU compare and adder logic                               */


// Compare CBAR high nybble for Common Area 1 address ("use CBR?")
assign cbar_hinyb_gteq = (addr_in[15:12] >= iolatched_oup_CBAR[7:4]);

// Compare CBAR low nybble for Bank Area address  ("use BBR?")
assign cbar_lonyb_gteq = (addr_in[15:12] >= iolatched_oup_CBAR[3:0]);

wire cbar_is_valid;
assign cbar_is_valid = (iolatched_oup_CBAR[7:4] >= iolatched_oup_CBAR[3:0]);

wire    [7:0]   bbr_cbr_mux;
assign bbr_cbr_mux =
        (cbar_is_valid & cbar_hinyb_gteq) ? iolatched_oup_CBR :
        (cbar_is_valid & cbar_lonyb_gteq) ? iolatched_oup_BBR : 8'b0;

wire    [7:0]   hiaddr_1meg;
assign hiaddr_1meg = bbr_cbr_mux + {4'b0,addr_in[15:12]};

//define when hiaddr_1meg is to be used instead of normal a[19..12]
assign addr_out = (/*en &&*/ (addr_in[23:16] != 0)) ?
                    addr_in[19:12] : (en && (! mreq_n) && (cbar_hinyb_gteq | cbar_lonyb_gteq)) ?
                    hiaddr_1meg : addr_in[19:12];// : 8'bz;

/**
                    addr_in[19:12] : (en_mmu && (! mreq_n) && (cbar_hinyb_gteq | cbar_lonyb_gteq)) ?
                    hiaddr_1meg : (en_mod4 && (! mreq_n)) ? {addr_in[19:17], adj_a16, adj_a15, addr_in[14:12] }
                        : addr_in[19:12];// : 8'bz;

*/

endmodule

