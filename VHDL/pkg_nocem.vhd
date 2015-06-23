
-----------------------------------------------------------------------------
-- NoCem -- Network on Chip Emulation Tool for System on Chip Research 
-- and Implementations
-- 
-- Copyright (C) 2006  Graham Schelle, Dirk Grunwald
-- 
-- This program is free software; you can redistribute it and/or
-- modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation; either version 2
-- of the License, or (at your option) any later version.
-- 
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  
-- 02110-1301, USA.
-- 
-- The authors can be contacted by email: <schelleg,grunwald>@cs.colorado.edu 
-- 
-- or by mail: Campus Box 430, Department of Computer Science,
-- University of Colorado at Boulder, Boulder, Colorado 80309
-------------------------------------------------------------------------------- 


-- 
-- Filename: pkg_nocem.vhd
-- 
-- Description: toplevel package file for nocem
-- 


--	THE Package File For NOCEM
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions.  Any design utilizing Nocem
--     must include this file....
--



library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


---------------------------------------------------------
---------------------------------------------------------
-- enumerations and derivative type definitions are 	 --
-- given here.  The values can be changed to change 	 --
-- the underlying functionality/performance of the NoC --
---------------------------------------------------------
---------------------------------------------------------


package pkg_nocem is 


-- enumerate the NOC types here
constant NOCEM_BUS_TYPE             		: integer := 0;
constant NOCEM_SIMPLE_PKT_TYPE      		: integer := 1;
constant NOCEM_SIMPLE_PKT_ARBSIZE_TYPE          : integer := 2;
constant NOCEM_VC_TYPE			      	: integer := 3;


-- enumerate channel FIFO types here
constant NOCEM_CHFIFO_NOVC_TYPE            : integer := 2;
constant NOCEM_CHFIFO_VC_TYPE              : integer := 3;


--enumerate FIFO implementation type here
-----------------------------------------------------------
--  WITHIN THE NOC CHANNELS CAN USE EITHER BRAM OR LUT   --
--  BASED FIFO IMPLEMENTATIONS.                          --
-----------------------------------------------------------
constant NOCEM_FIFO_LUT_TYPE             : integer := 0;



-- enumerate topology types here
--
-- MESH: connections in grid style, no torus
--
--
-- TORUS STRUCTURE: mesh connections plus connections looping
--                  top to bottom
--
--	DOUBLE TORUS STRUCTURE: torus structure plus connections
--                         looping left edge to right edge
--
constant NOCEM_TOPOLOGY_MESH   		: integer := 0;
constant NOCEM_TOPOLOGY_TORUS  		: integer := 1;
constant NOCEM_TOPOLOGY_DTORUS 		: integer := 2;








------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
-- system wide constants.  This is where the NoC is defined and these constants can		 --
-- can be changed and modified to change behavior of the network								 --
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------


constant NOCEM_TYPE        				: integer := NOCEM_CHFIFO_VC_TYPE;
constant NOCEM_CHFIFO_TYPE                              : integer := NOCEM_CHFIFO_VC_TYPE;
constant NOCEM_TOPOLOGY_TYPE				: integer := NOCEM_TOPOLOGY_MESH;
constant NOCEM_FIFO_IMPLEMENTATION			: integer := NOCEM_FIFO_LUT_TYPE;

constant NOCEM_NUM_AP 					: integer := 4;
constant NOCEM_NUM_COLS          			: integer := 2;
constant NOCEM_NUM_ROWS          			: integer := NOCEM_NUM_AP / NOCEM_NUM_COLS;

constant NOCEM_DW      					: integer := 8;
constant NOCEM_AW 	  				: integer := 2; 


constant NOCEM_NUM_VC 					: integer := 2;				  -- 2,4 VC's supported
constant NOCEM_VC_ID_WIDTH 				: integer := NOCEM_NUM_VC;   -- one hot encoding (do not change this!)

constant NOCEM_CHFIFO_DEPTH 				: integer := 4; -- MUST BE POWER OF 2 for LUTRAM,VC CHANNEL TYPES
constant NOCEM_MAX_PACKET_LENGTH			: integer := 8; -- MUST BE POWER OF 2 for LUTRAM,VC CHANNEL TYPES




--------------------------------------------------------------
-- channel indexing for a variety of arbitration decisions	--
--------------------------------------------------------------

constant NOCEM_NORTH_IX : integer := 4;
constant NOCEM_SOUTH_IX : integer := 3;
constant NOCEM_EAST_IX  : integer := 2;
constant NOCEM_WEST_IX  : integer := 1;
constant NOCEM_AP_IX    : integer := 0;

constant ARB_NORTH      	: std_logic_vector(4 downto 0) := "10000";
constant ARB_SOUTH 			: std_logic_vector(4 downto 0) := "01000";
constant ARB_EAST		 		: std_logic_vector(4 downto 0) := "00100";
constant ARB_WEST		 		: std_logic_vector(4 downto 0) := "00010";
constant ARB_AP		  		: std_logic_vector(4 downto 0) := "00001";
constant ARB_NODECISION	  	: std_logic_vector(4 downto 0) := "00000";
constant NOCEM_ARB_IX_SIZE : integer := 5;


------------------------------------------------------
--------------- STANDARD CHANNEL CONSTANTS -----------
------------------------------------------------------

constant NOCEM_CHFIFO_DATA_RE_IX 		: integer := 0;
constant NOCEM_CHFIFO_DATA_WE_IX 		: integer := 1;
constant NOCEM_CHFIFO_DATA_FULL_N_IX 	: integer := 2;
constant NOCEM_CHFIFO_DATA_EMPTY_N_IX 	: integer := 3;

constant NOCEM_CHFIFO_CNTRL_RE_IX 		: integer := 4;
constant NOCEM_CHFIFO_CNTRL_WE_IX 		: integer := 5;
constant NOCEM_CHFIFO_CNTRL_FULL_N_IX 	: integer := 6;
constant NOCEM_CHFIFO_CNTRL_EMPTY_N_IX : integer := 7;

constant NOCEM_CHFIFO_CNTRL_STANDARD_WIDTH : integer := NOCEM_CHFIFO_CNTRL_EMPTY_N_IX+1;

------------------------------------------------------
--------------- VC CHANNEL CONSTANTS -----------------
------------------------------------------------------

constant NOCEM_CHFIFO_VC_WR_ADDR_LIX  : integer 			:= NOCEM_CHFIFO_CNTRL_STANDARD_WIDTH;	  --8
constant NOCEM_CHFIFO_VC_WR_ADDR_HIX  : integer 			:= NOCEM_CHFIFO_VC_WR_ADDR_LIX+NOCEM_VC_ID_WIDTH-1;

constant NOCEM_CHFIFO_VC_CHDEST_LIX	  : integer 			:= NOCEM_CHFIFO_VC_WR_ADDR_HIX+1;--12		  --10
constant NOCEM_CHFIFO_VC_CHDEST_HIX	  : integer 			:= NOCEM_CHFIFO_VC_CHDEST_LIX+NOCEM_ARB_IX_SIZE-1;

