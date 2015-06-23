//sata_stack.v
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

module sata_stack (
  input               rst,            //reset
  input               clk,            //clock used to run the stack
  input               data_in_clk,
  input               data_in_clk_valid,
  input               data_out_clk,
  input               data_out_clk_valid,

  input               platform_ready,   //the underlying physical platform is
  output  wire        linkup,           //link is finished
  output              sata_ready,
  output              sata_init,

  input               send_sync_escape,
  input       [15:0]  user_features,

//User Interface
  output              busy,
  output              error,


  input               write_data_en,
  input               single_rdwr,
  input               read_data_en,

  input               send_user_command_stb,
  input               soft_reset_en,
  input       [7:0]   command,
  output              pio_data_ready,

  input       [15:0]  sector_count,
  input       [47:0]  sector_address,


  output              dma_activate_stb,
  output              d2h_reg_stb,
  output              pio_setup_stb,
  output              d2h_data_stb,
  output              dma_setup_stb,
  output  wire        set_device_bits_stb,

  output              dbg_send_command_stb,
  output              dbg_send_control_stb,
  output              dbg_send_data_stb,

  output              d2h_interrupt,
  output              d2h_notification,
  output      [3:0]   d2h_port_mult,
  output      [7:0]   d2h_device,
  output      [47:0]  d2h_lba,
  output      [15:0]  d2h_sector_count,
  output      [7:0]   d2h_status,
  output      [7:0]   d2h_error,

  input       [31:0]  user_din,
  input               user_din_stb,
  output      [1:0]   user_din_ready,
  input       [1:0]   user_din_activate,
  output      [23:0]  user_din_size,

  output      [31:0]  user_dout,
  output              user_dout_ready,
  input               user_dout_activate,
  input               user_dout_stb,
  output      [23:0]  user_dout_size,


  output              transport_layer_ready,
  output              link_layer_ready,
  output              phy_ready,

//Buffer
//Platform Interface
  output  [31:0]      tx_dout,
  output              tx_isk,
  output              tx_comm_reset,
  output              tx_comm_wake,
  output              tx_elec_idle,

  input   [31:0]      rx_din,
  input   [3:0]       rx_isk,
  input               rx_elec_idle,
  input               comm_init_detect,
  input               comm_wake_detect,
  input               rx_byte_is_aligned,


//Debug
  output              dbg_remote_abort,
  output              dbg_xmit_error,
  output              dbg_read_crc_error,

//PIO
  output              dbg_pio_response,
  output              dbg_pio_direction,
  output  [15:0]      dbg_pio_transfer_count,
  output  [7:0]       dbg_pio_e_status,

//Host dbg_ to Device Regster Values
  output  [7:0]       dbg_h2d_command,
  output  [15:0]      dbg_h2d_features,
  output  [7:0]       dbg_h2d_control,
  output  [3:0]       dbg_h2d_port_mult,
  output  [7:0]       dbg_h2d_device,
  output  [47:0]      dbg_h2d_lba,
  output  [15:0]      dbg_h2d_sector_count,

//DMA Specific Control

//Data Control
  output              dbg_cl_if_ready,
  output              dbg_cl_if_activate,
  output      [23:0]  dbg_cl_if_size,
  output              dbg_cl_if_strobe,
  output      [31:0]  dbg_cl_if_data,

  output      [1:0]   dbg_cl_of_ready,
  output      [1:0]   dbg_cl_of_activate,
  output              dbg_cl_of_strobe,
  output      [31:0]  dbg_cl_of_data,
  output      [23:0]  dbg_cl_of_size,

  output      [3:0]   dbg_cc_lax_state,
  output      [3:0]   dbg_cr_lax_state,
  output      [3:0]   dbg_cw_lax_state,

  output      [3:0]   dbg_t_lax_state,

  output      [3:0]   dbg_li_lax_state,
  output      [3:0]   dbg_lr_lax_state,
  output      [3:0]   dbg_lw_lax_state,
  output      [3:0]   dbg_lw_lax_fstate,

//Link Layer
  input               prim_scrambler_en,
  input               data_scrambler_en,

  output              dbg_ll_write_ready,
  output              dbg_ll_paw,
  output              dbg_ll_write_start,
  output              dbg_ll_write_strobe,
  output              dbg_ll_write_finished,
  output       [31:0] dbg_ll_write_data,
  output       [31:0] dbg_ll_write_size,
  output              dbg_ll_write_hold,
  output              dbg_ll_write_abort,

  output              dbg_ll_read_start,
  output              dbg_ll_read_strobe,
  output      [31:0]  dbg_ll_read_data,
  output              dbg_ll_read_ready,
  output              dbg_ll_read_finished,
  output              dbg_ll_remote_abort,
  output              dbg_ll_xmit_error,

  output              dbg_ll_send_crc,

//Phy Layer
  output      [3:0]   lax_state,

//Primative Detection
  output              dbg_detect_sync,
  output              dbg_detect_r_rdy,
  output              dbg_detect_r_ip,
  output              dbg_detect_r_ok,
  output              dbg_detect_r_err,
  output              dbg_detect_x_rdy,
  output              dbg_detect_sof,
  output              dbg_detect_eof,
  output              dbg_detect_wtrm,
  output              dbg_detect_cont,
  output              dbg_detect_hold,
  output              dbg_detect_holda,
  output              dbg_detect_align,
  output              dbg_detect_preq_s,
  output              dbg_detect_preq_p,
  output              dbg_detect_xrdy_xrdy,

  output              dbg_send_holda,

  output      [23:0]  slw_in_data_addra,
  output      [12:0]  slw_d_count,
  output      [12:0]  slw_write_count,
  output      [3:0]   slw_buffer_pos
);

