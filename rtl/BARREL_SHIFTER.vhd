-- #######################################################
-- #     < STORM CORE PROCESSOR by Stephan Nolting >     #
-- # *************************************************** #
-- #              Barrelshifter Unit                     #
-- # *************************************************** #
-- # Last modified: 27.03.2011                           #
-- #######################################################

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.STORM_core_package.all;

entity BARREL_SHIFTER is
	port	(
				-- Function Operands --
				----------------------------------------------------
				SHIFT_DATA_I    : in  STD_LOGIC_VECTOR(31 downto 0);
				SHIFT_DATA_O    : out STD_LOGIC_VECTOR(31 downto 0);

				-- Flag Operands --
				----------------------------------------------------
				CARRY_I         : in  STD_LOGIC;
				CARRY_O         : out STD_LOGIC;
				OVERFLOW_O      : out STD_LOGIC;

				-- Operation Control --
				----------------------------------------------------
				SHIFT_MODE_I    : in  STD_LOGIC_VECTOR(01 downto 0);
				SHIFT_POS_I     : in  STD_LOGIC_VECTOR(04 downto 0)
			);
end BARREL_SHIFTER;

architecture Structure of BARREL_SHIFTER is

begin

	-- Barrelshifter ---------------------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		BARREL_SHIFTER: process(SHIFT_MODE_I, SHIFT_POS_I, SHIFT_DATA_I, CARRY_I)
			variable shift_positions : integer range 0 to 31;
			variable SHIFT_DATA      : STD_LOGIC_VECTOR(31 downto 00);
		begin
			--- Shift amount ---
			shift_positions := to_integer(unsigned(SHIFT_POS_I));

			--- Shifter ---
			case (SHIFT_MODE_I) is
				when S_LSL   => -- Logical Shift Left
					if (shift_positions = 0) then -- no shift, keep carry
						SHIFT_DATA := SHIFT_DATA_I;
						CARRY_O    <= CARRY_I;
					else -- LSL #shift_positions
						SHIFT_DATA := to_StdLogicVector(to_BitVector(SHIFT_DATA_I) sll shift_positions);
						CARRY_O    <= SHIFT_DATA_I(32 - shift_positions);
					end if;

				when S_LSR   => -- Logical Shift Right
					if (shift_positions = 0) then -- LSR #32
						SHIFT_DATA := (others => '0');
						CARRY_O    <= SHIFT_DATA_I(31);
					else -- LSR #shift_positions
						SHIFT_DATA := to_StdLogicVector(to_BitVector(SHIFT_DATA_I) srl shift_positions);
						CARRY_O    <= SHIFT_DATA_I(shift_positions - 1);
					end if;

				when S_ASR   => -- Arithmetical Shift Right
					if (shift_positions = 0) then -- ASR #32
						SHIFT_DATA := (others => SHIFT_DATA_I(31)); -- complete sign extension
						CARRY_O    <= SHIFT_DATA_I(31);
					else -- ASR #shift_positions
						SHIFT_DATA := to_StdLogicVector(to_BitVector(SHIFT_DATA_I) sra shift_positions);
						CARRY_O    <= SHIFT_DATA_I(shift_positions - 1);
					end if;

				when S_ROR => -- Rotate Right (Extended)
					if (shift_positions = 0) then -- RRX = ROR #1 and fill with carry flag
						SHIFT_DATA := CARRY_I & SHIFT_DATA_I(31 downto 1); -- fill with carry flag
						CARRY_O    <= SHIFT_DATA_I(0);
					else -- ROR #shift_positions
						SHIFT_DATA := to_StdLogicVector(to_BitVector(SHIFT_DATA_I) ror shift_positions);
						CARRY_O    <= SHIFT_DATA_I(shift_positions - 1);
					end if;

				when others => -- undefined
					SHIFT_DATA := (others => '0');
					CARRY_O    <= '0';
			end case;

			--- Overflow Flag ---
			if (STORM_MODE = TRUE) then -- use cool overflow feature ;)
				if (SHIFT_MODE_I = S_LSL) then -- broken sign detection
					OVERFLOW_O <= SHIFT_DATA_I(31) xor SHIFT_DATA(31);
				else
					OVERFLOW_O <= '0';
				end if;
			else
				OVERFLOW_O <= '0';
			end if;

			--- Data Output ---
			SHIFT_DATA_O <= SHIFT_DATA;

		end process BARREL_SHIFTER;


end Structure;