-------------------------------------------------------------------------------
-- Title      : Testbench for design "n2h2_tx"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : tb_n2h2_tx.vhd
-- Author     : kulmala3
-- Created    : 30.03.2005
-- Last update: 2011-11-15
-- Description: DMA reads data from memory  and writes them to
--              HIBI. Values are just running numbers and checked automatically.
--
-------------------------------------------------------------------------------
-- Copyright (c) 2005 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 30.03.2005  1.0      AK      Created
-------------------------------------------------------------------------------
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-------------------------------------------------------------------------------

entity tb_n2h2_tx is

end tb_n2h2_tx;

-------------------------------------------------------------------------------

architecture rtl of tb_n2h2_tx is


  -- component generics
  constant data_width_g   : integer := 32;
  constant amount_width_g : integer := 16;


  constant wait_between_sends_c   : integer := 2;   -- unit: cycles
  constant hibi_full_c            : integer := 2;
  constant avalon_waitr_c         : integer := 7;
  constant amount_max_c           : integer := 63;  -- longest transfer in words
  constant incr_hibi_full_after_c : time    := 1000000 ns;  -- how often HIBI
                                                            -- goes full


  -----------------------------------------------------------------------------
  --
  -----------------------------------------------------------------------------
  -- clock and reset
  signal   Clk    : std_logic;
  signal   Clk2   : std_logic;          -- turha kello?
  signal   Rst_n  : std_logic;
  constant Period : time := 10 ns;

  type   main_control_type is (idle, send, wait_one);
  signal main_ctrl_r : main_control_type;

  signal amount_r   : std_logic_vector(amount_width_g-1 downto 0);
  signal mem_addr_r : std_logic_vector(data_width_g-1 downto 0);


  -----------------------------------------------------------------------------
  -- Tested sub-unit of Nios-to-HIBI
  -----------------------------------------------------------------------------
  component n2h2_tx
    generic (
      data_width_g   : integer;
      addr_width_g   : integer := 32;
      amount_width_g : integer
      );
    port (
      clk   : in std_logic;
      rst_n : in std_logic;

      -- Avalon master interface for reading memory
      avalon_addr_out         : out std_logic_vector(addr_width_g-1 downto 0);
      avalon_readdata_in      : in  std_logic_vector(data_width_g-1 downto 0);
      avalon_re_out           : out std_logic;
      avalon_waitrequest_in   : in  std_logic;
      avalon_readdatavalid_in : in  std_logic;

      -- Hibi interface for writing
      hibi_av_out   : out std_logic;
      hibi_data_out : out std_logic_vector(data_width_g-1 downto 0);
      hibi_comm_out : out std_logic_vector(4 downto 0);
      hibi_full_in  : in  std_logic;
      hibi_we_out   : out std_logic;

      -- DMA conf interface
      tx_start_in        : in  std_logic;
      tx_status_done_out : out std_logic;
      tx_comm_in         : in  std_logic_vector(4 downto 0);
      tx_hibi_addr_in    : in  std_logic_vector(addr_width_g-1 downto 0);
      tx_ram_addr_in     : in  std_logic_vector(addr_width_g-1 downto 0);
      tx_amount_in       : in  std_logic_vector(amount_width_g-1 downto 0)
      );
  end component;


  signal avalon_addr_from_tx   : std_logic_vector(data_width_g-1 downto 0);
  signal avalon_re_from_tx     : std_logic;
  signal avalon_readdata_to_tx : std_logic_vector(data_width_g-1 downto 0) := (others => '0');

  signal avalon_waitrequest_to_tx   : std_logic;
  signal avalon_waitrequest_to_tx2  : std_logic;
  signal avalon_readdatavalid_to_tx : std_logic;

  signal hibi_data_from_tx          : std_logic_vector(data_width_g-1 downto 0);
  signal hibi_av_from_tx            : std_logic;
  signal hibi_full_to_tx            : std_logic := '0';
  signal hibi_comm_from_tx          : std_logic_vector(4 downto 0);
  signal hibi_we_from_tx            : std_logic;

  -- Configuration signals
  signal tx_comm_to_tx      : std_logic_vector(4 downto 0)                := (others => '0');
  signal tx_hibi_addr_to_tx : std_logic_vector(data_width_g-1 downto 0)   := (others => '0');
  signal tx_ram_addr_to_tx  : std_logic_vector(data_width_g-1 downto 0)   := (others => '0');
  signal tx_amount_to_tx    : std_logic_vector(amount_width_g-1 downto 0) := (others => '0');
  signal tx_start_to_tx             : std_logic := '0';
  signal tx_status_done_from_tx     : std_logic;


  -----------------------------------------------------------------------------
  -- Memory and Avalon
  -----------------------------------------------------------------------------  
  constant rom_data_file_name_g : string  := "ram_init.dat";
  constant output_file_name_g   : string  := "ram_contents.dat";
  constant write_trigger_g      : natural := 16#6543#;  -- RAM gets dumped to file
  constant ram_addr_width_g     : integer := 16;

  component sram_scalable
    generic (
      rom_data_file_name_g : string;
      output_file_name_g   : string;
      write_trigger_g      : natural;
      addr_width_g         : integer;
      data_width_g         : integer
      );
    port (
      cs1_n_in   : in    std_logic;
      cs2_in     : in    std_logic;
      addr_in    : in    std_logic_vector(addr_width_g-1 downto 0);
      data_inout : inout std_logic_vector(data_width_g-1 downto 0);
      we_n_in    : in    std_logic;
      oe_n_in    : in    std_logic
      );
  end component;

  signal cs1_n_to_ram   : std_logic;
  signal cs2_to_ram     : std_logic;
  signal addr_to_ram    : std_logic_vector(ram_addr_width_g-1 downto 0);
  signal data_inout_ram : std_logic_vector(data_width_g-1 downto 0);
  signal we_n_to_ram    : std_logic;
  signal oe_n_to_ram    : std_logic;

  signal delayed_data_from_ram_r : std_logic_vector(data_width_g-1 downto 0);
  signal avalon_ready_r : std_logic;



  -----------------------------------------------------------------------------
  -- Signal for modeling HIBI
  -----------------------------------------------------------------------------
  signal hibi_addr_r        : std_logic_vector(data_width_g-1 downto 0);
  signal hibi_amount_r      : std_logic_vector(amount_width_g-1 downto 0);
  signal hibi_data_r        : std_logic_vector(data_width_g-1 downto 0);
  signal avalon_addr_r      : std_logic_vector(data_width_g-1 downto 0);
  signal avalon_data_r      : std_logic_vector(data_width_g-1 downto 0);
  signal avalon_amount_r    : std_logic_vector(amount_width_g-1 downto 0);
  signal wait_cnt_r         : integer range 0 to wait_between_sends_c;
  signal avalon_waitr_cnt_r : integer range 0 to avalon_waitr_c-1;
  signal hibi_we_was_up_r   : std_logic;
  --  signal hibi_full_cnt_r : integer range 0 to hibi_full_c;
  signal hibi_full_cnt_r    : integer;
  signal hibi_ready_r       : std_logic;

  signal hibi_full_up_cc : integer := 0;


  
