-------------------------------------------------------------------------------
--* 
--* @short RAM Sync-Write, Async Read
--* 
--* @generic C_FIFO_WIDTH       RAM-With (1..xx)
--* @generic C_FIFO_SIZE_WIDTH  RAM Size = 2**C_FIFO_SIZE_WIDTH
--*
--*    @author: Daniel Köthe
--*   @version: 1.0
--* @date:      2007-11-11
--/
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity ram is
  generic (
    C_FIFO_WIDTH      : integer := 8;
    C_FIFO_SIZE_WIDTH : integer := 4);

  port (clk  : in  std_logic;
        we   : in  std_logic;
        a    : in  std_logic_vector(C_FIFO_SIZE_WIDTH-1 downto 0);
        dpra : in  std_logic_vector(C_FIFO_SIZE_WIDTH-1 downto 0);
        di   : in  std_logic_vector(C_FIFO_WIDTH-1 downto 0);
        dpo  : out std_logic_vector(C_FIFO_WIDTH-1 downto 0));
end ram;

architecture behavior of ram is
  type ram_type is array (2**C_FIFO_SIZE_WIDTH-1 downto 0) of std_logic_vector (C_FIFO_WIDTH-1 downto 0);
  signal RAM : ram_type;
begin

  process (clk)
  begin
    if (clk'event and clk = '1') then
      if (we = '1') then
        RAM(conv_integer(a)) <= di;
      end if;
    end if;
  end process;

  dpo <= RAM(conv_integer(dpra));

end behavior;