constant NOCEM_CHFIFO_VC_VCDEST_LIX	  : integer 			:= NOCEM_CHFIFO_VC_CHDEST_HIX+1;		  --17		--15
constant NOCEM_CHFIFO_VC_VCDEST_HIX	  : integer 			:= NOCEM_CHFIFO_VC_VCDEST_LIX+NOCEM_VC_ID_WIDTH-1;

constant NOCEM_CHFIFO_VC_ALLOC_FROMNODE_LIX	 : integer 	:= NOCEM_CHFIFO_VC_VCDEST_HIX+1;			--21		  --17
constant NOCEM_CHFIFO_VC_ALLOC_FROMNODE_HIX	 : integer 	:= NOCEM_CHFIFO_VC_ALLOC_FROMNODE_LIX+NOCEM_VC_ID_WIDTH-1;

constant NOCEM_CHFIFO_VC_REQER_FROMNODE_LIX	 : integer 	:= NOCEM_CHFIFO_VC_ALLOC_FROMNODE_HIX+1;	 --25		 --19
constant NOCEM_CHFIFO_VC_REQER_FROMNODE_HIX	 : integer 	:= NOCEM_CHFIFO_VC_REQER_FROMNODE_LIX+NOCEM_VC_ID_WIDTH-1;

constant NOCEM_CHFIFO_VC_REQER_DEST_CH_LIX   : integer 	:= NOCEM_CHFIFO_VC_REQER_FROMNODE_HIX+1;	--29	--21
constant NOCEM_CHFIFO_VC_REQER_DEST_CH_HIX   : integer 	:= NOCEM_CHFIFO_VC_REQER_DEST_CH_LIX+NOCEM_ARB_IX_SIZE-1;

constant NOCEM_CHFIFO_VC_REQER_VCID_LIX	  : integer 	:= NOCEM_CHFIFO_VC_REQER_DEST_CH_HIX+1;		  --34	--26
constant NOCEM_CHFIFO_VC_REQER_VCID_HIX 	  : integer 	:= NOCEM_CHFIFO_VC_REQER_VCID_LIX+NOCEM_VC_ID_WIDTH-1;

constant NOCEM_CHFIFO_VC_EMPTY_LIX  	  : integer 		:= NOCEM_CHFIFO_VC_REQER_VCID_HIX+1;	--38	--28
constant NOCEM_CHFIFO_VC_EMPTY_HIX 	  : integer 			:= NOCEM_CHFIFO_VC_EMPTY_LIX+NOCEM_NUM_VC-1;

constant NOCEM_CHFIFO_VC_FULL_LIX  	  : integer 			:= NOCEM_CHFIFO_VC_EMPTY_HIX+1; --42		  --30
constant NOCEM_CHFIFO_VC_FULL_HIX 	  : integer 			:= NOCEM_CHFIFO_VC_FULL_LIX+NOCEM_NUM_VC-1;

constant NOCEM_CHFIFO_VC_EOP_RD_LIX		  : integer 		:= NOCEM_CHFIFO_VC_FULL_HIX+1; --46				--32
constant NOCEM_CHFIFO_VC_EOP_RD_HIX 	  	: integer 		:= NOCEM_CHFIFO_VC_EOP_RD_LIX+NOCEM_NUM_VC-1;

constant NOCEM_CHFIFO_VC_EOP_WR_LIX		  : integer 		:= NOCEM_CHFIFO_VC_EOP_RD_HIX+1;	  --50		  --34
constant NOCEM_CHFIFO_VC_EOP_WR_HIX 	  	: integer 		:= NOCEM_CHFIFO_VC_EOP_WR_LIX+NOCEM_NUM_VC-1;

constant NOCEM_CHFIFO_VC_RD_ADDR_LIX		  : integer 	:= NOCEM_CHFIFO_VC_EOP_WR_HIX+1;		 --54		  --36
constant NOCEM_CHFIFO_VC_RD_ADDR_HIX 	  	: integer 		:= NOCEM_CHFIFO_VC_RD_ADDR_LIX+NOCEM_VC_ID_WIDTH-1;

constant NOCEM_CHFIFO_VC_VCSRC_LIX	  : integer 			:= NOCEM_CHFIFO_VC_RD_ADDR_HIX+1; -- 58		 --38
constant NOCEM_CHFIFO_VC_VCSRC_HIX	  : integer 			:= NOCEM_CHFIFO_VC_VCSRC_LIX+NOCEM_VC_ID_WIDTH-1; 



constant NOCEM_CHFIFO_CNTRL_WIDTH : integer 					:= NOCEM_CHFIFO_VC_VCSRC_HIX+1; --62		 --40



--------------------------------------------------------------------------------
-- constants that have their usage defined by the underlying noc.					--
--------------------------------------------------------------------------------

-- depending on what is in the control packet, can set an arbitrary width
-- e.g. for simple packets, dest_addr/SOP/EOP are all that is needed and are
-- both placed in a single word



-- pkt control structure
constant NOCEM_PKTCNTRL_DEST_ADDR_LIX  : integer := 0;
constant NOCEM_PKTCNTRL_DEST_ADDR_HIX  : integer := NOCEM_AW-1;				--1
constant NOCEM_PKTCNTRL_SOP_IX 			: integer := NOCEM_PKTCNTRL_DEST_ADDR_HIX+1;	--2
constant NOCEM_PKTCNTRL_EOP_IX 			: integer := NOCEM_PKTCNTRL_SOP_IX+1;	--3
constant NOCEM_PKTCNTRL_OS_PKT_IX		: integer := NOCEM_PKTCNTRL_EOP_IX+1;


constant NOCEM_PKT_CNTRL_WIDTH 			: integer := NOCEM_PKTCNTRL_OS_PKT_IX+1;	 	--4




constant NOCEM_ARB_CNTRL_VC_MUX_WR_LIX	: integer := 0;														  
constant NOCEM_ARB_CNTRL_VC_MUX_WR_HIX	: integer := NOCEM_ARB_CNTRL_VC_MUX_WR_LIX+NOCEM_VC_ID_WIDTH-1;

constant NOCEM_ARB_CNTRL_VC_MUX_RD_LIX	: integer := NOCEM_ARB_CNTRL_VC_MUX_WR_HIX+1;	--4 --2													  
constant NOCEM_ARB_CNTRL_VC_MUX_RD_HIX	: integer := NOCEM_ARB_CNTRL_VC_MUX_RD_LIX+NOCEM_VC_ID_WIDTH-1;


constant NOCEM_ARB_CNTRL_VC_EOP_RD_LIX : integer := NOCEM_ARB_CNTRL_VC_MUX_RD_HIX+1;	--8  --4
constant NOCEM_ARB_CNTRL_VC_EOP_RD_HIX : integer := NOCEM_ARB_CNTRL_VC_EOP_RD_LIX+NOCEM_NUM_VC-1;

