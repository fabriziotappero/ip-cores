library ieee;
use ieee.std_logic_1164.all;

library grlib;
use grlib.amba.all;


package ac97 is

  component ac97_oc
    generic (
      slvndx : integer;
      ioaddr : integer;
      iomask : integer;
      irq    : integer);
    port (
      resetn            : in  std_logic;
      clk               : in  std_logic;
      ahbsi             : in  ahb_slv_in_type;
      ahbso             : out ahb_slv_out_type;
      bit_clk_pad_i     : in  std_logic;
      sync_pad_o        : out std_logic;
      sdata_pad_o       : out std_logic;
      sdata_pad_i       : in  std_logic;
      ac97_reset_padn_o : out std_logic;
      int_o             : out std_logic;
      dma_req_o         : out std_logic_vector(8 downto 0);
      dma_ack_i         : in  std_logic_vector(8 downto 0);
      suspended_o       : out std_logic;
      int_pol           : in std_logic
      );
  end component;

end package ac97;
