-------------------------------------------------------------------------------
-- File: ex_stage.vhd
-- Author: Jakob Lechner, Urban Stadler, Harald Trinkl, Christian Walter
-- Created: 2006-12-31
-- Last updated: 2006-12-31

-- Description:
-- Testbench for RLU unit
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_ARITH.all;
use work.rise_pack.all;
use work.RISE_PACK_SPECIFIC.all;

entity tb_rlu_unit_vhd is
end tb_rlu_unit_vhd;

architecture behavior of tb_rlu_unit_vhd is

  -- component Declaration for the Unit Under Test (UUT)
  component rlu is

                  port (
                    clk   : in std_logic;
                    reset : in std_logic;

                    lock_register : out LOCK_REGISTER_T;

                    set_lock0      : in std_logic;
                    set_lock_addr0 : in REGISTER_ADDR_T;

                    set_lock1      : in std_logic;
                    set_lock_addr1 : in REGISTER_ADDR_T;

                    clear_lock0      : in std_logic;
                    clear_lock_addr0 : in REGISTER_ADDR_T;

                    clear_lock1      : in std_logic;
                    clear_lock_addr1 : in REGISTER_ADDR_T);

  end component;

  constant clk_period : time := 10 ns;

  --inputs
  signal clk   : std_logic := '0';
  signal reset : std_logic := '0';

  signal clear_lock0_sig      : std_logic := '0';
  signal clear_lock_addr0_sig : REGISTER_ADDR_T;

  signal clear_lock1_sig      : std_logic := '0';
  signal clear_lock_addr1_sig : REGISTER_ADDR_T;

  signal set_lock0_sig      : std_logic := '0';
  signal set_lock_addr0_sig : REGISTER_ADDR_T;

  signal set_lock1_sig      : std_logic := '0';
  signal set_lock_addr1_sig : REGISTER_ADDR_T;

  --Outputs
  signal lock_register : LOCK_REGISTER_T;

begin

  -- instantiate the Unit Under Test (UUT)
  uut : rlu port map(
    clk                 => clk,
    reset               => reset,

    lock_register       => lock_register,

    set_lock0           => set_lock0_sig,
    set_lock_addr0      => set_lock_addr0_sig,

    set_lock1           => set_lock1_sig,
    set_lock_addr1      => set_lock_addr1_sig,

    clear_lock0         => clear_lock0_sig,
    clear_lock_addr0    => clear_lock_addr0_sig,

    clear_lock1         => clear_lock1_sig,
    clear_lock_addr1    => clear_lock_addr1_sig);


  cg : process
  begin
    clk <= '1';
    wait for clk_period/2;
    clk <= '0';
    wait for clk_period/2;
  end process;

  tb : process
  begin
    reset <= '0';
    wait for 10 * clk_period;
    reset <= '1';


    set_lock_addr0_sig     <= CONV_STD_LOGIC_VECTOR(8, REGISTER_ADDR_WIDTH);
    set_lock0_sig <= '1';
    wait for clk_period;
    set_lock_addr0_sig     <= CONV_STD_LOGIC_VECTOR(9, REGISTER_ADDR_WIDTH);
    set_lock0_sig <= '1';
    set_lock_addr1_sig     <= SR_REGISTER_ADDR;
    set_lock1_sig <= '1';
    clear_lock_addr0_sig   <= CONV_STD_LOGIC_VECTOR(8, REGISTER_ADDR_WIDTH);
    clear_lock0_sig <= '1';
    
    wait;                               -- will wait forever
  end process;

end;