//Parameters
//Registers/Wires

//Command Layer
wire                send_command_stb;
wire                send_control_stb;
wire                send_data_stb;

wire                if_strobe;
wire        [31:0]  if_data;
wire                if_ready;
wire                if_activate;
wire        [23:0]  if_size;

wire                of_strobe;
wire        [31:0]  of_data;
wire        [1:0]   of_ready;
wire        [1:0]   of_activate;
wire        [23:0]  of_size;


//Link Layer
wire                ll_sync_escape;
wire                ll_write_start;
wire                ll_write_strobe;
wire                ll_write_finished;
wire        [31:0]  ll_write_data;
wire        [31:0]  ll_write_size;
wire                ll_write_hold;
wire                ll_write_abort;


wire                ll_read_ready;
wire                ll_read_start;
wire                ll_read_strobe;
wire        [31:0]  ll_read_data;
wire                ll_read_finished;
wire                ll_read_crc_ok;
wire                ll_remote_abort;
wire                ll_xmit_error;

wire        [31:0]  ll_tx_dout;
wire                ll_tx_isk;

//Phy Layer
wire        [31:0]  phy_tx_dout;
wire                phy_tx_isk;

//User Interface state machine

//Transport Layer
wire                sync_escape;

wire        [7:0]   h2d_command;
wire        [15:0]  h2d_features;
wire        [7:0]   h2d_control;
wire        [3:0]   h2d_port_mult;
wire        [7:0]   h2d_device;
wire        [47:0]  h2d_lba;
wire        [15:0]  h2d_sector_count;


wire                remote_abort;
wire                xmit_error;
wire                read_crc_error;

//PIO
wire                pio_response;
wire                pio_direction;
wire        [15:0]  pio_transfer_count;
wire        [7:0]   pio_e_status;

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
wire                t_sync_escape;
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

//Comand Layer registers

