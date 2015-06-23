----------------------------------------------------------------------------------
-- Company: OPL Aerospatiale AG
-- Engineer: Owen Lynn <lynn0p@hotmail.com>
-- 
-- Create Date:    23:22:19 07/27/2009 
-- Design Name: 
-- Module Name:    scratch - impl 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Testbench for the DDR SDRAM controller. Sends a write command, sends a read 
--  and outputs to the led on the Spartan3e Starter Board
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
library UNISIM;
use UNISIM.VComponents.all;


entity scratch is
	port(         clk : in  std_logic; 
	             clke : in  std_logic;
	              rst : in  std_logic;
                 led : out std_logic_vector( 7 downto 0 );
					  
			-- SDRAM pins out
			  dram_clkp   : out   std_logic;
			  dram_clkn   : out   std_logic;
			  dram_clke   : out   std_logic;
			  dram_cs     : out   std_logic;
			  dram_cmd    : out   std_logic_vector(2 downto 0);
			  dram_bank   : out   std_logic_vector(1 downto 0);
			  dram_addr   : out   std_logic_vector(12 downto 0);
			  dram_dm     : out   std_logic_vector(1 downto 0);
			  dram_dqs    : inout std_logic_vector(1 downto 0);
			  dram_dq     : inout std_logic_vector(15 downto 0);

			-- debug signals
			  debug_reg   : out std_logic_vector(7 downto 0)
			  );
end scratch;

architecture impl of scratch is

	type DRAM_DRIVER_STATES is ( STATE0, STATE1, STATE2, STATE3, STATE4, STATE5 );
	signal dram_driver_state : DRAM_DRIVER_STATES := STATE0;

	signal clk_bufd        : std_logic;
	signal clk100mhz       : std_logic;
	signal dcm_locked      : std_logic;
	signal dcm_clk_000     : std_logic;
	signal dcm_clk_raw_000 : std_logic;
	
	signal op      : std_logic_vector(1 downto 0);
	signal addr    : std_logic_vector(25 downto 0);
	signal op_ack  : std_logic;
	signal busy_n  : std_logic;
	signal data_i  : std_logic_vector(7 downto 0);
	signal debug   : std_logic_vector(7 downto 0);
	
begin

	BUFG_CLK: BUFG
	port map(
		O => clk_bufd,
		I => clk
	);
	
	TB_DCM : DCM_SP
   generic map (
      CLKDV_DIVIDE => 2.0,                   --  Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
                                             --     7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
      CLKFX_DIVIDE => 2,                     --  Can be any integer from 1 to 32 
      CLKFX_MULTIPLY => 2,                   --  Can be any integer from 1 to 32
      CLKIN_DIVIDE_BY_2 => FALSE,            --  TRUE/FALSE to enable CLKIN divide by two feature
      CLKIN_PERIOD => 20.0,                  --  Specify period of input clock
      CLKOUT_PHASE_SHIFT => "NONE",          --  Specify phase shift of "NONE", "FIXED" or "VARIABLE" 
      CLK_FEEDBACK => "1X",                  --  Specify clock feedback of "NONE", "1X" or "2X" 
      DESKEW_ADJUST => "SOURCE_SYNCHRONOUS", -- "SOURCE_SYNCHRONOUS", "SYSTEM_SYNCHRONOUS" or
                                             --     an integer from 0 to 15
      DLL_FREQUENCY_MODE => "LOW",           -- "HIGH" or "LOW" frequency mode for DLL
      DUTY_CYCLE_CORRECTION => TRUE,         --  Duty cycle correction, TRUE or FALSE
      PHASE_SHIFT => 0,                      --  Amount of fixed phase shift from -255 to 255
      STARTUP_WAIT => FALSE)                 --  Delay configuration DONE until DCM_SP LOCK, TRUE/FALSE
   port map (
      CLK0     => dcm_clk_raw_000,       -- 0 degree DCM CLK ouptput
      CLK90    => open,                  -- 90 degree DCM CLK output
      CLK180   => open,                  -- 180 degree DCM CLK output
      CLK270   => open,                  -- 270 degree DCM CLK output
      CLK2X    => clk100mhz,             -- 2X DCM CLK output
      CLK2X180 => open,                  -- 2X, 180 degree DCM CLK out
      CLKDV    => open,                  -- Divided DCM CLK out (CLKDV_DIVIDE)
      CLKFX    => open,                  -- DCM CLK synthesis out (M/D) 
      CLKFX180 => open,                  -- 180 degree CLK synthesis out
      LOCKED   => dcm_locked,            -- DCM LOCK status output (means feedback is in phase with main clock)
      PSDONE   => open,                  -- Dynamic phase adjust done output
      STATUS   => open,                  -- 8-bit DCM status bits output
      CLKFB    => dcm_clk_000,           -- DCM clock feedback
      CLKIN    => clk_bufd,              -- Clock input (from IBUFG, BUFG or DCM)
      PSCLK    => '0',                   -- Dynamic phase adjust clock input
      PSEN     => '0',                   -- Dynamic phase adjust enable input
      PSINCDEC => '0',                   -- Dynamic phase adjust increment/decrement
      RST      => '0'                    -- DCM asynchronous reset input
   );	
	
	DCM_BUF_000: BUFG
	port map(
		O => dcm_clk_000,
		I => dcm_clk_raw_000
	);
	
	SDRAM: entity work.sdram_controller 
	port map(
		clk100mhz => clk100mhz,
	   reset => rst,
	   op => op,
	   addr => addr,
	   op_ack => op_ack,
	   busy_n => busy_n,
	   data_o => led,
	   data_i => data_i,
	             
		dram_clkp => dram_clkp,
		dram_clkn => dram_clkn,
		dram_clke => dram_clke,
		dram_cs => dram_cs,
		dram_cmd => dram_cmd,
		dram_bank => dram_bank,
		dram_addr => dram_addr,
		dram_dm => dram_dm,
		dram_dqs => dram_dqs,
		dram_dq => dram_dq,
		
		debug_reg => debug
	);
	
	debug_reg <= debug;
	
	process(clk_bufd, clke)
	begin
		if (clke = '0') then
			dram_driver_state <= STATE0;
		elsif (rising_edge(clk_bufd)) then
			case dram_driver_state is
				when STATE0 =>
					if (busy_n = '1') then
						dram_driver_state <= STATE1;
					end if;
					
				when STATE1 =>
					op <= "10";
					addr <= "0000000000"& x"6001";
					data_i <= "11110001";
					if (op_ack = '1') then
						dram_driver_state <= STATE2;
					end if;
					
				when STATE2 =>
					if (busy_n = '1') then
						dram_driver_state <= STATE3;
					end if;
					
				when STATE3 =>
					op <= "01";
					addr <= "0000000000" & x"6001";
					if (op_ack = '1') then
						dram_driver_state <= STATE4;
					end if;
					
				when STATE4 =>
					if (busy_n = '1') then
						dram_driver_state <= STATE5;
					end if;
					
				when STATE5 =>
					dram_driver_state <= STATE5;					
			end case;
		end if;
	end process;


end impl;
