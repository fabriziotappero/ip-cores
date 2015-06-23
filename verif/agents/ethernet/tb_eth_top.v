
/*-----------------------------------------------------------------
|           Ethernet MAC Traffic Generator Testbench                |
|                                                                   |
 ------------------------------------------------------------------*/

/*-----------------------------------------------------------------\
|  DESCRIPTION:                                                    |
|  tb_top.v:  Top of MAC testbench hierarchy                       |
|                                                                  |
|  Instantiates the following modules:                             |
|    tb_mii.v:  MII interface                                      |
|    tb_rmii.v: Reduced MII interface                              |
|    tb_smii.v: Serial MII interface (add-on module)               |
|    tb_gmii.v: Gigabit MII interface (add-on module)              |
|    tb_serd.v: Gigabit SERDES 10-bit interface (add-on module)    |
|                                                                  |
|  Included files:                                                 |
|    tb_conf.v                                                     |
|    tb_defs.v                                                     |
|    tb_objs.v                                                     |
|    tb_tasks.v                                                    |
|    tb_pktgn.v                                                    |
\-----------------------------------------------------------------*/
 

`timescale 1ns/100ps

`include "tb_eth_conf.v"
`include "tb_eth_defs.v"

module tb_eth_top(

	  REFCLK_50_MHz,            // 50 MHz Reference clock input
	  REFCLK_125_MHz,           // 125 MHz reference clock
          transmit_enable,          // transmit enable for testbench
	      
	  // Separate interfaces for each MII port type

          // Full MII, 4-bit interface
          // Transmit interface
          MII_RXD,                  // Receive data (output)
          MII_RX_CLK,               // Receive clock for MII (output)
          MII_CRS,                  // carrier sense (output)
          MII_COL,                  // Collision signal for MII (output)
	  MII_RX_DV,                // Receive data valid for MII (output)
          // Receive interface
          MII_TXD,                  // Transmit data (input)
          MII_TX_EN,                // Tx enable (input)
          MII_TX_CLK,               // Transmit clock (output)

          // Reduced MII, 2-bit interface
          // Transmit interface
          RMII_RXD,                 // Receive data (output)
          RMII_CRS_DV,              // carrier sense (output)
          // Receive interface
          RMII_TXD,                 // Transmit data (input)
          RMII_TX_EN,               // Tx enable (input)

          // Serial MII interface
          SMII_RXD,                 // Receive data (output)
          SMII_TXD,                 // Transmit data (input)
          SMII_SYNC,                // SMII SYNC signal (input)		     
		     
          // GMII, 8-bit/10-bit interface
          // Transmit interface
          GMII_RXD,                 // Receive data (output)
          GMII_RX_CLK,              // Receive clock for MII (output)
          GMII_CRS,                 // carrier sense (output)
          GMII_COL,                 // Collision signal for MII (output)
	  GMII_RX_DV,               // Receive data valid for MII (output)
          // Receive interface
          GMII_TXD,                 // Transmit data (input)
          GMII_TX_EN,               // Tx enable (input)
          GMII_TX_CLK,              // Transmit clock (output)
	  GMII_GTX_CLK,             // Gigabit Transmit clock (input), 125 MHz

              // MII management interface
	  MDIO,                     // serial I/O data
	  MDC                       // clock
		  );


   input   REFCLK_50_MHz, REFCLK_125_MHz;

   input   transmit_enable;

   // Full-MII signals
   output [`MII_WIDTH-1: 0]              MII_RXD;
   output                                MII_RX_CLK,
					                               MII_CRS,
					                               MII_COL,
					                               MII_RX_DV;
   input  [`MII_WIDTH-1: 0]              MII_TXD;
   input                 	               MII_TX_EN;
   output                	               MII_TX_CLK;
   
   // RMII signals
   output [`RMII_WIDTH-1: 0]             RMII_RXD;
   output                                RMII_CRS_DV;
   input  [`RMII_WIDTH-1: 0]             RMII_TXD;
   input                                 RMII_TX_EN;

   // Serial MII signals
   output                                SMII_RXD;
   input                                 SMII_TXD;
   input                                 SMII_SYNC;

   //Gigabit-MII signals
   output [`GMII_WIDTH-1: 0]             GMII_RXD;
   output                                GMII_RX_CLK, 
					                               GMII_CRS,
					                               GMII_COL,
					                               GMII_RX_DV;
   input  [`GMII_WIDTH-1: 0]             GMII_TXD;
   input                                 GMII_TX_EN;
   output                                GMII_TX_CLK;
   input                                 GMII_GTX_CLK;


   // MII Management
   inout                                 MDIO;
   input                                 MDC;

`include "tb_eth_objs.v"

   // transmit buffer
   reg [`MAX_PKT_SIZE*8 -1:0] 		       transmit_pkt;
   integer                               transmit_pkt_size;

   // receive buffer
   reg [`MAX_PKT_SIZE*8 -1:0]            receive_pkt;
   integer                               receive_pkt_size;

   reg                                   transmit_data_valid;
   wire                                  transmit_done;
   wire                                  receive_data_valid;
   reg                                   receive_data_available;

   integer   transmit_packet_count, packets_sent, transmit_timer;
   reg       transmit_timer_active, transmit_timer_expired, port_tx_busy;

                                        // flag set during transmission of
                                        // a packet sequence
   //Current transmit packet parameters
   integer    current_pkt_size;
   reg [47:0] current_src_mac, current_dstn_mac;
   reg [15:0] current_VLAN_TCI;
   reg        user_frame; // currently transmitting
                                                   // frame from user buffer
   integer    user_frame_current_ifg;
                                                   // ifg for user frame
   wire       SMII_TX_EN;

   reg [1:0]   user_crc_option; // CRC generation option for user frames
   reg [31:0]  user_crc_value;  // user-supplied CRC for user-generated frames
   
   // State variables exported to  MII module
   integer 		 mii_transmit_state,
				       mii_receive_state,
				       mii_collision_counter; // for normal cols
   reg         mii_SFD_received;

//   wire [31:0] event_file;
   /* MII port instantiations */
   /* Comment out unnecessary interfaces to save simulation cycles */

   tb_mii full_mii(
		   .port_type               ({port_duplex_status, port_speed[2:0]}),
		   .port_tx_enable          (MII_port_tx_enable),
		   .port_rx_enable          (MII_port_rx_enable),

		   .REFCLK                  (REFCLK_50_MHz),
		   .RXD                     (MII_RXD),
		   .RX_CLK                  (MII_RX_CLK),
		   .CRS                     (MII_CRS),
		   .COL                     (MII_COL),
		   .RX_DV                   (MII_RX_DV),
		   .TXD                     (MII_TXD),
		   .TX_EN                   (MII_TX_EN),
		   .TX_CLK                  (MII_TX_CLK),
		   .transmit_data_valid     (transmit_data_valid),
		   .transmit_complete       (transmit_done),
		   .receive_data_valid      (receive_data_valid),
		   .event_file              (event_file)
 );


   tb_rmii reduced_mii(
                   .port_type               ({port_duplex_status, port_speed[2:0]}),
		   .port_tx_enable          (RMII_port_tx_enable),
		   .port_rx_enable          (RMII_port_rx_enable),

		   .REFCLK                  (REFCLK_50_MHz),
		   .RXD                     (RMII_RXD),
		   .CRS_DV                  (RMII_CRS_DV),
		   .TXD                     (RMII_TXD),
		   .TX_EN                   (RMII_TX_EN),
		   .transmit_data_valid     (transmit_data_valid),
		   .transmit_complete       (transmit_done),
		   .receive_data_valid      (receive_data_valid),
		   .event_file              (event_file)
                   );


   integer i;

   initial
    begin
       transmit_data_valid = 0;
       transmit_packet_count = 0;
       receive_data_available =0;
       port_mii_type = 3'b111; // set port MII type to invalid
       packets_sent = 0;
       transmit_timer_active = 0;
       transmit_timer_expired = 0;
       port_tx_busy = 0;
       user_frame = 0;

       MII_port_tx_enable = 0;
       MII_port_rx_enable = 0;
       RMII_port_tx_enable = 0;
       RMII_port_rx_enable = 0;
       GMII_port_tx_enable = 0;
       GMII_port_rx_enable = 0;
       SMII_port_tx_enable = 0;
       SMII_port_rx_enable = 0;
       SERDES_tx_enable = 0;
       SERDES_rx_enable = 0;
       custom_tx_enable = 0;
       custom_rx_enable = 0;
       
       seqno_enable = 0; // do not insert sequence numbers in transmitted pkts
       timestamp_enable = 0; // do not insert timestamps
       packet_seq_no = 0;  // initialize sequence number
       L3_sequence_number = 0; // initialize IP sequence number
       flow_type = 0; // default = Layer-2 unicast
       
       user_crc_option = 0; // enable CRC insertion for user frames, good CRC
       user_crc_value = 0;  // defaulr for user_generated CRC
       
       // set default backoff parameters
       collision_limit = 16;
       backoff_slots[1] = 32'd2;
       backoff_type[1] = 1; // random backoff
       for (i=2; i <= `MAX_COLLISIONS; i=i+1)
	begin
	   backoff_slots[i] = backoff_slots[i-1] *2;
	   if (backoff_slots[i] > 1024)
	    backoff_slots[i] = 1024;  // clamp at 1024 slots
	   backoff_type[i] = 1; // random backoff
	end // for (i=2; i <= `MAX_COLLISIONS; i=i+1)

       set_default_header_parameters; // initialize headers to default patterns
       //outfile = $fopen(`PARAM_LOG_FILENAME); // open parameter log
//        while (1)
//        begin	
// 	#20;
// 	event_file = "eth_events_log"; // open event log
// 	#20;
// 	end
    end // initial begin

    

`include "tb_eth_tasks.v"

   //Generate a 1MHz clock for generating transmit timeout
   reg clock_1_MHz;
   integer clk_cnt_1_MHz;

   initial
    begin
       clock_1_MHz = 0;
       clk_cnt_1_MHz = 0;
    end // initial begin

   always @(posedge REFCLK_50_MHz)
    begin
       if (clk_cnt_1_MHz == 24)
	begin
	   clock_1_MHz = ~clock_1_MHz;
	   clk_cnt_1_MHz = 0;
	end 
       else
	clk_cnt_1_MHz = clk_cnt_1_MHz +1;
    end

   //Transmit timeout
   always @(posedge clock_1_MHz)
    if (transmit_timer_active)
     begin
	transmit_timer = transmit_timer -1;
	if (transmit_timer == 0)
	 begin
	    $display("%t ns: Testbench transmit timer timed out", $time);
	    if (`TERMINATE_ON_TRANSMIT_TIMEOUT)
	     $finish;
	    transmit_timer_expired= 1;
	    transmit_timer_active = 0;
	 end // if (transmit_timer == 0)
     end // if (transmit_timer_active)
   
   // Main transmit loop
   always @(posedge REFCLK_50_MHz)
    if ((port_tx_busy == 1) &&
	((port_speed == 0) || (port_speed == 1)))
     //only for 10 and 100 Mb ports
     begin: main_transmit_block
	integer delay, i;

	if (!user_frame)
	 construct_frame;
	transmit_data_valid= 1; // send signal to MII to transmit
       @(posedge REFCLK_50_MHz)
	transmit_data_valid = 0;
	wait(transmit_done);

	packets_sent = packets_sent +1;
	packet_seq_no = packet_seq_no +1; // increment sequence number;

	// update fields for next packet
	if (!user_frame)
	 update_header_parameters;
	if ((packets_sent >= transmit_packet_count) ||
	   (transmit_timer_expired)) // transmit no more packets
	 port_tx_busy = 0;
	else
	 begin
	    // wait for inter-packet spacing
	    delay = current_ifg - port_min_ifg; // delay in bit times
	    case(port_speed)
	     0: begin // 10 Mb/s = 100 ns per bit
		for (i = delay*5; i >= 0; i = i-1)
		 if (!transmit_timer_expired)
		  @(posedge REFCLK_50_MHz);
	     end // case: 0

	     1: begin // 100 Mb/s = 10 ns per bit
		for (i = delay/2; i >= 0; i = i-1)
		 if (!transmit_timer_expired)
		 @(posedge REFCLK_50_MHz);
	     end // case: 1
	     
	     default: begin // we shouldn't get here
	     end // case: default
	      
	    endcase // case(port_speed)
	    if (transmit_timer_expired)
	     port_tx_busy = 0;
	 end // else: !if((packets_sent >= transmit_packet_count) ||...
     end // block: main_transmit_block

   // Main loop for gigabit port
   always @(posedge REFCLK_125_MHz)
    if ((port_tx_busy == 1) &&
	(port_speed == 2))
     begin: main_transmit_block_gigabit
	integer delay, i;

	if (!user_frame)
	 construct_frame;
	transmit_data_valid= 1; // send signal to MII to transmit
       @(posedge REFCLK_125_MHz)
	transmit_data_valid = 0;
	wait(transmit_done);

	packets_sent = packets_sent +1;
	packet_seq_no = packet_seq_no +1; // increment sequence number;

	// update fields for next packet
	if (!user_frame)
	 update_header_parameters;
	if ((packets_sent >= transmit_packet_count) ||
	    (transmit_timer_expired)) // transmit no more packets
	 port_tx_busy = 0;
	else
	 begin
	    // wait for inter-packet spacing
	    delay = current_ifg - port_min_ifg; // delay in bit times
	    for (i = delay/8; i >= 0; i = i-1)
	     if (!transmit_timer_expired)
	      @(posedge REFCLK_125_MHz);

	    if (transmit_timer_expired)
	     port_tx_busy = 0;
	 end // else: !if((packets_sent >= transmit_packet_count) ||...
     end // block: main_transmit_block_gigabit

`include "tb_eth_pktgn.v" // packet generation tasks

endmodule // testbench

   


   
	      





