-------------------------------------------------------------------------------
--
-- T410 ROM wrapper for lpm_rom.
--
-- $Id: t410_rom-lpm-a.vhd 179 2009-04-01 19:48:38Z arniml $
--
-- Copyright (c) 2006 Arnim Laeuger (arniml@opencores.org)
--
-- All rights reserved
--
-- Redistribution and use in source and synthezised forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- Redistributions of source code must retain the above copyright notice,
-- this list of conditions and the following disclaimer.
--
-- Redistributions in synthesized form must reproduce the above copyright
-- notice, this list of conditions and the following disclaimer in the
-- documentation and/or other materials provided with the distribution.
--
-- Neither the name of the author nor the names of other contributors may
-- be used to endorse or promote products derived from this software without
-- specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
--
-- Please report bugs to the author, but before you do so, please
-- make sure that this is not a derivative work and that
-- you have the latest version of this file.
--
-- The latest version of this file can be found at:
--      http://www.opencores.org/cvsweb.shtml/t400/
--
-------------------------------------------------------------------------------

architecture lpm of t410_rom is

  component lpm_rom
    generic (
      LPM_WIDTH           :     positive;
      LPM_WIDTHAD         :     positive;
      LPM_NUMWORDS        :     natural   := 0;
      LPM_ADDRESS_CONTROL :     string    := "REGISTERED";
      LPM_OUTDATA         :     string    := "REGISTERED";
      LPM_FILE            :     string;
      LPM_TYPE            :     string    := "LPM_ROM";
      LPM_HINT            :     string    := "UNUSED"
    );
    port (
      ADDRESS             : in  STD_LOGIC_VECTOR(LPM_WIDTHAD-1 downto 0);
      INCLOCK             : in  STD_LOGIC := '0';
      OUTCLOCK            : in  STD_LOGIC := '0';
      MEMENAB             : in  STD_LOGIC := '1';
      Q                   : out STD_LOGIC_VECTOR(LPM_WIDTH-1 downto 0)
    );
  end component;

  signal vdd_s : std_logic;

begin

  vdd_s <= '1';

  rom_b : lpm_rom
    generic map (
      LPM_WIDTH   => 8,
      LPM_WIDTHAD => 9,
      LPM_OUTDATA => "UNREGISTERED",
      LPM_FILE    => "rom_41x.hex"
    )
    port map (
      ADDRESS  => addr_i,
      INCLOCK  => ck_i,
      OUTCLOCK => ck_i,
      MEMENAB  => vdd_s,
      Q        => data_o
    );

end lpm;
