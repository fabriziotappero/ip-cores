-- #######################################################
-- #     < STORM CORE PROCESSOR by Stephan Nolting >     #
-- # *************************************************** #
-- #              Machine Control System                 #
-- # *************************************************** #
-- # Last modified: 13.05.2012                           #
-- #######################################################

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.STORM_core_package.all;

entity MC_SYS is
-- ###############################################################################################
-- ##           System Startup Address                                                          ##
-- ###############################################################################################
	generic (
				BOOT_VEC        : STD_LOGIC_VECTOR(31 downto 0) := x"00000000" -- boot address
	        );
-- ###############################################################################################
-- ##           Global Control                                                                  ##
-- ###############################################################################################
	port	(
				CLK_I           : in  STD_LOGIC; -- global clock line
				G_HALT_I        : in  STD_LOGIC; -- global halt line
				RST_I           : in  STD_LOGIC; -- global reset line, high active

-- ###############################################################################################
-- ##           Global Control                                                                  ##
-- ###############################################################################################

				CTRL_I          : in  STD_LOGIC_VECTOR(CTRL_MSB downto 0); -- ctrl lines
				HALT_I          : in  STD_LOGIC; -- halt request
				PEND_XI_REQ_O   : out STD_LOGIC; -- pending external interrupt request
				INT_TKN_O       : out STD_LOGIC; -- int taken signal
				EMPTY_PIPE_I    : in  STD_LOGIC;

-- ###############################################################################################
-- ##           Operand Connection                                                              ##
-- ###############################################################################################

				FLAG_I          : in  STD_LOGIC_VECTOR(03 downto 0); -- ALU flag input
				CMSR_O          : out STD_LOGIC_VECTOR(31 downto 0); -- sreg output

				REG_PC_O        : out STD_LOGIC_VECTOR(31 downto 0); -- PC value for manual ops
				JMP_PC_O        : out STD_LOGIC_VECTOR(31 downto 0); -- PC value for branches
				LNK_PC_O        : out STD_LOGIC_VECTOR(31 downto 0); -- PC value for linking
				INF_PC_O        : out STD_LOGIC_VECTOR(31 downto 0); -- PC value for instr fetch

				MCR_DATA_I      : in  STD_LOGIC_VECTOR(31 downto 0); -- mcr data input
				MCR_DATA_O      : out STD_LOGIC_VECTOR(31 downto 0); -- mcr data output

				PC_INJECT_I     : in  STD_LOGIC;                     -- pc load from memory
				PC_INJECT_D_I   : in  STD_LOGIC_VECTOR(31 downto 0); -- write back data

-- ###############################################################################################
-- ##           External Interrupt Lines                                                        ##
-- ###############################################################################################

				EX_FIQ_I        : in  STD_LOGIC; -- fast int request
				EX_IRQ_I        : in  STD_LOGIC; -- normal int request
				EX_DAB_I        : in  STD_LOGIC; -- data abort int request
				EX_IAB_I        : in  STD_LOGIC; -- instr abort int request

-- ###############################################################################################
-- ##           Cache Control                                                                   ##
-- ###############################################################################################

				BUS_CYCC_O      : out STD_LOGIC_VECTOR(15 downto 0); -- bus timeout value
				DC_FLUSH_O      : out STD_LOGIC; -- flush d-cache
				DC_CLEAR_O      : out STD_LOGIC; -- clear d-cache
				DC_HIT_I        : in  STD_LOGIC; -- d-cache hit access
				DC_MISS_I       : in  STD_LOGIC; -- d-cache miss acess
				DC_FRESH_O      : out STD_LOGIC; -- d-cache auto-refresh
				IC_FRESH_O      : out STD_LOGIC; -- i-cache auto-refresh
				IC_CLEAR_O      : out STD_LOGIC; -- clear i-cache
				IC_HIT_I        : in  STD_LOGIC; -- i-cache hit access
				IC_MISS_I       : in  STD_LOGIC; -- i-cache miss access
				C_WTHRU_O       : out STD_LOGIC; -- write through
				CACHED_IO_O     : out STD_LOGIC; -- en cached IO
				PRTCT_IO_O      : out STD_LOGIC; -- protected IO
				DC_SYNC_I       : in  STD_LOGIC; -- d-cache is sync

-- ###############################################################################################
-- ##           System Control                                                                  ##
-- ###############################################################################################

				IO_PORT_O       : out STD_LOGIC_VECTOR(15 downto 0); -- direct output
				IO_PORT_I       : in  STD_LOGIC_VECTOR(15 downto 0); -- direct input
				ADR_FEEDBACK_I  : in  STD_LOGIC_VECTOR(31 downto 0)  -- adr feedback for exception handling

			);
end MC_SYS;

