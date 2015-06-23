--
-- Definition of a single port ROM for KCPSM program defined by cfreader.psm
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
entity cfreader is
    Port (      address : in std_logic_vector(7 downto 0);
            instruction : out std_logic_vector(15 downto 0);
                    clk : in std_logic);
    end cfreader;
--
architecture low_level_definition of cfreader is
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
attribute INIT_00 of ram_256_x_16 : label is  "0FFF06000500EF020FFFEF030F18EF01EF000F00EF06EF05EF040F00EF070F00";
attribute INIT_01 of ram_256_x_16 : label is  "912A6F05CF30A302CFF1CFF1CFF1CFF183470FFF83470FFF83470FFF83CB8347";
attribute INIT_02 of ram_256_x_16 : label is  "A903813EC5F10F00A804A7038118EF06EF070F0091366F01CF30912F6F15CF30";
attribute INIT_03 of ram_256_x_16 : label is  "EF060F01EF070F02EC05EB0495341F08CF508396050083CB813EC5F10F00AA04";
attribute INIT_04 of ram_256_x_16 : label is  "ED00EF03808095486101954960010003C1F08118EF060F00CFF1CFF1CFF1CFF1";
attribute INIT_05 of ram_256_x_16 : label is  "0F0083470F01EF030F18EF020FFF83470F02EF020FFD83470F01EF070F01EE01";
attribute INIT_06 of ram_256_x_16 : label is  "0FFFAC01AB0083470F02EF020FFEEF070F0083470F01EF03808083470F02EF07";
attribute INIT_07 of ram_256_x_16 : label is  "834E0F14CD80834E0F13CD70834E0F120D01834E0F110D008080EF030F18EF02";
attribute INIT_08 of ram_256_x_16 : label is  "0F0494801F08CF5083B8834E0F170D20834E0F16CDF02FE0CFA0834E0F15CD90";
attribute INIT_09 of ram_256_x_16 : label is  "660191A1C66183A594801F08CF5093ACCF510F01808006FFC5F20F01918BCF51";
attribute INIT_0A of ram_256_x_16 : label is  "95AA1F04CF5083B8660183A58080EF060F0283640F108080C5F10FFE06FF8080";
attribute INIT_0B of ram_256_x_16 : label is  "6F48CFB10FC995C6CFB10F0183640F17817491AC06FF1F02CF5094801F08CF50";
attribute INIT_0C of ram_256_x_16 : label is  "83470FFF834E0F0E0D048080050883CBEF070F04808091DE6F40CFB10FC191DA";
attribute INIT_0D of ram_256_x_16 : label is  "0F0215FB8080C5F20F0415FD8080834E0F0E0D0083470FFF83470FFF83470FFF";
attribute INIT_0E of ram_256_x_16 : label is  "000000000000000000000000000000000000000000000000000000008080C5F2";
attribute INIT_0F of ram_256_x_16 : label is  "80F0000000000000000000000000000000000000000000000000000000000000";
--
begin
--
  --Instantiate the Xilinx primitive for a block RAM
  ram_256_x_16: RAMB4_S16
  --translate_off
  --INIT values repeated to define contents for functional simulation
  generic map (INIT_00 => X"0FFF06000500EF020FFFEF030F18EF01EF000F00EF06EF05EF040F00EF070F00",
               INIT_01 => X"912A6F05CF30A302CFF1CFF1CFF1CFF183470FFF83470FFF83470FFF83CB8347",
               INIT_02 => X"A903813EC5F10F00A804A7038118EF06EF070F0091366F01CF30912F6F15CF30",
               INIT_03 => X"EF060F01EF070F02EC05EB0495341F08CF508396050083CB813EC5F10F00AA04",
               INIT_04 => X"ED00EF03808095486101954960010003C1F08118EF060F00CFF1CFF1CFF1CFF1",
               INIT_05 => X"0F0083470F01EF030F18EF020FFF83470F02EF020FFD83470F01EF070F01EE01",
               INIT_06 => X"0FFFAC01AB0083470F02EF020FFEEF070F0083470F01EF03808083470F02EF07",
               INIT_07 => X"834E0F14CD80834E0F13CD70834E0F120D01834E0F110D008080EF030F18EF02",
               INIT_08 => X"0F0494801F08CF5083B8834E0F170D20834E0F16CDF02FE0CFA0834E0F15CD90",
               INIT_09 => X"660191A1C66183A594801F08CF5093ACCF510F01808006FFC5F20F01918BCF51",
               INIT_0A => X"95AA1F04CF5083B8660183A58080EF060F0283640F108080C5F10FFE06FF8080",
               INIT_0B => X"6F48CFB10FC995C6CFB10F0183640F17817491AC06FF1F02CF5094801F08CF50",
               INIT_0C => X"83470FFF834E0F0E0D048080050883CBEF070F04808091DE6F40CFB10FC191DA",
               INIT_0D => X"0F0215FB8080C5F20F0415FD8080834E0F0E0D0083470FFF83470FFF83470FFF",
               INIT_0E => X"000000000000000000000000000000000000000000000000000000008080C5F2",
               INIT_0F => X"80F0000000000000000000000000000000000000000000000000000000000000",
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
-- END OF FILE cfreader.vhd
--
------------------------------------------------------------------------------------
