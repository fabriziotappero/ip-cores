library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity test_sim is
end test_sim;

architecture Behavioral of test_sim is


  COMPONENT singleDouble
	PORT(
    clk_i   :  in  std_logic;
    ce_i    :  in  std_logic;    
    rst_i   :  in  std_logic;
    data_i  :  in  std_logic;
    q_o     :  out std_logic_vector(3 downto 0);
    ready_o :  out std_logic
		);
	END COMPONENT;

  signal clk : std_logic := '0';
  signal ce_i : std_logic := '0';
  signal mdi : std_logic := '0';
  signal q_modified : std_logic_vector(3 downto 0);
  signal nd_modified : std_logic;
  
  constant period : time := 10 ns;
  constant md_period : time := period*16;
  signal reset : std_logic := '1';
begin

  Inst_modified: singleDouble PORT MAP(
    clk_i =>  clk,
    ce_i  =>  ce_i,
    rst_i  =>  reset,
    data_i   =>  mdi,
    q_o     =>  q_modified,
    ready_o    =>  nd_modified
  );

  process
  begin
    loop
      reset <= '1';
      ce_i <= '0';
      
      wait for (2*md_period);
    
      reset <= '0';
      ce_i <= '1';

      wait for 2*md_period;
    
      mdi <= not mdi;
      wait for 2*md_period;

      mdi <= not mdi;
      wait for md_period;

      mdi <= not mdi;
      wait for md_period;

      mdi <= not mdi;
      wait for md_period;

      mdi <= not mdi;
      wait for 2*md_period;

      mdi <= not mdi;
      wait for md_period;

      mdi <= not mdi;
      wait for 5*md_period;
    end loop;
  end process;
  
  process
  begin
    loop
      clk <= not clk;
      wait for period/2;    
    end loop;
  end process;

end Behavioral;

