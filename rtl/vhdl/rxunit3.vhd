--===========================================================================--
--
--  S Y N T H E Z I A B L E    miniUART   C O R E
--
--  www.OpenCores.Org - January 2000
--  This core adheres to the GNU public license  
--
-- Design units   : miniUART core for the System68
--
-- File name      : rxunit3.vhd
--
-- Purpose        : Implements an miniUART device for communication purposes 
--                  between the cpu68 cpu and the Host computer through
--                  an RS-232 communication protocol.
--                  
-- Dependencies   : ieee.std_logic_1164.all;
--                  ieee.numeric_std.all;
--
--===========================================================================--
-------------------------------------------------------------------------------
-- Revision list
-- Version   Author                 Date                        Changes
--
-- 0.1      Ovidiu Lupas     15 January 2000                   New model
-- 2.0      Ovidiu Lupas     17 April   2000  samples counter cleared for bit 0
--        olupas@opencores.org
--
-- 3.0      John Kent         5 January 2003  Added 6850 word format control
-- 3.1      John Kent        12 January 2003  Significantly revamped receive code.
-- 3.2      John Kent        10 January 2004  Rewrite of code.
--        dilbert57@opencores.org
-------------------------------------------------------------------------------
-- Description    : Implements the receive unit of the miniUART core. Samples
--                  16 times the RxD line and retain the value in the middle of
--                  the time interval. 
library ieee;
   use ieee.std_logic_1164.all;
   use ieee.std_logic_unsigned.all;

-------------------------------------------------------------------------------
-- Receive unit
-------------------------------------------------------------------------------
entity RxUnit is
  port (
     Clk    : in  Std_Logic;  -- Clock signal
     Reset  : in  Std_Logic;  -- Reset input
     ReadD  : in  Std_Logic;  -- Read data signal
     WdFmt  : in  Std_Logic_Vector(2 downto 0); -- word format
     BdFmt  : in  Std_Logic_Vector(1 downto 0); -- baud format
     RxClk  : in  Std_Logic;  -- RS-232 clock input
     RxDat  : in  Std_Logic;  -- RS-232 data input
     FRErr  : out Std_Logic;  -- Status signal
     ORErr  : out Std_Logic;  -- Status signal
	  PAErr  : out Std_logic;  -- Status signal
     DARdy  : out Std_Logic;  -- Status signal
     DAOut  : out Std_Logic_Vector(7 downto 0)
	  );
end; --================== End of entity ==============================--
-------------------------------------------------------------------------------
-- Architecture for receive Unit
-------------------------------------------------------------------------------
architecture Behaviour of RxUnit is
  -----------------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------------
  signal RxDebDel0  : Std_Logic;             -- Debounce Delayed Rx Data
  signal RxDebDel1  : Std_Logic;             -- Debounce Delayed Rx Data
  signal RxDebDel2  : Std_Logic;             -- Debounce Delayed Rx Data
  signal RxDebDel3  : Std_Logic;             -- Debounce Delayed Rx Data
  signal RxDeb      : Std_Logic;             -- Debounced Rx Data
  signal RxDatDel   : Std_Logic;             -- Delayed Rx Data
  signal RxDatEdge  : Std_Logic;             -- Rx Data Edge pulse
  signal RxClkDel   : Std_Logic;             -- Delayed Rx Input Clock
  signal RxClkEdge  : Std_Logic;             -- Rx Input Clock Edge pulse
  signal RxClkCnt   : Std_Logic_Vector(5 downto 0); -- Rx Baud Clock Counter
  signal RxBdClk    : Std_Logic;             -- Rx Baud Clock
  signal RxBdDel    : Std_Logic;             -- Delayed Rx Baud Clock
  signal RxBdEdge   : Std_Logic;             -- Rx Baud Clock Edge pulse
  signal RxStart    : Std_Logic;					-- Rx Start bit detected

  signal tmpDRdy    : Std_Logic;             -- Data Ready flag
  signal RxValid    : Std_Logic;             -- Rx Data Valid
  signal tmpRxVal   : Std_Logic;             -- Rx Data Valid
  signal outErr     : Std_Logic;             -- Over run error bit
  signal frameErr   : Std_Logic;             -- Framing error bit
  signal ParityErr  : Std_Logic;             -- Parity Error Bit
  signal RxParity   : Std_Logic;             -- Calculated RX parity bit
  signal RxState    : Std_Logic_Vector(3 downto 0);  -- receive bit state
  signal ShtReg     : Std_Logic_Vector(7 downto 0);  -- Shift Register
  signal DataOut    : Std_Logic_Vector(7 downto 0);  -- Data Output register

