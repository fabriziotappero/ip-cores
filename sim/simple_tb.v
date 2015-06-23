`timescale 1ns/1ps

`define SCLK_HALF_PERIOD 3

`define SCLK_PERIOD (2 * `SCLK_HALF_PERIOD)

`define STARTUP_TIMEOUT   32'h00000100
`define ERROR_TIMEOUT     32'h00000100
`define TXRX_TIMEOUT      32'h00001000

`include "sata_defines.v"

module simple_tb ();

//Parameters
//Registers/Wires
reg                 rst           = 0;            //reset
reg                 sata_clk      = 0;

wire                linkup;           //link is finished
wire                sata_ready;
wire                busy;


reg                 write_data_en;
reg                 read_data_en;

reg                 soft_reset_en   = 0;
reg         [15:0]  sector_count    = 8;
reg         [47:0]  sector_address  = 0;

wire                d2h_interrupt;
wire                d2h_notification;
wire        [3:0]   d2h_port_mult;
wire        [7:0]   d2h_device;
wire        [47:0]  d2h_lba;
wire        [15:0]  d2h_sector_count;
wire        [7:0]   d2h_status;
wire        [7:0]   d2h_error;


reg         [31:0]  user_din;
reg                 user_din_stb;
wire        [1:0]   user_din_ready;
reg         [1:0]   user_din_activate;
wire        [23:0]  user_din_size;

wire        [31:0]  user_dout;
wire                user_dout_ready;
reg                 user_dout_activate;
reg                 user_dout_stb;
wire        [23:0]  user_dout_size;


wire                transport_layer_ready;
wire                link_layer_ready;
wire                phy_ready;

wire    [31:0]      tx_dout;
wire                tx_isk;
wire                tx_comm_reset;
wire                tx_comm_wake;
wire                tx_elec_idle;

wire    [31:0]      rx_din;
wire    [3:0]       rx_isk;
wire                rx_elec_idle;
wire                comm_init_detect;
wire                comm_wake_detect;

wire                rx_byte_is_aligned;

wire                prim_scrambler_en;
wire                data_scrambler_en;

//Data Interface
wire                tx_set_elec_idle;
wire                rx_is_elec_idle;
wire                hd_ready;
wire                platform_ready;

//Debug
wire        [31:0]  hd_data_to_host;

reg         [23:0]  din_count;
reg         [23:0]  dout_count;
reg                 hold;

reg                 single_rdwr = 0;


reg                 clk         = 0;




//Submodules

