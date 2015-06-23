-- The Potato Processor - A simple processor for FPGAs
-- (c) Kristian Klomsten Skordal 2014 - 2015 <kristian.skordal@wafflemail.net>
-- Report bugs and issues on <http://opencores.org/project,potato,bugtracker>

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pp_types.all;
use work.pp_constants.all;
use work.pp_utilities.all;
use work.pp_csr.all;

--! @brief The Potato Processor is a simple processor core for use in FPGAs.
--! @details
--! It implements the RV32I (RISC-V base integer subset) ISA with additional
--! instructions for manipulation of control and status registers from the
--! currently unpublished supervisor extension.
entity pp_core is
	generic(
		PROCESSOR_ID           : std_logic_vector(31 downto 0) := x"00000000"; --! Processor ID.
		RESET_ADDRESS          : std_logic_vector(31 downto 0) := x"00000000"  --! Address of the first instruction to execute.
	);
	port(
		-- Control inputs:
		clk       : in std_logic; --! Processor clock
		reset     : in std_logic; --! Reset signal

		timer_clk : in std_logic; --! Clock used for the timer/counter

		-- Instruction memory interface:
		imem_address : out std_logic_vector(31 downto 0); --! Address of the next instruction
		imem_data_in : in  std_logic_vector(31 downto 0); --! Instruction input
		imem_req     : out std_logic;
		imem_ack     : in  std_logic;

		-- Data memory interface:
		dmem_address   : out std_logic_vector(31 downto 0); --! Data address
		dmem_data_in   : in  std_logic_vector(31 downto 0); --! Input from the data memory
		dmem_data_out  : out std_logic_vector(31 downto 0); --! Ouptut to the data memory
		dmem_data_size : out std_logic_vector( 1 downto 0);  --! Size of the data, 1 = 8 bits, 2 = 16 bits, 0 = 32 bits. 
		dmem_read_req  : out std_logic;                      --! Data memory read request
		dmem_read_ack  : in  std_logic;                      --! Data memory read acknowledge
		dmem_write_req : out std_logic;                      --! Data memory write request
		dmem_write_ack : in  std_logic;                      --! Data memory write acknowledge

		-- Tohost/fromhost interface:
		fromhost_data     : in  std_logic_vector(31 downto 0); --! Data from the host/simulator.
		fromhost_write_en : in  std_logic;                     --! Write enable signal from the host/simulator.
		tohost_data       : out std_logic_vector(31 downto 0); --! Data to the host/simulator.
		tohost_write_en   : out std_logic;                     --! Write enable signal to the host/simulator.

		-- External interrupt input:
		irq : in std_logic_vector(7 downto 0) --! IRQ inputs.
	);
end entity pp_core;

