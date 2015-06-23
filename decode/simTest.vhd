library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.globals.all;

entity sim_test is
end sim_test;

architecture Behavioral of sim_test is

	COMPONENT decode
	PORT(
    clk_i     : in  std_logic;
    rst_i     : in  std_logic;
    encoded_i : in  std_logic_vector(3 downto 0);
    nd_i      : in  std_logic;    
    decoded_o : out std_logic_vector(WORD_LENGTH-1 downto 0);
    nd_o      : out std_logic
		);
	END COMPONENT;

-- For encoded_i:
--
-- 0000 = null
-- 0001 = single one
-- 0010 = single zero
-- 0100 = double one
-- 1000 = double zero

  signal clk_i : std_logic;
  signal rst_i : std_logic;
  signal encoded_i : std_logic_vector(3 downto 0) := "0000";
  signal nd_i : std_logic := '0';
  signal decoded_o : std_logic_vector(WORD_LENGTH-1 downto 0);
  signal nd_o : std_logic;
  constant half_period : time := 10 ns;
  constant period : time := 2*half_period;
  constant mid_single : time := (INTERVAL_MIN_SINGLE+INTERVAL_MAX_SINGLE)/2*period;
  
begin

	Inst_decode: decode PORT MAP(
		clk_i     => clk_i,
		rst_i     => rst_i,
		encoded_i => encoded_i,
    nd_i      => nd_i,
		decoded_o => decoded_o,
		nd_o      => nd_o
	);

  process
  begin
-- below never changes
    rst_i <= '1';
    wait for MID_SINGLE;

    rst_i <= '0';
    encoded_i <= "0000";
    wait for MID_SINGLE;

  
    nd_i <= '1';
    wait for period;
    nd_i <= '0';
    
    wait for MID_SINGLE;

    encoded_i <= "1000"; -- 00

    nd_i <= '1';
    wait for period;
    nd_i <= '0';

    wait for MID_SINGLE;

-- above never changes

    encoded_i <= "0010"; --11

    nd_i <= '1';
    wait for period;
    nd_i <= '0';

    wait for MID_SINGLE;

    encoded_i <= "0100"; --0

    nd_i <= '1';
    wait for period;
    nd_i <= '0';

    wait for MID_SINGLE;

    encoded_i <= "0001"; --1

    nd_i <= '1';
    wait for period;
    nd_i <= '0';

    wait for MID_SINGLE;

    encoded_i <= "1000"; --00

    nd_i <= '1';
    wait for period;
    nd_i <= '0';

    wait for MID_SINGLE;


    encoded_i <= "0001"; --1

    nd_i <= '1';
    wait for period;
    nd_i <= '0';

    wait for MID_SINGLE;

    encoded_i <= "0100"; --0

    nd_i <= '1';
    wait for period;
    nd_i <= '0';

    wait for MID_SINGLE;

    encoded_i <= "0001"; --1

    nd_i <= '1';
    wait for period;
    nd_i <= '0';

    wait for MID_SINGLE;

    encoded_i <= "0100"; --0

    nd_i <= '1';
    wait for period;
    nd_i <= '0';

    wait for MID_SINGLE;

    encoded_i <= "0001"; --1

    nd_i <= '1';
    wait for period;
    nd_i <= '0';

    wait for MID_SINGLE;

    encoded_i <= "0100"; --0

    nd_i <= '1';
    wait for period;
    nd_i <= '0';

    wait for MID_SINGLE;
    
    encoded_i <= "0001"; --1

    nd_i <= '1';
    wait for period;
    nd_i <= '0';

    wait for MID_SINGLE;

    encoded_i <= "0100"; --0

    nd_i <= '1';
    wait for period;
    nd_i <= '0';

    wait for MID_SINGLE;
    
    encoded_i <= "0001"; --1

    nd_i <= '1';
    wait for period;
    nd_i <= '0';

    wait for MID_SINGLE;

    encoded_i <= "0100"; --0

    nd_i <= '1';
    wait for period;
    nd_i <= '0';

    wait for MID_SINGLE;

    encoded_i <= "0001"; --1

    nd_i <= '1';
    wait for period;
    nd_i <= '0';

    wait for MID_SINGLE;

    encoded_i <= "0100"; --0

    nd_i <= '1';
    wait for period;
    nd_i <= '0';

    wait for MID_SINGLE;


    
    

    encoded_i <= "0001"; --1

    nd_i <= '1';
    wait for period;
    nd_i <= '0';

    wait for MID_SINGLE;

    encoded_i <= "0100"; --0

    nd_i <= '1';
    wait for period;
    nd_i <= '0';

    wait for MID_SINGLE;

    encoded_i <= "0001"; --1

    nd_i <= '1';
    wait for period;
    nd_i <= '0';

    wait for MID_SINGLE;

    encoded_i <= "0100"; --0

    nd_i <= '1';
    wait for period;
    nd_i <= '0';

    wait for MID_SINGLE;

  end process;
  
  clock : process
  begin
    clk_i <= '1';
    loop
      wait for half_period;
      clk_i <= not clk_i;
    end loop;
  end process;   

end Behavioral;

