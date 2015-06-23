library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

package ahb_funct is
	
function nb_bits (A : std_logic_vector) return NATURAL;
function nb_bits (A : INTEGER) return NATURAL;

procedure fixed_priority(
t_turn: out integer;
t_grant: out integer;
req: in std_logic_vector; 
turn: in integer);
procedure round_robin(
def_elem: in integer; 
t_turn: out integer; 
t_grant: out integer; 
req: in std_logic_vector; 
turn: in integer);
procedure random_priority(
def_elem: in integer; 
t_turn: out integer; 
t_grant: out integer; 
random: in integer; 
req: in std_logic_vector; 
turn: in integer);
   
end ahb_funct;

package body ahb_funct is

  function nb_bits (A : std_logic_vector) return NATURAL is
    variable logres : NATURAL ;
    begin
     logres := 1;
     for i in A'length-1 downto 0 loop
      if A(i) = '1' then
        logres := i;
        exit;
      end if;
     end loop;
     return logres;
   end nb_bits;	 
   
   function nb_bits (A : INTEGER) return NATURAL is
    variable logres : NATURAL ;
    begin
     logres := 1;
     for i in 0 to 30 loop
      if 2**i <= A then
        logres := i+1;
      end if;
     end loop;
     return logres;
   end nb_bits;	

procedure fixed_priority(
t_turn: out integer;-- range 0 to num_elem-1; 
t_grant: out integer;
req: in std_logic_vector; 
turn: in integer-- range 0 to num_elem-1 
) is
begin
  t_grant := 0;
  t_turn := 0;
  req_for:for i in req'length-1 downto 0 loop
    if req(i) = '1' then
      t_grant := i;
    end if;
  end loop;
end fixed_priority;

procedure round_robin(
def_elem: in integer;
t_turn: out integer;-- range 0 to num_elem-1; 
t_grant: out integer;-- range 0 to num_elem-1; 
req: in std_logic_vector; 
turn: in integer-- range 0 to num_elem-1 
) is
constant req_size: integer:= req'length;
variable v_req: std_logic_vector(req_size*2-1 downto 0);
type turn_array  is array (req_size-1 downto 0) of std_logic_vector(req_size-1 downto 0);
variable v_turn: turn_array;
begin
  t_grant := def_elem;
  t_turn := turn;
  v_req := req&req;--concatenation
  for i in 0 to req_size-1 loop
    v_turn(i) := v_req(i+req_size-1 downto i);
  end loop;
  for j in 0 to req_size-1 loop
    if j=turn then
      for jj in 0 to req_size-1 loop
        if v_turn(j)(jj)='1' then
	  if turn+jj >=req'length then
	    t_turn := turn+jj-req_size;
 	    t_grant := turn+jj-req_size;
	  else	 
	    t_turn := turn+jj;  
	    t_grant := turn+jj;
	  end if;
        end if;
      end loop;  -- jj
    end if;
  end loop;  -- j    
end round_robin; 


procedure random_priority(
def_elem: in integer;
t_turn: out integer;-- range 0 to num_elem-1; 
t_grant: out integer;-- range 0 to num_elem-1; 
random: in integer;-- range 0 to 2**(nb_bits(num_elem));
req: in std_logic_vector; 
turn: in integer-- range 0 to num_elem-1
) is
constant req_size: integer:= req'length;
variable j, v_turn, upper_limit: integer;
begin
  t_grant := def_elem;
  upper_limit := 2**(nb_bits(req_size))-1;
  v_turn := turn;
  req_for:for i in upper_limit downto 0 loop
    if ((i >= random) and (i <= random+upper_limit)) then
      j := i mod req_size;
      if req(j) = '1' then
        t_grant := j;
        if turn=req_size-1 then
          v_turn := 0;
        else
          v_turn := turn+1;
        end if;
      end if;
	t_turn := v_turn;
    --synopsys translate_off
	assert (v_turn>=0 and v_turn<req_size) report "####ERROR: WRONG ARBITRATION!!!" severity failure;
    --synopsys translate_on
    end if;
  end loop;				
end random_priority;

   
end ahb_funct;