constant NOCEM_ARB_CNTRL_VC_EOP_WR_LIX : integer := NOCEM_ARB_CNTRL_VC_EOP_RD_HIX+1;	--12	--6
constant NOCEM_ARB_CNTRL_VC_EOP_WR_HIX : integer := NOCEM_ARB_CNTRL_VC_EOP_WR_LIX+NOCEM_NUM_VC-1;

constant NOCEM_ARB_CNTRL_WIDTH 			: integer := NOCEM_ARB_CNTRL_VC_EOP_WR_HIX+1;






--------------------------------------------------------------------------------
--These are the various subtypes that are used to easily index multibit words	--
--that are needed within nocem.  They are also used on interfaces to the 		--
--toplevel nocem instantiation																--
--------------------------------------------------------------------------------

subtype pkt_cntrl_word is std_logic_vector(NOCEM_PKT_CNTRL_WIDTH-1 downto 0);
type pkt_cntrl_array  is array(natural range <>) of pkt_cntrl_word;

subtype data_word is std_logic_vector(NOCEM_DW-1 downto 0);
type data_array  is array(natural range <>) of data_word;

subtype arb_cntrl_word is std_logic_vector(NOCEM_ARB_CNTRL_WIDTH-1 downto 0);
type arb_cntrl_array  is array(natural range <>) of arb_cntrl_word;

subtype channel_cntrl_word is std_logic_vector(NOCEM_CHFIFO_CNTRL_WIDTH-1 downto 0);
type channel_cntrl_array  is array(natural range <>) of channel_cntrl_word;

subtype node_addr_word is std_logic_vector(NOCEM_AW-1 downto 0);
type node_addr_array  is array(natural range <>) of node_addr_word;

subtype arb_decision is std_logic_vector(NOCEM_ARB_IX_SIZE-1 downto 0);
type arb_decision_array  is array(natural range <>) of arb_decision;

subtype vc_addr_word is std_logic_vector(NOCEM_VC_ID_WIDTH-1 downto 0);
type vc_addr_array  is array(natural range <>) of vc_addr_word;








--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--  components used in nocem, including the bridges									--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


component fifo_fwft_bram_nfc_v5
	port (
	din: IN std_logic_VECTOR(31 downto 0);
	rd_clk: IN std_logic;
	rd_en: IN std_logic;
	rst: IN std_logic;
	wr_clk: IN std_logic;
	wr_en: IN std_logic;
	dout: OUT std_logic_VECTOR(31 downto 0);
	empty: OUT std_logic;
	full: OUT std_logic);
end component;

component fifo_fwft_bram_v5
	port (
	clk: IN std_logic;
	din: IN std_logic_VECTOR(31 downto 0);
	rd_en: IN std_logic;
	rst: IN std_logic;
	wr_en: IN std_logic;
	dout: OUT std_logic_VECTOR(31 downto 0);
	empty: OUT std_logic;
	full: OUT std_logic);
end component;

component fifo_fwft_bram_v2p
	port (
	din: IN std_logic_VECTOR(31 downto 0);
	rd_clk: IN std_logic;
	rd_en: IN std_logic;
	rst: IN std_logic;
	wr_clk: IN std_logic;
	wr_en: IN std_logic;
	dout: OUT std_logic_VECTOR(31 downto 0);
	empty: OUT std_logic;
	full: OUT std_logic);
end component;

component fifo_fwft_bram
	port (
	din: IN std_logic_VECTOR(31 downto 0);
	rd_clk: IN std_logic;
	rd_en: IN std_logic;
	rst: IN std_logic;
	wr_clk: IN std_logic;
	wr_en: IN std_logic;
	dout: OUT std_logic_VECTOR(31 downto 0);
	empty: OUT std_logic;
	full: OUT std_logic);
