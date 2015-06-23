--
-- 8052 compatible microcontroller
--
-- Version : 0300
--
-- Copyright (c) 2001-2002 Daniel Wallner (jesus@opencores.org)
--           (c) 2004-2005 Andreas Voggeneder (andreas.voggeneder@fh-hagenberg.at)
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
--  http://www.opencores.org/cvsweb.shtml/t51/
--
-- Limitations :
--
-- File history :
--

library IEEE;
use IEEE.std_logic_1164.all;
use work.T51_Pack.all;

entity T51_Glue is
  generic(
    tristate  : integer := 1
  );
  port(
    Clk     : in std_logic;
    Rst_n   : in std_logic;
    INT0    : in std_logic;
    INT1    : in std_logic;
    RI      : in std_logic;
    TI      : in std_logic;
    OF0     : in std_logic;
    OF1     : in std_logic;
    OF2     : in std_logic;
    IO_Wr   : in std_logic;
    IO_Addr   : in std_logic_vector(6 downto 0);
    IO_Addr_r : in std_logic_vector(6 downto 0);
    IO_WData  : in std_logic_vector(7 downto 0);
    IO_RData  : out std_logic_vector(7 downto 0);
    Selected  : out std_logic;
    Int_Acc   : in std_logic_vector(6 downto 0);    -- Acknowledge
    R0      : out std_logic;
    R1      : out std_logic;
    SMOD    : out std_logic;
    P0_Sel    : out std_logic;
    P1_Sel    : out std_logic;
    P2_Sel    : out std_logic;
    P3_Sel    : out std_logic;
    TMOD_Sel  : out std_logic;
    TL0_Sel   : out std_logic;
    TL1_Sel   : out std_logic;
    TH0_Sel   : out std_logic;
    TH1_Sel   : out std_logic;
    T2CON_Sel : out std_logic;
    RCAP2L_Sel  : out std_logic;
    RCAP2H_Sel  : out std_logic;
    TL2_Sel   : out std_logic;
    TH2_Sel   : out std_logic;
    SCON_Sel  : out std_logic;
    SBUF_Sel  : out std_logic;
    P0_Wr   : out std_logic;
    P1_Wr   : out std_logic;
    P2_Wr   : out std_logic;
    P3_Wr   : out std_logic;
    TMOD_Wr   : out std_logic;
    TL0_Wr    : out std_logic;
    TL1_Wr    : out std_logic;
    TH0_Wr    : out std_logic;
    TH1_Wr    : out std_logic;
    T2CON_Wr  : out std_logic;
    RCAP2L_Wr : out std_logic;
    RCAP2H_Wr : out std_logic;
    TL2_Wr    : out std_logic;
    TH2_Wr    : out std_logic;
    SCON_Wr   : out std_logic;
    SBUF_Wr   : out std_logic;
    Int_Trig  : out std_logic_vector(6 downto 0)
  );
end T51_Glue;

architecture rtl of T51_Glue is

  signal  IE      : std_logic_vector(7 downto 0);
  signal  TCON    : std_logic_vector(7 downto 0);
  signal  PCON    : std_logic_vector(7 downto 0);

  signal  Int0_r    : std_logic_vector(1 downto 0);
  signal  Int1_r    : std_logic_vector(1 downto 0);