architecture MC_SYS_STRUCTURE of MC_SYS is

	-- Internal Machine Control Registers --
	signal MCR_CMSR             : STD_LOGIC_VECTOR(31 downto 0); -- Current Machine Status Register
	signal MCR_PC               : STD_LOGIC_VECTOR(31 downto 0); -- Program Counter
	signal SMSR_FIQ             : STD_LOGIC_VECTOR(31 downto 0); -- Fast Interrupt Status Reg
	signal SMSR_SVC             : STD_LOGIC_VECTOR(31 downto 0); -- Supervisor Status Reg
	signal SMSR_ABT             : STD_LOGIC_VECTOR(31 downto 0); -- Prefetch Abort Status Reg
	signal SMSR_IRQ             : STD_LOGIC_VECTOR(31 downto 0); -- Normal Interrupt Status Reg
	signal SMSR_UND             : STD_LOGIC_VECTOR(31 downto 0); -- Undefined Instruction Status Reg
	signal SMSR_SYS             : STD_LOGIC_VECTOR(31 downto 0); -- System Status Reg

	-- System Coprocessor Registers --
	type   CP_REG_TYPE is array(15 downto 0) of STD_LOGIC_VECTOR(31 downto 0);
	signal CP_REG_FILE          : CP_REG_TYPE;

	-- Flag Construction Bus --
	signal FLAG_BUS             : STD_LOGIC_VECTOR(31 downto 0);

	-- Context CTRL --
	signal CONT_EXE             : STD_LOGIC;
	signal NEW_MODE             : STD_LOGIC_VECTOR(04 downto 0);
	signal INT_VEC              : STD_LOGIC_VECTOR(04 downto 0);
	signal BR_CNT               : STD_LOGIC_VECTOR(02 downto 0);
	signal NO_BR_PIPE           : STD_LOGIC;

	-- INT Condition Signals --
	signal FIQ_TAKEN, IRQ_TAKEN : STD_LOGIC; -- external int handler
	signal DAB_TAKEN, IAB_TAKEN : STD_LOGIC; -- external int handler
	signal UND_TAKEN, SWI_TAKEN : STD_LOGIC; -- software int handler
	signal FIQ_TAKEN_NXT        : STD_LOGIC; 
	signal IRQ_TAKEN_NXT        : STD_LOGIC; 
	signal IAB_TAKEN_NXT        : STD_LOGIC; 
	signal DAB_TAKEN_NXT        : STD_LOGIC;
	signal DIS_CYCLE_OK         : STD_LOGIC;
	signal INVALID_BX_REQ       : STD_LOGIC;

	-- Coprocessor Signals --
	signal INVALID_CP_ACC       : STD_LOGIC;
	signal CP_IRQ               : STD_LOGIC;
	signal LFSR_DN              : STD_LOGIC;

	-- External INT Sync System --
	signal EXT_INT_REQ_SYNC     : STD_LOGIC_VECTOR(03 downto 0); -- external int sync reg

	-- PC Delay Buffer --
	type   PC_DELAY_BUF_TYPE is array (06 downto 0) of STD_LOGIC_VECTOR(31 downto 0);
	signal PC_DELAY_BUF         : PC_DELAY_BUF_TYPE;

