--
-- This is the top level VHDL file.
--
-- It iobufs for bidirational signals (towards an optional
-- external fast SRAM.
--
-- Pins fit the AVNET Virtex-E Evaluation board
--
-- For other boards, change pin assignments in this file.
--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

use work.cpu_pack.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity board_cpu is
	PORT (	CLK40			: in  STD_LOGIC;
			SWITCH			: in  STD_LOGIC_VECTOR (9 downto 0);

			SER_IN			: in  STD_LOGIC;
			SER_OUT			: out STD_LOGIC;

			TEMP_SPO		: in  STD_LOGIC;
			TEMP_SPI		: out STD_LOGIC;

	    	CLK_OUT			: out STD_LOGIC;
	    	LED				: out STD_LOGIC_VECTOR (7 downto 0);
			ENABLE_N		: out STD_LOGIC;
			DEACTIVATE_N	: out STD_LOGIC;
			TEMP_CE			: out STD_LOGIC;
			TEMP_SCLK		: out STD_LOGIC;
			SEG1			: out STD_LOGIC_VECTOR (7 downto 0);
			SEG2			: out STD_LOGIC_VECTOR (7 downto 0);

			XM_ADR			: out   STD_LOGIC_VECTOR(14 downto 0);
			XM_CE_N			: out STD_LOGIC;
			XM_OE_N			: out STD_LOGIC;
			XM_WE_N			: inout STD_LOGIC;
			XM_DIO			: inout STD_LOGIC_VECTOR(7 downto 0)
	    );
end board_cpu;

architecture behavioral of board_cpu is

	COMPONENT cpu
	PORT(	CLK_I			: in  STD_LOGIC;
			SWITCH			: in  STD_LOGIC_VECTOR (9 downto 0);

			SER_IN			: in  STD_LOGIC;
			SER_OUT			: out STD_LOGIC;

			TEMP_SPO		: in  STD_LOGIC;
			TEMP_SPI		: out STD_LOGIC;
			TEMP_CE			: out STD_LOGIC;
			TEMP_SCLK		: out STD_LOGIC;

			SEG1			: out STD_LOGIC_VECTOR (7 downto 0);
			SEG2			: out STD_LOGIC_VECTOR( 7 downto 0);
			LED				: out STD_LOGIC_VECTOR( 7 downto 0);

			XM_ADR			: out STD_LOGIC_VECTOR(15 downto 0);
			XM_RDAT			: in  STD_LOGIC_VECTOR( 7 downto 0);
			XM_WDAT			: out STD_LOGIC_VECTOR( 7 downto 0);
			XM_WE			: out STD_LOGIC;
			XM_CE			: out STD_LOGIC
		); 
	END COMPONENT; 

	signal XM_WDAT  : std_logic_vector( 7 downto 0);
	signal XM_RDAT  : std_logic_vector( 7 downto 0);
	signal MEM_T    : std_logic;
	signal XM_WE    : std_logic;
	signal WE_N     : std_logic;
	signal DEL_WE_N : std_logic;
	signal XM_CE    : std_logic;
	signal LCLK     : std_logic;


begin

	cp: cpu
	PORT MAP(	CLK_I        =>	CLK40,
				SWITCH       =>	SWITCH,

				SER_IN       => SER_IN,
				SER_OUT      =>	SER_OUT,

				TEMP_SPO     =>	 TEMP_SPO,
				TEMP_SPI     =>	 TEMP_SPI,

				XM_ADR(14 downto 0)  =>	XM_ADR,
				XM_ADR(15)  =>	open,
				XM_RDAT     =>	XM_RDAT,
				XM_WDAT     =>	XM_WDAT,
				XM_WE       =>	XM_WE,
				XM_CE       =>	XM_CE,
				TEMP_CE      =>	TEMP_CE,
				TEMP_SCLK    =>	TEMP_SCLK,
				SEG1         =>	SEG1,
				SEG2         =>	SEG2,
				LED          =>	LED
			);

	ENABLE_N     <= '0';
	DEACTIVATE_N <= '1';
	CLK_OUT      <= LCLK;

	MEM_T   <=     DEL_WE_N;		-- active low
	WE_N    <= not XM_WE;
	XM_OE_N <=     XM_WE;
	XM_CE_N <= not XM_CE;

	p147: iobuf	PORT MAP(I => XM_WDAT(7), O => XM_RDAT(7), T => MEM_T, IO => XM_DIO(7));
	p144: iobuf	PORT MAP(I => XM_WDAT(0), O => XM_RDAT(0), T => MEM_T, IO => XM_DIO(0));
	p142: iobuf	PORT MAP(I => XM_WDAT(6), O => XM_RDAT(6), T => MEM_T, IO => XM_DIO(6));
	p141: iobuf	PORT MAP(I => XM_WDAT(1), O => XM_RDAT(1), T => MEM_T, IO => XM_DIO(1));
	p140: iobuf	PORT MAP(I => XM_WDAT(5), O => XM_RDAT(5), T => MEM_T, IO => XM_DIO(5));
	p139: iobuf	PORT MAP(I => XM_WDAT(2), O => XM_RDAT(2), T => MEM_T, IO => XM_DIO(2));
	p133: iobuf	PORT MAP(I => XM_WDAT(4), O => XM_RDAT(4), T => MEM_T, IO => XM_DIO(4));
	p131: iobuf	PORT MAP(I => XM_WDAT(3), O => XM_RDAT(3), T => MEM_T, IO => XM_DIO(3));
	p63:  iobuf	PORT MAP(I => WE_N,		  O => DEL_WE_N,   T => '0',   IO => XM_WE_N);

	process(CLK40)
	begin
		if (rising_edge(CLK40)) then
			LCLK <= not LCLK;
		end if;
	end process;

end behavioral;
