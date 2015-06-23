------------------------------------------------------------------
-- PROJECT:     HiCoVec (highly configurable vector processor)
--
-- ENTITY:      tb_system
--
-- PURPOSE:     testbench of system entity
--              top level simulation model !!!
--              requires debugging unit to be deactivated !!!
--
-- AUTHOR:      harald manske, haraldmanske@gmx.de
--
-- VERSION:     1.0
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity tb_system is
end tb_system;

architecture testbench of tb_system is 
    component system
        port(
            clk: in std_logic;
            reset: in std_logic;
            
            rs232_txd: out std_logic; 
            rs232_rxd: in std_logic
         );
    end component;
    
    for impl: system use entity work.system(rtl);
    
    signal clk:   std_logic;
    signal reset: std_logic;
    signal rxd:   std_logic;
    signal txd:   std_logic;
    
    constant period	: time := 2ns;

begin
    
    impl: system port map (clk => clk, reset => reset, rs232_txd => txd, rs232_rxd => rxd);
                
    process
    begin
        wait for 100ns;
       
        -- reset
        reset <= '1';
        clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
        reset <= '0';
        
        -- start
        for i in 0 to 420000000 loop
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
        end loop;
            
        wait;
    end process;
    
end;