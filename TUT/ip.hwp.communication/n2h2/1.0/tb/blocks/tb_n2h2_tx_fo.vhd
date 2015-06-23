------------------------------------------------------------
-- Project     : Engine
-- Author      : Ari Kulmala
-- e-mail      : ari.kulmala@tut.fi
-- Date        : 7.7.2004
-- File        : tb_n2h_tx.vhdl
-- Design      : Syncronous testbench for Nios-to-Hibi v2 (N2H2 )transmitter
--               Unlike rx tb, this does not use config file, but
--               all the tests are hard-coded into this file.
------------------------------------------------------------
-- $Log$
-- Revision 1.1  2005/04/14 06:45:55  kulmala3
-- First version to CVS
--
-- 31.08.04 AK Streaming
-- 05.01.04 AK Interface signals naming changed.
------------------------------------------------------------
-------------------------------------------------------------------------------
-- Funbase IP library Copyright (C) 2011 TUT Department of Computer Systems
--
-- This file is part of HIBI
--
-- This source file may be used and distributed without
-- restriction provided that this copyright statement is not
-- removed from the file and that any derivative work contains
-- the original copyright notice and the associated disclaimer.
--
-- This source file is free software; you can redistribute it
-- and/or modify it under the terms of the GNU Lesser General
-- Public License as published by the Free Software Foundation;
-- either version 2.1 of the License, or (at your option) any
-- later version.
--
-- This source is distributed in the hope that it will be
-- useful, but WITHOUT ANY WARRANTY; without even the implied
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
-- PURPOSE.  See the GNU Lesser General Public License for more
-- details.
--
-- You should have received a copy of the GNU Lesser General
-- Public License along with this source; if not, download it
-- from http://www.opencores.org/lgpl.shtml
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

use work.txt_util.all;


entity tb_n2h2_tx is

end tb_n2h2_tx;

architecture rtl of tb_n2h2_tx is
  constant PERIOD : time := 50 ns;

  constant data_width_c   : integer := 32;  -- bits
  constant amount_width_c : integer := 9;   -- at max 2^amount words sent
  constant addr_width_c   : integer := 32;  -- bits
  constant addr_offset_c  : integer := (data_width_c)/8;

  constant comm_write_c     : std_logic_vector(4 downto 0) := "00010";
  constant comm_idle_c      : std_logic_vector(4 downto 0) := "00000";
  constant comm_write_msg_c : std_logic_vector(4 downto 0) := "00011";

  constant data_start_c    : integer := 0;
  constant wait_req_freq_c : integer := 10;

  -- Clk and reset
  signal clk   : std_logic;
  signal clk2  : std_logic;
  signal rst_n : std_logic;


  -- Two-level FSM in the testbench
  -- There are multiple test cases, and each has 4 phases
  type   test_states is (test1, test2, test3, stop_tests);
  type   test_case_states is (assign, trigger, monitor, finish);
  signal test_ctrl_r      : test_states      := test1;
  signal test_case_ctrl_r : test_case_states := trigger;



  -- signals from n2h_tx
  signal tx_status_duv_tb : std_logic := '0';
  signal tx_busy_duv_tb   : std_logic;

  -- signals from tb to n2h_tx
  signal internal_wait_tb_duv  : std_logic := '0';
  signal tx_irq_tb_duv         : std_logic;
  signal amount_tb_duv         : integer   := 0;
  signal amount_vec_tb_duv     : std_logic_vector(amount_width_c-1 downto 0);
  signal dpram_vec_addr_tb_duv : std_logic_vector(addr_width_c-1 downto 0);
  signal dpram_addr_tb_duv     : integer   := 0;
  signal hibi_addr_tb_duv      : std_logic_vector (data_width_c-1 downto 0);  -- 2011-11-11
  signal comm_tb_duv           : std_logic_vector(4 downto 0);



  --Duv=tx writes to hibi with these
  signal hibi_av_duv_tb       : std_logic := '0';
  signal hibi_data_duv_tb     : integer   := 0;
  signal hibi_data_vec_duv_tb : std_logic_vector(data_width_c-1 downto 0);
  signal hibi_comm_duv_tb     : std_logic_vector(4 downto 0);
  signal hibi_we_duv_tb       : std_logic;
  signal hibi_full_tb_duv     : std_logic := '1';

  -- Duv=tx reads meemory via these avalon signals
  signal avalon_addr_duv_tb          : std_logic_vector(addr_width_c-1 downto 0);
  signal avalon_read_duv_tb          : std_logic;
  signal avalon_vec_readdata_tb_duv  : std_logic_vector(data_width_c-1 downto 0);
  signal avalon_readdata_tb_duv      : integer := 0;
  signal avalon_waitrequest_tb_duv   : std_logic;
  signal avalon_readdatavalid_tb_duv : std_logic;



  -- others
  signal counter_r        : integer := 0;  -- temp counter_r, no special func
  signal new_hibi_addr_r  : integer := 0;
  signal new_amount_r     : integer := 0;
  signal new_dpram_addr_r : integer := 0;




  -- which address hibi should get next
  signal global_hibi_addr_r : integer := 0;
  -- global number of data in next packet
  signal global_amount_r    : integer := 0;
  signal global_comm_r      : std_logic_vector(4 downto 0);
  signal global_dpram_addr  : integer := 0;  -- given dpram addr

  -- check avalon signals
  signal avalon_data_counter_r : integer   := data_start_c;  -- data sent
  signal avalon_addr_counter_r : integer   := 0;    -- avalon addr right?
  signal avalon_amount         : integer   := 0;    -- how many data
  signal avalon_addr_sent      : std_logic := '0';  -- if already gave address
  signal avalon_last_addr      : integer   := 0;    -- store the old addr
  --  signal avalon_gave_data    : std_logic := 0;  -- avalon timing
  --  signal avalon_ok           : std_logic := '0';  -- all the avalon data ok

  -- check hibi signals
  signal hibi_addr_came      : std_logic; --:= '0';
  signal hibi_data_counter_r : integer   := data_start_c;  -- data received
  signal hibi_addr           : integer   := 0;  -- right hibi addr
  signal hibi_amount         : integer   := 0;  -- how many datas hibi has received
  --  signal hibi_ok           : std_logic := '0';  --hibi received all ok.


