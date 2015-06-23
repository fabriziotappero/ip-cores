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
-- File        : tbCrc-bhv-ea.vhdl
-- Owner       : Rainer Kastl
-- Description : Testbench
-- Links       : Crc-Rtl-ea.vhdl
-- 

library ieee;
use ieee.std_logic_1164.all;
use work.CRCs.all;

entity tbCrc is
end entity tbCrc;

architecture bhv of tbCrc is
    signal Clk, ResetSync : std_ulogic := '1';
    signal CRC_7 : std_ulogic_vector(6 downto 0);
    signal CRC_16 : std_ulogic_vector(15 downto 0);
    signal DataToCrc_7, DataToCrc_16 : std_ulogic;
    signal CRCDataIn_7,CRCClear_7 : std_ulogic;
    signal CRCDataIn_16,CRCClear_16 : std_ulogic;
    signal SerialCRC_7, SerialCRC_16 : std_ulogic;

    signal EndOfSim : boolean := false; -- stop clock generation when true

    -- Use the negative clock edge to setup the signals in front of the positive
    -- edge. Therefore no extra clock cycle is needed.
    procedure Test (
        Data : in std_ulogic_vector;
        Valid : in std_ulogic_vector;
        signal CRC : in std_ulogic_vector;
        signal SerialCRC : in std_ulogic;
        signal CRCDataIn : out std_ulogic;
        signal DataToCrc : out std_ulogic;
        signal CRCClear : out std_ulogic) is

        variable counter : natural := 0;

    begin
        wait until Clk = '0';
        -- shift data in
        CRCClear <= '0';
        CRCDataIn <= '1';

        while (counter <= Data'high) loop
            DataToCrc <= Data(counter);
            counter := counter + 1;
            wait until Clk = '0';
        end loop;

        -- compare parallel output
        CRCDataIn <= '0';

        assert (Valid = CRC) report "CRC error." severity error;

        -- compare serial output
        counter := 0;
        while (counter <= CRC'high) loop
            assert (Valid(counter) = SerialCRC) report "Serial CRC error"
            severity error;
            counter := counter + 1;
			wait until clk = '0';
        end loop;

        -- clear the registers, not needed after shifting the serial data out
        CRCClear <= '1';
        wait until Clk = '0';

        CRCClear <= '0';
    end procedure;

begin

    Clk <= not Clk after 10 ns when EndOfSim = false else '0';
    ResetSync <= '0' after 100 ns;

    generate_and_test7 : process is
        procedure Test7(
            Data : in std_ulogic_vector;
            Valid : in std_ulogic_vector) is
        begin
            Test(Data, Valid, CRC_7, SerialCRC_7, CRCDataIn_7, DataToCrc_7,
                CRCClear_7);
        end procedure;

        procedure Test16(
            Data : in std_ulogic_vector;
            Valid : in std_ulogic_vector) is
        begin
            Test(Data, Valid, CRC_16, SerialCRC_16, CRCDataIn_16, DataToCrc_16,
                CRCClear_16);
        end procedure;

        variable data : std_ulogic_vector(0 to (512*8)-1) := (others => '1');
    begin
        wait until (ResetSync = '0');

        Test7("0100000000000000000000000000000000000000","1001010");
        Test7("01000000000000000000000000000000000000001001010","0000000");
        Test7("0101000100000000000000000000000000000000","0101010");
        Test7("01010001000000000000000000000000000000000101010","0000000");
        Test7("0001000100000000000000000000100100000000","0110011");
        Test7("00010001000000000000000000001001000000000110011","0000000");
		Test7("000010000000000000000000000000000110101010", "0000111");
		Test7("0001110100101001011100000000111011000110000010110100101101011001001010110010101110100011101100001111001000000001100101110001000",
		"0000000");

        Test16(data, X"7FA1");
        Test16(X"1234567890ABCDEF", X"2FBC");
        Test16(X"1234567890ABCDEF2FBC", X"0000");
        Test16(X"F0F0F0F0F0F0F0F0F0F0", X"63E2");
        Test16(X"F0F0F0F0F0F0F0F0F0F063E2", X"0000");

        EndOfSim <= true;
        report "Simulation finished." severity note;
    end process;

    duv7: entity work.crc
    port map (iClk => Clk,
        iRstSync => ResetSync,
        iDataIn => CRCDataIn_7,
		iStrobe => '1',
        iClear => CRCClear_7,
        iData => DataToCrc_7,
        oParallel => CRC_7,
        oSerial => SerialCRC_7);

    duv16: entity work.crc
    generic map (gPolynom => crc16)
    port map (iClk => Clk,
        iRstSync => ResetSync,
        iDataIn => CRCDataIn_16,
		iStrobe => '1',
        iClear => CRCClear_16,
        iData => DataToCrc_16,
        oParallel => CRC_16,
        oSerial => SerialCRC_16);

end architecture bhv;
