-------------------------------------------------------------------------------
-- Title      : 2D mesh mk1 by ase
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ase_mesh1.vhdl
-- Author     : Lasse Lehtonen (ase)
-- Company    : 
-- Created    : 2010-06-14
-- Last update: 2012-06-14
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Instantiate variable-sized network from rows*cols routers
-------------------------------------------------------------------------------
-- Copyright (c) 2010 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2010-06-14  1.0      ase     Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity ase_mesh1 is

  generic (
    n_rows_g    : positive := 4;        -- Number of rows
    n_cols_g    : positive := 4;        -- Number of columns
    cmd_width_g : positive := 2;        -- Width of the cmd line in bits
    bus_width_g : positive := 32;       -- Width of the data bus in bits
    fifo_depth_g : natural := 4
    );
  port (
    clk   : in std_logic;
    rst_n : in std_logic;

    data_in   : in  std_logic_vector(n_rows_g*n_cols_g*bus_width_g-1 downto 0);
    cmd_in    : in  std_logic_vector(n_rows_g*n_cols_g*cmd_width_g-1 downto 0);
    stall_out : out std_logic_vector(n_rows_g*n_cols_g-1 downto 0);

    data_out : out std_logic_vector(n_rows_g*n_cols_g*bus_width_g-1 downto 0);
    cmd_out  : out std_logic_vector(n_rows_g*n_cols_g*cmd_width_g-1 downto 0);
    stall_in : in  std_logic_vector(n_rows_g*n_cols_g-1 downto 0));

end entity ase_mesh1;


architecture structural of ase_mesh1 is

  -- row data
  -- All signals named as <source><destination>name,
  -- e.g. sn_data means "data going from south to north"
  type r_data_type is array (0 to n_rows_g*2-1) of
    std_logic_vector(n_cols_g*bus_width_g-1 downto 0);
  type r_cmd_type is array (0 to n_rows_g*2-1) of
    std_logic_vector(2*n_cols_g-1 downto 0);
  type r_bit_type is array (0 to n_rows_g*2-1) of
    std_logic_vector(n_cols_g-1 downto 0);
  
  signal sn_data  : r_data_type;
  signal sn_cmd   : r_cmd_type;
  signal sn_stall : r_bit_type;

  signal ns_data  : r_data_type;
  signal ns_cmd   : r_cmd_type;
  signal ns_stall : r_bit_type;

  -- col data
  type c_data_type is array (0 to n_cols_g*2-1) of
    std_logic_vector(n_rows_g*bus_width_g-1 downto 0);
  type c_cmd_type is array (0 to n_cols_g*2-1) of
    std_logic_vector(2*n_rows_g-1 downto 0);
  type c_bit_type is array (0 to n_cols_g*2-1) of
    std_logic_vector(n_rows_g-1 downto 0);
  
  signal ew_data  : c_data_type;
  signal ew_cmd   : c_cmd_type;
  signal ew_stall : c_bit_type;

  signal we_data  : c_data_type;
  signal we_cmd   : c_cmd_type;
  signal we_stall : c_bit_type;

  
