--/////////////////////////REG///////////////////////////////
--Purpose: 37-bit register
--Created by: Minzhen Ren
--Last Modified by: Minzhen Ren
--Last Modified Date: October 6, 2010
--Lately Updates: 37-bit register for CORDIC log algorithm
--/////////////////////////////////////////////////////////////////
library IEEE;
  use IEEE.Std_Logic_1164.all;
  use IEEE.Std_Logic_Arith.all;
  use IEEE.Std_Logic_Unsigned.all;
  
 entity REG is
	generic( BIT_WIDTH       : Natural := 37);   -- Default is 37 bits
    port( CLK       : in  std_logic;
          RESET     : in  std_logic; -- high asserted
          DATA_IN   : in  std_logic_vector( BIT_WIDTH-1 downto 0 );
          DATA_OUT  : out std_logic_vector( BIT_WIDTH-1 downto 0 )
        );
 end REG;
 
 architecture BEHAVIOR of REG is
	
	begin
		
		reg_proc : process(CLK, RESET)
		begin
		if RESET = '1' then
			DATA_OUT <= (others => '0');
		elsif (CLK'event) and (CLK = '1') then
			DATA_OUT <= DATA_IN;
		end if;
		end process;
 end BEHAVIOR;