begin

	-- External Interrupt Signal Synchronizer ---------------------------------------------------------
	-- ---------------------------------------------------------------------------------------------------
		EXT_INT_SYNC_REG: process(CLK_I)
		begin
			if rising_edge(CLK_I) then
				if (RST_I = '1') then
					FIQ_TAKEN <= '0';
					IRQ_TAKEN <= '0';
					DAB_TAKEN <= '0';
					IAB_TAKEN <= '0';
				elsif (G_HALT_I = '0')then
					FIQ_TAKEN <= FIQ_TAKEN_NXT and (not FIQ_TAKEN);
					IRQ_TAKEN <= IRQ_TAKEN_NXT and (not IRQ_TAKEN);
					DAB_TAKEN <= DAB_TAKEN_NXT and (not DAB_TAKEN);
					IAB_TAKEN <= IAB_TAKEN_NXT and (not IAB_TAKEN);
				end if;
			end if;
		end process EXT_INT_SYNC_REG;

		EXT_INT_SYNC: process(CLK_I)
		begin
			-- IRQ REQ Buffer --
			if rising_edge(CLK_I) then
				if (RST_I = '1') then
					EXT_INT_REQ_SYNC <= (others => '0');
				else
					-- Fast Interrupt Request (FIQ) --
					if (FIQ_TAKEN = '1') then
						EXT_INT_REQ_SYNC(0) <= '0';
					elsif (EX_FIQ_I = '1') and (MCR_CMSR(SREG_FIQ_DIS) = '0') then
						EXT_INT_REQ_SYNC(0) <= '1';
					elsif (MCR_CMSR(SREG_FIQ_DIS) = '0') then
						EXT_INT_REQ_SYNC(0) <= '0';
					end if;
					-- Normal Interrupt Request (IRQ) --
					if (IRQ_TAKEN = '1') then
						EXT_INT_REQ_SYNC(1) <= '0';
					elsif (EX_IRQ_I = '1') and (MCR_CMSR(SREG_IRQ_DIS) = '0') then
						EXT_INT_REQ_SYNC(1) <= '1';
					elsif (MCR_CMSR(SREG_IRQ_DIS) = '0') then
						EXT_INT_REQ_SYNC(1) <= '0';
					end if;
					-- Data Fetch Abort Request (DAB) --
					if (DAB_TAKEN = '1') then
						EXT_INT_REQ_SYNC(2) <= '0';
					elsif (EX_DAB_I = '1') and (MCR_CMSR(SREG_DAB_DIS) = '0') then
						EXT_INT_REQ_SYNC(2) <= '1';
					elsif (MCR_CMSR(SREG_DAB_DIS) = '0') then
						EXT_INT_REQ_SYNC(2) <= '0';
					end if;
					-- Instruction Fetch Abort Request (IAB) --
					if (IAB_TAKEN = '1') then
						EXT_INT_REQ_SYNC(3) <= '0';
					elsif (EX_IAB_I = '1') and (MCR_CMSR(SREG_IAB_DIS) = '0') then
						EXT_INT_REQ_SYNC(3) <= '1';
					elsif (MCR_CMSR(SREG_IAB_DIS) = '0') then
						EXT_INT_REQ_SYNC(3) <= '0';
					end if;
				end if;
			end if;
		end process EXT_INT_SYNC;



	-- External Interrupt Cycle Control System --------------------------------------------------------
	-- ---------------------------------------------------------------------------------------------------

		-- Pending external interrupt request to stop instruction fetch until pipeline is empty --
		PEND_XI_REQ_O <= EXT_INT_REQ_SYNC(0) or EXT_INT_REQ_SYNC(1) or EXT_INT_REQ_SYNC(2) or EXT_INT_REQ_SYNC(3);

		-- FIQ Trap taken --
		FIQ_TAKEN_NXT <= EXT_INT_REQ_SYNC(0) and EMPTY_PIPE_I and NO_BR_PIPE;
		-- IRQ Trap taken --
		IRQ_TAKEN_NXT <= EXT_INT_REQ_SYNC(1) and EMPTY_PIPE_I and NO_BR_PIPE;
		-- Data Abort Trap taken --
		DAB_TAKEN_NXT <= EXT_INT_REQ_SYNC(2) and EMPTY_PIPE_I and NO_BR_PIPE;
		-- Instruction Abort Trap taken --
		IAB_TAKEN_NXT <= EXT_INT_REQ_SYNC(3) and EMPTY_PIPE_I and NO_BR_PIPE;
		-- Software Interrupt Trap taken --
		SWI_TAKEN <= CTRL_I(CTRL_EN) and CTRL_I(CTRL_SWI);
		-- Undefined Instruction Trap taken --
		UND_TAKEN <= CTRL_I(CTRL_EN) and (CTRL_I(CTRL_UND) or INVALID_CP_ACC or INVALID_BX_REQ);



	-- Interrupt Branch Adaption ----------------------------------------------------------------------
	-- ---------------------------------------------------------------------------------------------------
		BR_COUNTER: process(CLK_I)
		begin
			if rising_edge(CLK_I) then
				if (RST_I = '1') then
					BR_CNT <= (others => '0');
				elsif (G_HALT_I = '0') then
					if (BR_CNT /= "000") then
						BR_CNT <= Std_Logic_Vector(unsigned(BR_CNT) - 1);
					elsif (CTRL_I(CTRL_BRANCH) = '1') then
						BR_CNT <= "101"; -- 5 data processing pipe stages
					end if;
				end if;
			end if;
		end process BR_COUNTER;

		--- Wait until active branch cycle is completed ---
		NO_BR_PIPE <= '1' when ((BR_CNT = "000") and (CTRL_I(CTRL_BRANCH) = '0')) else '0';



	-- Interrupt Handler System -----------------------------------------------------------------------
	-- ---------------------------------------------------------------------------------------------------
		INT_HANDLER: process(MCR_CMSR, FLAG_I, FIQ_TAKEN, IRQ_TAKEN, DAB_TAKEN,
		                     IAB_TAKEN, SWI_TAKEN, UND_TAKEN, CTRL_I, MCR_DATA_I)
		begin
			-- default values --
			CONT_EXE               <= '1';
			FLAG_BUS               <= MCR_CMSR;
			FLAG_BUS(SREG_C_FLAG)  <= FLAG_I(0); -- Carry Flag
			FLAG_BUS(SREG_Z_FLAG)  <= FLAG_I(1); -- Zero Flag
			FLAG_BUS(SREG_N_FLAG)  <= FLAG_I(2); -- Negative Flag
			FLAG_BUS(SREG_O_FLAG)  <= FLAG_I(3); -- Overflow Flag
			FLAG_BUS(SREG_SHIN_M)  <= '0';
			FLAG_BUS(SREG_FIQ_DIS) <= MCR_CMSR(SREG_FIQ_DIS); -- keep current interrupt settings
			FLAG_BUS(SREG_IRQ_DIS) <= MCR_CMSR(SREG_IRQ_DIS); -- keep current interrupt settings
			FLAG_BUS(SREG_DAB_DIS) <= MCR_CMSR(SREG_DAB_DIS); -- keep current interrupt settings
			FLAG_BUS(SREG_IAB_DIS) <= MCR_CMSR(SREG_IAB_DIS); -- keep current interrupt settings

			--- Short Instruction Mode ---
			if (CTRL_I(CTRL_EN) = '1') and (CTRL_I(CTRL_BX) = '1') and (SHIN_EN = TRUE) then
				FLAG_BUS(SREG_SHIN_M) <= MCR_DATA_I(0);
				INVALID_BX_REQ        <= MCR_DATA_I(0);
			else
				FLAG_BUS(SREG_SHIN_M) <= MCR_CMSR(SREG_SHIN_M);
				INVALID_BX_REQ        <= '0';
			end if;

			--- Priority 1: Data Fetch Abort ---
			if (DAB_TAKEN = '1') then
				INT_VEC  <= DAT_INT_VEC;
				FLAG_BUS(SREG_MODE_4 downto SREG_MODE_0) <= Abort32_MODE;
				NEW_MODE <= Abort32_MODE;
				FLAG_BUS(SREG_DAB_DIS) <= '1'; -- disable DAB

			--- Priority 2: Fast Interrupt Request ---
			elsif (FIQ_TAKEN = '1') then
				INT_VEC  <= FIQ_INT_VEC;
				FLAG_BUS(SREG_MODE_4 downto SREG_MODE_0) <= FIQ32_MODE;
				NEW_MODE <= FIQ32_MODE;
				FLAG_BUS(SREG_FIQ_DIS) <= '1'; -- disable FIQ

			--- Priority 3: Interrupt Request ---
			elsif (IRQ_TAKEN = '1') then
				INT_VEC  <= IRQ_INT_VEC;
				FLAG_BUS(SREG_MODE_4 downto SREG_MODE_0) <= IRQ32_MODE;
				NEW_MODE <= IRQ32_MODE;
				FLAG_BUS(SREG_IRQ_DIS) <= '1'; -- disable IRQ

			--- Priority 4: Instruction Fetch Abort ---
			elsif (IAB_TAKEN = '1') then
				INT_VEC  <= PRF_INT_VEC;
				FLAG_BUS(SREG_MODE_4 downto SREG_MODE_0) <= Abort32_MODE;
				NEW_MODE <= Abort32_MODE;
				FLAG_BUS(SREG_IAB_DIS) <= '1'; -- disable IAB

			--- Priority 5: Undefined Instruction ---
			elsif (UND_TAKEN = '1') then
				INT_VEC  <= UND_INT_VEC;
				FLAG_BUS(SREG_MODE_4 downto SREG_MODE_0) <= Undefined32_MODE;
				NEW_MODE <= Undefined32_MODE;

			--- Priority 6: Software Interrupt ---
			elsif (SWI_TAKEN = '1') then
				INT_VEC  <= SWI_INT_VEC;
				FLAG_BUS(SREG_MODE_4 downto SREG_MODE_0) <= Supervisor32_MODE;
				NEW_MODE <= Supervisor32_MODE;
			else							-- normal operation
				CONT_EXE <= '0';
				INT_VEC  <= (others => '0');
				NEW_MODE <= MCR_CMSR(SREG_MODE_4 downto SREG_MODE_0); -- keep current mode
			end if;
		end process INT_HANDLER;

		--- Interrupt Taken Output ---
		INT_TKN_O <= CONT_EXE; -- Execute Interrupt



	-- Machine Control Register -----------------------------------------------------------------------
	-- ---------------------------------------------------------------------------------------------------
		MREG_WRITE_ACCESS: process(CLK_I, CTRL_I, MCR_CMSR)
			variable mwr_smsr_v, mwr_cmsr_v : std_logic;
			variable current_mode_v         : std_logic_vector(4 downto 0);
			variable cont_ret_v             : std_logic;
			variable cmsr_acc_case_v        : std_logic_vector(3 downto 0);
			variable smsr_acc_case_v        : std_logic_vector(2 downto 0);
		begin
			-- manual SMSR write access --
			mwr_smsr_v := CTRL_I(CTRL_MREG_ACC) and      CTRL_I(CTRL_MREG_M)  and CTRL_I(CTRL_MREG_RW);
			-- manual CMSR write access --
			mwr_cmsr_v := CTRL_I(CTRL_MREG_ACC) and (not CTRL_I(CTRL_MREG_M)) and CTRL_I(CTRL_MREG_RW);
			-- current operating mode --
			current_mode_v := MCR_CMSR(SREG_MODE_4 downto SREG_MODE_0);

			-- return from interrupt --
			cont_ret_v := '0';
			if ((CTRL_I(CTRL_RD_3 downto CTRL_RD_0) = C_PC_ADR) and (CTRL_I(CTRL_AF) = '1') and
				(current_mode_v /= User32_MODE)) then
				cont_ret_v := '1';
			end if;

			-- synchronous write --
			if rising_edge(CLK_I) then
				if (RST_I = '1') then
					MCR_PC   <= BOOT_VEC;    -- start-up address
					MCR_CMSR <= x"000003DF"; -- all INTs disabled and we are in SYSTEM32 mode
					SMSR_FIQ <= x"000003DF"; -- all INTs disabled and return to SYSTEM32 mode
					SMSR_SVC <= x"000003DF"; -- all INTs disabled and return to SYSTEM32 mode
					SMSR_ABT <= x"000003DF"; -- all INTs disabled and return to SYSTEM32 mode
					SMSR_IRQ <= x"000003DF"; -- all INTs disabled and return to SYSTEM32 mode
					SMSR_UND <= x"000003DF"; -- all INTs disabled and return to SYSTEM32 mode
					SMSR_SYS <= x"000003DF"; -- all INTs disabled and return to SYSTEM32 mode
				elsif (G_HALT_I = '0') then


					---- PROGRAM COUNTER ---------------------------------------------------------------
					if (CONT_EXE = '1') then -- load PC with interrupt vector
						MCR_PC <= x"000000" & "000" & INT_VEC;
					elsif (PC_INJECT_I = '1') then -- load pc from memory
						MCR_PC <= PC_INJECT_D_I;
					elsif (CTRL_I(CTRL_BRANCH) = '1') then -- taken branch
						MCR_PC <= MCR_DATA_I;
					elsif (HALT_I = '0') then -- no hold request -> normal operation
						if (MCR_CMSR(SREG_SHIN_M) = '1') and (SHIN_EN = TRUE) then
						-- 16-bit instruction mode --
							MCR_PC(31 downto 1) <= Std_Logic_Vector(unsigned(MCR_PC(31 downto 1)) + 1);
						else
						-- 32-bit instruction mode --
							MCR_PC(31 downto 2) <= Std_Logic_Vector(unsigned(MCR_PC(31 downto 2)) + 1);
						end if;
					end if;


					---- CURRENT MACHINE STATUS REGISTER -----------------------------------------------
					cmsr_acc_case_v := CONT_EXE & CTRL_I(CTRL_EN) & cont_ret_v & mwr_cmsr_v;
					case cmsr_acc_case_v is
						when "1000" | "1001" | "1010" | "1011" | "1100" | "1101" | "1110" | "1111" =>
							MCR_CMSR(09 downto 0) <= FLAG_BUS(09 downto 0); -- interrupt de, ctrl, mode bits
