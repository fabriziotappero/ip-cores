----------------------------------------------------------------------------------
-- Company: 
-- Engineer:     Lazaridis Dimitris
-- 
-- Create Date:    22:36:33 06/22/2012 
-- Design Name: 
-- Module Name:    DM_cnt_core - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DM_cnt_core is
port (
      --clk : in std_logic;
      --From_Alu : in std_logic_vector(31 downto 0);
		--op_code: in std_logic_vector(5 downto 0);
		MemRead: in std_logic;
		MemWrite : in std_logic;
		--IorD : in std_logic;
	   --E : out std_logic_vector(1 downto 0);
		We_c : out std_logic_vector(3 downto 0);
		Re_c : out std_logic_vector(3 downto 0);
		Ssr_c: out std_logic_vector(3 downto 0)
);
end DM_cnt_core;


architecture Behavioral of DM_cnt_core is
begin  
         --process(clk,MemRead,MemWrite)
        -- begin			
		--	if Falling_edge(clk) then
			Re_c(3 downto 0) <= MemRead & MemRead & MemRead & MemRead; 
			We_c(3 downto 0) <= MemWrite & MemWrite & MemWrite & MemWrite;
		
			Ssr_c <=(others => '0');  
			--end if;
			  
		--	end process;
						
			
		--	case op_code is
       --         when LB =>
      --          case From_Alu(1 downto 0) is
     --           when "00" =>
     --            Re_c(3 downto 0) <= "0001";
     --           when "01" =>
      --           Re_c(3 downto 0) <= "0010";
    --            when "10" =>
    --             Re_c(3 downto 0) <= "0100";
     --           when "11" =>
    --             Re_c(3 downto 0) <= "1000";
    --            when others =>
   --              Re_c(3 downto 0) <= "0000";  -- we -> 0;
  --              end case;					  
	--		       when others =>
	--				  Re_c(3 downto 0) <= "0000";
	--				 end case; 
               
end Behavioral;





