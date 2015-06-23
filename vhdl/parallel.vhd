library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity parallel is
  port (
    clk    : in  std_logic;
    rst    : in  std_logic;
    input  : in  std_logic;
    output : out std_logic_vector(1 downto 0));
end parallel;

architecture parallel of parallel is
  type states is (st0, st1);
  signal state : states;

  signal aux       : std_logic_vector(1 downto 0);

begin

  process(clk, rst)
  begin
    if rst = '1' then
      aux <= (others => '0');
      output    <= (others => '0');
		state <= st0;
    elsif clk'event and clk = '1' then
	   case state is
		   when st0 =>
			   aux(1) <= input;
				output <= aux;
				state <= st1;
		   when st1 =>
			   aux(0) <= input;
				state <= st0;
		end case;			
    end if;
  end process;

end parallel;
