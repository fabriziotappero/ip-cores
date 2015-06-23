-------------------------------------------------------------------------------
--
-- T8x49 ROM
-- Wrapper for ROM model from the LPM library.
--
-- $Id: t49_rom-lpm-a.vhd 295 2009-04-01 19:32:48Z arniml $
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
--      http://www.opencores.org/cvsweb.shtml/t48/
--
-------------------------------------------------------------------------------

architecture lpm of t49_rom is

  component lpm_rom
    generic (
      LPM_WIDTH           : positive;
      LPM_TYPE            : string    := "LPM_ROM";
      LPM_WIDTHAD         : positive;
      LPM_NUMWORDS        : natural   := 0;
      LPM_FILE            : string;
      LPM_ADDRESS_CONTROL : string    := "REGISTERED";
      LPM_OUTDATA         : string    := "REGISTERED";
      LPM_HINT            : string    := "UNUSED"
    );
    port (
      address             : in  std_logic_vector(LPM_WIDTHAD-1 downto 0);
      inclock             : in  std_logic;
      outclock            : in  std_logic;
      memenab             : in  std_logic;
      q                   : out std_logic_vector(LPM_WIDTH-1 downto 0)
    );
  end component;

  signal vdd_s : std_logic;

begin

  vdd_s  <= '1';

  rom_b : lpm_rom
    generic map (
      LPM_WIDTH           => 8,
      LPM_TYPE            => "LPM_ROM",
      LPM_WIDTHAD         => 11,
      LPM_NUMWORDS        => 2 ** 11,
      LPM_FILE            => "rom_t49.hex",
      LPM_ADDRESS_CONTROL => "REGISTERED",
      LPM_OUTDATA         => "UNREGISTERED",
      LPM_HINT            => "UNUSED"
    )
    port map (
      address  => rom_addr_i,
      inclock  => clk_i,
      outclock => clk_i,
      memenab  => vdd_s,
      q        => rom_data_o
    );

end lpm;
