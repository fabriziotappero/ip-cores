-- #######################################################
-- #             STORM Core System package               #
-- #         Created by Stephan Nolting (4788)           #
-- # +-------------------------------------------------+ #
-- #  This file contains all needed components and       #
-- #  system parameters for the STORM Core processor.    #
-- # +-------------------------------------------------+ #
-- # Last modified: 03.05.2012                           #
-- #######################################################

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package STORM_core_package is

  -- ARCHITECTURE CONSTANTS -----------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
	constant STORM_MODE       : boolean := FALSE; -- use STORM extension architecture
	constant USE_BIG_ENDIAN   : boolean := TRUE;  -- use big endian memory
	constant DATA_WIDTH       : natural := 32;    -- operation data width
	constant SHIN_EN          : boolean := FALSE; -- enable short instruction mode
	constant NOP_CMD          : STD_LOGIC_VECTOR(31 downto 00) := x"F0013007"; -- Dummy OPCODE

  -- DUMMY CYCLES FOR TEMPORAL PIPELINE CONFLICTS -------------------------------------------
  -- -------------------------------------------------------------------------------------------
 	constant DC_TAKEN_BRANCH  : natural := 2; -- empty cycles after taken branch
	constant OF_MS_REG_DD     : natural := 1; -- of-ms reg/reg conflict
	constant OF_WB_MEM_DD     : natural := 1; -- of-wb reg/mem conflict
	constant OF_EX_MEM_DD     : natural := 2; -- of-ex reg/mem conflict
	constant OF_MS_MEM_DD     : natural := 3; -- of-ms reg/mem conflict

  -- ADDRESS CONSTANTS ----------------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
	constant C_SP_ADR         : STD_LOGIC_VECTOR(3 downto 0) := "1101"; -- Stack Pointer = R13
	constant C_LR_ADR         : STD_LOGIC_VECTOR(3 downto 0) := "1110"; -- Link Register = R14
	constant C_PC_ADR         : STD_LOGIC_VECTOR(3 downto 0) := "1111"; -- Prog. Counter = R15
	constant SYS_CP_ADR       : STD_LOGIC_VECTOR(3 downto 0) := "1111"; -- system coprocessor

  -- WISHBONE CYCLE TYPES -------------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
	constant WB_CLASSIC_CYC   : STD_LOGIC_VECTOR(2 downto 0) := "000"; -- classic cycle
	constant WB_CON_BST_CYC   : STD_LOGIC_VECTOR(2 downto 0) := "001"; -- constant address burst
	constant WB_INC_BST_CYC   : STD_LOGIC_VECTOR(2 downto 0) := "010"; -- incrementing address burst
	constant WB_BST_END_CYC   : STD_LOGIC_VECTOR(2 downto 0) := "111"; -- burst end

  -- OPERAND ADR BUS LOCATIONS --------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
	constant OP_A_ADR_0       : natural :=  0; -- OP A ADR LSB
	constant OP_A_ADR_3       : natural :=  3; -- OP A ADR MSB
	constant OP_B_ADR_0       : natural :=  4; -- OP B ADR LSB
	constant OP_B_ADR_3       : natural :=  7; -- OP B ADR MSB
	constant OP_C_ADR_0       : natural :=  8; -- OP C ADR LSB
	constant OP_C_ADR_3       : natural := 11; -- OP C ADR MSB
	constant OP_A_IS_REG      : natural := 12; -- OP A is a reg adr
	constant OP_B_IS_REG      : natural := 13; -- OP B is a reg adr
	constant OP_C_IS_REG      : natural := 14; -- OP C is a reg adr

  -- OPERAND CONSTANTS ----------------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
	constant RD               : STD_LOGIC := '0';
	constant WR               : STD_LOGIC := '1';
	constant DQ_WORD          : STD_LOGIC_VECTOR(1 downto 0) := "00";
	constant DQ_BYTE          : STD_LOGIC_VECTOR(1 downto 0) := "01";
	constant DQ_HALFWORD      : STD_LOGIC_VECTOR(1 downto 0) := "10"; -- "11"

  -- FORWARDING BUS LOCATIONS ---------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
	constant FWD_DATA_LSB     : natural :=  0; -- Forwardind Data Bit 0
	constant FWD_DATA_MSB     : natural := 31; -- Forwarding Data Bit 31
	constant FWD_RD_LSB       : natural := 32; -- Destination Adr Bit 0
	constant FWD_RD_MSB       : natural := 35; -- Destination Adr Bit 3
	constant FWD_WB           : natural := 36; -- Data in stage will be written back to reg
	constant FWD_MCR_MOD      : natural := 37; -- machine control register will be modified
	constant FWD_FLAG_MOD     : natural := 38; -- sreg flags will be modified
	constant FWD_MCR_R_ACC    : natural := 39; -- MCR Read Access
	constant FWD_MEM_R_ACC    : natural := 40; -- Memory Read Access
	constant FWD_MEM_PC_LD    : natural := 41; -- pc load from memory
	constant FWD_MSB          : natural := 41; -- width of forwarding bus

  -- CTRL BUS LOCATIONS ---------------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
	constant CTRL_EN          : natural :=  0; -- stage enable
	constant CTRL_CONST       : natural :=  1; -- is immediate value
	constant CTRL_BRANCH      : natural :=  2; -- branch control
	constant CTRL_LINK        : natural :=  3; -- link
	constant CTRL_SHIFTR      : natural :=  4; -- use register shift offset
	constant CTRL_WB_EN	      : natural :=  5; -- write back enable

	constant CTRL_RD_0        : natural :=  6; -- destination register adr bit 0
	constant CTRL_RD_1        : natural :=  7; -- destination register adr bit 1
	constant CTRL_RD_2        : natural :=  8; -- destination register adr bit 2
	constant CTRL_RD_3        : natural :=  9; -- destination register adr bit 3

	constant CTRL_SWI         : natural := 10; -- software interrupt
	constant CTRL_UND         : natural := 11; -- undefined instruction interrupt

	constant CTRL_COND_0      : natural := 12; -- condition code bit 0
	constant CTRL_COND_1      : natural := 13; -- condition code bit 1
	constant CTRL_COND_2      : natural := 14; -- condition code bit 2
	constant CTRL_COND_3      : natural := 15; -- condition code bit 3

	constant CTRL_MS          : natural := 16; -- '0' = shift, '1' = multiply
	constant CTRL_AF          : natural := 17; -- alter flags / reload cmsr
	constant CTRL_ALU_FS_0    : natural := 18; -- alu function set bit 0
	constant CTRL_ALU_FS_1    : natural := 19; -- alu function set bit 1
	constant CTRL_ALU_FS_2    : natural := 20; -- alu function set bit 2
	constant CTRL_ALU_FS_3    : natural := 21; -- alu function set bit 3

	constant CTRL_MEM_ACC     : natural := 22; -- '1' = Access memory
	constant CTRL_MEM_DQ_0    : natural := 23; -- '0' = word, '1' = byte
	constant CTRL_MEM_DQ_1    : natural := 24; -- '0' = see above, '1' = halfword
	constant CTRL_MEM_SE      : natural := 25; -- '0' = no sign extension, '1' = sign extension
	constant CTRL_MEM_RW      : natural := 26; -- '0' = read, '1' = write

	constant CTRL_RD_USR      : natural := 27; -- '1' = read data from USR reg bank
	constant CTRL_WR_USR      : natural := 28; -- '1' = write fata to USR reg bank

	constant CTRL_MREG_ACC    : natural := 29; -- '1' = Access machine register file
	constant CTRL_MREG_M      : natural := 30; -- '0' = CMSR, '1' = SMSR
	constant CTRL_MREG_RW     : natural := 31; -- '0' = read, '1' = write
	constant CTRL_MREG_FA     : natural := 32; -- '0' = whole access, '1' = flag access

	constant CTRL_CP_ACC      : natural := 33; -- '1' coprocessor access
	constant CTRL_CP_RW       : natural := 34; -- '0' read, '1' = write
	constant CTRL_CP_REG_0    : natural := 35; -- cp register address bit 0
	constant CTRL_CP_REG_1    : natural := 36; -- cp register address bit 1
	constant CTRL_CP_REG_2    : natural := 37; -- cp register address bit 2
	constant CTRL_CP_REG_3    : natural := 38; -- cp register address bit 3

	constant CTRL_SHIFT_M_0   : natural := 39; -- shift mode bit 0
	constant CTRL_SHIFT_M_1   : natural := 40; -- shift mode bit 1
	constant CTRL_SHIFT_V_0   : natural := 41; -- shift value bit 0
	constant CTRL_SHIFT_V_1   : natural := 42; -- shift value bit 1
	constant CTRL_SHIFT_V_2   : natural := 43; -- shift value bit 2
	constant CTRL_SHIFT_V_3   : natural := 44; -- shift value bit 3
	constant CTRL_SHIFT_V_4   : natural := 45; -- shift value bit 4

	constant CTRL_BX          : natural := 46; -- is branch and exchange operation

	constant CTRL_MSB         : natural := 46; -- size of control bus

	-- Progress Redefinitions --
	constant CTRL_MODE_0      : natural := CTRL_AF;       -- mode bit 0
	constant CTRL_MODE_1      : natural := CTRL_ALU_FS_0; -- mode bit 1
	constant CTRL_MODE_2      : natural := CTRL_ALU_FS_1; -- mode bit 2
	constant CTRL_MODE_3      : natural := CTRL_ALU_FS_2; -- mode bit 3
	constant CTRL_MODE_4      : natural := CTRL_ALU_FS_3; -- mode bit 4

  -- SREG BIT LOCATIONS ---------------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
	constant SREG_MODE_0      : natural :=  0; -- mode bit 0
	constant SREG_MODE_1      : natural :=  1; -- mode bit 1
	constant SREG_MODE_2      : natural :=  2; -- mode bit 2
	constant SREG_MODE_3      : natural :=  3; -- mode bit 3
	constant SREG_MODE_4      : natural :=  4; -- mode bit 4
	constant SREG_SHIN_M      : natural :=  5; -- short instruction mode
	constant SREG_FIQ_DIS     : natural :=  6; -- disable FIQ
	constant SREG_IRQ_DIS     : natural :=  7; -- disable IRQ
	constant SREG_DAB_DIS     : natural :=  8; -- disable data fetch abort
	constant SREG_IAB_DIS     : natural :=  9; -- disable instruction fetch abort

	constant SREG_O_FLAG      : natural := 28; -- overflow flag
	constant SREG_C_FLAG      : natural := 29; -- carry flag
	constant SREG_Z_FLAG      : natural := 30; -- zero flag
	constant SREG_N_FLAG      : natural := 31; -- negative flag

  -- INTERNAL COPROCESSOR REGISTERS ---------------------------------------------------------
  -- ------------------------------------------------------------------------------------------- 
	constant CP_ID_REG_0      : natural :=  0; -- ID register 0
	constant CP_ID_REG_1      : natural :=  1; -- ID register 1
	constant CP_ID_REG_2      : natural :=  2; -- ID register 2

	constant CP_SYS_CTRL_0    : natural :=  6; -- system control register 0

	constant CP_CSTAT         : natural :=  8; -- cache statistics register
	constant CP_BUS_AFB       : natural :=  9; -- bus unit adr feedback

	constant CP_LFSR_POLY     : natural := 11; -- Internal lfsr, polynomial
	constant CP_LFSR_DATA     : natural := 12; -- Internal lfsr, shift register
	constant CP_IO_PORT       : natural := 13; -- Internal IO port

  -- INTERNAL IO PORT REGISTER --------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
	constant CP_IO_O_LSB      : natural :=  0; -- output LSB
	constant CP_IO_O_MSB      : natural := 15; -- output MSB
	constant CP_IO_I_LSB      : natural := 16; -- input LSB
	constant CP_IO_I_MSB      : natural := 31; -- input MSB

  -- SYSTEM CONTROL REGISTER 0 --------------------------------------------------------------
  -- ------------------------------------------------------------------------------------------- 
	constant CSCR0_FDC        : natural :=  0; -- flush d-cache
	constant CSCR0_CDC        : natural :=  1; -- clear d-cache
	constant CSCR0_CIC        : natural :=  2; -- flush i-cache
	constant CSCR0_CWT        : natural :=  3; -- d-cache write-thru enable
	constant CSCR0_DAR        : natural :=  4; -- d-cache "read through"
	constant CSCR0_IAR        : natural :=  5; -- i-cache "read through"
	constant CSCR0_CIO        : natural :=  6; -- enable cached IO
	constant CSCR0_PIO        : natural :=  7; -- protected IO
	constant CSCR0_DCS        : natural :=  8; -- d-cache is sync

	constant CSCR0_LFSRE      : natural := 13; -- internal LFSR enable
	constant CSCR0_LFSRM      : natural := 14; -- internal LFSR update mode (0:auto/1:access)
	constant CSCR0_LFSRD      : natural := 15; -- internal LFSR direction (0:right/1:left))
	constant CSCR0_MBC_0      : natural := 16; -- max bus cycle length bit 0
	constant CSCR0_MBC_15     : natural := 31; -- max bus cycle length bit 15

  -- INTERRUPT VECTORS ----------------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
	constant RES_INT_VEC      : STD_LOGIC_VECTOR(4 downto 0) := "00000"; -- hardware reset
	constant UND_INT_VEC      : STD_LOGIC_VECTOR(4 downto 0) := "00100"; -- going to Undefined32_MODE
	constant SWI_INT_VEC      : STD_LOGIC_VECTOR(4 downto 0) := "01000"; -- going to Supervisor32_MODE
	constant PRF_INT_VEC      : STD_LOGIC_VECTOR(4 downto 0) := "01100"; -- going to Abort32_MODE
	constant DAT_INT_VEC      : STD_LOGIC_VECTOR(4 downto 0) := "10000"; -- going to Abort32_MODE
	constant IRQ_INT_VEC      : STD_LOGIC_VECTOR(4 downto 0) := "11000"; -- going to IRQ32_MODE
	constant FIQ_INT_VEC      : STD_LOGIC_VECTOR(4 downto 0) := "11100"; -- going to FIQ32_MODE

  -- PROCESSOR MODE CODES -------------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
	constant User32_MODE      : STD_LOGIC_VECTOR(4 downto 0) := "10000";
	constant FIQ32_MODE       : STD_LOGIC_VECTOR(4 downto 0) := "10001";
	constant IRQ32_MODE       : STD_LOGIC_VECTOR(4 downto 0) := "10010";
	constant Supervisor32_MODE: STD_LOGIC_VECTOR(4 downto 0) := "10011";
	constant Abort32_MODE     : STD_LOGIC_VECTOR(4 downto 0) := "10111";
	constant Undefined32_MODE : STD_LOGIC_VECTOR(4 downto 0) := "11011";
	constant System32_MODE    : STD_LOGIC_VECTOR(4 downto 0) := "11111";

  -- CONDITION OPCODES ----------------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
	constant COND_EQ          : STD_LOGIC_VECTOR(3 downto 0) := "0000";
	constant COND_NE          : STD_LOGIC_VECTOR(3 downto 0) := "0001";
	constant COND_CS          : STD_LOGIC_VECTOR(3 downto 0) := "0010";
	constant COND_CC          : STD_LOGIC_VECTOR(3 downto 0) := "0011";
	constant COND_MI          : STD_LOGIC_VECTOR(3 downto 0) := "0100";
	constant COND_PL          : STD_LOGIC_VECTOR(3 downto 0) := "0101";
	constant COND_VS          : STD_LOGIC_VECTOR(3 downto 0) := "0110";
	constant COND_VC          : STD_LOGIC_VECTOR(3 downto 0) := "0111";
	constant COND_HI          : STD_LOGIC_VECTOR(3 downto 0) := "1000";
	constant COND_LS          : STD_LOGIC_VECTOR(3 downto 0) := "1001";
	constant COND_GE          : STD_LOGIC_VECTOR(3 downto 0) := "1010";
	constant COND_LT          : STD_LOGIC_VECTOR(3 downto 0) := "1011";
	constant COND_GT          : STD_LOGIC_VECTOR(3 downto 0) := "1100";
	constant COND_LE          : STD_LOGIC_VECTOR(3 downto 0) := "1101";
	constant COND_AL          : STD_LOGIC_VECTOR(3 downto 0) := "1110";
	constant COND_NV          : STD_LOGIC_VECTOR(3 downto 0) := "1111";

  -- COOL WORKING MUSIC ---------------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
	-- Carrie Underwood - Last Name
	-- Taylor Swift - Today Was A Fairy Tale
	-- Montgomery Gentry - One In Every Crowd
	-- Tim McGraw - Something Like That
	-- Rascal Flatts - These Days
	-- Coldwater Jane - Bring On The Love
	-- Reba McEntire - The Night The Lights Went Out In Georgia
	-- Laura Bell Bundy - Giddy Up On
	-- Jerrod Niemann - Lover, Lover
	-- Craig Morgan - Redneck Yacht Club
	-- Travis Tritt - I'm Gonna Be Somebody
	-- Crystal Shawanda - You Can Let Go
	-- Dixie Chicks - Wide Open Spaces
	-- Collin Raye - I Can Still Feel You
	-- Jason Aldean - She's Country
	-- Hunter Hayes - STORM Warning (lol, the core's theme xD)
	-- Keith Urban - You Gonna Fly
	-- Big And Rich - Lost In The Moment
	-- LeAnn Rimes - Something's Gotta Give
	-- Matt Kennon - The Call
	-- Brad Paisley - Letter To Me
	-- Montgomery Gentry - Where I Come From
	-- Dixie Chicks - Ready To Run
	-- Eagle-Eye Cherry - Skull Tattoo
	-- Keith Urban - You Gonna Fly
	-- Miranda Lambert - Baggage Claim
	-- Diamond Rio - Meet In The Middle
	-- Lost Trailers - How 'Bout You Don't
	-- Alabama - Song of The South
	-- Chris Cagle - What Kinda Gone
	-- Jerrod Niemann - Lover, Lover
	-- Tim McGraw - Where The Green Grass Grows
	-- Kenny Chesney - I Go Back
	-- The Band Perry - Postcard From Paris
	-- Chris Cagle - Got My Country On
	-- Kenny Chesney - Summertime
	-- Montgomery Gentry - Something To Be Proud Of

  -- INTERNAL MNEMONICS ---------------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
	constant L_AND : STD_LOGIC_VECTOR(3 downto 0) := "0000"; -- logical and
	constant L_XOR : STD_LOGIC_VECTOR(3 downto 0) := "0001"; -- logical xor
	constant A_SUB : STD_LOGIC_VECTOR(3 downto 0) := "0010"; -- sub
	constant A_RSB : STD_LOGIC_VECTOR(3 downto 0) := "0011"; -- reverse sub
	constant A_ADD : STD_LOGIC_VECTOR(3 downto 0) := "0100"; -- add
	constant A_ADC : STD_LOGIC_VECTOR(3 downto 0) := "0101"; -- add with carry
	constant A_SBC : STD_LOGIC_VECTOR(3 downto 0) := "0110"; -- sub with carry	
	constant A_RSC : STD_LOGIC_VECTOR(3 downto 0) := "0111"; -- reverse sub with carry
	constant L_TST : STD_LOGIC_VECTOR(3 downto 0) := "1000"; -- compare by logical and
	constant L_TEQ : STD_LOGIC_VECTOR(3 downto 0) := "1001"; -- compare by logical xor
	constant A_CMP : STD_LOGIC_VECTOR(3 downto 0) := "1010"; -- compare by subtraction
	constant A_CMN : STD_LOGIC_VECTOR(3 downto 0) := "1011"; -- compare by addition
	constant L_OR  : STD_LOGIC_VECTOR(3 downto 0) := "1100"; -- logical or
	constant L_MOV : STD_LOGIC_VECTOR(3 downto 0) := "1101"; -- pass operand B
	constant L_BIC : STD_LOGIC_VECTOR(3 downto 0) := "1110"; -- bit clear
	constant L_NOT : STD_LOGIC_VECTOR(3 downto 0) := "1111"; -- logical not
	constant L_NAN : STD_LOGIC_VECTOR(3 downto 0) := "1111"; -- logical nand
	constant PassA : STD_LOGIC_VECTOR(3 downto 0) := L_TEQ;  -- pass operand A
	constant PassB : STD_LOGIC_VECTOR(3 downto 0) := L_MOV;  -- pass operand B
	constant S_LSL : STD_LOGIC_VECTOR(1 downto 0) := "00";   -- logical shift left
	constant S_LSR : STD_LOGIC_VECTOR(1 downto 0) := "01";   -- logical shift right
	constant S_ASR : STD_LOGIC_VECTOR(1 downto 0) := "10";   -- arithmetical shift right
	constant S_ROR : STD_LOGIC_VECTOR(1 downto 0) := "11";   -- rotate right (extended)

  -- COMPONENT Machine Control System -------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  component MC_SYS
	 generic (
				BOOT_VEC       : STD_LOGIC_VECTOR(31 downto 0)
	         );
	 port	(
				CLK_I          : in  STD_LOGIC;
				G_HALT_I       : in  STD_LOGIC;
				RST_I          : in  STD_LOGIC;
				CTRL_I         : in  STD_LOGIC_VECTOR(CTRL_MSB downto 0);
				HALT_I         : in  STD_LOGIC;
				PEND_XI_REQ_O  : out STD_LOGIC;
				INT_TKN_O      : out STD_LOGIC;
				EMPTY_PIPE_I   : in  STD_LOGIC;
				FLAG_I         : in  STD_LOGIC_VECTOR(03 downto 0);
				CMSR_O         : out STD_LOGIC_VECTOR(31 downto 0);
				REG_PC_O       : out STD_LOGIC_VECTOR(31 downto 0);
				JMP_PC_O       : out STD_LOGIC_VECTOR(31 downto 0);
				LNK_PC_O       : out STD_LOGIC_VECTOR(31 downto 0);
				INF_PC_O       : out STD_LOGIC_VECTOR(31 downto 0);
				MCR_DATA_I     : in  STD_LOGIC_VECTOR(31 downto 0);
				MCR_DATA_O     : out STD_LOGIC_VECTOR(31 downto 0);
				PC_INJECT_I    : in  STD_LOGIC;
				PC_INJECT_D_I  : in  STD_LOGIC_VECTOR(31 downto 0);
				EX_FIQ_I       : in  STD_LOGIC;
				EX_IRQ_I       : in  STD_LOGIC;
				EX_DAB_I       : in  STD_LOGIC;
				EX_IAB_I       : in  STD_LOGIC;
				BUS_CYCC_O     : out STD_LOGIC_VECTOR(15 downto 0);
				DC_FLUSH_O     : out STD_LOGIC;
				DC_CLEAR_O     : out STD_LOGIC;
				DC_HIT_I       : in  STD_LOGIC;
				DC_MISS_I      : in  STD_LOGIC;
				DC_FRESH_O     : out STD_LOGIC;
				IC_FRESH_O     : out STD_LOGIC;
				IC_CLEAR_O     : out STD_LOGIC;
				IC_HIT_I       : in  STD_LOGIC;
				IC_MISS_I      : in  STD_LOGIC;
				C_WTHRU_O      : out STD_LOGIC;
				CACHED_IO_O    : out STD_LOGIC;
				PRTCT_IO_O     : out STD_LOGIC;
				DC_SYNC_I      : in  STD_LOGIC;
				IO_PORT_O      : out STD_LOGIC_VECTOR(15 downto 0);
				IO_PORT_I      : in  STD_LOGIC_VECTOR(15 downto 0);
				ADR_FEEDBACK_I : in  STD_LOGIC_VECTOR(31 downto 0)
			);
  end component;

  -- COMPONENT Operand Unit -----------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  component OPERAND_UNIT
	 port	(
				CTRL_I          : in  STD_LOGIC_VECTOR(CTRL_MSB downto 0);
				OP_ADR_I        : in  STD_LOGIC_VECTOR(14 downto 0);
				OP_A_I          : in  STD_LOGIC_VECTOR(31 downto 0);
				OP_B_I          : in  STD_LOGIC_VECTOR(31 downto 0);
				OP_C_I          : in  STD_LOGIC_VECTOR(31 downto 0);
				JMP_PC_I        : in  STD_LOGIC_VECTOR(31 downto 0);
				IMM_I           : in  STD_LOGIC_VECTOR(31 downto 0);
				OP_A_O          : out STD_LOGIC_VECTOR(31 downto 0);
				OP_B_O          : out STD_LOGIC_VECTOR(31 downto 0);
				SHIFT_VAL_O     : out STD_LOGIC_VECTOR(04 downto 0);
				BP1_O           : out STD_LOGIC_VECTOR(31 downto 0);
				HOLD_BUS_O      : out STD_LOGIC_VECTOR(02 downto 0);
				MSU_FW_I        : in  STD_LOGIC_VECTOR(FWD_MSB downto 0);
				ALU_FW_I        : in  STD_LOGIC_VECTOR(FWD_MSB downto 0);
				MEM_FW_I        : in  STD_LOGIC_VECTOR(FWD_MSB downto 0);
				WB_FW_I         : in  STD_LOGIC_VECTOR(FWD_MSB downto 0)
			);
  end component;
  
  -- COMPONENT Register File ----------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  component REG_FILE
	 port	(
				CLK_I           : in  STD_LOGIC;
				G_HALT_I        : in  STD_LOGIC;
				RST_I           : in  STD_LOGIC;
				CTRL_I          : in  STD_LOGIC_VECTOR(CTRL_MSB downto 0);
				OP_ADR_I        : in  STD_LOGIC_VECTOR(14 downto 0);
				MODE_I          : in  STD_LOGIC_VECTOR(04 downto 0);
				USR_RD_I        : in  STD_LOGIC;
				WB_DATA_I       : in  STD_LOGIC_VECTOR(31 downto 0);
				REG_PC_I        : in  STD_LOGIC_VECTOR(31 downto 0);
				OP_A_O          : out STD_LOGIC_VECTOR(31 downto 0);
				OP_B_O          : out STD_LOGIC_VECTOR(31 downto 0);
				OP_C_O          : out STD_LOGIC_VECTOR(31 downto 0)
			);
  end component;

  -- COMPONENT Memory Interface -------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  component LOAD_STORE_UNIT
    port (
				CLK_I          : in  STD_LOGIC;
				G_HALT_I       : in  STD_LOGIC;
				RST_I          : in  STD_LOGIC;
				CTRL_I         : in  STD_LOGIC_VECTOR(CTRL_MSB downto 0);
				MEM_DATA_I     : in  STD_LOGIC_VECTOR(31 downto 0);
				MEM_ADR_I      : in  STD_LOGIC_VECTOR(31 downto 0);
				MEM_BP_I       : in  STD_LOGIC_VECTOR(31 downto 0);
				MODE_I         : in  STD_LOGIC_VECTOR(04 downto 0);
				LNK_PC_I       : in  STD_LOGIC_VECTOR(31 downto 0);
				ADR_O          : out STD_LOGIC_VECTOR(31 downto 0);
				BP_O           : out STD_LOGIC_VECTOR(31 downto 0);
				LDST_FW_O      : out STD_LOGIC_VECTOR(FWD_MSB downto 0);
				XMEM_MODE_O    : out STD_LOGIC_VECTOR(04 downto 0);
				XMEM_ADR_O     : out STD_LOGIC_VECTOR(31 downto 0);
				XMEM_WR_DTA_O  : out STD_LOGIC_VECTOR(31 downto 0);
				XMEM_ACC_REQ_O : out STD_LOGIC;
				XMEM_RW_O      : out STD_LOGIC;
				XMEM_DQ_O      : out STD_LOGIC_VECTOR(01 downto 0)
			);
  end component;

  -- COMPONENT Opcode Decoder ---------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  component OPCODE_DECODER
	port	(
				OPCODE_DATA_I   : in  STD_LOGIC_VECTOR(31 downto 0);
				OPCODE_CTRL_I   : in  STD_LOGIC_VECTOR(15 downto 0);
				OPCODE_CTRL_O   : out STD_LOGIC_VECTOR(CTRL_MSB downto 0);
				OPCODE_MISC_O   : out STD_LOGIC_VECTOR(99 downto 0)
			);
  end component;

  -- COMPONENT Operation Control System -----------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  component FLOW_CTRL
	 port	(
				RST_I           : in  STD_LOGIC;
				CLK_I           : in  STD_LOGIC;
				G_HALT_I        : in  STD_LOGIC;
				INSTR_I         : in  STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
				INST_MREQ_O     : out STD_LOGIC;
				OPCODE_DATA_O   : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
				OPCODE_CTRL_I   : in  STD_LOGIC_VECTOR(CTRL_MSB downto 0);
				OPCODE_MISC_I   : in  STD_LOGIC_VECTOR(99 downto 0);
				OPCODE_CTRL_O   : out STD_LOGIC_VECTOR(15 downto 0);
				PC_HALT_O       : out STD_LOGIC;
				SREG_I          : in  STD_LOGIC_VECTOR(31 downto 0);
				EXECUTE_INT_I   : in  STD_LOGIC;
				STOP_IF_I       : in  STD_LOGIC;
				HOLD_BUS_I      : in  STD_LOGIC_VECTOR(02 downto 0);
				EMPTY_PIPE_O    : out STD_LOGIC;
				PC_INJECT_O     : out STD_LOGIC;
				OP_ADR_O        : out STD_LOGIC_VECTOR(14 downto 0);
				IMM_O           : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
				OF_CTRL_O       : out STD_LOGIC_VECTOR(CTRL_MSB downto 0);
				MS_CTRL_O       : out STD_LOGIC_VECTOR(CTRL_MSB downto 0);
				EX1_CTRL_O      : out STD_LOGIC_VECTOR(CTRL_MSB downto 0);
				MEM_CTRL_O      : out STD_LOGIC_VECTOR(CTRL_MSB downto 0);
				WB_CTRL_O       : out STD_LOGIC_VECTOR(CTRL_MSB downto 0)
			);
  end component;
  
  -- COMPONENT Multiplication/Shift Unit ----------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  component MS_UNIT
    port	(
				CLK_I           : in  STD_LOGIC;
				G_HALT_I        : in  STD_LOGIC;
				RST_I           : in  STD_LOGIC;
				CTRL_I          : in  STD_LOGIC_VECTOR(CTRL_MSB downto 0);
				OP_A_I          : in  STD_LOGIC_VECTOR(31 downto 0);
				OP_B_I          : in  STD_LOGIC_VECTOR(31 downto 0);
				BP_I            : in  STD_LOGIC_VECTOR(31 downto 0);
				CARRY_I         : in  STD_LOGIC;
				SHIFT_V_I       : in  STD_LOGIC_VECTOR(04 downto 0);
				OP_A_O          : out STD_LOGIC_VECTOR(31 downto 0);
				BP_O            : out STD_LOGIC_VECTOR(31 downto 0);
				RESULT_O        : out STD_LOGIC_VECTOR(31 downto 0);
				CARRY_O         : out STD_LOGIC;
				OVFL_O          : out STD_LOGIC;
				MSU_FW_O        : out STD_LOGIC_VECTOR(FWD_MSB downto 0)
			);
  end component;

  -- COMPONENT MS_UNIT/Multiplication Unit --------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  component MULTIPLY_UNIT
    port	(
				OP_B_I          : in  STD_LOGIC_VECTOR(31 downto 0);
				OP_C_I          : in  STD_LOGIC_VECTOR(31 downto 0);
				RESULT_O        : out STD_LOGIC_VECTOR(31 downto 0);
				CARRY_O         : out STD_LOGIC;
				OVFL_O          : out STD_LOGIC
			);
  end component;
  
  -- COMPONENT MS_UNIT/Barrel Shifter Unit --------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  component BARREL_SHIFTER
    port (
				SHIFT_DATA_I    : in  STD_LOGIC_VECTOR(31 downto 0);
				SHIFT_DATA_O    : out STD_LOGIC_VECTOR(31 downto 0);
				CARRY_I         : in  STD_LOGIC;
				CARRY_O         : out STD_LOGIC;
				OVERFLOW_O      : out STD_LOGIC;
				SHIFT_MODE_I    : in  STD_LOGIC_VECTOR(01 downto 0);
				SHIFT_POS_I     : in  STD_LOGIC_VECTOR(04 downto 0)
			);
  end component;
  
  -- COMPONENT Data Operation Unit ----------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  component ALU
	 port	(
				CLK_I           : in  STD_LOGIC;
				G_HALT_I        : in  STD_LOGIC;
				RST_I           : in  STD_LOGIC;
				CTRL_I          : in  STD_LOGIC_VECTOR(CTRL_MSB downto 0);
				OP_A_I          : in  STD_LOGIC_VECTOR(31 downto 0);
				OP_B_I          : in  STD_LOGIC_VECTOR(31 downto 0);
				BP1_I           : in  STD_LOGIC_VECTOR(31 downto 0);
				BP1_O           : out STD_LOGIC_VECTOR(31 downto 0);
				ADR_O           : out STD_LOGIC_VECTOR(31 downto 0);
				RESULT_O        : out STD_LOGIC_VECTOR(31 downto 0);
				FLAG_I          : in  STD_LOGIC_VECTOR(03 downto 0);
				FLAG_O          : out STD_LOGIC_VECTOR(03 downto 0);
				MS_CARRY_I      : in  STD_LOGIC;
				MS_OVFL_I       : in  STD_LOGIC;
				MCR_DTA_O       : out STD_LOGIC_VECTOR(31 downto 0);
				MCR_DTA_I       : in  STD_LOGIC_VECTOR(31 downto 0);
				ALU_FW_O        : out STD_LOGIC_VECTOR(FWD_MSB downto 0)
			);
  end component;

  -- COMPONENT Write Back Unit --------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  component WB_UNIT
    port	(
				CLK_I           : in  STD_LOGIC;
				G_HALT_I        : in  STD_LOGIC;
				RST_I           : in  STD_LOGIC;
				CTRL_I          : in  STD_LOGIC_VECTOR(CTRL_MSB downto 0);
				ALU_DATA_I      : in  STD_LOGIC_VECTOR(31 downto 0);
				ADR_BUFF_I      : in  STD_LOGIC_VECTOR(31 downto 0);
				WB_DATA_O       : out STD_LOGIC_VECTOR(31 downto 0);
				XMEM_RD_DATA_I  : in  STD_LOGIC_VECTOR(31 downto 0);
				WB_FW_O         : out STD_LOGIC_VECTOR(FWD_MSB downto 0)
			);
  end component;

  -- COMPONENT Cache Memory -----------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  component CACHE
	generic (
				CACHE_PAGES      : natural := 4;
				LOG2_CACHE_PAGES : natural := 2;
				PAGE_SIZE        : natural := 64; -- #words
				LOG2_PAGE_SIZE   : natural := 6
			);
	port (
				CORE_CLK_I  : in  STD_LOGIC;
				RST_I       : in  STD_LOGIC;
				HALT_I      : in  STD_LOGIC;
				P_CS_I      : in  STD_LOGIC;
				P_ADR_I     : in  STD_LOGIC_VECTOR(31 downto 0);
				P_DATA_I    : in  STD_LOGIC_VECTOR(31 downto 0);
				P_DATA_O    : out STD_LOGIC_VECTOR(31 downto 0);
				P_DQ_I      : in  STD_LOGIC_VECTOR(01 downto 0);
				P_WE_I      : in  STD_LOGIC;
				B_CS_I      : in  STD_LOGIC;
				B_P_SEL_I   : in  STD_LOGIC_VECTOR(LOG2_CACHE_PAGES-1 downto 0);
				B_D_SEL_O   : out STD_LOGIC;
				B_A_SEL_O   : out STD_LOGIC_VECTOR(31 downto 0);
				B_ADR_I     : in  STD_LOGIC_VECTOR(31 downto 0);
				B_DATA_I    : in  STD_LOGIC_VECTOR(31 downto 0);
				B_DATA_O    : out STD_LOGIC_VECTOR(31 downto 0);
				B_WE_I      : in  STD_LOGIC;
				B_DRT_ACK_I : in  STD_LOGIC;
				B_MSS_ACK_I : in  STD_LOGIC;
				B_IO_ACC_I  : in  STD_LOGIC;
				C_FRESH_I   : in  STD_LOGIC;
				C_FLUSH_I   : in  STD_LOGIC;
				C_CLEAR_I   : in  STD_LOGIC;
				C_MISS_O    : out STD_LOGIC;
				C_HIT_O     : out STD_LOGIC;
				C_DIRTY_O   : out STD_LOGIC;
				C_WTHRU_I   : in  STD_LOGIC;
				C_SYNC_O    : out STD_LOGIC
			);
  end component;

  -- COMPONENT Bus Unit ---------------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  component BUS_UNIT
	generic (
				I_CACHE_PAGES           : natural;
				LOG2_I_CACHE_PAGES      : natural;
				I_CACHE_PAGE_SIZE       : natural;
				LOG2_I_CACHE_PAGE_SIZE  : natural;
				D_CACHE_PAGES           : natural;
				LOG2_D_CACHE_PAGES      : natural;
				D_CACHE_PAGE_SIZE       : natural;
				LOG2_D_CACHE_PAGE_SIZE  : natural;
				IO_UC_BEGIN             : STD_LOGIC_VECTOR(31 downto 0);
				IO_UC_END               : STD_LOGIC_VECTOR(31 downto 0)
			);
	port    (
				CORE_CLK_I         : in  STD_LOGIC;
				RST_I              : in  STD_LOGIC;
				FREEZE_STORM_O     : out STD_LOGIC;
				STORM_MODE_I       : in  STD_LOGIC_VECTOR(04 downto 0);
				D_ABORT_O          : out STD_LOGIC;
				I_ABORT_O          : out STD_LOGIC;
				C_BUS_CYCC_I       : in  STD_LOGIC_VECTOR(15 downto 0);
				CACHED_IO_I        : in  STD_LOGIC;
				PROTECTED_IO_I     : in  STD_LOGIC;
				ADR_FEEDBACK_O     : out STD_LOGIC_VECTOR(31 downto 0);
				DC_CS_O            : out STD_LOGIC;
				DC_P_ADR_I         : in  STD_LOGIC_VECTOR(31 downto 0);
				DC_P_SEL_O         : out STD_LOGIC_VECTOR(LOG2_D_CACHE_PAGES-1 downto 0);
				DC_D_SEL_I         : in  STD_LOGIC;
				DC_A_SEL_I         : in  STD_LOGIC_VECTOR(31 downto 0);
				DC_P_CS_I          : in  STD_LOGIC;
				DC_P_WE_I          : in  STD_LOGIC;
				DC_ADR_O           : out STD_LOGIC_VECTOR(31 downto 0);
				DC_DATA_O          : out STD_LOGIC_VECTOR(31 downto 0);
				DC_DATA_I          : in  STD_LOGIC_VECTOR(31 downto 0);
				DC_WE_O            : out STD_LOGIC;
				DC_MISS_I          : in  STD_LOGIC;
				DC_DIRTY_I         : in  STD_LOGIC;
				DC_DRT_ACK_O       : out STD_LOGIC;
				DC_MSS_ACK_O       : out STD_LOGIC;
				DC_IO_ACC_O        : out STD_LOGIC;
				IC_CS_O            : out STD_LOGIC;
				IC_P_ADR_I         : in  STD_LOGIC_VECTOR(31 downto 0);
				IC_P_CS_I          : in  STD_LOGIC;
				IC_ADR_O           : out STD_LOGIC_VECTOR(31 downto 0);
				IC_DATA_O          : out STD_LOGIC_VECTOR(31 downto 0);
				IC_WE_O            : out STD_LOGIC;
				IC_MISS_I          : in  STD_LOGIC;
				IC_MSS_ACK_O       : out STD_LOGIC;
				WB_ADR_O           : out STD_LOGIC_VECTOR(31 downto 0);
				WB_CTI_O           : out STD_LOGIC_VECTOR(02 downto 0);
				WB_DATA_O          : out STD_LOGIC_VECTOR(31 downto 0);
				WB_SEL_O           : out STD_LOGIC_VECTOR(03 downto 0);
				WB_TGC_O           : out STD_LOGIC_VECTOR(06 downto 0);
				WB_WE_O            : out STD_LOGIC;
				WB_CYC_O           : out STD_LOGIC;
				WB_STB_O           : out STD_LOGIC;
				WB_DATA_I          : in  STD_LOGIC_VECTOR(31 downto 0);
				WB_ACK_I           : in  STD_LOGIC;
				WB_ERR_I           : in  STD_LOGIC;
				WB_HALT_I          : in  STD_LOGIC
            );
  end component;

  -- COMPONENT Processor Core ---------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  component CORE
    generic (
				BOOT_VEC        : STD_LOGIC_VECTOR(31 downto 0)
	        );
    port 	(
				RES             : in  STD_LOGIC;
				CLK             : in  STD_LOGIC;
				HALT            : in  STD_LOGIC;
				MODE            : out STD_LOGIC_VECTOR(04 downto 0);
				D_CACHE_REQ     : out STD_LOGIC;
				D_CACHE_ADR     : out STD_LOGIC_VECTOR(31 downto 0);
				D_CACHE_RD_DTA  : in  STD_LOGIC_VECTOR(31 downto 0);
				D_CACHE_WR_DTA  : out STD_LOGIC_VECTOR(31 downto 0);
				D_CACHE_DQ      : out STD_LOGIC_VECTOR(01 downto 0);
				D_CACHE_RW      : out STD_LOGIC;
				D_CACHE_ABORT   : in  STD_LOGIC;
				D_CACHE_CLEAR   : out STD_LOGIC;
				D_CACHE_FLUSH   : out STD_LOGIC;
				D_CACHE_MISS    : in  STD_LOGIC;
				D_CACHE_HIT     : in  STD_LOGIC;
				D_CACHE_FRESH   : out STD_LOGIC;
				D_CACHE_CIO     : out STD_LOGIC;
				IO_PROTECT_O    : out STD_LOGIC;
				D_CACHE_SYNC    : in  STD_LOGIC;
				I_CACHE_REQ     : out STD_LOGIC;
				I_CACHE_ADR     : out STD_LOGIC_VECTOR(31 downto 0);
				I_CACHE_RD_DTA  : in  STD_LOGIC_VECTOR(31 downto 0);
				I_CACHE_ABORT   : in  STD_LOGIC;
				I_CACHE_CLEAR   : out STD_LOGIC;
				I_CACHE_MISS    : in  STD_LOGIC;
				I_CACHE_HIT     : in  STD_LOGIC;
				I_CACHE_FRESH   : out STD_LOGIC;
				C_BUS_CYCC_O    : out STD_LOGIC_VECTOR(15 downto 0);
				C_WTHRU_O       : out STD_LOGIC;
				IO_PORT_OUT     : out STD_LOGIC_VECTOR(15 downto 0);
				IO_PORT_IN      : in  STD_LOGIC_VECTOR(15 downto 0);
				ADR_FEEDBACK_I  : in  STD_LOGIC_VECTOR(31 downto 0);
				IRQ             : in  STD_LOGIC;
				FIQ             : in  STD_LOGIC
			);
  end component;

end STORM_core_package;