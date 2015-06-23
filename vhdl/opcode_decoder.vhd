library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

use work.cpu_pack.ALL;

entity opcode_decoder is
	PORT(	CLK_I  : IN  std_logic;
			T2     : IN  std_logic;
			CLR    : IN  std_logic;
			CE     : IN  std_logic;
			OPCODE : IN  std_logic_vector(7 downto 0);
			OP_CYC : IN  cycle;					-- current cycle (M1, M2, ...)
			INT    : IN  std_logic;				-- interrupt
			RRZ    : IN  std_logic;				-- RR is zero

			OP_CAT : OUT op_category;

			-- select signals
			D_SX    : out std_logic_vector(1 downto 0);		-- ALU select X
			D_SY    : out std_logic_vector(3 downto 0);		-- ALU select Y
			D_OP    : out std_logic_vector(4 downto 0);		-- ALU operation
			D_SA    : out std_logic_vector(4 downto 0);		-- select address
			D_SMQ   : out std_logic;

			-- write enable/select signal
			D_WE_RR  : out std_logic;
			D_WE_LL  : out std_logic;
			D_WE_SP  : out SP_OP;

			D_RD_O   : out std_logic;
			D_WE_O   : out std_logic;
			D_LOCK   : out std_logic;

			-- input/output
			D_IO     : out std_logic;

			PC_OP  : out std_logic_vector(2 downto 0);

			LAST_M : out std_logic;		-- last M cycle of an opcode
			HLT    : out std_logic
		);
end opcode_decoder;

architecture Behavioral of opcode_decoder is

	function pc(A : std_logic;
				OP : std_logic_vector(2 downto 0)) return std_logic_vector is
	begin
		if (A = '1') then	return OP;
		else				return PC_NEXT;
		end if;
	end;

	function hadr(	A   : std_logic;
					ADR : std_logic_vector(4 downto 0)) return std_logic_vector is
	begin
		return ADR(4 downto 1) & A;
	end;

	function mix(A : std_logic) return std_logic_vector is
	begin
		if (A = '1') then	return ALU_X_MIX_Y;
		else				return ALU_MOVE_Y;
		end if;
	end;

	function sp(A : std_logic;
				OP : SP_OP) return SP_OP is
	begin
		if (A = '1') then	return OP;
		else				return SP_NOP;
		end if;
	end;

	signal LAST         : cycle;

	signal ENABLE_INT   : std_logic;
	signal DISABLE_INT  : std_logic;
	signal DISABLE_CNT  : std_logic_vector(3 downto 0);

	signal HALT_REQ     : std_logic;
	signal UNHALT_REQ   : std_logic;
	signal HALTED       : std_logic;
	signal INT_M1       : std_logic;
	signal INT_M2       : std_logic;

