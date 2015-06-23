-------------------------------------------------------------------------------
-- Title      : 16x2 LCD controller
-- Project    : 
-------------------------------------------------------------------------------
-- File       : lcd16x2_ctrl.vhd
-- Author     :   <stachelsau@T420>
-- Company    : 
-- Created    : 2012-07-28
-- Last update: 2012-11-28
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: The controller initializes the display when rst goes to '0'.
--              After that it writes the contend of the input signals
--              line1_buffer and line2_buffer continously to the display.
-------------------------------------------------------------------------------
-- Copyright (c) 2012 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2012-07-28  1.0      stachelsau      Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity lcd16x2_ctrl is
  
  generic (
    CLK_PERIOD_NS : positive := 20);    -- 50MHz

  port (
    clk          : in  std_logic;
    rst          : in  std_logic;
    lcd_e        : out std_logic;
    lcd_rs       : out std_logic;
    lcd_rw       : out std_logic;
    lcd_db       : out std_logic_vector(7 downto 4);
    line1_buffer : in  std_logic_vector(127 downto 0);  -- 16x8bit
    line2_buffer : in  std_logic_vector(127 downto 0)); 

end entity lcd16x2_ctrl;

architecture rtl of lcd16x2_ctrl is

  constant DELAY_15_MS   : positive := 15 * 10**6 / CLK_PERIOD_NS + 1;
  constant DELAY_1640_US : positive := 1640 * 10**3 / CLK_PERIOD_NS + 1;
  constant DELAY_4100_US : positive := 4100 * 10**3 / CLK_PERIOD_NS + 1;
  constant DELAY_100_US  : positive := 100 * 10**3 / CLK_PERIOD_NS + 1;
  constant DELAY_40_US   : positive := 40 * 10**3 / CLK_PERIOD_NS + 1;

  constant DELAY_NIBBLE     : positive := 10**3 / CLK_PERIOD_NS + 1;
  constant DELAY_LCD_E      : positive := 230 / CLK_PERIOD_NS + 1;
  constant DELAY_SETUP_HOLD : positive := 40 / CLK_PERIOD_NS + 1;

  constant MAX_DELAY : positive := DELAY_15_MS;

  -- this record describes one write operation
  type op_t is record
    rs      : std_logic;
    data    : std_logic_vector(7 downto 0);
    delay_h : integer range 0 to MAX_DELAY;
    delay_l : integer range 0 to MAX_DELAY;
  end record op_t;
  constant default_op      : op_t := (rs => '1', data => X"00", delay_h => DELAY_NIBBLE, delay_l => DELAY_40_US);
  constant op_select_line1 : op_t := (rs => '0', data => X"80", delay_h => DELAY_NIBBLE, delay_l => DELAY_40_US);
  constant op_select_line2 : op_t := (rs => '0', data => X"C0", delay_h => DELAY_NIBBLE, delay_l => DELAY_40_US);

  -- init + config operations:
  -- write 3 x 0x3 followed by 0x2
  -- function set command
  -- entry mode set command
  -- display on/off command
  -- clear display
  type config_ops_t is array(0 to 5) of op_t;
  constant config_ops : config_ops_t
    := (5 => (rs => '0', data => X"33", delay_h => DELAY_4100_US, delay_l => DELAY_100_US),
        4 => (rs => '0', data => X"32", delay_h => DELAY_40_US, delay_l => DELAY_40_US),
        3 => (rs => '0', data => X"28", delay_h => DELAY_NIBBLE, delay_l => DELAY_40_US),
        2 => (rs => '0', data => X"06", delay_h => DELAY_NIBBLE, delay_l => DELAY_40_US),
        1 => (rs => '0', data => X"0C", delay_h => DELAY_NIBBLE, delay_l => DELAY_40_US),
        0 => (rs => '0', data => X"01", delay_h => DELAY_NIBBLE, delay_l => DELAY_1640_US));

  signal this_op : op_t;

  type op_state_t is (IDLE,
                      WAIT_SETUP_H,
                      ENABLE_H,
                      WAIT_HOLD_H,
                      WAIT_DELAY_H,
                      WAIT_SETUP_L,
                      ENABLE_L,
                      WAIT_HOLD_L,
                      WAIT_DELAY_L,
                      DONE);

  signal op_state      : op_state_t := DONE;
  signal next_op_state : op_state_t;
  signal cnt           : natural range 0 to MAX_DELAY;
  signal next_cnt      : natural range 0 to MAX_DELAY;

  type state_t is (RESET,
                   CONFIG,
                   SELECT_LINE1,
                   WRITE_LINE1,
                   SELECT_LINE2,
                   WRITE_LINE2);

  signal state      : state_t               := RESET;
  signal next_state : state_t;
  signal ptr        : natural range 0 to 15 := 0;
  signal next_ptr   : natural range 0 to 15;

