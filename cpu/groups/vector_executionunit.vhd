------------------------------------------------------------------
-- PROJECT:      HiCoVec (highly configurable vector processor)
--
-- ENTITY:      vector_executionunit
--
-- PURPOSE:     execution unit of the vector unit
--
-- AUTHOR:      harald manske, haraldmanske@gmx.de
--
-- VERSION:     1.0
------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.cfg.all;
use work.datatypes.all;

entity vector_executionunit is
    port (   
        -- clock
        clk:        in std_logic;  
        
        -- data inputs
        memory_in:  in vectordata_type;
        scalar_in:  in std_logic_vector(31 downto 0);
        
        -- data outputs
        memory_out: out vectordata_type;
        scalar_out: out std_logic_vector(31 downto 0);
        out_valid:  out std_logic;
        shuffle_valid:  out std_logic;
        
        -- control signals
        rrrr:       in std_logic_vector(3 downto 0);
        vvvv:       in std_logic_vector(3 downto 0);
        wwww:       in std_logic_vector(3 downto 0);
        k_in:       in std_logic_vector(31 downto 0);
        vn:         in std_logic_vector(7 downto 0);    -- immediate value n for vector unit
        valuop:     in std_logic_vector(3 downto 0);
        vwidth:     in std_logic_vector(1 downto 0);
        load_r:     in std_logic;
        cc9:        in std_logic_vector(1 downto 0);
        c10:        in std_logic;
        c11:        in std_logic;
        c12:        in std_logic;
        cc13:       in std_logic_vector(1 downto 0);
        valu_go:    in std_logic;
        shuffle_go: in std_logic
    );
end vector_executionunit;

