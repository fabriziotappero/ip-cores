
/*-------------------------------------------------------------
|           Ethernet MAC Traffic Generator Testbench           | 
 -------------------------------------------------------------*/ 

/*-----------------------------------------------------------------\
|  DESCRIPTION:                                                    |
|  tb_mii.v:  MII interface of testbench                           |
|                                                                  |
|  Instantiated modules: none                                      |
|  Included files: tb_conf.v                                       |
\-----------------------------------------------------------------*/



`timescale 1ns/100ps

`include "tb_eth_conf.v"

module tb_rmii(
	       port_type,   // includes duplex status and speed
	       port_tx_enable, // enable port TX
	       port_rx_enable, // enable port RX
	       // MII signals
	       REFCLK,   // Reference clock input
	       // Transmit interface of testbench
	       RXD,      // Receive data (output)
	       CRS_DV,    // RX data valid (output) for MII
	       // Receive interface of testbench
	       TXD,      // Transmit data (input)
	       TX_EN,    // Transmit Enable (input)

	       // Packet interface
	       transmit_data_valid, // flag to enable transmission
	       transmit_complete,   // flag set to indicate end of transmission
	       receive_data_valid,  // set to signal valid packet received
	       event_file           // Log file descriptor
	       );

   input [3:0] 	                port_type;
   input                        port_tx_enable, port_rx_enable;

   input                        REFCLK;
   output [`RMII_WIDTH-1:0]     RXD;
   output                       CRS_DV;

   input [`RMII_WIDTH-1:0]      TXD;
   input                        TX_EN;

   input                        transmit_data_valid;
   inout                        transmit_complete;
   inout                        receive_data_valid;

   input  [31:0]                event_file;

   reg [`RMII_WIDTH-1:0] 	RXD;
   reg                          CRS, RXDV;

   reg                          local_transmit_complete;
   reg                          local_receive_data_valid;
          
   reg [7:0] 			tx_reg; // transmit data register
   reg                          transmit_clk;  // Transmit clock: 50 or 5 MHz
   integer                      transmit_clk_count; // counter to generate transmit clk

   integer                      CLK_DIVISOR; //Modulus of transmit clock counter
   integer                      PAUSE_COUNTER_MAX; // Modulus of counter to
                                                   // generate pause timer clock
   reg                          alignment_error;  // Alignment error in received frame

   integer                      collision_counter;
   integer                      forced_col_counter;
                                // collision counter for forced collisions
   reg                          collision_detect;
   reg                          backoff_complete;
   reg                          collision_limit_reached;
   reg                          extended_TX_EN;
   integer                      transmit_state;  // state of transmit interface
   integer                      receive_state; // state of receive interface
   
   reg                          paused;  // Pause frame received
   integer                      pause_parameter; // pause parameter received
   reg                          pause_timer_clk; // clock for pause timer
   reg [7:0]                    pause_timer_count; // counter to generate clock

   reg [`MAX_PKT_SIZE*8-1:0] 	transmit_pkt_reg;
   reg [15:0]                   transmit_pkt_size_reg;

   integer                      bytes_sent;

   integer                      first_IFG_cycle; // time at which IFG detected first
   integer                      last_IFG; // length of last IFG

   integer                      receive_packet_count; // number of pkts received

   // Valid transmit and receive states
