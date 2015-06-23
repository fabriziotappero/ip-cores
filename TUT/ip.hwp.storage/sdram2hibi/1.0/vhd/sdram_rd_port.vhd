-------------------------------------------------------------------------------
-- Title      : rd_port.vhd
-- Project    : 
-------------------------------------------------------------------------------
-- File       : rd_port.vhd
-- Author     : 
-- Company    : 
-- Created    : 2007-05-22
-- Last update: 2012-01-26
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: Read port for sdram2hibi
-------------------------------------------------------------------------------
-- Copyright (c) 2007 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2007-05-22  1.0      penttin5	Created
-- 2012-01-22  1.001    alhonen fixed names
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sdram_rd_port is
  
  generic (
    amountw_g       : integer;
    hibi_dataw_g    : integer;
    block_overlap_g : integer := 0;
    offsetw_g       : integer;
    mem_dataw_g     : integer;
    mem_addrw_g     : integer);

  port (
    clk            : in  std_logic;
    rst_n          : in  std_logic;
    conf_we_in     : in  std_logic;
    conf_data_in   : in  std_logic_vector(hibi_dataw_g - 1 downto 0);
    read_in        : in  std_logic;
    reserve_in     : in  std_logic;
    valid_out      : out std_logic;
    reserved_out   : out std_logic;
    end_addr_out   : out std_logic_vector(mem_addrw_g - 1 downto 0);
    src_addr_out   : out std_logic_vector(mem_addrw_g - 1 downto 0);
    amount_out     : out std_logic_vector(amountw_g - 1 downto 0);
    ret_addr_out   : out std_logic_vector(hibi_dataw_g - 1 downto 0);
    finish_out     : out std_logic;
    error_out      : out std_logic);

end sdram_rd_port;

architecture rtl of sdram_rd_port is

  -- parameter numbers
  constant src_addr_param_c : integer := 0;
  constant amount_param_c   : integer := 1;
  constant width_param_c    : integer := 1;
  constant ret_addr_param_c : integer := 2;
  constant height_param_c   : integer := 3;
  constant offset_param_c   : integer := 3;
  constant last_param_c     : integer := 3;

  signal reserved_r : std_logic;
  signal valid_r    : std_logic;
  signal src_addr_r : std_logic_vector(mem_addrw_g - 1 downto 0);
  signal amount_r   : std_logic_vector(amountw_g - 1 downto 0);
  signal width_r    : std_logic_vector(amountw_g - 1 downto 0);
  signal height_r   : std_logic_vector(hibi_dataw_g - offsetw_g - 1 downto 0);
  signal offset_r   : std_logic_vector(offsetw_g - 1 downto 0);
  signal end_addr_r : std_logic_vector(mem_addrw_g - 1 downto 0);
  signal ret_addr_r : std_logic_vector(hibi_dataw_g - 1 downto 0);

  signal finish          : std_logic;
  signal param_cnt_r     : integer range last_param_c downto 0;
  signal end_addr_rdy_r  : std_logic;
  signal calc_end_addr_r : std_logic;
  signal h_times_o_r     : std_logic_vector(hibi_dataw_g - 1 downto 0);

