-- #######################################################
-- #     < STORM CORE PROCESSOR by Stephan Nolting >     #
-- # *************************************************** #
-- #         30x32-Bit Banked 1w3r Register File         #
-- #            (+ address translation unit)             #
-- # *************************************************** #
-- # Last modified: 06.05.2012                           #
-- #######################################################

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.STORM_core_package.all;

entity REG_FILE is
	port	(
-- ###############################################################################################
-- ##       Global Control                                                                      ##
-- ###############################################################################################

				CLK_I       : in  STD_LOGIC; -- global clock network
				G_HALT_I    : in  STD_LOGIC; -- global halt line
				RST_I       : in  STD_LOGIC; -- global reset network

-- ###############################################################################################
-- ##       Local Control                                                                       ##
-- ###############################################################################################

				CTRL_I      : in  STD_LOGIC_VECTOR(CTRL_MSB downto 0); -- control lines
				OP_ADR_I    : in  STD_LOGIC_VECTOR(14 downto 0);       -- operand addresses
				MODE_I      : in  STD_LOGIC_VECTOR(04 downto 0);       -- current operation mode
				USR_RD_I    : in  STD_LOGIC;                           -- use USR bank

-- ###############################################################################################
-- ##       Operand Connection                                                                  ##
-- ###############################################################################################

				WB_DATA_I   : in  STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0); -- write back data path
				REG_PC_I    : in  STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0); -- current program counter

				OP_A_O      : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0); -- register A output
				OP_B_O      : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0); -- register B output
				OP_C_O      : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0)  -- register C output

			);
end REG_FILE;

architecture REG_FILE_STRUCTURE of REG_FILE is

	-- Data Register File --
	type   REG_FILE_TYPE is array (0 to 31) of STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
	signal REG_FILE : REG_FILE_TYPE := (others => (others => '0'));

	-- Memory <-> Register Allocation Map
	-- ------------------------------------------------------------------------
	-- 00: USR32 R0		10: USR32 R10		20: FIQ32 R13		30: Dummy Reg
	-- 01: USR32 R1		11: USR32 R11		21: FIQ32 R14 LR	31: Dummy Reg
	-- 02: USR32 R2		12: USR32 R12		22: SVP32 R13
	-- 03: USR32 R3		13: USR32 R13		23: SVP32 R14 LR
	-- 04: USR32 R4		14: USR32 R14 LR	24: ABT32 R13
	-- 05: USR32 R5		15: FIQ32 R8		25: ABT32 R14 LR
	-- 06: USR32 R6		16: FIQ32 R9		26: IRQ32 R13
	-- 07: USR32 R7		17: FIQ32 R10		27: IRQ32 R14 LR
	-- 08: USR32 R8		18: FIQ32 R11		28: UND32 R13
	-- 09: USR32 R9		19: FIQ32 R12		29: UND32 R14 LR

	-- Address Busses --
	signal R_ADR_PORT_A, R_ADR_PORT_B, R_ADR_PORT_C : STD_LOGIC_VECTOR(4 downto 0);
	signal W_ADR_PORT, MODE_INT                     : STD_LOGIC_VECTOR(4 downto 0);

	-- Address Translator --
	component ADR_TRANSLATION_UNIT
		port	(
					REG_ADR_I   : in  STD_LOGIC_VECTOR(3 downto 0);
					MODE_I      : in  STD_LOGIC_VECTOR(4 downto 0);
					ADR_O       : out STD_LOGIC_VECTOR(4 downto 0)
				);
	end component;