end component;


	COMPONENT noc2proc_bridge2
  generic
  (
    C_AWIDTH                       : integer              := 32;
    C_DWIDTH                       : integer              := 64;
    C_NUM_CS                       : integer              := 1;
    C_NUM_CE                       : integer              := 2;
    C_IP_INTR_NUM                  : integer              := 1
  );
  port
  (
		noc_arb_req         : out  std_logic;
		noc_arb_cntrl_out       : out  arb_cntrl_word;
		noc_arb_grant       : in  std_logic;
		noc_arb_cntrl_in        : in  arb_cntrl_word;		
		noc_datain        : in   std_logic_vector(NOCEM_DW-1 downto 0);
		noc_datain_valid  : in   std_logic;
		noc_datain_recvd  : out  std_logic;
		noc_dataout       : out std_logic_vector(NOCEM_DW-1 downto 0);
		noc_dataout_valid : out std_logic;
		noc_dataout_recvd : in  std_logic;
		noc_pkt_cntrl_in        : in   pkt_cntrl_word;
		noc_pkt_cntrl_in_valid  : in   std_logic;
		noc_pkt_cntrl_in_recvd  : out  std_logic;                  
		noc_pkt_cntrl_out       : out pkt_cntrl_word;
		noc_pkt_cntrl_out_valid : out std_logic;
		noc_pkt_cntrl_out_recvd : in  std_logic;
		Bus2IP_Clk                     : in  std_logic;
		Bus2IP_Reset                   : in  std_logic;
		IP2Bus_IntrEvent               : out std_logic_vector(0 to C_IP_INTR_NUM-1);
		Bus2IP_Addr                    : in  std_logic_vector(0 to C_AWIDTH-1);
		Bus2IP_Data                    : in  std_logic_vector(0 to C_DWIDTH-1);
		Bus2IP_BE                      : in  std_logic_vector(0 to C_DWIDTH/8-1);
		Bus2IP_Burst                   : in  std_logic;
		Bus2IP_CS                      : in  std_logic_vector(0 to C_NUM_CS-1);
		Bus2IP_CE                      : in  std_logic_vector(0 to C_NUM_CE-1);
		Bus2IP_RdCE                    : in  std_logic_vector(0 to C_NUM_CE-1);
		Bus2IP_WrCE                    : in  std_logic_vector(0 to C_NUM_CE-1);
		Bus2IP_RdReq                   : in  std_logic;
		Bus2IP_WrReq                   : in  std_logic;
		IP2Bus_Data                    : out std_logic_vector(0 to C_DWIDTH-1);
		IP2Bus_Retry                   : out std_logic;
		IP2Bus_Error                   : out std_logic;
		IP2Bus_ToutSup                 : out std_logic;
		IP2Bus_RdAck                   : out std_logic;
		IP2Bus_WrAck                   : out std_logic

	);	
  END COMPONENT;




	COMPONENT vc_node_ch_arbiter
    Port ( 
		-- needed to mux outputs for the accompanying switch
 		arb_grant_output : out arb_decision_array(4 downto 0);
	   n_channel_cntrl_in  : in channel_cntrl_word;
	   n_channel_cntrl_out : out channel_cntrl_word;
	   s_channel_cntrl_in  : in channel_cntrl_word;
	   s_channel_cntrl_out : out channel_cntrl_word;
	   e_channel_cntrl_in  : in channel_cntrl_word;
	   e_channel_cntrl_out : out channel_cntrl_word;
	   w_channel_cntrl_in  : in channel_cntrl_word;
	   w_channel_cntrl_out : out channel_cntrl_word;
	   ap_channel_cntrl_in  : in channel_cntrl_word;
	   ap_channel_cntrl_out : out channel_cntrl_word;	 
	   clk : in std_logic;
      rst : in std_logic		
		);
	END COMPONENT;


	COMPONENT vc_node_vc_allocator
    Port ( 
		local_ch_addr : in std_logic_vector(4 downto 0);
		outoing_vc_status : in std_logic_vector(NOCEM_NUM_VC-1 downto 0);
	   n_channel_cntrl_in  : in channel_cntrl_word;
	   n_channel_cntrl_out : out channel_cntrl_word;
	   s_channel_cntrl_in  : in channel_cntrl_word;
	   s_channel_cntrl_out : out channel_cntrl_word;
	   e_channel_cntrl_in  : in channel_cntrl_word;
	   e_channel_cntrl_out : out channel_cntrl_word;
	   w_channel_cntrl_in  : in channel_cntrl_word;
	   w_channel_cntrl_out : out channel_cntrl_word;
	   ap_channel_cntrl_in  : in channel_cntrl_word;
	   ap_channel_cntrl_out : out channel_cntrl_word;	 
	   clk : in std_logic;
      rst : in std_logic		
		);
	END COMPONENT;

	COMPONENT mux2to1
		generic (
			DWIDTH : integer;
			REG_OUTPUT : integer
		);
		port (
			din0 : in std_logic_vector( DWIDTH-1 downto 0);
			din1 : in std_logic_vector( DWIDTH-1 downto 0);
			sel  : in std_logic_vector( 1 downto 0);
			dout : out std_logic_vector( DWIDTH-1 downto 0);

			clk : in std_logic;
			rst : in std_logic
		);	
	END COMPONENT;

	COMPONENT mux4to1
		generic (
			DWIDTH : integer;
			REG_OUTPUT : integer
		);	
		port (
			din0 : in std_logic_vector( DWIDTH-1 downto 0);
			din1 : in std_logic_vector( DWIDTH-1 downto 0);
			din2 : in std_logic_vector( DWIDTH-1 downto 0);
			din3 : in std_logic_vector( DWIDTH-1 downto 0);
			sel  : in std_logic_vector( 3 downto 0);
			dout : out std_logic_vector( DWIDTH-1 downto 0);
			clk : in std_logic;
			rst : in std_logic
		);
	END COMPONENT;


	COMPONENT xto1_arbiter
	Generic (
		NUM_REQS   : integer;
		REG_OUTPUT : integer
	 );
    Port ( 
	   arb_req : in std_logic_vector(NUM_REQS-1 downto 0);
  		arb_grant : out std_logic_vector(NUM_REQS-1 downto 0);
	   clk : in std_logic;
  		rst : in std_logic);
	END COMPONENT;

	COMPONENT vc_controller
    Port ( 
		vc_my_id : in std_logic_vector(NOCEM_VC_ID_WIDTH-1 downto 0); -- should be tied to constant
		node_my_id : in std_logic_vector(NOCEM_AW-1 downto 0);
		pkt_cntrl_rd : in pkt_cntrl_word;
		pkt_cntrl_wr : in pkt_cntrl_word;
		pkt_re : in std_logic;
		pkt_we : in std_logic;
		vc_fifo_empty : in std_logic;
		vc_eop_rd_status : out std_logic;		  -- 0: no eop with rden, 1: eop and rden
 		vc_eop_wr_status  : out std_logic;		  -- 0: no eop with wren, 1: eop and wren
		vc_allocation_req : out std_logic;
		vc_req_id : out std_logic_vector(NOCEM_VC_ID_WIDTH-1 downto 0);
		vc_allocate_from_node : in std_logic_vector(NOCEM_VC_ID_WIDTH-1 downto 0);
		vc_requester_from_node : in std_logic_vector(NOCEM_VC_ID_WIDTH-1 downto 0);
		channel_dest : out arb_decision;
		vc_dest : out std_logic_vector(NOCEM_VC_ID_WIDTH-1 downto 0);
		vc_switch_req : out std_logic;	
		rst : in std_logic;
	 	clk : in std_logic
	 );
	END COMPONENT;


	COMPONENT vc_channel
		Generic (
			  IS_AN_ACCESS_POINT_CHANNEL : boolean
	 	);
		port (

			  node_dest_id	: in node_addr_word;
			  vc_mux_wr : in std_logic_vector(NOCEM_NUM_VC-1 downto 0);
	 		  vc_mux_rd : in std_logic_vector(NOCEM_NUM_VC-1 downto 0);
           wr_pkt_cntrl : in std_logic_vector(NOCEM_PKT_CNTRL_WIDTH-1 downto 0);
           wr_pkt_data  : in std_logic_vector(NOCEM_DW-1 downto 0);
           rd_pkt_cntrl : out std_logic_vector(NOCEM_PKT_CNTRL_WIDTH-1 downto 0);
           rd_pkt_data  : out std_logic_vector(NOCEM_DW-1 downto 0);
			  rd_pkt_chdest : out std_logic_vector(NOCEM_ARB_IX_SIZE-1 downto 0);
			  rd_pkt_vcdest : out vc_addr_word;
			  rd_pkt_vcsrc  : out vc_addr_word;
			  vc_allocate_from_node	    : in vc_addr_word;
	        vc_requester_from_node	 : in vc_addr_word;
			  vc_eop_rd_status 	: out std_logic_vector(NOCEM_NUM_VC-1 downto 0);
			  vc_eop_wr_status 	: out std_logic_vector(NOCEM_NUM_VC-1 downto 0);
			  vc_allocate_destch_to_node	    : out std_logic_vector(NOCEM_ARB_IX_SIZE-1 downto 0);
	        vc_requester_to_node	          : out vc_addr_word;				
			  vc_empty		: out std_logic_vector(NOCEM_NUM_VC-1 downto 0);
			  vc_full		: out std_logic_vector(NOCEM_NUM_VC-1 downto 0);
			  RE : in std_logic;
			  WE : in std_logic;
			  clk : in std_logic;
			  rst : in std_logic
		);
	END COMPONENT;


	COMPONENT vc_channel_destap
		port (
			  node_dest_id	: in node_addr_word;
			  vc_mux_wr : in std_logic_vector(NOCEM_NUM_VC-1 downto 0);
			  vc_mux_rd : IN std_logic_vector(NOCEM_NUM_VC-1 downto 0);
           wr_pkt_cntrl : in std_logic_vector(NOCEM_PKT_CNTRL_WIDTH-1 downto 0);
           wr_pkt_data  : in std_logic_vector(NOCEM_DW-1 downto 0);
           rd_pkt_cntrl : out std_logic_vector(NOCEM_PKT_CNTRL_WIDTH-1 downto 0);
           rd_pkt_data  : out std_logic_vector(NOCEM_DW-1 downto 0);
			  rd_pkt_chdest : out std_logic_vector(NOCEM_ARB_IX_SIZE-1 downto 0);
			  rd_pkt_vcdest : out vc_addr_word;
			  rd_pkt_vcsrc  : out vc_addr_word;
			  vc_allocate_from_node	    : in vc_addr_word;
	        vc_requester_from_node	 : in vc_addr_word;
			  vc_eop_rd_status 	: out std_logic_vector(NOCEM_NUM_VC-1 downto 0);
			  vc_eop_wr_status 	: out std_logic_vector(NOCEM_NUM_VC-1 downto 0);
			  vc_allocate_destch_to_node	    : out std_logic_vector(NOCEM_ARB_IX_SIZE-1 downto 0);
	        vc_requester_to_node	          : out vc_addr_word;					
			  vc_empty		: out std_logic_vector(NOCEM_NUM_VC-1 downto 0);
			  vc_full		: out std_logic_vector(NOCEM_NUM_VC-1 downto 0);
			  RE : in std_logic;
			  WE : in std_logic;
			  clk : in std_logic;
			  rst : in std_logic
		);
	END COMPONENT;



	COMPONENT vc_node
    Port ( 
		local_arb_addr : std_logic_vector(NOCEM_AW-1 downto 0);
	   n_datain : in data_word;
	   n_pkt_cntrl_in : in pkt_cntrl_word;
	   n_dataout : out data_word;
	   n_pkt_cntrl_out : out pkt_cntrl_word;
	   n_channel_cntrl_in  : in channel_cntrl_word;
	   n_channel_cntrl_out : out channel_cntrl_word;
	   s_datain : in data_word;
	   s_pkt_cntrl_in : in pkt_cntrl_word;
	   s_dataout : out data_word;
	   s_pkt_cntrl_out : out pkt_cntrl_word;
	   s_channel_cntrl_in  : in channel_cntrl_word;
	   s_channel_cntrl_out : out channel_cntrl_word;
	   e_datain : in data_word;
	   e_pkt_cntrl_in : in pkt_cntrl_word;
	   e_dataout : out data_word;
	   e_pkt_cntrl_out : out pkt_cntrl_word;
	   e_channel_cntrl_in  : in channel_cntrl_word;
	   e_channel_cntrl_out : out channel_cntrl_word;
	   w_datain : in data_word;
	   w_pkt_cntrl_in : in pkt_cntrl_word;
	   w_dataout : out data_word;
	   w_pkt_cntrl_out : out pkt_cntrl_word;
	   w_channel_cntrl_in  : in channel_cntrl_word;
	   w_channel_cntrl_out : out channel_cntrl_word;
	   ap_datain : in data_word;
	   ap_pkt_cntrl_in : in pkt_cntrl_word;
	   ap_dataout : out data_word;
	   ap_pkt_cntrl_out : out pkt_cntrl_word;
	   ap_channel_cntrl_in  : in channel_cntrl_word;
	   ap_channel_cntrl_out : out channel_cntrl_word;	 
	   clk : in std_logic;
      rst : in std_logic		
		);
	END COMPONENT;

