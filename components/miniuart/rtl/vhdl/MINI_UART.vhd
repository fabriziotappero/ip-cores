-------------------------------------------------------------------------------
-- Title      : UART
-- Project    : UART
-------------------------------------------------------------------------------
-- File        : MINI_UART.vhd
-- Author      : Philippe CARTON 
--               (philippe.carton2@libertysurf.fr)
-- Organization:
-- Created     : 15/12/2001
-- Last update : 8/1/2003
-- Platform    : Foundation 3.1i
-- Simulators  : ModelSim 5.5b
-- Synthesizers: Xilinx Synthesis
-- Targets     : Xilinx Spartan
-- Dependency  : IEEE std_logic_1164, Rxunit.vhd, Txunit.vhd, utils.vhd
-------------------------------------------------------------------------------
-- Description: Uart (Universal Asynchronous Receiver Transmitter) for SoC.
--    Wishbone compatable.
-------------------------------------------------------------------------------
-- Copyright (c) notice
--    This core adheres to the GNU public license 
--
-------------------------------------------------------------------------------
-- Revisions       :
-- Revision Number :
-- Version         :
-- Date            : 22.02.2012
-- Modifier        : Stephan Nolting
-- Description     : Adapted to pipelined Wishbone 32-bit bus
--
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity MINI_UART is
	generic	(
				BRDIVISOR     : INTEGER range 0 to 65535 -- Baud rate divisor
			);
	port	(
				-- Wishbone Bus --
				WB_CLK_I      : in  STD_LOGIC; -- memory master clock
				WB_RST_I      : in  STD_LOGIC; -- high active sync reset
				WB_CTI_I      : in  STD_LOGIC_VECTOR(02 downto 0); -- cycle indentifier
				WB_TGC_I      : in  STD_LOGIC_VECTOR(06 downto 0); -- cycle tag
				WB_ADR_I      : in  STD_LOGIC; -- adr in
				WB_DATA_I     : in  STD_LOGIC_VECTOR(31 downto 0); -- write data
				WB_DATA_O     : out STD_LOGIC_VECTOR(31 downto 0); -- read data
				WB_SEL_I      : in  STD_LOGIC_VECTOR(03 downto 0); -- data quantity
				WB_WE_I       : in  STD_LOGIC; -- write enable
				WB_STB_I      : in  STD_LOGIC; -- valid cycle
				WB_ACK_O      : out STD_LOGIC; -- acknowledge
				WB_HALT_O     : out STD_LOGIC; -- throttle master
				WB_ERR_O      : out STD_LOGIC; -- abnormal termination

				-- Terminal signals --
				IntTx_O       : out STD_LOGIC; -- Transmit interrupt: indicate waiting for Byte
				IntRx_O       : out STD_LOGIC; -- Receive interrupt: indicate Byte received
				BR_Clk_I      : in  STD_LOGIC; -- Clock used for Transmit/Receive
				TxD_PAD_O     : out STD_LOGIC; -- Tx RS232 Line
				RxD_PAD_I     : in  STD_LOGIC  -- Rx RS232 Line
			);
end MINI_UART;