begin

	-- Register File Write Access ---------------------------------------------------------------------
	-- ---------------------------------------------------------------------------------------------------

		--- Write Access Data Port ---
		write_access_data_port:
			ADR_TRANSLATION_UNIT
				port map (
								REG_ADR_I => CTRL_I(CTRL_RD_3 downto CTRL_RD_0),
								MODE_I    => CTRL_I(CTRL_MODE_4 downto CTRL_MODE_0),
								ADR_O     => W_ADR_PORT
							);

		--- Clock Triggered Write ---
		SYNCHRONOUS_MEM_WRITE: process(CLK_I, W_ADR_PORT, WB_DATA_I, CTRL_I)
		begin
			if rising_edge(CLK_I) then
				if (G_HALT_I = '0') then
					if ((CTRL_I(CTRL_EN) = '1') and (CTRL_I(CTRL_WB_EN)) = '1') then
						REG_FILE(to_integer(unsigned(W_ADR_PORT))) <= WB_DATA_I;
					end if;
				end if;
			end if;
		end process SYNCHRONOUS_MEM_WRITE;



	-- Register File Read Access ----------------------------------------------------------------------
	-- ---------------------------------------------------------------------------------------------------
	
		--- Force USR bank read ---
		MODE_INT <= MODE_I when (USR_RD_I = '0') else User32_MODE;

		--- Read Access Port A ---
		read_access_port_a:
			ADR_TRANSLATION_UNIT
				port map (
								REG_ADR_I => OP_ADR_I(OP_A_ADR_3 downto OP_A_ADR_0),
								MODE_I    => MODE_INT,
								ADR_O     => R_ADR_PORT_A
							);

		--- Read Access Port B ---
		read_access_port_b:
			ADR_TRANSLATION_UNIT
				port map (
								REG_ADR_I => OP_ADR_I(OP_B_ADR_3 downto OP_B_ADR_0),
								MODE_I    => MODE_INT,
								ADR_O     => R_ADR_PORT_B
							);

		--- Read Access Port C ---
		read_access_port_c:
			ADR_TRANSLATION_UNIT
				port map (
								REG_ADR_I => OP_ADR_I(OP_C_ADR_3 downto OP_C_ADR_0),
								MODE_I    => MODE_INT,
								ADR_O     => R_ADR_PORT_C
							);


		--- Memory Read Access ---
		OP_A_O <= REG_FILE(to_integer(unsigned(R_ADR_PORT_A))) when (OP_ADR_I(OP_A_ADR_3 downto OP_A_ADR_0) /= C_PC_ADR) else REG_PC_I;
		OP_B_O <= REG_FILE(to_integer(unsigned(R_ADR_PORT_B))) when (OP_ADR_I(OP_B_ADR_3 downto OP_B_ADR_0) /= C_PC_ADR) else REG_PC_I;
		OP_C_O <= REG_FILE(to_integer(unsigned(R_ADR_PORT_C))) when (OP_ADR_I(OP_C_ADR_3 downto OP_C_ADR_0) /= C_PC_ADR) else REG_PC_I;


end REG_FILE_STRUCTURE;


------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------


-- #######################################################
-- #     < STORM CORE PROCESSOR by Stephan Nolting >     #
-- # *************************************************** #
-- #         REG-FILE Address Translation Unit           #
-- # *************************************************** #
-- # Version 1.1, 28.05.2011                             #
-- #######################################################

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.STORM_core_package.all;

entity ADR_TRANSLATION_UNIT is
	port	(
				-- Register Address Input --
				--------------------------------------------------
				REG_ADR_I   : in  STD_LOGIC_VECTOR(3 downto 0);
				
				-- MODE Input --
				--------------------------------------------------
				MODE_I      : in  STD_LOGIC_VECTOR(4 downto 0);
				
				-- Memory Address Output --
				--------------------------------------------------
				ADR_O       : out STD_LOGIC_VECTOR(4 downto 0)
			);
end ADR_TRANSLATION_UNIT;

architecture ADRTU_STRUCTURE of ADR_TRANSLATION_UNIT is

