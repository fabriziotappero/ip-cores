//faux_sata_hd.v
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

module faux_sata_hd (
//Inputs/Outputs
input               rst,              //reset
input               clk,

//Data Interface
output      [31:0]  tx_dout,
output      [3:0]   tx_isk,
output              tx_set_elec_idle,
output              rx_byte_is_aligned,

input       [31:0]  rx_din,
input       [3:0]   rx_isk,
input               rx_is_elec_idle,

input               comm_reset_detect,
input               comm_wake_detect,

output              tx_comm_reset,
output              tx_comm_wake,

output              hd_ready,
output              phy_ready,


//Debug
output      [3:0]   oob_state,
output      [3:0]   cl_state,

//Link Layer
input               dbg_ll_write_start,
output              dbg_ll_write_strobe,
output              dbg_ll_write_finished,
input       [31:0]  dbg_ll_write_data,
input       [31:0]  dbg_ll_write_size,
input               dbg_ll_write_hold,
input               dbg_ll_write_abort,
output              dbg_ll_xmit_error,

output              dbg_ll_read_start,
output              dbg_ll_read_strobe,
output      [31:0]  dbg_ll_read_data,
input               dbg_ll_read_ready,
output              dbg_ll_read_finished,
output              dbg_ll_remote_abort,

input               dbg_data_scrambler_en,

input               dbg_hold,


//Transport Layer Debug
input               dbg_t_en,

//Trasport Layer Control/Status
output              dbg_tl_ready,
input               dbg_send_reg_stb,
input               dbg_send_dma_act_stb,
input               dbg_send_data_stb,
input               dbg_send_pio_stb,
input               dbg_send_dev_bits_stb,

output              dbg_remote_abort,
output              dbg_xmit_error,
output              dbg_read_crc_fail,

output              dbg_h2d_reg_stb,
output              dbg_h2d_data_stb,

output               dbg_pio_request,
input       [15:0]  dbg_pio_transfer_count,
input               dbg_pio_direction,
input       [7:0]   dbg_pio_e_status,

//FIS Structure
output      [7:0]   dbg_h2d_command,
output      [15:0]  dbg_h2d_features,
output              dbg_h2d_cmd_bit,
output      [3:0]   dbg_h2d_port_mult,
output      [7:0]   dbg_h2d_control,
output      [7:0]   dbg_h2d_device,
output      [47:0]  dbg_h2d_lba,
output      [15:0]  dbg_h2d_sector_count,

input               dbg_d2h_interrupt,
input               dbg_d2h_notification,
input       [7:0]   dbg_d2h_status,
input       [7:0]   dbg_d2h_error,
input       [3:0]   dbg_d2h_port_mult,
input       [7:0]   dbg_d2h_device,
input       [47:0]  dbg_d2h_lba,
input       [15:0]  dbg_d2h_sector_count,

//command layer data interface
output              dbg_cl_if_strobe,
input       [31:0]  dbg_cl_if_data,
input               dbg_cl_if_ready,
output              dbg_cl_if_activate,
input       [23:0]  dbg_cl_if_size,

output              dbg_cl_of_strobe,
output      [31:0]  dbg_cl_of_data,
input       [1:0]   dbg_cl_of_ready,
output      [1:0]   dbg_cl_of_activate,
input       [23:0]  dbg_cl_of_size,

output              command_layer_ready,

output              hd_read_from_host,
output      [31:0]  hd_data_from_host,

output              hd_write_to_host,
input       [31:0]  hd_data_to_host

);

//Parameters
//Registers/Wires
wire        [31:0]  phy_tx_dout;
wire                phy_tx_isk;

wire        [31:0]  sll_tx_dout;
wire                sll_tx_isk;

wire                ll_ready;
wire                ll_write_start;
wire                ll_write_finished;
wire                ll_write_strobe;
wire        [31:0]  ll_write_data;
wire        [31:0]  ll_write_size;
wire                ll_write_hold;
wire                ll_write_abort;

wire                ll_read_start;
wire                ll_read_strobe;
wire        [31:0]  ll_read_data;
wire                ll_remote_abort;
wire                ll_read_ready;
wire                ll_read_finished;
wire                ll_read_crc_ok;

wire                data_scrambler_en;


