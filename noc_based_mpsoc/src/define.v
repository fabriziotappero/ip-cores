/*********************************************************************
							
	File: define.v 
	
	Copyright (C) 2014  Alireza Monemi

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
	
	
	Purpose:
	contains global definitions 
	
	Info: monemi@fkegraduate.utm.my
*********************************************************************/
`ifndef	DEFINE_H
	`define	DEFINE_H

	
	
	
/*********************************************************************

The NoC router definition for  generate a mech topology. The following defines will generate 
a 3X3 noC 

********************************************************************/	
//define the topology: "MESH" or "TORUS"
`define						TOPOLOGY_DEF						"MESH" 
//define the routing algorithm : "XY_CLASSIC" or "BALANCE_DOR" or "ADAPTIVE_XY"	
`define						ROUTE_ALGRMT_DEF					"XY_CLASSIC"						
// The number of virtual channel (VC) for each individual physical channel. this value must be power of 2. The typical value is two and four.
`define 						VC_NUM_PER_PORT_DEF 				2

//The payload size in bites.  The packet flit size is payload size plus the two bit for flit type and the VC_NUM_PER_PORT.  
`define						PYLD_WIDTH_DEF						32

// The buffer size in words (PYLD_WIDTH_DEF	) for each individual VC.  
`define						BUFFER_NUM_PER_VC_DEF			4

// the number of IP core in X axis
`define 						X_NODE_NUM_DEF						3

// the number of IP core in Y axis
`define						Y_NODE_NUM_DEF						3


`define 						AEMB_RAM_WIDTH_IN_WORD_DEF		12


/***********************
if SDRAM_EN_DEF is defined as 1 then the core located in SDRAM_SW_X_ADDR_DEF	
and SDRAM_SW_Y_ADDR_DEF will be connected to shared external sdram. the sdram core ni 
support writting and readding from shared sdram memory
**********************/

`define 						SDRAM_EN_DEF						1//  0 : disabled  1: enabled 
`define 						SDRAM_SW_X_ADDR_DEF				2
`define 						SDRAM_SW_Y_ADDR_DEF				2
`define 						SDRAM_NI_CONNECT_PORT_DEF		0//local
`define 						SDRAM_ADDR_WIDTH_DEF				25




/* aeMB IP def
define the parameters for all aeMB IPs. define the values with the following formats:
parameter PARAMETER_ARRAY	="IPn:[the specefic value for nth IP];Def:[default value for the rest of IPs]"
e.g defining 
TIMER_EN_ARRAY_DEF				"IP0_0:1;IP2_0:1;Def:0"
will enable the timer for cores (0,0) and (2,0) while the timer is diabled for the reset cores 
*/
`define RAM_EN_ARRAY_DEF				"Def:1"
`define NOC_EN_ARRAY_DEF				"Def:1"
`define GPIO_EN_ARRAY_DEF				"Def:1"
`define EXT_INT_EN_ARRAY_DEF			"IP0_0:1;Def:0"
`define TIMER_EN_ARRAY_DEF				"IP0_0:1;Def:0"
`define INT_CTRL_EN_ARRAY_DEF			"IP0_0:1;Def:0"
	
//gpio 
`define IO_EN_ARRAY_DEF					"Def:0"
`define I_EN_ARRAY_DEF					"Def:0"
`define O_EN_ARRAY_DEF					"IP0_1:0;Def:1"
`define EXT_INT_NUM_ARRAY_DEF			"IP0_0:3;Def:0"
/********************
define the number & port width for all cores. 
e.g: 
`define O_PORT_WIDTH_ARRAY_DEF		"IP0_0:7,7,7,7,7,7,7,7;IP0_1:0;Def:1"
will define 8 port with the size of 7 bit each for core (0,0) and all other
cores will have just one output port width the size of 32;
the maximum port width is 32

