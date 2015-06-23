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
-- File        : TestWbMaster-Rtl-a.vhdl
-- Owner       : Rainer Kastl
-- Description : Wishbone master for testing SDHC-SC-Core on the SbX
-- Links       : 
-- 

architecture Rtl of TestWbMaster is

	type aState is (startAddr, writeBuffer, write, readbuffer, read, done);
	subtype aCounter is unsigned(7 downto 0); -- 128 * 32 bit = 512 byte

	type aWbState is (idle, write, read);

	type aReg is record

		State : aState;
		Counter : aCounter;
		WbState : aWbState;
		Err : std_ulogic;
		ReadData : unsigned(31 downto 0);
		StartAddr: unsigned(31 downto 0);

	end record aReg;

	signal R, NxR : aReg;

begin

	LEDBANK_O(7) <= R.Err;
	LEDBANK_O(2 downto 0) <= std_ulogic_vector(R.StartAddr(2 downto 0));

	Regs : process (CLK_I)
	begin
		if (rising_edge(CLK_I)) then

			if (RST_I = '1') then
				-- sync. reset
				R.State   <= startAddr;
				R.Counter <= (others => '0');
				R.WbState <= write;
				R.Err     <= '0';
				R.ReadData <= (others => '0');
				R.StartAddr <= X"00000000";

			else
				R <= NxR;

			end if;

		end if;
	end process Regs;

	StateMachine : process (R, ERR_I, RTY_I, ACK_I, DAT_I)
	begin

		-- default assignment
		NxR <= R;
		CTI_O <= "000";
		CYC_O <= '0';
		WE_O  <= '0';
		SEL_O <= "0";
		STB_O <= '0';
		ADR_O <= "000";
		DAT_O <= (others => '0');
		BTE_O <= "00";
		LEDBANK_O(6 downto 3) <= (others => '0');

		-- we don´t care for errors or retrys
		if (ERR_I = '1' or RTY_I = '1') then
			NxR.Err <= '1';
		end if;

		case R.WbState is
			when idle => 
				null;

			when write => 
				-- write data 
				CTI_O <= "000";
				CYC_O <= '1';
				WE_O  <= '1';
				SEL_O <= "1";
				STB_O <= '1';

				if (ACK_I = '1') then
					if (R.Counter = 128) then
						NxR.Counter <= (others => '0');
					else
						NxR.Counter <= R.Counter + 1;
					end if;
				end if;

			when read => 
				-- read data
				CTI_O <= "000";
				CYC_O <= '1';
				WE_O  <= '0';
				SEL_O <= "1";
				STB_O <= '1';

			when others => 
				report "Invalid wbState" severity error;
		end case;
					
		case R.State is
			when startAddr => 
				ADR_O <= "001";
				DAT_O <= std_ulogic_vector(R.startAddr);

				if (ACK_I = '1') then
					NxR.State <= read;
					NxR.Counter <= (others => '0');
					NxR.WbState <= write;
				end if;

			when writeBuffer => 
				ADR_O <= "100"; -- write data
				DAT_O <= std_ulogic_vector(R.ReadData + 1);

				if (ACK_I = '1') then
					if (R.Counter = 128) then
						NxR.State   <= write;
						NxR.Counter <= to_unsigned(128, aCounter'length);
						NxR.WbState <= write;
					else
						NxR.State <= readBuffer;
						NxR.WbState <= read;
					end if;
				end if;

			when write => 
				LEDBANK_O(3) <= '1';
				ADR_O <= "000"; 
				DAT_O <= X"00000010"; -- start write operation

				if (ACK_I = '1') then
					NxR.State   <= startAddr;
					NxR.WbState <= write;
					NxR.startAddr <= R.startAddr + 1;
				end if;

				if (R.StartAddr = 22) then
					NxR.State <= done;
					NxR.WbState <= idle;
				end if;

			when read => 
				LEDBANK_O(4) <= '1';
				ADR_O <= "000"; 
				DAT_O <= X"00000001"; -- start read operation

				if (ACK_I = '1') then
					NxR.State <= readBuffer;
					NxR.WbState <= read;
				end if;
				
			when readBuffer => 
				LEDBANK_O(5) <= '1';
				ADR_O <= "011"; -- read data
				
				if (ACK_I = '1') then
					NxR.ReadData <= unsigned(DAT_I);
					NxR.State <= writeBuffer;
					NxR.WbState <= write;
				end if;

			when done => 
				LEDBANK_O(6) <= '1';
				report "End of Simulation" severity failure;

			when others => 
				report "Invalid state" severity error;
		end case;
		
	end process StateMachine;


end architecture Rtl;
