------------------------------------------------------------------
-- PROJECT:      HiCoVec (highly configurable vector processor)
--
-- ENTITY:      tb_vector_alu_32
--
-- PURPOSE:     testbench of vector_alu_32 entity 
--
-- AUTHOR:      harald manske, haraldmanske@gmx.de
--
-- VERSION:     
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity tb_vector_alu_32 is
end tb_vector_alu_32;

architecture testbench of tb_vector_alu_32 is 
    component vector_alu_32
        port (
                clk:                in std_logic;
                v_in:               in std_logic_vector(31 downto 0);
                w_in:               in std_logic_vector(31 downto 0);
                carry_in:           in std_logic;
                rshift_in:          in std_logic;
                carry_out:          out std_logic;
                valu_out:           out std_logic_vector(31 downto 0);
                valuop:             in std_logic_vector(3 downto 0);
                source_sel:         in std_logic_vector(1 downto 0);
                carry_sel:          in std_logic_vector(1 downto 0);
                mult_source_sel:    in std_logic_vector(1 downto 0); 
                mult_dest_sel:      in std_logic_vector(1 downto 0); 
                reg_input_sel:      in std_logic;                   
                load_lsr:           in std_logic;
                load_other:         in std_logic
        );
    end component;
    
    component valu_controlunit
        port(   
            clk:                in std_logic;
            valu_go:            in std_logic;
            valuop:             in std_logic_vector(3 downto 0);
            vwidth:             in std_logic_vector(1 downto 0);
            source_sel:         out std_logic_vector(1 downto 0);
            carry_sel:          out std_logic_vector(1 downto 0);
            mult_source_sel:    out std_logic_vector(1 downto 0); 
            mult_dest_sel:      out std_logic_vector(1 downto 0); 
            reg_input_sel:      out std_logic;                 
            load_lsr:           out std_logic;
            load_other:         out std_logic;
            out_valid:          out std_logic
        );
    end component;
    
    for valu_controlunit_impl: valu_controlunit use entity work.valu_controlunit(rtl);
    for alu_impl: vector_alu_32 use entity work.vector_alu_32(rtl);
    
    signal clk:             std_logic;
    signal valu_go:         std_logic;
    signal vwidth:          std_logic_vector(1 downto 0);
    signal out_valid:       std_logic;
    signal v_in:            std_logic_vector(31 downto 0);
    signal w_in:            std_logic_vector(31 downto 0);
    signal carry_in:        std_logic;
    signal rshift_in:       std_logic;
    signal carry_out:       std_logic;
    signal valu_out:        std_logic_vector(31 downto 0);
    signal valuop:          std_logic_vector(3 downto 0);
    signal source_sel:      std_logic_vector(1 downto 0);
    signal carry_sel:       std_logic_vector(1 downto 0);
    signal load_lsr:        std_logic;
    signal load_other:      std_logic;
    signal mult_source_sel: std_logic_vector(1 downto 0); 
    signal mult_dest_sel:   std_logic_vector(1 downto 0); 
    signal reg_input_sel:   std_logic := '0';    
    
    constant period	: time := 2ns;
    
    begin
        valu_controlunit_impl: valu_controlunit
        port map (
            clk => clk,
            valu_go => valu_go,
            valuop => valuop,
            vwidth => vwidth,
            source_sel => source_sel,
            carry_sel => carry_sel,
            mult_source_sel => mult_source_sel,
            mult_dest_sel => mult_dest_sel,
            reg_input_sel => reg_input_sel,
            load_lsr => load_lsr,
            load_other => load_other,
            out_valid => out_valid
        ); 
        
        alu_impl: vector_alu_32
            port map (
                clk => clk,
                v_in => v_in,
                w_in => w_in,
                carry_in => carry_in,
                rshift_in => rshift_in,
                carry_out => carry_out,
                valu_out => valu_out,
                valuop => valuop,
                source_sel => source_sel,
                carry_sel => carry_sel,
                mult_source_sel => mult_source_sel,
                mult_dest_sel => mult_dest_sel,
                reg_input_sel => reg_input_sel,
                load_lsr => load_lsr,
                load_other => load_other
            );
        
    process
    begin
            
            wait for 100ns;
       
            -- vadd 8_bit
            v_in <= x"FE5A3415";
            w_in <= x"3EBB6849";

            carry_in <= '1';
            rshift_in <= '0';
            valuop <= "0000";
            vwidth <= "00";
            
            valu_go <= '1';
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            valu_go <= '0';
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
             
            
            assert valu_out = x"3C159C5E"
                report "vadd 8_bit : valu_out"
                severity Error; 
                
            assert carry_out = '1'
                report "vadd 8_bit : carry_out"
                severity Error; 
            
            
            -- vadd 16_bit
            v_in <= x"F0A17E63";
            w_in <= x"09C4A185";

            carry_in <= '1';
            rshift_in <= '0';
            valuop <= "0000";
            vwidth <= "01";
            
            valu_go <= '1';
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            valu_go <= '0';
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
            
            assert valu_out = x"FA651FE8"
                report "vadd 16_bit : valu_out"
                severity Error; 
                
            assert carry_out = '0'
                report "vadd 16_bit : carry_out"
                severity Error; 
					 
			
            -- vadd 32_bit
            v_in <= x"F0A17E63";
            w_in <= x"09C4A185";

            carry_in <= '1';
            rshift_in <= '0';
            valuop <= "0000";
            vwidth <= "10";
            
            valu_go <= '1';
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            valu_go <= '0';
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
            assert valu_out = x"FA661FE8"
                report "vadd 32_bit : valu_out"
                severity Error; 
                
            assert carry_out = '0'
                report "vadd 32_bit : carry_out"
                severity Error; 
			
            -- vadd 64_bit
            v_in <= x"F0A17E63";
            w_in <= x"09C4A185";

            carry_in <= '1';
            rshift_in <= '0';
            valuop <= "0000";
            vwidth <= "11";
            
            valu_go <= '1';
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            valu_go <= '0';
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
            assert valu_out = x"FA661FE9"
                report "vadd 64_bit : valu_out"
                severity Error; 
                
            assert carry_out = '0'
                report "vadd 64_bit : carry_out"
                severity Error; 
            
            
            -- vand 8_bit
            v_in <= "10010100110110101110010011101011";
            w_in <= "11010110101101010101010101010110";
    
            carry_in <= '1';
            rshift_in <= '0';
            valuop <= "1000";
            vwidth <= "00";
            
            valu_go <= '1';
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            valu_go <= '0';
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
            assert valu_out = "10010100100100000100010001000010"
                report "vand 8_bit : valu_out"
                severity Error; 
                
            assert carry_out = '0'
                report "vand 8_bit : carry_out"
                severity Error;
                
            -- vand 16_bit
            v_in <= "10010100110110101110010011101011";
            w_in <= "11010110101101010101010101010110";
    
            carry_in <= '1';
            rshift_in <= '0';
            valuop <= "1000";
            vwidth <= "01";
            
            valu_go <= '1';
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            valu_go <= '0';
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
            assert valu_out = "10010100100100000100010001000010"
                report "vand 16_bit : valu_out"
                severity Error; 
                
            assert carry_out = '0'
                report "vand 16_bit : carry_out"
                severity Error;
                
            -- vand 32_bit
            v_in <= "10010100110110101110010011101011";
            w_in <= "11010110101101010101010101010110";
    
            carry_in <= '1';
            rshift_in <= '0';
            valuop <= "1000";
            vwidth <= "10";
            
            valu_go <= '1';
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            valu_go <= '0';
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
            assert valu_out = "10010100100100000100010001000010"
                report "vand 32_bit : valu_out"
                severity Error; 
                
            assert carry_out = '0'
                report "vand 32_bit : carry_out"
                severity Error; 
            
            -- vand 64_bit
            v_in <= "10010100110110101110010011101011";
            w_in <= "11010110101101010101010101010110";
    
            carry_in <= '1';
            rshift_in <= '0';
            valuop <= "1000";
            vwidth <= "11";
            
            valu_go <= '1';
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            valu_go <= '0';
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
            assert valu_out = "10010100100100000100010001000010"
                report "vand 64_bit : valu_out"
                severity Error; 
                
            assert carry_out = '0'
                report "vand 64_bit : carry_out"
                severity Error; 
            
            
            -- vlsl 8_bit
            v_in <= "10010101001100100101101110111011";
            w_in <= "11111111111111111111111111111111";
    
            carry_in <= '1';
            rshift_in <= '0';
            valuop <= "1100";
            vwidth <= "00";
            
            valu_go <= '1';
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            valu_go <= '0';
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
            assert valu_out = "00101010011001001011011001110110"
                report "vlsl 8_bit : valu_out"
                severity Error; 
                
            assert carry_out = '1'
                report "vlsl 8_bit : carry_out"
                severity Error;
            
            
            -- vlsl 16_bit
            v_in <= "10010101001100100101101110111011";
            w_in <= "11111111111111111111111111111111";
    
            carry_in <= '1';
            rshift_in <= '0';
            valuop <= "1100";
            vwidth <= "01";
            
            valu_go <= '1';
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            valu_go <= '0';
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
            assert valu_out = "00101010011001001011011101110110"
                report "vlsl 16_bit : valu_out"
                severity Error; 
                
            assert carry_out = '1'
                report "vlsl 16_bit : carry_out"
                severity Error;
                
            -- vlsl 32_bit
            v_in <= "10010101001100100101101110111011";
            w_in <= "11111111111111111111111111111111";
    
            carry_in <= '1';
            rshift_in <= '0';
            valuop <= "1100";
            vwidth <= "10";
            
            valu_go <= '1';
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            valu_go <= '0';
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
            assert valu_out = "00101010011001001011011101110110"
                report "vlsl 32_bit : valu_out"
                severity Error; 
                
            assert carry_out = '1'
                report "vlsl 32_bit : carry_out"
                severity Error;
                
            -- vlsl 64_bit
            v_in <= "10010101001100100101101110111011";
            w_in <= "11111111111111111111111111111111";
    
            carry_in <= '1';
            rshift_in <= '0';
            valuop <= "1100";
            vwidth <= "11";
            
            valu_go <= '1';
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            valu_go <= '0';
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
            assert valu_out = "00101010011001001011011101110111"
                report "vlsl 64_bit : valu_out"
                severity Error; 
                
            assert carry_out = '1'
                report "vlsl 64_bit : carry_out"
                severity Error;
            
            
            -- vlsr 8_bit
            v_in <= "10010101001100100101101110111011";
            w_in <= "11111111111111111111111111111111";
    
            carry_in <= '1';
            rshift_in <= '0';
            valuop <= "1110";
            vwidth <= "00";
            
            valu_go <= '1';
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            valu_go <= '0';
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
            assert valu_out = "01001010000110010010110101011101"
                report "vlsr 8_bit : valu_out"
                severity Error; 
                
            assert carry_out = '1'
                report "vlsr 8_bit : carry_out"
                severity Error;
                
            
            -- vlsr 16_bit
            v_in <= "10010111011010110100100110010010";
            w_in <= "11111111111111111111111111111111";
    
            carry_in <= '1';
            rshift_in <= '1';
            valuop <= "1110";
            vwidth <= "01";
            
            valu_go <= '1';
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            valu_go <= '0';
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
            assert valu_out = "01001011101101010010010011001001"
                report "vlsr 16_bit : valu_out"
                severity Error; 
                
            assert carry_out = '0'
                report "vlsr 16_bit : carry_out"
                severity Error;
            
            
            -- vlsr 32_bit
            v_in <= "11001010110101011011111110110111";
            w_in <= "11111111111111111111111111111111";
    
            carry_in <= '1';
            rshift_in <= '1';
            valuop <= "1110";
            vwidth <= "10";
            
            valu_go <= '1';
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            valu_go <= '0';
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
            assert valu_out = "01100101011010101101111111011011"
                report "vlsr 32_bit : valu_out"
                severity Error; 
                
            assert carry_out = '1'
                report "vlsr 32_bit : carry_out"
                severity Error;
                
            -- vlsr 64_bit
            v_in <= "00101010010110101010101001110110";
            w_in <= "11111111111111111111111111111111";
    
            carry_in <= '1';
            rshift_in <= '1';
            valuop <= "1110";
            vwidth <= "11";
            
            valu_go <= '1';
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            valu_go <= '0';
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            clk <= '0'; wait for period / 2; clk <= '1'; wait for period / 2;
            
            assert valu_out = "10010101001011010101010100111011"
                report "vlsr 64_bit : valu_out"
                severity Error; 
                
            assert carry_out = '0'
                report "vlsr 64_bit : carry_out"
                severity Error;
            
			wait;
         
				
    end process;
    
end;