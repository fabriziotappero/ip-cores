-------------------------------------------------------------------------------
-- File        : packet_encoder_decoder.vhdl
-- Description : encode and decodes packets 
-- Author      : Vesa Lahtinen
-- Date        : 23.10.2003
-- Modified    : 
-- 27.04.2005   ES: New fifo
-- 23.08.2006   AR: new generics and support for LUT
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity packet_encoder_decoder is
  generic (
    wait_empty_fifo_g   : integer := 0;  -- before writing new pkt to net
    data_width_g        : integer := 36;  -- in bits
    addr_width_g        : integer := 32;
    tx_len_width_g     : integer := 8;
    packet_length_g     : integer := 3;  -- words= payload + hdr
    timeout_g           : integer := 0;  -- how many cycles wait for pkt completion
    fill_packet_g       : integer := 0;  -- fill pkt with dummy data
    lut_en_g            : integer := 1;
    net_type_g          : integer;      -- 0 MESH, 1 Octagon
    len_flit_en_g      : integer := 1;  -- 2007/08/03 where to place a pkt_len
    oaddr_flit_en_g : integer := 1;  -- 2007/08/03 whether to send the orig address
    dbg_en_g            : integer := 0;
    dbg_width_g         : integer := 1;
    status_en_g         : integer := 0
    );

  port (
    clk   : in std_logic;
    rst_n : in std_logic;

    -- Signals between IP block and encoder
    av_ip_enc_in     : in  std_logic;
    data_ip_enc_in   : in  std_logic_vector (data_width_g-1 downto 0);
    we_ip_enc_in     : in  std_logic;
    len_ip_enc_in    : in  std_logic_vector( tx_len_width_g-1 downto 0 );
    full_enc_ip_out  : out std_logic;
    empty_enc_ip_out : out std_logic;

    -- Signals between network and encoder
    av_enc_net_out   : out std_logic;
    data_enc_net_out : out std_logic_vector (data_width_g-1 downto 0);
    we_enc_net_out   : out std_logic;
    full_net_enc_in  : in  std_logic;
    empty_net_enc_in : in  std_logic;

    -- Signals between network and decoder
    data_net_dec_in  : in  std_logic_vector (data_width_g-1 downto 0);
    empty_net_dec_in : in  std_logic;
    re_dec_net_out   : out std_logic;

    -- Signals between IP block and decoder
    av_dec_ip_out    : out std_logic;
    data_dec_ip_out  : out std_logic_vector (data_width_g-1 downto 0);
    re_ip_dec_in     : in  std_logic;
    empty_dec_ip_out : out std_logic;

    dbg_out          : out std_logic_vector(dbg_width_g - 1 downto 0)
    );

end packet_encoder_decoder;

