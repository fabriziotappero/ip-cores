--===========================================================================--
--
--  S Y N T H E Z I A B L E    miniUART   C O R E
--
--  www.OpenCores.Org - January 2000
--  This core adheres to the GNU public license  
--
-- Design units   : miniUART core for the System68
--
-- File name      : miniuart2.vhd
--
-- Purpose        : Implements an miniUART device for communication purposes 
--                  between the CPU68 processor and the Host computer through
--                  an RS-232 communication protocol.
--                  
-- Dependencies   : ieee.std_logic_1164
--                  ieee.numeric_std
--
--===========================================================================--
-------------------------------------------------------------------------------
-- Revision list
-- Version   Author                 Date           Changes
--
-- 0.1      Ovidiu Lupas     15 January 2000       New model
-- 1.0      Ovidiu Lupas     January  2000         Synthesis optimizations
-- 2.0      Ovidiu Lupas     April    2000         Bugs removed - RSBusCtrl
--          the RSBusCtrl did not process all possible situations
--
--        olupas@opencores.org
--
-- 3.0      John Kent        October  2002         Changed Status bits to match mc6805
--                                                 Added CTS, RTS, Baud rate control
--                                                 & Software Reset
-- 3.1      John Kent        5 January 2003        Added Word Format control a'la mc6850
-- 3.2      John Kent        19 July 2003          Latched Data input to UART
-- 3.3      John Kent        16 January 2004       Integrated clkunit in rxunit & txunit
--                                                 Now has external TX 7 RX Baud Clock
--                                                 inputs like the MC6850... 
--                                                 also supports x1 clock and DCD. 
--
--        dilbert57@opencores.org
--
-------------------------------------------------------------------------------
-- Entity for miniUART Unit - 9600 baudrate                                  --
-------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;

entity miniUART is
  port (
     --
	  -- CPU signals
	  --
     clk      : in  Std_Logic;  -- System Clock
     rst      : in  Std_Logic;  -- Reset input (active high)
     cs       : in  Std_Logic;  -- miniUART Chip Select
     rw       : in  Std_Logic;  -- Read / Not Write
     irq      : out Std_Logic;  -- Interrupt
     Addr     : in  Std_Logic;  -- Register Select
     DataIn   : in  Std_Logic_Vector(7 downto 0); -- Data Bus In 
     DataOut  : out Std_Logic_Vector(7 downto 0); -- Data Bus Out
     --
	  -- Uart Signals
	  --
     RxC      : in  Std_Logic;  -- Receive Baud Clock
     TxC      : in  Std_Logic;  -- Transmit Baud Clock
     RxD      : in  Std_Logic;  -- Receive Data
     TxD      : out Std_Logic;  -- Transmit Data
	  DCD_n    : in  Std_Logic;  -- Data Carrier Detect
     CTS_n    : in  Std_Logic;  -- Clear To Send
     RTS_n    : out Std_Logic );  -- Request To send
