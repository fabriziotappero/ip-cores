--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:    20:57:23 09/12/05
-- Design Name:    
-- Module Name:    fill-unit - Behavioral
-- Project Name:   
-- Target Device:  
-- Tool versions:  
-- Description:
--
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
--------------------------------------------------------------------------------

library IEEE, UNISIM;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use UNISIM.VComponents.all;
use WORK.common.all;
use WORK.sdram.all;

use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
		  

package fillunit_pckg is
	component fillunit 
	  	generic(
	    FREQ                 :     natural := 50_000;  -- operating frequency in KHz
	    DATA_WIDTH           :     natural := 16;  -- host & SDRAM data width
	    HADDR_WIDTH          :     natural := 23  -- host-side address width
	    );
	  port(
	    clk                  : in  std_logic;  -- master clock
		 reset					 :	in  std_logic;  -- reset for this entity
	 	 rd1                  : out  std_logic;  -- initiate read operation
	    wr1                  : out  std_logic;  -- initiate write operation
	    opBegun              : in std_logic;  -- read/write/self-refresh op begun (clocked)
	    done1                : in std_logic;  -- read or write operation is done
	    hAddr1               : out  std_logic_vector(HADDR_WIDTH-1 downto 0);  -- address to SDRAM
	    hDIn1                : out  std_logic_vector(DATA_WIDTH-1 downto 0);  -- data to dualport to SDRAM
	    hDOut1               : in std_logic_vector(DATA_WIDTH-1 downto 0)  -- data from dualport to SDRAM
		 );
	end component fillunit;
end package fillunit_pckg;

library IEEE, UNISIM;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use UNISIM.VComponents.all;
use WORK.common.all;
use WORK.sdram.all;

use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity fillunit is
  	generic(
    FREQ                 :     natural := 50_000;  -- operating frequency in KHz
    DATA_WIDTH           :     natural := 16;  -- host & SDRAM data width
    HADDR_WIDTH          :     natural := 23  -- host-side address width
    );
  port(
    -- host side
    clk                  : in  std_logic;  -- master clock
	 reset					 :	in  std_logic;  -- reset for this entity
 	 rd1                  : out  std_logic;  -- initiate read operation
    wr1                  : out  std_logic;  -- initiate write operation
    opBegun              : in std_logic;  -- read/write/self-refresh op begun (clocked)
    done1                : in std_logic;  -- read or write operation is done
    hAddr1               : out  std_logic_vector(HADDR_WIDTH-1 downto 0);  -- address to SDRAM
    hDIn1                : out  std_logic_vector(DATA_WIDTH-1 downto 0);  -- data to dualport to SDRAM
    hDOut1               : in std_logic_vector(DATA_WIDTH-1 downto 0)  -- data from dualport to SDRAM
    );
end entity fillunit;

architecture arch of fillunit is

type cntrl_state is (idle, write_state, wait_state);

signal pixeldata, output	 : std_logic_vector(15 downto 0); -- broken down to 2 8 bit pixels
signal currentbuffer, write, start : std_logic;
signal address 				 : std_logic_vector(22 downto 0); 
signal counter 				 : std_logic_vector(11 downto 0);
begin
	hDIn1 <= output;
	hAddr1 <= address;
	wr1 <= '1';
	start <= '1';
	output <= pixeldata;


	process (clk, reset)
	begin	 
	   if rising_edge(clk) then
	 		if address = "0000001001011000000000" then
					address <= "00000000000000000000000";
					counter <= counter + 1;
			elsif done1 = '1' then
					address <= address + 1;
			
			end if;
		end if;
	end process;
		
screendivide: process (counter)
	begin
		if (counter = "100000000000") then
			pixeldata <= pixeldata + "0000010000000100";
		else
			pixeldata <= pixeldata;
		end if;
	end process;

end arch;