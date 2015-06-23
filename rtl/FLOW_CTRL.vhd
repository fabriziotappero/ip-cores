-- #######################################################
-- #     < STORM CORE PROCESSOR by Stephan Nolting >     #
-- # *************************************************** #
-- #             Operation Flow Control Unit             #
-- # *************************************************** #
-- # Last modified: 10.05.2012                           #
-- #######################################################

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.STORM_core_package.all;

entity FLOW_CTRL is
    Port (
-- ###############################################################################################
-- ##           Global Control                                                                  ##
-- ###############################################################################################

				RST_I               : in  STD_LOGIC; -- global reset input (high active)
				CLK_I               : in  STD_LOGIC; -- global clock input
				G_HALT_I            : in  STD_LOGIC; -- global halt line

-- ###############################################################################################
-- ##           Instruction Interface                                                           ##
-- ###############################################################################################

				INSTR_I             : in  STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0); -- instr cache data input
				INST_MREQ_O         : out STD_LOGIC; -- automatic instruction fetch memory request

-- ###############################################################################################
-- ##           OPCODE Decoder Connection                                                       ##
-- ###############################################################################################

				OPCODE_DATA_O       : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
				OPCODE_CTRL_I       : in  STD_LOGIC_VECTOR(CTRL_MSB downto 0);
				OPCODE_MISC_I       : in  STD_LOGIC_VECTOR(99 downto 0);
				OPCODE_CTRL_O       : out STD_LOGIC_VECTOR(15 downto 0);

-- ###############################################################################################
-- ##           Extended Control                                                                ##
-- ###############################################################################################

				PC_HALT_O           : out STD_LOGIC;                     -- freeze program counter
				SREG_I              : in  STD_LOGIC_VECTOR(31 downto 0); -- current machine status reg
				EXECUTE_INT_I       : in  STD_LOGIC;                     -- interrupt
				STOP_IF_I           : in  STD_LOGIC;                     -- freeze instruction fetch
				HOLD_BUS_I          : in  STD_LOGIC_VECTOR(02 downto 0); -- bubble insert
				EMPTY_PIPE_O        : out STD_LOGIC;                     -- pipeline is empty
				PC_INJECT_O         : out STD_LOGIC;                     -- pc load from memory

-- ###############################################################################################
-- ##           Pipeline Stage Control                                                          ##
-- ###############################################################################################

				OP_ADR_O            : out STD_LOGIC_VECTOR(14 downto 0);
				IMM_O               : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);

				OF_CTRL_O           : out STD_LOGIC_VECTOR(CTRL_MSB downto 0);
				MS_CTRL_O           : out STD_LOGIC_VECTOR(CTRL_MSB downto 0);
				EX1_CTRL_O          : out STD_LOGIC_VECTOR(CTRL_MSB downto 0);
				MEM_CTRL_O          : out STD_LOGIC_VECTOR(CTRL_MSB downto 0);
				WB_CTRL_O           : out STD_LOGIC_VECTOR(CTRL_MSB downto 0)

			 );
end FLOW_CTRL;

architecture FLOW_CTRL_STRUCTURE of FLOW_CTRL is

-- ###############################################################################################
-- ##           Local Signals                                                                   ##
-- ###############################################################################################

	-- Instruction Validation System --
	signal VALID_INSTR      : STD_LOGIC;

	-- Control Busses --
	signal DEC_CTRL_FF      : STD_LOGIC_VECTOR(CTRL_MSB downto 0);
	signal DEC_CTRL         : STD_LOGIC_VECTOR(CTRL_MSB downto 0);
	signal MS_CTRL          : STD_LOGIC_VECTOR(CTRL_MSB downto 0);
	signal EX1_CTRL         : STD_LOGIC_VECTOR(CTRL_MSB downto 0);
	signal CTRL_EX1_BUS     : STD_LOGIC_VECTOR(CTRL_MSB downto 0);
	signal MEM_CTRL         : STD_LOGIC_VECTOR(CTRL_MSB downto 0);
	signal WB_CTRL          : STD_LOGIC_VECTOR(CTRL_MSB downto 0);
	
	-- IF Arbiter --
	signal IF_CYCLE_CNT     : STD_LOGIC_VECTOR(01 downto 0);
	signal IF_CYCLE_CNT_NXT : STD_LOGIC_VECTOR(01 downto 0);
	signal IF_CYCLE_MOD     : STD_LOGIC;
	signal IF_CYCLE_MOD_NXT : STD_LOGIC;
	signal BRANCH_TAKEN     : STD_LOGIC;
	signal PC_INJECT        : STD_LOGIC;
	signal WR_IR_EN         : STD_LOGIC;
	signal IR_HALT          : STD_LOGIC;
	signal CTRL_REG_HALT    : STD_LOGIC;
	signal MULTI_CYCLE_REQ  : STD_LOGIC;
	signal INS_BUF_SEL      : STD_LOGIC;
	signal INS_BUF_SEL_NXT  : STD_LOGIC;
	signal INSTR_REG        : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
	signal INSTR_BUF        : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
	signal DIS_OF           : STD_LOGIC;
	signal DIS_MS           : STD_LOGIC;
	signal DIS_EX           : STD_LOGIC;

