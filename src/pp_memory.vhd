-- The Potato Processor - A simple processor for FPGAs
-- (c) Kristian Klomsten Skordal 2014 - 2015 <kristian.skordal@wafflemail.net>
-- Report bugs and issues on <http://opencores.org/project,potato,bugtracker>

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pp_types.all;
use work.pp_csr.all;
use work.pp_utilities.all;

entity pp_memory is
	port(
		clk    : in std_logic;
		reset  : in std_logic;
		stall  : in std_logic;

		-- Data memory inputs:
		dmem_read_ack  : in std_logic;
		dmem_write_ack : in std_logic;
		dmem_data_in   : in std_logic_vector(31 downto 0);

		-- Current PC value:
		pc : in std_logic_vector(31 downto 0);

		-- Destination register signals:
		rd_write_in  : in  std_logic;
		rd_write_out : out std_logic;
		rd_data_in   : in  std_logic_vector(31 downto 0);
		rd_data_out  : out std_logic_vector(31 downto 0);
		rd_addr_in   : in  register_address;
		rd_addr_out  : out register_address;

		-- Control signals:
		branch         : in  branch_type;
		mem_op_in      : in  memory_operation_type;
		mem_size_in    : in  memory_operation_size;
		mem_op_out     : out memory_operation_type;

		-- Whether the instruction should be counted:
		count_instr_in  : in  std_logic;
		count_instr_out : out std_logic;

		-- Exception signals:
		exception_in          : in std_logic;
		exception_out         : out std_logic;
		exception_context_in  : in  csr_exception_context;
		exception_context_out : out csr_exception_context;

		-- CSR signals:
		csr_addr_in   : in  csr_address;
		csr_addr_out  : out csr_address;
		csr_write_in  : in  csr_write_mode;
		csr_write_out : out csr_write_mode;
		csr_data_in   : in  std_logic_vector(31 downto 0);
		csr_data_out  : out std_logic_vector(31 downto 0)
	);
end entity pp_memory;

architecture behaviour of pp_memory is
	signal mem_op   : memory_operation_type;
	signal mem_size : memory_operation_size;

	signal rd_data : std_logic_vector(31 downto 0);
begin

	mem_op_out <= mem_op;

	pipeline_register: process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				rd_write_out <= '0';
				csr_write_out <= CSR_WRITE_NONE;
				count_instr_out <= '0';
				mem_op <= MEMOP_TYPE_NONE;
			elsif stall = '0' then
				mem_size <= mem_size_in;
				rd_data <= rd_data_in;
				rd_addr_out <= rd_addr_in;

				if exception_in = '1' then
					mem_op <= MEMOP_TYPE_NONE;
					rd_write_out <= '0';
					csr_write_out <= CSR_WRITE_REPLACE;
					csr_addr_out <= CSR_EPC;
					csr_data_out <= pc;
					count_instr_out <= '0';
				else
					mem_op <= mem_op_in;
					rd_write_out <= rd_write_in;
					csr_write_out <= csr_write_in;
					csr_addr_out <= csr_addr_in;
					csr_data_out <= csr_data_in;
					count_instr_out <= count_instr_in;
				end if;
			end if;
		end if;
	end process pipeline_register;

	update_exception_context: process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				exception_out <= '0';
			else
				exception_out <= exception_in or to_std_logic(branch = BRANCH_SRET);

				if exception_in = '1' then
					exception_context_out.status <= (
							pim => exception_context_in.status.im,
							im => (others => '0'),
							pei => exception_context_in.status.ei,
							ei => '0'
						);
					exception_context_out.cause <= exception_context_in.cause;
					exception_context_out.badvaddr <= exception_context_in.badvaddr;
				elsif branch = BRANCH_SRET then
					exception_context_out.status <= (
							pim => exception_context_in.status.pim,
							im => exception_context_in.status.pim,
							pei => exception_context_in.status.pei,
							ei => exception_context_in.status.pei
						);
					exception_context_out.cause <= CSR_CAUSE_NONE;
					exception_context_out.badvaddr <= (others => '0');
				else
					exception_context_out.status <= exception_context_in.status;
					exception_context_out.cause <= CSR_CAUSE_NONE;
					exception_context_out.badvaddr <= (others => '0');
				end if;
			end if;
		end if;
	end process update_exception_context;

	rd_data_mux: process(rd_data, dmem_data_in, mem_op, mem_size)
	begin
		if mem_op = MEMOP_TYPE_LOAD or mem_op = MEMOP_TYPE_LOAD_UNSIGNED then
			case mem_size is
				when MEMOP_SIZE_BYTE =>
					if mem_op = MEMOP_TYPE_LOAD_UNSIGNED then
						rd_data_out <= std_logic_vector(resize(unsigned(dmem_data_in(7 downto 0)), rd_data_out'length));
					else
						rd_data_out <= std_logic_vector(resize(signed(dmem_data_in(7 downto 0)), rd_data_out'length));
					end if;
				when MEMOP_SIZE_HALFWORD =>
					if mem_op = MEMOP_TYPE_LOAD_UNSIGNED then
						rd_data_out <= std_logic_vector(resize(unsigned(dmem_data_in(15 downto 0)), rd_data_out'length));
					else
						rd_data_out <= std_logic_vector(resize(signed(dmem_data_in(15 downto 0)), rd_data_out'length));
					end if;
				when MEMOP_SIZE_WORD =>
					rd_data_out <= dmem_data_in;
			end case;
		else
			rd_data_out <= rd_data;
		end if;
	end process rd_data_mux;

end architecture behaviour;
