----------------------------------------------------------------------------------
-- Company: OPL Aerospatiale AG
-- Engineer: Owen Lynn <lynn0p@hotmail.com>
-- 
-- Create Date:    13:08:21 08/30/2009 
-- Design Name: 
-- Module Name:    sdram_writer - impl 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: This module is responsible for generating the dqs, dq and dm waveforms
--  needed to tell the chip what to store.
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--  Copyright (c) 2009 Owen Lynn <lynn0p@hotmail.com>
--  Released under the GNU Lesser General Public License, Version 3
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-- Uses ODDR2 registers to generate the required DDR signals. Don't have to be as
--  careful with the timings as with sdram_reader, but you need to be able to feed
--  the ODDR2's within their setup and hold windows. Or very very hilarious things
--  will occur. Post-PAR simulation is good for getting a feel for the
--  (mis)timings.
entity sdram_writer is
	port(
		clk    : in std_logic;
		clk090 : in std_logic;
		clk180 : in std_logic;
		clk270 : in std_logic;
		rst    : in std_logic;
		addr   : in std_logic;
		data_o : in std_logic_vector(7 downto 0);
		dqs    : out std_logic_vector(1 downto 0);
		dm     : out std_logic_vector(1 downto 0);
		dq     : out std_logic_vector(15 downto 0)
	);
end sdram_writer;

architecture impl of sdram_writer is

	component oddr2_2 is
		port( 
			Q  : out std_logic_vector(1 downto 0);
			C0 : in std_logic;
			C1 : in std_logic;
			CE : in std_logic;
			D0 : in std_logic_vector(1 downto 0);
			D1 : in std_logic_vector(1 downto 0);
			R  : in std_logic;
			S  : in std_logic );
	end component;

	component oddr2_16 is
		port( 
			Q  : out std_logic_vector(15 downto 0);
			C0 : in std_logic;
			C1 : in std_logic;
			CE : in std_logic;
			D0 : in std_logic_vector(15 downto 0);
			D1 : in std_logic_vector(15 downto 0);
			R  : in std_logic;
			S  : in std_logic );
	end component;
  
	type WRITER_DQS_STATES is ( STATE_WRITER_DQS_0, STATE_WRITER_DQS_1, STATE_WRITER_DQS_DONE );
	type WRITER_DM_STATES is ( STATE_WRITER_DM_0, STATE_WRITER_DM_1, STATE_WRITER_DM_DONE );

	signal writer_dqs_state : WRITER_DQS_STATES := STATE_WRITER_DQS_0;
	signal writer_dm_state : WRITER_DM_STATES := STATE_WRITER_DM_0;

	signal dqs_rising : std_logic_vector(1 downto 0) := "00";
	signal dqs_falling : std_logic_vector(1 downto 0) := "00";
	signal dqs_fsm_r : std_logic;
	signal dqs_fsm_f : std_logic;

	signal dm_rising : std_logic_vector(1 downto 0) := "11";
	signal dm_falling : std_logic_vector(1 downto 0) := "11";

	signal dq_rising : std_logic_vector(15 downto 0) := x"0000";
	signal dq_falling : std_logic_vector(15 downto 0) := x"0000";
	
	signal data_out : std_logic_vector(15 downto 0);
	signal mask_out : std_logic_vector(1 downto 0);
  
begin
  
	ODDR2_dqs: oddr2_2
	port map(
		Q => dqs,
		C0 => clk,
		C1 => clk180,
		CE => '1',
		D0 => dqs_rising,
		D1 => dqs_falling,
		R => '0',
		S => '0'
	);
  
	ODDR2_dm: oddr2_2
	port map(
		Q => dm,
		C0 => clk090,
		C1 => clk270,
		CE => '1',
		D0 => dm_rising,
		D1 => dm_falling,
		R => '0',
		S => '0'
	);
  
	ODDR2_dq: oddr2_16
	port map(
		Q => dq,
		C0 => clk090,
		C1 => clk270,
		CE => '1',
		D0 => dq_rising,
		D1 => dq_falling,
		R => '0',
		S => '0'
	);
  
   dqs_rising(0)  <= dqs_fsm_r;
   dqs_rising(1)  <= dqs_fsm_r;
	dqs_falling(0) <= dqs_fsm_f;
	dqs_falling(1) <= dqs_fsm_f;
	
	-- this drives the oddr2_dqs
	process (clk180,rst)
	begin
		if (rst = '1') then
			dqs_fsm_r <= '0';
			dqs_fsm_f <= '0';
			writer_dqs_state <= STATE_WRITER_DQS_0;
		elsif (rising_edge(clk180)) then
			case writer_dqs_state is
				when STATE_WRITER_DQS_0 =>
					dqs_fsm_r <= '0';
					dqs_fsm_f <= '0';
					writer_dqs_state <= STATE_WRITER_DQS_1;
				when STATE_WRITER_DQS_1 =>
					dqs_fsm_r <= '1';
					dqs_fsm_f <= '0';
					writer_dqs_state <= STATE_WRITER_DQS_DONE;
				when STATE_WRITER_DQS_DONE =>
					dqs_fsm_r <= '0';
					dqs_fsm_f <= '0';
					writer_dqs_state <= STATE_WRITER_DQS_DONE;
			end case;
		end if;
	end process;


	data_out <= (x"00" & data_o) when addr = '0' else (data_o & x"00"); 
	mask_out <=             "10" when addr = '0' else "01";
	
	-- this drives the oddr2_dm and oddr2_dq
	process(clk,rst)
	begin
		if (rst = '1') then
			dm_rising <= "11";
			dq_rising <= x"0000";
			dm_falling <= "11";
			dq_falling <= x"0000";
			writer_dm_state <= STATE_WRITER_DM_0;
		elsif (rising_edge(clk)) then
			case writer_dm_state is
				when STATE_WRITER_DM_0 =>					
					dm_rising <= "11";
					dq_rising <= x"0000";
					dm_falling <= mask_out;
					dq_falling <= data_out;
					writer_dm_state <= STATE_WRITER_DM_1;
					
				when STATE_WRITER_DM_1 =>
					dm_rising <= "11";
					dq_rising <= x"0000";
					dm_falling <= "11";
					dq_falling <= x"0000";
					writer_dm_state <= STATE_WRITER_DM_DONE;
					
				when STATE_WRITER_DM_DONE =>
					dm_rising <= "00";
					dm_falling <= "00";
					writer_dm_state <= STATE_WRITER_DM_DONE;
			end case;
		end if;
	end process;
  
end impl;
