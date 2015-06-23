-- #######################################################################################################
-- #                           <<< STORM CORE PROCESSOR by Stephan Nolting >>>                           #
-- # *************************************************************************************************** #
-- #      ~ STORM Core Top Entity ~      | The STORM core is a powerfull 32 bit open source RISC         #
-- #           File Hierarchy            | processor, partly compatible to the ARM architecture.         #
-- # ------------------------------------+ This is the top entity of the core itself. Please refer to    #
-- # Core File Hierarchy:                | the STORM core's data sheet for more information.             #
-- # - CORE.vhd (this file)              |                                                               #
-- #   + STORM_CORE.vhd (package file)   +---------------------------------------------------------------#
-- #   - REG_FILE.vhd                    |                                                               #
-- #   - OPERANT_UNIT.vhd                |   SSSS TTTTT  OOO  RRRR  M   M        CCC  OOO  RRRR  EEEEE   #
-- #   - MS_UNIT.vhd                     |  S       T   O   O R   R MM MM       C    O   O R   R E       #
-- #     - MULTIPLY_UNIT.vhd             |   SSS    T   O   O RRRR  M M M  ###  C    O   O RRRR   EEE    #
-- #   -   BARREL_SHIFTER.vhd            |      S   T   O   O R  R  M   M       C    O   O R  R  E       #
-- #   - ALU.vhd                         |  SSSS    T    OOO  R   R M   M        CCC  OOO  R   R EEEEE   #
-- #   - FLOW_CTRL.vhd                   |                                                               #
-- #   - WB_UNIT.vhd                     +-------------------------------------------------------------- #
-- #   - MC_SYS.vhd                      | The STORM Core Processor was created by Stephan Nolting       #
-- #   - LOAD_STORE_UNIT.vhd             | Published at whttp://opencores.org/project,storm_core         #
-- #   - OPCODE_DECODER.vhd              | Contact me:                                                   #
-- #                                     | -> stnolting@googlemail.com                                   #
-- #                                     | -> stnolting@web.de                                           #
-- # *************************************************************************************************** #
-- # Last modified: 29.04.2012                                                                           #
-- #######################################################################################################

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.STORM_core_package.all;

entity CORE is
-- ###############################################################################################
-- ##       Startup Boot Address                                                                ##
-- ###############################################################################################
	Generic (
				BOOT_VEC        : STD_LOGIC_VECTOR(31 downto 0) := x"00000000"
	        );
    Port (
-- ###############################################################################################
-- ##       Global Control Signals                                                              ##
-- ###############################################################################################

				RES             : in  STD_LOGIC; -- global reset input (high active)
				CLK             : in  STD_LOGIC; -- global clock input

-- ###############################################################################################
-- ##       Status and Control                                                                  ##
-- ###############################################################################################

				HALT            : in  STD_LOGIC;                     -- halt processor
				MODE            : out STD_LOgIC_VECTOR(04 downto 0); -- processor mode

-- ###############################################################################################
-- ##      Data Cache Interface                                                                 ##
-- ###############################################################################################

				D_CACHE_REQ     : out STD_LOGIC;                     -- d-cache access request
				D_CACHE_ADR     : out STD_LOGIC_VECTOR(31 downto 0); -- data address
				D_CACHE_RD_DTA  : in  STD_LOGIC_VECTOR(31 downto 0); -- read data
				D_CACHE_WR_DTA  : out STD_LOGIC_VECTOR(31 downto 0); -- write data
				D_CACHE_DQ      : out STD_LOGIC_VECTOR(01 downto 0); -- data transfer quantity
				D_CACHE_RW      : out STD_LOGIC;                     -- read/write
				D_CACHE_ABORT   : in  STD_LOGIC;                     -- access abort request
				D_CACHE_CLEAR   : out STD_LOGIC;                     -- clear d-cache
				D_CACHE_FLUSH   : out STD_LOGIC;                     -- flush d-cache
				D_CACHE_MISS    : in  STD_LOGIC;                     -- d-cache miss
				D_CACHE_HIT     : in  STD_LOGIC;                     -- d-cache hit
				D_CACHE_FRESH   : out STD_LOGIC;                     -- refresh d-cache
				D_CACHE_CIO     : out STD_LOGIC;                     -- enable cached IO
				IO_PROTECT_O    : out STD_LOGIC;                     -- protected IO
				D_CACHE_SYNC    : in  STD_LOGIC;                     -- cache is sync

-- ###############################################################################################
-- ##      Instruction Cache Interface                                                          ##
-- ###############################################################################################

				I_CACHE_REQ     : out STD_LOGIC;                     -- i-cache access request
				I_CACHE_ADR     : out STD_LOGIC_VECTOR(31 downto 0); -- instruction address
				I_CACHE_RD_DTA  : in  STD_LOGIC_VECTOR(31 downto 0); -- read data
				I_CACHE_ABORT   : in  STD_LOGIC;                     -- access abort request
				I_CACHE_CLEAR   : out STD_LOGIC;                     -- clear i-cache
				I_CACHE_MISS    : in  STD_LOGIC;                     -- i-cache miss
				I_CACHE_HIT     : in  STD_LOGIC;                     -- i-cache hit
				I_CACHE_FRESH   : out STD_LOGIC;                     -- refresh i-cache

-- ###############################################################################################
-- ##      General Control Lines                                                                ##
-- ###############################################################################################

				C_BUS_CYCC_O    : out STD_LOGIC_VECTOR(15 downto 0); -- max bus cycle length
				C_WTHRU_O       : out STD_LOGIC;                     -- write through
				IO_PORT_OUT     : out STD_LOGIC_VECTOR(15 downto 0); -- direct output
				IO_PORT_IN      : in  STD_LOGIC_VECTOR(15 downto 0); -- direct input
				ADR_FEEDBACK_I  : in  STD_LOGIC_VECTOR(31 downto 0); -- address feedback for exceptions

-- ###############################################################################################
-- ##      Interrupt Interface                                                                  ##
-- ###############################################################################################

				IRQ             : in  STD_LOGIC; -- interrupt request
				FIQ             : in  STD_LOGIC  -- fast interrupt request
			 );
