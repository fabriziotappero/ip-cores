-- package for constants

library ieee;
use ieee.std_logic_1164.all;

package lan91c111_ctrl_pkg is

  constant lan91_data_width_c : integer := 32;

  -- Note: LAN91C111 has 15 bits wide address bus, which they index from 1 to 15.
  -- Altera (for S180 dev board) erroneously lists total of 20 bits ranging
  -- from 0 to 19, but the traces on the PCB for bits 0 and 16...19 go
  -- nowhere!
  constant lan91_addr_width_c : integer := 15;

  -- LAN91C111 very cleverly uses only 3 bits of its 15 bit wide
  -- address bus. Apparently, about two or three more bits are used for
  -- indexing multiple LAN91C111 devices on the same bus, but you couldn't
  -- easily do that anyway because they all default to the same base address.
  -- (You could configure that with an EEPROM.)

  constant real_addr_width_c : integer := 3;
  constant base_addr_c : std_logic_vector(lan91_addr_width_c-real_addr_width_c-1 downto 0) := "000000110000";

  -- To clarify this (this was a bit difficult to first find in the datasheet, so I had to
  -- reverse-engineer):
  -- A15 A14 A13 A12 A11 A10 A09 A08 A07 A06 A05 A04 A03 A02 A01
  --  0   0   0   0   0   0   1   1   0   0   0   0  |REAL ADDR|
  -- |        I call this part base_addr_c          |
  
  constant tx_len_w_c : integer := 11;
  constant sleep_time_w_c : integer := 32;
  constant submodules_c : integer := 3;
  
  -- MAC address of the device
  constant MAC_addr_c : std_logic_vector( 47 downto 0 ) := x"ACDCABBACD00";
--  constant MAC_addr_c : std_logic_vector( 47 downto 0 ) := x"000000000000";
  
  constant MAC_len_c : integer := 6;
  constant eth_header_len_c : integer := 20;  -- STATUS WORD, BYTE COUNT, dst MAC,
                                              -- src MAC, type, CONTROL
                                              -- BYTE/LAST DATA BYTE, total 20
                                              -- bytes or 10 words.
  constant eth_checksum_len_c : integer := 4;

  -- sleeping times
  constant clk_hz_c : integer := 25000000;  -- used only to calculate sleeping
                                            -- times.

  constant max_sleep_c : integer := clk_hz_c*3+1;

  -- sleeping times
  constant power_up_sleep_c : integer := 75000;  -- 3 ms with 25MHz
  constant reset_sleep_c : integer := 125;  -- 5 us with 25MHz


end lan91c111_ctrl_pkg;
