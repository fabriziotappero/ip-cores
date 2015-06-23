-------------------------------------------------------------------------------
-- Title      : Multiclock FIFO
-- Project    : 
-------------------------------------------------------------------------------
-- File       : multiclk_fifo.vhd
-- Author     : kulmala3
-- Created    : 16.12.2005
-- Last update: 16.08.2006
-- Description: Synchronous multi-clock FIFO. Note that clock frequencies MUST
-- be related (synchronized) in order to avoid metastability.
-- Clocks that are asynchronous wrt. each other do not work.
--
-- Note! data must be ready in the data in wrt. faster clock when writing!
-- same applies for re and we
--
-- This one uses slow full and empty for the corresponding slower clock (i.e.
-- reader is slower -> empty is delayed). eg. empty transition from 1->0 is
-- delayed.
--
-- In this implementation we really utilize both clocks, whch can be a problem
-- in some systems (routing the another clock).
-------------------------------------------------------------------------------
-- Copyright (c) 2005 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 16.12.2005  1.0      AK      Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity threeclk_fifo is

  generic (
    re_freq_g    :    integer := 1;     -- integer multiple of clk_we
    we_freq_g    :    integer := 1;     -- or vice versa
    tmp_freq_g   :    integer := 1;     -- integer multiple of both clk_re and clk_we
    depth_g      :    integer := 1;
    data_width_g :    integer := 1
    );
  port (
    clk_re       : in std_logic;
    clk_we       : in std_logic;
    clk_tmp      : in std_logic;
    rst_n        : in std_logic;

    data_in   : in  std_logic_vector (data_width_g-1 downto 0);
    we_in     : in  std_logic;
    full_out  : out std_logic;
    one_p_out : out std_logic;

    re_in     : in  std_logic;
    data_out  : out std_logic_vector (data_width_g-1 downto 0);
    empty_out : out std_logic;
    one_d_out : out std_logic
    );
end threeclk_fifo;

architecture structural of threeclk_fifo is

--   component multiclk_fifo
--     generic (
--       re_freq_g    :    integer := 0;     -- integer multiple of clk_we
--       we_freq_g    :    integer := 0;     -- or vice versa
--       depth_g      :    integer := 0;
--       data_width_g :    integer := 0
--       );
--     port (
--       clk_re       : in std_logic;
--       clk_we       : in std_logic;
--       rst_n        : in std_logic;

--       data_in   : in  std_logic_vector (data_width_g-1 downto 0);
--       we_in     : in  std_logic;
--       full_out  : out std_logic;
--       one_p_out : out std_logic;

--       re_in     : in  std_logic;
--       data_out  : out std_logic_vector (data_width_g-1 downto 0);
--       empty_out : out std_logic;
--       one_d_out : out std_logic
--       );                         
--   end component;

   signal data_wef_ref   : std_logic_vector (data_width_g-1 downto 0);
   signal we_to_ref      : std_logic;
   signal full_from_ref  : std_logic;
   signal one_p_from_ref : std_logic;
   signal re_to_wef      : std_logic;
   signal empty_from_wef : std_logic;


begin  -- structural



   we_fifo : entity work.multiclk_fifo
     generic map (
       re_freq_g    => tmp_freq_g,
       we_freq_g    => we_freq_g,
       data_width_g => data_width_g,
       depth_g      => depth_g
       )
     port map(
       clk_we       => clk_we,
       clk_re       => clk_tmp,
       rst_n        => rst_n,

       data_in  => data_in,
       we_in    => we_in,
       full_out => full_out,
       one_p_out => one_p_out,

       data_out  => data_wef_ref,
       re_in     => re_to_wef,
       empty_out => empty_from_wef
       --one_d_out 
       );


   re_to_wef <= not full_from_ref;
   we_to_ref <= not empty_from_wef;
  

  re_fifo : entity work.multiclk_fifo
    generic map (
      re_freq_g    => re_freq_g,
      we_freq_g    => tmp_freq_g,
      data_width_g => data_width_g,
      depth_g      => depth_g/2
      )
    port map(
      clk_we       => clk_tmp,
      clk_re       => clk_re,
      rst_n        => rst_n,

      data_in  => data_wef_ref,
      we_in    => we_to_ref,
      full_out => full_from_ref,
      one_p_out => one_p_from_ref,

      data_out  => data_out,
      re_in     => re_in,
      empty_out => empty_out,
      one_d_out => one_d_out
      );


  


end structural;
