-- $(lic)
-- $(help_generic)
-- $(help_local)

library IEEE;
use IEEE.std_logic_1164.all;

package tbenchmem_comp is

component mt48lc16m16a2
   generic (index : integer := 0;		-- Byte lane (0 - 3)
	    fname : string := "soft/tbenchsoft/sdram.dat");	-- File to read from
    PORT (
        Dq    : INOUT STD_LOGIC_VECTOR (15 DOWNTO 0);
        Addr  : IN    STD_LOGIC_VECTOR (12 DOWNTO 0);
        Ba    : IN    STD_LOGIC_VECTOR (1 downto 0);
        Clk   : IN    STD_LOGIC;
        Cke   : IN    STD_LOGIC;
        Cs_n  : IN    STD_LOGIC;
        Ras_n : IN    STD_LOGIC;
        Cas_n : IN    STD_LOGIC;
        We_n  : IN    STD_LOGIC;
        Dqm   : IN    STD_LOGIC_VECTOR (1 DOWNTO 0)
    );
END component;

component iram
      generic (index : integer := 0;		-- Byte lane (0 - 3)
	       Abits: Positive := 10;		-- Default 10 address bits (1 Kbyte)
	       echk : integer := 0;		-- Generate EDAC checksum
	       tacc : integer := 10;		-- access time (ns)
	       fname : string := "soft/tbenchsoft/ram.dat");	-- File to read from
      port (  
	A : in std_logic_vector;
        D : inout std_logic_vector(7 downto 0);
        CE1 : in std_logic;
        WE : in std_logic;
        OE : in std_logic

); end component;

end tbenchmem_comp;
