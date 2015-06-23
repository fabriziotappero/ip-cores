//set RTL for simulation, override FPGA specific definitions (JTAG TAP, MEMORY and CLOCK DIVIDER)
`define GENERIC_FPGA
`define MEMORY_MODEL        //simulation uses a memory model enabling INITIALIZE_MEMORY_MODEL. If you comment this, START_UP might be interesting.
`define NO_CLOCK_DIVISION   //if commented out, generic clock division is implemented (odd divisors are rounded down)
//~set RTL for simulation, override FPGA specific definitions (JTAG TAP, MEMORY and CLOCK DIVIDER)

`define FREQ_NUM_FOR_NS 100000000

`define FREQ 10000000
`define CLK_PERIOD (`FREQ_NUM_FOR_NS/`FREQ)

`define ETH_PHY_FREQ  25000000
`define ETH_PHY_PERIOD  (`FREQ_NUM_FOR_NS/`ETH_PHY_FREQ)    //40ns

`define UART_BAUDRATE 9600 

`define VPI_DEBUG

//`define WAVEFORM_OUTPUT

//`define START_UP						//pass firmware over spi to or1k_startup

`define INITIALIZE_MEMORY_MODEL			//instantaneously initialize memory model with firmware
										//only use with the memory model. 
                                        //If you use the original memory (`define MEMORY_MODEL 
                                        //commented out), comment this too.

`define TEST_UART
//`define TEST_ETHERNET
