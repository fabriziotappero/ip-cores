library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library work;
use work.PCK_CRC32_D32.all;
-- java -jar  jacksum.jar -a crc:32,04C11DB7,FFFFFFFF,false,false,00000000
-- -q 000000000000000100000002000000030000000400000005000000060000000700000008000000090000000A0000000B0000000C0000000D0000000E0000000F
-- -x 
-- Result: eb99fa90        64

use work.PCK_CRC8_D8.all;
-- java -jar  jacksum.jar -a crc:8,07,FF,false,false,00
-- -q 000102030405060708090A0B0C0D0E0F
-- -x 
-- Result: B8              16
  
entity crc_gen is
  generic (
    C_SR_WIDTH      : integer                                 := 32;
    crc_start_value : std_logic_vector(31 downto 0) := (others => '1'));
  port (
    clk          : in  std_logic;
    crc_clear    : in  std_logic;
    crc_en       : in  std_logic;
    crc_data_in  : in  std_logic_vector(C_SR_WIDTH-1 downto 0);
    crc_data_out : out std_logic_vector(C_SR_WIDTH-1 downto 0));
end crc_gen;

architecture rtl of crc_gen is
  signal crc_data_int : std_logic_vector(C_SR_WIDTH-1 downto 0);
  signal crc_data_in_int : std_logic_vector(C_SR_WIDTH-1 downto 0);
  
begin  -- crc_gen
  process(clk)
  begin
    if rising_edge(clk) then
      if (crc_clear = '1') then
        crc_data_int <= crc_start_value(C_SR_WIDTH-1 downto 0);
      elsif (crc_en = '1') then
        case C_SR_WIDTH is
          when 32 =>
            crc_data_int <= nextCRC32_D32(crc_data_in_int, crc_data_int);
          when 8 =>
            crc_data_int <= nextCRC8_D8(crc_data_in_int, crc_data_int);
          when others =>
            -- no crc calculation
            crc_data_int <= (others => '0');
        end case;
      end if;
    end if;
  end process;

  process(crc_data_int)
    begin
      for i  in 0 to 7 loop
          crc_data_out(24+7-i) <= not crc_data_int(i);
          crc_data_out(16+7-i) <= not crc_data_int(8+i);
          crc_data_out(8+7-i) <= not crc_data_int(16+i);
          crc_data_out(7-i) <= not crc_data_int(24+i);
      end loop;  -- i 
    end process;

  process(crc_data_in)
    begin
      for i  in 0 to 7 loop
          crc_data_in_int(7-i) <= crc_data_in(i);
          crc_data_in_int(8+7-i) <= crc_data_in(8+i);
          crc_data_in_int(16+7-i) <= crc_data_in(16+i);
          crc_data_in_int(24+7-i) <= crc_data_in(24+i);
      end loop;  -- i 
    end process;

    
end rtl;
