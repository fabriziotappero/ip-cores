------------------------------------------------------------------
-- PROJECT:     HiCoVec (highly configurable vector processor)
--
-- ENTITY:      cfg
--
-- PURPOSE:     base configuration file          
--
-- AUTHOR:      harald manske, haraldmanske@gmx.de
--
-- VERSION:     1.0
------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package cfg is
    -- configuration
    constant n: integer := 10;                      -- amount of vector registers 
    constant k: integer := 20;                      -- amount words per vector register (even numbers)
    
    constant use_debugger: boolean :=  true;        -- include debugging unit
    
    constant use_scalar_mult : boolean := true;     -- allow multiplications in scalar alu
    constant use_vector_mult : boolean := false;    -- allow multiplications in vector alu
    
    constant use_shuffle : boolean := false;        -- use shuffle unit
    constant max_shuffle_width : integer := 0;      -- max. shuffle width (dividable by 4)
    
    constant use_vectorshift : boolean := true;     -- allow shift of vector registers (vmol, vmor)
    constant vectorshift_width : integer := 32;     -- width of vectorshift in bit

    constant sram_size : integer := 4096;           -- sram size (memory size: 32 bit * sram_size)
end cfg;