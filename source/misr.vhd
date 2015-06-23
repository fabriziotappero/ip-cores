library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity misr is
port (
  clock    : in std_logic;
  reset    : in std_logic;
  sel_top   : in std_logic;
  data_in   : in std_logic_vector(63 downto 0);
  pass      : out std_logic
  --signature : out std_logic_vector(63 downto 0)
);
end misr;

architecture modular_com of misr is

shared variable lfsr_reg : std_logic_vector(63 downto 0);

begin

  process (clock)
    variable lfsr_tap :  std_logic;
  begin
    if clock'EVENT and clock='1' then  --1
      if reset = '1' then
        lfsr_reg := data_in;
	   else
        lfsr_tap := lfsr_reg(0) xor lfsr_reg(1) xor lfsr_reg(3) xor lfsr_reg(4);
        lfsr_reg := (lfsr_reg(62 downto 0) & lfsr_tap) xor data_in;
      end if;
    end if;
	-- signature <= lfsr_reg;
  end process;
  
 -- signature <= lfsr_reg;


process(clock,sel_top)
Constant signature_v : std_logic_vector(63 downto 0):= "1111101011010000100001011000010000111011010111101101101011101101";
variable count : std_logic_vector(7 downto 0) := "00000000"; 
--variable pass : std_logic;
begin
    if sel_top = '1' then
	 if rising_edge(clock) then
	    count := count + 1;
	 end if;
	 	 if count = "01000001" then
	    
		 if signature_v = lfsr_reg then
		    pass <= '0';
		 else
		    pass <= '1';
		 end if;	 
	 	 end if;
   end if;
end process;


  
end modular_com;