begin

  proc_state : process(state, op_state, ptr, line1_buffer, line2_buffer) is
  begin
    case state is
      when RESET =>
        this_op    <= default_op;
        next_state <= CONFIG;
        next_ptr   <= config_ops_t'high;
        
      when CONFIG =>
        this_op    <= config_ops(ptr);
        next_ptr   <= ptr;
        next_state <= CONFIG;
        if op_state = DONE then
          next_ptr <= ptr - 1;
          if ptr = 0 then
            next_state <= SELECT_LINE1;
          end if;
        end if;

      when SELECT_LINE1 =>
        this_op  <= op_select_line1;
        next_ptr <= 15;
        if op_state = DONE then
          next_state <= WRITE_LINE1;
        else
          next_state <= SELECT_LINE1;
        end if;

      when WRITE_LINE1 =>
        this_op      <= default_op;
        this_op.data <= line1_buffer(ptr*8 + 7 downto ptr*8);
        next_ptr     <= ptr;
        next_state   <= WRITE_LINE1;
        if op_state = DONE then
          next_ptr <= ptr - 1;
          if ptr = 0 then
            next_state <= SELECT_LINE2;
          end if;
        end if;

      when SELECT_LINE2 =>
        this_op  <= op_select_line2;
        next_ptr <= 15;
        if op_state = DONE then
          next_state <= WRITE_LINE2;
        else
          next_state <= SELECT_LINE2;
        end if;

      when WRITE_LINE2 =>
        this_op      <= default_op;
        this_op.data <= line2_buffer(ptr*8 + 7 downto ptr*8);
        next_ptr     <= ptr;
        next_state   <= WRITE_LINE2;
        if op_state = DONE then
          next_ptr <= ptr - 1;
          if ptr = 0 then
            next_state <= SELECT_LINE1;
          end if;
        end if;
        
    end case;
  end process proc_state;

  reg_state : process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        state <= RESET;
        ptr   <= 0;
      else
        state <= next_state;
        ptr   <= next_ptr;
      end if;
    end if;
  end process reg_state;

  -- we never read from the lcd
  lcd_rw <= '0';

  proc_op_state : process(op_state, cnt, this_op) is
  begin
    case op_state is
      when IDLE =>
        lcd_db        <= (others => '0');
        lcd_rs        <= '0';
        lcd_e         <= '0';
        next_op_state <= WAIT_SETUP_H;
        next_cnt      <= DELAY_SETUP_HOLD;
        
      when WAIT_SETUP_H =>
        lcd_db <= this_op.data(7 downto 4);
        lcd_rs <= this_op.rs;
        lcd_e  <= '0';
        if cnt = 0 then
          next_op_state <= ENABLE_H;
          next_cnt      <= DELAY_LCD_E;
        else
          next_op_state <= WAIT_SETUP_H;
          next_cnt      <= cnt - 1;
        end if;

      when ENABLE_H =>
        lcd_db <= this_op.data(7 downto 4);
        lcd_rs <= this_op.rs;
        lcd_e  <= '1';
        if cnt = 0 then
          next_op_state <= WAIT_HOLD_H;
          next_cnt      <= DELAY_SETUP_HOLD;
        else
          next_op_state <= ENABLE_H;
          next_cnt      <= cnt - 1;
        end if;

      when WAIT_HOLD_H =>
        lcd_db <= this_op.data(7 downto 4);
        lcd_rs <= this_op.rs;
        lcd_e  <= '0';
        if cnt = 0 then
          next_op_state <= WAIT_DELAY_H;
          next_cnt      <= this_op.delay_h;
        else
          next_op_state <= WAIT_HOLD_H;
          next_cnt      <= cnt - 1;
        end if;

      when WAIT_DELAY_H =>
        lcd_db <= (others => '0');
        lcd_rs <= '0';
        lcd_e  <= '0';
        if cnt = 0 then
          next_op_state <= WAIT_SETUP_L;
          next_cnt      <= DELAY_SETUP_HOLD;
        else
          next_op_state <= WAIT_DELAY_H;
          next_cnt      <= cnt - 1;
        end if;

      when WAIT_SETUP_L =>
        lcd_db <= this_op.data(3 downto 0);
        lcd_rs <= this_op.rs;
        lcd_e  <= '0';
        if cnt = 0 then
          next_op_state <= ENABLE_L;
          next_cnt      <= DELAY_LCD_E;
        else
          next_op_state <= WAIT_SETUP_L;
          next_cnt      <= cnt - 1;
        end if;

      when ENABLE_L =>
        lcd_db <= this_op.data(3 downto 0);
        lcd_rs <= this_op.rs;
        lcd_e  <= '1';
        if cnt = 0 then
          next_op_state <= WAIT_HOLD_L;
          next_cnt      <= DELAY_SETUP_HOLD;
        else
          next_op_state <= ENABLE_L;
          next_cnt      <= cnt - 1;
        end if;

      when WAIT_HOLD_L =>
        lcd_db <= this_op.data(3 downto 0);
        lcd_rs <= this_op.rs;
        lcd_e  <= '0';
        if cnt = 0 then
          next_op_state <= WAIT_DELAY_L;
          next_cnt      <= this_op.delay_l;
        else
          next_op_state <= WAIT_HOLD_L;
          next_cnt      <= cnt - 1;
        end if;

      when WAIT_DELAY_L =>
        lcd_db <= (others => '0');
        lcd_rs <= '0';
        lcd_e  <= '0';
        if cnt = 0 then
          next_op_state <= DONE;
          next_cnt      <= 0;
        else
          next_op_state <= WAIT_DELAY_L;
          next_cnt      <= cnt - 1;
        end if;

      when DONE =>
        lcd_db        <= (others => '0');
        lcd_rs        <= '0';
        lcd_e         <= '0';
        next_op_state <= IDLE;
        next_cnt      <= 0;
        
    end case;
  end process proc_op_state;

  reg_op_state : process (clk) is
  begin
    if rising_edge(clk) then
      if state = RESET then
        op_state <= IDLE;
      else
        op_state <= next_op_state;
        cnt      <= next_cnt;
      end if;
    end if;
  end process reg_op_state;
  

end architecture rtl;