end; --================== End of entity ==============================--
-------------------------------------------------------------------------------
-- Architecture for miniUART Controller Unit
-------------------------------------------------------------------------------
architecture uart of miniUART is
  -----------------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------------
  signal RxData : Std_Logic_Vector(7 downto 0); -- 
  signal TxData : Std_Logic_Vector(7 downto 0); -- 
  signal StatReg : Std_Logic_Vector(7 downto 0); -- status register
  --             StatReg detailed 
  -----------+--------+--------+--------+--------+--------+--------+--------+
  --  Irq    | PErr   | ORErr  | FErr   | CTS    | DCD    | TBufE  | DRdy   |
  -----------+--------+--------+--------+--------+--------+--------+--------+
  signal CtrlReg : Std_Logic_Vector(7 downto 0); -- control register
  --             CtrlReg detailed 
  -----------+--------+--------+--------+--------+--------+--------+--------+
  --  RxIEnb |TxCtl(1)|TxCtl(0)|WdFmt(2)|WdFmt(1)|WdFmt(0)|BdCtl(1)|BdCtl(0)|
  -----------+--------+--------+--------+--------+--------+--------+--------+
  -- RxIEnb
  -- 0       - Rx Interrupt disabled
  -- 1       - Rx Interrupt enabled
  -- TxCtl
  -- 0 1     - Tx Interrupt Enable
  -- 1 0     - RTS high
  -- WdFmt
  -- 0 0 0   - 7 data, even parity, 2 stop
  -- 0 0 1   - 7 data, odd  parity, 2 stop
  -- 0 1 0   - 7 data, even parity, 1 stop
  -- 0 1 1   - 7 data, odd  parity, 1 stop
  -- 1 0 0   - 8 data, no   parity, 2 stop
  -- 1 0 1   - 8 data, no   parity, 1 stop
  -- 1 1 0   - 8 data, even parity, 1 stop
  -- 1 1 1   - 8 data, odd  parity, 1 stop
  -- BdCtl
  -- 0 0     - Baud Clk divide by 1
  -- 0 1     - Baud Clk divide by 16
  -- 1 0     - Baud Clk divide by 64
  -- 1 1     - reset
 
  signal TxDbit   : Std_Logic;  -- Transmit data bit
  signal DRdy     : Std_Logic;  -- Receive Data ready
  signal TBufE    : Std_Logic;  -- Transmit buffer empty
  signal FErr     : Std_Logic;  -- Frame error
  signal OErr     : Std_Logic;  -- Output error
  signal PErr     : Std_Logic;  -- Parity Error
  signal TxIEnb   : Std_Logic;  -- Transmit interrupt enable
  signal Read     : Std_Logic;  -- Read receive buffer
  signal Load     : Std_Logic;  -- Load transmit buffer
  signal ReadCS   : Std_Logic;  -- Read Status register
  signal LoadCS   : Std_Logic;  -- Load Control register
  signal Reset    : Std_Logic;  -- Reset (Software & Hardware)
  signal RxRst    : Std_Logic;  -- Receive Reset (Software & Hardware)
  signal TxRst    : Std_Logic;  -- Transmit Reset (Software & Hardware)
  signal DCDDel   : Std_Logic;  -- Delayed DCD_n
  signal DCDEdge  : Std_Logic;  -- Rising DCD_N Edge Pulse
  signal DCDState : Std_Logic;  -- DCD Reset sequencer
  signal DCDInt   : Std_Logic;  -- DCD Interrupt

  -----------------------------------------------------------------------------
  -- Receive Unit
  -----------------------------------------------------------------------------
  component RxUnit
  port (
     Clk     : in  Std_Logic;  -- Clock signal
     Reset   : in  Std_Logic;  -- Reset input
     ReadD   : in  Std_Logic;  -- Read data signal
     WdFmt   : in  Std_Logic_Vector(2 downto 0); -- word format
     BdFmt   : in  Std_Logic_Vector(1 downto 0); -- baud format
     RxClk   : in  Std_Logic;  -- RS-232 clock input
     RxDat   : in  Std_Logic;  -- RS-232 data input
     FRErr   : out Std_Logic;  -- Status signal
     ORErr   : out Std_Logic;  -- Status signal
	  PAErr   : out Std_logic;  -- Status signal
     DARdy   : out Std_Logic;  -- Status signal
     DAOut   : out Std_Logic_Vector(7 downto 0));
  end component;
  -----------------------------------------------------------------------------
  -- Transmitter Unit
  -----------------------------------------------------------------------------
  component TxUnit
  port (
     Clk    : in  Std_Logic;  -- Clock signal
     Reset  : in  Std_Logic;  -- Reset input
     LoadD  : in  Std_Logic;  -- Load transmit data
     DAIn   : in  Std_Logic_Vector(7 downto 0);
     WdFmt  : in  Std_Logic_Vector(2 downto 0); -- word format
     BdFmt  : in  Std_Logic_Vector(1 downto 0); -- baud format
     TxClk  : in  Std_Logic;  -- Enable input
     TxDat  : out Std_Logic;  -- RS-232 data output
     TBE    : out Std_Logic );  -- Tx buffer empty
  end component;
begin
  -----------------------------------------------------------------------------
  -- Instantiation of internal components
  -----------------------------------------------------------------------------

  RxDev   : RxUnit  port map (
                Clk      => clk,
					 Reset    => RxRst,
					 ReadD    => Read,
					 WdFmt    => CtrlReg(4 downto 2),
					 BdFmt    => CtrlReg(1 downto 0),
					 RxClk    => RxC,
					 RxDat    => RxD,
					 FRErr    => FErr,
					 ORErr    => OErr,
					 PAErr    => PErr,
					 DARdy    => DRdy,
					 DAOut    => RxData
					 );

 
  TxDev   : TxUnit  port map (
                Clk      => clk,
					 Reset    => TxRst,
					 LoadD    => Load,
					 DAIn     => TxData,
					 WdFmt    => CtrlReg(4 downto 2),
					 BdFmt    => CtrlReg(1 downto 0),
					 TxClk    => TxC,
					 TxDat    => TxDbit,
					 TBE      => TBufE
					 );

  -----------------------------------------------------------------------------
  -- Implements the controller for Rx&Tx units
  -----------------------------------------------------------------------------
miniUart_Status : process(clk, Reset, CtrlReg, TxIEnb,
                          DRdy, TBufE, DCD_n, CTS_n, DCDInt,
                          FErr, OErr,  PErr )
variable Int : Std_Logic;
  begin
    if Reset = '1' then
	    Int     := '0';
       StatReg <= "00000000";
		 irq     <= '0';
    elsif clk'event and clk='0' then
		 Int        := (CtrlReg(7) and DRdy)   or
		               (CtrlReg(7) and DCDInt) or
		               (TxIEnb     and TBufE);
       StatReg(0) <= DRdy;  -- Receive Data Ready
       StatReg(1) <= TBufE and (not CTS_n); -- Transmit Buffer Empty
	    StatReg(2) <= DCDInt; -- Data Carrier Detect
		 StatReg(3) <= CTS_n; -- Clear To Send
       StatReg(4) <= FErr;  -- Framing error
       StatReg(5) <= OErr;  -- Overrun error
       StatReg(6) <= PErr;  -- Parity error
		 StatReg(7) <= Int;
		 irq        <= Int;
    end if;
  end process;


