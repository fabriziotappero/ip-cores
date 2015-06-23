library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
package basic_size is
     function log2_ceil(N : integer) return integer;
	 function count_satges(cells : integer) return integer;
	 function odd_even_stage(i : integer; ripple_width : integer; cs_w : integer) return integer ;
constant width : integer :=8;
constant N : integer := 64;
constant logN : integer := log2_ceil(N);


--constant P_stages : integer := count_satges(N);
constant K : integer := 2;

type n_ports_array is array (0 to N-1) of std_logic_vector(width-1 downto 0);
type max_tornment_array is array (0 to N-2) of std_logic_vector(width-1 downto 0);

TYPE  WORD   IS  array (WIDTH-1 DOWNTO 0) of STD_LOGIC;
type WORD_ARRAY is array (0 TO N-1 ) of std_logic_vector(width-1 downto 0);

end package basic_size; 

package body basic_size is
function log2_ceil(N : integer) return integer is
begin

if (N <= 2) then
return 1;
else
if (N mod 2 = 0) then
return 1 + log2_ceil(N/2);
else
return 1 + log2_ceil((N+1)/2);
end if;
end if;
end function log2_ceil;

function count_satges(cells : integer) return integer is
variable K : integer := 2;  --original input.
variable P : integer := 0;  --original input.
variable a : integer := 1;  --original input.
variable series : integer := 0;  --original input.
begin
counter : while  a**2 +(a*(2*K -1))+2*(K - cells ) - K < 0 loop
				  a := a + 1;
end loop counter; 
return a;
end function count_satges;



 function odd_even_stage(i : integer; ripple_width : integer; cs_w : integer) return integer is
variable rp_width : integer := 2   ;  --original input.
begin
 if   i = 0 then
     return (ripple_width mod 2);
 elsif cs_w mod 2 = 0  then
     return i mod 2;
else return 1;
end if;
end function odd_even_stage;

end package body;