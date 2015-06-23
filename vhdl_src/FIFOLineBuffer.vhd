PACKAGE TYPES IS
subtype SMALL_INTEGER is INTEGER range 0 to 639;
END PACKAGE;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use WORK.TYPES.all;

entity FIFOLineBuffer is
  generic (
	DATA_WIDTH : integer := 8;
	NO_OF_COLS : integer := 640 );
  port(
	clk : in std_logic;
	fsync : in std_logic;
	pdata_in : in std_logic_vector(DATA_WIDTH -1 downto 0);
	pdata_out : buffer std_logic_vector(DATA_WIDTH -1 downto 0)
	);
end FIFOLineBuffer;

architecture Behavioral of FIFOLineBuffer is

type ram_type is array (NO_OF_COLS downto 0) of std_logic_vector(DATA_WIDTH-1 downto 0);
signal ram_array : ram_type; -- := (others => "00000000");
--signal clk2 : std_logic;
signal rIndex : SMALL_INTEGER := 1;
signal wIndex : SMALL_INTEGER := 0;

begin

--  clk <= NOT clk;
  
  p : process(clk)
  begin
  if clk'event and clk='1' then
    if fsync = '1' then
	  pdata_out <= ram_array(rIndex);
	  if rIndex < NO_OF_COLS-1 then
	    rIndex <= rIndex+1;
	  else
		rIndex <= 0;
	  end if;
	end if;
  end if;
  end process;
  -- writing into the memory

  p2 : process (clk)
  begin
  if clk'event and clk='1' then
	if fsync = '1' then
      ram_array(wIndex) <= pdata_in;
	  if wIndex < NO_OF_COLS-1 then
		wIndex <= wIndex+1;
	  else
		wIndex <= 0;
	  end if;
	--else
	  --wIndex <= 0;
    end if; -- fsync
  end if; -- clk2
  end process p2;
  
end Behavioral;