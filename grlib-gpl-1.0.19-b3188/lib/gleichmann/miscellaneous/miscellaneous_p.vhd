library ieee;
use ieee.std_logic_1164.all;

package miscellaneous is

  -- Gleichmann board types
  constant compact_v1    : integer := 1;
  constant compact_v2    : integer := 2;
  constant mini_altera   : integer := 3;
  constant mini_lattice  : integer := 4;
  constant mini_lattice2 : integer := 5;
  constant midi          : integer := 6;

  component postponer
    generic(
      HAMAX : integer := 32;
      HDMAX : integer := 32;
      delta : integer := 1
      );
    port(
      hsel_d      : out std_logic;
      hready_ba_d : out std_logic;
      hwrite_d    : out std_logic;
      hmastlock_d : out std_logic;
      haddr_d     : out std_logic_vector;
      htrans_d    : out std_logic_vector(1 downto 0);
      hsize_d     : out std_logic_vector(2 downto 0);
      hburst_d    : out std_logic_vector(2 downto 0);
      hwdata_d    : out std_logic_vector;
      hmaster_d   : out std_logic_vector(3 downto 0);
      hsel        : in  std_logic;
      hready_ba   : in  std_logic;
      hwrite      : in  std_logic;
      hmastlock   : in  std_logic;
      haddr       : in  std_logic_vector;
      htrans      : in  std_logic_vector(1 downto 0);
      hsize       : in  std_logic_vector(2 downto 0);
      hburst      : in  std_logic_vector(2 downto 0);
      hwdata      : in  std_logic_vector;
      hmaster     : in  std_logic_vector(3 downto 0)
      );
  end component;


  component ahb2wb
    generic(
      HAMAX : integer := 8;
      HDMAX : integer := 8
      );
    port(
      hclk      : in  std_logic;
      hresetn   : in  std_logic;
      hsel      : in  std_logic;
      hready_ba : in  std_logic;
      haddr     : in  std_logic_vector;
      hwrite    : in  std_logic;
      htrans    : in  std_logic_vector(1 downto 0);
      hsize     : in  std_logic_vector(2 downto 0);
      hburst    : in  std_logic_vector(2 downto 0);
      hwdata    : in  std_logic_vector;
      hmaster   : in  std_logic_vector(3 downto 0);
      hmastlock : in  std_logic;
      hready    : out std_logic;
      hresp     : out std_logic_vector(1 downto 0);
      hrdata    : out std_logic_vector;
      hsplit    : out std_logic_vector(15 downto 0);
      wb_inta_i : in  std_logic;
      wbm_adr_o : out std_logic_vector;
      wbm_dat_o : out std_logic_vector;
      wbm_sel_o : out std_logic_vector(3 downto 0);
      wbm_we_o  : out std_logic;
      wbm_stb_o : out std_logic;
      wbm_cyc_o : out std_logic;
      wbm_dat_i : in  std_logic_vector;
      wbm_ack_i : in  std_logic;
      wbm_rty_i : in  std_logic;
      wbm_err_i : in  std_logic;
      irq_o     : out std_logic
      );
  end component;

end miscellaneous;
