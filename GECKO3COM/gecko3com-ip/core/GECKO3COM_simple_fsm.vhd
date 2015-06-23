--  GECKO3COM IP Core
--
--  Copyright (C) 2009 by
--   ___    ___   _   _
--  (  _ \ (  __)( ) ( )
--  | (_) )| (   | |_| |   Bern University of Applied Sciences
--  |  _ < |  _) |  _  |   School of Engineering and
--  | (_) )| |   | | | |   Information Technology
--  (____/ (_)   (_) (_)
--
--  This program is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details. 
--  You should have received a copy of the GNU General Public License
--  along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
--  URL to the project description: 
--    http://labs.ti.bfh.ch/gecko/wiki/systems/gecko3com/start
--------------------------------------------------------------------------------
--
--  Author:  Christoph Zimmermann
--  Date of creation:  3 february 2010 
--  Description:
--      This is the finite-state-mashine for the GECKO3com simple IP core.
--   
--      This core provides a simple FIFO and register interface to the
--      USB data transfer capabilities of the GECKO3COM/GECKO3main system.
--
--      Look at GECKO3COM_simple_test.vhd for an example how to use it.
--
--  Target Devices:     general
--  Tool versions:      11.1
--
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library work;
use work.GECKO3COM_defines.all;


entity GECKO3COM_simple_fsm is

  port (
    i_nReset                     : in  std_logic;
    i_sysclk                     : in  std_logic;
    o_receive_fifo_wr_en         : out std_logic;
    i_receive_fifo_full          : in  std_logic;
    o_receive_fifo_reset         : out std_logic;
    o_receive_transfersize_en    : out std_logic_vector((32/SIZE_DBUS_GPIF)-1 downto 0);
    i_receive_transfersize_lsb   : in  std_logic;
    o_receive_counter_load       : out std_logic;
    o_receive_counter_en         : out std_logic;
    i_receive_counter_zero       : in  std_logic;
    i_dev_dep_msg_out            : in  std_logic;
    i_request_dev_dep_msg_in     : in  std_logic;
    o_btag_reg_en                : out std_logic;
    o_nbtag_reg_en               : out std_logic;
    i_btag_correct               : in  std_logic;
    i_eom_bit_detected           : in  std_logic;
    i_send_transfersize_en       : in  std_logic;
    o_send_fifo_rd_en            : out std_logic;
    i_send_fifo_empty            : in  std_logic;
    o_send_fifo_reset            : out std_logic;
    o_send_counter_load          : out std_logic;
    o_send_counter_en            : out std_logic;
    i_send_counter_zero          : in  std_logic;
    o_send_mux_sel               : out std_logic_vector(2 downto 0);
    o_send_finished              : out std_logic;
    o_receive_newdata_set        : out std_logic;
    o_receive_end_of_message_set : out std_logic;
    o_send_data_request_set      : out std_logic;
    i_gpif_rx                    : in  std_logic;
    i_gpif_rx_empty              : in  std_logic;
    o_gpif_rx_rd_en              : out std_logic;
    i_gpif_tx                    : in  std_logic;
    i_gpif_tx_full               : in  std_logic;
    o_gpif_tx_wr_en              : out std_logic;
    i_gpif_abort                 : in  std_logic;       
    o_gpif_eom                   : out std_logic);

end GECKO3COM_simple_fsm;


architecture fsm of GECKO3COM_simple_fsm is

  -- XST specific synthesize attributes
  attribute safe_implementation : string;
  attribute safe_recovery_state : string;
  attribute fsm_encoding       : string;

  type   state_type is (st1_idle, st2_abort, st3_read_msg_id, st4_check_msg_id,
                        st5_read_nbtag, st6_read_transfer_size_low,
                        st7_read_transfer_size_high, st8_check_attributes,
                        st9_signal_data_request, st10_signal_receive_new_data,
                        st11_receive_data, st12_receive_wait,
                        st13_wait_for_receive_end, st14_read_align_bytes,
                        st15_start_response, st16_send_msg_id,
                        st17_send_nbtag, st18_send_transfer_size_low,
                        st19_send_transfer_size_high, st20_send_attributes,
                        st21_send_reserved, st22_send_data, st23_send_wait,
                        st24_wait_for_send_end);
  signal state, next_state : state_type;

  -- XST specific synthesize attributes
  attribute safe_recovery_state of state : signal is "st1_idle";
  attribute safe_implementation of state : signal is "yes";
  attribute fsm_encoding of state        : signal is "johnson";

  
  --Declare internal signals for all outputs of the state-machine
  signal s_receive_fifo_wr_en         : std_logic;
  signal s_receive_fifo_reset         : std_logic;
  signal s_receive_transfersize_en    : std_logic_vector((32/SIZE_DBUS_GPIF)-1 downto 0);
  signal s_receive_counter_load       : std_logic;
  signal s_receive_counter_en         : std_logic;
  signal s_btag_reg_en                : std_logic;
  signal s_nbtag_reg_en               : std_logic;
  signal s_send_fifo_rd_en            : std_logic;
  signal s_send_fifo_reset            : std_logic;
  signal s_send_counter_load          : std_logic;
  signal s_send_counter_en            : std_logic;
  signal s_send_mux_sel               : std_logic_vector(2 downto 0);
  signal s_send_finished              : std_logic;
  signal s_receive_newdata_set        : std_logic;
  signal s_receive_end_of_message_set : std_logic;
  signal s_send_data_request_set      : std_logic;
  signal s_gpif_eom                   : std_logic;
  signal s_gpif_rx_rd_en              : std_logic;
  signal s_gpif_tx_wr_en              : std_logic;
  

begin  -- fsm

  o_receive_fifo_wr_en         <= s_receive_fifo_wr_en;
  o_receive_transfersize_en    <= s_receive_transfersize_en;
  o_receive_counter_load       <= s_receive_counter_load;
  o_receive_counter_en         <= s_receive_counter_en;
  o_btag_reg_en                <= s_btag_reg_en;
  o_nbtag_reg_en               <= s_nbtag_reg_en;
  o_send_fifo_rd_en            <= s_send_fifo_rd_en;
  o_send_counter_load          <= s_send_counter_load;
  o_send_counter_en            <= s_send_counter_en;
  o_send_mux_sel               <= s_send_mux_sel;
  o_send_finished              <= s_send_finished;
  o_receive_newdata_set        <= s_receive_newdata_set;
  o_receive_end_of_message_set <= s_receive_end_of_message_set;
  o_send_data_request_set      <= s_send_data_request_set;
  o_gpif_eom                   <= s_gpif_eom;
  o_gpif_rx_rd_en              <= s_gpif_rx_rd_en;
  o_gpif_tx_wr_en              <= s_gpif_tx_wr_en;

  
  SYNC_PROC : process (i_sysclk)
  begin
    if (i_sysclk'event and i_sysclk = '1') then
      if (i_nReset = '0') then
        state <= st1_idle;

        o_receive_fifo_reset         <= '0';
        o_send_fifo_reset            <= '0';
      else
        state <= next_state;

        o_receive_fifo_reset         <= s_receive_fifo_reset;
        o_send_fifo_reset            <= s_send_fifo_reset;
      end if;
    end if;
  end process;

  --MEALY State-Machine - Outputs based on state and inputs
  OUTPUT_DECODE : process (state, i_receive_fifo_full,
                           i_receive_counter_zero, i_dev_dep_msg_out,
                           i_request_dev_dep_msg_in, --i_btag_correct,
                           i_eom_bit_detected, i_send_transfersize_en,
                           i_send_fifo_empty, i_send_counter_zero,
                           i_gpif_rx, i_gpif_rx_empty, i_gpif_tx,
                           i_gpif_tx_full, i_gpif_abort,
                           i_receive_transfersize_lsb)
  begin

    s_receive_fifo_wr_en         <= '0';
    s_receive_fifo_reset         <= '0';
    s_receive_transfersize_en    <= (others => '0');
    s_receive_counter_load       <= '0';
    s_receive_counter_en         <= '0';
    s_btag_reg_en                <= '0';
    s_nbtag_reg_en               <= '0';
    s_send_fifo_rd_en            <= '0';
    s_send_fifo_reset            <= '0';
    s_send_counter_load          <= '0';
    s_send_counter_en            <= '0';
    s_send_mux_sel               <= (others => '0');
    s_send_finished              <= '0';
    s_receive_newdata_set        <= '0';
    s_receive_end_of_message_set <= '0';
    s_send_data_request_set      <= '0';
    s_gpif_eom                   <= '0';
    s_gpif_rx_rd_en              <= '0';
    s_gpif_tx_wr_en              <= '0';

    if state = st11_receive_data then
      s_receive_fifo_wr_en <= '1';
    end if;

    if state = st2_abort then
      s_receive_fifo_reset <= '1';  
    end if;

    if state = st6_read_transfer_size_low then
      s_receive_transfersize_en <= "01";
    elsif state = st7_read_transfer_size_high then
      s_receive_transfersize_en <= "10";
    end if;

    if state = st8_check_attributes and
      i_dev_dep_msg_out = '1' and
      i_gpif_rx_empty = '0'
    then
      s_receive_counter_load <= '1';
    end if;

    if (state = st10_signal_receive_new_data and
        i_gpif_rx_empty = '0' and
        i_receive_fifo_full = '0' and
        i_receive_transfersize_lsb = '0')  -- if it is '1' then we have to read
                                           -- one time more from the fifo (which
                                           -- is 16bit wide)
      or (state = st11_receive_data and
          i_receive_counter_zero = '0' and
          i_gpif_rx_empty = '0' and
          i_receive_fifo_full = '0')
      or (state = st12_receive_wait and
          i_gpif_rx_empty = '0' and
          i_receive_fifo_full = '0')
    then
      s_receive_counter_en <= '1';
    end if;

    if state = st3_read_msg_id then
      s_btag_reg_en <= '1';
    end if;
    
    if state = st5_read_nbtag then
      s_nbtag_reg_en <= '1';
    end if;

    if (state = st21_send_reserved and
        i_gpif_tx_full = '0' and
        i_send_fifo_empty = '0')
      or (state = st22_send_data and
          i_gpif_tx_full = '0' and
          i_send_fifo_empty = '0' and
          i_send_counter_zero = '0')
      or (state = st23_send_wait and
          i_gpif_tx_full = '0' and
          i_send_fifo_empty = '0')
    then
      s_send_fifo_rd_en <= '1';
    end if;

    if state = st2_abort or state = st24_wait_for_send_end then
      s_send_fifo_reset <= '1';
    end if;

    if state = st20_send_attributes then
      s_send_counter_load <= '1';
    end if;

    if --(state = st21_send_reserved and i_gpif_tx_full = '0' and
        --i_send_fifo_empty = '0')
      (state = st22_send_data and
          i_gpif_tx_full = '0' and
          i_send_fifo_empty = '0' and
          i_send_counter_zero = '0')
      or (state = st23_send_wait and
          i_gpif_tx_full = '0' and
          i_send_fifo_empty = '0')
    then
      s_send_counter_en <= '1';
    end if;
 
    if state = st16_send_msg_id then
      s_send_mux_sel <= "000";
    elsif state = st17_send_nbtag then
      s_send_mux_sel <= "001";
    elsif state =st18_send_transfer_size_low then
      s_send_mux_sel <= "010";
    elsif state = st19_send_transfer_size_high then
      s_send_mux_sel <= "011";
    elsif state = st20_send_attributes then
      s_send_mux_sel <= "100";
    elsif state = st21_send_reserved then
      s_send_mux_sel <= "101";
    elsif state = st22_send_data or state = st23_send_wait then
      s_send_mux_sel <= "110";
    end if;

    if state = st24_wait_for_send_end and i_gpif_tx = '0' then
      s_send_finished <= '1';
    end if;
    
    if state = st10_signal_receive_new_data then
      s_receive_newdata_set <= '1';
    end if;

    if state = st8_check_attributes and i_eom_bit_detected = '1' then
      s_receive_end_of_message_set <= '1';
    end if;
    
    if state = st9_signal_data_request then
      s_send_data_request_set <= '1';
    end if;
    
    if (state = st22_send_data and i_send_counter_zero = '1')
      or state = st24_wait_for_send_end
    then
      s_gpif_eom <= '1';
    end if;
    
    if (i_gpif_rx_empty = '0' and
        (state = st1_idle or
         state = st5_read_nbtag or
         state = st6_read_transfer_size_low or
         state = st7_read_transfer_size_high or
         state = st8_check_attributes))
      or (state = st4_check_msg_id and
          i_gpif_rx_empty = '0' and
          (i_dev_dep_msg_out = '1' or i_request_dev_dep_msg_in = '1'))
      or ((state = st10_signal_receive_new_data or state = st12_receive_wait)
          and i_gpif_rx_empty = '0' and i_receive_fifo_full = '0')
      or (state = st11_receive_data and
          i_receive_counter_zero = '0' and
          i_gpif_rx_empty = '0' and
          i_receive_fifo_full = '0')
      or (state = st12_receive_wait and
          i_gpif_rx_empty = '0' and
          i_receive_fifo_full = '0')
      or (state = st14_read_align_bytes and i_gpif_rx_empty = '0')
    then
      s_gpif_rx_rd_en <= '1';
    end if;

    if (i_gpif_tx_full = '0' and
        (state = st16_send_msg_id or
         state = st17_send_nbtag or
         state = st18_send_transfer_size_low or
         state = st19_send_transfer_size_high or
         state = st20_send_attributes or
         state = st21_send_reserved))
      or (state = st22_send_data and
          i_gpif_tx_full = '0' and
          i_send_fifo_empty = '0')
      or (state = st23_send_wait and
          i_gpif_tx_full = '0' and
          i_send_fifo_empty = '0')
    then
      s_gpif_tx_wr_en <= '1';
    end if;
  end process;

  NEXT_STATE_DECODE : process (state, i_receive_fifo_full,
                               i_receive_counter_zero, i_dev_dep_msg_out,
                               i_request_dev_dep_msg_in, i_btag_correct,
                               i_eom_bit_detected, i_send_transfersize_en,
                               i_send_fifo_empty, i_send_counter_zero,
                               i_gpif_rx, i_gpif_rx_empty, i_gpif_tx,
                               i_gpif_tx_full, i_gpif_abort)
  begin
    --declare default state for next_state to avoid latches
    next_state <= state;                --default is to stay in current state

    case (state) is
      when st1_idle =>
        if i_gpif_abort = '1' then
          next_state <= st2_abort;
        elsif i_gpif_rx_empty = '0' then
          next_state <= st3_read_msg_id;
        end if;
        
      when st2_abort =>
        if i_gpif_abort = '0' then
          next_state <= st1_idle;          
        end if;
        
      when st3_read_msg_id =>
        next_state <= st4_check_msg_id;

      when st4_check_msg_id =>
        if i_gpif_abort = '1' then
          next_state <= st2_abort;
        elsif i_dev_dep_msg_out = '0' and i_request_dev_dep_msg_in = '0' then
          next_state <= st1_idle;
        elsif i_gpif_rx_empty = '0' and
          (i_dev_dep_msg_out = '1' or i_request_dev_dep_msg_in = '1')
        then
          next_state <= st5_read_nbtag;
        end if;
        
      when st5_read_nbtag =>
        if i_gpif_abort = '1' then
          next_state <= st2_abort;
        elsif i_gpif_rx_empty = '0' then
          next_state <= st6_read_transfer_size_low;
        end if;

      when st6_read_transfer_size_low =>
        if i_gpif_abort = '1' then
          next_state <= st2_abort;
        elsif i_btag_correct = '0' then
          next_state <= st1_idle;
        elsif i_gpif_rx_empty = '0' and i_btag_correct = '1' then
          next_state <= st7_read_transfer_size_high;
        end if;

      when st7_read_transfer_size_high =>
        if i_gpif_abort = '1' then
          next_state <= st2_abort;
        elsif i_gpif_rx_empty = '0' then
          next_state <= st8_check_attributes;
        end if;

      when st8_check_attributes =>
        if i_gpif_abort = '1' then
          next_state <= st2_abort;
        elsif i_dev_dep_msg_out = '0' and i_request_dev_dep_msg_in = '0' then
          next_state <= st1_idle;
        elsif i_gpif_rx_empty = '0' and i_request_dev_dep_msg_in = '1' then
          next_state <= st9_signal_data_request;
        elsif i_gpif_rx_empty = '0' and i_dev_dep_msg_out = '1' then
          next_state <= st10_signal_receive_new_data;
        end if;

      when st9_signal_data_request =>
        if i_gpif_abort = '1' then
          next_state <= st2_abort;
        elsif i_send_transfersize_en = '1' then
          next_state <= st15_start_response;
        end if;

      when st10_signal_receive_new_data =>
        if i_gpif_abort = '1' then
          next_state <= st2_abort;
        elsif i_gpif_rx_empty = '0' and i_receive_fifo_full = '0' then
          next_state <= st11_receive_data;
        end if;

      when st11_receive_data =>
        if i_gpif_abort = '1' then
          next_state <= st2_abort;
        elsif i_receive_counter_zero = '1' then
          --next_state <= st13_wait_for_receive_end;
          next_state <= st1_idle;
        elsif  i_gpif_rx_empty = '1' or i_receive_fifo_full = '1' then
          next_state <= st12_receive_wait;
        end if;

      when st12_receive_wait =>
        if i_gpif_abort = '1' then
          next_state <= st2_abort;
        elsif  i_gpif_rx_empty = '0' and i_receive_fifo_full = '0' then
          next_state <= st11_receive_data;
        end if;

      when st13_wait_for_receive_end =>
        if i_gpif_abort = '1' then
          next_state <= st2_abort;
        elsif i_gpif_rx = '0' then
          next_state <= st14_read_align_bytes;
        end if;

      when st14_read_align_bytes =>
        if i_gpif_abort = '1' then
          next_state <= st2_abort;
        elsif i_gpif_rx_empty = '1' then
          next_state <= st1_idle;
        end if;

      when st15_start_response =>
        if i_gpif_abort = '1' then
          next_state <= st2_abort;
        elsif i_gpif_tx_full = '0' then
          next_state <= st16_send_msg_id;
        end if;

      when st16_send_msg_id =>
        if i_gpif_abort = '1' then
          next_state <= st2_abort;
        elsif i_gpif_tx_full = '0' then
          next_state <= st17_send_nbtag;
        end if;

      when st17_send_nbtag =>
        if i_gpif_abort = '1' then
          next_state <= st2_abort;
        elsif i_gpif_tx_full = '0' then
          next_state <= st18_send_transfer_size_low;
        end if;

      when st18_send_transfer_size_low =>
        if i_gpif_abort = '1' then
          next_state <= st2_abort;
        elsif i_gpif_tx_full = '0' then
          next_state <= st19_send_transfer_size_high;
        end if;

      when st19_send_transfer_size_high =>
        if i_gpif_abort = '1' then
          next_state <= st2_abort;
        elsif i_gpif_tx_full = '0' then
          next_state <= st20_send_attributes;
        end if;

      when st20_send_attributes =>
        if i_gpif_abort = '1' then
          next_state <= st2_abort;
        elsif i_gpif_tx_full = '0' then
          next_state <= st21_send_reserved;
        end if;

      when st21_send_reserved =>
        if i_gpif_abort = '1' then
          next_state <= st2_abort;
        elsif i_gpif_tx_full = '0' and i_send_fifo_empty = '0' then
          next_state <= st22_send_data;
        end if;

      when st22_send_data =>
        if i_gpif_abort = '1' then
          next_state <= st2_abort;
        elsif i_send_counter_zero = '1' then
          next_state <= st24_wait_for_send_end;
        elsif i_gpif_tx_full = '1' or i_send_fifo_empty = '1' then
          next_state <= st23_send_wait;
        end if;

      when st23_send_wait =>
        if i_gpif_abort = '1' then
          next_state <= st2_abort;
        elsif i_gpif_tx_full = '0' and i_send_fifo_empty = '0' then
          next_state <= st22_send_data;
        end if;

      when st24_wait_for_send_end =>
        if i_gpif_abort = '1' then
          next_state <= st2_abort;
        elsif i_gpif_tx = '0' then
          next_state <= st1_idle;
        end if;
        
      when others =>
        next_state <= st1_idle;
    end case;
  end process;

end fsm;
