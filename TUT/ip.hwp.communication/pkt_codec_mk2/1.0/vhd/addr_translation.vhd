-------------------------------------------------------------------------------
-- Title      : Address translation unit
-- Project    : 
-------------------------------------------------------------------------------
-- File       : addr_translation.vhd
-- Author     : Lasse Lehtonen
-- Company    : 
-- Created    : 2011-10-12
-- Last update: 2012-05-04
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description:
--
-- Translates various addressing styles to network adresses and also
-- handles inserting the original address behind the network address flit.
--
-- Generics:
--
-- address_mode_g 0 : IP gives raw network address
-- address_mode_g 1 : IP gives integer ID numbers as target address
-- address_mode_g 2 : IP gives memory mapped addresses
--
-- addr_flit_en_g 0 : Nothing done
-- addr_flit_en_g 1 : Places the original address to the second flit
--
-------------------------------------------------------------------------------
-- Copyright (c) 2011 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2011-10-12  1.0      lehton87        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity addr_translation is
  
  generic (
    my_id_g        : natural;
    cmd_width_g    : positive;
    data_width_g   : positive;
    address_mode_g : natural;
    cols_g         : positive;
    rows_g         : positive;
    agents_g       : positive;
    agent_ports_g  : positive;
    addr_flit_en_g : natural;
    noc_type_g     : natural;
    len_width_g    : natural            -- 2012-05-04
    );
  port (
    clk           : in  std_logic;
    rst_n         : in  std_logic;
    -- from IP side
    ip_cmd_in     : in  std_logic_vector(cmd_width_g-1 downto 0);
    ip_data_in    : in  std_logic_vector(data_width_g-1 downto 0);
    ip_stall_out  : out std_logic;
    ip_len_in     : in  std_logic_vector(len_width_g-1 downto 0);  -- 2012-05-04
    -- to NET
    net_cmd_out   : out std_logic_vector(cmd_width_g-1 downto 0);
    net_data_out  : out std_logic_vector(data_width_g-1 downto 0);
    net_stall_in  : in  std_logic;
    orig_addr_out : out std_logic_vector(data_width_g-1 downto 0));

end addr_translation;


architecture rtl of addr_translation is

  signal addr_to_lut   : std_logic_vector(data_width_g-1 downto 0);
  signal addr_from_lut : std_logic_vector(data_width_g-1 downto 0);
  signal orig_addr_r   : std_logic_vector(data_width_g-1 downto 0);
  
begin  -- rtl

  safe_p : process (ip_cmd_in, ip_data_in)
  begin  -- process safe_p
    if ip_cmd_in = "01" then
      addr_to_lut <= ip_data_in;
    else
      addr_to_lut <= (others => '0');
    end if;
  end process safe_p;

  addr_lut_1 : entity work.address_lut
    generic map (
      my_id_g        => my_id_g,
      data_width_g   => data_width_g,
      address_mode_g => address_mode_g,
      cols_g         => cols_g,
      rows_g         => rows_g,
      agent_ports_g  => agent_ports_g,
      agents_g       => agents_g,
      noc_type_g     => noc_type_g,
      len_width_g    => len_width_g     -- 2012-05-04
      )
    port map (
      addr_in  => addr_to_lut,
      len_in   => ip_len_in,            -- 2012-05-04
      addr_out => addr_from_lut
      );

  net_cmd_out   <= ip_cmd_in;
  ip_stall_out  <= net_stall_in;
  orig_addr_out <= orig_addr_r;

  oa_p : process (clk, rst_n)
  begin  -- process oa_p
    if rst_n = '0' then                 -- asynchronous reset (active low)
      orig_addr_r <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if ip_cmd_in = "01" then
        orig_addr_r <= ip_data_in;
      end if;
    end if;
  end process oa_p;

  mux_p : process (ip_cmd_in, addr_from_lut, ip_data_in)
  begin  -- process mux_p
    if ip_cmd_in = "01" then
      net_data_out <= addr_from_lut;
    else
      net_data_out <= ip_data_in;
    end if;
  end process mux_p;

  
  
end rtl;