********************/	
`define IO_PORT_WIDTH_ARRAY_DEF		"Def:0"
`define I_PORT_WIDTH_ARRAY_DEF		"Def:0"
`define O_PORT_WIDTH_ARRAY_DEF		"IP0_0:7,7,7,7,7,7,7,7;IP0_1:0;Def:1"


`define					AEMB_IWB_DEF							32 //< INST bus width
`define 					AEMB_DWB_DEF 							32 ///< DATA bus width
`define					AEMB_XWB_DEF 							7	///< XCEL bus width

   // CACHE define
`define					AEMB_ICH_DEF 							11 ///< instruction cache size
`define					AEMB_IDX_DEF 							 6///< cache index size

 // OPTIONAL HARDWARE
`define					AEMB_BSF_DEF 							1 ///< optional barrel shift
`define					AEMB_MUL_DEF 							1 ///< optional multiplier

	
	
	
	
`define					AEMB_IWB_ADRR_RANG					`AEMB_IWB_DEF-3	:	0
`define					AEMB_DWB_ADRR_RANG					`AEMB_DWB_DEF-3	:	0
`define					RAM_ADDR_RANG							`AEMB_RAM_WIDTH_IN_WORD_DEF-1		:0
`define					NOC_S_ADDR_RANG						`NOC_S_ADDR_WIDTH_DEF-1		:	0								
	
