ROM_form.vhd

Ken Chapman (Xilinx Ltd) October 2002

This is the VHDL template file for the KCPSM assembler.
It is used to configure a Virtex(E) and Spartan-II(E) block RAM to act as a single port 
program ROM.

This VHDL file is not valid as input directly into a synthesis or simulation tool.
The assembler will read this template and insert the data required to complete the 
definition of program ROM and write it out to a new '.vhd' file associated with the 
name of the original '.psm' file being assembled.

This template can be modified to define alternative memory definitions such as dual port.
However, you are responsible for ensuring the template is correct as the assembler does 
not perform any checking of the VHDL.

The assembler identifies all text enclosed by {} characters, and replaces these
character strings. All templates should include these {} character strings for 
the assembler to work correctly. 

****************************************************************************************
	
This template defines a block RAM configured in 256 x 16-bit single port mode and 
conneceted to act as a single port ROM.

****************************************************************************************

The next line is used to determine where the template actually starts and must exist.
{begin template}
--
-- Definition of a single port ROM for KCPSM program defined by {name}.psm
-- and assmbled using KCPSM assembler.
--
-- Standard IEEE libraries
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--
-- The Unisim Library is used to define Xilinx primitives. It is also used during
-- simulation. The source can be viewed at %XILINX%\vhdl\src\unisims\unisim_VCOMP.vhd
--  
library unisim;
use unisim.vcomponents.all;
--
--
entity {name} is
    Port (      address : in std_logic_vector(7 downto 0);
            instruction : out std_logic_vector(15 downto 0);
                    clk : in std_logic);
    end {name};
--
architecture low_level_definition of {name} is
--
-- Attributes to define ROM contents during implementation synthesis. 
-- The information is repeated in the generic map for functional simulation
--
attribute INIT_00 : string; 
attribute INIT_01 : string; 
attribute INIT_02 : string; 
attribute INIT_03 : string; 
attribute INIT_04 : string; 
attribute INIT_05 : string; 
attribute INIT_06 : string; 
attribute INIT_07 : string; 
attribute INIT_08 : string; 
attribute INIT_09 : string; 
attribute INIT_0A : string; 
attribute INIT_0B : string; 
attribute INIT_0C : string; 
attribute INIT_0D : string; 
attribute INIT_0E : string; 
attribute INIT_0F : string; 
--
-- Attributes to define ROM contents during implementation synthesis.
--
attribute INIT_00 of ram_256_x_16 : label is  "{INIT_00}";
attribute INIT_01 of ram_256_x_16 : label is  "{INIT_01}";
attribute INIT_02 of ram_256_x_16 : label is  "{INIT_02}";
attribute INIT_03 of ram_256_x_16 : label is  "{INIT_03}";
attribute INIT_04 of ram_256_x_16 : label is  "{INIT_04}";
attribute INIT_05 of ram_256_x_16 : label is  "{INIT_05}";
attribute INIT_06 of ram_256_x_16 : label is  "{INIT_06}";
attribute INIT_07 of ram_256_x_16 : label is  "{INIT_07}";
attribute INIT_08 of ram_256_x_16 : label is  "{INIT_08}";
attribute INIT_09 of ram_256_x_16 : label is  "{INIT_09}";
attribute INIT_0A of ram_256_x_16 : label is  "{INIT_0A}";
attribute INIT_0B of ram_256_x_16 : label is  "{INIT_0B}";
attribute INIT_0C of ram_256_x_16 : label is  "{INIT_0C}";
attribute INIT_0D of ram_256_x_16 : label is  "{INIT_0D}";
attribute INIT_0E of ram_256_x_16 : label is  "{INIT_0E}";
attribute INIT_0F of ram_256_x_16 : label is  "{INIT_0F}";
--
begin
--
  --Instantiate the Xilinx primitive for a block RAM
  ram_256_x_16: RAMB4_S16
  --translate_off
  --INIT values repeated to define contents for functional simulation
  generic map (INIT_00 => X"{INIT_00}",
               INIT_01 => X"{INIT_01}",
               INIT_02 => X"{INIT_02}",
               INIT_03 => X"{INIT_03}",
               INIT_04 => X"{INIT_04}",
               INIT_05 => X"{INIT_05}",
               INIT_06 => X"{INIT_06}",
               INIT_07 => X"{INIT_07}",
               INIT_08 => X"{INIT_08}",
               INIT_09 => X"{INIT_09}",
               INIT_0A => X"{INIT_0A}",
               INIT_0B => X"{INIT_0B}",
               INIT_0C => X"{INIT_0C}",
               INIT_0D => X"{INIT_0D}",
               INIT_0E => X"{INIT_0E}",
               INIT_0F => X"{INIT_0F}",
  --translate_on
  port map(    DI => "0000000000000000",
               EN => '1',
               WE => '0',
              RST => '0',
              CLK => clk,
             ADDR => address,
               DO => instruction(15 downto 0)); 
--
end low_level_definition;
--
------------------------------------------------------------------------------------
--
-- END OF FILE {name}.vhd
--
------------------------------------------------------------------------------------

