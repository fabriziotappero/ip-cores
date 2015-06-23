-- $(lic)
-- $(help_generic)
-- $(help_local)

library IEEE;
use IEEE.std_logic_1164.all;
use work.leon_target.all;
use work.amba.all;
use work.memdef.all;

package bus_comp is

type ahbmst_mp_in is record
  req              : std_logic;
  address          : std_logic_vector(31 downto 0); 
  data             : std_logic_vector(31 downto 0);
  size             : lmd_memsize;
  burst            : std_logic;
  read             : std_logic;
  lock             : std_logic;
end record;
type ahbmst_mp_in_a is array (natural range <>) of ahbmst_mp_in;

type ahbmst_mp_out is record
  data             : std_logic_vector(31 downto 0); -- memory data
  ready            : std_logic;			    -- cycle ready
  grant            : std_logic;			    -- 
  retry            : std_logic;			    -- 
  mexc             : std_logic;			    -- memory exception
  cache            : std_logic;		-- cacheable data
end record;
type ahbmst_mp_out_a is array (natural range <>) of ahbmst_mp_out;

component ahbmst_mp
  generic ( AHBMST_PORTS : integer := 4 );
  port (
    rst   : in  std_logic;
    clk   : in  std_logic;
    i     : in  ahbmst_mp_in_a(AHBMST_PORTS-1 downto 0);
    o     : out ahbmst_mp_out_a(AHBMST_PORTS-1 downto 0);
    ahbi  : in  ahb_mst_in_type;
    ahbo  : out ahb_mst_out_type
  );
end component;

component ahbarb 
  generic (
    masters : integer := 2;		-- number of masters
    defmast : integer := 0 		-- default master
  );
  port (
    rst     : in  std_logic;
    clk     : in  std_logic;
    msti    : out ahb_mst_in_vector(0 to masters-1);
    msto    : in  ahb_mst_out_vector(0 to masters-1);
    slvi    : out ahb_slv_in_vector(0 to AHB_SLV_MAX-1);
    slvo    : in  ahb_slv_out_vector(0 to AHB_SLV_MAX)
  );
end component;

component apbmst
  port (
    rst     : in  std_logic;
    clk     : in  std_logic;
    ahbi    : in  ahb_slv_in_type;
    ahbo    : out ahb_slv_out_type;
    apbi    : out apb_slv_in_vector(0 to APB_SLV_MAX-1);
    apbo    : in  apb_slv_out_vector(0 to APB_SLV_MAX-1)
  );
end component;

end bus_comp;














