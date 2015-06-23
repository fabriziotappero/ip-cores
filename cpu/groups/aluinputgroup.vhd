------------------------------------------------------------------
-- PROJECT:      HiCoVec (highly configurable vector processor)
--
-- ENTITY:      aluinputgroup
--
-- PURPOSE:     consists of and connects components
--              used to switch inputs for the scalar
--              alu
--              also includes instruction register
--
-- AUTHOR:      harald manske, haraldmanske@gmx.de
--
-- VERSION:     1.0
------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity aluinputgroup is
    port(   -- clock
            clk:            in std_logic;
            
            -- data inputs
            memory_in:      in std_logic_vector(31 downto 0);   -- data from ram
            x_in:           in std_logic_vector(31 downto 0);
            y_in:           in std_logic_vector(31 downto 0);
            a_in:           in std_logic_vector(31 downto 0);
                                    
            -- data outputs
            ir_out:         out std_logic_vector(31 downto 0);
            k_out:          out std_logic_vector(31 downto 0);  -- k for vector unit
            vector_out:     out std_logic_vector(31 downto 0);  -- data for vector unit
            a_out:          out std_logic_vector(31 downto 0);
            b_out:          out std_logic_vector(31 downto 0);
            
            -- control signals
            sel_a:          in std_logic_vector(1 downto 0);
            sel_b:          in std_logic_vector(1 downto 0);
            sel_source_a:   in std_logic;                       -- c8
            sel_source_b:   in std_logic;                       -- c0
            load_ir:        in std_logic
         );
end aluinputgroup;

architecture rtl of aluinputgroup is 
    component dataregister
        port(   clk:        in std_logic;
                load:       in std_logic;
                data_in:    in std_logic_vector(31 downto 0);
                data_out:   out std_logic_vector(31 downto 0)
            );
    end component;
    
    component multiplexer4
        generic (
            w : positive
        );
        port (
            selector:    in std_logic_vector(1 downto 0);
            data_in_00:  in std_logic_vector(w-1 downto 0);
            data_in_01:  in std_logic_vector(w-1 downto 0);
            data_in_10:  in std_logic_vector(w-1 downto 0);
            data_in_11:  in std_logic_vector(w-1 downto 0);
            data_out:    out std_logic_vector(w-1 downto 0)
        );
    end component;
    
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

    for ir:    dataregister use entity work.dataregister(rtl);
    for mux_a: multiplexer4 use entity work.multiplexer4(rtl);
    for mux_b: multiplexer4 use entity work.multiplexer4(rtl);
    for mux_source_b: multiplexer2 use entity work.multiplexer2(rtl);
    for mux_source_a: multiplexer2 use entity work.multiplexer2(rtl);
    
    signal instruction: std_logic_vector(31 downto 0);
    signal n: std_logic_vector(31 downto 0);
    signal mux_a_to_source: std_logic_vector(31 downto 0);
    signal mux_b_to_source: std_logic_vector(31 downto 0);
    
    begin
        ir: dataregister 
            port map (
                clk => clk,
                load => load_ir,
                data_in => memory_in,
                data_out => instruction
            ); 
        
        mux_a: multiplexer4 
            generic map (
                w => 32
            )
            port map (
                selector => sel_a,
                data_in_00 => "00000000000000000000000000000000",
                data_in_01 => a_in,
                data_in_10 => x_in,
                data_in_11 => y_in,
                data_out => mux_a_to_source
            );
            
        mux_b: multiplexer4
            generic map (
                w => 32
            )
            port map (
                selector => sel_b,
                data_in_00 => n,
                data_in_01 => a_in,
                data_in_10 => x_in,
                data_in_11 => y_in,
                data_out => mux_b_to_source
            );
        
        mux_source_a: multiplexer2
            generic map (
                w => 32
            )
            port map (
                selector => sel_source_a,
                data_in_0 => mux_a_to_source,
                data_in_1 => "00000000000000000000000000000000",
                data_out => a_out
            );
        
        
        mux_source_b: multiplexer2
            generic map (
                w => 32
            )
            port map (
                selector => sel_source_b,
                data_in_0 => mux_b_to_source,
                data_in_1 => memory_in,
                data_out => b_out
            );
        
        
        n(15 downto 0) <= instruction(15 downto 0);
        n(31 downto 16) <= "0000000000000000";
        k_out <= mux_b_to_source;
        vector_out <= mux_a_to_source;
        ir_out <= instruction;

end rtl;