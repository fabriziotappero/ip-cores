--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Title			: NAND interface
-- File			: nand_interface.vhd
-- Author		: Alexey Lyashko <pradd@opencores.org>
-- License		: LGPL
--------------------------------------------------------------------------
-- Description	:
-- This file implements a simplistic NAND interface driven by 5 control signals:
-- action_cmd, action_address, action_read and action_write which trigger 
-- execution of Command Latch Cycle, Address Latch Cycle, Data Output  and 
-- Data Input cycles respectively. This interface controlls all timing stuff
-- as well.
-- This component may be used as a standalone NAND Flash adapter, although, 
-- I would recommend using the controller as a whole.
--------------------------------------------------------------------------
--------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.nand_stuff.all;

entity nand_interface is
	port
	(
		-- NAND HW interface
		nand_cle				: out	std_logic := '0';
		nand_ale				: out	std_logic := '0';
		nand_n_we			: out	std_logic := '1';
		nand_n_wp			: out	std_logic := '1';
		nand_n_ce			: out	std_logic := '1';
		nand_n_ce2			: out	std_logic := '1';
		nand_n_re			: out	std_logic := '1';
		nand_r_nb			: in	std_logic := '1';							-- We use single RB# input even for 8Gbit NAND chips. In such case, RB# should be ORed with RB2#
		nand_io				: inout std_logic_vector(15 downto 0);
		
		-- System interface
		clk					: in	std_logic;
		
		-- NAND controller internal interface
		data_rx				: in	std_logic_vector(15 downto 0);		-- Data input from the 'client'
		data_tx				: out	std_logic_vector(15 downto 0);		-- Data output to the 'client'
		ready					: out	std_logic := '0';							-- Indicates whether the component is ready for next operation.
		n_nand_enable		: in	std_logic := '1';							-- Enables the component and the NAND Flash. Signal is active LOW.
		action_cmd			: in	std_logic := '0';							-- When strobed high, initiates Command Latch Cycle
		action_address		: in	std_logic := '0';							-- When strobed high, initiates Address Latch Cycle
		action_read			: in	std_logic := '0';							-- When strobed high, initiates Data Output Cycle
		action_write		: in	std_logic := '0';							-- When strobed high, initiates Data Input Cycle
		is_x16				: in	std_logic := '0';							-- When '1', the NAND chip is a x16 NAND, so the data line must be remuxed!
		die_select			: in	std_logic := '0'							-- For x8 8Gbit devices only. Selects active die
	);
end nand_interface;

architecture action of nand_interface is
	-- NAND IO
	signal nand_io_rx				: 	std_logic_vector(15 downto 0);
	signal nand_io_tx				:	std_logic_vector(15 downto 0);
	signal nand_oe					:	std_logic;								-- Enables output on nand_io "pin"
	signal nand_io_buffer		:	std_logic_vector(15 downto 0);	-- Stores data read from the NAND Flash
	
	-- Main FSM
	type c_state_t is (C_IDLE, C_COMMAND, C_ADDRESS, C_READ, C_WRITE, C_DELAY);
	signal c_state 				:	c_state_t := C_IDLE;
	signal r_state					:	c_state_t;
	
	-- Latch states
	type l_state_t is (L_BEGIN, L_WE, L_RE, L_HOLD, L_END);
	signal l_state					:	l_state_t := L_BEGIN;
	
	-- Delay counter
	signal delay_cnt				: integer := 0;							-- Simply a delay counter
