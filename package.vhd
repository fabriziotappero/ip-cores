--Mango DSP Ltd. Copyright (C) 2006
--Creator: Nachum Kanovsky

library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;

package design_top_constants is
  subtype filename is string(1 to 256);
  type    array2xfilename is array (1 downto 0) of filename;

  function mk_filename(inp : string) return filename;
end design_top_constants;

package body design_top_constants is
  function mk_filename(inp : string) return filename is
    variable res        : filename := (others => NUL);
    variable inp_length : integer  := 0;
  begin
    if inp'length > filename'high then
      inp_length := filename'high;
    else
      inp_length := inp'length;
    end if;
    res(1 to inp_length) := inp(1 to inp_length);
    return res;
  end;
end design_top_constants;
