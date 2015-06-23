/*
 * gmii_tx_bfm.v
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

module gmii_tx_bfm
  (
    output           gmii_txclk,
    output reg       gmii_txctrl,
    output reg [7:0] gmii_txdata
  );
    parameter        giga_mode = 1;

reg gmii_txclk_offset;
initial begin 
               gmii_txclk_offset = 1'b0;
    forever #4 gmii_txclk_offset = !gmii_txclk_offset;
end
assign #2 gmii_txclk = gmii_txclk_offset;

integer feeder_file_tx, r_tx, s_tx;
integer start_addr_tx, end_addr_tx;
integer index_tx, num_tx;
reg eof_tx;
reg pcap_endian_tx;
reg [31:0] pcap_4bytes_tx;
reg [31:0] packet_leng_tx;
reg [ 7:0] packet_byte_tx;

generate
if (giga_mode) begin
initial
begin : feeder_tx
    gmii_txctrl   = 1'b0;
    gmii_txdata = 8'd0;
    #100;
    feeder_file_tx = $fopen("nic_drv_bfm/ptpdv2_tx.pcap","rb");
    if (feeder_file_tx == 0)
    begin
        $display("Failed to open ptpdv2_tx.pcap!");
        disable feeder_tx;
    end
    else
    begin
        // test pcap file endian
        r_tx = $fread(pcap_4bytes_tx, feeder_file_tx);
        pcap_endian_tx = (pcap_4bytes_tx == 32'ha1b2c3d4)? 1:0;
        s_tx = $fseek(feeder_file_tx, -4, 1);
        // skip pcap file header 24*8
        s_tx = $fseek(feeder_file_tx, 24, 1);
        // read packet content
        eof_tx = 0;
        num_tx = 0;
        while (!eof_tx & !$feof(feeder_file_tx))
        begin : fileread_loop
            // skip frame header (8+4)*8
            start_addr_tx = $ftell(feeder_file_tx);
            s_tx = $fseek(feeder_file_tx, 8+4, 1);
            // get frame length big endian 4*8
            r_tx = $fread(packet_leng_tx, feeder_file_tx);
            packet_leng_tx = pcap_endian_tx? 
                               {packet_leng_tx[31:24], packet_leng_tx[23:16], packet_leng_tx[15: 8], packet_leng_tx[ 7: 0]}:
                               {packet_leng_tx[ 7: 0], packet_leng_tx[15: 8], packet_leng_tx[23:16], packet_leng_tx[31:24]};
            // check whether end of file
            if (r_tx == 0) 
            begin
                eof_tx = 1;
                @(posedge gmii_txclk_offset);
                gmii_txctrl = 1'b0;
                gmii_txdata = 8'h00;
                disable fileread_loop;
            end
            // send ifg 96bit=12*8
            repeat (12)
            begin
                @(posedge gmii_txclk_offset)
                gmii_txctrl = 1'b0;
                gmii_txdata = 8'h00;
            end
            // send frame preamble and sfd 55555555555555d5=8*8
            repeat (7)
            begin
                @(posedge gmii_txclk_offset);
                gmii_txctrl = 1'b1;
                gmii_txdata = 8'h55;
            end
                @(posedge gmii_txclk_offset)
                gmii_txctrl = 1'b1;
                gmii_txdata = 8'hd5;
            // send frame content
            for (index_tx=0; index_tx<packet_leng_tx; index_tx=index_tx+1)
            begin
                r_tx = $fread(packet_byte_tx, feeder_file_tx);
                @(posedge gmii_txclk_offset);
                gmii_txctrl = 1'b1;
                gmii_txdata = packet_byte_tx;
                // check whether end of file
                if (r_tx == 0) 
                begin
                    eof_tx = 1;
                    @(posedge gmii_txclk_offset);
                    gmii_txctrl = 1'b0;
                    gmii_txdata = 8'h00;
                    disable fileread_loop;
                end
            end
            end_addr_tx = $ftell(feeder_file_tx);
            num_tx = num_tx + 1;
        end
        $fclose(feeder_file_tx);
        gmii_txctrl = 1'b0;
        gmii_txdata = 8'h00;
    end
end
end
else begin
initial
begin : feeder_tx
    gmii_txctrl = 1'b0;
    gmii_txdata = 4'd0;
    #100;
    feeder_file_tx = $fopen("nic_drv_bfm/ptpdv2_tx.pcap","rb");
    if (feeder_file_tx == 0)
    begin
        $display("Failed to open ptpdv2_tx.pcap!");
        disable feeder_tx;
    end
    else
    begin
        // test pcap file endian
        r_tx = $fread(pcap_4bytes_tx, feeder_file_tx);
        pcap_endian_tx = (pcap_4bytes_tx == 32'ha1b2c3d4)? 1:0;
        s_tx = $fseek(feeder_file_tx, -4, 1);
        // skip pcap file header 24*8
        s_tx = $fseek(feeder_file_tx, 24, 1);
        // read packet content
        eof_tx = 0;
        num_tx = 0;
        while (!eof_tx & !$feof(feeder_file_tx))
        begin : fileread_loop
            // skip frame header (8+4)*8
            start_addr_tx = $ftell(feeder_file_tx);
            s_tx = $fseek(feeder_file_tx, 8+4, 1);
            // get frame length big endian 4*8
            r_tx = $fread(packet_leng_tx, feeder_file_tx);
            packet_leng_tx = pcap_endian_tx? 
                               {packet_leng_tx[31:24], packet_leng_tx[23:16], packet_leng_tx[15: 8], packet_leng_tx[ 7: 0]}:
                               {packet_leng_tx[ 7: 0], packet_leng_tx[15: 8], packet_leng_tx[23:16], packet_leng_tx[31:24]};
            // check whether end of file
            if (r_tx == 0) 
            begin
                eof_tx = 1;
                @(posedge gmii_txclk_offset);
                gmii_txctrl = 1'b0;
                gmii_txdata = 4'h0;
                @(posedge gmii_txclk_offset);
                gmii_txctrl = 1'b0;
                gmii_txdata = 4'h0;
                disable fileread_loop;
            end
            // send ifg 96bit=12*8
            repeat (12)
            begin
                @(posedge gmii_txclk_offset)
                gmii_txctrl = 1'b0;
                gmii_txdata = 4'h0;
                @(posedge gmii_txclk_offset)
                gmii_txctrl = 1'b0;
                gmii_txdata = 4'h0;
            end
            // send frame preamble and sfd 55555555555555d5=8*8
            repeat (7)
            begin
                @(posedge gmii_txclk_offset);
                gmii_txctrl = 1'b1;
                gmii_txdata = 4'h5;
                @(posedge gmii_txclk_offset);
                gmii_txctrl = 1'b1;
                gmii_txdata = 4'h5;
            end
                @(posedge gmii_txclk_offset)
                gmii_txctrl = 1'b1;
                gmii_txdata = 4'h5;
                @(posedge gmii_txclk_offset)
                gmii_txctrl = 1'b1;
                gmii_txdata = 4'hd;
            // send frame content
            for (index_tx=0; index_tx<packet_leng_tx; index_tx=index_tx+1)
            begin
                r_tx = $fread(packet_byte_tx, feeder_file_tx);
                @(posedge gmii_txclk_offset);
                gmii_txctrl = 1'b1;
                gmii_txdata = packet_byte_tx[3:0];
                @(posedge gmii_txclk_offset);
                gmii_txctrl = 1'b1;
                gmii_txdata = packet_byte_tx[7:4];
                // check whether end of file
                if (r_tx == 0) 
                begin
                    eof_tx = 1;
                    @(posedge gmii_txclk_offset);
                    gmii_txctrl = 1'b0;
                    gmii_txdata = 4'h0;
                    @(posedge gmii_txclk_offset);
                    gmii_txctrl = 1'b0;
                    gmii_txdata = 4'h0;
                    disable fileread_loop;
                end
            end
            end_addr_tx = $ftell(feeder_file_tx);
            num_tx = num_tx + 1;
        end
        $fclose(feeder_file_tx);
        gmii_txctrl = 1'b0;
        gmii_txdata = 4'h0;
    end
end
end
endgenerate

endmodule
