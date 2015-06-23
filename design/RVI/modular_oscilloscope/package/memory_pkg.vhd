-------------------------------------------------------------------------------------------------100
--| Modular Oscilloscope
--| UNSL - Argentine
--|
--| File: memory_pkg.vhd
--| Version: 0.1
--| Tested in: Actel A3PE1500
--|   Board: RVI Prototype Board + LP Data Conversion Daughter Board
--|-------------------------------------------------------------------------------------------------
--| Description:
--|   Memories - Package
--|   Package for instantiate Control modules.
--|   
--|-------------------------------------------------------------------------------------------------
--| File history:
--|   0.1  | aug-2009 | First release
----------------------------------------------------------------------------------------------------
--| Copyright (R) 2009, Facundo Aguilera (budinero at gmail.com).
--|
--| This VHDL design file is an open design; you can redistribute it and/or
--| modify it and/or implement it after contacting the author.
----------------------------------------------------------------------------------------------------



-- Bloque completo
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.math_real.all;

package memory_pkg is 
  --------------------------------------------------------------------------------------------------
  -- Componentes  
  
  component dual_port_memory_wb is
    port(
      -- Puerto A (Higer prioriry)
      RST_I_a: in std_logic;  
      CLK_I_a: in std_logic;  
      DAT_I_a: in std_logic_vector (15 downto 0);
      DAT_O_a: out std_logic_vector (15 downto 0);
      ADR_I_a: in std_logic_vector (13 downto 0);
      CYC_I_a: in std_logic;  
      STB_I_a: in std_logic;  
      ACK_O_a: out std_logic ;
      WE_I_a: in std_logic;


      -- Puerto B (Lower prioriry)
      RST_I_b: in std_logic;  
      CLK_I_b: in std_logic;  
      DAT_I_b: in std_logic_vector (15 downto 0);
      DAT_O_b: out std_logic_vector (15 downto 0);
      ADR_I_b: in std_logic_vector (13 downto 0);
      CYC_I_b: in std_logic;  
      STB_I_b: in std_logic;  
      ACK_O_b: out std_logic ;
      WE_I_b: in std_logic
    );
  end component dual_port_memory_wb;
  
end package memory_pkg;
  