library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

use work.cpu_pack.ALL;

entity cpu_engine is
	PORT(	-- WISHBONE interface
			CLK_I   : in  std_logic;
			DAT_I   : in  std_logic_vector( 7 downto 0);
			DAT_O   : out std_logic_vector( 7 downto 0);
			RST_I   : in  std_logic;
			ACK_I   : in  std_logic;
			ADR_O   : out std_logic_vector(15 downto 0);
			CYC_O   : out std_logic;
			STB_O   : out std_logic;
			TGA_O   : out std_logic_vector( 0 downto 0);		-- '1' if I/O
			WE_O    : out std_logic;

			INT     : in  std_logic;
			HALT    : out std_logic;

			-- debug signals
			--
			Q_PC    : out std_logic_vector(15 downto 0);
			Q_OPC   : out std_logic_vector( 7 downto 0);
			Q_CAT   : out op_category;
			Q_IMM   : out std_logic_vector(15 downto 0);
			Q_CYC   : out cycle;

			-- select signals
			Q_SX    : out std_logic_vector(1 downto 0);
			Q_SY    : out std_logic_vector(3 downto 0);
			Q_OP    : out std_logic_vector(4 downto 0);
			Q_SA    : out std_logic_vector(4 downto 0);
			Q_SMQ   : out std_logic;

			-- write enable/select signal
			Q_WE_RR : out std_logic;
			Q_WE_LL : out std_logic;
			Q_WE_SP : out SP_OP;

			Q_RR    : out std_logic_vector(15 downto 0);
			Q_LL    : out std_logic_vector(15 downto 0);
			Q_SP    : out std_logic_vector(15 downto 0)
		);
end cpu_engine;

