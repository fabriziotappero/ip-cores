library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;

use work.globals.all;

entity testSim is
end testSim;

architecture Behavioral of testSim is

  component manchesterWireless
  port (
    clk_i             : in  std_logic;
    rst_i             : in  std_logic;
    data_i            : in  std_logic;
    q_o               : out std_logic_vector(WORD_LENGTH-1 downto 0);
    ready_o           : out std_logic;
    recieved_debug    : out std_logic_vector(3 downto 0);
    waitforstart_rdy  : out std_logic
  );
  end component; 
  
  signal clk_i             : std_logic;
  signal rst_i             : std_logic := '1';
  signal q_o 				   : std_logic_vector(3 downto 0);
  signal ready_o           : std_logic;
  signal recieved_debug    : std_logic_vector(3 downto 0);
  signal waitforstart_rdy  : std_logic;  
  
  constant half_period : time := 10 ns;
  constant period : time := 2*half_period;

  ----------Added by Thiag-------------
  file      TEST_IP       : TEXT open READ_MODE is "six.dat";
  signal data_i           : std_ulogic;
  constant  BIT_PERIOD    : time  :=  40 us;
  -------------------------------------

begin
  inst_manchesterWireless: manchesterWireless
  port map(
    clk_i   => clk_i,
    rst_i   => rst_i,
    data_i  => data_i,
    q_o     => q_o,
    ready_o => ready_o,
    recieved_debug => recieved_debug,
    waitforstart_rdy => waitforstart_rdy
  );
  
  process
  variable  LINE_BUF      : LINE;
  variable  IP_BIT        : BIT;
  begin
    wait for 5*period;
    rst_i <= '0';

    while not ENDFILE (TEST_IP) loop
      READLINE (TEST_IP,LINE_BUF);
      while (LINE_BUF'LENGTH /= 0) loop
        READ(LINE_BUF,IP_BIT);
        data_i  <= TO_STDULOGIC(IP_BIT);
        wait for BIT_PERIOD;
      end loop;
    end loop;
    assert (FALSE)
      report "End of Input Data"
      severity ERROR;
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