-----------------------------------------------------------------------------
-- Transmit control
-----------------------------------------------------------------------------

miniUart_TxControl : process( CtrlReg, TxDbit )
begin
    case CtrlReg(6 downto 5) is
	 when "00" => -- Disable TX Interrupts, Assert RTS
	   RTS_n  <= '0';
		TxIEnb <= '0';
		TxD    <= TxDbit;
    when "01" => -- Enable TX interrupts, Assert RTS
	   RTS_n  <= '0';
		TxIEnb <= '1';
		TxD    <= TxDbit;
    when "10" => -- Disable Tx Interrupts, Clear RTS
	   RTS_n  <= '1';
		TxIEnb <= '0';
		TxD    <= TxDbit;
    when "11" => -- Disable Tx interrupts, Assert RTS, send break
	   RTS_n  <= '0';
		TxIEnb <= '0';
		TxD    <= '0';
    when others =>
	   RTS_n  <= '0';
		TxIEnb <= '0';
		TxD    <= TxDbit;
	 end case;
end process;

-----------------------------------------------------------------------------
-- Write to control register
-----------------------------------------------------------------------------

miniUart_Control:  process(clk, Reset, cs, rw, Addr, DataIn, CtrlReg, TxData )
begin
  if (reset = '1') then
		 TxData  <= "00000000";
		 Load    <= '0';
		 Read    <= '0';
	    CtrlReg <= "00000000";
		 LoadCS  <= '0';
		 ReadCS	<= '0';
	elsif clk'event and clk='0' then
	    if cs = '1' then
	      if Addr = '1' then	-- Data Register
		     if rw = '0' then   -- write data register
             TxData <= DataIn;
	          Load   <= '1';
		       Read   <= '0';
  	        else               -- read Data Register
             TxData <= TxData;
	          Load   <= '0';
             Read   <= '1';
			  end if; -- rw
		     CtrlReg <= CtrlReg;
			  LoadCS  <= '0';
			  ReadCS	 <= '0';
	      else					  -- Control / Status register
           TxData <= TxData;
	        Load   <= '0';
		     Read   <= '0';
		     if rw = '0' then   -- write control register
			    CtrlReg <= DataIn;
				 LoadCS  <= '1';
				 ReadCS	<= '0';
  	        else               -- read status Register
		       CtrlReg <= CtrlReg;
				 LoadCS  <= '0';
				 ReadCS	<= '1';
			  end if; -- rw
		   end if; -- Addr
	    else                   -- not selected
         TxData  <= TxData;
	      Load    <= '0';
		   Read    <= '0';
			CtrlReg <= CtrlReg;
			LoadCS  <= '0';
			ReadCS  <= '0';

	    end if;  -- cs
   end if; -- clk / reset
end process;

---------------------------------------------------------------
--
-- set data output mux
--
--------------------------------------------------------------

miniUart_data_read: process(Addr, StatReg, RxData)
begin
	  if Addr = '1' then
		 DataOut <= RxData;    -- read data register
	  else
		 DataOut <= StatReg;   -- read status register
	  end if; -- Addr
end process;


---------------------------------------------------------------
--
-- Data Carrier Detect Edge rising edge detect
--
---------------------------------------------------------------
miniUart_DCD_edge : process( reset, clk, DCD_n, DCDDel	)
begin
   if reset = '1' then
	   DCDEdge <= '0';
		DCDDel  <= '0';
   elsif clk'event and clk = '0' then
	   DCDDel <= DCD_n;
		DCDEdge <= DCD_n and (not DCDDel);
   end if;
end process;


---------------------------------------------------------------
--
-- Data Carrier Detect Interrupt
--
---------------------------------------------------------------
miniUart_DCD_int : process( reset, clk, DCDEdge, DCDState, Read, ReadCS, DCDInt )
begin
   if reset = '1' then
	   DCDInt   <= '0';
		DCDState <= '0';
   elsif clk'event and clk = '0' then
		if DCDEdge = '1' then
		   DCDInt   <= '1';
			DCDState <= '0';
      elsif DCDState	= '0' then
		     -- To reset DCD interrupt, First read status
			  if (ReadCS <= '1') and (DCDInt = '1') then
			     DCDState <= '1';
           else
			     DCDState <= '0';
           end if;
		     DCDInt <= DCDInt;
      else	-- DCDstate = '1'
		     -- Then read the data register
			  if Read <= '1' then
			     DCDState <= '0';
				  DCDInt <= '0';
           else
			     DCDState <= DCDState;
				  DCDInt   <= DCDInt;
           end if;        
      end if; -- DCDState
   end if; -- clk / reset
end process;

---------------------------------------------------------------
--
-- reset may be hardware or software
--
---------------------------------------------------------------

miniUart_reset: process(rst, CtrlReg, Reset, DCD_n )
begin
	  Reset <= (CtrlReg(1) and CtrlReg(0)) or rst;
	  TxRst <= Reset;
	  RxRst <= Reset or DCD_n;
end process;

end; --===================== End of architecture =======================--

