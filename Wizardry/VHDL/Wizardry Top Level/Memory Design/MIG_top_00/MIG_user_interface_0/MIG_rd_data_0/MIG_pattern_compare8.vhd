-------------------------------------------------------------------------------
-- Copyright (c) 2005-2007 Xilinx, Inc.
-- This design is confidential and proprietary of Xilinx, All Rights Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /   Vendor             : Xilinx
-- \   \   \/    Version            : $Name: i+IP+131489 $
--  \   \        Application        : MIG
--  /   /        Filename           : MIG_pattern_compare8.vhd
-- /___/   /\    Date Last Modified : $Date: 2007/09/21 15:23:24 $
-- \   \  /  \   Date Created       : Mon May 2 2005
--  \___\/\___\
--
-- Device      : Virtex-4
-- Design Name : DDR SDRAM
-- Description: Compares the IOB output 8 bit data of one bank that is read
--              data during the intilaization to get the delay for the data
--              with respect to the command issued.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
library UNISIM;
use UNISIM.vcomponents.all;

entity MIG_pattern_compare8 is
  port(
    clk            : in  std_logic;
    rst            : in  std_logic;
    ctrl_rden      : in  std_logic;
    rd_data_rise   : in  std_logic_vector(7 downto 0);
    rd_data_fall   : in  std_logic_vector(7 downto 0);
    comp_done      : out std_logic;
    first_rising   : out std_logic;
    rise_clk_count : out std_logic_vector(2 downto 0);
    fall_clk_count : out std_logic_vector(2 downto 0)
    );
end MIG_pattern_compare8;

architecture arch of MIG_pattern_compare8 is

  constant IDLE        : std_logic_vector(1 downto 0) := "00";
  constant FIRST_DATA  : std_logic_vector(1 downto 0) := "01";
  constant SECOND_DATA : std_logic_vector(1 downto 0) := "10";
  constant COMP_OVER   : std_logic_vector(1 downto 0) := "11";

  signal state_rise      : std_logic_vector(1 downto 0);
  signal state_fall      : std_logic_vector(1 downto 0);
  signal next_state_rise : std_logic_vector(1 downto 0);
  signal next_state_fall : std_logic_vector(1 downto 0);
  signal rise_clk_cnt    : std_logic_vector(2 downto 0);
  signal fall_clk_cnt    : std_logic_vector(2 downto 0);
  signal ctrl_rden_r     : std_logic;
  signal pattern_rise1   : std_logic_vector(7 downto 0);
  signal pattern_fall1   : std_logic_vector(7 downto 0);
  signal pattern_rise2   : std_logic_vector(7 downto 0);
  signal pattern_fall2   : std_logic_vector(7 downto 0);
  signal rd_data_rise_r2 : std_logic_vector(7 downto 0);
  signal rd_data_fall_r2 : std_logic_vector(7 downto 0);
  signal rst_r           : std_logic;
