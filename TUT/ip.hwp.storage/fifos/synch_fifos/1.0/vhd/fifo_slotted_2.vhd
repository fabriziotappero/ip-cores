-------------------------------------------------------------------------------
-- Title      : fifo
-- Project    : 
-------------------------------------------------------------------------------
-- File       : fifo_slotted_2.vhd
-- Author     : 
-- Company    : 
-- Created    : 2005-05-23
-- Last update: 2005/12/15
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------
-- Copyright (c) 2005 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2005-05-23  1.0      penttin5        Created
-- 2005-05-31  1.1      penttin5        Added comments
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fifo is

  generic (
    data_width_g : integer := 0;
    depth_g      : integer := 0
    );
  port (
    clk       : in  std_logic;
    rst_n     : in  std_logic;
    data_in   : in  std_logic_vector (data_width_g-1 downto 0);
    we_in     : in  std_logic;
    one_p_out : out std_logic;
    full_out  : out std_logic;
    data_out  : out std_logic_vector (data_width_g-1 downto 0);
    re_in     : in  std_logic;
    empty_out : out std_logic;
    one_d_out : out std_logic
    );

end fifo;

architecture rtl of fifo is

  component fifo_reg
    generic (
      width_g : integer := 0);

    port (
      clk         : in  std_logic;
      rst_n       : in  std_logic;
      load_in     : in  std_logic;
      data1_in    : in  std_logic_vector(width_g - 1 downto 0);
      data2_in    : in  std_logic_vector(width_g - 1 downto 0);
      data_sel_in : in  std_logic;
      data_out    : out std_logic_vector(width_g - 1 downto 0));
  end component;  -- fifo_reg

  signal fifo_state_r : std_logic_vector(depth_g downto 0);
  type   reg_data_type is array (0 to depth_g) of std_logic_vector(data_width_g - 1 downto 0);
  type   reg_load_type is array (0 to depth_g - 1) of std_logic;
  signal reg_data_out : reg_data_type;
  signal reg_load     : reg_load_type;
  signal reg_data_sel : std_logic_vector(depth_g - 1 downto 0);

begin  -- rtl

  empty_out <= fifo_state_r(0);
  full_out  <= fifo_state_r(depth_g);
  one_d_out <= fifo_state_r(1);
  one_p_out <= fifo_state_r(depth_g - 1);
  data_out  <= reg_data_out(0);

  reg_data_out(depth_g) <= (others => '0');

  -- load new value if (write and this is the next free register) or read
  reg_load_assign : for i in 0 to depth_g - 1 generate
    reg_load(i) <= (fifo_state_r(i) and we_in) or re_in;
  end generate reg_load_assign;


  -- sel = 0 <=> load from data_in,
  -- sel = 1 <=> load from register i+1
  -- Data in from the next register (i+1) if:
  --  1 not read or not write or this is not the first free register
  --   AND
  --     1.1 read and fifo full or
  --     1.2 read and write and this is not the last free register
  reg_data_sel_assign : for i in 0 to depth_g - 1 generate
    reg_data_sel(i) <= ((re_in and (not(we_in) or fifo_state_r(depth_g))) or (re_in and we_in and not (fifo_state_r (i + 1))))
                       and (not(re_in and we_in and fifo_state_r(i)));
  end generate reg_data_sel_assign;

  map_registers : for i in 0 to depth_g - 1 generate
    gen_reg_i : fifo_reg
      generic map (
        width_g => data_width_g
        )
      port map (
        clk         => clk,
        rst_n       => rst_n,
        load_in     => reg_load(i),
        data1_in    => data_in,
        data2_in    => reg_data_out(i + 1),
        data_sel_in => reg_data_sel(i),
        data_out    => reg_data_out(i)
        );
  end generate map_registers;

  -----------------------------------------------------------------------------
  -- Update fifo_state_r
  -----------------------------------------------------------------------------
  fifo_state_r_update : process (clk, rst_n)
  begin  -- process fifo
    if rst_n = '0' then                 -- asynchronous reset (active low)

      -- after reset the first register is the first free register
      fifo_state_r (depth_g downto 1) <= (others => '0');
      fifo_state_r (0)                <= '1';

    elsif clk'event and clk = '1' then  -- rising clock edge

      -- free the last full register if:
      -- read and fifo isn't empty or simultaneus read and write and fifo is full
      if (re_in = '1' and ((we_in = '0' and fifo_state_r(0) = '0') or
                           (we_in = '1' and fifo_state_r(depth_g) = '1')))
      then
        fifo_state_r <= '0' & fifo_state_r(depth_g downto 1);

        -- fill the first free register if:
        -- write and fifo isn't full or simultaneus read and write and fifo is empty
        -- write and ( (no read and fifo not full) or (read and empty) )
      elsif (we_in = '1' and ((re_in = '0' and fifo_state_r(depth_g) = '0') or
                              (re_in = '1' and fifo_state_r(0) = '1'))) then        
        fifo_state_r <= fifo_state_r(depth_g - 1 downto 0) & '0';
      else
        fifo_state_r <= fifo_state_r;
      end if;
    end if;
  end process fifo_state_r_update;
end rtl;
