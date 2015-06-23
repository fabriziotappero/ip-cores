-----------------------------------------------------------------------------
-- Package: 	multlib
-- File:	multlib.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	A set of multipliers generated from the Arithmetic Module
--		Generator at Norwegian University of Science and Technology.
------------------------------------------------------------------------------

LIBRARY ieee;
use IEEE.std_logic_1164.all;

package multlib is

component mul_17_17
  generic (mulpipe : integer := 0);
  port (
    clk  : in std_ulogic;
    holdn: in std_ulogic;
    x    : in  std_logic_vector(16 downto 0);
    y    : in  std_logic_vector(16 downto 0);
    p    : out std_logic_vector(33 downto 0)
  ); 
end component;

component mul_33_9
  port (
    x    : in  std_logic_vector(32 downto 0);
    y    : in  std_logic_vector(8 downto 0);
    p    : out std_logic_vector(41 downto 0)
  ); 
end component;

component mul_33_17
  port (
    x    : in  std_logic_vector(32 downto 0);
    y    : in  std_logic_vector(16 downto 0);
    p    : out std_logic_vector(49 downto 0)
  ); 
end component;

component mul_33_33
  generic (mulpipe : integer := 0);
  port (
    clk  : in std_ulogic;
    holdn: in std_ulogic;
    x    : in  std_logic_vector(32 downto 0);
    y    : in  std_logic_vector(32 downto 0);
    p    : out std_logic_vector(65 downto 0)
  ); 
end component;

component add32
  port(
    x	 : in  std_logic_vector(31 downto 0);
    y	 : in  std_logic_vector(31 downto 0);
    ci	 : in  std_ulogic;
    s	 : out std_logic_vector(31 downto 0);
    co	 : out std_ulogic
  );
end component;

end multlib;

