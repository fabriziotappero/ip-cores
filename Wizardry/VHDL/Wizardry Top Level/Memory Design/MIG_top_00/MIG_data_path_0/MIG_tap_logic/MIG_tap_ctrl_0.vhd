-------------------------------------------------------------------------------
-- Copyright (c) 2005-2007 Xilinx, Inc.
-- This design is confidential and proprietary of Xilinx, All Rights Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /   Vendor             : Xilinx
-- \   \   \/    Version            : $Name: i+IP+131489 $
--  \   \        Application        : MIG
--  /   /        Filename           : MIG_tap_ctrl.vhd
-- /___/   /\    Date Last Modified : $Date: 2007/09/21 15:23:24 $
-- \   \  /  \   Date Created       : Mon May 2 2005
--  \___\/\___\
--
-- Device      : Virtex-4
-- Design Name : DDR SDRAM
-- Description: The tap control logic which claculates the relation between the
--              FPGA clock and the dqs from memory. It delays the dqs so as to
--              detect the edges of the dqs and then calculates the mid point
--              so that the data can be registered properly.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
library UNISIM;
use UNISIM.vcomponents.all;

entity MIG_tap_ctrl is
  port(
    clk                  : in  std_logic;
    reset                : in  std_logic;
    rdy_status           : in  std_logic;
    dqs                  : in  std_logic;
    ctrl_dummyread_start : in  std_logic;
    dlyinc               : out std_logic;
    dlyce                : out std_logic;
    dlyrst               : out std_logic;
    sel_done             : out std_logic;
    valid_data_tap_count : out std_logic;
    data_tap_count       : out std_logic_vector(5 downto 0)
    );
end MIG_tap_ctrl;

architecture arch of MIG_tap_ctrl is

  signal prev_dqs_level         : std_logic;
  signal dly_inc                : std_logic;
  signal dly_ce                 : std_logic;
  signal dly_rst                : std_logic;
  signal transition             : std_logic_vector(1 downto 0);
  signal first_edge             : std_logic;
  signal second_edge            : std_logic;
  signal second_edge_r1         : std_logic;
  signal second_edge_r2         : std_logic;
  signal second_edge_r3         : std_logic;
  signal transition_rst         : std_logic;
  signal sel_complete           : std_logic;
  signal tap_counter            : std_logic_vector(5 downto 0);
  signal first_edge_tap_count   : std_logic_vector(5 downto 0);
  signal second_edge_tap_count  : std_logic_vector(5 downto 0);
  signal pulse_width_tap_count  : std_logic_vector(5 downto 0);
  signal data_bit_tap_count     : std_logic_vector(5 downto 0);
  signal state                  : std_logic_vector(2 downto 0);
  signal idelay_rst_idle        : std_logic;
  signal idelay_rst_idle_r1     : std_logic;
  signal idelay_rst_idle_r2     : std_logic;
  signal idelay_rst_idle_r3     : std_logic;
  signal idelay_rst_idle_r4     : std_logic;
  signal idelay_rst_idle_r5     : std_logic;
  signal idelay_rst_idle_r6     : std_logic;
  signal idelay_inc_idle        : std_logic;
  signal idelay_inc_idle_r1     : std_logic;
  signal idelay_inc_idle_r2     : std_logic;
  signal idelay_inc_idle_r3     : std_logic;
  signal idelay_inc_idle_r4     : std_logic;
  signal idelay_inc_idle_r5     : std_logic;
  signal idelay_inc_idle_r6     : std_logic;
  signal detect_edge_idle       : std_logic;
  signal detect_edge_idle_r1    : std_logic;
  signal detect_edge_idle_r2    : std_logic;
  signal detect_edge_idle_r3    : std_logic;
  signal detect_edge_idle_r4    : std_logic;
  signal detect_edge_idle_r5    : std_logic;
  signal detect_edge_idle_r6    : std_logic;
  signal flag                   : std_logic_vector(3 downto 0);
  signal dly_after_first_cnt    : std_logic_vector(3 downto 0);
  signal pulse_center_tap_count : std_logic_vector(5 downto 0);
  signal valid_data_count       : std_logic;
  signal data_count_valid       : std_logic;
  signal dly_after_first        : std_logic_vector(3 downto 0);
  signal curr_dqs_level         : std_logic;
  signal delay_sel_done         : std_logic;
  signal reset_int              : std_logic;
  signal rst_r                  : std_logic;

  constant IDELAY_RST  : std_logic_vector(2 downto 0) := "000";
  constant IDLE        : std_logic_vector(2 downto 0) := "001";
  constant IDELAY_INC  : std_logic_vector(2 downto 0) := "010";
  constant DETECT_EDGE : std_logic_vector(2 downto 0) := "011";

