-- The Potato Processor - A simple processor for FPGAs
-- (c) Kristian Klomsten Skordal 2014 - 2015 <kristian.skordal@wafflemail.net>
-- Report bugs and issues on <http://opencores.org/project,potato,bugtracker>

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pp_types.all;
use work.pp_csr.all;

entity pp_writeback is
	port(
		clk    : in std_logic;
		reset  : in std_logic;

		-- Count instruction:
		count_instr_in  : in std_logic;
		count_instr_out : out std_logic;

		-- Exception signals:
		exception_ctx_in  : in  csr_exception_context;
		exception_in      : in  std_logic;
		exception_ctx_out : out csr_exception_context;
		exception_out     : out std_logic;

		-- CSR signals:
		csr_write_in  : in  csr_write_mode;
		csr_write_out : out csr_write_mode;
		csr_data_in   : in  std_logic_vector(31 downto 0);
		csr_data_out  : out std_logic_vector(31 downto 0);
		csr_addr_in   : in  csr_address;
		csr_addr_out  : out csr_address;

		-- Destination register interface:
		rd_addr_in   : in  register_address;
		rd_addr_out  : out register_address;
		rd_write_in  : in  std_logic;
		rd_write_out : out std_logic;
		rd_data_in   : in  std_logic_vector(31 downto 0);
		rd_data_out  : out std_logic_vector(31 downto 0)
	);
end entity pp_writeback;

architecture behaviour of pp_writeback is
begin

	pipeline_register: process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				rd_write_out <= '0';
				exception_out <= '0';
				count_instr_out <= '0';
			else
				count_instr_out <= count_instr_in;
				rd_data_out <= rd_data_in;
				rd_write_out <= rd_write_in;
				rd_addr_out <= rd_addr_in;

				exception_out <= exception_in;
				exception_ctx_out <= exception_ctx_in;

				csr_write_out <= csr_write_in;
				csr_data_out <= csr_data_in;
				csr_addr_out <= csr_addr_in;
			end if;
		end if;
	end process pipeline_register;

end architecture behaviour;
