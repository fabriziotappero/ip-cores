library ieee;
use ieee.std_logic_1164.all;
use work.leval2_package.all;

entity toplevel is 
	port(
		clk			: in std_logic;
		rst_low		: in std_logic;
		fpga_data	: inout std_logic_vector(WORD_BITS - 1 downto 0);
		fpga_addr	: out	std_logic_vector(ADDR_BITS - 1 downto 0);
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
    signal rst : std_logic;
    signal MemReadData : std_logic_vector(WORD_BITS - 1 downto 0);
    signal MemWriteData : std_logic_vector(WORD_BITS - 1 downto 0);
    signal MemAddress : std_logic_vector(ADDR_BITS - 1 downto 0);
    signal IOwait : std_logic;
	signal memory_rdy : std_logic;
	signal MemCe : std_logic_vector(1 downto 0);
	signal MemWrite : std_logic;
	signal MemRead : std_logic;
begin

    rst <= not rst_low; -- Wonderfull.
    fpga_addr <= MemAddress;
    IOwait <= memory_rdy and avr_rdy;
	mem_ce <= MemCe;
	read <= not MemRead;
	write <= not MemWrite;

    cpu : entity leval2
    port map (
                clk => clk,
                rst => rst,
                data_in => MemReadData,
                data_out => MemWriteData,
                addr_bus => MemAddress,
                iowait => IOwait,
                sync => sync,
                read => MemRead,
                write => MemWrite,
                led => led
             );

    addr_decoder : entity addr_decoder 
    port map (
            clk => clk,
            leval_addr => MemAddress, -- address to decode
            avr_irq => avr_irq, -- interrupt for avr
            mem_wait => memory_rdy, -- memory not ready 
            mem_ce => MemCe,  -- enable memory chip
            read_s => MemRead, -- memory read
            write_s => MemWrite); -- memory write

    bus_interface : entity bidirbus 
        port map (
            clk => clk,
            bidir => fpga_data,
            oe => MemWrite,
            inp => MemWriteData,
            outp => MemReadData);
end architecture;