begin

  R0 <= TCON(4);
  R1 <= TCON(6);
  SMOD <= PCON(7);

  -- Registers/Interrupts
  tristate_mux: if tristate/=0 generate
    IO_RData <= TCON when IO_Addr = "0001000" else "ZZZZZZZZ"; -- $88 TCON
    IO_RData <= PCON when IO_Addr = "0000111" else "ZZZZZZZZ"; -- $87 TCON
    IO_RData <= IE when IO_Addr = "0101000" else "ZZZZZZZZ";
    Selected <= '0';
  end generate;
  
  std_mux: if tristate=0 generate
    IO_RData <= TCON when IO_Addr = "0001000" else 
                PCON when IO_Addr = "0000111" else
                IE when IO_Addr = "0101000" else 
                (others =>'-');
    Selected <= '1' when IO_Addr = "0001000" or 
                         IO_Addr = "0000111" or
                         IO_Addr = "0101000" else
                '0';
  end generate;
  
  process (Rst_n, Clk)
  begin
    if Rst_n = '0' then
      IE   <= "00000000";
      TCON <= "00000000";
      PCON <= "00000000";
      Int0_r <= "11";
      Int1_r <= "11";
    elsif Clk'event and Clk = '1' then
      Int0_r(0) <= INT0;
      Int0_r(1) <= Int0_r(0);
      Int1_r(0) <= INT1;
      Int1_r(1) <= Int1_r(0);

      if IO_Wr = '1' and IO_Addr_r = "0101000" then
        IE <= IO_WData;
      end if;
      if IO_Wr = '1' and IO_Addr_r = "0001000" then
        TCON <= IO_WData;
      end if;
      if IO_Wr = '1' and IO_Addr_r = "0000111" then
        PCON <= IO_WData;
      end if;

      if OF0 = '1' then
        TCON(5) <= '1';
      end if;
      if Int_Acc(1) = '1' then
        TCON(5) <= '0';
      end if;
      if OF1 = '1' then
        TCON(7) <= '1';
      end if;
      if Int_Acc(3) = '1' then
        TCON(7) <= '0';
      end if;

      -- External interrupts
      if TCON(0) = '1' then
        if Int_Acc(0) = '1' then
          TCON(1) <= '0';
        end if;
        if Int0_r = "10" then
          TCON(1) <= '1';
        end if;
      else
        TCON(1) <= not Int0_r(0);
      end if;
      if TCON(2) = '1' then
        if Int_Acc(2) = '1' then
          TCON(3) <= '0';
        end if;
        if Int1_r = "10" then
          TCON(3) <= '1';
        end if;
      else
        TCON(3) <= not Int1_r(0);
      end if;
    end if;
  end process;

  Int_Trig(0) <= '0' when IE(7) = '0' or IE(0) = '0' else not Int0_r(1) when TCON(0) = '0' else TCON(1);
  Int_Trig(1) <= '1' when IE(7) = '1' and IE(1) = '1' and TCON(5) = '1' else '0';
  Int_Trig(2) <= '0' when IE(7) = '0' or IE(2) = '0' else not Int1_r(1) when TCON(2) = '0' else TCON(3);
  Int_Trig(3) <= '1' when IE(7) = '1' and IE(3) = '1' and TCON(7) = '1' else '0';
  Int_Trig(4) <= '1' when IE(7) = '1' and IE(4) = '1' and (RI = '1' or TI = '1') else '0';
  Int_Trig(5) <= '1' when IE(7) = '1' and IE(5) = '1' and OF2 = '1' else '0';
  Int_Trig(6) <= '0';

  P0_Sel <= '1' when IO_Addr = "0000000" else '0';
  P0_Wr <= '1' when IO_Addr_r = "0000000" and IO_Wr = '1' else '0';

  P1_Sel <= '1' when IO_Addr = "0010000" else '0';
  P1_Wr <= '1' when IO_Addr_r = "0010000" and IO_Wr = '1' else '0';

  P2_Sel <= '1' when IO_Addr = "0100000" else '0';
  P2_Wr <= '1' when IO_Addr_r = "0100000" and IO_Wr = '1' else '0';

  P3_Sel <= '1' when IO_Addr = "0110000" else '0';
  P3_Wr <= '1' when IO_Addr_r = "0110000" and IO_Wr = '1' else '0';

  TMOD_Sel <= '1' when IO_Addr = "0001001" else '0';
  TMOD_Wr <= '1' when IO_Addr_r = "0001001" and IO_Wr = '1' else '0';
  TL0_Sel <= '1' when IO_Addr = "0001010" else '0';
  TL0_Wr <= '1' when IO_Addr_r = "0001010" and IO_Wr = '1' else '0';
  TL1_Sel <= '1' when IO_Addr = "0001011" else '0';
  TL1_Wr <= '1' when IO_Addr_r = "0001011" and IO_Wr = '1' else '0';
  TH0_Sel <= '1' when IO_Addr = "0001100" else '0';
  TH0_Wr <= '1' when IO_Addr_r = "0001100" and IO_Wr = '1' else '0';
  TH1_Sel <= '1' when IO_Addr = "0001101" else '0';
  TH1_Wr <= '1' when IO_Addr_r = "0001101" and IO_Wr = '1' else '0';

  T2CON_Sel <= '1' when IO_Addr = "1001000" else '0';
  T2CON_Wr <= '1' when IO_Addr_r = "1001000" and IO_Wr = '1' else '0';
  RCAP2L_Sel <= '1' when IO_Addr = "1001010" else '0';
  RCAP2L_Wr <= '1' when IO_Addr_r = "1001010" and IO_Wr = '1' else '0';
  RCAP2H_Sel <= '1' when IO_Addr = "1001011" else '0';
  RCAP2H_Wr <= '1' when IO_Addr_r = "1001011" and IO_Wr = '1' else '0';
  TL2_Sel <= '1' when IO_Addr = "1001100" else '0';
  TL2_Wr <= '1' when IO_Addr_r = "1001100" and IO_Wr = '1' else '0';
  TH2_Sel <= '1' when IO_Addr = "1001101" else '0';
  TH2_Wr <= '1' when IO_Addr_r = "1001101" and IO_Wr = '1' else '0';

  SCON_Sel <= '1' when IO_Addr = "0011000" else '0';
  SCON_Wr <= '1' when IO_Addr_r = "0011000" and IO_Wr = '1' else '0';
  SBUF_Sel <= '1' when IO_Addr = "0011001" else '0';
  SBUF_Wr <= '1' when IO_Addr_r = "0011001" and IO_Wr = '1' else '0';
end;
