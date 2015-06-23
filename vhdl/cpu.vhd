library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

use work.cpu_pack.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity cpu is
	PORT(	CLK_I			: in  STD_LOGIC;
			SWITCH			: in  STD_LOGIC_VECTOR (9 downto 0);

			SER_IN			: in  STD_LOGIC;
			SER_OUT			: out STD_LOGIC;

			TEMP_SPO		: in  STD_LOGIC;
			TEMP_SPI		: out STD_LOGIC;

			TEMP_CE			: out STD_LOGIC;
			TEMP_SCLK		: out STD_LOGIC;
			SEG1			: out STD_LOGIC_VECTOR (7 downto 0);
			SEG2			: out STD_LOGIC_VECTOR (7 downto 0);
			LED				: out STD_LOGIC_VECTOR( 7 downto 0);

			XM_ADR			: out STD_LOGIC_VECTOR(15 downto 0);
			XM_RDAT			: in  STD_LOGIC_VECTOR( 7 downto 0);
			XM_WDAT			: out STD_LOGIC_VECTOR( 7 downto 0);
			XM_WE			: out STD_LOGIC;
			XM_CE			: out STD_LOGIC
	    );
end cpu;

architecture behavioral of cpu is

	COMPONENT bin_to_7segment
	PORT(	CLK_I : IN std_logic;
			PC    : IN std_logic_vector(15 downto 0);
			SEG1  : OUT std_logic_vector(7 downto 1);
			SEG2  : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;

	COMPONENT cpu_engine
	PORT(	CLK_I    : in  std_logic;
			DAT_I    : in  std_logic_vector( 7 downto 0);
			DAT_O    : out std_logic_vector( 7 downto 0);
			RST_I    : in  std_logic;
			ACK_I    : in  std_logic;
			ADR_O    : out std_logic_vector(15 downto 0);
			CYC_O    : out std_logic;
			STB_O    : out std_logic;
			TGA_O    : out std_logic_vector(0 downto 0);
			WE_O     : out std_logic;

			INT      : in  std_logic;
			HALT     : out std_logic;

			-- debug signals
			--
			Q_PC   : out std_logic_vector(15 downto 0);
			Q_OPC  : out std_logic_vector( 7 downto 0);
			Q_CAT  : out op_category;
			Q_IMM  : out std_logic_vector(15 downto 0);
			Q_CYC  : out cycle;

			-- select signals
			Q_SX    : out std_logic_vector(1 downto 0);
			Q_SY    : out std_logic_vector(3 downto 0);
			Q_OP    : out std_logic_vector(4 downto 0);
			Q_SA    : out std_logic_vector(4 downto 0);
			Q_SMQ   : out std_logic;

			-- write enable/select signal
			Q_WE_RR  : out std_logic;
			Q_WE_LL  : out std_logic;
			Q_WE_SP  : out SP_OP;

			Q_RR     : out std_logic_vector(15 downto 0);
			Q_LL     : out std_logic_vector(15 downto 0);
			Q_SP     : out std_logic_vector(15 downto 0)
		);
	END COMPONENT;

	COMPONENT input_output
	PORT(	CLK_I        : IN std_logic;
			CYC_I        : IN  std_logic;
			RST_O        : OUT std_logic;
			STB_I        : IN  std_logic;
			ACK_O        : OUT std_logic;
			IO           : IN  std_logic;
			WE_I         : IN  std_logic;
			ADR_I        : IN  std_logic_vector(7 downto 0);

			TEMP_SPO     : IN  std_logic;
			TEMP_SPI     : OUT std_logic;
			TEMP_CE      : OUT std_logic;
			TEMP_SCLK    : OUT std_logic;

			SER_IN       : IN  std_logic;
			SER_OUT      : OUT std_logic;

			SWITCH       : IN  std_logic_vector(9 downto 0);
			LED          : OUT std_logic_vector(7 downto 0);

			IO_WDAT      : IN  std_logic_vector(7 downto 0);
			IO_RDAT      : OUT std_logic_vector(7 downto 0);
			INT          : OUT std_logic;
			HALT         : in  std_logic
		);
	END COMPONENT;

	signal CLR      : std_logic;

	signal ADR      : std_logic_vector(15 downto 0);
	signal CYC      : std_logic;
	signal STB      : std_logic;
	signal XM_STB   : std_logic;
	signal IO_STB   : std_logic;
	signal ACK      : std_logic;
	signal XM_ACK   : std_logic;
	signal IO_ACK   : std_logic;

	signal HALT     : std_logic;
	signal INT      : std_logic;
	signal IO       : std_logic;
	signal WE       : std_logic;
	signal IO_RDAT  : std_logic_vector( 7 downto 0);
	signal WDAT     : std_logic_vector( 7 downto 0);
	signal RDAT     : std_logic_vector( 7 downto 0);

	signal PC       : std_logic_vector(15 downto 0);
	signal Q_C_SX    : std_logic_vector(1 downto 0);
	signal Q_C_SY    : std_logic_vector(3 downto 0);
	signal Q_C_OP    : std_logic_vector(4 downto 0);
	signal Q_C_SA    : std_logic_vector(4 downto 0);
	signal Q_C_SMQ   : std_logic;

	signal Q_C_WE_RR : std_logic;
	signal Q_C_WE_LL : std_logic;
	signal Q_C_WE_SP : SP_OP;

	signal Q_C_RR    : std_logic_vector(15 downto 0);
	signal Q_C_LL    : std_logic_vector(15 downto 0);
	signal Q_C_SP    : std_logic_vector(15 downto 0);

	signal Q_C_OPC   : std_logic_vector( 7 downto 0);
	signal Q_C_CAT   : op_category;
	signal Q_C_IMM   : std_logic_vector(15 downto 0);
	signal Q_C_CYC   : cycle;

begin

	SEG1(0) <= HALT;
	XM_ADR  <= ADR;
	XM_WDAT <= WDAT;
	XM_WE   <= WE;
	XM_STB  <= STB and not IO;
	IO_STB  <= STB and IO;
	XM_ACK  <= XM_STB;
	XM_CE   <= CYC and not IO;
	RDAT    <= IO_RDAT when (IO = '1') else XM_RDAT;
	ACK     <= IO_ACK  when (IO = '1') else XM_ACK;

	seg7: bin_to_7segment
	PORT MAP(	CLK_I => CLK_I,
				PC    => PC,
				SEG1  => SEG1(7 downto 1),		-- SEG1(0) is HALT
				SEG2  => SEG2
			);

	eng: cpu_engine
	PORT MAP(	CLK_I     => CLK_I,
				DAT_I     => RDAT,
				DAT_O     => WDAT,
				RST_I     => CLR,	-- SW-1 (RESET)
				ACK_I     => ACK,
				CYC_O     => CYC,
				STB_O     => STB,
				ADR_O     => ADR,
				TGA_O(0)  => IO,
				WE_O      => WE,

				INT       => INT,
				HALT      => HALT,

				Q_PC      => PC,
				Q_OPC     => Q_C_OPC,
				Q_CAT     => Q_C_CAT,
				Q_IMM     => Q_C_IMM,
				Q_CYC     => Q_C_CYC,

				Q_SX      => Q_C_SX,
				Q_SY      => Q_C_SY,
				Q_OP      => Q_C_OP,
				Q_SA      => Q_C_SA,
				Q_SMQ     => Q_C_SMQ,

				Q_WE_RR   => Q_C_WE_RR,
				Q_WE_LL   => Q_C_WE_LL,
				Q_WE_SP   => Q_C_WE_SP,

				Q_RR      => Q_C_RR,
				Q_LL      => Q_C_LL,
				Q_SP      => Q_C_SP
			);

	ino: input_output
	PORT MAP(	CLK_I        => CLK_I,
				CYC_I        => CYC,
				RST_O        => CLR,
				STB_I        => IO_STB,
				ACK_O        => IO_ACK,

				TEMP_SPO     => TEMP_SPO,
				TEMP_SPI     => TEMP_SPI,
				TEMP_CE      => TEMP_CE,
				TEMP_SCLK    => TEMP_SCLK,

				SER_IN       => SER_IN,
				SER_OUT      => SER_OUT,

				SWITCH       => SWITCH,
				LED          => LED,

				IO           => IO,
				WE_I         => WE,
				ADR_I        => ADR(7 downto 0),
				IO_RDAT      => IO_RDAT,
				IO_WDAT      => WDAT,
				INT          => INT,
				HALT         => HALT
			);

end behavioral;
