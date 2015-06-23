-------------------------------------------------------------------------------
-- Title      :
-- Project    : 
-------------------------------------------------------------------------------
-- File       : aif_read_out_burst
-- Author     : kulmala3
-- Created    : 01.07.2005
-- Last update: 05.01.2006
-- Description: OUT: regular fifo IN: output asynchronous ack/nack IF
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

entity aif_read_out_burst is
  generic (
    parity_g      : integer := 0;       -- do we send parity or no
    burst_width_g : integer := 6;       -- length = data_w/burst_w    
    data_width_g  : integer := 32
    ); 
  port (
    clk       : in  std_logic;
    rst_n     : in  std_logic;
    a_we_in   : in  std_logic;
    ack_out   : out std_logic;
    nack_out  : out std_logic;
    empty_out : out std_logic;
    re_in     : in  std_logic;
    burst_in  : in  std_logic;
    data_in   : in  std_logic_vector(burst_width_g-1 downto 0);
    data_out  : out std_logic_vector(data_width_g-1 downto 0)

    );
end aif_read_out_burst;

architecture rtl of aif_read_out_burst is

  constant stages_c      : integer := 3;
  constant ctrl_stages_c : integer := 2;  -- burst

  constant b_length_c : integer := data_width_g / burst_width_g;

  signal ack_r  : std_logic;
  signal nack_r : std_logic;
  -- synchronizer, last two are xorred
  signal a_we_r : std_logic_vector(stages_c-1 downto 0);

  type   in_data_type is array (0 to stages_c-1) of std_logic_vector(burst_width_g-1 downto 0);
  signal in_data_r : in_data_type;

  signal data_r : std_logic_vector(data_width_g-1 downto 0);

  type   data_vec_type is array (0 to b_length_c-1) of std_logic_vector(burst_width_g-1 downto 0);
--  signal data_slice  : std_logic_vector(burst_width_g-1 downto 0);
--  signal datavec     : data_vec_type;
  signal slice_cnt_r : integer range 0 to b_length_c-1;
  signal burst_r     : std_logic_vector(stages_c-1 downto 0);
  signal empty_r     : std_logic;
  signal data_ok_r   : std_logic;
  
begin
  data_out  <= data_r;
  ack_out   <= ack_r;
  nack_out  <= nack_r;
  empty_out <= empty_r;

  process (clk, rst_n)
  begin  -- process
    if rst_n = '0' then                 -- asynchronous reset (active low)
      a_we_r      <= (others => '0');
      ack_r       <= '0';
      empty_r     <= '1';
      slice_cnt_r <= 0;
      nack_r      <= '0';
      empty_r     <= '1';
      for i in 0 to stages_c-1 loop
        in_data_r(i) <= (others => '0');
      end loop;  -- i
      burst_r   <= (others => '0');
      data_ok_r <= '0';
      
    elsif clk'event and clk = '1' then  -- rising clock edge
      ack_r <= ack_r;

      for i in 0 to stages_c-2 loop
        a_we_r(i+1)    <= a_we_r(i);
        in_data_r(i+1) <= in_data_r(i);
        burst_r(i+1)   <= burst_r(i);
      end loop;  -- i

      burst_r(0)   <= burst_in;
      a_we_r(0)    <= a_we_in;
      in_data_r(0) <= data_in;

      if (a_we_r(stages_c-1) xor a_we_r(stages_c-2)) = '1' then
        -- slice cnt testaus!
        
        for i in 0 to b_length_c-1 loop
          if i = slice_cnt_r then
            data_r((i+1)*burst_width_g-1 downto burst_width_g*(i)) <= in_data_r(stages_c-2);
          end if;
        end loop;  -- i

        if slice_cnt_r = b_length_c-1 then
          empty_r     <= '0';
          slice_cnt_r <= 0;
          data_ok_r   <= '1';
        else
          empty_r     <= '1';
          slice_cnt_r <= slice_cnt_r+1;
        end if;

      end if;

      if (burst_r(stages_c-1) xor burst_r(stages_c-2)) = '1' then
        if data_ok_r = '0' then
          nack_r      <= not nack_r;
          empty_r     <= '1';
          slice_cnt_r <= 0;
        else
          data_ok_r <= '0';
        end if;
      end if;

      if re_in = '1' and empty_r = '0' then
        -- acknowledge, stop writing
        ack_r   <= not ack_r;
        empty_r <= '1';
      end if;


    end if;
  end process;
  
end rtl;