end CORE;

architecture CORE_STRUCTURE of CORE is

	-- ###############################################################################################
	-- ##           Internal Signals                                                                ##
	-- ###############################################################################################

	signal ALU_FLAGS        : STD_LOGIC_VECTOR(03 downto 0);       -- CMSR/SMSR flag bits
	signal CMSR             : STD_LOGIC_VECTOR(31 downto 0);       -- current machine status register
	signal MCR_DTA_RD       : STD_LOGIC_VECTOR(31 downto 0);       -- machine control register read data
	signal MCR_DTA_WR       : STD_LOGIC_VECTOR(31 downto 0);       -- machine control register write data
	signal IMMEDIATE        : STD_LOGIC_VECTOR(31 downto 0);       -- immediate value
	signal OP_ADR           : STD_LOGIC_VECTOR(14 downto 0);       -- operand register adresses and enables
	signal MS_CTRL          : STD_LOGIC_VECTOR(CTRL_MSB downto 0); -- multishifter control lines
	signal BP_MS            : STD_LOGIC_VECTOR(31 downto 0);       -- multishifter bypass
	signal OP_A_MS          : STD_LOGIC_VECTOR(31 downto 0);       -- operand A for multishifter
	signal OP_B_MS          : STD_LOGIC_VECTOR(31 downto 0);       -- operand B for multishifter
	signal MS_CARRY         : STD_LOGIC;                           -- multishifter carry output
	signal MS_OVFL          : STD_LOGIC;                           -- multishifter overflow output
	signal MS_FW_PATH       : STD_LOGIC_VECTOR(FWD_MSB downto 0);  -- multishifter forwarding bus
	signal WB_FW_PATH       : STD_LOGIC_VECTOR(FWD_MSB downto 0);  -- write back unit forwarding bus
	signal gCLK             : STD_LOGIC;                           -- global clock line
	signal gRES             : STD_LOGIC;                           -- global reset line
	signal G_HALT           : STD_LOGIC;                           -- gloabl halt line
	signal INT_EXECUTE      : STD_LOGIC;                           -- execute interrupt
	signal HALT_BUS         : STD_LOGIC_VECTOR(02 downto 0);       -- temporal data dependencie bus
	signal OF_CTRL          : STD_LOGIC_VECTOR(CTRL_MSB downto 0); -- OF stage control lines
	signal OF_OP_A          : STD_LOGIC_VECTOR(31 downto 0);       -- operant A
	signal OF_OP_B          : STD_LOGIC_VECTOR(31 downto 0);       -- operant B
	signal OF_OP_C          : STD_LOGIC_VECTOR(31 downto 0);       -- operant C
	signal PC_HALT          : STD_LOGIC;                           -- halt instruction fetch
	signal OF_OP_A_OUT      : STD_LOGIC_VECTOR(31 downto 0);       -- operand A output
	signal OF_OP_B_OUT      : STD_LOGIC_VECTOR(31 downto 0);       -- operand B output
	signal OF_BP1_OUT       : STD_LOGIC_VECTOR(31 downto 0);       -- bypass 1 output
	signal SHIFT_VAL        : STD_LOGIC_VECTOR(04 downto 0);       -- shift value
	signal OPC_A            : STD_LOGIC_VECTOR(15 downto 0);       -- opcode decoder input
	signal OPC_B            : STD_LOGIC_VECTOR(CTRL_MSB downto 0); -- opcode decoder output
	signal OPC_C            : STD_LOGIC_VECTOR(99 downto 0);       -- opcode decoder output
	signal OP_DATA          : STD_LOGIC_VECTOR(31 downto 0);       -- opcode decoder INSTR input
	signal EX1_CTRL         : STD_LOGIC_VECTOR(CTRL_MSB downto 0); -- EX stage control lines
	signal EX_BP1_OUT       : STD_LOGIC_VECTOR(31 downto 0);       -- bypass 1 register
	signal ALU_FW_PATH      : STD_LOGIC_VECTOR(FWD_MSB downto 0);  -- alu forwarding path
	signal EX_ADR_OUT       : STD_LOGIC_VECTOR(31 downto 0);       -- ex stage address output for data mem access
	signal EX_RES_OUT       : STD_LOGIC_VECTOR(31 downto 0);       -- ex stage result output
	signal MEM_CTRL         : STD_LOGIC_VECTOR(CTRL_MSB downto 0); -- MEM stage control lines
	signal MEM_ADR_OUT      : STD_LOGIC_VECTOR(31 downto 0);       -- mem_data address bypass
	signal MEM_BP_OUT       : STD_LOGIC_VECTOR(31 downto 0);       -- mem_data and bp2 register
	signal MEM_FW_PATH      : STD_LOGIC_VECTOR(FWD_MSB downto 0);  -- memory forwarding path
	signal REG_PC           : STD_LOGIC_VECTOR(31 downto 0);       -- PC value for manual operations
	signal JMP_PC           : STD_LOGIC_VECTOR(31 downto 0);       -- PC value for branches
	signal LNK_PC           : STD_LOGIC_VECTOR(31 downto 0);       -- PC value for linking
	signal INF_PC           : STD_LOGIC_VECTOR(31 downto 0);       -- PC value instruction fetch
	signal WB_CTRL          : STD_LOGIC_VECTOR(CTRL_MSB downto 0); -- WB stage control lines
	signal WB_DATA_LINE     : STD_LOGIC_VECTOR(31 downto 0);       -- data write back line
	signal MCR_STOP_IF      : STD_LOGIC;                           -- stop instruction fetch
	signal PIPE_EMPTY       : STD_LOGIC;                           -- pipeline is empty
	signal D_MEM_MODE       : STD_LOGIC_VECTOR(04 downto 0);       -- mode for data mem access
	signal PC_INJECT        : STD_LOGIC;                           -- load pc with data from wb stage

