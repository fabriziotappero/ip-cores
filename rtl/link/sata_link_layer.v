//sata_link_layer.v
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

module sata_link_layer (
  input               rst,            //reset
  input               clk,

//Command Interface
  output              link_layer_ready,

  input               sync_escape,
  output              post_align_write,
  input               hold,

//Phy Layer
  input               phy_ready,
  output              write_ready,
  input               platform_ready,

//XXX: I probably need some feedback to indicate that there is room to write
  output    [31:0]    tx_dout,
  output              tx_isk,

  input     [31:0]    rx_din,
  input     [3:0]     rx_isk,

  input               write_start,
  output              write_strobe,
  input     [31:0]    write_data,
  input     [31:0]    write_size,
  input               write_hold,
  output              write_finished,
  input               write_abort,

  output              read_start,
  output              read_strobe,
  output      [31:0]  read_data,
  input               read_ready,
  output              read_finished,
  output              read_crc_ok,
  output              remote_abort,

  output              xmit_error,
  output              wsize_z_error,
  input               prim_scrambler_en,
  input               data_scrambler_en,
  input               is_device,

  output      [3:0]   lax_i_state,
  output      [3:0]   lax_r_state,
  output      [3:0]   lax_w_state,
  output      [3:0]   lax_w_fstate,


//Detection
  output              detect_sync,
  output              detect_r_rdy,
  output              detect_r_ip,
  output              detect_r_ok,
  output              detect_r_err,
  output              detect_x_rdy,
  output              detect_sof,
  output              detect_eof,
  output              detect_wtrm,
  output              detect_cont,
  output              detect_hold,
  output              detect_holda,
  output              detect_align,
  output              detect_preq_s,
  output              detect_preq_p,
  output              detect_xrdy_xrdy,
  output              send_crc,

  output              dbg_send_holda,

  output      [23:0]  in_data_addra,
  output      [12:0]  d_count,
  output      [12:0]  write_count,
  output      [3:0]   buffer_pos



);


//Parameters
parameter           NOT_READY       = 4'h0;
parameter           IDLE            = 4'h1;
parameter           PM_DENY         = 4'h2;
//Registers/Wires
reg       [3:0]     state;


//Primatives
reg                 send_sync;
reg                 send_pmack;
reg                 send_pmnack;


wire                sli_idle;
wire      [31:0]    sli_tx_dout;
wire                sli_tx_isk;

reg                 write_en;
wire                write_idle;
wire      [31:0]    slw_tx_dout;
wire                slw_tx_isk;

reg                 read_en;
wire                read_idle;
wire      [31:0]    slr_tx_dout;
wire                slr_tx_isk;

wire      [31:0]    ll_tx_dout;
wire                ll_tx_isk;

wire                last_prim;

//Submodules

//XXX: I can probably use only one CRC checker for the entire stack but to make it easier I'm gonna use two for
      //the read and write path

//XXX: maybe add a scrambler for PRIM scrambling


cont_controller ccon (
  .rst                  (rst                    ),
  .clk                  (clk                    ),
  .phy_ready            (phy_ready              ),
  .xmit_cont_en         (prim_scrambler_en      ),
  .last_prim            (last_prim              ),

  .rx_din               (rx_din                 ),
  .rx_isk               (rx_isk                 ),

  .ll_tx_din            (ll_tx_dout             ),
  .ll_tx_isk            (ll_tx_isk              ),

  .cont_tx_dout         (tx_dout                ),
  .cont_tx_isk          (tx_isk                 ),

  .detect_sync          (detect_sync            ),
  .detect_r_rdy         (detect_r_rdy           ),
  .detect_r_ip          (detect_r_ip            ),
  .detect_r_err         (detect_r_err           ),
  .detect_r_ok          (detect_r_ok            ),
  .detect_x_rdy         (detect_x_rdy           ),
  .detect_sof           (detect_sof             ),
  .detect_eof           (detect_eof             ),
  .detect_wtrm          (detect_wtrm            ),
  .detect_cont          (detect_cont            ),
  .detect_hold          (detect_hold            ),
  .detect_holda         (detect_holda           ),
  .detect_preq_s        (detect_preq_s          ),
  .detect_preq_p        (detect_preq_p          ),
  .detect_align         (detect_align           ),
  .detect_xrdy_xrdy     (detect_xrdy_xrdy       )
);