-- Architecture for MINI_UART for synthesis
architecture Behaviour of MINI_UART is

  component Counter
  generic(COUNT: INTEGER range 0 to 65535); -- Count revolution
  port (
     Clk      : in  std_logic;  -- Clock
     Reset    : in  std_logic;  -- Reset input
     CE       : in  std_logic;  -- Chip Enable
     O        : out std_logic); -- Output  
  end component;

  component RxUnit
  port (
     Clk    : in  std_logic;  -- system clock signal
     Reset  : in  std_logic;  -- Reset input
     Enable : in  std_logic;  -- Enable input
     ReadA  : in  Std_logic;  -- Async Read Received Byte
     RxD    : in  std_logic;  -- RS-232 data input
     RxAv   : out std_logic;  -- Byte available
     DataO  : out std_logic_vector(7 downto 0)); -- Byte received
  end component;

  component TxUnit
  port (
     Clk    : in  std_logic;  -- Clock signal
     Reset  : in  std_logic;  -- Reset input
     Enable : in  std_logic;  -- Enable input
     LoadA  : in  std_logic;  -- Asynchronous Load
     TxD    : out std_logic;  -- RS-232 data output
     Busy   : out std_logic;  -- Tx Busy
     DataI  : in  std_logic_vector(7 downto 0)); -- Byte to transmit
  end component;

  signal RxData : std_logic_vector(7 downto 0) := x"00"; -- Last Byte received
  signal TxData : std_logic_vector(7 downto 0) := x"00"; -- Last bytes transmitted
  signal SReg   : std_logic_vector(7 downto 0) := x"00"; -- Status register
  signal EnabRx : std_logic;  -- Enable RX unit
  signal EnabTx : std_logic;  -- Enable TX unit
  signal RxAv   : std_logic;  -- Data Received
  signal TxBusy : std_logic;  -- Transmiter Busy
  signal ReadA  : std_logic;  -- Async Read receive buffer
  signal LoadA  : std_logic;  -- Async Load transmit buffer
  signal WB_ACK_O_INT : STD_LOGIC;  
 
  begin
	  Uart_Rxrate : Counter -- Baud Rate adjust
		 generic map (COUNT => BRDIVISOR) 
		 port map (BR_CLK_I, '0', '1', EnabRx); 
	  Uart_Txrate : Counter -- 4 Divider for Tx
		 generic map (COUNT => 4)  
		 port map (BR_CLK_I, '0', EnabRx, EnabTx);
	  Uart_TxUnit : TxUnit port map (BR_CLK_I, WB_RST_I, EnabTX, LoadA, TxD_PAD_O, TxBusy, TxData);
	  Uart_RxUnit : RxUnit port map (BR_CLK_I, WB_RST_I, EnabRX, ReadA, RxD_PAD_I, RxAv,   RxData);
	  IntTx_O <= not TxBusy;
	  IntRx_O <= RxAv;
	  SReg(0) <= not TxBusy;
	  SReg(1) <= RxAv;
	  SReg(7 downto 2) <= "000000";


	-- Wishbone Access -------------------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		WB_ACCESS: process(WB_CLK_I)
		begin
			if rising_edge(WB_CLK_I) then
				if (WB_RST_I = '1') then
					WB_DATA_O    <= (others => '0');
					WB_ACK_O_INT <= '0';
					LoadA        <= '0';
					ReadA        <= '0';
					TxData       <= (others => '0');
				else
					--- Defaults ---
					LoadA     <= '0';
					ReadA     <= '0';
					TxData    <= x"00";
					WB_DATA_O <= (others => '0');

					--- Data Write ---
					if (WB_STB_I = '1') and (WB_WE_I = '1') then
						if (WB_ADR_I = '0') then
							TxData <= WB_DATA_I(7 downto 0);
							LoadA  <= '1';
						end if;
					end if;

					--- Data Read ---
					if (WB_STB_I = '1') and (WB_WE_I = '0') then
						if (WB_ADR_I = '0') then
							WB_DATA_O <= x"000000" & RxData;
							ReadA     <= '1';
						else
							WB_DATA_O <= x"000000" & SReg;
						end if;
					end if;

					--- ACK Control ---
					if (WB_CTI_I = "000") or (WB_CTI_I = "111") then
						WB_ACK_O_INT <= WB_STB_I and (not WB_ACK_O_INT);
					else
						WB_ACK_O_INT <= WB_STB_I; -- data is valid one cycle later
					end if;
				end if;
			end if;
		end process WB_ACCESS;

		--- ACK Signal ---
		WB_ACK_O <= WB_ACK_O_INT;

		--- Throttle ---
		WB_HALT_O <= '0'; -- yeay, we're at full speed!

		--- Error ---
		WB_ERR_O <= '0';



end Behaviour;
