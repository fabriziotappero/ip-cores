--------------------------------------------------------------------------------
-- Company: OPL Aerospatiale AG
-- Engineer: Owen Lynn <lynn0p@hotmail.com>
--
-- Create Date:   01:02:17 08/25/2009
-- Design Name:   
-- Module Name:  scratch_isim_tb.vhd
-- Project Name:  SDRAM_TB
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: scratch
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--  Copyright (c) 2009 Owen Lynn <lynn0p@hotmail.com>
--  Released under the GNU Lesser General Public License, Version 3
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
 
library UNISIM;
use UNISIM.VComponents.all;

ENTITY scratch_isim_tb IS
	port(
		debug_reg : out std_logic_vector(7 downto 0)
	);
END scratch_isim_tb;
 
ARCHITECTURE behavior OF scratch_isim_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT scratch
    PORT(
         clk : IN  std_logic;
			clke : in std_logic;
         rst : IN  std_logic;
         led : OUT  std_logic_vector(7 downto 0);
         dram_clkp : OUT  std_logic;
         dram_clkn : OUT  std_logic;
         dram_clke : OUT  std_logic;
			dram_cs : out std_logic;
         dram_cmd : OUT  std_logic_vector(2 downto 0);
         dram_bank : OUT  std_logic_vector(1 downto 0);
         dram_addr : OUT  std_logic_vector(12 downto 0);
         dram_dm : OUT  std_logic_vector(1 downto 0);
         dram_dqs : INOUT  std_logic_vector(1 downto 0);
         dram_dq : INOUT  std_logic_vector(15 downto 0);
			
			debug_reg : out std_logic_vector(7 downto 0)
        );
    END COMPONENT;
	 
	 component ddr
	 port(
		Clk   : in std_logic;
		Clk_n : in std_logic;
		Cke   : in std_logic;
		Cs_n  : in std_logic;
		Ras_n : in std_logic;
		Cas_n : in std_logic;
		We_n  : in std_logic;
		Ba    : in std_logic_vector(1 downto 0);
		Addr  : in std_logic_vector(12 downto 0);
		Dm    : in std_logic_vector(1 downto 0);
		Dq    : inout std_logic_vector(15 downto 0);
		Dqs   : inout std_logic_vector(1 downto 0)
	 );
	 end component;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';

	--BiDirs
   signal dram_dqs : std_logic_vector(1 downto 0);
   signal dram_dq : std_logic_vector(15 downto 0);

 	--Outputs
   signal led : std_logic_vector(7 downto 0);
   signal dram_clkp : std_logic;
   signal dram_clkn : std_logic;
   signal dram_clke : std_logic;
	signal dram_cs : std_logic;
   signal dram_cmd : std_logic_vector(2 downto 0);
   signal dram_bank : std_logic_vector(1 downto 0);
   signal dram_addr : std_logic_vector(12 downto 0);
   signal dram_dm : std_logic_vector(1 downto 0);
	--signal debug_reg : std_logic_vector(7 downto 0);
	signal debug_wait : std_logic_vector(15 downto 0);

   -- Clock period definitions
   constant clk_period : time := 20.0 ns;
	
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: scratch PORT MAP (
          clk => clk,
			 clke => '1',
          rst => rst,
          led => led,
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
			 debug_reg => debug_reg
        );
		  
	DRAM_CHIP: ddr
	port map(
		Clk   => dram_clkp,
		Clk_n => dram_clkn,
		Cke   => dram_clke,
		Cs_n  => dram_cs,
		Ras_n => dram_cmd(0),
		Cas_n => dram_cmd(1),
		We_n  => dram_cmd(2),
		Ba    => dram_bank,
		Addr  => dram_addr,
		Dm    => dram_dm,
		Dq    => dram_dq,
		Dqs   => dram_dqs
	);
		  

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100ms.
      wait for 100ms;	

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
