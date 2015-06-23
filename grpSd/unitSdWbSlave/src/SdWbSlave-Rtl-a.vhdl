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
-- File        : SdWbSlave-Rtl-a.vhdl
-- Owner       : Rainer Kastl
-- Description : Wishbone interface of SDHC-SC-Core
-- Links       : 
-- 

architecture Rtl of SdWbSlave is

	type aWbState is (idle, ClassicWrite, ClassicRead);
	type aSdIntState is (idle, newOperation);
	type aReadBufferState is (invalid, readreq, latchdata, valid);

	type aRegs is record

		WbState             : aWbState; -- state of the wb interface
		SdIntState          : aSdIntState; -- state of the sd controller interface
		OperationBlock      : aOperationBlock; -- Operation for the SdController
		ReqOperation        : std_ulogic; -- Register for catching edges on the SdController ReqOperationEdge line
		ReadBuffer          : aData;
		ReadBufferState     : aReadBufferState;
		-- Register outputs
		oWbDat              : aSdWbSlaveDataOutput;
		oWbCtrl             : aWbSlaveCtrlOutput;
		oController         : aSdWbSlaveToSdController;
		oWriteFifo          : aoWriteFifo;
		oReadFifo 			: aoReadFifo;

	end record aRegs;

	constant cDefaultRegs : aRegs := (
	WbState                            => idle,
	SdIntState                         => idle,
	OperationBlock                     => cDefaultOperationBlock,
	ReqOperation                       => cInactivated,
	oWbDat                             => (Dat                             => (others => 'X')),
	oWbCtrl                            => cDefaultWbSlaveCtrlOutput,
	oController                        => cDefaultSdWbSlaveToSdController,
	oWriteFifo                         => cDefaultoWriteFifo,
	oReadFifo  					       => cDefaultoReadFifo,
	ReadBuffer                         => (others                          => '0'),
	ReadBufferState                    => invalid);

	signal R, NxR : aRegs;