begin  -- rtl

  --
  -- Instantiate DUV. Note that this is just one sbu-block
  -- from N2H.
  -- 
  -- 
  n2h2_tx_1 : entity work.n2h2_tx
    generic map (
      data_width_g   => data_width_c,
      amount_width_g => amount_width_c
      )
    port map (
      clk   => clk,
      rst_n => rst_n,

      -- Avalon master read interface to access the memory
      avalon_addr_out         => avalon_addr_duv_tb,
      avalon_readdata_in      => avalon_vec_readdata_tb_duv,
      avalon_re_out           => avalon_read_duv_tb,
      avalon_waitrequest_in   => avalon_waitrequest_tb_duv,
      avalon_readdatavalid_in => avalon_readdatavalid_tb_duv,  -- ES 2010/05/07

      -- Hibi interface for sending data
      hibi_data_out => hibi_data_vec_duv_tb,
      hibi_av_out   => hibi_av_duv_tb,
      hibi_full_in  => hibi_full_tb_duv,
      hibi_comm_out => hibi_comm_duv_tb,
      hibi_we_out   => hibi_we_duv_tb,

      -- DMA configuration interface, driven by "N2H ctrl logic" (=tb here)
      tx_start_in        => tx_irq_tb_duv,
      tx_status_done_out => tx_status_duv_tb,
      tx_comm_in         => comm_tb_duv,
      tx_hibi_addr_in    => hibi_addr_tb_duv,  --(others => '0'),
      tx_ram_addr_in     => dpram_vec_addr_tb_duv,
      tx_amount_in       => amount_vec_tb_duv
      );



  -- Processes check_avalon and check_hibi continuously monitor avalon and hibi
  -- buses and automatically check whether the data came right.
  -- It's simple because the sent data is implemented
  -- as a counter and hence the incoming data should be in order.
  -- If theres too much data read from avalon, hibi gets wrong packets
  -- and informs.
  -- If theres too much/few data sent to hibi, hibi informs also.


  -- TB uses integers. Convert them to/from bit vectors for port mapping
  hibi_data_duv_tb      <= to_integer(unsigned(hibi_data_vec_duv_tb));
  amount_vec_tb_duv     <= std_logic_vector(to_unsigned(amount_tb_duv, amount_width_c));
  dpram_vec_addr_tb_duv <=
    std_logic_vector(to_unsigned(dpram_addr_tb_duv, addr_width_c));
  avalon_vec_readdata_tb_duv <=
    std_logic_vector(to_unsigned(avalon_readdata_tb_duv, data_width_c))
    when avalon_readdatavalid_tb_duv = '1' else (others => 'Z');
  hibi_addr_tb_duv <= std_logic_vector (to_unsigned(global_hibi_addr_r, data_width_c));


  --
  -- "Test" is the main process that is implented as a state machine
  -- (test1, test2 ... etc) so that new tests can be easily implemented
  -- 
  test : process (clk, rst_n)
  begin  -- process test
    if rst_n = '0' then                 -- asynchronous reset (active low)
      test_ctrl_r      <= test1;        -- test2;
      test_case_ctrl_r <= trigger;      --assign;

      -- Initializations added 2011-11-11, ES
      comm_tb_duv   <= comm_idle_c;
      global_comm_r <= comm_idle_c;
      tx_irq_tb_duv <= '0';
      
    elsif clk'event and clk = '1' then  -- rising clock edge
      case test_ctrl_r is

        -----------------------------------------------------------------------
        -- tests are controlled by following signals, which must be set
        --       global_hibi_addr_r = where to send
        --       global_amount_r    = how much to send
        --       global_comm_r      = which command to use
        -----------------------------------------------------------------------
        when test1 =>
          -- Basic test: tests action under hibi_full signal
          -- and how one packet is transferred.
          case test_case_ctrl_r is
            when trigger =>
              -- assign and trigger irq.


              if tx_status_duv_tb = '1' then
                global_amount_r    <= 1; --4;
                amount_tb_duv      <= 1; --4;
                global_hibi_addr_r <= 230;
                global_comm_r      <= comm_write_c;
                comm_tb_duv        <= comm_write_c;
                tx_irq_tb_duv      <= '1';
                dpram_addr_tb_duv  <= 8;
                global_dpram_addr  <= 8;
                test_case_ctrl_r   <= monitor;

                -- Assert hibi full signal
                hibi_full_tb_duv <= '1';

              else
                assert false report "Cannot start test1, tx_status low" severity note;
              end if;

              
            when monitor =>
              tx_irq_tb_duv <= '0';

              counter_r <= counter_r+1;
              if counter_r < 10 then
                test_case_ctrl_r <= monitor;
              else
                hibi_full_tb_duv <= '0';
                test_case_ctrl_r <= finish;
              end if;

              -- if tx_status_duv_tb = '1' then
              --  -- values read.
              --                amount_tb_duv     <= 0;
              --                dpram_addr_tb_duv <= 0;
              --                comm_tb_duv       <= comm_idle_c;
              --                -- lets test the full signal
              --              end if;

            when finish =>
              if tx_status_duv_tb = '1' then
                assert false report "test1 finished." severity note;
                test_ctrl_r      <= test2;
                test_case_ctrl_r <= assign;
                counter_r        <= 0;
              else
                test_case_ctrl_r <= finish;
              end if;


            when others => null;
          end case;
        when test2 =>
          -- Tests how multiple packets are transferred and
          -- how max values are treated.

          case test_case_ctrl_r is
            when assign =>
              -- we always go to trigger next, unless otherwise noted.
              test_case_ctrl_r <= trigger;
              -- assign new values
              if counter_r = 0 then
                new_amount_r     <= 6;
                new_hibi_addr_r  <= 6302;
                new_dpram_addr_r <= 400;
              elsif counter_r = 1 then
                new_amount_r     <= 172;
                new_hibi_addr_r  <= 30;
                new_dpram_addr_r <= 300;
              elsif counter_r = 2 then
                new_amount_r     <= 1;
                new_hibi_addr_r  <= 21;
                new_dpram_addr_r <= 323;
              elsif counter_r = 3 then
                new_amount_r     <= 14;
                new_hibi_addr_r  <= 54;
                new_dpram_addr_r <= 12;
              elsif counter_r = 4 then
                new_amount_r     <= 6;
                new_hibi_addr_r  <= 602;
                new_dpram_addr_r <= 40;
              elsif counter_r = 5 then
                new_amount_r     <= 9;
                new_hibi_addr_r  <= 64510;
                new_dpram_addr_r <= 511;
              else
                --stop the tests
                test_ctrl_r      <= stop_tests;
                test_case_ctrl_r <= assign;
              end if;

              counter_r <= counter_r+1;

            when trigger =>
              -- assign and trigger irq.

              if tx_status_duv_tb = '1' then
                global_amount_r    <= new_amount_r;
                amount_tb_duv      <= new_amount_r;
                global_hibi_addr_r <= new_hibi_addr_r;
                global_comm_r      <= comm_write_c;
                comm_tb_duv        <= comm_write_c;
                tx_irq_tb_duv      <= '1';
                dpram_addr_tb_duv  <= new_dpram_addr_r;
                global_dpram_addr  <= new_dpram_addr_r;
                test_case_ctrl_r   <= monitor;
                -- deassert hibi full signal, just in case
                hibi_full_tb_duv   <= '0';

              else
                assert false report "Cannot start test, tx_status low" severity note;
              end if;

            when monitor =>
              tx_irq_tb_duv    <= '0';
              -- if tx_status_duv_tb = '1' then
              --  -- values read.
              --                amount_tb_duv     <= 0;
              --                dpram_addr_tb_duv <= 0;
              --                comm_tb_duv       <= comm_idle_c;
              -- lets test the full signal
              test_case_ctrl_r <= finish;
              -- end if;

            when finish =>
              if tx_status_duv_tb = '1' then
                assert false report "test2 finished." severity note;
                test_case_ctrl_r <= assign;
              else
                test_case_ctrl_r <= finish;
              end if;


            when others => null;
          end case;
        when test3      =>
        when stop_tests =>
          assert false report "All tests finished." severity failure;
        when others => null;
      end case;
    end if;
  end process test;



  --
  -- Checks whether data going to hibi is right
  --
  check_hibi : process (clk)            -- (clk)
  begin  -- process check_hibi
    if rst_n = '0' then
      hibi_addr_came <=  '0';
    
    elsif clk = '1' and clk'event then

      assert hibi_amount >= 0 report "Hibi amount negative - too much data" severity warning;


      -- Not expecting more data
      if hibi_amount = 0 then
        hibi_addr_came <= '0';
      end if;


      -- DMA writes. Check the addr and data
      if hibi_we_duv_tb = '1' then

        if hibi_comm_duv_tb /= global_comm_r then
          assert false report "Hibi command failure - expected" & str(global_comm_r) severity warning;
        end if;


        if hibi_av_duv_tb = '1' then
          -- DMA writes addr

          -- Address valid should not come before we have received all the data
          if hibi_amount = 0 then
            if hibi_data_duv_tb = global_hibi_addr_r then
              hibi_addr_came <= '1';
              hibi_amount    <= global_amount_r;
              assert false report "Hibi addr OK " & str(hibi_data_duv_tb) severity note;
              
            else
              assert false report "Hibi address error, expected " & str(global_hibi_addr_r)
                & ", but got " & str(hibi_data_duv_tb)
                severity warning;
            end if;

          else
            assert false report "Hibi data failure, address came before prev transfer is completed" severity warning;
          end if;

        else
          -- DMA writes data
          -- Data must be correct and come after addr

          if hibi_addr_came = '1' then
            if hibi_data_duv_tb = hibi_data_counter_r then
              assert false report "Hibi data OK " & str(hibi_data_duv_tb) severity note;
              
              hibi_data_counter_r <= hibi_data_counter_r+1;
              hibi_amount         <= hibi_amount-1;
              if hibi_amount = 1 then
                hibi_addr_came <= '0';
              end if;
            else
              assert false report "Hibi data error, expexted " & str(hibi_data_counter_r)
                & ", but got " & str(hibi_data_duv_tb)
                severity warning;
            end if;

          else
            assert false report "Data " & str(hibi_data_duv_tb) & " came before an address" severity warning;
          end if;
        end if;

      end if;
    end if;

  end process check_hibi;


  --
  --
  --  
  check_avalon : process (clk2, rst_n)
    variable waitreq_cnt_r       : integer := 0;
    variable expected_ava_addr_v : integer := -1;
    
  begin  -- process check_avalon
    if rst_n = '0' then
      -- reset added 2011-11-11, ES
      avalon_readdatavalid_tb_duv <= '0';
      avalon_waitrequest_tb_duv   <= '0';
      
    --elsif clk2'event and clk2 = '1' then  -- rising clock edge
    elsif clk'event and clk = '1' then  -- rising clock edge

      --assert avalon_amount >= 0 report "avalon amount negative - tried to read too much data" severity warning;

      avalon_last_addr <= to_integer(unsigned(avalon_addr_duv_tb));


      -- DMA reads memory
      if avalon_read_duv_tb = '1' then
        if avalon_waitrequest_tb_duv = '0' then

          avalon_readdatavalid_tb_duv <= '1';

          
          -- Calculate the expected address
          expected_ava_addr_v := global_dpram_addr + avalon_addr_counter_r;  --es

          if (expected_ava_addr_v) = (2**addr_width_c-2) then
            avalon_addr_counter_r <= 0 - global_dpram_addr;
          elsif (expected_ava_addr_v) = (2**addr_width_c-1) then
            -- odd number (eg. 511) overflow, add one.
            avalon_addr_counter_r <= 1 - global_dpram_addr;
          else
            avalon_addr_counter_r <= avalon_addr_counter_r + addr_offset_c;
          end if;

          -- Check addr
          assert expected_ava_addr_v = avalon_addr_duv_tb report "Avalon address error, expected "
            & str(expected_ava_addr_v)
            & ", but got " & str(to_integer(unsigned(avalon_addr_duv_tb)))
            severity warning;
          
          

          -- Generate the data that comes from the "memory"
          if avalon_addr_sent = '0' then
            -- 2011-11-11 not sending addr anymore in the beginning
            -- modifcation is prograa, not yet complete....
            avalon_readdata_tb_duv <= avalon_data_counter_r;
            avalon_data_counter_r  <= avalon_data_counter_r+1;
            avalon_addr_sent       <= '1';
            avalon_amount          <= global_amount_r;
