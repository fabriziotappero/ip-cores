
/*-----------------------------------------------------------------\
|  DESCRIPTION:                                                    |
|  tb_objs.v:  Definitions of global variables and data structures |
|                                                                  |
|  Instantiated modules: none                                      |
|  Included files: none                                            |
\-----------------------------------------------------------------*/


/******************** Port parameters ***************************/
reg  [2:0]            port_mii_type;      // 0 = reduced MII, 
                                          // 1 = full MII
                                          // 2 = Gigabit MII
                                          // 3 = Serial MII
reg                   port_duplex_status; // 0 = half-duplex, 1 = full
reg  [2:0]            port_speed;         // 0 = 10 Mb/s,  1 = 100 Mb/s
                                          // 2 = 1000 Mb/s

   // Enable flags for ports, set only for active ports
reg                   MII_port_tx_enable,
		      MII_port_rx_enable,
		      RMII_port_tx_enable,
		      RMII_port_rx_enable,
		      GMII_port_tx_enable,
		      GMII_port_rx_enable,
		      SMII_port_tx_enable,
		      SMII_port_rx_enable,
		      SERDES_tx_enable,
		      SERDES_rx_enable,
		      custom_tx_enable,
		      custom_rx_enable;

integer               port_min_ifg;       // Minimum inter-frame gap in bits
integer               current_ifg;        // Current inter-frame gap for packet sequence
integer               port_idle_count;    // Number of idle bits transmitted
                                          // before preamble, must be a multiple
                                          // of the MII data width
                                          // Default value = 0

integer               preamble_length;    // Length of preamble in bits
                                          // Includes Start-of-Frame Delimiter (SFD)
                                          // Range: 0 to 128, default = 64 bits
reg [127:0]           preamble_reg;       // Preamble pattern, upto 128 bits long
                                          // Includes SFD
                                          // Default = 55_55_55_55_55_55_55_57 hex

integer               dribble_bit_count;  // number of bits buffered in the PHY
                                          // when carrier sense is deasserted.
                                          // Must be a multiple of 4 for MII and RMII;
                                          // and a multiple of 8 for GMII and SMII
                                          // Default value = 0
reg                   carrier_override;   // Turns on carrier sense when set.
                                          // Useful for testing carrier-based flow control
                                          // Flag overrides normal carrier-sense signal

integer               frame_extend_bit_count;
                                          // number of extra bits sent at the end of frame
                                          // to generate an alignment error
                                          // Must be a multiple of the particular MII width
reg [31:0]            frame_extend_reg;   // The pattern of bits appended

// The following variables define the MAC behavior when a PAUSE frame
// is received
reg                   ignore_rcv_pause;   // When set, the MAC does not respond
                                          // to received PAUSE frames
                                          // Default = 0
integer               pause_increment;    // This value is added to the received
                                          // pause parameter in the PAUSE FRAME
                                          // Can be set to negative value to
                                          // model aggressive MAC behavior

integer               collision_detection_delay;
                                          // Delay between the actual collision event
                                          // and the testbench sending the jam pattern
                                          //(in nanoseconds)
                                          // This parameter models the PHY delay
                                          // Default = 0
reg                   force_collision;    // when set, testbench forces a collision
                                          // with the next incoming frame
                                          // and transmits the jamming pattern
integer               collision_offset;   // Delay in clock cycles from 
                                          // TX_EN active to the forced collision
integer               forced_collision_count;   // Number of collisions
                                                // to be forced
reg [31:0]            force_collision_delay;
                                          // variable stores position at which
                                          // collision is to be forced

integer               jam_length;         // Length of jamming pattern in bits
                                          // Default = 32 bits of 0101..01 pattern

// Collision backoff parameters
reg [31:0]            backoff_slots[`MAX_COLLISIONS: 1];
                                          // Number of slots to back off
                                          // on i-th collision
reg [`MAX_COLLISIONS: 1]  backoff_type;   // 0 = deterministic backoff
                                          // 1 = random backoff
integer               collision_limit;    // Max collisions allowed

/*************************************************************/

/**** Flow-level parameters used for packet generation****/
reg     [7:0]         flow_type;                // flow type
// Valid flow types are
// 0 = Layer-2 unicast, 1 = Layer-2 broadcast, 2 = Layer-2 multicast
// 3 = Layer-3 unicast, 4 = Layer-3 multicast
// 5 = Layer-4 unicast, 6 = Layer-4 multicast

integer               L2_protocol_type; // L2 protocol type
// Valid Layer-2 protocols
// 0 = Ethernet without VLAN tagging
// 1 = Ethernet with IEEE 802.1Q tagging
// 2 = IEEE 802.3 frames without VLAN tagging
// 3 = IEEE 802.3 frames with 802.1Q tagging
// 4 = IEEE 802.1d Bridge Protocol Data Units

//Layer-2 Header Parameters

reg     [47:0]        L2_src_mac_min,    //source MAC addr at transmission
		      L2_src_mac_max,    //Max for incremental pattern
		      L2_src_mac_incr;   //increment

reg     [1:0]         L2_src_mac_option; //Option for MAC addr generation
// 0 = constant MAC addr, 1 = incremental pattern, 2 = random between min and max

reg     [47:0]        L2_dstn_mac_min,  // destination MAC addr
		      L2_dstn_mac_max,   // at transmission
		      L2_dstn_mac_incr;  // increment for pattern

reg     [1:0]         L2_dstn_mac_option;
                    //Option for MAC addr generation
                    // 0 = constant MAC addr, 1 = incremental pattern,
                    // 2 = random between min and max
		      
reg     [15:0]        L2_type_field;     // Type field for Ethernet
// This type field is used only when the flow type is L2.
// For L3 and L4 flows, the type field is automatically set
// based on the L3 protocol used.

