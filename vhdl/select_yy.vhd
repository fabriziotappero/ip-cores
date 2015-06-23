library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

use work.cpu_pack.ALL;

entity select_yy is
    Port(	SY    : in  std_logic_vector( 3 downto 0);
			IMM   : in  std_logic_vector(15 downto 0);
			QUICK : in  std_logic_vector( 3 downto 0);
			RDAT  : in  std_logic_vector( 7 downto 0);
			RR    : in  std_logic_vector(15 downto 0);
			YY    : out std_logic_vector(15 downto 0)
		);
end select_yy;

architecture Behavioral of select_yy is

	function b4(A : std_logic) return std_logic_vector is
	begin
		return A & A & A & A;
	end;

	function b8(A : std_logic) return std_logic_vector is
	begin
		return b4(A) & b4(A);
	end;

begin

	-- bits 1..0
	--
	s_1_0: process(SY, IMM(1 downto 0), QUICK(1 downto 0), RDAT(1 downto 0),
	               RR(1 downto 0))
	begin
		case SY is
			when SY_I16 | SY_SI8
			   | SY_UI8			=> YY(1 downto 0) <= IMM  (1 downto 0);
			when SY_RR			=> YY(1 downto 0) <= RR   (1 downto 0);
			when SY_SQ | SY_UQ	=> YY(1 downto 0) <= QUICK(1 downto 0);
			when SY_SM | SY_UM	=> YY(1 downto 0) <= RDAT (1 downto 0);
			when others			=> YY(1 downto 0) <= SY   (1 downto 0);
		end case;
	end process;

	-- bits 3..2
	--
	s_3_2: process(SY, IMM(3 downto 2), QUICK(3 downto 2), RDAT(3 downto 2),
	               RR(3 downto 2))
	begin
		case SY is
			when SY_I16 | SY_SI8
			   | SY_UI8			=> YY(3 downto 2) <= IMM  (3 downto 2);
			when SY_RR			=> YY(3 downto 2) <= RR   (3 downto 2);
			when SY_SQ | SY_UQ	=> YY(3 downto 2) <= QUICK(3 downto 2);
			when SY_SM | SY_UM	=> YY(3 downto 2) <= RDAT (3 downto 2);
			when others			=> YY(3 downto 2) <= "00";
		end case;
	end process;

	-- bits 7..4
	--
	s_7_4: process(SY, IMM(7 downto 4), QUICK(3), RDAT(7 downto 4),
	               RR(7 downto 4))
	begin
		case SY is
			when SY_I16 | SY_SI8
			   | SY_UI8			=> YY(7 downto 4) <= IMM  (7 downto 4);
			when SY_RR			=> YY(7 downto 4) <= RR   (7 downto 4);
			when SY_SQ			=> YY(7 downto 4) <= b4(QUICK(3));
			when SY_SM | SY_UM	=> YY(7 downto 4) <= RDAT (7 downto 4);
			when others			=> YY(7 downto 4) <= "0000";
		end case;
	end process;

	-- bits 15..8
	--
	s_15_8: process(SY, IMM(15 downto 7), QUICK(3), RDAT(7), RR(15 downto 8))
	begin
		case SY is
			when SY_I16			=> YY(15 downto 8) <= IMM  (15 downto 8);
			when SY_SI8			=> YY(15 downto 8) <= b8(IMM(7));
			when SY_RR			=> YY(15 downto 8) <= RR(15 downto 8);
			when SY_SQ			=> YY(15 downto 8) <= b8(QUICK(3));
			when SY_SM			=> YY(15 downto 8) <= b8(RDAT(7));
			when others			=> YY(15 downto 8) <= "00000000";
		end case;
	end process;

end Behavioral;
