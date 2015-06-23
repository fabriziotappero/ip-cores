library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
USE work.cpu_types.ALL;

entity adder is
	generic( size : integer := d_bus_width);
	port( a : in std_logic_vector(size-1 downto 0);
              b : in std_logic_vector(size-1 downto 0);
              cin : in std_logic;
	      cout : out std_logic;
	      sum : out std_logic_vector(size-1 downto 0));
end adder;

architecture Behavioral of adder_new is
begin
  process(a,b,cin)
    variable temp_carry : std_logic_vector(size downto 0);
    variable temp_sum : std_logic_vector(size-1 downto 0);
  begin
    temp_carry(0) := cin;
    for i in 0 to size-1 loop
      temp_carry(i+1) := ((a(i) and b(i)) or (a(i) and temp_carry(i)) or (b(i) and temp_carry(i)));
      temp_sum(i) := a(i) xor b(i) xor temp_carry(i);
    end loop;
    sum <= temp_sum;
    cout <= temp_carry(size);
  end process;
end Behavioral;