`define       INACTIVE          0
`define       XMIT_IDLE         1
`define       RCV_IDLE          1
`define       XMIT_BUSY         2
`define       RCV_BUSY          2
`define       COLLISION         3
`define       XMIT_PAUSED       4

`define       FULL_DUPLEX_PORT     port_type[3]
`define       SPEED_100Mb          port_type[0]
   
   // access port parameters from tbench module
`define port_idle_count           `TESTBENCH.port_idle_count
`define preamble_length           `TESTBENCH.preamble_length
`define preamble_reg              `TESTBENCH.preamble_reg
`define dribble_bit_count         `TESTBENCH.dribble_bit_count
`define carrier_override          `TESTBENCH.carrier_override
`define frame_extend_bit_count    `TESTBENCH.frame_extend_bit_count
`define frame_extend_reg          `TESTBENCH.frame_extend_reg
`define ignore_rcv_pause          `TESTBENCH.ignore_rcv_pause
`define pause_increment           `TESTBENCH.pause_increment
`define collision_detection_delay `TESTBENCH.collision_detection_delay
`define force_collision           `TESTBENCH.force_collision
`define collision_offset          `TESTBENCH.collision_offset
`define forced_collision_count    `TESTBENCH.forced_collision_count
`define force_collision_delay     `TESTBENCH.force_collision_delay
`define jam_length                `TESTBENCH.jam_length

`define seq_number_offset         `TESTBENCH.seq_number_offset
`define timestamp_offset          `TESTBENCH.timestamp_offset

`define ext_transmit_state        `TESTBENCH.mii_transmit_state
`define ext_receive_state         `TESTBENCH.mii_receive_state
`define ext_collision_counter     `TESTBENCH.mii_collision_counter
`define ext_SFD_received          `TESTBENCH.mii_SFD_received

   assign CRS_DV = (CRS | `carrier_override) & port_tx_enable;

   assign transmit_complete = port_tx_enable ? local_transmit_complete :
			      1'bz;

   assign receive_data_valid = port_rx_enable ? local_receive_data_valid :
			       1'bz;

   initial
    begin
       transmit_clk_count = 0;
       RXD = 2'b00;
       CRS = 0;
       local_transmit_complete = 0;

       local_receive_data_valid = 0;

       tx_reg = 8'h00;
       transmit_clk = 0;

       collision_counter = 0;
       forced_col_counter = 0;
       collision_detect = 0;
       backoff_complete = 0;
       collision_limit_reached = 0;
       transmit_state = `INACTIVE;
       receive_state = `INACTIVE;
       `ext_transmit_state = transmit_state;
       `ext_receive_state = receive_state;       
       extended_TX_EN   = 0;

       paused = 0;          // clear paused flag 
       pause_parameter = 0;
       pause_timer_clk = 0;
       pause_timer_count = 0;
       // choose modulus of counter to generate pause timer clock
       PAUSE_COUNTER_MAX = 127;  // For Reduced MII
       first_IFG_cycle = 0;
       receive_packet_count = 0;
    end // initial begin
   
   // state transitions between inactive and idle
   always @(posedge port_tx_enable)
    if (transmit_state == `INACTIVE)
     begin
	transmit_state = `XMIT_IDLE;
	`ext_transmit_state = transmit_state;
     end // if (transmit_state == `INACTIVE)
   
   always @(negedge port_tx_enable)
    if (transmit_state == `XMIT_IDLE)
     begin
	transmit_state = `INACTIVE;
	`ext_transmit_state = transmit_state;
     end // if (transmit_state == `XMIT_IDLE)
   
   always @(posedge port_rx_enable)
    if (receive_state == `INACTIVE)
     begin
	receive_state = `RCV_IDLE;
	`ext_receive_state = receive_state;
     end // if (receive_state == `INACTIVE)
   always @(negedge port_rx_enable)
    begin
       if (receive_state == `RCV_IDLE)
	receive_state = `INACTIVE;
       `ext_receive_state = receive_state;
    end // always @ (negedge port_rx_enable)

   // export state of collision counter
   always @(collision_counter)
    if (!`force_collision)
     `ext_collision_counter = collision_counter;
   always @(forced_col_counter)
    if (`force_collision)
     `ext_collision_counter = forced_col_counter;

   /* configure transmit clock */
   always @(port_type)
    if (`SPEED_100Mb)
     CLK_DIVISOR = 1;   // Reduced MII, 100 Mb/s (use REFCLK)
    else
     CLK_DIVISOR = 10;  // Reduced MII, 10 Mb/s (divide by 10)

   /**********************Transmit Routines ******************************/

   /******* Transmit clock generator ********/
   always @(REFCLK)
    begin
       if (CLK_DIVISOR == 1)
	transmit_clk = REFCLK;
       else
	if (REFCLK == 0) // negative edge
	 begin
	    if (transmit_clk_count >= (CLK_DIVISOR/2 -1))
	     begin
		transmit_clk = ~transmit_clk;
		transmit_clk_count = 0;
	     end
	    else
	     transmit_clk_count = transmit_clk_count +1;
	 end // if (REFCLK == 0)
    end // always @ (REFCLK)
   /*****************************************/

   /* Log clock cycle time into event log */
   initial
    begin: log_clock_cycle_block
       integer clock_period, last_cycle;
       wait (port_tx_enable & port_rx_enable);
       @(posedge transmit_clk)
	last_cycle = $time;
       @(posedge transmit_clk)
	 clock_period = $time - last_cycle;
       $write("Clock period configured = %0d ns, data width = %0d\n",
	      clock_period, `RMII_WIDTH);
       $fwrite(event_file, "Clock period configured = %0d ns, data width = %0d\n",
	      clock_period, `RMII_WIDTH);
    end // block: log_clock_cycle_block
   
   /******* generate pause timer clk by dividing transmit clock by 512********/
   always @(negedge transmit_clk)
    begin
       if (pause_timer_count >= PAUSE_COUNTER_MAX)
	begin
	   pause_timer_clk = ~pause_timer_clk;
	   pause_timer_count = 0;
	end
       else
	pause_timer_count = pause_timer_count +1;
    end // always @ (negedge transmit_clk)
   /**********************************************************************/

   always @(posedge transmit_data_valid) // first transmission of a frame
    begin: transmit_block
       integer  ttime;

       if (port_tx_enable && `TESTBENCH.transmit_enable)
	begin
	   local_transmit_complete = 0;
	   collision_limit_reached = 0;
	   #1
	    // save packet data in register
	    transmit_pkt_reg = `TESTBENCH.transmit_pkt;
	   transmit_pkt_size_reg = `TESTBENCH.transmit_pkt_size;

	   if (!`FULL_DUPLEX_PORT) 
	    wait(`force_collision == 0);

	   if (!`FULL_DUPLEX_PORT) // wait for end of receive frame
	    wait(extended_TX_EN == 0); // wait for IFG after TX_EN goes down

	   if (`FULL_DUPLEX_PORT)
	    wait(paused == 0); // if in PAUSED state, wait for puse timer to expire

	   bytes_sent = 0;
	   
	   // Activate carrier sense
	   @(negedge transmit_clk);
	   CRS <= #1 1;
	   // insert seqno, timestamp and CRC
	   insert_seqno_timestamp_crc;

	   // copy packet back
	   `TESTBENCH.transmit_pkt = transmit_pkt_reg;
	   `TESTBENCH.transmit_pkt_size = transmit_pkt_size_reg;

	   // log packet
	   log_transmitted_packet;

	   transmit_state = `XMIT_BUSY;
	   `ext_transmit_state = transmit_state;
	   
	   if (`port_idle_count != 0)
	    begin
	       transmit_idle(`port_idle_count);
	    end // if (port_idle_count != 0)

	   // transmit preamble
	   if (`preamble_length != 0)
	    transmit_preamble(`preamble_reg, `preamble_length);

	   transmit_packet;

	   // Transmit extra bits if required to generate alignment error
	   if (`frame_extend_bit_count != 0)
	    begin
//	       @(posedge transmit_clk);
//	       if (`dribble_bit_count != 0) // Need to toggle CRS at each clock
//		CRS  <= #1 ~CRS;
	       transmit_frame_extend_bits(`frame_extend_reg, `frame_extend_bit_count);
	   	CRS  <= #1 0;
	   	RXD  <= #1 2'b00;
		
	    end // if (`frame_extend_bit_count != 0)
	   
	   // Turn off carrier sense 
	   @(negedge transmit_clk);
	   CRS  <= #1 0;
	   RXD  <= #1 2'b00;
	   ttime = $time;
	   $write("%t ns: Completed packet transmission to MAC\n",
		  $time);
	   $fwrite(event_file, "%t ns: Completed packet transmission to MAC\n",
		   $time);
	   if (port_tx_enable)
	    transmit_state = `XMIT_IDLE;
	   else
	    transmit_state = `INACTIVE;
	   `ext_transmit_state = transmit_state;
	   transmit_IFG(`TESTBENCH.port_min_ifg);
	   local_transmit_complete = 1;
	   collision_counter = 0;
	end // if (port_tx_enable)
    end // block: transmit_block

   always @(posedge backoff_complete) // retransmission of a frame
    if ((port_tx_enable) && (`TESTBENCH.transmit_enable))
    begin: retransmit_block
       integer  ttime;
       begin
	  if (collision_limit_reached)
	   begin
	      // discard frame
	      local_transmit_complete = 1;
	      if (port_tx_enable)
	       transmit_state = `XMIT_IDLE;
	      else
	       transmit_state = `INACTIVE;
	      `ext_transmit_state = transmit_state;
	      collision_counter = 0;
	   end
	  else
	   begin
	      local_transmit_complete = 0;
	      #1;
	      if (!`FULL_DUPLEX_PORT) 
	       wait(`force_collision == 0);
	      
	      if (!`FULL_DUPLEX_PORT) // wait for end of receive frame
	       wait(extended_TX_EN == 0); // wait for IFG after TX_EN goes down
	      
	      bytes_sent = 0;
	      
	      // Activate carrier sense
	      @(negedge transmit_clk);
	      CRS  <= #1  1;
	      
	      // insert seqno, timestamp and CRC
	      insert_seqno_timestamp_crc;

	      // copy packet back
	      `TESTBENCH.transmit_pkt = transmit_pkt_reg;
	      `TESTBENCH.transmit_pkt_size = transmit_pkt_size_reg;

	      // log packet
	      log_transmitted_packet;

	      transmit_state = `XMIT_BUSY;
	      `ext_transmit_state = transmit_state;
	  
	      if (`port_idle_count != 0)
	       transmit_idle(`port_idle_count);

	      // transmit preamble;
	      if (`preamble_length != 0)
	       transmit_preamble(`preamble_reg, `preamble_length);

	      transmit_packet;

	      // Transmit extra bits if required to generate alignment error
	      if (`frame_extend_bit_count != 0)
	       begin
//		  @(posedge transmit_clk);
//		  if (`dribble_bit_count != 0) // Need to toggle CRS at each clock
//		   CRS  <= #1 ~CRS;
		  transmit_frame_extend_bits(`frame_extend_reg, `frame_extend_bit_count);
	      	CRS <= #1  0;
	      	RXD <= #1 2'b00;

	       end // if (`frame_extend_bit_count != 0)
	   
	      // Turn off carrier sense 
	      @(negedge transmit_clk);
	      CRS <= #1  0;
	      RXD <= #1 2'b00;
	      ttime = $time;
	      $write("%t ns: Completed packet transmission to MAC\n",
		     $time);
	      $fwrite(event_file, "%0d ns: Completed packet transmission to MAC\n",
		      $time);

	      if (port_tx_enable)
	       transmit_state = `XMIT_IDLE;
	      else
	       transmit_state = `INACTIVE;
	      `ext_transmit_state = transmit_state;
	      transmit_IFG(`TESTBENCH.port_min_ifg);
	      local_transmit_complete = 1;
	      collision_counter = 0;
	   end // else: !if(collision_limit_reached)
       end
    end // block: retransmit_block
   
   // Pause timer
   always @(posedge pause_timer_clk)
    if (paused)
     begin
	if (pause_parameter != 0)
	 pause_parameter = pause_parameter -1;	 
	if (pause_parameter == 0)
	 begin
	    paused = 0;
	    if (`DEBUG_MII)
	     $write("%t ns: PAUSE completed\n", $time);
	 end // if (pause_parameter == 0)
	else
	 begin
	    if (`DEBUG_MII)
	     $write("%t ns: Pause timer = %0d\n", $time, pause_parameter);
	 end // else: !if(pause_parameter == 0)
     end // if (paused)

   task transmit_idle;
      input length;
      integer length; // in bits
      integer i;

      begin
	 for (i=0; i < length/`RMII_WIDTH; i = i+1)
	  begin
	     tx_reg = 0;
	     transmit(tx_reg, 1);
	  end // for (i=0; i < length/`RMII_WIDTH; i = i+1)
      end
   endtask // transmit_idle

   task transmit_preamble;
      input [127:0] pattern;
      input length;
      integer length; // in bits, including SFD
      integer i;
      begin
	 for (i=0; i < length; i = i+`RMII_WIDTH)
	  begin
	     tx_reg[0] = pattern[i];
	     tx_reg[1] = pattern[i+1];
	     transmit(tx_reg, 1);
	  end // for (i=0; i < length; i = i+1)
      end
   endtask // transmit_preamble	  
	
   task transmit_IFG;
      input length;
      integer length; // in bits
      integer i, cycles;

      begin
	 cycles = length/`RMII_WIDTH;
	 if (`SPEED_100Mb)
	 for (i=0; i < cycles; i = i+1)
	  begin
	     tx_reg = 0;
	     transmit(tx_reg, 1);
	  end // for (i=0; i < cycles; i = i+1)
      end
   endtask // transmit_IFG

   task transmit_packet;
 
      integer length, i;
      reg [`MAX_PKT_SIZE*8-1:0] packet;
      integer CRS_active_cycles;
      reg toggle_flag;
      
      begin
	 length = transmit_pkt_size_reg;
	 packet = transmit_pkt_reg;

	 // determine when Carrier Sense is to be deasserted
	 CRS_active_cycles = ((length *8 - `dribble_bit_count) + 2)/`RMII_WIDTH;
	 toggle_flag = 0;
	 for (i=0; i< length *4; i = i+1)
	  begin
	     tx_reg[1:0] = packet[1: 0];
	     packet[`MAX_PKT_SIZE*8-1:0] =
					  {2'b00, packet[`MAX_PKT_SIZE*8-1: 2]};
	     transmit(tx_reg, 1);
	     if ((i % 4) == 3)
	      bytes_sent = bytes_sent +1;

	     // Check if it is time to deactivate CRS
	     if ((`dribble_bit_count != 0) // If CRS is to be activated before
	                                // end of packet
		 )//&& (i < length*4 -1))  // do not modify CRS in last cycle
	                                // because calling routine will do it
	      begin
//		 @(posedge transmit_clk);
		 if (CRS_active_cycles != 0)
		  begin
		     CRS_active_cycles = CRS_active_cycles -1;
		     if (CRS_active_cycles == 0) // deactivate CRS
		      begin
			 CRS = 0;
			 toggle_flag = 1; // From now on, need to toggle CRS at every posedge
		      end // if (CRS_active_cycles == 0)
		  end // if (CRS_active_cycles != 0)
		 else // Toggle CRS at every clock edge
		  CRS = ~CRS;
	      end // if ((`dribble_bit_count != 0)...
	  end // for (i=0; i< length; i = i+1)    
      end
   endtask // transmit_packet
      
   task transmit_frame_extend_bits;  // transmit dribble bits after normal packet
                                // to generate an alignment error at the MAC
      
      input [31:0] pattern; // data
      input length; // length in bits
      integer length, i;
      begin
	 for (i=length; i >= 0; i = i-`RMII_WIDTH)
	  begin
	     tx_reg[1] = pattern[i-1];
	     tx_reg[0] = pattern[i-2];
	     transmit(tx_reg, 1);
	     // toggle CRS if we transmitted dribble bits
	     if ((`dribble_bit_count != 0)) 
//		 (i > `RMII_WIDTH))  // do not toggle in last cycle
	      begin
//		 @(posedge transmit_clk)
	       CRS <= #1 ~CRS;
	      end // if (dribble_bit_count != 0)
	  end // for (i=length; i > 0; i = i-`RMII_WIDTH)
      end
   endtask 

   task transmit;  // transmit routine 
      input [7:0] data; // transmit data
      input length;  // number of di-bits to transmit
      integer length, i;
      begin
	 for (i=0; i< length; i = i+1)
	  begin
	     @(negedge transmit_clk)
	      begin
		 RXD[1:0] = data[1:0];
		 data = data >> `RMII_WIDTH;
	      end 
	  end 
      end
   endtask // transmit
   
   task insert_seqno_timestamp_crc;
      // Inserts seqno, timestamp, and CRC in frame
      integer  ttime, i, j;
      integer position;
      reg [1:0] crc_option;
      reg [31:0] seqno, crc, good_crc;

      begin
	 if ((`TESTBENCH.seqno_enable) &&
	     (!`TESTBENCH.user_frame))
	  begin
	     // add sequence number to packet
	     if (`seq_number_offset < 0)
	      // insert sequence number at the end of frame before CRC
	      position = transmit_pkt_size_reg -4 + `seq_number_offset;
	     else
	      position = `seq_number_offset;
	     seqno = `TESTBENCH.packet_seq_no;

	     for (i=0; i<4; i=i+1)
	      for (j = 0; j < 8; j= j+1)
	       transmit_pkt_reg[(position+i)*8 + j] = seqno[(3-i)*8 + j];
	  end // if (`TESTBENCH.seqno_enable)
	 
	 if ((`TESTBENCH.timestamp_enable) &&
	     (!`TESTBENCH.user_frame))
	  begin
	     // add timestamp to packet
	     if (`timestamp_offset < 0)
	      // insert sequence number at the end of frame before CRC
	      position = transmit_pkt_size_reg -4 + `timestamp_offset;
	     else
	      position = `timestamp_offset;
	     ttime = $time;
	     
	     for (i=0; i<4; i=i+1)
	      for (j = 0; j < 8; j= j+1)
	       transmit_pkt_reg[(position+i)*8 + j] = ttime[(3-i)*8 + j];
	  end 

	 // Add CRC
	 good_crc = CRC32(transmit_pkt_reg, transmit_pkt_size_reg);	 
	 //if (!`TESTBENCH.user_frame)
	  crc_option = `TESTBENCH.flowrec_crc_option;
	// else
	 // crc_option = `TESTBENCH.user_crc_option;

	 case(crc_option)
	   0: // generate good CRC
	    begin
	       crc = good_crc;
	    end

	   1: // generate bad CRC
	    begin
	       crc = $random();
	       if (crc == good_crc)
		crc = crc ^ 32'h80000000;
	    end // case: 1

	   3: // Set CRC to user-defined value
	    begin
	       //if (!`TESTBENCH.user_frame)
		crc = `TESTBENCH.flowrec_user_crc;
	       //else
		//crc = `TESTBENCH.user_crc_value;
	    end // case: 3
	 endcase // case(`TESTBENCH.flowrec_crc_option)
	 
	 if (crc_option != 2'b10)
	  // insert CRC in frame
	  for (i= 0; i < 4; i=i+1)
	   for (j=0; j<8; j = j+1)
	    transmit_pkt_reg[(transmit_pkt_size_reg-4+i)*8 +j] =
		  crc[8*i +j];
      end
   endtask // insert_seqno_timestamp_crc
   
   task log_transmitted_packet;
      integer  ttime, i, j;
      reg [31:0] seq_no, timestamp;
      reg [47:0] mac_addr;
      integer position;
      reg [15:0] type_length_field;
      
      begin
	 ttime = $time;

	 // get type/length field
	 type_length_field[15:8] = transmit_pkt_reg[103:96];
	 type_length_field[7:0]  = transmit_pkt_reg[111:104];

	 // get sequence number and timestamp
	 if (`TESTBENCH.seqno_enable)
	  seq_no = `TESTBENCH.packet_seq_no;
	 else
	  seq_no = 0;
	 if (`TESTBENCH.timestamp_enable)
	  begin
	     // get timestamp from packet
	     timestamp = 0;
	     if (`timestamp_offset < 0)
	      position = transmit_pkt_size_reg -4 + `timestamp_offset;
	     else
	      position = `timestamp_offset;
	     for (i=0; i<4; i=i+1)
	      for (j = 0; j < 8; j= j+1)
	       timestamp[(3-i)*8 + j] = transmit_pkt_reg[(position+i)*8 + j];
	  end // if (`TESTBENCH.timestamp_enable)
	 
	 if (collision_counter == 0)
	  begin
	     $write("%0d ns: Starting packet transmission to MAC",
		 ttime);
	     $fwrite(event_file, "%0d ns: Starting packet transmission to MAC",
		     ttime);
	     
	  end // if (collision_counter == 0)
	 else
	  begin
	     $write("%0d ns: Retransmitting packet",
		    ttime);
	     $fwrite(event_file, "%0d ns: Retransmitting packet",
		     ttime);
	  end // else: !if(collision_counter == 0)

	 $write(", size = %0d", transmit_pkt_size_reg);
	 $fwrite(event_file, ", size = %0d", transmit_pkt_size_reg);

	 if (`TESTBENCH.seqno_enable && (!`TESTBENCH.user_frame))
	  begin
	     $write(", seq no = %0d", seq_no);
	     $fwrite(event_file, ", seq no = %0d", seq_no);
	  end // if (`TESTBENCH.seqno_enable)

	 if (`TESTBENCH.timestamp_enable && (!`TESTBENCH.user_frame))
	  begin
	     $write(", timestamp = %0d", timestamp);
	     $fwrite(event_file, ", timestamp = %0d", timestamp);
	  end // if (`TESTBENCH.timestamp_enable)
	 $write("\n");
	 $fwrite(event_file, "\n");

	 mac_addr = transmit_pkt_reg[95:48];
	 $write("SA = %h:%h:%h:%h:%h:%h, ",
		mac_addr[ 7: 0], mac_addr[15: 8], mac_addr[23:16],
		mac_addr[31:24], mac_addr[39:32], mac_addr[47:40]);

 	 $fwrite(event_file, "SA = %h:%h:%h:%h:%h:%h, ",
		 mac_addr[ 7: 0], mac_addr[15: 8], mac_addr[23:16],
		 mac_addr[31:24], mac_addr[39:32], mac_addr[47:40]);

	 mac_addr = transmit_pkt_reg[47:0];
	 $write("DA = %h:%h:%h:%h:%h:%h",
		mac_addr[ 7: 0], mac_addr[15: 8], mac_addr[23:16],
		mac_addr[31:24], mac_addr[39:32], mac_addr[47:40]);
	
	 $fwrite(event_file, "DA = %h:%h:%h:%h:%h:%h",
		 mac_addr[ 7: 0], mac_addr[15: 8], mac_addr[23:16],
		 mac_addr[31:24], mac_addr[39:32], mac_addr[47:40]);

	 if (type_length_field[15:0] == `DEFAULT_VLAN_TPID)
	  begin
	     $write(", VLAN TCI = %h%h", transmit_pkt_reg[119:112],
		    transmit_pkt_reg[127:120]);
	     $fwrite(event_file, ", VLAN TCI = %h%h", transmit_pkt_reg[119:112],
		     transmit_pkt_reg[127:120]);
	     // get length field
	     type_length_field[15:8] = transmit_pkt_reg[135:128];
	     type_length_field[7:0]  = transmit_pkt_reg[143:136];
	  end
	 $write(", type/length = %h", type_length_field[15:0]);
	 $fwrite(event_file, ", type/length = %h", type_length_field[15:0]);
	 $write("\n");
	 $fwrite(event_file, "\n");

	 if (`LOG_TRANSMITTED_FRAMES)
	  print_packet(event_file, transmit_pkt_reg, transmit_pkt_size_reg);
      end
   endtask // log_transmitted_packet
   
//**************************** RECEIVE ROUTINES *****************************//

   integer rcv_cycle_count, rcv_byte_count;
   reg     SFD_received; // flag to indicate SFD received
   
   reg [7:0] rcv_buffer;
   reg [`MAX_PKT_SIZE*8-1:0] 	receive_pkt_data;

   initial
    begin
       rcv_buffer = 0;
       SFD_received = 0;
       `ext_SFD_received = SFD_received;
       rcv_cycle_count = 0;
       rcv_byte_count = 0;
    end

   always @(posedge transmit_clk)
    if (port_rx_enable && TX_EN && (!SFD_received))
     begin: mii_rcv_block
	
	integer ttime;
	
	ttime = $time;
	if (receive_state != `RCV_BUSY) // first bit of preamble, calculate IFG
	 begin
	    if (`SPEED_100Mb)
	     last_IFG = (ttime - first_IFG_cycle)/10; // 10 ns per bit
	    else
	     last_IFG = (ttime - first_IFG_cycle)/100; // 100 ns per bit
	    $write("%0d ns: Preamble detected, last IFG = %0d bits\n",
		   ttime, last_IFG);
	    $fwrite(event_file, "%0d ns: Preamble detected, last IFG = %0d bits\n",
		    ttime, last_IFG);
	 end // if (receive_state == `IDLE)

	receive_state = `RCV_BUSY;
	`ext_receive_state = receive_state;       
	rcv_buffer = {TXD[1:0], rcv_buffer[7:2]};
	if ((rcv_buffer == `SFD) && (!collision_detect))
	 begin
	    #1 SFD_received = 1;
	    `ext_SFD_received = SFD_received;
	    ttime = $time;
	    $write("%0d ns: SFD received, last IFG = %0d bits\n",
		   ttime, last_IFG);
	    $fwrite(event_file, "%0d ns: SFD received, last IFG = %0d bits\n",
		   ttime, last_IFG);

	    // check and print IFG violations,
            // but do not check IFG for first packet
	    if ((last_IFG < `MIN_IFG) && (receive_packet_count != 0))
	     begin
		$write("IFG violation, received IFG = %0d bits, minimum IFG = %0d bits\n",
		       last_IFG, `MIN_IFG);
		$fwrite(event_file, "IFG violation, received IFG = %0d bits, minimum IFG = %0d bits\n",
			last_IFG, `MIN_IFG);
		if (`TERMINATE_ON_IFG_VIOLATION)
		 $finish;
	     end // if (last_IFG < `MIN_IFG)
	    rcv_cycle_count = 0;
	    rcv_byte_count = 0;
	    alignment_error = 0;
	 end // if ((rcv_buffer == `SFD) && (!collision_detect))
     end // block: mii_rcv_block

   always @(posedge transmit_clk)
    if (SFD_received)
     begin: SFD_rcv
            integer j;
	local_receive_data_valid = 0;
        rcv_buffer = {TXD[1:0], rcv_buffer[7:2]};
	
	rcv_cycle_count = rcv_cycle_count +1;
	if (TX_EN && (rcv_cycle_count % (8/`RMII_WIDTH) == 0))
	 begin
	    // check if we exceeded the buffer size
	    if (rcv_byte_count < `MAX_PKT_SIZE)
	     begin
		for (j=0; j< 8; j = j+1)
		 receive_pkt_data[(rcv_cycle_count*`RMII_WIDTH/8)*8 -1 -j]
		       = rcv_buffer[7-j];
	     end // if (rcv_byte_count < `MAX_PKT_SIZE)
	    rcv_byte_count = rcv_byte_count+1;
	 end // if (TX_EN && (rcv_cycle_count % (8/`RMII_WIDTH) == 0))
     end // if (SFD_received)
   
   always @(negedge TX_EN) 
    if (port_rx_enable && SFD_received && (!collision_detect)
	&& (!`force_collision))
     begin: receive_log_block
	
	receive_state = `RCV_IDLE;
	`ext_receive_state = receive_state;       
	// check for oversize frame
	if (rcv_byte_count > `MAX_PKT_SIZE)
	 begin
	    $write("%t ns: Maximum packet size exceeded while receiving from MAC, size = %0d bytes\n",
		   $time, rcv_byte_count);
	    $fwrite(event_file, "%t ns: Maximum packet size exceeded while receiving from MAC, size = %0d bytes\n",
		    $time, rcv_byte_count);
	    rcv_byte_count = `MAX_PKT_SIZE; // truncate packet to max size
	    if (`TERMINATE_ON_OVERSIZE_FRAME)
	     begin
		if (`LOG_RECEIVED_FRAMES || `LOG_FRAMES_WITH_ERRORS)
		 print_packet(event_file, receive_pkt_data, rcv_byte_count);
		$finish;
	     end // if (`TERMINATE_ON_OVERSIZE_FRAME)
	 end // if (rcv_byte_count > `MAX_PKT_SIZE)

	// Copy packet from buffer
	`TESTBENCH.receive_pkt = receive_pkt_data;
	`TESTBENCH.receive_pkt_size = rcv_byte_count;
	local_receive_data_valid = 1;
	`TESTBENCH.receive_data_available = 1;

	if (rcv_cycle_count % (8/`RMII_WIDTH) != 0)
	 // frame alignment error
	 alignment_error = 1;
	else
	 alignment_error = 0;
	// log message

	if (pause_frame(receive_pkt_data[511:0], rcv_byte_count)) // pause received
	 begin
	    pause_parameter = get_pause_time(receive_pkt_data[511:0]);
	    log_pause_frame;
	    if (!`ignore_rcv_pause) // respond to pause only if flag set
	     begin
		pause_parameter = pause_parameter + `pause_increment;
		      // add or subtract user-defined increment
		if (pause_parameter < 0)
		 pause_parameter = 0;
		paused = (pause_parameter != 0);
		if (paused)
		 begin
		    transmit_state = `XMIT_PAUSED;
		    `ext_transmit_state = transmit_state;
		 end // if (paused)
	     end // if (!ignore_rcv_pause)
	 end // if pause_frame(receive_pkt_data,
	else
	 log_received_packet;
	
	rcv_buffer = 0;
	SFD_received = 0;
	`ext_SFD_received = SFD_received;
	rcv_cycle_count = 0;
	rcv_byte_count = 0;
     end // block: receive_log_block

   // Keep track of the cycle in which IFG begins
   always @(negedge TX_EN) 
    if (port_rx_enable)
     begin: monitor_IFG
	@(posedge transmit_clk);
	first_IFG_cycle = $time;
     end // block: monitor_IFG
   
   task log_received_packet;

      integer  ttime, payload_start, i, j;
      reg [31:0] seq_no, timestamp;
      reg [47:0] mac_addr;
      reg [15:0] type_length_field;
      integer position, header_length;
      reg [31:0] computed_crc, received_crc;
      reg errored_packet;

      begin
	 ttime = $time;
	 errored_packet = 0;
	 header_length = 6*2 + 4 + 2; // size of L2 header with no tagging
	 
	 // get type/length field
	 type_length_field[15:8] = receive_pkt_data[103:96];
	 type_length_field[7:0]  = receive_pkt_data[111:104];

	 // get sequence number and timestamp
	 seq_no = 0;
	 timestamp = 0;

	 if (`TESTBENCH.seqno_enable)
	  begin
	     if (`seq_number_offset < 0)
	      // sequence number at the end of frame before CRC
	      position = rcv_byte_count -4 + `seq_number_offset;
	     else
	      position = `seq_number_offset;
	     if ((position >= 0) && (position +4 <= `MAX_PKT_SIZE))
	      for (i=0; i<4; i=i+1)
	       for (j = 0; j < 8; j= j+1)
		seq_no[(3-i)*8 + j] =  receive_pkt_data[(position+i)*8 + j];
	  end // if (`TESTBENCH.seqno_enable)
	 if (`TESTBENCH.timestamp_enable)
	  begin

	     // get timestamp from packet
	     timestamp = 0;
	     if (`timestamp_offset < 0)
	      // timestamp at the end of frame before CRC
	      position =rcv_byte_count -4 + `timestamp_offset;
	     else
	      position = `timestamp_offset;
	     if ((position >= 0) && (position +4 <= `MAX_PKT_SIZE))
	      for (i=0; i<4; i=i+1)
	       for (j = 0; j < 8; j= j+1)
		timestamp[(3-i)*8 + j] =  receive_pkt_data[(position+i)*8 + j];
	  end // if (`TESTBENCH.timestamp_enable)
	     
	 if (rcv_byte_count < `MIN_FRAME_SIZE) // under-size frame
	  begin
	     $write("%0d ns: Received undersize packet, ",
		    ttime);
	     $fwrite(event_file, "%0d ns: Received undersize packet, ",
		     ttime);
	     errored_packet = 1;
	  end // if (pkt_size < `MIN_FRAME_SIZE)
	 else
	  begin
	     $write("%0d ns: Received packet, ",
		    ttime);
	     $fwrite(event_file, "%0d ns: Received packet, ",
		     ttime);
	  end // else: !if(pkt_size < `MIN_FRAME_SIZE)

	 if (rcv_byte_count >= 8)
	  begin
	     computed_crc = CRC32(receive_pkt_data, rcv_byte_count);
	     for (i= 0; i < 4; i=i+1)
	      for (j=0; j<8; j = j+1)
	       received_crc[8*i +j] = receive_pkt_data[(rcv_byte_count-4+i)*8 +j];
	  end // if (rcv_byte_count >= 8)

	 $write("size = %0d", rcv_byte_count);
	 $fwrite(event_file, "size = %0d", rcv_byte_count);

	 if (!errored_packet) // do not print parameters
	  begin
	     if (`TESTBENCH.seqno_enable)
	      begin
		 $write(", seq no = %0d", seq_no);
		 $fwrite(event_file, ", seq no = %0d", seq_no);
	      end // if (`TESTBENCH.seqno_enable)
	     if (`TESTBENCH.timestamp_enable)
	      begin
		 $write(", timestamp = %0d", timestamp);
		 $fwrite(event_file, ", timestamp = %0d", timestamp);
	      end // if (`TESTBENCH.timestamp_enable)
	     $write("\n");
	     $fwrite(event_file, "\n");
	     
	     mac_addr = receive_pkt_data[95:48];
	     $write("SA = %h:%h:%h:%h:%h:%h, ",
		    mac_addr[ 7: 0], mac_addr[15: 8], mac_addr[23:16],
		    mac_addr[31:24], mac_addr[39:32], mac_addr[47:40]);
	     $fwrite(event_file, "SA = %h:%h:%h:%h:%h:%h, ",
		     mac_addr[ 7: 0], mac_addr[15: 8], mac_addr[23:16],
		     mac_addr[31:24], mac_addr[39:32], mac_addr[47:40]);
	 
	     mac_addr = receive_pkt_data[47:0];
	     $write("DA = %h:%h:%h:%h:%h:%h",
		    mac_addr[ 7: 0], mac_addr[15: 8], mac_addr[23:16],
		    mac_addr[31:24], mac_addr[39:32], mac_addr[47:40]);
	     $fwrite(event_file, "DA = %h:%h:%h:%h:%h:%h",
		     mac_addr[ 7: 0], mac_addr[15: 8], mac_addr[23:16],
		     mac_addr[31:24], mac_addr[39:32], mac_addr[47:40]);

	     if (type_length_field[15:0] == `DEFAULT_VLAN_TPID) // tagged frame
	      begin
		 $write(", VLAN TCI = %h%h", receive_pkt_data[119:112],
			receive_pkt_data[127:120]);
		 $fwrite(event_file, ", VLAN TCI = %h%h", receive_pkt_data[119:112],
			 receive_pkt_data[127:120]);
		 // get length field
		 type_length_field[15:8] = receive_pkt_data[135:128];
		 type_length_field[7:0]  = receive_pkt_data[143:136];
		 header_length = header_length +4;
	      end
	     $write(", type/length = %h", type_length_field[15:0]);
	     $fwrite(event_file, ", type/length = %h", type_length_field[15:0]);
	     $write("\n");
	     $fwrite(event_file, "\n");
	  end // if (!errored_packet)
	 else
	  begin // under-size frame
	     $write("\n");
	     $fwrite(event_file, "\n");
	     if (`TERMINATE_ON_UNDERSIZE_FRAME)
	      begin
		 if (`LOG_RECEIVED_FRAMES || `LOG_FRAMES_WITH_ERRORS)
		  print_packet(event_file, receive_pkt_data, rcv_byte_count);
		 $finish;
	      end // if (`TERMINATE_ON_UNDERSIZE_FRAME)
	  end // else: !if(!errored_

	 // check for errors
	 if (alignment_error)
	  begin
	     $write("Frame alignment error\n");
	     $fwrite(event_file, "Frame alignment error\n");
	     errored_packet = 1;
	     if (`TERMINATE_ON_ALIGNMENT_ERROR)
	      begin
		 if (`LOG_RECEIVED_FRAMES || `LOG_FRAMES_WITH_ERRORS)
		  print_packet(event_file, receive_pkt_data, rcv_byte_count);
		 $finish;
	      end // if (`TERMINATE_ON_ALIGNMENT_ERROR)
	  end // if (alignment_error)
	 
	 if (computed_crc != received_crc)
	  begin
	     $write("CRC error, computed CRC = %x, received CRC = %x\n",
		    computed_crc[31:0], received_crc[31:0]);
	     $fwrite(event_file, "CRC error, computed CRC = %x, received CRC = %x\n",
		     computed_crc[31:0], received_crc[31:0]);
	     errored_packet = 1;
	     if (`TERMINATE_ON_CRC_ERROR)
	      begin
		 if (`LOG_RECEIVED_FRAMES || `LOG_FRAMES_WITH_ERRORS)
		  print_packet(event_file, receive_pkt_data, rcv_byte_count);
		 $finish;
	      end // if (`TERMINATE_ON_CRC_ERROR)
	  end // if (computed_crc != received_crc)
	     
	 if (type_length_field[15:11] == 5'b00000) // 802.3 frame
	     // check for length error
	  begin
	     if ((rcv_byte_count-header_length) != {16'd0, type_length_field})
	      begin
		 $write("Length error, type/length field = %0d, expected value = %0d\n",
			type_length_field, rcv_byte_count-header_length);
		 $fwrite(event_file,
			 "Length error, type/length field = %0d, expected value = %0d\n",
			 type_length_field, rcv_byte_count-header_length);
		 errored_packet = 1;
	      end // if ((rcv_byte_count-header_length) != {16'd0, type_length_field})
	  end // if (type_length_field[15:11] == 5'b00000)
	 if (`LOG_RECEIVED_FRAMES)
	  print_packet(event_file, receive_pkt_data, rcv_byte_count);
	 else
	  if (`LOG_FRAMES_WITH_ERRORS && errored_packet)
	   print_packet(event_file, receive_pkt_data, rcv_byte_count);
      end
   endtask // log_received_packet

   task log_pause_frame;
      integer  ttime, i, j;
      reg [15:0] pause_time;
      reg [47:0] mac_addr;
      reg [31:0] computed_crc, received_crc;
      reg errored_packet;

      begin
	 ttime = $time;
	 errored_packet = 0;
	 
	 // compute CRC
	 computed_crc = CRC32(receive_pkt_data, rcv_byte_count);
	 for (i= 0; i < 4; i=i+1)
	  for (j=0; j<8; j = j+1)
	   received_crc[8*i +j] = receive_pkt_data[(rcv_byte_count-4+i)*8 +j];
	 $write("%0d ns: Received PAUSE frame, ",
		ttime);
	 $fwrite(event_file, "%0d ns: Received PAUSE frame, ",
		 ttime);
	 $write("size = %0d, ", rcv_byte_count);
	 $fwrite(event_file, "size = %0d, ", rcv_byte_count);

	 mac_addr = receive_pkt_data[95:48];
	 $write("SA = %h:%h:%h:%h:%h:%h, ",
		mac_addr[ 7: 0], mac_addr[15: 8], mac_addr[23:16],
		mac_addr[31:24], mac_addr[39:32], mac_addr[47:40]);
	 $fwrite(event_file, "SA = %h:%h:%h:%h:%h:%h, ",
		 mac_addr[ 7: 0], mac_addr[15: 8], mac_addr[23:16],
		 mac_addr[31:24], mac_addr[39:32], mac_addr[47:40]);
	 pause_time[15:8] = receive_pkt_data[135:128];
	 pause_time[ 7:0] = receive_pkt_data[143:136];
	 $write("pause time = %x\n", pause_time[15:0]);
	 $fwrite(event_file, "pause time = %x\n", pause_time[15:0]);
	 // check for errors
	 if (alignment_error)
	  begin
	     $write("Frame alignment error\n");
	     $fwrite(event_file, "Frame alignment error\n");
	     errored_packet = 1;
	  end // if (alignment_error)
	     
	 if (computed_crc != received_crc)
	  begin
	     $write("CRC error, computed CRC = %x, received CRC = %x\n",
		    computed_crc[31:0], received_crc[31:0]);
	     $fwrite(event_file, "CRC error, computed CRC = %x, received CRC = %x\n",
		     computed_crc[31:0], received_crc[31:0]);
	     errored_packet = 1;
	  end // if (computed_crc != received_crc)
	 if (`LOG_RECEIVED_FRAMES)
	  print_packet(event_file, receive_pkt_data, rcv_byte_count);
	 else
	  if (`LOG_FRAMES_WITH_ERRORS && errored_packet)
	   print_packet(event_file, receive_pkt_data, rcv_byte_count);
      end
   endtask // log_pause_frame
   
   /****************************************************************************/
   /*              Collision handling for half-duplex interface                */
   /****************************************************************************/

   always @ (TX_EN or CRS)
    if (port_tx_enable && `TESTBENCH.transmit_enable && (!`force_collision))
     begin : collision_detection
	   integer ttime;
       #0;
       if (CRS == 1 && TX_EN == 1 && (!`FULL_DUPLEX_PORT))
	begin
	   #(`collision_detection_delay * 10);
	   collision_detect = 1;
	   ttime = $time;
	   transmit_state = `COLLISION;
	   receive_state = `COLLISION;
	   `ext_transmit_state = transmit_state;
	   `ext_receive_state = receive_state;
	   
	   // check for out-of-window collision
	   if (bytes_sent > 64)
	    begin
	       $write("%0d ns: Out-of-window collision, collision counter = %0d\n",
		      ttime, collision_counter+1);
	       $fwrite(event_file,
		       "%0d ns: Out-of-window collision, collision counter = %0d\n",
		       ttime, collision_counter+1);
	    end // if (bytes_sent > 64)
	   else
	    begin
	       $write("%0d ns: Collision detected, collision counter = %0d\n",
		      ttime, collision_counter+1);
	       $fwrite(event_file,
		       "%0d ns: Collision detected, collision counter = %0d\n",
		       ttime, collision_counter+1);
	    end // else: !if(bytes_sent > 64)
	end // if (CRS==1 && TX_EN==1 && (!`FULL_DUPLEX_PORT))
    end // always @ (TX_EN or CRS_DV)

   always @ (posedge collision_detect)
    begin : collision_handling
       integer backoff_slots, backoff_interval;
       integer ttime, i, x;

       SFD_received = 0;
       `ext_SFD_received = SFD_received;
       backoff_complete = 0;
       if (`DEBUG_MII)
	$write("%t ns: waiting for transmit state = XMIT_DATA\n",
		      $time);

       disable transmit_block;
       disable retransmit_block;
       disable transmit_packet;
       disable transmit_frame_extend_bits;
       disable transmit;

       if (`DEBUG_MII)
	$write("%t ns: Sending jamming signal\n",
		      $time);
       transmit_jam_signal;
       if (port_tx_enable)
	transmit_state = `XMIT_IDLE;
       else
	transmit_state = `INACTIVE;
       `ext_transmit_state = transmit_state;
       CRS = 0;
       wait(TX_EN == 0);
       #1
	collision_detect = 0;
       
       // Do backoff 
       collision_counter = collision_counter +1;
       if ((collision_counter >= `MAX_COLLISIONS) ||
	   (collision_counter >= `TESTBENCH.collision_limit))
	begin
	   collision_limit_reached = 1;
	   ttime = $time;
	   $write("%0d ns: Aborting transmission to MAC due to excessive collisions, collision counter = %0d\n",
		  ttime, collision_counter);
	   $fwrite(event_file,
		   "%0d ns: Aborting transmission to MAC due to excessive collisions, collision counter = %0d\n",
		   ttime, collision_counter);
	   backoff_interval = 0;
	   collision_counter = 0;
	end // if ((collision_counter >= `MAX_COLLISIONS) ||...
       else
	begin
	   // compute backoff interval
	   if (collision_counter == 0)
	    backoff_interval = 0;
	   else
	    begin
	       backoff_slots = `TESTBENCH.backoff_slots[collision_counter];
	       backoff_interval = backoff_slots;  // deterministic backoff
	       if (`TESTBENCH.backoff_type[collision_counter]) // random backoff
		begin
		   x = $random();
		   backoff_interval = x[15:0] % backoff_slots;
		end // if (`TESTBENCH.backoff_type[index])
	    end // else: !if(collision_counter == 0)
	end // else: !if((collision_counter >= `MAX_COLLISIONS) ||...
       
       // wait for backoff interval
       if (backoff_interval > 0)
	begin
	   if (`DEBUG_MII)
	    $write("%t ns: Going into backoff, backoff interval = %0d slot(s)\n",
		   $time, backoff_interval);
	   if (`SPEED_100Mb) // 100 Mb port
	    #(backoff_interval * 100 * 512); // 512 bits * 10 ns
	   else
	    #(backoff_interval * 1000 * 512); // 512 bits * 100 ns
	   if (`DEBUG_MII)
	    $write("%t ns: Backoff complete\n", $time);
	end // if (backoff_interval > 0)

       backoff_complete = 1;
       transmit_state = `XMIT_IDLE;
       `ext_transmit_state = transmit_state;

    end // always @ (posedge collision_detect)

   // generate sense signal for half-duplex
   always @(TX_EN)
    if (port_tx_enable)
     begin
	#0;
	if (TX_EN == 1) // starting to receive frame
	 extended_TX_EN = 1;
	else            // end of reception
	 begin
	    if (`SPEED_100Mb) // 100 Mb port
	     #(`TESTBENCH.port_min_ifg * 100); // IFG * 10 ns/bit
	    else
	     #(`TESTBENCH.port_min_ifg * 1000); // IFG * 100 ns/bit
	    if (TX_EN == 0)
	     extended_TX_EN = 0;
	 end // else: !if(TX_EN == 1)
     end // always @ (TX_EN)
   
   // Force collisions with an incoming frame
   always @ (posedge transmit_clk)
    if (port_tx_enable && port_rx_enable && (!`FULL_DUPLEX_PORT) &&
	`force_collision && TX_EN && (!CRS))
     begin : force_collision_block
	integer ttime, temp;

	if (`DEBUG_MII)
	 $display("%t ns: Waiting to force collision, delay = %0d MII cycles",
		  $time, `force_collision_delay);

	// count down to the bit position of collision
	`force_collision_delay = `force_collision_delay - `RMII_WIDTH;
	temp = `force_collision_delay;
	if (temp <= 0)
	 // Force collision now
	 begin
	    #(`collision_detection_delay * 10);
	    CRS = 1;  // activate carrier sense
	    ttime = $time;
	    transmit_state = `COLLISION;
	    receive_state = `COLLISION;
	    `ext_transmit_state = transmit_state;
	    `ext_receive_state = receive_state;
	    forced_col_counter = forced_col_counter +1;
	    $write("%0d ns: Forcing collision, collision counter = %0d\n",
		   ttime, forced_col_counter);
	    $fwrite(event_file, "%0d ns: Forcing collision, collision counter = %0d\n",
		    ttime, forced_col_counter);
	    if (`DEBUG_MII)
	     $write("%t ns: Sending jamming signal\n",$time);
	    transmit_jam_signal;
	    if (port_tx_enable)
	     transmit_state = `XMIT_IDLE;
	    else
	     transmit_state = `INACTIVE;
	    `ext_transmit_state = transmit_state;
	    CRS = 0;
	    wait(TX_EN == 0);
	    SFD_received = 0;
	    `ext_SFD_received = SFD_received;

	    // Check if it is time to disable forced collisions
	    `forced_collision_count = `forced_collision_count -1;
	    if (`forced_collision_count == 0)
	     begin
		`force_collision = 0;
		forced_col_counter = 0;
	     end // if (`forced_collision_countn == 0)
	    else // reload position of forced collision
	     `force_collision_delay = `collision_offset;
	 end // if (force_collision_delay == 0)
     end // block: force_collision

   // reset pointer to position of collision at the end of each frame
   always @(negedge TX_EN)
    if (port_tx_enable && port_rx_enable && (!`FULL_DUPLEX_PORT) &&
	`force_collision)
     begin
	if (`DEBUG_MII)
	 $display("%t ns: End of forced collision, TX_EN sensed low", $time);
	`force_collision_delay = `collision_offset;
     end // if (port_tx_enable && port_rx_enable && (!`FULL_DUPLEX_PORT) &&...
	    
   task transmit_jam_signal; // transmit 32 bits of 0101... jamming pattern 
      integer i;
      begin
	 for (i=0; i < `jam_length/`RMII_WIDTH; i = i+1)
	  begin
	     tx_reg = 8'h55;
	     transmit(tx_reg, 1);
	  end 
      end
   endtask // transmit_jam_signal
   
   /****************************************************************************/
   /*                              Utility Routines                            */
   /****************************************************************************/
   
   task print_packet;
      input [31:0]                      event_file;
      input [`MAX_PKT_SIZE*8-1:0] 	pkt_data;
      input [15:0] 			pkt_size;
      integer i, j;
      reg [7:0] x;
      begin
	 $write("Contents:\n");
	 $fwrite(event_file, "Contents:\n");
	 for (i=0; i< pkt_size; i=i+1)
	  begin
	     for (j=0; j<8; j= j+1)
	      x[j] = pkt_data[i*8 +j];
	     $write("%x", x[7:0]);
	     $fwrite(event_file, "%x", x[7:0]);
	     if ((i == pkt_size-1) || (i[3:0] == 4'b1111))
	      begin
		 $write("\n");
		 $fwrite(event_file, "\n");
	      end // if ((i == pkt_size-1) || (i[3:0] == 4'b1111))
	     else
	      begin
		 $write(" ");
		 $fwrite(event_file, " ");
	      end // else: !if((i == pkt_size-1) || (i[3:0] == 4'b1111))
	  end // for (i=0; i< pkt_size; i=i+1)
	 $write("****\n");
	 $fwrite(event_file, "****\n");
      end
   endtask // print_packet

   function [31:0] CRC32; // compute CRC-32
      input [`MAX_PKT_SIZE*8-1:0] packet;
      input [15:0] 		  packet_size;

   parameter gen_degree = 32;           // Degree of generator polynomial
   integer   i, j, k;

   reg [gen_degree-1:0]         gen_polynomial;   // Generator polynomial
   reg [`MAX_PKT_SIZE*8-1:0]    operand;
   
   begin
      gen_polynomial = 32'b11101101101110001000001100100000;
      /* Generator polynomial = x**32 + x**26 + x**23 + x**22 +
       x**16 + x**12 + x**11 + x**10 + x**8 + x**7 + x**5 +
       x**4 + x**2 + x**1 + 1.
       Coefficient of x**32 omitted */
      
      for (i=0; i < packet_size*8; i= i+1)
       operand[i] = packet[i];
      
      // clear CRC area in packet
      for (i=(packet_size-4)*8; i < packet_size*8; i= i+1)
       operand[i] = 0;
      
      // Invert first 32 bits of operand before CRC computation
      operand[31:0] = ~operand[31:0];
      
      // Compute CRC
      for (i=0; i < (packet_size-4)*8; i = i+1)
       if (operand[i])
	for (j=0; j < 32; j= j+1)
	 operand[i+j+1] = operand[i+j+1] ^ gen_polynomial[j];
      
      // Copy CRC 
      for (i=0; i <= 24; i= i+8)
       for (j=0; j < 8; j = j+1)
	CRC32[i+j] = ~operand[(packet_size-4)*8+i+j];
   end
   endfunction // CRC32

   function pause_frame; // returns 1 if the input frame is a Pause frame
      input [511:0] pkt_data;
      input pkt_size;
      integer pkt_size;
      reg [47:0] 		 destination_mac_addr;
      reg [15:0] 		 frame_type;
      reg [15:0] 		 opcode;

      begin

	 if (pkt_size < 64)
	  pause_frame = 0;
	 else
	  begin
	     // get destination address, type, and opcode
	     destination_mac_addr[47:40] = pkt_data[7:0];
	     destination_mac_addr[39:32] = pkt_data[15:8];
	     destination_mac_addr[31:24] = pkt_data[23:16];
	     destination_mac_addr[23:16] = pkt_data[31:24];
	     destination_mac_addr[15:8]  = pkt_data[39:32];
	     destination_mac_addr[7:0]   = pkt_data[47:40];
	     
	     frame_type[15:8] = pkt_data[103:96];
	     frame_type[7:0]  = pkt_data[111:104];
	     
	     opcode[15:8] = pkt_data[119:112];
	     opcode[7:0]  = pkt_data[127:120];
	     
	     if ((destination_mac_addr == `PAUSE_DEST_MAC) &&
		 (frame_type == `PAUSE_TYPE) &&
		 (opcode == `PAUSE_OPCODE))
	      pause_frame = 1;
	     else
	      pause_frame = 0;
	  end // else: !if(packet_size < 64)
      end
   endfunction // pause_frame

   function [31:0] get_pause_time; // returns pause parameter from pause frame
      input [511:0] pkt_data;
      begin
	 get_pause_time[15:8] = pkt_data[135:128];
	 get_pause_time[ 7:0] = pkt_data[143:136];
         get_pause_time[31:16] = 16'd0;
			       
      end
   endfunction // get_pause_time
endmodule // tb_rmii






