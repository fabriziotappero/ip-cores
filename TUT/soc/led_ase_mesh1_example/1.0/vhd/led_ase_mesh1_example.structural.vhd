-- ***************************************************
-- File: led_ase_mesh1_example.structural.vhd
-- Creation date: 08.12.2011
-- Creation time: 15:10:05
-- Description: 
-- Created by: ege
-- This file was generated with Kactus2 vhdl generator.
-- ***************************************************
library IEEE;
library std;
library work;
use work.all;
use IEEE.std_logic_1164.all;

entity led_ase_mesh1_example is

	port (

		-- Interface: clk
		clk : in std_logic;

		-- Interface: led_0
		led_0_out : out std_logic;

		-- Interface: led_1
		led_1_out : out std_logic;

		-- Interface: reset
		reset_n : in std_logic;

		-- Interface: switch_0
		switch_0_in : in std_logic;

		-- Interface: switch_1
		switch_1_in : in std_logic);

end led_ase_mesh1_example;


architecture structural of led_ase_mesh1_example is

	signal led_pkt_codec_mk2_1_pkt_codec_mk2_to_ase_mesh1_top4_1_port0CMD_IN : std_logic_vector(1 downto 0);
	signal led_pkt_codec_mk2_1_pkt_codec_mk2_to_ase_mesh1_top4_1_port0CMD_OUT : std_logic_vector(1 downto 0);
	signal led_pkt_codec_mk2_2_pkt_codec_mk2_to_ase_mesh1_top4_1_port1CMD_IN : std_logic_vector(1 downto 0);
	signal led_pkt_codec_mk2_2_pkt_codec_mk2_to_ase_mesh1_top4_1_port1CMD_OUT : std_logic_vector(1 downto 0);
	signal switch_pkt_codec_mk2_1_pkt_codec_mk2_to_ase_mesh1_top4_1_port2CMD_IN : std_logic_vector(1 downto 0);
	signal switch_pkt_codec_mk2_1_pkt_codec_mk2_to_ase_mesh1_top4_1_port2CMD_OUT : std_logic_vector(1 downto 0);
	signal switch_pkt_codec_mk2_2_pkt_codec_mk2_to_ase_mesh1_top4_1_port3CMD_IN : std_logic_vector(1 downto 0);
	signal switch_pkt_codec_mk2_2_pkt_codec_mk2_to_ase_mesh1_top4_1_port3CMD_OUT : std_logic_vector(1 downto 0);
	signal led_pkt_codec_mk2_1_pkt_codec_mk2_to_ase_mesh1_top4_1_port0DATA_IN : std_logic_vector(31 downto 0);
	signal led_pkt_codec_mk2_1_pkt_codec_mk2_to_ase_mesh1_top4_1_port0DATA_OUT : std_logic_vector(31 downto 0);
	signal led_pkt_codec_mk2_2_pkt_codec_mk2_to_ase_mesh1_top4_1_port1DATA_IN : std_logic_vector(31 downto 0);
	signal led_pkt_codec_mk2_2_pkt_codec_mk2_to_ase_mesh1_top4_1_port1DATA_OUT : std_logic_vector(31 downto 0);
	signal switch_pkt_codec_mk2_1_pkt_codec_mk2_to_ase_mesh1_top4_1_port2DATA_IN : std_logic_vector(31 downto 0);
	signal switch_pkt_codec_mk2_1_pkt_codec_mk2_to_ase_mesh1_top4_1_port2DATA_OUT : std_logic_vector(31 downto 0);
	signal switch_pkt_codec_mk2_2_pkt_codec_mk2_to_ase_mesh1_top4_1_port3DATA_IN : std_logic_vector(31 downto 0);
	signal switch_pkt_codec_mk2_2_pkt_codec_mk2_to_ase_mesh1_top4_1_port3DATA_OUT : std_logic_vector(31 downto 0);
	signal led_pkt_codec_mk2_1_pkt_codec_mk2_to_ase_mesh1_top4_1_port0STALL_IN : std_logic;
	signal led_pkt_codec_mk2_1_pkt_codec_mk2_to_ase_mesh1_top4_1_port0STALL_OUT : std_logic;
	signal led_pkt_codec_mk2_2_pkt_codec_mk2_to_ase_mesh1_top4_1_port1STALL_IN : std_logic;
	signal led_pkt_codec_mk2_2_pkt_codec_mk2_to_ase_mesh1_top4_1_port1STALL_OUT : std_logic;
	signal switch_pkt_codec_mk2_1_pkt_codec_mk2_to_ase_mesh1_top4_1_port2STALL_IN : std_logic;
	signal switch_pkt_codec_mk2_1_pkt_codec_mk2_to_ase_mesh1_top4_1_port2STALL_OUT : std_logic;
	signal switch_pkt_codec_mk2_2_pkt_codec_mk2_to_ase_mesh1_top4_1_port3STALL_IN : std_logic;
	signal switch_pkt_codec_mk2_2_pkt_codec_mk2_to_ase_mesh1_top4_1_port3STALL_OUT : std_logic;

	-- Top level for 2x2 32-bit ase_mesh1 NoC.
	-- 
	-- 
	component ase_mesh1_top4
		port (

			-- Interface: clock
			clk : in std_logic;

			-- Interface: port0
			cmd0_in : in std_logic_vector(1 downto 0);
			data0_in : in std_logic_vector(31 downto 0);
			stall0_in : in std_logic;
			cmd0_out : out std_logic_vector(1 downto 0);
			data0_out : out std_logic_vector(31 downto 0);
			stall0_out : out std_logic;

			-- Interface: port1
			cmd1_in : in std_logic_vector(1 downto 0);
			data1_in : in std_logic_vector(31 downto 0);
			stall1_in : in std_logic;
			cmd1_out : out std_logic_vector(1 downto 0);
			data1_out : out std_logic_vector(31 downto 0);
			stall1_out : out std_logic;

			-- Interface: port2
			cmd2_in : in std_logic_vector(1 downto 0);
			data2_in : in std_logic_vector(31 downto 0);
			stall2_in : in std_logic;
			cmd2_out : out std_logic_vector(1 downto 0);
			data2_out : out std_logic_vector(31 downto 0);
			stall2_out : out std_logic;

			-- Interface: port3
			cmd3_in : in std_logic_vector(1 downto 0);
			data3_in : in std_logic_vector(31 downto 0);
			stall3_in : in std_logic;
			cmd3_out : out std_logic_vector(1 downto 0);
			data3_out : out std_logic_vector(31 downto 0);
			stall3_out : out std_logic;

			-- Interface: reset
			rst_n : in std_logic

		);
	end component;

	-- Inverts led output for evey data word received.
	component led_pkt_codec_mk2
		port (

			-- Interface: clk
			clk : in std_logic;

			-- Interface: led
			led_out : out std_logic;

			-- Interface: pkt_codec_mk2
			cmd_in : in std_logic_vector(1 downto 0);
			data_in : in std_logic_vector(31 downto 0);
			stall_in : in std_logic;
			cmd_out : out std_logic_vector(1 downto 0);
			data_out : out std_logic_vector(31 downto 0);
			stall_out : out std_logic;

			-- Interface: reset
			rst_n : in std_logic

		);
	end component;

	-- Sends a constant addr+data pair every time a switch is toggled. 
	component switch_pkt_codec_mk2
		generic (
			target_id_g : integer := 0 -- target_id in the noc

		);
		port (

			-- Interface: clock
			clk : in std_logic;

			-- Interface: pkt_codec_mk2
			cmd_in : in std_logic_vector(1 downto 0);
			data_in : in std_logic_vector(31 downto 0);
			stall_in : in std_logic;
			cmd_out : out std_logic_vector(1 downto 0);
			data_out : out std_logic_vector(31 downto 0);
			stall_out : out std_logic;

			-- Interface: reset
			rst_n : in std_logic;

			-- Interface: switch
			switch_in : in std_logic

		);
	end component;

	-- You can write vhdl code after this tag and it is saved through the generator.
	-- ##KACTUS2_BLACK_BOX_DECLARATIONS_BEGIN##
	-- ##KACTUS2_BLACK_BOX_DECLARATIONS_END##
	-- Stop writing your code after this tag.