sata_stack ss (
  .rst                   (rst                  ),  //reset
  .clk                   (sata_clk             ),  //clock used to run the stack
  .data_in_clk           (sata_clk             ),
  .data_out_clk          (sata_clk             ),

  .platform_ready        (platform_ready       ),  //the underlying physical platform is
  .linkup                (linkup               ),  //link is finished
  .sata_ready            (sata_ready           ),


  .busy                  (busy                 ),


  .write_data_en         (write_data_en        ),
  .single_rdwr           (single_rdwr          ),
  .read_data_en          (read_data_en         ),

  .send_user_command_stb (1'b0                 ),
  .soft_reset_en         (soft_reset_en        ),
  .command               (1'b0                 ),

  .sector_count          (sector_count         ),
  .sector_address        (sector_address       ),

  .d2h_interrupt         (d2h_interrupt        ),
  .d2h_notification      (d2h_notification     ),
  .d2h_port_mult         (d2h_port_mult        ),
  .d2h_device            (d2h_device           ),
  .d2h_lba               (d2h_lba              ),
  .d2h_sector_count      (d2h_sector_count     ),
  .d2h_status            (d2h_status           ),
  .d2h_error             (d2h_error            ),

  .user_din              (user_din             ),
  .user_din_stb          (user_din_stb         ),
  .user_din_ready        (user_din_ready       ),
  .user_din_activate     (user_din_activate    ),
  .user_din_size         (user_din_size        ),

  .user_dout             (user_dout            ),
  .user_dout_ready       (user_dout_ready      ),
  .user_dout_activate    (user_dout_activate   ),
  .user_dout_stb         (user_dout_stb        ),
  .user_dout_size        (user_dout_size       ),

  .transport_layer_ready (transport_layer_ready),
  .link_layer_ready      (link_layer_ready     ),
  .phy_ready             (phy_ready            ),

  .tx_dout               (tx_dout              ),
  .tx_isk                (tx_isk               ),
  .tx_comm_reset         (tx_comm_reset        ),
  .tx_comm_wake          (tx_comm_wake         ),
  .tx_elec_idle          (tx_elec_idle         ),

  .rx_din                (rx_din               ),
  .rx_isk                (rx_isk               ),
  .rx_elec_idle          (rx_elec_idle         ),
  .comm_init_detect      (comm_init_detect     ),
  .comm_wake_detect      (comm_wake_detect     ),
  .rx_byte_is_aligned    (rx_byte_is_aligned   ),


  .prim_scrambler_en     (prim_scrambler_en    ),
  .data_scrambler_en     (data_scrambler_en    )
);

faux_sata_hd  fshd   (
  .rst                   (rst                  ),
  .clk                   (sata_clk             ),
  .tx_dout               (rx_din               ),
  .tx_isk                (rx_isk               ),

  .rx_din                (tx_dout              ),
  .rx_isk                ({3'b000, tx_isk}     ),
  .rx_is_elec_idle       (tx_elec_idle         ),
  .rx_byte_is_aligned    (rx_byte_is_aligned   ),

  .comm_reset_detect     (tx_comm_reset        ),
  .comm_wake_detect      (tx_comm_wake         ),

  .tx_comm_reset         (comm_init_detect     ),
  .tx_comm_wake          (comm_wake_detect     ),

  .hd_ready              (hd_ready             ),
//  .phy_ready             (phy_ready            ),


  .dbg_data_scrambler_en (data_scrambler_en    ),

  .dbg_hold              (hold                ),

  .dbg_ll_write_start    (0                    ),
  .dbg_ll_write_data     (0                    ),
  .dbg_ll_write_size     (0                    ),
  .dbg_ll_write_hold     (0                    ),
  .dbg_ll_write_abort    (0                    ),

  .dbg_ll_read_ready     (0                    ),
  .dbg_t_en              (0                    ),

  .dbg_send_reg_stb      (0                    ),
  .dbg_send_dma_act_stb  (0                    ),
  .dbg_send_data_stb     (0                    ),
  .dbg_send_pio_stb      (0                    ),
  .dbg_send_dev_bits_stb (0                    ),

  .dbg_pio_transfer_count(0                    ),
  .dbg_pio_direction     (0                    ),
  .dbg_pio_e_status      (0                    ),

  .dbg_d2h_interrupt     (0                    ),
  .dbg_d2h_notification  (0                    ),
  .dbg_d2h_status        (0                    ),
  .dbg_d2h_error         (0                    ),
  .dbg_d2h_port_mult     (0                    ),
  .dbg_d2h_device        (0                    ),
  .dbg_d2h_lba           (0                    ),
  .dbg_d2h_sector_count  (0                    ),

  .dbg_cl_if_data        (0                    ),
  .dbg_cl_if_ready       (0                    ),
  .dbg_cl_if_size        (0                    ),
  .dbg_cl_of_ready       (0                    ),
  .dbg_cl_of_size        (0                    ),
  .hd_data_to_host       (hd_data_to_host      )


);



//Asynchronous Logic
assign  prim_scrambler_en             = 1;
assign  data_scrambler_en             = 1;
assign  platform_ready                = 1;
assign  hd_data_to_host               = 32'h01234567;


//Synchronous Logic
always #`SCLK_HALF_PERIOD sata_clk    = ~sata_clk;
always #1 clk                         = ~clk;

//Simulation Control
initial begin
  rst <=  1;
  $dumpfile ("design.vcd");
  $dumpvars(0, simple_tb);
  #(20 * `SCLK_PERIOD);
  rst <=  0;
  #40000;
  $finish();
end


//Simulation Conditions
initial begin
  sector_address                    <=  0;
  sector_count                      <=  8;
  write_data_en                     <=  0;
  read_data_en                      <=  0;
  single_rdwr                       <=  0;

  #(20 * `SCLK_PERIOD);
  while (!linkup) begin
    #1;
  end
  while (busy) begin
    #1;
  end
  //Send a command
//  #(700 * `SCLK_PERIOD);
  #(563 * `SCLK_PERIOD);
  write_data_en                     <=  1;
  #(1000 * `SCLK_PERIOD);
  while (!busy) begin
    #1;
  end
  write_data_en                     <=  0;
  #(100 * `SCLK_PERIOD);


  while (busy) begin
    #1;
  end

  #(200 * `SCLK_PERIOD);
  write_data_en                     <=  1;
  //read_data_en                     <=  1;
  #(20 * `SCLK_PERIOD);
  while (!busy) begin
    #1;
  end
  write_data_en                     <=  1;
  //read_data_en                     <=  0;



end

initial begin
  hold                              <=  0;
  #(20 * `SCLK_PERIOD);
  while (!write_data_en) begin
    #1;
 end
  #(800* `SCLK_PERIOD);
  hold                              <=  1;
  #(100 * `SCLK_PERIOD);
  hold                              <=  0;
end
/*
//inject a hold
initial begin
  hold                              <=  0;
  #(20 * `SCLK_PERIOD);
  while (!write_data_en) begin
    #1;
  end
  #(682 * `SCLK_PERIOD);
  hold                              <=  1;
  #(1 * `SCLK_PERIOD);
  hold                              <=  0;
end
*/


/*
initial begin
  sector_address                    <=  0;
  sector_count                      <=  0;
  write_data_en                     <=  0;
  read_data_en                      <=  0;

  #(20 * `SCLK_PERIOD);
  while (!linkup) begin
    #1;
  end
  while (busy) begin
    #1;
  end
  //Send a command
  #(824 * `SCLK_PERIOD);
  write_data_en                     <=  1;
  #(20 * `SCLK_PERIOD);
  while (!busy) begin
    #1;
  end
  write_data_en                     <=  0;
end
*/

//Buffer Fill/Drain
always @ (posedge sata_clk) begin
  if (rst) begin
    user_din                        <=  0;
    user_din_stb                    <=  0;
    user_din_activate               <=  0;
    din_count                       <=  0;

    user_dout_activate              <=  0;
    user_dout_stb                   <=  0;
    dout_count                      <=  0;
  end
  else begin
    user_din_stb                    <=  0;
    user_dout_stb                   <=  0;

    if ((user_din_ready > 0) && (user_din_activate == 0)) begin
      din_count                     <=  0;
      if (user_din_ready[0]) begin
        user_din_activate[0]        <=  1;
      end
      else begin
        user_din_activate[1]        <=  1;
      end
    end

    if (din_count >= user_din_size) begin
      user_din_activate            <=  0;
    end
    else if (user_din_activate > 0) begin
      user_din_stb                  <=  1;
      user_din                      <=  din_count;
      din_count                     <=  din_count + 1;
    end

    if (user_dout_ready && !user_dout_activate) begin
      dout_count                    <=  0;
      user_dout_activate            <=  1;
    end

    if (dout_count >= user_dout_size) begin
      user_dout_activate             <=  0;
    end
    else if (user_dout_activate) begin
      user_dout_stb                 <=  1;
    end
  end
end


endmodule
