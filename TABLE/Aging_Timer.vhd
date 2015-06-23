-- UART BAUD RATE GENERATOR

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- N is the size of the register that holds the counter in bits.
-- M represents the modulo value, i.e., if 10, counter counts to 9 and wraps
entity Aging_Timer is
   generic(
      N: integer := 32;  -- 32 bits couter
      M: integer := 10  -- 125000  = 1 miliscond
   );
   port(
      clk, reset: in std_logic;
      timeout: out std_logic;
	  timer_aging_bit: out std_logic;
      count_out: out std_logic_vector(31 downto 0)--N-1
   );
end Aging_Timer;

architecture beh of Aging_Timer is
   SIGNAL timeout_i : STD_LOGIC;
   SIGNAL timer_aging_bit_i : STD_LOGIC;
   signal r_reg: unsigned(N-1 downto 0);
   signal r_next: unsigned(N-1 downto 0);
   begin

-- sequential logic that creates the FF
   process(clk, reset)
      begin
         if (reset = '1') then
            r_reg <= (others => '0');
         elsif (clk'event and clk='1') then
            r_reg <= r_next;
         end if;
   end process;

-- next state logic for the FF, count from 0 to M-1 and wrap
   r_next <= (others => '0') when r_reg=(M-1) else r_reg + 1;

-- output logic, output the actually count in the register, in case it's needed
   count_out <= std_logic_vector(r_reg);

-- generate a 1 clock cycle wide 'tick' when counter reaches max value
   timeout_i <= '1' when r_reg=(M-1) else '0';
   
	  process(clk, reset)
      begin
         if (reset = '1') then
				timer_aging_bit_i <= '0';
         elsif (clk'event and clk='1') then
				IF(timeout_i = '1' ) THEN
				timer_aging_bit_i <= NOT  timer_aging_bit_i;
				END IF ;
         end if;
   end process;
timeout <= timeout_i;
timer_aging_bit <=timer_aging_bit_i;
end beh;




