-----------------------------------------------------------------------------------------
-- register file model as a simple memory 
--
-----------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.all;

entity regFileModel is
  port ( -- global signals
         clr        : in  std_logic;                     -- global reset input
         clk        : in  std_logic;                     -- global clock input
         -- internal bus to register file
         intAddress : in  std_logic_vector(7 downto 0);  -- address bus to register file
         intWrData  : in  std_logic_vector(7 downto 0);  -- write data to register file
         intWrite   : in  std_logic;                     -- write control to register file
         intRead    : in  std_logic;                     -- read control to register file
         intRdData  : out std_logic_vector(7 downto 0)); -- data read from register file
end regFileModel;

architecture Behavioral of regFileModel is

  type RAM is array (integer range <>)of std_logic_vector (7 downto 0);
  signal regFile : RAM (0 to 255);

  begin 
    -- register file write
    process (clr, clk)
    begin
      if (clr = '1') then
        for index in 0 to 255 loop
          regFile(index) <= (others => '0');
        end loop;
      elsif (rising_edge(clk)) then
        if (intWrite = '1') then
          regFile(conv_integer(intAddress)) <= intWrData;
        end if;
      end if;
    end process;
    -- register file read
    process (clr, clk)
    begin
      if (clr = '1') then
        intRdData <= (others => '0');
      elsif (rising_edge(clk)) then
        if (intRead = '1') then
          intRdData <= regFile(conv_integer(intAddress));
        end if;
      end if;
    end process;
  end Behavioral;