begin  -- rtl

  -- drive outputs
  reserved_out <= reserved_r;
  valid_out    <= valid_r;
  src_addr_out <= src_addr_r;
  amount_out   <= amount_r;
  end_addr_out <= end_addr_r;
  ret_addr_out <= ret_addr_r;

  -- purpose: Detect finished operation
  -- type   : combinational
  -- inputs : read_in, amount_r, height_r
  -- outputs: finish
  port_finishes : process (read_in, amount_r, height_r)
  begin  -- process port_finishes
    if read_in = '1'
      and to_integer(unsigned(amount_r)) = 1
      and (to_integer(unsigned(height_r)) = 1 or
           to_integer(unsigned(height_r)) = 0) then
      finish <= '1';
    else
      finish <= '0';
    end if;
  end process port_finishes;

  finish_output: process (clk, rst_n)
  begin  -- process finish_output
    if rst_n = '0' then                 -- asynchronous reset (active low)
      finish_out <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      finish_out <= finish;
    end if;
  end process finish_output;

  param_counter: process (clk, rst_n)
  begin  -- process param_counter
    if rst_n = '0' then                 -- asynchronous reset (active low)
      param_cnt_r <= 0;
    elsif clk'event and clk = '1' then  -- rising clock edge

      if conf_we_in = '1' and param_cnt_r = last_param_c then
        param_cnt_r <= 0;
      elsif conf_we_in = '1' then
        param_cnt_r <= param_cnt_r + 1;
      else
        param_cnt_r <= param_cnt_r;
      end if;
    end if;
  end process param_counter;

  reserved_proc : process (clk, rst_n)
  begin  -- process reserved_proc
    if rst_n = '0' then                 -- asynchronous reset (active low)
      reserved_r <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge

      if finish = '1' then
        -- operation finishes
        reserved_r <= '0';
      elsif reserve_in = '1' then
        -- reserve from sdram2hibi
        reserved_r <= '1';
      else
        reserved_r <= reserved_r;
      end if;
    end if;
  end process reserved_proc;

  valid_proc : process (clk, rst_n)
  begin  -- process valid_proc
    if rst_n = '0' then                 -- asynchronous reset (active low)
      valid_r <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge

      if finish = '1' then
        -- operation finishes
        valid_r <= '0';
      elsif block_overlap_g = 0
        and conf_we_in = '1' and param_cnt_r = last_param_c then
        -- without block overlap, configuration finishes on
        -- third paramater write
        valid_r <= '1';
      elsif block_overlap_g = 1 and end_addr_rdy_r = '1' then
        -- with block overlap, configuration finishes on
        -- end address calculation
        valid_r <= '1';
      else
        valid_r <= valid_r;
      end if;
    end if;

  end process valid_proc;

  src_addr_proc : process (clk, rst_n)
  begin  -- process src_addr_proc
    if rst_n = '0' then                 -- asynchronous reset (active low)
      src_addr_r <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge

      if read_in = '1' and to_integer(unsigned(amount_r)) = 1 then
        -- line finishes, jump to next line
        src_addr_r <= std_logic_vector(unsigned(src_addr_r) +
                                       unsigned(offset_r) + 1);
      elsif read_in = '1' then
        -- line continues, increase src_addr
        src_addr_r <= std_logic_vector(unsigned(src_addr_r) + 1);

      elsif conf_we_in = '1' and param_cnt_r = src_addr_param_c then
        -- configure from sdram2hibi
        src_addr_r <= conf_data_in(mem_addrw_g - 1 downto 0);
      else
        src_addr_r <= src_addr_r;
      end if;
    end if;
  end process src_addr_proc;

  width_proc : process (clk, rst_n)
  begin  -- process width_proc
    if rst_n = '0' then                 -- asynchronous reset (active low)
      width_r <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge

      if conf_we_in = '1' and param_cnt_r = width_param_c then
        width_r <= conf_data_in(amountw_g - 1 downto 0);
      else
        width_r <= width_r;
      end if;
    end if;
  end process width_proc;

  height_proc : process (clk, rst_n)
  begin  -- process height_proc
    if rst_n = '0' then                 -- asynchronous reset (active low)
      height_r <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if read_in = '1' and to_integer(unsigned(amount_r)) = 1
        and to_integer(unsigned(height_r)) /= 0 then
        height_r <= std_logic_vector(unsigned(height_r) - 1);
      elsif conf_we_in = '1' and param_cnt_r = height_param_c then
        height_r <= conf_data_in(conf_data_in'length - 1 downto offsetw_g);
      else
        height_r <= height_r;
      end if;
    end if;
  end process height_proc;

  offset_proc : process (clk, rst_n)
  begin  -- process offset_proc
    if rst_n = '0' then                 -- asynchronous reset (active low)
      offset_r <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if conf_we_in = '1' and param_cnt_r = offset_param_c then
        offset_r <= conf_data_in(offsetw_g - 1 downto 0);
      else
        offset_r <= offset_r;
      end if;
    end if;
  end process offset_proc;

  end_addr_proc : process (clk, rst_n)
    variable h_times_o_v : integer;
  begin  -- process end_addr_proc
    if rst_n = '0' then                 -- asynchronous reset (active low)
      end_addr_r      <= (others => '0');
      end_addr_rdy_r  <= '0';
      calc_end_addr_r <= '0';
      h_times_o_r     <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge

      h_times_o_r <= h_times_o_r;
      
      if finish = '1' then
        -- opertation finishes
        end_addr_rdy_r  <= '0';
        calc_end_addr_r <= '0';

      elsif conf_we_in = '1' and param_cnt_r = src_addr_param_c then
        -- calculate end address in seperate steps
        -- if block_overlap_g = 0:
        --    final end_addr_r = dst_addr_r + width_r
        -- if block_overlap_g = 1:
        --    final end_addr_r = dst_addr_r + width_r + (height_r-1)*offset_r

        -- 1) end_addr_r = dst_addr
        end_addr_r      <= conf_data_in(mem_addrw_g - 1 downto 0);
        end_addr_rdy_r  <= '0';
        calc_end_addr_r <= '0';

      elsif conf_we_in = '1' and param_cnt_r = width_param_c then

        -- 2) end_addr_r = dst_addr + width
        end_addr_r <= std_logic_vector(unsigned(end_addr_r) +
                                       unsigned(conf_data_in(mem_addrw_g - 1
                                                             downto 0)));
        if block_overlap_g = 0 then
          -- If no block overlap, this is the final result
          end_addr_rdy_r  <= '1';
        else
          -- Otherwise we have to calculate more
          end_addr_rdy_r  <= '0';
        end if;
        calc_end_addr_r <= '0';

      elsif block_overlap_g = 1 and
        conf_we_in = '1' and param_cnt_r = height_param_c then

        -- 3) end_addr_r = dst_addr + width
        --    h_times_o_r = height * offset

        h_times_o_v :=
          to_integer(unsigned(conf_data_in(conf_data_in'length - 1
                                           downto offsetw_g))) *
          to_integer(unsigned(conf_data_in(offsetw_g - 1
                                           downto 0)));
                         
        h_times_o_r <= std_logic_vector(to_unsigned(h_times_o_v, hibi_dataw_g));

        end_addr_rdy_r  <= '0';
        calc_end_addr_r <= '1';

      elsif calc_end_addr_r = '1' then
        -- 4) end_addr_r = dst_addr_r + width_r + height_r*offset_r - height_r
        --               = dst_addr_r + amount_r + (height_r-1)*offset_r
        end_addr_r      <= std_logic_vector(
          unsigned(end_addr_r) + unsigned(h_times_o_r(end_addr_r'length - 1 downto 0))
          - unsigned(height_r));

        end_addr_rdy_r  <= '1';
        calc_end_addr_r <= '0';
      else
        calc_end_addr_r <= calc_end_addr_r;
        end_addr_rdy_r  <= end_addr_rdy_r;
      end if;

    end if;
  end process end_addr_proc;

  amount_proc : process (clk, rst_n)
  begin  -- process amount_proc
    if rst_n = '0' then                 -- asynchronous reset (active low)
      amount_r <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge

      if read_in = '1' and to_integer(unsigned(amount_r)) = 1 then
        -- next line on block transfer or transfer finishes
        amount_r <= width_r;
      elsif read_in = '1' then
        -- transfer continues on the same line
        amount_r <= std_logic_vector(unsigned(amount_r) - 1);
      elsif conf_we_in = '1' and param_cnt_r = amount_param_c then
        -- param write from sdram2hibi
        amount_r <= conf_data_in(amountw_g - 1 downto 0);
      end if;
    end if;
  end process amount_proc;

  ret_addr_proc: process (clk, rst_n)
  begin  -- process ret_addr_proc
    if rst_n = '0' then                 -- asynchronous reset (active low)
      ret_addr_r <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge

      if conf_we_in = '1' and param_cnt_r = ret_addr_param_c then
        ret_addr_r <= conf_data_in;
      else
        ret_addr_r <= ret_addr_r;
      end if;
    end if;
  end process ret_addr_proc;
end rtl;