--            -- first slot contains address
--            avalon_readdata_tb_duv <= global_hibi_addr_r;
--            avalon_addr_sent       <= '1';
--            avalon_amount          <= global_amount_r;            

          else
            -- now the data
            if avalon_last_addr = avalon_addr_duv_tb then
              avalon_readdata_tb_duv <= avalon_data_counter_r;
              avalon_data_counter_r  <= avalon_data_counter_r;
              avalon_amount          <= avalon_amount;
            else
              avalon_readdata_tb_duv <= avalon_data_counter_r;
              avalon_data_counter_r  <= avalon_data_counter_r+1;
              avalon_amount          <= avalon_amount-1;
              
            end if;

            if avalon_amount = 1 then
              -- next we expect that a new packet should be sent.
              avalon_addr_sent      <= '0';
              avalon_addr_counter_r <= 0;
            end if;

          end if;          
 
        end if;
      else
        -- Not reading
        avalon_readdatavalid_tb_duv <= '0';            
      end if;



      -- Generate occasional wait requests to DMA
      avalon_waitrequest_tb_duv <= '0';  -- was always
      waitreq_cnt_r             := waitreq_cnt_r +1;
      -- generate waitreq
      if waitreq_cnt_r = wait_req_freq_c then
        avalon_waitrequest_tb_duv <= '1' and avalon_read_duv_tb;
        waitreq_cnt_r             := 0;
      end if;


    end if;                             -- rst/clk
  end process check_avalon;


  --
  -- Generate clocks and reset
  --  
  CLOCK1 : process                      -- generate clock signal for design
    variable clktmp : std_logic := '0';
  begin
    wait for PERIOD/2;
    clktmp := not clktmp;
    clk    <= clktmp;
  end process CLOCK1;

--  clk2 <= clk after PERIOD/4;           -- 2011-11-15 ES
  
  -- different phase for the avalon bus
  CLOCK2 : process                      -- generate clock signal for design
    variable clk2tmp : std_logic := '0';
  begin
    clk2tmp := not clk2tmp;
    clk2    <= clk2tmp;
    wait for PERIOD/2;
  end process CLOCK2;

  RESET : process
  begin
    rst_n <= '0';                       -- Reset the testsystem
    wait for 6*PERIOD;                  -- Wait 
    rst_n <= '1';                       -- de-assert reset
    wait;
  end process RESET;


end rtl;
