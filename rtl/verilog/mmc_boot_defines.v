// Copyright 2004-2005 Openchip
// http://www.openchip.org

`ifdef MMC_BOOT_DEFINES
`else
`define MMC_BOOT_DEFINES


// send 80 clocks ?
`define CMD_INIT	4'b1111  

// Initialize
`define CMD0	 			4'b0000  

// identify, loop until ready !
`define CMD1	 			4'b0001  

// just read the rest of response
`define CMD1_IDLE	 		4'b1001  

// read CID
`define CMD2	 			4'b0010  

// assign RCA
`define CMD3	 			4'b0011	

// go transfer
`define CMD7	 			4'b0111	

// stream read command
`define CMD11 			     4'b1011  

// stream read transfer in progress
`define CMD_TRANSFER 		4'b1100  

// config done, just idle wait for reset
`define CMD_CONFIG_DONE 	     4'b1101  

// config error, just idle wait for reset
`define CMD_CONFIG_ERROR 	4'b1110  


`endif