attribute syn_preserve : boolean;
attribute syn_preserve of pulse_width_tap_count  : signal is true ;

begin

  process(clk)
  begin
    if clk'event and clk = '1' then
      rst_r <= reset;
    end if;
  end process;

  dlyinc               <= dly_inc;
  dlyce                <= dly_ce;
  dlyrst               <= dly_rst;
  sel_done             <= sel_complete;
  valid_data_tap_count <= valid_data_count;
  data_tap_count       <= data_bit_tap_count;

  data_count_valid <= '1' when (second_edge_r3 = '1') or (tap_counter = "111111") else '0';
  reset_int        <= not(rdy_status) or rst_r;

  delay_sel_done <= '1' when ((second_edge = '1') or (tap_counter = "111111")) else
                    '0' when (ctrl_dummyread_start = '0') else
                    sel_complete;

  dly_after_first <= "1001" when ((transition = "01") and (first_edge = '0')) else
                     (dly_after_first_cnt - '1') when ((dly_after_first_cnt /= "0000")
                                                       and (dly_inc = '1')) else
                     dly_after_first_cnt;

  curr_dqs_level <= dqs;

-- Shift registers for controls
  process(clk)
  begin
    if clk'event and clk = '1' then
      if reset_int = '1' then
        second_edge_r1      <= '0';
        second_edge_r2      <= '0';
        second_edge_r3      <= '0';
        idelay_rst_idle_r1  <= '0';
        idelay_rst_idle_r2  <= '0';
        idelay_rst_idle_r3  <= '0';
        idelay_rst_idle_r4  <= '0';
        idelay_rst_idle_r5  <= '0';
        idelay_rst_idle_r6  <= '0';
        idelay_inc_idle_r1  <= '0';
        idelay_inc_idle_r2  <= '0';
        idelay_inc_idle_r3  <= '0';
        idelay_inc_idle_r4  <= '0';
        idelay_inc_idle_r5  <= '0';
        idelay_inc_idle_r6  <= '0';
        detect_edge_idle_r1 <= '0';
        detect_edge_idle_r2 <= '0';
        detect_edge_idle_r3 <= '0';
        detect_edge_idle_r4 <= '0';
        detect_edge_idle_r5 <= '0';
        detect_edge_idle_r6 <= '0';
        valid_data_count    <= '0';
      else
        second_edge_r1      <= second_edge;
        second_edge_r2      <= second_edge_r1;
        second_edge_r3      <= second_edge_r2;
        idelay_rst_idle_r1  <= idelay_rst_idle;
        idelay_rst_idle_r2  <= idelay_rst_idle_r1;
        idelay_rst_idle_r3  <= idelay_rst_idle_r2;
        idelay_rst_idle_r4  <= idelay_rst_idle_r3;
        idelay_rst_idle_r5  <= idelay_rst_idle_r4;
        idelay_rst_idle_r6  <= idelay_rst_idle_r5;
        idelay_inc_idle_r1  <= idelay_inc_idle;
        idelay_inc_idle_r2  <= idelay_inc_idle_r1;
        idelay_inc_idle_r3  <= idelay_inc_idle_r2;
        idelay_inc_idle_r4  <= idelay_inc_idle_r3;
        idelay_inc_idle_r5  <= idelay_inc_idle_r4;
        idelay_inc_idle_r6  <= idelay_inc_idle_r5;
        detect_edge_idle_r1 <= detect_edge_idle;
        detect_edge_idle_r2 <= detect_edge_idle_r1;
        detect_edge_idle_r3 <= detect_edge_idle_r2;
        detect_edge_idle_r4 <= detect_edge_idle_r3;
        detect_edge_idle_r5 <= detect_edge_idle_r4;
        detect_edge_idle_r6 <= detect_edge_idle_r5;
        valid_data_count    <= data_count_valid;
      end if;
    end if;
  end process;

