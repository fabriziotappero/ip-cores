library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

use work.cpu_pack.ALL;

entity alu8 is
	PORT(	CLK_I : in   std_logic;
			T2    : in   std_logic;
			CLR   : in   std_logic;
			CE    : in   std_logic;

			ALU_OP : in  std_logic_vector( 4 downto 0);
			XX     : in  std_logic_vector(15 downto 0);
			YY     : in  std_logic_vector(15 downto 0);

			ZZ     : out std_logic_vector(15 downto 0)
		);
end alu8;

architecture Behavioral of alu8 is


	function sh_mask(Y    : unsigned(3 downto 0);
					 YMAX : unsigned(3 downto 0);
	                 LR   : std_logic;
	                 FILL : std_logic;
					 X    : std_logic) return std_logic is

	begin
		if (YMAX >= Y) then									-- Y small
			if (LR = '1') then		return	X;			-- LSL
			else					return	FILL;		-- LSR
			end if;
		else												-- Y big
			if (LR = '1') then		return	FILL;		-- LSL
			else					return	X;			-- ASR/LSR
			end if;
		end if;
	end;

	function b8(A : std_logic) return std_logic_vector is
	begin
		return A & A & A & A & A & A & A & A;
	end;

	function b16(A : std_logic) return std_logic_vector is
	begin
		return b8(A) & b8(A);
	end;

	function aoxn(A : std_logic_vector(3 downto 0)) return std_logic is
	begin
		case A is
			-- and
			when "0000" =>	return '0';
			when "0001" =>	return '0';
			when "0010" =>	return '0';
			when "0011" =>	return '1';
			-- or
			when "0100" =>	return '0';
			when "0101" =>	return '1';
			when "0110" =>	return '1';
			when "0111" =>	return '1';
			-- xor
			when "1000" =>	return '0';
			when "1001" =>	return '1';
			when "1010" =>	return '1';
			when "1011" =>	return '0';
			-- not Y
			when "1100" =>	return '1';
			when "1101" =>	return '0';
			when "1110" =>	return '1';
			when others =>	return '0';
		end case;
	end;

	signal MD_OR     : std_logic_vector(15 downto 0);		-- Multiplicator/Divisor
	signal PROD_REM  : std_logic_vector(31 downto 0);
	signal MD_OP     : std_logic;						-- operation D/M, S/U
	signal QP_NEG    : std_logic;						-- product / quotient negative
	signal RM_NEG    : std_logic;						-- remainder negative

