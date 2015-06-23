library IEEE;
use IEEE.std_logic_1164.all;
use work.amba.all;
use work.peri_io_comp.all;

package peri_mem_comp is

type wprot_out_type is record
  wprothit          : std_logic;
end record;

component wprot
  port (
    rst    : in  std_logic;
    clk    : in  std_logic;
    wpo    : out wprot_out_type;
    ahbsi  : in  ahb_slv_in_type;
    apbi   : in  apb_slv_in_type;
    apbo   : out apb_slv_out_type
  );
end component;

type sdram_out_type is record
  sdcke    	: std_logic_vector ( 1 downto 0);  -- clk en
  sdcsn    	: std_logic_vector ( 1 downto 0);  -- chip sel
  sdwen    	: std_logic;                       -- write en
  rasn   	: std_logic;                       -- row addr stb
  casn   	: std_logic;                       -- col addr stb
  dqm    	: std_logic_vector ( 3 downto 0);  -- data i/o mask
end record;

type sdram_in_type is record
  haddr         : std_logic_vector(31 downto 0);  -- memory address
  rhaddr        : std_logic_vector(31 downto 0);  -- memory address
  hready        : std_logic;
  hsize         : std_logic_vector(1 downto 0);
  hsel          : std_logic;
  hwrite        : std_logic;
  htrans        : std_logic_vector(1 downto 0);
  rhtrans       : std_logic_vector(1 downto 0);
  nhtrans       : std_logic_vector(1 downto 0);
  idle     	: std_logic;
  enable   	: std_logic;

end record;
  
type sdram_mctrl_out_type is record
  address       : std_logic_vector(16 downto 2);
  busy          : std_logic;
  aload         : std_logic;
  bdrive        : std_logic;
  hready        : std_logic;
  hsel          : std_logic;
  hresp    	: std_logic_vector ( 1 downto 0);

end record;

component sdmctrl
  port (
    rst    : in  std_logic;
    clk    : in  std_logic;
    sdi    : in  sdram_in_type;
    sdo    : out sdram_out_type;
    apbi   : in  apb_slv_in_type;
    apbo   : out apb_slv_out_type;
    wpo    : in  wprot_out_type;
    sdmo   : out sdram_mctrl_out_type
  );
end component; 

type memory_in_type is record
  data          : std_logic_vector(31 downto 0); -- Data bus address
  brdyn         : std_logic;
  bexcn         : std_logic;
  writen        : std_logic;
  wrn           : std_logic_vector(3 downto 0);

end record;

type memory_out_type is record
  address       : std_logic_vector(27 downto 0);
  data          : std_logic_vector(31 downto 0);

  ramsn         : std_logic_vector(4 downto 0);
  ramoen        : std_logic_vector(4 downto 0); 
  iosn          : std_logic;
  romsn         : std_logic_vector(1 downto 0);
  oen           : std_logic;
  writen        : std_logic;
  wrn           : std_logic_vector(3 downto 0);
  bdrive        : std_logic_vector(3 downto 0);
  read          : std_logic;
end record;

type mctrl_out_type is record
  pioh             : std_logic_vector(15 downto 0);

end record;

component mctrl 
  port (
    rst    : in  std_logic;
    clk    : in  std_logic;
    memi   : in  memory_in_type;
    memo   : out memory_out_type;
    ahbsi  : in  ahb_slv_in_type;
    ahbso  : out ahb_slv_out_type;
    apbi   : in  apb_slv_in_type;
    apbo   : out apb_slv_out_type;
    pioo   : in  pio_out_type;
    wpo    : in  wprot_out_type;
    sdo    : out sdram_out_type;
    mctrlo : out mctrl_out_type
  );
end component; 


end peri_mem_comp;
