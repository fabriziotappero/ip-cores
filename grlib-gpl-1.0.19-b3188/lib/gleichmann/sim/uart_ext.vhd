--------------------------------------------------------------------------------
--  Project:         LEON-ARC
--  Entity:          uart_ext
--  Architecture(s): behav
--  Author:          tame@msc-ge.com
--  Company:         Gleichmann Electronics
--
--  Description:
--    This file contains a simple module that is connected to the 4 UART
--    signals CTS, RX, RTS and TX. It loops the signals RTS and TX back to the
--    outputs CTS and RX after a predefined time.
--    If enabled, the logger prints the current value of the 4 pins mentioned
--    above into a log file whenever they change.
--
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;

library work;
use work.txt_util.all;


entity uart_ext is
  generic (
    logfile_name : string := "logfile_uart";
    t_delay      : time   := 5 ns);
  port (
    resetn    : in  std_logic;
    -- logging enable signal
    log_en    : in  std_logic := '1';
    -- current cycle number
    cycle_num : in  integer;
    cts       : out std_logic;
    rxd       : out std_logic;
    txd       : in  std_logic;
    rts       : in  std_logic);
end entity;


architecture behav of uart_ext is
  file logfile              : text open write_mode is logfile_name;
  shared variable logline   : line;
  shared variable logstring : string(1 to 80);
begin

  log_start : process is
  begin
    if log_en = '1' then
      print(logfile, "#");
      print(logfile, "# CYCLE_NUMBER CTS RX RTS TX");
      print(logfile, "#");
    end if;
    wait;
  end process;

  -- note: cycle number shall not be on sensitivity list
  log_loop : postponed process (log_en, rts, txd) is
    variable rxd_int : std_logic;
    variable cts_int : std_logic;
  begin
    rxd_int := txd;
    cts_int := rts;
    if (log_en = '1') and (cycle_num >= 0) then
      print(logfile,
            str(cycle_num) & " " &
            str(cts_int) & " " &
            str(rxd_int) & " " &
            str(rts) & " " &
            str(txd));
    end if;
    rxd <= rxd_int after t_delay;
    cts <= cts_int after t_delay;
  end process;

end architecture;
