-------------------------------------------------------------------------------
-- Funbase IP library Copyright (C) 2011 TUT Department of Computer Systems
--
-- This source file may be used and distributed without
-- restriction provided that this copyright statement is not
-- removed from the file and that any derivative work contains
-- the original copyright notice and the associated disclaimer.
--
-- This source file is free software; you can redistribute it
-- and/or modify it under the terms of the GNU Lesser General
-- Public License as published by the Free Software Foundation;
-- either version 2.1 of the License, or (at your option) any
-- later version.
--
-- This source is distributed in the hope that it will be
-- useful, but WITHOUT ANY WARRANTY; without even the implied
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
-- PURPOSE.  See the GNU Lesser General Public License for more
-- details.
--
-- You should have received a copy of the GNU Lesser General
-- Public License along with this source; if not, download it
-- from http://www.opencores.org/lgpl.shtml
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- File        : receiver.vhdl
-- Description : 
-- Author      : Vesa Lahtinen
-- e-mail      : erno.salminen@tut.fi
-- Project     : mikälie
-- Design      : Do not use term design when you mean system
-- Date        : 06.06.2002
-- Modified    : 
--
-- 01.04.2003   Fifo_Mux_Write added 
-- 13.04        message stuff removed, es
-- 27.07.2004   Clk+Rst removed from addr_decoder, ES
--
-- 15.12.2004   ES names changed
-- 31.01.2005   ES signals changed to generics
-- 07.02.2005   ES new generics
-- 04.03.2005   ES new generic cfg_addr_width_g
-- 
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.hibiv2_pkg.all; 

entity receiver is
  generic (
    id_g             :    integer := 5;
    base_id_g        :    integer := 5;
    addr_g           :    integer := 46;
    id_width_g       :    integer := 4;
    data_width_g     :    integer := 32;
    addr_width_g     :    integer := 32;  -- in bits
    cfg_addr_width_g :    integer := 16;  -- in bits 04.03.2005
    cfg_re_g         :    integer := 1;   -- 07.02.05
    cfg_we_g         :    integer := 1;   -- 07.02.05
    multicast_en_g   :    integer := 1;   -- 07.02.05
    inv_addr_en_g    :    integer := 0
    );
  port (
    clk              : in std_logic;
    rst_n            : in std_logic;

    av_in            : in  std_logic;
    data_in          : in  std_logic_vector ( data_width_g-1 downto 0);
    comm_in          : in  std_logic_vector ( comm_width_c-1 downto 0);
    cfg_rd_rdy_in    : in  std_logic;

    av_out           : out std_logic;
    data_out         : out std_logic_vector ( data_width_g-1 downto 0);
    comm_out         : out std_logic_vector ( comm_width_c-1 downto 0);
    we_out           : out std_logic;
    full_in          : in  std_logic;
    one_p_in         : in  std_logic;

    cfg_we_out       : out std_logic;
    cfg_re_out       : out std_logic;
    cfg_data_out     : out std_logic_vector ( data_width_g -1 downto 0);
    cfg_addr_out     : out std_logic_vector ( cfg_addr_width_g -1 downto 0);  --03.04.05
    cfg_ret_addr_out : out std_logic_vector ( addr_width_g -1 downto 0);
    full_out         : out std_logic
    );
end receiver;