--							MCR_CMSR(31 downto 0) <= FLAG_BUS(31 downto 0);
						when "0110" | "0111" => -- context down change
--						when "0110" | "0111" | "0010" | "0011" => -- context down change
							case (current_mode_v) is -- current mode
								when FIQ32_MODE        => MCR_CMSR <= SMSR_FIQ;
								when Supervisor32_MODE => MCR_CMSR <= SMSR_SVC;
								when Abort32_MODE      => MCR_CMSR <= SMSR_ABT;
								when IRQ32_MODE        => MCR_CMSR <= SMSR_IRQ;
								when Undefined32_MODE  => MCR_CMSR <= SMSR_UND;
								when System32_MODE     => MCR_CMSR <= SMSR_SYS;
								when others            => MCR_CMSR <= MCR_CMSR;
							end case;
						when "0101" => -- manual write
							if (current_mode_v = User32_MODE) or (CTRL_I(CTRL_MREG_FA) = '1') then -- restricted access for user mode
								MCR_CMSR <= MCR_DATA_I(31 downto 28) & MCR_CMSR(27 downto 0);
							else
								MCR_CMSR <= MCR_DATA_I(31 downto 0); -- full sreg access
							end if;
						when "0100" => -- automatic access
							if (CTRL_I(CTRL_AF) = '1') then -- alter flags
								MCR_CMSR <= FLAG_BUS(31 downto 0); -- update whole sreg
							else -- keep flags
								MCR_CMSR <= MCR_CMSR(31 downto 28) & FLAG_BUS(27 downto 0); -- update without flags
							end if;
						when others => -- keep CMSR
							MCR_CMSR <= MCR_CMSR;
					end case;


					---- SAVED MACHINE STATUS REGISTER -------------------------------------------------
					smsr_acc_case_v := CONT_EXE & (CTRL_I(CTRL_EN) and mwr_smsr_v) & CTRL_I(CTRL_MREG_FA);
					case (smsr_acc_case_v) is
						-- Content up-change --
						when "100" | "101" | "110" | "111" =>
							case (NEW_MODE) is -- save old machine status register
								when FIQ32_MODE        => SMSR_FIQ <= MCR_CMSR;
								when Supervisor32_MODE => SMSR_SVC <= MCR_CMSR;
								when Abort32_MODE      => SMSR_ABT <= MCR_CMSR;
								when IRQ32_MODE        => SMSR_IRQ <= MCR_CMSR;
								when Undefined32_MODE  => SMSR_UND <= MCR_CMSR;
								when System32_MODE     => SMSR_SYS <= MCR_CMSR;
								when others            => NULL;
							end case;
						-- manual write, flag access only --
						when "011" =>
							case (current_mode_v) is
								when FIQ32_MODE        => SMSR_FIQ(31 downto 28) <= MCR_DATA_I(31 downto 28);
								when Supervisor32_MODE => SMSR_SVC(31 downto 28) <= MCR_DATA_I(31 downto 28);
								when Abort32_MODE      => SMSR_ABT(31 downto 28) <= MCR_DATA_I(31 downto 28);
								when IRQ32_MODE        => SMSR_IRQ(31 downto 28) <= MCR_DATA_I(31 downto 28);
								when Undefined32_MODE  => SMSR_UND(31 downto 28) <= MCR_DATA_I(31 downto 28);
								when System32_MODE     => SMSR_SYS(31 downto 28) <= MCR_DATA_I(31 downto 28);
								when others            => NULL;
							end case;
						-- manual write, full access --
						when "010" =>
							case (current_mode_v) is
								when FIQ32_MODE        => SMSR_FIQ <= MCR_DATA_I;
								when Supervisor32_MODE => SMSR_SVC <= MCR_DATA_I;
								when Abort32_MODE      => SMSR_ABT <= MCR_DATA_I;
								when IRQ32_MODE        => SMSR_IRQ <= MCR_DATA_I;
								when Undefined32_MODE  => SMSR_UND <= MCR_DATA_I;
								when System32_MODE     => SMSR_SYS <= MCR_DATA_I;
								when others            => NULL;
							end case;
						-- keep content --
						when others =>
							NULL;
					end case;

				end if;
			end if;
		end process MREG_WRITE_ACCESS;

		--- MCR Output ---
		CMSR_O <= MCR_CMSR; -- current status register



	-- System Coprocessor Write Access ----------------------------------------------------------------
	-- ---------------------------------------------------------------------------------------------------
		SYS_CP_ACC: process(CLK_I, CTRL_I, MCR_CMSR)
			variable is_priv_mode_v         : std_logic;
			variable cr_r_acc_v, cr_w_acc_v : std_logic;
			variable cp_adr_v               : integer range 0 to 15;
		begin
			-- Is Priviliged mode? --
			is_priv_mode_v := '1';
			if (MCR_CMSR(SREG_MODE_4 downto SREG_MODE_0) = User32_MODE) then
				is_priv_mode_v := '0';
			end if;

			-- CP Register Address --
			cp_adr_v := to_integer(unsigned(CTRL_I(CTRL_CP_REG_3 downto CTRL_CP_REG_0)));

			-- Unpriviliged w-access --
			INVALID_CP_ACC <= CTRL_I(CTRL_CP_ACC) and CTRL_I(CTRL_CP_RW) and CTRL_I(CTRL_EN) and (not is_priv_mode_v);

			-- CR write access --
			cr_w_acc_v := CTRL_I(CTRL_CP_ACC) and CTRL_I(CTRL_CP_RW) and CTRL_I(CTRL_EN) and is_priv_mode_v;

			-- CR read access --
			cr_r_acc_v := CTRL_I(CTRL_CP_ACC) and (not CTRL_I(CTRL_CP_RW)) and CTRL_I(CTRL_EN);

			if rising_edge(CLK_I) then
				if (RST_I = '1') then
					CP_REG_FILE <= (others => (others => '0')); -- clear all
					CP_REG_FILE(CP_ID_REG_0) <= x"07DC050D"; -- core update date
					CP_REG_FILE(CP_ID_REG_1) <= x"53744E6F";
					CP_REG_FILE(CP_ID_REG_2) <= x"34373838";
					CP_REG_FILE(CP_SYS_CTRL_0)(CSCR0_MBC_15 downto CSCR0_MBC_0) <= x"0100"; -- max cycle length
					CP_REG_FILE(CP_SYS_CTRL_0)(CSCR0_PIO) <= '1'; -- IO area is protected
				else

					-- System Control Register 0 --------------------------------------------------
					if (G_HALT_I = '0') and (cr_w_acc_v = '1') and (cp_adr_v = CP_SYS_CTRL_0) then
						CP_REG_FILE(CP_SYS_CTRL_0) <= MCR_DATA_I;
					else
						CP_REG_FILE(CP_SYS_CTRL_0)(CSCR0_FDC) <= '0'; -- auto-reset flush d-cache
						CP_REG_FILE(CP_SYS_CTRL_0)(CSCR0_CDC) <= '0'; -- auto-reset clear d-cache
						CP_REG_FILE(CP_SYS_CTRL_0)(CSCR0_CIC) <= '0'; -- auto-reset clear i-cache
						CP_REG_FILE(CP_SYS_CTRL_0)(CSCR0_DCS) <= DC_SYNC_I; -- d-cache sync
					end if;

					-- Cache Statistic Register ---------------------------------------------------
					if (IC_MISS_I = '1') then
						CP_REG_FILE(CP_CSTAT)(15 downto 00) <= (others => '0');
					elsif (CP_REG_FILE(CP_CSTAT)(15 downto 00) /= x"FFFF") and (IC_HIT_I = '1') and (G_HALT_I = '0') then
						CP_REG_FILE(CP_CSTAT)(15 downto 00) <= Std_Logic_Vector(unsigned(CP_REG_FILE(CP_CSTAT)(15 downto 00)) + 1);
					end if;
					if (DC_MISS_I = '1') then
						CP_REG_FILE(CP_CSTAT)(31 downto 16) <= (others => '0');
					elsif (CP_REG_FILE(CP_CSTAT)(31 downto 16) /= x"FFFF") and (DC_HIT_I = '1') and (G_HALT_I = '0')  then
						CP_REG_FILE(CP_CSTAT)(31 downto 16) <= Std_Logic_Vector(unsigned(CP_REG_FILE(CP_CSTAT)(31 downto 16)) + 1);
					end if;

					-- Bus Unit Address Feedback --------------------------------------------------
					CP_REG_FILE(CP_BUS_AFB) <= ADR_FEEDBACK_I;

					-- Internal LFSR:: Polynomial Register ----------------------------------------
					if (G_HALT_I = '0') and (cr_w_acc_v = '1') and (cp_adr_v = CP_LFSR_POLY) then
						CP_REG_FILE(CP_LFSR_POLY) <= MCR_DATA_I;
					end if;

					-- Internal LFSR: Shift Register ----------------------------------------------
					if (G_HALT_I = '0') and (cr_w_acc_v = '1') and (cp_adr_v = CP_LFSR_DATA) then
						CP_REG_FILE(CP_LFSR_DATA) <= MCR_DATA_I;
					elsif (CP_REG_FILE(CP_SYS_CTRL_0)(CSCR0_LFSRE) = '1') then
						if ((CP_REG_FILE(CP_SYS_CTRL_0)(CSCR0_LFSRM) = '1') and (cr_r_acc_v = '1')) or
						   (CP_REG_FILE(CP_SYS_CTRL_0)(CSCR0_LFSRM) = '0') then
							if (CP_REG_FILE(CP_SYS_CTRL_0)(CSCR0_LFSRD) = '0') then -- right shift
								CP_REG_FILE(CP_LFSR_DATA) <= LFSR_DN & CP_REG_FILE(CP_LFSR_DATA)(31 downto 1);
							else -- left shift
								CP_REG_FILE(CP_LFSR_DATA) <= CP_REG_FILE(CP_LFSR_DATA)(30 downto 0) & LFSR_DN;
							end if;
						end if;
					end if;

					-- Internal IO Register -------------------------------------------------------
					CP_REG_FILE(CP_IO_PORT)(CP_IO_I_MSB downto CP_IO_I_LSB) <= IO_PORT_I;
					if (G_HALT_I = '0') and (cr_w_acc_v = '1') and (cp_adr_v = CP_IO_PORT) then
						CP_REG_FILE(CP_IO_PORT)(CP_IO_O_MSB downto CP_IO_O_LSB) <= MCR_DATA_I(CP_IO_O_MSB downto CP_IO_O_LSB);
					end if;

				end if;
			end if;
		end process SYS_CP_ACC;

		--- System Control Processor Output ---
		DC_FLUSH_O  <= CP_REG_FILE(CP_SYS_CTRL_0)(CSCR0_FDC);
		DC_CLEAR_O  <= CP_REG_FILE(CP_SYS_CTRL_0)(CSCR0_CDC);
		DC_FRESH_O  <= CP_REG_FILE(CP_SYS_CTRL_0)(CSCR0_DAR);
		CACHED_IO_O <= CP_REG_FILE(CP_SYS_CTRL_0)(CSCR0_CIO);
		PRTCT_IO_O  <= CP_REG_FILE(CP_SYS_CTRL_0)(CSCR0_PIO);
		IC_FRESH_O  <= CP_REG_FILE(CP_SYS_CTRL_0)(CSCR0_IAR);
		IC_CLEAR_O  <= CP_REG_FILE(CP_SYS_CTRL_0)(CSCR0_CIC);
		C_WTHRU_O   <= CP_REG_FILE(CP_SYS_CTRL_0)(CSCR0_CWT);
		BUS_CYCC_O  <= CP_REG_FILE(CP_SYS_CTRL_0)(CSCR0_MBC_15 downto CSCR0_MBC_0);
		IO_PORT_O   <= CP_REG_FILE(CP_IO_PORT)(CP_IO_O_MSB downto CP_IO_O_LSB);

		--- Internal LFSR XOR ---
		LFSR_UPDATE: process(CP_REG_FILE)
			variable lfsr_tmp_v  : std_logic_vector(31 downto 0);
			variable lfsr_d_in_v : std_logic;
		begin
			lfsr_tmp_v  := CP_REG_FILE(CP_LFSR_DATA) and CP_REG_FILE(CP_LFSR_POLY);
			lfsr_d_in_v := '0';
			for i in 0 to 31 loop
				lfsr_d_in_v := lfsr_d_in_v xor lfsr_tmp_v(i);
			end loop;
			LFSR_DN <= lfsr_d_in_v;
		end process LFSR_UPDATE;



	-- MCR / CP Read Access ---------------------------------------------------------------------------
	-- ---------------------------------------------------------------------------------------------------
		MREG_READ_ACCESS: process(CTRL_I, MCR_CMSR, SMSR_FIQ, SMSR_SVC, SMSR_ABT, SMSR_IRQ, SMSR_UND, SMSR_SYS, CP_REG_FILE)
			variable mrd_smsr_v, mrd_csmr_v, mrd_cp_v : std_logic;
		begin
			-- manual SMSR_mode read access request --
			mrd_smsr_v := CTRL_I(CTRL_MREG_ACC) and CTRL_I(CTRL_MREG_M);-- and (not CTRL(CTRL_MREG_RW));
			-- manual CMSR read access request --
			mrd_csmr_v := CTRL_I(CTRL_MREG_ACC) and (not CTRL_I(CTRL_MREG_M));-- and (not CTRL(CTRL_MREG_RW));
			-- coprocessor read --
			mrd_cp_v   := CTRL_I(CTRL_CP_ACC)   and (not CTRL_I(CTRL_CP_RW));

			if (mrd_csmr_v = '1') then --(mrd_csmr_v and CTRL(CTRL_EN)) = '1' then
				MCR_DATA_O <= MCR_CMSR;
			elsif (mrd_smsr_v = '1') then --mrd_smsr_v and CTRL(CTRL_EN)) = '1' then
				case (MCR_CMSR(SREG_MODE_4 downto SREG_MODE_0)) is
					when FIQ32_MODE        => MCR_DATA_O <= SMSR_FIQ;
					when Supervisor32_MODE => MCR_DATA_O <= SMSR_SVC;
					when Abort32_MODE      => MCR_DATA_O <= SMSR_ABT;
					when IRQ32_MODE        => MCR_DATA_O <= SMSR_IRQ;
					when Undefined32_MODE  => MCR_DATA_O <= SMSR_UND;
					when System32_MODE     => MCR_DATA_O <= SMSR_SYS;
					when others            => MCR_DATA_O <= (others => '0');
				end case;
