-------------------------------------------------------------------------------
--
-- (c) Copyright 2009-2011 Xilinx, Inc. All rights reserved.
--
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
--
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
--
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
--
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
--
-------------------------------------------------------------------------------
-- Project    : Virtex-6 Integrated Block for PCI Express
-- File       : test_interface.vhd
-- Version    : 2.3
---- Description:  Procedures invoked by the test program file.
----
----
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

-- Package Declaration

package test_interface is

type BYTE_ARRAY             is array (999 downto 0) of std_logic_vector(7 downto 0);
type DATA_ARRAY             is array (499 downto 0) of std_logic_vector(7 downto 0);
type THIRTY_THREE_BIT_ARRAY is array (6 downto 0) of std_logic_vector((33 - 1) downto 0);
type DWORD_ARRAY            is array (6 downto 0) of std_logic_vector((32 - 1) downto 0);
type ENABLE_ARRAY           is array (6 downto 0) of INTEGER;

constant PCI_EXP_MEM_READ32            : std_logic_vector(6 downto 0) := "0000000";
constant PCI_EXP_IO_READ               : std_logic_vector(6 downto 0) := "0000010";
constant PCI_EXP_CFG_READ0             : std_logic_vector(6 downto 0) := "0000100";
constant PCI_EXP_COMPLETION_WO_DATA    : std_logic_vector(6 downto 0) := "0001010";
constant PCI_EXP_MEM_READ64            : std_logic_vector(6 downto 0) := "0100000";
constant PCI_EXP_MSG_NODATA            : std_logic_vector(6 downto 3) := "0110";
constant PCI_EXP_MEM_WRITE32           : std_logic_vector(6 downto 0) := "1000000";
constant PCI_EXP_IO_WRITE              : std_logic_vector(6 downto 0) := "1000010";
constant PCI_EXP_CFG_WRITE0            : std_logic_vector(6 downto 0) := "1000100";
constant PCI_EXP_COMPLETION_DATA       : std_logic_vector(6 downto 0) := "1001010";
constant PCI_EXP_MEM_WRITE64           : std_logic_vector(6 downto 0) := "1100000";
constant PCI_EXP_MSG_DATA              : std_logic_vector(6 downto 3) := "1110";

constant COMPLETER_ID_CFG              : std_logic_vector(15 downto 0) := X"01A0";

constant DEV_ID                        : std_logic_vector(15 downto 0) := X"6011";
constant VEN_ID                        : std_logic_vector(15 downto 0) := X"10EE";
constant DEV_VEN_ID                    : std_logic_vector(31 downto 0) := (DEV_ID & VEN_ID);
constant MAX_LINK_SPEED                : integer := 1;

signal trn_trem_n_c    : std_logic_vector ((8  - 1) downto 0 );
signal trn_td_c        : std_logic_vector ((64 - 1) downto 0 );

shared variable frame_store_tx          : BYTE_ARRAY;
shared variable frame_store_tx_idx      : INTEGER;
shared variable DATA_STORE              : DATA_ARRAY;
shared variable P_READ_DATA             : std_logic_vector(31 downto 0);
shared variable Lglobal                 : line;
shared variable BAR_RANGE               : DWORD_ARRAY;
shared variable BAR                     : THIRTY_THREE_BIT_ARRAY;
shared variable NUMBER_OF_IO_BARS       : INTEGER;
shared variable NUMBER_OF_MEM64_BARS    : INTEGER;
shared variable NUMBER_OF_MEM32_BARS    : INTEGER;
shared variable BAR_ENABLED             : ENABLE_ARRAY;
shared variable pio_check_design : boolean;
shared variable i                       : INTEGER;
shared variable success                 : boolean;

-- Cfg Rd/Wr interface signals
type cfg_rdwr_sigs is record
  trn_clk          : std_logic;
  trn_reset_n      : std_logic;
  cfg_rd_wr_done_n : std_logic;
  cfg_dwaddr       : std_logic_vector(9 downto 0);
  cfg_di           : std_logic_vector(31 downto 0);
  cfg_do           : std_logic_vector(31 downto 0);
  cfg_byte_en_n    : std_logic_vector(3 downto 0);
  cfg_wr_en_n      : std_logic;
  cfg_rd_en_n      : std_logic;
end record;
signal cfg_rdwr_int : cfg_rdwr_sigs := (trn_clk => 'Z', trn_reset_n => 'Z', cfg_rd_wr_done_n => '1', cfg_dwaddr => (OTHERS => '0'), cfg_di => x"00000000", cfg_do => x"00000000", cfg_byte_en_n => "1111", cfg_wr_en_n => '1', cfg_rd_en_n => '1');


file tx_file : TEXT open write_mode is "tx.dat";

procedure writeNowToTx (  text_string     : in string);

procedure writeHexToTx (  text_string     : in string;
                                               hexValue        : in std_logic_vector);

procedure writeNowToScreen (text_string     : in string);


procedure FINISH;

procedure FINISH_FAILURE;

procedure PROC_TX_SYNCHRONIZE (

  first : in INTEGER;
  last_call: in INTEGER;
  signal trn_lnk_up_n : in std_logic;
  signal trn_tdst_rdy_n : in std_logic;
  signal trn_clk : in std_logic

);

procedure PROC_TX_TYPE0_CONFIGURATION_READ (

  tag                      : in std_logic_vector (7 downto 0);
  reg_addr                 : in std_logic_vector (11 downto 0);
  first_dw_be              : in std_logic_vector (3 downto 0);
  signal trn_td_c          : out std_logic_vector(63 downto 0);
  signal trn_tsof_n        : out std_logic;
  signal trn_teof_n        : out std_logic;
  signal trn_trem_n_c      : out std_logic_vector(7 downto 0);
  signal trn_tsrc_rdy_n    : out std_logic;
  signal trn_lnk_up_n : in std_logic;
  signal trn_tdst_rdy_n : in std_logic;
  signal trn_clk : in std_logic

);


procedure PROC_TX_TYPE0_CONFIGURATION_WRITE (

  tag                      : in std_logic_vector (7 downto 0);
  reg_addr                 : in std_logic_vector (11 downto 0);
  reg_data                 : in std_logic_vector (31 downto 0);
  first_dw_be              : in std_logic_vector (3 downto 0);
  signal trn_td_c          : out std_logic_vector(63 downto 0);
  signal trn_tsof_n        : out std_logic;
  signal trn_teof_n        : out std_logic;
  signal trn_trem_n_c      : out std_logic_vector(7 downto 0);
  signal trn_tsrc_rdy_n    : out std_logic;
  signal trn_lnk_up_n : in std_logic;
  signal trn_tdst_rdy_n : in std_logic;
  signal trn_clk : in std_logic

);

procedure PROC_TX_TYPE1_CONFIGURATION_READ (

  tag                      : in std_logic_vector (7 downto 0);
  reg_addr                 : in std_logic_vector (11 downto 0);
  first_dw_be              : in std_logic_vector (3 downto 0);
  signal trn_td_c          : out std_logic_vector(63 downto 0);
  signal trn_tsof_n        : out std_logic;
  signal trn_teof_n        : out std_logic;
  signal trn_trem_n_c      : out std_logic_vector(7 downto 0);
  signal trn_tsrc_rdy_n    : out std_logic;
  signal trn_lnk_up_n : in std_logic;
  signal trn_tdst_rdy_n : in std_logic;
  signal trn_clk : in std_logic

);

procedure PROC_TX_TYPE1_CONFIGURATION_WRITE (

  tag                      : in std_logic_vector (7 downto 0);
  reg_addr                 : in std_logic_vector (11 downto 0);
  reg_data                 : in std_logic_vector (31 downto 0);
  first_dw_be              : in std_logic_vector (3 downto 0);
  signal trn_td_c          : out std_logic_vector(63 downto 0);
  signal trn_tsof_n        : out std_logic;
  signal trn_teof_n        : out std_logic;
  signal trn_trem_n_c      : out std_logic_vector(7 downto 0);
  signal trn_tsrc_rdy_n    : out std_logic;
  signal trn_lnk_up_n : in std_logic;
  signal trn_tdst_rdy_n : in std_logic;
  signal trn_clk : in std_logic

);

procedure PROC_TX_MEMORY_READ_32 (

  tag                      : in std_logic_vector (7 downto 0);
  tc                       : in std_logic_vector (2 downto 0);
  len                      : in std_logic_vector (9 downto 0);
  addr                     : in std_logic_vector (31 downto 0);
  last_dw_be               : in std_logic_vector (3 downto 0);
  first_dw_be              : in std_logic_vector (3 downto 0);
  signal trn_td_c          : out std_logic_vector(63 downto 0);
  signal trn_tsof_n        : out std_logic;
  signal trn_teof_n        : out std_logic;
  signal trn_trem_n_c      : out std_logic_vector(7 downto 0);
  signal trn_tsrc_rdy_n    : out std_logic;
  signal trn_lnk_up_n : in std_logic;
  signal trn_tdst_rdy_n : in std_logic;
  signal trn_clk : in std_logic


);

procedure PROC_TX_MEMORY_READ_64 (

  tag                      : in std_logic_vector (7 downto 0);
  tc                       : in std_logic_vector (2 downto 0);
  len                      : in std_logic_vector (9 downto 0);
  addr                     : in std_logic_vector (63 downto 0);
  last_dw_be               : in std_logic_vector (3 downto 0);
  first_dw_be              : in std_logic_vector (3 downto 0);
  signal trn_td_c          : out std_logic_vector(63 downto 0);
  signal trn_tsof_n        : out std_logic;
  signal trn_teof_n        : out std_logic;
  signal trn_trem_n_c      : out std_logic_vector(7 downto 0);
  signal trn_tsrc_rdy_n    : out std_logic;
  signal trn_lnk_up_n : in std_logic;
  signal trn_tdst_rdy_n : in std_logic;
  signal trn_clk : in std_logic


);

procedure PROC_TX_MEMORY_WRITE_32 (

  tag                         : in std_logic_vector (7 downto 0);
  tc                          : in std_logic_vector (2 downto 0);
  len                         : in std_logic_vector (9 downto 0);
  addr                        : in std_logic_vector (31 downto 0);
  last_dw_be                  : in std_logic_vector (3 downto 0);
  first_dw_be                 : in std_logic_vector (3 downto 0);
  ep                          : in std_logic;
  signal trn_td_c             : out std_logic_vector(63 downto 0);
  signal trn_tsof_n           : out std_logic;
  signal trn_teof_n           : out std_logic;
  signal trn_trem_n_c         : out std_logic_vector(7 downto 0);
  signal trn_tsrc_rdy_n       : out std_logic;
  signal trn_terrfwd_n        : out std_logic;
  signal trn_lnk_up_n : in std_logic;
  signal trn_tdst_rdy_n : in std_logic;
  signal trn_clk : in std_logic


);


procedure PROC_TX_MEMORY_WRITE_64 (

  tag                         : in std_logic_vector (7 downto 0);
  tc                          : in std_logic_vector (2 downto 0);
  len                         : in std_logic_vector (9 downto 0);
  addr                        : in std_logic_vector (63 downto 0);
  last_dw_be                  : in std_logic_vector (3 downto 0);
  first_dw_be                 : in std_logic_vector (3 downto 0);
  ep                          : in std_logic;
  signal trn_td_c             : out std_logic_vector(63 downto 0);
  signal trn_tsof_n           : out std_logic;
  signal trn_teof_n           : out std_logic;
  signal trn_trem_n_c         : out std_logic_vector(7 downto 0);
  signal trn_tsrc_rdy_n       : out std_logic;
  signal trn_terrfwd_n        : out std_logic;
  signal trn_lnk_up_n : in std_logic;
  signal trn_tdst_rdy_n : in std_logic;
  signal trn_clk : in std_logic


);


procedure PROC_TX_COMPLETION (

  tag                      : in std_logic_vector (7 downto 0);
  tc                       : in std_logic_vector (2 downto 0);
  len                      : in std_logic_vector (9 downto 0);
  comp_status              : in std_logic_vector (2 downto 0);
  signal trn_td_c          : out std_logic_vector(63 downto 0);
  signal trn_tsof_n        : out std_logic;
  signal trn_teof_n        : out std_logic;
  signal trn_trem_n_c      : out std_logic_vector(7 downto 0);
  signal trn_tsrc_rdy_n    : out std_logic;
  signal trn_lnk_up_n : in std_logic;
  signal trn_tdst_rdy_n : in std_logic;
  signal trn_clk : in std_logic

);