--	COMPONENT noc2proc_bridge
--  generic
--  (
--
--    NOC_ADDR_WIDTH						   : integer			:= 4;
--	 NOC_ARB_CNTRL_WIDTH						: integer			:= 4;
--	 NOC_DATA_WIDTH						   : integer			:= 16;
--	 NOC_PKT_CNTRL_WIDTH						: integer			:= 4;
--
--    C_AWIDTH                       : integer              := 32;
--    C_DWIDTH                       : integer              := 64;
--    C_NUM_CS                       : integer              := 1;
--    C_NUM_CE                       : integer              := 2;
--    C_IP_INTR_NUM                  : integer              := 1
--
--  );
--  port
--  (
--		noc_arb_req         : out  std_logic;
--		noc_arb_cntrl_req   : out  std_logic_vector(NOC_ARB_CNTRL_WIDTH-1 downto 0);
--
--		noc_arb_grant         : in std_logic;
--		noc_arb_cntrl_grant   : in  std_logic_vector(NOC_ARB_CNTRL_WIDTH-1 downto 0);
--		
--		noc_datain        : in   std_logic_vector(NOC_DATA_WIDTH-1 downto 0);
--		noc_datain_valid  : in   std_logic;
--		noc_datain_recvd  : out  std_logic;
--
--		noc_dataout       : out std_logic_vector(NOC_DATA_WIDTH-1 downto 0);
--		noc_dataout_valid : out std_logic;
--		noc_dataout_recvd : in  std_logic;
--
--		noc_pkt_cntrl_in        : in   std_logic_vector(NOC_PKT_CNTRL_WIDTH-1 downto 0);
--		noc_pkt_cntrl_in_valid  : in   std_logic;
--		noc_pkt_cntrl_in_recvd  : out  std_logic;      
--             
--		noc_pkt_cntrl_out       : out std_logic_vector(NOC_PKT_CNTRL_WIDTH-1 downto 0);
--		noc_pkt_cntrl_out_valid : out std_logic;
--		noc_pkt_cntrl_out_recvd : in  std_logic;
--
--
--    Bus2IP_Clk                     : in  std_logic;
--    Bus2IP_Reset                   : in  std_logic;
--    IP2Bus_IntrEvent               : out std_logic_vector(0 to C_IP_INTR_NUM-1);
--    Bus2IP_Addr                    : in  std_logic_vector(0 to C_AWIDTH-1);
--    Bus2IP_Data                    : in  std_logic_vector(0 to C_DWIDTH-1);
--    Bus2IP_BE                      : in  std_logic_vector(0 to C_DWIDTH/8-1);
--    Bus2IP_Burst                   : in  std_logic;
--    Bus2IP_CS                      : in  std_logic_vector(0 to C_NUM_CS-1);
--    Bus2IP_CE                      : in  std_logic_vector(0 to C_NUM_CE-1);
--    Bus2IP_RdCE                    : in  std_logic_vector(0 to C_NUM_CE-1);
--    Bus2IP_WrCE                    : in  std_logic_vector(0 to C_NUM_CE-1);
--    Bus2IP_RdReq                   : in  std_logic;
--    Bus2IP_WrReq                   : in  std_logic;
--    IP2Bus_Data                    : out std_logic_vector(0 to C_DWIDTH-1);
--    IP2Bus_Retry                   : out std_logic;
--    IP2Bus_Error                   : out std_logic;
--    IP2Bus_ToutSup                 : out std_logic;
--    IP2Bus_RdAck                   : out std_logic;
--    IP2Bus_WrAck                   : out std_logic;
--    Bus2IP_MstError                : in  std_logic;
--    Bus2IP_MstLastAck              : in  std_logic;
--    Bus2IP_MstRdAck                : in  std_logic;
--    Bus2IP_MstWrAck                : in  std_logic;
--    Bus2IP_MstRetry                : in  std_logic;
--    Bus2IP_MstTimeOut              : in  std_logic;
--    IP2Bus_Addr                    : out std_logic_vector(0 to C_AWIDTH-1);
--    IP2Bus_MstBE                   : out std_logic_vector(0 to C_DWIDTH/8-1);
--    IP2Bus_MstBurst                : out std_logic;
--    IP2Bus_MstBusLock              : out std_logic;
--    IP2Bus_MstNum                  : out std_logic_vector(0 to 4);
--    IP2Bus_MstRdReq                : out std_logic;
--    IP2Bus_MstWrReq                : out std_logic;
--    IP2IP_Addr                     : out std_logic_vector(0 to C_AWIDTH-1)
--  );
--	END COMPONENT;
--




