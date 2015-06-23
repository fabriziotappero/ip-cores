--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   00:00:04 08/14/2009
-- Design Name:   
-- Module Name:   /home/yann/fpga/work/pdp1-3/testtop.vhd
-- Project Name:  pdp1-3
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: top
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
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
 
ENTITY testtop IS
END testtop;
 
ARCHITECTURE behavior OF testtop IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT top
    PORT(
         CLK_50M : IN  std_logic;
         LED : OUT  std_logic_vector(7 downto 0);
         SW : IN  std_logic_vector(3 downto 0);
         AWAKE : OUT  std_logic;
         SPI_MOSI : OUT  std_logic;
         DAC_CS : OUT  std_logic;
         SPI_SCK : OUT  std_logic;
         DAC_CLR : OUT  std_logic;
         DAC_OUT : IN  std_logic;
			RS232_DCE_RXD : IN std_logic;
			RS232_DCE_TXD : OUT std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLK_50M : std_logic := '0';
   signal SW : std_logic_vector(3 downto 0) := (others => '0');
   signal DAC_OUT : std_logic := '0';

 	--Outputs
   signal LED : std_logic_vector(7 downto 0);
   signal AWAKE : std_logic;
   signal SPI_MOSI : std_logic;
   signal DAC_CS : std_logic;
   signal SPI_SCK : std_logic;
   signal DAC_CLR : std_logic;
	signal TXD, RXD : std_logic;
 
   constant CLK_50M_period : time := 20ns;
	constant bittime : time := 8.680555us; --1s/115200;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: top PORT MAP (
          CLK_50M => CLK_50M,
          LED => LED,
          SW => SW,
          AWAKE => AWAKE,
          SPI_MOSI => SPI_MOSI,
          DAC_CS => DAC_CS,
          SPI_SCK => SPI_SCK,
          DAC_CLR => DAC_CLR,
          DAC_OUT => DAC_OUT,
			RS232_DCE_RXD => RXD,
			RS232_DCE_TXD => TXD
        );
 
   -- No clocks detected in port list. Replace CLK_50M below with 
   -- appropriate port name 
 
   CLK_50M_process :process
   begin
		CLK_50M <= '0';
		wait for CLK_50M_period/2;
		CLK_50M <= '1';
		wait for CLK_50M_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin
		RXD <= '1';
      -- hold reset state for 100ms.
      wait for 10ms;
		
				wait for 16*bittime;
		-- TODO: show reply data
		RXD <= '0'; wait for bittime;
		RXD <= '1'; wait for bittime;
		RXD <= '0'; wait for bittime;
		RXD <= '1'; wait for bittime;
		RXD <= '0'; wait for bittime;
		RXD <= '0'; wait for bittime;
		RXD <= '0'; wait for bittime;
		RXD <= '0'; wait for bittime;
		RXD <= '1'; wait for bittime;
		RXD <= '1'; wait for bittime;		-- first sixbit 000101
		wait for 16*bittime;
		RXD <= '0'; wait for bittime;
		RXD <= '1'; wait for bittime;
		RXD <= '1'; wait for bittime;
		RXD <= '1'; wait for bittime;
		RXD <= '1'; wait for bittime;
		RXD <= '1'; wait for bittime;
		RXD <= '1'; wait for bittime;
		RXD <= '0'; wait for bittime;
		RXD <= '0'; wait for bittime;
		RXD <= '1'; wait for bittime;				-- this byte is not marked as binary data and should be skipped
		wait for 16*bittime;
		RXD <= '0'; wait for bittime;
		RXD <= '0'; wait for bittime;
		RXD <= '1'; wait for bittime;
		RXD <= '1'; wait for bittime;
		RXD <= '0'; wait for bittime;
		RXD <= '0'; wait for bittime;
		RXD <= '0'; wait for bittime;
		RXD <= '0'; wait for bittime;
		RXD <= '1'; wait for bittime;
		RXD <= '1'; wait for bittime;		-- second sixbit 001100
		wait for 16*bittime;
		RXD <= '0'; wait for bittime;
		RXD <= '0'; wait for bittime;
		RXD <= '0'; wait for bittime;
		RXD <= '0'; wait for bittime;
		RXD <= '1'; wait for bittime;
		RXD <= '1'; wait for bittime;
		RXD <= '1'; wait for bittime;
		RXD <= '0'; wait for bittime;
		RXD <= '1'; wait for bittime;
		RXD <= '1'; wait for bittime;		-- third sixbit 111000


      wait for CLK_50M_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
