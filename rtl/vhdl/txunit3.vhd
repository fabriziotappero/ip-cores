--===========================================================================--
--
--  S Y N T H E Z I A B L E    miniUART   C O R E
--
--  www.OpenCores.Org - January 2000
--  This core adheres to the GNU public license  
--
-- Design units   : miniUART core for the System68
--
-- File name      : txunit2.vhd
--
-- Purpose        : Implements an miniUART device for communication purposes 
--                  between the CPU68 processor and the Host computer through
--                  an RS-232 communication protocol.
--                  
-- Dependencies   : IEEE.Std_Logic_1164
--
--===========================================================================--
-------------------------------------------------------------------------------
-- Revision list
-- Version   Author                 Date                        Changes
--
-- 0.1      Ovidiu Lupas       15 January 2000                 New model
-- 2.0      Ovidiu Lupas       17 April   2000    unnecessary variable removed
--  olupas@opencores.org
--
-- 3.0      John Kent           5 January 2003    added 6850 word format control
-- 3.1      John Kent          12 January 2003    Rearranged state machine code
-- 3.2      John Kent          30 March 2003      Revamped State machine
-- 3.3      John Kent          16 January 2004    Major re-write - added baud rate gen
--
--  dilbert57@opencores.org
--
-------------------------------------------------------------------------------
-- Description    : 
-------------------------------------------------------------------------------
-- Entity for the Tx Unit                                                    --
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

-------------------------------------------------------------------------------
-- Transmitter unit
-------------------------------------------------------------------------------
entity TxUnit is
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
end; --================== End of entity ==============================--
-------------------------------------------------------------------------------
-- Architecture for TxUnit
-------------------------------------------------------------------------------
architecture Behaviour of TxUnit is
  type TxStateType is ( TxIdle_State, Start_State, Data_State, Parity_State, Stop_State );
  -----------------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------------
  signal TxClkDel  : Std_Logic;             -- Delayed Tx Input Clock
  signal TxClkEdge : Std_Logic;             -- Tx Input Clock Edge pulse
  signal TxClkCnt  : Std_Logic_Vector(5 downto 0); -- Tx Baud Clock Counter
  signal TxBdDel   : Std_Logic;             -- Delayed Tx Baud Clock
  signal TxBdEdge  : Std_Logic;             -- Tx Baud Clock Edge pulse
  signal TxBdClk    : Std_Logic;            -- Tx Baud Clock

  signal TBuff     : Std_Logic_Vector(7 downto 0); -- transmit buffer
  signal TBufE     : Std_Logic;                    -- Transmit Buffer Empty

  signal TReg      : Std_Logic_Vector(7 downto 0); -- transmit register
  signal TxParity  : Std_logic;                    -- Parity Bit
  signal DataCnt   : Std_Logic_Vector(3 downto 0); -- Data Bit Counter
  signal TRegE     : Std_Logic;                    --  Transmit Register empty
  signal TRegEDel  : Std_Logic;                    --  Transmit Register empty
  signal TRegEEdge : Std_Logic;
  signal TxState   : TxStateType;
  signal TxDbit    : Std_Logic;
begin

  ---------------------------------------------------------------------
  -- Transmit Clock Edge Detection
  -- A falling edge will produce a one clock cycle pulse
  ---------------------------------------------------------------------
  txunit_clock_edge : process(Clk, Reset, TxClk, TxClkDel )
  begin
    if Reset = '1' then
	   TxClkDel  <= TxClk;
		TxClkEdge <= '0';
	 elsif Clk'event and Clk = '0' then
	   TxClkDel  <= TxClk;
		TxClkEdge <= TxClkDel and (not TxClk);
	 end if;
  end process;


  ---------------------------------------------------------------------
  -- Transmit Clock Divider
  -- Advance the count only on an input clock pulse
  ---------------------------------------------------------------------
  txunit_clock_divide : process(Clk, Reset, TxClkEdge, TxClkCnt )
  begin
    if Reset = '1' then
	   TxClkCnt <= "000000";
	 elsif Clk'event and Clk = '0' then
	   if TxClkEdge = '1' then 
		  TxClkCnt <= TxClkCnt + "000001";
      else
		  TxClkCnt <= TxClkCnt;
      end if; -- TxClkEdge
	 end if;	-- reset / clk
  end process;

  ---------------------------------------------------------------------
  -- Receiver Clock Selector
  -- Select output then look for rising edge
  ---------------------------------------------------------------------
  txunit_clock_select : process(Clk, Reset, BdFmt, TxClk, TxClkCnt,
                                TxBdDel, TxBdEdge )
  begin
  -- BdFmt
  -- 0 0     - Baud Clk divide by 1
  -- 0 1     - Baud Clk divide by 16
  -- 1 0     - Baud Clk divide by 64
  -- 1 1     - reset
    case BdFmt is
	 when "00" =>	  -- Div by 1
	   TxBdClk <= TxClk;
	 when "01" =>	  -- Div by 16
	   TxBdClk <= TxClkCnt(3);
	 when "10" =>	  -- Div by 64
	   TxBdClk <= TxClkCnt(5);
	 when others =>  -- reset
	   TxBdClk <= '0';
    end case;

    if Reset = '1' then
	   TxBdDel  <= TxBdClk;
		TxBdEdge <= '0';
	 elsif Clk'event and Clk = '0' then
	   TxBdDel  <= TxBdClk;
		TxBdEdge <= TxBdClk and (not TxBdDel);
	 end if;
  end process;

  ---------------------------------------------------------------------
  -- Transmit Buffer Empty Edge
  -- generate a negative edge pulse
  ---------------------------------------------------------------------
  txunit_busy : process(Clk, Reset, TRegE, TRegEDel )
  begin
     if Reset = '1' then
	      TRegEDel  <= '0';
			TRegEEdge <= '0';
     elsif Clk'event and Clk = '0' then
	    TRegEDel  <= TRegE;
		 TRegEEdge <= TregEDel and (not TRegE ); -- falling edge
     end if;
   end process;

  ---------------------------------------------------------------------
  -- Transmitter activation process
  ---------------------------------------------------------------------
  txunit_write : process(Clk, Reset, LoadD, DAIn, TBufE, TRegEEdge )
  begin
     if Reset = '1' then
           TBufE   <= '1';
			  TBuff   <= "00000000";
     elsif Clk'event and Clk = '0' then
		     if LoadD = '1' then
			    TBuff <= DAIn;
             TBufE <= '0';
			  else
			    TBuff <= TBuff;
             if (TBufE = '0') and (TRegEEdge = '1') then
				   -- Once the transmitter is started 
					-- We can flag the buffer empty again.
               TBufE <= '1';
				 else
               TBufE <= TBufE;
				 end if;
			  end if;
    end if; -- clk / reset
    TBE <= TBufE;

  end process;

  -----------------------------------------------------------------------------
  -- Implements the Tx unit
  -----------------------------------------------------------------------------
  txunit_transmit :  process(Reset, Clk, TxState, TxDbit, TBuff, TReg,
                             TxBdEdge, TxParity, DataCnt, WdFmt,
									  TBufE, TRegE )
  begin
	 if Reset = '1' then
          TxDbit   <= '1';
	       TReg     <= "00000000";
		    TxParity <= '0';
		    DataCnt  <= "0000";
          TRegE    <= '1';
		    TxState  <= TxIdle_State;
    elsif Clk'event and Clk = '0' then
      if TxBdEdge = '1' then
        case TxState is
        when TxIdle_State =>  -- TxIdle_State (also 1st or 2nd Stop bit)
          TxDbit     <= '1';
	       TReg       <= TBuff;
		    TxParity   <= '0';
		    DataCnt    <= "0000";
          TRegE      <= '1';
		    if TBufE = '0' then
             TxState <= Start_State;
	       else
             TxState <= TxIdle_State;
		    end if;

        when Start_State =>
          TxDbit   <= '0';           -- Start bit
		    TReg     <= TReg;
	       TxParity <= '0';
		    if WdFmt(2) = '0' then
		      DataCnt <= "0110";       -- 7 data + parity
	       else
            DataCnt <= "0111";       -- 8 data
	       end if;
          TRegE    <= '0';
          TxState  <= Data_State;

        when Data_State =>
          TxDbit   <= TReg(0);
          TReg     <= '1' & TReg(7 downto 1);
          TxParity <= TxParity xor TReg(0);
          TRegE    <= '0';
		    DataCnt  <= DataCnt - "0001";
		    if DataCnt = "0000" then
	         if (WdFmt(2) = '1') and (WdFmt(1) = '0') then
			     if WdFmt(0) = '0' then         -- 8 data bits
                TxState <= Stop_State;       -- 2 stops
			     else
				    TxState <= TxIdle_State;     -- 1 stop
		        end if;
		      else
			     TxState <= Parity_State;       -- parity
		      end if;
	    	 else
            TxState  <= Data_State;
		    end if;

        when Parity_State =>           -- 7/8 data + parity bit
	       if WdFmt(0) = '0' then
			    TxDbit <= not( TxParity );   -- even parity
		    else
			    TXDbit <= TxParity;          -- odd parity
	       end if;
		    Treg     <= Treg;
		    TxParity <= '0';
          TRegE    <= '0';
		    DataCnt  <= "0000";
		    if WdFmt(1) = '0' then
			   TxState <= Stop_State; -- 2 stops
		    else
			   TxState <= TxIdle_State; -- 1 stop
		    end if;

        when Stop_State => -- first stop bit
          TxDbit     <= '1';           -- 2 stop bits
	       Treg       <= Treg;
		    TxParity   <= '0';
		    DataCnt    <= "0000";
          TRegE      <= '0';
		    TxState    <= TxIdle_State;

        when others =>  -- Undefined
          TxDbit     <= TxDbit;
	       Treg       <= Treg;
		    TxParity   <= '0';
		    DataCnt    <= "0000";
          TRegE      <= TregE;
          TxState    <= TxIdle_State;

        end case; -- TxState

		else -- TxBdEdge
		  TxDbit   <= TxDbit;
	     TReg     <= TReg;
		  TxParity <= TxParity;
		  DataCnt  <= DataCnt;
        TRegE    <= TRegE;
		  TxState  <= TxState;
		end if; -- TxBdEdge
	 end if;	 -- clk / reset

	 TxDat <= TxDbit;
  end process;

end Behaviour; --=================== End of architecture ====================--