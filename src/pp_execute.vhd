-- The Potato Processor - A simple processor for FPGAs
-- (c) Kristian Klomsten Skordal 2014 - 2015 <kristian.skordal@wafflemail.net>
-- Report bugs and issues on <http://opencores.org/project,potato,bugtracker>

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pp_types.all;
use work.pp_csr.all;
use work.pp_utilities.all;

entity pp_execute is
	port(
		clk    : in std_logic;
		reset  : in std_logic;

		stall, flush : in std_logic;

		-- IRQ input:
		irq : in std_logic_vector(7 downto 0);

		-- Data memory outputs:
		dmem_address   : out std_logic_vector(31 downto 0);
		dmem_data_out  : out std_logic_vector(31 downto 0);
		dmem_data_size : out std_logic_vector( 1 downto 0);
		dmem_read_req  : out std_logic;
		dmem_write_req : out std_logic;

		-- Register addresses:
		rs1_addr_in, rs2_addr_in, rd_addr_in : in  register_address;
		rd_addr_out                          : out register_address;

		-- Register values:
		rs1_data_in, rs2_data_in : in std_logic_vector(31 downto 0);
		rd_data_out              : out std_logic_vector(31 downto 0);

		-- Constant values:
		shamt_in     : in std_logic_vector(4 downto 0);
		immediate_in : in std_logic_vector(31 downto 0);

		-- Instruction address:
		pc_in     : in  std_logic_vector(31 downto 0);
		pc_out    : out std_logic_vector(31 downto 0);

		-- Funct3 value from the instruction, used to choose which comparison
		-- is used when branching:
		funct3_in : in std_logic_vector(2 downto 0);

		-- CSR signals:
		csr_addr_in          : in  csr_address;
		csr_addr_out         : out csr_address;
		csr_write_in         : in  csr_write_mode;
		csr_write_out        : out csr_write_mode;
		csr_value_in         : in  std_logic_vector(31 downto 0);
		csr_value_out        : out std_logic_vector(31 downto 0);
		csr_writeable_in     : in  boolean;
		csr_use_immediate_in : in  std_logic; 

		-- Control signals:
		alu_op_in    : in  alu_operation;
		alu_x_src_in : in  alu_operand_source;
		alu_y_src_in : in  alu_operand_source;
		rd_write_in  : in  std_logic;
		rd_write_out : out std_logic;
		branch_in    : in  branch_type;
		branch_out   : out branch_type;

		-- Memory control signals:
		mem_op_in    : in  memory_operation_type;
		mem_op_out   : out memory_operation_type;
		mem_size_in  : in  memory_operation_size;
		mem_size_out : out memory_operation_size;

		-- Whether the instruction should be counted:
		count_instruction_in  : in  std_logic;
		count_instruction_out : out std_logic;

		-- Exception control registers:
		status_in : in  csr_status_register;
		evec_in   : in  std_logic_vector(31 downto 0);
		evec_out  : out std_logic_vector(31 downto 0);

		-- Exception signals:
		decode_exception_in       : in std_logic;
		decode_exception_cause_in : in csr_exception_cause;

		-- Exception outputs:
		exception_out         : out std_logic;
		exception_context_out : out csr_exception_context;

		-- Control outputs:
		jump_out        : out std_logic;
		jump_target_out : out std_logic_vector(31 downto 0);

		-- Inputs to the forwarding logic from the MEM stage:
		mem_rd_write          : in std_logic;
		mem_rd_addr           : in register_address;
		mem_rd_value          : in std_logic_vector(31 downto 0);
		mem_csr_addr          : in csr_address;
		mem_csr_write         : in csr_write_mode;
		mem_csr_value         : in std_logic_vector(31 downto 0);
		mem_exception         : in std_logic;
		mem_exception_context : in csr_exception_context;

		-- Inputs to the forwarding logic from the WB stage:
		wb_rd_write          : in std_logic;
		wb_rd_addr           : in register_address;
		wb_rd_value          : in std_logic_vector(31 downto 0);
		wb_csr_addr          : in csr_address;
		wb_csr_write         : in csr_write_mode;
		wb_csr_value         : in std_logic_vector(31 downto 0);
		wb_exception         : in std_logic;
		wb_exception_context : in csr_exception_context;

		-- Hazard detection unit signals:
		mem_mem_op : in memory_operation_type;
		hazard_detected : out std_logic
	);