reg     [15:0]        L2_VLAN_TCI_min,   // VLAN Tag Control Information 
		      L2_VLAN_TCI_max,   // at transmission
		      L2_VLAN_TCI_incr;  // increment
reg     [1:0]         L2_VLAN_TCI_option;
                  //Option for VLAN TCI generation
                  // 0 = constant, 1 = incremental pattern,
                  // 2 = random between min and max

reg     [15:0]        L2_VLAN_TPID;       // VLAN TPID field for IEEE 802.1Q
                                         // default = 8100 hex

reg     [31:0]        L2_frame_size_min, // Min packet size
		      L2_frame_size_max, // Max packet size
		      L2_frame_size_incr;// packet size increment
reg     [1:0]         L2_frame_size_option;
                  //Option for packet size
                  // 0 = constant, 1 = incremental size
                  // 2 = random between min and max

reg [`MAX_HEADER_SIZE*8-1:0] L2_LLC_header;  // user-defined LLC header
integer               L2_LLC_header_length;  // length of LLC header
reg                   L2_LLC_header_enable;  // enable custom LLC header

reg [`MAX_HEADER_SIZE*8-1:0] L2_custom_header;// user_defined L2 header
integer                      L2_custom_header_length;// length of
                                                     //  user_defined L2 header
reg                          L2_custom_header_enable;// enable user-defined
                                                     // L2 header

reg [1:0]             flowrec_crc_option;    // options for CRC generation
// 0 = Generate and append good CRC
// 1 = Append bad CRC
// 2 = Do not append CRC
// 3 = Append user-defined CRC
reg [31:0]            flowrec_user_crc;      // user-defined CRC

reg [7:0]             L3_protocol_type;    // Layer-3 protocol
// Valid Layer-3 protocols
// 1 = IGMP Version 1
// 2 = IGMP Version 2
// 4 = IP Version 4
// 6 = IP Version 6 (not supported yet)
// 7 = ICMP on IP Version 4
// 8 = TCP/IP ARP
// 9 = IPX (not supported yet)

// Layer-3 Header Parameters

reg  [31:0]           L3_src_address,    // IP source address
	              L3_dstn_address;   // IP destination address
reg  [7:0]            L3_TTL;            // time to live
reg  [15:0]           L3_sequence_number;      // IP sequence number field
// other IP header fields
reg  [7:0]         IP_service_type; 
reg  [2:0]         IP_flags;
reg  [12:0]        IP_fragment_offset;
reg  [7:0]         IP_protocol_field;

reg [`IP_EXTENSION_HEADER_SIZE*8-1:0] IP_ext_header;
                                          // IP extension header
reg  [31:0]        IP_ext_header_length;  // length of
                                          //   IP extension header

reg [`MAX_HEADER_SIZE*8-1:0] L3_custom_header; // user_defined L3 header 
integer               L3_custom_header_length; // length of
                                               //  user_defined L3 header
reg                   L3_custom_header_enable; // enable user-defined
                                               // L3 header
reg  [1:0]            L3_checksum_option; // options for L3 checksum
// 0 = Generate good checksum
// 1 = Generate bad checksum
// 2 = Set checkum to zero
// 3 = Set checksum to user-defined value
reg  [15:0]           L3_user_checksum;   // user-defined L3 checksum



reg  [7:0]            L4_protocol_type; // Layer-4 protocol
// Valid Layer-4 protocols
// 0 = TCP
// 1 = UDP

reg    [15:0]         L4_src_port,      // TCP or UDP port numbers
		      L4_dstn_port;

reg    [31:0]         L4_sequence_number,
		      L4_ack_number;          // TCP sequence and ack numbers
reg    [5:0]          TCP_flags;               // flags in the TCP header (6 bits)
reg    [15:0]         TCP_urgent_pointer;      // Urgent pointer in TCP header;
reg    [15:0]         TCP_window_size;         // Window size in TCP header;

reg [`MAX_HEADER_SIZE*8-1:0] L4_custom_header; // user_defined L4 header 
integer               L4_custom_header_length; // length of
                                               //  user_defined L4 header
reg                   L4_custom_header_enable; // enable user-defined
                                               // L4 header

reg  [1:0]            L4_checksum_option; // options for L4 checksum
// 0 = Generate good checksum
// 1 = Generate bad checksum
// 2 = Set checkum to zero
// 3 = Set checksum to user-defined value
reg [15:0 ]           L4_user_checksum;   // user-defined L4 checksum

// Payload variables
reg [1:0]             payload_option;   // Option for setting payload of
                                         // transmitted packets
// 0 = send increasing sequence of bytes
// 1 = send decreasing sequence of bytes
// 2 = random payload
// 3 = user-defined payload
reg [7:0]             payload_start;    // starting value for payload sequence
reg [`MAX_PKT_SIZE*8-1:0]  user_payload;// buffer to hold user-defined payload
integer               payload_length;   // max size of payload in bytes for L3 and L4 flows

integer               L3_header_position,  // offsets for various headers
		      L4_header_position,  // in frame
		      payload_position;

/***************End of flow records *************************/
// global options

reg   seqno_enable;     // flag to enable insertion of
                        // seq numbers in transmitted frames
integer seq_number_offset; // position of seq number transmitted within frame
                        // set to negative value for insertion at end of frame
reg   timestamp_enable; // flag to enable insertion of
                        // timestamps in transmitted frames
integer timestamp_offset; // position of timestamp transmitted within frame
                        // set to negative value for insertion at end of frame

reg     [31:0]        packet_seq_no; // Sequence number of packet

reg     [31:0]        packet_timestamp; // timestamp in packet
/********************************************************************************/

reg   [31:0]                  event_file; // handle to event log file
reg   [31:0]                  outfile;    // handle to param log file
/*************************************************************/





