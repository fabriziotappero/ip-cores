//===================================================================================
//  Changeable testbench defines (constants) - tested together with 
//    pci_user_constants.v file, and not when regression testing!
//===================================================================================

// define whether or not testbench should stop executing after error is detected
`define STOP_ON_FAILURE

`ifdef REGRESSION 
`else // Following DEFINES are used only without regression testing (together with pci_user_constants) !!!

    // next two defines are used to generate clocks
    // only one at the time can be defined, otherwise testbench won't work
    // they are used to generate both clocks with same period and phase shift of define's value in nano seconds

    //`define PCI_CLOCK_FOLLOWS_WB_CLOCK 2
    //`define WB_CLOCK_FOLLOWS_PCI_CLOCK 2
    
    // wishbone period in ns
    `define WB_PERIOD 10.0
    
    // values of image registers of PCI bridge device - valid are only upper 20 bits, others must be ZERO !
    `define TAR0_BASE_ADDR_0	32'h1000_0000
    `define TAR0_BASE_ADDR_1  	32'h2000_0000
    `define TAR0_BASE_ADDR_2  	32'h4000_0000
    `define TAR0_BASE_ADDR_3  	32'h6000_0000
    `define TAR0_BASE_ADDR_4  	32'h8000_0000
    `define TAR0_BASE_ADDR_5  	32'hA000_0000
    
    `define TAR0_ADDR_MASK_0	32'hFFFF_F000 // when BA0 is used to access configuration space, this is NOT important!
    `define TAR0_ADDR_MASK_1  	32'hFFFF_F000
    `define TAR0_ADDR_MASK_2  	32'hFFFF_F000
    `define TAR0_ADDR_MASK_3  	32'hFFFF_F000
    `define TAR0_ADDR_MASK_4  	32'hFFFF_F000
    `define TAR0_ADDR_MASK_5  	32'hFFFF_F000
    
    `define TAR0_TRAN_ADDR_0	32'hC000_0000 // when BA0 is used to access configuration space, this is NOT important!
    `define TAR0_TRAN_ADDR_1  	32'hA000_0000
    `define TAR0_TRAN_ADDR_2  	32'h8000_0000
    `define TAR0_TRAN_ADDR_3  	32'h6000_0000
    `define TAR0_TRAN_ADDR_4  	32'h4000_0000
    `define TAR0_TRAN_ADDR_5  	32'h2000_0000
    
    // values of image registers of PCI behavioral target devices !
    `define BEH_TAR1_MEM_START 32'hC000_0000
    `define BEH_TAR1_MEM_END   32'hC000_0FFF
    `define BEH_TAR1_IO_START  32'hD000_0001
    `define BEH_TAR1_IO_END    32'hD000_0FFF
    
    `define BEH_TAR2_MEM_START 32'hE000_0000
    `define BEH_TAR2_MEM_END   32'hE000_0FFF
    `define BEH_TAR2_IO_START  32'hF000_0001
    `define BEH_TAR2_IO_END    32'hF000_0FFF

    // IDSEL lines of each individual Target is connected to one address line
    // following defines set the address line IDSEL is connected to
    // TAR0 = DUT - bridge
    // TAR1 = behavioral target 1
    // TAR2 = behavioral target 2

    `define TAR0_IDSEL_INDEX    11          
    `define TAR1_IDSEL_INDEX    12
    `define TAR2_IDSEL_INDEX    13

    // next 3 defines are derived from previous three defines
    `define TAR0_IDSEL_ADDR     (32'h0000_0001 << `TAR0_IDSEL_INDEX)
    `define TAR1_IDSEL_ADDR     (32'h0000_0001 << `TAR1_IDSEL_INDEX)
    `define TAR2_IDSEL_ADDR     (32'h0000_0001 << `TAR2_IDSEL_INDEX)

    `define DISABLE_COMPLETION_EXPIRED_TESTS
`endif

//===================================================================================
//  User-unchangeable testbench defines (constants)
//===================================================================================

// setup and hold time definitions for WISHBONE - used in BFMs for signal generation
`define Tsetup 3
`define Thold  1

// how many clock cycles should model wait for design's response - integer 32 bit value
`define WAIT_FOR_RESPONSE 10

// maximum number of transactions allowed in single call to block or cab transfer routines
`define MAX_BLK_SIZE  4096

// maximum retry terminations allows for WISHBONE master to repeat an access
`define WB_TB_MAX_RTY 10000


// some common types and defines
`define WB_ADDR_WIDTH 32
`define WB_DATA_WIDTH 32
`define WB_SEL_WIDTH `WB_DATA_WIDTH/8
`define WB_TAG_WIDTH 5
`define WB_ADDR_TYPE [(`WB_ADDR_WIDTH - 1):0]
`define WB_DATA_TYPE [(`WB_DATA_WIDTH - 1):0]
`define WB_SEL_TYPE  [(`WB_SEL_WIDTH  - 1):0]
`define WB_TAG_TYPE  [(`WB_TAG_WIDTH  - 1):0]

