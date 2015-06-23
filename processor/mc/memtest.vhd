library ieee;
use ieee.std_logic_1164.all;
use work.leval_package.all;


entity memtest is 
  port(
    clk : in std_logic;
    rst : in std_logic;
    pause : in std_logic;
    fpga_data : inout std_logic_vector(WORD_SIZE - 1 downto 0);
    fpga_addr : out	std_logic_vector(ADDR_SIZE - 1 downto 0);
    avr_irq : out std_logic;
    wait_f : in  std_logic;
    read : out std_logic;
    write : out std_logic;
    led : out std_logic_vector(7 downto 0));
end entity;

architecture rtl of memtest is
  -- Components:
  component leval is
  port (
     pause : in std_logic;
     rst : in std_logic;
     clk : in std_logic;
     data_bus : inout std_logic_vector(BUS_SIZE-1 downto 0);
     addr_bus : out std_logic_vector(ADDR_SIZE-1 downto 0);
     wait_s : in std_logic;
     read  : out std_logic;
     write : out std_logic;
     led       : out std_logic_vector(7 downto 0));
  end	component;
  
  component addr_decoder is
  port (
    leval_addr	: in std_logic_vector(ADDR_SIZE - 1 downto 0);
    avr_irq		: out std_logic;
    wt			: out std_logic
  );
  end component;

  component ext_mem is
    port(
      we : in std_logic;
      re : in std_logic;
      a : in std_logic_vector(4 downto 0);
      d : inout std_logic_vector(WORD_SIZE - 1 downto 0)
    );
  end component;

  -- Signals:
  signal addr_s : std_logic_vector(ADDR_SIZE - 1 downto 0);
  signal data_s : std_logic_vector(WORD_SIZE - 1 downto 0);
  signal data_out_s : std_logic_vector(WORD_SIZE - 1 downto 0);
  signal data_in_s : std_logic_vector(WORD_SIZE - 1 downto 0);
  signal write_s : std_logic;
  signal read_s : std_logic;
  signal wait_s : std_logic;
  
  
  signal flash_ce0	: std_logic;
  signal flash_ce1	: std_logic := '0';	

begin

  LEVAL_CPU : leval
  port map(
    pause => '0', -- TODO: set to pause
    clk => clk,
    rst => rst,
    data_bus => data_s,
    addr_bus	=> addr_s, 
    wait_s	=> wait_s,
    read		=> read_s,
    write		=> write_s,
    led => led
  );

  dmem : ext_mem 
  port map (
    we => write_s,
    re => read_s,
    a => addr_s(4 downto 0),
    d => data_s
  );

  ADDR_DEC	: addr_decoder 
  port map (
    leval_addr => addr_s,
    avr_irq => avr_irq,
    wt => wait_s
  );


end architecture rtl;


