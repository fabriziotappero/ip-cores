library IEEE;
use IEEE.std_logic_1164.all;

entity lfsr is
port (
  clock    : in std_logic;
  reset    : in std_logic;
  sel_top   : in std_logic;
  --                               input
  data_out : out std_logic_vector(63 downto 0)
);
end lfsr;

architecture modular of lfsr is

  

begin

  process (clock,sel_top)
    variable lfsr_tap : std_logic;
	 variable seed : std_logic_vector(63 downto 0);
	 variable lfsr_reg : std_logic_vector(63 downto 0);
  begin
    if sel_top = '1' then seed := x"0F0F0F0F0F0F0F0F"; else seed := x"0000000000000000"; end if;
    if clock'EVENT and clock='0' then  --1
      if reset = '1' then  --1
        lfsr_reg := seed;
      else
        lfsr_tap := lfsr_reg(0) xor lfsr_reg(1) xor lfsr_reg(3) xor lfsr_reg(4);
        lfsr_reg := lfsr_reg(62 downto 0) & lfsr_tap;
      end if;
    end if;
	 data_out <= lfsr_reg;
  end process;
  
  --data_out <= lfsr_reg;
  
end modular;