procedure PROC_TX_COMPLETION_DATA (

  tag                      : in std_logic_vector (7 downto 0);
  tc                       : in std_logic_vector (2 downto 0);
  len                      : in std_logic_vector (9 downto 0);
  byte_count               : in std_logic_vector (11 downto 0);
  lower_addr               : in std_logic_vector (6 downto 0);
  comp_status              : in std_logic_vector (2 downto 0);
  ep                       : in std_logic;
  signal trn_td_c          : out std_logic_vector(63 downto 0);
  signal trn_tsof_n        : out std_logic;
  signal trn_teof_n        : out std_logic;
  signal trn_trem_n_c      : out std_logic_vector(7 downto 0);
  signal trn_tsrc_rdy_n    : out std_logic;
  signal trn_terrfwd_n     : out std_logic;
  signal trn_lnk_up_n : in std_logic;
  signal trn_tdst_rdy_n : in std_logic;
  signal trn_clk : in std_logic

);

procedure PROC_TX_MESSAGE (

  tag                      : in std_logic_vector (7 downto 0);
  tc                       : in std_logic_vector (2 downto 0);
  len                      : in std_logic_vector (9 downto 0);
  data                     : in std_logic_vector (63 downto 0);
  message_rtg              : in std_logic_vector (2 downto 0);
  message_code             : in std_logic_vector (7 downto 0);
  signal trn_td_c          : out std_logic_vector(63 downto 0);
  signal trn_tsof_n        : out std_logic;
  signal trn_teof_n        : out std_logic;
  signal trn_trem_n_c      : out std_logic_vector(7 downto 0);
  signal trn_tsrc_rdy_n    : out std_logic;
  signal trn_lnk_up_n : in std_logic;
  signal trn_tdst_rdy_n : in std_logic;
  signal trn_clk : in std_logic

);

procedure PROC_TX_MESSAGE_DATA (

  tag                      : in std_logic_vector (7 downto 0);
  tc                       : in std_logic_vector (2 downto 0);
  len                      : in std_logic_vector (9 downto 0);
  data                     : in std_logic_vector (63 downto 0);
  message_rtg              : in std_logic_vector (2 downto 0);
  message_code             : in std_logic_vector (7 downto 0);
  signal trn_td_c          : out std_logic_vector(63 downto 0);
  signal trn_tsof_n        : out std_logic;
  signal trn_teof_n        : out std_logic;
  signal trn_trem_n_c      : out std_logic_vector(7 downto 0);
  signal trn_tsrc_rdy_n    : out std_logic;
  signal trn_lnk_up_n : in std_logic;
  signal trn_tdst_rdy_n : in std_logic;
  signal trn_clk : in std_logic

);

procedure PROC_TX_IO_READ (

  tag                      : in std_logic_vector (7 downto 0);
  addr                     : in std_logic_vector (31 downto 0);
  first_dw_be              : in std_logic_vector (3 downto 0);
  signal trn_td_c          : out std_logic_vector(63 downto 0);
  signal trn_tsof_n        : out std_logic;
  signal trn_teof_n        : out std_logic;
  signal trn_trem_n_c      : out std_logic_vector(7 downto 0);
  signal trn_tsrc_rdy_n    : out std_logic;
  signal trn_lnk_up_n : in std_logic;
  signal trn_tdst_rdy_n : in std_logic;
  signal trn_clk : in std_logic

);

procedure PROC_TX_IO_WRITE (

  tag                      : in std_logic_vector (7 downto 0);
  addr                     : in std_logic_vector (31 downto 0);
  first_dw_be              : in std_logic_vector (3 downto 0);
  data                     : in std_logic_vector(31 downto 0);
  signal trn_td_c          : out std_logic_vector(63 downto 0);
  signal trn_tsof_n        : out std_logic;
  signal trn_teof_n        : out std_logic;
  signal trn_trem_n_c      : out std_logic_vector(7 downto 0);
  signal trn_tsrc_rdy_n    : out std_logic;
  signal trn_lnk_up_n : in std_logic;
  signal trn_tdst_rdy_n : in std_logic;
  signal trn_clk : in std_logic

);

procedure PROC_USR_DATA_SETUP_SEQ;

procedure PROC_TX_CLK_EAT  (

  clock_count : in INTEGER;
  signal trn_clk : in std_logic

);

procedure PROC_SET_READ_DATA  (

  be     : in std_logic_vector(3 downto 0);
  data   : in std_logic_vector(31 downto 0)

);

procedure PROC_WAIT_FOR_READ_DATA  (

  signal tx_rx_read_data_valid    : out std_logic;
  signal rx_tx_read_data_valid    : in std_logic;
  signal rx_tx_read_data : in std_logic_vector(31 downto 0);
  signal trn_clk : in std_logic

);

procedure PROC_DISPLAY_PCIE_MAP  (

  BAR            : THIRTY_THREE_BIT_ARRAY;
  BAR_ENABLED    : ENABLE_ARRAY;
  BAR_RANGE      : DWORD_ARRAY

);

procedure PROC_BUILD_PCIE_MAP
;

procedure PROC_BAR_SCAN  (

  signal tx_rx_read_data_valid : out std_logic;
  signal rx_tx_read_data_valid : in std_logic;
  signal rx_tx_read_data : in std_logic_vector (31 downto 0);
  signal trn_td_c : out std_logic_vector(63 downto 0);
  signal trn_tsof_n : out std_logic;
  signal trn_teof_n : out std_logic;
  signal trn_trem_n_c : out std_logic_vector(7 downto 0);
  signal trn_tsrc_rdy_n : out std_logic;
  signal trn_lnk_up_n : in std_logic;
  signal trn_tdst_rdy_n : in std_logic;
  signal trn_clk : in std_logic

);

procedure PROC_BAR_PROGRAM  (

  signal trn_td_c          : out std_logic_vector(63 downto 0);
  signal trn_tsof_n        : out std_logic;
  signal trn_teof_n        : out std_logic;
  signal trn_trem_n_c      : out std_logic_vector(7 downto 0);
  signal trn_tsrc_rdy_n    : out std_logic;
  signal trn_lnk_up_n : in std_logic;
  signal trn_tdst_rdy_n : in std_logic;
  signal trn_clk : in std_logic

);

procedure PROC_BAR_INIT  (

  signal tx_rx_read_data_valid : out std_logic;
  signal rx_tx_read_data_valid : in std_logic;
  signal rx_tx_read_data : in std_logic_vector (31 downto 0);
  signal trn_td_c : out std_logic_vector(63 downto 0);
  signal trn_tsof_n : out std_logic;
  signal trn_teof_n : out std_logic;
  signal trn_trem_n_c : out std_logic_vector(7 downto 0);
  signal trn_tsrc_rdy_n : out std_logic;
  signal trn_lnk_up_n : in std_logic;
  signal trn_tdst_rdy_n : in std_logic;
  signal trn_clk : in std_logic

 );

procedure PROC_SYSTEM_INITIALIZATION(
     signal trn_reset_n: in std_logic;
     signal trn_lnk_up_n: in std_logic;
     signal speed_change_done_n : in std_logic 
);


procedure PROC_READ_CFG_DW (
  addr                : in    std_logic_vector(9 downto 0);
  signal cfg_rdwr_int : inout cfg_rdwr_sigs
);

procedure PROC_WRITE_CFG_DW (
  addr                : in    std_logic_vector(9 downto 0);
  data                : in    std_logic_vector(31 downto 0);
  byte_en_n           : in    std_logic_vector(3 downto 0);
  signal cfg_rdwr_int : inout cfg_rdwr_sigs
);

end package test_interface;



-- Package Body

package body test_interface is

--************************************************************
--     Proc : writeNowToTx
--     Inputs : Text String
--     Outputs : None
--     Description : Displays text string to Tx file pre-appended with
--         current simulation time..
--*************************************************************

procedure writeNowToTx (

  text_string     : in string

) is

  variable L      : line;