begin

-- #######################################################################################################
-- ##  INSTRUCTION FETCH ARBITER                                                                        ##
-- #######################################################################################################

	-- Instruction Fetch Arbiter -----------------------------------------------------------------
	-- ----------------------------------------------------------------------------------------------
		IF_ARBITER: process (CLK_I)
		begin
			--- Sync counter ---
			if rising_edge(CLK_I) then
				if (RST_I = '1') then
					IF_CYCLE_CNT <= (others => '0');
					IF_CYCLE_MOD <= '0';
				elsif (G_HALT_I = '0') then
					if (to_integer(unsigned(IF_CYCLE_CNT)) /= 0) then -- Decrement until zero
						IF_CYCLE_CNT <= Std_Logic_Vector(unsigned(IF_CYCLE_CNT) - 1);
						IF_CYCLE_MOD <= IF_CYCLE_MOD;
					elsif (BRANCH_TAKEN = '1') or (EXECUTE_INT_I = '1') then
						IF_CYCLE_CNT <= Std_Logic_Vector(to_unsigned(DC_TAKEN_BRANCH, 2));
						IF_CYCLE_MOD <= '1';
					elsif (HOLD_BUS_I(0) = '1') then
						IF_CYCLE_CNT <= HOLD_BUS_I(2 downto 1); -- temporal data dependency
						IF_CYCLE_MOD <= '0';
					end if;
				end if;
			end if;
		end process IF_ARBITER;



	-- Instruction Fetch Arbiter Control Lines ---------------------------------------------------
	-- ----------------------------------------------------------------------------------------------
		IF_ARBITER_CTRL: process (IF_CYCLE_CNT,    IF_CYCLE_MOD, HOLD_BUS_I(0),
		                          MULTI_CYCLE_REQ, BRANCH_TAKEN, EXECUTE_INT_I, STOP_IF_I)
			variable cnt_zero_v : std_logic;
		begin
			--- Zero detector ---
			cnt_zero_v := '0';
			if (IF_CYCLE_CNT = "00") then
				cnt_zero_v := '1';
			end if;

			--- Default values and first cycle init ---
			DIS_OF          <= STOP_IF_I and (not MULTI_CYCLE_REQ);
			DIS_MS          <= HOLD_BUS_I(0);
			DIS_EX          <= BRANCH_TAKEN   or EXECUTE_INT_I;
			CTRL_REG_HALT   <= HOLD_BUS_I(0);
			IR_HALT         <= HOLD_BUS_I(0)  or MULTI_CYCLE_REQ or STOP_IF_I;
			INS_BUF_SEL_NXT <= HOLD_BUS_I(0)  or MULTI_CYCLE_REQ;
			INST_MREQ_O     <= '1';

			--- Signal ROM ---
			if (IF_CYCLE_MOD = '1') then -- Taken branch / Interrupt
				if (cnt_zero_v = '0') then -- Cycle counter not zero
					DIS_OF          <= '1';
					DIS_MS          <= '1';
					DIS_EX          <= '1';
					CTRL_REG_HALT   <= '0';
					IR_HALT         <= '0';
					INS_BUF_SEL_NXT <= '0';
					INST_MREQ_O     <= '1';
				end if;
			else -- Temporal data dependency
				if (cnt_zero_v = '0') then -- Cycle counter not zero
					DIS_OF          <= '0';
					DIS_MS          <= '1';
					DIS_EX          <= '0';
					CTRL_REG_HALT   <= '1';
					IR_HALT         <= '1';
					INS_BUF_SEL_NXT <= '1';
					INST_MREQ_O     <= '0';
				end if;
			end if;
		end process IF_ARBITER_CTRL;



	-- System Start-Up Control -------------------------------------------------------------------
	-- ----------------------------------------------------------------------------------------------
		STARTUP_CTRL: process(CLK_I)
		begin
			if rising_edge(CLK_I) then
				if (RST_I = '1') then
					WR_IR_EN <= '0';
				elsif (G_HALT_I = '0') then
					WR_IR_EN <= '1';
				end if;
			end if;
		end process STARTUP_CTRL;



	-- Instruction Register and Buffer -----------------------------------------------------------
	-- ----------------------------------------------------------------------------------------------
		INSTRUCTION_BUFFER: process(CLK_I)
		begin
			if rising_edge(CLK_I) then
				if (RST_I = '1') then
					INSTR_REG   <= NOP_CMD;
					INSTR_BUF   <= NOP_CMD;
					INS_BUF_SEL <= '0';
				else
					if (WR_IR_EN = '1') and (G_HALT_I = '0') then
						INS_BUF_SEL <= INS_BUF_SEL_NXT;
						if (INS_BUF_SEL = '0') then
							INSTR_BUF <= INSTR_I;
						end if;
						if (IR_HALT = '0') then
							if (INS_BUF_SEL = '0') then
								INSTR_REG <= INSTR_I;
							else
								INSTR_REG <= INSTR_BUF;
							end if;
						end if;
					end if;
				end if;
			end if;
		end process INSTRUCTION_BUFFER;

		--- Instruction Decoder Connection ---
		OPCODE_DATA_O <= INSTR_REG;

		--- PC Halt Output ---
		PC_HALT_O <= IR_HALT;