//Command Layer
wire                cl_send_reg_stb;
wire                cl_send_dma_act_stb;
wire                cl_send_data_stb;
wire                cl_send_pio_stb;
wire                cl_send_dev_bits_stb;

wire        [15:0]  cl_pio_transfer_count;
wire                cl_pio_direction;
wire        [7:0]   cl_pio_e_status;

wire                cl_d2h_interrupt;
wire                cl_d2h_notification;
wire        [7:0]   cl_d2h_status;
wire        [7:0]   cl_d2h_error;
wire        [3:0]   cl_d2h_port_mult;
wire        [7:0]   cl_d2h_device;
wire        [47:0]  cl_d2h_lba;
wire        [15:0]  cl_d2h_sector_count;



//Trasport Layer Control/Status
wire                transport_layer_ready;
wire                send_reg_stb;
wire                send_dma_act_stb;
wire                send_data_stb;
wire                send_pio_stb;
wire                send_dev_bits_stb;


wire                remote_abort;
wire                xmit_error;
wire                read_crc_fail;

wire                h2d_reg_stb;
wire                h2d_data_stb;

wire                pio_request;
wire        [15:0]  pio_transfer_count;
wire                pio_direction;
wire        [7:0]   pio_e_status;

wire        [31:0]  if_data;
wire                if_ready;
wire        [23:0]  if_size;

wire        [1:0]   of_ready;
wire        [23:0]  of_size;

//Host to Device Registers
wire        [7:0]   h2d_command;
wire        [15:0]  h2d_features;
wire                h2d_cmd_bit;
wire        [7:0]   h2d_control;
wire        [3:0]   h2d_port_mult;
wire        [7:0]   h2d_device;
wire        [47:0]  h2d_lba;
wire        [15:0]  h2d_sector_count;

//Device to Host Registers
wire                d2h_interrupt;
wire                d2h_notification;
wire        [3:0]   d2h_port_mult;
wire        [7:0]   d2h_device;
wire        [47:0]  d2h_lba;
wire        [15:0]  d2h_sector_count;
wire        [7:0]   d2h_status;
wire        [7:0]   d2h_error;

//DMA Specific Control

//Data Control
wire                cl_if_ready;
wire                cl_if_activate;
wire        [23:0]  cl_if_size;

wire                cl_if_strobe;
wire        [31:0]  cl_if_data;

wire        [1:0]   cl_of_ready;
wire        [1:0]   cl_of_activate;
wire                cl_of_strobe;
wire        [31:0]  cl_of_data;
wire        [23:0]  cl_of_size;


//Link Layer Interface
wire                t_write_start;
wire                t_write_strobe;
wire                t_write_finished;
wire        [31:0]  t_write_data;
wire        [31:0]  t_write_size;
wire                t_write_hold;
wire                t_write_abort;
wire                t_xmit_error;

wire                t_read_start;
wire                t_read_ready;
wire        [31:0]  t_read_data;
wire                t_read_strobe;
wire                t_read_finished;
wire                t_read_crc_ok;
wire                t_remote_abort;

//Sub Modules
faux_sata_hd_phy hd_phy(
  .rst                  (rst                    ),
  .clk                  (clk                    ),

  //incomming/output data
  .tx_dout              (phy_tx_dout            ),
  .tx_isk               (phy_tx_isk             ),
  .tx_set_elec_idle     (tx_set_elec_idle       ),

  .rx_din               (rx_din                 ),
  .rx_isk               (rx_isk                 ),
  .rx_is_elec_idle      (rx_is_elec_idle        ),
  .rx_byte_is_aligned   (rx_byte_is_aligned     ),

  .comm_reset_detect    (comm_reset_detect      ),
  .comm_wake_detect     (comm_wake_detect       ),

  .tx_comm_reset        (tx_comm_reset          ),
  .tx_comm_wake         (tx_comm_wake           ),

  //Status
  .lax_state            (oob_state              ),
  .phy_ready            (phy_ready              ),
  .hd_ready             (hd_ready               )
);

