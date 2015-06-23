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
-- File        : Wishbone-p.vhdl
-- Owner       : Rainer Kastl
-- Description : 
-- Links       : 
-- 

-------------------------------------------------
-- file: Wishbone-p.vhdl
-- author: Rainer Kastl
--
-- Wishbone specific package.
-- Wishbone specification revision B.3
-------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package Wishbone is
	type aEndian is (big, little);

	subtype aCti is std_ulogic_vector(2 downto 0);

	constant cCtiClassicCycle     : aCti := "000";
	constant cCtiConstAdrBurstCyc : aCti := "001";
	constant cCtiIncBurstCyc      : aCti := "010";
	constant cCtiEndOfBurst       : aCti := "111";

	subtype aBte is std_ulogic_vector(1 downto 0);

	constant cBteLinear      : aBte := "00";
	constant cBteFourBeat    : aBte := "01";
	constant cBteEightBeat   : aBte := "10";
	constant cBteSixteenBeat : aBte := "11";

	-- Control inputs for a wishbone slave
	-- Unfortunately unconstrained types in records are only supported in
	-- VHDL2008, therefore signals with a range dependend on generics can not be
	-- put inside the record (iSel, iAdr, iDat).
	type aWbSlaveCtrlInput is record
		-- Control signals
		Cyc  :  std_ulogic; -- Indicates a bus cycle
		Lock :  std_ulogic; -- Indicates that the current cycle is not interruptable
		Stb  :  std_ulogic; -- Indicates the selection of the slave
		We   :  std_ulogic; -- Write enable, indicates whether the cycle is a read or write cycle
		Cti  :  aCti; -- used for synchronous cycle termination
		Bte  :  aBte; -- Burst type extension
	end record;

	-- Control output signals of a wishbone slave
	-- See aWbSlaveCtrlInput for a explanation why oDat is not in the record.
	type aWbSlaveCtrlOutput is record
		-- Control signals
		Ack : std_ulogic; -- Indicates the end of a normal bus cycle
		Err : std_ulogic; -- Indicates an error
		Rty : std_ulogic; -- Indicates that the request should be retried
	end record;

	constant cDefaultWbSlaveCtrlOutput : aWbSlaveCtrlOutput := ('0','0','0');

end package Wishbone;

