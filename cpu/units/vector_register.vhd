------------------------------------------------------------------
-- PROJECT:     HiCoVec (highly configurable vector processor)
--
-- ENTITY:      vector_register
--
-- PURPOSE:     32 bit register file for vector_slice
--
-- AUTHOR:      harald manske, haraldmanske@gmx.de
--
-- VERSION:     1.0
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

use work.cfg.all;
use work.datatypes.all;

entity vector_register is
    generic (
        n : integer range 1 to 256;
        slicenr : natural
    );
            
    port (   
        -- clock
        clk:            in  std_logic;
        
        -- data inputs
        r_in:           in  std_logic_vector(31 downto 0);
        
        -- data outputs
        v_out:          out std_logic_vector(31 downto 0);
        w_out:          out std_logic_vector(31 downto 0);
        
        -- control signals
        load_r:         in  std_logic;
        load_select:    in  std_logic;
        k_in:           in  std_logic_vector(31 downto 0);       
        select_v:       in  std_logic_vector(7 downto 0);
        select_w:       in  std_logic_vector(3 downto 0);
        select_r:       in  std_logic_vector(7 downto 0)
    );
         
end vector_register;
        
architecture rtl of vector_register is   
    type regfile_type is array(0 to n-1) of std_logic_vector(31 downto 0);
    signal regfile : regfile_type := (others => (others => '0'));   
begin
        process 
        begin
            wait until clk='1' and clk'event;
            
            if (load_r = '1' and load_select /= '1') or (load_r = '1' and load_select = '1'
              and k_in = slicenr) then
                regfile(conv_integer(select_r)) <= r_in;
            end if;
            
            v_out <= regfile(conv_integer(select_v));
            w_out <= regfile(conv_integer(select_w));
        end process;
        
 
end rtl;