// definitions file only for testbench usage
// wishbone master behavioral defines
// flags type for wishbone cycle initialization
`define CYC_FLAG_TYPE [0:0]
// cab flag field in cycle initialization data
`define CYC_CAB_FLAG [0]
// read cycle stimulus - consists of:
//    - address field - which address read will be performed from
//    - sel field     - what byte select value should be
//    - tag field     - what tag values should be put on the bus
`define READ_STIM_TYPE [(`WB_ADDR_WIDTH + `WB_SEL_WIDTH + `WB_TAG_WIDTH - 1):0]
`define READ_STIM_LENGTH (`WB_ADDR_WIDTH + `WB_SEL_WIDTH + `WB_TAG_WIDTH)
`define READ_ADDRESS  [(`WB_ADDR_WIDTH - 1):0]
`define READ_SEL      [(`WB_ADDR_WIDTH + `WB_SEL_WIDTH - 1):`WB_ADDR_WIDTH]
`define READ_TAG_STIM [(`WB_ADDR_WIDTH + `WB_SEL_WIDTH + `WB_TAG_WIDTH - 1):(`WB_ADDR_WIDTH + `WB_SEL_WIDTH)]

// read cycle return type consists of:
//    - read data field
//    - tag field received from WISHBONE
//    - wishbone slave response fields - ACK, ERR and RTY
//    - test bench error indicator (when testcase has not used wb master model properly)
//    - how much data was actually transfered
`define READ_RETURN_TYPE [(32 + 4 + `WB_DATA_WIDTH + `WB_TAG_WIDTH - 1):0]
`define READ_DATA        [(32 + `WB_DATA_WIDTH + 4 - 1):32 + 4]
`define READ_TAG_RET     [(32 + 4 + `WB_DATA_WIDTH + `WB_TAG_WIDTH - 1):(`WB_DATA_WIDTH + 32 + 4)]
`define READ_RETURN_LENGTH (32 + 4 + `WB_DATA_WIDTH + `WB_TAG_WIDTH - 1)

// write cycle stimulus type consists of
//    - address field
//    - data field
//    - sel field
//    - tag field
`define WRITE_STIM_TYPE [(`WB_ADDR_WIDTH + `WB_DATA_WIDTH + `WB_SEL_WIDTH + `WB_TAG_WIDTH - 1):0]
`define WRITE_ADDRESS       [(`WB_ADDR_WIDTH - 1):0]
`define WRITE_DATA          [(`WB_ADDR_WIDTH + `WB_DATA_WIDTH - 1):`WB_ADDR_WIDTH]
`define WRITE_SEL           [(`WB_ADDR_WIDTH + `WB_DATA_WIDTH + `WB_SEL_WIDTH - 1):(`WB_ADDR_WIDTH + `WB_DATA_WIDTH)]
`define WRITE_TAG_STIM      [(`WB_ADDR_WIDTH + `WB_DATA_WIDTH + `WB_SEL_WIDTH + `WB_TAG_WIDTH - 1):(`WB_ADDR_WIDTH + `WB_DATA_WIDTH + `WB_SEL_WIDTH)]

// length of WRITE_STIMULUS
`define WRITE_STIM_LENGTH (`WB_ADDR_WIDTH + `WB_DATA_WIDTH + `WB_SEL_WIDTH + `WB_TAG_WIDTH)

// write cycle return type consists of:
//    - test bench error indicator (when testcase has not used wb master model properly)
//    - wishbone slave response fields - ACK, ERR and RTY
//    - tag field received from WISHBONE
//    - how much data was actually transfered
`define WRITE_RETURN_TYPE [(32 + 4 + `WB_TAG_WIDTH - 1):0]
`define WRITE_TAG_RET     [(32 + 4 + `WB_TAG_WIDTH - 1):32 + 4]

// this four fields are common to both read and write routines return values
`define TB_ERROR_BIT [0]
`define CYC_ACK [1]
`define CYC_RTY [2]
`define CYC_ERR [3]
`define CYC_RESPONSE [3:1]
`define CYC_ACTUAL_TRANSFER [35:4]

// block transfer flags
`define WB_TRANSFER_FLAGS [42:0]
// consists of:
// - number of transfer cycles to perform
// - flag that enables retry termination handling - if disabled, block transfer routines will return on any termination other than acknowledge
// - flag indicating CAB transfer is to be performed - ignored by all single transfer routines
// - number of initial wait states to insert
// - number of subsequent wait states to insert
`define WB_FAST_B2B          [42]
`define WB_TRANSFER_SIZE     [41:10]
`define WB_TRANSFER_AUTO_RTY [8]
`define WB_TRANSFER_CAB      [9]
`define INIT_WAITS           [3:0]
`define SUBSEQ_WAITS         [7:4]