sata_link_layer fsll (
  .rst                  (rst || !hd_ready       ),
  .clk                  (clk                    ),
  .prim_scrambler_en    (1                      ),
  .data_scrambler_en    (data_scrambler_en      ),

  .link_layer_ready     (ll_ready               ),
  .sync_escape          (0                      ),
  .hold                 (dbg_hold               ),

  //Transport Layer Interface
  .write_start          (ll_write_start         ),
  .write_strobe         (ll_write_strobe        ),
  .write_data           (ll_write_data          ),
  .write_size           (ll_write_size          ),
  .write_hold           (ll_write_hold          ),
  .write_finished       (ll_write_finished      ),
  .write_abort          (ll_write_abort         ),
  .xmit_error           (t_xmit_error           ),

  .read_strobe          (ll_read_strobe         ),
  .read_data            (ll_read_data           ),
  .read_ready           (ll_read_ready          ),
  .read_start           (ll_read_start          ),
  .read_finished        (ll_read_finished       ),
  .read_crc_ok          (ll_read_crc_ok         ),
  .remote_abort         (ll_remote_abort        ),

  //Phy Layer
  .phy_ready            (phy_ready              ),
  .platform_ready       (hd_ready               ),
  .tx_dout              (sll_tx_dout            ),
  .tx_isk               (sll_tx_isk             ),

  .rx_din               (rx_din                 ),
  .rx_isk               (rx_isk                 ),
  .is_device            (1                      )
);

faux_sata_hd_transport  ftl (
  .rst                  (rst || !hd_ready       ),
  .clk                  (clk                    ),

  //Trasport Layer Control/Status
  .transport_layer_ready(transport_layer_ready  ),
  .send_reg_stb         (send_reg_stb           ),
  .send_dma_act_stb     (send_dma_act_stb       ),
  .send_data_stb        (send_data_stb          ),
  .send_pio_stb         (send_pio_stb           ),
  .send_dev_bits_stb    (send_dev_bits_stb      ),

  .remote_abort         (remote_abort           ),
  .xmit_error           (xmit_error             ),
  .read_crc_fail        (read_crc_fail          ),

  .h2d_reg_stb          (h2d_reg_stb            ),
  .h2d_data_stb         (h2d_data_stb           ),

  .pio_request          (pio_request            ),
  .pio_transfer_count   (pio_transfer_count     ),
  .pio_direction        (pio_direction          ),
  .pio_e_status         (pio_e_status           ),

  //FIS Structure
  .h2d_command          (h2d_command            ),
  .h2d_features         (h2d_features           ),
  .h2d_cmd_bit          (h2d_cmd_bit            ),
  .h2d_port_mult        (h2d_port_mult          ),
  .h2d_control          (h2d_control            ),
  .h2d_device           (h2d_device             ),
  .h2d_lba              (h2d_lba                ),
  .h2d_sector_count     (h2d_sector_count       ),

  .d2h_interrupt        (d2h_interrupt          ),
  .d2h_notification     (d2h_notification       ),
  .d2h_status           (d2h_status             ),
  .d2h_error            (d2h_error              ),
  .d2h_port_mult        (d2h_port_mult          ),
  .d2h_device           (d2h_device             ),
  .d2h_lba              (d2h_lba                ),
  .d2h_sector_count     (d2h_sector_count       ),

  //command layer data interface
  .cl_if_strobe         (cl_if_strobe           ),
  .cl_if_data           (cl_if_data             ),
  .cl_if_ready          (cl_if_ready            ),
  .cl_if_activate       (cl_if_activate         ),
  .cl_if_size           (cl_if_size             ),

  .cl_of_strobe         (cl_of_strobe           ),
  .cl_of_data           (cl_of_data             ),
  .cl_of_ready          (cl_of_ready            ),
  .cl_of_activate       (cl_of_activate         ),
  .cl_of_size           (cl_of_size             ),

  //Link Layer Interface
  .link_layer_ready     (ll_ready               ),

  .ll_write_start       (t_write_start          ),
  .ll_write_strobe      (t_write_strobe         ),
  .ll_write_finished    (t_write_finished       ),
  .ll_write_data        (t_write_data           ),
  .ll_write_size        (t_write_size           ),
  .ll_write_hold        (t_write_hold           ),
  .ll_write_abort       (t_write_abort          ),
  .ll_xmit_error        (t_xmit_error           ),

  .ll_read_start        (t_read_start           ),
  .ll_read_ready        (t_read_ready           ),
  .ll_read_data         (t_read_data            ),
  .ll_read_strobe       (t_read_strobe          ),
  .ll_read_finished     (t_read_finished        ),
  .ll_read_crc_ok       (t_read_crc_ok          ),
  .ll_remote_abort      (t_remote_abort         )


);