--	COMPONENT packet_buffer
--   generic(
--	 DATAIN_WIDTH : integer := 64;
--	 DATAOUT_WIDTH : integer := 32
--	);	
--	port (
--		din: IN std_logic_VECTOR(DATAIN_WIDTH-1 downto 0);
--		clk: IN std_logic;
--		rd_en: IN std_logic;
--		rst: IN std_logic;
--		wr_en : IN std_logic;
--		dout: OUT std_logic_VECTOR(DATAOUT_WIDTH-1 downto 0);
--		empty: OUT std_logic;
--		full: OUT std_logic;
--		wr_ack : out std_logic;
--		pkt_len : in std_logic_vector(7 downto 0);
--		pkt_metadata_din 		: in std_logic_vector(255 downto 0);		
--		pkt_metadata_re		: IN std_logic;				
--		pkt_metadata_we		: IN std_logic;
--		pkt_metadata_dout 	: out std_logic_vector(255 downto 0);
--		pkt_metadata_empty	: out std_logic;
--		pkt_metadata_full		: out std_logic
--	
--	);
--	END COMPONENT;


--
--	COMPONENT nocem_net_layer
--    Port ( 
--		noc_arb_req         : out  std_logic;
--		noc_arb_cntrl_req   : out  arb_cntrl_word;
--		noc_arb_grant         : in std_logic;
--		noc_arb_cntrl_grant   : in  arb_cntrl_word;		
--		noc_datain        : in   data_word;
--		noc_datain_valid  : in   std_logic;
--		noc_datain_recvd  : out  std_logic;
--		noc_dataout       : out data_word;
--		noc_dataout_valid : out std_logic;
--		noc_dataout_recvd : in  std_logic;
--		noc_pkt_cntrl_in        : in   pkt_cntrl_word;
--		noc_pkt_cntrl_in_valid  : in   std_logic;
--		noc_pkt_cntrl_in_recvd  : out  std_logic;                   
--		noc_pkt_cntrl_out       : out pkt_cntrl_word;
--		noc_pkt_cntrl_out_valid : out std_logic;
--		noc_pkt_cntrl_out_recvd : in  std_logic;
--		ip2noc_addr 			: in std_logic_vector(NOCEM_AW-1 downto 0);
--		ip2noc_packet_len 	: in std_logic_vector(7 downto 0);
--		ip2noc_pkt_cntrl_we	: in std_logic;
--		ip2noc_packet 			: in std_logic_vector(63 downto 0);
--		ip2noc_packet_we 		: in std_logic;
--		ip2noc_pb_rdy  		: out std_logic;
--		noc2ip_addr 			: out std_logic_vector(NOCEM_AW-1 downto 0);
--		noc2ip_packet_len 	: out std_logic_vector(7 downto 0);
--		noc2ip_pkt_cntrl_re	: in std_logic;
--		noc2ip_packet 			: out std_logic_vector(63 downto 0);
--		noc2ip_packet_re 		: in std_logic;
--		noc2ip_pb_rdy  		: out std_logic;
--		clk : in std_logic;
--      rst : in std_logic				
--		);
--	END COMPONENT;





	COMPONENT nocem
   Port( 
		arb_req         : in  std_logic_vector(NOCEM_NUM_AP-1 downto 0);
		arb_cntrl_in   : in  arb_cntrl_array(NOCEM_NUM_AP-1 downto 0);
		arb_grant         : out std_logic_vector(NOCEM_NUM_AP-1 downto 0);
		arb_cntrl_out   : out  arb_cntrl_array(NOCEM_NUM_AP-1 downto 0);
		datain        : in   data_array(NOCEM_NUM_AP-1 downto 0);
		datain_valid  : in   std_logic_vector(NOCEM_NUM_AP-1 downto 0);
		datain_recvd  : out  std_logic_vector(NOCEM_NUM_AP-1 downto 0);
		dataout       : out data_array(NOCEM_NUM_AP-1 downto 0);
		dataout_valid : out std_logic_vector(NOCEM_NUM_AP-1 downto 0);
		dataout_recvd : in  std_logic_vector(NOCEM_NUM_AP-1 downto 0);
		pkt_cntrl_in        : in   pkt_cntrl_array(NOCEM_NUM_AP-1 downto 0);
		pkt_cntrl_in_valid  : in   std_logic_vector(NOCEM_NUM_AP-1 downto 0);
		pkt_cntrl_in_recvd  : out  std_logic_vector(NOCEM_NUM_AP-1 downto 0);                  
		pkt_cntrl_out       : out pkt_cntrl_array(NOCEM_NUM_AP-1 downto 0);
		pkt_cntrl_out_valid : out std_logic_vector(NOCEM_NUM_AP-1 downto 0);
		pkt_cntrl_out_recvd : in  std_logic_vector(NOCEM_NUM_AP-1 downto 0);
		clk : in std_logic;
      rst : in std_logic		
	);
	END COMPONENT;