architecture rtl of vector_executionunit is 
    component selectunit
        port (
            data_in :   in  vectordata_type;
            k_in:       in  std_logic_vector(31 downto 0);
            data_out:   out std_logic_vector(31 downto 0)
        );   
    end component;
    
    component shuffle
        port (
            clk:                in  std_logic;
            shuffle_go:         in  std_logic;
            shuffle_valid:      out std_logic;
            data_in_v:          in  vectordata_type;
            data_in_w:          in  vectordata_type;
            vn:                 in  std_logic_vector(7 downto 0);
            ssss:               in  std_logic_vector(3 downto 0);
            vwidth:             in  std_logic_vector(1 downto 0);
            shuffle_out_sel:    in  std_logic_vector(1 downto 0);
            data_out:           out vectordata_type
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
    
    component vector_slice
        generic (
            slicenr : natural := 0
        );
        port (   
            clk:                in std_logic;  
            memory_in:          in std_logic_vector(31 downto 0);
            scalar_in:          in std_logic_vector(31 downto 0);
            shuffle_in:         in std_logic_vector(31 downto 0);
            carry_in:           in std_logic;
            rshift_in:          in std_logic;
            v_out:              out std_logic_vector(31 downto 0);
            w_out:              out std_logic_vector(31 downto 0);
            carry_out:          out std_logic;
            rrrr:               in std_logic_vector(7 downto 0);
            vvvv:               in std_logic_vector(7 downto 0);
            wwww:               in std_logic_vector(3 downto 0);
            k_in:               in std_logic_vector(31 downto 0);
            load_r:             in std_logic;
            cc9:                in std_logic_vector(1 downto 0);
            c12:                in std_logic;
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
    
    component multiplexer2
        generic (
            w : positive
        );
        port(
            selector:   in std_logic;
            data_in_0:  in std_logic_vector(w-1 downto 0);
            data_in_1:  in std_logic_vector(w-1 downto 0);
            data_out:   out std_logic_vector(w-1 downto 0)
        );
    end component;
    
    for shuffle_impl: shuffle use entity work.shuffle(rtl);
    for selectunit_impl: selectunit use entity work.selectunit(rtl);
    for valu_controlunit_impl: valu_controlunit use entity work.valu_controlunit(rtl); 
    
    for rrrr_mux: multiplexer2 use entity work.multiplexer2(rtl);
    for vvvv_mux: multiplexer2 use entity work.multiplexer2(rtl);
    
    signal carry :  std_logic_vector(k-1 downto 0);
    signal v_vector : vectordata_type;
    signal w_vector : vectordata_type;
    signal shuffle_out : vectordata_type;
    signal select_v : std_logic_vector(7 downto 0);
    signal select_r : std_logic_vector(7 downto 0);
    
    signal sel_r : std_logic_vector(7 downto 0);
    signal sel_v : std_logic_vector(7 downto 0);
    signal sel_w : std_logic_vector(3 downto 0);
    
    signal rrrr_ext  : std_logic_vector(7 downto 0);
    signal vvvv_ext  : std_logic_vector(7 downto 0);
    
    signal source_sel: std_logic_vector(1 downto 0);
    signal carry_sel:  std_logic_vector(1 downto 0);
    signal mult_source_sel: std_logic_vector(1 downto 0);
    signal mult_dest_sel: std_logic_vector(1 downto 0);
    signal reg_input_sel: std_logic;
    signal load_lsr: std_logic;
    signal load_other: std_logic;

begin    
    rrrr_ext <= "0000" & rrrr;
    vvvv_ext <= "0000" & vvvv;
    
    rrrr_mux : multiplexer2
        generic map (w => 8) 
        port map (
            selector => c10,
            data_in_0 => rrrr_ext,
            data_in_1 => vn,
            data_out => select_r
        );

    
    vvvv_mux : multiplexer2
        generic map (w => 8) 
        port map (
            selector => c11,
            data_in_0 => vvvv_ext,
            data_in_1 => vn,
            data_out => select_v
        );    

    -- check index < n
    sel_r <= select_r when (select_r < n) else (others => '0');
    sel_v <= select_v when (select_v < n) else (others => '0');
    sel_w <= wwww when (wwww < n) else (others => '0');
   
    selectunit_impl: selectunit 
        port map (
            data_in => v_vector,
            k_in => k_in,
            data_out => scalar_out
        ); 
    
    shuffle_impl: shuffle
        port map (
            clk => clk,
            shuffle_go => shuffle_go,
            shuffle_valid => shuffle_valid,
            data_in_v => v_vector,
            data_in_w => w_vector,
            vn => vn,
            ssss => valuop,
            vwidth => vwidth,
            shuffle_out_sel => cc13,
            data_out => shuffle_out
        );
        
    valu_controlunit_impl: valu_controlunit
        port map (
            clk => clk,
            valu_go         => valu_go,
            valuop          => valuop,
            vwidth          => vwidth,
            source_sel      => source_sel,
            carry_sel       => carry_sel,
            mult_source_sel => mult_source_sel,
            mult_dest_sel   => mult_dest_sel,
            reg_input_sel   => reg_input_sel,
            load_lsr        => load_lsr, 
            load_other      => load_other,
            out_valid       => out_valid
        ); 
    
    vector_slice_impl: for i in k-1 downto 0 generate
        vector_slice_even: if i mod 2 = 0 generate
            slice_even: vector_slice
            generic map (
                slicenr => i
            )
            port map (
                clk => clk,
                memory_in       => memory_in(i),
                scalar_in       => scalar_in,
                shuffle_in      => shuffle_out(i),
                carry_in        => '0', 
                rshift_in       => carry(i+1), 
                v_out           => v_vector(i),
                w_out           => w_vector(i),
                carry_out       => carry(i),
                rrrr            => sel_r,
                vvvv            => sel_v,
                wwww            => sel_w,
                k_in            => k_in,
                load_r          => load_r,
                cc9             => cc9,
                c12             => c12,
                valuop          => valuop,
                source_sel      => source_sel,
                carry_sel       => carry_sel,
                mult_source_sel => mult_source_sel,
                mult_dest_sel   => mult_dest_sel,
                reg_input_sel   => reg_input_sel,
                load_lsr        => load_lsr,
                load_other      => load_other
            );
        end generate;
        
        vector_slice_uneven: if i mod 2 = 1 generate
            slice_uneven: vector_slice
            generic map (
                slicenr => i
            )
            port map (
                clk => clk,
                memory_in       => memory_in(i),
                scalar_in       => scalar_in,
                shuffle_in      => shuffle_out(i),
                carry_in        => carry(i-1),
                rshift_in       => '0',
                v_out           => v_vector(i),
                w_out           => w_vector(i),
                carry_out       => carry(i),
                rrrr            => sel_r,
                vvvv            => sel_v,
                wwww            => sel_w,
                k_in            => k_in,
                load_r          => load_r,
                cc9             => cc9,
                c12             => c12,
                valuop          => valuop,
                source_sel      => source_sel,
                carry_sel       => carry_sel,
                mult_source_sel => mult_source_sel,
                mult_dest_sel   => mult_dest_sel,
                reg_input_sel   => reg_input_sel,
                load_lsr        => load_lsr,
                load_other      => load_other
            );
        end generate;
    end generate ;
  
    memory_out <= v_vector;
  
end rtl;