faux_hd_command_layer fcl(
  .rst                  (rst                    ),
  .clk                  (clk                    ),

  .command_layer_ready  (command_layer_ready    ),

  .hd_read_from_host    (hd_read_from_host      ),
  .hd_data_from_host    (hd_data_from_host      ),

  .hd_write_to_host     (hd_write_to_host       ),
  .hd_data_to_host      (hd_data_to_host        ),


  .transport_layer_ready(transport_layer_ready  ),
  .send_reg_stb         (cl_send_reg_stb        ),
  .send_dma_act_stb     (cl_send_dma_act_stb    ),
  .send_data_stb        (cl_send_data_stb       ),
  .send_pio_stb         (cl_send_pio_stb        ),
  .send_dev_bits_stb    (cl_send_dev_bits_stb   ),

  .remote_abort         (remote_abort           ),
  .xmit_error           (xmit_error             ),
  .read_crc_fail        (read_crc_fail          ),

  .h2d_reg_stb          (h2d_reg_stb            ),
  .h2d_data_stb         (h2d_data_stb           ),

  .pio_request          (pio_request            ),
  .pio_transfer_count   (cl_pio_transfer_count  ),
  .pio_direction        (cl_pio_direction       ),
  .pio_e_status         (cl_pio_e_status        ),

  //FIS Structure
  .h2d_command          (h2d_command            ),
  .h2d_features         (h2d_features           ),
  .h2d_cmd_bit          (h2d_cmd_bit            ),
  .h2d_port_mult        (h2d_port_mult          ),
  .h2d_control          (h2d_control            ),
  .h2d_device           (h2d_device             ),
  .h2d_lba              (h2d_lba                ),
  .h2d_sector_count     (h2d_sector_count       ),

  .d2h_interrupt        (cl_d2h_interrupt       ),
  .d2h_notification     (cl_d2h_notification    ),
  .d2h_status           (cl_d2h_status          ),
  .d2h_error            (cl_d2h_error           ),
  .d2h_port_mult        (cl_d2h_port_mult       ),
  .d2h_device           (cl_d2h_device          ),
  .d2h_lba              (cl_d2h_lba             ),
  .d2h_sector_count     (cl_d2h_sector_count    ),

  //command layer data interface
  .cl_if_strobe         (cl_if_strobe           ),
  .cl_if_data           (if_data                ),
  .cl_if_ready          (if_ready               ),
  .cl_if_activate       (cl_if_activate         ),
  .cl_if_size           (if_size                ),

  .cl_of_strobe         (cl_of_strobe           ),
  .cl_of_data           (cl_of_data             ),
  .cl_of_ready          (of_ready               ),
  .cl_of_activate       (cl_of_activate         ),
  .cl_of_size           (of_size                ),
  .cl_state             (cl_state               )

);

assign                  tx_dout         = !phy_ready ? phy_tx_dout : sll_tx_dout;
assign                  tx_isk[3:1]     =  3'b000;
assign                  tx_isk[0]       = !phy_ready ? phy_tx_isk  : sll_tx_isk;


//Debug
//assign                ll_write_start        = (dbg_ll_en) ? dbg_ll_write_start  : t_write_start;
//assign                ll_write_data         = (dbg_ll_en) ? dbg_ll_write_data   : t_write_data;
//assign                ll_write_hold         = (dbg_ll_en) ? dbg_ll_write_hold   : t_write_hold;
//assign                ll_write_size         = (dbg_ll_en) ? dbg_ll_write_size   : t_write_size;
//assign                ll_write_abort        = (dbg_ll_en) ? dbg_ll_write_abort  : t_write_abort;
//assign                data_scrambler_en     = (dbg_ll_en) ? dbg_data_scrambler_en : 1;
//
//assign                ll_read_ready         = (dbg_ll_en) ? dbg_ll_read_ready   : t_read_ready;
//
assign                ll_write_start        = t_write_start;
assign                ll_write_data         = t_write_data;
assign                ll_write_hold         = t_write_hold;
assign                ll_write_size         = t_write_size;
assign                ll_write_abort        = t_write_abort;
assign                data_scrambler_en     = 1;

assign                ll_read_ready         = t_read_ready;