begin

	alumux: process(ALU_OP, MD_OP, XX, YY, QP_NEG, RM_NEG, PROD_REM)

		variable MASKED_X : std_logic_vector(15 downto 0);
		variable SCNT     : unsigned(3 downto 0);
		variable SFILL    : std_logic;
		variable ROL1     : std_logic_vector(15 downto 0);
		variable ROL2     : std_logic_vector(15 downto 0);
		variable ROL4     : std_logic_vector(15 downto 0);
		variable ROL8     : std_logic_vector(15 downto 0);
		variable X_GE_Y	  : std_logic;	-- signed   X >=  Y
		variable X_HS_Y	  : std_logic;	-- unsigned X >=  Y
		variable X_HSGE_Y : std_logic;	-- any      X >=  Y
		variable X_EQ_Y	  : std_logic;	-- signed   X ==  Y
		variable X_CMP_Y  : std_logic;

	begin
		MASKED_X := XX and b16(ALU_OP(0));
		SFILL    := ALU_OP(0) and XX(15);

		if (ALU_OP(1) = '1') then	-- LSL
			SCNT := UNSIGNED(YY(3 downto 0));
		else						-- LSR / ASR
			SCNT := "0000" - UNSIGNED(YY(3 downto 0));
		end if;

		if (SCNT(0) = '0') then	ROL1 := XX;
		else					ROL1 := XX(14 downto 0) & XX(15);
		end if;

		if (SCNT(1) = '0') then	ROL2 := ROL1;
		else					ROL2 := ROL1(13 downto 0) & ROL1(15 downto 14);
		end if;

		if (SCNT(2) = '0') then	ROL4 := ROL2;
		else					ROL4 := ROL2(11 downto 0) & ROL2(15 downto 12);
		end if;

		if (SCNT(3) = '0') then	ROL8 := ROL4;
		else					ROL8 := ROL4(7 downto 0) & ROL4(15 downto 8);
		end if;

		if (XX = YY) then		X_EQ_Y := '1';
		else					X_EQ_Y := '0';
		end if;

		if (UNSIGNED(XX) >= UNSIGNED(YY)) then		X_HSGE_Y := '1';
		else										X_HSGE_Y := '0';
		end if;

		if (XX(15) /= YY(15)) then		-- different sign/high bit
			X_HS_Y := XX(15);		-- X ia bigger iff high bit set
			X_GE_Y := YY(15);		-- X is bigger iff Y negative
		else							-- same sign/high bit: GE == HS
			X_HS_Y := X_HSGE_Y;
			X_GE_Y := X_HSGE_Y;
		end if;

		case ALU_OP is
			when	ALU_X_HS_Y	=>	X_CMP_Y :=      X_HS_Y;
			when	ALU_X_LO_Y	=>	X_CMP_Y := not  X_HS_Y;
			when	ALU_X_HI_Y	=>	X_CMP_Y :=      X_HS_Y and not X_EQ_Y;
			when	ALU_X_LS_Y	=>	X_CMP_Y := not (X_HS_Y and not X_EQ_Y);
			when	ALU_X_GE_Y	=>	X_CMP_Y :=      X_GE_Y;
			when	ALU_X_LT_Y	=>	X_CMP_Y := not  X_GE_Y;
			when	ALU_X_GT_Y	=>	X_CMP_Y :=      X_GE_Y and not X_EQ_Y;
			when	ALU_X_LE_Y	=>	X_CMP_Y := not (X_GE_Y and not X_EQ_Y);
			when	ALU_X_EQ_Y	=>	X_CMP_Y :=      X_EQ_Y;
			when	others		=>	X_CMP_Y := not  X_EQ_Y;
		end case;

		ZZ <= X"0000";

		case ALU_OP is
			when	ALU_X_HS_Y | ALU_X_LO_Y | ALU_X_HI_Y | ALU_X_LS_Y |
					ALU_X_GE_Y | ALU_X_LT_Y | ALU_X_GT_Y | ALU_X_LE_Y |
					ALU_X_EQ_Y | ALU_X_NE_Y =>
				ZZ  <= b16(X_CMP_Y);

			when 	ALU_NEG_Y |	ALU_X_SUB_Y =>
				ZZ  <= MASKED_X - YY;

			when	ALU_MOVE_Y | ALU_X_ADD_Y =>
				ZZ  <= MASKED_X + YY;

			when 	ALU_X_AND_Y | ALU_X_OR_Y  | ALU_X_XOR_Y | ALU_NOT_Y =>
				for i in 0 to 15 loop
					ZZ(i) <= aoxn(ALU_OP(1 downto 0) & XX(i) & YY(i));
				end loop;

			when	ALU_X_LSR_Y | ALU_X_ASR_Y | ALU_X_LSL_Y =>
				for i in 0 to 15 loop
					ZZ(i) <= sh_mask(SCNT, CONV_UNSIGNED(i, 4),
									 ALU_OP(1), SFILL, ROL8(i));
				end loop;

			when	ALU_X_MIX_Y =>
					ZZ(15 downto 8) <= YY(7 downto 0);
					ZZ( 7 downto 0) <= XX(7 downto 0);

			when	ALU_MUL_IU | ALU_MUL_IS |
					ALU_DIV_IU | ALU_DIV_IS | ALU_MD_STP =>	-- mult/div ini/step
					ZZ <= PROD_REM(15 downto 0);

			when	ALU_MD_FIN =>	-- mult/div
				if (QP_NEG = '0') then	ZZ <= PROD_REM(15 downto 0);
				else					ZZ <= X"0000" - PROD_REM(15 downto 0);
				end if;

			when	others =>	-- modulo
				if (RM_NEG = '0') then	ZZ <= PROD_REM(31 downto 16);
				else					ZZ <= X"0000" - PROD_REM(31 downto 16);
				end if;
		end case;
	end process;

	muldiv: process(CLK_I)

		variable POS_YY : std_logic_vector(15 downto 0);
		variable POS_XX : std_logic_vector(15 downto 0);
		variable DIFF   : std_logic_vector(16 downto 0);
		variable SUM    : std_logic_vector(16 downto 0);

	begin
		if (rising_edge(CLK_I)) then
			if (T2 = '1') then
				if (CLR = '1') then
					PROD_REM <= X"00000000";	-- product/remainder
					MD_OR    <= X"0000";		-- multiplicator/divisor
					MD_OP    <= '0';			-- mult(0)/div(1)
					QP_NEG   <= '0';			-- quotient/product negative
					RM_NEG   <= '0';			-- remainder negative
				elsif (CE = '1') then
					SUM  := ('0' & PROD_REM(31 downto 16)) + ('0' & MD_OR);
					DIFF := ('0' & PROD_REM(30 downto 15)) - ('0' & MD_OR);

					if (XX(15) = '0') then	POS_XX := XX;
					else					POS_XX := X"0000" - XX;
					end if;

					if (YY(15) = '0') then	POS_YY := YY;
					else					POS_YY := X"0000" - YY;
					end if;

					case  ALU_OP is
						when	ALU_MUL_IU | ALU_MUL_IS | ALU_DIV_IU | ALU_DIV_IS =>
							MD_OP    <= ALU_OP(1);		-- div / mult
							MD_OR    <= POS_YY;		-- multiplicator/divisor
							QP_NEG   <= ALU_OP(0) and (XX(15) xor YY(15));
							RM_NEG   <= ALU_OP(0) and  XX(15);
							PROD_REM <= X"0000" & POS_XX;

						when	ALU_MD_STP =>
							if (MD_OP = '0') then		-- multiplication step

								PROD_REM(15 downto 0) <= PROD_REM(16 downto 1);
								if (PROD_REM(0) = '0') then
										PROD_REM(31 downto 15) <=
										'0' & PROD_REM(31 downto 16);
								else
									PROD_REM(31 downto 15) <= SUM;
								end if;
							else						-- division step
								if (DIFF(16) = '1') then	-- carry: small remainder
									PROD_REM(31 downto 16) <= PROD_REM(30 downto 15);
								else
									PROD_REM(31 downto 16) <= DIFF(15 downto 0);
								end if;

								PROD_REM(15 downto 1) <= PROD_REM(14 downto 0);
								PROD_REM(0) <= not DIFF(16);
							end if;

						when	others =>
					end case;
				end if;
			end if;
		end if;
	end process;

end Behavioral;
