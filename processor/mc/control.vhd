library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;
use work.leval_package.all;

entity control is
	port (
		clk					: in std_logic;
		rst					: in std_logic;
		-- status register
		status_in			: in std_logic_vector(STATUS_REG_SIZE-1 downto 0);
		data_rdy				: in std_logic; -- data ready on data bus signal
		sync					: in std_logic; -- AVR ready signal
		-- instruction signals
		opcode				: in std_logic_vector(OPCODE_SIZE-1 downto 0);
		breakpoint			: in std_logic;
		debug_en				: in std_logic;
		break_mask			: in std_logic_vector(STATUS_REG_SIZE-1 downto 0);
		break_flags			: in std_logic_vector(STATUS_REG_SIZE-1 downto 0);
		indir_reg1			: in std_logic;
		indir_reg2			: in std_logic;
		-- scrath control signals
		write_reg_en		: out std_logic; -- enables writing of register file
		-- use address from indirect register-registers
		indir_reg1_sel		: out std_logic;
		indir_reg2_sel		: out std_logic;
		-- ALU
		alu_func				: out std_logic_vector(FUNCT_SIZE-1 downto 0);
		alu_op1_sel			: out std_logic; -- use r2 as first operand in ALU
		alu_op2_sel			: out std_logic; -- when high use immidiate as second argument
		-- status register control line
		status_reg_w_en	: out std_logic_vector(STATUS_REG_SIZE-1 downto 0);
		-- PC control
		pc_write_en			: out std_logic; -- increment program counter
		branch_taken		: out std_logic; -- take branch
		-- memory control signals
		write					: out std_logic; -- write-signal
		read					: out std_logic; -- read-signal
		-- datapaths
		mem_to_reg_sel		: out std_logic; -- use databus instead of ALU result
		write_indir_addr_wr_en : out std_logic; -- udpate registers with indirect addresses
		state_out			: out std_logic_vector(3 downto 0)); -- DEBUG SIGNAL
end entity;

architecture rtl of control is
	-- States
	type state_type is (st0_init,st1_fetch,st2_regfetch,st3_load_indir_regs,st4_load_indir_data,
		st5_execute,st6_wait_data,st7_wait_done,st8_io_done,st9_halt);
	signal state : state_type := st0_init;
	signal jump : boolean;
	signal stored : boolean := true; -- this is used only on LOAD operations to know if we
												-- wrote result into register. So we can use the same
												-- register for address and result
begin

	-- DECODE AND OUTPUT
	OUTPUT_DECODE: process (state,opcode,indir_reg1,indir_reg2,jump,stored,data_rdy)
	begin
		-- default values
		write_reg_en		<= '0'; -- disable register writing
		mem_to_reg_sel		<= '0'; -- use ALU's result
		alu_op1_sel		<= '0'; -- don't write result
		indir_reg1_sel		<= '0'; -- don't use indir-regs default
		indir_reg2_sel		<= '0';
		alu_func				<= (others => '0');
		alu_op2_sel			<= '0'; -- don't use immidiate default
		status_reg_w_en	<= (others => '0'); -- don't write status register
		branch_taken		<= '0'; -- don't branch
		write			<= '0';
		read				<= '0';
		pc_write_en			<= '0'; -- don't change PC
		write_indir_addr_wr_en <= '0';
		stored <= stored;
		
		case	(state)	is
			when st0_init =>
				state_out <= X"0";
				
			when st1_fetch =>
				state_out <= X"1";
				
			when st2_regfetch =>
				-- do nothing, we're waiting for the registers to load
				state_out <= X"2";
				
			when st3_load_indir_regs =>
				-- load the indirection registers with the current register-out values
				state_out <= X"3";
				write_indir_addr_wr_en <= '1';
				 -- load indirect value
				if indir_reg1 = '1' then
					indir_reg1_sel <= '1';
				end if;
				if indir_reg2 = '1' then
					indir_reg2_sel <= '1';
				end if;
				
			when st4_load_indir_data =>
				-- do nothing
				state_out <= X"4";
				if indir_reg1 = '1' then
					indir_reg1_sel	<=	'1';
				end if;
				if	indir_reg2 = '1' then
					indir_reg2_sel	<=	'1';
				end if;
				
			when st5_execute =>
				-- main execution state, sets signals according to input and state
				state_out <= X"5";
				status_reg_w_en <= (others => '1'); -- update status register on each operation
				
				-- if we have load or store, we should wait with updating of PC
				if (opcode = LOAD or opcode = STORE) then
					pc_write_en <= '0';
				else
					pc_write_en <= '1';
				end if;
				
				-- indirect addressing
				if indir_reg1 = '1' then
					indir_reg1_sel <= '1';
				end if;
				if indir_reg2 = '1' then
					indir_reg2_sel <= '1';
				end if;
				
				case opcode is
					-- Arithmetical / Logic functions
					when ADD =>
						alu_func <= ALU_ADD;
						write_reg_en <= '1';
						
					when SUBB =>
						alu_func <= ALU_SUB;
						write_reg_en <= '1';
						
					when MUL =>
						alu_func <= ALU_MUL;
						write_reg_en <= '1';
						