`define 					NOC_S_ADDR_WIDTH_DEF				3

/*************************************************************
Do not change the rest of definition, otherwise u need to adjast the other verilog codes 
to work with new values.
************************************************************/
	`define 				LOCAL_PORT 							0
	`define				EAST_PORT							1
	`define				NORTH_PORT							2
	`define 				WEST_PORT							3
	`define				SOUTH_PORT							4
	
	
	`define X_Y_ADDR_WIDTH_IN_HDR			4
	
	`define X_ADDR_END						(32-(PORT_NUM_BCD_WIDTH+(`X_Y_ADDR_WIDTH_IN_HDR-X_NODE_NUM_WIDTH)))
	`define X_ADDR_STRT						`X_ADDR_END-X_NODE_NUM_WIDTH
	`define Y_ADDR_END						`X_ADDR_STRT-(`X_Y_ADDR_WIDTH_IN_HDR-Y_NODE_NUM_WIDTH)	
	`define Y_ADDR_STRT						`Y_ADDR_END-Y_NODE_NUM_WIDTH
	
	`define DES_X_ADDR_LOC					`X_ADDR_END-1		:	`X_ADDR_STRT	
	`define DES_Y_ADDR_LOC     			`Y_ADDR_END-1		:	`Y_ADDR_STRT	
	
	 
	 `define			HDR_FLIT								2'b10
	 `define			BODY_FLIT							2'b00
	 `define			TAIL_FLIT							2'b01
	 
	 
	 `define 			FLIT_HDR_FLG_LOC				 	FLIT_WIDTH-1
	 `define 			FLIT_TAIL_FLAG_LOC			 	FLIT_WIDTH-2
	 
	 `define 			FLIT_IN_VC_END						FLIT_WIDTH-FLIT_TYPE_WIDTH
	 `define 			FLIT_IN_VC_STRT					`FLIT_IN_VC_END				-	VC_NUM_PER_PORT
	
	 `define 			FLIT_IN_PORT_SEL_END				`FLIT_IN_VC_STRT			
	 `define 			FLIT_IN_PORT_SEL_STRT			`FLIT_IN_PORT_SEL_END		-	log2(PORT_NUM)
	 
	 `define 			FLIT_IN_X_DES_END					`FLIT_IN_PORT_SEL_STRT	- (`X_Y_ADDR_WIDTH_IN_HDR-X_NODE_NUM_WIDTH)
	 `define 			FLIT_IN_X_DES_STRT				`FLIT_IN_X_DES_END		-	X_NODE_NUM_WIDTH	
	
	 `define 			FLIT_IN_Y_DES_END					`FLIT_IN_X_DES_STRT		-	(`X_Y_ADDR_WIDTH_IN_HDR-Y_NODE_NUM_WIDTH)	
	 `define 			FLIT_IN_Y_DES_STRT				`FLIT_IN_Y_DES_END		-	Y_NODE_NUM_WIDTH	
	
	 `define 			FLIT_IN_X_SRC_END					`FLIT_IN_Y_DES_STRT		-	(`X_Y_ADDR_WIDTH_IN_HDR-X_NODE_NUM_WIDTH)	
	 `define 			FLIT_IN_X_SRC_STRT				`FLIT_IN_X_SRC_END		-	X_NODE_NUM_WIDTH		 
	 
	 `define 			FLIT_IN_Y_SRC_END					`FLIT_IN_X_SRC_STRT		-	(`X_Y_ADDR_WIDTH_IN_HDR-Y_NODE_NUM_WIDTH)	
	 `define				FLIT_IN_Y_SRC_STRT				`FLIT_IN_Y_SRC_END		-	Y_NODE_NUM_WIDTH 
	
	 `define				FLIT_IN_TYPE_LOC					`FLIT_HDR_FLG_LOC				:		`FLIT_TAIL_FLAG_LOC
	 `define 			FLIT_IN_VC_LOC						`FLIT_IN_VC_END-1				:		`FLIT_IN_VC_STRT		
	 `define 			FLIT_IN_PORT_SEL_LOC				`FLIT_IN_PORT_SEL_END-1		:		`FLIT_IN_PORT_SEL_STRT
	 
	 `define 			FLIT_IN_X_DES_LOC					`FLIT_IN_X_DES_END-1			:		`FLIT_IN_X_DES_STRT
	 `define 			FLIT_IN_Y_DES_LOC					`FLIT_IN_Y_DES_END-1			:		`FLIT_IN_Y_DES_STRT			
	
	 `define 			FLIT_IN_X_SRC_LOC					`FLIT_IN_X_SRC_END-1			:		`FLIT_IN_X_SRC_STRT	
	 `define 			FLIT_IN_Y_SRC_LOC					`FLIT_IN_Y_SRC_END-1			:		`FLIT_IN_Y_SRC_STRT			
	
	 `define 			FLIT_IN_DES_LOC					`FLIT_IN_PORT_SEL_STRT-1   : 		`FLIT_IN_Y_DES_STRT
	 `define 			FLIT_IN_SRC_LOC               `FLIT_IN_Y_DES_STRT-1		:     `FLIT_IN_Y_SRC_STRT	
	 
	`define 			FLIT_IN_PYLD_LOC					`FLIT_IN_PORT_SEL_END-1		:		0
	`define 			FLIT_IN_AFTER_PORT_LOC			`FLIT_IN_X_DES_END-1			:		0
	
	
	`define				FLIT_IN_WR_RAM_LOC				0				
	`define				FLIT_IN_ACK_REQ_LOC				1
	
	
	`define  START_LOC(port_num,width)	   (width*(port_num+1)-1)
	`define	END_LOC(port_num,width)			(width*port_num)
	`define	CORE_NUM(x,y) 						((y * X_NODE_NUM) +	x)
	`define  SELECT_WIRE(x,y,port,width)	`CORE_NUM(x,y)] [`START_LOC(port,width) : `END_LOC(port,width )
	
	`define	NI_RD_PCK_ADDR				0
	`define	NI_WR_PCK_ADDR				4
	`define	NI_STATUS_ADDR				8
	
	`define	NI_WR_DONE_LOC				0
	`define	NI_RD_DONE_LOC				1
	`define 	NI_RD_OVR_ERR_LOC			2
	`define	NI_RD_NPCK_ERR_LOC		3
	`define	NI_HAS_PCK_LOC				4
	`define  NI_ALL_VCS_FULL_LOC		5
	`define  NI_ISR_LOC					6
	
	`define	NI_PTR_WIDTH				19
	`define	NI_PCK_SIZE_WIDTH			13
	
		
	


 `define LOG2	function integer log2;\
      input integer number;	begin	\
         log2=0;	\
         while(2**log2<number) begin	\
            log2=log2+1;	\
         end	\
      end	\
   endfunction // log2 



`endif


