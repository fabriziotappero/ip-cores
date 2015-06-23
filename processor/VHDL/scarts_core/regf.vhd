-----------------------------------------------------------------------
-- This file is part of SCARTS.
-- 
-- SCARTS is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-- 
-- SCARTS is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with SCARTS.  If not, see <http://www.gnu.org/licenses/>.
-----------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.scarts_core_pkg.all;
use work.scarts_pkg.all;

entity scarts_regf is
  generic (
    CONF : scarts_conf_type); 
  port (
    wclk    : in  std_ulogic;
    rclk    : in  std_ulogic;
    hold    : in  std_ulogic;

    wdata   : in  std_logic_vector(CONF.word_size-1 downto 0);
    waddr   : in  std_logic_vector(REGADDR_W-1 downto 0);
    wen     : in  std_ulogic;
    raddr1  : in  std_logic_vector(REGADDR_W-1 downto 0);
    raddr2  : in  std_logic_vector(REGADDR_W-1 downto 0);

    rdata1  : out std_logic_vector(CONF.word_size-1 downto 0);
    rdata2  : out std_logic_vector(CONF.word_size-1 downto 0));
end scarts_regf;

architecture behaviour of scarts_regf is

  signal regfram1i_wdata       : std_logic_vector(CONF.word_size-1 downto 0);
  signal regfram1i_waddr       : std_logic_vector(REGADDR_W-1 downto 0);
  signal regfram1i_wen         : std_ulogic;
  signal regfram1i_raddr       : std_logic_vector(REGADDR_W-1 downto 0);
  signal regfram1o_rdata       : std_logic_vector(CONF.word_size-1 downto 0);

  signal regfram2i_wdata       : std_logic_vector(CONF.word_size-1 downto 0);
  signal regfram2i_waddr       : std_logic_vector(REGADDR_W-1 downto 0);
  signal regfram2i_wen         : std_ulogic;
  signal regfram2i_raddr       : std_logic_vector(REGADDR_W-1 downto 0);
  signal regfram2o_rdata       : std_logic_vector(CONF.word_size-1 downto 0);

  signal enable : std_ulogic;

begin

  enable <= not hold;

  regfram1i_wdata <= wdata;
  regfram1i_waddr <= waddr;
  regfram1i_wen   <= wen;
  regfram1i_raddr <= raddr1;

  regfram2i_wdata <= wdata;
  regfram2i_waddr <= waddr;
  regfram2i_wen   <= wen;
  regfram2i_raddr <= raddr2;
  
  rdata1 <= regfram1o_rdata;
  rdata2 <= regfram2o_rdata;

  ram1 : scarts_regfram
  generic map (CONF => CONF)
  port map (wclk   => wclk,
            rclk   => rclk,
            enable => enable,
            wdata  => regfram1i_wdata,
            waddr  => regfram1i_waddr,
            wen    => regfram1i_wen,
            raddr  => regfram1i_raddr,
            rdata  => regfram1o_rdata);
  
  ram2 : scarts_regfram
  generic map (CONF => CONF)
  port map (wclk   => wclk,
            rclk   => rclk,
            enable => enable,
            wdata  => regfram2i_wdata,
            waddr  => regfram2i_waddr,
            wen    => regfram2i_wen,
            raddr  => regfram2i_raddr,
            rdata  => regfram2o_rdata);
  
end behaviour;
