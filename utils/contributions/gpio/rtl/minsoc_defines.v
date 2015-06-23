//
// Define FPGA manufacturer
//
//`define GENERIC_FPGA
//`define ALTERA_FPGA
`define XILINX_FPGA

// 
// Define FPGA Model (comment all out for ALTERA)
//
//`define SPARTAN2
//`define SPARTAN3
//`define SPARTAN3E
`define SPARTAN3A
//`define VIRTEX
//`define VIRTEX2
//`define VIRTEX4
//`define VIRTEX5


//
// Memory
//
`define MEMORY_ADR_WIDTH   13	//MEMORY_ADR_WIDTH IS NOT ALLOWED TO BE LESS THAN 12, memory is composed by blocks of address width 11
								//Address width of memory -> select memory depth, 2 powers MEMORY_ADR_WIDTH defines the memory depth 
								//the memory data width is 32 bit, memory amount in Bytes = 4*memory depth

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
`define FPGA_CLOCK_DIVISION		//Altera ALTPLL is not implemented, didn't find the code for its verilog instantiation
								//if you selected altera and this, the GENERIC_CLOCK_DIVISION will be automatically taken

//
// Define division
//
`define CLOCK_DIVISOR 5		//in case of GENERIC_CLOCK_DIVISION the real value will be rounded down to an even value
							//in FPGA case, check minsoc_clock_manager for allowed divisors
							//DO NOT USE CLOCK_DIVISOR = 1 COMMENT THE CLOCK DIVISION SELECTION INSTEAD

//
// Reset polarity
//
//`define NEGATIVE_RESET;      //rstn
`define POSITIVE_RESET;      //rst

//
// Start-up circuit (only necessary later to load firmware automatically from SPI memory)
//
//`define START_UP

//
// Connected modules
//
`define UART
//`define ETHERNET
`define GPIO

//
// Ethernet reset
//
//`define ETH_RESET 	1'b0
`define ETH_RESET	1'b1

//
// GPIO Pins
//
`define GPIO_HAS_INPUT_PINS
//`define GPIO_HAS_OUTPUT_PINS
`define GPIO_HAS_BIDIR_PINS

`define GPIO_NUM_INPUT	 	4'd8
`define GPIO_NUM_OUTPUT		4'd0
`define GPIO_NUM_BIDIR		4'd8

//
// Interrupts
//
`define APP_INT_RES1	1:0
`define APP_INT_UART	2
`define APP_INT_RES2	3
`define APP_INT_ETH	4
`define APP_INT_PS2	5
`define APP_INT_GPIO 6
`define APP_INT_RES3	19:7

//
// Address map
//
`define APP_ADDR_DEC_W	8
`define APP_ADDR_SRAM	`APP_ADDR_DEC_W'h00
`define APP_ADDR_FLASH	`APP_ADDR_DEC_W'h04
`define APP_ADDR_DECP_W  4
`define APP_ADDR_PERIP  `APP_ADDR_DECP_W'h9
`define APP_ADDR_SPI	`APP_ADDR_DEC_W'h97
`define APP_ADDR_ETH	`APP_ADDR_DEC_W'h92
`define APP_ADDR_AUDIO	`APP_ADDR_DEC_W'h9d
`define APP_ADDR_UART	`APP_ADDR_DEC_W'h90
`define APP_ADDR_PS2	`APP_ADDR_DEC_W'h94
`define APP_ADDR_GPIO   `APP_ADDR_DEC_W'h9e
`define APP_ADDR_RES2	`APP_ADDR_DEC_W'h9f

//
// Set-up GENERIC_TAP, GENERIC_MEMORY if GENERIC_FPGA was chosen
// and GENERIC_CLOCK_DIVISION if NO_CLOCK_DIVISION was not set
//
`ifdef GENERIC_FPGA
	`define GENERIC_TAP
	`define GENERIC_MEMORY
	`ifndef NO_CLOCK_DIVISION
		`define GENERIC_CLOCK_DIVISION
	`endif
`endif
