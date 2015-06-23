/*
 * gmii_rx_bfm.v
 * 
 * Copyright (c) 2012, BABY&HW. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301  USA
 */

`timescale 1ns/1ns

module gmii_rx_bfm
  (
    output           gmii_rxclk,
    output reg       gmii_rxctrl,
    output reg [7:0] gmii_rxdata
  );
    parameter        giga_mode = 1;

reg gmii_rxclk_offset;
initial begin 
               gmii_rxclk_offset = 1'b0;
    forever #4 gmii_rxclk_offset = !gmii_rxclk_offset;
end
assign #2 gmii_rxclk = gmii_rxclk_offset;

integer feeder_file_rx, r_rx, s_rx;
integer start_addr_rx, end_addr_rx;
integer index_rx, num_rx;
reg eof_rx;
reg pcap_endian_rx;
reg [31:0] pcap_4bytes_rx;
reg [31:0] packet_leng_rx;
reg [ 7:0] packet_byte_rx;

generate
if (giga_mode) begin
initial
begin : feeder_rx
    gmii_rxctrl = 1'b0;
    gmii_rxdata = 8'd0;
    #100;
    feeder_file_rx = $fopen("ptpdv2_rx.pcap","rb");
    if (feeder_file_rx == 0)
    begin
        $display("Failed to open ptpdv2_rx.pcap!");
        disable feeder_rx;
    end
    else
    begin
        // test pcap file endian
        r_rx = $fread(pcap_4bytes_rx, feeder_file_rx);
        pcap_endian_rx = (pcap_4bytes_rx == 32'ha1b2c3d4)? 1:0;
        s_rx = $fseek(feeder_file_rx, -4, 1);
        // skip pcap file header 24*8
        s_rx = $fseek(feeder_file_rx, 24, 1);
        // read packet content
        eof_rx = 0;
        num_rx = 0;
        while (!eof_rx & !$feof(feeder_file_rx))
        begin : fileread_loop
            // skip frame header (8+4)*8
            start_addr_rx = $ftell(feeder_file_rx);
            s_rx = $fseek(feeder_file_rx, 8+4, 1);
            // get frame length big endian 4*8
            r_rx = $fread(packet_leng_rx, feeder_file_rx);
            packet_leng_rx = pcap_endian_rx? 
                               {packet_leng_rx[31:24], packet_leng_rx[23:16], packet_leng_rx[15: 8], packet_leng_rx[ 7: 0]}:
                               {packet_leng_rx[ 7: 0], packet_leng_rx[15: 8], packet_leng_rx[23:16], packet_leng_rx[31:24]};
            // check whether end of file
            if (r_rx == 0) 
            begin
                eof_rx = 1;
                @(posedge gmii_rxclk_offset);
                gmii_rxctrl = 1'b0;
                gmii_rxdata = 8'h00;
                disable fileread_loop;
            end
            // send ifg 96bit=12*8
            repeat (12)
            begin
                @(posedge gmii_rxclk_offset)
                gmii_rxctrl = 1'b0;
                gmii_rxdata = 8'h00;
            end
            // send frame preamble and sfd 55555555555555d5=8*8
            repeat (7)
            begin
                @(posedge gmii_rxclk_offset);
                gmii_rxctrl = 1'b1;
                gmii_rxdata = 8'h55;
            end
                @(posedge gmii_rxclk_offset)
                gmii_rxctrl = 1'b1;
                gmii_rxdata = 8'hd5;
            // send frame content
            for (index_rx=0; index_rx<packet_leng_rx; index_rx=index_rx+1)
            begin
                r_rx = $fread(packet_byte_rx, feeder_file_rx);
                @(posedge gmii_rxclk_offset);
                gmii_rxctrl = 1'b1;
                gmii_rxdata = packet_byte_rx;
                // check whether end of file
                if (r_rx == 0) 
                begin
                    eof_rx = 1;
                    @(posedge gmii_rxclk_offset);
                    gmii_rxctrl = 1'b0;
                    gmii_rxdata = 8'h00;
                    disable fileread_loop;
                end
            end
            end_addr_rx = $ftell(feeder_file_rx);
            num_rx = num_rx + 1;
        end
        $fclose(feeder_file_rx);
        gmii_rxctrl = 1'b0;
        gmii_rxdata = 8'h00;
    end
end
end
else begin
initial
begin : feeder_rx
    gmii_rxctrl = 1'b0;
    gmii_rxdata = 4'd0;
    #100;
    feeder_file_rx = $fopen("ptpdv2_rx.pcap","rb");
    if (feeder_file_rx == 0)
    begin
        $display("Failed to open ptpdv2_rx.pcap!");
        disable feeder_rx;
    end
    else
    begin
        // test pcap file endian
        r_rx = $fread(pcap_4bytes_rx, feeder_file_rx);
        pcap_endian_rx = (pcap_4bytes_rx == 32'ha1b2c3d4)? 1:0;
        s_rx = $fseek(feeder_file_rx, -4, 1);
        // skip pcap file header 24*8
        s_rx = $fseek(feeder_file_rx, 24, 1);
        // read packet content
        eof_rx = 0;
        num_rx = 0;
        while (!eof_rx & !$feof(feeder_file_rx))
        begin : fileread_loop
            // skip frame header (8+4)*8
            start_addr_rx = $ftell(feeder_file_rx);
            s_rx = $fseek(feeder_file_rx, 8+4, 1);
            // get frame length big endian 4*8
            r_rx = $fread(packet_leng_rx, feeder_file_rx);
            packet_leng_rx = pcap_endian_rx? 
                               {packet_leng_rx[31:24], packet_leng_rx[23:16], packet_leng_rx[15: 8], packet_leng_rx[ 7: 0]}:
                               {packet_leng_rx[ 7: 0], packet_leng_rx[15: 8], packet_leng_rx[23:16], packet_leng_rx[31:24]};
            // check whether end of file
            if (r_rx == 0) 
            begin
                eof_rx = 1;
                @(posedge gmii_rxclk_offset);
                gmii_rxctrl = 1'b0;
                gmii_rxdata = 4'h0;
                @(posedge gmii_rxclk_offset);
                gmii_rxctrl = 1'b0;
                gmii_rxdata = 4'h0;
                disable fileread_loop;
            end
            // send ifg 96bit=12*8
            repeat (12)
            begin
                @(posedge gmii_rxclk_offset)
                gmii_rxctrl = 1'b0;
                gmii_rxdata = 4'h0;
                @(posedge gmii_rxclk_offset)
                gmii_rxctrl = 1'b0;
                gmii_rxdata = 4'h0;
            end
            // send frame preamble and sfd 55555555555555d5=8*8
            repeat (7)
            begin
                @(posedge gmii_rxclk_offset);
                gmii_rxctrl = 1'b1;
                gmii_rxdata = 4'h5;
                @(posedge gmii_rxclk_offset);
                gmii_rxctrl = 1'b1;
                gmii_rxdata = 4'h5;
            end
                @(posedge gmii_rxclk_offset)
                gmii_rxctrl = 1'b1;
                gmii_rxdata = 4'h5;
                @(posedge gmii_rxclk_offset)
                gmii_rxctrl = 1'b1;
                gmii_rxdata = 4'hd;
            // send frame content
            for (index_rx=0; index_rx<packet_leng_rx; index_rx=index_rx+1)
            begin
                r_rx = $fread(packet_byte_rx, feeder_file_rx);
                @(posedge gmii_rxclk_offset);
                gmii_rxctrl = 1'b1;
                gmii_rxdata = packet_byte_rx[3:0];
                @(posedge gmii_rxclk_offset);
                gmii_rxctrl = 1'b1;
                gmii_rxdata = packet_byte_rx[7:4];
                // check whether end of file
                if (r_rx == 0) 
                begin
                    eof_rx = 1;
                    @(posedge gmii_rxclk_offset);
                    gmii_rxctrl = 1'b0;
                    gmii_rxdata = 4'h0;
                    @(posedge gmii_rxclk_offset);
                    gmii_rxctrl = 1'b0;
                    gmii_rxdata = 4'h0;
                    disable fileread_loop;
                end
            end
            end_addr_rx = $ftell(feeder_file_rx);
            num_rx = num_rx + 1;
        end
        $fclose(feeder_file_rx);
        gmii_rxctrl = 1'b0;
        gmii_rxdata = 4'h0;
        $fclose(feeder_file_rx);
        gmii_rxctrl = 1'b0;
        gmii_rxdata = 4'h0;
    end
end
end
endgenerate

endmodule