begin

	-- Address Translator -----------------------------------------------------------------------------
	-- ---------------------------------------------------------------------------------------------------
		ADR_TRANSLATOR: process(REG_ADR_I, MODE_I)
			variable VIRT_REG_SEL : STD_LOGIC_VECTOR(15 downto 0);
			variable REAL_REG_SEL : STD_LOGIC_VECTOR(31 downto 0);
		begin

			--- One-Hot Virtual Register Select ---
			case (REG_ADR_I) is
				when "0000" => VIRT_REG_SEL := "0000000000000001"; -- R0_<mode>
				when "0001" => VIRT_REG_SEL := "0000000000000010"; -- R1_<mode>
				when "0010" => VIRT_REG_SEL := "0000000000000100"; -- R2_<mode>
				when "0011" => VIRT_REG_SEL := "0000000000001000"; -- R3_<mode>
				when "0100" => VIRT_REG_SEL := "0000000000010000"; -- R4_<mode>
				when "0101" => VIRT_REG_SEL := "0000000000100000"; -- R5_<mode>
				when "0110" => VIRT_REG_SEL := "0000000001000000"; -- R6_<mode>
				when "0111" => VIRT_REG_SEL := "0000000010000000"; -- R7_<mode>
				when "1000" => VIRT_REG_SEL := "0000000100000000"; -- R8_<mode>
				when "1001" => VIRT_REG_SEL := "0000001000000000"; -- R9_<mode>
				when "1010" => VIRT_REG_SEL := "0000010000000000"; -- R10_<mode>
				when "1011" => VIRT_REG_SEL := "0000100000000000"; -- R11_<mode>
				when "1100" => VIRT_REG_SEL := "0001000000000000"; -- R12_<mode>
				when "1101" => VIRT_REG_SEL := "0010000000000000"; -- R13_<mode>
				when "1110" => VIRT_REG_SEL := "0100000000000000"; -- R14_<mode>
				when "1111" => VIRT_REG_SEL := "1000000000000000"; -- DUMMY PC
				when others => VIRT_REG_SEL := "0000000000000000"; -- undefined
			end case;

			--- Address Mapping: Virtual Register -> Real Register ---
			REAL_REG_SEL               := (others => '0');
			REAL_REG_SEL(07 downto 00) := VIRT_REG_SEL(07 downto 00); -- R0-R7 are always the same
			REAL_REG_SEL(31)           := VIRT_REG_SEL(15); -- PC access = dummy access

			case (MODE_I) is

				when User32_MODE | System32_MODE =>
					REAL_REG_SEL(14 downto 08) := VIRT_REG_SEL(14 downto 08);

				when FIQ32_MODE =>
					REAL_REG_SEL(21 downto 15) := VIRT_REG_SEL(14 downto 08);

				when Supervisor32_MODE =>
					REAL_REG_SEL(12 downto 08) := VIRT_REG_SEL(12 downto 08);
					REAL_REG_SEL(23 downto 22) := VIRT_REG_SEL(14 downto 13);

				when Abort32_MODE =>
					REAL_REG_SEL(12 downto 08) := VIRT_REG_SEL(12 downto 08);
					REAL_REG_SEL(25 downto 24) := VIRT_REG_SEL(14 downto 13);

				when IRQ32_MODE =>
					REAL_REG_SEL(12 downto 08) := VIRT_REG_SEL(12 downto 08);
					REAL_REG_SEL(27 downto 26) := VIRT_REG_SEL(14 downto 13);

				when Undefined32_MODE =>
					REAL_REG_SEL(12 downto 08) := VIRT_REG_SEL(12 downto 08);
					REAL_REG_SEL(29 downto 28) := VIRT_REG_SEL(14 downto 13);

				when others =>
					REAL_REG_SEL(29 downto 00) := (others => '0');

			end case;

			--- Address Encoder ---
			case (REAL_REG_SEL) is
				when "00000000000000000000000000000001" => ADR_O <= "00000";
				when "00000000000000000000000000000010" => ADR_O <= "00001";
				when "00000000000000000000000000000100" => ADR_O <= "00010";
				when "00000000000000000000000000001000" => ADR_O <= "00011";
				when "00000000000000000000000000010000" => ADR_O <= "00100";
				when "00000000000000000000000000100000" => ADR_O <= "00101";
				when "00000000000000000000000001000000" => ADR_O <= "00110";
				when "00000000000000000000000010000000" => ADR_O <= "00111";
				when "00000000000000000000000100000000" => ADR_O <= "01000";
				when "00000000000000000000001000000000" => ADR_O <= "01001";
				when "00000000000000000000010000000000" => ADR_O <= "01010";
				when "00000000000000000000100000000000" => ADR_O <= "01011";
				when "00000000000000000001000000000000" => ADR_O <= "01100";
				when "00000000000000000010000000000000" => ADR_O <= "01101";
				when "00000000000000000100000000000000" => ADR_O <= "01110";
				when "00000000000000001000000000000000" => ADR_O <= "01111";
				when "00000000000000010000000000000000" => ADR_O <= "10000";
				when "00000000000000100000000000000000" => ADR_O <= "10001";
				when "00000000000001000000000000000000" => ADR_O <= "10010";
				when "00000000000010000000000000000000" => ADR_O <= "10011";
				when "00000000000100000000000000000000" => ADR_O <= "10100";
				when "00000000001000000000000000000000" => ADR_O <= "10101";
				when "00000000010000000000000000000000" => ADR_O <= "10110";
				when "00000000100000000000000000000000" => ADR_O <= "10111";
				when "00000001000000000000000000000000" => ADR_O <= "11000";
				when "00000010000000000000000000000000" => ADR_O <= "11001";
				when "00000100000000000000000000000000" => ADR_O <= "11010";
				when "00001000000000000000000000000000" => ADR_O <= "11011";
				when "00010000000000000000000000000000" => ADR_O <= "11100";
				when "00100000000000000000000000000000" => ADR_O <= "11101";
				when "01000000000000000000000000000000" => ADR_O <= "11110";
				when "10000000000000000000000000000000" => ADR_O <= "11111";
				when others                             => ADR_O <= "11111";
			end case;

		end process ADR_TRANSLATOR;


end ADRTU_STRUCTURE;