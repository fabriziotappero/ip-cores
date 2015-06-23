

/*-----------------------------------------------------------------
|           Ethernet MAC Testbench                                  |
|                                                                   |
------------------------------------------------------------------*/

/*-----------------------------------------------------------------\
|  DESCRIPTION:                                                    |
|  tb_tasks.v:  Testbench tasks included in th_top.v               |
|                                                                  |
|  Instantiated modules: none                                      |
|  Included files: none                                            |
\-----------------------------------------------------------------*/

 /*-------------------------------------------------------------\
 |                                                              |
 |      Tasks to set port and MAC parameters such as            |
 |      preamble, collision parameters, etc.                    |
 |                                                              |
 \-------------------------------------------------------------*/

task init_port;
      input [2:0] speed;
   input [2:0] 	  MII_type;
   input duplex_status;
   input IFG_length;
   integer IFG_length;

   begin
      if ((port_mii_type != 3'b111) &&
	  (port_mii_type != MII_type))
       begin
	  $write("testbench_init_port:  MII type_new cannot be changed once set\n");
	  if (`TERMINATE_ON_TASK_ERRORS)
	   $finish;
       end // if ((port_mii_type != 3'b111) &&...
      else
       begin
	  port_mii_type = MII_type;
	  port_duplex_status = duplex_status;
	  port_speed = speed;
	  port_min_ifg = IFG_length;

	  // initialize port parameters to their default values
	  port_idle_count = 0; // number of idle bits transmitted before preamble
	  preamble_length = 64; // 64-bit preamble, including SFD
	  preamble_reg = {64'd0,
			  64'hd555_5555_5555_5555}; // preamble pattern

	  dribble_bit_count = 0; //bits buffered in PHY when carrier goes down
	  carrier_override = 0; // Do not force carrier
	  frame_extend_bit_count = 0; // Do not send additional bits after packet data
	  frame_extend_reg = 32'd0; // Pattern of additional bits
	  ignore_rcv_pause = 0; // handle received PAUSE frames normally
	  pause_increment = 0; // Do not change received PAUSE parameter
	  collision_detection_delay = 0;  // collision detection delay in PHY
	  force_collision = 0; // Do not force collisions
	  jam_length = 32; // length of jamming pattern in bits

	  force_collision_delay = 32'd0;
	  
	  packet_seq_no = 32'd0; // Running sequence number for port

	  // activate the proper MII interface
	  case (port_mii_type)
	    0: // Reduced MII
	     begin
		RMII_port_tx_enable = 1;
		RMII_port_rx_enable = 1;
	     end // case: 0
	    1: // Full MII
	     begin
		MII_port_tx_enable = 1;
		MII_port_rx_enable = 1;
	     end // case: 1
	    2: // Gigabit MII
	     begin
		GMII_port_tx_enable = 1;
		GMII_port_rx_enable = 1;
	     end // case: 2
	    3: // Serial MII
	     begin
		SMII_port_tx_enable = 1;
		SMII_port_rx_enable = 1;
	     end // case: 3
	    4: // custom interface
	     begin
		custom_tx_enable = 1;
		custom_rx_enable = 1;
	     end // case: 4
	    5: // Gigabit 10-bit SERDES interface
	     begin
		SERDES_tx_enable = 1;
		SERDES_rx_enable = 1;
	     end // case: 0
	    default:
	     begin
		$write("testbench_init_port: MII type_new %0d not supported",
		       port_mii_type);
		if (`TERMINATE_ON_PARAM_ERRORS)
		 $finish;
	     end // case: default
	  endcase // case(port_mii_type)
       end // else: !if((port_mii_type != 3'b111) &&...
   end
endtask // testbench_init_port

task set_idle_count;
   
   // Sets number if idle bits sent before preamble
   input bit_count;
   integer bit_count;
   begin
      port_idle_count = bit_count;
   end
endtask // set_idle_count

task set_preamble;
   
   // Sets preamble length and pattern
   input length;
   input [127:0] pattern;
   integer length;
   begin
      preamble_length = length;
      preamble_reg = pattern;
   end
endtask // set_preamble

task set_dribble_bit_count;
   // Sets number of bits buffered in the PHY when carrier sense is deasserted
   input count;
   integer count;
   begin
      dribble_bit_count = count;
   end
endtask // set_dribble_bit_count

task set_frame_extension_bits;
   // Sets count of bits added to the frame to generate alignment error
   input count;
   input [31:0] pattern;
   integer count;
   begin
      frame_extend_bit_count = count;
      frame_extend_reg = pattern;
   end
endtask // set_frame_extension_bits

task set_carrier_sense;
   input value;
   begin
      carrier_override = value;
   end
endtask // set_carrier_sense

task set_pause_options;
   // Set option for handling of received PAUSE frames
   input option, increment;
   integer option, increment;
   begin
      case(option)
	1: // add user-supplied increment to pause parameter received
	 begin
	    ignore_rcv_pause = 0;
	    pause_increment = increment;
	 end // case: 1
	2: // ignore received pause frames
	 begin
	    ignore_rcv_pause = 1;
	 end // case: 2
	default: // handle pause frames normally
	 begin
	    ignore_rcv_pause = 0;
	    pause_increment = 0;
	 end // case: 0
      endcase // case(option)
   end
endtask // set_pause_options

task set_collision_detect_delay;
   // Set delay between occurrence of collision and
   // processing by the testbench
   // value in nanoseconds
   input delay;
   integer delay;
   begin
      collision_detection_delay = delay;
   end
endtask // set_collision_detect_delay

task set_jam_length;
   // Set length of jamming pattern sent in response to collision event
   input length;
   integer length;
   begin
      jam_length = length;
   end
endtask // set_jam_length


task set_collision_backoff;
   // Set collision backoff in number of slots
   // collision_count
   // index = index of collision whose parameters are to be set
   // slots = number of slots to backoff
   // flag = 0: back off deterministically by constant number of slots
   //      = 1: back off by random number of slots between 0 and slots-1
   //      = 2: end backoff and reset collision counter
   input index, slots, flag;
   integer index, slots, flag;
   begin
      if ((index > 0) && (index <= `MAX_COLLISIONS)) // check validity of index
       begin
	  case(flag)
	    0: begin // deterministic backoff
	       backoff_slots[index] = slots;
	       backoff_type[index] = 0;
	    end // case: 0
	    1: begin // random backoff
	       backoff_slots[index] = slots;
	       backoff_type[index] = 1;
	    end // case: 1
	    default: begin // set collision limit
	       collision_limit = index;
	    end // case: default
	  endcase // case(flag)
       end // if ((index > 0) && (index <= `MAX_COLLISIONS))
      else
       if ((index == `MAX_COLLISIONS) && (flag >= 2)) // set collision limit
	collision_limit = index;
   end
endtask // set_collision_backoff

 /*-------------------------------------------------------------\
 |                                                              |
 |      Tasks to set flow parameters such as                    |
 |      packet size and header fields                           |
 |                                                              |
 \-------------------------------------------------------------*/

task set_flow_type;
// Sets flow type_new for the packet sequence to be generated
   input [7:0]  type_new;
   begin
      flow_type = type_new;
   end
endtask // set_flow_type

task set_L2_protocol;
   // sets L2 protocol at ingress
   input type_new;
   integer type_new;
   begin
      L2_protocol_type = type_new[7:0];
      L2_custom_header_enable = 0; // disable custom header
   end
endtask // testbench_set_L2_protocol

task set_L2_source_address;
   // sets source MAC address for transmitted frames
   input type_new;
   input [47:0] mac_min, mac_max, mac_incr;
   integer type_new;

   reg [31:0] x, y;
   reg [47:0] mac_random;
   
   begin
      L2_src_mac_min = mac_min;
      L2_src_mac_max = mac_max;
      L2_src_mac_incr = mac_incr;
      L2_src_mac_option = type_new[1:0];
      L2_custom_header_enable = 0; // disable custom header

      // set current MAC address for packet sequence
      case (L2_src_mac_option)
	0: // constant
	 current_src_mac = L2_src_mac_min;
	1: // incremental
	 if (L2_src_mac_incr[47] == 0)
	  current_src_mac = L2_src_mac_min;
	 else
	  current_src_mac = L2_src_mac_max;
	2: // random
	 begin
	    x = $random();
	    y = $random();
	    mac_random = {x[15:0], y[31:0]};
	    if (L2_src_mac_min != L2_src_mac_max)
	     current_src_mac = L2_src_mac_min +
				  (mac_random % (L2_src_mac_max -
						 L2_src_mac_min));
	    else
	     current_src_mac = L2_src_mac_min;
	 end // case: 2
      endcase // case(L2_src_mac_option)
   end
endtask // set_L2_source_address

task set_L2_destination_address;
   // sets destination MAC address for transmitted frames
   input type_new;
   input [47:0] mac_min, mac_max, mac_incr;
   integer type_new;

   reg [31:0] x, y;
   reg [47:0] mac_random;
   begin
      L2_dstn_mac_min = mac_min;
      L2_dstn_mac_max = mac_max;
      L2_dstn_mac_incr = mac_incr;
      L2_dstn_mac_option = type_new[1:0];
      L2_custom_header_enable = 0; // disable custom header

      // Set current destination MAC for packet sequence
      case (L2_dstn_mac_option)
	0: // constant
	 current_dstn_mac = L2_dstn_mac_min;
	1: // incremental
	 if (L2_dstn_mac_incr[47] == 0)
	  current_dstn_mac = L2_dstn_mac_min;
	 else
	  current_dstn_mac = L2_dstn_mac_max;
	2: // random
	 begin
	    x = $random();
            y = $random();
	    mac_random = {x[15:0], y[31:0]};
	    if (L2_dstn_mac_min != L2_dstn_mac_max)
	     current_dstn_mac = L2_dstn_mac_min +
				   (mac_random % (L2_dstn_mac_max -
						  L2_dstn_mac_min));
	    else
	     current_dstn_mac = L2_dstn_mac_min;
	 end // case: 2
      endcase // case(L2_dstn_mac_option)
   end
endtask // set_L2_destination_address

task set_L2_VLAN_TCI;
   // sets VLAN TCI of transmitted frames
   input type_new;
   input [15:0] min_TCI, max_TCI, increment;
   integer type_new;

   reg [31:0] x;
   begin
      L2_VLAN_TCI_min = min_TCI;
      L2_VLAN_TCI_max = max_TCI;
      L2_VLAN_TCI_incr = increment;
      L2_VLAN_TCI_option = type_new[1:0];
      L2_custom_header_enable = 0; // disable custom header

      // set current VLAN TCI for packet sequence
      case (L2_VLAN_TCI_option)
	0: // constant
	 current_VLAN_TCI = L2_VLAN_TCI_min;
	1: // incremental
	 if (L2_VLAN_TCI_incr[15] == 0)
	  current_VLAN_TCI = L2_VLAN_TCI_min;
	 else
	  current_VLAN_TCI = L2_VLAN_TCI_max;
	2: // random
	 begin
	    x = $random();
	    if (L2_VLAN_TCI_max != L2_VLAN_TCI_min)
	     current_VLAN_TCI = L2_VLAN_TCI_min +
				   (x % (L2_VLAN_TCI_max -
					 L2_VLAN_TCI_min));
	    else
	     current_VLAN_TCI = L2_VLAN_TCI_min;
	 end // case: 2
      endcase // case(L2_VLAN_TCI_option)
   end
endtask // set_L2_VLAN_TCI

task set_L2_VLAN_TPID;
   // sets VLAN TPID field
   input [15:0] TPID;
   begin
      L2_VLAN_TPID = TPID;
      L2_custom_header_enable = 0; // disable custom header
   end
endtask

task set_L2_frame_size;
   // sets size of transmitted frames
   input type_new, min_size, max_size, increment;
   integer type_new, min_size, max_size, increment;

   reg [31:0] x;
   begin
      L2_frame_size_option = type_new[1:0];
      L2_frame_size_min = min_size;
      L2_frame_size_max = max_size;
      L2_frame_size_incr = increment;

      // set current packet size parameter
      case (L2_frame_size_option)
	0: // constant
	 current_pkt_size = L2_frame_size_min;
	1: // incremental
	 if (increment >= 0)
	  current_pkt_size = L2_frame_size_min;
	 else
	  current_pkt_size = L2_frame_size_max;
	2: // $random
	 begin
	    x = $random();
	    if (L2_frame_size_max != L2_frame_size_min)
	     current_pkt_size = L2_frame_size_min +
				     (x % (L2_frame_size_max - L2_frame_size_min));
	    else
	     current_pkt_size = L2_frame_size_min;
	 end // case: 2
      endcase // case(L2_frame_size_option)
   end
endtask

task set_L2_type_field;
   // sets 16-bit type_new field for L2 Ethernet flows
   input [15:0] type_new;
   begin
      L2_type_field = type_new;
   end
endtask // testbench_set_L2_type_field

task set_LLC_header;
   // sets LLC and SNAP headers for transmitted frames
   // default is aa_aa_03_00_00_00_08_00 hex
   input header_length;
   input [`MAX_HEADER_SIZE*8-1: 0] header;
      integer header_length;
   begin
      L2_LLC_header = header;
      L2_LLC_header_length = header_length;
      L2_LLC_header_enable = 1;
   end
endtask // testbench_set_LLC_header

task set_L2_custom_header;
   // sets a user-defined L2 header
   input header_length;
   input [`MAX_HEADER_SIZE*8-1: 0] header;
   integer header_length;
   
   begin
      if (header_length == 0) //disable user-defined L2 header
       L2_custom_header_enable = 0;
      else
       begin
	  L2_custom_header_enable = 1;
	  L2_custom_header = header;
	  L2_custom_header_length = header_length;
       end // else: !if(header_length == 0)
   end
endtask // testbench_set_L2_custom_header

task set_L3_protocol;
   // sets L3 protocol
   input protocol;
   integer protocol;
   begin
      L3_protocol_type = protocol[7:0];
   end
endtask

task set_IP_header;
   // sets IP header fields
   input [31:0] src_addr, dstn_addr;
   input [7:0] service_type;
   input [15:0] sequence_number;
   input [2:0] flags;
   input [12:0] fragment_offset;
   input [7:0] ttl;
   input [7:0] protocol;
   begin
      L3_src_address = src_addr;
      L3_dstn_address = dstn_addr;
      L3_sequence_number = sequence_number;
      IP_flags = flags;
      IP_fragment_offset = fragment_offset;
      L3_TTL = ttl;
      IP_protocol_field = protocol;
      IP_service_type = service_type;
   end // else: !if((flow_id < 0) || (flow_id > NFLOWS))
endtask // testbench_set_L3_IP_header

task set_IP_extension_header;
   // sets IP extension header
   input header_length;
   input [`IP_EXTENSION_HEADER_SIZE*8-1: 0] header;
   integer header_length;
   begin
      IP_ext_header = header;
      IP_ext_header_length = header_length;
   end // else: !if((flow_id < 0) || (flow_id > NFLOWS))
endtask // set_IP_extension_header

task set_L3_custom_header;
   // sets a user-defined L2 header
   input header_length;
   input [`MAX_HEADER_SIZE*8-1: 0] header;
   integer header_length;
   begin
      if (header_length == 0) //disable user-defined LLC header
       L3_custom_header_enable = 0;
      else
       begin
	  L3_custom_header_enable = 1;
	  L3_custom_header = header;
	  L3_custom_header_length = header_length;
       end // else: !if(header_length == 0)
   end
endtask // set_L3_custom_header

task set_L4_protocol;
   // sets L4 protocol
   input protocol;
   integer protocol;
   begin
      L4_protocol_type = protocol[7:0];
   end
endtask

task set_TCP_port_numbers;
   // sets TCP header fields
   input src_port, dstn_port;
   integer src_port, dstn_port;
   begin
      L4_src_port = src_port;
      L4_dstn_port = dstn_port;
   end
endtask // set_TCP_header

task set_TCP_sequence_number;
   input sequence_number;
   integer sequence_number;
   begin
      L4_sequence_number = sequence_number;
   end
endtask // set_TCP_sequence_number

task set_TCP_header_fields;
   // sets other fields in TCP header
   input [31:0] ack_number;
   input [5:0] flags;
   input [15:0] urgent_pointer;
   input [15:0] window_size;
   begin
      L4_ack_number = ack_number;
      TCP_flags = flags;
      TCP_urgent_pointer = urgent_pointer;
      TCP_window_size = window_size;
   end
endtask

task set_UDP_port_numbers;
   // sets UDP header fields
   input src_port, dstn_port;
   integer src_port, dstn_port;
   begin
      L4_src_port = src_port;
      L4_dstn_port = dstn_port;
   end
endtask // 

task set_L4_custom_header;
   // sets a user-defined L4 header
   input header_length;
   input [`MAX_HEADER_SIZE*8-1: 0] header;
   integer header_length;
   begin
      if (header_length == 0) //disable user-defined LLC header
       L4_custom_header_enable = 0;
      else
       begin
	  L4_custom_header_enable = 1;
	  L4_custom_header = header;
	  L4_custom_header_length = header_length;
       end // else: !if(header_length == 0)
   end
endtask // testbench_set_L4_custom_header

task set_payload_data;
   // sets payload of transmitted packets from user-supplied buffer
   input length;
   input [`MAX_PKT_SIZE*8-1: 0] payload;
   integer length;
   begin
      user_payload = payload;
      payload_length = length;
      payload_option = 2'd3; // enable user_defined payload
   end
endtask // set_payload

task set_payload_type;
   input option, length, start;
   integer option, length, start;
   begin
      payload_option = option[1:0]; // defines random, increasing, or decreasing sequence
      payload_length = length;
      payload_start = start;
   end
endtask // set_payload_option

task set_crc_option;
   // Sets option for L2 CRC generation
   input option, value;
   integer option, value;
   begin
      flowrec_crc_option = option[1:0];
      flowrec_user_crc = value;
   end
endtask // set_crc_option

task set_user_crc_option;
   // Sets option for CRC generation for user-supplied frames,
   // including PAUSE frames
   input option, value;
   integer option, value;
   begin
      user_crc_option = option[1:0];
      user_crc_value = value;
   end
endtask // set_user_crc_option

task set_L3_checksum_option;
   // Sets option for L3 checksum generation
   input option;
   input [15:0]  value;
   integer option;
   begin
      L3_checksum_option = option;
      L3_user_checksum = value;
   end
endtask // set_L3_checksum_option

task set_L4_checksum_option;
   // Sets option for L4 checksum generation
   input option;
   input [15:0] value;
   integer option;
   begin
      L4_checksum_option = option;
      L4_user_checksum = value;
   end
endtask // set_L4_checksum_option

task enable_sequence_number;
   input flag, offset;
   integer offset;
   begin
      seqno_enable = flag;
      if (seqno_enable)
       seq_number_offset = offset;
   end
endtask // enable_sequence_number

task enable_timestamp;
   input flag, offset;
   integer offset;
   begin
      timestamp_enable = flag;
      if (timestamp_enable)
       timestamp_offset = offset;
   end
endtask // enable_timestamp

task set_default_header_parameters;
   begin
      // initialize default header parameters

      L2_custom_header_enable = 0; // do not use custom headers
      L3_custom_header_enable = 0;
      IP_ext_header_length = 0; // No IP extension header
      L4_custom_header_enable = 0;
      payload_option = 0; // generate payload as increasing sequence of byte_news

      L2_protocol_type = 2; // default = 802.3 with no VLAN tagging
      L2_src_mac_option = 2'b00;    // Fixed source MAC
      L2_src_mac_min = 48'h01_02_03_04_05_06; // source MAC address
      L2_dstn_mac_option = 2'b00;    // Fixed destination MAC
      if (flow_type == 1) // Layer-2 broadcast
       L2_dstn_mac_min = 48'hff_ff_ff_ff_ff_ff; // destination MAC address
      else
       L2_dstn_mac_min = 48'h06_05_04_03_02_01;
      L2_type_field = `DEFAULT_L2_TYPE;   // Default type_new field for Ethernet frames
      L2_VLAN_TCI_option = 2'b00; // Fixed VLAN tag
      L2_VLAN_TCI_min = 0;        // Null VLAN tag

      L2_VLAN_TPID = `DEFAULT_VLAN_TPID; // default 802.1Q TPID = 8100 hex
      
      L2_frame_size_option = 2'b00; // constant size frames
      L2_frame_size_min = 64;       // 64-byte_new frames
      flowrec_crc_option = 0;  // append good CRC
      
      // set current packet parameters
      current_pkt_size = L2_frame_size_min;
      current_src_mac = L2_src_mac_min;
      current_dstn_mac = L2_dstn_mac_min;
      current_VLAN_TCI = L2_VLAN_TCI_min;

      // Set default LLC header (for IP)
      L2_LLC_header_length = 8;  // 3-byte_new LLC + 5-byte_new SNAP
      L2_LLC_header = {192'd0, 64'haa_aa_03_00_00_00_08_00};

      // Set default L3 header parameters
      L3_protocol_type = 4;  // default = IP v4
      L3_checksum_option = 0; // transmit good checksum
      
      L3_src_address =  32'h80_00_00_01; // IP source address
      L3_dstn_address = 32'h81_00_00_01; // IP destination address
      L3_TTL = 1;                        // IP time-to-live field
      L3_sequence_number = 16'd0;
      IP_flags = 3'd0;
      IP_fragment_offset = 0;
      L3_TTL = 1;
      IP_protocol_field = 8'd0;
      IP_service_type = 8'd0;
      
      // Set default L4 header parameters
      L4_protocol_type = 0;  // default = TCP
      L4_src_port = 0;       // TCP source port
      L4_dstn_port = 0;      // TCP destination port
      L4_checksum_option = 0; // enable good L4 checksum
      L4_sequence_number = 0;
      L4_ack_number = 0;    // TCP sequence and ack numbers
      TCP_flags = 6'b000000; // Flags in TCP header;
      TCP_urgent_pointer = 0; // Urgent pointer in TCP header
      TCP_window_size = 0;   // TCP advertised window

      payload_length = `MAX_PKT_SIZE; // set default max payload size 
      payload_option = 2'b00; // payload = increasing sequence of byte_news
      payload_start = 0; // starting at 0
   end

endtask // set_default_header_parameters

task print_packet_parameters;
   // print current parameter settings to console and file 

   integer int1, int2, int3, int4, int5;
   integer i, j;
   reg [`MAX_HEADER_SIZE*8-1:0] header;
   reg [47:0] mac_addr1;
   reg [7:0] byte_new;

   begin
      int1 = flow_type;
      $write("flow type_new = %0d ", int1);
      $fwrite(outfile, "flow type_new = %0d ", int1);
      case (int1)
	0:
	 begin
	    $write("(L2 unicast)\n");
	    $fwrite(outfile, "(L2 unicast)\n");
	 end // case: 0
	1:
	 begin
	    $write("(L2 broadcast)\n");
	    $fwrite(outfile, "(L2 broadcast)\n");
	 end // case: 1
	2:
	 begin
	    $write("(L2 multicast)\n");
	    $fwrite(outfile, "(L2 multicast)\n");
	 end // case: 2
	3:
	 begin
	    $write("(L3 unicast)\n");
	    $fwrite(outfile, "(L3 unicast)\n");
	 end // case: 3
	4:
	 begin
	    $write("(L3 multicast)\n");
	    $fwrite(outfile, "(L3 multicast)\n");
	 end // case: 4
	5:
	 begin
	    $write("(L4 unicast)\n");
	    $fwrite(outfile, "(L4 unicast)\n");
	 end // case: 5
	6:
	 begin
	    $write("(L4 multicast)\n");
	    $fwrite(outfile, "(L4 multicast)\n");
	 end // case: 6
	default:
	 begin
	    $write("(unknown)\n");
	    $fwrite(outfile, "(unknown)\n");
	 end // case: default
      endcase // case(int1)
      
      if (!L2_custom_header_enable)
       begin
	  int1 = L2_protocol_type;
	  $write("L2 protocol = %0d ", int1);
	  $fwrite(outfile, "L2 protocol = %0d ", int1);
	  case (int1)
	    0:
	     begin
		$write("(untagged Ethernet)\n");
		$fwrite(outfile, "(untagged Ethernet)\n");
	     end // case: 0
	    1:
	     begin
		$write("(tagged Ethernet)\n");
		$fwrite(outfile, "(tagged Ethernet)\n");
	     end
	    2:
	     begin
		$write("(untagged 802.3)\n");
		$fwrite(outfile, "(untagged 802.3)\n");
	     end // case: 2
	    3:
	     begin
		$write("(tagged 802.3)\n");
		$fwrite(outfile, "(tagged 802.3)\n");
	     end // case: 3
	    4:
	     begin
		$write("(802.1d BPDU)\n");
		$fwrite(outfile, "(802.1d BPDU)\n");
	     end // case: 4
	    default:
	     begin
		$write("(unknown)\n");
		$fwrite(outfile, "(unknown)\n");
	     end // case: default
	  endcase // case(int1)
	  
	  int1 = L2_frame_size_option;
	  $write("L2 frame size option = %0d ", int1);
	  $fwrite(outfile, "L2 frame size option = %0d ", int1);
	  case (int1)
	    0:
	     begin
		int2 = L2_frame_size_min;
		$write("(constant), frame size = %0d\n", int2);
		$fwrite(outfile, "(constant), frame size = %0d\n", int2);
	     end // case: 0
	    1:
	     begin
		int2 = L2_frame_size_min;
		int3 = L2_frame_size_max;
		int4 = current_pkt_size;
		int5 = L2_frame_size_incr;
		$write("(incremental), current size = %0d, min = %0d, max = %0d, increment = %0d\n",
		       int4, int2, int3, int5);
		$fwrite(outfile,
			"(incremental), current size = %0d, min = %0d, max = %0d, increment = %0d\n",
			int4, int2, int3, int5);
	     end // case: 1
	    2:
	     begin
		int2 = L2_frame_size_min;
		int3 = L2_frame_size_max;
		$write("(random), min = %0d, max = %0d\n",
		       int2, int3);
		$fwrite(outfile, "(random), min = %0d, max = %0d\n",
			int2, int3);
	     end // case: 2
	    default:
	     begin
		$write("\n");
		$fwrite(outfile, "\n");
	     end // case: default
	  endcase // case(int1)
	  
	  // print source MAC
	  int1 = L2_src_mac_option;
	  $write("Source MAC option = %0d ", int1);
	  $fwrite(outfile, "Source MAC option = %0d ", int1);
	  case (int1)
	    0:
	     begin
		mac_addr1 = L2_src_mac_min;
		$write("(constant), MAC addr = ");
		$fwrite(outfile, "(constant), MAC addr = ");
		$write("%h:%h:%h:%h:%h:%h\n",
		       mac_addr1[47:40], mac_addr1[39:32], mac_addr1[31:24],
		       mac_addr1[23:16], mac_addr1[15: 8], mac_addr1[ 7: 0]);
		$fwrite(outfile, "%h:%h:%h:%h:%h:%h\n",
			mac_addr1[47:40], mac_addr1[39:32], mac_addr1[31:24],
			mac_addr1[23:16], mac_addr1[15: 8], mac_addr1[ 7: 0]);
	     end // case: 0
	    1:
	     begin
		$write("(incremental), current = ");
		$fwrite(outfile, "(incremental), current = ");
		mac_addr1 = current_src_mac;
		$write("%h:%h:%h:%h:%h:%h\n",
		       mac_addr1[47:40], mac_addr1[39:32], mac_addr1[31:24],
		       mac_addr1[23:16], mac_addr1[15: 8], mac_addr1[ 7: 0]);
		$fwrite(outfile, "%h:%h:%h:%h:%h:%h\n",
			mac_addr1[47:40], mac_addr1[39:32], mac_addr1[31:24],
			mac_addr1[23:16], mac_addr1[15: 8], mac_addr1[ 7: 0]);
		$write("min = ");
		$fwrite(outfile, "min = ");
		mac_addr1 = L2_src_mac_min;
		$write("%h:%h:%h:%h:%h:%h",
		       mac_addr1[47:40], mac_addr1[39:32], mac_addr1[31:24],
		       mac_addr1[23:16], mac_addr1[15: 8], mac_addr1[ 7: 0]);
		$fwrite(outfile, "%h:%h:%h:%h:%h:%h",
			mac_addr1[47:40], mac_addr1[39:32], mac_addr1[31:24],
			mac_addr1[23:16], mac_addr1[15: 8], mac_addr1[ 7: 0]);
		$write(", max = ");
		$fwrite(outfile, ", max = ");
		mac_addr1 = L2_src_mac_max;
		$write("%h:%h:%h:%h:%h:%h",
		       mac_addr1[47:40], mac_addr1[39:32], mac_addr1[31:24],
		       mac_addr1[23:16], mac_addr1[15: 8], mac_addr1[ 7: 0]);
		$fwrite(outfile, "%h:%h:%h:%h:%h:%h",
			mac_addr1[47:40], mac_addr1[39:32], mac_addr1[31:24],
			mac_addr1[23:16], mac_addr1[15: 8], mac_addr1[ 7: 0]);
		$write(", incr = ");
		$fwrite(outfile, ", incr = ");
		mac_addr1 = L2_src_mac_incr;
		$write("%h:%h:%h:%h:%h:%h\n",
		       mac_addr1[47:40], mac_addr1[39:32], mac_addr1[31:24],
		       mac_addr1[23:16], mac_addr1[15: 8], mac_addr1[ 7: 0]);
		$fwrite(outfile, "%h:%h:%h:%h:%h:%h\n",
			mac_addr1[47:40], mac_addr1[39:32], mac_addr1[31:24],
			mac_addr1[23:16], mac_addr1[15: 8], mac_addr1[ 7: 0]);
	     end // case: 1
	    2:
	     begin
		$write("(random), min = ");
		$fwrite(outfile, "(random), min = ");
		mac_addr1 = L2_src_mac_min;
		$write("%h:%h:%h:%h:%h:%h",
		       mac_addr1[47:40], mac_addr1[39:32], mac_addr1[31:24],
		       mac_addr1[23:16], mac_addr1[15: 8], mac_addr1[ 7: 0]);
		$fwrite(outfile, "%h:%h:%h:%h:%h:%h",
			mac_addr1[47:40], mac_addr1[39:32], mac_addr1[31:24],
			mac_addr1[23:16], mac_addr1[15: 8], mac_addr1[ 7: 0]);
		$write(", max = ");
		$fwrite(outfile, ", max = ");
		mac_addr1 = L2_src_mac_max;
		$write("%h:%h:%h:%h:%h:%h\n",
		       mac_addr1[47:40], mac_addr1[39:32], mac_addr1[31:24],
		       mac_addr1[23:16], mac_addr1[15: 8], mac_addr1[ 7: 0]);
		$fwrite(outfile, "%h:%h:%h:%h:%h:%h\n",
			mac_addr1[47:40], mac_addr1[39:32], mac_addr1[31:24],
			mac_addr1[23:16], mac_addr1[15: 8], mac_addr1[ 7: 0]);
	     end // case: 2
	    default:
	     begin
		$write("\n");
		$fwrite(outfile, "\n");
	     end // case: default
	  endcase // case(int1)
	  
	  // print destination MAC
	  int1 = L2_dstn_mac_option;
	  $write("Dest MAC option = %0d ", int1);
	  $fwrite(outfile, "Dest MAC option = %0d ", int1);
	  case (int1)
	    0:
	     begin
		mac_addr1 = L2_dstn_mac_min;
		$write("(constant), MAC addr = ");
		$fwrite(outfile, "(constant), MAC addr = ");
		$write("%h:%h:%h:%h:%h:%h\n",
		       mac_addr1[47:40], mac_addr1[39:32], mac_addr1[31:24],
		       mac_addr1[23:16], mac_addr1[15: 8], mac_addr1[ 7: 0]);
		$fwrite(outfile, "%h:%h:%h:%h:%h:%h\n",
			mac_addr1[47:40], mac_addr1[39:32], mac_addr1[31:24],
			mac_addr1[23:16], mac_addr1[15: 8], mac_addr1[ 7: 0]);
	     end // case: 0
	    1:
	     begin
		$write("(incremental), current = ");
		$fwrite(outfile, "(incremental), current = ");
		mac_addr1 = current_dstn_mac;
		$write("%h:%h:%h:%h:%h:%h\n",
		       mac_addr1[47:40], mac_addr1[39:32], mac_addr1[31:24],
		       mac_addr1[23:16], mac_addr1[15: 8], mac_addr1[ 7: 0]);
		$fwrite(outfile, "%h:%h:%h:%h:%h:%h\n",
			mac_addr1[47:40], mac_addr1[39:32], mac_addr1[31:24],
			mac_addr1[23:16], mac_addr1[15: 8], mac_addr1[ 7: 0]);
		$write("min = ");
		$fwrite(outfile, "min = ");
		mac_addr1 = L2_dstn_mac_min;
		$write("%h:%h:%h:%h:%h:%h",
		       mac_addr1[47:40], mac_addr1[39:32], mac_addr1[31:24],
		       mac_addr1[23:16], mac_addr1[15: 8], mac_addr1[ 7: 0]);
		$fwrite(outfile, "%h:%h:%h:%h:%h:%h",
			mac_addr1[47:40], mac_addr1[39:32], mac_addr1[31:24],
			mac_addr1[23:16], mac_addr1[15: 8], mac_addr1[ 7: 0]);
		$write(", max = ");
		$fwrite(outfile, ", max = ");
		mac_addr1 = L2_dstn_mac_max;
		$write("%h:%h:%h:%h:%h:%h",
		       mac_addr1[47:40], mac_addr1[39:32], mac_addr1[31:24],
		       mac_addr1[23:16], mac_addr1[15: 8], mac_addr1[ 7: 0]);
		$fwrite(outfile, "%h:%h:%h:%h:%h:%h",
			mac_addr1[47:40], mac_addr1[39:32], mac_addr1[31:24],
			mac_addr1[23:16], mac_addr1[15: 8], mac_addr1[ 7: 0]);
		$write(", incr = ");
		$fwrite(outfile, ", incr = ");
		mac_addr1 = L2_dstn_mac_incr;
		$write("%h:%h:%h:%h:%h:%h\n",
		       mac_addr1[47:40], mac_addr1[39:32], mac_addr1[31:24],
		       mac_addr1[23:16], mac_addr1[15: 8], mac_addr1[ 7: 0]);
		$fwrite(outfile, "%h:%h:%h:%h:%h:%h\n",
			mac_addr1[47:40], mac_addr1[39:32], mac_addr1[31:24],
			mac_addr1[23:16], mac_addr1[15: 8], mac_addr1[ 7: 0]);
	     end // case: 1
	    2:
	     begin
		$write("(random), min = ");
		$fwrite(outfile, "(random), min = ");
		mac_addr1 = L2_dstn_mac_min;
		$write("%h:%h:%h:%h:%h:%h",
		       mac_addr1[47:40], mac_addr1[39:32], mac_addr1[31:24],
		       mac_addr1[23:16], mac_addr1[15: 8], mac_addr1[ 7: 0]);
		$fwrite(outfile, "%h:%h:%h:%h:%h:%h",
			mac_addr1[47:40], mac_addr1[39:32], mac_addr1[31:24],
			mac_addr1[23:16], mac_addr1[15: 8], mac_addr1[ 7: 0]);
		$write(", max = ");
		$fwrite(outfile, ", max = ");
		mac_addr1 = L2_dstn_mac_max;
		$write("%h:%h:%h:%h:%h:%h\n",
		       mac_addr1[47:40], mac_addr1[39:32], mac_addr1[31:24],
		       mac_addr1[23:16], mac_addr1[15: 8], mac_addr1[ 7: 0]);
		$fwrite(outfile, "%h:%h:%h:%h:%h:%h\n",
			mac_addr1[47:40], mac_addr1[39:32], mac_addr1[31:24],
			mac_addr1[23:16], mac_addr1[15: 8], mac_addr1[ 7: 0]);
	     end // case: 2
	    default:
	     begin
		$write("\n");
		$fwrite(outfile, "\n");
	     end // case: default
	  endcase // case(int1)
	  
	  // print VLAN TCI
	  int1 = L2_protocol_type;
	  if ((int1 == 1) || (int1 == 3)) // tagged frames
	   begin
	      int1 = L2_VLAN_TCI_option;
	      $write("L2 VLAN TCI option = %0d ", int1);
	      $fwrite(outfile, "L2 VLAN TCI option = %0d ", int1);
	      case (int1)
		0:
		 begin
		    int2 = L2_VLAN_TCI_min;
		    $write("(constant), TCI = %h\n", int2[15:0]);
		    $fwrite(outfile, "(constant), TCI = %h\n", int2[15:0]);
		 end // case: 0
		1:
		 begin
		    int2 = L2_VLAN_TCI_min;
		    int3 = L2_VLAN_TCI_max;
		    int4 = current_VLAN_TCI;
		    int5 = L2_VLAN_TCI_incr;
		    $write("(incremental), current = %h, min = %h, max = %h, increment = %h\n",
			   int4[15:0], int2[15:0], int3[15:0], int5[15:0]);
		    $fwrite(outfile,
			    "(incremental), current = %h, min = %h, max = %h, increment = %h\n",
			    int4[15:0], int2[15:0], int3[15:0], int5[15:0]);
		 end // case: 1
		2:
		 begin
		    int2 = L2_VLAN_TCI_min;
		    int3 = L2_VLAN_TCI_max;
		    $write("(random), min = %h, max = %h\n",
			   int2[15:0], int3[15:0]);
		    $fwrite(outfile, "(random), min = %h, max = %h\n",
			    int2[15:0], int3[15:0]);
		 end // case: 2
		default:
		 begin
		    $write("\n");
		    $fwrite(outfile, "\n");
		 end // case: default
	      endcase // case(int1)
	   end // if ((int1 == 1) || (int1 == 3))
	  
	  // print type_new field
	  int1 = L2_protocol_type;
	  if ((int1 == 0) || (int1 == 1)) // Only for Ethernet frames
	   begin
	      int1 = L2_type_field;
	      $write("L2 type_new = %h\n", int1[15:0]);
	      $fwrite(outfile, "L2 type_new = %h\n", int1[15:0]);
	   end // if ((int1 == 0) || (int1 == 1))
	  
	  // print L2 LLC header
	  if ((L2_LLC_header_enable) &&
	      (L2_LLC_header_length != 0))
	   begin
	      $write("LLC header = ");
	      $fwrite(outfile, "LLC header = ");
	      header = L2_LLC_header;
	      for (i= L2_LLC_header_length-1; i >= 0;
		   i = i-1)
	       begin
		  for (j=0; j < 8; j= j+1)
		   byte_new[j] = header[i*8 +j];
		  $write("%h ", byte_new[7:0]);
		  $fwrite(outfile,"%h ", byte_new[7:0]);
	       end // for (i = L2_LLC_header_length;...
	      $write("\n");
	      $fwrite(outfile, "\n");
	   end // if ((L2_LLC_header_enable) &&...
       end // if (!L2_custom_header_enable)
      else
       // print L2 custom header
       if (L2_custom_header_length != 0)
	begin
	   $write("L2 custom header = ");
	   $fwrite(outfile, "L2 custom header = ");
	   header = L2_custom_header;
	   for (i = L2_custom_header_length -1;
		i >= 0; i = i-1)
	    begin
	       for (j=0; j < 8; j= j+1)
		byte_new[j] = header[i*8 +j];
	       $write("%h ", byte_new[7:0]);
	       $fwrite(outfile,"%h ", byte_new[7:0]);
	    end // for (i = L2_custom_header_length;...
	   $write("\n");
	   $fwrite(outfile, "\n");
	end // if (L2_custom_header_length != 0)
      
      // print IFG
      $write("Current IFG = %0d\n", current_ifg);
      $fwrite(outfile,
	      "Current IFG = %0d\n", current_ifg);
      
      // print CRC option
      $write("L2 CRC option = %0d ", flowrec_crc_option);
      $fwrite(outfile,
	      "L2 CRC option = %0d ", flowrec_crc_option);
      case (flowrec_crc_option)
	0:
	 begin
	    $write("(normal CRC)\n");
	    $fwrite(outfile, "(normal CRC)\n");
	 end // case: 0
	1:
	 begin
	    $write("(bad CRC)\n");
	    $fwrite(outfile, "(bad CRC)\n");
	 end // case: 1
	2:
	 begin
	    $write("(no CRC appended)\n");
	    $fwrite(outfile, "(no CRC appended)\n");
	 end // case: 2
	3:
	 begin
	    $write("(user-defined CRC), CRC = %h\n",
		   flowrec_user_crc);
	    $fwrite(outfile, "(user-defined CRC), CRC = %h\n",
		    flowrec_user_crc);
	 end // case: 3
      endcase // case(flowrec_crc_option)
      
      if (flow_type >= 3) // Layer-3/4 flow
       begin
	  // print L3 parameters
	  case(L3_protocol_type)
	    4: // IP v4
	     begin
		$write("L3 protocol = 4 (IPv4)\n");
		$fwrite(outfile, "L3 protocol = 4 (IPv4)\n");
		int1 = L3_src_address;
		int2 = L3_dstn_address;
		byte_new = L3_TTL;
		$write("IP src addr = %h.%h.%h.%h, ",
		       int1[31:24], int1[23:16], int1[15:8], int1[7:0]);
		$fwrite(outfile, "IP src addr = %h.%h.%h.%h, ",
			int1[31:24], int1[23:16], int1[15:8], int1[7:0]);
		$write("dstn addr = %h.%h.%h.%h, ",
		       int2[31:24], int2[23:16], int2[15:8], int2[7:0]);
		$fwrite(outfile, "dstn addr = %h.%h.%h.%h, ",
			int2[31:24], int2[23:16], int2[15:8], int2[7:0]);
		$write("TTL = %0d\n", byte_new);
		$fwrite(outfile, "TTL = %0d\n", byte_new);
		byte_new = IP_service_type;
		$write("IP service type_new = %h, ", byte_new);
		$fwrite(outfile, "IP service type_new = %h, ", byte_new);
		byte_new = IP_flags;
		int1 = IP_fragment_offset;
		int2 = IP_protocol_field;
		$write("flags = %b, frag offset = %0d, protocol = %h\n",
		       byte_new[2:0], int1[12:0], int2[7:0]);
		$fwrite(outfile,
			"flags = %b, frag offset = %0d, protocol = %h\n",
			byte_new[2:0], int1[12:0], int2[7:0]);
		if (IP_ext_header_length != 0)
		 begin
		    // print IP extension header
		    $write("IP extension header = ");
		    $fwrite(outfile, "IP extension header = ");
		    header = IP_ext_header;
		    for (i = IP_ext_header_length -1;
			 i >= 0; i = i-1)
		     begin
			for (j=0; j < 8; j= j+1)
			 byte_new[j] = header[i*8 +j];
			$write("%h ", byte_new[7:0]);
			$fwrite(outfile,"%h ", byte_new[7:0]);
		     end // for (i = IP_ext_header_length -1;...
		    $write("\n");
		    $fwrite(outfile, "\n");
		 end // if (IP_ext_header_length != 0)
	     end // case: 4
	  endcase // case(L3-Protocol_type)
	  if (L3_custom_header_enable)
	   begin
	      // print L3 custom header
	      $write("L3 custom header = ");
	      $fwrite(outfile, "L3 custom header = ");
	      header = L3_custom_header;
	      for (i = L3_custom_header_length -1;
		   i >= 0; i = i-1)
	       begin
		  for (j=0; j < 8; j= j+1)
		   byte_new[j] = header[i*8 +j];
		  $write("%h ", byte_new[7:0]);
		  $fwrite(outfile,"%h ", byte_new[7:0]);
	       end // for (i = L3_custom_header_length;...
	      $write("\n");
	      $fwrite(outfile, "\n");
	   end // if (L3_custom_header_enable)
	  
	  // print checksum option
	  $write("L3 checksum option = %0d ", L3_checksum_option);
	  $fwrite(outfile,
		  "L3 checksum option = %0d ", L3_checksum_option);
	  case (L3_checksum_option)
	    0:
	     begin
		$write("(normal checksum)\n");
		$fwrite(outfile, "(normal checksum)\n");
	     end // case: 0
	    1:
	     begin
		$write("(bad checksum)\n");
		$fwrite(outfile, "(bad checksum)\n");
	     end // case: 1
	    2:
	     begin
		$write("(zero checksum)\n");
		$fwrite(outfile, "(zero checksum)\n");
	     end // case: 2
	    3:
	     begin
		$write("(user-defined checksum), checksum = %h\n",
		       L3_user_checksum);
		$fwrite(outfile,
			"(user-defined checksum), checksum = %h\n",
			L3_user_checksum);
	     end // case: 3
	  endcase // case(L3_checksum_option)
       end // if (flow_type >= 3)
      
      if (flow_type >= 4) // Layer-4 flow
       begin
	  // print L4 parameters
	  case(L4_protocol_type)
	    0:
	     begin // TCP
		int1 = L4_src_port;
		int2 = L4_dstn_port;
		byte_new = TCP_flags;
		$write("TCP src port = %h, dstn port = %h, flags = %b\n",
		       int1[15:0], int2[15:0], byte_new[5:0]);
		$fwrite(outfile,
			"TCP src port = %h, dstn port = %h, flags = %b\n",
			int1[15:0], int2[15:0], byte_new[5:0]);
		int1 = L4_sequence_number;
		int2 = L4_ack_number;
		int3 = TCP_urgent_pointer;
		int4 = TCP_window_size;
		$write("TCP seq no = %0d, ack no = %0d, urgent ptr = %0d, window size = %0d\n",
		       int1, int2, int3[15:0], int4[15:0]);
		$fwrite(outfile,
			"TCP seq no = %0d, ack no = %0d, urgent ptr = %0d, window size = %0d\n",
			int1, int2, int3[15:0], int4[15:0]);
	     end // case: 0
	    1:
	     begin // UDP
		int1 = L4_src_port;
		int2 = L4_dstn_port;
		$write("UDP src port = %h, dstn port = %h\n",
		       int1[15:0], int2[15:0]);
		$fwrite(outfile, "UDP src port = %h, dstn port = %h\n",
			int1[15:0], int2[15:0]);
	     end // case: 1
	  endcase // case(L4_protocol_type)
	  
	  // print L4 checksum option
	  $write("L4 checksum option = %0d ", L4_checksum_option);
	  $fwrite(outfile,
		  "L4 checksum option = %0d ", L4_checksum_option);
	  case (L4_checksum_option)
	    0:
	     begin
		$write("(normal checksum)\n");
		$fwrite(outfile, "(normal checksum)\n");
	     end // case: 0
	    1:
	     begin
		$write("(bad checksum)\n");
		$fwrite(outfile, "(bad checksum)\n");
	     end // case: 1
	    2:
	     begin
		$write("(zero checksum)\n");
		$fwrite(outfile, "(zero checksum)\n");
	     end // case: 2
	    3:
	     begin
		$write("(user-defined checksum), checksum = %h\n",
		       L4_user_checksum);
		$fwrite(outfile,
			"(user-defined checksum), checksum = %h\n",
			L4_user_checksum);
	     end // case: 3
	  endcase // case(L4_checksum_option)
       end // if (flow_type >= 4)
      
      $write("----------------------------------\n");
      $fwrite(outfile, "----------------------------------\n");
   end
endtask 


/*-------------------------------------------------------------\
 |                                                              |
 |      Tasks for transmission and reception of packets         |
 |                                                              |
 \-------------------------------------------------------------*/

task transmit_packet_sequence;
   // transmits a sequence of packets with header parameters already set
   // npackets = number of packets in sequence
   // IFG = inter-frame-gap
   // blocking = 0 => task returns immediately, otherwise waits
   // until all packets have been transmitted
   // timeout: used in blocking mode to avoid indefinite wait
   // value in microseconds
   
      input npackets, IFG;
   input blocking;
   input timeout_value;
   integer npackets, IFG, timeout_value;
   
   
   integer port;
   integer x, y;
   reg [47:0] mac_random;
   
   begin
      if (port_tx_busy)
       begin
	  $write("%t: testbench_transmit_packet_sequence:  Port already transmitting, packets not sent\n",$time);
	  if (`TERMINATE_ON_TRANSMIT_ERRORS)
	   $finish;
       end // if (port_tx_busy)
      else
       begin
	  packets_sent = 0;
	  user_frame = 0;
	  transmit_packet_count = npackets;
	  if (IFG > port_min_ifg)
	   current_ifg = IFG;
	  else
	   current_ifg = port_min_ifg;
	  port_tx_busy = 1;

	  if (blocking)
	   begin
	      transmit_timer_expired = 0;
	      transmit_timer = timeout_value;
	      transmit_timer_active = 1;
	      wait((port_tx_busy == 0) ||
		   (transmit_timer_expired));
	      transmit_timer_active = 0;
	   end // if (blocking)
	  
       end // else: !if(port_busy)
   end
endtask // port_tx_busy

task update_header_parameters;
   integer x, y;
   reg [47:0] mac_random;

   begin
      // set packet size
      case (L2_frame_size_option)
	1: // incremental
	 begin
	    current_pkt_size =  current_pkt_size +
					    L2_frame_size_incr;
	    if (current_pkt_size > L2_frame_size_max)
	     current_pkt_size = L2_frame_size_max;
	    if (current_pkt_size < L2_frame_size_min)
	     current_pkt_size = L2_frame_size_min;
	 end // case: 1
	2: // random
	 begin
	    x = $random();
	    if (L2_frame_size_max != L2_frame_size_min)
	     current_pkt_size = L2_frame_size_min +
				     (x % (L2_frame_size_max - L2_frame_size_min));
	    else
	     current_pkt_size = L2_frame_size_min;
	 end // case: 2
      endcase // case(L2_frame_size_option)
      // Set source MAC
      case (L2_src_mac_option)
	1: // incremental
	 begin
	    current_src_mac = current_src_mac +
				       L2_src_mac_incr;

	    if (current_src_mac < L2_src_mac_min)
	     current_src_mac = L2_src_mac_min;
	    if (current_src_mac > L2_src_mac_max)
	     current_src_mac = L2_src_mac_max;
	 end
	2: // random
	 begin
	    x = $random();
            y = $random();
	    mac_random = {x[15:0], y[31:0]};
	    if (L2_src_mac_min != L2_src_mac_max)
	     current_src_mac = L2_src_mac_min +
				  (mac_random % (L2_src_mac_max -
						 L2_src_mac_min));
	    else
	     current_src_mac = L2_src_mac_min;
	 end // case: 2
      endcase // case(L2_src_mac_option)

	  // Set destination MAC
      case (L2_dstn_mac_option)
	1: // incremental
	 begin
	    current_dstn_mac = current_dstn_mac +
				       L2_dstn_mac_incr;

	    if (current_dstn_mac < L2_dstn_mac_min)
	     current_dstn_mac = L2_dstn_mac_min;
	    if (current_dstn_mac > L2_dstn_mac_max)
	     current_dstn_mac = L2_dstn_mac_max;
	 end
	2: // random
	 begin
	    x = $random();
            y = $random();
	    mac_random = {x[15:0], y[31:0]};
	    if (L2_dstn_mac_min != L2_dstn_mac_max)
	     current_dstn_mac = L2_dstn_mac_min +
				   (mac_random % (L2_dstn_mac_max -
						  L2_dstn_mac_min));
	    else
	     current_dstn_mac = L2_dstn_mac_min;
	 end // case: 2
      endcase // case(L2_dstn_mac_option)
   
	  
      // set VLAN TCI
      case (L2_VLAN_TCI_option)
	1: // incremental
	 begin
	    current_VLAN_TCI = current_VLAN_TCI +
					L2_VLAN_TCI_incr;
	    
	    if (current_VLAN_TCI > L2_VLAN_TCI_max)
	     current_VLAN_TCI = L2_VLAN_TCI_max;
	    if (current_VLAN_TCI < L2_VLAN_TCI_min)
	     current_VLAN_TCI = L2_VLAN_TCI_min;
	 end // case: 1
	
	2: // random
	 begin
	    x = $random();
	    if (L2_VLAN_TCI_max != L2_VLAN_TCI_min)
	     current_VLAN_TCI = L2_VLAN_TCI_min +
				   (x % (L2_VLAN_TCI_max -
					 L2_VLAN_TCI_min));
	    else
	     current_VLAN_TCI = L2_VLAN_TCI_min;
	 end // case: 2
      endcase // case(L2_VLAN_TCI_option)

   end 
endtask // update_header_parameters

task transmit_packet_from_buffer;
   
   // transmits a sequence of packets from the given buffer
   // npackets = number of packets in sequence
   // IFG = inter-frame-gap
   // blocking = 0 => task returns immediately, otherwise waits
   // until all packets have been transmitted
   // timeout: used in blocking mode to avoid indefinite wait
   // value in microseconds
   
    input npackets, IFG;
   input [`MAX_PKT_SIZE*8-1:0] packet_data;
   input size;
      input blocking;
      input timeout_value;
      integer npackets, IFG, timeout_value, size;

   begin
      if (port_tx_busy) // port currently transmitting
       begin
	  $write("%tns: testbench_transmit_packet_from_buffer:  Port already transmitting, packets not sent\n",
		 $time);
	  if (`TERMINATE_ON_TRANSMIT_ERRORS)
	   $finish;
       end // if (port_tx_busy)
      else
       begin
	  user_frame = 1;
	  transmit_packet_count = npackets;
	  packets_sent = 0;
	  if (IFG > port_min_ifg)
	   current_ifg = IFG;
	  else
	   current_ifg = port_min_ifg;
	  transmit_pkt = packet_data;
	  transmit_pkt_size = size;
	  port_tx_busy = 1;
	  
	  if (blocking)
	   begin
	      transmit_timer_expired = 0;
	      transmit_timer = timeout_value;
	      transmit_timer_active = 1;
	      wait((port_tx_busy == 0) ||
		   (transmit_timer_expired));
	      transmit_timer_active = 0;
	   end // if (blocking)
       end // else: !if(port_busy)
   end
endtask // transmit_packet_from_buffer

task transmit_pause_frame;
   // Transmit a pause frame to the Device under Test
   // blocking = 0 => task returns immediately, otherwise waits
   // until frame has been transmitted
   // timeout: used in blocking mode to avoid indefinite wait
   // value in microseconds
   
   input [47:0] src_mac; // source MAC address
   input [15:0] pause_time;
   input blocking, timeout_value;
   integer timeout_value;

   reg [`MAX_PKT_SIZE*8-1:0] packet_data;
   integer size;
   begin
      if (port_tx_busy)
       begin
	  $write("testbench_transmit_pause_frame:  Port already transmitting, packets not sent\n");
	  if (`TERMINATE_ON_TRANSMIT_ERRORS)
	   $finish;
       end // if (port_tx_busy)
      else
       begin
	  user_frame = 1;
	  transmit_packet_count = 1;
	  packets_sent = 0;
	  user_frame_current_ifg = port_min_ifg;
	  construct_pause_frame(src_mac, pause_time, packet_data, size);
	  transmit_pkt = packet_data;
	  transmit_pkt_size = size;
	  port_tx_busy = 1;
		  
	  if (blocking)
	   begin
	      transmit_timer_expired = 0;
	      transmit_timer = timeout_value;
	      transmit_timer_active = 1;
	      wait((port_tx_busy == 0) ||
		   (transmit_timer_expired));
	      transmit_timer_active = 0;
	   end // if (blocking)
       end // else: !if(port_tx_busy[port])
   end
endtask // testbench_transmit_pause_frame


task read_transmit_buffer;
   // returns last packet transmitted
   // must be called when the transmitter in state
   // `TRANSMIT_FRAME to get correct CRC
   output [`MAX_PKT_SIZE*8-1:0] buffer;
   output size;
   integer size;
   begin
      buffer = transmit_pkt;
      size = transmit_pkt_size;
   end
endtask // read_transmit_buffer

task receive_packet;
   output [`MAX_PKT_SIZE*8-1:0] buffer;
   output size;
   integer size;
   begin
      wait (receive_data_available);
      buffer = receive_pkt;
      size = receive_pkt_size;
      receive_data_available = 0;
   end
endtask // receive_packet   


 /*-------------------------------------------------------------\
 |                                                              |
 |      Tasks for event and status reporting                    |
 |                                                              |
 \-------------------------------------------------------------*/


task get_transmit_state;
   output state;
   integer state;
   // monitors state of transmit port
   begin
      if (mii_transmit_state == 2)
       state = 1; // curently transmitting a frame
      else
       if (mii_transmit_state == 3)
	state = 2; // curently resolving a collision
       else
	if (port_tx_busy == 1)
	 state = 3; // in the middle of a packet sequence
	else
	 state = 0; // idle
   end
endtask // get_transmit_state


task get_receive_state;
   output state;
   integer state;
   // monitors state of receive port
   begin
      if (mii_receive_state == 2)
       state = 1; // curently receiving a frame
      else
       if (mii_receive_state == 3)
	state = 2; // curently resolving a collision
       else
	state = 0; // idle
   end
endtask // get_receive_state

task wait_for_event;
   // waits for designated event
   input event_type, value;
   integer event_type, value;
   begin
      case(event_type)
	1: begin // wait until transmission of current frame starts
	   wait(mii_transmit_state == 2);
	end // case: 1

	2: begin // wait until transmission of current packet sequence ends
	   wait (port_tx_busy == 0);
	end 

	3: begin // wait until transmission of current frame ends
	   @(posedge transmit_done);
	end 
	
	4: begin // wait for arrival of first bit of next frame
	   @(posedge mii_SFD_received);
	end 
	5: begin // wait until last bit of current frame is received
	   @(posedge receive_data_valid);
	end 

	6: begin // wait until a collision is detected at the port
	   wait(mii_transmit_state == 3);
	end 

	7: begin // wait until collision detected and collision counter = value
	   wait ((mii_transmit_state == 3) &&
		 (mii_collision_counter == value));
	end 
	default: begin
	   $display("%t ns: testbench_wait-for_event: Invalid event type_new",$time);
	   if (`TERMINATE_ON_PARAM_ERRORS)
	    $finish;
	end // case: default
      endcase // case(event_type)
   end
endtask // testbench_wait_for_event

