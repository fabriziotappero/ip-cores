library ieee;
use ieee.std_logic_1164.all;
library techmap;
use techmap.gencomp.all;

entity clkgate is
  generic (tech : integer := 0; ncpu : integer := 1);
  port (
    rst     : in  std_ulogic;
    clkin   : in  std_ulogic;
    pwd     : in  std_logic_vector(ncpu-1 downto 0);
    clkahb  : out std_ulogic;
    clkcpu  : out std_logic_vector(ncpu-1 downto 0)
  );
end;

architecture rtl of clkgate is
signal npwd : std_logic_vector(ncpu-1 downto 0);
signal vrst : std_logic_vector(ncpu-1 downto 0);
signal clken: std_logic_vector(ncpu-1 downto 0);
signal vcc : std_ulogic;
begin

  vcc <= '1';
  cand : for i in 0 to ncpu-1 generate
    clken(i) <= not npwd(i);
    clkand0 : clkand generic map (tech) port map (clkin, clken(i), clkcpu(i));
  end generate;
  cand0 : clkand generic map (tech) port map (clkin, vcc, clkahb);

  vrst <= (others => rst);
  nreg : process(clkin)
  begin 
    if falling_edge(clkin) then 
      npwd <= pwd and vrst;
    end if;
  end process;

end;
