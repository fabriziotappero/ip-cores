-- 10/24/2005
-- Register Address Decoding

library ieee;
use ieee.std_logic_1164.all;

entity reg_dec is port(
  addr:	in std_logic_vector(2 downto 0);
  en0:	out std_logic;
  en1:	out std_logic;
  en2:	out std_logic;
  en3:	out std_logic;
  en4:	out std_logic;
  en5:	out std_logic;
  en6:	out std_logic;
  en7:	out std_logic
  );
end reg_dec;

architecture rd_arch of reg_dec is
begin
  process(addr)
  begin
    en0 <= (not addr(2)) and (not addr(1)) and (not addr(0));
    en1 <= (not addr(2)) and (not addr(1)) and addr(0);
    en2 <= (not addr(2)) and addr(1) and (not addr(0));
    en3 <= (not addr(2)) and addr(1) and addr(0);
    en4 <= addr(2) and (not addr(1)) and (not addr(0));
    en5 <= addr(2) and (not addr(1)) and addr(0);
    en6 <= addr(2) and addr(1) and (not addr(0));
    en7 <= addr(2) and addr(1) and addr(0);
  end process;
end rd_arch;
