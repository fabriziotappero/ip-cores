-- SDHC-SC-Core
-- Secure Digital High Capacity Self Configuring Core
-- 
-- (C) Copyright 2010, Rainer Kastl
-- All rights reserved.
-- 
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
--     * Redistributions of source code must retain the above copyright
--       notice, this list of conditions and the following disclaimer.
--     * Redistributions in binary form must reproduce the above copyright
--       notice, this list of conditions and the following disclaimer in the
--       documentation and/or other materials provided with the distribution.
--     * Neither the name of the <organization> nor the
--       names of its contributors may be used to endorse or promote products
--       derived from this software without specific prior written permission.
-- 
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS  "AS IS" AND
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-- 
-- File        : SdData-Rtl-a.vhdl
-- Owner       : Rainer Kastl
-- Description : FSM for sending and receiving data via the SD Bus
-- Links       : SD Spec 2.00
-- 

architecture Rtl of SdData is

	type aState is (idle, send, receive, crcstatus, checkbusy); -- overall states
	type aRegion is (startbit, data, crc, endbit); -- regions in send and receive state
	subtype aCounter is unsigned(LogDualis(512*8)-1 downto 0); -- bit counter

	subtype aCrcStatus is std_ulogic_vector(2 downto 0);

	-- all registers
	type aReg is record
		State   : aState;
		Region  : aRegion;
		Counter : aCounter;

		Mode : aSdDataBusMode; -- standard or wide SD mode

		Word        : aWord; -- temporary save for data to write to the read fifo
		WordInvalid : std_ulogic; -- after starting receiving we have to wait for the word to be valid before it can be written to the read fifo

		-- outputs
		Data          : aoSdData;
		Controller    : aSdDataToController;
		ReadWriteFifo : aoReadFifo;
		WriteReadFifo : aoWriteFifo;
		DisableSdClk  : std_ulogic;
		CrcStatus     : aCrcStatus;
	end record aReg;

	-- default value for registers
	constant cDefaultReg : aReg := (
	State         => idle,
	Region        => startbit,
	Counter       => (others => '0'),
	Mode          => standard,
	WordInvalid   => cInactivated,
	Word          => (others => '0'),
	Data          => cDefaultSdData,
	Controller    => cDefaultSdDataToController,
	ReadWriteFifo => cDefaultoReadFifo,
	WriteReadFifo => cDefaultoWriteFifo,
	DisableSdClk  => cInactivated,
	CrcStatus     => (others => '0'));

	type aCrcOut is record
		DataIn  : std_ulogic;
		Data    : std_ulogic_vector(3 downto 0);
	end record aCrcOut;

	constant cDefaultCrcOut : aCrcOut := (
	DataIn => cInactivated,
	Data   => (others       => '0'));

	type aCrcIn is record
		Correct : std_ulogic_vector(3 downto 0);
		Serial  : std_ulogic_vector(3 downto 0);
	end record aCrcIn;

	signal CrcIn     : aCrcIn;
	signal CrcOut    : aCrcOut;
	signal CrcDataIn : std_ulogic_vector(3 downto 0);
	signal R, NextR  : aReg;

	-- aliases for bits, bytes and words from the bit counter
	alias RBitC is R.Counter(LogDualis(8)-1 downto 0);
	alias RByteC is R.Counter(LogDualis(4)+LogDualis(8)-1 downto LogDualis(8));
	alias RWordC is R.Counter(R.Counter'high downto LogDualis(4)+LogDualis(8));
	alias RBitInWordC is R.Counter(LogDualis(32)-1 downto 0);

begin

	-- registered outputs
	oData               <= R.Data;
	oSdDataToController <= R.Controller;
	oReadWriteFifo      <= R.ReadWriteFifo;
	oWriteReadFifo      <= R.WriteReadFifo;
	oDisableSdClk       <= R.DisableSdClk;


	Regs : process (iClk)
	begin
		-- clock event
		if (iClk'event and iClk = cActivated) then
			if (iRstSync = cActivated) then
				R <= cDefaultReg;
			else
				-- synchronous enable
				if (iStrobe = cActivated) then
					R <= NextR;
				end if;

				-- rdreq and wrreq have to be exactly one clock cycle wide
				R.ReadWriteFifo.rdreq <= NextR.ReadWriteFifo.rdreq and iStrobe;
				R.WriteReadFifo.wrreq <= NextR.WriteReadFifo.wrreq and iStrobe;

				-- Clock has to be disabled before the next strobe is generated
				R.DisableSdClk        <= NextR.DisableSdClk;
			end if;
		end if;
	end process Regs;

	-- Calculate the next state and output
	Comb : process (iData, iSdDataFromController, CrcIn, iReadWriteFifo, iWriteReadFifo, R)

		--------------------------------------------------------------------------------
		-- Handle accessing the fifo
		--------------------------------------------------------------------------------
		procedure HandleFifoAccess (signal status : in std_ulogic; signal req : out std_ulogic) is
		begin
			if (status = cActivated) then
				-- stop data transfer to card and wait for a change of the fifo status
				report "Fifo not ready, waiting" severity note;

				NextR.DisableSdClk <= cActivated;
				NextR.Counter      <= R.Counter;
				req                <= cInactivated;
			else
				-- enable request and continue transfer with the sd card
				NextR.DisableSdClk <= cInactivated;
				req                <= cActivated;
			end if;
		end procedure HandleFifoAccess;

		--------------------------------------------------------------------------------
		-- Set crc outputs so data is shifted in
		--------------------------------------------------------------------------------
		procedure ShiftIntoCrc (constant data : in aSdData) is
		begin
			CrcOut.Data   <= data;
			CrcOut.DataIn <= cActivated;
		end procedure ShiftIntoCrc;

		--------------------------------------------------------------------------------
		-- Send data to card and calculate crc
		--------------------------------------------------------------------------------
		procedure SendBitsAndShiftIntoCrc (constant data : in aSdData) is
		begin
			ShiftIntoCrc(data);
			NextR.Data.Data <= data;
		end procedure SendBitsAndShiftIntoCrc;

		--------------------------------------------------------------------------------
		-- Calculate the next counter and region
		-- Handles loading next data from fifo or writing data to fifo as well
		--------------------------------------------------------------------------------
		procedure CalcNextAndHandleData (constant send : boolean) is
			-- End and decrement values for standard mode
			variable BitEnd : integer := 0;
			variable BitDec : integer := 1;
		begin

			-- reset variables if wide mode is used
			if R.Mode = wide then
				BitEnd := 3;
				BitDec := 4;
			end if;

			if (RBitC = BitEnd) then
				-- Byte finished, switch to next byte starting with MSBit
				NextR.Counter <= R.Counter + (16 - BitDec);

				if (RByteC = 3) then
					-- Word finished
					NextR.WordInvalid  <= cInactivated; -- received words are no longer invalid

					if (RWordC = 127) then
						-- whole block finished, send crc next
						NextR.Region  <= crc;
						NextR.Counter <= to_unsigned(0, aCounter'length);

					else
						if (send = true) then
							-- save next word to send from fifo
							NextR.Word <= iReadWriteFifo.q;
						end if;
					end if;
				end if;
			else
				NextR.Counter <= R.Counter - BitDec; -- switch to next bits (MSBit to LSBit)
			end if;

			if (send = true) then
				if ((RBitC = BitEnd + BitDec and RByteC = 3 and RWordC < 127)) then
					-- current word almost sent, request next word to send from fifo
					HandleFifoAccess(iReadWriteFifo.rdempty, NextR.ReadWriteFifo.rdreq);

				end if;
			else
				if (RByteC = 0 and RBitC = 7 and R.WordInvalid = cInactivated and iSdDataFromController.DisableRb = cInactivated) then
					-- received word is valid, save it to ram
					NextR.WriteReadFifo.data <= R.Word;
					HandleFifoAccess(iWriteReadFifo.wrfull, NextR.WriteReadFifo.wrreq);
				end if;
			end if;
		end procedure CalcNextAndHandleData;

		--------------------------------------------------------------------------------
		-- Calculate the bit address in widewidth mode
		--------------------------------------------------------------------------------
		impure
		function IsBitAddrInRangeWideWidth (constant addr : in natural) return boolean is
			variable curHighAddr : integer;
		begin
			-- calculate current address (of the high bit in case of wide mode)
			-- widewidth receiving counts from an offset to 4096
			-- and the bit counter is reversed
			curHighAddr := (127 - to_integer(RWordC)) * 32 + (3 - to_integer(RByteC)) * 8 + to_integer(RBitC);

			if (R.Mode = standard) then
				return curHighAddr = addr;
			else
				return curHighAddr >= addr and curHighAddr - 3 <= addr;
			end if;
		end function IsBitAddrInRangeWideWidth;

		--------------------------------------------------------------------------------
		-- Get specific bit from data vector
		--------------------------------------------------------------------------------
		impure
		function GetBitFromData (constant addr : in natural) return std_ulogic is
		begin
			if (R.Mode = standard) then
				return iData.Data(0);
			else
				return iData.Data(addr mod 4);
			end if;
		end function GetBitFromData;

		variable temp : std_ulogic_vector(3 downto 0) := "0000";

	begin

		-- default assignments
		NextR                                         <= R;
		NextR.Data.En                                 <= (others => cInactivated);
		NextR.Controller                              <= cDefaultSdDataToController;
		NextR.Controller.WideMode                     <= R.Controller.WideMode;
		NextR.Controller.SpeedBits.HighSpeedSupported <= R.Controller.SpeedBits.HighSpeedSupported;
		NextR.Controller.SpeedBits.SwitchFunctionOK   <= R.Controller.SpeedBits.SwitchFunctionOK;
		NextR.ReadWriteFifo                           <= cDefaultoReadFifo;
		NextR.WriteReadFifo                           <= cDefaultoWriteFifo;
		CrcOut                                        <= cDefaultCrcOut;

		case R.State is
			when idle => 
				-- check if card signals that it is busy (the controller has to enable this check)
				if (iSdDataFromController.CheckBusy = cActivated) then
					NextR.State <= crcstatus;
					NextR.Region <= startbit;
					NextR.Counter <= (others => '0');

				elsif (R.Mode = wide and iData.Data = cSdStartBits) or (R.Mode = standard and iData.Data(0) = cSdStartBit) then
					-- start receiving
					NextR.Region      <= data;
					NextR.State       <= receive;
					NextR.Counter     <= to_unsigned(7,aCounter'length);
					NextR.WordInvalid <= cActivated;

					-- which kind of response is expected?
					if (iSdDataFromController.DataMode = widewidth) then
						if (iSdDataFromController.ExpectBits = ScrBits) then
							NextR.Counter <= to_unsigned(cScrBitsCount, aCounter'length);
						elsif (iSdDataFromController.ExpectBits = SwitchFunctionBits) then 
							NextR.Counter <= to_unsigned(cSwitchFunctionBitsCount, aCounter'length);
						end if;
					end if;

				elsif (iSdDataFromController.Valid = cActivated) then
					-- sending requested by controller

					case iReadWriteFifo.rdempty is
						when cActivated => 
							-- no data is available to send -> stall
							report "Fifo empty, waiting for data" severity note;
							NextR.DisableSdClk <= cActivated;

						when cInactivated => 
							-- data is available, start sending
							NextR.State               <= send;
							NextR.Region              <= startbit;
							NextR.ReadWriteFifo.rdreq <= cActivated;
							NextR.DisableSdClk        <= cInactivated;
							NextR.Counter             <= to_unsigned(7, aCounter'length);

						when others => 
							report "rdempty invalid" severity error;
					end case;
				else
					-- switch between standard and wide mode only if nothing else is going on
					NextR.Mode <= iSdDataFromController.Mode; 
				end if;

			when crcstatus =>		
				case R.Region is
					when startbit => 
						if (iData.Data(0) = cSdStartBit) then
							NextR.Region <= data;
						end if;

					when data => 
						NextR.CrcStatus(to_integer(R.Counter)) <= iData.Data(0);
						NextR.Counter <= R.Counter + 1;

						if (R.Counter = 2) then
							NextR.Region <= endbit;
						end if;

					when endbit => 
						if (R.CrcStatus /= "010") then
							NextR.Controller.Err <= cActivated;
							NextR.State <= idle;
						else
							NextR.State <= checkbusy;
						end if;
					when others => 
						report "Invalid state reached" severity error;
				end case;

			when checkbusy => 
				NextR.Controller.Busy <= cActivated;

				if (iData.Data(0) = cActivated) then
					NextR.Controller.Valid <= cActivated;
					NextR.State <= idle;
				end if;

			when send =>

				-- Handle the data enable signal
				case R.Mode is
					when wide => 
						NextR.Data.En <= (others => cActivated);

					when standard => 
						NextR.Data.En <= "0001";

					when others => 
						report "Invalid SDData mode" severity error;
						NextR.Data.En <= (others => 'X');
				end case;

				case R.Region is
					when startbit => 
						SendBitsAndShiftIntoCrc(cSdStartBits);
						NextR.Region <= data;

						-- save data to send from fifo
						NextR.Word <= iReadWriteFifo.q;

					when data => 
						case R.Mode is
							when wide => 
								for i in 0 to 3 loop
									temp(3 - i) := R.Word(to_integer(RBitInWordC) - i);
								end loop;

							when standard => 
								temp := "---" & R.Word(to_integer(RBitInWordC));

							when others => 
								temp := "XXXX";
						end case;

						SendBitsAndShiftIntoCrc(temp);
						CalcNextAndHandleData(true);							

					when crc => 
						NextR.Data.Data <= CrcIn.Serial;

						if (R.Counter = 15) then
						-- all crc bits sent
							NextR.Counter        <= to_unsigned(0, aCounter'length);
							NextR.Region         <= endbit;
							NextR.Controller.Ack <= cActivated;

						else
							NextR.Counter <= R.Counter + 1;
						end if;

					when endbit => 
						NextR.Data.Data <= cSdEndBits;
						NextR.State     <= idle;

					when others => 
						report "Region not handled" severity error;
				end case;	

			when receive => 
				case R.Region is
					when data => 
						-- save received data to temporary word register
						case R.Mode is
							when standard => 
								NextR.Word(to_integer(RBitInWordC)) <= iData.Data(0);

							when wide => 
								for i in 0 to 3 loop
									NextR.Word(to_integer(RBitInWordC) - i) <= iData.Data(3 - i);
								end loop;

							when others => 
								report "Unhandled mode" severity error;
						end case;	

						ShiftIntoCrc(std_ulogic_vector(iData.Data));
						CalcNextAndHandleData(false);

						-- check responses 
						if (iSdDataFromController.DataMode = widewidth) then
							if (iSdDataFromController.ExpectBits = ScrBits) then
								if (IsBitAddrInRangeWideWidth(cWideModeBitAddr)) then
									NextR.Controller.WideMode <= GetBitFromData(cWideModeBitAddr);
								end if;
							end if;

							if (iSdDataFromController.ExpectBits = SwitchFunctionBits) then
								if (IsBitAddrInRangeWideWidth(cHighSpeedBitAddr)) then
									NextR.Controller.SpeedBits.HighSpeedSupported <= GetBitFromData(cHighSpeedBitAddr);
								elsif (IsBitAddrInRangeWideWidth(cSwitchFunctionBitLowAddr)) then
									NextR.Controller.SpeedBits.SwitchFunctionOK <= iData.Data;
								end if;
							end if;
						end if;

					when crc =>
						-- save last word to ram
						ShiftIntoCrc(std_ulogic_vector(iData.Data));

						if (R.Counter = 15) then
							-- all 16 crc bits received
							NextR.Region <= endbit;
						else
							NextR.Counter <= R.Counter + 1;

							if (R.Counter = 0 and iSdDataFromController.DisableRb = cInactivated) then
								HandleFifoAccess(iWriteReadFifo.wrfull, NextR.WriteReadFifo.wrreq);
								NextR.WriteReadFifo.data <= R.Word;
							end if;
						end if;

					when endbit => 
						-- in standard mode all unused crcs are correct, because no data was shifted in
						if (CrcIn.Correct = "1111") then 
							NextR.Controller.Valid <= cActivated;
						else
							NextR.Controller.Err <= cActivated;
						end if;

						NextR.Region <= startbit;
						NextR.State  <= idle;

					when others => 
						report "Region not handled" severity error;
				end case;

			when others => 
				report "State not handled" severity error;
		end case;

	end process Comb;

	CrcDataIn <= (others => CrcOut.DataIn) when R.Mode = wide else "000" & CrcOut.DataIn;

	crcs: for idx in 3 downto 0 generate

		CRC_inst : entity work.Crc
		generic map (
			gPolynom => crc16
		)
		port map (
			iClk         => iClk,
			iRstSync     => iRstSync,
			iStrobe      => iStrobe,
			iClear		 => cInactivated,
			iDataIn      => CrcDataIn(idx),
			iData        => CrcOut.Data(idx),
			oIsCorrect   => CrcIn.Correct(idx),
			oSerial      => CrcIn.Serial(idx)
		);

	end generate crcs;

end architecture Rtl;

