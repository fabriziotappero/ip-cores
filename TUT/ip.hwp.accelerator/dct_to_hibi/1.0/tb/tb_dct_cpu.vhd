-------------------------------------------------------------------------------
-- Title      : Testbench for dct, CPU emulator
-- Project    : 
-------------------------------------------------------------------------------
-- File       : tb_dct_cpu.vhd
-- Author     : 
-- Company    : 
-- Created    : 2006-05-24
-- Last update: 2013-03-22
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: CPU emulator
-------------------------------------------------------------------------------
-- Copyright (c) 2006 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2006-05-24  1.0      rasmusa Created
-------------------------------------------------------------------------------

library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use ieee.std_logic_misc.all;


library std;
use std.textio.all;
use work.tb_dct_package.all;

library dct;
library idct;
library quantizer;
library dctQidct;

use dct.DCT_pkg.all;
use idct.IDCT_pkg.all;
use quantizer.Quantizer_pkg.all;

entity tb_dct_cpu is
  
  generic (
    data_width_g : integer := 32;
    comm_width_g : integer := 5);
  port (
    clk_dctqidct_fast : in std_logic;
    clk               : in std_logic;
    rst_n             : in std_logic;

    data_in  : in  std_logic_vector(data_width_g-1 downto 0);
    comm_in  : in  std_logic_vector(comm_width_g-1 downto 0);
    av_in    : in  std_logic;
    re_out   : out std_logic;
    empty_in : in  std_logic;

    data_out : out std_logic_vector(data_width_g-1 downto 0);
    comm_out : out std_logic_vector(comm_width_g-1 downto 0);
    av_out   : out std_logic;
    we_out   : out std_logic;
    full_in  : in  std_logic;

    dct_data_idct_in  : in std_logic_vector(IDCT_resultw_co-1 downto 0);
    dct_data_quant_in : in std_logic_vector(QUANT_resultw_co-1 downto 0);
    dct_wr_idct_in    : in std_logic;
    dct_wr_quant_in   : in std_logic;
    dct_wr_dct_in     : in std_logic;
    dct_data_dct_in   : in std_logic_vector(DCT_inputw_co-1 downto 0);
    dct_qp_in         : in std_logic_vector(4 downto 0);
    dct_intra_in      : in std_logic;
    dct_chroma_in     : in std_logic;
    dct_loadqp_in     : in std_logic

    );

end tb_dct_cpu;

architecture rtl of tb_dct_cpu is

  constant hibi_addr_cpu_q_c : integer := hibi_addr_cpu_c + 1;
  constant hibi_addr_cpu_i_c : integer := hibi_addr_cpu_c + 2;

  constant data_max_c : integer := 384;
  constant n_blocks_c : integer := 6;
  type     value_vect_type is array (0 to data_max_c-1) of std_logic_vector(16-1 downto 0);
  type     qp_vect_type is array (0 to n_blocks_c-1) of std_logic_vector(4 downto 0);
  constant qp_w_c     : integer := 5;


  type data_type is record
    original  : value_vect_type;
    dct_org   : value_vect_type;
    dct_idct  : value_vect_type;
    idct      : value_vect_type;
    dct_quant : value_vect_type;
    quant     : value_vect_type;
    qp        : qp_vect_type;
    chroma    : std_logic_vector(6-1 downto 0);
    intra     : std_logic_vector(6-1 downto 0);
  end record;

  constant qp_c : integer := 1;

  constant values_per_word_c : integer := data_width_g/16;

  signal data_counter_r : integer range 0 to data_max_c-1;
  signal rx_counter_r   : integer range 0 to 8*8-1;

  signal idle_counter_r : integer;

  signal data_r : data_type;

  signal q_counter_r : integer range 0 to data_max_c-1;
  signal i_counter_r : integer range 0 to data_max_c-1;
  signal d_counter_r : integer range 0 to data_max_c-1;
  signal qp_counter_r : integer range 0 to data_max_c-1;

  signal res_q_cnt_r : integer range 0 to data_max_c-1;
  signal res_i_cnt_r : integer range 0 to data_max_c-1;

  signal result_is_quant_r : std_logic;
  signal last_av_r : integer;

  signal wait_zero_r : std_logic;

  signal test_data_type : integer := 2;
  
  -- CONTROL WORD CONFIG
  signal intra : std_logic := '0';
--  signal intra_old_r : std_logic;
  signal qp    : std_logic_vector(qp_w_c-1 downto 0) := std_logic_vector(to_unsigned(qp_c, qp_w_c));

  type   send_control_type is (idle, send_av, send_ret_addr_q, send_ret_addr_i, send_control, send_data);
  signal send_ctrl,send_ctrl_old : send_control_type;

  signal free_r : std_logic;
  signal new_req_r  : std_logic;
  
  function generate_data (
    constant test_data_type : integer )
    return value_vect_type is
    variable ret_v : value_vect_type;
  begin  -- generate_data
    for i in 0 to data_max_c-1 loop
      if test_data_type = 0 then
        ret_v(i) := std_logic_vector(resize(to_signed( 0, DCT_inputw_co), 16));
      elsif test_data_type = 1 then
        ret_v(i) := std_logic_vector(resize(to_signed( 28, DCT_inputw_co), 16));     
      elsif test_data_type = 2 then        
        ret_v(i) := std_logic_vector(resize(to_signed( ((i*4) mod (i+1))*7, DCT_inputw_co), 16));        
      end if;
    end loop;  -- i
    return ret_v;
  end generate_data;

  
