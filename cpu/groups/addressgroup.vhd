------------------------------------------------------------------
-- PROJECT:     HiCoVec (highly configurable vector processor)
--
-- ENTITY:      addressgroup
--
-- PURPOSE:     consists of and connects components
--              used for adressing the memory interface
--
-- AUTHOR:      harald manske, haraldmanske@gmx.de
--
-- VERSION:     1.0
------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity addressgroup is
    port(   -- clock
            clk:            in std_logic;  
            
            -- data inputs
            address_in:     in std_logic_vector(31 downto 0);
            
            -- data outputs
            address_out:    out std_logic_vector(31 downto 0);
            ic_out:         out std_logic_vector(31 downto 0);
            
            -- control signals
            sel_source:     in std_logic; -- c1
            inc:            in std_logic;
            load_ic:        in std_logic;
            reset_ic:       in std_logic
         );
end addressgroup;

architecture rtl of addressgroup is 
    component instructioncounter
        port(   clk:        in std_logic;
                load:       in std_logic;
                inc:        in std_logic;
                reset:      in std_logic;
                data_in:    in std_logic_vector(31 downto 0);
                data_out:   out std_logic_vector(31 downto 0)
            );
    end component;
    
    component multiplexer2
        generic (
            w : positive -- word width
        );
        port (   
            selector:   in std_logic;
            data_in_0:  in std_logic_vector(w-1 downto 0);
            data_in_1:  in std_logic_vector(w-1 downto 0);
            data_out:   out std_logic_vector(w-1 downto 0)
        );
    end component;
    

    for ic: instructioncounter use entity work.instructioncounter(rtl);
    for mux: multiplexer2 use entity work.multiplexer2(rtl);

    
    signal instruction:    std_logic_vector(31 downto 0);
    
    begin
        ic: instructioncounter port map (
            clk => clk,
            load => load_ic,
            inc => inc,
            reset => reset_ic,
            data_in => address_in,
            data_out => instruction 
        ); 
        
        mux: multiplexer2 
            generic map (
                w => 32
            )
            port map (
                selector => sel_source,
                data_in_0 => instruction,
                data_in_1 => address_in,
                data_out => address_out
            );
        
        ic_out <= instruction;
end rtl;