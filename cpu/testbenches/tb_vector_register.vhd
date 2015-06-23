------------------------------------------------------------------
-- PROJECT:      HiCoVec (highly configurable vector processor)
--
-- ENTITY:      tb_vector_register
--
-- PURPOSE:     testbench of vector_register entity
--
-- AUTHOR:      harald manske, haraldmanske@gmx.de
--
-- VERSION:     1.0
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity tb_vector_register is
end tb_vector_register;

architecture testbench of tb_vector_register is 
    component vector_register
        generic (
            n : integer range 1 to 256;
            slicenr : natural
        );
                
        port (   
            clk:            in  std_logic;
            r_in:           in  std_logic_vector(31 downto 0);
            v_out:          out std_logic_vector(31 downto 0);
            w_out:          out std_logic_vector(31 downto 0);
            load_r:         in  std_logic;
            load_select:    in  std_logic;
            k_in:           in  std_logic_vector(31 downto 0);       
            select_v:       in  std_logic_vector(7 downto 0);
            select_w:       in  std_logic_vector(2 downto 0);
            select_r:       in  std_logic_vector(7 downto 0)
        );
    end component;
    
    for impl: vector_register use entity work.vector_register(rtl);
    
    constant n:        integer range 0 to 256 := 4;
    constant slicenr:  natural := 2;
    
    signal clk:         std_logic;
    signal r_in:        std_logic_vector(31 downto 0);
    signal v_out:       std_logic_vector(31 downto 0);
    signal w_out:       std_logic_vector(31 downto 0);
    signal k_in:        std_logic_vector(31 downto 0);
    signal load_r:      std_logic;
    signal load_select: std_logic;
    signal select_v:    std_logic_vector(7 downto 0) := "00000000";
    signal select_w:    std_logic_vector(2 downto 0) := "000";
    signal select_r:    std_logic_vector(7 downto 0) := "00000000";
    
    constant period	: time := 2ns;
    
    begin
        impl: vector_register generic map (n => n, slicenr => slicenr) 
            port map (clk => clk, r_in => r_in, v_out => v_out, w_out => w_out,
                load_r => load_r, load_select => load_select, k_in => k_in, select_v =>
                select_v, select_w => select_w, select_r => select_r); 
                
    process
    begin
            
            wait for 100ns;
            
            -- 1: load 00000000, v_out = 00000000, w_out = 00000000
            
            r_in <= "11010010110111101101001011011110";
            select_r <= "00000000";
            select_v <= "00000000";
            select_w <= "000";
            load_r <= '1';
            load_select <= '0';
            
                       
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
            assert v_out = "11010010110111101101001011011110" 
                report "1 : v_out"
                severity Error;
                
            assert w_out = "11010010110111101101001011011110" 
                report "1 : w_out"
                severity Error;
                
            
            -- 2: load 00000001, v_out = 00000000, w_out = 00000001
            
            r_in <= "10010011001110101001001100111010";
            select_r <= "00000001";
            select_v <= "00000000";
            select_w <= "001";
            load_r <= '1';
            load_select <= '0';
            
                       
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
            assert v_out = "11010010110111101101001011011110" 
                report "2 : v_out"
                severity Error;
                
            assert w_out = "10010011001110101001001100111010" 
                report "2 : w_out"
                severity Error;
                
            
            -- 3: load 00000010, v_out = 00000010, w_out = 00000000
            
            r_in <= "11110001110000111111000111000011";
            select_r <= "00000010";
            select_v <= "00000010";
            select_w <= "000";
            load_r <= '1';
            load_select <= '0';
            
                       
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
            assert v_out = "11110001110000111111000111000011" 
                report "3 : v_out"
                severity Error;
                
            assert w_out = "11010010110111101101001011011110" 
                report "3 : w_out"
                severity Error;
                
            -- 4: load 00000011, v_out = 00000000, w_out = 00000010
            
            r_in <= "00011110000111100001111000011110";
            select_r <= "00000011";
            select_v <= "00000000";
            select_w <= "010";
            load_r <= '1';
            load_select <= '0';
            
                       
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
            assert v_out = "11010010110111101101001011011110" 
                report "4 : v_out"
                severity Error;
                
            assert w_out = "11110001110000111111000111000011" 
                report "4 : w_out"
                severity Error;
            
            -- 5: load 00000000, set slicenr wrong
            
            r_in <= "11111111000000001111111100000000";
            select_r <= "00000000";
            select_v <= "00000000";
            select_w <= "010";
            k_in <= "00000000000000000000000000000000";
            load_r <= '1';
            load_select <= '1';
            
                       
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
            assert v_out = "11010010110111101101001011011110" 
                report "5 : v_out"
                severity Error;
                
            assert w_out = "11110001110000111111000111000011" 
                report "5 : w_out"
                severity Error;
                
            
            -- 6: load 00000000, set slicenr properly
            
            r_in <= "11111111000000001111111100000000";
            select_r <= "00000000";
            select_v <= "00000000";
            select_w <= "010";
            k_in <= "00000000000000000000000000000010";
            load_r <= '1';
            load_select <= '1';
            
                       
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
            assert v_out = "11111111000000001111111100000000" 
                report "6 : v_out"
                severity Error;
                
            assert w_out = "11110001110000111111000111000011" 
                report "6 : w_out"
                severity Error;
            
            wait;
    end process;
    
end;