-- #######################################################################################################
-- ##  OPERAND FETCH                                                                                    ##
-- #######################################################################################################

	-- Stage "Operand Fetch" Control Unit --------------------------------------------------------
	-- ----------------------------------------------------------------------------------------------
		OF_CTRL_UNIT: process(CLK_I, DEC_CTRL_FF, OPCODE_MISC_I(91 downto 87))
		begin
			--- Opcode Decoder Connection ---
			if rising_edge(CLK_I) then
				if (RST_I = '1') then
					DEC_CTRL_FF               <= (others => '0');
					OP_ADR_O                  <= (others => '0');
					IMM_O                     <= (others => '0');
					OPCODE_CTRL_O(9 downto 0) <= (others => '0');
				elsif (G_HALT_I = '0') and (CTRL_REG_HALT = '0') then
					OPCODE_CTRL_O(9 downto 1) <= OPCODE_MISC_I(96 downto 88); -- next offset & next dual op
					OPCODE_CTRL_O(0)          <= OPCODE_MISC_I(87) and (not DIS_OF); -- flag for multi cycle ops
					DEC_CTRL_FF               <= OPCODE_CTRL_I;
					DEC_CTRL_FF(CTRL_EN)      <= not (DIS_OF);
					OP_ADR_O                  <= OPCODE_MISC_I(47 downto 33);
					IMM_O                     <= OPCODE_MISC_I(79 downto 48);
				end if;
			end if;

			--- Check for NEVER EVER condition ---
			DEC_CTRL <= DEC_CTRL_FF;
			if (DEC_CTRL_FF(CTRL_COND_3 downto CTRL_COND_0) = COND_NV) then
				DEC_CTRL(CTRL_EN) <= '0';
			end if;

			--- Multi Cycle OP Request ---
			MULTI_CYCLE_REQ <= '1';
			if (OPCODE_MISC_I(91 downto 87) = "00000") then -- next dual op
				MULTI_CYCLE_REQ <= '0';
			end if;

		end process OF_CTRL_UNIT;


	-- Pipeline Stage "OPERAND FETCH" CTRL Bus ---------------------------------------------------
	-- ----------------------------------------------------------------------------------------------
		OF_CTRL_O <= DEC_CTRL;



-- #######################################################################################################
-- ##  MULTIPLICATION & SHIFT                                                                           ##
-- #######################################################################################################

	-- Pipeline Registers ------------------------------------------------------------------------
	-- ----------------------------------------------------------------------------------------------
		STAGE_BUFFER_2: process(CLK_I)
		begin
			if rising_edge (CLK_I) then
				if (RST_I = '1') then
					MS_CTRL <= (others => '0');
					-- set 'never condition' for start up --
					MS_CTRL(CTRL_COND_3 downto CTRL_COND_0) <= COND_NV;
				elsif (G_HALT_I = '0') then
					MS_CTRL <= DEC_CTRL;
					-- disable stage when branching or inserting dummy cycle --
					MS_CTRL(CTRL_EN) <= DEC_CTRL(CTRL_EN) and (not DIS_MS);
				end if;
			end if;
		end process STAGE_BUFFER_2;



	-- Pipeline Stage "MULTIPLY/SHIFT" CTRL Bus --------------------------------------------------
	-- ----------------------------------------------------------------------------------------------
		MS_CTRL_O <= MS_CTRL;