begin  -- rtl


  -----------------------------------------------------------------------------
  -- DUT component instantiation 
  --
  ------------------------------------------------------------------------------  
  DUT : n2h2_tx
    --DUT: entity work.n2h2_tx
    generic map (
      data_width_g   => data_width_g,
      amount_width_g => amount_width_g)
    port map (
      clk   => clk,
      rst_n => rst_n,

      avalon_addr_out         => avalon_addr_from_tx,
      avalon_re_out           => avalon_re_from_tx,
      avalon_readdata_in      => avalon_readdata_to_tx,
      avalon_waitrequest_in   => avalon_waitrequest_to_tx2,
      avalon_readdatavalid_in => avalon_readdatavalid_to_tx,

      hibi_data_out => hibi_data_from_tx,
      hibi_av_out   => hibi_av_from_tx,
      hibi_full_in  => hibi_full_to_tx,
      hibi_comm_out => hibi_comm_from_tx,
      hibi_we_out   => hibi_we_from_tx,

      tx_start_in        => tx_start_to_tx,
      tx_status_done_out => tx_status_done_from_tx,
      tx_comm_in         => tx_comm_to_tx,
      tx_hibi_addr_in    => tx_hibi_addr_to_tx,
      tx_ram_addr_in     => tx_ram_addr_to_tx,
      tx_amount_in       => tx_amount_to_tx);



  -----------------------------------------------------------------------------
  -- Give commands to the tested block n2h2_tx
  -- Asks to send longer and longer transfer
  ------------------------------------------------------------------------------  
  test : process (clk, rst_n)
  begin  -- process test
    if rst_n = '0' then                 -- asynchronous reset (active low)
      tx_start_to_tx     <= '0';
      tx_hibi_addr_to_tx <= X"0000ffff";
      tx_comm_to_tx      <= (others => 'Z');                           --'0');
      tx_ram_addr_to_tx  <= (others => 'Z');                           -- '0');
      tx_amount_to_tx    <= (others => 'Z');                           -- '0');
      wait_cnt_r         <= 0;
      main_ctrl_r        <= idle;
      amount_r           <= conv_std_logic_vector(1, amount_width_g);  --(others => '0');
      mem_addr_r         <= (others => '0');

      
    elsif clk'event and clk = '1' then  -- rising clock edge


      case main_ctrl_r is
        
        when idle =>
          -- Wait that previous tx is ready and then few cycles more. 
          -- Increase the source memory address for every transfer
          
          tx_start_to_tx <= '0';

          if tx_status_done_from_tx = '1' then
            wait_cnt_r <= wait_cnt_r+1;

            if wait_cnt_r = wait_between_sends_c-1 then
              wait_cnt_r  <= 0;
              main_ctrl_r <= send;
              if conv_integer(amount_r) > 1 then
                mem_addr_r <= mem_addr_r+conv_integer(tx_amount_to_tx)*4;
              else
                mem_addr_r <= mem_addr_r+conv_integer(tx_amount_to_tx)*4;
              end if;
            end if;

          end if;


        when send =>
          -- Ask to send a new transfer
          -- Increase the mem addr, hibi addr
          tx_start_to_tx     <= '1';
          tx_ram_addr_to_tx  <= mem_addr_r;
          tx_hibi_addr_to_tx <= tx_hibi_addr_to_tx+1;
          tx_amount_to_tx    <= amount_r;
          tx_comm_to_tx      <= "00010";

          -- Increase transfer length for the next time
          if conv_integer(amount_r) >= amount_max_c then
            amount_r <= conv_std_logic_vector(1, amount_width_g);
          else
            amount_r <= amount_r+1;
          end if;

          -- Loop back to idle state
          main_ctrl_r <= idle;


        when others =>
      end case;
    end if;
  end process test;

  -- avalon_readdata_to_tx <= avalon_data_r;


  -----------------------------------------------------------------------------
  -- Instantiate memory block
  ------------------------------------------------------------------------------  
  sram_scalable_1 : sram_scalable
    generic map (
      rom_data_file_name_g => rom_data_file_name_g,
      output_file_name_g   => output_file_name_g,
      write_trigger_g      => write_trigger_g,
      addr_width_g         => ram_addr_width_g,
      data_width_g         => data_width_g)
    port map (
      cs1_n_in   => cs1_n_to_ram,
      cs2_in     => cs2_to_ram,
      addr_in    => addr_to_ram,
      data_inout => data_inout_ram,
      we_n_in    => we_n_to_ram,
      oe_n_in    => oe_n_to_ram
      );



  -----------------------------------------------------------------------------
  -- Imitate Avalon switch fabric between mem and n2h2_tx:
  --  - delay the addr going to memory by one cycle
  --  - delay the data coming from memory by one cycle
  ------------------------------------------------------------------------------  
  cs1_n_to_ram <= '0';                  -- avalon_waitrequest_to_tx;
  cs2_to_ram   <= avalon_re_from_tx;
  addr_to_ram  <= conv_std_logic_vector(conv_integer(avalon_addr_from_tx)/4, ram_addr_width_g);

  avalon_waitrequest_to_tx2 <= avalon_waitrequest_to_tx or (not avalon_re_from_tx);
  avalon_readdata_to_tx     <= delayed_data_from_ram_r;


  delay_valid : process (clk, rst_n)
  begin  -- process delay_valid
    if rst_n = '0' then                 -- asynchronous reset (active low)

    elsif clk'event and clk = '1' then  -- rising clock edge
      -- memory latency 2 (note below the same signal assignment)
      avalon_readdatavalid_to_tx <= not avalon_waitrequest_to_tx2;

    end if;
  end process delay_valid;
  -- memory latency 1
  -- avalon_readdatavalid_to_tx <= not avalon_waitrequest_to_tx2;

  we_n_to_ram <= '1';
  oe_n_to_ram <= '0';

  avalon : process (clk2, rst_n)
  begin  -- process avalon
    if rst_n = '0' then                 -- asynchronous reset (active low)
      avalon_waitrequest_to_tx <= '1';
      delayed_data_from_ram_r  <= (others => 'Z');  --data_inout_ram;
      avalon_waitr_cnt_r       <= 0;


    elsif clk'event and clk = '1' then  -- rising clock edge

      
      if tx_start_to_tx = '1' then
        avalon_addr_r <= mem_addr_r;
      end if;

      delayed_data_from_ram_r <= data_inout_ram;

      if avalon_re_from_tx = '1' then
        if avalon_waitr_cnt_r = avalon_waitr_c-1 then
          avalon_waitr_cnt_r       <= 0;
          avalon_waitrequest_to_tx <= '1';
        else
          avalon_waitr_cnt_r       <= avalon_waitr_cnt_r+1;
          avalon_waitrequest_to_tx <= '0';
        end if;

      else
        avalon_waitrequest_to_tx <= '1';
      end if;
    end if;
                                        --avalon_waitrequest_to_tx <= '0';
  end process avalon;


  -----------------------------------------------------------------------------
  -- Imitate the HIBI wrapper that gets the data from n2h2_tx
  ------------------------------------------------------------------------------    
  hibi : process (clk, rst_n)
  begin  -- process hibi
    if rst_n = '0' then                 -- asynchronous reset (active low)
      hibi_addr_r      <= X"0000ffff";
      hibi_full_to_tx  <= '1';
      hibi_data_r      <= (others => '0');
      hibi_amount_r    <= (others => '0');
      hibi_full_cnt_r  <= 0;
      hibi_we_was_up_r <= '1';

    elsif clk'event and clk = '1' then  -- rising clock edge

                                        -- Generate full signal
      if hibi_we_was_up_r = '1' then
        hibi_full_cnt_r <= hibi_full_cnt_r+1;
        hibi_full_to_tx <= '1';
        if hibi_full_cnt_r = hibi_full_up_cc then
          hibi_full_to_tx  <= '0';
          hibi_full_cnt_r  <= 0;
          hibi_we_was_up_r <= '0';
        end if;
      end if;

      -- Take and check the incoming data
      if hibi_we_from_tx = '1' then
        if hibi_full_up_cc > 0 then
          hibi_full_to_tx <= '1';
        end if;
        hibi_we_was_up_r <= '1';

        assert hibi_comm_from_tx /= "00000" report "Error. DMA sets comm=idle" severity error;



        if hibi_av_from_tx = '1' then
          -- Check incoming address
          -- +1 because of the main test program value
          assert hibi_addr_r+1 = hibi_data_from_tx report "hibi addr error" severity error;
          hibi_addr_r <= hibi_addr_r+1;

        else
          -- Check incoming data
          assert avalon_readdata_to_tx = hibi_data_from_tx report "hibi data error" severity error;

          if hibi_data_r = 2**ram_addr_width_g-1 then
            hibi_data_r <= (others => '0');
          else
            hibi_data_r <= hibi_data_r+1;
          end if;

          hibi_amount_r        <= hibi_amount_r+1;
          assert hibi_amount_r <= tx_amount_to_tx report "too many data" severity error;
        end if;

      else
        -- DMA does not write to HIBI        
        if main_ctrl_r = send then
          hibi_amount_r <= (others => '0');
        end if;
      end if;

    end if;
  end process hibi;


  -----------------------------------------------------------------------------
  -- 
  ------------------------------------------------------------------------------  
  full_control : process
  begin  -- process full_control
    wait for incr_hibi_full_after_c;
    hibi_full_up_cc <= hibi_full_up_cc+1;
  end process full_control;



  -----------------------------------------------------------------------------
  -- Generate clokcs and reset
  ------------------------------------------------------------------------------  
  CLOCK1 : process                      -- generate clock signal for design
    variable clktmp : std_logic := '0';
  begin
    wait for PERIOD/2;
    clktmp := not clktmp;
    Clk    <= clktmp;
  end process CLOCK1;

  CLOCK2 : process                      -- generate clock signal for design
    variable clktmp : std_logic := '0';
  begin
    clktmp := not clktmp;
    Clk2   <= clktmp;
    wait for PERIOD/2;
  end process CLOCK2;

  RESET : process
  begin
    Rst_n <= '0';                       -- Reset the testsystem
    wait for 6*PERIOD;                  -- Wait 
    Rst_n <= '1';                       -- de-assert reset
    wait;
  end process RESET;




end rtl;
