/*
 * rtc.v
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

module rtc (
  input rst, clk,
  // 1. direct time adjustment: ToD set up
  input        time_ld,
  input [37:0] time_reg_ns_in,   // 37:8 ns, 7:0 ns_fraction
  input [47:0] time_reg_sec_in,  // 47:0 sec
  // 2. frequency adjustment: frequency set up for drift compensation
  input        period_ld,
  input [39:0] period_in,        // 39:32 ns, 31:0 ns_fraction
  // 3. precise time adjustment: small time difference adjustment with a time mark
  input        adj_ld,
  input [31:0] adj_ld_data,
  output reg   adj_ld_done,
  input [39:0] period_adj,  // 39:32 ns, 31:0 ns_fraction

  // time output: for internal with ns fraction
  output [37:0] time_reg_ns,  // 37:8 ns, 7:0 ns_fraction
  output [47:0] time_reg_sec, // 47:0 sec
  // time output: for external with one pps accuracy 
  output reg    time_one_pps,
  // time output: for external with ptp standard
  output [31:0] time_ptp_ns,  // 31:0 ns
  output [47:0] time_ptp_sec  // 47:0 sec
);

parameter time_acc_modulo = 38'd256000000000;  // 1,000,000,000ns * 256ns_fraction, 1s carry_out

reg  [39:0] period_fix;  // 39:32 ns, 31:0 ns_fraction
reg  [31:0] adj_cnt;
reg  [39:0] time_adj;    // 39:32 ns, 31:0 ns_fraction
// frequency and small time difference adjustment registers
always @(posedge rst or posedge clk) begin
  if (rst) begin
    period_fix  <= period_fix;  //40'd0;
    adj_cnt     <= 32'hffffffff;
    time_adj    <= time_adj;    //40'd0;
    adj_ld_done <= 1'b0;
  end
  else begin
    if (period_ld)  // load period adjustment
      period_fix <= period_in;
    else
      period_fix <= period_fix;

    if (adj_ld)  // load precise time adjustment time mark
      adj_cnt  <= adj_ld_data;
    else if (adj_cnt==32'hffffffff)
      adj_cnt  <= adj_cnt;  // no cycling
    else
      adj_cnt  <= adj_cnt - 1;  // counting down

    if (adj_cnt==0)  // change period temparorily
      time_adj <= period_fix + period_adj;
    else
      time_adj <= period_fix + 0;

    if (adj_cnt==32'hffffffff)
      adj_ld_done <= 1'b1;
    else
      adj_ld_done <= 1'b0;
  end
end

reg  [39:0] time_adj_08n_32f;      //             39:32 ns, 31:0 ns_fraction
reg  [39:0] time_adj_16b_00n_24f;  // 39:24 sign,           23:0 ns_fraction
wire [37:0] time_adj_22b_08n_08f;  // 37:16 sign, 15: 8 ns,  7:0 ns_fraction
// delta-sigma circuit to keep the lower 24bit of time_adj
always @(posedge rst or posedge clk) begin
  if (rst) begin
    time_adj_08n_32f     <= 40'd0;
    time_adj_16b_00n_24f <= 24'd0;
  end
  else begin
    time_adj_08n_32f     <= time_adj[39: 0] + time_adj_16b_00n_24f;  // add the delta
    time_adj_16b_00n_24f <= {16'h0000, time_adj_08n_32f[23: 0]}; // save the delta
  end
end
assign time_adj_22b_08n_08f = time_adj_08n_32f[39]? {22'h3fffff, time_adj_08n_32f[39:24]}: {22'h000000, time_adj_08n_32f[39:24]};  // preserve the sign

reg  [37:0] time_acc_30n_08f_pre_pos;  // 37:8 ns , 7:0 ns_fraction
reg  [37:0] time_acc_30n_08f_pre_neg;  // 37:8 ns , 7:0 ns_fraction
wire        time_acc_48s_inc = (time_acc_30n_08f_pre_pos >= time_acc_modulo)? 1'b1: 1'b0;
// time accumulator pre adder (48bit_s + 30bit_ns + 8bit_ns_fraction)
always @(posedge rst or posedge clk) begin
  if (rst) begin
    time_acc_30n_08f_pre_pos <= 38'd0;
    time_acc_30n_08f_pre_neg <= 38'd0;
  end
  else begin
    if (time_ld) begin  // direct write
      time_acc_30n_08f_pre_pos <= time_reg_ns_in + time_adj_22b_08n_08f;
      time_acc_30n_08f_pre_neg <= time_reg_ns_in + time_adj_22b_08n_08f;
    end
    else begin
      if (time_acc_48s_inc) begin
        time_acc_30n_08f_pre_pos <= time_acc_30n_08f_pre_neg + time_adj_22b_08n_08f;
        time_acc_30n_08f_pre_neg <= time_acc_30n_08f_pre_neg + time_adj_22b_08n_08f - time_acc_modulo;
      end
      else begin
        time_acc_30n_08f_pre_pos <= time_acc_30n_08f_pre_pos + time_adj_22b_08n_08f;
        time_acc_30n_08f_pre_neg <= time_acc_30n_08f_pre_pos + time_adj_22b_08n_08f - time_acc_modulo;
      end
    end
  end
end

reg  [37:0] time_acc_30n_08f;          // 37:8 ns , 7:0 ns_fraction
reg  [47:0] time_acc_48s;              // 47:0 sec
// time accumulator (48bit_s + 30bit_ns + 8bit_ns_fraction)
always @(posedge rst or posedge clk) begin
  if (rst) begin
    time_acc_30n_08f <= 38'd0;
    time_acc_48s     <= 48'd0;
  end
  else begin
    if (time_ld) begin  // direct write
      time_acc_30n_08f <= time_reg_ns_in;
      time_acc_48s     <= time_reg_sec_in;
    end
    else begin

      if (time_acc_48s_inc)
        time_acc_30n_08f <= time_acc_30n_08f_pre_neg;
      else
        time_acc_30n_08f <= time_acc_30n_08f_pre_pos;

      if (time_acc_48s_inc)
        time_acc_48s     <= time_acc_48s + 1;
      else
        time_acc_48s     <= time_acc_48s;

    end
  end
end

// time output (48bit_s + 30bit_ns + 8bit_ns_fraction)
assign time_reg_ns  = time_acc_30n_08f;
assign time_reg_sec = time_acc_48s;
// time output (48bit_s + 32bit_ns)
assign time_ptp_ns  = {2'b00, time_acc_30n_08f[37:8]};  // 30bit is enough to represent 1,000,000,000ns
assign time_ptp_sec = time_acc_48s;
// time output one pps
always @(posedge rst or posedge clk) begin
  if (rst)
    time_one_pps <= 1'b0;
  else
    time_one_pps <= time_acc_48s_inc;
end

endmodule
