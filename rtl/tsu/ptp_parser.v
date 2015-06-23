/*
 * ptp_parser.v
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

module ptp_parser (
  input        clk, rst,
  input [31:0] int_data,
  input        int_valid,
  input        int_sop,
  input        int_eop,
  input [ 1:0] int_mod,

  input [ 7:0] ptp_msgid_mask,

  output reg        ptp_found,
  output reg [31:0] ptp_infor
);

// constant values
parameter c_vlan_tpid_1 = 16'h8100;
parameter c_vlan_tpid_2 = 16'h88a8;
parameter c_vlan_tpid_3 = 16'h9100;

parameter c_mpls_type_1 = 16'h8847;
parameter c_mpls_type_2 = 16'h8848;

parameter c_ipv4_type   = 16'h0800;
parameter c_ipv6_type   = 16'h86dd;

parameter c_ptp2_type   = 16'h88f7;
parameter c_ptp4_port_1 = 16'h013f;
parameter c_ptp4_port_2 = 16'h0140;

// buffer data input
reg [31:0] int_data_d1;
always @(posedge rst or posedge clk) begin
  if (rst) begin
    int_data_d1  <= 32'h00000000;
  end
  else begin
    if (int_valid) begin
      int_data_d1  <= int_data;
    end
  end
end

// packet parser: counter
reg [ 9:0] int_cnt, bypass_ipv4_cnt, bypass_ipv6_cnt, bypass_udp_cnt, ptp_cnt;
reg bypass_vlan, ptp_l2, bypass_mpls, bypass_ipv4, bypass_ipv6, found_udp, bypass_udp, ptp_l4, ptp_event;
always @(posedge rst or posedge clk) begin
  if (rst) begin
    int_cnt <= 10'd0;
    bypass_ipv4_cnt <= 10'd0;
    bypass_ipv6_cnt <= 10'd0;
    bypass_udp_cnt <= 10'd0;
  end
  else begin
    if (int_valid && int_sop)
      int_cnt <= 10'd0;
    else if (int_valid)
      int_cnt <= int_cnt + 10'd1 - bypass_vlan - bypass_mpls - (bypass_ipv4 || bypass_ipv6 || bypass_udp);

    if (int_valid && int_sop)
      bypass_ipv4_cnt <= 10'd0;
    else if (int_valid && bypass_ipv4)
      bypass_ipv4_cnt <= bypass_ipv4_cnt + 10'd1;

    if (int_valid && int_sop)
      bypass_ipv6_cnt <= 10'd0;
    else if (int_valid && bypass_ipv6)
      bypass_ipv6_cnt <= bypass_ipv6_cnt + 10'd1;

    if (int_valid && int_sop)
      bypass_udp_cnt <= 10'd0;
    else if (int_valid && bypass_udp)
      bypass_udp_cnt <= bypass_udp_cnt + 10'd1;

    if (int_valid && int_sop)
      ptp_cnt <= 10'd0;
    else if (int_valid && (ptp_l2 || (bypass_udp_cnt>=10'd2 && ptp_l4)))
      ptp_cnt <= ptp_cnt + 10'd1;
  end
end

// packet parser: comparator
always @(posedge rst or posedge clk) begin
  if (rst) begin
    bypass_vlan  <= 1'b0;
    bypass_mpls  <= 1'b0;
    bypass_ipv4  <= 1'b0;
    bypass_ipv6  <= 1'b0;
    found_udp    <= 1'b0;
    bypass_udp   <= 1'b0;
    ptp_l2    <= 1'b0;
    ptp_l4    <= 1'b0;
    ptp_event <= 1'b0;
  end
  else if (int_valid && int_sop) begin
    bypass_vlan  <= 1'b0;
    bypass_mpls  <= 1'b0;
    bypass_ipv4  <= 1'b0;
    bypass_ipv6  <= 1'b0;
    found_udp    <= 1'b0;
    bypass_udp   <= 1'b0;
    ptp_l2    <= 1'b0;
    ptp_l4    <= 1'b0;
    ptp_event <= 1'b0;
  end
  else begin
    // bypass vlan
    if      (int_valid && int_cnt==10'd4 && (int_data[31:16]==c_vlan_tpid_1 || int_data[31:16]==c_vlan_tpid_2 || int_data[31:16]==c_vlan_tpid_3))  // ether_type == vlan
      bypass_vlan <= 1'b1;
    else if (int_valid && int_cnt==10'd5 && (int_data[31:16]==c_vlan_tpid_1 || int_data[31:16]==c_vlan_tpid_2 || int_data[31:16]==c_vlan_tpid_3) && bypass_vlan)  // vlan_type == vlan
      bypass_vlan <= 1'b1;
    else if (int_valid && bypass_vlan)
      bypass_vlan <= 1'b0;

    // bypass mpls
    if      (int_valid && (int_cnt==10'd4 || bypass_vlan && int_cnt==10'd5) && 
            (int_data[31:16]==c_mpls_type_1 || int_data[31:16]==c_mpls_type_2))  // ether_type == mpls
      bypass_mpls <= 1'b1;
    else if (int_valid &&  int_cnt==10'd5 && bypass_mpls && 
             int_data[24]==1'b0)  // bottom of label stack == 0
      bypass_mpls <= 1'b1;
    else if (int_valid && bypass_mpls)
      bypass_mpls <= 1'b0;

    // bypass ipv4
    if      (int_valid && (int_cnt==10'd4 || (bypass_vlan || bypass_mpls) && int_cnt==10'd5) && bypass_ipv4_cnt==10'd0 &&
            (int_data[31:16]==c_ipv4_type || bypass_mpls) && int_data[15:12]==4'h4)  // ether_type == ipv4, ip_version == 4
      bypass_ipv4 <= 1'b1;
    else if (int_valid && bypass_ipv4_cnt==10'd4)
      bypass_ipv4 <= 1'b0;

    // bypass ipv6
    if      (int_valid && (int_cnt==10'd4 || (bypass_vlan || bypass_mpls) && int_cnt==10'd5) && bypass_ipv6_cnt==10'd0 &&
            (int_data[31:16]==c_ipv6_type || bypass_mpls) && int_data[15:12]==4'h6)  // ether_type == ipv6, ip_version == 6
      bypass_ipv6 <= 1'b1;
    else if (int_valid && bypass_ipv6_cnt==10'd9)
      bypass_ipv6 <= 1'b0;

    // check if it is udp
    if      (int_valid && bypass_ipv4_cnt==10'd1 && int_data[ 7: 0]== 8'h11)  // ipv4_protocol == udp
      found_udp <= 1'b1;
    else if (int_valid && bypass_ipv6_cnt==10'd1 && int_data[31:24]== 8'h11)  // ipv6_protocol == udp
      found_udp <= 1'b1;

    // bypass udp
    if      (int_valid && bypass_ipv4_cnt==10'd4 && bypass_udp_cnt==10'd0 && found_udp)  // ipv4_udp
      bypass_udp <= 1'b1;
    else if (int_valid && bypass_ipv6_cnt==10'd9 && bypass_udp_cnt==10'd0 && found_udp)  // ipv6_udp
      bypass_udp <= 1'b1;
    else if (int_valid && bypass_udp_cnt==10'd2)
      bypass_udp <= 1'b0;

    // check if it is L2 PTP
    if (int_valid && (int_cnt==10'd4 || bypass_vlan && int_cnt==10'd5) && int_data[31:16]==c_ptp2_type)  // ether_type == ptp
      ptp_l2 <= 1'b1;
    // check if it is L4 PTP
    if (int_valid && bypass_udp_cnt==10'd0 && bypass_udp &&
       (int_data[31:16]==c_ptp4_port_1 || int_data[31:16]==c_ptp4_port_2))  // udp_dest_port == ptp_event || ptp_general
      ptp_l4 <= 1'b1;

    // check if it is PTP Event message
    if      (int_valid && (int_cnt==10'd4 || bypass_vlan && int_cnt==10'd5) && int_data[31:16]==c_ptp2_type &&
            (ptp_msgid_mask[int_data[11: 8]]))  // ptp_message_id == ptp_event
      ptp_event <= 1'b1;
    else if (int_valid && int_cnt==10'd5 && bypass_udp_cnt==10'd1 && ptp_l4 &&
            (ptp_msgid_mask[int_data[11: 8]]))  // ptp_message_id == ptp_event 
      ptp_event <= 1'b1;
  end
end

// ptp message
reg [31:0] ptp_data;
reg [ 3:0] ptp_msgid;
reg [15:0] ptp_seqid;
reg [11:0] ptp_cksum;
always @(posedge rst or posedge clk) begin
  if (rst) begin
    ptp_data  <= 32'd0;
    ptp_msgid <= 4'd0;
    ptp_seqid <= 16'd0;
    ptp_cksum <= 12'd0;
  end
  else if (int_valid && int_sop) begin
    ptp_data  <= 32'd0;
    ptp_msgid <= 4'd0;
    ptp_seqid <= 16'd0;
    ptp_cksum <= 12'd0;
  end
  else begin
    // get PTP identification information as additional information to Timestamp
    // ptp message body
    if (int_valid && (ptp_l2 || (bypass_udp_cnt>=10'd2 && ptp_l4)))
      ptp_data <= {int_data_d1[15:0], int_data[31:16]};
    // message id
    if (int_valid && ptp_cnt==10'd1)
      ptp_msgid <= ptp_data[27:24];
    // sequence id
    if (int_valid && ptp_cnt==10'd8)
      ptp_seqid <= ptp_data[15:0];
    // sum up clock id and source port id
    if (int_valid && ptp_cnt==10'd6)
      ptp_cksum <= ptp_data[31:24] + ptp_data[23:16] + ptp_data[15: 8] + ptp_data[ 7: 0] + ptp_cksum;
    if (int_valid && ptp_cnt==10'd7)
      ptp_cksum <= ptp_data[31:24] + ptp_data[23:16] + ptp_data[15: 8] + ptp_data[ 7: 0] + ptp_cksum;
    if (int_valid && ptp_cnt==10'd8)
      ptp_cksum <= ptp_data[31:24] + ptp_data[23:16]                                     + ptp_cksum;
  end
end

// parser output
always @(posedge rst or posedge clk) begin
  if (rst) begin
    ptp_found <=  1'b0;
    ptp_infor <= 32'd0;
  end
  else if (int_valid && int_sop) begin
    ptp_found <=  1'b0;
    ptp_infor <= 32'd0;
  end
  else if (int_valid && ptp_cnt==10'd9) begin
    ptp_found <=  ptp_event;
    ptp_infor <= {ptp_msgid, ptp_cksum, ptp_seqid};  // 4+12+16
  end
end

endmodule
