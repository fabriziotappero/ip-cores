----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:53:58 02/09/2009 
-- Design Name: 
-- Module Name:    clockdiv - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity clockdiv is
    Port ( CLK_50M : in  STD_LOGIC;
           CLK : out  STD_LOGIC;		-- 2MHz
--			  CLK_180 : out std_logic;
			  LOCKED : out STD_LOGIC);
end clockdiv;

architecture Behavioral of clockdiv is
	signal CLK_out : std_logic := '0';
begin
	LOCKED <= '1';
	process (CLK_50M)
		-- 50M/25=2M.. should use DCM.
		constant top : integer := 25/2-1;
		variable count : integer range 0 to top := 0;
	begin
		if rising_edge(CLK_50M) then
			if count=top then
				CLK_out <= not CLK_out;
				count := 0;
			else
				count := count+1;
			end if;
		end if;
	end process;

	CLK <= CLK_out;

   -- DCM_SP: Digital Clock Manager Circuit
   --         Spartan-3E/3A	(Spartan 3 can't output this low frequency)
   -- Xilinx HDL Language Template, version 10.1.3

--   DCM_SP_inst : DCM_SP
--   generic map (
--      CLKDV_DIVIDE => 2.0, --  Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
--                           --     7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
--      CLKFX_DIVIDE => 25,   --  Can be any interger from 1 to 32
--      CLKFX_MULTIPLY => 4, --  Can be any integer from 2 to 32
--      CLKIN_DIVIDE_BY_2 => false, --  TRUE/FALSE to enable CLKIN divide by two feature
--      CLKIN_PERIOD => 200.0, --  Specify period of input clock in ns
--      CLKOUT_PHASE_SHIFT => "NONE", --  Specify phase shift of "NONE", "FIXED" or "VARIABLE" 
--      CLK_FEEDBACK => "NONE",         --  Specify clock feedback of "NONE", "1X" or "2X" 
--      DESKEW_ADJUST => "SYSTEM_SYNCHRONOUS", -- "SOURCE_SYNCHRONOUS", "SYSTEM_SYNCHRONOUS" or
--                                             --     an integer from 0 to 15
--      DLL_FREQUENCY_MODE => "LOW",     -- "HIGH" or "LOW" frequency mode for DLL
--      DUTY_CYCLE_CORRECTION => TRUE, --  Duty cycle correction, TRUE or FALSE
--      PHASE_SHIFT => 0,        --  Amount of fixed phase shift from -255 to 255
--      STARTUP_WAIT => TRUE) --  Delay configuration DONE until DCM_SP LOCK, TRUE/FALSE
--   port map (
----      CLK0 => CLK_2X,     -- 0 degree DCM CLK ouptput
----      CLK180 => CLK180, -- 180 degree DCM CLK output
----      CLK270 => CLK270, -- 270 degree DCM CLK output
----      CLK2X => CLK_400k,   -- 2X DCM CLK output
----      CLK2X180 => CLK2X180, -- 2X, 180 degree DCM CLK out
----      CLK90 => CLK90,   -- 90 degree DCM CLK output
----      CLKDV => CLK_2X,   -- Divided DCM CLK out (CLKDV_DIVIDE)
--      CLKFX => CLK,   -- DCM CLK synthesis out (M/D)
----      CLKFX180 => CLK_180, -- 180 degree CLK synthesis out
--      LOCKED => LOCKED, -- DCM LOCK status output
----      PSDONE => PSDONE, -- Dynamic phase adjust done output
----      STATUS => STATUS, -- 8-bit DCM status bits output
----      CLKFB => CLK,   -- DCM clock feedback
--      CLKIN => CLK_out   -- Clock input (from IBUFG, BUFG or DCM)
----      PSCLK => PSCLK,   -- Dynamic phase adjust clock input
----      PSEN => PSEN,     -- Dynamic phase adjust enable input
----      PSINCDEC => PSINCDEC, -- Dynamic phase adjust increment/decrement
----      RST => RST        -- DCM asynchronous reset input
--   );
end Behavioral;
