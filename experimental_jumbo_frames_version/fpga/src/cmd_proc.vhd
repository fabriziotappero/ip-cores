-------------------------------------------------------------------------------
-- Title      : User command processor
-- Project    : 
-------------------------------------------------------------------------------
-- File       : cmd_proc.vhd
-- Author     : Wojciech M. Zabolotny (wzab@ise.pw.edu.pl)
-- License    : BSD License
-- Company    : 
-- Created    : 2014-10-04
-- Last update: 2014-10-23
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: This block performs the user defined commands
--              but also generates responses for some internal commands.
--              
-------------------------------------------------------------------------------
-- Copyright (c) 2014 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2014-10-04  1.0      WZab    Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
library work;
use work.pkt_ack_pkg.all;
use work.desc_mgr_pkg.all;
use work.pkt_desc_pkg.all;
entity cmd_proc is
  
  port (
    cmd_code     : in  std_logic_vector(15 downto 0);
    cmd_seq      : in  std_logic_vector(15 downto 0);
    cmd_arg      : in  std_logic_vector(31 downto 0);
    cmd_run      : in  std_logic;
    cmd_ack      : out std_logic;
    cmd_response : out std_logic_vector(8*12-1 downto 0);
    clk          : in  std_logic;
    rst_p        : in  std_logic;
    -- Other inputs, needed to execute specific functions
    retr_count   : in std_logic_vector(31 downto 0)
    );

end entity cmd_proc;

architecture beh of cmd_proc is

  signal cmd_run_0, cmd_run_1, cmd_run_2 : std_logic               := '0';
  signal del_count                       : integer range 0 to 1000 := 0;
  
begin  -- architecture beh

  process (clk, rst_p) is
  begin  -- process
    if rst_p = '1' then                 -- asynchronous reset (active low)
      cmd_ack      <= '0';
      cmd_run_0    <= '0';
      cmd_run_1    <= '0';
      cmd_run_2    <= '0';
      del_count    <= 0;
      cmd_response <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      -- Synchronize cmd_run signals
      cmd_run_2 <= cmd_run;
      cmd_run_1 <= cmd_run_2;
      cmd_run_0 <= cmd_run_1;
      -- Detect command strobe
      if cmd_run_1 /= cmd_run_0 then
        -- Line cmd_run has changed its state, it means that we need
        -- to execute a command
        if cmd_code(15 downto 8) = x"00" then
          -- For internal commands just send response immediately
          cmd_response <= cmd_code & cmd_seq &  -- This fields should be always
                                        -- sent on the begining of response!
                          x"00000000" & x"00000000";
          cmd_ack <= cmd_run;
        else
          -- Now we just simulate it, so let's start delay counter
          del_count <= 100;             -- execution of command takes 100 ckp
        end if;
      end if;
      -- We simulate execution of the user command, which was triggered by above
      -- "if" block
      if del_count > 0 then
        -- Decrease del_count until it is zero
        del_count <= del_count-1;
      end if;
      if del_count = 1 then
        -- Send response to the command:
        cmd_response <= cmd_code & cmd_seq &    -- This fields should be always
                                        -- sent on the begining of response!
                        cmd_arg & retr_count;
        cmd_ack <= cmd_run;
      end if;
    end if;
  end process;

end architecture beh;
