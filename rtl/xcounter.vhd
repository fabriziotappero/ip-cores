----------------------------------------------------------------------------------
-- Company:            ISI/Nallatech
-- Engineer:           Luis Munoz
-- Email:              lfmunoz4@gmail.com
-- 
-- Create Date:        06:01:23 01/01/2011 
--
-- Module Name:        XCOUNTER - Behavioral 
--
-- Project Name:       Counter
--
-- Target Devices:     Any
--
-- Description:        This module increments on the risinge edge of CLK_i when CLKen_i 
--                     is high. It counts from 0 to XVAL and wraps around, on the last value,
--                     XVAL, DONE_o goes high.
--
-- Revision:           1.0 Initial Release
--
-- Additional Comments: 
     
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL; 


entity xcounter is
generic(
    XVAL      : std_logic_vector := x"3"
);
port(
    CLK_i     : in std_logic;
    RST_i     : in std_logic;
    CLKen_i   : in std_logic;    
    COUNT_o   : out std_logic_vector(XVAL'length-1 downto 0);
    DONE_o    : out std_logic
    
);
end xcounter;

architecture Behavioral of xcounter is

   constant lastVal        : std_logic_vector(XVAL'length-1 downto 0) := XVAL;    
   signal   counter_r      : std_logic_vector(XVAL'length-1 downto 0);    

begin
-------------------------------------------------
    process(CLK_i, CLKen_i, RST_i)
    begin
        if rising_edge(CLK_i) then
            if(RST_i = '1') then
                counter           <= (others=>'0');
            elsif( CLKen_i = '1') then
                if( counter_r = lastVal) then
                    counter_r     <= (others=>'0');    
                else
                    counter_r     <= counter_r + 1;
                end if;        
            end if;    
        end if;
    end process;    
    -- two output signals done and the counter value
    DONE_o    <= '1' when counter_r = lastVal  else '0';    
    COUNT_o   <= counter_r;
-------------------------------------------------
end Behavioral;

