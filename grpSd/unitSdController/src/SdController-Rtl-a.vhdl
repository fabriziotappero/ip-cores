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
-- File        : SdController-Rtl-a.vhdl
-- Owner       : Rainer Kastl
-- Description : Main FSM controlling Cmd and Data FSMs, communicates with Wb
-- Links       : 
-- 

architecture Rtl of SdController is

	type aSdControllerState is (startup, init, config, requestnewoperation, idle, invalidCard, read, write);
	type aCmdRegion is (CMD0, CMD8, ACMD41, CMD2, CMD3, SelectCard, CheckBusWidth, SetBusWidth, CheckSpeed, ChangeSpeed, GetStatus);
	type aRegion is (idle, send, response, waitstate, senddata, receivedata, checkbusy, waitstatedata);

	subtype aCounter is natural range 0 to (512/32)-1;

	constant cDefaultToSdCmd : aSdCmdFromController := (
	(id       => (others        => '0'),
	arg       => (others        => '0')),
	Valid     => cInactivated,
	ExpectCID => cInactivated,
	CheckCrc  => cActivated);

	type aSdControllerReg is record
		State          : aSdControllerState;
		CmdRegion      : aCmdRegion;
		Region         : aRegion;
		Counter        : aCounter;
		SendCMD55      : std_ulogic;
		SentCMD55      : std_ulogic;
		HCS            : std_ulogic;
		CCS            : std_ulogic;
		RCA            : aSdRCA;
		CardStatus     : aSdCardStatus;
		ToSdCmd        : aSdCmdFromController;
		ToSdData       : aSdDataFromController;
		ToDataRam      : aSdControllerToRam;
		ToSdWbSlave    : aSdControllerToSdWbSlave;
		HighSpeed      : std_ulogic;
		OperationBlock : aOperationBlock;
		LedBank		   : std_ulogic_vector(7 downto 0);
	end record aSdControllerReg;

	constant cDefaultSdControllerReg : aSdControllerReg := (
	State          => startup,
	CmdRegion      => CMD0,
	Region         => idle,
	Counter        => 0,
	SendCMD55      => cInactivated,
	SentCMD55      => cInactivated,
	HCS            => cActivated,
	CCS            => cInactivated,
	RCA            => cDefaultRCA,
	CardStatus     => cDefaultSdCardStatus,
	ToSdCmd        => cDefaultToSdCmd,
	ToSdData       => cDefaultSdDataFromController,
	ToDataRam      => cDefaultSdControllerToRam,
	ToSdWbSlave    => cDefaultSdControllerToSdWbSlave,
	HighSpeed      => cInactivated,
	OperationBlock => cDefaultOperationBlock,
	LedBank        => (others => '0'));

	signal R, NextR       : aSdControllerReg;

	constant cReadTimeoutNat    : natural := gClkFrequency / (1 sec / gReadTimeout) - 1;
	constant cWriteTimeoutNat   : natural := gClkFrequency / (1 sec / gWriteTimeout) - 1;
	constant cNcrTimeoutNatLow  : natural := gClkFrequency / (1 sec / (1 sec / 25E6 * 8)) - 1;
	constant cNcrTimeoutNatHigh : natural := gClkFrequency / (1 sec / (1 sec / 50E6 * 8)) - 1;
	constant cStartupTimeoutNat : natural := gClkFrequency / (1 sec / gStartupTimeout) - 1;

	constant cMaxTimeoutBitWidth : natural := LogDualis(cWriteTimeoutNat);
	subtype aTimeoutValue is unsigned(cMaxTimeoutBitWidth - 1 downto 0);

	constant cNcrTimeoutLow  : aTimeoutValue := to_unsigned(cNcrTimeoutNatLow, aTimeoutValue'length);
	constant cNcrTimeoutHigh : aTimeoutValue := to_unsigned(cNcrTimeoutNatHigh, aTimeoutValue'length);
	constant cStartupTimeout : aTimeoutValue := to_unsigned(cStartupTimeoutNat, aTimeoutValue'length);
	constant cReadTimeout    : aTimeoutValue := to_unsigned(cReadTimeoutNat, aTimeoutValue'length);
	constant cWriteTimeout   : aTimeoutValue := to_unsigned(cWriteTimeoutNat, aTimeoutValue'length);

	signal TimeoutEnable  : std_ulogic;
	signal TimeoutDisable : std_ulogic;
	signal Timeout        : std_ulogic;
	signal TimeoutMax     : unsigned(cMaxTimeoutBitWidth - 1 downto 0);
	
begin

	oSdCmd     <= R.ToSdCmd;
	oSdData    <= R.ToSdData;
	oSdWbSlave <= R.ToSdWbSlave;
	oHighSpeed <= R.HighSpeed;
	oLedBank   <= R.LedBank;

	Regs : process (iClk, iRstSync)
	begin
		if (iClk'event and iClk = cActivated) then
			if (iRstSync = cActivated) then
				R <= cDefaultSdControllerReg;
			else
				R <= NextR;
			end if;
		end if;
	end process Regs;

	Comb : process (iSdCmd, iSdData, iSdWbSlave, Timeout, R)
		variable ocr           : aSdRegOCR;
		variable arg           : aSdCmdArg;
		variable NextRegion    : aRegion;
		variable NextCmdRegion : aCmdRegion;
		variable NextState     : aSdControllerState;

		procedure EnableNcrTimeout is
		begin
			TimeoutEnable <= cActivated;

			if (R.HighSpeed = cInactivated) then
				TimeoutMax <= cNcrTimeoutLow;
			else
				TimeoutMax <= cNcrTimeoutHigh;
			end if;
		end procedure EnableNcrTimeout;

	begin
		-- default assignments
		NextR          <= R;
		NextR.ToSdCmd  <= cDefaultToSdCmd;
		TimeoutEnable  <= cInactivated;
		TimeoutDisable <= cInactivated;
		TimeoutMax     <= to_unsigned(0, TimeoutMax'length);
		NextRegion     := R.Region;
		NextCmdRegion  := R.CmdRegion;
		NextState      := R.State;

		case R.State is
			when startup =>
				TimeoutEnable <= cActivated;
				TimeoutMax    <= cStartupTimeout;

				if (Timeout = cActivated) then
					TimeoutDisable  <= cActivated;
					NextR.State     <= init;
					NextR.CmdRegion <= CMD0;
					NextR.Region    <= send;
				end if;

			when init => 
				case R.CmdRegion is
					when CMD0 => 
						case R.Region is
							when send => 
								NextR.ToSdCmd.Content.id <= cSdCmdGoIdleState;
								NextR.CardStatus         <= cDefaultSdCardStatus;
								NextRegion               := waitstate;

							when waitstate => 
								NextRegion    := send;
								NextCmdRegion := CMD8;

							when others => 
								report "SdController: Unhandled state" severity error;
						end case;

					when CMD8 => 
						case R.Region is
							when send => 
								NextR.ToSdCmd.Content.id  <= cSdCmdSendIfCond;
								NextR.ToSdCmd.Content.arg <= cSdArgVoltage;
								NextRegion                := response;

							when response => 
								if (iSdCmd.Valid = cActivated) then
									if (iSdCmd.Content.id = cSdCmdSendIfCond and iSdCmd.Content.arg = cSdArgVoltage) then
										NextR.Region <= waitstate;
										NextR.HCS    <= cActivated;

									else
										NextR.State <= invalidCard;
									end if;
								elsif (Timeout = cActivated) then
									NextR.HCS       <= cInactivated;
									NextR.CmdRegion <= ACMD41;
									NextR.Region    <= send;
									NextR.SendCMD55 <= cActivated;
								end if;

							when waitstate => 
								NextCmdRegion   := ACMD41;
								NextRegion      := send;
								NextR.SendCMD55 <= cActivated;

							when others => 
								report "SdController: Unhandled state" severity error;
						end case;

					when ACMD41 => 
						if (R.SendCMD55 = cInactivated) then
							case R.Region is
								when send => 
									ocr.nBusy                 := '0';
									ocr.ccs                   := R.HCS;
									ocr.voltagewindow         := cVoltageWindow;
									NextR.ToSdCmd.Content.id  <= cSdCmdACMD41;
									NextR.ToSdCmd.Content.arg <= OCRToArg(ocr);
									NextRegion                := response;

								when response => 
									NextR.ToSdCmd.CheckCrc <= cInactivated;

									if (iSdCmd.Valid = cActivated) then
										NextR.CmdRegion <= CMD8;
										NextR.Region    <= waitstate;

										if (iSdCmd.Content.id = cSdR3Id) then
											ocr := ArgToOcr(iSdCmd.Content.arg);

											if (ocr.nBusy = cnInactivated) then
												if (ocr.voltagewindow /= cVoltageWindow) then
													NextR.State <= invalidCard;
												else
													NextR.CCS       <= ocr.ccs;
													NextR.CmdRegion <= ACMD41;
													NextR.Region    <= waitstate;
												end if;
											end if;
										end if;
									elsif (Timeout = cActivated) then
										NextR.State <= invalidCard;
									end if;

								when waitstate => 
									NextCmdRegion := CMD2;
									NextRegion    := send;

								when others => 
									report "SdController: Unhandled state" severity error;
							end case;
						end if;

					when CMD2 => 
						case R.Region is
							when send => 
								NextR.ToSdCmd.Content.id <= cSdCmdAllSendCID;
								NextR.ToSdCmd.Valid      <= cActivated;

								NextRegion := response;

							when response => 
								NextR.ToSdCmd.ExpectCID <= cActivated;

								if (iSdCmd.Valid = cActivated) then
									NextR.State    <= invalidCard;

									if (iSdCmd.Content.id = cSdR2Id) then 
										NextR.State     <= init;
										NextR.Region    <= waitstate;
									end if;
								elsif (Timeout = cActivated) then
									NextR.State <= invalidCard;
								end if;

							when waitstate => 
								NextCmdRegion := CMD3;
								NextRegion    := send;

							when others => 
								report "SdController: Unhandled state" severity error;
						end case;

					when CMD3 => 
						case R.Region is
							when send => 
								NextR.ToSdCmd.Content.id <= cSdCmdSendRelAdr;
								NextR.ToSdCmd.Valid      <= cActivated;
								NextRegion               := response;

							when response => 
								if (iSdCmd.Valid = cActivated) then
									if (iSdCmd.Content.id = cSdCmdSendRelAdr) then
										NextR.RCA    <= iSdCmd.Content.arg(31 downto 16);
										NextR.Region <= waitstate;
									end if;
								elsif (Timeout = cActivated) then
									NextR.State <= invalidCard;
								end if;

							when waitstate => 
								NextState     := config;
								NextCmdRegion := SelectCard;
								NextRegion    := send;

							when others => 
								report "SdController: Unhandled region" severity error;
						end case;

					when others => 
						report "SdController: Unhandled CmdRegion" severity error;
				end case;

			when config =>
				case R.CmdRegion is
					when SelectCard => 
						case R.Region is
							when send => 
								NextR.ToSdCmd.Content.id  <= cSdCmdSelCard;
								NextR.ToSdCmd.Content.arg <= R.RCA & X"0000";
								NextRegion                := response;

							when response => -- Response R1b: with busy!
								if (iSdCmd.Valid = cActivated) then
									if (iSdCmd.Content.id = cSdCmdSelCard) then
										NextR.CardStatus <= iSdCmd.Content.arg;

										if (iSdCmd.Content.arg(cSdStatusReadyForDataBit) = cActivated) then
											NextR.Region <= waitstatedata;
										else
											NextR.Region <= waitstate;
										end if;

									else
										NextR.State <= invalidCard;
									end if;

								elsif (Timeout = cActivated) then
									NextR.State <= invalidCard;
								end if;

							when waitstate => 
								NextRegion := checkbusy;

							when waitstatedata => 
								NextR.SendCMD55 <= cActivated;
								NextCmdRegion   := CheckBusWidth;
								NextRegion      := send;

							when others => 
								report "Unhandled Region" severity error;
						end case;

					when CheckBusWidth => 
						if (R.SendCMD55 = cInactivated) then
							NextR.ToSdData.DataMode <= widewidth;
							NextR.ToSdData.ExpectBits <= ScrBits;

							case R.Region is
								when send => 
									NextR.ToSdCmd.Content.id  <= cSdCmdSendSCR;
									NextR.ToSdCmd.Content.arg <= (others => '0'); -- stuff bits
									NextRegion                := response;

								when response => 
									if (iSdCmd.Valid = cActivated) then
										if (iSdCmd.Content.id = cSdCmdSendSCR) then
											NextR.CardStatus <= iSdCmd.Content.arg;
											NextR.Region     <= receivedata;
											TimeoutDisable   <= cActivated;

										else
											NextR.State <= invalidCard;
										end if;
									elsif (Timeout = cActivated) then
										NextR.State <= invalidCard;
									end if;

								when receivedata => 
									null;

								when waitstatedata => 
									NextRegion           := send;

									if (Timeout = cActivated) then
										if (iSdData.WideMode = cActivated) then
											NextCmdRegion   := SetBusWidth;
											NextR.SendCMD55 <= cActivated;

										else 
											NextCmdRegion := CheckSpeed;
										end if;
									end if;

								when others => 
									report "Unhandled region" severity error;
							end case;
						end if;

					when SetBusWidth => 
						if (R.SendCMD55 = cInactivated) then
							case R.Region is
								when send => 
									NextR.ToSdCmd.Content.id              <= cSdCmdSetBusWidth;
									NextR.ToSdCmd.Content.arg(1 downto 0) <= cSdWideBusWidth;
									NextRegion                            := response;

								when response => 
									if (iSdCmd.Valid = cActivated) then
										if (iSdCmd.Content.id = cSdCmdSetBusWidth) then
											NextR.CardStatus <= iSdCmd.Content.arg;
											NextR.Region <= waitstate;

										else
											NextR.State <= invalidCard;
										end if;
									elsif (Timeout = cActivated) then
										NextR.State <= invalidCard;
									end if;

									when waitstate => 
									NextR.ToSdData.Mode <= wide;
									-- NextR.LedBank(4) <= cActivated;

									if gHighSpeedMode = true then

										NextRegion          := send;
										NextCmdRegion       := CheckSpeed;

									else

										NextState := idle;

									end if;

								when others => 
									report "Unhandled region" severity error;
							end case;
						end if;

					when CheckSpeed => 
						NextR.ToSdData.DataMode   <= widewidth;
						NextR.ToSdData.ExpectBits <= SwitchFunctionBits;

						case R.Region is
							when send => 
								NextR.ToSdCmd.Content.id  <= cSdCmdSwitchFunction;
								NextR.ToSdCmd.Content.arg <= cSdCmdCheckSpeedSupport;
								NextRegion                := response;

							when response => 
								if (iSdCmd.Valid = cActivated) then
									if (iSdCmd.Content.id = cSdCmdSwitchFunction) then
										NextR.CardStatus <= iSdCmd.Content.arg;
										NextR.Region     <= receivedata;

									else
										NextR.State <= invalidCard;
									end if;
								elsif (Timeout = cActivated) then
									NextR.State <= invalidCard;
								end if;

							when receivedata => 
								null;

							when waitstatedata => 
								if (Timeout = cActivated) then
									-- check if high speed mode is supported
									if (iSdData.SpeedBits.HighSpeedSupported = cActivated and
									iSdData.SpeedBits.SwitchFunctionOK = X"1") then
										NextRegion    := send;
										NextCmdRegion := ChangeSpeed;
									else
										NextRegion := idle;
										NextState  := requestnewoperation;
									end if;
								end if;

							when others => 
								report "Unhandled region" severity error;
						end case;

					when ChangeSpeed => 
						case R.Region is
							when send => 
								NextR.ToSdCmd.Content.id  <= cSdCmdSwitchFunction;
								NextR.ToSdCmd.Content.arg <= cSdCmdSwitchSpeed;
								NextRegion                := response;

							when response => 
								if (iSdCmd.Valid = cActivated) then
									if (iSdCmd.Content.id = cSdCmdSwitchFunction) then
										NextR.CardStatus <= iSdCmd.Content.arg;
										NextR.Region     <= receivedata;

									else
										NextR.State <= invalidCard;
									end if;
								elsif (Timeout = cActivated) then
									NextR.State <= invalidCard;
								end if;

							when receivedata => 

							when waitstatedata => 
								if (Timeout = cActivated) then
									-- check if switching was successful
									if (iSdData.SpeedBits.HighSpeedSupported = cActivated and
									iSdData.SpeedBits.SwitchFunctionOK = X"1") then
										NextR.HighSpeed <= cActivated;
										NextRegion      := send;
										NextCmdRegion   := GetStatus;
										--NextR.LedBank(5)<= cActivated;
									else
										NextRegion := idle;
										NextState  := requestnewoperation;
									end if;
								end if;

							when others => 
								report "Unhandled region" severity error;
						end case;

					when GetStatus => 
						case R.Region is
							when idle => 
								EnableNcrTimeout;

								if (Timeout = cActivated) then
									NextR.Region <= send;
								end if;

							when send => 
								NextR.ToSdCmd.Content.id              <= cSdCmdSendStatus;
								NextR.ToSdCmd.Content.arg(31 downto 16) <= R.RCA;
								NextRegion                            := response;

							when response => 
								if (iSdCmd.Valid = cActivated) then
									if (iSdCmd.Content.id = cSdCmdSendStatus) then
										NextR.CardStatus <= iSdCmd.Content.arg;
										NextR.Region <= waitstate;

									else
										NextR.State <= invalidCard;
									end if;
								elsif (Timeout = cActivated) then
									NextR.State <= invalidCard;
								end if;

							when waitstate => 
								NextRegion    := idle;
								NextState     := requestnewoperation;

							when others => 
								report "Unhandled region" severity error;
						end case;

					when others => 
						report "Unhandled CmdRegion" severity error;
				end case;

			when read => 
				NextR.ToSdData.DataMode <= usual;

				case R.Region is
					when send =>
						NextR.LedBank(0) <= cActivated;	
						-- send a read command
						NextR.ToSdCmd.Content.id  <= cSdCmdReadSingleBlock;
						
						-- we get a block address, but a standard capacity card needs a byte address
						case R.CCS is
							when cActivated => 
								NextR.ToSdCmd.Content.arg <= R.OperationBlock.StartAddr;

							when cInactivated => 
								NextR.ToSdCmd.Content.arg <= R.OperationBlock.StartAddr(31-9 downto 0) & X"00" & '0'; -- calculate byte address

							when others => 
								report "Invalid CCS" severity error;
						end case;

						NextRegion                := response;

					when response => 
						NextR.LedBank(1) <= cActivated;

						-- wait for the response and handle it
						if (iSdCmd.Valid = cActivated) then
							if (iSdCmd.Content.id = cSdCmdReadSingleBlock) then
								NextR.CardStatus <= iSdCmd.Content.arg;
								NextR.Region     <= receivedata;

							else
								NextR.State <= invalidCard;
							end if;
						elsif (Timeout = cActivated) then
							NextR.State <= invalidCard;
						end if;

					when receivedata => 
						NextR.LedBank(2) <= cActivated;

					when waitstatedata => 
						NextR.LedBank(3) <= cActivated;
						NextRegion := idle;
						NextState  := requestnewoperation;

					when others => 
						report "Unhandled region";
				end case;

			when write => 
				NextR.ToSdData.DataMode <= usual;

				case R.Region is
					when send =>
						-- send a write command
						NextR.ToSdCmd.Content.id  <= cSdCmdWriteSingleBlock;
						
						-- we get a block address, but a standard capacity card needs a byte address
						case R.CCS is
							when cActivated => 
								NextR.ToSdCmd.Content.arg <= R.OperationBlock.StartAddr;

							when cInactivated => 
								NextR.ToSdCmd.Content.arg <= R.OperationBlock.StartAddr(31-9 downto 0) & X"00" & '0'; -- calculate byte address

							when others => 
								report "Invalid CCS" severity error;
						end case;

						NextRegion                := response;

					when response => 
						-- wait for the response and handle it
						if (iSdCmd.Valid = cActivated) then
							if (iSdCmd.Content.id = cSdCmdWriteSingleBlock) then
								NextR.CardStatus <= iSdCmd.Content.arg;
								NextR.Region     <= senddata;

							else
								NextR.State <= invalidCard;
							end if;
						elsif (Timeout = cActivated) then
							NextR.State <= invalidCard;
						end if;

					when senddata => 
						NextRegion := checkbusy;

					when checkbusy => null;

					when waitstatedata => 
						NextRegion := idle;
						NextState  := requestnewoperation;

					when others => 
						report "Unhandled region";
				end case;

			when requestnewoperation => 
				NextR.LedBank <= (others => '0');
				NextR.ToSdData.DisableRb       <= cInactivated;
				NextR.ToSdWbSlave.ReqOperation <= not R.ToSdWbSlave.ReqOperation;
				NextR.State                    <= idle;

			when idle => 
				NextR.LedBank(6) <= cActivated;

				-- wait for next operation
				if (iSdWbSlave.AckOperation = cActivated) then

					-- save operation
					NextR.OperationBlock <= iSdWbSlave.OperationBlock;
					
					-- handle operations
					case iSdWbSlave.OperationBlock.Operation is
						when cOperationRead => 

							NextR.State  <= read;
							NextR.Region <= send;

						when cOperationWrite => 

							NextR.State  <= write;
							NextR.Region <= send;

						when others => 
							NextR.State <= requestnewoperation;
							report "Unknown operation" severity error;
					end case;

					NextR.LedBank(6) <= cInactivated;
				end if;

			when invalidCard => 
				NextR.LedBank(7) <= cActivated;

			when others => 
				report "SdController: Unhandled state" severity error;
		end case;

		case R.Region is
			when idle => -- do nothing
				null;

			when send => 
				NextR.ToSdCmd.Valid <= cActivated;

				if (R.SendCMD55 = cActivated) then
					NextR.ToSdCmd.Content.id  <= cSdNextIsACMD;
					NextR.ToSdCmd.Content.arg <= R.RCA & X"0000";
					NextRegion                := response;
				end if;

				if (iSdCmd.Ack = cActivated) then
					NextR.ToSdCmd.Valid <= cInactivated;
					NextR.Region        <= NextRegion;
				end if;

			when response => 
				-- oLedBank(0)   <= cActivated;
				TimeoutEnable <= cActivated;
				TimeoutMax    <= cReadTimeout;

				if (iSdCmd.Valid = cActivated) then
					TimeoutDisable <= cActivated;
				end if;

				if (R.SendCMD55 = cActivated) then
					if (iSdCmd.Valid = cActivated) then
						if (iSdCmd.Content.id = cSdNextIsACMD) then
							NextR.CardStatus <= iSdCmd.Content.arg;
							NextR.Region <= waitstate;

							if (iSdCmd.Content.arg(cSdArgAppCmdPos) = cActivated) then
								NextR.SentCMD55 <= cActivated;
							end if;
						else 
							NextR.State <= invalidCard;
						end if;
					elsif (Timeout = cActivated) then
						NextR.State     <= startup;
						NextR.CmdRegion <= CMD0;
						NextR.Region    <= idle;
					end if;
				end if;


			when waitstate => 
				EnableNcrTimeout;

				if (Timeout = cActivated) then
					if (R.SentCMD55 = cActivated) then
						NextR.SentCMD55 <= cInactivated;
						NextR.SendCMD55 <= cInactivated;
						NextRegion := send;
					end if;

					TimeoutDisable  <= cActivated;
					NextR.Region    <= NextRegion;
					NextR.CmdRegion <= NextCmdRegion;
					NextR.State     <= NextState;
				end if;

			when senddata => 
				NextR.ToSdData.Valid <= cActivated;

				if (iSdData.Ack = cActivated) then
					NextR.ToSdData.Valid <= cInactivated;
					NextR.Region         <= NextRegion;
				end if;

			when checkbusy => 
				NextR.ToSdData.CheckBusy <= cActivated;
				TimeoutEnable <= cActivated;
				TimeoutMax    <= cWriteTimeout;

				if (iSdData.Valid = cActivated) then
					NextR.Region <= waitstatedata;
					NextR.ToSdData.CheckBusy <= cInactivated;
					TimeoutDisable <= cActivated;
				end if;

			when receivedata => 
				TimeoutEnable <= cActivated;
				TimeoutMax    <= cReadTimeout;

				if (iSdData.Err = cActivated) then
					NextR.State    <= init;
					TimeoutDisable <= cActivated;

				elsif (iSdData.Valid = cActivated) then
					NextR.Region   <= waitstatedata;
					TimeoutDisable <= cActivated;

				elsif (Timeout = cActivated) then
					NextR.State <= invalidCard;
					NextR.LedBank(5) <= cActivated;
				end if;


			when waitstatedata => 
				EnableNcrTimeout;

				if (Timeout = cActivated) then
					TimeoutDisable  <= cActivated;
					NextR.Region    <= NextRegion;
					NextR.CmdRegion <= NextCmdRegion;
					NextR.State     <= NextState;
				end if;

			when others => 
				report "Unhandled region" severity error;
		end case;
	end process Comb;

	TimeoutCounter_inst : entity work.Counter
	generic map (
		gBitWidth => cMaxTimeoutBitWidth
	)
	port map (
		iClk         => iClk,
		iRstSync     => iRstSync,
		iEnable      => TimeoutEnable,
		iDisable     => TimeoutDisable,
		iMax         => TimeoutMax,
		oStrobe      => Timeout);

end architecture Rtl;

