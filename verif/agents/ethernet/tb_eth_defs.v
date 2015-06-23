
/*-----------------------------------------------------------------\
|  DESCRIPTION:                                                    |
|  tb_defs.v:  Definitions of symbolic constants                   |
|              used as task arguments in user-callable             |
|              tasks                                               |
|                                                                  |
|  Instantiated modules: none                                      |
|  Included files: none                                            |
\-----------------------------------------------------------------*/

 

// Global defines useful for setting arguments
//  of testbench tasks

/*******************************************************************/

// Parameters in port initialization task
// MII types
`define RMII        0 // Reduced MII
`define FULL_MII    1 // Full MII
`define GMII        2 // Gigabit MII
`define SMII        3 // serial MII
`define CUSTOM      4 // custom parallel interface
`define SERDES      5 // Gigabit Ethernet SERDES interface

// duplex status
`define HALF_DUPLEX 0
`define FULL_DUPLEX 1
// Port speed
`define SPEED_10    0 // 10 Mb/s
`define SPEED_100   1 // 100 Mb/s
`define SPEED_1000  2 // 1000 Mb/s

// Options in handling received PAUSE frames
// (used as arguments in task "set_pause_options")
`define NORMAL_PAUSE_HANDLING        0
`define ADD_TO_PAUSE_INTERVAL        1
`define IGNORE_RECEIVED_PAUSE        2

// Flow types in task "set_flow_type"
`define L2_UNICAST    0 // Layer-2 unicast flow
`define L2_BROADCAST  1 // Layer-2 broadcast
`define L2_MULTICAST  2 // Layer-2 multicast
`define L3_UNICAST    3 // Layer-3 unicast flow
`define L3_MULTICAST  4 // Layer-3 multicast flow
`define L4_UNICAST    5 // Layer-4 unicast flow
`define L4_MULTICAST  6 // Layer-4 multicast flow

// L2 protocol choices
// used as argument in task "set_L2_protocol"
`define UNTAGGED_ETHERNET   0 // Ethernet frames without tagging
`define   TAGGED_ETHERNET   1 // Ethernet frames with tagging
`define UNTAGGED_802        2 // 802.3 frames without tagging
`define   TAGGED_802        3 // 802.3 frames with tagging
`define BPDU                4 // 802.1d Bridge Protocol Data Units

// Options for generation of MAC addresses, VLAN TCI,
// and packet size in packet sequences
`define CONSTANT_VALUE         0  // constant value in all packets
`define INCREMENTAL_PATTERN    1  // increasing or decreasing pattern
`define RANDOM_PATTERN         2  // randomly generated value

// L3 protocol choices
// used as argument in task "set_L3_protocol"
`define IGMP_v1             1 // IGMP Version 1
`define IGMP_v2             2 // IGMP Version 2
`define IP_v4               4 // IP Version 4
`define IP_v6               6 // IP Version 6
`define ICMP_v4             7 // ICMP on IP Version 4
`define ARP                 8 // TCP/IP ARP
`define IPX                 9 // IPX

// L4 protocol choices
// used as argument in task "set_L4_protocol"
`define TCP                 0
`define UDP                 1

// Options for setting paylod of transmitted packets
// used in task "set_payload_type"
`define INCREASING_PAYLOAD  0 // increasing sequence of bytes (default)
`define DECREASING_PAYLOAD  1 // decreasing sequence of bytes
`define RANDOM_PAYLOAD      2 // Randomly generated payload
`define USER_PAYLOAD        3 // user-supplied payload

// Options for CRC generation
// used in task "set_crc_option"
`define GOOD_CRC              0 // good CRC
`define BAD_CRC               1 // transmit bad CRC
`define NO_CRC                2 // do not insert CRC
`define USER_DEFINED_CRC      3 // user-defined value

// options for L3 and L4 cheksum generation
// used in tasks "set_L3_checksum_option" and
// "set_L4_checksum_option
`define GOOD_CHECKSUM         0 // insert good checksum
`define BAD_CHECKSUM          1 // insert bad checksum
`define NO_CHECKSUM           2 // transmit checksum of all zeroes
`define USER_DEFINED_CHECKSUM 3 // user-defined value

// blocking/non-blocking option in transmit tasks
`define BLOCKING              1 // task blocks until end of transmission
`define NON_BLOCKING          0 // task returns immediately

// Transmit states returned by task "get_transmit_state"
`define TRANSMIT_FRAME        1 // port currently transmitting a frame
`define COLLISION_STATE       2 // port resolving a collision
`define TRANSMIT_SEQUENCE     3 // Transmission of packet sequence in progress
`define IDLE_STATE            0 // idle

//States returned by task "get_receive_state"
`define RECEIVE_FRAME         1 // Port receiving a frame

// event types in task "wait_for_event"
`define START_OF_XMIT_FRAME        1 // start of transmission of next frame
`define END_OF_XMIT_SEQUENCE       2 // end of packet sequence in progress
`define END_OF_XMIT_FRAME          3 // end of current frame in progress
`define START_OF_RCV_FRAME         4 // start of frame reception
`define END_OF_RCV_FRAME           5 // end of frame reception
`define COLLISION_EVENT            6 // collision event
`define REPEATED_COLLISION_EVENT   7 // repeated collisions

`define DUMMY                      0 // Dummy argument for tasks
//  





