constant EXERCISER_MODE_SIM        : integer := 0;
constant EXERCISER_MODE_IMPLEMENT1 : integer := 0;


	COMPONENT ap_exerciser_vc
	Generic(

		DELAY_START_COUNTER_WIDTH 		: integer := 32;
		DELAY_START_CYCLES 				: integer := 500;
		PKT_LENGTH 							: integer := 5;
		INTERVAL_COUNTER_WIDTH 			: integer := 8;
		DATA_OUT_INTERVAL 				: integer := 16;
	   INIT_DEST_ADDR 					: integer := 2;
		MY_ADDR 								: integer := 0;
		EXERCISER_MODE						: integer := EXERCISER_MODE_SIM			 
		 )	;
    Port ( 
		arb_req         : out  std_logic;
		arb_cntrl_out   : out  arb_cntrl_word;
		arb_grant         : in std_logic;
		arb_cntrl_in      : in  arb_cntrl_word;		
		datain        : in   data_word;
		datain_valid  : in   std_logic;
		datain_recvd  : out  std_logic;
		dataout       : out data_word;
		dataout_valid : out std_logic;
		dataout_recvd : in  std_logic;
		pkt_cntrl_in        : in   pkt_cntrl_word;
		pkt_cntrl_in_valid  : in   std_logic;
		pkt_cntrl_in_recvd  : out  std_logic;                  
		pkt_cntrl_out       : out pkt_cntrl_word;
		pkt_cntrl_out_valid : out std_logic;
		pkt_cntrl_out_recvd : in  std_logic;
		clk : in std_logic;
      rst : in std_logic		
		
		);
	END COMPONENT;


	COMPONENT access_point_exerciser
	Generic(
		DELAY_START_COUNTER_WIDTH: integer;
		DELAY_START_CYCLES: integer;
		BURST_LENGTH: integer;
		INIT_DATA_OUT : data_word;
		INTERVAL_COUNTER_WIDTH: integer;
		DATA_OUT_INTERVAL : integer;
	   INIT_DEST_ADDR : integer
		 )	;
    Port ( 
	 
		-- arbitration lines (usage depends on underlying network)
		arb_req         : out  std_logic;
		arb_cntrl_out   : out  arb_cntrl_word;
		arb_grant         : in std_logic;
		arb_cntrl_in   : in  arb_cntrl_word;		
		datain        : in   data_word;
		datain_valid  : in   std_logic;
		datain_recvd  : out  std_logic;
		dataout       : out data_word;
		dataout_valid : out std_logic;
		dataout_recvd : in  std_logic;
		pkt_cntrl_in        : in   pkt_cntrl_word;
		pkt_cntrl_in_valid  : in   std_logic;
		pkt_cntrl_in_recvd  : out  std_logic;                  
		pkt_cntrl_out       : out pkt_cntrl_word;
		pkt_cntrl_out_valid : out std_logic;
		pkt_cntrl_out_recvd : in  std_logic;
		clk : in std_logic;
      rst : in std_logic		
		
		);
	END COMPONENT;





	COMPONENT channel_fifo
		generic (
		  P0_NODE_ADDR : integer;
		  P1_NODE_ADDR : integer;
		  IS_AN_ACCESS_POINT_CHANNEL : boolean
		);
		port (
		   p0_datain : in data_word;
		   p0_pkt_cntrl_in : in pkt_cntrl_word;
		   p0_dataout : out data_word;
		   p0_pkt_cntrl_out : out pkt_cntrl_word;
		   p0_channel_cntrl_in  : in channel_cntrl_word;
		   p0_channel_cntrl_out : out channel_cntrl_word;
		   p1_datain : in data_word;
		   p1_pkt_cntrl_in : in pkt_cntrl_word;
		   p1_dataout : out data_word;
		   p1_pkt_cntrl_out : out pkt_cntrl_word;
		   p1_channel_cntrl_in  : in channel_cntrl_word;
		   p1_channel_cntrl_out : out channel_cntrl_word;   
			clk: IN std_logic;   
			rst: IN std_logic      
	   );
	END COMPONENT;

	COMPONENT channel_fifo_reg
	PORT(
		clk : IN std_logic;
		din : IN std_logic_vector(255 downto 0);
		rd_en : IN std_logic;
		rst : IN std_logic;
		wr_en : IN std_logic;          
		dout : OUT std_logic_vector(255 downto 0);
		empty : OUT std_logic;
		full : OUT std_logic
		);
	END COMPONENT;


COMPONENT fifo_allvhdl
	GENERIC(	
		WIDTH : integer;
		ADDR_WIDTH : integer
	);
	PORT(
			din : in std_logic_vector(WIDTH-1 downto 0);  -- Input data
			dout : out std_logic_vector(WIDTH-1 downto 0);  -- Output data
			clk : in std_logic;  		-- System Clock
			rst : in std_logic;  	-- System global Reset
			rd_en : in std_logic;  		-- Read Enable
			wr_en : in std_logic;  		-- Write Enable
			full : out std_logic;  	-- Full Flag
			empty : out std_logic	-- Empty Flag
		);
END COMPONENT;



	COMPONENT fifo_gfs
	generic (
		WIDTH : integer;  	-- FIFO word width
		ADD_WIDTH : integer	-- Address Width
		); 

	PORT(
		Data_in : IN std_logic_vector(WIDTH-1 downto 0);
		clk : IN std_logic;
		Reset : IN std_logic;
		RE : IN std_logic;
		WE : IN std_logic;          
		Data_out : OUT std_logic_vector(WIDTH-1 downto 0);
		Full : OUT std_logic;
		Half_full : OUT std_logic;
		empty : OUT std_logic
		);	
	END COMPONENT;


COMPONENT ic_bus_nocem
	Port ( 

		arb_grant : in std_logic_vector(NOCEM_NUM_AP-1 downto 0);

		--data and addr incoming/outgoing line (usage depends on underlying network)
		datain        : in   data_array(NOCEM_NUM_AP-1 downto 0);
		dataout       : out data_array(NOCEM_NUM_AP-1 downto 0);

		dataout_valid : out std_logic_vector(NOCEM_NUM_AP-1 downto 0);

		addrin  : in   pkt_cntrl_array(NOCEM_NUM_AP-1 downto 0);
		addrout : out  pkt_cntrl_array(NOCEM_NUM_AP-1 downto 0);

		addrout_valid : out std_logic_vector(NOCEM_NUM_AP-1 downto 0);	
	
	 	clk : in std_logic;
    	rst : in std_logic
		
		
		
	);
END COMPONENT;


COMPONENT simple_pkt_node
	port (
	local_arb_addr : std_logic_vector(NOCEM_AW-1 downto 0);
   n_datain : in data_word;
   n_pkt_cntrl_in : in pkt_cntrl_word;
   n_dataout : out data_word;
   n_pkt_cntrl_out : out pkt_cntrl_word;
   n_channel_cntrl_in  : in channel_cntrl_word;
   n_channel_cntrl_out : out channel_cntrl_word;
   s_datain : in data_word;
   s_pkt_cntrl_in : in pkt_cntrl_word;
   s_dataout : out data_word;
   s_pkt_cntrl_out : out pkt_cntrl_word;
   s_channel_cntrl_in  : in channel_cntrl_word;
   s_channel_cntrl_out : out channel_cntrl_word;
   e_datain : in data_word;
   e_pkt_cntrl_in : in pkt_cntrl_word;
   e_dataout : out data_word;
   e_pkt_cntrl_out : out pkt_cntrl_word;
   e_channel_cntrl_in  : in channel_cntrl_word;
   e_channel_cntrl_out : out channel_cntrl_word;
   w_datain : in data_word;
   w_pkt_cntrl_in : in pkt_cntrl_word;
   w_dataout : out data_word;
   w_pkt_cntrl_out : out pkt_cntrl_word;
   w_channel_cntrl_in  : in channel_cntrl_word;
   w_channel_cntrl_out : out channel_cntrl_word;
   ap_datain : in data_word;
   ap_pkt_cntrl_in : in pkt_cntrl_word;
   ap_dataout : out data_word;
   ap_pkt_cntrl_out : out pkt_cntrl_word;
   ap_channel_cntrl_in  : in channel_cntrl_word;
   ap_channel_cntrl_out : out channel_cntrl_word;
   clk : in std_logic;
   rst : in std_logic 
	);