architecture Behavioral of cpu_engine is

	-- Unfortunately, the on-chip memory needs a clock to read data.
	-- Therefore we cannot make it wishbone compliant without a speed penalty.
	-- We avoid this problem by making the on-chip memory part of the CPU.
	-- However, as a consequence, you cannot DMA to the on-chip memory.
	--
	-- The on-chip memory is 8K, so that you can run a test SoC without external
	-- memory. For bigger applications, you should use external ROM and RAM and
	-- remove the internal memory entirely (setting EXTERN accordingly).
	--
	COMPONENT memory
	PORT(	CLK_I : IN  std_logic;
			T2    : IN  std_logic;
			CE    : IN  std_logic;
			PC    : IN  std_logic_vector(15 downto 0);
			ADR   : IN  std_logic_vector(15 downto 0);
			WR    : IN  std_logic;
			WDAT  : IN  std_logic_vector(7 downto 0);

			OPC   : OUT std_logic_vector(7 downto 0);
			RDAT  : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;

	COMPONENT opcode_fetch
	PORT(	CLK_I  : IN  std_logic;
			T2     : IN  std_logic;
			CLR    : IN  std_logic;
			CE     : IN  std_logic;
			PC_OP  : IN  std_logic_vector(2 downto 0);
			JDATA  : IN  std_logic_vector(15 downto 0);
			RR     : IN  std_logic_vector(15 downto 0);
			RDATA  : IN  std_logic_vector(7 downto 0);
			PC     : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;

	COMPONENT opcode_decoder
	PORT(	CLK_I  : IN  std_logic;
			T2     : IN  std_logic;
			CLR    : IN  std_logic;
			CE     : IN  std_logic;
			OPCODE : in std_logic_vector(7 downto 0);
			OP_CYC : in cycle;
			INT    : in std_logic;
			RRZ    : in std_logic;

			OP_CAT : out op_category;

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

			LAST_M : out std_logic;
			HLT    : out std_logic
		);
	END COMPONENT;

	COMPONENT data_core
	PORT(	CLK_I : in  std_logic;
			T2    : in  std_logic;
			CLR   : in  std_logic;
			CE    : in  std_logic;

			-- select signals
			SX    : in  std_logic_vector( 1 downto 0);
			SY    : in  std_logic_vector( 3 downto 0);
			OP    : in  std_logic_vector( 4 downto 0);		-- alu op
			PC    : in  std_logic_vector(15 downto 0);		-- PC
			QU    : in  std_logic_vector( 3 downto 0);		-- quick operand
			SA    : in  std_logic_vector(4 downto 0);			-- select address
			SMQ   : in  std_logic;							-- select MQ (H/L)

			-- write enable/select signal
			WE_RR  : in  std_logic;
			WE_LL  : in  std_logic;
			WE_SP  : in  SP_OP;

			IMM : in  std_logic_vector(15 downto 0);		-- immediate data
			RDAT : in  std_logic_vector( 7 downto 0);		-- data from memory/IO
			ADR   : out std_logic_vector(15 downto 0);		-- memory/IO address
			MQ    : out std_logic_vector( 7 downto 0);		-- data to memory/IO

			Q_RR  : out std_logic_vector(15 downto 0);
			Q_LL  : out std_logic_vector(15 downto 0);
			Q_SP  : out std_logic_vector(15 downto 0)
		);
	END COMPONENT;

	-- global signals
	signal CE      : std_logic;
	signal T2      : std_logic;

	-- memory signals
	signal	WDAT     : std_logic_vector(7 downto 0);
	signal	RDAT     : std_logic_vector(7 downto 0);
	signal	M_PC     : std_logic_vector(15 downto 0);
	signal	M_OPC    : std_logic_vector(7 downto 0);

	-- decoder signals
	--
	signal	D_CAT    : op_category;
	signal	D_OPC    : std_logic_vector(7 downto 0);
	signal	D_CYC    : cycle;          
	signal	D_PC     : std_logic_vector(15 downto 0);	-- debug signal
	signal	D_PC_OP  : std_logic_vector( 2 downto 0);
	signal	D_LAST_M : std_logic;
	signal	D_IO     : std_logic;

	-- select signals
	signal	D_SX    : std_logic_vector(1 downto 0);
	signal	D_SY    : std_logic_vector(3 downto 0);
	signal	D_OP    : std_logic_vector(4 downto 0);
	signal	D_SA    : std_logic_vector(4 downto 0);
	signal	D_SMQ   : std_logic;

	-- write enable/select signals
	signal	D_WE_RR  : std_logic;
	signal	D_WE_LL  : std_logic;
	signal	D_WE_SP  : SP_OP;
	signal	D_RD_O   : std_logic;
	signal	D_WE_O   : std_logic;
	signal	D_LOCK   : std_logic;	-- first cycle

	signal	LM_WE    : std_logic;

	-- core signals
	--
	signal	C_IMM  : std_logic_vector(15 downto 0);
	signal	ADR    : std_logic_vector(15 downto 0);

	signal	C_CYC    : cycle;								-- debug signal
	signal	C_PC     : std_logic_vector(15 downto 0);		-- debug signal
	signal	C_OPC    : std_logic_vector( 7 downto 0);		-- debug signal
	signal	C_RR     : std_logic_vector(15 downto 0);
												 
	signal	RRZ      : std_logic;
	signal	OC_JD    : std_logic_vector(15 downto 0);

	-- select signals
	signal	C_SX     : std_logic_vector(1 downto 0);
	signal	C_SY     : std_logic_vector(3 downto 0);
	signal	C_OP     : std_logic_vector(4 downto 0);
	signal	C_SA     : std_logic_vector(4 downto 0);
	signal	C_SMQ    : std_logic;
	signal	C_WE_RR  : std_logic;
	signal	C_WE_LL  : std_logic;
	signal	C_WE_SP  : SP_OP;

	signal XM_OPC    : std_logic_vector(7 downto 0);
	signal LM_OPC    : std_logic_vector(7 downto 0);
	signal LM_RDAT   : std_logic_vector(7 downto 0);
	signal XM_RDAT   : std_logic_vector(7 downto 0);
	signal	C_IO     : std_logic;
	signal	C_RD_O   : std_logic;
	signal	C_WE_O   : std_logic;

	-- signals to remember, whether the previous read cycle
	-- addressed internal memory or external memory
	--
	signal OPCS      : std_logic;	-- '1' if opcode from external memory
	signal RDATS     : std_logic;	-- '1' if data   from external memory
	signal EXTERN    : std_logic;	-- '1' if opcode or data from external memory

begin

	memo: memory
	PORT MAP(	CLK_I => CLK_I,
				T2    => T2,
				CE    => CE,

				-- read in T1
				PC    => M_PC,
				OPC   => LM_OPC,

				-- read or written in T2
				ADR   => ADR,
				WR    => LM_WE,
				WDAT  => WDAT,
				RDAT  => LM_RDAT
			);

	ocf: opcode_fetch
	 PORT MAP(	CLK_I    => CLK_I,
				T2       => T2,
				CLR      => RST_I,
				CE       => CE,
				PC_OP    => D_PC_OP,
				JDATA    => OC_JD,
				RR       => C_RR,
				RDATA    => RDAT,
				PC       => M_PC
			);

	opdec: opcode_decoder
	PORT MAP(	CLK_I    => CLK_I,
				T2       => T2,
				CLR      => RST_I,
				CE       => CE,
				OPCODE  => D_OPC,
				OP_CYC  => D_CYC,
				INT     => INT,
				RRZ     => RRZ,

				OP_CAT  => D_CAT,

				-- select signals
				D_SX    => D_SX,
				D_SY    => D_SY,
				D_OP    => D_OP,
				D_SA    => D_SA,
				D_SMQ   => D_SMQ,

				-- write enable/select signal
				D_WE_RR => D_WE_RR,
				D_WE_LL => D_WE_LL,
				D_WE_SP => D_WE_SP,
				D_RD_O  => D_RD_O,
				D_WE_O  => D_WE_O,
				D_LOCK  => D_LOCK,

				D_IO    => D_IO,

				PC_OP   => D_PC_OP,
				LAST_M  => D_LAST_M,
				HLT     => HALT
	);

	dcore: data_core
	PORT MAP(	CLK_I  => CLK_I,
				T2     => T2,
				CLR    => RST_I,
				CE     => CE,

				-- select signals
				SX     => C_SX,
				SY     => C_SY,
				OP     => C_OP,
				PC     => C_PC,
				QU     => C_OPC(3 downto 0),
				SA     => C_SA,
				SMQ    => C_SMQ,

				-- write enable/select signal
				WE_RR  => C_WE_RR,
				WE_LL  => C_WE_LL,
				WE_SP  => C_WE_SP,

				IMM    => C_IMM,
				RDAT   => RDAT,
				ADR    => ADR,
				MQ     => WDAT,

				Q_RR   => C_RR,
				Q_LL   => Q_LL,
				Q_SP   => Q_SP
			);

	CE       <= ACK_I or not EXTERN;
	TGA_O(0) <= T2 and C_IO;
	WE_O     <= T2 and C_WE_O;
	STB_O    <= EXTERN;
	CYC_O    <= EXTERN;

	Q_RR   <= C_RR;
	RRZ    <= '1' when (C_RR = X"0000") else '0';
	OC_JD  <= M_OPC & C_IMM(7 downto 0);

	Q_PC   <= C_PC;
	Q_OPC  <= C_OPC;
	Q_CYC  <= C_CYC;
	Q_IMM  <= C_IMM;

	-- select signals
	Q_SX    <= C_SX;
	Q_SY    <= C_SY;
	Q_OP    <= C_OP;
	Q_SA    <= C_SA;
	Q_SMQ   <= C_SMQ;

	-- write enable/select signal (debug)
	Q_WE_RR <= C_WE_RR;
	Q_WE_LL <= C_WE_LL;
	Q_WE_SP <= C_WE_SP;

	DAT_O   <= WDAT;

	process(CLK_I)
	begin
		if (rising_edge(CLK_I)) then
			if (RST_I = '1') then	T2 <= '0';
			elsif (CE = '1') then	T2 <= not T2;
			end if;
		end if;
	end process;

	process(T2, M_PC, ADR, C_IO, C_RD_O, C_WE_O)
	begin
		if (T2 = '0') then									-- opcode fetch
			EXTERN <= M_PC(15) or M_PC(14) or M_PC(13);		-- 8Kx8  internal memory
-- A		EXTERN <= M_PC(15) or M_PC(14) or M_PC(13) or	-- 512x8 internal memory
-- A				  M_PC(12) or M_PC(11) or M_PC(10) or M_PC(9)
-- B		EXTERN <= '1';									-- no    internal memory
		else												-- data or I/O
			EXTERN <= (ADR(15) or ADR(14) or ADR(13) or		-- 8Kx8  internal memory
-- A		EXTERN <= (ADR(15) or ADR(14) or ADR(13) or		-- 512x8  internal memory
-- A				   ADR(12) or ADR(11) or ADR(10) or ADR(9) or
-- B		EXTERN <= ('1' or								-- no    internal memory
					  C_IO) and (C_RD_O or C_WE_O);
		end if;
	end process;

	-- remember whether access is to internal or to external (incl I/O) memory.
	-- clock read data to XM_OPCODE in T1 or to XM_RDAT in T2
	--
	process(CLK_I)
	begin
		if (rising_edge(CLK_I)) then
			if (CE = '1') then
				if (T2 = '0') then
					OPCS   <= EXTERN;
					XM_OPC <= DAT_I;
				else
					RDATS   <= EXTERN;
					XM_RDAT <= DAT_I;
				end if;
			end if;
		end if;
	end process;

	M_OPC <= LM_OPC  when (OPCS = '0')  else XM_OPC;
	ADR_O <= M_PC    when (T2 = '0')    else ADR;
	RDAT  <= LM_RDAT when (RDATS = '0') else XM_RDAT;

	process(CLK_I, RST_I)	-- nuovo (thanks to Riccardo Cerulli-Irelli)
	begin
		if (RST_I = '1') then

			C_PC    <= X"0000";
			C_OPC   <= X"01";
			C_CYC   <= M1;

			C_SX    <= "00";
			C_SY    <= "0000";
			C_OP    <= "00000";
			C_SA    <= "00000";
			C_SMQ   <= '0';
			C_WE_RR <= '0';
			C_WE_LL <= '0';
			C_WE_SP <= SP_NOP;
			C_IO    <= '0';
			C_RD_O  <= '0';
			C_WE_O  <= '0';
			LM_WE   <= '0';
		elsif ((rising_edge(CLK_I) and T2 = '1') and CE = '1' ) then
			C_CYC   <= D_CYC;
			Q_CAT   <= D_CAT;
			C_PC    <= D_PC;
			C_OPC   <= D_OPC;
			C_SX    <= D_SX;
			C_SY    <= D_SY;
			C_OP    <= D_OP;
			C_SA    <= D_SA;
			C_SMQ   <= D_SMQ;
			C_WE_RR <= D_WE_RR;
			C_WE_LL <= D_WE_LL;
			C_WE_SP <= D_WE_SP;
			C_IO    <= D_IO;
			C_RD_O  <= D_RD_O;
			C_WE_O  <= D_WE_O;
			LM_WE   <= D_WE_O and not D_IO;

		end if;
	end process;

	process(CLK_I, RST_I)	-- nuovo (thanks to Riccardo Cerulli-Irelli)
	begin
		if (RST_I = '1') then
			D_PC    <= X"0000";
			D_OPC   <= X"01";
			D_CYC   <= M1;
			C_IMM   <= X"FFFF";

		elsif ((rising_edge(CLK_I) and T2 = '1') and CE = '1' ) then
			if (D_LAST_M = '1') then	-- D goes to M1
				-- signals valid for entire opcode...     PORTATO FUORI
				D_OPC <= M_OPC;
				D_PC  <= M_PC;
				D_CYC <= M1;
			else
				case D_CYC is
					when M1 =>	D_CYC <= M2;	-- C goes to M1
								C_IMM <= X"00" & M_OPC;
					when M2 =>	D_CYC <= M3;
								C_IMM(15 downto 8) <= M_OPC;
					when M3 =>	D_CYC <= M4;
					when M4 =>	D_CYC <= M5;
					when M5 =>	D_CYC <= M1;
				end case;
			end if;
		end if;
	end process;

end Behavioral;
