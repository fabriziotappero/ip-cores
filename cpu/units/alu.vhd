------------------------------------------------------------------
-- PROJECT:      HiCoVec (highly configurable vector processor)
--
-- ENTITY:      alu
--
-- PURPOSE:     alu of scalar unit
--
-- AUTHOR:      harald manske, haraldmanske@gmx.de
--
-- VERSION:     1.0
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

use work.cfg.all;

entity alu is
    port(   
        a_in:       in std_logic_vector(31 downto 0);
        b_in:       in std_logic_vector(31 downto 0);
        carry_in:   in std_logic;
        aluop:      in std_logic_vector(3 downto 0);
        op_select:  in std_logic;
        zero_out:   out std_logic;
        carry_out:  out std_logic;
        alu_out:    out std_logic_vector(31 downto 0)
    );
end alu;

architecture rtl of alu is 
    component multiplexer2
        generic (
            w : positive
        );
        port (   
            selector:   in std_logic;
            data_in_0:  in std_logic_vector(w-1 downto 0);
            data_in_1:  in std_logic_vector(w-1 downto 0);
            data_out:   out std_logic_vector(w-1 downto 0)
        );
    end component;
    
    for mux: multiplexer2 use entity work.multiplexer2(rtl);
    
    signal aluop_multiplexed: std_logic_vector(3 downto 0) := "0000";
    
    signal left:            unsigned(32 downto 0);
    signal right:           unsigned(32 downto 0);
    signal mult_res:        unsigned(31 downto 0);
    signal carry:           std_logic;
  
begin
    mux: multiplexer2 
            generic map (w => 4) 
            port map (selector => op_select, data_in_0 => aluop, data_in_1 => "0000",
              data_out => aluop_multiplexed);
    
    process (a_in, b_in, carry, left, right, aluop_multiplexed, mult_res)
        variable alu_out_buffer:  unsigned(32 downto 0);
    begin
        case aluop_multiplexed is
            when  "0000" | "0001" | "0100" =>    -- add / adc / inc - use same adder  
                alu_out_buffer := left + right + carry;
            
            when  "0010" | "0011" | "0110" =>    -- sub / sbc / dec - use same subtractor  
                alu_out_buffer := left - right - carry;
   
            when  "1000" =>      -- and (a and b) 
                alu_out_buffer := "0" & unsigned( a_in and b_in);
            
            when  "1001" =>      -- or  (a or b)
                alu_out_buffer := "0" & unsigned(a_in or b_in);
            
            when  "1010" =>      -- xor (a xor b)
                alu_out_buffer := "0" & unsigned(a_in xor b_in);
                
            when "1011" =>   -- mult (a(15:0) * b(15:0)
                alu_out_buffer := "0" & mult_res;
            
            when  "1100" =>      -- lsl (a shift left, insert 0) 
                alu_out_buffer(32 downto 1) := left(31 downto 0);
                alu_out_buffer(0) := '0';
                
            when  "1110" =>      -- lsr (a shift right, insert 0)
                alu_out_buffer(32) := left(0);
                alu_out_buffer(30 downto 0) := left(31 downto 1);
                alu_out_buffer(31) := '0';
            
            when  "1101" =>      -- rol (a shift left, insert c)
                alu_out_buffer(32 downto 1) := left(31 downto 0);
                alu_out_buffer(0) := carry;
            
            when  "1111" =>      -- ror (a shift right, insert c)
                alu_out_buffer(32) := left(0);
                alu_out_buffer(30 downto 0) := left(31 downto 1);
                alu_out_buffer(31) := carry;
            
            when others =>       -- not defined
                alu_out_buffer := (others => '0'); 
        end case;
        
        alu_out <= std_logic_vector(alu_out_buffer(31 downto 0));
        carry_out <= alu_out_buffer(32);
        
        if(alu_out_buffer(31 downto 0) = 0) then
             zero_out <= '1';
        else
             zero_out <= '0';
        end if;
    end process;
    
    left <= unsigned ("0" & a_in);
    
    right <= (others => '0') when (aluop_multiplexed = "0100" or aluop_multiplexed = "0110") 
        else unsigned ("0" & b_in);
   
    carry <= '0' when (aluop_multiplexed = "0000" or aluop_multiplexed = "0010") 
        else '1' when (aluop_multiplexed = "0100" or aluop_multiplexed = "0110")
        else carry_in;

    mult_gen: if use_scalar_mult generate
        mult_res <= left(15 downto 0) * right(15 downto 0);
    end generate;
    
    not_mult_gen: if not use_scalar_mult generate
        mult_res <= (others => '0');
    end generate;
end rtl;