begin
	-- NAND chip enable
	nand_n_ce				<= n_nand_enable when is_x16 = '1' else
									n_nand_enable when die_select = '0' else
									'1';

	nand_n_ce2				<= '1' when is_x16 = '1' else
									n_nand_enable when die_select = '1' else
									'1';
	
	-- NAND IO bidirectional "pin"
	-- nand_io mapping to NAND device pins:
	-- ========================================================================================================================
	-- | Bits |  15  |  14  |  13  |  12  |  11  |  10  |   9  |   8  |   7  |   6  |   5  |   4  |   3  |   2  |   1  |   0  |
	-- ========================================================================================================================
	-- | x8   |   NC |   NC |   NC |   NC |   NC |   NC |   NC |   NC |  44  |  43  |  42  |  41  |  32  |  31  |  30  |  29  |
	-- ------------------------------------------------------------------------------------------------------------------------
	-- | x16  |  47  |  45  |  43  |  41  |  33  |  31  |  29  |  27  |  46  |  44  |  42  |  40  |  32  |  30  |  28  |  26  |
	-- ------------------------------------------------------------------------------------------------------------------------
	-- | PC*  |  47  |  45  |  33  |  27  |  46  |  40  |  28  |  26  |  44  |  43  |  42  |  41  |  32  |  31  |  30  |  29  |
	-- ------------------------------------------------------------------------------------------------------------------------
	-- * physical connection.
	--
	-- nand_io and data_tx are muxed accordingly, so that we do not have to deal with this head ache outside this module.
	nand_io					<= nand_io_tx when nand_oe = '1' and is_x16 = '0' else
									nand_io_tx(15)&nand_io_tx(14)&nand_io_tx(11)&nand_io_tx(8)&nand_io_tx(7)&nand_io_tx(4)&nand_io_tx(1)&nand_io_tx(0)&
									nand_io_tx(6)&nand_io_tx(13)&nand_io_tx(5)&nand_io_tx(12)&nand_io_tx(3)&nand_io_tx(10)&nand_io_tx(2)&nand_io_tx(9) when nand_oe = '1' and is_x16 = '1'
									else "ZZZZZZZZZZZZZZZZ";
									
	data_tx					<= nand_io_buffer when is_x16 = '0' else
									nand_io_buffer(15)&nand_io_buffer(14)&nand_io_buffer(6)&nand_io_buffer(4)&nand_io_buffer(13)&nand_io_buffer(2)&nand_io_buffer(0)&nand_io_buffer(12)&
									nand_io_buffer(11)&nand_io_buffer(7)&nand_io_buffer(5)&nand_io_buffer(10)&nand_io_buffer(3)&nand_io_buffer(1)&nand_io_buffer(9)&nand_io_buffer(8) when is_x16 = '1';
	
	-- READY
	ready						<= '1' when c_state = C_IDLE and nand_r_nb = '1' and n_nand_enable = '0' else '0';
	
	-- NAND write enable
	nand_n_we				<= '0' when (c_state = C_COMMAND and (l_state = L_BEGIN or l_state = L_WE)) or
												(c_state = C_DELAY and r_state = C_COMMAND and (l_state = L_BEGIN or l_state = L_WE)) or
												(c_state = C_ADDRESS and (l_state = L_BEGIN or l_state = L_WE)) or
												(c_state = C_DELAY and r_state = C_ADDRESS and (l_state = L_BEGIN or l_state = L_WE)) or
												(c_state = C_WRITE and (l_state = L_BEGIN or l_state = L_WE)) or
												(c_state = C_DELAY and r_state = C_WRITE and (l_state = L_BEGIN or l_state = L_WE))
												else
												'1';
	
	-- NAND io port output enable
	nand_oe					<= '1' when (c_state = C_COMMAND and (l_state = L_BEGIN or l_state = L_WE or l_state = L_HOLD)) or
												(c_state = C_DELAY and r_state = C_COMMAND and (l_state = L_BEGIN or l_state = L_WE or l_state = L_HOLD)) or
												(c_state = C_ADDRESS and (l_state = L_BEGIN or l_state = L_WE or l_state = L_HOLD)) or
												(c_state = C_DELAY and r_state = C_ADDRESS and (l_state = L_BEGIN or l_state = L_WE or l_state = L_HOLD)) or
												(c_state = C_WRITE and (l_state = L_BEGIN or l_state = L_WE or l_state = L_HOLD)) or
												(c_state = C_DELAY and r_state = C_WRITE and (l_state = L_BEGIN or l_state = L_WE or l_state = L_HOLD))
												else
												'0';
	
	-- NAND read enable
	nand_n_re				<= '0' when (c_state = C_READ and (l_state = L_BEGIN or l_state = L_RE)) or
												(c_state = C_DELAY and r_state = C_READ and (l_state = L_BEGIN or l_state = L_RE))
												else
												'1';
	
	-- NAND Command Latch
	nand_cle					<= '1' when (c_state = C_COMMAND and (l_state = L_WE or l_state = L_HOLD)) or
												(c_state = C_DELAY and r_state = C_COMMAND and (l_state = L_WE or l_state = L_HOLD))
												else
												'0';
	-- NAND Address Latch
	nand_ale					<= '1' when (c_state = C_ADDRESS and (l_state = L_WE or l_state = L_HOLD)) or
												(c_state = C_DELAY and r_state = C_ADDRESS and (l_state = L_WE or l_state = L_HOLD))
												else
												'0';
												
	NAND_IFACE:	process(clk, action_cmd, action_address, action_read, action_write, nand_r_nb)
					begin
					if(rising_edge(clk) and n_nand_enable = '0')then
						case c_state is
							----------------------------------------------------
							-- Idle state - controller awaits orders
							----------------------------------------------------
							when C_IDLE =>
								delay_cnt						<= 0;
								l_state							<= L_BEGIN;
								
								if(action_cmd = '1')then
									c_state						<= C_DELAY;
									r_state						<= C_COMMAND;
									delay_cnt					<= t_wp - t_cls - 1;
									nand_io_tx(7 downto 0)	<= data_rx(7 downto 0);
									nand_io_tx(15 downto 8)	<= "00000000";					-- bits 15 to 8 should be pulled low during command submission
									
								elsif(action_address = '1')then
									c_state						<= C_DELAY;
									r_state						<= C_ADDRESS;
									delay_cnt					<= t_wp - t_als - 1;
									nand_io_tx(7 downto 0)	<= data_rx(7 downto 0);
									nand_io_tx(15 downto 8)	<= "00000000";					-- bits 15 to 8 should be pulled low during address submission
									
								elsif(action_read = '1')then
									c_state						<= C_READ;
									
								elsif(action_write = '1')then
									c_state						<= C_WRITE;
									nand_io_tx					<= data_rx;
									
								else
									c_state						<= C_IDLE;
								end if;
								
							----------------------------------------------------
							-- Command submission state - controller forwards
							-- command to the NAND flash
							----------------------------------------------------
							when C_COMMAND =>
								if(l_state = L_BEGIN)then
									l_state						<= L_WE;						-- nand_n_we goes low, nand_oe goes high
									delay_cnt					<= t_cls;
									r_state						<= C_COMMAND;
									c_state						<= C_DELAY;
									
								elsif(l_state = L_WE)then
									l_state						<= L_HOLD;
									delay_cnt					<= t_clh;
									r_state						<= C_COMMAND;
									c_state						<= C_DELAY;
									
								elsif(l_state = L_HOLD)then
									c_state						<= C_IDLE;
									l_state						<= L_BEGIN;
								end if;
							
							----------------------------------------------------
							-- Address submission state - controller forwards
							-- address byte to the NAND flash
							----------------------------------------------------
							when C_ADDRESS =>
								if(l_state = L_BEGIN)then
									l_state						<= L_WE;
									delay_cnt					<= t_als;
									r_state						<= C_ADDRESS;
									c_state						<= C_DELAY;
									
								elsif(l_state = L_WE)then
									l_state						<= L_HOLD;
									delay_cnt					<= t_alh;
									r_state						<= C_ADDRESS;
									c_state						<= C_DELAY;
									
								elsif(l_state = L_HOLD)then
									delay_cnt					<= t_wh - t_alh;
									c_state						<= C_DELAY;
									r_state						<= C_IDLE;
									l_state						<= L_BEGIN;
								end if;
							
							----------------------------------------------------
							-- Data Input state - one byte/word is written 
							-- to the NAND device
							----------------------------------------------------
							when C_WRITE =>
								if(l_state = L_BEGIN)then
									l_state						<= L_WE;
									delay_cnt					<= t_wp;
									r_state						<= C_WRITE;
									c_state						<= C_DELAY;
									
								elsif(l_state = L_WE)then
									l_state						<= L_HOLD;
									delay_cnt					<= t_wh;
									r_state						<= C_WRITE;
									c_state						<= C_DELAY;
									
								elsif(l_state = L_HOLD)then
									l_state						<= L_BEGIN;
									c_state						<= C_IDLE;
								end if;
							
							----------------------------------------------------
							-- Data Output state - one byte/word is read 
							-- from the NAND device and stored to nand_io_buffer
							----------------------------------------------------
							when C_READ =>
								if(l_state = L_BEGIN)then
									l_state						<= L_RE;
									delay_cnt					<= t_rp;
									r_state						<= C_READ;
									c_state						<= C_DELAY;
									
								elsif(l_state = L_RE)then
									nand_io_buffer				<= nand_io;
									l_state						<= L_HOLD;
									delay_cnt					<= t_reh;
									r_state						<= C_READ;
									c_state						<= C_DELAY;
									
								elsif(l_state = L_HOLD)then
									l_state						<= L_BEGIN;
									c_state						<= C_IDLE;
								end if;
							
							
							----------------------------------------------------
							-- Delay state - controller "waits" until delay_cnt
							-- reaches 0 (delay expires)
							----------------------------------------------------
							when C_DELAY =>
								if(delay_cnt > 0)then
									delay_cnt					<= delay_cnt - 1;
								else
									c_state						<= r_state;
								end if;
								
							----------------------------------------------------
							-- Default state - we need to make sure that 
							-- the controller is in IDLE state on power op or if
							-- anything goes wrong
							----------------------------------------------------
							when others =>
								c_state							<= C_IDLE;
						end case;
					end if;
					end process;
end action;