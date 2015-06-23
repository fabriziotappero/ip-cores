-------------------------------------------------------------------------------
-- Title      :
-- Project    : 
-------------------------------------------------------------------------------
-- File       : aif_read_in_burst
-- Author     : kulmala3
-- Created    : 01.07.2005
-- Last update: 28.07.2006
-- Description: Input: regular fifo IF: output asynchronous ack/nack IF
--
-------------------------------------------------------------------------------
-- Copyright (c) 2005 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 01.07.2005  1.0      AK      Created
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity aif_read_in_burst is
  generic (
    parity_g      : integer := 0;       -- do we send parity or no
    burst_width_g : integer := 6;       -- length = data_w/burst_w
    data_width_g  : integer := 36
    );
  port (
    clk       : in  std_logic;
    rst_n     : in  std_logic;
    empty_in  : in  std_logic;
    re_out    : out std_logic;
    data_in   : in  std_logic_vector(data_width_g-1 downto 0);
    data_out  : out std_logic_vector(burst_width_g-1 downto 0);
    a_we_out  : out std_logic;
    burst_out : out std_logic;
    nack_in   : in  std_logic;
    ack_in    : in  std_logic

    );                                  
end aif_read_in_burst;

architecture rtl of aif_read_in_burst is
  constant stages_c : integer := 2;     -- only works with 2 now
  signal   ack_r    : std_logic_vector(stages_c-1 downto 0);
  signal   nack_r   : std_logic_vector(stages_c-1 downto 0);

  constant b_length_c : integer := data_width_g / burst_width_g;

  signal slow_cnt_r   : integer range 0 to 15;  -- slowdown counter
  signal slow_value_r : integer range 0 to 15;  -- slowdown counter
  signal fail_cnt_r   : integer range 0 to 1;  -- two times we try to send per speed
  signal a_we_l       : std_logic;
--  signal full_r : std_logic;

  type   data_vec_type is array (0 to b_length_c-1) of std_logic_vector(burst_width_g-1 downto 0);
  signal data_slice  : std_logic_vector(burst_width_g-1 downto 0);
--  signal datavec     : data_vec_type;
  signal slice_cnt_r : integer range 0 to b_length_c-1;

  signal ack_receiveid_r  : std_logic;
  signal nack_receiveid_r : std_logic;

  type   send_state is (wait_data, send_burst, wait_ack, read_fifo);
  signal ctrl_r : send_state;

  signal burst_r : std_logic;
  
begin
  
  a_we_out <= a_we_l;

  data_out <= data_slice;

  burst_out <= burst_r;

  process (clk, rst_n)
  begin  -- process
    if rst_n = '0' then                 -- asynchronous reset (active low)
      a_we_l           <= '0';
      re_out           <= '0';
      ack_r            <= (others => '0');
      nack_r           <= (others => '0');
      slow_cnt_r       <= 1;
      slice_cnt_r      <= 0;
      fail_cnt_r       <= 0;
      ctrl_r           <= wait_data;
      slow_value_r     <= 1;
      ack_receiveid_r  <= '0';
      nack_receiveid_r <= '0';
      burst_r          <= '0';
      
    elsif clk'event and clk = '1' then  -- rising clock edge
      for i in 0 to stages_c-2 loop
        ack_r(i+1)  <= ack_r(i);
        nack_r(i+1) <= nack_r(i);
      end loop;  -- i
      ack_r(0)  <= ack_in;
      nack_r(0) <= nack_in;

      ack_receiveid_r  <= ack_receiveid_r or ((ack_r(stages_c-1) xor ack_r(stages_c-2)));
      nack_receiveid_r <= nack_receiveid_r or ((nack_r(stages_c-1) xor nack_r(stages_c-2)));

      case ctrl_r is
        when wait_data =>
          if empty_in = '1' then
            ctrl_r <= wait_data;
          else
            -- data in HIBI FIFO, send it
            a_we_l      <= not a_we_l;
            slow_cnt_r  <= slow_value_r;
            slice_cnt_r <= 0;
            ctrl_r      <= send_burst;
          end if;

        when send_burst =>
--          if slow_cnt_r = 1 then
--            slow_cnt_r <= slow_cnt_r-1;
--            if slice_cnt_r = b_length_c-1 then
--              ctrl_r      <= wait_ack;
--              burst_r <= not burst_r;
--              slice_cnt_r <= 0;         -- last one
--            else
--              slice_cnt_r <= slice_cnt_r+1;
--            end if;
--          elsif slow_cnt_r = 0 then
--            a_we_l     <= not a_we_l;
--            slow_cnt_r <= slow_value_r;
--          else
--            slow_cnt_r <= slow_cnt_r-1;
--          end if;

          if slow_cnt_r = 0 then
            a_we_l     <= not a_we_l;
            slow_cnt_r <= slow_value_r;
          elsif slow_cnt_r = 1 then --slow_value_r then
            
            if slice_cnt_r = b_length_c-1 then
              ctrl_r      <= wait_ack;
              burst_r     <= not burst_r;
              slice_cnt_r <= 0;         -- last one
            else
              slice_cnt_r <= slice_cnt_r+1;
            end if;
            slow_cnt_r <= slow_cnt_r-1;
          else
            slow_cnt_r <= slow_cnt_r-1;
            
          end if;
          
        when wait_ack =>
          if ack_receiveid_r = '1' then
            ack_receiveid_r <= '0';
            ctrl_r          <= read_fifo;
            re_out          <= '1';
          end if;

          if nack_receiveid_r = '1' then
            nack_receiveid_r <= '0';
            slow_value_r <= slow_value_r+1;
            slow_cnt_r   <= slow_value_r+1;
            a_we_l       <= not a_we_l;
            ctrl_r       <= send_burst;
            slice_cnt_r  <= 0;          -- ha´s been for a while now
          end if;

        when read_fifo =>
          re_out <= '0';
          ctrl_r <= wait_data;
          
        when others => null;
      end case;
      
      
    end if;
  end process;


  datamux : process (data_in, slice_cnt_r)
    variable datavec : data_vec_type;
    
  begin  -- process datamux
    datavec(0) := data_in(burst_width_g-1 downto 0);
    for i in 2 to b_length_c loop
      datavec(i-1) := data_in(burst_width_g*(i)-1 downto burst_width_g*(i-1));
    end loop;  -- i
    data_slice <= datavec(slice_cnt_r);
  end process datamux;

end rtl;
