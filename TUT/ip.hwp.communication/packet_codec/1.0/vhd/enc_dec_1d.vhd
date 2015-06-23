-------------------------------------------------------------------------------
-- File        : enc_dec_1d.vhd
-- Description : Makes a packet encode-decode structure
--
-- Author      : Vesa Lahtinen
-- Date        : 28.11.2003
-- Modified    : 23.08.2006 Modified to fit all nets.
--
-------------------------------------------------------------------------------

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


library ieee;
use ieee.std_logic_1164.all;
--use work.system_pkg.all;

entity enc_dec_1d is
  generic (
    n_ag_g       : integer := 4;

    wait_empty_fifo_g : integer := 0;
    data_width_g      : integer := 36;
    addr_width_g      : integer := 32;
    packet_length_g   : integer := 8;
    tx_len_width_g    : integer := 8;
    timeout_g         : integer := 0;
    fill_packet_g     : integer := 0;

    lut_en_g        : integer := 1;
    net_type_g      : integer;
    len_flit_en_g   : integer := 1;     -- 2007/08/03 where to place a pkt_len
    oaddr_flit_en_g : integer := 1;     -- 2007/08/03 whether to send the orig address
    status_en_g     : integer := 0

    );  
  port (
    Clk   : in std_logic;  --std_logic_vector (n_ag_g-1 downto 0);
    Rst_n : in std_logic;

    --Encoder stuff
    av_ip_enc_in     : in  std_logic_vector (n_ag_g-1 downto 0); 
    data_ip_enc_in   : in  std_logic_vector (n_ag_g * data_width_g -1 downto 0);
    we_ip_enc_in     : in  std_logic_vector (n_ag_g-1 downto 0);
    len_ip_enc_in    : in  std_logic_vector (n_ag_g*tx_len_width_g-1 downto 0);
    full_enc_ip_out  : out std_logic_vector (n_ag_g-1 downto 0);
    empty_enc_ip_out : out std_logic_vector (n_ag_g-1 downto 0);


    av_enc_net_out   : out std_logic_vector (n_ag_g-1 downto 0);  --14.10.2006
    data_enc_net_out : out std_logic_vector (n_ag_g * data_width_g -1 downto 0); 
    we_enc_net_out   : out std_logic_vector (n_ag_g-1 downto 0);
    full_net_enc_in  : in  std_logic_vector (n_ag_g-1 downto 0);
    empty_net_enc_in : in  std_logic_vector (n_ag_g-1 downto 0);

    --Decoder stuff
    data_net_dec_in  : in  std_logic_vector (n_ag_g * data_width_g -1 downto 0); 
    re_dec_net_out   : out std_logic_vector (n_ag_g-1 downto 0);
    full_net_dec_in  : in  std_logic_vector (n_ag_g-1 downto 0);
    empty_net_dec_in : in  std_logic_vector (n_ag_g-1 downto 0);

    av_dec_ip_out    : out std_logic_vector (n_ag_g-1 downto 0);
    data_dec_ip_out  : out std_logic_vector (n_ag_g * data_width_g -1 downto 0); 
    re_ip_dec_in     : in  std_logic_vector (n_ag_g-1 downto 0);
    empty_dec_ip_out : out std_logic_vector (n_ag_g-1 downto 0) 
    );

end enc_dec_1d;

