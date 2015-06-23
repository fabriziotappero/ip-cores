------------------------------------------------------------------
-- PROJECT:      HiCoVec (highly configurable vector processor)
--
-- ENTITY:      tb_flaggroup
--
-- PURPOSE:     testbench of flaggroup entity
--
-- AUTHOR:      harald manske, haraldmanske@gmx.de
--
-- VERSION:     1.0
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity tb_flaggroup is
end tb_flaggroup;

architecture testbench of tb_flaggroup is 
    component flaggroup
        port(   
            clk:    in std_logic;
            c_in:   in std_logic;
            z_in:   in std_logic;
            c_out:  out std_logic;
            z_out:  out std_logic;
            load_c: in std_logic;
            load_z: in std_logic;
            sel_c:  in std_logic_vector(1 downto 0);
            sel_z:  in std_logic_vector(1 downto 0)
        );
    end component;
    
    for impl: flaggroup use entity work.flaggroup(rtl);
    
    signal clk:    std_logic;
    signal c_in:   std_logic;
    signal z_in:   std_logic;
    signal c_out:  std_logic;
    signal z_out:  std_logic;
    signal load_c: std_logic;
    signal load_z: std_logic;
    signal sel_c:  std_logic_vector(1 downto 0);
    signal sel_z:  std_logic_vector(1 downto 0);
        
    constant period	: time := 2ns;
    
    begin
        impl: flaggroup port map (clk => clk, c_in => c_in, z_in => z_in, c_out => c_out,
            z_out => z_out, load_c => load_c, load_z => load_z, sel_c => sel_c, sel_z => sel_z); 
    process
    begin
            wait for 100ns;
            
            -- set c, clear z
            sel_c <= "11";          
            sel_z <= "10";
            load_c <= '1';
            load_z <= '1';
                        
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
            assert c_out = '1'
                report "set c, clear z : c_out"
                severity Error;

            assert z_out = '0'
                report "set c, clear z : z_out"
                severity Error;   

            -- clear c, set z
            sel_c <= "10";          
            sel_z <= "11";
            load_c <= '1';
            load_z <= '1';
                        
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
            assert c_out = '0'
                report "clear c, set z : c_out"
                severity Error;

            assert z_out = '1'
                report "clear c, set z : z_out"
                severity Error;    
            
            
            -- load c, read z
            c_in <= '1';
            z_in <= '0';
            
            sel_c <= "00";          
            sel_z <= "00";
            load_c <= '1';
            load_z <= '0';
            
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
            assert c_out = '1'
                report "load c, read z : c_out"
                severity Error;

            assert z_out = '1'
                report "load c, read z : z_out"
                severity Error; 
                
            
            -- read c, load z
            c_in <= '0';
            z_in <= '0';
            
            sel_c <= "00";          
            sel_z <= "00";
            load_c <= '0';
            load_z <= '1';
            
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
            assert c_out = '1'
                report "read c, load z : c_out"
                severity Error;

            assert z_out = '0'
                report "read c, load z : z_out"
                severity Error; 
            
            wait;
    end process;
end;