-- #######################################################
-- #     < STORM CORE PROCESSOR by Stephan Nolting >     #
-- # *************************************************** #
-- #                Multiply/Shift Unit                  #
-- # *************************************************** #
-- # Last modified: 26.03.2012                           #
-- #######################################################

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.STORM_core_package.all;

entity MS_UNIT is
	port	(
-- ###############################################################################################
-- ##           Global Control                                                                  ##
-- ###############################################################################################

				CLK_I           : in  STD_LOGIC; -- global clock line
				G_HALT_I        : in  STD_LOGIC; -- global halt line
				RST_I           : in  STD_LOGIC; -- global reset line
				CTRL_I          : in  STD_LOGIC_VECTOR(CTRL_MSB downto 0); -- stage control lines

-- ###############################################################################################
-- ##           Operant Connection                                                              ##
-- ###############################################################################################

				OP_A_I          : in  STD_LOGIC_VECTOR(31 downto 0); -- operant a input
				OP_B_I          : in  STD_LOGIC_VECTOR(31 downto 0); -- operant b input
				BP_I            : in  STD_LOGIC_VECTOR(31 downto 0); -- bypass input
				CARRY_I         : in  STD_LOGIC; -- carry input

				SHIFT_V_I       : in  STD_LOGIC_VECTOR(04 downto 0); -- shift value in

				OP_A_O          : out STD_LOGIC_VECTOR(31 downto 0); -- operant a bypass
				BP_O            : out STD_LOGIC_VECTOR(31 downto 0); -- bypass output
				RESULT_O        : out STD_LOGIC_VECTOR(31 downto 0); -- operation result
				CARRY_O         : out STD_LOGIC; -- operation carry signal
				OVFL_O          : out STD_LOGIC; -- operation overflow signal

-- ###############################################################################################
-- ##           Forwarding Path                                                                 ##
-- ###############################################################################################

				MSU_FW_O        : out STD_LOGIC_VECTOR(FWD_MSB downto 0) -- forwarding path

			);
end MS_UNIT;

architecture Structural of MS_UNIT is

	-- Pipeline Registers --
	signal	OP_A_REG      : STD_LOGIC_VECTOR(31 downto 0);
	signal	OP_B_REG      : STD_LOGIC_VECTOR(31 downto 0);
	signal	BP_REG        : STD_LOGIC_VECTOR(31 downto 0);
	signal	SHIFT_V_TEMP  : STD_LOGIC_VECTOR(04 downto 0);
	
	-- Local Signals --
	signal	OP_RESULT     : STD_LOGIC_VECTOR(31 downto 0);
	signal	SFT_DATA      : STD_LOGIC_VECTOR(31 downto 0);
	signal	MUL_DATA      : STD_LOGIC_VECTOR(31 downto 0);
	signal	SFT_CARRY     : STD_LOGIC;
	signal	MUL_CARRY     : STD_LOGIC;
	signal	SFT_OVFL      : STD_LOGIC;
	signal	MUL_OVFL      : STD_LOGIC;

begin

	-- Pipeline-Buffers ------------------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		MS_BUFFER: process(CLK_I)
		begin
			if rising_edge (CLK_I) then
				if (RST_I = '1') then
					OP_A_REG     <= (others => '0');
					OP_B_REG     <= (others => '0');
					BP_REG       <= (others => '0');
					SHIFT_V_TEMP <= (others => '0');
				elsif (G_HALT_I = '0') then
					OP_A_REG     <= OP_A_I;
					OP_B_REG     <= OP_B_I;
					BP_REG       <= BP_I;
					SHIFT_V_TEMP <= SHIFT_V_I;
				end if;
			end if;
		end process MS_BUFFER;



	-- Multiplicator ---------------------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		Multiplicator:
			MULTIPLY_UNIT
				port map	(
								OP_B_I      => OP_B_REG,  -- operand B input
								OP_C_I      => BP_REG,    -- operand C input
								RESULT_O    => MUL_DATA,  -- multiplication data result
								CARRY_O     => MUL_CARRY, -- multiplication carry result
								OVFL_O      => MUL_OVFL   -- multiplication overflow result
							);


	-- Barrelshifter ---------------------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		Barrelshifter:
			BARREL_SHIFTER
				port map (
								SHIFT_DATA_I   => OP_B_REG,     -- data getting shifted
								SHIFT_DATA_O   => SFT_DATA,     -- shift data result
								CARRY_I        => CARRY_I,     -- carry input
								CARRY_O        => SFT_CARRY,    -- carry output
								OVERFLOW_O     => SFT_OVFL,     -- overflow output
								SHIFT_MODE_I   => CTRL_I(CTRL_SHIFT_M_1 downto CTRL_SHIFT_M_0), -- shift mode
								SHIFT_POS_I    => SHIFT_V_TEMP  -- shift positions
							);
							
							
	-- Operation Result Selector ---------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		OP_RESULT <= MUL_DATA  when (CTRL_I(CTRL_MS) = '1') else SFT_DATA;  -- result data
		CARRY_O   <= MUL_CARRY when (CTRL_I(CTRL_MS) = '1') else SFT_CARRY; -- carry flag
		OVFL_O    <= MUL_OVFL  when (CTRL_I(CTRL_MS) = '1') else SFT_OVFL;  -- overflow flag



	-- Module Data Output ----------------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		RESULT_O   <= OP_RESULT; -- Operation Data Result
		OP_A_O     <= OP_A_REG;  -- Operant A Output
		BP_O       <= BP_REG;    -- Bypass Output



	-- Forwarding Path -----------------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		-- Operation Data Result --
		MSU_FW_O(FWD_DATA_MSB downto FWD_DATA_LSB) <= OP_RESULT;

		-- Destination Register Address --
		MSU_FW_O(FWD_RD_MSB downto FWD_RD_LSB) <= CTRL_I(CTRL_RD_3 downto CTRL_RD_0);

		-- Data Write Back Enabled --
		MSU_FW_O(FWD_WB) <= CTRL_I(CTRL_EN) and CTRL_I(CTRL_WB_EN);

		-- Processor mode will be modified --
		MSU_FW_O(FWD_MCR_MOD) <= CTRL_I(CTRL_EN) and CTRL_I(CTRL_MREG_ACC) and CTRL_I(CTRL_MREG_RW);

		-- SREG flags will be modified
		MSU_FW_O(FWD_FLAG_MOD) <= CTRL_I(CTRL_EN) and CTRL_I(CTRL_AF);

		-- MCR Read Access --
		MSU_FW_O(FWD_MCR_R_ACC) <= CTRL_I(CTRL_EN) and ((CTRL_I(CTRL_MREG_ACC) and (not CTRL_I(CTRL_MREG_RW))) or (CTRL_I(CTRL_CP_ACC) and (not CTRL_I(CTRL_CP_RW))));

		-- Memory Read Access --
		MSU_FW_O(FWD_MEM_R_ACC) <= CTRL_I(CTRL_EN) and CTRL_I(CTRL_MEM_ACC) and (not CTRL_I(CTRL_MEM_RW));

		-- Memory-Pc Load --
		MSU_FW_O(FWD_MEM_PC_LD) <= '1' when (CTRL_I(CTRL_RD_3 downto CTRL_RD_0) = C_PC_ADR) and (CTRL_I(CTRL_EN) = '1') and (CTRL_I(CTRL_MEM_ACC) = '1') and (CTRL_I(CTRL_MEM_RW) = '0') else '0';



end Structural;