architecture structural of packet_encoder_decoder is

  constant fifo_width_c : integer := data_width_g +1;  -- data + av
  constant fifo_depth_c : integer := packet_length_g;  -- payload_words + hdr_words


  component packet_encoder_ctrl
    generic (
      wait_empty_fifo_g   :    integer := 0;
      data_width_g        :    integer := 0;
      addr_width_g        :    integer := 32;  -- lsb part of data_width_g
      tx_len_width_g      :    integer := 4;
      packet_length_g     :    integer := 0;
      timeout_g           :    integer := 0;
      fill_packet_g       :    integer := 0;
      lut_en_g            :    integer := 1;
      net_type_g          :    integer;
      len_flit_en_g      :    integer := 1;  -- 2007/08/03 where to place a pkt_len
      oaddr_flit_en_g :    integer := 1;  -- 2007/08/03 whether to send the orig address
      dbg_en_g            :    integer;
      dbg_width_g         :    integer;
      status_en_g         :    integer := 0
      );
    port (
      clk                 : in std_logic;
      rst_n               : in std_logic;

      ip_av_in      : in  std_logic;
      ip_data_in    : in  std_logic_vector (data_width_g-1 downto 0);
      ip_we_in      : in  std_logic;
      ip_tx_len_in  : in  std_logic_vector (tx_len_width_g-1 downto 0);
      ip_stall_out  : out std_logic;

      fifo_av_in    : in  std_logic;
      fifo_data_in  : in  std_logic_vector (data_width_g-1 downto 0);
      fifo_re_out   : out std_logic;
      fifo_full_in  : in  std_logic;
      fifo_empty_in : in  std_logic;

      net_av_out   : out std_logic;
      net_data_out : out std_logic_vector (data_width_g-1 downto 0);
      net_we_out   : out std_logic;
      net_empty_in : in  std_logic;
      net_full_in  : in  std_logic;
      dbg_out      : out std_logic_vector(dbg_width_g - 1 downto 0)
      );
  end component;

  component packet_decoder_ctrl
    generic (
      data_width_g    :    integer := 0;
      addr_width_g    :    integer := 0;
      pkt_len_g       :    integer := 0;
      fill_packet_g   :    integer := 0;
      len_flit_en_g   :    integer := 1;  -- 2007/08/03 where to place a pkt_len
      oaddr_flit_en_g :    integer := 1;  -- 2007/08/03 whether to send the orig address
      dbg_en_g        :    integer;
      dbg_width_g     :    integer
      );
    port (
      clk             : in std_logic;
      rst_n           : in std_logic;

      net_data_in  : in  std_logic_vector (data_width_g-1 downto 0);
      net_empty_in : in  std_logic;
      net_re_out   : out std_logic;

      fifo_av_out   : out std_logic;
      fifo_data_out : out std_logic_vector (data_width_g-1 downto 0);
      fifo_we_out   : out std_logic;
      fifo_full_in  : in  std_logic;
      dbg_out       : out std_logic_vector(dbg_width_g - 1 downto 0)
      );
  end component;

  component fifo
    generic (
      data_width_g : integer := 0;
      depth_g      : integer := 0
      );
    port (
      clk   : in std_logic;
      rst_n : in std_logic;

      data_in   : in  std_logic_vector (data_width_g-1 downto 0);
      we_in     : in  std_logic;
      full_out  : out std_logic;
      one_p_out : out std_logic;

      data_out  : out std_logic_vector (data_width_g-1 downto 0);
      re_in     : in  std_logic;
      empty_out : out std_logic;
      one_d_out : out std_logic
      );

  end component;

  -- dbg signals
  signal enc_dbg : std_logic_vector(dbg_width_g - 1 downto 0);
  signal dec_dbg : std_logic_vector(dbg_width_g - 1 downto 0);

  -- Signals for enc-fifo
  signal d_av_to_encfifo    : std_logic_vector (fifo_width_c-1 downto 0) ;-- (data_width_g+1-1 downto 0);
  signal d_av_from_encfifo  : std_logic_vector (fifo_width_c-1 downto 0) ;-- (data_width_g+1-1 downto 0);
  signal full_from_encfifo  : std_logic;
  signal empty_from_encfifo : std_logic;
  signal we_to_encfifo      : std_logic;

  -- Signals for encoding
  signal av_fifo_enc   : std_logic;
  signal data_fifo_enc : std_logic_vector (data_width_g-1 downto 0);
  signal re_enc_fifo   : std_logic;
  signal stall_from_enc : std_logic;

  -- Signals between the control and the fifo of decoder
  signal d_av_to_decfifo   : std_logic_vector (fifo_width_c-1 downto 0) ;-- (data_width_g+1-1 downto 0);
  signal d_av_from_decfifo : std_logic_vector (fifo_width_c-1 downto 0) ;-- (data_width_g+1-1 downto 0);

  signal av_dec_fifo   : std_logic;
  signal data_dec_fifo : std_logic_vector (data_width_g-1 downto 0);
  signal we_dec_fifo   : std_logic;
  signal full_fifo_dec : std_logic;

