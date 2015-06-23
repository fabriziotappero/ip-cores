-------------------------------------------------------------------------------
-- Title      : data mux
-- Project    : 
-------------------------------------------------------------------------------
-- File       : udp_arp_data_mux.vhd
-- Author     : Jussi Nieminen  <niemin95@galapagosinkeiju.cs.tut.fi>
-- Last update: 2010-08-18
-------------------------------------------------------------------------------
-- Description: Multiplexer.
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2009/09/15  1.0      niemin95        Created
-------------------------------------------------------------------------------




library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.udp_ip_pkg.all;

entity udp_arp_data_mux is

  generic (
    data_width_g : integer := 16;
    tx_len_w_g   : integer := 11
    );

  port (
    rx_data_valid_in   : in  std_logic;
    new_rx_in          : in  std_logic;
    rx_data_in         : in  std_logic_vector( data_width_g-1 downto 0 );
    rx_res_in          : in  std_logic_vector( 2 downto 0 );
    rx_re_out          : out std_logic;
    rx_datas_out       : out std_logic_vector( 3*data_width_g-1 downto 0 );
    rx_data_valids_out : out std_logic_vector( 2 downto 0 );
    new_rxs_out        : out std_logic_vector( 1 downto 0 );
    tx_datas_in        : in  std_logic_vector( 3*data_width_g-1 downto 0 );
    tx_data_valids_in  : in  std_logic_vector( 2 downto 0 );
    tx_target_MACs_in  : in  std_logic_vector( 2*MAC_addr_w_c-1 downto 0 );
    tx_lens_in         : in  std_logic_vector( 2*tx_len_w_g-1 downto 0 );
    tx_frame_types_in  : in  std_logic_vector( 2*frame_type_w_c-1 downto 0 );
    new_txs_in         : in  std_logic_vector( 1 downto 0 );
    tx_re_in           : in  std_logic;
    tx_data_out        : out std_logic_vector( data_width_g-1 downto 0 );
    tx_data_valid_out  : out std_logic;
    tx_target_MAC_out  : out std_logic_vector( MAC_addr_w_c-1 downto 0 );
    tx_len_out         : out std_logic_vector( tx_len_w_g-1 downto 0 );
    tx_frame_type_out  : out std_logic_vector( frame_type_w_c-1 downto 0 );
    new_tx_out         : out std_logic;
    tx_res_out         : out std_logic_vector( 2 downto 0 );
    input_select_in    : in  std_logic_vector( 1 downto 0 );
    output_select_in   : in  std_logic_vector( 1 downto 0 )
    );

end udp_arp_data_mux;


architecture rtl of udp_arp_data_mux is

  signal input_select_int  : integer range 0 to 2;
  signal output_select_int : integer range 0 to 2;
  
  type tx_data_array is array (0 to 2) of std_logic_vector( udp_data_width_c-1 downto 0 );
  signal rx_datas_array_r : tx_data_array;
  signal tx_datas_array_r : tx_data_array;

  type MAC_array is array (0 to 1) of std_logic_vector( MAC_addr_w_c-1 downto 0 );
  signal MAC_addr_array_r : MAC_array;
  type frame_type_array is array (0 to 1) of std_logic_vector( frame_type_w_c-1 downto 0 );
  signal frame_type_array_r : frame_type_array;
  type tx_lens_array is array (0 to 1) of std_logic_vector( tx_len_w_c-1 downto 0 );
  signal tx_lens_array_r : tx_lens_array;

  constant udp_selected_c : integer := 0;
  constant arp_selected_c : integer := 1;
  constant app_selected_c : integer := 2;

-------------------------------------------------------------------------------
begin  -- rtl
-------------------------------------------------------------------------------

  input_select_int  <= to_integer( unsigned( input_select_in ));
  output_select_int <= to_integer( unsigned( output_select_in ));
  -- 0: UDP
  -- 1: ARP
  -- 2: application

  
  datas: for n in 0 to 2 generate
    rx_datas_out( (n+1)*udp_data_width_c-1 downto n*udp_data_width_c ) <= rx_datas_array_r(n);
    tx_datas_array_r(n) <= tx_datas_in( (n+1)*udp_data_width_c-1 downto n*udp_data_width_c );
  end generate datas;

  other_arrays: for n in 0 to 1 generate
    MAC_addr_array_r(n)   <= tx_target_MACs_in( (n+1)*MAC_addr_w_c-1 downto n*MAC_addr_w_c );
    frame_type_array_r(n) <= tx_frame_types_in( (n+1)*frame_type_w_c-1 downto n*frame_type_w_c );
    tx_lens_array_r(n)    <= tx_lens_in( (n+1)*tx_len_w_c-1 downto n*tx_len_w_c );
  end generate other_arrays;
  
  

  eth_data_mux : process (rx_data_in, rx_data_valid_in, new_rx_in, input_select_int,
                          output_select_int, rx_res_in, tx_datas_array_r, tx_data_valids_in,
                          MAC_addr_array_r, tx_lens_array_r, frame_type_array_r, new_txs_in,
                          tx_re_in)
  begin  -- process eth_data_mux

    -- ** INPUTS **
    -- default values. Others than the selected range stay as zero.
    rx_datas_array_r   <= (others => (others => '0'));
    rx_data_valids_out <= (others => '0');
    new_rxs_out        <= (others => '0');

    rx_datas_array_r(input_select_int) <= rx_data_in;
    rx_data_valids_out( input_select_int ) <= rx_data_valid_in;

    if input_select_int /= app_selected_c then
      new_rxs_out( input_select_int ) <= new_rx_in;
    else
      -- if data is going to application, also the udp block needs to have the
      -- data_valid signal (to know when reading really happens. Plain re from
      -- application isn't enough, cause it can be up even if data_valid is down.)
      rx_data_valids_out(udp_selected_c) <= rx_data_valid_in;
    end if;
    

    rx_re_out <= rx_res_in( input_select_int );

    -- ** OUTPUTS **
    tx_data_out         <= tx_datas_array_r( output_select_int );
    tx_data_valid_out   <= tx_data_valids_in( output_select_int );
    -- only data and data_valid can come from application, others come either
    -- from arp or udp
    if output_select_int /= app_selected_c then
      tx_target_MAC_out <= MAC_addr_array_r( output_select_int );
      tx_len_out        <= tx_lens_array_r( output_select_int );
      tx_frame_type_out <= frame_type_array_r( output_select_int );
      new_tx_out        <= new_txs_in( output_select_int );
    else
      -- if data is coming from the application, these signals have been set by
      -- udp block
      tx_target_MAC_out <= MAC_addr_array_r( udp_selected_c );
      tx_len_out        <= tx_lens_array_r( udp_selected_c );
      tx_frame_type_out <= frame_type_array_r( udp_selected_c );
      new_tx_out        <= new_txs_in( udp_selected_c );
    end if;

    tx_res_out                      <= (others => '0');
    tx_res_out( output_select_int ) <= tx_re_in;

  end process eth_data_mux;

end rtl;
