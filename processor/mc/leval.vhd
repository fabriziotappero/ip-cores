library ieee;
use ieee.std_logic_1164.all;
use work.leval_package.all;

entity leval is
	port(
		rst		: in std_logic; -- convert to synchronous
		clk		: in std_logic;
		data_in	: in std_logic_vector(BUS_SIZE - 1 downto 0);
		data_out	: out std_logic_vector(BUS_SIZE - 1 downto 0);
		addr_bus	: out std_logic_vector(ADDR_SIZE-1 downto 0);
		wait_s	: in std_logic;
		sync		: in std_logic;
		read		: out std_logic;
		write		: out std_logic;
		led		: out std_logic_vector(7 downto 0));
--		pc_out : out std_logic_vector(MC_ADDR_SIZE-1 downto 0);
--		state_out : out std_logic_vector(3 downto 0);
--		status_out : out std_logic_vector(STATUS_REG_SIZE-1 downto 0);
--		pc_write_out : out std_logic);
end entity;

architecture rtl of leval is	 
	component pc_incer is
	port(
		clk		: in std_logic;
		rst		: in std_logic;
		pause		: in std_logic;
		offset	: in std_logic_vector(MC_ADDR_SIZE - 1 downto 0);
		branch	: in std_logic;
		pc_next	: out std_logic_vector(MC_ADDR_SIZE - 1 downto 0) );
	end component pc_incer;
	
	component inst_mem is
	port (
		clk	: in std_logic;
		addr	: in std_logic_vector(MC_ADDR_SIZE - 1 downto 0);
		dout	: out std_logic_vector(MC_INSTR_SIZE - 1 downto 0);
		din	: in std_logic_vector(MC_INSTR_SIZE - 1 downto 0);
		we		: in std_logic);
	end component inst_mem;

	component alu is
	port (
		in_a		: in std_logic_vector(OBJECT_SIZE-1 downto 0);
		in_b		: in std_logic_vector(OBJECT_SIZE-1 downto 0);
		funct		: in std_logic_vector(FUNCT_SIZE-1 downto 0);
		status	: out std_logic_vector(STATUS_REG_SIZE-1 downto 0);
		output	: out std_logic_vector(OBJECT_SIZE-1 downto 0));
	end component alu;

	component reg_mem is
	port (
		clk	: in std_logic;
		we		: in std_logic;
		a		: in std_logic_vector(SCRATCH_ADDR_SIZE - 1 downto 0);
		b		: in std_logic_vector(SCRATCH_ADDR_SIZE - 1 downto 0);
		dia	: in std_logic_vector(WORD_SIZE - 1 downto 0);
		doa	: out std_logic_vector(WORD_SIZE - 1 downto 0);
		dob	: out  std_logic_vector(WORD_SIZE - 1 downto 0));
	end component reg_mem;

	component control	is	
	port(
		clk				: in std_logic;
		rst				: in std_logic;
		status_in		: in std_logic_vector(STATUS_REG_SIZE - 1 downto 0);
		data_rdy			: in std_logic;
		sync				: in std_logic;
		opcode			: in std_logic_vector(OPCODE_SIZE - 1 downto 0);
		breakpoint		: in std_logic;
		debug_en			: in std_logic;
		break_mask		: in std_logic_vector(STATUS_REG_SIZE - 1 downto 0);
		break_flags		: in std_logic_vector(STATUS_REG_SIZE - 1 downto 0);
		indir_reg1		: in std_logic;
		indir_reg2		: in std_logic;
		write_reg_en	: out std_logic;
		indir_reg1_sel	: out std_logic;
		indir_reg2_sel	: out std_logic;
		alu_func			: out std_logic_vector(FUNCT_SIZE-1	downto	0);
		alu_op1_sel		: out std_logic;
		alu_op2_sel			: out std_logic;
		status_reg_w_en	: out std_logic_vector(STATUS_REG_SIZE-1 downto 0);	
		pc_write_en			:	out	std_logic;
		branch_taken		:	out	std_logic;
		write					:	out	std_logic;
		read					:	out	std_logic;
		mem_to_reg_sel		:	out	std_logic;
		write_indir_addr_wr_en : out std_logic);
--		state_out : out std_logic_vector(3 downto 0));
	end component control;

	signal instr : std_logic_vector(MC_INSTR_SIZE-1 downto 0);
	signal pc_write_en : std_logic;
	 
	-- Skratch memory input lines
	signal r1_addr : std_logic_vector(SCRATCH_ADDR_SIZE-1 downto 0);
	signal r2_addr : std_logic_vector(SCRATCH_ADDR_SIZE-1 downto 0);
	signal scratch_we : std_logic; -- Enable register writing
	signal wr_value : std_logic_vector(WORD_SIZE-1 downto 0);

	-- from SCRATCH
	signal r1_value : std_logic_vector(WORD_SIZE-1 downto 0);
	signal r2_value : std_logic_vector(WORD_SIZE-1 downto 0);
	-- to ALU
	signal alu_func : std_logic_vector(FUNCT_SIZE-1 downto 0);
	signal alu_op1_val : std_logic_vector(WORD_SIZE-1 downto 0);
	signal alu_op2_val : std_logic_vector(WORD_SIZE-1 downto 0);
	-- from ALU
	signal alu_status : std_logic_vector(STATUS_REG_SIZE-1 downto 0);
	signal alu_out : std_logic_vector(WORD_SIZE-1 downto 0);
	-- to CONTROL
	-- from CONTROL
	signal alu_op2_sel : std_logic;
	signal branch : std_logic;
	signal SRWriteEnable : std_logic_vector(STATUS_REG_SIZE-1 downto 0);
	signal r1_in_mux, r2_in_mux : std_logic;
	signal write_s, read_s : std_logic;
	signal mem_to_reg : std_logic;

	-- instruction
	signal opcode : std_logic_vector(OPCODE_SIZE-1 downto 0);
	signal db_enable, b_point : std_logic;
	signal imm		: std_logic_vector(WORD_SIZE-1 downto 0);
	signal r1_indir, r2_indir : std_logic; -- Indirection bits (set if indirect)
	signal bmask_s, bflags_s : std_logic_vector(7 downto 0);
	signal inst_r1_addr	 : std_logic_vector(SCRATCH_ADDR_SIZE-1 downto 0);--Reg1 addr
	signal inst_r2_addr	 : std_logic_vector(SCRATCH_ADDR_SIZE-1 downto 0);--Reg2 addr

	-- registers
	signal pc : std_logic_vector(MC_ADDR_SIZE-1 downto 0) := (others => '0');
	signal reg1		: std_logic_vector(SCRATCH_ADDR_SIZE-1 downto 0) := (others => '0');
	signal reg2		: std_logic_vector(SCRATCH_ADDR_SIZE-1 downto 0) := (others => '0');
	signal status : std_logic_vector(STATUS_REG_SIZE-1 downto 0) := (others => '0');
	 
	signal alu_op1_sel : std_logic;
	signal write_indir_addr_wr_en : std_logic;