assign                dbg_ll_write_strobe   = ll_write_strobe;
assign                dbg_ll_write_finished = ll_write_finished;
assign                dbg_ll_xmit_error     = xmit_error;

assign                dbg_ll_read_strobe    = ll_read_strobe;
assign                dbg_ll_read_start     = ll_read_start;
assign                dbg_ll_read_finished  = ll_read_finished;
assign                dbg_ll_read_data      = ll_read_data;
assign                dbg_ll_remote_abort   = ll_remote_abort;



//Transport Layer Debug Signals
assign                dbg_tl_ready          = transport_layer_ready;

assign                t_read_strobe         = ll_read_strobe;
assign                t_read_start          = ll_read_start;
assign                t_read_finished       = ll_read_finished;
assign                t_read_data           = ll_read_data;
assign                t_remote_abort        = ll_remote_abort;
assign                t_read_crc_ok         = ll_read_crc_ok;
assign                t_write_strobe        = ll_write_strobe;
assign                t_write_finished      = ll_write_finished;

assign                send_reg_stb          = (dbg_t_en)  ? dbg_send_reg_stb        : cl_send_reg_stb;
assign                send_dma_act_stb      = (dbg_t_en)  ? dbg_send_dma_act_stb    : cl_send_dma_act_stb;
assign                send_data_stb         = (dbg_t_en)  ? dbg_send_data_stb       : cl_send_data_stb;
assign                send_pio_stb          = (dbg_t_en)  ? dbg_send_pio_stb        : cl_send_pio_stb;
assign                send_dev_bits_stb     = (dbg_t_en)  ? dbg_send_dev_bits_stb   : cl_send_dev_bits_stb;


assign                dbg_pio_request       = pio_request;
assign                pio_transfer_count    = (dbg_t_en)  ? dbg_pio_transfer_count  : cl_pio_transfer_count;
assign                pio_direction         = (dbg_t_en)  ? dbg_pio_direction       : cl_pio_direction;
assign                pio_e_status          = (dbg_t_en)  ? dbg_pio_e_status        : cl_pio_e_status;


assign                d2h_interrupt         = (dbg_t_en)  ? dbg_d2h_interrupt       : cl_d2h_interrupt;
assign                d2h_notification      = (dbg_t_en)  ? dbg_d2h_notification    : cl_d2h_notification;
assign                d2h_status            = (dbg_t_en)  ? dbg_d2h_status          : cl_d2h_status;
assign                d2h_error             = (dbg_t_en)  ? dbg_d2h_error           : cl_d2h_error;
assign                d2h_port_mult         = (dbg_t_en)  ? dbg_d2h_port_mult       : cl_d2h_port_mult;
assign                d2h_device            = (dbg_t_en)  ? dbg_d2h_device          : cl_d2h_device;
assign                d2h_lba               = (dbg_t_en)  ? dbg_d2h_lba             : cl_d2h_lba;
assign                d2h_sector_count      = (dbg_t_en)  ? dbg_d2h_sector_count    : cl_d2h_sector_count;


assign                cl_if_data            = (dbg_t_en)  ? dbg_cl_if_data          : if_data;
assign                cl_if_ready           = (dbg_t_en)  ? dbg_cl_if_ready         : if_ready;
assign                cl_if_size            = (dbg_t_en)  ? dbg_cl_if_size          : if_size;
assign                cl_of_ready           = (dbg_t_en)  ? dbg_cl_of_ready         : of_ready;
assign                cl_of_size            = (dbg_t_en)  ? dbg_cl_of_size          : of_size;

assign                dbg_remote_abort      = remote_abort;
assign                dbg_xmit_error        = xmit_error;
assign                dbg_read_crc_fail     = read_crc_fail;

assign                dbg_h2d_reg_stb       = h2d_reg_stb;
assign                dbg_h2d_data_stb      = h2d_data_stb;

assign                dbg_h2d_command       = h2d_command;
assign                dbg_h2d_features      = h2d_features;
assign                dbg_h2d_cmd_bit       = h2d_cmd_bit;
assign                dbg_h2d_port_mult     = h2d_port_mult;
assign                dbg_h2d_control       = h2d_control;
assign                dbg_h2d_device        = h2d_device;
assign                dbg_h2d_lba           = h2d_lba;
assign                dbg_h2d_sector_count  = h2d_sector_count;


endmodule