begin
	oWbDat      <= R.oWbDat;
	oWbCtrl     <= R.oWbCtrl;
	oController <= R.oController;
	oWriteFifo  <= R.oWriteFifo;
	oReadFifo   <= R.oReadFifo;

	WbStateReg  : process (iClk, iRstSync)
	begin
		if (iClk'event and iClk = cActivated) then
			if (iRstSync = cActivated) then -- sync. reset
				R <= cDefaultRegs;
			else
				R <= NxR;
			end if;
		end if;
	end process WbStateReg ;

	WbStateAndOutputs : process (iWbCtrl, iWbDat, iController, iWriteFifo, iReadFifo, R)
	begin
		-- Default Assignments

		NxR             <= R;
		NxR.oWbDat.Dat  <= (others => 'X');
		NxR.oWbCtrl     <= cDefaultWbSlaveCtrlOutput;
		NxR.oWriteFifo  <= cDefaultoWriteFifo;

		case R.ReadBufferState is
			when invalid => 
				-- is new data available?
				if (iReadFifo.rdempty = cInactivated) then
					NxR.oReadFifo.rdreq <= cActivated;
					NxR.ReadBufferState <= readreq;
				end if;

			when readreq => 
			-- readreq was sent, data is available next cycle
				NxR.oReadFifo.rdreq <= cInactivated;
				NxR.ReadBufferState <= latchdata;

			when latchdata => 
				NxR.ReadBuffer <= iReadFifo.q;
				NxR.ReadBufferState <= valid;

			when valid => 
			-- do nothing, wishbone statemachine sets the state to invalid when it used it
				null;

			when others => 
				report "Error: Invalid ReadBufferState" severity error;
		end case;
		

		-- Determine next state
		case R.WbState is
			when idle =>
				if iWbCtrl.Cyc = cActivated and iWbCtrl.Stb = cActivated then

					case iWbCtrl.Cti is
						when cCtiClassicCycle => 
							case iWbCtrl.We is
								when cInactivated => 

									-- perform a ClassicRead
									NxR.oWbCtrl.Ack <= cActivated;
									NxR.WbState     <= ClassicRead;

									if (iWbDat.Sel = "1") then
										case iWbDat.Adr is
											when cOperationAddr => 
												NxR.oWbDat.Dat <= R.OperationBlock.Operation;

											when cStartAddrAddr => 
												NxR.oWbDat.Dat <= R.OperationBlock.StartAddr;

											when cEndAddrAddr => 
												NxR.oWbDat.Dat <= R.OperationBlock.EndAddr;

											when cReadDataAddr => 
												-- check if data is available
												case R.ReadBufferState is
													when valid =>
														-- use buffered data
														NxR.oWbDat.Dat <= R.ReadBuffer;
														NxR.ReadBufferState <= invalid;

													when latchdata => 
														-- use input directly
														NxR.oWbDat.Dat <= iReadFifo.q;
														NxR.ReadBufferState <= invalid;

													when readreq => 
													-- no data available, insert a waitstate
														NxR.oWbCtrl.Ack <= cInactivated;
														NxR.WbState     <= idle;

													when invalid => 
													-- no data available, insert a waitstate
														NxR.oWbCtrl.Ack <= cInactivated;
														NxR.WbState     <= idle;

													when others => 
														report "Invalid ReadBufferState" severity error;
												end case;

											when others => 
												report "Read to an invalid address" severity warning;
												NxR.oWbCtrl.Err <= cActivated;
												NxR.oWbCtrl.Ack <= cInactivated;
										end case;
									end if;
									
								when cActivated => 

									--perform a ClassicWrite
									NxR.oWbCtrl.Ack <= cActivated;
									NxR.WbState     <= ClassicWrite;

									if (iWbDat.Sel = "1") then
										if (iWbDat.Adr = cOperationAddr or iWbDat.Adr = cStartAddrAddr or iWbDat.Adr = cEndAddrAddr) and 
										R.SdIntState = newOperation then
										-- insert waitstates until we can notify the SdController again

											NxR.oWbCtrl.Ack <= cInactivated;
											NxR.WbState     <= idle;
										end if;

										if (iWbDat.Adr = cWriteDataAddr and iWriteFifo.wrfull = cActivated) then
											NxR.oWbCtrl.Ack <= cInactivated;
											NxR.oWbCtrl.Err <= cActivated;
											NxR.WbState     <= idle;
										end if;

									end if;

								when others => 
									report "iWbCtrl.We is invalid" severity warning;
							end case;		

						when others => null;
					end case;

				end if;

			when ClassicRead => 
				NxR.WbState <= idle;

			when ClassicWrite => 
				NxR.WbState <= idle;

				if (iWbDat.Sel = "1") then
					case iWbDat.Adr is
						when cOperationAddr => 

							NxR.OperationBlock.Operation <= iWbDat.Dat;
							NxR.SdIntState               <= newOperation;

						when cStartAddrAddr => 
							
							NxR.OperationBlock.StartAddr <= iWbDat.Dat;

						when cEndAddrAddr => 

							NxR.OperationBlock.EndAddr <= iWbDat.Dat;

						when cWriteDataAddr => 

							NxR.oWriteFifo.data  <= iWbDat.Dat;
							NxR.oWriteFifo.wrreq <= cActivated;

						when others => 
							report "Write to an invalid address" severity warning;
							NxR.oWbCtrl.Err <= cActivated;
							NxR.oWbCtrl.Ack <= cInactivated;
					end case;
				end if;


			when others => 
				report "Invalid state" severity error;
		end case;

		-- send operations to SdController
		case R.SdIntState is
			when idle => 
				-- save edges on the ReqOperationEdge line which would be missed otherwise

				if (iController.ReqOperation = cActivated) then

					NxR.ReqOperation <= cActivated;

				end if;

			when newOperation => 
				-- send a new operation, when the controller requested it
				if (R.ReqOperation = cActivated or iController.ReqOperation = cActivated) then

					NxR.oController.OperationBlock <= R.OperationBlock;
					NxR.oController.AckOperation   <= not R.oController.AckOperation;

					-- go to idle state, the next request will come only after the SdController received this block

					NxR.ReqOperation <= cInactivated;
					NxR.SdIntState   <= idle;

				end if;

			when others => 
				report "Invalid state" severity error;
		end case;

	end process WbStateAndOutputs;
end architecture Rtl;