-- #####################################################################################################
-- ##  ALU OPERATION & MCR / CP ACCESS                                                                ##
-- #####################################################################################################

	-- Pipeline Registers ------------------------------------------------------------------------
	-- ----------------------------------------------------------------------------------------------
		STAGE_BUFFER_3: process(CLK_I)
		begin
			if rising_edge(CLK_I) then
				if (RST_I = '1') then
					EX1_CTRL <= (others => '0');
					-- set 'never condition' for start up --
					EX1_CTRL(CTRL_COND_3 downto CTRL_COND_0) <= COND_NV;
				elsif (G_HALT_I = '0') then
					EX1_CTRL <= MS_CTRL;
					-- disable stage when branching --
					EX1_CTRL(CTRL_EN) <= MS_CTRL(CTRL_EN) and (not DIS_EX);
				end if;
			end if;
		end process STAGE_BUFFER_3;



	-- Condition Check System --------------------------------------------------------------------
	-- ----------------------------------------------------------------------------------------------
		COND_CHECK_SYS: process(EX1_CTRL, SREG_I)
			variable valid_v : std_logic;
		begin
			case EX1_CTRL(CTRL_COND_3 downto CTRL_COND_0) is
				when COND_EQ => -- EQ = EQUAL: Zero set
					valid_v := SREG_I(SREG_Z_FLAG);
				when COND_NE => -- NE = NOT EQUAL: Zero clr
					valid_v := not SREG_I(SREG_Z_FLAG);
				when COND_CS => -- CS = UNSIGNED OR HIGHER: Carry set
					valid_v := SREG_I(SREG_C_FLAG);
				when COND_CC => -- CC = UNSIGNED LOWER: Carry clr
					valid_v := not SREG_I(SREG_C_FLAG);
				when COND_MI => -- MI = NEGATIVE: Negative set
					valid_v := SREG_I(SREG_N_FLAG);
				when COND_PL => -- PL = POSITIVE OR ZERO: Negative clr
					valid_v := not SREG_I(SREG_N_FLAG);
				when COND_VS => -- VS = OVERFLOW: Overflow set
					valid_v := SREG_I(SREG_O_FLAG);
				when COND_VC => -- VC = NO OVERFLOW: Overflow clr
					valid_v := not SREG_I(SREG_O_FLAG);
				when COND_HI => -- HI = UNSIGNED HIGHER: Carry set and Zero clr
					valid_v := SREG_I(SREG_C_FLAG) and (not SREG_I(SREG_Z_FLAG));
				when COND_LS => -- LS = UNSIGNED LOWER OR SAME: Carry clr or Zero set
					valid_v := (not SREG_I(SREG_C_FLAG)) or SREG_I(SREG_Z_FLAG);
				when COND_GE => -- GE = GREATER OR EQUAL
					valid_v := SREG_I(SREG_N_FLAG) xnor SREG_I(SREG_O_FLAG);
				when COND_LT => -- LT = LESS THAN
					valid_v := SREG_I(SREG_N_FLAG) xor SREG_I(SREG_O_FLAG);
				when COND_GT => -- GT = GREATER THAN
					valid_v := (not SREG_I(SREG_Z_FLAG)) and (SREG_I(SREG_N_FLAG) xnor SREG_I(SREG_O_FLAG));
				when COND_LE => -- LE = LESS THAN OR EQUAL
					valid_v := SREG_I(SREG_Z_FLAG) or (SREG_I(SREG_N_FLAG) xor SREG_I(SREG_O_FLAG));
				when COND_AL => -- AL = ALWAYS
					valid_v := '1';
				when COND_NV => -- NV = NEVER
					valid_v := '0';
				when others  => -- UNDEFINED
					valid_v := '0';
			end case;
			--- Valid Instruction Signal ---
			VALID_INSTR <= EX1_CTRL(CTRL_EN) and valid_v;
		end process COND_CHECK_SYS;



	-- Detector for automatic/manual branches ----------------------------------------------------
	-- ----------------------------------------------------------------------------------------------
		BRANCH_DETECTOR: process(EX1_CTRL, VALID_INSTR, WB_CTRL)
			variable manual_branch_v : std_logic;
			variable pc_injector_v   : std_logic;
		begin
			-- Manual Branch when R_Dest = PC --
			manual_branch_v := '0';
			if (EX1_CTRL(CTRL_RD_3 downto CTRL_RD_0) = C_PC_ADR) and (EX1_CTRL(CTRL_WB_EN) = '1') then
				manual_branch_v := '1';
			end if;

			-- Loading PC from Memory --
			pc_injector_v := '0';
			if (WB_CTRL(CTRL_RD_3 downto CTRL_RD_0) = C_PC_ADR) and (WB_CTRL(CTRL_EN) = '1') and
			   (WB_CTRL(CTRL_MEM_ACC) = '1') and (WB_CTRL(CTRL_MEM_RW) = '0') then
				pc_injector_v := '1';
			end if;
			PC_INJECT_O <= pc_injector_v;

			-- Branch Taken Signal --
			BRANCH_TAKEN <= (VALID_INSTR and (EX1_CTRL(CTRL_BRANCH) or manual_branch_v) and
			                (not EX1_CTRL(CTRL_MEM_ACC))) or pc_injector_v;
		end process BRANCH_DETECTOR;



	-- EX Stage CTRL_BUS and Link Control --------------------------------------------------------
	-- ----------------------------------------------------------------------------------------------
		EX_CTRL_BUS_CONSTRUCTION: process(EX1_CTRL, BRANCH_TAKEN, VALID_INSTR)
		begin
			--- CTRL_BUS for EX stage ---
			CTRL_EX1_BUS              <= EX1_CTRL;
			CTRL_EX1_BUS(CTRL_BRANCH) <= BRANCH_TAKEN; -- insert branch taken signal
			CTRL_EX1_BUS(CTRL_EN)     <= VALID_INSTR;  -- insert current op validation
		end process EX_CTRL_BUS_CONSTRUCTION;



	-- Pipeline Stage "EXECUTE" CTRL Bus ---------------------------------------------------------
	-- ----------------------------------------------------------------------------------------------
		EX1_CTRL_O <= CTRL_EX1_BUS;



