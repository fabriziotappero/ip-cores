//sata_phy_layer.v
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

module sata_phy_layer (

input               rst,            //reset
input               clk,

input               platform_ready,   //the underlying physical platform is
output              linkup,           //link is finished

output  [31:0]      tx_dout,
output              tx_isk,
output              tx_comm_reset,
output              tx_comm_wake,
output              tx_elec_idle,

input   [31:0]      rx_din,
input   [3:0]       rx_isk,
input               rx_elec_idle,
input               rx_byte_is_aligned,
input               comm_init_detect,
input               comm_wake_detect,

output              phy_ready,
output      [3:0]   lax_state

);


//Parameters
parameter           NOT_READY         = 4'h0;
parameter           SEND_FIRST_ALIGN  = 4'h1;
parameter           SEND_SECOND_ALIGN = 4'h2;
parameter           READY             = 4'h3;

//Registers/Wires
reg         [3:0]   state;
reg         [7:0]   align_count;

//OOB Control
wire        [31:0]  oob_tx_dout;
wire                oob_tx_isk;

//Phy Control
wire        [31:0]  phy_tx_dout;
wire                phy_tx_isk;
wire                align_detected;



//Submodules
oob_controller oob (
  .rst                (rst),
  .clk                (clk),

  //OOB controller
  .platform_ready     (platform_ready),
  .linkup             (linkup),

  //Platform Control
  .tx_dout            (oob_tx_dout),
  .tx_isk             (oob_tx_isk),
  .tx_comm_reset      (tx_comm_reset),
  .tx_comm_wake       (tx_comm_wake),
  .tx_set_elec_idle   (tx_elec_idle),

  .rx_din             (rx_din),
  .rx_isk             (rx_isk),
  .comm_init_detect   (comm_init_detect),
  .comm_wake_detect   (comm_wake_detect),
  .rx_byte_is_aligned (rx_byte_is_aligned),
  .rx_is_elec_idle    (rx_elec_idle),
  .lax_state          (lax_state)

);

//Asynchronous Logic
assign              tx_dout         = !linkup ? oob_tx_dout : phy_tx_dout;
assign              tx_isk          = !linkup ? oob_tx_isk  : phy_tx_isk;

assign              phy_tx_dout     =  `PRIM_ALIGN;
assign              phy_tx_isk      =  1;

assign              align_detected  = ((rx_isk > 0) && (rx_din == `PRIM_ALIGN) && rx_byte_is_aligned);
//assign              phy_ready       = ((state == READY) && (!align_detected));
assign              phy_ready       = (state == READY);



//Synchronous Logic
always @ (posedge clk) begin
  if (rst) begin
    state             <=  NOT_READY;
    align_count       <=  0;
  end
  else begin
    if (state == READY) begin
      align_count       <=  align_count + 1;
    end
    case (state)
      NOT_READY:  begin
        align_count   <=  0;
        if (linkup) begin
`ifdef VERBOSE
          $display ("sata_phy_layer: linkup! send aligns");
`endif
          state       <=  SEND_FIRST_ALIGN;
        end
      end
      SEND_FIRST_ALIGN: begin
        state         <=  SEND_SECOND_ALIGN;
      end
      SEND_SECOND_ALIGN: begin
        state         <=  READY;
      end
      READY:      begin
        if (align_count ==  255) begin
          state       <=  SEND_FIRST_ALIGN;
`ifdef VERBOSE
          $display ("sata_phy_layer: linkup! send alignment dwords");
`else
          $display ("sata_phy_layer: .");
`endif
//Send an align primitive
        end
      end
      default:    begin
      end
    endcase
  end
end



endmodule
