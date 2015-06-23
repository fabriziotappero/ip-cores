
/*-----------------------------------------------------------------\
|  DESCRIPTION:                                                    |
|  tb_conf.v:  Global constant definitions                         |
|                                                                  |
|  Instantiated modules: none                                      |
|  Included files: none                                            |
\-----------------------------------------------------------------*/


`define TESTBENCH  tb_top.u_tb_eth // hierarchical name of testbench instance

`define MAX_STR_LENGTH   100 // max length for character strings

`define MAX_PKT_SIZE 8000 // Max packet size in bytes

`define MAX_HEADER_SIZE 42 // Max size of user-defined packet headers
                           // (in bytes)
`define IP_EXTENSION_HEADER_SIZE  256 // Max size of IP Extension Header

`define MIN_IFG  96 // Minimum permitted IFG on receive side
                    // for signalling error

`define EVENT_LOG_FILENAME "stargate_events.log"  // file to log events

`define PARAM_LOG_FILENAME "stargate_log_files/tb_param.log" // file for logging packet parameters
                                              // from print_packet_parameters task

/*******************Default values of packet fields ***********************/
`define DEFAULT_VLAN_TPID 16'h8100 // VLAN Tag Protocol ID in IEEE 802.1Q
`define DEFAULT_L2_TYPE 16'h0700   // Default type field for Ethernet frames
                                   // set to an unassigned value
`define PAUSE_DEST_MAC  48'h0180c2000001 // Destination MAC address for PAUSE frames
`define PAUSE_TYPE   16'h8808 //  type/length value defined for PAUSE frames
`define PAUSE_OPCODE 16'h0001 // Opcode for PAUSE frame 
/********************************************************************************/

/************************* MII parameters ***************************************/
`define MII_WIDTH        4             // Width of MII interface
`define RMII_WIDTH       2             // Width of Reduced MII interface
`define GMII_WIDTH       8             // Width of Gigabit MII interface
`define SERDES_WIDTH    10             // Width of SERDES interface
`define SFD              8'b11010101   // Start-of-frame delimiter
`define MAX_COLLISIONS   16            // Collision limit
`define BACKOFF_LIMIT    1024          // Maximum backoff in slots
`define MIN_FRAME_SIZE   64            // Minimum size of a valid frame, in bytes
/********************************************************************************/

/*************** Options for logging frames into events.log file*****************/
`define LOG_TRANSMITTED_FRAMES     1     // log all frames on transmission

`define LOG_RECEIVED_FRAMES        1     // log all frames on reception

`define LOG_FRAMES_WITH_ERRORS     1     // log frames received with errors
/********************************************************************************/

/****************Options for terminating simulation on error conditions*********/
`define TERMINATE_ON_TASK_ERRORS   1    // Terminate when a task is called illegally
`define TERMINATE_ON_PARAM_ERRORS  1    // Terminate when a parameter to a task
                                        // is out of range
`define TERMINATE_ON_TRANSMIT_ERRORS 1   // Terminate on transmit errors, such as
                                         // when transmit_packet_sequence
                                         // finds the port busy

`define TERMINATE_ON_TRANSMIT_TIMEOUT 1  // Terminate when transmit timer
                                         // times out
`define TERMINATE_ON_IFG_VIOLATION 0     // Terminate when IFG on receive
                                         // less than MIN_IFG
`define TERMINATE_ON_CRC_ERROR 0         // Terminate when received frame has
                                         // CRC error
`define TERMINATE_ON_UNDERSIZE_FRAME 0   // Terminate when size of received frame
                                         // is less than the defined minimum
`define TERMINATE_ON_OVERSIZE_FRAME 0    // Terminate when size of received frame
                                         // is larger than the defined minimum
`define TERMINATE_ON_ALIGNMENT_ERROR 0   // Terminate when received frame has
                                         // an alignment error
/********************************************************************************/

/******** The following are debug switches ***********/
`define DEBUG_MII        0             // Debug MII interfaces
/********************************************************************************/