sata_link_layer_write slw (
  .rst                  (rst                    ),
  .clk                  (clk                    ),
  .en                   (write_en               ),
  .idle                 (write_idle             ),
  .phy_ready            (phy_ready              ),
  .write_ready          (write_ready            ),
  .send_sync_escape     (sync_escape            ),

  .detect_x_rdy         (detect_x_rdy           ),
  .detect_r_rdy         (detect_r_rdy           ),
  .detect_r_ip          (detect_r_ip            ),
  .detect_r_err         (detect_r_err           ),
  .detect_r_ok          (detect_r_ok            ),
  .detect_cont          (detect_cont            ),
  .detect_hold          (detect_hold            ),
  .detect_holda         (detect_holda           ),
  .detect_sync          (detect_sync            ),
  .detect_align         (detect_align           ),

  .send_holda           (dbg_send_holda         ),

  .write_start          (write_start            ),
  .write_strobe         (write_strobe           ),
  .write_data           (write_data             ),
  .write_size           (write_size             ),
  .write_hold           (write_hold             ),
  .write_finished       (write_finished         ),
  .write_abort          (write_abort            ),

  .last_prim            (last_prim              ),
  .send_crc             (send_crc               ),
  .post_align_write     (post_align_write       ),

  .tx_dout              (slw_tx_dout            ),
  .tx_isk               (slw_tx_isk             ),
  .rx_din               (rx_din                 ),
  .rx_isk               (rx_isk                 ),

  .xmit_error           (xmit_error             ),
  .wsize_z_error        (wsize_z_error          ),

  .data_scrambler_en    (data_scrambler_en      ),
  .is_device            (is_device              ),
  .state                (lax_w_state            ),
  .fstate               (lax_w_fstate           ),

  .in_data_addra        (in_data_addra          ),
  .write_count          (write_count            ),
  .d_count              (d_count                ),
  .buffer_pos           (buffer_pos             )
);

sata_link_layer_read slr (
  .rst                  (rst                    ),
  .clk                  (clk                    ),
  .en                   (read_en                ),
  .idle                 (read_idle              ),
  .sync_escape          (sync_escape            ),
  .phy_ready            (phy_ready              ),
  .dbg_hold             (hold                   ),

  .detect_align         (detect_align           ),
  .detect_sync          (detect_sync            ),
  .detect_x_rdy         (detect_x_rdy           ),
  .detect_sof           (detect_sof             ),
  .detect_eof           (detect_eof             ),
  .detect_wtrm          (detect_wtrm            ),
  .detect_cont          (detect_cont            ),
  .detect_holda         (detect_holda           ),
  .detect_hold          (detect_hold            ),
  .detect_xrdy_xrdy     (detect_xrdy_xrdy       ),

  .tx_dout              (slr_tx_dout            ),
  .tx_isk               (slr_tx_isk             ),
  .rx_din               (rx_din                 ),
  .rx_isk               (rx_isk                 ),

  .read_ready           (read_ready             ),
  .read_strobe          (read_strobe            ),
  .read_data            (read_data              ),
  .read_start           (read_start             ),
  .read_finished        (read_finished          ),
  .remote_abort         (remote_abort           ),

  .crc_ok               (read_crc_ok            ),

  .data_scrambler_en    (data_scrambler_en      ),
  .is_device            (is_device              ),
  .lax_r_state          (lax_r_state            )
);

//Asynchronous logic
assign  ll_tx_dout = (!read_idle) ? slr_tx_dout  : (!write_idle) ? slw_tx_dout : sli_tx_dout;
assign  ll_tx_isk  = (!read_idle) ? slr_tx_isk   : (!write_idle) ? slw_tx_isk  : sli_tx_isk;


assign  sli_tx_dout   = (send_pmnack) ? `PRIM_PMNACK  :
                        (send_pmack)  ? `PRIM_PMACK :
                        `PRIM_SYNC;

assign  sli_tx_isk    = 1;

assign  link_layer_ready  = (state == IDLE) && read_idle && write_idle;

assign  lax_i_state       = state;




//Main State Machine
always @ (posedge clk) begin
  if (rst) begin
    state             <=  NOT_READY;
    send_pmnack       <=  0;
    send_pmack        <=  0;

    write_en          <=  0;
    read_en           <=  0;
  end
  else begin
    //Strobes
    send_pmnack       <=  0;
    send_pmack        <=  0;

    write_en          <=  0;
    read_en           <=  0;

    if (!platform_ready) begin
      state           <=  NOT_READY;
    end

    if (phy_ready) begin
      case (state)
        NOT_READY: begin
          if (platform_ready) begin
            state       <=  IDLE;
          end
        end
        IDLE: begin
          write_en      <=  1;
          read_en       <=  1;
          if (detect_preq_s || detect_preq_p) begin
            send_pmnack <=  1;
            state       <=  PM_DENY;
          end
        end
        PM_DENY: begin
           if (detect_preq_s || detect_preq_p) begin
            send_pmnack <=  1;
          end
          else begin
            state       <=  IDLE;
          end
        end
        default: begin
          state         <=  NOT_READY;
        end
      endcase
    end
  end
end

endmodule