end entity pp_execute;

architecture behaviour of pp_execute is 
	signal alu_op : alu_operation;
	signal alu_x_src, alu_y_src : alu_operand_source;

	signal alu_x, alu_y, alu_result : std_logic_vector(31 downto 0);

	signal rs1_addr, rs2_addr : register_address;
	signal rs1_data, rs2_data : std_logic_vector(31 downto 0);

	signal mem_op : memory_operation_type;
	signal mem_size : memory_operation_size;

	signal pc        : std_logic_vector(31 downto 0);
	signal immediate : std_logic_vector(31 downto 0);
	signal shamt     : std_logic_vector( 4 downto 0);
	signal funct3    : std_logic_vector( 2 downto 0);

	signal rs1_forwarded, rs2_forwarded : std_logic_vector(31 downto 0);

	signal branch : branch_type;
	signal branch_condition : std_logic;
	signal do_jump : std_logic;
	signal jump_target : std_logic_vector(31 downto 0);

	signal sr : csr_status_register;
	signal evec, evec_forwarded : std_logic_vector(31 downto 0);

	signal csr_write : csr_write_mode;
	signal csr_addr  : csr_address;
	signal csr_use_immediate : std_logic;
	signal csr_writeable : boolean;

	signal csr_value, csr_value_forwarded : std_logic_vector(31 downto 0);
	
	signal decode_exception : std_logic;
	signal decode_exception_cause : csr_exception_cause;

	signal exception_taken : std_logic;
	signal exception_cause : csr_exception_cause;
	signal exception_vaddr : std_logic_vector(31 downto 0);

	signal exception_context_forwarded : csr_exception_context;

	signal data_misaligned, instr_misaligned : std_logic;

	signal irq_asserted : std_logic;
	signal irq_asserted_num : std_logic_vector(3 downto 0);
