library ieee;
use ieee.std_logic_1164.all;

entity testSim is
end testSim;

architecture Behavioral of testSim is
  constant start_length : integer := 20;

  component waitForStart
  generic (start_length : integer);
  port (
    data_i : in  std_logic;
    clk_i : in  std_logic;
    rst_i : in std_logic;           
    ready_o : out  std_logic    
  );
  end component; 

  constant half_period : time := 10 ns;

  signal data_i : std_logic;
  signal clk_i : std_logic;
  signal rst_i : std_logic := '1';
  signal ready_o : std_logic;
begin
  
  process
  begin
    rst_i <= '1';
    wait for 5 ns;
    rst_i <= '0';
    data_i <= '1';
    
    wait for 400 ns;
    data_i <= '0';
    
    wait for 100 ns;
    data_i <= '1';
    
    wait for 2000 ns;
  end process;
  
  waitForStart1 : waitForStart
  generic map(start_length => start_length)
  port map(
    data_i => data_i,
    clk_i => clk_i,
    rst_i => rst_i,
    ready_o => ready_o
  );

  clock : process
  begin
    clk_i <= '1';
    loop
      wait for half_period;
      clk_i <= not clk_i;
    end loop;
  end process; 
end Behavioral;

