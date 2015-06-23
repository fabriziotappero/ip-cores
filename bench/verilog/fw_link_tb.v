// $Id: fw_link_tb.v,v 1.2 2003-04-27 04:30:51 johnsonw10 Exp $
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// FIREWIRE IP Core                                             ////
////                                                              ////
//// This file is part of the firewire project                    ////
//// http://www.opencores.org/cores/firewire/                     ////
////                                                              ////
//// Description                                                  ////
//// Implementation of firewire IP core according to              ////
//// firewire IP core specification document.                     ////
////                                                              ////
//// To Do:                                                       ////
//// -                                                            ////
////                                                              ////
//// Author(s):                                                   ////
//// - johnsonw10@opencores.org                                   ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2001 Authors and OPENCORES.ORG                 ////
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
//// PURPOSE. See the GNU Lesser General Public License for more  ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.1  2002/03/10 17:17:36  johnsonw10
// Initail revision. Top level test bench.
//
//
//

/**********************************************************************
  Design Notes:
  1. Startup sequence:
     * hard reset
     * set all enable signals
     * PHY receives self ID packet
     * PHY status receiving of self ID packet (PHYID write)
     * 
     * 
     * 
***********************************************************************/

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on

`include "fw_link_defines.vh"

module fw_link_tb;

parameter BUF_SIZE = 64;
reg reset_n;
reg sclk;

wire [0:7] d;
wire [0:1] ctl;

wire [0:3] phy_reg_addr;
wire [0:7] phy_reg_data;

wire [0:31] grxf_data, atxf_data, itxf_data;

integer pkt_type;

reg [0:31] selfid_data;
reg [0:3] ack_code;

// host interface
reg [0:7]  host_addr;
wire [0:31] host_data;
reg  [0:31] host_data_out;  // driven by the host

reg        host_cs_n, host_wr_n;
reg [0:31] send_buf[0:BUF_SIZE-1];
reg [0:31] exp_buf[0:BUF_SIZE-1];

wire [0:7]  phy_d;
wire [0:1]  phy_ctl;

reg [0:15] status, exp_status, rcvd_status;

integer rcvd_ql_num, exp_ql_num;

reg [0:31] atxf_din;
reg        atxf_wr;

reg [0:31] itxf_din;
reg        itxf_wr;

// packet fields
reg [0:1] spd;
reg [0:5] tl;
reg [0:1] rt;
reg [0:3] tc;
reg [0:3] pri;
reg [0:15] dest_id;
reg [0:47] dest_offset;

reg err_count;


initial begin
    // set time format
    $timeformat(-9, 1, " ns", 5);
    err_count = 0;
    reset_n = 1;
    host_cs_n = 1;
    host_wr_n = 1;

    rcvd_ql_num = 0;
    atxf_wr = 0;

    #25 reset_n = 0;
    #100 reset_n = 1;
    
    
    // enable link_op (set bits 5, 6, 7, 8 @ 0x08)
    host_write_reg (16'h08, 32'h0780_0000);
    
    #100;

    // phy receive selfid packet #0
    spd = 2'b00;
    pkt_type = `SELF_ID_PKT;
    selfid_data[0:1]   = 2'b01;          //selfid packet identifier
    selfid_data[2:7]   = 6'b00_0011;     //sender's phy_ID
    selfid_data[8]     = 1'b0;           //always 0
    selfid_data[9]     = 1'b1;           //link_active = 1
    selfid_data[10:15] = 6'b01_0000;     //gap_count = 10h
    selfid_data[16:17] = 2'b00;          //phy_speed = 100Mbit/s
    selfid_data[18:19] = 2'b00;          //phy_delay <= 144ns
    selfid_data[20]    = 1'b0;           //contender = 0
    selfid_data[21:23] = 3'b000;         //power_class = 0;
    selfid_data[24:25] = 2'b11;          //p0;
    selfid_data[26:27] = 2'b11;          //p1
    selfid_data[28:29] = 2'b11;          //p2
    selfid_data[30]    = 1'b0;           //initiated_reset = 0
    selfid_data[31]    = 1'b0;           //more_packets = 0

    phy_ctrl.rcv_buf[0] = selfid_data;
    phy_ctrl.rcv_buf[1] = ~selfid_data;

    set_exp_buf (2);
    
    phy_ctrl.phy_rcv_pkt (spd, pkt_type);     //receive 2 32-bit word at 100Mbit/s

    #100;

    //phy status
    status[0]    = 1'b1;     // reset_gap = 1
    status[1]    = 1'b0;     // sub_gap = 0
    status[2]    = 1'b0;     // bus_reset = 0;
    status[3]    = 1'b0;     // bus_time_out = 0;
    status[4:7]  = 4'h0;     // physical_id addr
    status[8:15] = 8'b0010_1000;  // id = a, r = 0, ps = 0
    
    exp_status = status;
    phy_ctrl.phy_status (status);

    // read request for data quadlet at 400Mbit/s
    phy_ctrl.arb_won = 1;  //tells phy to grant the bus control
    spd = 2'b10;
    tl = 6'b010101;
    rt = 2'b01;
    tc = 4'h4;
    pri = 4'h0;
    dest_id = 16'haaaa;
    dest_offset = 48'h1234_5678_9abc;

    phy_ctrl.send_ack = 1; //tells phy to send back ack pakcet
    set_send_buf (3);

    $display ("STATUS @%t: %m: sending read request for data for quadlet", 
	      $time);
    host_write_atxf (3);

    // dest sends back ack packet
    wait (phy_ctrl.pkt_sent);
    spd = 2'b10;
    pkt_type = `ACK_PKT;
    ack_code = `ACK_COMPLETE;
    phy_ctrl.rcv_buf[0] = {ack_code, ~ack_code, 24'h00_0000};
    phy_ctrl.phy_rcv_pkt(spd, pkt_type);

end

initial sclk = 0;
always #10 sclk = ~sclk;   // 50MHz sclk
    
// atx FIFO
fifo_beh atxf (
	       // Outputs
	       .dout			(atxf_data[0:31]),
	       .empty			(atxf_ef),
	       .full			(atxf_ff),
	       // Inputs
	       .reset_n			(reset_n),
	       .clk			(sclk),
	       .wr			(atxf_wr),
	       .din			(atxf_din[0:31]),
	       .rd			(atxf_rd));

// itx FIFO
fifo_beh itxf (
	       // Outputs
	       .dout			(itxf_data[0:31]),
	       .empty			(itxf_ef),
	       .full			(itxf_ff),
	       // Inputs
	       .reset_n			(reset_n),
	       .clk			(sclk),
	       .wr			(itxf_wr),
	       .din			(itxf_din[0:31]),
	       .rd			(itxf_rd));

wire [0:15] src_id;
wire hard_rst = ~reset_n;

// bi-directional d and ctl buses
tran tran_d0 (d[0], phy_d[0]);
tran tran_d1 (d[1], phy_d[1]);
tran tran_d2 (d[2], phy_d[2]);
tran tran_d3 (d[3], phy_d[3]);
tran tran_d4 (d[4], phy_d[4]);
tran tran_d5 (d[5], phy_d[5]);
tran tran_d6 (d[6], phy_d[6]);
tran tran_d7 (d[7], phy_d[7]);

tran tran_ctl0(ctl[0], phy_ctl[0]);
tran tran_ctl1(ctl[1], phy_ctl[1]);

assign host_data = host_data_out;

fw_link_host_if link_host_if (/*AUTOINST*/
			      // Outputs
			      .src_id	(src_id[0:15]),
			      .tx_asy_en(tx_asy_en),
			      .rx_asy_en(rx_asy_en),
			      .tx_iso_en(tx_iso_en),
			      .rx_iso_en(rx_iso_en),
			      .soft_rst	(soft_rst),
			      // Inouts
			      .host_data(host_data[0:31]),
			      // Inputs
			      .hard_rst	(hard_rst),
			      .sclk	(sclk),
			      .host_cs_n(host_cs_n),
			      .host_wr_n(host_wr_n),
			      .host_addr(host_addr[0:7]));

fw_link_ctrl link_ctrl (/*AUTOINST*/
			// Outputs
			.lreq		(lreq),
			.status_rcvd	(status_rcvd),
			.arb_reset_gap	(arb_reset_gap),
			.sub_gap	(sub_gap),
			.bus_reset	(bus_reset),
			.state_time_out	(state_time_out),
			.phy_reg_addr	(phy_reg_addr[0:3]),
			.phy_reg_data	(phy_reg_data[0:7]),
			.atxf_rd	(atxf_rd),
			.itxf_rd	(itxf_rd),
			.grxf_we	(grxf_we),
			.grxf_data	(grxf_data[0:31]),
			// Inouts
			.d		(d[0:7]),
			.ctl		(ctl[0:1]),
			// Inputs
			.hard_rst	(hard_rst),
			.sclk		(sclk),
			.src_id		(src_id[0:15]),
			.soft_rst	(soft_rst),
			.tx_asy_en	(tx_asy_en),
			.rx_asy_en	(rx_asy_en),
			.tx_iso_en	(tx_iso_en),
			.rx_iso_en	(rx_iso_en),
			.atxf_ef	(atxf_ef),
			.atxf_data	(atxf_data[0:31]),
			.itxf_ef	(itxf_ef),
			.itxf_data	(itxf_data[0:31]),
			.grxf_ff	(grxf_ff));

wire lreq_sent;

assign phy_ctrl.lreq_rcvd = link_ctrl.link_req.req_sent;

defparam phy_ctrl.BUF_SIZE = BUF_SIZE;
fw_phy_ctrl phy_ctrl (/*AUTOINST*/
		      // Inouts
		      .phy_ctl		(phy_ctl[0:1]),
		      .phy_d		(phy_d[0:7]),
		      // Inputs
		      .sclk		(sclk));

// grxf monitor
always @ (posedge sclk) begin : grxf_monitor
    if (grxf_we) begin
	$display ("STATUS @%t: %m: received quadlet %0d = %x", 
		  $time, rcvd_ql_num, grxf_data);
	if (grxf_data != exp_buf[rcvd_ql_num]) begin
	    $display ("ERROR @%t: %m: incorrect quadlet %0d received:", 
		      $time, rcvd_ql_num);
	    $display ("        expected: %x", exp_buf[rcvd_ql_num]);
	    $display ("        received: %x", grxf_data);

	    err_count = err_count + 1;
	end

	rcvd_ql_num = (rcvd_ql_num == exp_ql_num) ? 0 : (rcvd_ql_num + 1);
    end
end

// status monitor
always @ (posedge sclk) begin : status_monitor
    if (status_rcvd) begin
	rcvd_status = {arb_reset_gap, sub_gap, bus_reset, state_time_out, 
		       phy_reg_addr, phy_reg_data};
	$display ("STATUS @%t: %m: received phy status = %x", 
		  $time, rcvd_status);
	$display ("    arb_reset_gap = %h", arb_reset_gap);
	$display ("    sub_gap = %h", sub_gap);
	$display ("    bus_reset = %h", bus_reset);
	$display ("    state_time_out = %h", state_time_out);
	$display ("    phy_reg_addr = %h", phy_reg_addr);
	$display ("    phy_reg_data = %h", phy_reg_data);

	if (exp_status != rcvd_status) begin
	    $display ("ERROR @%t: %m: incorrect phy status received:", $time);
	    $display ("        expected: %x", exp_status);
	    $display ("        received: %x", rcvd_status);

	    err_count = err_count + 1;
	end
    end
end

`include "fw_host_tasks.v"

task set_send_buf;
input ql_num;
integer ql_num;

begin
    send_buf[0] = {14'h0000, spd, tl, rt, tc, pri};
    send_buf[1] = {dest_id, dest_offset[0:15]};
    send_buf[2] = dest_offset[16:47];

    // set exp_buf for the checker
    phy_ctrl.tx_spd     = spd;
    phy_ctrl.exp_ql_num = ql_num + 1;
    phy_ctrl.exp_buf[0] = {dest_id, tl, rt, tc, pri};
    phy_ctrl.exp_buf[1] = {src_id, dest_offset[0:15]};
    phy_ctrl.exp_buf[2] = dest_offset[16:47];
    phy_ctrl.exp_buf[3] = gen_crc(ql_num);
end
endtask // set_send_buf

task set_exp_buf;
input ql_num;
integer ql_num;
begin
    exp_ql_num = 2;
    exp_buf[0] = phy_ctrl.rcv_buf[0];
    exp_buf[1] = phy_ctrl.rcv_buf[1];
end
endtask // set_exp_buf

// CRC32 generation function
parameter MSB32       = 32'h8000_0000;
parameter CRC_COMPUTE = 32'h04c1_1db7;
parameter CRC_RESULTs = 32'hc704_dd7b;

function [0:31] gen_crc;
input ql_num;
integer ql_num;

reg [0:31] crc_sum;
reg [0:31] mask;
reg        new_bit, old_bit, sum_bit;
 
integer i;
integer in_ql;
begin
    crc_sum = 32'hffff_ffff;
    for (i = 0; i < ql_num; i = i + 1) begin
	in_ql = phy_ctrl.exp_buf[i];
	for (mask = MSB32; mask != 0; mask = mask >> 1) begin
	    new_bit = ((in_ql & mask) != 32'h0000_0000);
	    old_bit = ((crc_sum & MSB32) != 32'h0000_0000);
	    sum_bit = old_bit ^ new_bit;

	    // update crc_sum
	    crc_sum = (crc_sum << 1) ^ (sum_bit ? CRC_COMPUTE : 0);
	end // (mask = MSB32; mask != 0; mask = mask >> 1)
    end //for (i = 0; i < ql_num, i = i + 1)

    gen_crc = crc_sum;
end
endfunction

endmodule // fw_link_tb

// Local Variables:
// verilog-library-directories:("." "../../rtl/verilog")
// End: