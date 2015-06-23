------------------------------------------------------------------------
-- uartcomponent.vhd
------------------------------------------------------------------------
-- Author:  Dan Pederson
--          Copyright 2004 Digilent, Inc.
------------------------------------------------------------------------
-- Description:	This file defines a UART which transfers data to and 
--				from serial and parallel information.  It requires two 
--				major processes:  receiving and transferring.  The 
--				receiving portion reads serially transmitted data, and
--				converts it into parallel data, while the transferring
--				portion reads parallel data, and transmits it as serial 
--				data.  There are three error signals provided with this 
--				UART.  They are frame error, parity error, and overwrite 
--				error signals.  This UART is configured to use an ODD 
--				parity bit at a baud rate of 9600. 
--		
------------------------------------------------------------------------
-- Revision History:
--  	07/15/04 (DanP) Created 
--		05/24/05 (DanP) Updated commenting style
--		06/06/05 (DanP) Synchronized state machines to fix timing bug		
------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-------------------------------------------------------------------------
--
--Title:	UARTcomponent entity
--
--Inputs:	7	:	RXD
--					CLK
--					DBIN
--					RDA
--					RD
--					WR
--					RST
--
--Outputs:	7	:	TXD
--					DBOUT
--					RDA
--					TBE
--					PE
--					FE
--					OE						
--
--Description:	This describes the UART component entity.  The inputs are
-- 				the Pegasus 50 MHz clock, a reset button, The RXD from 
--				the serial cable, an 8-bit data bus from the parallel 
--				port, and Read Data Available (RDA)and Transfer Buffer 
--				Empty(TBE) handshaking signals.  The outputs are the TXD 
--				signal for the serial port, an 8-bit data bus for the
--				parallel port, RDA and TBE handshaking signals, and three
--				error signals for parity, frame, and overwrite errors.
--
-------------------------------------------------------------------------
entity UARTcomponent is
	Generic (
		--@48MHz
--		BAUD_DIVIDE_G : integer := 26; 	--115200 baud
--		BAUD_RATE_G   : integer := 417

		--@26.6MHz
		BAUD_DIVIDE_G : integer := 14; 	--115200 baud
		BAUD_RATE_G   : integer := 231
	);
	Port (	
		TXD 	: out 	std_logic  	:= '1';					-- Transmitted serial data output
		RXD 	: in  	std_logic;							-- Received serial data input
		CLK 	: in  	std_logic;							-- Clock signal
		DBIN 	: in  	std_logic_vector (7 downto 0);		-- Input parallel data to be transmitted
		DBOUT 	: out 	std_logic_vector (7 downto 0);		-- Recevived parallel data output
		RDA		: inout  std_logic;							-- Read Data Available
		TBE		: out 	std_logic 	:= '1';					-- Transfer Buffer Emty
		RD		: in  	std_logic;							-- Read Strobe
		WR		: in  	std_logic;							-- Write Strobe
		PE		: out 	std_logic;							-- Parity error		
		FE		: out 	std_logic;							-- Frame error
		OE		: out 	std_logic;							-- Overwrite error
		RST		: in  	std_logic	:= '0');				-- Reset signal
						
end UARTcomponent;

architecture Behavioral of UARTcomponent is

------------------------------------------------------------------------
-- Local Type and Signal Declarations
------------------------------------------------------------------------

-------------------------------------------------------------------------
--Title:	Local Type Declarations
--
--Description:	There are two state machines used in this entity.  The
--				rstate is used to synchronize the receiving portion of 
--				the UART, and the tstate is used to synchronize the 
--				sending portion of the UART.
--
-------------------------------------------------------------------------
	type rstate is (					  
		strIdle,			
		strEightDelay,	
		strGetData,
		strWaitFor0,
		strWaitFor1,		
		strCheckStop	
	);

	type tstate is (
		sttIdle,			
		sttTransfer,	
		sttShift,	
		sttDelay,
		sttWaitWrite		
		);

-------------------------------------------------------------------------
--
--Title:  Local Signal Declarations
--
--Description:	The constants and signals used by this entity are 
--				described below:
--
--				-baudRate	:	This is the Baud Rate constant used to 
--								synchronize the Pegasus 50 MHz clock with a 
--								baud rate of 9600.  To get this number, divide 
--								50MHz by 9600.
--				-baudDivide	: 	This is the Baud Rate divider used to safely
--								read data transmitted at a baud rate of 9600.
--								It is simply the above described baudRate
--								constant divided by 16.
--
--				-rdReg		:	this is the receive holding register
--				-rdSReg		:	this is the receive shift register
--				-tfReg		:	this is the transfer holding register
--				-tfSReg		:	this is the transfer shifting register 
--				-clkDiv		:	counter used to get rClk
--				-ctr		:	used for delay times
--				-tfCtr		:	used to delay in the transfer process
--				-dataCtr	:	counts the number of read data bits
--				-parError	:	parity error bit
--				-frameError	:	frame error bit
--				-CE			:	clock enable bit for the writing latch
--				-ctRst	  	:	reset for the ctr
--				-load		:	load signal used to load the transfer shift
--								register
--				-shift		:	shift signal used to unload the transfer
--								shift register
--				-par		:	represents the parity in the transfer
--								holding register
--				-tClkRST	:	reset for the tfCtr	
--				-rShift		:	shift signal used to load the receive shift
--								register
--				-dataRST	:	reset for the dataCtr
--				-dataIncr	:	signal to increment the dataCtr
--				-tfIncr		:	signal to increment the tfCtr
--				-tDelayCtr	:	counter used to delay the transfer state 
--								machine.
--				-tDelayRst	:	reset signal for the tDelayCtr counter.
--				 
--				The following signals are used by the two state machines
--				for state control:
--				-Receive State Machine	:	strCur, strNext
--				-Transfer State Machine	:	sttCur, sttNext
--	
-------------------------------------------------------------------------

--  @26.7MHz
--	constant baudRate	:	std_logic_vector(12 downto 0) := "1 0100 0101 1000";  
--	constant baudRate	:	std_logic_vector(12 downto 0) := conv_std_logic_vector(1406,13); -- 19200
--	constant baudRate	:	std_logic_vector(12 downto 0) := conv_std_logic_vector(703,13);  -- 38400
--	constant baudRate	:	std_logic_vector(12 downto 0) := conv_std_logic_vector(469,13);  -- 57600
--   constant baudRate	:	std_logic_vector(12 downto 0) := conv_std_logic_vector(417,13);  --115200

--  @26.7MHz
--	constant baudDivide	: 	std_logic_vector(8 downto 0) 	:= conv_std_logic_vector(1,9);  -- Used for simulation
--	constant baudDivide	: 	std_logic_vector(8 downto 0) 	:= conv_std_logic_vector(88,9); -- Used for  19 200 baud
--	constant baudDivide	: 	std_logic_vector(8 downto 0) 	:= conv_std_logic_vector(44,9); -- Used for  38 400 baud
--	constant baudDivide	: 	std_logic_vector(8 downto 0) 	:= conv_std_logic_vector(29,9); -- Used for  57 600 baud
--	constant baudDivide	: 	std_logic_vector(8 downto 0) 	:= conv_std_logic_vector(26,9); -- Used for 115 200 baud

	constant baudRate	:	std_logic_vector(12 downto 0)   := conv_std_logic_vector(BAUD_RATE_G,13);  --115200
	constant baudDivide	: 	std_logic_vector(8 downto 0) 	:= conv_std_logic_vector(BAUD_DIVIDE_G-1,9); -- Used for 115 200 baud
																		     
	signal rdReg		: 	std_logic_vector(7 downto 0) 	:= "00000000";			
	signal rdSReg		: 	std_logic_vector(9 downto 0) 	:= "1111111111";		
	signal tfReg		: 	std_logic_vector(7 downto 0);								
	signal tfSReg  		: 	std_logic_vector(10 downto 0) 	:= "11111111111";		
	signal clkDiv		: 	std_logic_vector(9 downto 0)		:= "0000000000";			
	signal ctr			: 	std_logic_vector(3 downto 0)		:= "0000";			
	signal tfCtr		: 	std_logic_vector(3 downto 0)		:= "0000";																	
	signal dataCtr 		: 	std_logic_vector(3 downto 0)		:= "0000";				
	signal parError		: 	std_logic;														
	signal frameError	: 	std_logic;													
	signal CE			:	std_logic;															 		
	signal ctRst		: 	std_logic 	:= '0';
	signal load			: 	std_logic 	:= '0';
	signal shift		: 	std_logic 	:= '0';
	signal par			: 	std_logic;
   signal tClkRST		: 	std_logic 	:= '0';
	signal rShift		: 	std_logic 	:= '0';
	signal dataRST 		:	std_logic 	:= '0';
	signal dataIncr		: 	std_logic 	:= '0';
	signal tfIncr		:	std_logic	:= '0';
	signal tDelayCtr	:	std_logic_vector (12 downto 0);
	signal tDelayRst	:	std_logic := '0';

	signal strCur		:  rstate	:= strIdle; 	
	signal strNext		:  rstate;					
	signal sttCur 		:  tstate 	:= sttIdle;		
	signal sttNext 		:  tstate;						

-------------------------------------------------------------------------
-- Module Implementation
-------------------------------------------------------------------------
begin
-------------------------------------------------------------------------
--
--Title:  Initial signal definitions
--
--Description:	The following lines of code define 4 internal and 1
--				external signal.  The most significant bit of the rdSReg
--				signifies the frame error bit, so frameError is tied to
--				that signal.  The parError is high if there is a parity
--				error, so it is set equal to the inverse of rdSReg(8) 
--				XOR-ed with the data bits.  In this manner, it can 
--				determine if the parity bit found in rdSReg(8) matches 
--				the data bits.  The parallel information output is equal
-- 				to rdReg, so DBOUT is set equal to rdReg.  Likewise, the 
--				input parallel information is equal to DBIN, so tfReg is 
--				set equal to DBIN.  Because the tfSReg is used to shift
--				out transmitted data, the TXD port is set equal to the
--				first bit of tfsReg.  Finally, the par signal represents 
--				the parity of the data, so par is set to the inverse of 
--				the data bits XOR-ed together.  This UART can be changed 
--				to use EVEN parity if the "not" is omitted from the par 
--				definition.
--
-------------------------------------------------------------------------
	frameError <= not rdSReg(9);
	parError <= not ( rdSReg(8) xor (((rdSReg(0) xor rdSReg(1)) xor 
		(rdSReg(2) xor rdSReg(3))) xor ((rdSReg(4) xor rdSReg(5)) xor 
		(rdSReg(6) xor rdSReg(7)))) );
	DBOUT <= rdReg;
	tfReg <= DBIN;
 	TXD <= tfsReg(0);
	par <=  not ( ((tfReg(0) xor tfReg(1)) xor (tfReg(2) xor tfReg(3))) xor 
		((tfReg(4) xor tfReg(5)) xor (tfReg(6) xor tfReg(7))) );
-------------------------------------------------------------------------
--
--Title: Clock Divide counter 
--
--Description:	This process defines clkDiv as a signal that increments
--				with the clock up until it is either reset by ctRst, or
--				equals baudDivide.  This signal is used to define a 
--				counter called ctr that increments at the rate of the 
--				divided baud rate.
--
-------------------------------------------------------------------------
	process (CLK, clkDiv)	    								
		begin
			if (CLK = '1' and CLK'event) then
				if (clkDiv = baudDivide or ctRst = '1') then
					clkDiv <= "0000000000";
				else
					clkDiv <= clkDiv +1;
				end if;
			end if;
		end process;
-------------------------------------------------------------------------
--
--Title: Transfer delay counter 
--
--Description:	This process defines tDelayCtr as a counter that runs
--				until it equals baudRate, or until it is reset by 
--				tDelayRst.  This counter is used to measure delay times
--				when sending data out on the TXD signal.  When the 
--				counter is equal to baudRate, or is reset, it is set 
--				equal to 0.
--
-------------------------------------------------------------------------
	process (CLK, tDelayCtr)
		begin
			if (CLK = '1' and CLK'event) then
				if (tDelayCtr = baudRate or tDelayRst = '1') then
					tDelayCtr <= "0000000000000";
				else
					tDelayCtr <= tDelayCtr+1;
				end if;
			end if;
		end process;
-------------------------------------------------------------------------
--
--Title: ctr set up 
--
--Description:	This process sets up ctr, which uses clkDiv to count
--				increase at a rate needed to properly receive data in
--				from RXD.  If ctRst is strobed, the counter is reset.  If
--				clkDiv is equal to baudDivide, then ctr is incremented
--				once.  This signal is used by the receiving state machine
--				to measure delay times between RXD reads.		
--
-------------------------------------------------------------------------
	process (CLK)
		begin
			if CLK = '1' and CLK'Event then
				if ctRst = '1' then
					ctr <= "0000";
				elsif clkDiv = baudDivide then
					ctr <= ctr + 1;
				else
					ctr <= ctr;
				end if;
			end if;
		end process;
-------------------------------------------------------------------------
--
--Title: transfer counter 
--
--Description:	This process makes tfCtr increment whenever the tfIncr
--				signal is strobed high.  If the tClkRst signal is strobed
--				high, the tfCtr is reset to "0000."  This counter is used
--				to keep track of how many data bits have been 
--				transmitted.
--
-------------------------------------------------------------------------
	process (CLK, tClkRST)	 						
		begin
			if (CLK = '1' and CLK'event) then
				if tClkRST = '1' then
					tfCtr <= "0000";
				elsif tfIncr = '1' then
					tfCtr <= tfCtr +1;
				end if;
			end if;
		end process;
-------------------------------------------------------------------------
--
--Title: Error and RDA flag controller 
--
--Description: 	This process controls the error flags FE, OE, and PE, as
--				well as the Read Data Available (RDA) flag.  When CE goes
--				high, it means that data has been read into the rdSReg.
--				This process then analyzes the read data for errors, sets
--				rdReg equal to the eight data bits in rdSReg, and flags
--				RDA to indicate that new data is present in rdReg.  FE 
--				and PE are simply equal to the frameError and parError 
--				signals.  OE is flagged high if RDA is already high when 
--				CE is strobed.  This means that unread data was still in 
--				the rdReg when it was written over with the new data.	
--
-------------------------------------------------------------------------
	process (CLK, RST, RD, CE)
		begin
			if RD = '1' or RST = '1' then
				FE <= '0';
				OE <= '0';
				RDA <= '0';
				PE <= '0';
			elsif CLK = '1' and CLK'event then
				if CE = '1' then
					FE <= frameError;
					PE <= parError;
					rdReg(7 downto 0) <= rdSReg (7 downto 0);					
					if RDA = '1' then
						OE <= '1';
					else
						OE <= '0';
						RDA <= '1';
					end if; 
				end if;				
			end if;
		end process;
-------------------------------------------------------------------------
--
--Title: Receiving shift register 
--
--Description:	This process controls the receiving shift register 
--				(rdSReg).  Whenever rShift is high, implying that data 
--				needs to be shifted in, rdSReg is shifts in RXD to the 
--				most significant bit, while shifting its existing data 
--				right.
--
-------------------------------------------------------------------------
	process (CLK, rShift)
		begin
			if CLK = '1' and CLK'Event then
				if rShift = '1' then
					rdSReg <= (RXD & rdSReg(9 downto 1));
				end if;
			end if;
		end process;
-------------------------------------------------------------------------
--
--Title: Incoming Data counter 
--
--Description:	This process controls the dataCtr to keep track of 
--				shifted values into the rdSReg.  The dataCtr signal is 
--				incremented once every time dataIncr is strobed high.
--				
-------------------------------------------------------------------------

 	process (CLK, dataRST)
		begin
			if (CLK = '1' and CLK'event) then
				if dataRST = '1' then
					dataCtr <= "0000";
				elsif dataIncr = '1' then
					dataCtr <= dataCtr +1;
				end if;
			end if;
		end process;
-------------------------------------------------------------------------
--
--Title: Receiving State Machine controller 
--
--Description:	This process takes care of the Receiving state machine
--				movement.  It causes the next state to be evaluated on
--				each rising edge of CLK.  If the RST signal is strobed,
--				the state is changed to the default starting state,
-- 				which is strIdle
--
-------------------------------------------------------------------------
	process (CLK, RST)
		begin
			if CLK = '1' and CLK'Event then
				if RST = '1' then -- najj
					strCur <= strIdle;
				else
					strCur <= strNext;
				end if;
			end if;
		end process;
-------------------------------------------------------------------------
--
--Title: Receiving State Machine  
--
--Description:	This process contains all of the next state logic for the
--				Receiving state machine.
--
-------------------------------------------------------------------------				
	process (strCur, ctr, RXD, dataCtr)
		begin   
			case strCur is
-------------------------------------------------------------------------
--
--Title: strIdle state 
--
--Description:	This state is the idle and startup default stage for the
--				Receiving state machine.  The machine stays in this state
--				until the RXD signal goes low.  When this occurs, the
--				ctRst signal is strobed to reset ctr for the next state,
--				which is strEightDelay.  
--
-------------------------------------------------------------------------
				when strIdle =>
					dataIncr <= '0';
					rShift <= '0';
					dataRst <= '1';				
					CE <= '0';
					ctRst <= '1';

					if RXD = '0' then
						strNext <= strEightDelay;
					else
						strNext <= strIdle;
					end if;
-------------------------------------------------------------------------
--
--Title: strEightDelay state 
--
--Description:	This state simply delays the state machine for eight clock
--				cycles.  This is needed so that the incoming RXD data 
--				signal is read in the middle of each data emission.  This
--				ensures an accurate RXD signal reading.  ctr counts from 
--				0 to 8 to keep track of rClk cycles.  When it equals 8 
--				(1000) the next state, strWaitFor0, is loaded.  During 
--				this state, the dataRst signal is strobed high to reset 
--				the shift-in data counter (dataCtr).
--
-------------------------------------------------------------------------			
				when strEightDelay => 
					dataIncr <= '0';
					rShift <= '0';
					dataRst <= '1';
					CE <= '0';
					ctRst <= '0';

					if ctr(3 downto 0) = "1000" then
						strNext <= strWaitFor0;
					else
						strNext <= strEightDelay;
					end if;
-------------------------------------------------------------------------
--
--Title: strGetData state 
--
--Description:	In this state, the dataIncr and rShift signals are 
--				strobed high for one clock cycle.  By doing this, the 
--				rdSReg shift register shifts in RXD once, while the 
--				dataCtr is incremented by one.  This state simply 
--				captures the incoming data on RXD into the rdSReg shift 
--				register.  The next state loaded is strWaitFor0, which 
--				starts the two delay states needed between data shifts. 
--
-------------------------------------------------------------------------	
				when strGetData =>	
					CE <= '0';
					dataRst <= '0';
					ctRst <= '0';
					dataIncr <= '1';
					rShift <= '1';

					strNext <= strWaitFor0;
-------------------------------------------------------------------------
--
--Title: strWaitFor0 state 
--
--Description:	This state is a delay state, which delays the receive
--				state machine if not all of the incoming serial data has
--				not been shifted in yet.  If dataCtr does not equal 10
--				(1010), the state is stayed in until the fourth bit of
--				ctr is equal to 1.  When this happens, half of the delay
--				has been achieved, and the second delay state is loaded, 
--				which is strWaitFor1.  If dataCtr does equal 10 (1010),
--				all of the needed data has been acquired, so the 
--				strCheckStop state is loaded to check for errors and 
--				reset the receive state machine.
--
-------------------------------------------------------------------------
				when strWaitFor0 =>
					CE <= '0';
					dataRst <= '0';
					ctRst <= '0';
					dataIncr <= '0';
					rShift <= '0';

					if dataCtr = "1010" then
						strNext <= strCheckStop;
					elsif ctr(3) = '0' then
						strNext <= strWaitFor1;
					else
						strNext <= strWaitFor0;
					end if;
-------------------------------------------------------------------------
--
--Title: strEightDelay state 
--
--Description:	This state is much like strWaitFor0, except it waits for
--				the fourth bit of ctr to equal 1.  Once this occurs, the
--				strGetData state is loaded in order to shift in the next
--				data bit from RXD.  Because strWaitFor0 is the only state
--				that calls this state, no other signals need to be 
--				checked.
--
-------------------------------------------------------------------------				
				when strWaitFor1 =>
					CE <= '0';
					dataRst <= '0';
					ctRst <= '0';
					dataIncr <=	'0';
					rShift <= '0';

					if ctr(3) = '0' then
						strNext <= strWaitFor1;
					else
						strNext <= strGetData;
					end if;				
-------------------------------------------------------------------------
--
--Title: strCheckStop state 
--
--Description:	This state allows the newly acquired data to be checked
--				for errors.  The CE flag is strobed to start the
--				previously defined error checking process.  This state is
--				passed straight through to the strIdle state.
--
-------------------------------------------------------------------------			
				when strCheckStop =>
					dataIncr <= '0';
					rShift <= '0';
					dataRst <= '0';
					ctRst <= '0';
					CE <= '1';
					strNext <= strIdle;			
			end case;
		end process;
-------------------------------------------------------------------------
--
--Title: Transfer shift register controller 
--
--Description:	This process uses the load, shift, and clk signals to 
--				control the transfer shift register (tfSReg).  Once load
--				is equal to '1', the tfSReg gets a '1', the parity bit,
--				the data bits found in tfReg, and a '0'.  Under this
--				format, the shift register can be used to shift out the
--				appropriate signal to serially transfer the data.  The
--				data is shifted out of the tfSReg whenever shift = '1'. 
--
-------------------------------------------------------------------------
	process (load, shift, CLK, tfSReg)
		begin
			if CLK = '1' and CLK'Event then
				if load = '1' then
					tfSReg (10 downto 0) <= ('1' & par & tfReg(7 downto 0) &'0');
				elsif shift = '1' then			  
					tfSReg (10 downto 0) <= ('1' & tfSReg(10 downto 1));
				end if;
			end if;
		end process;
-------------------------------------------------------------------------
--
--Title: Transfer State Machine controller 
--
--Description:	This process takes care of the Transfer state machine
--				movement.  It causes the next state to be evaluated on
--				each rising edge of CLK.  If the RST signal is strobed,
--				the state is changed to the default starting state, which
--				is sttIdle.
--
-------------------------------------------------------------------------
	process (CLK, RST)
		begin
			if (CLK = '1' and CLK'Event) then
				if RST = '1' then
					sttCur <= sttIdle;
				else
					sttCur <= sttNext;
				end if;
			end if;
		end process;		
-------------------------------------------------------------------------
--
--Title: Transfer State Machine 
--
--Description:	This process controls the next state logic in the 
--				transfer state machine.  The transfer state machine 
--				controls the shift and load signals that are used to load 
--				and transmit the parallel data in a serial form.  It also 
--				controls the Transmit Buffer Empty (TBE) signal that 
--				indicates if the transmit buffer (tfSReg) is in use or 
--				not.
--
-------------------------------------------------------------------------	
	process (sttCur, tfCtr, WR, tDelayCtr)
		begin   	   
			case sttCur is			
-------------------------------------------------------------------------
--
--Title: sttIdle state 
--
--Description:	This state is the idle and startup default stage for the 
--				transfer state machine.  The state is stayed in until
--				the WR signal goes high.  Once it goes high, the 
--				sttTransfer state is loaded.  The load and shift signals
--				are held low in the sttIdle state, while the TBE signal
--				is held high to indicate that the transmit buffer is not
--				currently in use.  Once the idle state is left, the TBE
--				signal is held low to indicate that the transfer state
--				machine is using the transmit buffer.
--
-------------------------------------------------------------------------		
				when sttIdle =>
					TBE <= '1';				
					tClkRST <= '0';
					tfIncr <= '0';
					shift <= '0';
					load <= '0';
					tDelayRst <= '1';

					if WR = '0' then
						sttNext <= sttIdle;
					else
						sttNext <= sttTransfer;
					end if;	
-------------------------------------------------------------------------
--
--Title: sttTransfer state
--
--Description:	This state sets the load, tClkRST, and tDelayRst signals 
--				high, while setting the TBE signal low.  The load signal 
--				is set high to load the transfer shift register with the 
--				appropriate data, while the tClkRST and tDelayRst signals 
--				are strobed to reset the tfCtr and tDelayCtr.  The next
--				state loaded is the sttDelay state.
--			
-------------------------------------------------------------------------
				when sttTransfer =>
					TBE <= '0';
					shift <= '0';
					load <= '1';
					tClkRST <= '1';
					tfIncr <= '0';
					tDelayRst <= '1';
							
					sttNext <= sttDelay;			
-------------------------------------------------------------------------
--
--Title: sttShift state 
--
--Description:	This state strobes the shift and tfIncr signals high, and
--				checks the tfCtr to see if enough data has been 
--				transmitted.  By strobing the shift and tfIncr signals
--				high, the tfSReg is shifted, and the tfCtr is incremented
--				once.  If tfCtr does not equal 9 (1001), then not all of
--				the bits have been transmitted, so the next state loaded 
--				is the sttDelay state.  If tfCtr does equal 9, the final 
--				state, sttWaitWrite, is loaded.
--
-------------------------------------------------------------------------
				when sttShift =>
					TBE <= '0';
					shift <= '1';
					load <= '0';
					tfIncr <= '1';
					tClkRST <= '0';
					tDelayRst <= '0';

					if tfCtr = "1010" then
						sttNext <= sttWaitWrite;
					else
						sttNext <= sttDelay;
					end if;
-------------------------------------------------------------------------
--
--Title: sttDelay state
--
--Description:	This state is responsible for delaying the transfer state
--				machine between transmissions.  All signals are held low
--				while the tDelayCtr is tested.  Once tDelayCtr is equal 
--				to baudRate, the sttShift state is loaded.  
--			
-------------------------------------------------------------------------
				when sttDelay =>
					TBE <= '0';
					shift <= '0';
					load <= '0';
					tClkRst <= '0';
					tfIncr <= '0';
					tDelayRst <= '0';

					if tDelayCtr = baudRate then
						sttNext <= sttShift;
					else
						sttNext <= sttDelay;
					end if;
-------------------------------------------------------------------------
--
--Title: sttWaitWrite state
--
--Description:	This state checks to make sure that the initial WR signal
--				that triggered the transfer state machine has been 
--				brought back low.  Without this state, a write signal 
--				that is held high for a long time will result in multiple 
--				transmissions.  Once the WR signal is low, the sttIdle 
--				state is loaded to reset the transfer state machine.
--			
-------------------------------------------------------------------------					
				when sttWaitWrite =>
					TBE <= '0';
					shift <= '0';
					load <= '0';
					tClkRst <= '0';
					tfIncr <= '0';
					tDelayRst <= '0';
					
					if WR = '1' then
						sttNext <= sttWaitWrite;
					else
						sttNext <= sttIdle;
					end if; 
			end case;
		end process;						 				
end Behavioral;