begin  -- rtl

  re_out <= not empty_in;

  process (clk, rst_n)
    variable zero_vect_v : std_logic_vector(data_width_g-qp_w_c-1-1 downto 0) := (others => '0');
  begin  -- process

    if rst_n = '0' then                 -- asynchronous reset (active low)
      send_ctrl       <= idle;
      free_r          <= '1';
      data_r.original <= generate_data(test_data_type);
      send_ctrl <= idle;
      idle_counter_r <= 0;
    elsif clk'event and clk = '1' then  -- rising clock edge

      send_ctrl_old <= send_ctrl;
      if send_ctrl_old /= send_ctrl then
        idle_counter_r <= 0;
      else
        idle_counter_r <= idle_counter_r + 1;
      end if;

      assert idle_counter_r < 20000 report "IDLE TIME EXCEEDED" severity failure;
      
      case send_ctrl is
        
        when idle =>
          if full_in = '0' then
            we_out   <= '0';
            data_out <= (others => '0');
            comm_out <= (others => '0');

            if free_r = '1' or new_req_r = '1' then
              send_ctrl <= send_av;
              free_r    <= '0';
            end if;
            
          end if;

          
        when send_av =>
          av_out    <= '1';
          data_out  <= std_logic_vector(to_unsigned(hibi_addr_dct_c, data_width_g));
          we_out    <= '1';
          comm_out  <= "00010";
          send_ctrl <= send_ret_addr_q;
          
        when send_ret_addr_q =>
          if full_in = '0' then
            av_out    <= '0';
            data_out  <= std_logic_vector(to_unsigned(hibi_addr_cpu_q_c, data_width_g));
            we_out    <= '1';
            send_ctrl <= send_ret_addr_i;
          end if;

        when send_ret_addr_i =>
          if full_in = '0' then
            data_out  <= std_logic_vector(to_unsigned(hibi_addr_cpu_i_c, data_width_g));
            we_out    <= '1';
            send_ctrl <= send_control;
          end if;

        when send_control =>
          if full_in = '0' then
            data_out  <= zero_vect_v & intra & qp;
            we_out    <= '1';
            send_ctrl <= send_data;
            assert false report "REQUEST SENT" severity note;
          end if;

        when send_data =>
          if full_in = '0' then
            we_out <= '1';

            for i in 0 to values_per_word_c-1 loop
              data_out((i+1)*16-1 downto i*16) <= data_r.original(data_counter_r + i);
            end loop;  -- i           

            if data_counter_r = data_max_c-values_per_word_c then
              send_ctrl      <= idle;
              data_counter_r <= 0;
              assert false report "Data sent!" severity note;          
            else
              data_counter_r <= data_counter_r + values_per_word_c;
            end if;

          end if;
          
        when others => null;
      end case;
      
      
    end if;
  end process;

  re_out <= not empty_in;

  rx_proc : process (clk, rst_n)
    variable or_v : std_logic_vector(5 downto 0);
  begin  -- process rx_proc
    if rst_n = '0' then                 -- asynchronous reset (active low)
      rx_counter_r      <= 0;
      result_is_quant_r <= '1';
      res_q_cnt_r       <= 0;
      res_i_cnt_r       <= 0;
      new_req_r <= '0';
      wait_zero_r <= '0';

    elsif clk'event and clk = '1' then  -- rising clock edge

      new_req_r <= '0';
      
      if empty_in = '0' and av_in = '1' then
        last_av_r <= to_integer(unsigned(data_in));
      end if;
      
      if empty_in = '0' and av_in = '1' and data_in = std_logic_vector(to_unsigned(hibi_addr_cpu_rtm_c+2,data_width_g)) then
       assert false report "Got release!" severity note;
       new_req_r <= '1';
       end if;

      if res_q_cnt_r /= 0 and wait_zero_r = '0' then
        wait_zero_r <= '1';
      end if;
      
      if res_q_cnt_r = 0 and empty_in = '0' and av_in = '0' and wait_zero_r = '1' and (last_av_r = hibi_addr_cpu_q_c ) then
        or_v := (others => '0');

        for j in 0 to 5 loop
          for i in j*64 to (j+1)*64-1 loop
            if intra = '0' or i mod 64 /= 0 then
              or_v(j) := or_v(j) or or_reduce( data_r.quant(i) );
            end if;
          end loop;  -- i          
        end loop;  -- j

        
