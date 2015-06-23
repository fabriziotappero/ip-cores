/*
 *  WISHBONE to SystemACE MPU + CY7C67300 bridge
 *  Copyright (C) 2008 Sebastien Bourdeauducq - http://lekernel.net
 *  Modified on Mar 2009 by Zeus Gomez Marmolejo <zeus@opencores.org>
 *
 *  This file is part of the Zet processor. This processor is free
 *  hardware; you can redistribute it and/or modify it under the terms of
 *  the GNU General Public License as published by the Free Software
 *  Foundation; either version 3, or (at your option) any later version.
 *
 *  Zet is distrubuted in the hope that it will be useful, but WITHOUT
 *  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 *  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public
 *  License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Zet; see the file COPYING. If not, see
 *  <http://www.gnu.org/licenses/>.
 */

module aceusb (
    /* WISHBONE slave interface */
    input         wb_clk_i,
    input         wb_rst_i,
    input  [ 6:1] wb_adr_i,
    input  [15:0] wb_dat_i,
    output [15:0] wb_dat_o,
    input         wb_cyc_i,
    input         wb_stb_i,
    input         wb_we_i,
    output reg    wb_ack_o,

    /* Signals shared between SystemACE and USB */
    output [ 6:1] aceusb_a_,
    inout  [15:0] aceusb_d_,
    output        aceusb_oe_n_,
    output        aceusb_we_n_,

    /* SystemACE signals */
    input         ace_clkin_,
    output        ace_mpce_n_,

    output        usb_cs_n_,
    output        usb_hpi_reset_n_
  );

wire access_read1;
wire access_write1;
wire access_ack1;

/* Avoid potential glitches by sampling wb_adr_i and wb_dat_i only at the appropriate time */
reg load_adr_dat;
reg [5:0] address_reg;
reg [15:0] data_reg;
always @(posedge wb_clk_i) begin
  if(load_adr_dat) begin
    address_reg <= wb_adr_i;
    data_reg <= wb_dat_i;
  end
end

aceusb_access access(
  .ace_clkin(ace_clkin_),
  .rst(wb_rst_i),
  
  .a(address_reg),
  .di(data_reg),
  .do(wb_dat_o),
  .read(access_read1),
  .write(access_write1),
  .ack(access_ack1),

  .aceusb_a(aceusb_a_),
  .aceusb_d(aceusb_d_),
  .aceusb_oe_n(aceusb_oe_n_),
  .aceusb_we_n(aceusb_we_n_),
  .ace_mpce_n(ace_mpce_n_),
  .usb_cs_n(usb_cs_n_),
  .usb_hpi_reset_n(usb_hpi_reset_n_)
);

/* Synchronize read, write and acknowledgement pulses */ 
reg access_read;
reg access_write;
wire access_ack;
wire op;

aceusb_sync sync_read(
  .clk0(wb_clk_i),
  .flagi(access_read),
  
  .clk1(ace_clkin_),
  .flago(access_read1)
);

aceusb_sync sync_write(
  .clk0(wb_clk_i),
  .flagi(access_write),
  
  .clk1(ace_clkin_),
  .flago(access_write1)
);

aceusb_sync sync_ack(
  .clk0(ace_clkin_),
  .flagi(access_ack1),
  
  .clk1(wb_clk_i),
  .flago(access_ack)
);

/* Main FSM */

reg  state;
reg  next_state;

localparam
  IDLE = 1'd0,
  WAIT = 1'd1;

  assign op = wb_cyc_i & wb_stb_i;

always @(posedge wb_clk_i) begin
  if(wb_rst_i)
    state <= IDLE;
  else
    state <= next_state;
end

always @(state or op or wb_we_i or access_ack) begin
  load_adr_dat = 1'b0;
  wb_ack_o = 1'b0;
  access_read = 1'b0;
  access_write = 1'b0;
  
  next_state = state;
  
  case(state)
    IDLE: begin
      if(op) begin
        load_adr_dat = 1'b1;
        if(wb_we_i)
          access_write = 1'b1;
        else
          access_read = 1'b1;
        next_state = WAIT;
      end
    end

    WAIT: begin
      if(access_ack) begin
        wb_ack_o = 1'b1;
        access_write = 1'b0;
        load_adr_dat = 1'b0;
        access_read = 1'b0;
        next_state = IDLE;
      end
    end
  endcase
end

endmodule
