library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
library UNISIM;
use UNISIM.VComponents.all;

use work.cpu_pack.ALL;
use work.mem_content.All;

entity memory is
	Port (	CLK_I	: in  std_logic;
			T2		: in  std_logic;
			CE		: in  std_logic;
			PC		: in  std_logic_vector(15 downto 0);
			ADR		: in  std_logic_vector(15 downto 0);
			WR		: in  std_logic;
			WDAT	: in  std_logic_vector( 7 downto 0);

			OPC		: out std_logic_vector( 7 downto 0);
			RDAT	: out std_logic_vector( 7 downto 0)
		);
end memory;

architecture Behavioral of memory is

	signal ENA     : std_logic;
	signal ENB     : std_logic;

	signal WR_0    : std_logic;
	signal WR_1    : std_logic;

	signal LADR    : std_logic_vector( 3 downto 0);
	signal OUT_0   : std_logic_vector( 7 downto 0);
	signal OUT_1   : std_logic_vector( 7 downto 0);

	signal LPC     : std_logic_vector( 3 downto 0);
	signal OPC_0   : std_logic_vector( 7 downto 0);
	signal OPC_1   : std_logic_vector( 7 downto 0);

begin

	ENA   <= CE and not T2;
	ENB   <= CE and     T2;

	WR_0  <= '1' when (WR = '1' and ADR(15 downto 12) = "0000"  ) else '0';
	WR_1  <= '1' when (WR = '1' and ADR(15 downto 12) = "0001"  ) else '0';

	-- Bank 0 ------------------------------------------------------------------------
	--
	m_0_0 : RAMB4_S1_S1
	-- synopsys translate_off
	GENERIC MAP(
	INIT_00 => m_0_0_0, INIT_01 => m_0_0_1, INIT_02 => m_0_0_2, INIT_03 => m_0_0_3, 
	INIT_04 => m_0_0_4, INIT_05 => m_0_0_5, INIT_06 => m_0_0_6, INIT_07 => m_0_0_7, 
	INIT_08 => m_0_0_8, INIT_09 => m_0_0_9, INIT_0A => m_0_0_A, INIT_0B => m_0_0_B, 
	INIT_0C => m_0_0_C, INIT_0D => m_0_0_D, INIT_0E => m_0_0_E, INIT_0F => m_0_0_F)
	-- synopsys translate_on
	PORT MAP(	ADDRA => PC(11 downto 0),		ADDRB => ADR(11 downto 0),
				CLKA  => CLK_I,					CLKB  => CLK_I,
				DIA   => "0",					DIB   => WDAT(0 downto 0),
				ENA   => ENA,					ENB   => ENB,
				RSTA  => '0',					RSTB  => '0',
				WEA   => '0',					WEB   => WR_0,
				DOA   => OPC_0(0 downto 0),		DOB   => OUT_0(0 downto 0)
			);

	m_0_1 : RAMB4_S1_S1
	-- synopsys translate_off
	GENERIC MAP(
	INIT_00 => m_0_1_0, INIT_01 => m_0_1_1, INIT_02 => m_0_1_2, INIT_03 => m_0_1_3, 
	INIT_04 => m_0_1_4, INIT_05 => m_0_1_5, INIT_06 => m_0_1_6, INIT_07 => m_0_1_7, 
	INIT_08 => m_0_1_8, INIT_09 => m_0_1_9, INIT_0A => m_0_1_A, INIT_0B => m_0_1_B, 
	INIT_0C => m_0_1_C, INIT_0D => m_0_1_D, INIT_0E => m_0_1_E, INIT_0F => m_0_1_F)
	-- synopsys translate_on
	PORT MAP(	ADDRA => PC(11 downto 0),		ADDRB => ADR(11 downto 0),
				CLKA  => CLK_I,					CLKB  => CLK_I,
				DIA   => "0",					DIB   => WDAT(1 downto 1),
				ENA   => ENA,					ENB   => ENB,
				RSTA  => '0',					RSTB  => '0',
				WEA   => '0',					WEB   => WR_0,
				DOA   => OPC_0(1 downto 1),		DOB   => OUT_0(1 downto 1)
			);

	m_0_2 : RAMB4_S1_S1
	-- synopsys translate_off
	GENERIC MAP(
	INIT_00 => m_0_2_0, INIT_01 => m_0_2_1, INIT_02 => m_0_2_2, INIT_03 => m_0_2_3, 
	INIT_04 => m_0_2_4, INIT_05 => m_0_2_5, INIT_06 => m_0_2_6, INIT_07 => m_0_2_7, 
	INIT_08 => m_0_2_8, INIT_09 => m_0_2_9, INIT_0A => m_0_2_A, INIT_0B => m_0_2_B, 
	INIT_0C => m_0_2_C, INIT_0D => m_0_2_D, INIT_0E => m_0_2_E, INIT_0F => m_0_2_F)
	-- synopsys translate_on
	PORT MAP(	ADDRA => PC(11 downto 0),		ADDRB => ADR(11 downto 0),
				CLKA  => CLK_I,					CLKB  => CLK_I,
				DIA   => "0",					DIB   => WDAT(2 downto 2),
				ENA   => ENA,					ENB   => ENB,
				RSTA  => '0',					RSTB  => '0',
				WEA   => '0',					WEB   => WR_0,
				DOA   => OPC_0(2 downto 2),		DOB   => OUT_0(2 downto 2)
			);

	m_0_3 : RAMB4_S1_S1
	-- synopsys translate_off
	GENERIC MAP(
	INIT_00 => m_0_3_0, INIT_01 => m_0_3_1, INIT_02 => m_0_3_2, INIT_03 => m_0_3_3, 
	INIT_04 => m_0_3_4, INIT_05 => m_0_3_5, INIT_06 => m_0_3_6, INIT_07 => m_0_3_7, 
	INIT_08 => m_0_3_8, INIT_09 => m_0_3_9, INIT_0A => m_0_3_A, INIT_0B => m_0_3_B, 
	INIT_0C => m_0_3_C, INIT_0D => m_0_3_D, INIT_0E => m_0_3_E, INIT_0F => m_0_3_F)
	-- synopsys translate_on
	PORT MAP(	ADDRA => PC(11 downto 0),		ADDRB => ADR(11 downto 0),
				CLKA  => CLK_I,					CLKB  => CLK_I,
				DIA   => "0",					DIB   => WDAT(3 downto 3),
				ENA   => ENA,					ENB   => ENB,
				RSTA  => '0',					RSTB  => '0',
				WEA   => '0',					WEB   => WR_0,
				DOA   => OPC_0(3 downto 3),		DOB   => OUT_0(3 downto 3)
			);

	m_0_4 : RAMB4_S1_S1
	-- synopsys translate_off
	GENERIC MAP(
	INIT_00 => m_0_4_0, INIT_01 => m_0_4_1, INIT_02 => m_0_4_2, INIT_03 => m_0_4_3, 
	INIT_04 => m_0_4_4, INIT_05 => m_0_4_5, INIT_06 => m_0_4_6, INIT_07 => m_0_4_7, 
	INIT_08 => m_0_4_8, INIT_09 => m_0_4_9, INIT_0A => m_0_4_A, INIT_0B => m_0_4_B, 
	INIT_0C => m_0_4_C, INIT_0D => m_0_4_D, INIT_0E => m_0_4_E, INIT_0F => m_0_4_F)
	-- synopsys translate_on
	PORT MAP(	ADDRA => PC(11 downto 0),		ADDRB => ADR(11 downto 0),
				CLKA  => CLK_I,					CLKB  => CLK_I,
				DIA   => "0",					DIB   => WDAT(4 downto 4),
				ENA   => ENA,					ENB   => ENB,
				RSTA  => '0',					RSTB  => '0',
				WEA   => '0',					WEB   => WR_0,
				DOA   => OPC_0(4 downto 4),		DOB   => OUT_0(4 downto 4)
			);

	m_0_5 : RAMB4_S1_S1
	-- synopsys translate_off
	GENERIC MAP(
	INIT_00 => m_0_5_0, INIT_01 => m_0_5_1, INIT_02 => m_0_5_2, INIT_03 => m_0_5_3, 
	INIT_04 => m_0_5_4, INIT_05 => m_0_5_5, INIT_06 => m_0_5_6, INIT_07 => m_0_5_7, 
	INIT_08 => m_0_5_8, INIT_09 => m_0_5_9, INIT_0A => m_0_5_A, INIT_0B => m_0_5_B, 
	INIT_0C => m_0_5_C, INIT_0D => m_0_5_D, INIT_0E => m_0_5_E, INIT_0F => m_0_5_F)
	-- synopsys translate_on
	PORT MAP(	ADDRA => PC(11 downto 0),		ADDRB => ADR(11 downto 0),
				CLKA  => CLK_I,					CLKB  => CLK_I,
				DIA   => "0",					DIB   => WDAT(5 downto 5),
				ENA   => ENA,					ENB   => ENB,
				RSTA  => '0',					RSTB  => '0',
				WEA   => '0',					WEB   => WR_0,
				DOA   => OPC_0(5 downto 5),		DOB   => OUT_0(5 downto 5)
			);

	m_0_6 : RAMB4_S1_S1
	-- synopsys translate_off
	GENERIC MAP(
	INIT_00 => m_0_6_0, INIT_01 => m_0_6_1, INIT_02 => m_0_6_2, INIT_03 => m_0_6_3, 
	INIT_04 => m_0_6_4, INIT_05 => m_0_6_5, INIT_06 => m_0_6_6, INIT_07 => m_0_6_7, 
	INIT_08 => m_0_6_8, INIT_09 => m_0_6_9, INIT_0A => m_0_6_A, INIT_0B => m_0_6_B, 
	INIT_0C => m_0_6_C, INIT_0D => m_0_6_D, INIT_0E => m_0_6_E, INIT_0F => m_0_6_F)
	-- synopsys translate_on
	PORT MAP(	ADDRA => PC(11 downto 0),		ADDRB => ADR(11 downto 0),
				CLKA  => CLK_I,					CLKB  => CLK_I,
				DIA   => "0",					DIB   => WDAT(6 downto 6),
				ENA   => ENA,					ENB   => ENB,
				RSTA  => '0',					RSTB  => '0',
				WEA   => '0',					WEB   => WR_0,
				DOA   => OPC_0(6 downto 6),		DOB   => OUT_0(6 downto 6)
			);

	m_0_7 : RAMB4_S1_S1
	-- synopsys translate_off
	GENERIC MAP(
	INIT_00 => m_0_7_0, INIT_01 => m_0_7_1, INIT_02 => m_0_7_2, INIT_03 => m_0_7_3, 
	INIT_04 => m_0_7_4, INIT_05 => m_0_7_5, INIT_06 => m_0_7_6, INIT_07 => m_0_7_7, 
	INIT_08 => m_0_7_8, INIT_09 => m_0_7_9, INIT_0A => m_0_7_A, INIT_0B => m_0_7_B, 
	INIT_0C => m_0_7_C, INIT_0D => m_0_7_D, INIT_0E => m_0_7_E, INIT_0F => m_0_7_F)
	-- synopsys translate_on
	PORT MAP(	ADDRA => PC(11 downto 0),		ADDRB => ADR(11 downto 0),
				CLKA  => CLK_I,					CLKB  => CLK_I,
				DIA   => "0",					DIB   => WDAT(7 downto 7),
				ENA   => ENA,					ENB   => ENB,
				RSTA  => '0',					RSTB  => '0',
				WEA   => '0',					WEB   => WR_0,
				DOA   => OPC_0(7 downto 7),		DOB   => OUT_0(7 downto 7)
			);

	-- Bank 1 ------------------------------------------------------------------------
	--
	m_1_0 : RAMB4_S1_S1
	-- synopsys translate_off
	GENERIC MAP(
	INIT_00 => m_1_0_0, INIT_01 => m_1_0_1, INIT_02 => m_1_0_2, INIT_03 => m_1_0_3, 
	INIT_04 => m_1_0_4, INIT_05 => m_1_0_5, INIT_06 => m_1_0_6, INIT_07 => m_1_0_7, 
	INIT_08 => m_1_0_8, INIT_09 => m_1_0_9, INIT_0A => m_1_0_A, INIT_0B => m_1_0_B, 
	INIT_0C => m_1_0_C, INIT_0D => m_1_0_D, INIT_0E => m_1_0_E, INIT_0F => m_1_0_F)
	-- synopsys translate_on
	PORT MAP(	ADDRA => PC(11 downto 0),		ADDRB => ADR(11 downto 0),
				CLKA  => CLK_I,					CLKB  => CLK_I,
				DIA   => "0",					DIB   => WDAT(0 downto 0),
				ENA   => ENA,					ENB   => ENB,
				RSTA  => '0',					RSTB  => '0',
				WEA   => '0',					WEB   => WR_1,
				DOA   => OPC_1(0 downto 0),		DOB   => OUT_1(0 downto 0)
			);

	m_1_1 : RAMB4_S1_S1
	-- synopsys translate_off
	GENERIC MAP(
	INIT_00 => m_1_1_0, INIT_01 => m_1_1_1, INIT_02 => m_1_1_2, INIT_03 => m_1_1_3, 
	INIT_04 => m_1_1_4, INIT_05 => m_1_1_5, INIT_06 => m_1_1_6, INIT_07 => m_1_1_7, 
	INIT_08 => m_1_1_8, INIT_09 => m_1_1_9, INIT_0A => m_1_1_A, INIT_0B => m_1_1_B, 
	INIT_0C => m_1_1_C, INIT_0D => m_1_1_D, INIT_0E => m_1_1_E, INIT_0F => m_1_1_F)
	-- synopsys translate_on
	PORT MAP(	ADDRA => PC(11 downto 0),		ADDRB => ADR(11 downto 0),
				CLKA  => CLK_I,					CLKB  => CLK_I,
				DIA   => "0",					DIB   => WDAT(1 downto 1),
				ENA   => ENA,					ENB   => ENB,
				RSTA  => '0',					RSTB  => '0',
				WEA   => '0',					WEB   => WR_1,
				DOA   => OPC_1(1 downto 1),		DOB   => OUT_1(1 downto 1)
			);

	m_1_2 : RAMB4_S1_S1
	-- synopsys translate_off
	GENERIC MAP(
	INIT_00 => m_1_2_0, INIT_01 => m_1_2_1, INIT_02 => m_1_2_2, INIT_03 => m_1_2_3, 
	INIT_04 => m_1_2_4, INIT_05 => m_1_2_5, INIT_06 => m_1_2_6, INIT_07 => m_1_2_7, 
	INIT_08 => m_1_2_8, INIT_09 => m_1_2_9, INIT_0A => m_1_2_A, INIT_0B => m_1_2_B, 
	INIT_0C => m_1_2_C, INIT_0D => m_1_2_D, INIT_0E => m_1_2_E, INIT_0F => m_1_2_F)
	-- synopsys translate_on
	PORT MAP(	ADDRA => PC(11 downto 0),		ADDRB => ADR(11 downto 0),
				CLKA  => CLK_I,					CLKB  => CLK_I,
				DIA   => "0",					DIB   => WDAT(2 downto 2),
				ENA   => ENA,					ENB   => ENB,
				RSTA  => '0',					RSTB  => '0',
				WEA   => '0',					WEB   => WR_1,
				DOA   => OPC_1(2 downto 2),		DOB   => OUT_1(2 downto 2)
			);

	m_1_3 : RAMB4_S1_S1
	-- synopsys translate_off
	GENERIC MAP(
	INIT_00 => m_1_3_0, INIT_01 => m_1_3_1, INIT_02 => m_1_3_2, INIT_03 => m_1_3_3, 
	INIT_04 => m_1_3_4, INIT_05 => m_1_3_5, INIT_06 => m_1_3_6, INIT_07 => m_1_3_7, 
	INIT_08 => m_1_3_8, INIT_09 => m_1_3_9, INIT_0A => m_1_3_A, INIT_0B => m_1_3_B, 
	INIT_0C => m_1_3_C, INIT_0D => m_1_3_D, INIT_0E => m_1_3_E, INIT_0F => m_1_3_F)
	-- synopsys translate_on
	PORT MAP(	ADDRA => PC(11 downto 0),		ADDRB => ADR(11 downto 0),
				CLKA  => CLK_I,					CLKB  => CLK_I,
				DIA   => "0",					DIB   => WDAT(3 downto 3),
				ENA   => ENA,					ENB   => ENB,
				RSTA  => '0',					RSTB  => '0',
				WEA   => '0',					WEB   => WR_1,
				DOA   => OPC_1(3 downto 3),		DOB   => OUT_1(3 downto 3)
			);

	m_1_4 : RAMB4_S1_S1
	-- synopsys translate_off
	GENERIC MAP(
	INIT_00 => m_1_4_0, INIT_01 => m_1_4_1, INIT_02 => m_1_4_2, INIT_03 => m_1_4_3, 
	INIT_04 => m_1_4_4, INIT_05 => m_1_4_5, INIT_06 => m_1_4_6, INIT_07 => m_1_4_7, 
	INIT_08 => m_1_4_8, INIT_09 => m_1_4_9, INIT_0A => m_1_4_A, INIT_0B => m_1_4_B, 
	INIT_0C => m_1_4_C, INIT_0D => m_1_4_D, INIT_0E => m_1_4_E, INIT_0F => m_1_4_F)
	-- synopsys translate_on
	PORT MAP(	ADDRA => PC(11 downto 0),		ADDRB => ADR(11 downto 0),
				CLKA  => CLK_I,					CLKB  => CLK_I,
				DIA   => "0",					DIB   => WDAT(4 downto 4),
				ENA   => ENA,					ENB   => ENB,
				RSTA  => '0',					RSTB  => '0',
				WEA   => '0',					WEB   => WR_1,
				DOA   => OPC_1(4 downto 4),		DOB   => OUT_1(4 downto 4)
			);

	m_1_5 : RAMB4_S1_S1
	-- synopsys translate_off
	GENERIC MAP(
	INIT_00 => m_1_5_0, INIT_01 => m_1_5_1, INIT_02 => m_1_5_2, INIT_03 => m_1_5_3, 
	INIT_04 => m_1_5_4, INIT_05 => m_1_5_5, INIT_06 => m_1_5_6, INIT_07 => m_1_5_7, 
	INIT_08 => m_1_5_8, INIT_09 => m_1_5_9, INIT_0A => m_1_5_A, INIT_0B => m_1_5_B, 
	INIT_0C => m_1_5_C, INIT_0D => m_1_5_D, INIT_0E => m_1_5_E, INIT_0F => m_1_5_F)
	-- synopsys translate_on
	PORT MAP(	ADDRA => PC(11 downto 0),		ADDRB => ADR(11 downto 0),
				CLKA  => CLK_I,					CLKB  => CLK_I,
				DIA   => "0",					DIB   => WDAT(5 downto 5),
				ENA   => ENA,					ENB   => ENB,
				RSTA  => '0',					RSTB  => '0',
				WEA   => '0',					WEB   => WR_1,
				DOA   => OPC_1(5 downto 5),		DOB   => OUT_1(5 downto 5)
			);
	-- synopsys translate_on

	m_1_6 : RAMB4_S1_S1
	-- synopsys translate_off
	GENERIC MAP(
	INIT_00 => m_1_6_0, INIT_01 => m_1_6_1, INIT_02 => m_1_6_2, INIT_03 => m_1_6_3, 
	INIT_04 => m_1_6_4, INIT_05 => m_1_6_5, INIT_06 => m_1_6_6, INIT_07 => m_1_6_7, 
	INIT_08 => m_1_6_8, INIT_09 => m_1_6_9, INIT_0A => m_1_6_A, INIT_0B => m_1_6_B, 
	INIT_0C => m_1_6_C, INIT_0D => m_1_6_D, INIT_0E => m_1_6_E, INIT_0F => m_1_6_F)
	-- synopsys translate_on
	PORT MAP(	ADDRA => PC(11 downto 0),		ADDRB => ADR(11 downto 0),
				CLKA  => CLK_I,					CLKB  => CLK_I,
				DIA   => "0",					DIB   => WDAT(6 downto 6),
				ENA   => ENA,					ENB   => ENB,
				RSTA  => '0',					RSTB  => '0',
				WEA   => '0',					WEB   => WR_1,
				DOA   => OPC_1(6 downto 6),		DOB   => OUT_1(6 downto 6)
			);


	m_1_7 : RAMB4_S1_S1
	-- synopsys translate_off
	GENERIC MAP(
	INIT_00 => m_1_7_0, INIT_01 => m_1_7_1, INIT_02 => m_1_7_2, INIT_03 => m_1_7_3, 
	INIT_04 => m_1_7_4, INIT_05 => m_1_7_5, INIT_06 => m_1_7_6, INIT_07 => m_1_7_7, 
	INIT_08 => m_1_7_8, INIT_09 => m_1_7_9, INIT_0A => m_1_7_A, INIT_0B => m_1_7_B, 
	INIT_0C => m_1_7_C, INIT_0D => m_1_7_D, INIT_0E => m_1_7_E, INIT_0F => m_1_7_F)
	-- synopsys translate_on
	PORT MAP(	ADDRA => PC(11 downto 0),		ADDRB => ADR(11 downto 0),
				CLKA  => CLK_I,					CLKB  => CLK_I,
				DIA   => "0",					DIB   => WDAT(7 downto 7),
				ENA   => ENA,					ENB   => ENB,
				RSTA  => '0',					RSTB  => '0',
				WEA   => '0',					WEB   => WR_1,
				DOA   => OPC_1(7 downto 7),		DOB   => OUT_1(7 downto 7)
			);

	process(CLK_I)    -- new
	begin
		if (rising_edge(CLK_I) and T2 = '1') then
			if (CE = '1') then
				LADR <= ADR(15 downto 12);
			end if;
		end if;
	end process;
	

	process(LADR, OUT_0, OUT_1)
	begin

		case LADR is
			when "0001" =>	RDAT <= OUT_1;
			when others =>	RDAT <= OUT_0;
		end case;

	end process;

	process(CLK_I)
	begin
		if (rising_edge(CLK_I) and T2 = '0') then
			if (CE = '1') then
				LPC <= PC(15 downto 12);
			end if;
		end if;
	end process;

	process(LPC, OPC_0, OPC_1)
	begin
		case LPC is
			when "0001" =>	OPC <= OPC_1;
			when others =>	OPC <= OPC_0;
		end case;
	end process;

end Behavioral;