begin  -- architecture structural

  -- De-activate the signals "coming from outside"
  ns_data(0)             <= (others => '0');
  ns_cmd(0)              <= (others => '0');
  ns_stall(n_rows_g*2-1) <= (others => '0');

  we_data(0)             <= (others => '0');
  we_cmd(0)              <= (others => '0');
  we_stall(n_cols_g*2-1) <= (others => '0');

  sn_data(n_rows_g*2-1) <= (others => '0');
  sn_cmd(n_rows_g*2-1)  <= (others => '0');
  sn_stall(0)           <= (others => '0');

  ew_data(n_cols_g*2-1) <= (others => '0');
  ew_cmd(n_cols_g*2-1)  <= (others => '0');
  ew_stall(0)           <= (others => '0');


  -- Instantiate rows*cols routers
  row : for r in 0 to n_rows_g-1 generate
    col : for c in 0 to n_cols_g-1 generate


      col_fifo : if r < n_rows_g-1 generate
        ns_link_fifo : entity work.link_fifo
          generic map (
            cmd_width_g  => cmd_width_g,
            data_width_g => bus_width_g,
            depth_g      => fifo_depth_g)
          port map (
            clk       => clk,
            rst_n     => rst_n,
            cmd_in    => ns_cmd(r*2+1)(c*2+1 downto c*2),
            data_in   => ns_data(r*2+1)((c+1)*bus_width_g-1 downto c*bus_width_g),
            stall_out => ns_stall(r*2+1)(c),
            cmd_out   => ns_cmd((r+1)*2)(c*2+1 downto c*2),
            data_out  => ns_data((r+1)*2)((c+1)*bus_width_g-1 downto c*bus_width_g),
            stall_in  => ns_stall((r+1)*2)(c));
        sn_link_fifo : entity work.link_fifo
          generic map (
            cmd_width_g  => cmd_width_g,
            data_width_g => bus_width_g,
            depth_g      => fifo_depth_g)
          port map (
            clk       => clk,
            rst_n     => rst_n,
            cmd_in    => sn_cmd((r+1)*2)(c*2+1 downto c*2),
            data_in   => sn_data((r+1)*2)((c+1)*bus_width_g-1 downto c*bus_width_g),
            stall_out => sn_stall((r+1)*2)(c),
            cmd_out   => sn_cmd((r)*2+1)(c*2+1 downto c*2),
            data_out  => sn_data((r)*2+1)((c+1)*bus_width_g-1 downto c*bus_width_g),
            stall_in  => sn_stall((r)*2+1)(c));
      end generate col_fifo;

      row_fifo : if c < n_cols_g-1 generate
        we_link_fifo : entity work.link_fifo
          generic map (
            cmd_width_g  => cmd_width_g,
            data_width_g => bus_width_g,
            depth_g      => fifo_depth_g)
          port map (
            clk       => clk,
            rst_n     => rst_n,
            cmd_in    => we_cmd(c*2+1)(r*2+1 downto r*2),
            data_in   => we_data(c*2+1)((r+1)*bus_width_g-1 downto r*bus_width_g),
            stall_out => we_stall(c*2+1)(r),
            cmd_out   => we_cmd((c+1)*2)(r*2+1 downto r*2),
            data_out  => we_data((c+1)*2)((r+1)*bus_width_g-1 downto r*bus_width_g),
            stall_in  => we_stall((c+1)*2)(r));
        ew_link_fifo : entity work.link_fifo
          generic map (
            cmd_width_g  => cmd_width_g,
            data_width_g => bus_width_g,
            depth_g      => fifo_depth_g)
          port map (
            clk       => clk,
            rst_n     => rst_n,
            cmd_in    => ew_cmd((c+1)*2)(r*2+1 downto r*2),
            data_in   => ew_data((c+1)*2)((r+1)*bus_width_g-1 downto r*bus_width_g),
            stall_out => ew_stall((c+1)*2)(r),
            cmd_out   => ew_cmd((c)*2+1)(r*2+1 downto r*2),
            data_out  => ew_data((c)*2+1)((r+1)*bus_width_g-1 downto r*bus_width_g),
            stall_in  => ew_stall((c)*2+1)(r));
      end generate row_fifo;

      i_router : entity work.ase_mesh1_router(rtl)
        generic map (
          n_rows_g    => n_rows_g,
          n_cols_g    => n_cols_g,
          bus_width_g => bus_width_g)
        port map (
          clk   => clk,
          rst_n => rst_n,

          a_data_in   => data_in(((r*n_cols_g)+c+1)*bus_width_g-1 downto
                                 ((r*n_cols_g)+c)*bus_width_g),
          a_da_in     => cmd_in(2*((r*n_cols_g)+c)+1),
          a_av_in     => cmd_in(2*((r*n_cols_g)+c)),
          a_stall_out => stall_out((r*n_cols_g)+c),
          a_data_out  => data_out(((r*n_cols_g)+c+1)*bus_width_g-1 downto
                                  ((r*n_cols_g)+c)*bus_width_g),
          a_da_out    => cmd_out(2*((r*n_cols_g)+c)+1),
          a_av_out    => cmd_out(2*((r*n_cols_g)+c)),
          a_stall_in  => stall_in((r*n_cols_g)+c),

          n_data_in   => ns_data(r*2)((c+1)*bus_width_g-1 downto c*bus_width_g),
          n_da_in     => ns_cmd(r*2)(c*2),
          n_av_in     => ns_cmd(r*2)(c*2+1),
          n_stall_out => ns_stall(r*2)(c),
          n_data_out  => sn_data(r*2)((c+1)*bus_width_g-1 downto c*bus_width_g),
          n_da_out    => sn_cmd(r*2)(c*2),
          n_av_out    => sn_cmd(r*2)(c*2+1),
          n_stall_in  => sn_stall(r*2)(c),

          e_data_in   => ew_data(c*2+1)((r+1)*bus_width_g-1 downto r*bus_width_g),
          e_da_in     => ew_cmd(c*2+1)(r*2),
          e_av_in     => ew_cmd(c*2+1)(r*2+1),
          e_stall_out => ew_stall(c*2+1)(r),
          e_data_out  => we_data(c*2+1)((r+1)*bus_width_g-1 downto r*bus_width_g),
          e_da_out    => we_cmd(c*2+1)(r*2),
          e_av_out    => we_cmd(c*2+1)(r*2+1),
          e_stall_in  => we_stall(c*2+1)(r),

          s_data_in   => sn_data(r*2+1)((c+1)*bus_width_g-1 downto c*bus_width_g),
          s_da_in     => sn_cmd(r*2+1)(c*2),
          s_av_in     => sn_cmd(r*2+1)(c*2+1),
          s_stall_out => sn_stall(r*2+1)(c),
          s_data_out  => ns_data(r*2+1)((c+1)*bus_width_g-1 downto c*bus_width_g),
          s_da_out    => ns_cmd(r*2+1)(c*2),
          s_av_out    => ns_cmd(r*2+1)(c*2+1),
          s_stall_in  => ns_stall(r*2+1)(c),

          w_data_in   => we_data(c*2)((r+1)*bus_width_g-1 downto r*bus_width_g),
          w_da_in     => we_cmd(c*2)(r*2),
          w_av_in     => we_cmd(c*2)(r*2+1),
          w_stall_out => we_stall(c*2)(r),
          w_data_out  => ew_data(c*2)((r+1)*bus_width_g-1 downto r*bus_width_g),
          w_da_out    => ew_cmd(c*2)(r*2),
          w_av_out    => ew_cmd(c*2)(r*2+1),
          w_stall_in  => ew_stall(c*2)(r));

    end generate col;
  end generate row;
  


end architecture structural;
