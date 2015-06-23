-------------------------------------------------------------------------------
-- Title      : UART
-- Project    : UART
-------------------------------------------------------------------------------
-- File        : MiniUart.vhd
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
-- Date    :
-- Modifier        : name <email>
-- Description     :
--
------------------------------------------------------------------------------

library ieee;
   use ieee.std_logic_1164.all;

entity UART is
  generic(BRDIVISOR: INTEGER range 0 to 65535 := 130); -- Baud rate divisor
  port (
-- Wishbone signals
     WB_CLK_I : in  std_logic;  -- clock
     WB_RST_I : in  std_logic;  -- Reset input
     WB_ADR_I : in  std_logic_vector(1 downto 0); -- Adress bus          
     WB_DAT_I : in  std_logic_vector(7 downto 0); -- DataIn Bus
     WB_DAT_O : out std_logic_vector(7 downto 0); -- DataOut Bus
     WB_WE_I  : in  std_logic;  -- Write Enable
     WB_STB_I : in  std_logic;  -- Strobe
     WB_ACK_O : out std_logic;	-- Acknowledge
-- process signals     
     IntTx_O  : out std_logic;  -- Transmit interrupt: indicate waiting for Byte
     IntRx_O  : out std_logic;  -- Receive interrupt: indicate Byte received
     BR_Clk_I : in  std_logic;  -- Clock used for Transmit/Receive
     TxD_PAD_O: out std_logic;  -- Tx RS232 Line
     RxD_PAD_I: in  std_logic);  -- Rx RS232 Line     
end UART;

-- Architecture for UART for synthesis
architecture Behaviour of UART is

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

  signal RxData : std_logic_vector(7 downto 0); -- Last Byte received
  signal TxData : std_logic_vector(7 downto 0); -- Last bytes transmitted
  signal SReg   : std_logic_vector(7 downto 0); -- Status register
  signal EnabRx : std_logic;  -- Enable RX unit
  signal EnabTx : std_logic;  -- Enable TX unit
  signal RxAv   : std_logic;  -- Data Received
  signal TxBusy : std_logic;  -- Transmiter Busy
  signal ReadA  : std_logic;  -- Async Read receive buffer
  signal LoadA  : std_logic;  -- Async Load transmit buffer
  signal Sig0   : std_logic;  -- gnd signal
  signal Sig1   : std_logic;  -- vcc signal  
 
  begin
  sig0 <= '0';
  sig1 <= '1';
  Uart_Rxrate : Counter -- Baud Rate adjust
     generic map (COUNT => BRDIVISOR) 
     port map (BR_CLK_I, sig0, sig1, EnabRx); 
  Uart_Txrate : Counter -- 4 Divider for Tx
     generic map (COUNT => 4)  
     port map (BR_CLK_I, Sig0, EnabRx, EnabTx);
  Uart_TxUnit : TxUnit port map (BR_CLK_I, WB_RST_I, EnabTX, LoadA, TxD_PAD_O, TxBusy, TxData);
  Uart_RxUnit : RxUnit port map (BR_CLK_I, WB_RST_I, EnabRX, ReadA, RxD_PAD_I, RxAv, RxData);
  IntTx_O <= not TxBusy;
  IntRx_O <= RxAv;
  SReg(0) <= not TxBusy;
  SReg(1) <= RxAv;
  SReg(7 downto 2) <= "000000";
  
  -- Implements WishBone data exchange.
  -- Clocked on rising edge. Synchronous Reset RST_I
  WBctrl : process(WB_CLK_I, WB_RST_I, WB_STB_I, WB_WE_I, WB_ADR_I)
  variable StatM : std_logic_vector(4 downto 0);
  begin
     if Rising_Edge(WB_CLK_I) then
        if (WB_RST_I = '1') then
  	   ReadA <= '0';
  	   LoadA <= '0';
  	else
	   if (WB_STB_I = '1' and WB_WE_I = '1' and WB_ADR_I = "00") then -- Write Byte to Tx
              TxData <= WB_DAT_I;
	      LoadA <= '1';   -- Load signal
           else LoadA <= '0';	   
           end if;
	   if (WB_STB_I = '1' and WB_WE_I = '0' and WB_ADR_I = "00") then -- Read Byte from Rx
	      ReadA <= '1';   -- Read signal
           else ReadA <= '0';	   
           end if;           
        end if;	
     end if;
  end process;
  WB_ACK_O <= WB_STB_I;
  WB_DAT_O <=
     RxData when WB_ADR_I = "00" else  -- Read Byte from Rx
     SReg when WB_ADR_I = "01" else    -- Read Status Reg
     "00000000";
end Behaviour;