architecture behaviour of pp_core is

	------- Flush signals -------
	signal flush_if, flush_id, flush_ex : std_logic;

	------- Stall signals -------
	signal stall_if, stall_id, stall_ex, stall_mem : std_logic;

	-- Signals used to determine if an instruction should be counted
	-- by the instret counter:
	signal if_count_instruction, id_count_instruction  : std_logic;
	signal ex_count_instruction, mem_count_instruction : std_logic;
	signal wb_count_instruction : std_logic; 

	-- CSR read port signals:
	signal csr_read_data      : std_logic_vector(31 downto 0);
	signal csr_read_writeable : boolean;
	signal csr_read_address, csr_read_address_p : csr_address;

	-- Status register outputs:
	signal status : csr_status_register;
	signal evec   : std_logic_vector(31 downto 0);

	-- Load hazard detected in the execute stage:
	signal load_hazard_detected : std_logic;

	-- Branch targets:
	signal exception_target, branch_target : std_logic_vector(31 downto 0);
	signal branch_taken, exception_taken   : std_logic;

	-- Register file read ports:
	signal rs1_address_p, rs2_address_p : register_address;
	signal rs1_address, rs2_address     : register_address;
	signal rs1_data, rs2_data           : std_logic_vector(31 downto 0);

	-- Data memory signals:
	signal dmem_address_p   : std_logic_vector(31 downto 0);
	signal dmem_data_size_p : std_logic_vector(1 downto 0);
	signal dmem_data_out_p  : std_logic_vector(31 downto 0);
	signal dmem_read_req_p  : std_logic;
	signal dmem_write_req_p : std_logic;

	-- Fetch stage signals:
	signal if_instruction, if_pc : std_logic_vector(31 downto 0);
	signal if_instruction_ready  : std_logic;

	-- Decode stage signals:
	signal id_funct3          : std_logic_vector(2 downto 0);
	signal id_rd_address      : register_address;
	signal id_rd_write        : std_logic;
	signal id_rs1_address     : register_address;
	signal id_rs2_address     : register_address;
	signal id_csr_address     : csr_address;
	signal id_csr_write       : csr_write_mode;
	signal id_csr_use_immediate : std_logic;
	signal id_shamt           : std_logic_vector(4 downto 0);
	signal id_immediate       : std_logic_vector(31 downto 0);
	signal id_branch          : branch_type;
	signal id_alu_x_src, id_alu_y_src : alu_operand_source;
	signal id_alu_op          : alu_operation;
	signal id_mem_op          : memory_operation_type;
	signal id_mem_size        : memory_operation_size;
	signal id_pc              : std_logic_vector(31 downto 0);
	signal id_exception       : std_logic;
	signal id_exception_cause : csr_exception_cause;

	-- Execute stage signals:
	signal ex_dmem_address   : std_logic_vector(31 downto 0);
	signal ex_dmem_data_size : std_logic_vector(1 downto 0);
	signal ex_dmem_data_out  : std_logic_vector(31 downto 0);
	signal ex_dmem_read_req  : std_logic;
	signal ex_dmem_write_req : std_logic;
	signal ex_rd_address     : register_address;
	signal ex_rd_data        : std_logic_vector(31 downto 0);
	signal ex_rd_write       : std_logic;
	signal ex_pc             : std_logic_vector(31 downto 0);
	signal ex_csr_address    : csr_address;
	signal ex_csr_write      : csr_write_mode;
	signal ex_csr_data       : std_logic_vector(31 downto 0);
	signal ex_branch         : branch_type;
	signal ex_mem_op         : memory_operation_type;
	signal ex_mem_size       : memory_operation_size;
	signal ex_exception_context : csr_exception_context;

	-- Memory stage signals:
	signal mem_rd_write    : std_logic;
	signal mem_rd_address  : register_address;
	signal mem_rd_data     : std_logic_vector(31 downto 0);
	signal mem_csr_address : csr_address;
	signal mem_csr_write   : csr_write_mode;
	signal mem_csr_data    : std_logic_vector(31 downto 0);
	signal mem_mem_op      : memory_operation_type;

	signal mem_exception         : std_logic;
	signal mem_exception_context : csr_exception_context;

	-- Writeback signals:
	signal wb_rd_address  : register_address;
	signal wb_rd_data     : std_logic_vector(31 downto 0);
	signal wb_rd_write    : std_logic;
	signal wb_csr_address : csr_address;
	signal wb_csr_write   : csr_write_mode;
	signal wb_csr_data    : std_logic_vector(31 downto 0);

	signal wb_exception         : std_logic;
	signal wb_exception_context : csr_exception_context;