-- Tap Delay Selection Complete for Data bus associated with a dqs
  process(clk)
  begin
    if(clk'event and clk = '1') then
      if (reset_int = '1') then
        sel_complete <= '0';
      else
        sel_complete <= delay_sel_done;
      end if;
    end if;
  end process;


-- Start detection of second transition only after 10 taps from first transition
  process(clk)
  begin
    if(clk'event and clk = '1') then
      if (reset_int = '1') then
        dly_after_first_cnt <= "0000";
      else
        dly_after_first_cnt <= dly_after_first;
      end if;
    end if;
  end process;


-- Tap Counter
  process(clk)
  begin
    if(clk'event and clk = '1') then
      if ((reset_int = '1') or (tap_counter = "111111")) then
        tap_counter <= "000000";
      elsif (dly_inc = '1') then
        tap_counter <= tap_counter + '1';
      end if;
    end if;
  end process;

-- Tap value for Data IDELAY circuit
  process(clk)
  begin
    if(clk'event and clk = '1') then
      if (reset_int = '1') then
        first_edge_tap_count <= "000000";
      elsif ((transition = "01") and (first_edge = '0')) then
        first_edge_tap_count <= tap_counter;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if(clk'event and clk = '1') then
      if (reset_int = '1') then
        second_edge_tap_count <= "000000";
      elsif ((transition = "10") and (second_edge = '0')) then
        second_edge_tap_count <= tap_counter;
      end if;
    end if;
  end process;


  process(clk)
  begin
    if(clk'event and clk = '1') then
      if (reset_int = '1') then
        pulse_width_tap_count <= "000000";
      elsif (second_edge_r1 = '1') then
        pulse_width_tap_count <= (second_edge_tap_count - first_edge_tap_count);
      end if;
    end if;
  end process;


  process(clk)
  begin
    if(clk'event and clk = '1') then
      if (reset_int = '1') then
        pulse_center_tap_count <= "000000";
      elsif (second_edge_r2 = '1') then
        pulse_center_tap_count <= '0' & pulse_width_tap_count(5 downto 1);
        -- Shift right to divide by 2 and find pulse center
      end if;
    end if;
  end process;


  process(clk)
  begin
    if(clk'event and clk = '1') then
      if (reset_int = '1') then
        data_bit_tap_count <= "000000";
      elsif (second_edge_r3 = '1') then  -- 2 edges detected
        data_bit_tap_count <= first_edge_tap_count + pulse_center_tap_count;
      elsif ((transition = "01") and ((tap_counter = "111111"))) then
        if (first_edge_tap_count(5) = '0') then
          data_bit_tap_count <= first_edge_tap_count + "010000";
        else
          data_bit_tap_count <= first_edge_tap_count - "010000";
        end if;
      elsif ((transition = "00") and ((tap_counter = "111111"))) then
        data_bit_tap_count <= "100000";
      end if;
    end if;
  end process;


-- Logic required to determine whether the registered dqs is on the edge of
-- meeting setup time in the FPGA clock domain.
-- If dqs is on the edge, then the vector 'flag' will not be "1111" or "0000" and
-- edge detection will not be executed.
-- If dqs is not on the edge, then the vector 'flag' will be "1111" or "0000" and
-- edge detection will be executed.

  process(clk)
  begin
    if clk'event and clk = '1' then
      if (reset_int = '1') then
        flag <= (others => '0');
      elsif (detect_edge_idle_r3 = '1' or idelay_inc_idle_r3 = '1' or
             idelay_rst_idle_r3 = '1') then
        if (curr_dqs_level /= prev_dqs_level) then
          flag(0) <= '0';
        else
          flag(0) <= '1';
        end if;
      elsif (detect_edge_idle_r4 = '1' or idelay_inc_idle_r4 = '1' or
             idelay_rst_idle_r4 = '1') then
        if (curr_dqs_level /= prev_dqs_level) then
          flag(1) <= '0';
        else
          flag(1) <= '1';
        end if;
      elsif (detect_edge_idle_r5 = '1' or idelay_inc_idle_r5 = '1' or
             idelay_rst_idle_r5 = '1') then
        if (curr_dqs_level /= prev_dqs_level) then
          flag(2) <= '0';
        else
          flag(2) <= '1';
        end if;
      elsif (detect_edge_idle_r6 = '1' or idelay_inc_idle_r6 = '1' or
             idelay_rst_idle_r6 = '1') then
        if (curr_dqs_level /= prev_dqs_level) then
          flag(3) <= '0';
        else
          flag(3) <= '1';
        end if;

      end if;
    end if;
  end process;


-- First and second edge assignment logic
  process(clk)
  begin
    if(clk'event and clk = '1') then
      if (reset_int = '1') then
        transition(1 downto 0) <= "00";
      elsif ((dly_after_first_cnt = "0000") and (state = DETECT_EDGE) and
             ((flag = X"0") or (flag = X"F"))) then
        if ((curr_dqs_level /= prev_dqs_level) and (transition_rst = '0') and
            (tap_counter > "000000")) then
          transition <= transition + '1';
        end if;
      elsif (transition_rst = '1') then
        transition <= "00";
      else
        transition <= transition;
      end if;
    end if;
  end process;


  process(clk)
  begin
    if(clk'event and clk = '1') then
      if (reset_int = '1') then
        transition_rst <= '0';
        first_edge     <= '0';
        second_edge    <= '0';
      else
        case transition is
          when "01" =>
            first_edge <= '1';

          when "10" =>
            if (transition_rst = '1') then
              second_edge    <= '0';
              transition_rst <= '0';
            else
              second_edge    <= '1';
              transition_rst <= '1';
            end if;
          when others =>
            first_edge  <= '0';
            second_edge <= '0';
        end case;
      end if;
    end if;
  end process;

-- State Machine for edge detection and midpoint determination
  process(clk)
  begin
    if(clk'event and clk = '1') then
      if (reset_int = '1') then         -- dqs IDELAY in reset
        dly_rst           <= '1';
        dly_ce            <= '0';
        dly_inc           <= '0';
        idelay_rst_idle   <= '0';
        detect_edge_idle  <= '0';
        idelay_inc_idle   <= '0';
        prev_dqs_level    <= curr_dqs_level;
        state(2 downto 0) <= IDELAY_RST;
      elsif ((ctrl_dummyread_start = '1') and (sel_complete = '0')) then
        case state is
          when "000" =>                 -- IDELAY_RST
            dly_rst           <= '1';
            dly_ce            <= '0';
            dly_inc           <= '0';
            idelay_rst_idle   <= '1';
            state(2 downto 0) <= IDLE;
          when "001" =>                 -- IDLE
            dly_rst          <= '0';
            dly_ce           <= '0';
            dly_inc          <= '0';
            idelay_rst_idle  <= '0';
            detect_edge_idle <= '0';
            idelay_inc_idle  <= '0';
            if (idelay_rst_idle_r5 = '1') then
              state(2 downto 0) <= IDELAY_INC;
            elsif ((idelay_inc_idle_r6 = '1') or ((detect_edge_idle_r6 = '1')
                    and (second_edge_r2 = '0') and (tap_counter /= "111111"))) then
              state(2 downto 0) <= DETECT_EDGE;
            else
              state(2 downto 0) <= IDLE;
            end if;
          when "010" =>                 -- IDELAY_INC
            dly_rst           <= '0';
            dly_ce            <= '1';
            dly_inc           <= '1';
            idelay_inc_idle   <= '1';
            state(2 downto 0) <= IDLE;
            if((flag(3 downto 0) = X"0") or (flag(3 downto 0) = X"F")) then
              prev_dqs_level <= curr_dqs_level;
            else
              prev_dqs_level <= prev_dqs_level;
            end if;

          when "011" =>                 -- DETECT_EDGE
            dly_rst           <= '0';
            dly_ce            <= '1';
            dly_inc           <= '1';
            detect_edge_idle  <= '1';
            state(2 downto 0) <= IDLE;
            if((flag(3 downto 0) = X"0") or (flag(3 downto 0) = X"F")) then
              prev_dqs_level <= curr_dqs_level;
            else
              prev_dqs_level <= prev_dqs_level;
            end if;
          when others =>
            dly_rst           <= '0';
            dly_ce            <= '0';
            dly_inc           <= '0';
            idelay_rst_idle   <= '0';
            detect_edge_idle  <= '0';
            idelay_inc_idle   <= '0';
            prev_dqs_level    <= curr_dqs_level;
            state(2 downto 0) <= IDLE;
        end case;
      else
        dly_rst          <= '0';
        dly_ce           <= '0';
        dly_inc          <= '0';
        idelay_rst_idle  <= '0';
        detect_edge_idle <= '0';
        idelay_inc_idle  <= '0';
        prev_dqs_level   <= curr_dqs_level;
        state            <= IDELAY_RST;
      end if;
    end if;
  end process;

end arch;
