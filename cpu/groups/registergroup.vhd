------------------------------------------------------------------
-- PROJECT:     HiCoVec (highly configurable vector processor)
--
-- ENTITY:      registergroup
--
-- PURPOSE:     register file and destination multiplexer
--              
-- AUTHOR:      harald manske, haraldmanske@gmx.de
--
-- VERSION:     1.0
------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity registergroup is
    port(   -- clock
            clk:            in std_logic;
            
            -- data inputs
            result_in:      in std_logic_vector(31 downto 0);   -- data from alu
            vector_in:      in std_logic_vector(31 downto 0);   -- data from vector unit
            ic_in:          in std_logic_vector(31 downto 0);   -- instruction 
            enable_in:      in std_logic;                       -- c6
                                    
            -- data outputs
            x_out:          out std_logic_vector(31 downto 0);  
            y_out:          out std_logic_vector(31 downto 0);
            a_out:          out std_logic_vector(31 downto 0);
            
            -- control signals
            sel_source:     in std_logic_vector(1 downto 0);    -- cc2
            sel_dest:       in std_logic_vector(1 downto 0)     -- dd
         );
end registergroup;

architecture rtl of registergroup is 
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
   
    component demultiplexer1x4
        port(   selector:       in std_logic_vector(1 downto 0);
                data_in:        in std_logic;
                data_out_00:    out std_logic;
                data_out_01:    out std_logic;
                data_out_10:    out std_logic;
                data_out_11:    out std_logic
            );
    end component;
    
    for reg_x: dataregister use entity work.dataregister(rtl);
    for reg_y: dataregister use entity work.dataregister(rtl);
    for reg_a: dataregister use entity work.dataregister(rtl);
    
    for mux_input: multiplexer4 use entity work.multiplexer4(rtl);
    for demux: demultiplexer1x4 use entity work.demultiplexer1x4(rtl);
    
    signal data_in:     std_logic_vector(31 downto 0);
    signal load_x:      std_logic; 
    signal load_y:      std_logic;
    signal load_a:      std_logic;
       
    begin
        mux_input: multiplexer4 
            generic map (
                w => 32
            )
            port map (
                selector => sel_source,
                data_in_00 => result_in,
                data_in_01 => ic_in,
                data_in_10 => vector_in,
                data_in_11 => "--------------------------------",
                data_out => data_in
            ); 
        
        demux: demultiplexer1x4 port map (
            selector => sel_dest,
            data_in => enable_in,
            data_out_00 => open,
            data_out_01 => load_a,
            data_out_10 => load_x,
            data_out_11 => load_y
        );
        
        reg_x: dataregister port map(
            clk => clk,
            load => load_x,
            data_in => data_in,
            data_out => x_out
        );
        
        reg_y: dataregister port map(
            clk => clk,
            load => load_y,
            data_in => data_in,
            data_out => y_out
        );
        
        reg_a: dataregister port map(
            clk => clk,
            load => load_a,
            data_in => data_in,
            data_out => a_out
        );
   
end rtl;