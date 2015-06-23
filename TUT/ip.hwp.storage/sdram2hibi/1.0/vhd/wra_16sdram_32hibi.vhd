-------------------------------------------------------------------------------
-- Title      : Adapter wrapper 16-bit sdram <-> 32-bit hibi
-- Project    : 
-------------------------------------------------------------------------------
-- File       : wra_16sdram_32hibi.vhd
-- Author     :   <alhonena@AHVEN>
-- Company    : 
-- Created    : 2012-01-26
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: It was easier and more fail-safe to make an adapter block
-- to connect sdram2hibi to a 16-bit sdram, than trying to modify the
-- sdram2hibi to directly support 16-bit sdram.
-- This is connected between sdram_controller and sdram2hibi.
--
-- Converts the operations to two times longer/shorter operations,
-- transparently like it would be just a slower 32-bit sdram.
--
-- As of 2012-01-26, there still might be room for some optimization.
-------------------------------------------------------------------------------
-- Copyright (c) 2012 Tampere University of Technology
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2012-01-26  1.0      alhonena	Created
-- 2012-04-10  1.1      alhonena  PLEASE NOTE: The SDRAM controller block,
-- for some mysterious reason, ABORTS the read/write operation if fifo gets
-- full/empty. This weird behavior is a considered decision by the author,
-- so I didn't go and break the compatibility. This fact makes this adapter
-- block a way more complex than necessary. In fact it also makes the
-- hibi2sdram more complex. In the future we might want to simplify the whole
-- circus.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity wra_16sdram_32hibi is

  generic (
    mem_addr_width_g     : integer := 22
    );
  
  port (
    clk   : in std_logic;
    rst_n : in std_logic;

    
    -- FROM/TO SDRAM2HIBI: the 32-bit interface.

    sdram2hibi_write_on_out    : out std_logic;
    sdram2hibi_comm_in         : in  std_logic_vector(1 downto 0);
    sdram2hibi_addr_in         : in  std_logic_vector(21 downto 0);
    sdram2hibi_data_amount_in  : in  std_logic_vector(mem_addr_width_g-1 downto 0);
    sdram2hibi_input_one_d_in  : in  std_logic;
    sdram2hibi_input_empty_in  : in  std_logic;
    sdram2hibi_output_full_in  : in  std_logic;
    sdram2hibi_busy_out        : out std_logic;
    sdram2hibi_re_out          : out std_logic;
    sdram2hibi_we_out          : out std_logic;

    sdram2hibi_data_in         : in  std_logic_vector(31 downto 0);
    sdram2hibi_data_out        : out std_logic_vector(31 downto 0);

    -- FROM/TO SDRAM_CONTROLLER: the 16-bit interface.

    ctrl_command_out            : out std_logic_vector(1 downto 0);
    ctrl_address_out            : out std_logic_vector(21 downto 0);
    ctrl_data_amount_out        : out std_logic_vector(mem_addr_width_g-1 downto 0);
    ctrl_byte_select_out        : out std_logic_vector(1 downto 0);
    ctrl_input_empty_out        : out std_logic;
    ctrl_input_one_d_out        : out std_logic;
    ctrl_output_full_out        : out std_logic;
    ctrl_data_out               : out std_logic_vector(15 downto 0);
    ctrl_write_on_in            : in  std_logic;
    ctrl_busy_in                : in  std_logic;
    ctrl_output_we_in           : in  std_logic;
    ctrl_input_re_in            : in  std_logic;
    ctrl_data_in                : in  std_logic_vector(15 downto 0)    

    );

end wra_16sdram_32hibi;

architecture rtl of wra_16sdram_32hibi is

  -- commands
  constant command_nop_c   : std_logic_vector(1 downto 0) := "00";
  constant command_read_c  : std_logic_vector(1 downto 0) := "01";
  constant command_write_c : std_logic_vector(1 downto 0) := "10";

  type state_t is (idle, read_1, read_2, read_stall, write_1, write_2);
  signal state_r : state_t;

  signal read_temp_r  : std_logic_vector(15 downto 0);
  signal write_temp_r : std_logic_vector(15 downto 0);

  signal data_cnt_r  : unsigned(mem_addr_width_g-1 downto 0);
  signal cur_addr_r : unsigned(mem_addr_width_g-1 downto 0);

  signal sdram2hibi_re_out_r : std_logic;

  signal ctrl_input_empty_out_r : std_logic;
  
