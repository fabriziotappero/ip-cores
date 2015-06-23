//cont_controller.v
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

module cont_controller (


input               rst,            //reset
input               clk,
input               phy_ready,
input               xmit_cont_en,   //enable the transmit cont primative (slows simulations WAY!!! down)

input               last_prim,


input       [31:0]  ll_tx_din,
input               ll_tx_isk,

output      [31:0]  cont_tx_dout,
output              cont_tx_isk,

input       [31:0]  rx_din,
input       [3:0]   rx_isk,

output              detect_sync,
output              detect_r_rdy,
output              detect_r_ip,
output              detect_r_err,
output              detect_r_ok,
output              detect_x_rdy,
output              detect_sof,
output              detect_eof,
output              detect_wtrm,
output              detect_cont,
output              detect_hold,
output              detect_holda,
output              detect_preq_s,
output              detect_preq_p,
output              detect_align,

output              detect_xrdy_xrdy
);

//Parameters
//Registers/Wires

//CONT detect State Machine
wire                hold_cont;
wire                holda_cont;
wire                pmreq_p_cont;
wire                pmreq_s_cont;
wire                r_err_cont;
wire                r_ip_cont;
wire                r_ok_cont;
wire                r_rdy_cont;
wire                sync_cont;
wire                wtrm_cont;
wire                x_rdy_cont;

reg                 cont_detect;

reg         [31:0]  prev_prim;

reg                 hold_cont_ready;
reg                 holda_cont_ready;
reg                 pmreq_p_cont_ready;
reg                 pmreq_s_cont_ready;
reg                 r_err_cont_ready;
reg                 r_ip_cont_ready;
reg                 r_ok_cont_ready;
reg                 r_rdy_cont_ready;
reg                 sync_cont_ready;
reg                 wtrm_cont_ready;
reg                 x_rdy_cont_ready;


//CONT generate state machine
reg       [31:0]    tx_prev_prim;
reg                 tx_cont_enable;
reg                 tx_cont_sent;
reg                 send_cont;

//Scrambler control
wire                scram_en;
wire      [31:0]    scram_dout;


//Submodules
scrambler scram (
  .rst            (rst              ),
  .clk            (clk              ),
  .prim_scrambler (1'b1             ),
  .en             (scram_en         ),
  .din            (ll_tx_din        ),
  .dout           (scram_dout       )
);

//Asynchronous Logic
assign  detect_sync   = ((rx_isk[0])     && (rx_din == `PRIM_SYNC    )) ||  sync_cont;   //sync (normal) == sync(cont)
assign  detect_r_rdy  = ((rx_isk[0])     && (rx_din == `PRIM_R_RDY   )) ||  r_rdy_cont;
assign  detect_r_ip   = ((rx_isk[0])     && (rx_din == `PRIM_R_IP    )) ||  r_ip_cont;
assign  detect_r_err  = ((rx_isk[0])     && (rx_din == `PRIM_R_ERR   )) ||  r_err_cont;
assign  detect_r_ok   = ((rx_isk[0])     && (rx_din == `PRIM_R_OK    )) ||  r_ok_cont;
assign  detect_x_rdy  = ((rx_isk[0])     && (rx_din == `PRIM_X_RDY   )) ||  x_rdy_cont;
assign  detect_sof    = (rx_isk[0])      && (rx_din == `PRIM_SOF     );
assign  detect_eof    = (rx_isk[0])      && (rx_din == `PRIM_EOF     );
assign  detect_wtrm   = ((rx_isk[0])     && (rx_din == `PRIM_WTRM    )) ||  wtrm_cont;
assign  detect_cont   = (rx_isk[0])      && (rx_din == `PRIM_CONT    );
assign  detect_hold   = ((rx_isk[0])     && (rx_din == `PRIM_HOLD    )) ||  hold_cont;  //hold  (normal) == hold  (cont)
assign  detect_holda  = ((rx_isk[0])     && (rx_din == `PRIM_HOLDA   )) ||  holda_cont; //holda (normal) == holda (cont)
assign  detect_preq_s = ((rx_isk[0])     && (rx_din == `PRIM_PREQ_S  )) ||  pmreq_s_cont;
assign  detect_preq_p = ((rx_isk[0])     && (rx_din == `PRIM_PREQ_P  )) ||  pmreq_p_cont;
assign  detect_align  = (rx_isk[0])      && (rx_din == `PRIM_ALIGN   );

assign  detect_xrdy_xrdy  = ((((rx_isk[0])&& (rx_din == `PRIM_X_RDY   )) ||  x_rdy_cont) && ll_tx_isk && (ll_tx_din == `PRIM_X_RDY));

assign  sync_cont     =   sync_cont_ready    && ((rx_din == `PRIM_CONT) || (!rx_isk[0] || detect_align));
assign  hold_cont     =   hold_cont_ready    && ((rx_din == `PRIM_CONT) || (!rx_isk[0] || detect_align));
assign  holda_cont    =   holda_cont_ready   && ((rx_din == `PRIM_CONT) || (!rx_isk[0] || detect_align));
assign  pmreq_p_cont  =   pmreq_p_cont_ready && ((rx_din == `PRIM_CONT) || (!rx_isk[0] || detect_align));
assign  pmreq_s_cont  =   pmreq_s_cont_ready && ((rx_din == `PRIM_CONT) || (!rx_isk[0] || detect_align));
assign  r_err_cont    =   r_err_cont_ready   && ((rx_din == `PRIM_CONT) || (!rx_isk[0] || detect_align));
assign  r_ip_cont     =   r_ip_cont_ready    && ((rx_din == `PRIM_CONT) || (!rx_isk[0] || detect_align));
assign  r_ok_cont     =   r_ok_cont_ready    && ((rx_din == `PRIM_CONT) || (!rx_isk[0] || detect_align));
assign  r_rdy_cont    =   r_rdy_cont_ready   && ((rx_din == `PRIM_CONT) || (!rx_isk[0] || detect_align));
assign  wtrm_cont     =   wtrm_cont_ready    && ((rx_din == `PRIM_CONT) || (!rx_isk[0] || detect_align));
assign  x_rdy_cont    =   x_rdy_cont_ready   && ((rx_din == `PRIM_CONT) || (!rx_isk[0] || detect_align));