END COMPONENT;











COMPONENT arb_bus_nocem
	Port(
		arb_req   : in  std_logic_vector(NOCEM_NUM_AP-1 downto 0);
		arb_grant : out std_logic_vector(NOCEM_NUM_AP-1 downto 0);	 
	 	clk : in std_logic;
      rst : in std_logic
	);
END COMPONENT;



	COMPONENT simple_pkt_local_arb
    Port ( 

		-- local arb info (should be held constant on incoming signal)
		local_arb_addr : std_logic_vector(NOCEM_AW-1 downto 0);

		-- needed to mux outputs for the accompanying switch
 		arb_grant_output : out arb_decision_array(4 downto 0);

	   n_pkt_cntrl_in : in pkt_cntrl_word;
	   n_pkt_cntrl_out : out pkt_cntrl_word;
	   n_channel_cntrl_in  : in channel_cntrl_word;
	   n_channel_cntrl_out : out channel_cntrl_word;

	   s_pkt_cntrl_in : in pkt_cntrl_word;
	   s_pkt_cntrl_out : out pkt_cntrl_word;
	   s_channel_cntrl_in  : in channel_cntrl_word;
	   s_channel_cntrl_out : out channel_cntrl_word;

	   e_pkt_cntrl_in : in pkt_cntrl_word;
	   e_pkt_cntrl_out : out pkt_cntrl_word;
	   e_channel_cntrl_in  : in channel_cntrl_word;
	   e_channel_cntrl_out : out channel_cntrl_word;

	   w_pkt_cntrl_in : in pkt_cntrl_word;
	   w_pkt_cntrl_out : out pkt_cntrl_word;
	   w_channel_cntrl_in  : in channel_cntrl_word;
	   w_channel_cntrl_out : out channel_cntrl_word;


	   ap_pkt_cntrl_in : in pkt_cntrl_word;
	   ap_pkt_cntrl_out : out pkt_cntrl_word;
	   ap_channel_cntrl_in  : in channel_cntrl_word;
	   ap_channel_cntrl_out : out channel_cntrl_word;
	 
	 	clk : in std_logic;
      rst : in std_logic
		);
		END COMPONENT;


	COMPONENT simple_pkt_local_switch
    Port ( 
		arb_grant_output : in arb_decision_array(4 downto 0);	 	 
	 	ap_datain        				: in  data_word;
		ap_dataout       				: out data_word;
	 	n_datain              	   : in  data_word;
		n_dataout              		: out data_word;
	 	s_datain               		: in  data_word;
		s_dataout              		: out data_word;
	 	e_datain                	: in  data_word;
		e_dataout               	: out data_word;
	 	w_datain                	: in  data_word;
		w_dataout               	: out data_word;	 
	 
		n_pkt_cntrl_in  : in pkt_cntrl_word;	 
		n_pkt_cntrl_out : out pkt_cntrl_word;	 

		s_pkt_cntrl_in  : in pkt_cntrl_word;	 
		s_pkt_cntrl_out : out pkt_cntrl_word;	 

		e_pkt_cntrl_in  : in pkt_cntrl_word;	 
		e_pkt_cntrl_out : out pkt_cntrl_word;	 

		w_pkt_cntrl_in  : in pkt_cntrl_word;	 
		w_pkt_cntrl_out : out pkt_cntrl_word;	 

		ap_pkt_cntrl_in  : in pkt_cntrl_word;	 
		ap_pkt_cntrl_out : out pkt_cntrl_word;	 
	 
	 	clk : in std_logic;
      rst : in std_logic
			  
	);
	END COMPONENT;


	COMPONENT ic_pkt_nocem
    Port ( 
		arb_req         : in  std_logic_vector(NOCEM_NUM_AP-1 downto 0);
		arb_cntrl_in   : in  arb_cntrl_array(NOCEM_NUM_AP-1 downto 0);
		arb_grant         : out std_logic_vector(NOCEM_NUM_AP-1 downto 0);
		arb_cntrl_out   : out  arb_cntrl_array(NOCEM_NUM_AP-1 downto 0);
		datain        : in   data_array(NOCEM_NUM_AP-1 downto 0);
		datain_valid  : in   std_logic_vector(NOCEM_NUM_AP-1 downto 0);
		datain_recvd  : out  std_logic_vector(NOCEM_NUM_AP-1 downto 0);
		dataout       : out data_array(NOCEM_NUM_AP-1 downto 0);
		dataout_valid : out std_logic_vector(NOCEM_NUM_AP-1 downto 0);
		dataout_recvd : in  std_logic_vector(NOCEM_NUM_AP-1 downto 0);
		pkt_cntrl_in        : in   pkt_cntrl_array(NOCEM_NUM_AP-1 downto 0);
		pkt_cntrl_in_valid  : in   std_logic_vector(NOCEM_NUM_AP-1 downto 0);
		pkt_cntrl_in_recvd  : out  std_logic_vector(NOCEM_NUM_AP-1 downto 0);                   
		pkt_cntrl_out       : out pkt_cntrl_array(NOCEM_NUM_AP-1 downto 0);
		pkt_cntrl_out_valid : out std_logic_vector(NOCEM_NUM_AP-1 downto 0);
		pkt_cntrl_out_recvd : in  std_logic_vector(NOCEM_NUM_AP-1 downto 0);	 		 	 
	 	clk : in std_logic;
      rst : in std_logic		
		);
	END COMPONENT;








  function addr_gen  (I,num_rows,num_cols,addr_width : integer) return std_logic_vector;
	function Log2 (input : integer) return integer; 

end pkg_nocem;


package body pkg_nocem is

-- Example 1
  function addr_gen  (I,num_rows,num_cols,addr_width : integer) return std_logic_vector is
    variable final_addr : std_logic_vector(addr_width-1 downto 0);
	 variable x_coord, y_coord : integer;
  begin
    x_coord := I mod num_cols;
	 y_coord := I / num_cols;

	 final_addr(addr_width-1 downto addr_width/2) := CONV_STD_LOGIC_VECTOR(x_coord,addr_width/2);
	 final_addr(addr_width/2-1 downto 0)          := CONV_STD_LOGIC_VECTOR(y_coord,addr_width/2);
    return final_addr; 
  end addr_gen;
 

	-- it'll do for now
	function Log2 (input : integer) return integer is
	begin

		case input is
			when 1 => return 0;
			when 2 => return 1;
			when 4 => return 2;
			when 8 => return 3;
			when 16 => return 4;
			when 32 => return 5;
			when 64 => return 6;
			when others => return -1;
		end case;


	end Log2;



end pkg_nocem;