begin
	-- Global CLOCK, RESET and HALT Networks -----------------------------------------------------
	-- ----------------------------------------------------------------------------------------------
		gCLK   <= CLK;
		gRES   <= RES;
		G_HALT <= HALT; -- maybe try clock gating?!



	-- 32-bit Opcode Decoder ---------------------------------------------------------------------
	-- ----------------------------------------------------------------------------------------------
		Instruction_Decoder: OPCODE_DECODER
			port map	(
							OPCODE_DATA_I    => OP_DATA,        -- current instruction word
							OPCODE_CTRL_I    => OPC_A,          -- control feedback input
							OPCODE_CTRL_O    => OPC_B,          -- control lines output
							OPCODE_MISC_O    => OPC_C
						);



	-- Operation Flow Control --------------------------------------------------------------------
	-- ----------------------------------------------------------------------------------------------
		Operation_Flow_Control: FLOW_CTRL
			port map	(
							RST_I            => gRES,           -- global active high reset
							CLK_I            => gCLK,           -- global clock net
							G_HALT_I         => G_HALT,         -- global halt signal
							INSTR_I          => I_CACHE_RD_DTA, -- instruction input
							INST_MREQ_O      => I_CACHE_REQ,    -- instr fetch memory request
							OPCODE_DATA_O    => OP_DATA,        -- instruction register output
							OPCODE_CTRL_I    => OPC_B,          -- control lines input
							OPCODE_MISC_I    => OPC_C,          -- immediate and operand adr stuff
							OPCODE_CTRL_O    => OPC_A,          -- control feedback output
							PC_HALT_O        => PC_HALT,        -- halt instruction fetch output
							SREG_I           => CMSR,           -- current machine status register
							EXECUTE_INT_I    => INT_EXECUTE,    -- execute int req
							STOP_IF_I        => MCR_STOP_IF,    -- stop new instruction fetch
							HOLD_BUS_I       => HALT_BUS,       -- number of bubbles
							EMPTY_PIPE_O     => PIPE_EMPTY,     -- pipeline is empty
							PC_INJECT_O      => PC_INJECT,      -- pc load from memory
							OP_ADR_O         => OP_ADR,         -- operand register addresses
							IMM_O            => IMMEDIATE,      -- immediate output
							OF_CTRL_O        => OF_CTRL,        -- stage control OF
							MS_CTRL_O        => MS_CTRL,        -- stage control MS
							EX1_CTRL_O       => EX1_CTRL,       -- stage control EX
							MEM_CTRL_O       => MEM_CTRL,       -- stage control MA
							WB_CTRL_O        => WB_CTRL         -- stage control WB
						);



	-- Machine Control/Status System -------------------------------------------------------------
	-- ----------------------------------------------------------------------------------------------
		Machine_Control_System: MC_SYS
			generic map (
							BOOT_VEC        => BOOT_VEC         -- bootlvector address
			            )
			port map	(
							CLK_I           => gCLK,            -- global clock net
							G_HALT_I        => G_HALT,          -- global halt signal
							RST_I           => gRES,            -- global active high reset
							CTRL_I          => EX1_CTRL,        -- stage control
							HALT_I          => PC_HALT,         -- halt program counter
							PEND_XI_REQ_O   => MCR_STOP_IF,     -- pending ext. int request
							INT_TKN_O       => INT_EXECUTE,     -- execute interrupt output
							EMPTY_PIPE_I    => PIPE_EMPTY,      -- pipeline is empty
							FLAG_I          => ALU_FLAGS,       -- alu flags input
							CMSR_O          => CMSR,            -- current machine status register
							REG_PC_O        => REG_PC,          -- PC value for manual operations
							JMP_PC_O        => JMP_PC,          -- PC value for branches
							LNK_PC_O        => LNK_PC,          -- PC value for linking
							INF_PC_O        => INF_PC,          -- PC value for instruction fetch
							MCR_DATA_I      => MCR_DTA_WR,      -- mcr write data input
							MCR_DATA_O      => MCR_DTA_RD,      -- mcr read data output
							PC_INJECT_I     => PC_INJECT,       -- pc load from memory
							PC_INJECT_D_I   => WB_DATA_LINE,    -- write back data
							EX_FIQ_I        => FIQ,             -- external fast interrupt request
							EX_IRQ_I        => IRQ,             -- external interrupt request
							EX_DAB_I        => D_CACHE_ABORT,   -- external D memory abort request
							EX_IAB_I        => I_CACHE_ABORT,   -- external I memory abort request
							BUS_CYCC_O      => C_BUS_CYCC_O,    -- bus timeout value
							DC_FLUSH_O      => D_CACHE_FLUSH,   -- flush d-cache
							DC_CLEAR_O      => D_CACHE_CLEAR,   -- clear d-cache
							DC_HIT_I        => D_CACHE_HIT,     -- d-cache hit access
							DC_MISS_I       => D_CACHE_MISS,    -- d-cache miss acess
							DC_FRESH_O      => D_CACHE_FRESH,   -- d-cache auto-refresh
							IC_FRESH_O      => I_CACHE_FRESH,   -- i-cache auto-refresh
							IC_CLEAR_O      => I_CACHE_CLEAR,   -- clear i-cache
							IC_HIT_I        => I_CACHE_HIT,     -- i-cache hit access
							IC_MISS_I       => I_CACHE_MISS,    -- i-cache miss accessear i-cache
							C_WTHRU_O       => C_WTHRU_O,       -- write through
							CACHED_IO_O     => D_CACHE_CIO,     -- en cached IO
							PRTCT_IO_O      => IO_PROTECT_O,    -- protected IO
							DC_SYNC_I       => D_CACHE_SYNC,    -- d-cache is sync
							IO_PORT_O       => IO_PORT_OUT,     -- direct output
							IO_PORT_I       => IO_PORT_IN,      -- direct input
							ADR_FEEDBACK_I  => ADR_FEEDBACK_I   -- adr feedback for exception handling
						);



	-- External Interface ------------------------------------------------------------------------
	-- ----------------------------------------------------------------------------------------------
		I_CACHE_ADR <= INF_PC;
		MODE        <= D_MEM_MODE;--CMSR(SREG_MODE_4 downto SREG_MODE_0);



	-- Data Register File ------------------------------------------------------------------------
	-- ----------------------------------------------------------------------------------------------
		Register_File: REG_FILE
			port map	(
							CLK_I           => gCLK,            -- global clock net
							G_HALT_I        => G_HALT,          -- global halt signal
							RST_I           => gRES,            -- global active high reset
							CTRL_I          => WB_CTRL,         -- stage control
							OP_ADR_I        => OP_ADR,          -- operand addresses
							MODE_I          => CMSR(SREG_MODE_4 downto SREG_MODE_0), -- current processor mode
							USR_RD_I        => OF_CTRL(CTRL_RD_USR), -- read data from USR reg bank
							WB_DATA_I       => WB_DATA_LINE,    -- write back bus
							REG_PC_I        => REG_PC,          -- PC for manual operations
							OP_A_O          => OF_OP_A,         -- register A output
							OP_B_O          => OF_OP_B,         -- register B output
							OP_C_O          => OF_OP_C          -- register C output
						);



	-- Operand Fetch Unit & Dependencie Detector -------------------------------------------------
	-- ----------------------------------------------------------------------------------------------
		Operand_Fetch_Unit: OPERAND_UNIT
			port map	(
							CTRL_I          => OF_CTRL,         -- stage flow control
							OP_ADR_I        => OP_ADR,          -- register operand address
							OP_A_I          => OF_OP_A,         -- register A input
							OP_B_I          => OF_OP_B,         -- register B input
							OP_C_I          => OF_OP_C,         -- register C input
							JMP_PC_I        => JMP_PC,          -- PC value for branches
							IMM_I           => IMMEDIATE,       -- immediate value
							OP_A_O          => OF_OP_A_OUT,     -- operand A data output
							OP_B_O          => OF_OP_B_OUT,     -- operant B data output
							SHIFT_VAL_O     => SHIFT_VAL,       -- shift operand output
							BP1_O           => OF_BP1_OUT,      -- bypass data output
							HOLD_BUS_O      => HALT_BUS,        -- insert n bubbles
							MSU_FW_I        => MS_FW_PATH,      -- ms forwarding path
							ALU_FW_I        => ALU_FW_PATH,     -- alu forwarding path
							MEM_FW_I        => MEM_FW_PATH,     -- memory forwarding path
							WB_FW_I         => WB_FW_PATH       -- write back forwarding path
						);



	-- Multiplicator and BArrelshifter Unit ------------------------------------------------------
	-- ----------------------------------------------------------------------------------------------
		Multishifter: MS_UNIT
			port map	(
							CLK_I           => gCLK,            -- global clock line
							G_HALT_I        => G_HALT,          -- global halt signal
							RST_I           => gRES,            -- global reset line
							CTRL_I          => MS_CTRL,         -- stage control
							OP_A_I          => OF_OP_A_OUT,     -- operant a input
							OP_B_I          => OF_OP_B_OUT,     -- operant b input
							BP_I            => OF_BP1_OUT,      -- bypass input
							CARRY_I         => CMSR(SREG_C_FLAG), -- carry input
							SHIFT_V_I       => SHIFT_VAL,       -- shift value in
							OP_A_O          => OP_A_MS,         -- operant a bypass output
							BP_O            => BP_MS,           -- bypass output
							RESULT_O        => OP_B_MS,         -- operation result
							CARRY_O         => MS_CARRY,        -- operation carry signal
							OVFL_O          => MS_OVFL,         -- operation overflow signal
							MSU_FW_O        => MS_FW_PATH       -- forwarding path
						);



	-- Arithmetical/Logical Unit -----------------------------------------------------------------
	-- ----------------------------------------------------------------------------------------------
		Operator: ALU
			port map	(
							CLK_I           => gCLK,            -- global clock net
							G_HALT_I        => G_HALT,          -- global halt signal
							RST_I           => gRES,            -- global active high reset
							CTRL_I          => EX1_CTRL,        -- stage control
							OP_A_I          => OP_A_MS,         -- operand A input
							OP_B_I          => OP_B_MS,         -- operant B input
							BP1_I           => BP_MS,           -- bypass data input
							BP1_O           => EX_BP1_OUT,      -- bypass data output
							ADR_O           => EX_ADR_OUT,      -- memory access address
							RESULT_O        => EX_RES_OUT,      -- EX result data
							FLAG_I          => CMSR(31 downto 28), -- sreg alu flags input
							FLAG_O          => ALU_FLAGS,       -- alu flags output
							MS_CARRY_I      => MS_CARRY,        -- ms carry output
							MS_OVFL_I       => MS_OVFL,         -- ms overflow output
							MCR_DTA_O       => MCR_DTA_WR,      -- mcr write data output
							MCR_DTA_I       => MCR_DTA_RD,      -- mcr read data input
							ALU_FW_O        => ALU_FW_PATH      -- alu forwarding path
						);



	-- Memory Access System ----------------------------------------------------------------------
	-- ----------------------------------------------------------------------------------------------
		Memory_Access: LOAD_STORE_UNIT
			port map	(
							CLK_I           => gCLK,            -- global clock net
							G_HALT_I        => G_HALT,          -- global halt signal
							RST_I           => gRES,            -- global reset net
							CTRL_I          => MEM_CTRL,        -- stage control
							MEM_DATA_I      => EX_RES_OUT,      -- EX data result
							MEM_ADR_I       => EX_ADR_OUT,      -- memory access address
							MEM_BP_I        => EX_BP1_OUT,      -- bp/write data input
							MODE_I          => CMSR(SREG_MODE_4 downto SREG_MODE_0), -- current processor mode
							LNK_PC_I        => LNK_PC,          -- pc for link operations
							ADR_O           => MEM_ADR_OUT,     -- address bypass output
							BP_O            => MEM_BP_OUT,      -- bypass(data) output
							LDST_FW_O       => MEM_FW_PATH,     -- memory forwarding path
							XMEM_MODE_O     => D_MEM_MODE,      -- processor mode for access
							XMEM_ADR_O      => D_CACHE_ADR,     -- D memory address output
							XMEM_WR_DTA_O   => D_CACHE_WR_DTA,  -- memory write data output
							XMEM_ACC_REQ_O  => D_CACHE_REQ,     -- access request
							XMEM_RW_O       => D_CACHE_RW,      -- read/write
							XMEM_DQ_O       => D_CACHE_DQ       -- memory data quantity
						);



	-- Data Write-Back System --------------------------------------------------------------------
	-- ----------------------------------------------------------------------------------------------
		Data_Write_Back: WB_UNIT
			port map	(
							CLK_I           => gCLK,            -- global clock net
							G_HALT_I        => G_HALT,          -- global halt signal
							RST_I           => gRES,            -- global reset net
							CTRL_I          => WB_CTRL,         -- stage control
							ALU_DATA_I      => MEM_BP_OUT,      -- alu data input
							ADR_BUFF_I      => MEM_ADR_OUT,     -- address bypass input 
							WB_DATA_O       => WB_DATA_LINE,    -- data write back line
							XMEM_RD_DATA_I  => D_CACHE_RD_DTA,  -- memory read data
							WB_FW_O         => WB_FW_PATH       -- forwarding path
						);
	
end CORE_STRUCTURE;