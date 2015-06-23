/*
 * ptp_queue.v
 * 
 * Copyright (c) 2012, BABY&HW. All rights reserved.
 *
 * This library is free software, you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation, either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY, without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library, if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301  USA
 */

`timescale 1ns/1ns
`include "define.h"

module ptp_queue (
  input          aclr,
  input	 [127:0] data,
  input	         rdclk,
  input	         rdreq,
  input	         wrclk,
  input	         wrreq,
  output [127:0] q,
  output         rdempty,
  output [  3:0] rdusedw,
  output         wrfull,
  output [  3:0] wrusedw
);

`ifdef USE_ALTERA_IP
dcfifo_128b_16 dcfifo(
  .aclr(aclr),

  .wrclk(wrclk),
  .wrreq(wrreq),
  .data(data),
  .wrfull(wrfull),
  .wrusedw(wrusedw),

  .rdclk(rdclk),
  .rdreq(rdreq),
  .q(q),
  .rdempty(rdempty),
  .rdusedw(rdusedw)
);
`endif

`ifdef USE_XILINX_IP
dcfifo_128b_16 dcfifo(
  .rst(aclr),

  .wr_clk(wrclk),
  .wr_en(wrreq),
  .din(data),
  .full(wrfull),
  .wr_data_count(wrusedw),

  .rd_clk(rdclk),
  .rd_en(rdreq),
  .dout(q),
  .empty(rdempty),
  .rd_data_count(rdusedw)
);
`endif

endmodule