assign  cont_tx_dout  = (!xmit_cont_en) ? ll_tx_din :                           //when transmit cont gen is disable
                      ((tx_prev_prim != ll_tx_din) && ll_tx_isk) ? ll_tx_din :  //if the prev != curr (exit)
                        (last_prim)      ? ll_tx_din:
                        (tx_cont_enable) ?                                      //if the cont is enabled
                          send_cont ?   `PRIM_CONT  :                           //need to first send the cont
                                        scram_dout  :                           //send the junk
                                          ll_tx_din;                            //tx cont is not enabled

assign  cont_tx_isk   = (!xmit_cont_en) ? ll_tx_isk :
                        ((tx_prev_prim != ll_tx_din) && ll_tx_isk) ? ll_tx_isk ://if the prev != curr (exit)
                        (last_prim)      ?ll_tx_isk:  
                        (tx_cont_enable) ?                                      //if the cont is enabled
                          send_cont ?   1 :                                     //need to first send the cont
                                        0 :                                     //send the junk
                                          ll_tx_isk;                            //tx cont is not enabled
assign  scram_en      = tx_cont_enable;

//Synchronous logic

//Cont detect
always @ (posedge clk) begin
  if (rst) begin
    cont_detect             <=  0;

    hold_cont_ready         <=  0;
    holda_cont_ready        <=  0;
    pmreq_p_cont_ready      <=  0;
    pmreq_s_cont_ready      <=  0;
    r_err_cont_ready        <=  0;
    r_ip_cont_ready         <=  0;
    r_ok_cont_ready         <=  0;
    r_rdy_cont_ready        <=  0;
    sync_cont_ready         <=  0;
    wtrm_cont_ready         <=  0;
    x_rdy_cont_ready        <=  0;

  end
  else begin
    if (!detect_align) begin
      if (rx_isk) begin
        if (rx_din == `PRIM_CONT) begin
          cont_detect                 <=  1;
        end
        else if (prev_prim == rx_din) begin
          case (prev_prim)
            `PRIM_SYNC   : begin
              sync_cont_ready         <=  1;
            end
            `PRIM_R_RDY  : begin
              r_rdy_cont_ready        <=  1;
            end
            `PRIM_R_IP   : begin
              r_ip_cont_ready         <=  1;
            end
            `PRIM_R_ERR  : begin
              r_err_cont_ready        <=  1;
            end
            `PRIM_R_OK   : begin
              r_ok_cont_ready         <=  1;
            end
            `PRIM_X_RDY  : begin
              x_rdy_cont_ready        <=  1;
            end
            `PRIM_WTRM   : begin
              wtrm_cont_ready         <=  1;
            end
            `PRIM_HOLD   : begin
              if (cont_detect) begin
                hold_cont_ready       <=  0;
                cont_detect           <=  0;
              end
              else begin
                hold_cont_ready       <=  1;
              end
            end
            `PRIM_HOLDA  : begin
              if (cont_detect) begin
                holda_cont_ready      <=  0;
                cont_detect           <=  0;
              end
              else begin
                holda_cont_ready      <=  1;
              end
            end
            `PRIM_PREQ_S : begin
              pmreq_s_cont_ready      <=  1;
            end
            `PRIM_PREQ_P : begin
              pmreq_p_cont_ready      <=  1;
            end
            `PRIM_ALIGN  : begin
            end
            default: begin
              hold_cont_ready         <=  0;
              holda_cont_ready        <=  0;
              pmreq_p_cont_ready      <=  0;
              pmreq_s_cont_ready      <=  0;
              r_err_cont_ready        <=  0;
              r_ip_cont_ready         <=  0;
              r_ok_cont_ready         <=  0;
              r_rdy_cont_ready        <=  0;
              sync_cont_ready         <=  0;
              wtrm_cont_ready         <=  0;
              x_rdy_cont_ready        <=  0;
            end
          endcase
        end
        //save the previous primative
        else begin
          prev_prim               <=  rx_din;
          //previous primative doesn't equal current primitive
          cont_detect             <=  0;
          hold_cont_ready         <=  0;
          holda_cont_ready        <=  0;
          pmreq_p_cont_ready      <=  0;
          pmreq_s_cont_ready      <=  0;
          r_err_cont_ready        <=  0;
          r_ip_cont_ready         <=  0;
          r_ok_cont_ready         <=  0;
          r_rdy_cont_ready        <=  0;
          sync_cont_ready         <=  0;
          wtrm_cont_ready         <=  0;
          x_rdy_cont_ready        <=  0;

        end
      end
      if (!rx_isk[0] && !cont_detect) begin
        cont_detect             <=  0;
        hold_cont_ready         <=  0;
        holda_cont_ready        <=  0;
        pmreq_p_cont_ready      <=  0;
        pmreq_s_cont_ready      <=  0;
        r_err_cont_ready        <=  0;
        r_ip_cont_ready         <=  0;
        r_ok_cont_ready         <=  0;
        r_rdy_cont_ready        <=  0;
        sync_cont_ready         <=  0;
        wtrm_cont_ready         <=  0;
        x_rdy_cont_ready        <=  0;
      end
    end
  end
