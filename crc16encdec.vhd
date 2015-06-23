-------------------------------------------------------------------------------
--     Politecnico di Torino                                              
--     Dipartimento di Automatica e Informatica             
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------     
--
--     Title          : EPC Class1 Gen2 RFID Tag - CRC16 encoder/decoder
--
--     File name      : crc16encdec.vhd 
--
--     Description    : Tag CRC16 encoder/decoder    
--
--     Authors        : Erwing R. Sanchez <erwing.sanchez@polito.it>
--
-------------------------------------------------------------------------------            
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.STD_LOGIC_ARITH.all;


entity crc16encdec is

  generic(
    PRESET_CRC16 : integer := 65535);  -- X"FFFF"
  port (
    clk   : in  std_logic;
    rst_n : in  std_logic;
    init  : in  std_logic;
    ce    : in  std_logic;
    sdi   : in  std_logic;
    cout  : out std_logic_vector(15 downto 0));

end crc16encdec;

architecture CRC16beh of crc16encdec is


  signal crc16reg : std_logic_vector(15 downto 0);
  
begin  -- CRC16beh

  process (clk, rst_n)
  begin  -- process
    if rst_n = '0' then                 -- asynchronous reset (active low)
      crc16reg <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if init = '1' then
        crc16reg <= conv_std_logic_vector(PRESET_CRC16,16);
      elsif ce = '1' then
        crc16reg(0)            <= crc16reg(15) xor sdi;
        crc16reg(4 downto 1)   <= crc16reg(3 downto 0);
        crc16reg(5)            <= crc16reg(15) xor sdi xor crc16reg(4);
        crc16reg(11 downto 6)  <= crc16reg(10 downto 5);
        crc16reg(12)           <= crc16reg(15) xor sdi xor crc16reg(11);
        crc16reg(15 downto 13) <= crc16reg(14 downto 12);
      end if;
    end if;
  end process;

  cout <= crc16reg;
  
end CRC16beh;
