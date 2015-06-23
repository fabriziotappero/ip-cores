----------------------------------------------------------------------------------------------------
-- (c) 2005-2010 Hoffmann RF & DSP    opencores@hoffmann-hochfrequenz.de
-- V1.0   2010-nov-22  published under BSD license.
----------------------------------------------------------------------------------------------------
-- Design Name:  pipestage.vhd
-- Description:		pipeline stage with variable width and depth
--
-- The length of the pipeline must be known at compile time and
-- be passed as a generic. 
-- The width is taken from the connected busses if needed.
-- There are several flavours of pipestages depending on the
-- type of the signal to be delayed. 
--
-- If n_stages = 0, clk and ce are ignored, of course.
-- If you want to use Xilinx SRL16 or 32, do not use rst.
--
-- calls other entities and libs: only ieee standard
--
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity slv_pipestage is
  generic (
    n_stages: natural  := 1
  );
  Port ( 
    clk: in  std_logic;
    ce:  in  std_logic := '1';
    rst: in  std_logic := '0';
    
    i:   in  std_logic_vector;
    o:   out std_logic_vector
    );
end slv_pipestage;


architecture rtl of slv_pipestage is


-- copy a std_logic value to all locations of a variable size std_logic_vector.
function blow_up(b: std_logic; s: integer) return std_logic_vector is
  variable r: std_logic_vector(s-1 downto 0);
begin
  for n in 0 to s-1 loop
    r(n) := b;
  end loop;
  return r;
end;



begin

assert i'length = o'length
  report "slv_pipestage: input and output length do not match: "
       & integer'image(i'length)
       & " vs. "
       & integer'image(o'length)
  severity error;


ns0: if n_stages = 0 
generate
begin
  o <= i;
end generate;