begin

  -- for xbar_util_mon
  gen_dbg: if dbg_en_g = 1 generate
    dbg_out(0) <= we_ip_enc_in and
                  not(stall_from_enc or full_from_encfifo) and
                  not(av_ip_enc_in);
  end generate gen_dbg;

  -- Concurrent assignments
  -- 1) outputs
  full_enc_ip_out  <= stall_from_enc or full_from_encfifo;
  empty_enc_ip_out <= empty_from_encfifo;
  av_dec_ip_out    <= d_av_from_decfifo (0);
  data_dec_ip_out  <= d_av_from_decfifo (data_width_g downto 1);

  -- 2) to enc-fifo
  we_to_encfifo                          <= we_ip_enc_in and not(stall_from_enc);
  d_av_to_encfifo(data_width_g downto 1) <= data_ip_enc_in;
  d_av_to_encfifo(0)                     <= av_ip_enc_in;

  -- 3) to encoder ctrl
  data_fifo_enc <= d_av_from_encfifo (data_width_g downto 1);
  av_fifo_enc   <= d_av_from_encfifo (0);

  -- 4) to dec-fifo
  d_av_to_decfifo (data_width_g downto 1) <= data_dec_fifo;
  d_av_to_decfifo (0)                     <= av_dec_fifo;



  encode_control : packet_encoder_ctrl
    generic map (
      wait_empty_fifo_g => wait_empty_fifo_g,
      data_width_g      => data_width_g,
      addr_width_g      => addr_width_g,
      tx_len_width_g    => tx_len_width_g,
      packet_length_g   => packet_length_g,
      timeout_g         => timeout_g,
      fill_packet_g     => fill_packet_g,
      lut_en_g          => lut_en_g,
      net_type_g        => net_type_g,
      len_flit_en_g     => len_flit_en_g,    -- 2007/08/03
      oaddr_flit_en_g   => oaddr_flit_en_g,  -- 2007/08/03
      dbg_en_g          => dbg_en_g,
      dbg_width_g       => dbg_width_g,
      status_en_g       => status_en_g
      )
    port map (
      clk               => clk,
      rst_n             => rst_n,

      ip_av_in      => av_ip_enc_in,
      ip_data_in    => data_ip_enc_in,
      ip_we_in      => we_ip_enc_in,
      ip_tx_len_in  => len_ip_enc_in,
      ip_stall_out  => stall_from_enc,

      fifo_av_in    => av_fifo_enc,
      fifo_data_in  => data_fifo_enc,
      fifo_full_in  => full_from_encfifo,
      fifo_empty_in => empty_from_encfifo,
      fifo_re_out   => re_enc_fifo,

      net_av_out   => av_enc_net_out,
      net_data_out => data_enc_net_out,
      net_we_out   => we_enc_net_out,
      net_empty_in => empty_net_enc_in,
      net_full_in  => full_net_enc_in,
      dbg_out      => enc_dbg
      );


  decode_control : packet_decoder_ctrl
    generic map (
      data_width_g    => data_width_g,
      addr_width_g    => addr_width_g,
      pkt_len_g       => packet_length_g,
      fill_packet_g   => fill_packet_g,
      len_flit_en_g   => len_flit_en_g,    -- 2007/08/03
      oaddr_flit_en_g => oaddr_flit_en_g,  -- 2007/08/03
      dbg_en_g        => dbg_en_g,
      dbg_width_g     => dbg_width_g
      )
    port map (
      clk             => clk,
      rst_n           => rst_n,

      net_data_in  => data_net_dec_in,
      net_empty_in => empty_net_dec_in,
      net_re_out   => re_dec_net_out,

      fifo_av_out   => av_dec_fifo,
      fifo_data_out => data_dec_fifo,
      fifo_we_out   => we_dec_fifo,
      fifo_full_in  => full_fifo_dec,
      dbg_out       => dec_dbg
      );

  encode_fifo : fifo
    generic map (
      data_width_g => fifo_width_c,
      depth_g      => fifo_depth_c
      )
    port map (
      clk       => clk,
      rst_n     => rst_n,
      data_In   => d_av_to_encfifo,
      we_in     => we_to_encfifo,
      full_out  => full_from_encfifo,
      data_out  => d_av_from_encfifo,
      re_in     => re_enc_fifo,
      empty_out => empty_from_encfifo
      );


  decode_fifo : fifo
    generic map (
      data_width_g => fifo_width_c,
      depth_g      => fifo_depth_c
      )
    port map (
      clk       => clk,
      rst_n     => rst_n,
      data_In   => d_av_to_decfifo,
      we_in     => we_dec_fifo,
      full_out  => full_fifo_dec,
      data_out  => d_av_from_decfifo,
      re_in     => re_ip_dec_in,
      empty_out => empty_dec_ip_out
      );

end structural;
