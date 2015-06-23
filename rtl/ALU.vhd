-- #######################################################
-- #     < STORM CORE PROCESSOR by Stephan Nolting >     #
-- # *************************************************** #
-- #         Arithmetical/Logical/MCR_Access Unit        #
-- # *************************************************** #
-- # Last modified: 04.04.2012                           #
-- #######################################################

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.STORM_core_package.all;

entity ALU is
	port	(
-- ###############################################################################################
-- ##           Global Control                                                                  ##
-- ###############################################################################################

				CLK_I           : in  STD_LOGIC; -- global clock line
				G_HALT_I        : in  STD_LOGIC; -- global halt line
				RST_I           : in  STD_LOGIC; -- global reset line
				CTRL_I          : in  STD_LOGIC_VECTOR(CTRL_MSB downto 0); -- stage control lines

-- ###############################################################################################
-- ##           Operand Connection                                                              ##
-- ###############################################################################################

				OP_A_I          : in  STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0); -- operant a input
				OP_B_I          : in  STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0); -- operant b input
				BP1_I           : in  STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0); -- bypass input
				BP1_O           : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0); -- bypass output
				ADR_O           : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0); -- alu address output
				RESULT_O        : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0); -- EX result output

				FLAG_I          : in  STD_LOGIC_VECTOR(03 downto 0); -- alu flags input
				FLAG_O          : out STD_LOGIC_VECTOR(03 downto 0); -- alu flgas output
				
				MS_CARRY_I      : in  STD_LOGIC; -- multiply/shift carry
				MS_OVFL_I       : in  STD_LOGIC; -- multiply/shift overflow

				MCR_DTA_O       : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0); -- mcr write data output
				MCR_DTA_I       : in  STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0); -- mcr read data input

-- ###############################################################################################
-- ##           Forwarding Path                                                                 ##
-- ###############################################################################################

				ALU_FW_O        : out STD_LOGIC_VECTOR(FWD_MSB downto 0) -- forwarding path

			);
end ALU;

architecture ALU_STRUCTURE of ALU is

	-- Pipeline Register --
	signal OP_B, OP_A   : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
	signal MS_CARRY_REG : STD_LOGIC;
	signal MS_OVFL_REG  : STD_LOGIC;

	-- Local Signals --
	signal ALU_OUT      : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
	signal RESULT_TMP   : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
	signal ADDER_RES    : STD_LOGIC_VECTOR(DATA_WIDTH   downto 0);
	signal ADD_MODE     : STD_LOGIC_VECTOR(02 downto 0);
	signal CARRY_OUT    : STD_LOGIC;
	signal OVFL_OUT     : STD_LOGIC;