//Submodules
sata_command_layer scl (
  .rst                  (rst                      ),
  .linkup               (linkup                   ),
  .clk                  (clk                      ),
  .data_in_clk          (data_in_clk              ),
  .data_in_clk_valid    (data_in_clk_valid        ),
  .data_out_clk         (data_out_clk             ),
  .data_out_clk_valid   (data_out_clk_valid       ),

  //Application Interface
  .sata_init            (sata_init                ),
  .command_layer_ready  (sata_ready               ),
  .busy                 (busy                     ),
  .dev_error            (error                    ),
  .send_sync_escape     (send_sync_escape         ),
  .user_features        (user_features            ),

  .write_data_en        (write_data_en            ),
  .single_rdwr          (single_rdwr              ),
  .read_data_en         (read_data_en             ),

  .send_user_command_stb(send_user_command_stb    ),
  .soft_reset_en        (soft_reset_en            ),
  .command              (command                  ),
  .pio_data_ready       (pio_data_ready           ),

  .sector_count         (sector_count             ),
  .sector_address       (sector_address           ),

  .user_din             (user_din                 ),
  .user_din_stb         (user_din_stb             ),
  .user_din_ready       (user_din_ready           ),
  .user_din_activate    (user_din_activate        ),
  .user_din_size        (user_din_size            ),

  .user_dout            (user_dout                ),
  .user_dout_ready      (user_dout_ready          ),
  .user_dout_activate   (user_dout_activate       ),
  .user_dout_stb        (user_dout_stb            ),
  .user_dout_size       (user_dout_size           ),

  //Transfer Layer Interface
  .transport_layer_ready(transport_layer_ready    ),
  .sync_escape          (sync_escape              ),

  .t_send_command_stb   (send_command_stb         ),
  .t_send_control_stb   (send_control_stb         ),
  .t_send_data_stb      (send_data_stb            ),

  .t_dma_activate_stb   (dma_activate_stb         ),
  .t_d2h_reg_stb        (d2h_reg_stb              ),
  .t_pio_setup_stb      (pio_setup_stb            ),
  .t_d2h_data_stb       (d2h_data_stb             ),
  .t_dma_setup_stb      (dma_setup_stb            ),
  .t_set_device_bits_stb(set_device_bits_stb      ),

  .t_remote_abort       (remote_abort             ),
  .t_xmit_error         (xmit_error               ),
  .t_read_crc_error     (read_crc_error           ),


  //PIO
  .t_pio_response       (pio_response             ),
  .t_pio_direction      (pio_direction            ),
  .t_pio_transfer_count (pio_transfer_count       ),
  .t_pio_e_status       (pio_e_status             ),

  //Host to Device Register Values
  .h2d_command          (h2d_command              ),
  .h2d_features         (h2d_features             ),
  .h2d_control          (h2d_control              ),
  .h2d_port_mult        (h2d_port_mult            ),
  .h2d_device           (h2d_device               ),
  .h2d_lba              (h2d_lba                  ),
  .h2d_sector_count     (h2d_sector_count         ),

  //Device to Host Register Values
  .d2h_interrupt        (d2h_interrupt            ),
  .d2h_notification     (d2h_notification         ),
  .d2h_port_mult        (d2h_port_mult            ),
  .d2h_device           (d2h_device               ),
  .d2h_lba              (d2h_lba                  ),
  .d2h_sector_count     (d2h_sector_count         ),
  .d2h_status           (d2h_status               ),
  .d2h_error            (d2h_error                ),

  //command layer data interface
  .t_if_strobe          (if_strobe                ),
  .t_if_data            (if_data                  ),
  .t_if_ready           (if_ready                 ),
  .t_if_activate        (if_activate              ),
  .t_if_size            (if_size                  ),

  .t_of_strobe          (of_strobe                ),
  .t_of_data            (of_data                  ),
  .t_of_ready           (of_ready                 ),
  .t_of_activate        (of_activate              ),
  .t_of_size            (of_size                  ),

  .cl_c_state           (dbg_cc_lax_state         ),
  .cl_r_state           (dbg_cr_lax_state         ),
  .cl_w_state           (dbg_cw_lax_state         )



);



//Transport Layer
sata_transport_layer stl (
  .rst                    (rst  | !linkup         ),
  .clk                    (clk                    ),
  .phy_ready              (phy_ready              ),

  //Status
  .transport_layer_ready  (transport_layer_ready  ),
  .sync_escape            (sync_escape            ),

  .send_command_stb       (send_command_stb       ),
  .send_control_stb       (send_control_stb       ),
  .send_data_stb          (send_data_stb          ),

  .dma_activate_stb       (dma_activate_stb       ),
  .d2h_reg_stb            (d2h_reg_stb            ),
  .pio_setup_stb          (pio_setup_stb          ),
  .d2h_data_stb           (d2h_data_stb           ),
  .dma_setup_stb          (dma_setup_stb          ),
  .set_device_bits_stb    (set_device_bits_stb    ),

  .remote_abort           (remote_abort           ),
  .xmit_error             (xmit_error             ),
  .read_crc_error         (read_crc_error         ),

  //PIO
  .pio_response           (pio_response           ),
  .pio_direction          (pio_direction          ),
  .pio_transfer_count     (pio_transfer_count     ),
  .pio_e_status           (pio_e_status           ),

  //Host to Device Register Values
  .h2d_command            (h2d_command            ),
  .h2d_features           (h2d_features           ),
  .h2d_control            (h2d_control            ),
  .h2d_port_mult          (h2d_port_mult          ),
  .h2d_device             (h2d_device             ),
  .h2d_lba                (h2d_lba                ),
  .h2d_sector_count       (h2d_sector_count       ),

  //Device to Host Register Values
  .d2h_interrupt          (d2h_interrupt          ),
  .d2h_notification       (d2h_notification       ),
  .d2h_port_mult          (d2h_port_mult          ),
  .d2h_device             (d2h_device             ),
  .d2h_lba                (d2h_lba                ),
  .d2h_sector_count       (d2h_sector_count       ),
  .d2h_status             (d2h_status             ),
  .d2h_error              (d2h_error              ),

  //command layer data interface
  .cl_if_ready            (cl_if_ready            ),
  .cl_if_activate         (cl_if_activate         ),
  .cl_if_size             (cl_if_size             ),
  .cl_if_strobe           (cl_if_strobe           ),
  .cl_if_data             (cl_if_data             ),

  .cl_of_ready            (cl_of_ready            ),
  .cl_of_activate         (cl_of_activate         ),
  .cl_of_strobe           (cl_of_strobe           ),
  .cl_of_data             (cl_of_data             ),
  .cl_of_size             (cl_of_size             ),


  //Link Layer Interface
  .link_layer_ready       (link_layer_ready       ),
  .ll_sync_escape         (t_sync_escape          ),

  .ll_write_start         (t_write_start          ),
  .ll_write_strobe        (t_write_strobe         ),
  .ll_write_finished      (t_write_finished       ),
  .ll_write_data          (t_write_data           ),
  .ll_write_size          (t_write_size           ),
  .ll_write_hold          (t_write_hold           ),
  .ll_write_abort         (t_write_abort          ),
  .ll_xmit_error          (t_xmit_error           ),

  .ll_read_start          (t_read_start           ),
  .ll_read_ready          (t_read_ready           ),
  .ll_read_data           (t_read_data            ),
  .ll_read_strobe         (t_read_strobe          ),
  .ll_read_finished       (t_read_finished        ),
  .ll_read_crc_ok         (t_read_crc_ok          ),
  .ll_remote_abort        (t_remote_abort         ),

  .lax_state              (dbg_t_lax_state        )

);