-- #####################################################################################################
-- ##  DATA CACHE ACCESS                                                                              ##
-- #####################################################################################################

	-- Pipeline Registers ------------------------------------------------------------------------
	-- ----------------------------------------------------------------------------------------------
		STAGE_BUFFER_4: process(CLK_I)
		begin
			if rising_edge (CLK_I) then
				if (RST_I = '1') then
					MEM_CTRL <= (others => '0');
				elsif (G_HALT_I = '0') then
					MEM_CTRL <= CTRL_EX1_BUS;
					--- linking operation (branch/interrupt) ---
					if (EXECUTE_INT_I = '1') then
						MEM_CTRL             <= (others => '0');
						MEM_CTRL(CTRL_EN)    <= '1'; -- force enable
						MEM_CTRL(CTRL_WB_EN) <= '1'; -- force LR write back
						MEM_CTRL(CTRL_LINK)  <= '1'; -- yes, we're linking
					end if;
					--- Insert RD = LR when performing link operations ---
					if (EX1_CTRL(CTRL_LINK) = '1') or (EXECUTE_INT_I = '1') then
						MEM_CTRL(CTRL_RD_3 downto CTRL_RD_0) <= C_LR_ADR;
					end if;
				end if;
			end if;
		end process STAGE_BUFFER_4;


	-- Pipeline Stage "MEMORY" CTRL Bus ----------------------------------------------------------
	-- ----------------------------------------------------------------------------------------------
		MEM_CTRL_O <= MEM_CTRL;



-- #####################################################################################################
-- ##  DATA WRITE BACK                                                                                ##
-- #####################################################################################################

	-- Pipeline Registers ------------------------------------------------------------------------
	-- ----------------------------------------------------------------------------------------------
		STAGE_BUFFER_5: process(CLK_I)
		begin
			if rising_edge (CLK_I) then
				if (RST_I = '1') then
					WB_CTRL <= (others => '0');
				elsif (G_HALT_I = '0') then
					WB_CTRL <= MEM_CTRL;
					--- Write back to USER register bank ---
					if (MEM_CTRL(CTRL_WR_USR) = '1') then
						WB_CTRL(CTRL_MODE_4 downto CTRL_MODE_0) <= User32_MODE;
					else
						WB_CTRL(CTRL_MODE_4 downto CTRL_MODE_0) <= SREG_I(SREG_MODE_4 downto SREG_MODE_0);
					end if;
				end if;
			end if;
		end process STAGE_BUFFER_5;


	-- Pipeline Stage "WRITE BACK" CTRL Bus ------------------------------------------------------
	-- ----------------------------------------------------------------------------------------------
		WB_CTRL_O <= WB_CTRL;



	-- Empty Pipeline Detector -------------------------------------------------------------------
	-- ----------------------------------------------------------------------------------------------
		EMPTY_PIPE_O <= not(DEC_CTRL(CTRL_EN) or MS_CTRL(CTRL_EN) or CTRL_EX1_BUS(CTRL_EN) or MEM_CTRL(CTRL_EN) or WB_CTRL(CTRL_EN));



end FLOW_CTRL_STRUCTURE;