ns1: if n_stages = 1
generate
begin
  u_reg: process(clk)
  begin
    if rising_edge(clk)
    then
      if rst = '1' 
      then
        o <= blow_up('0', o'length);
      elsif ce = '1'
      then
        o <= i;
      end if;
    end if; -- rising_edge()
  end process;
end generate;



ns2: if n_stages >= 2
generate 
  type bla is array(0 to n_stages-1) of	std_logic_vector(i'range); 
	signal reg: bla;   
begin
  u_reg: process(clk)
  begin
    if rising_edge(clk)
    then
      if rst = '1' 
      then
        for n in reg'range loop
          reg(n) <= blow_up('0', o'length); -- other doesn't work here :-(
			  end loop;
      elsif ce = '1'
      then
        reg(0) <= i;
				for n in 1 to n_stages-1 loop
					reg(n) <= reg(n-1);
				end loop;
       end if;
    end if; -- rising_edge()
  end process;
  o <= reg(n_stages-1);
end generate;

end rtl;

----------------------------------------------------------------------------------------------------

-- the rest is mostly copy & paste.

----------------------------------------------------------------------------------------------------
-- std_logic version

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity sl_pipestage is
  generic (
    n_stages: natural  := 1
  );
  Port ( 
    clk: in  std_logic;
    ce:  in  std_logic := '1';
    rst: in  std_logic := '0';
    
    i:   in  std_logic;
    o:   out std_logic
    );
end sl_pipestage;


architecture rtl of sl_pipestage is

begin

ns0: if n_stages = 0 
generate
begin
  o <= i;
end generate;


ns1: if n_stages = 1
generate
begin
  u_reg: process(clk)
  begin
    if rising_edge(clk)
    then
      if rst = '1' 
      then
        o <= '0'; 
      elsif ce = '1'
      then
        o <= i;
      end if;
    end if; -- rising_edge()
  end process;
end generate;



ns2: if n_stages >= 2
generate 
  type bla is array(0 to n_stages-1) of	std_logic; 
	signal reg: bla;   
begin
  u_reg: process(clk)
  begin
    if rising_edge(clk)
    then
      if rst = '1' 
      then
    		  for n in reg'range loop
          reg(n) <= '0';
			  end loop;
      elsif ce = '1'
      then
        reg(0) <= i;
				for n in 1 to n_stages-1 loop
					reg(n) <= reg(n-1);
				end loop;
       end if;
    end if; -- rising_edge()
  end process;
  o <= reg(n_stages-1);
end generate;

end rtl;




----------------------------------------------------------------------------------------------------
-- boolean version
--
-- boolean, integer and float are unresolved types. 
-- Modelsim warns for these about potential multisource assignments.
-- This is harmless. n_stages is still unknown when the architecture is compiled.
-- Nevertheless the compiler could see that whatever n_stages might be,
-- it cannot be 1 AND 2 at the same time.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity bool_pipestage is
  generic (
    n_stages: natural  := 1
  );
  Port ( 
    clk: in  std_logic;
    ce:  in  std_logic := '1';
    rst: in  std_logic;
    
    i:   in  boolean;
    o:   out boolean
  );
end bool_pipestage;



architecture rtl of bool_pipestage is

begin

ns0: if n_stages = 0 
generate
begin
  o <= i;
end generate;


ns1: if n_stages = 1
generate
begin
  u_reg: process(clk)
  begin
    if rising_edge(clk)
    then
      if rst = '1' 
      then
        o <= false; 
      elsif ce = '1'
      then
        o <= i;
      end if;
    end if; -- rising_edge()
  end process;
end generate;


ns2: if n_stages >= 2
generate 
  type bla is array(0 to n_stages-1) of	boolean; 
	signal reg: bla;   
begin
  u_reg: process(clk)
  begin
    if rising_edge(clk)
    then
      if rst = '1' 
      then
    		  for n in reg'range loop
          reg(n) <= false;
			  end loop;
      elsif ce = '1'
      then
        reg(0) <= i;
				for n in 1 to n_stages-1 loop
					reg(n) <= reg(n-1);
				end loop;
       end if;
    end if; -- rising_edge()
  end process;
  o <= reg(n_stages-1);
end generate;

end rtl;



----------------------------------------------------------------------------------------------------
-- signed version

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity signed_pipestage is
  generic (
    n_stages: natural  := 1
  );
  Port ( 
    clk: in  std_logic;
    ce:  in  std_logic := '1';
    rst: in  std_logic := '0';
    
    i:   in  signed;
    o:   out signed
  );
end signed_pipestage;


architecture rtl of signed_pipestage is


function blow_up(b: std_logic; s: integer) return signed is
  variable r: signed(s-1 downto 0);
begin
  for n in 0 to s-1 loop
    r(n) := b;
  end loop;
  return r;
end;


begin

assert i'length = o'length
  report "signed_pipestage: input and output length do not match: "
       & integer'image(i'length)
       & " vs. "
       & integer'image(o'length)
  severity error;


ns0: if n_stages = 0 
generate
begin
  o <= i;
end generate;


ns1: if n_stages = 1
generate
begin
  u_reg: process(clk)
  begin
    if rising_edge(clk)
    then
      if rst = '1' 
      then
        o <= blow_up('0', o'length);
      elsif ce = '1'
      then
        o <= i;
      end if;
    end if; -- rising_edge()
  end process;
end generate;



ns2: if n_stages >= 2
generate 
  type bla is array(0 to n_stages-1) of	signed(i'range); 
	signal reg: bla;   
begin
  u_reg: process(clk)
  begin
    if rising_edge(clk)
    then
      if rst = '1' 
      then
    		  for n in reg'range loop
          reg(n) <= blow_up('0', o'length);
			  end loop;
      elsif ce = '1'
      then
        reg(0) <= i;
				for n in 1 to n_stages-1 loop
					reg(n) <= reg(n-1);
				end loop;
       end if;
    end if; -- rising_edge()
  end process;
  o <= reg(n_stages-1);
end generate;

end rtl;

----------------------------------------------------------------------------------------------------
-- unsigned version

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity unsigned_pipestage is
  generic (
    n_stages: natural  := 1	-- 0 to quite a few
  );
  Port ( 
    clk: in  std_logic;
    ce:  in  std_logic := '1';
    rst: in  std_logic := '0';
    
    i:   in  unsigned;
    o:   out unsigned
  );
end unsigned_pipestage;



architecture rtl of unsigned_pipestage is


function blow_up(b: std_logic; s: integer) return unsigned is
  variable r: unsigned(s-1 downto 0);
begin
  for n in 0 to s-1 loop
    r(n) := b;
  end loop;
  return r;
end;


begin

assert i'length = o'length
  report "unsigned_pipestage: input and output length do not match: "
       & integer'image(i'length)
       & " vs. "
       & integer'image(o'length)
  severity error;


ns0: if n_stages = 0 
generate
begin
  o <= i;
end generate;


ns1: if n_stages = 1
generate
begin
  u_reg: process(clk)
  begin
    if rising_edge(clk)
    then
      if rst = '1' 
      then
        o <= blow_up('0', o'length);
      elsif ce = '1'
      then
        o <= i;
      end if;
    end if; -- rising_edge()
  end process;
end generate;



ns2: if n_stages >= 2
generate 
  type bla is array(0 to n_stages-1) of	unsigned(i'range); 
	signal reg: bla;   
begin
  u_reg: process(clk)
  begin
    if rising_edge(clk)
    then
      if rst = '1' 
      then
    		  for n in reg'range loop
          reg(n) <= blow_up('0', o'length);
			  end loop;
      elsif ce = '1'
      then
        reg(0) <= i;
				for n in 1 to n_stages-1 loop
					reg(n) <= reg(n-1);
				end loop;
       end if;
    end if; -- rising_edge()
  end process;
  o <= reg(n_stages-1);
end generate;

end rtl;


----------------------------------------------------------------------------------------------------
-- integer version

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity integer_pipestage is
  generic (
    n_stages: natural  := 1
  );
  Port ( 
    clk: in  std_logic;
    ce:  in  std_logic := '1';
    rst: in  std_logic := '0';
    
    i:   in  integer;
    o:   out integer
  );
end integer_pipestage;


architecture rtl of integer_pipestage is

begin

ns0: if n_stages = 0 
generate
begin
  o <= i;
end generate;


ns1: if n_stages = 1
generate
begin
  u_reg: process(clk)
  begin
    if rising_edge(clk)
    then
      if rst = '1' 
      then
        o <= 0; 
      elsif ce = '1'
      then
        o <= i;
      end if;
    end if; -- rising_edge()
  end process;
end generate;


ns2: if n_stages >= 2
generate 
  type bla is array(0 to n_stages-1) of	integer; 
	signal reg: bla;   
begin
  u_reg: process(clk)
  begin
    if rising_edge(clk)
    then
      if rst = '1' 
      then
    		  for n in reg'range loop
          reg(n) <= 0;
			  end loop;
      elsif ce = '1'
      then
        reg(0) <= i;
				for n in 1 to n_stages-1 loop
					reg(n) <= reg(n-1);
				end loop;
       end if;
    end if; -- rising_edge()
  end process;
  o <= reg(n_stages-1);
end generate;

end rtl;


----------------------------------------------------------------------------------------------------
-- real version

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity real_pipestage is
  generic (
    n_stages: natural  := 1
  );
  Port ( 
    clk: in  std_logic;
    ce:  in  std_logic := '1';
    rst: in  std_logic := '0';
    
    i:   in  real;
    o:   out real
  );
end real_pipestage;




architecture rtl of real_pipestage is

begin

ns0: if n_stages = 0 
generate
begin
  o <= i;
end generate;


ns1: if n_stages = 1
generate
begin
  u_reg: process(clk)
  begin
    if rising_edge(clk)
    then
      if rst = '1' 
      then
        o <= 0.0; 
      elsif ce = '1'
      then
        o <= i;
      end if;
    end if; -- rising_edge()
  end process;
end generate;


ns2: if n_stages >= 2
generate 
  type bla is array(0 to n_stages-1) of	real; 
	signal reg: bla;   
begin
  u_reg: process(clk)
  begin
    if rising_edge(clk)
    then
      if rst = '1' 
      then
    		  for n in reg'range loop
          reg(n) <= 0.0;
			  end loop;
      elsif ce = '1'
      then
        reg(0) <= i;
				for n in 1 to n_stages-1 loop
					reg(n) <= reg(n-1);
				end loop;
       end if;
    end if; -- rising_edge()
  end process;
  o <= reg(n_stages-1);
end generate;

end rtl;




--------------------------------------------------------------------------------------------------
-- unsigned fixed point version
--
-- If you don't have / cannot compile the floatfixlib, comment out the rest of the file.
-- David Bishop's version as supplied with Modelsim 6.5 seems to work with ISE 12.3, too.
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
library floatfixlib;
use floatfixlib.fixed_pkg.all;

entity ufixed_pipestage is
  generic (
    n_stages: natural  := 1
  );
  Port ( 
    clk: in  std_logic;
    ce:  in  std_logic := '1';
    rst: in  std_logic := '0';
    
    i:   in  ufixed;
    o:   out ufixed
  );
end ufixed_pipestage;



architecture rtl of ufixed_pipestage is


function blow_up(b: std_logic; s: integer) return ufixed is
  variable r: ufixed(s-1 downto 0);
begin
  for n in 0 to s-1 loop
    r(n) := b;
  end loop;
  return r;
end;


begin

assert i'length = o'length
  report "ufixed_pipestage: input and output length do not match: "
       & integer'image(i'length)
       & " vs. "
       & integer'image(o'length)
  severity error;


ns0: if n_stages = 0 
generate
begin
  o <= i;
end generate;


ns1: if n_stages = 1
generate
begin
  u_reg: process(clk)
  begin
    if rising_edge(clk)
    then
      if rst = '1' 
      then
        o <= blow_up('0', o'length);
      elsif ce = '1'
      then
        o <= i;
      end if;
    end if; -- rising_edge()
  end process;
end generate;



ns2: if n_stages >= 2
generate 
  type bla is array(0 to n_stages-1) of	ufixed(i'range); 
	signal reg: bla;   
begin
  u_reg: process(clk)
  begin
    if rising_edge(clk)
    then
      if rst = '1' 
      then
    		  for n in reg'range loop
          reg(n) <= blow_up('0', o'length);
			  end loop;
      elsif ce = '1'
      then
        reg(0) <= i;
				for n in 1 to n_stages-1 loop
					reg(n) <= reg(n-1);
				end loop;
       end if;
    end if; -- rising_edge()
  end process;
  o <= reg(n_stages-1);
end generate;

end rtl;



----------------------------------------------------------------------------------------------------
-- signed fixed point version
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
library floatfixlib;
use floatfixlib.fixed_pkg.all;

entity sfixed_pipestage is
  generic (
    n_stages: natural  := 1
  );
  Port ( 
    clk: in  std_logic;
    ce:  in  std_logic := '1';
    rst: in  std_logic := '0';
    
    i:   in  sfixed;
    o:   out sfixed
  );
end sfixed_pipestage;



architecture rtl of sfixed_pipestage is


function blow_up(b: std_logic; s: integer) return sfixed is
  variable r: sfixed(s-1 downto 0);
begin
  for n in 0 to s-1 loop
    r(n) := b;
  end loop;
  return r;
end;


begin

assert i'length = o'length
  report "sfixed_pipestage: input and output length do not match: "
       & integer'image(i'length)
       & " vs. "
       & integer'image(o'length)
  severity error;


ns0: if n_stages = 0 
generate
begin
  o <= i;
end generate;


ns1: if n_stages = 1
generate
begin
  u_reg: process(clk)
  begin
    if rising_edge(clk)
    then
      if rst = '1' 
      then
        o <= blow_up('0', o'length);
      elsif ce = '1'
      then
        o <= i;
      end if;
    end if; -- rising_edge()
  end process;
end generate;



ns2: if n_stages >= 2
generate 
  type bla is array(0 to n_stages-1) of	sfixed(i'range); 
	signal reg: bla;   
begin
  u_reg: process(clk)
  begin
    if rising_edge(clk)
    then
      if rst = '1' 
      then
    		  for n in reg'range loop
          reg(n) <= blow_up('0', o'length);
			  end loop;
      elsif ce = '1'
      then
        reg(0) <= i;
				for n in 1 to n_stages-1 loop
					reg(n) <= reg(n-1);
				end loop;
       end if;
    end if; -- rising_edge()
  end process;
  o <= reg(n_stages-1);
end generate;

end rtl;

