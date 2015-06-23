//File name=Module=Cfg_Ctrl    2005-04-03           btltz@mail.china.com           btltz from CASIC  
//Description:   Transact commands.
//               Include "control logic", "control/status register(and the gpio output pins)",
//               "configuration port".  Note routing tables is in "LSer".
//Origin:        SpaceWire Std - Draft-1(Clause 9/10) of ECSS(European Cooperation for Space Standardization),ESTEC,ESA.
//               SpaceWire Router Requirements Specification Issue 1 Rev 5. Astrium & University of Dundee 
//--     TODO:   make the rtl faster
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//

/*synthesize translate_off*/
`include "timescale.v"
/*synthesize translate_on */
`define reset  1	               // WISHBONE standard reset
`define XIL_BRAM	    			   // Use Xilinx block RAM
`define XIL_DISRAM	 			   // Use Xilinx distributed RAM
`define TOOL_NOTSUP_PORT_ARRAY   // If the tools not support port array declaration  


module Cfg_Ctrl  #(parameter DW=32,AW=32, IO_PORTNUM=16, CFG_AW=4, IO_DW=10, EXT_DW=9)
( 
// interface with SpW I/O ports, External port
                  output [PORTNUM-1:0] rd_IBUF_o,    // Note write to SpW IO port FIFO is performed by "switch core"
                 `ifdef TOOL_NOTSUP_PORT_ARRAY                  
					   input [IO_DW-1:0]	SpW_D0_i, SpW_D1_i, SpW_D2_i, SpW_D3_i,
						                  SpW_D4_i, SpW_D5_i, SpW_D6_i, SpW_D7_i,
												SpW_D8_i, SpW_D9_i, SpW_D10_i,SpW_D11_i,
												SpW_D12_i,SpW_D13_i,SpW_D14_i,SpW_D15_i,
 
                 `else
                  input [IO_DW-1:0] SpW_D_i [0:PORTNUM-1],
					  `endif
					   input [PORTNUM-1:0] empty_IBUF_i,  // empty flag of SpW input interface buffer(fifo)
						input [PORTNUM-1:0] full_OBUF_i,	  // full flag of SpW output interface buffer(fifo) 
						
						output [EXT_DW-1:0] EXT_data_o,
						output we_EXTport_o,
						output rd_EXTport_o,
						input  [EXT_DW-1:0] EXT_data_i,
						input  empty_eibuf_i,               // empty flag of external input port buffer(fifo)
						input  full_eobuf_i,						// full flag of external output port buffer(fifo)

// interface for user to inspect
             		output cfg_int_o,                   // interrupt the user application
						output cfg_wrbusy_o,                // configuration write in progress
						output[AW-1:0] cfg_int_addr, 
						input [AW-1:0] cfg_addr_i,
						//input [DW-1:0] cfg_data_i,        // reserved
						//input [] cfg_ben_i,               // configuration byte enable
						//input cfg_wren_i,                 // reserved
 
  
// global signal input						
						input reset,
						input gclk       
					 );

				  parameter EOP         = 9'b1_0000_0000;                 // {p,1'b1,8'b0000_0000}
				  parameter EEP         = 9'b1_0000_0001;   		          // {p,1'b1,8'b0000_0001}
				  parameter HEADS_Cargo = 9'b0_xxxx_xxxx;                 // {p,1'b0,1-byte data } 
				// commands  
              parameter CMD_WRITE   =; 
				  parameter CMD_REQ_ID  =; 

              parameter STATENUM = 8;
				  parameter RESET           = 'b0000_0001;
				  parameter IDLE            = 'b0000_0010;
				  parameter RCV_CMD         = 'b0000_0100;
				  parameter  

////////////////////////////
// Registers(Control, status)
//

`include "RegSWR.v"

////////////////////////////
// Command & Reply
//
reg [7:0] cmd [0:13];
reg [7:0] rpy [0:11];

always @(posedge gclk)																	


endmodule

`undef reset 
`undef TOOL_NOTSUP_PORT_ARRAY