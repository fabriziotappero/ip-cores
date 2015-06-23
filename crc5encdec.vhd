-------------------------------------------------------------------------------
--     Politecnico di Torino                                              
--     Dipartimento di Automatica e Informatica             
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------     
--
--     Title          : EPC Class1 Gen2 RFID Tag - CRC5 encoder/decoder
--
--     File name      : crc5encdec.vhd 
--
--     Description    : Tag CRC5 encoder/decoder    
--
--     Authors        : Erwing R. Sanchez <erwing.sanchez@polito.it>
--                        
-------------------------------------------------------------------------------            
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.STD_LOGIC_ARITH.all;


entity crc5encdec is

  generic(
    PRESET_CRC5 : integer := 9);        -- "01001"
  port (
    clk   : in  std_logic;
    rst_n : in  std_logic;
    init  : in  std_logic;
    ce    : in  std_logic;
    sdi   : in  std_logic;
    cout  : out std_logic_vector(4 downto 0));

end crc5encdec;

architecture CRC5beh of crc5encdec is


  signal crc5reg : std_logic_vector(4 downto 0);
  
begin  -- CRC5beh

  process (clk, rst_n)
  begin  -- process
    if rst_n = '0' then                 -- asynchronous reset (active low)
      crc5reg <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if init = '1' then
        crc5reg <= conv_std_logic_vector(PRESET_CRC5,5);
      elsif ce = '1' then
        crc5reg(0)          <= crc5reg(4) xor sdi;
        crc5reg(2 downto 1) <= crc5reg(1 downto 0);
        crc5reg(3)          <= crc5reg(4) xor sdi xor crc5reg(2);
        crc5reg(4)          <= crc5reg(3);
      end if;
    end if;
  end process;

  cout <= crc5reg;
  
end CRC5beh;
