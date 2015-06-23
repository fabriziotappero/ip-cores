-- The Potato Processor - A simple processor for FPGAs
-- (c) Kristian Klomsten Skordal 2014 - 2015 <kristian.skordal@wafflemail.net>
-- Report bugs and issues on <http://opencores.org/project,potato,bugtracker>

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pp_csr.all;

entity pp_csr_unit is
	generic(
		PROCESSOR_ID : std_logic_vector(31 downto 0)
	);
	port(
		clk, timer_clk : in std_logic;
		reset : in std_logic;

		-- Count retired instruction:
		count_instruction : in std_logic;

		-- HTIF interface:
		fromhost_data    : in  std_logic_vector(31 downto 0);
		fromhost_updated : in  std_logic;
		tohost_data      : out std_logic_vector(31 downto 0);
		tohost_updated   : out std_logic;

		-- Read port:
		read_address   : in csr_address;
		read_data_out  : out std_logic_vector(31 downto 0);
		read_writeable : out boolean;

		-- Write port:
		write_address : in csr_address;
		write_data_in : in std_logic_vector(31 downto 0);
		write_mode    : in csr_write_mode;

		-- Exception context write port:
		exception_context       : in csr_exception_context;
		exception_context_write : in std_logic;

		-- Registers needed for exception handling, always read:
		status_out : out csr_status_register;
		evec_out   : out std_logic_vector(31 downto 0)
	);
end entity pp_csr_unit;

architecture behaviour of pp_csr_unit is

	-- Implemented counters:
	signal counter_time    : std_logic_vector(63 downto 0);
	signal counter_cycle   : std_logic_vector(63 downto 0);
	signal counter_instret : std_logic_vector(63 downto 0);

	-- Implemented registers:
	signal sup0, sup1 : std_logic_vector(31 downto 0) := (others => '0');
	signal epc, evec  : std_logic_vector(31 downto 0) := (others => '0');
	signal badvaddr   : std_logic_vector(31 downto 0) := (others => '0');
	signal cause      : csr_exception_cause;

	-- HTIF FROMHOST register:
	signal fromhost: std_logic_vector(31 downto 0);

	-- Status register:
	signal status_register : csr_status_register;

begin

	read_writeable <= csr_is_writeable(read_address);

	--! Updates the FROMHOST register when new data is available.
	htif_fromhost: process(clk)
	begin
		if rising_edge(clk) then
			if fromhost_updated = '1' then
				fromhost <= fromhost_data;
			end if;
		end if;	
	end process htif_fromhost;

	--! Sends a word to the host over the HTIF interface.
	htif_tohost: process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				tohost_data <= (others => '0');
				tohost_updated <= '0';
			else
				if write_mode /= CSR_WRITE_NONE and write_address = CSR_TOHOST then
					tohost_data <= write_data_in;
					tohost_updated <= '1';
				else
					tohost_updated <= '0';
				end if;
			end if;
		end if;
	end process htif_tohost;

	write: process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				status_register <= CSR_SR_DEFAULT;
			else
				if exception_context_write = '1' then
					status_register <= exception_context.status;
					cause <= exception_context.cause;
					badvaddr <= exception_context.badvaddr;
				end if;

				if write_mode /= CSR_WRITE_NONE then
					case write_address is
						when CSR_STATUS =>
							if exception_context_write = '0' then
								status_register <= to_csr_status_register(write_data_in);
							end if;
						when CSR_EPC =>
							epc <= write_data_in;
						when CSR_EVEC =>
							evec <= write_data_in;
						when CSR_SUP0 =>
							sup0 <= write_data_in;
						when CSR_SUP1 =>
							sup1 <= write_data_in;
						when others =>
							-- Ignore writes to invalid or read-only registers
					end case;
				end if;
			end if;
		end if;
	end process write;

	status_out <= exception_context.status when exception_context_write = '1' else status_register;

	read: process(clk)
	begin
		if rising_edge(clk) then
			--if exception_context_write  = '1' then
			--	status_out <= exception_context.status;
			--else
			--	status_out <= status_register;
			--end if;

			if write_mode /= CSR_WRITE_NONE and write_address = CSR_EVEC then
				evec_out <= write_data_in;
			else
				evec_out <= evec;
			end if;

			if write_mode /= CSR_WRITE_NONE and write_address = read_address then
				read_data_out <= write_data_in;
			else
				case read_address is
	
					-- Status and control registers:
					when CSR_STATUS => -- Status register
						read_data_out <= to_std_logic_vector(status_register);
					when CSR_HARTID => -- Processor ID
						read_data_out <= PROCESSOR_ID;
					when CSR_FROMHOST => -- Fromhost data
						read_data_out <= fromhost;
					when CSR_EPC | CSR_EPC_SRET => -- Exception PC value
						read_data_out <= epc;
					when CSR_EVEC => -- Exception handler address
						read_data_out <= evec;
					when CSR_CAUSE => -- Exception cause
						read_data_out <= to_std_logic_vector(cause);
					when CSR_BADVADDR => -- Load/store address responsible for the exception
						read_data_out <= badvaddr;
	
					-- Supporting registers:
					when CSR_SUP0 =>
						read_data_out <= sup0;
					when CSR_SUP1 =>
						read_data_out <= sup1;
	
					-- Timers and counters:
					when CSR_TIME =>
						read_data_out <= counter_time(31 downto 0);
					when CSR_TIMEH =>
						read_data_out <= counter_time(63 downto 32);
					when CSR_CYCLE =>
						read_data_out <= counter_cycle(31 downto 0);
					when CSR_CYCLEH =>
						read_data_out <= counter_cycle(63 downto 32);
					when CSR_INSTRET =>
						read_data_out <= counter_instret(31 downto 0);
					when CSR_INSTRETH =>
						read_data_out <= counter_instret(63 downto 32);
	
					-- Return zero from write-only registers and invalid register addresses:
					when others =>
						read_data_out <= (others => '0');
				end case;
			end if;
		end if;
	end process read;

	timer_counter: entity work.pp_counter
		port map(
			clk => timer_clk,
			reset => reset,
			count => counter_time,
			increment => '1'
		);

	cycle_counter: entity work.pp_counter
		port map(
			clk => clk,
			reset => reset,
			count => counter_cycle,
			increment => '1'
		);

	instret_counter: entity work.pp_counter
		port map(
			clk => clk,
			reset => reset,
			count => counter_instret,
			increment => count_instruction
		);

end architecture behaviour;
