//faux_sata_hd_phy.v
/*
Distributed under the MIT license.
Copyright (c) 2011 Dave McCoy (dave.mccoy@cospandesign.com)

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

`include "sata_defines.v"

module faux_sata_hd_phy (
//Inputs/Outputs
input               rst,              //reset
input               clk,

//Data Interface
output  reg [31:0]  tx_dout,
output  reg         tx_isk,
output  reg         tx_set_elec_idle,
output  reg         rx_byte_is_aligned,

input       [31:0]  rx_din,
input       [3:0]   rx_isk,
input               rx_is_elec_idle,

input               comm_reset_detect,
input               comm_wake_detect,

output  reg         tx_comm_reset,
output  reg         tx_comm_wake,

output      [3:0]   lax_state,

output  reg         hd_ready,
output              phy_ready



);

//Parameters
parameter           IDLE                  = 4'h0;
parameter           WAIT_FOR_NO_RESET     = 4'h1;
parameter           SEND_INIT             = 4'h2;
parameter           WAIT_FOR_WAKE         = 4'h3;
parameter           WAIT_FOR_NO_WAKE      = 4'h4;
parameter           SEND_WAKE             = 4'h5;
parameter           STOP_SEND_WAKE        = 4'h6;
parameter           SEND_CONFIGURE_END    = 4'h7;
parameter           WAIT_FOR_DIALTONE     = 4'h8;
parameter           SEND_ALIGN            = 4'h9;
parameter           WAIT_FOR_ALIGN        = 4'hA;
parameter           READY                 = 4'hB;
parameter           SEND_FIRST_ALIGNMENT  = 4'hC;
parameter           SEND_SECOND_ALIGNMENT = 4'hD;


parameter           INITIALIZE_TIMEOUT         = 100;

//Registers/Wires
reg         [3:0]   state = IDLE;
reg         [31:0]  timer;
reg         [7:0]   align_count;
wire                align_detected;
wire                dialtone_detected;
wire                timeout;

//Sub Modules


//Asynchronous Logic

assign              lax_state         = state;
assign              align_detected    = ((rx_isk > 0) && (rx_din == `PRIM_ALIGN));
assign              dialtone_detected = ((rx_isk == 0) && (rx_din == `DIALTONE));
assign              timeout           = (timer == 0);
assign              phy_ready         = (state == READY);

//Synchronous Logic
always @ (posedge clk) begin
  if (rst) begin
    state                   <=  IDLE;
    tx_dout                 <=  0;
    tx_isk                  <=  0;
    tx_set_elec_idle        <=  1;
    timer                   <=  0;
    hd_ready                <=  0;
    rx_byte_is_aligned      <=  0;
    align_count             <=  0;
  end
  else begin
    tx_comm_reset           <=  0;
    tx_comm_wake            <=  0;
    rx_byte_is_aligned      <=  0;

    if (state == READY) begin
      align_count           <=  align_count + 1;
    end
    if (timer > 0) begin
      timer                 <=  timer - 1;
    end

    if ((comm_reset_detect) && (state > WAIT_FOR_NO_RESET)) begin
      $display("faux_sata_hd: Asynchronous RESET detected");
      state                 <=  IDLE;
    end

    case (state)
      IDLE: begin
        align_count   <=  0;
        hd_ready            <=  0;
        tx_set_elec_idle    <=  1;
        if (comm_reset_detect) begin
          //detected a reset from the host
          $display("faux_sata_hd: RESET detected");
          state             <=  WAIT_FOR_NO_RESET;
        end
      end
      WAIT_FOR_NO_RESET: begin
        if (!comm_reset_detect) begin
          //host stopped sending reset
          $display("faux_sata_hd: RESET deasserted");
          hd_ready            <=  0;
          tx_set_elec_idle    <=  1;
          state             <=  SEND_INIT;
        end
      end
      SEND_INIT: begin
//XXX: I may need to send more than one of these
        $display("faux_sata_hd: send INIT");
        tx_comm_reset       <=  1;
        state               <=  WAIT_FOR_WAKE;
      end
      WAIT_FOR_WAKE: begin
        if (comm_wake_detect) begin
          $display ("faux_sata_hd: WAKE detected");
          state             <=  WAIT_FOR_NO_WAKE;
        end
      end
      WAIT_FOR_NO_WAKE: begin
        if (!comm_wake_detect) begin
          $display ("faux_sata_hd: WAKE deasserted");
          state             <=  SEND_WAKE;
        end
      end
      SEND_WAKE: begin
        $display ("faux_sata_hd: send WAKE");
        tx_comm_wake        <=  1;
        state               <=  STOP_SEND_WAKE;
      end
      STOP_SEND_WAKE: begin
        $display ("faux_sata_hd: stop sending WAKE");
        state               <=  WAIT_FOR_DIALTONE;
      end
      WAIT_FOR_DIALTONE: begin
        if (dialtone_detected) begin
          $display ("faul_sata_hd: detected dialtone");
          state             <=  SEND_ALIGN;
        end
      end
      SEND_ALIGN: begin
        $display ("faul_sata_hd: send aligns");
        tx_set_elec_idle    <=  0;
        tx_dout             <=  `PRIM_ALIGN;
        tx_isk              <=  1;
        state               <=  WAIT_FOR_ALIGN;
        timer               <=  32'h`INITIALIZE_TIMEOUT;
        rx_byte_is_aligned  <=  1;
      end
      WAIT_FOR_ALIGN: begin
        rx_byte_is_aligned  <=  1;
        if (align_detected) begin
          $display ("faux_sata_hd: detected ALIGN primitive from host");
          $display ("faux_sata_hd: Ready");
          tx_dout           <=  `PRIM_ALIGN;
          tx_isk            <=  1;
          timer             <=  0;
          state             <=  READY;
        end
        else if (timeout) begin
          $display ("faux_sata_hd: Timeout while waiting for an alignment from the host");
          state             <=  IDLE;
        end
      end
      READY: begin
        hd_ready            <=  1;
        rx_byte_is_aligned  <=  1;
        tx_isk              <=  1;
        tx_dout             <=  `PRIM_SYNC;
        if (align_count == 255) begin
          tx_dout           <=  `PRIM_ALIGN;
          state             <=  SEND_FIRST_ALIGNMENT;
        end
      end
      SEND_FIRST_ALIGNMENT: begin
        rx_byte_is_aligned  <=  1;
        tx_isk              <=  1;
        tx_dout             <=  `PRIM_ALIGN;
        state               <=  SEND_SECOND_ALIGNMENT;
      end
      SEND_SECOND_ALIGNMENT: begin
        rx_byte_is_aligned  <=  1;
        tx_isk              <=  1;
        tx_dout             <=  `PRIM_ALIGN;
        state               <=  READY;
      end
      default: begin
        $display ("faux_sata_hd: In undefined state!");
        state               <=  IDLE;
      end
    endcase
  end
end

endmodule