architecture structural of receiver is

  component  addr_decoder
    generic (
      data_width_g      :     integer := 32;
      addr_width_g      :     integer := 32;  -- in bits
      id_width_g        :     integer := 4;
      id_g              :     integer := 5;
      base_id_g         :     integer := 5;
      addr_g            :     integer := 46;
      cfg_re_g          :     integer := 1;   -- 07.02.05
      cfg_we_g          :     integer := 1;   -- 07.02.05
      multicast_en_g    :     integer := 1;   -- 07.02.05
      inv_addr_en_g     :     integer := 0
      );
    port (
      addr_in           : in  std_logic_vector ( addr_width_g -1 downto 0);
      comm_in           : in  std_logic_vector ( comm_width_c -1 downto 0);
      enable_in         : in  std_logic;
      base_id_match_out : out std_logic;
      addr_match_out    : out std_logic
      );
  end component; --addr_decoder;

  component rx_control
    generic (
      data_width_g     :     integer := 32;
      addr_width_g     :     integer := 25;  -- in bits!
      id_width_g       :     integer := 5;   --  04.03.2005
      cfg_addr_width_g :     integer := 16;  -- in bits 04.03.2005
      cfg_re_g         :     integer := 1;   -- 07.02.05
      cfg_we_g         :     integer := 1    -- 07.02.05
      );
    port (
      clk              : in  std_logic;
      rst_n            : in  std_logic;
      av_in            : in  std_logic;
      data_in          : in  std_logic_vector ( data_width_g-1 downto 0);
      comm_in          : in  std_logic_vector ( comm_width_c-1 downto 0);
      full_in          : in  std_logic;
      one_p_in         : in  std_logic;
      cfg_rd_rdy_in    : in  std_logic;      --16.05
      addr_match_in    : in  std_logic;
      decode_addr_out  : out std_logic_vector ( addr_width_g -1 downto 0);
      decode_comm_out  : out std_logic_vector ( comm_width_c-1 downto 0);
      decode_en_out    : out std_logic;
      data_out         : out std_logic_vector ( data_width_g-1 downto 0);
      comm_out         : out std_logic_vector ( comm_width_c-1 downto 0);
      av_Out           : out std_logic;
      we_Out           : out std_logic;
      full_Out         : out std_logic;
      cfg_we_Out       : out std_logic;
      cfg_re_Out       : out std_logic;
      cfg_data_out     : out std_logic_vector ( data_width_g-1 downto 0);
      cfg_addr_out     : out std_logic_vector ( cfg_addr_width_g -1 downto 0);
      cfg_ret_addr_out : out std_logic_vector ( addr_width_g -1 downto 0)
      );
  end component;  --rx_control;


  -- From rx_ctrl to addr decoder
  signal addr_rx_dec   : std_logic_vector ( addr_width_g-1 downto 0);
  signal comm_rx_dec   : std_logic_vector ( comm_width_c-1 downto 0);
  signal enable_rx_dec : std_logic;

  -- From addr decoder to rx_ctrl
  signal addr_match_dec_rx : std_logic;


  signal Tie_High : std_logic;
  signal Tie_Low  : std_logic;

begin  -- structural

  -- Concurrent assignments
  Tie_High <= '1';
  Tie_Low  <= '0';


  Control : rx_control                       -- for design compiler
  -- Control : entity work.rx_control
    generic map(
      data_width_g     => data_width_g,
      addr_width_g     => addr_width_g,
      id_width_g       => id_width_g,        --04-03-05
      cfg_addr_width_g => cfg_addr_width_g,  -- 04.03.05
      cfg_re_g         => cfg_re_g,
      cfg_we_g         => cfg_we_g
      )
    port map(
      clk              => clk,
      rst_n            => rst_n,
      av_in            => av_in,
      data_in          => data_in,
      comm_in          => comm_in,
      addr_Match_in    => addr_match_dec_rx,
      decode_addr_out  => addr_rx_dec,
      decode_comm_out  => comm_rx_dec,
      decode_en_out    => enable_rx_dec,
      cfg_rd_rdy_in    => cfg_rd_rdy_in,     --16.05

      full_in         => full_in,
      one_p_in        => one_p_in,
      data_out        => data_out,
      comm_out        => comm_out,
      av_out          => av_out,
      we_out          => we_out,

      cfg_we_out       => cfg_we_out,
      cfg_re_out       => cfg_re_out,
      full_out         => full_out,
      cfg_data_out     => cfg_data_out,
      cfg_addr_out     => cfg_addr_out,
      cfg_ret_addr_out => cfg_ret_addr_out
      );


  Decoder : addr_decoder
  -- Decoder : entity work.addr_decoder 
    generic map (
      data_width_g   => data_width_g,
      addr_width_g   => addr_width_g,
      id_width_g     => id_width_g,
      id_g           => id_g,
      base_id_g      => base_id_g,
      addr_g         => addr_g,
      cfg_re_g       => cfg_re_g,        -- 07.02.05
      cfg_we_g       => cfg_we_g,        -- 07.02.05
      multicast_en_g => multicast_en_g,  -- 07.02.05
      inv_addr_en_g  => inv_addr_en_g
      )
    port map (
      addr_in        => addr_rx_dec,
      comm_in        => comm_rx_dec,
      enable_in      => enable_rx_dec,
      --base_id_match_out => 
      addr_match_out => addr_match_dec_rx
      );


end structural;
