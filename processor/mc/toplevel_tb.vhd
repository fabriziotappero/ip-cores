library ieee;
use ieee.std_logic_1164.all;
use work.leval_package.all;
use work.avremu_package.all;

entity toplevel_tb is
end entity;

architecture rtl of toplevel_tb is

-- COMPONENTS FOR THIS TEST

component avremu is
  port (
    data  : inout databus_t;            -- Data bus
    addr  : in    addr_t;               -- Address bus
    intr  : in    std_logic;            -- Interrupt line
    read  : in    std_logic;            -- Read signal
    write : in    std_logic;            -- Write signal
    rdy   : out   std_logic);           -- Ready flag
end component avremu;

component ext_mem is
	port(
		we : in std_logic;
		re : in std_logic;
		a : in std_logic_vector(ADDR_SIZE - 1 downto 0);
		d : inout std_logic_vector(WORD_SIZE - 1 downto 0);
		ce : in std_logic
	);
end component;

component toplevel is 
	port(
		clk : in std_logic;
		rst_low : in std_logic;
		fpga_data : inout std_logic_vector(WORD_SIZE - 1 downto 0);
		fpga_addr : out	std_logic_vector(ADDR_SIZE - 1 downto 0);
		avr_irq : out std_logic;
		avr_rdy : in  std_logic;
		sync : in std_logic;
		read : out std_logic;
		write : out std_logic;
		mem_ce : out std_logic;
		led : out std_logic_vector(7 downto 0);
		err : in std_logic_vector(1 downto 0));
end component;


signal dut_clk : std_logic := '1';
signal dut_rst : std_logic := '1';
signal iobus : std_logic_vector(WORD_SIZE - 1 downto 0);
signal ioaddr : std_logic_vector(ADDR_SIZE - 1 downto 0);
signal interrupt : std_logic;
signal rdy : std_logic; -- FROM AVR
signal sync : std_logic := '1'; -- FROM AVR
signal read : std_logic; -- TO MEM/AVR
signal write : std_logic; --  To mem/avr
signal mem_ce : std_logic; -- To mem
signal leds : std_logic_vector(7 downto 0);


-- Architecture begin
begin

	-----------------------------------------------------------------------------
	-- Design under test
	-----------------------------------------------------------------------------
	dut : toplevel
	port map (
		clk => dut_clk,
		rst_low => dut_rst, 
		fpga_data => iobus,
		fpga_addr => ioaddr,
		avr_irq => interrupt,
		avr_rdy => rdy,
		sync => sync,
		read => read,
		write => write,
		mem_ce => mem_ce,
		led =>  leds,
		err => "00"
	);

	-----------------------------------------------------------------------------
	-- Support units
	-----------------------------------------------------------------------------

	-- The AVR
	-----------------------------------------------------------------------------
	iounit : avremu 
	port map (
		data => iobus,
		addr => ioaddr(7 downto 0),
		intr => interrupt,
		read => read,
		write => write,
		rdy => rdy
	);

	-- External memory
	-----------------------------------------------------------------------------
	memory : ext_mem
	port map(
		we => write,
		re => read,
		a => ioaddr,
		d => iobus,
		ce => mem_ce
	);

	-- Clock generator
	-----------------------------------------------------------------------------
	clock_gen : process(dut_clk)
	begin
		if dut_clk = '1' then
			dut_clk <= '0' after 5 ns, '1' after 10 ns;
		end if;
	end process;
end architecture;