begin

  write (L, String'("[ "));
  write (L, now);
  write (L, String'(" ] : "));
  write (L, text_string);
  writeline (tx_file, L);

end writeNowToTx;


--************************************************************
--     Proc : writeHexToTx
--     Inputs : hex value with bit width that is multiple of 4
--     Outputs : None
--     Description : Displays nibble aligned hex value to Tx file
--
--*************************************************************

procedure writeHexToTx (

  text_string     : in string;
  hexValue        : in std_logic_vector

) is

  variable L      : line;

begin

  write (L, text_string);
  hwrite(L, hexValue);
  writeline (tx_file, L);

end writeHexToTx;


--************************************************************
--     Proc : writeNowToScreen
--     Inputs : Text String
--     Outputs : None
--     Description : Displays current simulation time and text string to
--          standard output.
--*************************************************************

procedure writeNowToScreen (

  text_string     : in string

) is

  variable L      : line;

begin

  write (L, String'("[ "));
  write (L, now);
  write (L, String'(" ] : "));
  write (L, text_string);
  writeline (output, L);

end writeNowToScreen;



--************************************************************
--     Proc : PROC_READ_DATA
--     Inputs : None
--     Outputs : None
--     Description : Consume clocks.
--   *************************************************************/

procedure PROC_READ_DATA (

  last                  : in INTEGER;
  trn_d                 : in std_logic_vector (63 downto 0);
  trn_rem               : in std_logic_vector (7 downto 0)

) is

  variable i            : INTEGER;
  variable data_byte    : std_logic_vector (7 downto 0);
  variable remain       : INTEGER;
  variable hi_index     : INTEGER;
  variable low_index    : INTEGER;
  variable my_line      : line;

begin

  hi_index := 63;
  low_index := 56;
  if (last = 1) then

    if (trn_rem = X"0F") then

      remain := 4;

    else remain := 8;

    end if;

  else

    remain := 8;

  end if;
  for i in 0 to (remain - 1) loop

    data_byte := trn_d( hi_index downto low_index);
    hi_index := hi_index - 8;
    low_index := low_index - 8;
    frame_store_tx(frame_store_tx_idx) := data_byte;
    frame_store_tx_idx := frame_store_tx_idx + 1;

  end loop;

end PROC_READ_DATA;


--************************************************************
--  Proc : PROC_DECIPHER_FRAME
--  Inputs : None
-- Outputs : fmt, tlp_type, traffic_class, td, ep, attr, length
--  Description : Deciphers frame
--  *************************************************************/


procedure PROC_DECIPHER_FRAME (

  fmt                   : out std_logic_vector (1 downto 0);
  tlp_type              : out std_logic_vector (4 downto 0);
  traffic_class         : out std_logic_vector (2 downto 0);
  td                    : out std_logic;
  ep                    : out std_logic;
  attr                  : out std_logic_vector (1 downto 0);
  length                : out std_logic_vector (9 downto 0)

) is

begin

  fmt := frame_store_tx(0)(6 downto 5);
  tlp_type := frame_store_tx(0)(4 downto 0);
  traffic_class := frame_store_tx(1)(6 downto 4);
  td := frame_store_tx(2)(7);
  ep := frame_store_tx(2)(6);
  attr := frame_store_tx(2)(5 downto 4);
  length(9 downto 8) := frame_store_tx(2)(1 downto 0);
  length(7 downto 0) := frame_store_tx(3);

end PROC_DECIPHER_FRAME;


-- ************************************************************
--  Proc : PROC_3DW
--  Inputs : fmt, type, traffic_class, td, ep, attr, length,
--  payload,
--  Outputs : None
--  Description : Gets variables and prints frame
--  *************************************************************/


procedure PROC_3DW (

  fmt              : in std_logic_vector (1 downto 0);
  tlp_type         : in std_logic_vector (4 downto 0);
  traffic_class    : in std_logic_vector (2 downto 0);
  td               : in std_logic;
  ep               : in std_logic;
  attr             : in std_logic_vector (1 downto 0);
  length           : in std_logic_vector (9 downto 0);
  payload          : in INTEGER

) is

  variable requester_id         : std_logic_vector (15 downto 0);
  variable tag                  : std_logic_vector (7 downto 0);
  variable byte_enables         : std_logic_vector (7 downto 0);
  variable address_low          : std_logic_vector (31 downto 0);
  variable completer_id         : std_logic_vector (15 downto 0);
  variable register_address     : std_logic_vector (9 downto 0);
  variable completion_status    : std_logic_vector (2 downto 0);
  variable i                    : INTEGER;
  variable L                    : line;
  variable fmt_type             : std_logic_vector (6 downto 0);

begin

  writeHexToTx (String'("     Traffic Class: 0x"), '0' & traffic_class);
  write (L, String'("     TD: ")); write(L,  td); writeline (tx_file, L);
  write (L, String'("     EP: ")); write(L, ep); writeline (tx_file, L);
  writeHexToTx (String'("     Attributes: 0x"), "00" & attr);
  writeHexToTx (String'("     Length: 0x"), "00" & length);

  fmt_type := fmt & tlp_type;
  case (fmt_type) is

    when PCI_EXP_CFG_READ0 | PCI_EXP_CFG_WRITE0 =>

      requester_id := frame_store_tx(4) & frame_store_tx(5);
      tag := frame_store_tx(6);
      byte_enables := frame_store_tx(7);
      completer_id := frame_store_tx(8) & frame_store_tx(9);
      register_address(9 downto 8) := frame_store_tx(10)(1 downto 0);
      register_address(7 downto 0) := frame_store_tx(11);

      writeHexToTx ( String'("     Requester Id: 0x"), requester_id);
      writeHexToTx ( String'("     Tag: 0x"), tag);
      writeHexToTx ( String'("     Last and First Byte Enables: 0x"), byte_enables);
      writeHexToTx ( String'("     Completer Id: 0x"), completer_id);
      writeHexToTx ( String'("     Register Address: 0x"), "00" & register_address);

      if (payload = 1) then

        write (L, String'("")); writeline(tx_file, L);
        for i in 12 to (frame_store_tx_idx - 1) loop

          writeHexToTx ( String'("     0x"), frame_store_tx(i));

        end loop;

      end if;
      write (L, String'("")); writeline(tx_file, L);

    when PCI_EXP_COMPLETION_WO_DATA | PCI_EXP_COMPLETION_DATA=>

      completer_id := frame_store_tx(4) & frame_store_tx(5);
      completion_status(2 downto 0) := frame_store_tx(6)(7 downto 5);
      requester_id := frame_store_tx(8) & frame_store_tx(9);
      tag := frame_store_tx(10);

      writeHexToTx ( String'("     Completer Id: 0x"), completer_id);
      writeHexToTx ( String'("     Completion Status: 0x"), '0' & completion_status);
      writeHexToTx ( String'("     Requester Id: 0x"), requester_id);
      writeHexToTx ( String'("     Tag: 0x"), tag);

      if (payload = 1) then

        write (L, String'("")); writeline(tx_file, L);
        for i in 12 to (frame_store_tx_idx - 1) loop

                    writeHexToTx ( String'("     0x"), frame_store_tx(i));

        end loop;

      end if;
      write (L, String'("")); writeline(tx_file, L);

    when others =>

      requester_id := frame_store_tx(4) & frame_store_tx(5);
      tag := frame_store_tx(6);
      byte_enables := frame_store_tx(7);
      address_low(31 downto 24) := frame_store_tx(8);
      address_low(23 downto 16) := frame_store_tx(9);
      address_low(15 downto 8) := frame_store_tx(10);
      address_low( 7 downto 0) := frame_store_tx(11);

      writeHexToTx ( String'("     Requester Id: 0x"), requester_id);
      writeHexToTx ( String'("     Tag: 0x"), tag);
      writeHexToTx ( String'("     Last and First Byte Enables: 0x"), byte_enables);
      writeHexToTx ( String'("     Address Low: 0x"), address_low);

      if (payload = 1) then

        write (L, String'("")); writeline(tx_file, L);
        for i in 12 to (frame_store_tx_idx - 1) loop

          writeHexToTx ( String'("     0x"), frame_store_tx(i));

        end loop;

      end if;
      write (L, String'("")); writeline(tx_file, L);

  end  case;

end PROC_3DW;


-- ************************************************************
--  Proc : PROC_4DW
--  Inputs : fmt, type, traffic_class, td, ep, attr, length
--  payload
--  Outputs : None
--  Description : Gets variables and prints frame
--  *************************************************************/


procedure PROC_4DW (

  fmt              : in std_logic_vector (1 downto 0);
  tlp_type         : in std_logic_vector (4 downto 0);
  traffic_class    : in std_logic_vector (2 downto 0);
  td               : in std_logic;
  ep               : in std_logic;
  attr             : in std_logic_vector (1 downto 0);
  length           : in std_logic_vector (9 downto 0);
  payload          : in INTEGER

) is

  variable requester_id    : std_logic_vector (15 downto 0);
  variable tag             : std_logic_vector (7 downto 0);
  variable byte_enables    : std_logic_vector (7 downto 0);
  variable message_code    : std_logic_vector (7 downto 0);
  variable address_high    : std_logic_vector (31 downto 0);
  variable address_low     : std_logic_vector (31 downto 0);
  variable msg_type        : std_logic_vector (2 downto 0);
  variable i               : INTEGER;
  variable L               : line;
  variable fmt_type        : std_logic_vector (6 downto 0);

begin

  writeHexToTx (String'("     Traffic Class: 0x"), '0' & traffic_class);
  write (L, String'("     TD: ")); write(L,  td); writeline (tx_file, L);
  write (L, String'("     EP: ")); write(L, ep); writeline (tx_file, L);
  writeHexToTx (String'("     Attributes: 0x"), "00" & attr);
  writeHexToTx (String'("     Length: 0x"), "00" & length);

  requester_id := frame_store_tx(4) & frame_store_tx(5);
  tag := frame_store_tx(6);
  byte_enables := frame_store_tx(7);
  message_code := frame_store_tx(7);
  address_high(31 downto 24) := frame_store_tx(8);
  address_high(23 downto 16) := frame_store_tx(9) ;
  address_high(15 downto 8) := frame_store_tx(10);
  address_high(7 downto 0) := frame_store_tx(11);
  address_low(31 downto 24) := frame_store_tx(12);
  address_low(23 downto 16) := frame_store_tx(13);
  address_low(15 downto 8) := frame_store_tx(14) ;
  address_low(7 downto 0) := frame_store_tx(15);

  writeHexToTx ( String'("     Requester Id: 0x"), requester_id);
  writeHexToTx ( String'("     Tag: 0x"), tag);

  fmt_type := fmt & tlp_type;

  if ((fmt_type(6 downto 3) = PCI_EXP_MSG_NODATA)
     or (fmt_type(6 downto 3) = PCI_EXP_MSG_DATA)) then

    msg_type := tlp_type(2 downto 0);
    writeHexToTx ( String'("     Message Type: 0x"), '0' & msg_type);
    writeHexToTx ( String'("     Message Code: 0x"), message_code);
    writeHexToTx ( String'("     Address High: 0x"), address_high);
    writeHexToTx ( String'("     Address Low:  0x"), address_low);

    if (payload = 1) then

      write (L, String'("")); writeline(tx_file, L);
      for i in 16 to (frame_store_tx_idx - 1) loop

        writeHexToTx ( String'("     0x"), frame_store_tx(i));

      end loop;

    end if;
    write (L, String'("")); writeline(tx_file, L);

  else

    case (fmt_type) is

      when PCI_EXP_MEM_READ64 | PCI_EXP_MEM_WRITE64 =>

        writeHexToTx ( String'("     Last and First Byte Enables: 0x"), byte_enables);
        writeHexToTx ( String'("     Address High: 0x"), address_high);
        writeHexToTx ( String'("     Address Low:  0x"), address_low);

        if (payload = 1) then

          write (L, String'("")); writeline(tx_file, L);
          for i in 16 to (frame_store_tx_idx - 1) loop

            writeHexToTx ( String'("     0x"), frame_store_tx(i));

          end loop;

        end if;

        write (L, String'("")); writeline(tx_file, L);

      when others =>

        write (L, String'(": Not a vaild frame")); writeline (tx_file, L); write (L, String'("")); writeline(tx_file, L);
        assert (false)
          report "Simulation Ended"
          severity failure;

    end  case; -- (fmt_type)

  end if;

end PROC_4DW;


--************************************************************
--  Proc : PROC_PARSE_FRAME
--  Inputs : None
--  Outputs : None
--  Description : Parse frame data
--  *************************************************************/

procedure PROC_PARSE_FRAME is

  variable fmt                  : std_logic_vector (1 downto 0);
  variable tlp_type             : std_logic_vector (4 downto 0);
  variable traffic_class        : std_logic_vector (2 downto 0);
  variable td                   : std_logic;
  variable ep                   : std_logic;
  variable attr                 : std_logic_vector (1 downto 0);
  variable length               : std_logic_vector (9 downto 0);
  variable payload              : INTEGER;
  variable reqester_id          : std_logic_vector(15 downto 0);
  variable completer_id         : std_logic_vector(15 downto 0);
  variable tag                  : std_logic_vector(7 downto 0);
  variable byte_enables         : std_logic_vector(7 downto 0);
  variable message_code         : std_logic_vector(7 downto 0);
  variable address_low          : std_logic_vector(31 downto 0);
  variable address_high         : std_logic_vector(31 downto 0);
  variable register_address     : std_logic_vector (9 downto 0);
  variable completion_status    : std_logic_vector (2 downto 0);
  variable log_file_ptr         : std_logic_vector (31 downto 0);
  variable frame_store_idx      : INTEGER;
  variable fmt_type             : std_logic_vector (6 downto 0);
  variable L                    : line;

begin

  writeNowToScreen ( String'("PROC_PARSE_FRAME on Transmit"));
  PROC_DECIPHER_FRAME (fmt, tlp_type, traffic_class, td, ep, attr, length);

  -- decode the packets received based on fmt and type
  fmt_type := fmt & tlp_type;

  if (fmt_type(6 downto 3) = PCI_EXP_MSG_NODATA) then

    writeNowToTx("Message With No Data Frame");
    payload := 0;
    PROC_4DW(fmt, tlp_type, traffic_class, td, ep, attr, length, payload);

  elsif (fmt_type(6 downto 3) = PCI_EXP_MSG_DATA) then

    writeNowToTx("Message With Data Frame");
    payload := 1;
    PROC_4DW(fmt, tlp_type, traffic_class, td, ep, attr, length, payload);

  else

    case (fmt_type) is

      when PCI_EXP_MEM_READ32 =>

        writeNowToTx("Memory Read-32 Frame");
        payload := 0;
        PROC_3DW(fmt, tlp_type, traffic_class, td, ep, attr, length, payload);

      when PCI_EXP_IO_READ =>

        writeNowToTx("IO Read Frame");
        payload := 0;
        PROC_3DW(fmt, tlp_type, traffic_class, td, ep, attr, length, payload);

      when PCI_EXP_CFG_READ0 =>

        writeNowToTx("Config Read Type 0 Frame");
        payload := 0;
        PROC_3DW(fmt, tlp_type, traffic_class, td, ep, attr, length, payload);

      when PCI_EXP_COMPLETION_WO_DATA =>

        writeNowToTx("Completion Without Data Frame");
        payload := 0;
        PROC_3DW(fmt, tlp_type, traffic_class, td, ep, attr, length, payload);

      when PCI_EXP_MEM_READ64 =>

        writeNowToTx("Memory Read-64 Frame");
        payload := 0;
        PROC_4DW(fmt, tlp_type, traffic_class, td, ep, attr, length, payload);

      when PCI_EXP_MEM_WRITE32 =>

        writeNowToTx("Memory Write-32 Frame");
        payload := 1;
        PROC_3DW(fmt, tlp_type, traffic_class, td, ep, attr, length, payload);

      when PCI_EXP_IO_WRITE =>

        writeNowToTx("IO Write Frame");
        payload := 1;
        PROC_3DW(fmt, tlp_type, traffic_class, td, ep, attr, length, payload);

      when PCI_EXP_CFG_WRITE0 =>

        writeNowToTx("Config Write Type 0 Frame");
        payload := 1;
        PROC_3DW(fmt, tlp_type, traffic_class, td, ep, attr, length, payload);

      when PCI_EXP_COMPLETION_DATA =>

        writeNowToTx("Completion With Data Frame");
        payload := 1;
        PROC_3DW(fmt, tlp_type, traffic_class, td, ep, attr, length, payload);

      when PCI_EXP_MEM_WRITE64 =>

        writeNowToTx("Memory Write-64 Frame");
        payload := 1;
        PROC_4DW(fmt, tlp_type, traffic_class, td, ep, attr, length, payload);

      when others =>

        writeNowToTx("Not a vaild frame. fmt_type = ");
        write (L, fmt_type);
        writeline (tx_file, L);
        assert (false)
          report "Simulation Ended"
          severity failure;

    end  case;

  end if;

  frame_store_tx_idx := 0; -- reset frame pointer

end PROC_PARSE_FRAME;

--************************************************************
--  Proc : FINISH
--  Inputs : None
--  Outputs : None
--  Description : Ends simulation with successful message
--*************************************************************/

procedure FINISH is

  variable  L : line;

begin

  assert (false)
    report "Simulation Stopped."
    severity failure;

end FINISH;


--************************************************************
--  Proc : FINISH_FAILURE
--  Inputs : None
--  Outputs : None
--  Description : Ends simulation with failure message
--*************************************************************/

procedure FINISH_FAILURE is

  variable  L : line;

begin

  assert (false)
    report "Simulation Ended With 1 or more failures"
    severity failure;

end FINISH_FAILURE;


--************************************************************
--    Proc : PROC_TX_CLK_EAT
--    Inputs : None
--    Outputs : None
--    Description : Consume clocks.
--*************************************************************/

procedure PROC_TX_CLK_EAT  (

  clock_count : in INTEGER;
  signal trn_clk : in std_logic

) is

  variable i  : INTEGER;

begin

  for i in 0 to (clock_count - 1) loop

    wait until (trn_clk'event and trn_clk = '1');

  end loop;

end PROC_TX_CLK_EAT;


--************************************************************
--    Proc : PROC_TX_SYNCHRONIZE
--    Inputs : first_, last_call_
--    Outputs : None
--    Description : Synchronize with tx clock and handshake signals
--*************************************************************/

procedure PROC_TX_SYNCHRONIZE (

  first : in INTEGER;
  last_call: in INTEGER;
  signal trn_lnk_up_n : in std_logic;
  signal trn_tdst_rdy_n : in std_logic;
  signal trn_clk : in std_logic 

) is

  variable last  : INTEGER;

begin

  assert (trn_lnk_up_n = '0')
    report "TX Trn interface is MIA"
    severity failure;

  wait until (trn_clk'event and trn_clk = '1');

  if ((trn_tdst_rdy_n = '1') and (first = 1)) then

    while (trn_tdst_rdy_n = '1') loop

      wait until (trn_clk'event and trn_clk = '1');

    end loop;

  end if;
  if (first = 1) then

    if (trn_trem_n_c = X"00") then --"00000000") then

      last := 0;

    else

      last := 1;

    end if;

    PROC_READ_DATA(last, trn_td_c, trn_trem_n_c);

  end if;
  if (last_call = 1) then

    PROC_PARSE_FRAME;

  end if;

end PROC_TX_SYNCHRONIZE;



--************************************************************
--    Proc : PROC_TX_TYPE0_CONFIGURATION_READ
--    Inputs : Tag, PCI/PCI-Express Reg Address, First BypeEn
--    Outputs : Transaction Tx Interface Signaling
--    Description : Generates a Type 0 Configuration Read TLP
--*************************************************************/

procedure PROC_TX_TYPE0_CONFIGURATION_READ (

  tag                      : in std_logic_vector (7 downto 0);
  reg_addr                 : in std_logic_vector (11 downto 0);
  first_dw_be              : in std_logic_vector (3 downto 0);
  signal trn_td_c          : out std_logic_vector(63 downto 0);
  signal trn_tsof_n        : out std_logic;
  signal trn_teof_n        : out std_logic;
  signal trn_trem_n_c      : out std_logic_vector(7 downto 0);
  signal trn_tsrc_rdy_n    : out std_logic;
  signal trn_lnk_up_n : in std_logic;
  signal trn_tdst_rdy_n : in std_logic;
  signal trn_clk : in std_logic

) is

begin

  assert (trn_lnk_up_n = '0')
    report "TX Trn interface is MIA"
    severity failure;


  PROC_TX_SYNCHRONIZE(0, 0, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);

  trn_td_c          <= '0' &
                       "00" &
                       "00100" &
                       '0' &
                       "000" &
                       "0000" &
                       '0' &
                       '0' &
                       "00" &
                       "00" &
                       "0000000001" &
                       COMPLETER_ID_CFG &
                       tag(7 downto 0) &
                       "0000" &
                       first_dw_be(3 downto 0);
  trn_tsof_n 	    <= '0';
  trn_teof_n 	    <= '1';
  trn_trem_n_c 	    <= X"00";
  trn_tsrc_rdy_n    <= '0';

  PROC_TX_SYNCHRONIZE(1,0, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);

  trn_td_c          <= COMPLETER_ID_CFG &
                       "0000" &
                       reg_addr(11 downto 2) &
                       "00" &
                       X"00000000";
  trn_tsof_n 	    <= '1';
  trn_teof_n 	    <= '0';
  trn_trem_n_c 	    <= X"0F";
  trn_tsrc_rdy_n    <= '0';

  PROC_TX_SYNCHRONIZE(1, 1, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);

  trn_teof_n	    <= '1';
  trn_trem_n_c	    <= X"00";
  trn_tsrc_rdy_n    <= '1';

end PROC_TX_TYPE0_CONFIGURATION_READ;


--************************************************************
--    Proc : PROC_TX_TYPE0_CONFIGURATION_WRITE
--    Inputs : Tag, PCI/PCI-Express Reg Address, First BypeEn
--    Outputs : Transaction Tx Interface Signaling
--    Description : Generates a Type 0 Configuration Write TLP
--*************************************************************/

procedure PROC_TX_TYPE0_CONFIGURATION_WRITE (

  tag                      : in std_logic_vector (7 downto 0);
  reg_addr                 : in std_logic_vector (11 downto 0);
  reg_data                 : in std_logic_vector (31 downto 0);
  first_dw_be              : in std_logic_vector (3 downto 0);
  signal trn_td_c          : out std_logic_vector(63 downto 0);
  signal trn_tsof_n        : out std_logic;
  signal trn_teof_n        : out std_logic;
  signal trn_trem_n_c      : out std_logic_vector(7 downto 0);
  signal trn_tsrc_rdy_n    : out std_logic;
  signal trn_lnk_up_n : in std_logic;
  signal trn_tdst_rdy_n : in std_logic;
  signal trn_clk : in std_logic

) is

begin

  assert (trn_lnk_up_n = '0')
    report "TX Trn interface is MIA"
    severity failure;


  PROC_TX_SYNCHRONIZE(0, 0, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);

  trn_td_c <=          '0' &
                       "10" &
                       "00100" &
                       '0' &
                       "000" &
                       "0000" &
                       '0' &
                       '0' &
                       "00" &
                       "00" &
                       "0000000001" &
                       COMPLETER_ID_CFG &
                       tag(7 downto 0) &
                       "0000" &
                       first_dw_be(3 downto 0);
  trn_tsof_n 	    <= '0';
  trn_tsrc_rdy_n    <= '0';

  PROC_TX_SYNCHRONIZE(1,0, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);

  trn_td_c          <= COMPLETER_ID_CFG &
                       "0000" &
                       reg_addr(11 downto 2) &
                       "00" &
                       reg_data(7 downto 0) &
                       reg_data(15 downto 8) &
                       reg_data(23 downto 16) &
                       reg_data(31 downto 24);
  trn_tsof_n 	    <= '1';
  trn_teof_n 	    <= '0';
  trn_trem_n_c 	    <= X"00";

  PROC_TX_SYNCHRONIZE(1, 1, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);

  trn_teof_n	    <= '1';
  trn_tsrc_rdy_n    <= '1';


end PROC_TX_TYPE0_CONFIGURATION_WRITE;


--************************************************************
--    Proc : PROC_TX_TYPE1_CONFIGURATION_READ
--    Inputs : Tag, PCI/PCI-Express Reg Address, First BypeEn
--    Outputs : Transaction Tx Interface Signaling
--    Description : Generates a Type 1 Configuration Read TLP
--*************************************************************/

procedure PROC_TX_TYPE1_CONFIGURATION_READ (

  tag                      : in std_logic_vector (7 downto 0);
  reg_addr                 : in std_logic_vector (11 downto 0);
  first_dw_be              : in std_logic_vector (3 downto 0);
  signal trn_td_c          : out std_logic_vector(63 downto 0);
  signal trn_tsof_n        : out std_logic;
  signal trn_teof_n        : out std_logic;
  signal trn_trem_n_c      : out std_logic_vector(7 downto 0);
  signal trn_tsrc_rdy_n    : out std_logic;
  signal trn_lnk_up_n : in std_logic;
  signal trn_tdst_rdy_n : in std_logic;
  signal trn_clk : in std_logic

) is

begin

  assert (trn_lnk_up_n = '0')
    report "TX Trn interface is MIA"
    severity failure;

  PROC_TX_SYNCHRONIZE(0, 0, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);

  trn_td_c          <= '0' &
                       "00" &
                       "00101" &
                       '0' &
                       "000" &
                       "0000" &
                       '0' &
                       '0' &
                       "00" &
                       "00" &
                       "0000000001" &
                       COMPLETER_ID_CFG &
                       tag(7 downto 0) &
                       "0000" &
                       first_dw_be(3 downto 0);
  trn_tsof_n 	    <= '0';
  trn_teof_n 	    <= '1';
  trn_trem_n_c 	    <= X"00";
  trn_tsrc_rdy_n    <= '0';

  PROC_TX_SYNCHRONIZE(1,0, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);

  trn_td_c          <= COMPLETER_ID_CFG &
                       "0000" &
                       reg_addr(11 downto 2) &
                       "00" &
                       X"00000000";
                       trn_tsof_n <= '1';
                       trn_teof_n <= '0';
                       trn_trem_n_c <= X"0F";
                       trn_tsrc_rdy_n <= '0';

  PROC_TX_SYNCHRONIZE(1, 1, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);

  trn_teof_n        <= '1';
  trn_trem_n_c      <= X"00";
  trn_tsrc_rdy_n    <= '1';

end PROC_TX_TYPE1_CONFIGURATION_READ;


--************************************************************
--    Proc : PROC_TX_TYPE1_CONFIGURATION_WRITE
--    Inputs : Tag, PCI/PCI-Express Reg Address, First BypeEn
--    Outputs : Transaction Tx Interface Signaling
--    Description : Generates a Type 1 Configuration Write TLP
--*************************************************************/

procedure PROC_TX_TYPE1_CONFIGURATION_WRITE (

  tag                      : in std_logic_vector (7 downto 0);
  reg_addr                 : in std_logic_vector (11 downto 0);
  reg_data                 : in std_logic_vector (31 downto 0);
  first_dw_be              : in std_logic_vector (3 downto 0);
  signal trn_td_c          : out std_logic_vector(63 downto 0);
  signal trn_tsof_n        : out std_logic;
  signal trn_teof_n        : out std_logic;
  signal trn_trem_n_c      : out std_logic_vector(7 downto 0);
  signal trn_tsrc_rdy_n    : out std_logic;
  signal trn_lnk_up_n : in std_logic;
  signal trn_tdst_rdy_n : in std_logic;
  signal trn_clk : in std_logic

) is

begin

  assert (trn_lnk_up_n = '0')
    report "TX Trn interface is MIA"
    severity failure;

  PROC_TX_SYNCHRONIZE(0, 0, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);

  trn_td_c          <= '0' &
                       "10" &
                       "00101" &
                       '0' &
                       "000" &
                       "0000" &
                       '0' &
                       '0' &
                       "00" &
                       "00" &
                       "0000000001" &
                       COMPLETER_ID_CFG &
                       tag(7 downto 0) &
                       "0000" &
                       first_dw_be(3 downto 0);
  trn_tsof_n 	    <= '0';
  trn_tsrc_rdy_n    <= '0';

  PROC_TX_SYNCHRONIZE(1,0, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);

  trn_td_c          <= COMPLETER_ID_CFG &
                       "0000" &
                       reg_addr(11 downto 2) &
                       "00" &
                       reg_data(7 downto 0) &
                       reg_data(15 downto 8) &
                       reg_data(23 downto 16) &
                       reg_data(31 downto 24);

  trn_tsof_n       <= '1';
  trn_teof_n       <= '0';
  trn_trem_n_c     <= X"00";

  PROC_TX_SYNCHRONIZE(1, 1, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);

  trn_teof_n       <= '1';
  trn_tsrc_rdy_n   <= '1';

end PROC_TX_TYPE1_CONFIGURATION_WRITE;


--************************************************************
--  Procedure : PROC_TX_MEMORY_READ_32
--  Inputs : Tag, Length, Address, Last Byte En, First Byte En
--  Outputs : Transaction Tx Interface Signaling
--  Description : Generates a Memory Read 32 TLP
--*************************************************************/

procedure PROC_TX_MEMORY_READ_32 (

  tag                      : in std_logic_vector (7 downto 0);
  tc                       : in std_logic_vector (2 downto 0);
  len                      : in std_logic_vector (9 downto 0);
  addr                     : in std_logic_vector (31 downto 0);
  last_dw_be               : in std_logic_vector (3 downto 0);
  first_dw_be              : in std_logic_vector (3 downto 0);
  signal trn_td_c          : out std_logic_vector(63 downto 0);
  signal trn_tsof_n        : out std_logic;
  signal trn_teof_n        : out std_logic;
  signal trn_trem_n_c      : out std_logic_vector(7 downto 0);
  signal trn_tsrc_rdy_n    : out std_logic;
  signal trn_lnk_up_n : in std_logic;
  signal trn_tdst_rdy_n : in std_logic;
  signal trn_clk : in std_logic


) is

begin

  assert (trn_lnk_up_n = '0')
    report "TX Trn interface is MIA"
    severity failure;


  PROC_TX_SYNCHRONIZE(0, 0, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);

  trn_td_c <=          '0' &
                       "00" &
                       "00000" &
                       '0' &
                       tc(2 downto 0) &
                       "0000" &
                       '0' &
                       '0' &
                       "00" &
                       "00" &
                       len(9 downto 0) &
                       COMPLETER_ID_CFG &
                       tag(7 downto 0) &
                       last_dw_be(3 downto 0) &
                       first_dw_be(3 downto 0);
  trn_tsof_n        <= '0';
  trn_teof_n        <= '1';
  trn_trem_n_c 	    <= X"00";
  trn_tsrc_rdy_n    <= '0';

  PROC_TX_SYNCHRONIZE(1,0, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);

  trn_td_c          <= addr(31 downto 2) &
                       "00" &
                       X"00000000";
  trn_tsof_n        <= '1';
  trn_teof_n        <= '0';
  trn_trem_n_c      <= X"0F";
  trn_tsrc_rdy_n    <= '0';

  PROC_TX_SYNCHRONIZE(1, 1, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);

  trn_teof_n        <= '1';
  trn_trem_n_c      <= X"00";
  trn_tsrc_rdy_n    <= '1';

end PROC_TX_MEMORY_READ_32;


--************************************************************
--  Proc : PROC_TX_MEMORY_READ_64
--  Inputs : Tag, Length, Address, Last Byte En, First Byte En
--  Outputs : Transaction Tx Interface Signaling
--  Description : Generates a Memory Read 64 TLP
--*************************************************************/

procedure PROC_TX_MEMORY_READ_64 (

  tag                      : in std_logic_vector (7 downto 0);
  tc                       : in std_logic_vector (2 downto 0);
  len                      : in std_logic_vector (9 downto 0);
  addr                     : in std_logic_vector (63 downto 0);
  last_dw_be               : in std_logic_vector (3 downto 0);
  first_dw_be              : in std_logic_vector (3 downto 0);
  signal trn_td_c          : out std_logic_vector(63 downto 0);
  signal trn_tsof_n        : out std_logic;
  signal trn_teof_n        : out std_logic;
  signal trn_trem_n_c      : out std_logic_vector(7 downto 0);
  signal trn_tsrc_rdy_n    : out std_logic;
  signal trn_lnk_up_n : in std_logic;
  signal trn_tdst_rdy_n : in std_logic;
  signal trn_clk : in std_logic


) is

begin

  assert (trn_lnk_up_n = '0')
    report "TX Trn interface is MIA"
    severity failure;


  PROC_TX_SYNCHRONIZE(0, 0, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);

  trn_td_c <=          '0' &
                       "01" &
                       "00000" &
                       '0' &
                       tc(2 downto 0) &
                       "0000" &
                       '0' &
                       '0' &
                       "00" &
                       "00" &
                       len(9 downto 0) &
                       COMPLETER_ID_CFG &
                       tag(7 downto 0) &
                       last_dw_be(3 downto 0) &
                       first_dw_be(3 downto 0);
  trn_tsof_n        <= '0';
  trn_teof_n        <= '1';
  trn_trem_n_c      <= X"00";
  trn_tsrc_rdy_n    <= '0';

  PROC_TX_SYNCHRONIZE(1,0, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);

  trn_td_c          <= addr(63 downto 2) &
                       "00";
  trn_tsof_n        <= '1';
  trn_teof_n        <= '0';
  trn_trem_n_c      <= X"00";
  trn_tsrc_rdy_n    <= '0';

  PROC_TX_SYNCHRONIZE(1, 1, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);

  trn_teof_n        <= '1';
  trn_trem_n_c      <= X"00";
  trn_tsrc_rdy_n    <= '1';

end PROC_TX_MEMORY_READ_64;


--************************************************************
--    Proc : PROC_TX_MEMORY_WRITE_32
--    Inputs : Tag, Length, Address, Last Byte En, First Byte En
--    Outputs : Transaction Tx Interface Signaling
--    Description : Generates a Memory Write 32 TLP
--*************************************************************/

procedure PROC_TX_MEMORY_WRITE_32 (

  tag                         : in std_logic_vector (7 downto 0);
  tc                          : in std_logic_vector (2 downto 0);
  len                         : in std_logic_vector (9 downto 0);
  addr                        : in std_logic_vector (31 downto 0);
  last_dw_be                  : in std_logic_vector (3 downto 0);
  first_dw_be                 : in std_logic_vector (3 downto 0);
  ep                          : in std_logic;
  signal trn_td_c             : out std_logic_vector(63 downto 0);
  signal trn_tsof_n           : out std_logic;
  signal trn_teof_n           : out std_logic;
  signal trn_trem_n_c         : out std_logic_vector(7 downto 0);
  signal trn_tsrc_rdy_n       : out std_logic;
  signal trn_terrfwd_n        : out std_logic;
  signal trn_lnk_up_n : in std_logic;
  signal trn_tdst_rdy_n : in std_logic;
  signal trn_clk : in std_logic


) is

  variable length             : std_logic_vector(9 downto 0);
  variable i                  : INTEGER;
  variable int_length         : INTEGER;
  variable unsigned_length    : unsigned(9 downto 0);

begin

  assert (trn_lnk_up_n = '0')
    report "TX Trn interface is MIA"
    severity failure;


  if (len = "0000000000") then 

    length := "1000000000"; --1024

  else

    length := len;

  end if;

  PROC_TX_SYNCHRONIZE(0, 0, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);

  trn_td_c                <= '0' &
                             "10" &
                             "00000" &
                             '0' &
                             tc(2 downto 0) &
                             "0000" &
                             '0' &
                             '0' &
                             "00" &
                             "00" &
                             len(9 downto 0) &
                             COMPLETER_ID_CFG &
                             tag(7 downto 0) &
                             last_dw_be(3 downto 0) &
                             first_dw_be(3 downto 0);
  trn_tsof_n              <= '0';
  trn_teof_n              <= '1';
  trn_trem_n_c            <= X"00";
  trn_tsrc_rdy_n          <= '0';

  PROC_TX_SYNCHRONIZE(1,0, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);

  trn_td_c                <= addr(31 downto 2) &
                             "00" &
                             DATA_STORE(0) &
                             DATA_STORE(1) &
                             DATA_STORE(2) &
                             DATA_STORE(3);
  trn_tsof_n              <= '1';

  if (length /= "0000000001") then

    unsigned_length := unsigned(length);
    int_length := to_integer( unsigned_length);
    i := 4;
    while (i < (int_length * 4)) loop

      PROC_TX_SYNCHRONIZE(1,0, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);

      trn_td_c            <= DATA_STORE(i+0) &
                             DATA_STORE(i+1) &
                             DATA_STORE(i+2) &
                             DATA_STORE(i+3) &
                             DATA_STORE(i+4) &
                             DATA_STORE(i+5) &
                             DATA_STORE(i+6) &
                             DATA_STORE(i+7);

      if ((i+7) >= ((int_length*4)-1) ) then

        trn_teof_n <= '0';
        if (ep = '1') then

          trn_terrfwd_n   <= '0';

        end if;
        if (((int_length - 1) mod 2) = 0) then

          trn_trem_n_c    <= X"00";

        else

          trn_trem_n_c    <= X"0F";

        end if;

      end if;

      i := i + 8;

    end loop;

  else

    trn_teof_n            <= '0';
    if (ep = '1') then

      trn_terrfwd_n       <= '0';

    end if;

    trn_trem_n_c          <= X"00";

  end if;

  PROC_TX_SYNCHRONIZE(1, 1, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);

  trn_teof_n	          <= '1';
  trn_trem_n_c            <= X"00";
  trn_terrfwd_n           <= '1';
  trn_tsrc_rdy_n          <= '1';


end PROC_TX_MEMORY_WRITE_32;



--************************************************************
--  Proc : PROC_TX_MEMORY_WRITE_64
--  Inputs : Tag, Length, Address, Last Byte En, First Byte En
--  Outputs : Transaction Tx Interface Signaling
--  Description : Generates a Memory Write 64 TLP
--*************************************************************/

procedure PROC_TX_MEMORY_WRITE_64 (

  tag                         : in std_logic_vector (7 downto 0);
  tc                          : in std_logic_vector (2 downto 0);
  len                         : in std_logic_vector (9 downto 0);
  addr                        : in std_logic_vector (63 downto 0);
  last_dw_be                  : in std_logic_vector (3 downto 0);
  first_dw_be                 : in std_logic_vector (3 downto 0);
  ep                          : in std_logic;
  signal trn_td_c             : out std_logic_vector(63 downto 0);
  signal trn_tsof_n           : out std_logic;
  signal trn_teof_n           : out std_logic;
  signal trn_trem_n_c         : out std_logic_vector(7 downto 0);
  signal trn_tsrc_rdy_n       : out std_logic;
  signal trn_terrfwd_n        : out std_logic;
  signal trn_lnk_up_n : in std_logic;
  signal trn_tdst_rdy_n : in std_logic;
  signal trn_clk : in std_logic


) is

  variable length             : std_logic_vector(9 downto 0);
  variable i                  : INTEGER;
  variable int_length         : INTEGER;
  variable unsigned_length    : unsigned(9 downto 0);

begin

  assert (trn_lnk_up_n = '0')
    report "TX Trn interface is MIA"
    severity failure;


  if (len = "0000000000") then
  
    length := "1000000000"; --1024
  
  else

    length := len;

  end if;

  PROC_TX_SYNCHRONIZE(0, 0, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);

  trn_td_c               <= '0' &
                            "11" &
                            "00000" &
                            '0' &
                            tc(2 downto 0) &
                            "0000" &
                            '0' &
                            '0' &
                            "00" &
                            "00" &
                            len(9 downto 0) &
                            COMPLETER_ID_CFG &
                            tag(7 downto 0) &
                            last_dw_be(3 downto 0) &
                            first_dw_be(3 downto 0);
  trn_tsof_n             <= '0';
  trn_teof_n             <= '1';
  trn_trem_n_c           <= X"00";
  trn_tsrc_rdy_n         <= '0';

  PROC_TX_SYNCHRONIZE(1,0, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);

  trn_td_c               <= addr(63 downto 2) &
                            "00" ;
  trn_tsof_n             <= '1';

  unsigned_length := unsigned(length);
  int_length := to_integer( unsigned_length);
  if (int_length = 1) then

    DATA_STORE(4) := X"00";
    DATA_STORE(5) := X"00";
    DATA_STORE(6) := X"00";
    DATA_STORE(7) := X"00";

  end if;
  i := 0;
  while (i < (int_length * 4)) loop

    PROC_TX_SYNCHRONIZE(1,0, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);

    trn_td_c             <= DATA_STORE(i+0) &
                            DATA_STORE(i+1) &
                            DATA_STORE(i+2) &
                            DATA_STORE(i+3) &
                            DATA_STORE(i+4) &
                            DATA_STORE(i+5) &
                            DATA_STORE(i+6) &
                            DATA_STORE(i+7);

    if ((i+7) >= ((int_length*4)-1) ) then

      trn_teof_n <= '0';
      if (ep = '1') then

        trn_terrfwd_n    <= '0';

      end if;
      if ((int_length mod 2) = 0) then

        trn_trem_n_c     <= X"00";

      else

        trn_trem_n_c     <= X"0F";

      end if;

    end if;

    i := i + 8;

  end loop;

  PROC_TX_SYNCHRONIZE(1, 1, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);

  trn_teof_n             <= '1';
  trn_terrfwd_n          <= '1';
  trn_trem_n_c           <= X"00";
  trn_tsrc_rdy_n         <= '1';


end PROC_TX_MEMORY_WRITE_64;


--************************************************************
--  Proc : PROC_TX_COMPLETION_
--  Inputs : Tag, Tc, Length, Completion Status
--  Outputs : Transaction Tx Interface Signaling
--  Description : Generates a Completion TLP
--*************************************************************/


procedure PROC_TX_COMPLETION (

  tag                      : in std_logic_vector (7 downto 0);
  tc                       : in std_logic_vector (2 downto 0);
  len                      : in std_logic_vector (9 downto 0);
  comp_status              : in std_logic_vector (2 downto 0);
  signal trn_td_c          : out std_logic_vector(63 downto 0);
  signal trn_tsof_n        : out std_logic;
  signal trn_teof_n        : out std_logic;
  signal trn_trem_n_c      : out std_logic_vector(7 downto 0);
  signal trn_tsrc_rdy_n    : out std_logic;
  signal trn_lnk_up_n : in std_logic;
  signal trn_tdst_rdy_n : in std_logic;
  signal trn_clk : in std_logic

) is

begin

  assert (trn_lnk_up_n = '0')
  report "TX Trn interface is MIA"
    severity failure;


  PROC_TX_SYNCHRONIZE(0, 0, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);

  trn_td_c          <= '0' &
                       "00" &
                       "01010" &
                       '0' &
                       tc(2 downto 0) &
                       "0000" &
                       '0' &
                       '0' &
                       "00" &
                       "00" &
                       len(9 downto 0) &
                       COMPLETER_ID_CFG &
                       comp_status(2 downto 0) &
                       '0' &
                       X"000";
  trn_tsof_n        <= '0';
  trn_teof_n        <= '1';
  trn_trem_n_c      <= X"00";
  trn_tsrc_rdy_n    <= '0';

  PROC_TX_SYNCHRONIZE(1,0, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);

  trn_td_c          <= COMPLETER_ID_CFG &
                       tag(7 downto 0) &
                       X"00" &
                       X"00000000";
  trn_tsof_n        <= '1';
  trn_teof_n        <= '0';
  trn_trem_n_c      <= X"0F";

  PROC_TX_SYNCHRONIZE(1, 1, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);

  trn_teof_n        <= '1';
  trn_trem_n_c	    <= X"00";
  trn_tsrc_rdy_n    <= '1';


end PROC_TX_COMPLETION;


--************************************************************
--  Proc : PROC_TX_COMPLETION_DATA_
--  Inputs : Tag, Tc, Length, Completion Status
--  Outputs : Transaction Tx Interface Signaling
--  Description : Generates a Completion with Data TLP
--*************************************************************/

procedure PROC_TX_COMPLETION_DATA (

  tag                      : in std_logic_vector (7 downto 0);
  tc                       : in std_logic_vector (2 downto 0);
  len                      : in std_logic_vector (9 downto 0);
  byte_count               : in std_logic_vector (11 downto 0);
  lower_addr               : in std_logic_vector (6 downto 0);
  comp_status              : in std_logic_vector (2 downto 0);
  ep                       : in std_logic;
  signal trn_td_c          : out std_logic_vector(63 downto 0);
  signal trn_tsof_n        : out std_logic;
  signal trn_teof_n        : out std_logic;
  signal trn_trem_n_c      : out std_logic_vector(7 downto 0);
  signal trn_tsrc_rdy_n    : out std_logic;
  signal trn_terrfwd_n     : out std_logic;
  signal trn_lnk_up_n : in std_logic;
  signal trn_tdst_rdy_n : in std_logic;
  signal trn_clk : in std_logic

) is

  variable length : std_logic_vector(9 downto 0);
  variable i : INTEGER;
  variable int_length : INTEGER;
  variable unsigned_length : unsigned(9 downto 0);

begin

  assert (trn_lnk_up_n = '0')
  report "TX Trn interface is MIA"
    severity failure;


  if (len = "0000000000") then 

    length := "1000000000"; --1024

  else

    length := len;

  end if;

  PROC_TX_SYNCHRONIZE(0, 0, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);

  trn_td_c                 <= '0' &
                              "10" &
                              "01010" &
                              '0' &
                              tc(2 downto 0) &
                              "0000" &
                              '0' &
                              '0' &
                              "00" &
                              "00" &
                              len(9 downto 0) &
                              COMPLETER_ID_CFG &
                              comp_status(2 downto 0) &
                              '0' &
                              byte_count(11 downto 0);
  trn_tsof_n               <= '0';
  trn_teof_n               <= '1';
  trn_trem_n_c             <= X"00";
  trn_tsrc_rdy_n           <= '0';

  PROC_TX_SYNCHRONIZE(1,0, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);

  trn_td_c                 <= COMPLETER_ID_CFG &
                              tag(7 downto 0) &
                              '0' &
                              lower_addr(6 downto 0) &
                              DATA_STORE(0) &
                              DATA_STORE(1) &
                              DATA_STORE(2) &
                              DATA_STORE(3);
  trn_tsof_n               <= '1';

  if (length /= "0000000001") then

    unsigned_length := unsigned(length);
    int_length := to_integer( unsigned_length);
    i := 4;
    while (i < (int_length * 4)) loop

      PROC_TX_SYNCHRONIZE(1,0, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);
      trn_td_c             <= DATA_STORE(i+0) &
                              DATA_STORE(i+1) &
                              DATA_STORE(i+2) &
                              DATA_STORE(i+3) &
                              DATA_STORE(i+4) &
                              DATA_STORE(i+5) &
                              DATA_STORE(i+6) &
                              DATA_STORE(i+7);

      if ((i+7) >= ((int_length*4)-1) ) then

        trn_teof_n         <= '0';
        if (ep = '1') then

          trn_terrfwd_n    <= '0';

        end if;
        if (((int_length - 1) mod 2) = 0) then

          trn_trem_n_c     <= X"00";

        else

          trn_trem_n_c     <= X"0F";

        end if;

      end if;

      i := i + 8;

    end loop;

  else

    trn_teof_n <= '0';
    if (ep = '1') then

      trn_terrfwd_n        <= '0';

    end if;

    trn_trem_n_c           <= X"00";

  end if;

  PROC_TX_SYNCHRONIZE(1, 1, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);

  trn_teof_n               <= '1';
  trn_terrfwd_n            <= '1';
  trn_trem_n_c	           <= X"00";
  trn_tsrc_rdy_n           <= '1';


end PROC_TX_COMPLETION_DATA;


--************************************************************
--    Proc : PROC_TX_MESSAGE
--    Inputs : Tag, TC, Address, Message Routing, Message Code
--    Outputs : Transaction Tx Interface Signaling
--    Description : Generates a Message TLP
--*************************************************************/

procedure PROC_TX_MESSAGE (

  tag                      : in std_logic_vector (7 downto 0);
  tc                       : in std_logic_vector (2 downto 0);
  len                      : in std_logic_vector (9 downto 0);
  data                     : in std_logic_vector (63 downto 0);
  message_rtg              : in std_logic_vector (2 downto 0);
  message_code             : in std_logic_vector (7 downto 0);
  signal trn_td_c          : out std_logic_vector(63 downto 0);
  signal trn_tsof_n        : out std_logic;
  signal trn_teof_n        : out std_logic;
  signal trn_trem_n_c      : out std_logic_vector(7 downto 0);
  signal trn_tsrc_rdy_n    : out std_logic;
  signal trn_lnk_up_n : in std_logic;
  signal trn_tdst_rdy_n : in std_logic;
  signal trn_clk : in std_logic

) is

begin

  assert (trn_lnk_up_n = '0')
    report "TX Trn interface is MIA"
    severity failure;


  PROC_TX_SYNCHRONIZE(0, 0, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);

  trn_td_c          <= '0' &
                       "01" &
                       "10" & message_rtg(2 downto 0) &
                       '0' &
                       tc(2 downto 0) &
                       "0000" &
                       '0' &
                       '0' &
                       "00" &
                       "00" &
                       "0000000000" &
                       COMPLETER_ID_CFG &
                       tag(7 downto 0) &
                       message_code(7 downto 0);
  trn_tsof_n        <= '0';
  trn_teof_n        <= '1';
  trn_trem_n_c      <= X"00";
  trn_tsrc_rdy_n    <= '0';

  PROC_TX_SYNCHRONIZE(1,0, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);

  trn_td_c          <= data;
  trn_tsof_n        <= '1';
  trn_teof_n        <= '0';
  trn_trem_n_c      <= X"00";


  PROC_TX_SYNCHRONIZE(1, 1, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);

  trn_teof_n        <= '1';
  trn_trem_n_c	    <= X"00";
  trn_tsrc_rdy_n    <= '1';


end PROC_TX_MESSAGE;



--************************************************************
--    Proc : PROC_TX_MESSAGE_DATA
--    Inputs : Tag, TC, Address, Message Routing, Message Code
--    Outputs : Transaction Tx Interface Signaling
--    Description : Generates a Message Data TLP
--*************************************************************/

procedure PROC_TX_MESSAGE_DATA (

  tag                      : in std_logic_vector (7 downto 0);
  tc                       : in std_logic_vector (2 downto 0);
  len                      : in std_logic_vector (9 downto 0);
  data                     : in std_logic_vector (63 downto 0);
  message_rtg              : in std_logic_vector (2 downto 0);
  message_code             : in std_logic_vector (7 downto 0);
  signal trn_td_c          : out std_logic_vector(63 downto 0);
  signal trn_tsof_n        : out std_logic;
  signal trn_teof_n        : out std_logic;
  signal trn_trem_n_c      : out std_logic_vector(7 downto 0);
  signal trn_tsrc_rdy_n    : out std_logic;
  signal trn_lnk_up_n : in std_logic;
  signal trn_tdst_rdy_n : in std_logic;
  signal trn_clk : in std_logic

) is

  variable length             : std_logic_vector(9 downto 0);
  variable i                  : INTEGER;
  variable int_length         : INTEGER;
  variable unsigned_length    : unsigned(9 downto 0);

begin

  assert (trn_lnk_up_n = '0')
  report "TX Trn interface is MIA"
    severity failure;


  if (len = "0000000000") then

    length := "1000000000"; --1024

  else

    length := len;

  end if;

  PROC_TX_SYNCHRONIZE(0, 0, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);

  trn_td_c              <= '0' &
                           "11" &
                           "10" & message_rtg(2 downto 0) &
                           '0' &
                           tc(2 downto 0) &
                           "0000" &
                           '0' &
                           '0' &
                           "00" &
                           "00" &
                           length(9 downto 0) &
                           COMPLETER_ID_CFG &
                           tag(7 downto 0) &
                           message_code(7 downto 0);

  trn_tsof_n            <= '0';
  trn_teof_n            <= '1';
  trn_trem_n_c          <= X"00";
  trn_tsrc_rdy_n        <= '0';

  PROC_TX_SYNCHRONIZE(1,0, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);

  trn_td_c              <= data;
  trn_tsof_n            <= '1';

  unsigned_length := unsigned(length);
  int_length := to_integer( unsigned_length);
  i := 0;
  while (i < (int_length * 4)) loop

    PROC_TX_SYNCHRONIZE(1,0, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);

    trn_td_c            <= DATA_STORE(i+0) &
                           DATA_STORE(i+1) &
                           DATA_STORE(i+2) &
                           DATA_STORE(i+3) &
                           DATA_STORE(i+4) &
                           DATA_STORE(i+5) &
                           DATA_STORE(i+6) &
                           DATA_STORE(i+7);

    if ((i+7) >= ((int_length*4)-1) ) then

      trn_teof_n        <= '0';
      if ((int_length mod 2) = 0) then

        trn_trem_n_c    <= X"00";

      else

        trn_trem_n_c    <= X"0F";

      end if;

    end if;

    i := i + 8;

  end loop;

  PROC_TX_SYNCHRONIZE(1, 1, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);

  trn_teof_n            <= '1';
  trn_trem_n_c          <= X"00";
  trn_tsrc_rdy_n        <= '1';


end PROC_TX_MESSAGE_DATA;



--************************************************************
--    Proc : PROC_TX_IO_READ
--    Inputs : Tag, Address
--    Outputs : Transaction Tx Interface Signaling
--    Description : Generates a IO Read TLP
--*************************************************************/

procedure PROC_TX_IO_READ (

  tag                      : in std_logic_vector (7 downto 0);
  addr                     : in std_logic_vector (31 downto 0);
  first_dw_be              : in std_logic_vector (3 downto 0);
  signal trn_td_c          : out std_logic_vector(63 downto 0);
  signal trn_tsof_n        : out std_logic;
  signal trn_teof_n        : out std_logic;
  signal trn_trem_n_c      : out std_logic_vector(7 downto 0);
  signal trn_tsrc_rdy_n    : out std_logic;
  signal trn_lnk_up_n : in std_logic;
  signal trn_tdst_rdy_n : in std_logic;
  signal trn_clk : in std_logic

) is

begin

  assert (trn_lnk_up_n = '0')
    report "TX Trn interface is MIA"
    severity failure;


  PROC_TX_SYNCHRONIZE(0, 0, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);

  trn_td_c          <= '0' &
                       "00" &
                       "00010" &
                       '0' &
                       "000" &
                       "0000" &
                       '0' &
                       '0' &
                       "00" &
                       "00" &
                       "0000000001" &
                       COMPLETER_ID_CFG &
                       tag(7 downto 0) &
                       "0000" &
                       first_dw_be(3 downto 0);
  trn_tsof_n        <= '0';
  trn_teof_n        <= '1';
  trn_trem_n_c      <= X"00";
  trn_tsrc_rdy_n    <= '0';

  PROC_TX_SYNCHRONIZE(1,0, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);

  trn_td_c          <= addr(31 downto 2) &
                      "00" &
                       X"00000000";
  trn_tsof_n        <= '1';
  trn_teof_n        <= '0';
  trn_trem_n_c      <= X"0F";
  trn_tsrc_rdy_n    <= '0';

  PROC_TX_SYNCHRONIZE(1, 1, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);

  trn_teof_n        <= '1';
  trn_trem_n_c      <= X"00";
  trn_tsrc_rdy_n    <= '1';
 
end PROC_TX_IO_READ;


--************************************************************
--    Proc : PROC_TX_IO_WRITE
--    Inputs : Tag, Address, Data
--    Outputs : Transaction Tx Interface Signaling
--    Description : Generates a IO Read TLP
--*************************************************************/

procedure PROC_TX_IO_WRITE (

  tag                      : in std_logic_vector (7 downto 0);
  addr                     : in std_logic_vector (31 downto 0);
  first_dw_be              : in std_logic_vector (3 downto 0);
  data                     : in std_logic_vector(31 downto 0);
  signal trn_td_c          : out std_logic_vector(63 downto 0);
  signal trn_tsof_n        : out std_logic;
  signal trn_teof_n        : out std_logic;
  signal trn_trem_n_c      : out std_logic_vector(7 downto 0);
  signal trn_tsrc_rdy_n    : out std_logic;
  signal trn_lnk_up_n : in std_logic;
  signal trn_tdst_rdy_n : in std_logic;
  signal trn_clk : in std_logic

) is

begin

  assert (trn_lnk_up_n = '0')
    report "TX Trn interface is MIA"
    severity failure;


  PROC_TX_SYNCHRONIZE(0, 0, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);

  trn_td_c          <= '0' &
                       "10" &
                       "00010" &
                       '0' &
                       "000" &
                       "0000" &
                       '0' &
                       '0' &
                       "00" &
                       "00" &
                       "0000000001" &
                       COMPLETER_ID_CFG &
                       tag(7 downto 0) &
                       "0000" &
                       first_dw_be(3 downto 0);
  trn_tsof_n        <= '0';
  trn_teof_n        <= '1';
  trn_trem_n_c      <= X"00";
  trn_tsrc_rdy_n    <= '0';

  PROC_TX_SYNCHRONIZE(1,0, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);

  trn_td_c          <= addr(31 downto 2) &
                       "00" &
                       data(7 downto 0) &
                       data(15 downto 8) &
                       data(23 downto 16) &
                       data(31 downto 24);
  trn_tsof_n        <= '1';
  trn_teof_n        <= '0';
  trn_trem_n_c      <= X"00";

  PROC_TX_SYNCHRONIZE(1, 1, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);

  trn_teof_n        <= '1';
  trn_trem_n_c      <= X"00";
  trn_tsrc_rdy_n    <= '1';


end PROC_TX_IO_WRITE;


--************************************************************
--    Proc : PROC_USR_DATA_SETUP_SEQ
--    Inputs : None
--    Outputs : None
--    Description : Populates scratch pad data area with known good data.
--*************************************************************/

procedure PROC_USR_DATA_SETUP_SEQ is

  variable i             : INTEGER;
  variable unsigned_i    : unsigned(7 downto 0);
  variable vector_i      : std_logic_vector(7 downto 0);

begin

  for i in 0 to 4095 loop

    unsigned_i := to_unsigned(i, 8);
    vector_i := std_logic_vector(unsigned_i);
    DATA_STORE(i) := vector_i(7 downto 0);

  end loop;

end PROC_USR_DATA_SETUP_SEQ;


--************************************************************
--    Proc : PROC_SET_READ_DATA
--    Inputs : Data
--    Outputs : None
--    Description : Set read data to known value
--*************************************************************/

procedure PROC_SET_READ_DATA  (

  be     : in std_logic_vector(3 downto 0);
  data   : in std_logic_vector(31 downto 0)

) is

begin

  P_READ_DATA := data;

end PROC_SET_READ_DATA;



--************************************************************
--    Proc : PROC_WAIT_FOR_READ_DATA
--    Inputs : None
--    Outputs : Read data P_READ_DATA will be valid
--    Description : This task must be executed
--                  immediately following a read call
--                  in order for the read process to function
--                  correctly.
--*************************************************************/

procedure PROC_WAIT_FOR_READ_DATA  (

  signal tx_rx_read_data_valid    : out std_logic;
  signal rx_tx_read_data_valid    : in std_logic;
  signal rx_tx_read_data : in std_logic_vector(31 downto 0);
  signal trn_clk : in std_logic

) is

  variable j : INTEGER;

begin

  j := 10;
  tx_rx_read_data_valid <= '1';
  while (rx_tx_read_data_valid = '0') loop

    wait until (trn_clk'event and trn_clk = '1');

  end loop;
  P_READ_DATA := rx_tx_read_data;
  tx_rx_read_data_valid <= '0'; -- indicate to rx_app to make rx_tx_valid = 0
  wait until rx_tx_read_data_valid = '0';

end PROC_WAIT_FOR_READ_DATA;


--***********************************************************
--      Procedure : PROC_DISPLAY_PCIE_MAP
--      Inputs : none
--      Outputs : none
--      Description : Displays the Memory Manager's P_MAP calculations
--                    based on range values read from PCI_E device.
--*************************************************************/

procedure PROC_DISPLAY_PCIE_MAP  (

  BAR            : THIRTY_THREE_BIT_ARRAY;
  BAR_ENABLED    : ENABLE_ARRAY;
  BAR_RANGE      : DWORD_ARRAY

) is

  variable i              : INTEGER;
  variable L              : line;
  variable func_result    : std_logic_vector(31 downto 0);

begin

  for i in 0 to 6 loop

    write (L, String'("            BAR "));
    hwrite(L, std_logic_vector(to_unsigned(i, 4)));
    write (L, String'(" = 0x"));
    hwrite(L, BAR(i)(31 downto 0));
    write (L, String'(" RANGE = 0x"));
    hwrite(L, BAR_RANGE(i)(31 downto 0));

    case BAR_ENABLED(i) is

      when 1 => write (L, String'(" IO MAPPED"));

      when 2 => write (L, String'(" MEM32 MAPPED"));

      when 3 => write (L, String'(" MEM64 MAPPED"));

      when others => write (L, String'(" DISABLED"));

    end case;
    writeline (output, L);

  end loop;

end PROC_DISPLAY_PCIE_MAP;



--*************************************************************
--      Procedure : PROC_BUILD_PCIE_MAP
--      Inputs :
--      Outputs :
--      Description : Looks at range values read from config space and
--                    builds corresponding mem/io map
--*************************************************************/

procedure PROC_BUILD_PCIE_MAP

is

  variable i    : INTEGER;
  variable L    : line;
  variable RANGE_VALUE : std_logic_vector(31 downto 0);

begin

  writeNowToScreen(String'("PCI EXPRESS BAR MEMORY/IO MAPPING PROCESS BEGUN.."));

  BAR(0) := '0' & X"10000000";
  BAR(1) := '0' & X"20000000";
  BAR(2) := '0' & X"30000000";
  BAR(3) := '0' & X"40000000";
  BAR(4) := '0' & X"50000000";
  BAR(5) := '0' & X"60000000";
  BAR(6) := '0' & X"70000001";  -- bit 0 must be set to enable the EROM


  i := 0;
  while (i <= 6) loop

    RANGE_VALUE := BAR_RANGE(i);

    if (RANGE_VALUE = X"00000000") then

      BAR_ENABLED(i) := 0; -- Disabled
      BAR(i) := '0' & X"00000000";

    else

      if ((RANGE_VALUE(0) = '1') and (i /= 6)) then

        BAR_ENABLED(i) := 1; -- IO
        NUMBER_OF_IO_BARS := NUMBER_OF_IO_BARS + 1;
--        if (pio_check_design and (NUMBER_OF_IO_BARS >1)) then
--          write (L, String'("Warning: PIO design only supports 1 IO BAR. Testbench will disable BAR"));
--          hwrite(L, std_logic_vector(to_unsigned(i, 4)));
--          writeline (output, L);
--          BAR_ENABLED(i) := 0; -- Disabled
--        end if;

      else

        if (RANGE_VALUE(2) = '1') then

          BAR_ENABLED(i) := 3; -- Mem64
          BAR_ENABLED(i+1) := 0; -- Mem64 uses upper BAR so set as disabled

          NUMBER_OF_MEM64_BARS := NUMBER_OF_MEM64_BARS + 1;
          if (pio_check_design and (NUMBER_OF_MEM64_BARS >1)) then
            write (L, String'("Warning: PIO design only supports 1 MEM64 BAR. Testbench will disable BAR"));
            hwrite(L, std_logic_vector(to_unsigned(i, 4)));
            writeline (output, L);
            BAR_ENABLED(i) := 0; -- Disabled
          end if;
          i := i + 1;

        else


          if (i /= 6) then NUMBER_OF_MEM32_BARS := NUMBER_OF_MEM32_BARS + 1;
          end if; 
          BAR_ENABLED(i) := 2; -- Mem32
--          if (pio_check_design and (NUMBER_OF_MEM32_BARS >1)) then
--            write (L, String'("Warning: PIO design only supports 1 MEM32 BAR. Testbench will disable BAR"));
--            hwrite(L, std_logic_vector(to_unsigned(i, 4)));
--            writeline (output, L);
--            BAR_ENABLED(i) := 0; -- Disabled
--          end if;


        end if;

      end if;

    end if;

    i := i + 1;

  end loop;

end PROC_BUILD_PCIE_MAP;


--***********************************************************
--        Proc : PROC_BAR_SCAN
--        Inputs : None
--        Outputs : None
--        Description : Scans PCI core's configuration registers.
--*************************************************************/

procedure PROC_BAR_SCAN  (

  signal tx_rx_read_data_valid : out std_logic;
  signal rx_tx_read_data_valid : in std_logic;
  signal rx_tx_read_data : in std_logic_vector (31 downto 0);
  signal trn_td_c : out std_logic_vector(63 downto 0);
  signal trn_tsof_n : out std_logic;
  signal trn_teof_n : out std_logic;
  signal trn_trem_n_c : out std_logic_vector(7 downto 0);
  signal trn_tsrc_rdy_n : out std_logic;
  signal trn_lnk_up_n : in std_logic;
  signal trn_tdst_rdy_n : in std_logic;
  signal trn_clk : in std_logic

) is

  variable P_ADDRESS_MASK : std_logic_vector((32 - 1) downto 0);
  variable L : line;
  variable DEFAULT_TAG : std_logic_vector(( 8 - 1) downto 0);

begin


-- TRN MODEL Initialization
  BAR_RANGE(0) := X"FFE00000";
  BAR_RANGE(1) := X"FFE00000";
  BAR_RANGE(2) := X"00000000";
  BAR_RANGE(3) := X"00000000";
  BAR_RANGE(4) := X"00000000";
  BAR_RANGE(5) := X"00000000";
  BAR_RANGE(6) := X"00000000";


end PROC_BAR_SCAN;


--************************************************************
--       Procedure : PROC_BAR_PROGRAM
--       Inputs : None
--       Outputs : None
--       Description : Program's PCI core's configuration registers.
-- ************************************************************/

procedure PROC_BAR_PROGRAM  (

  signal trn_td_c          : out std_logic_vector(63 downto 0);
  signal trn_tsof_n        : out std_logic;
  signal trn_teof_n        : out std_logic;
  signal trn_trem_n_c      : out std_logic_vector(7 downto 0);
  signal trn_tsrc_rdy_n    : out std_logic;
  signal trn_lnk_up_n : in std_logic;
  signal trn_tdst_rdy_n : in std_logic;
  signal trn_clk : in std_logic

) is

  variable L : line;
  variable DEFAULT_TAG : std_logic_vector(( 8 - 1) downto 0);

begin

  DEFAULT_TAG := X"0f";

  write (L, String'("[ ")); write (L, now);
  write (L, String'(" ] : Setting Core Configuration Space..."));
  writeline (output, L);
  PROC_TX_CLK_EAT(3000, trn_clk);

-- Program BAR0

  PROC_TX_TYPE0_CONFIGURATION_WRITE (
    DEFAULT_TAG, --tag :in std_logic_vector (7 downto 0);
    X"010",  --reg_addr 12'h10
    BAR(0)(31 downto 0), --reg_data : in std_logic_vector (31 downto 0);
    X"F", --first_dw_be : in std_logic_vector (3 downto 0);
    trn_td_c, trn_tsof_n,trn_teof_n,trn_trem_n_c, trn_tsrc_rdy_n, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);
  DEFAULT_TAG := X"10";
  PROC_TX_CLK_EAT(100, trn_clk);

-- Program BAR1

  PROC_TX_TYPE0_CONFIGURATION_WRITE (
    DEFAULT_TAG, --tag :in std_logic_vector (7 downto 0);
    X"014", --reg_addr 12'h14
    BAR(1)(31 downto 0), --reg_data : in std_logic_vector (31 downto 0);
    X"F", --first_dw_be : in std_logic_vector (3 downto 0);
    trn_td_c, trn_tsof_n,trn_teof_n,trn_trem_n_c, trn_tsrc_rdy_n, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);
  DEFAULT_TAG := X"11";
  PROC_TX_CLK_EAT(100, trn_clk);

-- Program BAR2

  PROC_TX_TYPE0_CONFIGURATION_WRITE (
    DEFAULT_TAG, --tag :in std_logic_vector (7 downto 0);
    X"018", --reg_addr 12'h18
    BAR(2)(31 downto 0), --reg_data : in std_logic_vector (31 downto 0);
    X"F", --first_dw_be : in std_logic_vector (3 downto 0);
    trn_td_c, trn_tsof_n,trn_teof_n,trn_trem_n_c, trn_tsrc_rdy_n, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);
  DEFAULT_TAG := X"12";
  PROC_TX_CLK_EAT(100, trn_clk);

-- Program BAR3

  PROC_TX_TYPE0_CONFIGURATION_WRITE (
    DEFAULT_TAG, --tag :in std_logic_vector (7 downto 0);
    X"01C", --reg_addr 12'h1C
    BAR(3)(31 downto 0), --reg_data : in std_logic_vector (31 downto 0);
    X"F", --first_dw_be : in std_logic_vector (3 downto 0);
    trn_td_c, trn_tsof_n,trn_teof_n,trn_trem_n_c, trn_tsrc_rdy_n, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);
  DEFAULT_TAG := X"13";
  PROC_TX_CLK_EAT(100, trn_clk);

-- Program BAR4

  PROC_TX_TYPE0_CONFIGURATION_WRITE (
    DEFAULT_TAG, --tag :in std_logic_vector (7 downto 0);
    X"020", --reg_addr 12'h20
    BAR(4)(31 downto 0), --reg_data : in std_logic_vector (31 downto 0);
    X"F", --first_dw_be : in std_logic_vector (3 downto 0);
    trn_td_c, trn_tsof_n,trn_teof_n,trn_trem_n_c, trn_tsrc_rdy_n, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);
  DEFAULT_TAG := X"14";
  PROC_TX_CLK_EAT(100, trn_clk);

-- Program BAR5

  PROC_TX_TYPE0_CONFIGURATION_WRITE (
    DEFAULT_TAG, --tag :in std_logic_vector (7 downto 0);
    X"024", --reg_addr 12'h24
    BAR(5)(31 downto 0), --reg_data : in std_logic_vector (31 downto 0);
    X"F", --first_dw_be : in std_logic_vector (3 downto 0);
    trn_td_c, trn_tsof_n,trn_teof_n,trn_trem_n_c, trn_tsrc_rdy_n, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);
  DEFAULT_TAG := X"15";
  PROC_TX_CLK_EAT(100, trn_clk);

-- Program Expansion ROM BAR

  PROC_TX_TYPE0_CONFIGURATION_WRITE (
    DEFAULT_TAG, --tag :in std_logic_vector (7 downto 0);
    X"030", --reg_addr 12'h30
    BAR(6)(31 downto 0), --reg_data : in std_logic_vector (31 downto 0);
    X"F", --first_dw_be : in std_logic_vector (3 downto 0);
    trn_td_c, trn_tsof_n,trn_teof_n,trn_trem_n_c, trn_tsrc_rdy_n, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);
  DEFAULT_TAG := X"16";
  PROC_TX_CLK_EAT(100, trn_clk);


-- Program PCI Command Register

  PROC_TX_TYPE0_CONFIGURATION_WRITE (
    DEFAULT_TAG, --tag :in std_logic_vector (7 downto 0);
    X"004", --reg_addr 12'h04
    X"00000007", --reg_data : in std_logic_vector (31 downto 0);
    X"1", --first_dw_be : in std_logic_vector (3 downto 0);
    trn_td_c, trn_tsof_n,trn_teof_n,trn_trem_n_c, trn_tsrc_rdy_n, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);
  DEFAULT_TAG := X"17";
  PROC_TX_CLK_EAT(100, trn_clk);


-- Program PCIe Device Control Register

  PROC_TX_TYPE0_CONFIGURATION_WRITE (
    DEFAULT_TAG, --tag :in std_logic_vector (7 downto 0);
    X"068", --reg_addr 12'h68
    X"0000005F", --reg_data : in std_logic_vector (31 downto 0);
    X"1", --first_dw_be : in std_logic_vector (3 downto 0);
    trn_td_c, trn_tsof_n,trn_teof_n,trn_trem_n_c, trn_tsrc_rdy_n, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);
  DEFAULT_TAG := X"18";
  PROC_TX_CLK_EAT(1000, trn_clk);

end PROC_BAR_PROGRAM;


--   ***********************************************************
--      Procedure : PROC_BAR_INIT
--      Inputs : None
--      Outputs : None
--     Description : Initialize PCI core based on core's configuration.
--   *************************************************************/

procedure PROC_BAR_INIT  (

  signal tx_rx_read_data_valid : out std_logic;
  signal rx_tx_read_data_valid : in std_logic;
  signal rx_tx_read_data : in std_logic_vector (31 downto 0);
  signal trn_td_c : out std_logic_vector(63 downto 0);
  signal trn_tsof_n : out std_logic;
  signal trn_teof_n : out std_logic;
  signal trn_trem_n_c : out std_logic_vector(7 downto 0);
  signal trn_tsrc_rdy_n : out std_logic;
  signal trn_lnk_up_n : in std_logic;
  signal trn_tdst_rdy_n : in std_logic;
  signal trn_clk : in std_logic

) is

begin

  PROC_BAR_SCAN(tx_rx_read_data_valid, rx_tx_read_data_valid, rx_tx_read_data, trn_td_c, trn_tsof_n,
                trn_teof_n, trn_trem_n_c, trn_tsrc_rdy_n, trn_lnk_up_n, trn_tdst_rdy_n,trn_clk);

  PROC_BUILD_PCIE_MAP;

  PROC_DISPLAY_PCIE_MAP(BAR, BAR_ENABLED, BAR_RANGE );

  PROC_BAR_PROGRAM( trn_td_c, trn_tsof_n, trn_teof_n,
                    trn_trem_n_c, trn_tsrc_rdy_n, trn_lnk_up_n, trn_tdst_rdy_n, trn_clk);

end PROC_BAR_INIT;



--************************************************************
--  Proc : PROC_SYSTEM_INITIALIZATION
--  Inputs : None
--  Outputs : None
--  Description : Waits for Reset to deassert and for Link up.
--*************************************************************/

procedure PROC_SYSTEM_INITIALIZATION(
   signal trn_reset_n: in std_logic;
   signal trn_lnk_up_n: in std_logic;
   signal speed_change_done_n : in std_logic )  is

  variable  L : line;

begin

--------------------------------------------------------------------------
-- Wait for Transaction reset to be de-asserted..
--------------------------------------------------------------------------

  wait until trn_reset_n = '1';
  writeNowToScreen ( String'("Transaction Reset is De-asserted"));

--------------------------------------------------------------------------
-- Wait for Transaction link to be asserted..
--------------------------------------------------------------------------

  if MAX_LINK_SPEED = 1 then
       wait until (trn_lnk_up_n = '0');
  else
       wait until (trn_lnk_up_n = '0');
       wait until (speed_change_done_n = '0');
  end if;

  writeNowToScreen ( String'("Transaction Link is Up"));


end PROC_SYSTEM_INITIALIZATION;

--************************************************************
--  Proc : PROC_READ_CFG_DW
--  Inputs : addr - 10-bit address
--  Outputs : None
--  Inouts : cfg_rdwr_int - configuration interface signals
--  Description : Read Configuration Space DW
--*************************************************************/

procedure PROC_READ_CFG_DW (
  addr                 : in    std_logic_vector(9 downto 0);
  signal cfg_rdwr_int  : inout cfg_rdwr_sigs
) is
    variable L : line;
  begin

    -- Because cfg_rdwr_int is an inout, we have to tri-state the sub-signals we want to read
    cfg_rdwr_int.cfg_rd_wr_done_n <= 'Z';
    cfg_rdwr_int.cfg_do <= (OTHERS => 'Z');
    cfg_rdwr_int.trn_clk <= 'Z';
    cfg_rdwr_int.trn_reset_n <= 'Z';

    assert (cfg_rdwr_int.trn_reset_n = '1')
    report "TX Reset is asserted"
    severity failure;

    if (cfg_rdwr_int.cfg_rd_wr_done_n /= '1') then
      wait until (rising_edge(cfg_rdwr_int.trn_clk) and cfg_rdwr_int.cfg_rd_wr_done_n = '1');
    end if;

    wait until (rising_edge(cfg_rdwr_int.trn_clk));
    cfg_rdwr_int.cfg_dwaddr <= addr;
    cfg_rdwr_int.cfg_wr_en_n <= '1';
    cfg_rdwr_int.cfg_rd_en_n <= '0';
    writeNowToScreen(String'("Reading Config space"));
    write (L, String'("  Addr: [0x"));
    hwrite(L, "00" & addr);
    write (L, String'("]"));
    writeline(output, L);


    wait until (rising_edge(cfg_rdwr_int.trn_clk) and cfg_rdwr_int.cfg_rd_wr_done_n = '0');
    cfg_rdwr_int.cfg_rd_en_n <= '1';
    write (L, String'("  Cfg Addr [0x"));
    hwrite(L, "00" & addr);
    write (L, String'("] -> Data [0x"));
    hwrite(L, cfg_rdwr_int.cfg_do);
    write (L, String'("]"));
    writeline(output, L);

  end PROC_READ_CFG_DW;

--************************************************************
--  Proc : PROC_WRITE_CFG_DW
--  Inputs : addr - 10-bit address
--           data - 32-bit data to write
--           byte_en_n - 4-bit active-low byte enable
--  Outputs : None
--  Inouts : cfg_rdwr_int - configuration interface signals
--  Description : Write Configuration Space DW
--*************************************************************/

procedure PROC_WRITE_CFG_DW (
  addr                : in    std_logic_vector(9 downto 0);
  data                : in    std_logic_vector(31 downto 0);
  byte_en_n           : in    std_logic_vector(3 downto 0);
  signal cfg_rdwr_int : inout cfg_rdwr_sigs
) is
    variable L : line;
  begin

    -- Because cfg_rdwr_int is an inout, we have to tri-state the sub-signals we want to read
    cfg_rdwr_int.cfg_rd_wr_done_n <= 'Z';
    cfg_rdwr_int.cfg_do <= (OTHERS => 'Z');
    cfg_rdwr_int.trn_clk <= 'Z';
    cfg_rdwr_int.trn_reset_n <= 'Z';

    assert (cfg_rdwr_int.trn_reset_n = '1')
    report "TX Reset is asserted"
    severity failure;

    if (cfg_rdwr_int.cfg_rd_wr_done_n /= '1') then
      wait until (rising_edge(cfg_rdwr_int.trn_clk) and cfg_rdwr_int.cfg_rd_wr_done_n = '1');
    end if;

    wait until (rising_edge(cfg_rdwr_int.trn_clk));
    cfg_rdwr_int.cfg_dwaddr <= addr;
    cfg_rdwr_int.cfg_wr_en_n <= '0';
    cfg_rdwr_int.cfg_rd_en_n <= '1';
    cfg_rdwr_int.cfg_di <= data;
    cfg_rdwr_int.cfg_byte_en_n <= byte_en_n;
    writeNowToScreen(String'("Writing Config space"));
    write (L, String'("  Addr: [0x"));
    hwrite(L, "00" & addr);
    write (L, String'("] -> Data [0x"));
    hwrite(L, data);
    write (L, String'("]"));
    writeline(output, L);

    wait until (rising_edge(cfg_rdwr_int.trn_clk) and cfg_rdwr_int.cfg_rd_wr_done_n = '0');
    cfg_rdwr_int.cfg_wr_en_n <= '1';

  end PROC_WRITE_CFG_DW;


end package body test_interface;