begin

	-- Pipeline-Buffers ------------------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		ALU_BUFFER: process(CLK_I)
		begin
			if rising_edge (CLK_I) then
				if (RST_I = '1') then
					OP_A         <= (others => '0');
					OP_B         <= (others => '0');
					BP1_O        <= (others => '0');
					MS_CARRY_REG <= '0';
					MS_OVFL_REG  <= '0';
				elsif (G_HALT_I = '0') then
					OP_A         <= OP_A_I;
					OP_B         <= OP_B_I;
					BP1_O        <= BP1_I;
					MS_CARRY_REG <= MS_CARRY_I;
					MS_OVFL_REG  <= MS_OVFL_I;
				end if;
			end if;
		end process ALU_BUFFER;



	-- Functional Core -------------------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		OPERATION_CORE: process(CTRL_I(CTRL_ALU_FS_3 downto CTRL_ALU_FS_0), ADDER_RES, OP_A, OP_B)
		begin
			-- Defaults --
			ADD_MODE <= "000";
			ALU_OUT  <= ADDER_RES(31 downto 0);

			-- Function Select --
			case CTRL_I(CTRL_ALU_FS_3 downto CTRL_ALU_FS_0) is
				when A_ADD => -- ADD: result = OP_A + OP_B
					ADD_MODE <= "000";
				when A_ADC => -- ADC: result = OP_A + OP_B + Carry-Flag
					ADD_MODE <= "100";
				when A_SUB => -- SUB: result = OP_A - OP_B
					ADD_MODE <= "001";
				when A_SBC => -- SBC: result = OP_A - OP_B - Carry-Flag
					ADD_MODE <= "101";
				when A_RSB => -- RSB: result = OP_B - OP_A
					ADD_MODE <= "010";
				when A_RSC => -- RSC: result = OP_B - OP_A - Carry-Flag
					ADD_MODE <= "110";
				when A_CMP => -- CMP: result = OP_B, compares by F = OP_A - OP_B
					ADD_MODE <= "001";
					ALU_OUT <= OP_B;
				when A_CMN => -- CMN: result = OP_A, compares by F = OP_A + OP_B
					ADD_MODE <= "000";
					ALU_OUT <= OP_A;

				when L_AND => -- AND: result = OP_A AND OP_B
					ALU_OUT <= OP_A and OP_B;
				when L_OR  => -- OR: result = OP_A OR OP_B
					ALU_OUT <= OP_A or OP_B;
				when L_XOR => -- XOR: result = OP_A XOR OP_B
					ALU_OUT <= OP_A xor OP_B;
				when L_NOT => -- NOT: result = not(OP_A AND OP_B)
					if (STORM_MODE = TRUE) then
						ALU_OUT <= not(OP_A and OP_B); -- STORM_OP: NOT
					else
						ALU_OUT <= not OP_B; -- ARM_OP: MVN
					end if;
				when L_BIC => -- BIC: result = OP_A and (not OP_B)
					ALU_OUT <= OP_A and (not OP_B);
				when L_MOV => -- MOV: result = OP_B
					ALU_OUT <= OP_B; -- boring, huh?
				when L_TST => -- TST: result = OP_B, compares by F = OP_A and OP_B
					ALU_OUT <= OP_B;
				when L_TEQ => -- TEQ: result = OP_A, compares by F = OP_A xor OP_B
					ALU_OUT <= OP_A;
				when others => -- Just to satisfy the synthesis tool...
					NULL;
			end case;
		end process OPERATION_CORE;



	-- Adder/Subtractor ------------------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		ADDER_SUBTRACTOR: process(ADD_MODE, OP_A, OP_B, FLAG_I(1), ADDER_RES)
			variable add_a_v, add_b_v : std_logic_vector(32 downto 0);
			variable adder_tmp_v      : std_logic_vector(32 downto 0);
			variable carry_int_v      : std_logic_vector(00 downto 0);
		begin
			add_a_v(32) := '0';
			add_b_v(32) := '0';
			case (ADD_MODE(1 downto 0)) is
				when "00"   => -- (+OP_A) + (+OP_B)
					add_a_v(31 downto 0) := OP_A;
					add_b_v(31 downto 0) := OP_B;
				when "01"   => -- (+OP_A) + (-OP_B)
					add_a_v(31 downto 0) := OP_A;
					add_b_v(31 downto 0) := not OP_B;
				when others => -- (-OP_A) + (+OP_B)
					add_a_v(31 downto 0) := not OP_A;
					add_b_v(31 downto 0) := OP_B;
			end case;

			--- Carry input logic ---
			carry_int_v(0) := (ADD_MODE(2) and FLAG_I(1)) xor (ADD_MODE(0) or ADD_MODE(1));
			--- Adder/Subtractor ---
			adder_tmp_v := std_logic_vector(unsigned(add_a_v) + unsigned(add_b_v) + unsigned(carry_int_v(0 downto 0)));
			ADDER_RES <= adder_tmp_v;
			--- Carry output logic ---
			CARRY_OUT <= adder_tmp_v(32) xor (ADD_MODE(0) or ADD_MODE(1));
			--- Overflow output logic ---
			OVFL_OUT  <= ((not add_a_v(31)) and (not add_b_v(31)) and adder_tmp_v(31)) or (add_a_v(31) and add_b_v(31) and (not adder_tmp_v(31)));

		end process ADDER_SUBTRACTOR;



	-- Flag Logic ------------------------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		ALU_FLAG_LOGIC: process(ADDER_RES, OP_A,     OP_B,         ALU_OUT,     FLAG_I,
		                        CARRY_OUT, OVFL_OUT, MS_CARRY_REG, MS_OVFL_REG, CTRL_I)
			variable is_add_zero_v : std_logic;
			variable is_xor_zero_v : std_logic;
			variable is_and_zero_v : std_logic;
			variable is_out_zero_v : std_logic;
		begin
			--- Zero Detectors ---
			is_add_zero_v := '0';
			is_xor_zero_v := '0';
			is_and_zero_v := '0';
			is_out_zero_v := '0';
			if (ADDER_RES(31 downto 0) = x"00000000") then
				is_add_zero_v := '1';
			end if;
			if ((OP_A xor OP_B) = x"00000000") then
				is_xor_zero_v := '1';
			end if;
			if ((OP_A and OP_B) = x"00000000") then
				is_and_zero_v := '1';
			end if;
			if (ALU_OUT = x"00000000") then
				is_out_zero_v := '1';
			end if;

			--- Function Select ---
			case CTRL_I(CTRL_ALU_FS_3 downto CTRL_ALU_FS_0) is
				-- Logical Operations --
				when L_AND | L_OR | L_XOR | L_NOT | L_BIC | L_MOV =>
					FLAG_O(0) <= FLAG_I(1);
					FLAG_O(1) <= is_out_zero_v;
					FLAG_O(2) <= ALU_OUT(31);
					FLAG_O(3) <= MS_OVFL_REG;
				-- Logical AND Compare --
				when L_TST =>
					FLAG_O(0) <= MS_CARRY_REG;
					FLAG_O(1) <= is_and_zero_v;
					FLAG_O(2) <= OP_A(31) and OP_B(31);
					FLAG_O(3) <= MS_OVFL_REG;
				-- Logical XOR Compare --
				when L_TEQ =>
					FLAG_O(0) <= MS_CARRY_REG;
					FLAG_O(1) <= is_xor_zero_v;
					FLAG_O(2) <= OP_A(31) xor OP_B(31);
					FLAG_O(3) <= MS_OVFL_REG;
				-- Arithmetical Sub Operations & Compare --
				when A_SUB | A_RSB | A_SBC | A_RSC | A_CMP =>
					FLAG_O(0) <= not CARRY_OUT; -- borrow flag
					FLAG_O(1) <= is_add_zero_v;
					FLAG_O(2) <= ADDER_RES(31);
					FLAG_O(3) <= MS_OVFL_REG or OVFL_OUT; --(ADDER_RES(31) and (OP_A(31) xnor OP_B(31))) or MS_OVFL_REG
				-- Arithmetical Add Operations & Compare --
				when others => -- A_ADD | A_ADC | A_CMN
					FLAG_O(0) <= CARRY_OUT; -- carry flag
					FLAG_O(1) <= is_add_zero_v;
					FLAG_O(2) <= ADDER_RES(31);
					FLAG_O(3) <= MS_OVFL_REG or OVFL_OUT; --(ADDER_RES(31) and (OP_A(31) xnor OP_B(31))) or MS_OVFL_REG
			end case;
		end process ALU_FLAG_LOGIC;



	-- Forwarding Paths ------------------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		-- Operation Data Result --
		ALU_FW_O(FWD_DATA_MSB downto FWD_DATA_LSB) <= RESULT_TMP;
		-- Destination Register Address --
		ALU_FW_O(FWD_RD_MSB downto FWD_RD_LSB) <= CTRL_I(CTRL_RD_3 downto CTRL_RD_0);
		-- Data Write Back Enabled --
		ALU_FW_O(FWD_WB) <= CTRL_I(CTRL_EN) and CTRL_I(CTRL_WB_EN);
		-- Mode bits modification --
		ALU_FW_O(FWD_MCR_MOD) <= '0'; -- not needed here
		-- Flag bits modification --
		ALU_FW_O(FWD_FLAG_MOD) <= CTRL_I(CTRL_EN) and CTRL_I(CTRL_AF);
		-- MCR Read Access --
		ALU_FW_O(FWD_MCR_R_ACC) <= CTRL_I(CTRL_EN) and ((CTRL_I(CTRL_MREG_ACC) and (not CTRL_I(CTRL_MREG_RW))) or (CTRL_I(CTRL_CP_ACC) and (not CTRL_I(CTRL_CP_RW))));
		-- Memory Read Access --
		ALU_FW_O(FWD_MEM_R_ACC) <= CTRL_I(CTRL_EN) and CTRL_I(CTRL_MEM_ACC)  and (not CTRL_I(CTRL_MEM_RW));
		-- Memory-Pc Load --
		ALU_FW_O(FWD_MEM_PC_LD) <= '0'; -- not needed here



	-- Stage Data Mux --------------------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------

		--- MCR / CP Read Access ---
		RESULT_TMP  <= MCR_DTA_I when ((CTRL_I(CTRL_MREG_ACC) = '1') and (CTRL_I(CTRL_MREG_RW) = '0')) or
                                      ((CTRL_I(CTRL_CP_ACC)   = '1') and (CTRL_I(CTRL_CP_RW)   = '0')) else ALU_OUT;
		RESULT_O <= RESULT_TMP;

		--- MCR Connection ---
		MCR_DTA_O <= ALU_OUT;

		--- Memory Address ---
		ADR_O     <= ALU_OUT;



end ALU_STRUCTURE;