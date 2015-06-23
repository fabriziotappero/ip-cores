library ieee;
use ieee.std_logic_1164.all;

-- PREFIX: log_xxx
package log is

-- combine or vector 
function log_orv(d : std_logic_vector) return std_logic;

end log;

package body log is

function log_orv(d : std_logic_vector) return std_logic is
variable tmp : std_logic;
begin
  tmp := '0';
  for i in d'range loop tmp := tmp or d(i); end loop; --'
  return(tmp);
end;

end log;
