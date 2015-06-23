--
-- Definition of a single port ROM for KCPSM program defined by fat16rd.psm
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
entity fat16rd is
    Port (      address : in std_logic_vector(7 downto 0);
            instruction : out std_logic_vector(15 downto 0);
                    clk : in std_logic);
    end fat16rd;
--
architecture low_level_definition of fat16rd is
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
attribute INIT_00 of ram_256_x_16 : label is  "83E8910C1601A6018345C47083AE838B8348EF05EF02EF04EF03EF01EF000F00";
attribute INIT_01 of ram_256_x_16 : label is  "951A6F01D008D108D208D30E0F07A30BA20AA109A008810C933EC551650183C4";
attribute INIT_02 of ram_256_x_16 : label is  "0200812E952F6FFFCFD0952F6FFFCFE0C1E0C0D083E883E31F7FAF0883D38335";
attribute INIT_03 of ram_256_x_16 : label is  "C44164018080C3F5AF07C2F5AF06C1F5AF05C0F4AF048080834583AEC4700300";
attribute INIT_04 of ram_256_x_16 : label is  "838483E30FE383D30300020001000000808083D3050053005200510040019115";
attribute INIT_05 of ram_256_x_16 : label is  "5B005A00C945C864C4E0C6D083E8C7E083E883E30F0683D3CB30CA20C910C800";
attribute INIT_06 of ram_256_x_16 : label is  "D10E0F09956A6F01D100D0060F05C1D083E8C0E0C6D083E8EB0BEA0AE909E808";
attribute INIT_07 of ram_256_x_16 : label is  "5B005A00C915C804D100D006838483E30F01CB35CA25C915C804956F6F01D008";
attribute INIT_08 of ram_256_x_16 : label is  "CFF1CF60C6D083E883D38080C3E0C2D083E8C1E0C0D083E88080833503000200";
attribute INIT_09 of ram_256_x_16 : label is  "0F0A83E30F05808083A2959FCF610F03C6E083E883E30F04919DCF610FE591F2";
attribute INIT_0A of ram_256_x_16 : label is  "E10DE00C8080C1E0C0D083E883E30F02EE0FC3E0C2D083E883E30F04818C83E3";
attribute INIT_0B of ram_256_x_16 : label is  "C08481B8D300D200D100D00699BFDD0ECD700F087300720071006002E30FE20E";
attribute INIT_0C of ram_256_x_16 : label is  "0F00EF050F01EF070F01808091C71601A60183CBEE04ED038080C3B5C2A5C195";
attribute INIT_0D of ram_256_x_16 : label is  "0F0083EAEF020F07E301E20083EAEF020F03E101E000EF060F018080EF05EF07";
attribute INIT_0E of ram_256_x_16 : label is  "0F00AE03AD0291EA1F01AF00EF020F01808095E4660183E8C6F08080EF06EF02";
attribute INIT_0F of ram_256_x_16 : label is  "000000000000000000000000000000000000000080F081F2EF050F048080EF02";
--
begin
--
  --Instantiate the Xilinx primitive for a block RAM
  ram_256_x_16: RAMB4_S16
  --translate_off
  --INIT values repeated to define contents for functional simulation
  generic map (INIT_00 => X"83E8910C1601A6018345C47083AE838B8348EF05EF02EF04EF03EF01EF000F00",
               INIT_01 => X"951A6F01D008D108D208D30E0F07A30BA20AA109A008810C933EC551650183C4",
               INIT_02 => X"0200812E952F6FFFCFD0952F6FFFCFE0C1E0C0D083E883E31F7FAF0883D38335",
               INIT_03 => X"C44164018080C3F5AF07C2F5AF06C1F5AF05C0F4AF048080834583AEC4700300",
               INIT_04 => X"838483E30FE383D30300020001000000808083D3050053005200510040019115",
               INIT_05 => X"5B005A00C945C864C4E0C6D083E8C7E083E883E30F0683D3CB30CA20C910C800",
               INIT_06 => X"D10E0F09956A6F01D100D0060F05C1D083E8C0E0C6D083E8EB0BEA0AE909E808",
               INIT_07 => X"5B005A00C915C804D100D006838483E30F01CB35CA25C915C804956F6F01D008",
               INIT_08 => X"CFF1CF60C6D083E883D38080C3E0C2D083E8C1E0C0D083E88080833503000200",
               INIT_09 => X"0F0A83E30F05808083A2959FCF610F03C6E083E883E30F04919DCF610FE591F2",
               INIT_0A => X"E10DE00C8080C1E0C0D083E883E30F02EE0FC3E0C2D083E883E30F04818C83E3",
               INIT_0B => X"C08481B8D300D200D100D00699BFDD0ECD700F087300720071006002E30FE20E",
               INIT_0C => X"0F00EF050F01EF070F01808091C71601A60183CBEE04ED038080C3B5C2A5C195",
               INIT_0D => X"0F0083EAEF020F07E301E20083EAEF020F03E101E000EF060F018080EF05EF07",
               INIT_0E => X"0F00AE03AD0291EA1F01AF00EF020F01808095E4660183E8C6F08080EF06EF02",
               INIT_0F => X"000000000000000000000000000000000000000080F081F2EF050F048080EF02",
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
-- END OF FILE fat16rd.vhd
--
------------------------------------------------------------------------------------
