-------------------------------------------------------------------------------
-- Title      : Package for constants
-- Project    : UDP2HIBI
-------------------------------------------------------------------------------
-- File       : udp2hibi_pkg.vhd
-- Author     : Jussi Nieminen
-- Last update: 2012-03-22
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: (see the title...)
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2009/12/02  1.0      niemin95	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package udp2hibi_pkg is

  -- **************************************
  -- * udp2hibi headers and conf packets: *
  -- **************************************

  constant id_hi_idx_c : integer := 31;
  constant id_lo_idx_c : integer := 28;
  
  -- tx configuration:
  -----------------------------------------------------------------------------
  -- 31_28,27___________________________0
  -- |0x0 |   28 bits: timeout value     |
  
  -- 31_________________________________0
  -- |     32 bits: destination IP       |
  
  -- 31_____________16,15_______________0
  -- | 16b: dest port | 16b: source port |
  
  -- 31_________________________________0
  -- |    32 bits: sender's hibi addr    |

  constant tx_conf_header_id_c : std_logic_vector( 3 downto 0 ) := x"0";
  constant timeout_w_c : integer := 28;
  -----------------------------------------------------------------------------

  
  -- tx data:
  -----------------------------------------------------------------------------
  -- 31_28,27________17,16______________0
  -- |0x1 | 11b:tx_len | 17b:don't care |

  -- 31_____24,23____17,16_____8,7______0
  -- | byte 3 | byte 2 | byte 1 | byte 0 |

  -- etc...

  constant tx_data_header_id_c : std_logic_vector( 3 downto 0 ) := x"1";
  constant tx_len_w_c : integer := 11;
  -----------------------------------------------------------------------------

  
  -- tx release:
  -----------------------------------------------------------------------------
  -- 31_28,27___________________________0
  -- |0x2 |   28 bits: don't care        |

  constant tx_release_header_id_c : std_logic_vector( 3 downto 0 ) := x"2";
  -----------------------------------------------------------------------------


  -- rx configuration:
  -----------------------------------------------------------------------------
  -- 31_28,27___________________________0
  -- |0x3 |   28 bits: don't care        |
  
  -- 31_________________________________0
  -- |        32 bits: source IP         |
  
  -- 31_____________16,15_______________0
  -- | 16b: dest port | 16b: source port |
  
  -- 31_________________________________0
  -- |     32 bits: dest hibi addr       |

  constant rx_conf_header_id_c : std_logic_vector( 3 downto 0 ) := x"3";
  -----------------------------------------------------------------------------


  -- rx data:
  -----------------------------------------------------------------------------
  -- 31_28,27________17,16______________0
  -- |0x4 | 11b:rx_len | 17b:don't care |

  -- 31_____24,23____17,16_____8,7______0
  -- | byte 3 | byte 2 | byte 1 | byte 0 |

  -- etc...

  constant rx_data_header_id_c : std_logic_vector( 3 downto 0 ) := x"4";
  -----------------------------------------------------------------------------


  -- ack:
  -----------------------------------------------------------------------------
  -- 31_28,27,26________________________0
  -- |0x5 |?x|    27 bits: don't care    |

  -- if bit 27 = '1': tx configuration ack, else rx conf ack

  constant ack_header_id_c : std_logic_vector( 3 downto 0 ) := x"5";
  constant tx_conf_ack_id_c : std_logic := '1';
  constant rx_conf_ack_id_c : std_logic := '0';
  -----------------------------------------------------------------------------


  -- nack:
  -----------------------------------------------------------------------------
  -- 31_28,27,26________________________0
  -- |0x6 |?x|    27 bits: don't care    |

  -- if bit 27 = '1': tx configuration nack, else rx conf nack

  constant nack_header_id_c : std_logic_vector( 3 downto 0 ) := x"6";
  -----------------------------------------------------------------------------

  
  -- **************************************************************************

  -- just to avoid plain literals:
  constant ip_addr_w_c        : integer := 32;        -- bits
  constant udp_port_w_c       : integer := 16;        -- bits
  constant udp_block_data_w_c : integer := 16;        -- bits
  constant udp_block_freq_c   : integer := 25000000;  --1/s, 25MHz

end udp2hibi_pkg;