begin  -- rtl

  -- Full signal for read operations gets propagated through.
  ctrl_output_full_out <= sdram2hibi_output_full_in;

  busy_proc: process (state_r, ctrl_busy_in)
  begin  -- process busy_proc
    if ctrl_busy_in = '1' or state_r /= idle then
      sdram2hibi_busy_out <= '1';
    else
      sdram2hibi_busy_out <= '0';
    end if;
  end process busy_proc;

  ctrl_byte_select_out <= "00";         -- not implemented in sdram2hibi.

  -- This dirty "write on" signal is used in sdram2hibi to count actual
  -- words written in sdram to know when the operation is finished.
  sdram2hibi_write_on_out <= sdram2hibi_re_out_r;

  sdram2hibi_re_out <= sdram2hibi_re_out_r;
  ctrl_input_empty_out <= ctrl_input_empty_out_r;

  -- Ask for double amount of words.
  -- Hence, amount is guaranteed to be even and is checked only at read_2 and write_2.
  ctrl_data_amount_out <= std_logic_vector(data_cnt_r(mem_addr_width_g-2 downto 0)) & '0';
  ctrl_address_out <= std_logic_vector(cur_addr_r);
  
  fsm: process (clk, rst_n)
  begin  -- process fsm
    if rst_n = '0' then                 -- asynchronous reset (active low)
      state_r <= idle;
      ctrl_command_out <= command_nop_c;
      ctrl_input_empty_out_r <= '1';
      ctrl_input_one_d_out <= '0';
      
    elsif clk'event and clk = '1' then  -- rising clock edge

      sdram2hibi_we_out   <= '0';
      sdram2hibi_re_out_r   <= '0';

      case state_r is

        ---------------------------------------------------------
        when idle =>
        ---------------------------------------------------------

          if ctrl_input_re_in = '1' then
            -- this happens when coming from write_2.
            ctrl_input_empty_out_r <= '1';
            ctrl_input_one_d_out   <= '0';
          end if;

          ctrl_command_out <= command_nop_c;
          
          if sdram2hibi_comm_in = command_read_c then
            ctrl_command_out <= command_read_c;
            -- multiply the address by 2 because it's a word address.
            cur_addr_r           <= unsigned(sdram2hibi_addr_in(20 downto 0) & '0');
            data_cnt_r           <= unsigned(sdram2hibi_data_amount_in);  -- count 32-bit words, it's easier.
            state_r <= read_1;
          end if;

          if sdram2hibi_comm_in = command_write_c then
            ctrl_command_out <= command_write_c;
            -- multiply the address by 2 because it's a word address.
            cur_addr_r          <= unsigned(sdram2hibi_addr_in(20 downto 0) & '0');
            data_cnt_r          <= unsigned(sdram2hibi_data_amount_in);  -- count 32-bit words, it's easier.
            state_r <= write_1;
          end if;          

        ---------------------------------------------------------
        when read_1 =>
        ---------------------------------------------------------

          if ctrl_output_we_in = '1' then
            cur_addr_r <= cur_addr_r + to_unsigned(1, mem_addr_width_g);
            read_temp_r <= ctrl_data_in;
            state_r <= read_2;
          end if;
          
        ---------------------------------------------------------
        when read_2 =>
        ---------------------------------------------------------
          
          if ctrl_output_we_in = '1' then
            cur_addr_r <= cur_addr_r + to_unsigned(1, mem_addr_width_g);
            sdram2hibi_data_out <= ctrl_data_in & read_temp_r;
            if sdram2hibi_output_full_in = '0' then
              sdram2hibi_we_out   <= '1';
            else
              state_r <= read_stall;
            end if;

            if data_cnt_r = 1 then
              state_r <= idle;
              ctrl_command_out <= command_nop_c;
            else
              state_r <= read_1;
              data_cnt_r <= data_cnt_r - to_unsigned(1, mem_addr_width_g);             
            end if;
          end if;

        ---------------------------------------------------------
        when read_stall =>
        ---------------------------------------------------------
          -- This should happen only in some very special occasions
          -- because full signal is propagated directly to the controller
          -- in advance, preventing the read operation. So, this happens
          -- when the full rises suddenly after the sdram read.

          -- Data is already written to sdram2hibi_data_out register,
          -- just assert we when possible.
          if sdram2hibi_output_full_in = '0' then
            sdram2hibi_we_out <= '1';

            if data_cnt_r = 1 then
              state_r <= idle;
              ctrl_command_out <= command_nop_c;
            else
              state_r <= read_1;
              data_cnt_r <= data_cnt_r - to_unsigned(1, mem_addr_width_g);             
            end if;

          end if;

        ---------------------------------------------------------
        when write_1 =>
        ---------------------------------------------------------

          if ctrl_input_re_in = '1' then
            -- this happens when coming from write_2. This is
            -- overridden if there is something to write right
            -- away.
            cur_addr_r <= cur_addr_r + to_unsigned(1, mem_addr_width_g);            
            ctrl_input_empty_out_r <= '1';
            ctrl_input_one_d_out   <= '0';
          end if;
          
          if sdram2hibi_input_empty_in = '0' then
            -- Here, assert sdram2hibi side re for one cycle but
            -- use a temp register for the next data. This way,
            -- sdram2hibi_input_empty_in has time to get to the
            -- new value before we are again in this state.
            sdram2hibi_re_out_r <= '1';
            write_temp_r  <= sdram2hibi_data_in(31 downto 16);

            ctrl_data_out <= sdram2hibi_data_in(15 downto 0);           
            ctrl_input_empty_out_r <= '0';
            ctrl_input_one_d_out   <= '0';  -- tell that there are more words!
            state_r <= write_2;
          end if;

        ---------------------------------------------------------
        when write_2 =>
        ---------------------------------------------------------

          if ctrl_input_re_in = '1' then
            -- this re is from the write_1 state operation, for the first word.
            -- hence, it's possible to write the next 16 bits.
            ctrl_data_out <= write_temp_r;
            cur_addr_r <= cur_addr_r + to_unsigned(1, mem_addr_width_g);
            ctrl_input_empty_out_r <= '0';

            if data_cnt_r = 1 then
              ctrl_input_one_d_out   <= '1';  -- just one word left.
              state_r <= idle;
              ctrl_command_out <= command_nop_c;
            else
              state_r <= write_1;
              data_cnt_r <= data_cnt_r - to_unsigned(1, mem_addr_width_g);
            end if;
            
          end if;
          

        when others => null;
      end case;
    end if;
  end process fsm;

end rtl;