begin

	-- You can write vhdl code after this tag and it is saved through the generator.
	-- ##KACTUS2_BLACK_BOX_ASSIGNMENTS_BEGIN##
	-- ##KACTUS2_BLACK_BOX_ASSIGNMENTS_END##
	-- Stop writing your code after this tag.

	ase_mesh1_top4_1 : ase_mesh1_top4
		port map (
			clk => clk,
			cmd0_in(1 downto 0) => led_pkt_codec_mk2_1_pkt_codec_mk2_to_ase_mesh1_top4_1_port0CMD_IN(1 downto 0),
			cmd0_out(1 downto 0) => led_pkt_codec_mk2_1_pkt_codec_mk2_to_ase_mesh1_top4_1_port0CMD_OUT(1 downto 0),
			cmd1_in(1 downto 0) => led_pkt_codec_mk2_2_pkt_codec_mk2_to_ase_mesh1_top4_1_port1CMD_IN(1 downto 0),
			cmd1_out(1 downto 0) => led_pkt_codec_mk2_2_pkt_codec_mk2_to_ase_mesh1_top4_1_port1CMD_OUT(1 downto 0),
			cmd2_in(1 downto 0) => switch_pkt_codec_mk2_1_pkt_codec_mk2_to_ase_mesh1_top4_1_port2CMD_IN(1 downto 0),
			cmd2_out(1 downto 0) => switch_pkt_codec_mk2_1_pkt_codec_mk2_to_ase_mesh1_top4_1_port2CMD_OUT(1 downto 0),
			cmd3_in(1 downto 0) => switch_pkt_codec_mk2_2_pkt_codec_mk2_to_ase_mesh1_top4_1_port3CMD_IN(1 downto 0),
			cmd3_out(1 downto 0) => switch_pkt_codec_mk2_2_pkt_codec_mk2_to_ase_mesh1_top4_1_port3CMD_OUT(1 downto 0),
			data0_in(31 downto 0) => led_pkt_codec_mk2_1_pkt_codec_mk2_to_ase_mesh1_top4_1_port0DATA_IN(31 downto 0),
			data0_out(31 downto 0) => led_pkt_codec_mk2_1_pkt_codec_mk2_to_ase_mesh1_top4_1_port0DATA_OUT(31 downto 0),
			data1_in(31 downto 0) => led_pkt_codec_mk2_2_pkt_codec_mk2_to_ase_mesh1_top4_1_port1DATA_IN(31 downto 0),
			data1_out(31 downto 0) => led_pkt_codec_mk2_2_pkt_codec_mk2_to_ase_mesh1_top4_1_port1DATA_OUT(31 downto 0),
			data2_in(31 downto 0) => switch_pkt_codec_mk2_1_pkt_codec_mk2_to_ase_mesh1_top4_1_port2DATA_IN(31 downto 0),
			data2_out(31 downto 0) => switch_pkt_codec_mk2_1_pkt_codec_mk2_to_ase_mesh1_top4_1_port2DATA_OUT(31 downto 0),
			data3_in(31 downto 0) => switch_pkt_codec_mk2_2_pkt_codec_mk2_to_ase_mesh1_top4_1_port3DATA_IN(31 downto 0),
			data3_out(31 downto 0) => switch_pkt_codec_mk2_2_pkt_codec_mk2_to_ase_mesh1_top4_1_port3DATA_OUT(31 downto 0),
			rst_n => reset_n,
			stall0_in => led_pkt_codec_mk2_1_pkt_codec_mk2_to_ase_mesh1_top4_1_port0STALL_IN,
			stall0_out => led_pkt_codec_mk2_1_pkt_codec_mk2_to_ase_mesh1_top4_1_port0STALL_OUT,
			stall1_in => led_pkt_codec_mk2_2_pkt_codec_mk2_to_ase_mesh1_top4_1_port1STALL_IN,
			stall1_out => led_pkt_codec_mk2_2_pkt_codec_mk2_to_ase_mesh1_top4_1_port1STALL_OUT,
			stall2_in => switch_pkt_codec_mk2_1_pkt_codec_mk2_to_ase_mesh1_top4_1_port2STALL_IN,
			stall2_out => switch_pkt_codec_mk2_1_pkt_codec_mk2_to_ase_mesh1_top4_1_port2STALL_OUT,
			stall3_in => switch_pkt_codec_mk2_2_pkt_codec_mk2_to_ase_mesh1_top4_1_port3STALL_IN,
			stall3_out => switch_pkt_codec_mk2_2_pkt_codec_mk2_to_ase_mesh1_top4_1_port3STALL_OUT
		);

	led_pkt_codec_mk2_0 : led_pkt_codec_mk2
		port map (
			clk => clk,
			cmd_in(1 downto 0) => led_pkt_codec_mk2_1_pkt_codec_mk2_to_ase_mesh1_top4_1_port0CMD_OUT(1 downto 0),
			cmd_out(1 downto 0) => led_pkt_codec_mk2_1_pkt_codec_mk2_to_ase_mesh1_top4_1_port0CMD_IN(1 downto 0),
			data_in(31 downto 0) => led_pkt_codec_mk2_1_pkt_codec_mk2_to_ase_mesh1_top4_1_port0DATA_OUT(31 downto 0),
			data_out(31 downto 0) => led_pkt_codec_mk2_1_pkt_codec_mk2_to_ase_mesh1_top4_1_port0DATA_IN(31 downto 0),
			led_out => led_0_out,
			rst_n => reset_n,
			stall_in => led_pkt_codec_mk2_1_pkt_codec_mk2_to_ase_mesh1_top4_1_port0STALL_OUT,
			stall_out => led_pkt_codec_mk2_1_pkt_codec_mk2_to_ase_mesh1_top4_1_port0STALL_IN
		);

	led_pkt_codec_mk2_1 : led_pkt_codec_mk2
		port map (
			clk => clk,
			cmd_in(1 downto 0) => led_pkt_codec_mk2_2_pkt_codec_mk2_to_ase_mesh1_top4_1_port1CMD_OUT(1 downto 0),
			cmd_out(1 downto 0) => led_pkt_codec_mk2_2_pkt_codec_mk2_to_ase_mesh1_top4_1_port1CMD_IN(1 downto 0),
			data_in(31 downto 0) => led_pkt_codec_mk2_2_pkt_codec_mk2_to_ase_mesh1_top4_1_port1DATA_OUT(31 downto 0),
			data_out(31 downto 0) => led_pkt_codec_mk2_2_pkt_codec_mk2_to_ase_mesh1_top4_1_port1DATA_IN(31 downto 0),
			led_out => led_1_out,
			rst_n => reset_n,
			stall_in => led_pkt_codec_mk2_2_pkt_codec_mk2_to_ase_mesh1_top4_1_port1STALL_OUT,
			stall_out => led_pkt_codec_mk2_2_pkt_codec_mk2_to_ase_mesh1_top4_1_port1STALL_IN
		);

	switch_pkt_codec_mk2_0 : switch_pkt_codec_mk2
		generic map (
			target_id_g => 0
		)
		port map (
			clk => clk,
			cmd_in(1 downto 0) => switch_pkt_codec_mk2_1_pkt_codec_mk2_to_ase_mesh1_top4_1_port2CMD_OUT(1 downto 0),
			cmd_out(1 downto 0) => switch_pkt_codec_mk2_1_pkt_codec_mk2_to_ase_mesh1_top4_1_port2CMD_IN(1 downto 0),
			data_in(31 downto 0) => switch_pkt_codec_mk2_1_pkt_codec_mk2_to_ase_mesh1_top4_1_port2DATA_OUT(31 downto 0),
			data_out(31 downto 0) => switch_pkt_codec_mk2_1_pkt_codec_mk2_to_ase_mesh1_top4_1_port2DATA_IN(31 downto 0),
			rst_n => reset_n,
			stall_in => switch_pkt_codec_mk2_1_pkt_codec_mk2_to_ase_mesh1_top4_1_port2STALL_OUT,
			stall_out => switch_pkt_codec_mk2_1_pkt_codec_mk2_to_ase_mesh1_top4_1_port2STALL_IN,
			switch_in => switch_0_in
		);

	switch_pkt_codec_mk2_1 : switch_pkt_codec_mk2
		generic map (
			target_id_g => 1
		)
		port map (
			clk => clk,
			cmd_in(1 downto 0) => switch_pkt_codec_mk2_2_pkt_codec_mk2_to_ase_mesh1_top4_1_port3CMD_OUT(1 downto 0),
			cmd_out(1 downto 0) => switch_pkt_codec_mk2_2_pkt_codec_mk2_to_ase_mesh1_top4_1_port3CMD_IN(1 downto 0),
			data_in(31 downto 0) => switch_pkt_codec_mk2_2_pkt_codec_mk2_to_ase_mesh1_top4_1_port3DATA_OUT(31 downto 0),
			data_out(31 downto 0) => switch_pkt_codec_mk2_2_pkt_codec_mk2_to_ase_mesh1_top4_1_port3DATA_IN(31 downto 0),
			rst_n => reset_n,
			stall_in => switch_pkt_codec_mk2_2_pkt_codec_mk2_to_ase_mesh1_top4_1_port3STALL_OUT,
			stall_out => switch_pkt_codec_mk2_2_pkt_codec_mk2_to_ase_mesh1_top4_1_port3STALL_IN,
			switch_in => switch_1_in
		);

end structural;

