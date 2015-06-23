-- ***************************************************
-- File: altera_de_II_demo.vhd
-- Creation date: 14.03.2012
-- Creation time: 15:52:16
-- Description: Simple demo for Altera DE2 development board.Instantietes two components sig_gen and port blinker. 
-- Sig_gen reads switch[17] from DE2 board and activates port blinker to blink leds in DE2 Board. Note that sig_gen detects rising_edges of switch[17].
-- Switch[0] is reset.
-- 
-- DEMO INSTRUCTIONS.
-- 1. Open altera_de_II_demo design in Kactus2
-- 2. Generate top-level VHDL with Kactus2 vhdl generator the ribbon
-- 3. Generate Qurtus project for synthesizing demo design by clicking Quartus project generator in the ribbon element. 
-- 4. Open generated project with Quartus. Compile and synthesize.
-- 5. Program the FPGA.
-- Created by: ege
-- This file was generated with Kactus2 vhdl generator.
-- ***************************************************
library IEEE;
library work;
use IEEE.std_logic_1164.all;
use work.all;

entity altera_de_II_demo is

	port (

		-- Interface: clk
		-- clk input
		clk : in std_logic;

		-- Interface: port_out
		port_out : out std_logic;

		-- Interface: rst_n
		-- active low reset in
		rst_n : in std_logic;

		-- Interface: toggle_in
		toggle_in : in std_logic
	);

end altera_de_II_demo;


architecture kactusHierarchical of altera_de_II_demo is

	signal gen_to_blinkerENABLE_FROM_GEN : std_logic;
	signal gen_to_blinkerSIGNAL_FROM_GEN : std_logic_vector(31 downto 0);

	-- Counts up and inverts output when reaching the limit value. Then start over again.
	component port_blinker
		generic (
			SIGNAL_WIDTH : integer := 32 -- In bits

		);
		port (

			-- Interface: clk
			clk : in std_logic;

			-- Interface: port_out
			port_out : out std_logic;

			-- Interface: rst_n
			rst_n : in std_logic;

			-- Interface: signal_gen_if
			ena_in : in std_logic;
			val_in : in std_logic_vector(31 downto 0)

		);
	end component;

	-- Generates a constant value to the output bus and an enable signal that can be toggled.
	component sig_gen
		generic (
			SIGNAL_VAL : integer := 50000000; -- Constant value driven to the output
			SIGNAL_WIDTH : integer := 32 -- In bits

		);
		port (

			-- Interface: clk
			clk : in std_logic;

			-- Interface: rst_n
			rst_n : in std_logic;

			-- Interface: signal_gen_if
			ena_out : out std_logic;
			sig_out : out std_logic_vector(31 downto 0);

			-- Interface: toggle_in
			toggle_in : in std_logic

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

	port_blinker_1 : port_blinker
		port map (
			clk => clk,
			ena_in => gen_to_blinkerENABLE_FROM_GEN,
			port_out => port_out,
			rst_n => rst_n,
			val_in(31 downto 0) => gen_to_blinkerSIGNAL_FROM_GEN(31 downto 0)
		);

	sig_gen_1 : sig_gen
		generic map (
			SIGNAL_VAL => 4_000_000
		)
		port map (
			clk => clk,
			ena_out => gen_to_blinkerENABLE_FROM_GEN,
			rst_n => rst_n,
			sig_out(31 downto 0) => gen_to_blinkerSIGNAL_FROM_GEN(31 downto 0),
			toggle_in => toggle_in
		);

end kactusHierarchical;