end


//Cont Generator
always @ (posedge clk) begin
  if (rst || !xmit_cont_en) begin
    tx_prev_prim              <=  0;
    tx_cont_enable            <=  0;
    tx_cont_sent              <=  0;
    send_cont                 <=  0;
  end
  else begin
    if (phy_ready) begin

      send_cont               <=  0;

      if (ll_tx_isk) begin

        //reset everything because the previous primative is not equal to the current one
        if (tx_prev_prim != ll_tx_din) begin
          send_cont           <=  0;
          tx_cont_sent        <=  0;
          tx_cont_enable      <=  0;
        end
        else begin

          //see if we need to send the cont primative
          if (tx_cont_enable && send_cont) begin
            tx_cont_sent          <=  1;
          end

          //previous primative == current primative
          case (tx_prev_prim)
            `PRIM_SYNC   : begin
              tx_cont_enable     <=  1;
              if (!tx_cont_sent && !send_cont) begin
                send_cont          <=  1;
              end
            end
            `PRIM_R_RDY  : begin
              tx_cont_enable     <=  1;
              if (!tx_cont_sent && !send_cont) begin
                send_cont          <=  1;
              end
            end
            `PRIM_R_IP   : begin
              tx_cont_enable     <=  1;
              if (!tx_cont_sent && !send_cont) begin
                send_cont          <=  1;
              end
            end
            `PRIM_R_ERR  : begin
              tx_cont_enable     <=  1;
              if (!tx_cont_sent && !send_cont) begin
                send_cont          <=  1;
              end
            end
            `PRIM_R_OK   : begin
              tx_cont_enable     <=  1;
              if (!tx_cont_sent && !send_cont) begin
                send_cont          <=  1;
              end
            end
            `PRIM_X_RDY  : begin
              tx_cont_enable     <=  1;
              if (!tx_cont_sent && !send_cont) begin
                send_cont          <=  1;
              end
            end
            `PRIM_WTRM   : begin
              tx_cont_enable     <=  1;
              if (!tx_cont_sent && !send_cont) begin
                send_cont          <=  1;
              end
            end
            `PRIM_HOLD   : begin
              tx_cont_enable     <=  1;
              if (!tx_cont_sent && !send_cont) begin
                send_cont          <=  1;
              end
            end
            `PRIM_HOLDA  : begin
              tx_cont_enable     <=  1;
              if (!tx_cont_sent && !send_cont) begin
                send_cont          <=  1;
              end
            end
            `PRIM_PREQ_S : begin
              tx_cont_enable     <=  1;
              if (!tx_cont_sent && !send_cont) begin
                send_cont          <=  1;
              end
            end
            `PRIM_PREQ_P : begin
              tx_cont_enable     <=  1;
              if (!tx_cont_sent && !send_cont) begin
                send_cont          <=  1;
              end
            end
            default: begin
              send_cont         <=  0;
              tx_cont_enable    <=  0;
              tx_cont_sent      <=  0;
            end
          endcase
        end
      end
      else begin
        //it is not a k value so don't read it
        tx_prev_prim          <=  0;
      end
      //k value record the PRIM
      tx_prev_prim          <=  ll_tx_din;

      if (last_prim) begin
        tx_cont_enable      <=  0;
      end
    end
  end
end



endmodule