--        for i in 0 to data_max_c-1 loop
--          if intra = '1' then
--            if i mod 64 /= 0 then
--              or_v := or_v or or_reduce(data_r.quant(i));              
--            end if;
--          else
--            or_v := or_v or or_reduce(data_r.quant(i));
--          end if;
--        end loop;  -- i
        
        assert false report "Got zero bit" severity note;
        assert or_v = data_in(5 downto 0) report "Zero bits do not match!" severity failure;


        wait_zero_r <= '0';
        data_r.quant <= (others => (others => '0'));

        
      elsif empty_in = '0' and av_in = '0' and (last_av_r = hibi_addr_cpu_i_c or last_av_r = hibi_addr_cpu_q_c) then

        if result_is_quant_r = '1' then
          
          for i in 0 to values_per_word_c-1 loop
            assert data_in((i+1)*16-1 downto i*16) = data_r.dct_quant(res_q_cnt_r+i) report "Result data mismatch in QUANT" severity failure;
            data_r.quant(res_q_cnt_r+i) <= data_in((i+1)*16-1 downto i*16);
          end loop;  -- i

          if res_q_cnt_r = data_max_c-values_per_word_c then
            res_q_cnt_r <= 0;
            assert false report "QUANT Data received!" severity note;
          else
            res_q_cnt_r <= res_q_cnt_r + values_per_word_c;
          end if;

        else
          for i in 0 to values_per_word_c-1 loop
            assert data_in((i+1)*16-1 downto i*16) = data_r.dct_idct(res_i_cnt_r+i) report "Result data mismatch in IDCT" severity failure;
            data_r.idct(res_i_cnt_r+i) <= data_in((i+1)*16-1 downto i*16);
          end loop;  -- i

          --res_i_cnt_r <= res_i_cnt_r + values_per_word_c;

          if res_i_cnt_r = data_max_c-values_per_word_c then
            res_i_cnt_r <= 0;
            data_r.idct <= (others => (others => '0'));
            assert false report "IDCT Data received!" severity note;
            --new_req_r <= '1';           -- LM to no self 
          else
            res_i_cnt_r <= res_i_cnt_r + values_per_word_c;
          end if;

        end if;

        if rx_counter_r = 8*8-values_per_word_c then
          rx_counter_r      <= 0;
          result_is_quant_r <= not result_is_quant_r;
        else
          rx_counter_r <= rx_counter_r + values_per_word_c;
        end if;
        
      end if;
    end if;
  end process rx_proc;


  ref_storing : process (clk_dctqidct_fast, rst_n)
    variable dct_data_v : std_logic_vector(16-1 downto 0);
  begin  -- process result_storing
    if rst_n = '0' then                 -- asynchronous reset (active low)
      q_counter_r <= 0;
      i_counter_r <= 0;
      d_counter_r <= 0;


    elsif clk_dctqidct_fast'event and clk_dctqidct_fast = '1' then  -- rising clock edge

      
      if dct_wr_idct_in = '1' then

        data_r.dct_idct(i_counter_r) <= std_logic_vector(resize(signed(dct_data_idct_in), 16));

        if i_counter_r = data_max_c-1 then
          i_counter_r <= 0;          
        else
          i_counter_r <= i_counter_r + 1;
        end if;

      end if;

      if dct_wr_quant_in = '1' then

        if q_counter_r mod 64 = 0 and intra = '1' then
          data_r.dct_quant(q_counter_r) <= std_logic_vector(resize(unsigned(dct_data_quant_in), 16));
        else          
          data_r.dct_quant(q_counter_r) <= std_logic_vector(resize(signed(dct_data_quant_in), 16));          
        end if;

        if q_counter_r = data_max_c-1 then
          q_counter_r <= 0;
        else
          q_counter_r <= q_counter_r + 1;
        end if;

      end if;

      if dct_wr_dct_in = '1' then
        dct_data_v := std_logic_vector(resize(signed(dct_data_dct_in), 16));

        assert dct_data_v = data_r.original(d_counter_r) report "DCT Input MISMATCH" severity failure;
        data_r.dct_org(d_counter_r) <= dct_data_v;


        if d_counter_r = data_max_c-1 then
          d_counter_r <= 0;
        else
          d_counter_r <= d_counter_r + 1;
        end if;
        
      end if;

      if dct_loadqp_in = '1' then

        assert dct_chroma_in = '1' or ( qp_counter_r /= 4 and qp_counter_r /= 5 ) report "CHROMA FAILURE" severity failure;

        assert dct_intra_in = intra report "INTRA FAILURE" severity failure;
        assert dct_qp_in = qp report "QP FAILURE" severity failure;
        
        data_r.chroma( qp_counter_r ) <= dct_chroma_in;
        data_r.intra ( qp_counter_r ) <= dct_intra_in;
        data_r.qp( qp_counter_r ) <= dct_qp_in;
        

        if qp_counter_r = n_blocks_c-1 then
          qp_counter_r <= 0;
          assert false report "All QPs went right!" severity note;
        else
          qp_counter_r <= qp_counter_r + 1;
        end if;

      end if;
      
      
    end if;
  end process ref_storing;
  
end rtl;
