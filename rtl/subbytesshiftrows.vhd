--
-- This file is part of the Crypto-PAn core.
--
-- Copyright (c) 2007 The University of Waikato, Hamilton, New Zealand.
-- Authors: Anthony Blake (tonyb33@opencores.org)
--          
-- All rights reserved.
--
-- This code has been developed by the University of Waikato WAND 
-- research group. For further information please see http://www.wand.net.nz/
--
-- This source file is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
--
-- This source is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with libtrace; if not, write to the Free Software
-- Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
--

library ieee;
use ieee.std_logic_1164.all;

use work.cryptopan.all;

entity subbytesshiftrows is

  port (
    bytes_in  : in  s_vector;
    bytes_out : out s_vector;

    in_en  : in  std_logic;
    out_en : out std_logic;

    clk   : in std_logic;
    reset : in std_logic
    );

end subbytesshiftrows;


architecture rtl of subbytesshiftrows is

  component dual_bram_256x8
    port (
      addra : IN  std_logic_VECTOR(7 downto 0);
      addrb : IN  std_logic_VECTOR(7 downto 0);
      clka  : IN  std_logic;
      clkb  : IN  std_logic;
      douta : OUT std_logic_VECTOR(7 downto 0);
      doutb : OUT std_logic_VECTOR(7 downto 0));
  end component;
  
  component sbox
    port (
      clk   : in  std_logic;
      reset : in  std_logic;
      addra : in  std_logic_vector(7 downto 0);
      douta : out std_logic_vector(7 downto 0));
  end component;

  signal subbytes_out : s_vector;

  signal in_en_int : std_logic;

begin  -- rtl

  out_en <= in_en_int;

  CLKLOGIC : process (clk, reset)
  begin 
    if reset = '1' then            
      in_en_int <= '0';
    elsif clk'event and clk = '1' then  
      in_en_int <= in_en;
    end if;
  end process CLKLOGIC;

  USE_BRAM_GEN         : if use_bram = true generate
    GEN_SBOX_BRAM : for i in 0 to 7 generate

      SBOX_i: dual_bram_256x8
        port map (
            addra => bytes_in(i),
            addrb => bytes_in(i+8),
            clka  => clk,
            clkb  => clk,
            douta => subbytes_out(i),
            doutb => subbytes_out(i+8));    
      
    end generate GEN_SBOX_BRAM;
  end generate USE_BRAM_GEN;

  NO_BRAM_GEN            : if use_bram = false generate
    GEN_SBOX_NOBRAM : for i in 0 to 15 generate
      SBOX_i : sbox
        port map (
          clk   => clk,
          reset => reset,
          addra => bytes_in(i),
          douta => subbytes_out(i) );

    end generate GEN_SBOX_NOBRAM;
  end generate NO_BRAM_GEN;

  bytes_out(0) <= subbytes_out(0);
  bytes_out(1) <= subbytes_out(1);
  bytes_out(2) <= subbytes_out(2);
  bytes_out(3) <= subbytes_out(3);

  bytes_out(4) <= subbytes_out(5);
  bytes_out(5) <= subbytes_out(6);
  bytes_out(6) <= subbytes_out(7);
  bytes_out(7) <= subbytes_out(4);

  bytes_out(8)  <= subbytes_out(10);
  bytes_out(9)  <= subbytes_out(11);
  bytes_out(10) <= subbytes_out(8);
  bytes_out(11) <= subbytes_out(9);

  bytes_out(12) <= subbytes_out(15);
  bytes_out(13) <= subbytes_out(12);
  bytes_out(14) <= subbytes_out(13);
  bytes_out(15) <= subbytes_out(14);



end rtl;