architecture structural of enc_dec_1d is

  constant wait_empty_fifo_c : integer := 0;
  -- has to be 1 with store-and-forward net!!!
  -- 17.02.2006: see if 0 works with cut-through maesh

  component packet_encoder_decoder
    generic (
      wait_empty_fifo_g :    integer;
      data_width_g      :    integer;
      addr_width_g      :    integer;
      tx_len_width_g    :    integer;
      packet_length_g   :    integer;
      timeout_g         :    integer;
      fill_packet_g     :    integer;
      lut_en_g          :    integer;
      net_type_g        :    integer;
      len_flit_en_g     :    integer := 1;  -- 2007/08/03 where to place a pkt_len
      oaddr_flit_en_g   :    integer := 1;  -- 2007/08/03 whether to send the orig address
      status_en_g       :    integer := 0
      );
    port (
      clk               : in std_logic;
      rst_n             : in std_logic;

      av_ip_enc_in     : in  std_logic;
      data_ip_enc_in   : in  std_logic_vector(data_width_g-1 downto 0);
      we_ip_enc_in     : in  std_logic;
      len_ip_enc_in    : in  std_logic_vector(tx_len_width_g-1 downto 0);
      full_enc_ip_out  : out std_logic;
      empty_enc_ip_out : out std_logic;

      av_dec_ip_out    : out std_logic;
      data_dec_ip_out  : out std_logic_vector(data_width_g-1 downto 0);
      re_ip_dec_in     : in  std_logic;
      empty_dec_ip_out : out std_logic;

      av_enc_net_out   : out std_logic;
      data_enc_net_out : out std_logic_vector(data_width_g-1 downto 0);
      we_enc_net_out   : out std_logic;
      full_net_enc_in  : in  std_logic;
      empty_net_enc_in : in  std_logic;

      data_net_dec_in  : in  std_logic_vector(data_width_g-1 downto 0);
      empty_net_dec_in : in  std_logic;
      re_dec_net_out   : out std_logic
      );
  end component;
  
  
begin  -- structural


  mpa_enc_dec       : for i in 0 to n_ag_g-1 generate
    encoder_decoder : packet_encoder_decoder
      generic map (
        wait_empty_fifo_g => wait_empty_fifo_g,
        data_width_g      => data_width_g,
        addr_width_g      => addr_width_g,
        tx_len_width_g    => tx_len_width_g,
        packet_length_g   => packet_length_g,
        timeout_g         => timeout_g,
        lut_en_g          => lut_en_g,
        fill_packet_g     => fill_packet_g,
        net_type_g        => net_type_g,
        len_flit_en_g     => len_flit_en_g,   -- 2007/08/03
        oaddr_flit_en_g   => oaddr_flit_en_g,  -- 2007/08/03
        status_en_g       => status_en_g

        )
      port map(
        clk   => clk,                   -- (i),
        rst_n => rst_n,

        av_ip_enc_in     => av_ip_enc_in (i),
        data_ip_enc_in   => data_ip_enc_in (((i+1)*data_width_g)-1 downto ((i)*data_width_g)),  --(r)(c),
        we_ip_enc_in     => we_ip_enc_in (i),
        len_ip_enc_in    => len_ip_enc_in( (i+1)*tx_len_width_g-1 downto i*tx_len_width_g ),
        full_enc_ip_out  => full_enc_ip_out (i),
        empty_enc_ip_out => empty_enc_ip_out (i),

        av_enc_net_out   => av_enc_net_out (i),
        data_enc_net_out => data_enc_net_out (((i+1)*data_width_g)-1 downto ((i)*data_width_g)),  --(r)(c)
        we_enc_net_out   => we_enc_net_out (i),
        full_net_enc_in  => full_net_enc_in (i),
        empty_net_enc_in => empty_net_enc_in (i),


        data_net_dec_in  => data_net_dec_in (((i+1)*data_width_g)-1 downto ((i)*data_width_g)),  --(r)(c)
        re_dec_net_out   => re_dec_net_out (i),
        empty_net_dec_in => empty_net_dec_in (i),

        av_dec_ip_out    => av_dec_ip_out (i),
        data_dec_ip_out  => data_dec_ip_out (((i+1)*data_width_g)-1 downto ((i)*data_width_g)),  --(r)(c),
        empty_dec_ip_out => empty_dec_ip_out (i),
        re_ip_dec_in     => re_ip_dec_in (i)
        );

  end generate mpa_enc_dec;

end structural;





