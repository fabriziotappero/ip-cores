-------------------------------------------------------------------------------
-- Title      : DCT QI DCT block and dct_2_hibi together
-- Project    : 
-------------------------------------------------------------------------------
-- File       : dctqidct_top.vhd
-- Author     : 
-- Company    : 
-- Created    : 2006-07-13
-- Last update: 2006-08-03
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Copyright (c) 2006 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2006-07-13  1.0      rasmusa Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library dct;
library idct;
library quantizer;
library dctQidct;

use dct.DCT_pkg.all;
use idct.IDCT_pkg.all;
use quantizer.Quantizer_pkg.all;

entity dctqidct_top is
  
  generic (
    data_width_g  : integer := 32;
    comm_width_g  : integer := 3;
    use_self_rel_g : integer := 1;
    own_address_g : integer := 0;
    rtm_address_g : integer := 0;
    debug_w_g : integer := 1
    );

  port (
    clk   : in std_logic;
    rst_n : in std_logic;

    data_in  : in  std_logic_vector(data_width_g-1 downto 0);
    comm_in  : in  std_logic_vector(comm_width_g-1 downto 0);
    av_in    : in  std_logic;
    empty_in : in  std_logic;
    re_out   : out std_logic;
    data_out : out std_logic_vector(data_width_g-1 downto 0);
    comm_out : out std_logic_vector(comm_width_g-1 downto 0);
    av_out   : out std_logic;
    we_out   : out std_logic;
    full_in  : in  std_logic;
    debug_out: out std_logic_vector(debug_w_g-1 downto 0) );

end dctqidct_top;

architecture structural of dctqidct_top is

  component dct_to_hibi
    generic (
      data_width_g  : integer;
      comm_width_g  : integer;
      dct_width_g   : integer;
      quant_width_g : integer;
      idct_width_g  : integer;
      use_self_rel_g : integer;
      own_address_g : integer;
      rtm_address_g : integer;
      debug_w_g : integer );
    port (
      clk            : in  std_logic;
      rst_n               : in  std_logic;
      hibi_av_out         : out std_logic;
      hibi_data_out       : out std_logic_vector (data_width_g-1 downto 0);
      hibi_comm_out       : out std_logic_vector (comm_width_g-1 downto 0);
      hibi_we_out         : out std_logic;
      hibi_re_out         : out std_logic;
      hibi_av_in          : in  std_logic;
      hibi_data_in        : in  std_logic_vector (data_width_g-1 downto 0);
      hibi_comm_in        : in  std_logic_vector (comm_width_g-1 downto 0);
      hibi_empty_in       : in  std_logic;
      hibi_full_in        : in  std_logic;
      wr_dct_out          : out std_logic;
      quant_ready4col_out : out std_logic;
      idct_ready4col_out  : out std_logic;
      data_dct_out        : out std_logic_vector(DCT_inputw_co-1 downto 0);
      intra_out           : out std_logic;
      loadQP_out          : out std_logic;
      QP_out              : out std_logic_vector (4 downto 0);
      chroma_out          : out std_logic;
      data_idct_in        : in  std_logic_vector(IDCT_resultw_co-1 downto 0);
      data_quant_in       : in  std_logic_vector(QUANT_resultw_co-1 downto 0);
      dct_ready4col_in    : in  std_logic;
      wr_idct_in          : in  std_logic;
      wr_quant_in         : in  std_logic;
      debug_out    : out std_logic_vector(debug_w_g-1 downto 0) );
  end component;

  component dctQidct_core
    port (
      QP_in                 : in  std_logic_vector (4 downto 0);
      chroma_in             : in  std_logic;
      clk                   : in  std_logic;
      data_dct_in           : in  std_logic_vector (DCT_inputw_co-1 downto 0);
      idct_ready4column_in  : in  std_logic;
      intra_in              : in  std_logic;
      loadQP_in             : in  std_logic;
      quant_ready4column_in : in  std_logic;
      rst_n                 : in  std_logic;
      wr_dct_in             : in  std_logic;
      data_idct_out         : out std_logic_vector (IDCT_resultw_co-1 downto 0);
      data_quant_out        : out std_logic_vector (QUANT_resultw_co-1 downto 0);
      dct_ready4column_out  : out std_logic;
      wr_idct_out           : out std_logic;
      wr_quant_out          : out std_logic);
  end component;

  signal QP                 : std_logic_vector (4 downto 0);
  signal chroma             : std_logic;
  signal data_dct           : std_logic_vector (DCT_inputw_co-1 downto 0);
  signal idct_ready4column  : std_logic;
  signal intra              : std_logic;
  signal loadQP             : std_logic;
  signal quant_ready4column : std_logic;
  signal wr_dct             : std_logic;
  signal data_idct          : std_logic_vector (IDCT_resultw_co-1 downto 0);
  signal data_quant         : std_logic_vector (QUANT_resultw_co-1 downto 0);
  signal dct_ready4column   : std_logic;
  signal wr_idct            : std_logic;
  signal wr_quant           : std_logic;


begin  -- structural
 
  
  dct_to_hibi_1_12 : dct_to_hibi
    generic map (
      data_width_g  => data_width_g,
      comm_width_g  => comm_width_g,
      dct_width_g   => DCT_inputw_co,
      quant_width_g => QUANT_resultw_co,
      idct_width_g  => IDCT_resultw_co,
      use_self_rel_g => use_self_rel_g,
      own_address_g => own_address_g,
      rtm_address_g => rtm_address_g,
      debug_w_g => debug_w_g )
    port map (
      clk          => clk,
      rst_n         => rst_n,
      hibi_av_out   => av_out,
      hibi_data_out => data_out,
      hibi_comm_out => comm_out,
      hibi_we_out   => we_out,
      hibi_re_out   => re_out,
      hibi_av_in    => av_in,
      hibi_data_in  => data_in,
      hibi_comm_in  => comm_in,
      hibi_empty_in => empty_in,
      hibi_full_in  => full_in,

      wr_dct_out          => wr_dct,
      quant_ready4col_out => quant_ready4column,
      idct_ready4col_out  => idct_ready4column,
      data_dct_out        => data_dct,
      intra_out           => intra,
      loadQP_out          => loadQP,
      QP_out              => QP,
      chroma_out          => chroma,
      data_idct_in        => data_idct,
      data_quant_in       => data_quant,
      dct_ready4col_in    => dct_ready4column,
      wr_idct_in          => wr_idct,
      wr_quant_in         => wr_quant,
      debug_out     => debug_out );

  dctQidct_core_1 : dctQidct_core
    port map (
      QP_in                 => QP,
      chroma_in             => chroma,
      clk                   => clk,
      data_dct_in           => data_dct,
      idct_ready4column_in  => idct_ready4column,
      intra_in              => intra,
      loadQP_in             => loadQP,
      quant_ready4column_in => quant_ready4column,
      rst_n                 => rst_n,
      wr_dct_in             => wr_dct,
      data_idct_out         => data_idct,
      data_quant_out        => data_quant,
      dct_ready4column_out  => dct_ready4column,
      wr_idct_out           => wr_idct,
      wr_quant_out          => wr_quant);


end structural;