--			elsif (mrd_cp_v = '1') then
			else
				MCR_DATA_O <= CP_REG_FILE(to_integer(unsigned(CTRL_I(CTRL_CP_REG_3 downto CTRL_CP_REG_0))));
--			else
--				MCR_DATA_O <= (others => '0');
			end if;
		end process MREG_READ_ACCESS;



	-- MCR PC Output ----------------------------------------------------------------------------------
	-- ---------------------------------------------------------------------------------------------------
		PC_DELAY_UNIT: process(CLK_I)
		begin
			if rising_edge(CLK_I) then
				if (RST_I = '1') then
					PC_DELAY_BUF <= (others => (others => '0'));
				elsif (G_HALT_I = '0') then
					if (HALT_I = '0') then
						PC_DELAY_BUF(1 downto 0) <= PC_DELAY_BUF(0) & MCR_PC;
					end if;
					PC_DELAY_BUF(6 downto 2) <= PC_DELAY_BUF(5 downto 1);
				end if;
			end if;
		end process PC_DELAY_UNIT;

		--- PC output ---
		INF_PC_O <= MCR_PC;          -- PC value for instruction fetch (i-cache access)
		JMP_PC_O <= PC_DELAY_BUF(0); -- PC value for branch destination calculation
		REG_PC_O <= PC_DELAY_BUF(0); -- PC value for alu operation
		LNK_PC_O <= PC_DELAY_BUF(4); -- PC value for link operation write back



end MC_SYS_STRUCTURE;