begin
--  -- DEBUG signals
--	status_out <= status;
--	pc_out <= pc;
--	pc_write_out <= pc_write_en;
	led <= pc(7 downto 0);
	
	-- map memory control signals outside
	write <= write_s;
	read <= read_s;

	-- MUX for ALU immidiate/r2 value
	alu_op1_val <= r2_value when alu_op1_sel = '1' else r1_value;
	alu_op2_val <= imm when alu_op2_sel = '1' else r2_value;
	
	-- MUXes for SCRATCH addresses, select either instruction
	-- 's addreses or, if we're indirect, the indirect-regs
	r1_addr <= reg1 when r1_in_mux = '1' else inst_r1_addr;
	r2_addr <= reg2 when r2_in_mux = '1' else inst_r2_addr;
	
	-- set data out
	data_out <= r1_value;
	
	-- MUX for result
	wr_value <= data_in when mem_to_reg = '1' else alu_out;
	
	--	Address bus
	addr_bus	<= alu_out(ADDR_SIZE-1 downto 0);
	
	-- Split fetched instruction into sub-signals
	opcode <= instr(47 downto 42); --opcode
	db_enable <= instr(41); -- debug bit
	b_point <= instr(40); -- break point bit
	r1_indir <= instr(39); -- reg1 indirection bit
	inst_r1_addr <= instr(38 downto 29); --reg1 address
	r2_indir <= instr(28); -- reg2 indir bit
	inst_r2_addr <= instr(27 downto 18); --reg2 address
	imm <= "000000" & sign_extend_18_26(instr(17 downto 0));
  -- Branch instruction signals (branch mask and branch flags)
	bflags_s <= instr(20 downto 13);
	bmask_s <= instr(28 downto 21);
	
	scrmem : reg_mem
	port map (
	  clk => clk,
	  we => scratch_we,
	  a => r1_addr,
	  b => r2_addr,
	  dia => wr_value,
	  doa => r1_value,
	  dob => r2_value);
	
	alu_inst : alu
	port map (
		in_a => alu_op1_val,
		in_b => alu_op2_val,
		funct => alu_func,
		status => alu_status,
		output => alu_out);

	instrmem : inst_mem
	port map (
		clk => clk,
		addr => pc,
		dout => instr,
		din => "000000000000000000000000000000000000000000000000",
		we => '0');

	pc_incer_inst : pc_incer
	port map (
		clk => clk,
		rst => rst,
		pause => pc_write_en,
		offset => alu_out(MC_ADDR_SIZE-1 downto 0),
		branch => branch,
		pc_next => pc);
		
	control_unit : control
	port map (
    clk => clk,
	  rst => rst,
	  sync => sync,
	  status_in => status,
	  data_rdy=> wait_s,
	  opcode => opcode, 
	  breakpoint=> b_point,
	  debug_en=> db_enable, 
	  break_mask=> bmask_s,
	  break_flags=> bflags_s,
	  indir_reg1=> r1_indir,
	  indir_reg2=> r2_indir,
	  write_reg_en=> scratch_we,
	  alu_op1_sel => alu_op1_sel,
	  indir_reg1_sel =>	r1_in_mux,
	  indir_reg2_sel =>	r2_in_mux,
	  alu_func=> alu_func,
	  alu_op2_sel=> alu_op2_sel,
	  status_reg_w_en=> SRWriteEnable, 
	  pc_write_en => pc_write_en,
	  branch_taken => branch, 
	  write => write_s,
	  read => read_s,
	  mem_to_reg_sel => mem_to_reg,
	  write_indir_addr_wr_en => write_indir_addr_wr_en);
--	  state_out => state_out);

	-- update registers on rising clock edge
	update_regs : process(clk, rst)	
	begin
		if rising_edge(clk) then
			-- update status register with status from alu masked by SRWriteEnable
			status <= (status and (not SRWriteEnable)) or (SRWriteEnable and alu_status);
			-- update addresses from indirect registers
			if write_indir_addr_wr_en = '1' then
			  reg1 <= r1_value(SCRATCH_ADDR_SIZE - 1 downto 0);
			  reg2 <= r2_value(SCRATCH_ADDR_SIZE - 1 downto 0);
			end if;
		end if;
	end process update_regs;
end	rtl;
