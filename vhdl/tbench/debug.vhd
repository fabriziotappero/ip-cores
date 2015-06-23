-- $(lic)
-- $(help_generic)
-- $(help_local)

library IEEE;
use STD.TEXTIO.all;

package debug is

procedure print(s : string);

end debug;

package body debug is

procedure print(s : string) is
    variable L1 : line;
begin
  L1:= new string'(s); 
  writeline(output,L1);
end;

end debug;