begin

  ---------------------------------------------------------------------
  -- Receiver Data Debounce
  -- Input level must be stable for 4 Receive Clock cycles.
  ---------------------------------------------------------------------
  rxunit_data_debounce : process(Clk, Reset, RxClkEdge, RxDat,
                                 RxDebDel0, RxDebDel1, RxDebDel2, RxDebDel3 )
  begin
    if Reset = '1' then
	   RxDebDel0 <= RxDat;
	   RxDebDel1 <= RxDat;
	   RxDebDel2 <= RxDat;
	   RxDebDel3 <= RxDat;
	 elsif Clk'event and Clk = '0' then
	   if RxClkEdge = '1' then
	     RxDebDel0  <= RxDat;
	     RxDebDel1  <= RxDebDel0;
	     RxDebDel2  <= RxDebDel1;
	     RxDebDel3  <= RxDebDel2;
		  if (RxDebDel3 or RxDebDel2 or RxDebDel1 or RxDebDel0) = '0' then
		    RxDeb <= '0';
        elsif (RxDebDel3 and RxDebDel2 and RxDebDel1 and RxDebDel0) = '1' then
		    RxDeb <= '1';
        else
		    RxDeb <= RxDeb;
        end if;
      else
	     RxDebDel0  <= RxDebDel0;
	     RxDebDel1  <= RxDebDel1;
	     RxDebDel2  <= RxDebDel2;
	     RxDebDel3  <= RxDebDel3;
		  RxDeb      <= RxDeb;
      end if;
	 end if;
  end process;

  ---------------------------------------------------------------------
  -- Receiver Data Edge Detection
  -- A falling edge will produce a one clock cycle pulse
  ---------------------------------------------------------------------
  rxunit_data_edge : process(Clk, Reset, RxDeb, RxDatDel )
  begin
    if Reset = '1' then
	   RxDatDel  <= RxDeb;
		RxDatEdge <= '0';
	 elsif Clk'event and Clk = '0' then
	   RxDatDel  <= RxDeb;
		RxDatEdge <= RxDatDel and (not RxDeb);
	 end if;
  end process;

  ---------------------------------------------------------------------
  -- Receiver Clock Edge Detection
  -- A rising edge will produce a one clock cycle pulse
  -- RxClock 
  ---------------------------------------------------------------------
  rxunit_clock_edge : process(Clk, Reset, RxClk, RxClkDel )
  begin
    if Reset = '1' then
	   RxClkDel  <= RxClk;
		RxClkEdge <= '0';
	 elsif Clk'event and Clk = '0' then
	   RxClkDel  <= RxClk;
		RxClkEdge <= RxClk and (not RxClkDel);
	 end if;
  end process;


  ---------------------------------------------------------------------
  -- Receiver Clock Divider
  -- Reset the Rx Clock divider on any data edge
  -- Note that debounce data will be skewed by 4 clock cycles.
  -- Advance the count only on an input clock pulse
  ---------------------------------------------------------------------
  rxunit_clock_divide : process(Clk, Reset, RxDatEdge, RxState, RxStart,
                                RxClkEdge, RxClkCnt )
  begin
    if Reset = '1' then
	   RxClkCnt  <= "000000";
		RxStart   <= '0';
	 elsif Clk'event and Clk = '0' then

	   if RxState = "1111" then     -- idle state
		  if RxStart = '0' then      -- in hunt mode
		    if RxDatEdge = '1' then -- falling edge starts counter
		      RxStart <= '1';
          else
			   RxStart <= RxStart;	  -- other wise remain halted
          end if;
        else
		    RxStart <= RxStart;		  -- Acquired start, stay in this state
        end if;
      else
		  RxStart <= '0';	           -- non idle, reset start flag
      end if; -- RxState

      if RxState = "1111" and RxStart = '0' then
		  RxClkCnt <= "000011";  -- Reset to 3 to account for debounce skew
		else
		  if RxClkEdge = '1' then
		    RxClkCnt <= RxClkCnt + "000001";
        else
		    RxClkCnt <= RxClkCnt;
        end if; -- RxClkEdge
      end if; -- RxState
	 end if;	 -- clk / reset
  end process;

  ---------------------------------------------------------------------
  -- Receiver Clock Selector
  -- Select output then look for rising edge
  ---------------------------------------------------------------------
  rxunit_clock_select : process(Clk, Reset, BdFmt, RxClk, RxClkCnt,
                                RxBdDel, RxBdEdge )
  begin
  -- BdFmt
  -- 0 0     - Baud Clk divide by 1
  -- 0 1     - Baud Clk divide by 16
  -- 1 0     - Baud Clk divide by 64
  -- 1 1     - reset
    case BdFmt is
	 when "00" =>	  -- Div by 1
	   RxBdClk <= RxClk;
	 when "01" =>	  -- Div by 16
	   RxBdClk <= RxClkCnt(3);
	 when "10" =>	  -- Div by 64
	   RxBdClk <= RxClkCnt(5);
	 when others =>  -- reset
	   RxBdClk <= '0';
    end case;

    if Reset = '1' then
	   RxBdDel  <= RxBdClk;
		RxBdEdge <= '0';
	 elsif Clk'event and Clk = '0' then
	   RxBdDel  <= RxBdClk;
		RxBdEdge <= RxBdClk and (not RxBdDel);
	 end if;

  end process;


  ---------------------------------------------------------------------
  -- Receiver process
  ---------------------------------------------------------------------
  rxunit_receive : process(Clk, Reset, RxState, RxBdEdge, RxDat )
  begin
    if Reset = '1' then
        frameErr  <= '0';
        outErr    <= '0';
		  parityErr <= '0';

        ShtReg    <= "00000000";  -- Shift register
		  DataOut   <= "00000000";
		  RxParity  <= '0';         -- Parity bit
		  RxValid   <= '0';         -- Data RX data valid flag
        RxState   <= "1111";
    elsif Clk'event and Clk='0' then
        if RxBdEdge = '1' then
          case RxState is
          when "0000" | "0001" | "0010" | "0011" |
					"0100" | "0101" | "0110" => -- data bits 0 to 6
            ShtReg    <= RxDat & ShtReg(7 downto 1);
			   RxParity  <= RxParity xor RxDat;
				parityErr <= parityErr;
				frameErr  <= frameErr;
				outErr    <= outErr;
				RxValid   <= '0';   
				DataOut   <= DataOut;
				if RxState = "0110" then
 			     if WdFmt(2) = '0' then
                RxState <= "1000";          -- 7 data + parity
			     else
                RxState <= "0111";          -- 8 data bits
				  end if; -- WdFmt(2)
				else
              RxState   <= RxState + "0001";
				end if; -- RxState

          when "0111" =>                 -- data bit 7
            ShtReg    <= RxDat & ShtReg(7 downto 1);
			   RxParity  <= RxParity xor RxDat;
				parityErr <= parityErr;
				frameErr  <= frameErr;
				outErr    <= outErr;
				RxValid   <= '0';   
				DataOut   <= DataOut;
			   if WdFmt(1) = '1' then      -- parity bit ?
              RxState <= "1000";         -- yes, go to parity
				else
              RxState <= "1001";         -- no, must be 2 stop bit bits
			   end if;

	       when "1000" =>                 -- parity bit
			   if WdFmt(2) = '0' then
              ShtReg <= RxDat & ShtReg(7 downto 1); -- 7 data + parity
				else
				  ShtReg <= ShtReg;          -- 8 data + parity
				end if;
				RxParity <= RxParity;
				if WdFmt(0) = '0' then      -- parity polarity ?
				  if RxParity = RxDat then  -- check even parity
					  parityErr <= '1';
				  else
					  parityErr <= '0';
				  end if;
				else
				  if RxParity = RxDat then  -- check for odd parity
					  parityErr <= '0';
				  else
					  parityErr <= '1';
				  end if;
				end if;
				frameErr  <= frameErr;
				outErr    <= outErr;
				RxValid   <= '0';   
				DataOut   <= DataOut;
            RxState   <= "1001";

          when "1001" =>                 -- stop bit (Only one required for RX)
			   ShtReg    <= ShtReg;
				RxParity  <= RxParity;
				parityErr <= parityErr;
            if RxDat = '1' then         -- stop bit expected
              frameErr <= '0';           -- yes, no framing error
            else
              frameErr <= '1';           -- no, framing error
            end if;
            if tmpDRdy = '1' then        -- Has previous data been read ? 
              outErr <= '1';             -- no, overrun error
            else
              outErr <= '0';             -- yes, no over run error
            end if;
				RxValid   <= '1';   
				DataOut   <= ShtReg;
            RxState   <= "1111";

          when others =>                 -- this is the idle state
            ShtReg    <= ShtReg;
			   RxParity  <= RxParity;
				parityErr <= parityErr;
				frameErr  <= frameErr;
				outErr    <= outErr;
				RxValid   <= '0';   
				DataOut   <= DataOut;
			   if RxDat = '0' then  -- look for start request
              RxState  <= "0000"; -- yes, read data
			   else
				  RxState <= "1111";    -- otherwise idle
			   end if;
          end case; -- RxState
		  else  -- RxBdEdge
            ShtReg    <= ShtReg;
			   RxParity  <= RxParity;
				parityErr <= parityErr;
				frameErr  <= frameErr;
				outErr    <= outErr;
				RxValid   <= RxValid;   
				DataOut   <= DataOut;
				RxState   <= RxState;
        end if; -- RxBdEdge
    end if; -- clk / reset
  end process;


  ---------------------------------------------------------------------
  -- Receiver Read process
  ---------------------------------------------------------------------
  rxunit_read : process(Clk, Reset, ReadD, RxValid, tmpRxVal, tmpDRdy )
  begin
    if Reset = '1' then
        tmpDRdy   <= '0';
		  tmpRxVal  <= '0';
    elsif Clk'event and Clk='0' then
        if ReadD = '1' then
		    -- Data was read, reset data ready
          tmpDRdy  <= '0';
			 tmpRxVal <= tmpRxVal;
		  else
		    if RxValid = '1' and tmpRxVal = '0' then
			   -- Data was received, set Data ready
			   tmpDRdy  <= '1';
				tmpRxVal <= '1';
			 else
			   -- Test for falling edge of RxValid.
		      tmpDRdy <= tmpDRdy;
			   if RxValid = '0' and tmpRxVal = '1' then
			     tmpRxVal  <= '0';
			   else
			     tmpRxVal  <= tmpRxVal;
				end if;
			 end if; -- RxValid
        end if; -- ReadD
    end if; -- clk / reset
  end process;


  DARdy <= tmpDRdy;
  DAOut <= DataOut;
  FRErr <= frameErr;
  ORErr <= outErr;
  PAErr <= parityErr;

end Behaviour; --==================== End of architecture ====================--