begin

	-- Register values should not be latched in by a clocked process,
	-- this is already done in the register files.
	csr_value <= csr_value_in;
	rd_data_out <= alu_result;

	branch_out <= branch;

	mem_op_out <= mem_op;
	mem_size_out <= mem_size;

	csr_write_out <= csr_write;
	csr_addr_out  <= csr_addr;

	pc_out <= pc;

	exception_out <= exception_taken;
	exception_context_out <= (
				status => exception_context_forwarded.status,
				cause => exception_cause,
				badvaddr => exception_vaddr
			) when exception_taken = '1' else exception_context_forwarded;

	do_jump <= (to_std_logic(branch = BRANCH_JUMP or branch = BRANCH_JUMP_INDIRECT)
		or (to_std_logic(branch = BRANCH_CONDITIONAL) and branch_condition)
		or to_std_logic(branch = BRANCH_SRET)) and not stall;
	jump_out <= do_jump;
	jump_target_out <= jump_target;

	evec_out <= evec_forwarded;
	exception_taken <= (decode_exception or to_std_logic(exception_cause /= CSR_CAUSE_NONE) or irq_asserted) and not stall; 

	irq_asserted <= to_std_logic(exception_context_forwarded.status.ei = '1' and
		(irq and exception_context_forwarded.status.im) /= x"00");

	rs1_data <= rs1_data_in;
	rs2_data <= rs2_data_in;

	dmem_address <= alu_result;
	dmem_data_out <= rs2_forwarded;
	dmem_write_req <= '1' when mem_op = MEMOP_TYPE_STORE else '0';
	dmem_read_req <= '1' when memop_is_load(mem_op) else '0';

	pipeline_register: process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' or flush = '1' then
				rd_write_out <= '0';
				branch <= BRANCH_NONE;
				csr_write <= CSR_WRITE_NONE;
				mem_op <= MEMOP_TYPE_NONE;
				decode_exception <= '0';
				count_instruction_out <= '0';
			elsif stall = '0' then
				pc <= pc_in;
				count_instruction_out <= count_instruction_in;

				-- Register signals:
				rd_write_out <= rd_write_in;
				rd_addr_out <= rd_addr_in;
				rs1_addr <= rs1_addr_in;
				rs2_addr <= rs2_addr_in;

				-- ALU signals:
				alu_op <= alu_op_in;
				alu_x_src <= alu_x_src_in;
				alu_y_src <= alu_y_src_in;

				-- Control signals:
				branch <= branch_in;
				mem_op <= mem_op_in;
				mem_size <= mem_size_in;

				-- Constant values:
				immediate <= immediate_in;
				shamt <= shamt_in;
				funct3 <= funct3_in;

				-- CSR signals:
				csr_write <= csr_write_in;
				csr_addr <= csr_addr_in;
				csr_use_immediate <= csr_use_immediate_in;
				csr_writeable <= csr_writeable_in;

				-- Status register;
				sr <= status_in;

				-- Exception vector base:
				evec <= evec_in;

				-- Instruction decoder exceptions:
				decode_exception <= decode_exception_in;
				decode_exception_cause <= decode_exception_cause_in;
			end if;
		end if;
	end process pipeline_register;

	set_data_size: process(mem_size)
	begin
		case mem_size is
			when MEMOP_SIZE_BYTE =>
				dmem_data_size <= b"01";
			when MEMOP_SIZE_HALFWORD =>
				dmem_data_size <= b"10";
			when MEMOP_SIZE_WORD =>
				dmem_data_size <= b"00";
			when others =>
				dmem_data_size <= b"11";
		end case;
	end process set_data_size;

	get_irq_num: process(irq, exception_context_forwarded)
		variable temp : std_logic_vector(3 downto 0);
	begin
		temp := (others => '0');

		for i in 0 to 7 loop
			if irq(i) = '1' and exception_context_forwarded.status.im(i) = '1' then
				temp := std_logic_vector(to_unsigned(i, temp'length));
				exit;
			end if;
		end loop;

		irq_asserted_num <= temp;
	end process get_irq_num;

	data_misalign_check: process(mem_size, alu_result)
	begin
		case mem_size is
			when MEMOP_SIZE_HALFWORD =>
				if alu_result(0) /= '0' then
					data_misaligned <= '1';
				else
					data_misaligned <= '0';
				end if;
			when MEMOP_SIZE_WORD =>
				if alu_result(1 downto 0) /= b"00" then
					data_misaligned <= '1';
				else
					data_misaligned <= '0';
				end if;
			when others =>
				data_misaligned <= '0';
		end case;
	end process data_misalign_check;

	instr_misalign_check: process(jump_target, branch, branch_condition, do_jump)
	begin
		if jump_target(1 downto 0) /= b"00" and do_jump = '1' then
			instr_misaligned <= '1';
		else
			instr_misaligned <= '0';
		end if;
	end process instr_misalign_check;

	find_exception_cause: process(decode_exception, decode_exception_cause, mem_op,
		data_misaligned, instr_misaligned, irq_asserted, irq_asserted_num)
	begin
		if irq_asserted = '1' then
			exception_cause <= std_logic_vector(unsigned(CSR_CAUSE_IRQ_BASE) + unsigned(irq_asserted_num));
		elsif decode_exception = '1' then
			exception_cause <= decode_exception_cause;
		elsif mem_op = MEMOP_TYPE_INVALID then
			exception_cause <= CSR_CAUSE_INVALID_INSTR;
		elsif instr_misaligned = '1' then
			exception_cause <= CSR_CAUSE_INSTR_MISALIGN;
		elsif data_misaligned = '1' and mem_op = MEMOP_TYPE_STORE then
			exception_cause <= CSR_CAUSE_STORE_MISALIGN;
		elsif data_misaligned = '1' and memop_is_load(mem_op) then
			exception_cause <= CSR_CAUSE_LOAD_MISALIGN;
		else
			exception_cause <= CSR_CAUSE_NONE;
		end if;
	end process find_exception_cause;

	find_exception_vaddr: process(instr_misaligned, data_misaligned, jump_target, alu_result)
	begin
		if instr_misaligned = '1' then
			exception_vaddr <= jump_target;
		elsif data_misaligned = '1' then
			exception_vaddr <= alu_result;
		else
			exception_vaddr <= (others => '0');
		end if;
	end process find_exception_vaddr;

	calc_jump_tgt: process(branch, pc, rs1_forwarded, immediate, csr_value_forwarded)
	begin
		case branch is
			when BRANCH_JUMP | BRANCH_CONDITIONAL =>
				jump_target <= std_logic_vector(unsigned(pc) + unsigned(immediate));
			when BRANCH_JUMP_INDIRECT =>
				jump_target <= std_logic_vector(unsigned(rs1_forwarded) + unsigned(immediate));
			when BRANCH_SRET =>
				jump_target <= csr_value_forwarded; -- Will be the EPC value in the case of SRET
			when others =>
				jump_target <= (others => '0');
		end case;
	end process calc_jump_tgt;

	alu_x_mux: entity work.pp_alu_mux
		port map(
			source => alu_x_src,
			register_value => rs1_forwarded,
			immediate_value => immediate,
			shamt_value => shamt,
			pc_value => pc,
			csr_value => csr_value_forwarded,
			output => alu_x
		);

	alu_y_mux: entity work.pp_alu_mux
		port map(
			source => alu_y_src,
			register_value => rs2_forwarded,
			immediate_value => immediate,
			shamt_value => shamt,
			pc_value => pc,
			csr_value => csr_value_forwarded,
			output => alu_y
		);

	alu_x_forward: process(mem_rd_write, mem_rd_value, mem_rd_addr, rs1_addr,
		rs1_data, wb_rd_write, wb_rd_addr, wb_rd_value)
	begin
		if mem_rd_write = '1' and mem_rd_addr = rs1_addr and mem_rd_addr /= b"00000" then
			rs1_forwarded <= mem_rd_value;
		elsif wb_rd_write = '1' and wb_rd_addr = rs1_addr and wb_rd_addr /= b"00000" then
			rs1_forwarded <= wb_rd_value;
		else
			rs1_forwarded <= rs1_data;
		end if;
	end process alu_x_forward;

	alu_y_forward: process(mem_rd_write, mem_rd_value, mem_rd_addr, rs2_addr,
		rs2_data, wb_rd_write, wb_rd_addr, wb_rd_value)
	begin
		if mem_rd_write = '1' and mem_rd_addr = rs2_addr and mem_rd_addr /= b"00000" then
			rs2_forwarded <= mem_rd_value;
		elsif wb_rd_write = '1' and wb_rd_addr = rs2_addr and wb_rd_addr /= b"00000" then
			rs2_forwarded <= wb_rd_value;
		else
			rs2_forwarded <= rs2_data;
		end if;
	end process alu_y_forward;

	csr_forward: process(mem_csr_write, wb_csr_write, csr_addr, mem_csr_addr, wb_csr_addr,
		csr_value, mem_csr_value, wb_csr_value, csr_writeable, mem_exception, wb_exception,
		mem_exception_context, wb_exception_context)
	begin
		if csr_addr = CSR_CAUSE and mem_exception = '1' then
			csr_value_forwarded <= to_std_logic_vector(mem_exception_context.cause);
		elsif csr_addr = CSR_STATUS and mem_exception = '1' then
			csr_value_forwarded <= to_std_logic_vector(mem_exception_context.status);
		elsif csr_addr = CSR_BADVADDR and mem_exception = '1' then
			csr_value_forwarded <= mem_exception_context.badvaddr;
		elsif mem_csr_write /= CSR_WRITE_NONE and mem_csr_addr = csr_addr and csr_writeable then
			csr_value_forwarded <= mem_csr_value;
		elsif csr_addr = CSR_CAUSE and wb_exception = '1' then
			csr_value_forwarded <= to_std_logic_vector(wb_exception_context.cause);
		elsif csr_addr = CSR_STATUS and wb_exception = '1' then
			csr_value_forwarded <= to_std_logic_vector(wb_exception_context.status);
		elsif csr_addr = CSR_BADVADDR and wb_exception = '1' then
			csr_value_forwarded <= wb_exception_context.badvaddr;
		elsif wb_csr_write /= CSR_WRITE_NONE and wb_csr_addr = csr_addr and csr_writeable then
			csr_value_forwarded <= wb_csr_value;
		else
			csr_value_forwarded <= csr_value;
		end if;
	end process csr_forward;

	evec_forward: process(mem_csr_write, mem_csr_addr, mem_csr_value,
		wb_csr_write, wb_csr_addr, wb_csr_value, evec)
	begin
		if mem_csr_write /= CSR_WRITE_NONE and mem_csr_addr = CSR_EVEC then
			evec_forwarded <= mem_csr_value;
		elsif wb_csr_write /= CSR_WRITE_NONE and wb_csr_addr = CSR_EVEC then
			evec_forwarded <= wb_csr_value;
		else
			evec_forwarded <= evec;
		end if;
	end process evec_forward;

	exception_ctx_forward: process(mem_exception, wb_exception, mem_exception_context, wb_exception_context,
		exception_cause, exception_vaddr, mem_csr_write, mem_csr_addr, mem_csr_value,
		wb_csr_write, wb_csr_addr, wb_csr_value, sr)
	begin
		if mem_exception = '1' then
			exception_context_forwarded <= mem_exception_context;
		elsif mem_csr_write /= CSR_WRITE_NONE and mem_csr_addr = CSR_STATUS then
			exception_context_forwarded <= (
				status => to_csr_status_register(mem_csr_value),
				cause => mem_exception_context.cause,
				badvaddr => mem_exception_context.badvaddr);
		elsif wb_exception = '1' then
			exception_context_forwarded <= wb_exception_context;
		elsif wb_csr_write /= CSR_WRITE_NONE and wb_csr_addr = CSR_STATUS then
			exception_context_forwarded <= (
				status => to_csr_status_register(wb_csr_value),
				cause => wb_exception_context.cause,
				badvaddr => wb_exception_context.badvaddr);
		else
			exception_context_forwarded.status <= sr;
			exception_context_forwarded.cause <= exception_cause;
			exception_context_forwarded.badvaddr <= exception_vaddr;
		end if;
	end process exception_ctx_forward;

	detect_load_hazard: process(mem_mem_op, mem_rd_addr, rs1_addr, rs2_addr,
		alu_x_src, alu_y_src)
	begin
		if (mem_mem_op = MEMOP_TYPE_LOAD or mem_mem_op = MEMOP_TYPE_LOAD_UNSIGNED) and
				((alu_x_src = ALU_SRC_REG and mem_rd_addr = rs1_addr and rs1_addr /= b"00000")
			or
				(alu_y_src = ALU_SRC_REG and mem_rd_addr = rs2_addr and rs2_addr /= b"00000"))
		then
			hazard_detected <= '1';
		else
			hazard_detected <= '0';
		end if;
	end process detect_load_hazard;

	branch_comparator: entity work.pp_comparator
		port map(
			funct3 => funct3,
			rs1 => rs1_forwarded,
			rs2 => rs2_forwarded,
			result => branch_condition
		);

	alu_instance: entity work.pp_alu
		port map(
			result => alu_result,
			x => alu_x,
			y => alu_y,
			operation => alu_op
		);

	csr_alu_instance: entity work.pp_csr_alu
		port map(
			x => csr_value_forwarded,
			y => rs1_forwarded,
			result => csr_value_out,
			immediate => rs1_addr,
			use_immediate => csr_use_immediate,
			write_mode => csr_write
		);


end architecture behaviour;
