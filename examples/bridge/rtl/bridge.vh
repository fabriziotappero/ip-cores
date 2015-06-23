
// Address size for number of ports.  Default value 4,
// which will allow design to scale up to 16 ports
`define PORT_ASZ    4

// We will have only 4 ports in our sample design
`define NUM_PORTS   4

// Data structure from parser to Allocator/FIB.  Contains MAC DA,
// MAC SA, and source port
`define PAR_DATA_SZ (48+48+4)
`define PAR_MACDA    47:0
`define PAR_MACSA    95:48
`define PAR_SRCPORT  99:96

// additional information from allocator to FIB
`define A2F_STARTPG  111:100
`define A2F_ENDPG    123:112

// total size of parser+allocator structure to FIB
`define PM2F_SZ      124

// number of entries in FIB table
`define FIB_ENTRIES   256
`define FIB_ASZ       $clog2(`FIB_ENTRIES)

// FIB entry definition
`define FIB_ENTRY_SZ  60
`define FIB_MACADDR   47:0     // MAC address
`define FIB_AGE       55:48    // 8 bit age counter
`define FIB_PORT      59:56    // associated port

`define FIB_MAX_AGE   255      // maximum value of age timer

`define MULTICAST     48'h0100000000  // multicast bit

// Packet control codes
`define PCC_SOP     2'b01    // Start of packet
`define PCC_DATA    2'b00    // data word
`define PCC_EOP     2'b10    // End of packet
`define PCC_BADEOP  2'b11    // End of packet w/ error

`define ANY_EOP(x)   (( (x) == `PCC_EOP) || ( (x) == `PCC_BADEOP))

// Packet FIFO Word
`define PRW_DATA     63:0      // 64 bits of packet data
`define PRW_PCC      65:64     // packet control code
`define PRW_VALID    68:66     // # of valid bytes modulo 8
`define PFW_SZ       69

// Port FIFO sizes
`define RX_FIFO_DEPTH 256
`define TX_FIFO_DEPTH 1024

`define RX_USG_SZ     $clog2(`RX_FIFO_DEPTH)+1
`define TX_USG_SZ     $clog2(`TX_FIFO_DEPTH)+1

// Linked List Definitions
`define LL_PAGES     4096
`define LL_PG_ASZ    $clog2(`LL_PAGES)

`define LL_ENDPAGE   { 1'b1, {`LL_PG_ASZ{1'b0}} }

`define LL_MAX_REF   16
`define LL_REFSZ     4

`define LL_LNP_SZ    (`LL_PG_ASZ*2+1)


// Packet buffer size
`define PB_LINES_PER_PAGE 4
`define PB_DEPTH     (`LL_PAGES*`PB_LINES_PER_PAGE)
`define PB_ASZ       $clog2(`PB_DEPTH)

// Packet buffer request structure
`define PBR_DATA     68:0    // only valid for writes
`define PBR_ADDR     82:69
`define PBR_WRITE    83
`define PBR_PORT     87:84   // only valid for reads
`define PBR_SZ       88

// GMII definitions
`define GMII_PRE     8'h55
`define GMII_SFD     8'hD5
