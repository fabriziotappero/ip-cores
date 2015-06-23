library ieee;
use ieee.std_logic_1164.all;
use work.leval_package.all;

entity toplevel is 
	port(
		clk			: in std_logic;
		rst_low		: in std_logic;
		fpga_data	: inout std_logic_vector(WORD_SIZE - 1 downto 0);
		fpga_addr	: out	std_logic_vector(ADDR_SIZE - 1 downto 0);
		avr_irq		: out std_logic;
		avr_rdy		: in  std_logic;
		sync			: in std_logic;
		read			: out std_logic;
		write			: out std_logic;
		mem_ce		: out std_logic_vector(1 downto 0);
		led			: out std_logic_vector(7 downto 0);
		err			: in std_logic_vector(1 downto 0));
end entity;

architecture rtl of toplevel is
	-- Components:
	component leval is
	port (
		rst		: in std_logic;
		clk		: in std_logic;
		data_in	: in std_logic_vector(BUS_SIZE - 1 downto 0);
		data_out	: out std_logic_vector(BUS_SIZE - 1 downto 0);
		addr_bus	: out std_logic_vector(ADDR_SIZE-1 downto 0);
		wait_s	: in std_logic;
		read		: out std_logic;
		write		: out std_logic;
		sync		: in std_logic;
		led		: out std_logic_vector(7 downto 0));
		-- DEBUG SIGNALS
--		pc_out : out std_logic_vector(MC_ADDR_SIZE-1 downto 0);
--		state_out : out std_logic_vector(3 downto 0);
--		status_out : out std_logic_vector(STATUS_REG_SIZE-1 downto 0);
--		pc_write_out : out std_logic);
	end component;
  
	component addr_decoder is
	port (
		clk			: in std_logic;
		leval_addr	: in std_logic_vector(ADDR_SIZE - 1 downto 0);
		avr_irq		: out std_logic;
		mem_wait		: out std_logic;
		mem_ce		: out std_logic_vector(1 downto 0);
		read_s		: in std_logic;
		write_s		: in std_logic);
	end component;
	
	component synchronizer is
	port (
		clk	: in std_logic;
		ws		: in std_logic;
		wso	: out std_logic);
	end component;

	-- Tristate bus
	component bidirbus is
	port (
		bidir : inout std_logic_vector(WORD_SIZE - 1 downto 0);
		oe : in std_logic;
		clk : in std_logic;
		inp : in std_logic_vector(WORD_SIZE - 1 downto 0);
		outp : out std_logic_vector(WORD_SIZE - 1 downto 0));
	end component;
	
--	-- CHIPSCOPE MODULES:
--	component icon
--	port (
--		control0    :   out std_logic_vector(35 downto 0);
--		control1    :   out std_logic_vector(35 downto 0));
--	end component;
--
--	component ila
--	port (
--		control     : in    std_logic_vector(35 downto 0);
--		clk         : in    std_logic;
--		trig0       : in    std_logic_vector(47 downto 0));
--	end component;
--	
--	component vio
--	port (
--		control     : in    std_logic_vector(35 downto 0);
--		clk         : in    std_logic;
--		sync_in     : in    std_logic_vector(47 downto 0);
--		sync_out    :   out std_logic_vector(47 downto 0));
--	end component;
--
--	-- CHIPSCOPE SIGNALS:
--	signal trig0      : std_logic_vector(47 downto 0);
--	signal control1    : std_logic_vector(35 downto 0);
--	signal sync_in    : std_logic_vector(47 downto 0);
--	signal sync_out   : std_logic_vector(47 downto 0);
--	signal control0       : std_logic_vector(35 downto 0);
--	-- END OF CHIPSCOPE COMPONENTS

--	-- DEBUG SIGNALS:
-- signal pc_out : std_logic_vector(MC_ADDR_SIZE-1 downto 0);
--	signal state_out : std_logic_vector(3 downto 0);
--	signal pc_write_out : std_logic;
--	signal status_out : std_logic_vector(STATUS_REG_SIZE-1 downto 0);
--	signal op1, op2 : std_logic_vector(WORD_SIZE-1 downto 0);

	-- Tristatebus signals
	-- From bidirbus to synchro
	signal t_bus_data_out : std_logic_vector(BUS_SIZE - 1 downto 0);
	
	-- Synchronizer signals
	-- From synchronizer 
	signal sync_ws_out : std_logic;

	-- These give way for flip-flops
	signal read_s_delayed : std_logic;
	signal write_s_delayed : std_logic;
	signal avr_irq_s_delayed : std_logic;
	signal mem_ce_s_delayed : std_logic_vector(1 downto 0);
	signal addr_s_delayed : std_logic_vector(ADDR_SIZE - 1 downto 0);

	-- This is from leval out to the world
	signal leval_data_out : std_logic_vector(BUS_SIZE - 1 downto 0);

	-- Signals:
	signal addr_s : std_logic_vector(ADDR_SIZE - 1 downto 0);
	signal mem_wait_s : std_logic;
	signal mem_wait_and_avr_rdy : std_logic;
	signal write_s : std_logic;
	signal read_s : std_logic;
	signal rst : std_logic;
	signal avr_irq_s : std_logic;
	signal mem_ce_s : std_logic_vector(1 downto 0);
	-- Clock control signals:
	signal leval_clk : std_logic := '0';

begin

	rst <= not rst_low;
	fpga_addr <= addr_s_delayed;
	read <= not read_s_delayed;
	write <= not write_s_delayed;
	avr_irq <= avr_irq_s_delayed;
	mem_ce <= mem_ce_s_delayed;
	mem_wait_and_avr_rdy <= mem_wait_s and avr_rdy;
	leval_clk <= clk;
--	-- DEBUG SIGNALS
--	pc <= pc_out;

	synchronizer_inst : synchronizer
	port map(
		clk => leval_clk,
		ws =>  mem_wait_and_avr_rdy, --connect the RDY/WAIT signal directly to synchronizer
		wso => sync_ws_out); -- connect the synched RDY/WAIT to leval

	bidirbus_inst : bidirbus
	port map(
		clk => leval_clk,
		oe => write_s,
		bidir => fpga_data,
		inp => leval_data_out, -- from leval into bidirbus
		outp => t_bus_data_out); -- from bidirbus to leval
	
	leval_inst : leval
	port map(
		clk => leval_clk,
		rst => rst,
		sync => sync,
		data_out => leval_data_out,
		data_in => t_bus_data_out, --connect Tristatebus to data in
		addr_bus	=> addr_s, 
		wait_s	=> sync_ws_out,
		read		=> read_s,
		write		=> write_s,
		led => led);
--		status_out => status_out,
--		pc_out => pc_out,
--		state_out => state_out,
--		pc_write_out => pc_write_out);

	addr_decoder_inst	: addr_decoder 
	port map (
	  clk => leval_clk,
	  leval_addr => addr_s,
		avr_irq => avr_irq_s,
		mem_wait => mem_wait_s,
		mem_ce => mem_ce_s,
		read_s => read_s_delayed,
		write_s => write_s_delayed
	);

	flank_delay : process(clk)
	begin
		if rising_edge(clk) then
			read_s_delayed <= read_s;
			write_s_delayed <= write_s;
			avr_irq_s_delayed <= avr_irq_s;
			mem_ce_s_delayed <= mem_ce_s;
			addr_s_delayed <= addr_s;
		end if;
	end process;

end architecture rtl;