sata_link_layer sll(
  .rst                    (rst  | !linkup         ),
  .clk                    (clk                    ),

  //Status
  .link_layer_ready       (link_layer_ready       ),
  .sync_escape            (ll_sync_escape         ),
  .write_ready            (dbg_ll_write_ready     ),
  .post_align_write       (dbg_ll_paw             ),
  .hold                   (1'b0                   ),

  //Transport Layer Interface
  .write_start            (ll_write_start         ),
  .write_strobe           (ll_write_strobe        ),
  .write_finished         (ll_write_finished      ),
  .write_data             (ll_write_data          ),
  .write_size             (ll_write_size          ),
  .write_hold             (ll_write_hold          ),
  .write_abort            (ll_write_abort         ),

  .read_data              (ll_read_data           ),
  .read_strobe            (ll_read_strobe         ),
  .read_ready             (ll_read_ready          ),
  .read_start             (ll_read_start          ),
  .read_finished          (ll_read_finished       ),
  .remote_abort           (ll_remote_abort        ),
  .xmit_error             (ll_xmit_error          ),
  .read_crc_ok            (ll_read_crc_ok         ),

  .prim_scrambler_en      (prim_scrambler_en      ),
  .data_scrambler_en      (data_scrambler_en      ),

   //Phy Layer
  .phy_ready              (phy_ready              ),
  .platform_ready         (platform_ready         ),
  .tx_dout                (ll_tx_dout             ),
  .tx_isk                 (ll_tx_isk              ),

  .rx_din                 (rx_din                 ),
  .rx_isk                 (rx_isk                 ),
  .is_device              (1'b0                   ),

//Primative Detection
  .detect_sync            (dbg_detect_sync        ),
  .detect_r_rdy           (dbg_detect_r_rdy       ),
  .detect_r_ip            (dbg_detect_r_ip        ),
  .detect_r_ok            (dbg_detect_r_ok        ),
  .detect_r_err           (dbg_detect_r_err       ),
  .detect_x_rdy           (dbg_detect_x_rdy       ),
  .detect_sof             (dbg_detect_sof         ),
  .detect_eof             (dbg_detect_eof         ),
  .detect_wtrm            (dbg_detect_wtrm        ),
  .detect_cont            (dbg_detect_cont        ),
  .detect_hold            (dbg_detect_hold        ),
  .detect_holda           (dbg_detect_holda       ),
  .detect_align           (dbg_detect_align       ),
  .detect_preq_s          (dbg_detect_preq_s      ),
  .detect_preq_p          (dbg_detect_preq_p      ),
  .detect_xrdy_xrdy       (dbg_detect_xrdy_xrdy   ),

  .dbg_send_holda         (dbg_send_holda         ),

  .send_crc               (dbg_ll_send_crc        ),


  .lax_i_state            (dbg_li_lax_state       ),
  .lax_r_state            (dbg_lr_lax_state       ),
  .lax_w_state            (dbg_lw_lax_state       ),
  .lax_w_fstate           (dbg_lw_lax_fstate      ),


  .in_data_addra          (slw_in_data_addra      ),
  .d_count                (slw_d_count            ),
  .write_count            (slw_write_count        ),
  .buffer_pos             (slw_buffer_pos         )




);

sata_phy_layer phy (
  .rst                    (rst                    ),
  .clk                    (clk                    ),

  //Control/Status
  .platform_ready         (platform_ready         ),
  .linkup                 (linkup                 ),

  //Platform Interface
  .tx_dout                (phy_tx_dout            ),
  .tx_isk                 (phy_tx_isk             ),
  .tx_comm_reset          (tx_comm_reset          ),
  .tx_comm_wake           (tx_comm_wake           ),
  .tx_elec_idle           (tx_elec_idle           ),

  .rx_din                 (rx_din                 ),
  .rx_isk                 (rx_isk                 ),
  .comm_init_detect       (comm_init_detect       ),
  .comm_wake_detect       (comm_wake_detect       ),
  .rx_elec_idle           (rx_elec_idle           ),
  .rx_byte_is_aligned     (rx_byte_is_aligned     ),

  .lax_state              (lax_state              ),
  .phy_ready              (phy_ready              )
);



//Asynchronous Logic

//control of data to the platform controller
assign                tx_dout     = (phy_ready) ? ll_tx_dout  : phy_tx_dout;
assign                tx_isk      = (phy_ready) ? ll_tx_isk   : phy_tx_isk;

  //no activity on the stack

//Debug
assign                ll_write_start        = t_write_start;
assign                dbg_ll_write_start    = t_write_start;
assign                ll_write_data         = t_write_data;
assign                dbg_ll_write_data     = t_write_data;
assign                ll_write_hold         = t_write_hold;
assign                dbg_ll_write_hold     = t_write_hold;
assign                ll_write_size         = t_write_size;
assign                dbg_ll_write_size     = t_write_size;
assign                ll_write_abort        = t_write_abort;
assign                dbg_ll_write_abort    = t_write_abort;

assign                ll_read_ready         = t_read_ready;
assign                dbg_ll_read_ready     = t_read_ready;
assign                ll_sync_escape        = t_sync_escape;

assign                dbg_ll_write_strobe   = ll_write_strobe;
assign                t_write_strobe        = ll_write_strobe;

assign                dbg_ll_write_finished = ll_write_finished;
assign                t_write_finished      = ll_write_finished;


assign                dbg_ll_read_strobe    = ll_read_strobe;
assign                dbg_ll_read_start     = ll_read_start;
assign                dbg_ll_read_finished  = ll_read_finished;
assign                dbg_ll_read_data      = ll_read_data;
assign                dbg_ll_remote_abort   = ll_remote_abort;
assign                dbg_ll_xmit_error     = ll_xmit_error;

assign                t_read_strobe         = ll_read_strobe;
assign                t_read_start          = ll_read_start;
assign                t_read_finished       = ll_read_finished;
assign                t_read_data           = ll_read_data;
assign                t_remote_abort        = ll_remote_abort;
assign                t_xmit_error          = ll_xmit_error;
assign                t_read_crc_ok         = ll_read_crc_ok;

assign                dbg_send_command_stb  = send_command_stb;
assign                dbg_send_control_stb  = send_control_stb;
assign                dbg_send_data_stb     = send_data_stb;

assign                dbg_remote_abort        = remote_abort;
assign                dbg_xmit_error          = xmit_error;
assign                dbg_read_crc_error      = read_crc_error;

assign                dbg_h2d_command         = h2d_command;
assign                dbg_h2d_features        = h2d_features;
assign                dbg_h2d_control         = h2d_control;
assign                dbg_h2d_port_mult       = h2d_port_mult;
assign                dbg_h2d_device          = h2d_device;
assign                dbg_h2d_sector_count    = h2d_sector_count;


assign                cl_if_ready             = if_ready;
assign                dbg_cl_if_activate      = cl_if_activate;
assign                if_activate             = cl_if_activate;
assign                dbg_cl_if_size          = if_size;
assign                cl_if_size              = if_size;
assign                dbg_cl_if_strobe        = cl_if_strobe;
assign                if_strobe               = cl_if_strobe;
assign                dbg_cl_if_data          = if_data;
assign                cl_if_data              = if_data;

assign                cl_of_ready             = of_ready;
assign                dbg_cl_of_ready         = of_ready;
assign                of_activate             = cl_of_activate;
assign                dbg_cl_of_activate      = cl_of_activate;
assign                of_strobe               = cl_of_strobe;
assign                dbg_cl_of_strobe        = cl_of_strobe;
assign                of_data                 = cl_of_data;
assign                dbg_cl_of_data          = cl_of_data;
assign                cl_of_size              = of_size;
assign                dbg_cl_of_size          = of_size;



//Synchronous Logic
endmodule
