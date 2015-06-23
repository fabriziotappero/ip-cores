-------------------------------------------------------------------------------
-- File Name :  AC_CR_ROM.vhd
--
-- Project   : JPEG_ENC
--
-- Module    : AC_CR_ROM
--
-- Content   : AC_CR_ROM Chrominance
--
-- Description : 
--
-- Spec.     : 
--
-- Author    : Michal Krepa
--
-------------------------------------------------------------------------------
-- History :
-- 20090329: (MK): Initial Creation.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
----------------------------------- LIBRARY/PACKAGE ---------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- generic packages/libraries:
-------------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

-------------------------------------------------------------------------------
-- user packages/libraries:
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
----------------------------------- ENTITY ------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
entity AC_CR_ROM is
  port 
  (
        CLK                : in  std_logic;
        RST                : in  std_logic;
        runlength          : in  std_logic_vector(3 downto 0);
        VLI_size           : in  std_logic_vector(3 downto 0);
        
        VLC_AC_size        : out unsigned(4 downto 0);
        VLC_AC             : out unsigned(15 downto 0)
    );
end entity AC_CR_ROM;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
----------------------------------- ARCHITECTURE ------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
architecture RTL of AC_CR_ROM is

  signal rom_addr : std_logic_vector(7 downto 0);
  