begin

  pattern_rise1 <= X"AA";
  pattern_fall1 <= X"55";
  pattern_rise2 <= X"99";
  pattern_fall2 <= X"66";

  process(clk)
  begin
    if(clk'event and clk = '1') then
      rst_r <= rst;
    end if;
  end process;

  process(clk)
  begin
    if(clk'event and clk = '1') then
      if(rst_r = '1') then
        state_rise <= IDLE;
      else
        state_rise <= next_state_rise;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if(clk'event and clk = '1') then
      if(rst_r = '1') then
        state_fall <= IDLE;
      else
        state_fall <= next_state_fall;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if(clk'event and clk = '1') then
      if(rst_r = '1') then
        ctrl_rden_r <= '0';
      else
        ctrl_rden_r <= ctrl_rden;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if(clk'event and clk = '1') then
      if(rst_r = '1') then
        rise_clk_cnt <= "000";
      elsif((state_rise = FIRST_DATA) or (state_rise = SECOND_DATA)) then
        rise_clk_cnt <= rise_clk_cnt + '1';
      end if;
    end if;
  end process;

  rise_clk_count <= rise_clk_cnt when (state_rise = COMP_OVER) else "000";

  comp_done <= '1' when ((state_rise = COMP_OVER) and (state_fall = COMP_OVER))
               else '0';

  process(clk)
  begin
    if(clk'event and clk = '1') then
      if(rst_r = '1') then
        fall_clk_cnt <= "000";
      elsif((state_fall = FIRST_DATA) or (state_fall = SECOND_DATA)) then
        fall_clk_cnt <= fall_clk_cnt + '1';
      end if;
    end if;
  end process;

  fall_clk_count <= fall_clk_cnt when (state_fall = COMP_OVER) else "000";

  process(clk)
  begin
    if (clk = '1' and clk'event) then
      if (rst_r = '1') then
        first_rising <= '0';
      elsif(state_rise = SECOND_DATA and rd_data_rise = pattern_fall2
           and rd_data_rise_r2 = pattern_fall1) then
        first_rising <= '1';
      end if;
    end if;
  end process;

  process(clk)
  begin
    if (clk = '1' and clk'event) then
      if (rst_r = '1') then
        rd_data_rise_r2 <= (others => '0');
        rd_data_fall_r2 <= (others => '0');
      else
        rd_data_rise_r2 <= rd_data_rise;
        rd_data_fall_r2 <= rd_data_fall;
      end if;
    end if;
  end process;

  process(ctrl_rden_r, state_rise, rd_data_rise, rd_data_rise_r2, pattern_rise1,
          pattern_fall1, pattern_rise2, pattern_fall2, rst_r)
  begin
    if(rst_r = '1') then
      next_state_rise <= IDLE;
    else
      case state_rise is
        when IDLE =>
          if(ctrl_rden_r = '1') then
            next_state_rise <= FIRST_DATA;
          else
            next_state_rise <= IDLE;
          end if;

        when FIRST_DATA =>
          if((rd_data_rise = pattern_rise1) or (rd_data_rise = pattern_fall1)) then
            next_state_rise <= SECOND_DATA;
          else
            next_state_rise <= FIRST_DATA;
          end if;

        when SECOND_DATA =>
          if(((rd_data_rise=pattern_rise2) and (rd_data_rise_r2=pattern_rise1)) or
             ((rd_data_rise=pattern_fall2) and (rd_data_rise_r2=pattern_fall1))) then
            next_state_rise <= COMP_OVER;
          else
            next_state_rise <= SECOND_DATA;
          end if;

        when COMP_OVER =>
          next_state_rise <= COMP_OVER;

        when others =>
          next_state_rise <= IDLE;
      end case;
    end if;
  end process;

  process(ctrl_rden_r, state_fall, rd_data_fall, rd_data_fall_r2, pattern_rise1,
          pattern_fall1, pattern_rise2, pattern_fall2, rst_r)
  begin
    if(rst_r = '1') then
      next_state_fall <= IDLE;
    else
      case state_fall is
        when IDLE =>
          if(ctrl_rden_r = '1') then
            next_state_fall <= FIRST_DATA;
          else
            next_state_fall <= IDLE;
          end if;

        when FIRST_DATA =>
          if((rd_data_fall = pattern_rise1) or (rd_data_fall = pattern_fall1)) then
            next_state_fall <= SECOND_DATA;
          else
            next_state_fall <= FIRST_DATA;
          end if;

        when SECOND_DATA =>
          if(((rd_data_fall=pattern_rise2) and (rd_data_fall_r2=pattern_rise1)) or
             ((rd_data_fall=pattern_fall2) and (rd_data_fall_r2=pattern_fall1))) then
            next_state_fall <= COMP_OVER;
          else
            next_state_fall <= SECOND_DATA;
          end if;

        when COMP_OVER =>
          next_state_fall <= COMP_OVER;

        when others =>
          next_state_fall <= IDLE;
      end case;
    end if;
  end process;


end arch;
