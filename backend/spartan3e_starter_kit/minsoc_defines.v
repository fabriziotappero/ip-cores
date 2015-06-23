//
// Define FPGA manufacturer
//
//`define GENERIC_FPGA
//`define ALTERA_FPGA
`define XILINX_FPGA

// 
// Define Xilinx FPGA family
//
`ifdef XILINX_FPGA
//`define SPARTAN2
//`define SPARTAN3
`define SPARTAN3E
//`define SPARTAN3A
//`define VIRTEX
//`define VIRTEX2
//`define VIRTEX4
//`define VIRTEX5

//
// Define Altera FPGA family
//
`elsif ALTERA_FPGA
//`define ARRIA_GX
//`define ARRIA_II_GX
//`define CYCLONE_I
//`define CYCLONE_II
`define CYCLONE_III
//`define CYCLONE_III_LS
//`define CYCLONE_IV_E
//`define CYCLONE_IV_GS
//`define MAX_II
//`define MAX_V
//`define MAX3000A
//`define MAX7000AE
//`define MAX7000B
//`define MAX7000S
//`define STRATIX
//`define STRATIX_II
//`define STRATIX_II_GX
//`define STRATIX_III
`endif

//
// Memory
//
`define MEMORY_ADR_WIDTH   13	//MEMORY_ADR_WIDTH IS NOT ALLOWED TO BE LESS THAN 12, 
                                //memory is composed by blocks of address width 11
								//Address width of memory -> select memory depth, 
                                //2 powers MEMORY_ADR_WIDTH defines the memory depth 
								//the memory data width is 32 bit, 
                                //memory amount in Bytes = 4*memory depth

//
// Memory type	(uncomment something if ASIC or generic memory)
//
//`define GENERIC_MEMORY
//`define AVANT_ATP
//`define VIRAGE_SSP
//`define VIRTUALSILICON_SSP


//
// TAP selection
//
//`define GENERIC_TAP
`define FPGA_TAP

//
// Clock Division selection
//
//`define NO_CLOCK_DIVISION
//`define GENERIC_CLOCK_DIVISION
`define FPGA_CLOCK_DIVISION		// For Altera ALTPLL, only CYCLONE_III family has been tested.

//
// Define division
//
`define CLOCK_DIVISOR 2		//in case of GENERIC_CLOCK_DIVISION the real value will be rounded 
                            //down to an even value in FPGA case, check minsoc_clock_manager 
                            //for allowed divisors.
				            //DO NOT USE CLOCK_DIVISOR = 1 COMMENT THE CLOCK DIVISION SELECTION 
                            //INSTEAD.

//
// Reset polarity
//
//`define NEGATIVE_RESET      //rstn
`define POSITIVE_RESET      //rst

//
// Start-up circuit (only necessary later to load firmware automatically from SPI memory)
//
//`define START_UP

//
// Connected modules
//
`define UART
//`define JSP
//`define ETHERNET

//
// Ethernet reset
//
`define ETH_RESET 	1'b0
//`define ETH_RESET	1'b1

//
// Set-up GENERIC_TAP, GENERIC_MEMORY if GENERIC_FPGA was chosen
// and GENERIC_CLOCK_DIVISION if NO_CLOCK_DIVISION was not set
//
`ifdef GENERIC_FPGA
    `undef FPGA_TAP
    `undef FPGA_CLOCK_DIVISION
    `undef XILINX_FPGA
    `undef SPARTAN3E

	`define GENERIC_TAP
	`define GENERIC_MEMORY
	`ifndef NO_CLOCK_DIVISION
		`define GENERIC_CLOCK_DIVISION
	`endif
`endif