begin

	stall_if <= stall_id;
	stall_id <= stall_ex;
	stall_ex <= load_hazard_detected or stall_mem;
	stall_mem <= to_std_logic(memop_is_load(mem_mem_op) and dmem_read_ack = '0')
		or to_std_logic(mem_mem_op = MEMOP_TYPE_STORE and dmem_write_ack = '0');

	flush_if <= (branch_taken or exception_taken) and not stall_if;
	flush_id <= (branch_taken or exception_taken) and not stall_id;
	flush_ex <= (branch_taken or exception_taken) and not stall_ex;

	------- Control and status module -------
	csr_unit: entity work.pp_csr_unit
			generic map(
				PROCESSOR_ID => PROCESSOR_ID
			) port map(
				clk => clk,
				reset => reset,
				timer_clk => timer_clk,
				count_instruction => wb_count_instruction,
				fromhost_data => fromhost_data,
				fromhost_updated => fromhost_write_en,
				tohost_data => tohost_data,
				tohost_updated => tohost_write_en,
				read_address => csr_read_address,
				read_data_out => csr_read_data,
				read_writeable => csr_read_writeable,
				write_address => wb_csr_address,
				write_data_in => wb_csr_data,
				write_mode => wb_csr_write,
				exception_context => wb_exception_context,
				exception_context_write => wb_exception,
				status_out => status,
				evec_out => evec
			);

	csr_read_address <= id_csr_address when stall_ex = '0' else csr_read_address_p;

	store_previous_csr_addr: process(clk, stall_ex)
	begin
		if rising_edge(clk) and stall_ex = '0' then
			csr_read_address_p <= id_csr_address;
		end if;
	end process store_previous_csr_addr;

	------- Register file -------
	regfile: entity work.pp_register_file
			port map(
				clk => clk,
				rs1_addr => rs1_address,
				rs2_addr => rs2_address,
				rs1_data => rs1_data,
				rs2_data => rs2_data,
				rd_addr => wb_rd_address,
				rd_data => wb_rd_data,
				rd_write => wb_rd_write
			);

	rs1_address <= id_rs1_address when stall_ex = '0' else rs1_address_p;
	rs2_address <= id_rs2_address when stall_ex = '0' else rs2_address_p;

	store_previous_rsaddr: process(clk, stall_ex)
	begin
		if rising_edge(clk) and stall_ex = '0' then
			rs1_address_p <= id_rs1_address;
			rs2_address_p <= id_rs2_address;
		end if;
	end process store_previous_rsaddr;

	------- Instruction Fetch (IF) Stage -------
	fetch: entity work.pp_fetch
		generic map(
			RESET_ADDRESS => RESET_ADDRESS
		) port map(
			clk => clk,
			reset => reset,
			imem_address => imem_address,
			imem_data_in => imem_data_in,
			imem_req => imem_req,
			imem_ack => imem_ack,
			stall => stall_if,
			flush => flush_if,
			branch => branch_taken,
			exception => exception_taken,
			branch_target => branch_target,
			evec => exception_target,
			instruction_data => if_instruction,
			instruction_address => if_pc,
			instruction_ready => if_instruction_ready
		);
	if_count_instruction <= if_instruction_ready;

	------- Instruction Decode (ID) Stage -------
	decode: entity work.pp_decode
		generic map(
			RESET_ADDRESS => RESET_ADDRESS,
			PROCESSOR_ID => PROCESSOR_ID
		) port map(
			clk => clk,
			reset => reset,
			flush => flush_id,
			stall => stall_id,
			instruction_data => if_instruction,
			instruction_address => if_pc,
			instruction_ready => if_instruction_ready,
			instruction_count => if_count_instruction,
			funct3 => id_funct3,
			rs1_addr => id_rs1_address,
			rs2_addr => id_rs2_address,
			rd_addr => id_rd_address,
			csr_addr => id_csr_address,
			shamt => id_shamt,
			immediate => id_immediate,
			rd_write => id_rd_write,
			branch => id_branch,
			alu_x_src => id_alu_x_src,
			alu_y_src => id_alu_y_src,
			alu_op => id_alu_op,
			mem_op => id_mem_op,
			mem_size => id_mem_size,
			count_instruction => id_count_instruction,
			pc => id_pc,
			csr_write => id_csr_write,
			csr_use_imm => id_csr_use_immediate,
			decode_exception => id_exception,
			decode_exception_cause => id_exception_cause
		);

	------- Execute (EX) Stage -------
	execute: entity work.pp_execute
		port map(
			clk => clk,
			reset => reset,
			stall => stall_ex,
			flush => flush_ex,
			irq => irq,
			dmem_address => ex_dmem_address,
			dmem_data_size => ex_dmem_data_size,
			dmem_data_out => ex_dmem_data_out,
			dmem_read_req => ex_dmem_read_req,
			dmem_write_req => ex_dmem_write_req,
			rs1_addr_in => rs1_address,
			rs2_addr_in => rs2_address,
			rd_addr_in => id_rd_address,
			rd_addr_out => ex_rd_address,
			rs1_data_in => rs1_data,
			rs2_data_in => rs2_data,
			shamt_in => id_shamt,
			immediate_in => id_immediate,
			funct3_in => id_funct3,
			pc_in => id_pc,
			pc_out => ex_pc,
			csr_addr_in => csr_read_address,
			csr_addr_out => ex_csr_address,
			csr_write_in => id_csr_write,
			csr_write_out => ex_csr_write,
			csr_value_in => csr_read_data,
			csr_value_out => ex_csr_data,
			csr_writeable_in => csr_read_writeable,
			csr_use_immediate_in => id_csr_use_immediate,
			alu_op_in => id_alu_op,
			alu_x_src_in => id_alu_x_src,
			alu_y_src_in => id_alu_y_src,
			rd_write_in => id_rd_write,
			rd_write_out => ex_rd_write,
			rd_data_out => ex_rd_data,
			branch_in => id_branch,
			branch_out => ex_branch,
			mem_op_in => id_mem_op,
			mem_op_out => ex_mem_op,
			mem_size_in => id_mem_size,
			mem_size_out => ex_mem_size,
			count_instruction_in => id_count_instruction,
			count_instruction_out => ex_count_instruction,
			status_in => status,
			evec_in => evec,
			evec_out => exception_target,
			decode_exception_in => id_exception,
			decode_exception_cause_in => id_exception_cause,
			exception_out => exception_taken,
			exception_context_out => ex_exception_context,
			jump_out => branch_taken,
			jump_target_out => branch_target,
			mem_rd_write => mem_rd_write,
			mem_rd_addr => mem_rd_address,
			mem_rd_value => mem_rd_data,
			mem_csr_addr => mem_csr_address,
			mem_csr_value => mem_csr_data,
			mem_csr_write => mem_csr_write,
			mem_exception => mem_exception,
			mem_exception_context => mem_exception_context,
			wb_rd_write => wb_rd_write,
			wb_rd_addr => wb_rd_address,
			wb_rd_value => wb_rd_data,
			wb_csr_addr => wb_csr_address,
			wb_csr_value => wb_csr_data,
			wb_csr_write => wb_csr_write,
			wb_exception => wb_exception,
			wb_exception_context => wb_exception_context,
			mem_mem_op => mem_mem_op,
			hazard_detected => load_hazard_detected
		);

	dmem_address <= ex_dmem_address when stall_mem = '0' else dmem_address_p;
	dmem_data_size <= ex_dmem_data_size when stall_mem = '0' else dmem_data_size_p;
	dmem_data_out <= ex_dmem_data_out when stall_mem = '0' else dmem_data_out_p;
	dmem_read_req <= ex_dmem_read_req when stall_mem = '0' else dmem_read_req_p;
	dmem_write_req <= ex_dmem_write_req when stall_mem = '0' else dmem_write_req_p;

	store_previous_dmem_address: process(clk, stall_mem)
	begin
		if rising_edge(clk) and stall_mem = '0' then
			dmem_address_p <= ex_dmem_address;
			dmem_data_size_p <= ex_dmem_data_size;
			dmem_data_out_p <= ex_dmem_data_out;
			dmem_read_req_p <= ex_dmem_read_req;
			dmem_write_req_p <= ex_dmem_write_req;
		end if;
	end process store_previous_dmem_address;

	------- Memory (MEM) Stage -------
	memory: entity work.pp_memory
		port map(
			clk => clk,
			reset => reset,
			stall => stall_mem,
			dmem_data_in => dmem_data_in,
			dmem_read_ack => dmem_read_ack,
			dmem_write_ack => dmem_write_ack,
			pc => ex_pc,
			rd_write_in => ex_rd_write,
			rd_write_out => mem_rd_write,
			rd_data_in => ex_rd_data,
			rd_data_out => mem_rd_data,
			rd_addr_in => ex_rd_address,
			rd_addr_out => mem_rd_address,
			branch => ex_branch,
			mem_op_in => ex_mem_op,
			mem_op_out => mem_mem_op,
			mem_size_in => ex_mem_size,
			count_instr_in => ex_count_instruction,
			count_instr_out => mem_count_instruction,
			exception_in => exception_taken,
			exception_out => mem_exception, 
			exception_context_in => ex_exception_context,
			exception_context_out => mem_exception_context,
			csr_addr_in => ex_csr_address,
			csr_addr_out => mem_csr_address,
			csr_write_in => ex_csr_write,
			csr_write_out => mem_csr_write,
			csr_data_in => ex_csr_data,
			csr_data_out => mem_csr_data
		);

	------- Writeback (WB) Stage -------
	writeback: entity work.pp_writeback
		port map(
			clk => clk,
			reset => reset,
			count_instr_in => mem_count_instruction,
			count_instr_out => wb_count_instruction,
			exception_ctx_in => mem_exception_context,
			exception_ctx_out => wb_exception_context,
			exception_in => mem_exception,
			exception_out => wb_exception,
			csr_write_in => mem_csr_write,
			csr_write_out => wb_csr_write,
			csr_data_in => mem_csr_data,
			csr_data_out => wb_csr_data,
			csr_addr_in => mem_csr_address,
			csr_addr_out => wb_csr_address,
			rd_addr_in => mem_rd_address,
			rd_addr_out => wb_rd_address,
			rd_write_in => mem_rd_write,
			rd_write_out => wb_rd_write,
			rd_data_in => mem_rd_data,
			rd_data_out => wb_rd_data
		);

end architecture behaviour;
 