-------------------------------------------------------------------------------
-- Architecture: begin
-------------------------------------------------------------------------------
begin
  
  rom_addr <= runlength & VLI_size;

  -------------------------------------------------------------------
  -- AC-ROM
  -------------------------------------------------------------------
  p_AC_CR_ROM : process(CLK, RST)
  begin
    if RST = '1' then
      VLC_AC_size <= (others => '0');
      VLC_AC      <= (others => '0'); 
    elsif CLK'event and CLK = '1' then
      case runlength is 
        when X"0" =>
        
          case VLI_size is
            when X"0" =>
              VLC_AC_size <= to_unsigned(2, VLC_AC_size'length);
              VLC_AC      <= resize("00", VLC_AC'length); 
            when X"1" =>
              VLC_AC_size <= to_unsigned(2, VLC_AC_size'length);
              VLC_AC      <= resize("01", VLC_AC'length);
            when X"2" =>
              VLC_AC_size <= to_unsigned(3, VLC_AC_size'length);
              VLC_AC      <= resize("100", VLC_AC'length);
            when X"3" =>
              VLC_AC_size <= to_unsigned(4, VLC_AC_size'length);
              VLC_AC      <= resize("1010", VLC_AC'length);
            when X"4" =>
              VLC_AC_size <= to_unsigned(5, VLC_AC_size'length);
              VLC_AC      <= resize("11000", VLC_AC'length);
            when X"5" =>
              VLC_AC_size <= to_unsigned(5, VLC_AC_size'length);
              VLC_AC      <= resize("11001", VLC_AC'length);
            when X"6" =>
              VLC_AC_size <= to_unsigned(6, VLC_AC_size'length);
              VLC_AC      <= resize("111000", VLC_AC'length);
            when X"7" =>
              VLC_AC_size <= to_unsigned(7, VLC_AC_size'length);
              VLC_AC      <= resize("1111000", VLC_AC'length);
            when X"8" =>
              VLC_AC_size <= to_unsigned(9, VLC_AC_size'length);
              VLC_AC      <= resize("111110100", VLC_AC'length);
            when X"9" =>
              VLC_AC_size <= to_unsigned(10, VLC_AC_size'length);
              VLC_AC      <= resize("1111110110", VLC_AC'length);
            when X"A" =>
              VLC_AC_size <= to_unsigned(12, VLC_AC_size'length);
              VLC_AC      <= resize("111111110100", VLC_AC'length);
            when others =>
              VLC_AC_size <= to_unsigned(0, VLC_AC_size'length);
              VLC_AC      <= resize("0", VLC_AC'length);
          end case;
        
        when X"1" =>
        
          case VLI_size is
            when X"1" =>
              VLC_AC_size <= to_unsigned(4, VLC_AC_size'length);
              VLC_AC      <= resize("1011", VLC_AC'length); 
            when X"2" =>
              VLC_AC_size <= to_unsigned(6, VLC_AC_size'length);
              VLC_AC      <= resize("111001", VLC_AC'length);
            when X"3" =>
              VLC_AC_size <= to_unsigned(8, VLC_AC_size'length);
              VLC_AC      <= resize("11110110", VLC_AC'length);
            when X"4" =>
              VLC_AC_size <= to_unsigned(9, VLC_AC_size'length);
              VLC_AC      <= resize("111110101", VLC_AC'length);
            when X"5" =>
              VLC_AC_size <= to_unsigned(11, VLC_AC_size'length);
              VLC_AC      <= resize("11111110110", VLC_AC'length);
            when X"6" =>
              VLC_AC_size <= to_unsigned(12, VLC_AC_size'length);
              VLC_AC      <= resize("111111110101", VLC_AC'length);
            when X"7" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110001000", VLC_AC'length);
            when X"8" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110001001", VLC_AC'length);
            when X"9" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110001010", VLC_AC'length);
            when X"A" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110001011", VLC_AC'length);
            when others =>
              VLC_AC_size <= to_unsigned(0, VLC_AC_size'length);
              VLC_AC      <= resize("0", VLC_AC'length);
          end case;
          
        when X"2" =>
        
          case VLI_size is
            when X"1" =>
              VLC_AC_size <= to_unsigned(5, VLC_AC_size'length);
              VLC_AC      <= resize("11010", VLC_AC'length); 
            when X"2" =>
              VLC_AC_size <= to_unsigned(8, VLC_AC_size'length);
              VLC_AC      <= resize("11110111", VLC_AC'length);
            when X"3" =>
              VLC_AC_size <= to_unsigned(10, VLC_AC_size'length);
              VLC_AC      <= resize("1111110111", VLC_AC'length);
            when X"4" =>
              VLC_AC_size <= to_unsigned(12, VLC_AC_size'length);
              VLC_AC      <= resize("111111110110", VLC_AC'length);
            when X"5" =>
              VLC_AC_size <= to_unsigned(15, VLC_AC_size'length);
              VLC_AC      <= resize("111111111000010", VLC_AC'length);
            when X"6" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110001100", VLC_AC'length);
            when X"7" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110001101", VLC_AC'length);
            when X"8" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110001110", VLC_AC'length);
            when X"9" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110001111", VLC_AC'length);
            when X"A" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110010000", VLC_AC'length);
            when others =>
              VLC_AC_size <= to_unsigned(0, VLC_AC_size'length);
              VLC_AC      <= resize("0", VLC_AC'length);
          end case;
        
        when X"3" =>
          
          case VLI_size is
            when X"1" =>
              VLC_AC_size <= to_unsigned(5, VLC_AC_size'length);
              VLC_AC      <= resize("11011", VLC_AC'length); 
            when X"2" =>
              VLC_AC_size <= to_unsigned(8, VLC_AC_size'length);
              VLC_AC      <= resize("11111000", VLC_AC'length);
            when X"3" =>
              VLC_AC_size <= to_unsigned(10, VLC_AC_size'length);
              VLC_AC      <= resize("1111111000", VLC_AC'length);
            when X"4" =>
              VLC_AC_size <= to_unsigned(12, VLC_AC_size'length);
              VLC_AC      <= resize("111111110111", VLC_AC'length);
            when X"5" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110010001", VLC_AC'length);
            when X"6" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110010010", VLC_AC'length);
            when X"7" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110010011", VLC_AC'length);
            when X"8" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110010100", VLC_AC'length);
            when X"9" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110010101", VLC_AC'length);
            when X"A" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110010110", VLC_AC'length);
            when others =>
              VLC_AC_size <= to_unsigned(0, VLC_AC_size'length);
              VLC_AC      <= resize("0", VLC_AC'length);
          end case;
        
        when X"4" =>
        
          case VLI_size is
            when X"1" =>
              VLC_AC_size <= to_unsigned(6, VLC_AC_size'length);
              VLC_AC      <= resize("111010", VLC_AC'length); 
            when X"2" =>
              VLC_AC_size <= to_unsigned(9, VLC_AC_size'length);
              VLC_AC      <= resize("111110110", VLC_AC'length);
            when X"3" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110010111", VLC_AC'length);
            when X"4" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110011000", VLC_AC'length);
            when X"5" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110011001", VLC_AC'length);
            when X"6" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110011010", VLC_AC'length);
            when X"7" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110011011", VLC_AC'length);
            when X"8" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110011100", VLC_AC'length);
            when X"9" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110011101", VLC_AC'length);
            when X"A" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110011110", VLC_AC'length);
            when others =>
              VLC_AC_size <= to_unsigned(0, VLC_AC_size'length);
              VLC_AC      <= resize("0", VLC_AC'length);
          end case;
        
        when X"5" =>
        
          case VLI_size is
            when X"1" =>
              VLC_AC_size <= to_unsigned(6, VLC_AC_size'length);
              VLC_AC      <= resize("111011", VLC_AC'length); 
            when X"2" =>
              VLC_AC_size <= to_unsigned(10, VLC_AC_size'length);
              VLC_AC      <= resize("1111111001", VLC_AC'length);
            when X"3" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110011111", VLC_AC'length);
            when X"4" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110100000", VLC_AC'length);
            when X"5" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110100001", VLC_AC'length);
            when X"6" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110100010", VLC_AC'length);
            when X"7" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110100011", VLC_AC'length);
            when X"8" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110100100", VLC_AC'length);
            when X"9" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110100101", VLC_AC'length);
            when X"A" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110100110", VLC_AC'length);
            when others =>
              VLC_AC_size <= to_unsigned(0, VLC_AC_size'length);
              VLC_AC      <= resize("0", VLC_AC'length);
          end case;
        
        when X"6" =>
        
          case VLI_size is
            when X"1" =>
              VLC_AC_size <= to_unsigned(7, VLC_AC_size'length);
              VLC_AC      <= resize("1111001", VLC_AC'length); 
            when X"2" =>
              VLC_AC_size <= to_unsigned(11, VLC_AC_size'length);
              VLC_AC      <= resize("11111110111", VLC_AC'length);
            when X"3" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110100111", VLC_AC'length);
            when X"4" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110101000", VLC_AC'length);
            when X"5" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110101001", VLC_AC'length);
            when X"6" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110101010", VLC_AC'length);
            when X"7" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110101011", VLC_AC'length);
            when X"8" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110101100", VLC_AC'length);
            when X"9" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110101101", VLC_AC'length);
            when X"A" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110101110", VLC_AC'length);
            when others =>
              VLC_AC_size <= to_unsigned(0, VLC_AC_size'length);
              VLC_AC      <= resize("0", VLC_AC'length);
          end case;
        
        when X"7" =>
        
          case VLI_size is
            when X"1" =>
              VLC_AC_size <= to_unsigned(7, VLC_AC_size'length);
              VLC_AC      <= resize("1111010", VLC_AC'length); 
            when X"2" =>
              VLC_AC_size <= to_unsigned(11, VLC_AC_size'length);
              VLC_AC      <= resize("11111111000", VLC_AC'length);
            when X"3" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110101111", VLC_AC'length);
            when X"4" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110110000", VLC_AC'length);
            when X"5" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110110001", VLC_AC'length);
            when X"6" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110110010", VLC_AC'length);
            when X"7" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110110011", VLC_AC'length);
            when X"8" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110110100", VLC_AC'length);
            when X"9" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110110101", VLC_AC'length);
            when X"A" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110110110", VLC_AC'length);
            when others =>
              VLC_AC_size <= to_unsigned(0, VLC_AC_size'length);
              VLC_AC      <= resize("0", VLC_AC'length);
          end case;
        
        when X"8" =>
        
          case VLI_size is
            when X"1" =>
              VLC_AC_size <= to_unsigned(8, VLC_AC_size'length);
              VLC_AC      <= resize("11111001", VLC_AC'length); 
            when X"2" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110110111", VLC_AC'length);
            when X"3" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110111000", VLC_AC'length);
            when X"4" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110111001", VLC_AC'length);
            when X"5" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110111010", VLC_AC'length);
            when X"6" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110111011", VLC_AC'length);
            when X"7" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110111100", VLC_AC'length);
            when X"8" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110111101", VLC_AC'length);
            when X"9" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110111110", VLC_AC'length);
            when X"A" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111110111111", VLC_AC'length);
            when others =>
              VLC_AC_size <= to_unsigned(0, VLC_AC_size'length);
              VLC_AC      <= resize("0", VLC_AC'length);
          end case;
        
        when X"9" =>
        
          case VLI_size is
            when X"1" =>
              VLC_AC_size <= to_unsigned(9, VLC_AC_size'length);
              VLC_AC      <= resize("111110111", VLC_AC'length); 
            when X"2" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111000000", VLC_AC'length);
            when X"3" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111000001", VLC_AC'length);
            when X"4" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111000010", VLC_AC'length);
            when X"5" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111000011", VLC_AC'length);
            when X"6" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111000100", VLC_AC'length);
            when X"7" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111000101", VLC_AC'length);
            when X"8" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111000110", VLC_AC'length);
            when X"9" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111000111", VLC_AC'length);
            when X"A" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111001000", VLC_AC'length);
            when others =>
              VLC_AC_size <= to_unsigned(0, VLC_AC_size'length);
              VLC_AC      <= resize("0", VLC_AC'length);
          end case;
        
        when X"A" =>
        
          case VLI_size is
            when X"1" =>
              VLC_AC_size <= to_unsigned(9, VLC_AC_size'length);
              VLC_AC      <= resize("111111000", VLC_AC'length); 
            when X"2" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111001001", VLC_AC'length);
            when X"3" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111001010", VLC_AC'length);
            when X"4" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111001011", VLC_AC'length);
            when X"5" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111001100", VLC_AC'length);
            when X"6" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111001101", VLC_AC'length);
            when X"7" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111001110", VLC_AC'length);
            when X"8" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111001111", VLC_AC'length);
            when X"9" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111010000", VLC_AC'length);
            when X"A" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111010001", VLC_AC'length);
            when others =>
              VLC_AC_size <= to_unsigned(0, VLC_AC_size'length);
              VLC_AC      <= resize("0", VLC_AC'length);
          end case;
        
        when X"B" =>
        
          case VLI_size is
            when X"1" =>
              VLC_AC_size <= to_unsigned(9, VLC_AC_size'length);
              VLC_AC      <= resize("111111001", VLC_AC'length); 
            when X"2" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111010010", VLC_AC'length);
            when X"3" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111010011", VLC_AC'length);
            when X"4" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111010100", VLC_AC'length);
            when X"5" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111010101", VLC_AC'length);
            when X"6" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111010110", VLC_AC'length);
            when X"7" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111010111", VLC_AC'length);
            when X"8" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111011000", VLC_AC'length);
            when X"9" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111011001", VLC_AC'length);
            when X"A" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111011010", VLC_AC'length);
            when others =>
              VLC_AC_size <= to_unsigned(0, VLC_AC_size'length);
              VLC_AC      <= resize("0", VLC_AC'length);
          end case;
        
        when X"C" =>
        
          case VLI_size is
            when X"1" =>
              VLC_AC_size <= to_unsigned(9, VLC_AC_size'length);
              VLC_AC      <= resize("111111010", VLC_AC'length); 
            when X"2" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111011011", VLC_AC'length);
            when X"3" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111011100", VLC_AC'length);
            when X"4" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111011101", VLC_AC'length);
            when X"5" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111011110", VLC_AC'length);
            when X"6" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111011111", VLC_AC'length);
            when X"7" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111100000", VLC_AC'length);
            when X"8" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111100001", VLC_AC'length);
            when X"9" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111100010", VLC_AC'length);
            when X"A" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111100011", VLC_AC'length);
            when others =>
              VLC_AC_size <= to_unsigned(0, VLC_AC_size'length);
              VLC_AC      <= resize("0", VLC_AC'length);
          end case;
        
        when X"D" =>
        
          case VLI_size is
            when X"1" =>
              VLC_AC_size <= to_unsigned(11, VLC_AC_size'length);
              VLC_AC      <= resize("11111111001", VLC_AC'length); 
            when X"2" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111100100", VLC_AC'length);
            when X"3" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111100101", VLC_AC'length);
            when X"4" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111100110", VLC_AC'length);
            when X"5" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111100111", VLC_AC'length);
            when X"6" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111101000", VLC_AC'length);
            when X"7" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111101001", VLC_AC'length);
            when X"8" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111101010", VLC_AC'length);
            when X"9" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111101011", VLC_AC'length);
            when X"A" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111101100", VLC_AC'length);
            when others =>
              VLC_AC_size <= to_unsigned(0, VLC_AC_size'length);
              VLC_AC      <= resize("0", VLC_AC'length);
          end case;
        
        when X"E" =>
        
          case VLI_size is
            when X"1" =>
              VLC_AC_size <= to_unsigned(14, VLC_AC_size'length);
              VLC_AC      <= resize("11111111100000", VLC_AC'length); 
            when X"2" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111101101", VLC_AC'length);
            when X"3" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111101110", VLC_AC'length);
            when X"4" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111101111", VLC_AC'length);
            when X"5" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111110000", VLC_AC'length);
            when X"6" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111110001", VLC_AC'length);
            when X"7" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111110010", VLC_AC'length);
            when X"8" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111110011", VLC_AC'length);
            when X"9" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111110100", VLC_AC'length);
            when X"A" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111110101", VLC_AC'length);
            when others =>
              VLC_AC_size <= to_unsigned(0, VLC_AC_size'length);
              VLC_AC      <= resize("0", VLC_AC'length);
          end case;
        
        when X"F" =>
        
          case VLI_size is
            when X"0" =>
              VLC_AC_size <= to_unsigned(10, VLC_AC_size'length);
              VLC_AC      <= resize("1111111010", VLC_AC'length); 
            when X"1" =>
              VLC_AC_size <= to_unsigned(15, VLC_AC_size'length);
              VLC_AC      <= resize("111111111000011", VLC_AC'length);
            when X"2" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111110110", VLC_AC'length);
            when X"3" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111110111", VLC_AC'length);
            when X"4" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111111000", VLC_AC'length);
            when X"5" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111111001", VLC_AC'length);
            when X"6" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111111010", VLC_AC'length);
            when X"7" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111111011", VLC_AC'length);
            when X"8" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111111100", VLC_AC'length);
            when X"9" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111111101", VLC_AC'length);
            when X"A" =>
              VLC_AC_size <= to_unsigned(16, VLC_AC_size'length);
              VLC_AC      <= resize("1111111111111110", VLC_AC'length);
            when others =>
              VLC_AC_size <= to_unsigned(0, VLC_AC_size'length);
              VLC_AC      <= resize("0", VLC_AC'length);
          end case;
          
        when others =>
          VLC_AC_size <= (others => '0'); 
          VLC_AC      <= (others => '0'); 
      end case;
    end if;
  end process;
  
  

end architecture RTL;
-------------------------------------------------------------------------------
-- Architecture: end
-------------------------------------------------------------------------------