begin

	LAST_M <= '1' when (OP_CYC = LAST) else '0';

	HLT    <= HALTED;	-- show when CPU is halted
	-- HLT    <= '1' when DISABLE_CNT = 0 else '0';	-- show when ints enabled

	process(CLK_I, CLR)
	begin
		if (CLR = '1') then
			DISABLE_CNT <= "0001";	-- 1 x disabled
			INT_M2      <= '0';
			HALTED      <= '0';
		elsif ((rising_edge(CLK_I) and T2 = '1') and CE = '1' ) then
			if (DISABLE_INT = '1') then
				DISABLE_CNT <= DISABLE_CNT + 1;
			elsif (ENABLE_INT  = '1' and DISABLE_CNT /= 0) then
				DISABLE_CNT <= DISABLE_CNT - 1;
			end if;

			if (UNHALT_REQ = '1') then
				HALTED <= '0';
			elsif (HALT_REQ = '1') then
				HALTED <= '1';
			end if;

			INT_M2 <= INT_M1;
		end if;
	end process;

	process(OPCODE, OP_CYC, INT, RRZ, INT_M2, DISABLE_CNT, HALTED)

		variable	IS_M1			: std_logic;
		variable	IS_M2, IS_M1_M2	: std_logic;
		variable	IS_M3, IS_M2_M3	: std_logic;
		variable	IS_M4, IS_M3_M4	: std_logic;
		variable	IS_M5			: std_logic;

	begin
		if (OP_CYC = M1) then	IS_M1 := '1';	else	IS_M1 := '0';	end if;
		if (OP_CYC = M2) then	IS_M2 := '1';	else	IS_M2 := '0';	end if;
		if (OP_CYC = M3) then	IS_M3 := '1';	else	IS_M3 := '0';	end if;
		if (OP_CYC = M4) then	IS_M4 := '1';	else	IS_M4 := '0';	end if;
		if (OP_CYC = M5) then	IS_M5 := '1';	else	IS_M5 := '0';	end if;

		IS_M1_M2		:= IS_M1 or IS_M2;
		IS_M2_M3		:=          IS_M2 or IS_M3;
		IS_M3_M4		:=                   IS_M3 or IS_M4;

		-- default: NOP
		--
		OP_CAT      <= undef;
		D_SX        <= SX_ANY;
		D_SY        <= SY_ANY;
		D_OP        <= "00000";
		D_SA        <= "00000";
		D_SMQ       <= '0';
		D_WE_RR     <= '0';
		D_WE_LL     <= '0';
		D_WE_SP     <= SP_NOP;
		D_WE_O      <= '0';
		D_RD_O      <= '0';
		D_LOCK      <= '0';
		D_IO        <= '0';
		PC_OP       <= PC_NEXT;
		LAST        <= M1;			-- default: single cycle opcode (M1 only)
		ENABLE_INT  <= '0';
		DISABLE_INT <= '0';
		HALT_REQ    <= '0';
		UNHALT_REQ  <= '0';
		INT_M1      <= '0';

		if ((IS_M1 = '1' and INT = '1' and DISABLE_CNT = "0000")	-- new INT or
			or INT_M2 = '1' ) then							-- continue INT
			OP_CAT      <= INTR;
			LAST        <= M2;
			INT_M1      <= IS_M1;
			D_OP        <= ALU_X_ADD_Y;
			D_SX        <= SX_PC;
			D_SY        <= SY_SY0;		-- PC + 0 (current PC)
			D_SA        <= ADR_dSP;
			D_WE_O      <= IS_M1_M2;
			D_LOCK      <= IS_M1;
			PC_OP       <= pc(IS_M1, PC_INT);
			D_SMQ       <= IS_M1;
			D_WE_SP     <= sp(IS_M1_M2, SP_LOAD);
			DISABLE_INT <= IS_M1;
			UNHALT_REQ  <= '1';

		elsif (HALTED = '1') then
			OP_CAT      <= HALT_WAIT;
			LAST        <= M2;
			PC_OP       <= PC_WAIT;

		elsif (OPCODE(7) = '1') then
			case OPCODE(6 downto 4) is
				when "010" =>
					OP_CAT  <= ADD_RR_I;
					D_OP    <= ALU_X_ADD_Y;
					D_SX    <= SX_RR;
					D_SY    <= SY_UQ;
					D_WE_RR <= IS_M1;

				when "011" =>
					OP_CAT  <= SUB_RR_I;
					D_OP    <= ALU_X_SUB_Y;
					D_SX    <= SX_RR;
					D_SY    <= SY_UQ;
					D_WE_RR <= IS_M1;

				when "100" =>
					OP_CAT  <= MOVE_I_RR;
					D_OP    <= ALU_MOVE_Y;
					D_SX    <= SX_ANY;
					D_SY    <= SY_SQ;
					D_WE_RR <= IS_M1;

				when "101" =>
					OP_CAT  <= SEQ_LL_I;
					D_OP    <= ALU_X_EQ_Y;
					D_SX    <= SX_LL;
					D_SY    <= SY_SQ;
					D_WE_RR <= IS_M1;		-- !! RR

				when "110" =>
					OP_CAT  <= MOVE_I_LL;
					D_OP    <= ALU_MOVE_Y;
					D_SX    <= SX_ANY;
					D_SY    <= SY_UQ;
					D_WE_LL <= IS_M1;

				when "111" =>
					case OPCODE(3 downto 0) is
						when "0100" =>
							OP_CAT  <= ADD_RR_I;
							D_OP    <= ALU_X_ADD_Y;
							D_SX    <= SX_RR;
							D_SY    <= SY_I16;
							LAST    <= M3;
							D_WE_RR <= IS_M3;
	
						when "0101" =>
							OP_CAT  <= ADD_RR_I;
							D_OP    <= ALU_X_ADD_Y;
							D_SX    <= SX_RR;
							D_SY    <= SY_UI8;
							LAST    <= M2;
							D_WE_RR <= IS_M2;
	
						when "0110" =>
							OP_CAT  <= SUB_RR_I;
							D_OP    <= ALU_X_SUB_Y;
							D_SX    <= SX_RR;
							D_SY    <= SY_I16;
							LAST    <= M3;
							D_WE_RR <= IS_M3;

						when "0111" =>
							OP_CAT  <= SUB_RR_I;
							D_OP    <= ALU_X_SUB_Y;
							D_SX    <= SX_RR;
							D_SY    <= SY_UI8;
							LAST    <= M2;
							D_WE_RR <= IS_M2;

						when "1000" =>
							OP_CAT <= MOVE_I_RR;
							D_OP   <= ALU_MOVE_Y;
							D_SX   <= SX_ANY;
							D_SY   <= SY_I16;
							LAST    <= M3;
							D_WE_RR <= IS_M3;

						when "1001" =>
							OP_CAT  <= MOVE_I_RR;
							D_OP    <= ALU_MOVE_Y;
							D_SX    <= SX_ANY;
							D_SY    <= SY_SI8;
							LAST    <= M2;
							D_WE_RR <= IS_M2;

						when "1010" =>
							OP_CAT <= SEQ_LL_I;
							D_OP   <= ALU_X_EQ_Y;
							D_SX   <= SX_LL;
							D_SY   <= SY_I16;
							LAST    <= M3;
							D_WE_RR <= IS_M3;			-- SEQ sets RR !

						when "1011" =>
							OP_CAT  <= SEQ_LL_I;
							D_OP    <= ALU_X_EQ_Y;
							D_SX    <= SX_LL;
							D_SY    <= SY_SI8;
							LAST    <= M2;
							D_WE_RR <= IS_M2;			-- SEQ sets RR !

						when "1100" =>
							OP_CAT <= MOVE_I_LL;
							D_OP   <= ALU_MOVE_Y;
							D_SX   <= SX_ANY;
							D_SY   <= SY_I16;
							LAST    <= M3;
							D_WE_LL <= IS_M3;

						when "1101" =>
							OP_CAT  <= MOVE_I_LL;
							D_OP    <= ALU_MOVE_Y;
							D_SX    <= SX_ANY;
							D_SY    <= SY_SI8;
							LAST    <= M2;
							D_WE_LL <= IS_M2;

					when others =>	-- undefined
				end case;

				when others =>	-- undefined
			end case;
		else
			case OPCODE(6 downto 0) is
				-- 00000000000000000000000000000000000000000000000000000000000000000000
				when "0000000" =>
					OP_CAT   <= HALT;
					HALT_REQ <= '1';
					PC_OP    <= PC_WAIT;

				when "0000001" =>
					OP_CAT <= NOP;

				when "0000010" =>
					OP_CAT <= JMP_i;
					LAST   <= M3;
					PC_OP  <= pc(IS_M2, PC_JMP);

				when "0000011" =>
					OP_CAT <= JMP_RRNZ_i;
					LAST   <= M3;
					PC_OP  <= pc(IS_M2 and not RRZ, PC_JMP);

				when "0000100" =>
					OP_CAT <= JMP_RRZ_i;
					LAST   <= M3;
					PC_OP  <= pc(IS_M2 and RRZ, PC_JMP);

				when "0000101" =>
					OP_CAT  <= CALL_i;
					LAST    <= M3;
					D_OP    <= ALU_X_ADD_Y;
					D_SX    <= SX_PC;
					D_SY    <= SY_SY3;		-- PC + 3
					D_SA    <= ADR_dSP;
					D_WE_O  <= IS_M1_M2;
					D_LOCK  <= IS_M1;
					PC_OP   <= pc(IS_M2, PC_JMP);
					D_SMQ   <= IS_M1;
					D_WE_SP <= sp(IS_M1_M2, SP_LOAD);

				when "0000110" =>
					OP_CAT  <= CALL_RR;
					LAST    <= M2;
					D_OP    <= ALU_X_ADD_Y;
					D_SX    <= SX_PC;
					D_SY    <= SY_SY1;		-- PC + 1
					D_SA    <= ADR_dSP;
					D_WE_O  <= IS_M1_M2;
					D_LOCK  <= IS_M1;
					PC_OP   <= pc(IS_M1, PC_JPRR);
					D_SMQ   <= IS_M1;
					D_WE_SP <= sp(IS_M1_M2, SP_LOAD);

				when "0000111" | "1111000" =>
					if (OPCODE(0) = '1') then
						OP_CAT      <= RET;
					else
						OP_CAT      <= RETI;
						ENABLE_INT  <= IS_M1;
					end if;

					LAST    <= M5;
					D_SA    <= ADR_SPi;		-- read address: (SP)+
					D_RD_O  <= IS_M1_M2;
					D_LOCK  <= IS_M1;
					D_WE_SP <= sp(IS_M1_M2, SP_INC);
					case OP_CYC is
						when M1 =>	PC_OP   <= PC_WAIT;
						when M2 =>	PC_OP   <= PC_WAIT;
						when M3 =>	PC_OP   <= PC_RETL;
						when M4 =>	PC_OP   <= PC_RETH;
						when others =>
					end case;

				when "0001000" =>
					OP_CAT  <= MOVE_SPi_RR;
					D_SX    <= SX_RR;
					D_SY    <= SY_UM;
					D_SA    <= ADR_SPi;
					D_RD_O  <= IS_M1_M2;
					D_LOCK  <= IS_M1;
					LAST    <= M3;
					PC_OP   <= pc(IS_M1_M2, PC_WAIT);
					D_WE_RR <= IS_M2_M3;
					D_WE_SP <= sp(IS_M1_M2, SP_INC);
					D_OP    <= mix(IS_M3);

				when "0001001" =>
					OP_CAT  <= MOVE_SPi_RS;
					LAST    <= M2;
					D_OP    <= ALU_MOVE_Y;
					D_SX    <= SX_ANY;
					D_SY    <= SY_SM;
					D_SA    <= ADR_SPi;
					D_RD_O  <= IS_M1;
					D_WE_RR <= IS_M2;
					PC_OP   <= pc(IS_M1, PC_WAIT);
					D_WE_SP <= sp(IS_M1, SP_INC);

				when "0001010" =>
					OP_CAT  <= MOVE_SPi_RU;
					LAST    <= M2;
					D_OP    <= ALU_MOVE_Y;
					D_SX    <= SX_ANY;
					D_SY    <= SY_UM;
					D_SA    <= ADR_SPi;
					D_RD_O  <= IS_M1;
					PC_OP   <= pc(IS_M1, PC_WAIT);
					D_WE_SP <= sp(IS_M1, SP_INC);
					D_WE_RR <= IS_M2;

				when "0001011" =>
					OP_CAT  <= MOVE_SPi_LL;
					LAST    <= M3;
					D_SX    <= SX_LL;
					D_SY    <= SY_UM;
					D_SA    <= ADR_SPi;
					D_RD_O  <= IS_M1_M2;
					D_LOCK  <= IS_M1;
					PC_OP   <= pc(IS_M1_M2, PC_WAIT);
					D_WE_SP <= sp(IS_M1_M2, SP_INC);
					D_WE_LL <= IS_M2_M3;
					D_OP    <= mix(IS_M3);

				when "0001100" =>
					OP_CAT  <= MOVE_SPi_LS;
					LAST    <= M2;
					D_OP    <= ALU_MOVE_Y;
					D_SX    <= SX_ANY;
					D_SY    <= SY_SM;
					D_SA    <= ADR_SPi;
					D_RD_O  <= IS_M1;
					PC_OP   <= pc(IS_M1, PC_WAIT);
					D_WE_SP <= sp(IS_M1, SP_INC);
					D_WE_LL <= IS_M2;

				when "0001101" =>
					OP_CAT  <= MOVE_SPi_LU;
					LAST    <= M2;
					D_OP    <= ALU_MOVE_Y;
					D_SX    <= SX_ANY;
					D_SY    <= SY_UM;
					D_SA    <= ADR_SPi;
					D_RD_O  <= IS_M1;
					PC_OP   <= pc(IS_M1, PC_WAIT);
					D_WE_SP <= sp(IS_M1, SP_INC);
					D_WE_LL <= IS_M2;

				when "0001110" =>
					OP_CAT  <= MOVE_RR_dSP;
					LAST    <= M2;
					D_OP    <= ALU_X_OR_Y;
					D_SX    <= SX_RR;
					D_SY    <= SY_SY0;
					D_SA    <= ADR_dSP;
					D_WE_O  <= IS_M1_M2;
					D_LOCK  <= IS_M1;
					PC_OP   <= pc(IS_M1, PC_WAIT);
					D_WE_SP <= sp(IS_M1_M2, SP_LOAD);
					D_SMQ   <= IS_M1;

				when "0001111" =>
					OP_CAT  <= MOVE_R_dSP;
					D_OP    <= ALU_X_OR_Y;
					D_SX    <= SX_RR;
					D_SY    <= SY_SY0;
					D_SA    <= ADR_dSP;
					D_WE_O  <= '1';
					D_WE_SP <= SP_LOAD;

				-- 11111111111111111111111111111111111111111111111111111111111111111111
				when "0010000" =>
					OP_CAT  <= AND_RR_i;
					LAST    <= M3;		-- wait for ##
					D_OP    <= ALU_X_AND_Y;
					D_SX    <= SX_RR;
					D_SY    <= SY_I16;
					D_WE_RR <= IS_M2;

				when "0010001" =>
					OP_CAT  <= AND_RR_i;
					LAST    <= M2;			-- wait for #
					D_OP    <= ALU_X_AND_Y;
					D_SX    <= SX_RR;
					D_SY    <= SY_UI8;
					D_WE_RR <= IS_M1;

				when "0010010" =>
					OP_CAT  <= OR_RR_i;
					LAST    <= M3;		-- wait for ##
					D_OP    <= ALU_X_OR_Y;
					D_SX    <= SX_RR;
					D_SY    <= SY_I16;
					D_WE_RR <= IS_M2;

				when "0010011" =>
					OP_CAT  <= OR_RR_i;
					LAST    <= M2;			-- wait for #
					D_OP    <= ALU_X_OR_Y;
					D_SX    <= SX_RR;
					D_SY    <= SY_UI8;
					D_WE_RR <= IS_M1;

				when "0010100" =>
					OP_CAT  <= XOR_RR_i;
					LAST    <= M3;		-- wait for ##
					D_OP    <= ALU_X_XOR_Y;
					D_SX    <= SX_RR;
					D_SY    <= SY_I16;
					D_WE_RR <= IS_M2;

				when "0010101" =>
					OP_CAT  <= XOR_RR_i;
					LAST    <= M2;			-- wait for #
					D_OP    <= ALU_X_XOR_Y;
					D_SX    <= SX_RR;
					D_SY    <= SY_UI8;
					D_WE_RR <= IS_M1;

				when "0010110" =>
					OP_CAT  <= SEQ_RR_i;
					LAST    <= M3;		-- wait for ##
					D_OP    <= ALU_X_EQ_Y;
					D_SX    <= SX_RR;
					D_SY    <= SY_I16;
					D_WE_RR <= IS_M2;

				when "0010111" =>
					OP_CAT  <= SEQ_RR_i;
					LAST    <= M2;			-- wait for #
					D_OP    <= ALU_X_EQ_Y;
					D_SX    <= SX_RR;
					D_SY    <= SY_UI8;
					D_WE_RR <= IS_M1;

				when "0011000" =>
					OP_CAT  <= SNE_RR_i;
					LAST    <= M3;		-- wait for ##
					D_OP    <= ALU_X_NE_Y;
					D_SX    <= SX_RR;
					D_SY    <= SY_I16;
					D_WE_RR <= IS_M2;

				when "0011001" =>
					OP_CAT  <= SNE_RR_i;
					LAST    <= M2;			-- wait for #
					D_OP    <= ALU_X_NE_Y;
					D_SX    <= SX_RR;
					D_SY    <= SY_UI8;
					D_WE_RR <= IS_M1;

				when "0011010" =>
					OP_CAT  <= SGE_RR_i;
					LAST    <= M3;		-- wait for ##
					D_OP    <= ALU_X_GE_Y;
					D_SX    <= SX_RR;
					D_SY    <= SY_I16;
					D_WE_RR <= IS_M2;

				when "0011011" =>
					OP_CAT  <= SGE_RR_i;
					LAST    <= M2;			-- wait for #
					D_OP    <= ALU_X_GE_Y;
					D_SX    <= SX_RR;
					D_SY    <= SY_SI8;
					D_WE_RR <= IS_M1;

				when "0011100" =>
					OP_CAT  <= SGT_RR_i;
					LAST    <= M3;		-- wait for ##
					D_OP    <= ALU_X_GT_Y;
					D_SX    <= SX_RR;
					D_SY    <= SY_I16;
					D_WE_RR <= IS_M2;

				when "0011101" =>
					OP_CAT  <= SGT_RR_i;
					LAST    <= M2;			-- wait for #
					D_OP    <= ALU_X_GT_Y;
					D_SX    <= SX_RR;
					D_SY    <= SY_SI8;
					D_WE_RR <= IS_M1;

				when "0011110" =>
					OP_CAT  <= SLE_RR_i;
					LAST    <= M3;		-- wait for ##
					D_OP    <= ALU_X_LE_Y;
					D_SX    <= SX_RR;
					D_SY    <= SY_I16;
					D_WE_RR <= IS_M2;

				when "0011111" =>
					OP_CAT  <= SLE_RR_i;
					LAST    <= M2;			-- wait for #
					D_OP    <= ALU_X_LE_Y;
					D_SX    <= SX_RR;
					D_SY    <= SY_SI8;
					D_WE_RR <= IS_M1;

				-- 22222222222222222222222222222222222222222222222222222222222222222222
				when "0100000" =>
					OP_CAT  <= SLT_RR_i;
					LAST    <= M3;		-- wait for ##
					D_OP    <= ALU_X_LT_Y;
					D_SX    <= SX_RR;
					D_SY    <= SY_I16;
					D_WE_RR <= IS_M2;

				when "0100001" =>
					OP_CAT  <= SLT_RR_i;
					LAST    <= M2;			-- wait for #
					D_OP    <= ALU_X_LT_Y;
					D_SX    <= SX_RR;
					D_SY    <= SY_SI8;
					D_WE_RR <= IS_M1;

				when "0100010" =>
					OP_CAT  <= SHS_RR_i;
					LAST    <= M3;		-- wait for ##
					D_OP    <= ALU_X_HS_Y;
					D_SX    <= SX_RR;
					D_SY    <= SY_I16;
					D_WE_RR <= IS_M2;

				when "0100011" =>
					OP_CAT  <= SHS_RR_i;
					LAST    <= M2;			-- wait for #
					D_OP    <= ALU_X_HS_Y;
					D_SX    <= SX_RR;
					D_SY    <= SY_UI8;
					D_WE_RR <= IS_M1;

				when "0100100" =>
					OP_CAT  <= SHI_RR_i;
					LAST    <= M3;		-- wait for ##
					D_OP    <= ALU_X_HI_Y;
					D_SX    <= SX_RR;
					D_SY    <= SY_I16;
					D_WE_RR <= IS_M2;

				when "0100101" =>
					OP_CAT  <= SHI_RR_i;
					LAST    <= M2;			-- wait for #
					D_OP    <= ALU_X_HI_Y;
					D_SX    <= SX_RR;
					D_SY    <= SY_UI8;
					D_WE_RR <= IS_M1;

				when "0100110" =>
					OP_CAT <= SLS_RR_i;
					LAST    <= M3;		-- wait for ##
					D_OP   <= ALU_X_LS_Y;
					D_SX   <= SX_RR;
					D_SY   <= SY_I16;
					D_WE_RR <= IS_M2;

				when "0100111" =>
					OP_CAT  <= SLS_RR_i;
					LAST    <= M2;			-- wait for #
					D_OP    <= ALU_X_LS_Y;
					D_SX    <= SX_RR;
					D_SY    <= SY_UI8;
					D_WE_RR <= IS_M1;

				when "0101000" =>
					OP_CAT  <= SLO_RR_i;
					LAST    <= M3;		-- wait for ##
					D_OP    <= ALU_X_LO_Y;
					D_SX    <= SX_RR;
					D_SY    <= SY_I16;
					D_WE_RR <= IS_M2;

				when "0101001" =>
					OP_CAT  <= SLO_RR_i;
					LAST    <= M2;			-- wait for #
					D_OP    <= ALU_X_LO_Y;
					D_SX    <= SX_RR;
					D_SY    <= SY_UI8;
					D_WE_RR <= IS_M1;

				when "0101010" =>
					OP_CAT  <= ADD_SP_I;
					LAST    <= M3;		-- wait for ##
					D_OP    <= ALU_ANY;
					D_SX    <= SX_ANY;
					D_SY    <= SY_ANY;
					D_SA    <= ADR_16SP_L;
					D_WE_SP <= sp(IS_M2, SP_LOAD);

				when "0101011" =>
					OP_CAT  <= ADD_SP_I;
					LAST    <= M2;			-- wait for #
					D_OP    <= ALU_ANY;
					D_SX    <= SX_ANY;
					D_SY    <= SY_ANY;
					D_SA    <= ADR_8SP_L;
					D_WE_SP <= sp(IS_M1, SP_LOAD);

				when "0101100" =>
					OP_CAT  <= CLRW_dSP;
					LAST    <= M2;
					D_OP    <= ALU_X_AND_Y;
					D_SX    <= SX_ANY;
					D_SY    <= SY_SY0;
					D_SA    <= ADR_dSP;
					D_WE_O  <= '1';
					D_LOCK  <= IS_M1;
					D_WE_SP <= SP_LOAD;
					PC_OP   <= pc(IS_M1, PC_WAIT);

				when "0101101" =>
					OP_CAT  <= CLRB_dSP;
					D_OP    <= ALU_X_AND_Y;
					D_SX    <= SX_ANY;
					D_SY    <= SY_SY0;
					D_SA    <= ADR_dSP;
					D_WE_O  <= IS_M1;
					D_WE_SP <= SP_LOAD;

				when "0101110" =>
					OP_CAT  <= IN_ci_RU;
					LAST    <= M2;
					D_OP    <= ALU_MOVE_Y;
					D_SX    <= SX_ANY;
					D_SY    <= SY_UM;
					D_SA    <= ADR_IO;
					D_RD_O  <= IS_M1;
					D_IO    <= IS_M1;
					D_WE_RR <= IS_M2;

				when "0101111" =>
					OP_CAT  <= OUT_R_ci;
					LAST    <= M2;
					D_OP    <= ALU_X_OR_Y;
					D_SX    <= SX_RR;
					D_SY    <= SY_SY0;
					D_SA    <= ADR_IO;
					D_WE_O  <= IS_M1;
					D_IO    <= IS_M1;

				-- 33333333333333333333333333333333333333333333333333333333333333333333
				when "0110000" =>
					OP_CAT  <= AND_LL_RR;
					D_OP    <= ALU_X_AND_Y;
					D_SX    <= SX_LL;
					D_SY    <= SY_RR;
					D_WE_RR <= IS_M1;

				when "0110001" =>
					OP_CAT  <= OR_LL_RR;
					D_OP    <= ALU_X_OR_Y;
					D_SX    <= SX_LL;
					D_SY    <= SY_RR;
					D_WE_RR <= IS_M1;

				when "0110010" =>
					OP_CAT  <= XOR_LL_RR;
					D_OP    <= ALU_X_XOR_Y;
					D_SX    <= SX_LL;
					D_SY    <= SY_RR;
					D_WE_RR <= IS_M1;

				when "0110011" =>
					OP_CAT  <= SEQ_LL_RR;
					D_OP    <= ALU_X_EQ_Y;
					D_SX    <= SX_LL;
					D_SY    <= SY_RR;
					D_WE_RR <= IS_M1;

				when "0110100" =>
					OP_CAT  <= SNE_LL_RR;
					D_OP    <= ALU_X_NE_Y;
					D_SX    <= SX_LL;
					D_SY    <= SY_RR;
					D_WE_RR <= IS_M1;

				when "0110101" =>
					OP_CAT  <= SGE_LL_RR;
					D_OP    <= ALU_X_GE_Y;
					D_SX    <= SX_LL;
					D_SY    <= SY_RR;
					D_WE_RR <= IS_M1;

				when "0110110" =>
					OP_CAT  <= SGT_LL_RR;
					D_OP    <= ALU_X_GT_Y;
					D_SX    <= SX_LL;
					D_SY    <= SY_RR;
					D_WE_RR <= IS_M1;

				when "0110111" =>
					OP_CAT  <= SLE_LL_RR;
					D_OP    <= ALU_X_LE_Y;
					D_SX    <= SX_LL;
					D_SY    <= SY_RR;
					D_WE_RR <= IS_M1;

				when "0111000" =>
					OP_CAT  <= SLT_LL_RR;
					D_OP    <= ALU_X_LT_Y;
					D_SX    <= SX_LL;
					D_SY    <= SY_RR;
					D_WE_RR <= IS_M1;

				when "0111001" =>
					OP_CAT  <= SHS_LL_RR;
					D_OP    <= ALU_X_HS_Y;
					D_SX    <= SX_LL;
					D_SY    <= SY_RR;
					D_WE_RR <= IS_M1;

				when "0111010" =>
					OP_CAT  <= SHI_LL_RR;
					D_OP    <= ALU_X_HI_Y;
					D_SX    <= SX_LL;
					D_SY    <= SY_RR;
					D_WE_RR <= IS_M1;

				when "0111011" =>
					OP_CAT  <= SLS_LL_RR;
					D_OP    <= ALU_X_LS_Y;
					D_SX    <= SX_LL;
					D_SY    <= SY_RR;
					D_WE_RR <= IS_M1;

				when "0111100" =>
					OP_CAT  <= SLO_LL_RR;
					D_OP    <= ALU_X_LO_Y;
					D_SX    <= SX_LL;
					D_SY    <= SY_RR;
					D_WE_RR <= IS_M1;

				when "0111101" =>
					OP_CAT  <= LNOT_RR;
					D_OP    <= ALU_X_EQ_Y;
					D_SX    <= SX_RR;
					D_SY    <= SY_SY0;
					D_WE_RR <= IS_M1;

				when "0111110" =>
					OP_CAT  <= NEG_RR;
					D_OP    <= ALU_NEG_Y;
					D_SX    <= SX_ANY;
					D_SY    <= SY_RR;
					D_WE_RR <= IS_M1;

				when "0111111" =>
					OP_CAT  <= NOT_RR;
					D_OP    <= ALU_NOT_Y;
					D_SX    <= SX_ANY;
					D_SY    <= SY_RR;
					D_WE_RR <= IS_M1;

				-- 44444444444444444444444444444444444444444444444444444444444444444444
				when "1000000" =>
					OP_CAT  <= MOVE_LL_RR;
					D_OP    <= ALU_X_OR_Y;
					D_SX    <= SX_LL;
					D_SY    <= SY_SY0;
					D_WE_RR <= IS_M1;

				when "1000001" =>
					OP_CAT  <= MOVE_LL_cRR;
					LAST    <= M2;
					PC_OP   <= pc(IS_M1, PC_WAIT);
					D_OP    <= ALU_X_OR_Y;
					D_SX    <= SX_LL;
					D_SY    <= SY_SY0;
					D_SA    <= hadr(IS_M2, ADR_cRR_H);
					D_WE_O  <= IS_M1_M2;
					D_LOCK  <= IS_M1;
					D_SMQ   <= IS_M2;

				when "1000010" =>
					OP_CAT  <= MOVE_L_cRR;
					D_OP    <= ALU_X_OR_Y;
					D_SX    <= SX_LL;
					D_SY    <= SY_SY0;
					D_SA    <= ADR_cRR_L;
					D_WE_O  <= IS_M1;

				when "1000011" =>
					OP_CAT  <= MOVE_RR_LL;
					D_OP    <= ALU_X_OR_Y;
					D_SX    <= SX_RR;
					D_SY    <= SY_SY0;
					D_WE_LL <= IS_M1;

				when "1000100" =>
					OP_CAT  <= MOVE_RR_cLL;
					LAST    <= M2;
					PC_OP   <= pc(IS_M1, PC_WAIT);
					D_OP    <= ALU_X_OR_Y;
					D_SX    <= SX_RR;
					D_SY    <= SY_SY0;
					D_SA    <= hadr(IS_M2, ADR_cLL_H);
					D_WE_O  <= IS_M1_M2;
					D_LOCK  <= IS_M1;
					D_SMQ   <= IS_M2;

				when "1000101" =>
					OP_CAT  <= MOVE_R_cLL;
					D_OP    <= ALU_X_OR_Y;
					D_SX    <= SX_RR;
					D_SY    <= SY_SY0;
					D_SA    <= ADR_cLL_L;
					D_WE_O  <= IS_M1;

				when "1000110" =>
					OP_CAT  <= MOVE_cRR_RR;
					LAST    <= M3;
					D_SX    <= SX_ANY;
					D_SY    <= SY_UM;
					D_WE_RR <= not IS_M1;		-- M2 or M3
					PC_OP   <= pc(IS_M1_M2, PC_WAIT);
					D_OP    <= mix(IS_M3);
					D_SA    <= hadr(IS_M2, ADR_cRR_H);
					D_RD_O  <= IS_M1_M2;
					D_LOCK  <= IS_M1;

				when "1000111" =>
					OP_CAT  <= MOVE_cRR_RS;
					LAST    <= M2;
					D_OP    <= ALU_MOVE_Y;
					D_SX    <= SX_ANY;
					D_SY    <= SY_SM;
					D_SA    <= ADR_cRR_L;
					D_RD_O  <= IS_M1;
					D_WE_RR <= IS_M2;
					PC_OP   <= pc(IS_M1, PC_WAIT);

				when "1001000" =>
					OP_CAT  <= MOVE_cRR_RU;
					LAST    <= M2;
					D_OP    <= ALU_MOVE_Y;
					D_SX    <= SX_ANY;
					D_SY    <= SY_UM;
					D_SA    <= ADR_cRR_L;
					D_RD_O  <= IS_M1;
					D_WE_RR <= IS_M2;
					PC_OP  <= pc(IS_M1, PC_WAIT);

				when "1001001" =>
					OP_CAT  <= MOVE_ci_RR;
					LAST    <= M4;
					D_SX    <= SX_RR;
					D_SY    <= SY_UM;
					PC_OP   <= pc(IS_M3, PC_WAIT);
					D_OP    <= mix(IS_M4);
					D_WE_RR <= IS_M3_M4;
					D_SA    <= hadr(IS_M3, ADR_cI16_H);
					D_RD_O  <= IS_M2_M3;
					D_LOCK  <= IS_M2;

				when "1001010" =>
					OP_CAT  <= MOVE_ci_RS;
					LAST    <= M3;
					D_OP    <= ALU_MOVE_Y;
					D_SX    <= SX_ANY;
					D_SY    <= SY_SM;
					D_SA    <= ADR_cI16_L;
					D_RD_O  <= IS_M2;
					D_WE_RR <= IS_M3;

				when "1001011" =>
					OP_CAT  <= MOVE_ci_RU;
					LAST    <= M3;
					D_OP    <= ALU_MOVE_Y;
					D_SX    <= SX_ANY;
					D_SY    <= SY_UM;
					D_SA    <= ADR_cI16_L;
					D_RD_O  <= IS_M2;
					D_WE_RR <= IS_M3;

				when "1001100" =>
					OP_CAT  <= MOVE_ci_LL;
					LAST    <= M4;
					D_SX    <= SX_LL;
					D_SY    <= SY_UM;
					PC_OP   <= pc(IS_M3, PC_WAIT);
					D_OP    <= mix(IS_M4);
					D_SA    <= hadr(IS_M3, ADR_cI16_H);
					D_RD_O  <= IS_M2_M3;
					D_LOCK  <= IS_M2;
					D_WE_LL <= IS_M3_M4;

				when "1001101" =>
					OP_CAT  <= MOVE_ci_LS;
					LAST    <= M3;
					D_OP    <= ALU_MOVE_Y;
					D_SX    <= SX_ANY;
					D_SY    <= SY_SM;
					D_SA    <= ADR_cI16_L;
					D_RD_O  <= IS_M2;
					D_WE_LL <= IS_M3;

				when "1001110" =>
					OP_CAT  <= MOVE_ci_LU;
					LAST    <= M3;
					D_OP    <= ALU_MOVE_Y;
					D_SX    <= SX_ANY;
					D_SY    <= SY_UM;
					D_SA    <= ADR_cI16_L;
					D_RD_O  <= IS_M2;
					D_WE_LL <= IS_M3;

				when "1001111" =>
					OP_CAT  <= MOVE_RR_SP;
					D_SA    <= ADR_cRR_L;
					D_WE_SP <= SP_LOAD;

				-- 55555555555555555555555555555555555555555555555555555555555555555555
				when "1010000" =>
					-- spare

				when "1010001" =>
					-- spare

				when "1010010" =>
					OP_CAT  <= LSL_RR_i;
					LAST    <= M2;
					D_OP    <= ALU_X_LSL_Y;
					D_SX    <= SX_RR;
					D_SY    <= SY_UI8;
					D_WE_RR <= IS_M1;

				when "1010011" =>
					OP_CAT  <= ASR_RR_i;
					LAST    <= M2;
					D_OP    <= ALU_X_ASR_Y;
					D_SX    <= SX_RR;
					D_SY    <= SY_UI8;
					D_WE_RR <= IS_M1;

				when "1010100" =>
					OP_CAT  <= LSR_RR_i;
					LAST    <= M2;
					D_OP    <= ALU_X_LSR_Y;
					D_SX    <= SX_RR;
					D_SY    <= SY_UI8;
					D_WE_RR <= IS_M1;

				when "1010101" =>
					OP_CAT  <= LSL_LL_RR;
					D_OP    <= ALU_X_LSL_Y;
					D_SX    <= SX_LL;
					D_SY    <= SY_RR;
					D_WE_RR <= IS_M1;

				when "1010110" =>
					OP_CAT  <= ASR_LL_RR;
					D_OP    <= ALU_X_ASR_Y;
					D_SX    <= SX_LL;
					D_SY    <= SY_RR;
					D_WE_RR <= IS_M1;

				when "1010111" =>
					OP_CAT  <= LSR_LL_RR;
					D_OP    <= ALU_X_LSR_Y;
					D_SX    <= SX_LL;
					D_SY    <= SY_RR;
					D_WE_RR <= IS_M1;

				when "1011000" =>
					OP_CAT  <= ADD_LL_RR;
					D_OP    <= ALU_X_ADD_Y;
					D_SX    <= SX_LL;
					D_SY    <= SY_RR;
					D_WE_RR <= IS_M1;

				when "1011001" =>
					OP_CAT  <= SUB_LL_RR;
					D_OP    <= ALU_X_SUB_Y;
					D_SX    <= SX_LL;
					D_SY    <= SY_RR;
					D_WE_RR <= IS_M1;

				when "1011010" =>
					OP_CAT  <= MOVE_RR_ci;
					LAST    <= M3;
					D_SX    <= SX_RR;
					D_SY    <= SY_SY0;
					D_OP    <= ALU_X_OR_Y;
					D_SA    <= hadr(IS_M3, ADR_cI16_H);
					D_WE_O  <= IS_M2_M3;
					D_LOCK  <= IS_M2;
					D_SMQ   <= IS_M3;

				when "1011011" =>
					OP_CAT  <= MOVE_R_ci;
					LAST    <= M3;
					D_SX    <= SX_RR;
					D_SY    <= SY_SY0;
					D_OP    <= ALU_X_OR_Y;
					D_SA    <= ADR_cI16_L;
					D_WE_O  <= IS_M2;

				when "1011100" =>		-- long offset / long move
					OP_CAT  <= MOVE_RR_uSP;
					LAST    <= M3;
					D_SX    <= SX_RR;
					D_SY    <= SY_SY0;
					D_OP    <= ALU_X_OR_Y;
					D_SA    <= hadr(IS_M3, ADR_16SP_H);
					D_WE_O  <= IS_M2_M3;
					D_LOCK  <= IS_M2;
					D_SMQ   <= IS_M3;

				when "1011101" =>		-- short offset / long move
					OP_CAT  <= MOVE_RR_uSP;
					LAST    <= M2;
					D_SX    <= SX_RR;
					D_SY    <= SY_SY0;
					D_OP    <= ALU_X_OR_Y;
					D_SA    <= hadr(IS_M2, ADR_8SP_H);
					D_WE_O  <= IS_M1_M2;
					D_LOCK  <= IS_M1;
					D_SMQ   <= IS_M2;

				when "1011110" =>		-- long offset / short move
					OP_CAT  <= MOVE_R_uSP;
					LAST    <= M3;
					D_SX    <= SX_RR;
					D_SY    <= SY_SY0;
					D_OP    <= ALU_X_OR_Y;
					D_SA    <= ADR_16SP_L;
					D_WE_O  <= IS_M2;
					D_OP    <= ALU_X_OR_Y;

				when "1011111" =>		-- short offset / short move
					OP_CAT  <= MOVE_R_uSP;
					LAST    <= M2;
					D_SX    <= SX_RR;
					D_SY    <= SY_SY0;
					D_OP    <= ALU_X_OR_Y;
					D_SA    <= ADR_8SP_L;
					D_WE_O  <= IS_M1;
					D_OP    <= ALU_X_OR_Y;

				-- 66666666666666666666666666666666666666666666666666666666666666666666
				when "1100000" =>	-- long offset, long move
					OP_CAT <= MOVE_uSP_RR;
					LAST   <= M4;
					D_SX   <= SX_RR;
					D_SY   <= SY_UM;
					PC_OP   <= pc(IS_M3, PC_WAIT);
					D_OP    <= mix(IS_M3_M4);
					D_SA    <= hadr(IS_M3, ADR_16SP_H);
					D_RD_O  <= IS_M2_M3;
					D_LOCK  <= IS_M2;
					D_WE_RR <= IS_M3_M4;

				when "1100001" =>	-- short offset, long move
					OP_CAT  <= MOVE_uSP_RR;
					LAST    <= M3;
					D_SX    <= SX_RR;
					D_SY    <= SY_UM;
					PC_OP   <= pc(IS_M2, PC_WAIT);
					D_OP    <= mix(IS_M3);
					D_SA    <= hadr(IS_M2, ADR_8SP_H);
					D_RD_O  <= IS_M1_M2;
					D_LOCK  <= IS_M1;
					D_WE_RR <= IS_M2_M3;

				when "1100010" =>	-- long offset, short move
					OP_CAT  <= MOVE_uSP_RS;
					LAST    <= M3;
					D_OP    <= ALU_MOVE_Y;
					D_SX    <= SX_RR;
					D_SY    <= SY_SM;
					D_SA    <= ADR_16SP_L;
					D_RD_O  <= IS_M2;
					D_WE_RR <= IS_M3;

				when "1100011" =>	-- short offset, short move
					OP_CAT  <= MOVE_uSP_RS;
					LAST    <= M2;
					D_OP    <= ALU_MOVE_Y;
					D_SX    <= SX_RR;
					D_SY    <= SY_SM;
					D_SA    <= ADR_8SP_L;
					D_RD_O  <= IS_M1;
					D_WE_RR <= IS_M2;

				when "1100100" =>	-- long offset, short move
					OP_CAT  <= MOVE_uSP_RU;
					LAST    <= M3;
					D_OP    <= ALU_MOVE_Y;
					D_SX    <= SX_RR;
					D_SY    <= SY_UM;
					D_SA    <= ADR_16SP_L;
					D_RD_O  <= IS_M2;
					D_WE_RR <= IS_M3;

				when "1100101" =>	-- short offset, short move
					OP_CAT  <= MOVE_uSP_RU;
					LAST    <= M2;
					D_OP    <= ALU_MOVE_Y;
					D_SX    <= SX_RR;
					D_SY    <= SY_UM;
					D_SA    <= ADR_8SP_L;
					D_RD_O  <= IS_M1;
					D_WE_RR <= IS_M2;

				when "1100110" =>	-- long offset, long move
					OP_CAT  <= MOVE_uSP_LL;
					LAST    <= M4;
					D_SX    <= SX_LL;
					D_SY    <= SY_UM;
					PC_OP   <= pc(IS_M3, PC_WAIT);
					D_OP    <= mix(IS_M4);
					D_SA    <= hadr(IS_M3, ADR_8SP_H);
					D_RD_O  <= IS_M2_M3;
					D_LOCK  <= IS_M2;
					D_WE_LL <= IS_M3_M4;

				when "1100111" =>	-- short offset, long move
					OP_CAT  <= MOVE_uSP_LL;
					LAST    <= M3;
					D_SX    <= SX_LL;
					D_SY    <= SY_UM;
					PC_OP   <= pc(IS_M2, PC_WAIT);
					D_OP    <= mix(IS_M3);
					D_SA    <= hadr(IS_M2, ADR_8SP_H);
					D_RD_O  <= IS_M1_M2;
					D_LOCK  <= IS_M1;
					D_WE_LL <= IS_M2_M3;

				when "1101000" =>	-- long offset, short move
					OP_CAT  <= MOVE_uSP_LS;
					LAST    <= M3;
					D_OP    <= ALU_MOVE_Y;
					D_SX    <= SX_RR;
					D_SY    <= SY_SM;
					D_SA    <= ADR_16SP_L;
					D_RD_O  <= IS_M2;
					D_WE_LL <= IS_M3;

				when "1101001" =>	-- short offset, short move
					OP_CAT  <= MOVE_uSP_LS;
					LAST    <= M2;
					D_OP    <= ALU_MOVE_Y;
					D_SX    <= SX_RR;
					D_SY    <= SY_SM;
					D_SA    <= ADR_8SP_L;
					D_RD_O  <= IS_M1;
					D_WE_LL <= IS_M2;

				when "1101010" =>	-- long offset, short move
					OP_CAT  <= MOVE_uSP_LU;
					LAST    <= M3;
					D_OP    <= ALU_MOVE_Y;
					D_SX    <= SX_RR;
					D_SY    <= SY_UM;
					D_SA    <= ADR_16SP_L;
					D_RD_O  <= IS_M2;
					D_WE_LL <= IS_M3;

				when "1101011" =>	-- short offset, short move
					OP_CAT  <= MOVE_uSP_LU;
					LAST    <= M2;
					D_OP    <= ALU_MOVE_Y;
					D_SX    <= SX_RR;
					D_SY    <= SY_UM;
					D_SA    <= ADR_8SP_L;
					D_RD_O  <= IS_M1;
					D_WE_LL <= IS_M2;

				when "1101100" =>
					OP_CAT  <= LEA_uSP_RR;
					LAST    <= M3;
					D_OP    <= ALU_X_ADD_Y;
					D_SX    <= SX_SP;
					D_SY    <= SY_I16;
					D_WE_RR <= IS_M2;

				when "1101101" =>
					OP_CAT  <= LEA_uSP_RR;
					LAST    <= M2;
					D_OP    <= ALU_X_ADD_Y;
					D_SX    <= SX_SP;
					D_SY    <= SY_UI8;
					D_WE_RR <= IS_M1;

				when "1101110" =>
					OP_CAT  <= MOVE_dRR_dLL;
					LAST    <= M3;
					D_WE_RR <= IS_M1;
					D_RD_O  <= IS_M1;
					D_WE_O  <= IS_M2;
					D_WE_LL <= IS_M3;
					PC_OP  <= pc(IS_M1_M2, PC_WAIT);

					case OP_CYC is
						when M1 =>	-- decrement RR
							D_OP    <= ALU_X_SUB_Y;
							D_SX    <= SX_RR;
							D_SY    <= SY_SY1;
							D_SA    <= ADR_dRR;
						when M2 =>	-- write read memory
							D_OP    <= ALU_MOVE_Y;
							D_SX    <= SX_ANY;
							D_SY    <= SY_UM;
							D_SA    <= ADR_dLL;
						when others =>	-- decrement LL
							D_OP    <= ALU_X_SUB_Y;
							D_SX    <= SX_LL;
							D_SY    <= SY_SY1;
					end case;

				when "1101111" =>
					OP_CAT  <= MOVE_RRi_LLi;
					LAST    <= M3;
					D_WE_RR <= IS_M1;
					D_RD_O  <= IS_M1;
					D_WE_O  <= IS_M2;
					D_WE_LL <= IS_M3;
					PC_OP  <= pc(IS_M1_M2, PC_WAIT);

					case OP_CYC is
						when M1 =>	-- decrement RR
							D_OP    <= ALU_X_ADD_Y;
							D_SX    <= SX_RR;
							D_SY    <= SY_SY1;
							D_SA    <= ADR_RRi;
						when M2 =>	-- write read memory
							D_OP    <= ALU_MOVE_Y;
							D_SX    <= SX_ANY;
							D_SY    <= SY_UM;
							D_SA    <= ADR_dLL;
						when others =>	-- decrement LL
							D_OP    <= ALU_X_ADD_Y;
							D_SX    <= SX_LL;
							D_SY    <= SY_SY1;
					end case;

				-- 77777777777777777777777777777777777777777777777777777777777777777777
				when "1110000" =>
					OP_CAT  <= MUL_IS;
					D_OP    <= ALU_MUL_IS;
					D_SX    <= SX_LL;
					D_SY    <= SY_RR;
					D_WE_RR <= IS_M1;

				when "1110001" =>
					OP_CAT  <= MUL_IU;
					D_OP    <= ALU_MUL_IU;
					D_SX    <= SX_LL;
					D_SY    <= SY_RR;
					D_WE_RR <= IS_M1;

				when "1110010" =>
					OP_CAT  <= DIV_IS;
					D_OP    <= ALU_DIV_IS;
					D_SX    <= SX_LL;
					D_SY    <= SY_RR;
					D_WE_RR <= IS_M1;

				when "1110011" =>
					OP_CAT  <= DIV_IU;
					D_OP    <= ALU_DIV_IU;
					D_SX    <= SX_LL;
					D_SY    <= SY_RR;
					D_WE_RR <= IS_M1;

				when "1110100" =>
					OP_CAT  <= MD_STEP;
					D_OP    <= ALU_MD_STP;
					D_SX    <= SX_LL;
					D_SY    <= SY_RR;
					D_WE_RR <= IS_M1;

				when "1110101" =>
					OP_CAT  <= MD_FIN;
					D_OP    <= ALU_MD_FIN;
					D_SX    <= SX_LL;
					D_SY    <= SY_RR;
					D_WE_RR <= IS_M1;

				when "1110110" =>
					OP_CAT  <= MOD_FIN;
					D_OP    <= ALU_MOD_FIN;
					D_SX    <= SX_LL;
					D_SY    <= SY_RR;
					D_WE_RR <= IS_M1;

				when "1110111" =>
					OP_CAT      <= EI;
					ENABLE_INT  <= IS_M1;

				when "1111001" =>
					OP_CAT      <= DI;
					DISABLE_INT <= IS_M1;

				-- undefined --------------------------------------------------------
				when others =>
			end case;
		end if;
	end process;

end Behavioral;
