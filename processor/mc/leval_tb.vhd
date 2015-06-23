library ieee;

use ieee.std_logic_1164.all;
use work.leval_package.all;
use work.avremu_package.all;

entity leval_tb is
end entity;

architecture rtl of leval_tb is
  -- Components:
  component leval is
	port (
	   rst : in std_logic;
	   clk : in std_logic;
	   data_bus : inout std_logic_vector(BUS_SIZE-1 downto 0);
	   addr_bus : out std_logic_vector(ADDR_SIZE-1 downto 0);
	   wait_s : in std_logic;
	   read  : out std_logic;
	   write : out std_logic;
	   sync : in std_logic;
	   led       : out std_logic_vector(7 downto 0));
  end	component;
  
  component addr_decoder is
  port (
      clk : in std_logic;
      leval_addr	: in std_logic_vector(ADDR_SIZE - 1 downto 0);
      avr_irq		: out std_logic;
      mem_wait				: out std_logic;
      mem_ce    : out std_logic;
      read_s : in std_logic;
      write_s : in std_logic
	);
  end component;

  -- Signals:
	signal addr_s : std_logic_vector(ADDR_SIZE - 1 downto 0);
	signal mem_wait_s : std_logic;
	signal wait_s : std_logic;
	signal write_s : std_logic;
	signal read_s : std_logic;
	signal rst : std_logic;
	
	
	signal flash_ce0	: std_logic;
	signal flash_ce1	: std_logic := '0';	
	signal clk : std_logic;
	signal rst_low : std_logic;
	signal fpga_data : std_logic_vector(WORD_SIZE - 1 downto 0);
	signal fpga_addr : std_logic_vector(ADDR_SIZE - 1 downto 0);
	signal avr_irq :  std_logic;
	signal wait_f :  std_logic;
	signal read : std_logic;
	signal write :  std_logic;
	signal mem_ce : std_logic;
	signal sync_s : std_logic;
	signal led :  std_logic_vector(7 downto 0);
	signal err :  std_logic_vector(1 downto 0);
begin
  
  rst <= not rst_low;
  fpga_addr <= addr_s;
  --wait_s <= mem_wait_s and wait_f;
  read <= not read_s;
  write <= not write_s;

	LEVAL_CPU : leval
	port map(
		clk => clk,
		rst => rst,
		data_bus => fpga_data,
		addr_bus	=> addr_s, 
		wait_s	=> wait_s,
		read		=> read_s,
		write		=> write_s,
		led => led,
		sync => sync_s
	);

	ADDR_DEC	: addr_decoder 
	port map (
	  clk => clk,
	  leval_addr => addr_s,
		avr_irq => avr_irq,
		mem_wait => mem_wait_s,
		mem_ce => mem_ce,
		read_s => read_s,
		write_s => write_s
	);


   testproc : process
   begin
   sync_s <= '1';
--   pause_pc <= '0';
	rst_low <= '1';

    wait;
   end process;

end architecture;