--					-- NOT IMPLEMENTED
--					when DIV =>
--						alu_func <= ALU_DIV;
--						write_reg_en <= '1';
--					when MODULO =>
--						alu_func <= ALU_MOD;
--						write_reg_en <= '1';
						
					when LAND =>
						alu_func <= ALU_AND;
						write_reg_en <= '1';
						
					when LOR =>
						alu_func <= ALU_OR;
						write_reg_en <= '1';
						
					when LXOR =>
						alu_func <= ALU_XOR;
						write_reg_en <= '1';
						
					when LOAD =>
						mem_to_reg_sel <= '1'; -- use data bus
						alu_func <= ALU_ADD;
						alu_op2_sel <= '1';
						alu_op1_sel <= '1';
						stored <= false;
						
					when STORE =>
						alu_func <= ALU_ADD;
						alu_op2_sel <= '1';
						alu_op1_sel <= '1';
						stored <= true;
						
					when BIDX =>
						if jump then
							alu_func <= ALU_ADD;
							branch_taken <= '1';
							alu_op2_sel <= '1';
						end if;
						
					when GET_TYPE =>
						alu_func <= ALU_GET_TYPE;
						write_reg_en <= '1';
						
					when SET_TYPE =>
						alu_func <= ALU_SET_TYPE;
						write_reg_en <= '1';
						
					when SET_TYPE_IMM	=>
						alu_func <= ALU_SET_TYPE;
						write_reg_en <= '1';
						alu_op2_sel <= '1';
						
					when SET_DATUM =>
						alu_func <= ALU_SET_DATUM;
						write_reg_en <= '1';
						
					when SET_DATUM_IMM =>
						alu_func <= ALU_SET_DATUM;
						write_reg_en <= '1';
						alu_op2_sel <= '1';
						
					when SET_GC =>
						alu_func <= ALU_SET_GC;
						write_reg_en <= '1';
						
					when SET_GC_IMM =>
						alu_func <= ALU_SET_GC;
						write_reg_en <= '1';
						alu_op2_sel <= '1';
						
					when CPY =>
						alu_func <= ALU_CPY;
						write_reg_en <= '1';
						
					when CMP_TYPE =>
						alu_func <= ALU_CMP_TYPE;
						
					when CMP_TYPE_IMM =>
						alu_func <= ALU_CMP_TYPE_IMM;
						alu_op2_sel <= '1';
						
					when CMP_DATUM =>
						alu_func <= ALU_CMP_DATUM;
						
					when CMP_DATUM_IMM =>
						alu_func <= ALU_CMP_DATUM;
						alu_op2_sel <= '1';
						
					when CMP_GC =>
						alu_func <= ALU_CMP_GC;
						
					when CMP_GC_IMM =>
						alu_func <= ALU_CMP_GC_IMM;
						alu_op2_sel <= '1';
						
					when CMP =>
						alu_func <= ALU_CMP;
						
					when SHIFT_L =>
						alu_func <= ALU_SL;
						write_reg_en <= '1';
						
					when SHIFT_R =>
						alu_func <= ALU_SR;
						write_reg_en <= '1';
						
					when SETLED =>
						alu_func <= ALU_SETLED;
						
					when others =>
						-- unknown opcode, do nothing
						alu_func <= ALU_PASS;
					end case;
					
			when st6_wait_data =>
				-- HOLD load or store signals
				state_out <= X"6";
				if indir_reg1 = '1' then
					indir_reg1_sel <= '1';
				end if;
				if indir_reg2 = '1' then 
					indir_reg2_sel <= '1'; 
				end if;
				
				alu_op2_sel <= '1'; -- use immediate value
				alu_func <= ALU_ADD;  --calculate load/store address
				alu_op1_sel <= '1'; -- use R2 with immidiate in ALU
				
				if (opcode = LOAD) then
					mem_to_reg_sel <= '1'; -- load data from bus
					read <= '1'; -- set read control signal
					if data_rdy = '0' and stored = false then -- if data is not stored, but ready on the bus
						write_reg_en <= '1'; -- enable writing of the register
						stored <= true; -- remember that we stored data
					end if;
				else -- means STORE
					stored <= true; -- we don't need to write anything in register memory
					write <= '1'; -- set write control signal
				end if;
				
			when st7_wait_done =>
				-- remove read/write signal and wait till distanation unit clears ready control line
				state_out <= X"7";
				-- hold address values just to be sure
				if indir_reg1 = '1' then
					indir_reg1_sel <= '1';
				end if;
				if indir_reg2 = '1' then
					indir_reg2_sel <= '1';
				end if;
				alu_op2_sel <= '1';
				alu_func <= ALU_ADD;
				alu_op1_sel <= '1';
				
			when st8_io_done =>
				-- one cycle to update PC
				state_out <= X"8";
				pc_write_en <= '1';
				
			when st9_halt =>
				-- HALT state (we can't get out of here unless reset)
				state_out <= X"9";
				
			when others =>
				-- unknown state
				state_out <= X"F";
		end case;
		
	end process;
		
	-- NEXT STATE FUNCTION
	NEXT_STATE_DECODE: process(clk)
	begin
	if rising_edge(clk) then
		if rst = '1' then
			state <= st0_init;
		end if;
		case (state) is
			when st0_init =>
				if sync = '1' then
					state <= st1_fetch;
				end if;
			when st1_fetch =>
				state <= st2_regfetch;
				
			when st2_regfetch =>
				if indir_reg1 = '1' or indir_reg2 = '1' then
					-- if we need to load indirect registers
					state <= st3_load_indir_regs;
				else
					state <= st5_execute;
				end if;
				
			when st3_load_indir_regs =>
				state <= st4_load_indir_data;
				
			when st4_load_indir_data =>
				state <= st5_execute;
				
			when st5_execute =>
				-- HALT conditions
				if breakpoint = '1' or debug_en = '1' or opcode = HALT then
					state <= st9_halt;
				-- LOAD/STORE
				elsif opcode=LOAD or opcode = STORE then
					state <= st6_wait_data;
				-- otherwise go to fetch next instruction
				else
					state <= st1_fetch;
				end if;
			when st6_wait_data =>
				if data_rdy = '0' and stored = true then
					state <= st7_wait_done;
				end if;
				
			when st7_wait_done =>
				if data_rdy = '1' then
					state <= st8_io_done;
				end if;
				
			when st8_io_done =>
					state <= st1_fetch;
					
			when st9_halt =>
				-- We halt, program is over.
		end case;
	end if;
	end process;
	
	update_branch_evaluator : process(clk)
	begin
		if rising_edge(clk) then
			-- compare status register with branch flags, filtered by branch mask
			if (status_in and break_mask) = (break_flags and break_mask) then
				jump <= true;
			else 
				jump <= false;
			end if;
		end if;
	end process;
end rtl;
