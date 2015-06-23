library ieee;
use ieee.std_logic_1164.all;

use work.globals.all;

entity synthTest is
  port (
    clk_i             : in std_logic;
    rst_i             : in std_logic;
    data_i            : in std_logic;
    ready_o           : out std_logic;
    character_o       : out std_logic_vector(0 to 7);
    anode_ctrl        : out std_logic_vector(3 downto 0);
    recieved_debug    : out std_logic_vector(3 downto 0);
    waitforstart_rdy  : out std_logic;
    testpin           : out std_logic
  );
end synthTest;

architecture Behavioral of synthTest is

  component manchesterWireless
  port (
    clk_i             : in  std_logic;
    rst_i             : in  std_logic;
    data_i            : in  std_logic;
    q_o               : out std_logic_vector(WORD_LENGTH-1 downto 0);
    ready_o           : out std_logic;
    recieved_debug : out std_logic_vector(3 downto 0);
    waitforstart_rdy : out std_logic    
  );
  end component; 

  signal decode_output : std_logic_vector(WORD_LENGTH-1 downto 0);
  signal ud_buff1, ud_buff1_reg : std_logic_vector(6 downto 0);
  signal reset_manchester, soft_reset, ready_o_buff : std_logic;
begin
  character_o(7) <= '1'; -- turn off decimal point
  testpin <= '1';

  reset_manchester <=  rst_i or soft_reset;
  ready_o <= ready_o_buff;

  inst_manchesterWireless : manchesterWireless
  port map(
    clk_i   => clk_i,
    rst_i   => reset_manchester,
    data_i  => data_i,
    q_o     => decode_output,
    ready_o => ready_o_buff,
    recieved_debug => recieved_debug, 
    waitforstart_rdy => waitforstart_rdy
  );
  
  -- decode digit
  with decode_output(3 downto 0) select
     ud_buff1  <= "0000001" when x"0",  -- off
                   "1001111" when x"1",  -- 1
                   "0010010" when x"2",  -- 2
                   "0000110" when x"3",  -- 3
                   "1001100" when x"4",  -- 4
                   "0100100" when x"5",  -- 5
                   "0100000" when x"6",  -- 6
                   "0001111" when x"7",  -- 7
                   "0000000" when x"8",  -- 8
                   "0000100" when x"9",  -- 9
                   "0110000" when others; -- Error

  process (clk_i,rst_i)
  begin  
     if rst_i = '1' then
       soft_reset <= '0';
       ud_buff1_reg <= "1111111";
     elsif (clk_i'event and clk_i = '1') then
       -- register the output
       if (ready_o_buff = '1') then
        ud_buff1_reg <= ud_buff1;
        soft_reset <= '1';
       else
        soft_reset <= '0';
       end if;
       
     end if;
  end process;
   
  character_o(0 to 6) <= ud_buff1_reg;
  anode_ctrl <= "0111";  
               
end Behavioral;

