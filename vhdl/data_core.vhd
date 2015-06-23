library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

use work.cpu_pack.ALL;

entity data_core is
	PORT(	CLK_I : in  std_logic;
			T2    : in  std_logic;
			CLR   : in  std_logic;
			CE    : in  std_logic;

			-- select signals
			SX    : in  std_logic_vector( 1 downto 0);
			SY    : in  std_logic_vector( 3 downto 0);
			OP    : in  std_logic_vector( 4 downto 0);		-- alu op
			PC    : in  std_logic_vector(15 downto 0);		-- PC
			QU    : in  std_logic_vector( 3 downto 0);			-- quick operand
			SA    : in  std_logic_vector(4 downto 0);			-- select address
			SMQ   : in  std_logic;							-- select MQ (H/L)

			-- write enable/select signal
			WE_RR : in  std_logic;
			WE_LL : in  std_logic;
			WE_SP : in  SP_OP;

			-- data in signals
			IMM  : in  std_logic_vector(15 downto 0);		-- immediate data
			RDAT : in  std_logic_vector( 7 downto 0);		-- memory/IO data

			-- memory control signals
			ADR     : out std_logic_vector(15 downto 0);
			MQ     : out std_logic_vector( 7 downto 0);

			Q_RR   : out std_logic_vector(15 downto 0);
			Q_LL   : out std_logic_vector(15 downto 0);
			Q_SP   : out std_logic_vector(15 downto 0)
		);
end data_core;

architecture Behavioral of data_core is

	function b8(A : std_logic) return std_logic_vector is
	begin
		return A & A & A & A & A & A & A & A;
	end;

	COMPONENT alu8
	PORT(	CLK_I : in  std_logic;
			T2    : in  std_logic;
			CE    : in  std_logic;
			CLR   : in  std_logic;

			ALU_OP : IN  std_logic_vector( 4 downto 0);
			XX     : IN  std_logic_vector(15 downto 0);
			YY     : IN  std_logic_vector(15 downto 0);
			ZZ     : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;

	COMPONENT select_yy
	PORT(	SY      : IN  std_logic_vector( 3 downto 0);
			IMM     : IN  std_logic_vector(15 downto 0);
			QUICK   : IN  std_logic_vector( 3 downto 0);
			RDAT    : IN  std_logic_vector( 7 downto 0);
			RR      : IN  std_logic_vector(15 downto 0);          
			YY      : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;

	-- cpu registers
	--
	signal RR     : std_logic_vector(15 downto 0);
	signal LL     : std_logic_vector(15 downto 0);
	signal SP     : std_logic_vector(15 downto 0);

	-- internal buses
	--
	signal XX      : std_logic_vector(15 downto 0);
	signal YY      : std_logic_vector(15 downto 0);
	signal ZZ      : std_logic_vector(15 downto 0);
	signal ADR_X   : std_logic_vector(15 downto 0);
	signal ADR_Z   : std_logic_vector(15 downto 0);
	signal ADR_YZ  : std_logic_vector(15 downto 0);
	signal ADR_XYZ : std_logic_vector(15 downto 0);

begin

	alu_8: alu8
	PORT MAP(	CLK_I  => CLK_I,
				T2     => T2,
				CE     => CE,
				CLR    => CLR,
				ALU_OP => OP,
				XX     => XX,
				YY     => YY,
				ZZ     => ZZ
	);

	selyy: select_yy
	PORT MAP(	SY      => SY,
				IMM     => IMM,
				QUICK   => QU,
				RDAT    => RDAT,
				RR      => RR,
				YY      => YY
	);

	ADR		<= ADR_XYZ;
	MQ      <= ZZ(15 downto 8) when SMQ = '1' else ZZ(7 downto 0);

	Q_RR <= RR;
	Q_LL <= LL;
	Q_SP <= SP;

	-- memory address
	--
	sel_ax: process(SA(4 downto 3), IMM)

		variable SAX : std_logic_vector(4 downto 3);

	begin
		SAX := SA(4 downto 3);

		case SAX is

			when SA_43_I16 =>	ADR_X <= IMM;
			when SA_43_I8S =>	ADR_X <= b8(IMM(7)) & IMM(7 downto 0);
			when others	   =>	ADR_X <= b8(SA(3)) & b8(SA(3));
		end case;
	end process;

	sel_az: process(SA(2 downto 1), LL, RR, SP)

		variable SAZ : std_logic_vector(2 downto 1);

	begin
		SAZ := SA(2 downto 1);

		case SAZ is
			when SA_21_0  =>	ADR_Z <= X"0000";
			when SA_21_LL =>	ADR_Z <= LL;
			when SA_21_RR =>	ADR_Z <= RR;
			when others	  =>	ADR_Z <= SP;
		end case;
	end process;

	sel_ayz: process(SA(0), ADR_Z)
	begin
		ADR_YZ <= ADR_Z + (X"000" & "000" & SA(0));
	end process;

	sel_axyz: process(ADR_X, ADR_YZ)
	begin
		ADR_XYZ <= ADR_X + ADR_YZ;
	end process;

	sel_xx: process(SX, LL, RR, SP, PC)
	begin
		case SX is
			when SX_LL	=>	XX <= LL;
			when SX_RR	=>	XX <= RR;
			when SX_SP	=>	XX <= SP;
			when others	=>	XX <= PC;
		end case;
	end process;

	regs: process(CLK_I)
	begin
		if (rising_edge(CLK_I)) then
			if    (CLR = '1') then
				RR  <= X"0000";
				LL  <= X"0000";
				SP  <= X"0000";
			elsif (CE  = '1' and T2 = '1') then
				if (WE_RR = '1') then		RR  <= ZZ;		end if;
				if (WE_LL = '1') then		LL  <= ZZ;		end if;

				case WE_SP is
					when SP_INC  	=>		SP <= ADR_YZ;
					when SP_LOAD 	=>		SP <= ADR_XYZ;
					when SP_NOP		=>		null;
				end case;
			end if;
		end if;
	end process;

end Behavioral;
